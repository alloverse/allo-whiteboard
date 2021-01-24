package.path = string.format(
    package.path..";"
    .."lib/cairo/?.lua"
)



local Whiteboard = require("whiteboard")

local client = Client(
    arg[2], 
    "allo-whiteboard"
)
local app = App(client)

print("+===================+")
print("+ ADDING WHITEBOARD +")
print("+===================+")

local whiteboard = Whiteboard(ui.Bounds(1.5, 1, 0,   2, 1, 0.01))

app.mainView = whiteboard

-- Checks whiteboard refresh 20 times per second
app:scheduleAction(0.05, true, function()
  
  whiteboard:update()

end)

app:connect()
app:run()