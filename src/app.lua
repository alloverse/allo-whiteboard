local client = Client(
    arg[1], 
    "allo-jukebox"
)
local app = App(client)

local myAppView = ui.View(ui.Bounds(0,0,0,1,1,1))
-- ... configure your app's startup UI

app.mainView = myAppView
app:connect()
app:run()