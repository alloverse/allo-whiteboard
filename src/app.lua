
local class = require('pl.class')
local tablex = require('pl.tablex')
local pretty = require('pl.pretty')
local vec3 = require("modules.vec3")
local mat4 = require("modules.mat4")
local cairo = require("cairo")

local client = Client(
    arg[1], 
    "allo-whiteboard"
)
local app = App(client)
local BOARD_RESOLUTION = 128

print("+==================+")
print("+ WHITEBOARD ADDED +")
print("+==================+")

class.Whiteboard(ui.View)

function Whiteboard:_init(bounds)
  self:super(bounds)
  print("+ initiating...    +")
  print("+ ---------------- +")
  print("+ width: " .. bounds.size.width .. "         +")
  print("+ height: " .. bounds.size.height .. "        +")
  print("+ ---------------- +")

  self.isReadyForDrawing = false
  self.isDirty = false;
  self.brushSize = 3;

  self.sr = cairo.image_surface(cairo.cairo_format("rgb24"), bounds.size.width * BOARD_RESOLUTION, bounds.size.height * BOARD_RESOLUTION)  
  self.cr = self.sr:context()

  self:resetBoard()

end

function Whiteboard:specification()

  self.sr:save_png("whiteboard.png")

  local fh = io.open("whiteboard.png", "rb")
  local image_to_convert = fh:read("*a")
  fh:close()
  local encoded_image = ui.util.base64_encode(image_to_convert)


  local s = self.bounds.size
  local w2 = s.width / 2.0
  local h2 = s.height / 2.0
  local mySpec = tablex.union(ui.View.specification(self), {
      geometry = {
          type = "inline",
          --          #tl?                #tr?              #bl?               #br?
          vertices=   {{w2, -h2, 0.0},    {w2, h2, 0.0},    {-w2, -h2, 0.0},   {-w2, h2, 0.0}},
          uvs=        {{0.0, 0.0},        {0.0, 1.0},       {1.0, 0.0},        {1.0, 1.0}},
          triangles=  {{0, 3, 1},         {0, 2, 3},        {1, 3, 0},         {3, 2, 0}},
          texture= encoded_image
      },
      collider= {
          type= "box",
          width= s.width, height= s.height, depth= s.depth
      }
  })
  return mySpec
end


function Whiteboard:onInteraction(inter, body, sender)
    if body[1] == "point" then
        --print("pointing at the whiteboard");
        local worldPoint = vec3(body[3][1], body[3][2], body[3][3])
        local inverted = mat4.invert({}, self.bounds.pose.transform)
        local localPoint = vec3(mat4.mul_vec4({}, inverted, {worldPoint.x, worldPoint.y, worldPoint.z, 1}))
        
        local localPointTopLeftOrigo = vec3(self.bounds.size.width/2 - localPoint.x, self.bounds.size.height/2 - localPoint.y, self.bounds.size.depth/2 - localPoint.z)
        local normalizedLocalPointTopLeftOrigo = vec3(localPointTopLeftOrigo.x / self.bounds.size.width, localPointTopLeftOrigo.y / self.bounds.size.height, localPointTopLeftOrigo.z / self.bounds.size.depth)

        -- print("----------------------")
        -- print(worldPoint)
        -- print(localPoint)
        -- print(localPointTopLeftOrigo)
        -- print(normalizedLocalPointTopLeftOrigo)

        if self.isReadyForDrawing then
          --print("Drawing on the whiteboard...");
          self:drawPixel(normalizedLocalPointTopLeftOrigo.x * self.bounds.size.width * BOARD_RESOLUTION, normalizedLocalPointTopLeftOrigo.y * self.bounds.size.height *  BOARD_RESOLUTION)
        end

    elseif body[1] == "point-exit" then
        -- print("No longer pointing at the whiteboard");

    elseif body[1] == "poke" then
        -- set whiteboard to be "ready to recieve point events" when picking up "point" interactions
        self.isReadyForDrawing = body[2]
    end
end

