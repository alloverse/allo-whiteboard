local class = require('pl.class')
local tablex = require('pl.tablex')

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
end

function Whiteboard:specification()
    local s = self.bounds.size
    local w2 = s.width / 2.0
    local h2 = s.height / 2.0
    local mySpec = tablex.union(ui.View.specification(self), {
        geometry = {
            type = "inline",
                  --   #bl                   #br                  #tl                    #tr
            vertices= {{w2, -h2, 0.0},       {w2, h2, 0.0},       {-w2, -h2, 0.0},       {-w2, h2, 0.0}},
            uvs=      {{0.0, 0.0},           {1.0, 0.0},          {0.0, 1.0},            {1.0, 1.0}},
            triangles= {{0, 3, 1}, {0, 2, 3}},
            texture= "iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAABTElEQVR4nO3SAQHAQAyEsG7+Pd8LCbEA37ZdWH/pbQ2AawBcA+AaANcAuAbANQCuAXANgGsAXAPgGgDXALgGwDUArgFwDYBrAFwD4BoA1wC4BsA1AK4BcA2AawBcA+AaANcAuAbANQCuAXANgGsAXAPgGgDXALgGwDUArgFwDYBrAFwD4BoA1wC4BsA1AK4BcA2AawBcA+AaANcAuAbANQCuAXANgGsAXAPgGgDXALgGwDUArgFwDYBrAFwD4BoA1wC4BsA1AK4BcA2AawBcA+AaANcAuAbANQCuAXANgGsAXAPgGgDXALgGwDUArgFwDYBrAFwD4BoA1wC4BsA1AK4BcA2AawBcA+AaANcAuAbANQCuAXANgGsAXAPgGgDXALgGwDUArgFwDYBrAFwD4BoA1wC4BsA1AK4BcA2AawBcA+AaANcAuAaQ3d0Dd/sE/CoaECQAAAAASUVORK5CYII="
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
        print("pointing at the whiteboard");

        if isReadyForDrawing then
          print("Drawing on the whiteboard...");

          self:drawPixel(body[3][1], body[3][2])
          
          -- overlap of the "point ray" and the whiteboard in WORLD SPACE COORDINATES
          -- TODO: convert world space coordinate to local whiteboard coordinate 
          -- in order to find where on the board we should be drawing. Freya's YT video?!
        end

    elseif body[1] == "point-exit" then
        print("No longer pointing at the whiteboard");

    elseif body[1] == "poke" then
        print("Whiteboard receiving a poke");
        
        -- set whiteboard to be "ready to recieve point events" when picking up "point" interactions
        isReadyForDrawing = body[2]
    end
end

function Whiteboard:drawPixel(x, y)
  -- convert x and y coordinates to the corresponding pixel on the surface of the whiteboard
  -- set said pixel to black
end




local whiteboardView = Whiteboard(ui.Bounds(-1,1,0,1,1,0.1))


app.mainView = whiteboardView
app:connect()
app:run()