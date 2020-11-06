local cairo = require("cairo")
local class = require('pl.class')
local tablex = require('pl.tablex')
local vec3 = require("modules.vec3")
local mat4 = require("modules.mat4")
local pretty = require('pl.pretty')

local BOARD_RESOLUTION = 128

class.DrawableSurface(ui.View)

function DrawableSurface:_init(bounds)
  self:super(bounds)

  self.isDirty = false;
  self.brushSize = 3;

  -- Table keeping tabs on users and if they initated intention (is allowed to draw)
  -- {obj user, bool hasIntentToDraw}
  self.drawingUserControlTable = {}

  self.sr = cairo.image_surface(cairo.cairo_format("rgb24"), bounds.size.width * BOARD_RESOLUTION, bounds.size.height * BOARD_RESOLUTION)  
  self.cr = self.sr:context()

  self:clearBoard()
end

function DrawableSurface:specification()
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
      },
      cursor= {
        name= "brushCursor",
        size= self.brushSize
      }
  })
  return mySpec
end

function DrawableSurface:onInteraction(inter, body, sender)
  if body[1] == "point" then
    -- Pointing at the board
    self:_attemptToDraw(sender, body[3][1], body[3][2], body[3][3]);
  elseif body[1] == "point-exit" then
    -- No longer pointing at the board
  elseif body[1] == "poke" then
    -- set whiteboard ability to pick up "point" interactions depending on poke is true or false.
    self.drawingUserControlTable[sender] = body[2];
  end
end


function DrawableSurface:_attemptToDraw(sender, worldX, worldY, worldZ)
  
  -- Checks if the user is allowed to draw
  if (self.drawingUserControlTable[sender] ~= true ) then return end
  
  local worldPoint = vec3(worldX, worldY, worldZ)
  local inverted = mat4.invert({}, self:transformFromWorld())
  
  local localPoint = vec3(mat4.mul_vec4({}, inverted, {worldPoint.x, worldPoint.y, worldPoint.z, 1}))
  local localPointBottomLeftOrigo = vec3(self.bounds.size.width/2 + localPoint.x, self.bounds.size.height/2 + localPoint.y, self.bounds.size.depth/2 + localPoint.z)
  
  -- print("----------------------")
  -- print("worldPoint..........................", worldPoint)
  -- print("localPoint (center origo)...........", localPoint)
  -- print("localPointBottomLeftOrigo...........", localPointBottomLeftOrigo)

  self:_drawAt( localPointBottomLeftOrigo.x * BOARD_RESOLUTION, 
                localPointBottomLeftOrigo.y * BOARD_RESOLUTION)
end

function DrawableSurface:_drawAt(x, y)
  self.cr:rgb(255, 255, 255)
  self.cr:circle(x, y, self.brushSize)
  self.cr:fill()
  
  self.isDirty = true
end

function DrawableSurface:broadcastTextureChanged()
  if self.app == nil then return end

  local geom = self:specification().geometry
  self:updateComponents({geometry = geom})
  self.isDirty = false
end

function DrawableSurface:sendIfDirty()
  if self.isDirty then
    self:broadcastTextureChanged()
  end
end

function DrawableSurface:clearBoard()
  self.cr:rgb(0, 0, 0)
  self.cr:paint()
 
  self:broadcastTextureChanged()
end

function DrawableSurface:setBrushSize(newbrushSize)
  self.brushSize = newbrushSize
 
  local c = self:specification().cursor
  self:updateComponents({cursor = c})
end

function DrawableSurface:resize(newWidth, newHeight)

  local oldWidth = self.bounds.size.width
  local oldHeight = self.bounds.size.height

  if (oldWidth == newWidth and oldHeight == newHeight) then return end

  local newCalculatedWidth = newWidth * BOARD_RESOLUTION
  local newCalculatedHeight = newHeight * BOARD_RESOLUTION
  local oldCalculatedWidth = oldWidth * BOARD_RESOLUTION
  local oldCalculatedHeight = oldHeight * BOARD_RESOLUTION

  local newSourceX = math.floor(((newCalculatedWidth - oldCalculatedWidth)/2)+0.5)
  local newSourceY = math.floor(((newCalculatedHeight - oldCalculatedHeight)/2)+0.5)
  
  local newsr = cairo.image_surface(cairo.cairo_format("rgb24"), newCalculatedWidth, newCalculatedHeight)  
  local newcr = newsr:context()

  newcr:source(self.sr, newSourceX, newSourceY)

  self.sr = newsr
  self.cr = newcr
  self.cr:paint()

  self.bounds.size.width = newWidth
  self.bounds.size.height = newHeight 

  self:updateComponents(
    self:specification()
  )
end


return DrawableSurface