function Whiteboard:drawPixel(x, y)
  -- print("x: ", x, " y: ", y)

  self.cr:rgb(255, 255, 255)
  self.cr:circle(x, y, self.brushSize)
  self.cr:fill()
  
  self.isDirty = true
end

function Whiteboard:broadcastTextureChanged()
  if self.app == nil then return end

  local geom = self:specification().geometry
  self:updateComponents({geometry = geom})
  self.isDirty = false
end

function Whiteboard:sendIfDirty()
  if self.isDirty then
    self:broadcastTextureChanged()
  end
end

function Whiteboard:setBrushSize(newbrushSize)
  self.brushSize = newbrushSize
end


function Whiteboard:resetBoard()
  print("Resetting board!")
  
  -- DRAWS THE WHOLE BOARD BLACK
  self.cr:rgb(0, 0, 0)
  self.cr:paint()

  -- DRAWS ORIENTATION MARKERS
  self.cr:rgb(255, 0, 0)    -- RED, TOP LEFT
  self.cr:circle(0, 0, 16)
  self.cr:fill()

  self.cr:rgb(0, 255, 0)    -- GREEN, TOP RIGHT
  self.cr:circle(self.bounds.size.width*BOARD_RESOLUTION, 0, 16)
  self.cr:fill()

  self.cr:rgb(255, 255, 0)  -- YELLOW, BOTTOM LEFT
  self.cr:circle(0, self.bounds.size.height*BOARD_RESOLUTION, 16)
  self.cr:fill()

  self.cr:rgb(255, 0, 255)  -- MAGENTA, BOTTOM RIGHT
  self.cr:circle(self.bounds.size.width*BOARD_RESOLUTION, self.bounds.size.height*BOARD_RESOLUTION, 16)
  self.cr:fill()

  -- DRAWS A BORDER ALONG THE EDGES OF THE WHITEBOARD
  self.cr:rgb(255, 255, 255)  -- WHITE
  self.cr:rectangle(0, 0, 5, self.bounds.size.height*BOARD_RESOLUTION)
  self.cr:rectangle(self.bounds.size.width*BOARD_RESOLUTION-5, 0, 5, self.bounds.size.height*BOARD_RESOLUTION)
  self.cr:rectangle(0, 0, self.bounds.size.width*BOARD_RESOLUTION, 5)
  self.cr:rectangle(0, self.bounds.size.height*BOARD_RESOLUTION-5, self.bounds.size.width*BOARD_RESOLUTION, 5)
  self.cr:fill()

  self:broadcastTextureChanged()
end



local whiteboardView = Whiteboard(ui.Bounds(1.5, 1, 0,   2, 1, 0.1))

-- ADDS THE GRAB HANDLE
local grabHandle = ui.GrabHandle(ui.Bounds(-0.9, -0.5, 0.5,   0.2, 0.2, 0.2))
whiteboardView:addSubview(grabHandle)

-- ADDS THE RESET BUTTON
local resetButton = ui.Button(ui.Bounds(0, -0.4, 0.5,   0.2, 0.2, 0.2):rotate(math.pi/4, 1, 0 ,0))
resetButton.texture = " iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAADqSURBVHgB7ZZRDkQRDEVrMguwBEuw/x9LsARL6ajExHho62P8uIlIqN6Tx6MGABAO6gWHdQEeAM45CCGUnhMilsbJWltyeu/HedqWA5GUUsIMgf1826pWMdkcY4wljvpBzO8AmZK5BIIDaM0XuZ4LpRArAKH5GEAKMQNQmM8BeojR/s0ANOcImMmSgMzzCeYSfRvF0hqBOZpKcUr3JjwO8O4HZlerMQY0kuY5/gXuX3ABWACumBhJU9SQRO/53x8jyZM6A9AUNbBrvgJQQuyZcwAKiP394wB6CFFRqikmJAAVYlbU3Kv4AnwAjUeU7dSfDjoAAAAASUVORK5CYII="
resetButton.onActivated = function()
  whiteboardView:resetBoard()
end
whiteboardView:addSubview(resetButton)

