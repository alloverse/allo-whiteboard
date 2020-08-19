local cairo = require("cairo")
local class = require('pl.class')
local tablex = require('pl.tablex')
local vec3 = require("modules.vec3")
local mat4 = require("modules.mat4")

local BOARD_RESOLUTION = 128

class.Whiteboard(ui.View)

function Whiteboard:_init(bounds)
  self:super(bounds)
  print("+ initializing...  +")
  print("+ ---------------- +")
  print("+ width: " .. bounds.size.width .. "         +")
  print("+ height: " .. bounds.size.height .. "        +")
  print("+ ---------------- +")

  self.isDirty = false;
  self.brushSize = 3;

  -- Table keeping tabs on users and if they initated intention (is allowed to draw)
  -- {obj user, bool hasIntentToDraw}
  self.drawingUserControlTable = {}

  self.sr = cairo.image_surface(cairo.cairo_format("rgb24"), bounds.size.width * BOARD_RESOLUTION, bounds.size.height * BOARD_RESOLUTION)  
  self.cr = self.sr:context()

  self:clearBoard()

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
  local d2 = s.depth / 2.0
  local mySpec = tablex.union(ui.View.specification(self), {
      geometry = {
          type = "inline",
          --          #tl?                #tr?              #bl?               #br?
          vertices=   {{-w2, h2, 0.0},    {w2, h2, 0.0},    {-w2, -h2, 0.0},   {w2, -h2, 0.0}},
          uvs=        {{0.0, 0.0},        {1.0, 0.0},       {0.0, 1.0},        {1.0, 1.0}},
          triangles=  {{0, 1, 3},         {3, 2, 0},        {0, 2, 3},         {3, 1, 0}},
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
        self:_attemptToDraw(sender, body[3][1], body[3][2], body[3][3]);

    elseif body[1] == "point-exit" then
        -- print("No longer pointing at the whiteboard");

    elseif body[1] == "poke" then
        -- set whiteboard ability to pick up "point" interactions depending on poke is true or false.
        self.drawingUserControlTable[sender] = body[2];

        -- print("= USER CONTROL TABLE =")
        -- for key,value in pairs(self.drawingUserControlTable) do 
        --   print(key, value)
        -- end
    end

end


function Whiteboard:_attemptToDraw(sender, worldX, worldY, worldZ)
  -- Checks if the user is allowed to draw
  if (self.drawingUserControlTable[sender] ~= true ) then return end

  local worldPoint = vec3(worldX, worldY, worldZ)
  local inverted = mat4.invert({}, self.bounds.pose.transform)
  local localPoint = vec3(mat4.mul_vec4({}, inverted, {worldPoint.x, worldPoint.y, worldPoint.z, 1}))
  
  local localPointTopLeftOrigo = vec3(self.bounds.size.width/2 + localPoint.x, self.bounds.size.height/2 + localPoint.y, self.bounds.size.depth/2 + localPoint.z)
  local normalizedLocalPointTopLeftOrigo = vec3(localPointTopLeftOrigo.x / self.bounds.size.width, localPointTopLeftOrigo.y / self.bounds.size.height, localPointTopLeftOrigo.z / self.bounds.size.depth)

  -- print("----------------------")
  -- print(worldPoint)
  -- print(localPoint)
  -- print(localPointTopLeftOrigo)
  -- print(normalizedLocalPointTopLeftOrigo)

    self:_drawAt( normalizedLocalPointTopLeftOrigo.x * self.bounds.size.width * BOARD_RESOLUTION, 
                    normalizedLocalPointTopLeftOrigo.y * self.bounds.size.height * BOARD_RESOLUTION)
end

function Whiteboard:_drawAt(x, y)
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

function Whiteboard:resize(bounds)
  
  -- TODO:
  -- Add a maxiumum size restriction
  -- Update (recreate) the cairo surface to the new size of the whiteboard
  -- Decide how resizing will be done by the user (dragging interaction?)

  print("+ resizing...    +")
  print("+ ---------------- +")
  print("+ width: " .. bounds.size.width .. "         +")
  print("+ height: " .. bounds.size.height .. "        +")
  print("+ ---------------- +")

  
 


  local pattern = self.cr:source()

  local newsr = cairo.image_surface(cairo.cairo_format("rgb24"), bounds.size.width * BOARD_RESOLUTION, bounds.size.height * BOARD_RESOLUTION)  
  local newcr = newsr:context()

  -- newcr:rgb(255, 0, 255)
  -- newcr:paint()

  newcr:source(self.sr) --TODO: set x & y of the new pattern according to cr:source(patt | sr, [x, y])

  self.sr = newsr
  self.cr = newcr

  self.cr:paint()

  -- self.isDirty = true
  self.bounds = bounds
  self:updateComponents(
    self:specification()
  )

end

function Whiteboard:onHorizontalResizeActive()
  print("horizontal resizing active!")
end


function Whiteboard:clearBoard()
  
  -- DRAWS THE WHOLE BOARD BLACK
  self.cr:rgb(0, 0, 0)
  self.cr:paint()

  -- DRAWS ORIENTATION MARKERS
  -- self.cr:rgb(255, 0, 0)    -- RED, TOP LEFT
  -- self.cr:circle(0, 0, 16)
  -- self.cr:fill()

  -- self.cr:rgb(0, 255, 0)    -- GREEN, TOP RIGHT
  -- self.cr:circle(self.bounds.size.width*BOARD_RESOLUTION, 0, 16)
  -- self.cr:fill()

  -- self.cr:rgb(255, 255, 0)  -- YELLOW, BOTTOM LEFT
  -- self.cr:circle(0, self.bounds.size.height*BOARD_RESOLUTION, 16)
  -- self.cr:fill()

  -- self.cr:rgb(255, 0, 255)  -- MAGENTA, BOTTOM RIGHT
  -- self.cr:circle(self.bounds.size.width*BOARD_RESOLUTION, self.bounds.size.height*BOARD_RESOLUTION, 16)
  -- self.cr:fill()

  -- -- DRAWS A BORDER ALONG THE EDGES OF THE WHITEBOARD
  -- self.cr:rgb(255, 255, 255)  -- WHITE
  -- self.cr:rectangle(0, 0, 5, self.bounds.size.height*BOARD_RESOLUTION)
  -- self.cr:rectangle(self.bounds.size.width*BOARD_RESOLUTION-5, 0, 5, self.bounds.size.height*BOARD_RESOLUTION)
  -- self.cr:rectangle(0, 0, self.bounds.size.width*BOARD_RESOLUTION, 5)
  -- self.cr:rectangle(0, self.bounds.size.height*BOARD_RESOLUTION-5, self.bounds.size.width*BOARD_RESOLUTION, 5)
  -- self.cr:fill()

  self:broadcastTextureChanged()
end

return Whiteboard