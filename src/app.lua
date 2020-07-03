local Whiteboard = require("whiteboard")

local client = Client(
    arg[1], 
    "allo-whiteboard"
)
local app = App(client)

print("+==================+")
print("+ WHITEBOARD ADDED +")
print("+==================+")


-- CREATES THE WHITEBOARD
local whiteboardView = Whiteboard(ui.Bounds(1.5, 1, 0,   2, 1, 0.1))

-- ADDS THE GRAB HANDLE
local grabHandle = ui.GrabHandle(ui.Bounds(-0.9, -0.5, 0.5,   0.2, 0.2, 0.2))
whiteboardView:addSubview(grabHandle)

-- ADDS THE RESET BUTTON
local resetButton = ui.Button(ui.Bounds(0, -0.4, 0.5,   0.2, 0.2, 0.2):rotate(math.pi/4, math.pi/4, 0 ,0))
resetButton.texture = " iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAADqSURBVHgB7ZZRDkQRDEVrMguwBEuw/x9LsARL6ajExHho62P8uIlIqN6Tx6MGABAO6gWHdQEeAM45CCGUnhMilsbJWltyeu/HedqWA5GUUsIMgf1826pWMdkcY4wljvpBzO8AmZK5BIIDaM0XuZ4LpRArAKH5GEAKMQNQmM8BeojR/s0ANOcImMmSgMzzCeYSfRvF0hqBOZpKcUr3JjwO8O4HZlerMQY0kuY5/gXuX3ABWACumBhJU9SQRO/53x8jyZM6A9AUNbBrvgJQQuyZcwAKiP394wB6CFFRqikmJAAVYlbU3Kv4AnwAjUeU7dSfDjoAAAAASUVORK5CYII="
resetButton.onActivated = function()
  whiteboardView:resetBoard()
end
whiteboardView:addSubview(resetButton)

-- ADDS BRUSH SIZE DOWN BUTTON
local brushSizeDownButton = ui.Button(ui.Bounds(0.7, -0.4, 0.5,  0.2, 0.2, 0.2):rotate(math.pi/4, math.pi/4, 0 ,0) )
brushSizeDownButton.texture = " iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAGzSURBVHgB7VftkYIwEF2uAkuwBDvQDixBO9AOpBOgAqAChgqgA+gAOsjlMRdcSIQEnMMfvpnMxDUfbz+yu3hEJGhD/NDG+BJwIrDb7ejxeFCWZVRVFQkhutE0TSe73W603+/JFWJuyEOFvEDYIgiCbo/N2bMEpFZCaihcgT33+30dAWlu7WBY4nq9DjQ8HA6dLI5jbT3OWEQAmnNIn4vT6WTlLqzlmLGE+RBu9qIohAxAW592a7GHu2MiJnRhGIYDzV0u5yS4JeA6KwJgyuEQzdqAyzheKDIUwF8KSZIsvlwN/nx939f+1xLR+Xzu5zKqaS2iKOrnx+PRuGbAiAcfnpeSu4IMLkVMjO/z/iZPNuL50/M8o9wGr/ZyOfB5xaiu636+pLCMId3Yz9u2JScC8hn1c5jOZZgIlGU5TyDP835+uVxoLfirStPUuEbLYBw2+Z8m6oJFUptOHu9KxegRyCYVK+abFiMapWRlCZu6AJetLsdqIHePgaZDBucgS4IYGhJT22bK/9YElCU2a8m4hrxHmAMs8bamdEwErRou4FaBzyGDuV1fjFaM/hvfT7PNCfwCLC5MjI43pfEAAAAASUVORK5CYII="
brushSizeDownButton.onActivated = function()
  whiteboardView:setBrushSize(whiteboardView.brushSize - 1)
end
whiteboardView:addSubview(brushSizeDownButton)

-- ADDS BRUSH SIZE UP BUTTON
local brushSizeUpButton = ui.Button(ui.Bounds(0.9, -0.4, 0.5,  0.2, 0.2, 0.2):rotate(math.pi/4, math.pi/4, 0 ,0) )
brushSizeUpButton.texture = " iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAG6SURBVHgB7VfbsYIwEF1uBZZgCXagHViCdqAdaCdABUAFDBVAB9ABdJCbw1xwycMEcS5+eGYysy55nH1kswZEJGhF/NDK+BKYRWCz2dDtdqM8z6muaxJC9KNt2153uVxou93SXAjXkJsKeYDwRRiG/RqfvZ0EpFVCWijmAmuu1+syAtLd2sbwxPl8nli42+16XZIk2nzs8RIBWM4hYy4Oh4NXuDCXw+EJ8ybc7WVZCpmAvjHt52IND8eTnNCVURRNLDcdrsJEgnsCofMiAKYcNuYuAhgIGYfFi1MF4jUgTVOrm30IYPDre7/fte9aIToej6Mss5qWIo7jUd7v98Y5E0Y8+XC9yGKxC2QIKXJCPS/4Ex5sxONnEARGvQ9sa7ke+LzHqGmaUX7lYVEhwzjKXdfRLALyGo0yXMeHCtt3TqCqKjeBoihG+XQ60VLwW5VlmXGOVsE4bPXfpw54FrXnxeNdpRg9AvmUYvqEx4iUkjx4wqfLQcgWP8fDQO1WgaZDJuekSoIYGhJT22aq/94EBk+s1pJxC3mP4AI88bamVCWCVg0HcK8g5tDB3XOSFUN7jP4b379mqxP4BQb3iETeAvICAAAAAElFTkSuQmCC"
brushSizeUpButton.onActivated = function()
  whiteboardView:setBrushSize(whiteboardView.brushSize + 1)
end
whiteboardView:addSubview(brushSizeUpButton)

app.mainView = whiteboardView

-- Checks whiteboard refresh 10 times per second
app:scheduleAction(0.1, true, function() 
  whiteboardView:sendIfDirty()
end)

app:connect()
app:run()