-- ADDS BRUSH SIZE DOWN BUTTON
local brushSizeDownButton = ui.Button(ui.Bounds(0.7, -0.5, 0.5,  0.2, 0.2, 0.2):rotate(math.pi/4, 1, 0 ,0) )
brushSizeDownButton.texture = " iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAGzSURBVHgB7VftkYIwEF2uAkuwBDvQDixBO9AOpBOgAqAChgqgA+gAOsjlMRdcSIQEnMMfvpnMxDUfbz+yu3hEJGhD/NDG+BJwIrDb7ejxeFCWZVRVFQkhutE0TSe73W603+/JFWJuyEOFvEDYIgiCbo/N2bMEpFZCaihcgT33+30dAWlu7WBY4nq9DjQ8HA6dLI5jbT3OWEQAmnNIn4vT6WTlLqzlmLGE+RBu9qIohAxAW592a7GHu2MiJnRhGIYDzV0u5yS4JeA6KwJgyuEQzdqAyzheKDIUwF8KSZIsvlwN/nx939f+1xLR+Xzu5zKqaS2iKOrnx+PRuGbAiAcfnpeSu4IMLkVMjO/z/iZPNuL50/M8o9wGr/ZyOfB5xaiu636+pLCMId3Yz9u2JScC8hn1c5jOZZgIlGU5TyDP835+uVxoLfirStPUuEbLYBw2+Z8m6oJFUptOHu9KxegRyCYVK+abFiMapWRlCZu6AJetLsdqIHePgaZDBucgS4IYGhJT22bK/9YElCU2a8m4hrxHmAMs8bamdEwErRou4FaBzyGDuV1fjFaM/hvfT7PNCfwCLC5MjI43pfEAAAAASUVORK5CYII="
brushSizeDownButton.onActivated = function()
  whiteboardView:setBrushSize(whiteboardView.brushSize - 1)
end
whiteboardView:addSubview(brushSizeDownButton)

-- ADDS BRUSH SIZE UP BUTTON
local brushSizeUpButton = ui.Button(ui.Bounds(0.9, -0.5, 0.5,  0.2, 0.2, 0.2):rotate(math.pi/4, 1, 0 ,0) )
brushSizeUpButton.texture = " iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAG6SURBVHgB7VfbsYIwEF1uBZZgCXagHViCdqAdaCdABUAFDBVAB9ABdJCbw1xwycMEcS5+eGYysy55nH1kswZEJGhF/NDK+BKYRWCz2dDtdqM8z6muaxJC9KNt2153uVxou93SXAjXkJsKeYDwRRiG/RqfvZ0EpFVCWijmAmuu1+syAtLd2sbwxPl8nli42+16XZIk2nzs8RIBWM4hYy4Oh4NXuDCXw+EJ8ybc7WVZCpmAvjHt52IND8eTnNCVURRNLDcdrsJEgnsCofMiAKYcNuYuAhgIGYfFi1MF4jUgTVOrm30IYPDre7/fte9aIToej6Mss5qWIo7jUd7v98Y5E0Y8+XC9yGKxC2QIKXJCPS/4Ex5sxONnEARGvQ9sa7ke+LzHqGmaUX7lYVEhwzjKXdfRLALyGo0yXMeHCtt3TqCqKjeBoihG+XQ60VLwW5VlmXGOVsE4bPXfpw54FrXnxeNdpRg9AvmUYvqEx4iUkjx4wqfLQcgWP8fDQO1WgaZDJuekSoIYGhJT22aq/94EBk+s1pJxC3mP4AI88bamVCWCVg0HcK8g5tDB3XOSFUN7jP4b379mqxP4BQb3iETeAvICAAAAAElFTkSuQmCC"
brushSizeUpButton.onActivated = function()
  whiteboardView:setBrushSize(whiteboardView.brushSize + 1)
end
whiteboardView:addSubview(brushSizeUpButton)

app.mainView = whiteboardView

-- Runs sendIfDirty() 10 times per second
app:scheduleAction(0.05, true, function() 
  whiteboardView:sendIfDirty()
end)

app:connect()
app:run()
