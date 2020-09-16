local Whiteboard = require("whiteboard")

local client = Client(
    arg[1], 
    "allo-whiteboard"
)
local app = App(client)

print("+===================+")
print("+ ADDING WHITEBOARD +")
print("+===================+")

local whiteboard = Whiteboard(ui.Bounds(1.5, 1, 0,   2, 1, 0.1))

app.mainView = whiteboard

-- Checks whiteboard refresh 10 times per second
app:scheduleAction(0.1, true, function()
  
  whiteboard:update()

end)

app:connect()
app:run()