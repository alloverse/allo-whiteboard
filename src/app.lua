
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
local isReadyForDrawing = false
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

  self.sr = cairo.image_surface(cairo.cairo_format("rgb24"), bounds.size.width * BOARD_RESOLUTION, bounds.size.height * BOARD_RESOLUTION)  
  self.cr = self.sr:context()

  -- DRAWS ORIENTATION MARKERS
  self.cr:rgb(255, 0, 0)    -- RED, TOP LEFT
  self.cr:circle(  0,    0,  16)
  self.cr:fill()

  self.cr:rgb(0, 255, 0)    -- GREEN, TOP RIGHT
  self.cr:circle(  bounds.size.width*BOARD_RESOLUTION,  0,  16)
  self.cr:fill()

  self.cr:rgb(255, 255, 0)  -- YELLOW, BOTTOM LEFT
  self.cr:circle(  0,    bounds.size.height*BOARD_RESOLUTION, 16)
  self.cr:fill()

  self.cr:rgb(255, 0, 255)  -- MAGENTA, BOTTOM RIGHT
  self.cr:circle(  bounds.size.width*BOARD_RESOLUTION,  bounds.size.height*BOARD_RESOLUTION, 16)
  self.cr:fill()

  -- DRAWS A BORDER ALONG THE EDGES OF THE WHITEBOARD
  self.cr:rgb(255, 255, 255)  -- WHITE
  self.cr:rectangle(0, 0, 5, bounds.size.height*BOARD_RESOLUTION)
  self.cr:rectangle(bounds.size.width*BOARD_RESOLUTION-5, 0, 5, bounds.size.height*BOARD_RESOLUTION)
  self.cr:rectangle(0, 0, bounds.size.width*BOARD_RESOLUTION, 5)
  self.cr:rectangle(0, bounds.size.height*BOARD_RESOLUTION-5, bounds.size.width*BOARD_RESOLUTION, 5)
  self.cr:fill()

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

        if isReadyForDrawing then
          --print("Drawing on the whiteboard...");
          self:drawPixel(normalizedLocalPointTopLeftOrigo.x * self.bounds.size.width * BOARD_RESOLUTION, normalizedLocalPointTopLeftOrigo.y * self.bounds.size.height *  BOARD_RESOLUTION)
        end

    elseif body[1] == "point-exit" then
        -- print("No longer pointing at the whiteboard");

    elseif body[1] == "poke" then
        -- set whiteboard to be "ready to recieve point events" when picking up "point" interactions
        isReadyForDrawing = body[2]
    end
end

function Whiteboard:drawPixel(x, y)
  --print("x: " .. x .. " y: " .. y)

  self.cr:rgb(255, 255, 255)
  self.cr:circle(x, y, 5)
  self.cr:fill()
  
  self:broadcastTextureChanged()

end

function Whiteboard:broadcastTextureChanged()
  local geom = self:specification().geometry
  self:updateComponents({geometry = geom})
end


local whiteboardView = Whiteboard(ui.Bounds(1.5, 1, 0, 2, 1, 0.1))


app.mainView = whiteboardView
app:connect()
app:run()