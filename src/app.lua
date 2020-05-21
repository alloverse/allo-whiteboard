
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

print("whiteboard found")

class.Whiteboard(ui.View)

function Whiteboard:_init(bounds)
  self:super(bounds)
  print("initiating whiteboard!")

  self.sr = cairo.image_surface(cairo.cairo_format("rgb24"), 128, 128)
  self.cr = self.sr:context()

end

function Whiteboard:specification()


  print(self.sr:save_png("whiteboard.png"))

  local fh = io.open("whiteboard.png", "rb")
  local image_to_convert = fh:read("*a")
  fh:close()

  local encoded_image = ui.util.base64_encode(image_to_convert)

  print(encoded_image)


  local s = self.bounds.size
  local w2 = s.width / 2.0
  local h2 = s.height / 2.0
  local mySpec = tablex.union(ui.View.specification(self), {
      geometry = {
          type = "inline",
                --   #bl                   #br                  #tl                    #tr
          vertices= {{w2, -h2, 0.0},       {w2, h2, 0.0},       {-w2, -h2, 0.0},       {-w2, h2, 0.0}},
          uvs=      {{0.0, 0.0},           {1.0, 0.0},          {0.0, 1.0},            {1.0, 1.0}},
          triangles= {{0, 3, 1}, {0, 2, 3}, {1, 3, 0}, {3, 2, 0}},
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

        if isReadyForDrawing then
          --print("Drawing on the whiteboard...");
          
          local worldPoint = vec3(body[3][1], body[3][2], body[3][3])

          local inverted = mat4.invert({}, self.bounds.pose.transform)

          local localPoint = vec3(mat4.mul_vec4({}, inverted, {worldPoint.x, worldPoint.y, worldPoint.z, 1}))
          
          local localPointTopLeftOrigo = vec3(self.bounds.size.width/2 - localPoint.x, self.bounds.size.height/2 - localPoint.y, self.bounds.size.depth/2 - localPoint.z)
          normalizedLocalPointTopLeftOrigo = vec3(localPointTopLeftOrigo.x / self.bounds.size.width, localPointTopLeftOrigo.y / self.bounds.size.height, localPointTopLeftOrigo.z / self.bounds.size.depth)

          -- print("----------------")
          -- print(worldPoint)
          -- print(localPoint)
          -- print(normalizedLocalPointTopLeftOrigo)

          self:drawPixel(normalizedLocalPointTopLeftOrigo.x * 128, normalizedLocalPointTopLeftOrigo.y * 128)

        end

    elseif body[1] == "point-exit" then
        print("No longer pointing at the whiteboard");

    elseif body[1] == "poke" then
        -- set whiteboard to be "ready to recieve point events" when picking up "point" interactions
        isReadyForDrawing = body[2]
    end
end

function Whiteboard:drawPixel(x, y)
  -- convert x and y coordinates to the corresponding pixel on the surface of the whiteboard
  -- set said pixel to black
  print("x: " .. x .. " y: " .. y)


  self.cr:rgb(255, 0, 255)
  self.cr:rectangle(x, y, 10, 10)
  self.cr:fill()
  
  self:broadcastTextureChanged()

end

function Whiteboard:broadcastTextureChanged()
  local geom = self:specification().geometry
  self:updateComponents({geometry = geom})
end


local whiteboardView = Whiteboard(ui.Bounds(1,0,0,2,1,0.1))


app.mainView = whiteboardView
app:connect()
app:run()