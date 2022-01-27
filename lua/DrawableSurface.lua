local cairo = require("cairo")
local class = require('pl.class')
local tablex = require('pl.tablex')
local vec3 = require("modules.vec3")
local mat4 = require("modules.mat4")
local pretty = require('pl.pretty')

local ffi = require('ffi')

local BOARD_RESOLUTION = 512

class.DrawableSurface(ui.View)

function DrawableSurface:_init(bounds)
  self:super(bounds)

  self.brushSize = 3;

  -- Table keeping tabs on users and if they initated intention (is allowed to draw)
  self.accessControlTable = {}

  self.videoSurface = nil

  local width = bounds.size.width * BOARD_RESOLUTION
  local height = bounds.size.height * BOARD_RESOLUTION
  self.sr = cairo.image_surface(cairo.cairo_format("rgb24"), width, height)
  self.cr = self.sr:context()

  self:setResolution(width, height)

  self.backgroundColor = {0.051,0.023,0.101}
  self.brushColor = {1, 1, 1}



  self:clearBoard()
end

function DrawableSurface:specification()
  local s = self.bounds.size
  local mySpec = {
      collider= {
          type= "box",
          width= s.width, height= s.height, depth= s.depth
      },
      grabbable = {
        grabbable = true,
        actuate_on= "$parent"
      },
      cursor= {
        name= "brushCursor",
        size= self.brushSize
      }
  }
  return tablex.union(ui.View.specification(self), mySpec)
end

function DrawableSurface:onInteraction(inter, body, sender)
  local currentControlTable = self.accessControlTable[sender]
  
  if body[1] == "point" then
    -- Sender is pointing at the board, attempt to draw at the coordinate they're pointing
    self:_attemptToDraw(sender, body[3][1], body[3][2], body[3][3]);
  elseif body[1] == "point-exit" then
    -- Sender is no longer pointing at the board - terminate their chain of previous coordinates
    if currentControlTable==nil then return end
    currentControlTable.previousCoord = {nil, nil}
  elseif body[1] == "poke" then
    -- A poke initiates the senders' intention to interact with the board
    -- Create their unique entry into the accessControlTable and set their "allowedToDraw" flag based on wether they pushed or released the poke.
    self.accessControlTable[sender] = {allowedToDraw = body[2], previousCoord={x=nil, y=nil}}

    -- If the poke is released, terminate their chain of previous coordinates
    if (body[2] == false) then
      currentControlTable.previousCoord = {nil, nil}
    end
  end
end

function DrawableSurface:_attemptToDraw(sender, worldX, worldY, worldZ)
  local currentControlTable = self.accessControlTable[sender]

  -- If the user hasn't poked the board, they don't have an entry in the accessControlTable and thus we don't need to try to draw.
  if (currentControlTable == nil or currentControlTable.allowedToDraw == false ) then return end

  local worldPoint = vec3(worldX, worldY, worldZ)
  local inverted = mat4.invert({}, self:transformFromWorld())
  
  local localPoint = vec3(mat4.mul_vec4({}, inverted, {worldPoint.x, worldPoint.y, worldPoint.z, 1}))
  local localPointBottomLeftOrigo = vec3(self.bounds.size.width/2 + localPoint.x, self.bounds.size.height/2 + localPoint.y, self.bounds.size.depth/2 + localPoint.z)
  
  -- print("----------------------")
  -- print("worldPoint..........................", worldPoint)
  -- print("localPoint (center origo)...........", localPoint)
  -- print("localPointBottomLeftOrigo...........", localPointBottomLeftOrigo)

  self:_drawAt(sender, localPointBottomLeftOrigo.x * BOARD_RESOLUTION, localPointBottomLeftOrigo.y * BOARD_RESOLUTION)
end

function DrawableSurface:_drawAt(sender, x, y)
  local currentControlTable = self.accessControlTable[sender]

  self.cr:move_to(x,y)
  self.cr:rgb(unpack(self.brushColor))

  if currentControlTable.previousCoord.x ~= nil then
    -- There's a set of valid previous coordinates, to draw a line from them to the current coordinate.
    self.cr:line_cap("round")
    self.cr:line_to(currentControlTable.previousCoord.x, currentControlTable.previousCoord.y)
    self.cr:line_width(self.brushSize*2)
    self.cr:stroke()
  else 
    -- There's no valid previous coordinate, so don't interpolate. Instead, draw a circle (point).
    self.cr:circle(x, y, self.brushSize)
    self.cr:fill()
  end
  
  currentControlTable.previousCoord.x = x
  currentControlTable.previousCoord.y = y

  self:broadcastTextureChanged()
end

function DrawableSurface:broadcastTextureChanged()
  self.sr:flush()
  local bitmap = self.sr:bitmap()
  local bpp = bitmap.stride / bitmap.w
  self.videoSurface:sendFrame(ffi.string(bitmap.data, (bitmap.stride/bpp) * bitmap.h * bpp), bitmap.w, bitmap.h, bitmap.format, bitmap.stride)
end

function DrawableSurface:clearBoard()
  self.cr:rgb(unpack(self.backgroundColor))
  self.cr:paint()
 
  self:broadcastTextureChanged()
end

function DrawableSurface:setBrushSize(newbrushSize)
  self.brushSize = newbrushSize
 
  local c = self:specification().cursor
  self:updateComponents({cursor = c})
end

function DrawableSurface:resize(newWidth, newHeight, commit)
  local oldWidth = math.floor(self.bounds.size.width + 0.5)
  local oldHeight = math.floor(self.bounds.size.height + 0.5)

  if (oldWidth == newWidth and oldHeight == newHeight) then return false end

  if commit then
    print("committing to new size")

    local newResX = math.floor(newWidth * BOARD_RESOLUTION + 0.5)
    local newResY = math.floor(newHeight * BOARD_RESOLUTION + 0.5)
    
    local newsr = cairo.image_surface(cairo.cairo_format("rgb24"), newResX, newResY)  
    local newcr = newsr:context()

    self:setResolution(newResX, newResY)

    newcr:rgb(unpack(self.backgroundColor))
    newcr:paint()

    local newSourceX = (newResX - self.sr:width())/2
    local newSourceY = (newResY - self.sr:height())/2

    newcr:source(self.sr, newSourceX, newSourceY)

    self.sr = newsr
    self.cr = newcr
    
    self.cr:paint()
  end

  self.bounds.size.width = newWidth
  self.bounds.size.height = newHeight 

  self.videoSurface.bounds.size.width = newWidth
  self.videoSurface.bounds.size.height = newHeight
  self.videoSurface:setBounds()

  self:updateComponents(
    self:specification()
  )

  return true
end

function DrawableSurface:setResolution(width, height)
  if self.videoSurface then 
    self.videoSurface:removeFromSuperview()
  end

  self.videoSurface = VideoSurface(ui.Bounds(0, 0, 0.003, self.bounds.size.width, self.bounds.size.height, 0), {width, height})
  self:addSubview(self.videoSurface)
end


return DrawableSurface
