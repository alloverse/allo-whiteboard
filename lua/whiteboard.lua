local vec3 = require("modules.vec3")
local mat4 = require("modules.mat4")
local class = require('pl.class')
local DrawableSurface = require("DrawableSurface")

class.Whiteboard(ui.View)

Whiteboard.assets = {
  quit = Asset.Base64("iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAABHNCSVQICAgIfAhkiAAABUtJREFUeJztm+1TGlcUxp9dcEEQ1wFl7VjT5sXMRE3SWmOssUkax6oBtNM/r39DJ8bXWKNJG3XaRGPbqJlpY0zrS+sC4cUFFYHdfohaQMC9cLc6kOfj7p5nz/l593Dv3pX5dvapgiLVxMoy2JNO4qQ0sbIMAMUJ4KB4oAgBJBYPFBmA1OKBIgKQrnigSABkKh4oAgDZigcKHMBxxQMFDEBN8UCBAlBbPFCAAEiKBwB9LjfZDEm5hGmuRbdIHFNwI4BU7wFoaa4PhaAPBDNfoHYhrmi3YtcMQEkgAKF/EMLQCHThcPqLmON9TCtv8MF398Du7NJNcF+aAODcHlT3D0AvSdBLEuxDI2AjEWKf0r9WUTk+Ac7jhTAwqAkE6gCM6xuoHhxOSpbz+WEfeQAmFiPyqRobByPLhx7CwCB04W2q+VIFYF5+DWHkAZi9vSPnDJsi7GPjwH5B2WT4ZxP20TEw8XjScc7nR3X/fZQEs/QVQlEDYFl6icqHk0BK0okyrq6hcvJx+ua3f4xzu2EfHs04WvRbEoR7A+A8XgpZUwLAz83D+uOUqm5tfrUM68zM0RMM3j3rQ6Ngo9GsHrqdHQj3B2HY+DvXlA+VNwBdeBvlLxaIYiwvFsHPzScdK/H5IAyrb5ZsNApheBTGPCHkBCDx7xw3m+B2dEMuKSHyqHg2C8vSSwBASTAIYXCEuMtHbTbs2auIYlJF5RGICAI83Z1QWDI765NpWBaWYB8Yhm6brLvvVdoguu4Sg08VtSa4W1sLb2cHWZCiwDo1DX0oRBQWtVohupyQDQay+6VR/gASnoft8+fgu9met2U2RXkeossBudRIxS9vAErKdFZqbECwpTlf27SKlVsg9rkQN5uoeWoyFQ40fwbpciNVz1hZGcReF+JlZqq+mi2GfO03EK67QMUrbjLB3edErNxCxS9R2i2HGcDb8SV2z9TmZSOXGiH2OhDleUqJJUvbFyIsC3f3Vzn/VssGA0SXE1GrlXJi/0n7N0IsC5njcgqN2KuwZ7NRTihZ2gKQZVR+/xDG9Y2cwkvX1mGdmqacVLK0A6AoqJx4BNObP/OysSwuoWL2OZ2c0kgbAApge/QDzMuvqdjxs3OwLCxS8UoVfQCKAtuTKZT9/gdVW+vUDMyvyDY91Ig6AOvMTyjbX+XRlm3yMYyra1Q9qQKo+PkpLITvBkjEyDLsY+PgRDc1T2oAKuaeg5//lSyIYbB99mOykFgMwvAoOL+f7F4ZRAVA+S+/gX82Rxznb2uFp6cLW1evEMWxkQiqhkahl/Lfo6QCQDZwAKNilyNBgdbrh4X721oRvlhHFK8PhWBZzL/X5AQgtdRQ/SV4ujoBnU5VfLC5CcGmTxIMGXjv3MbOR2dU5yBdaYS/9brq6zMp7xFwAGP73FmIzh4ox0x7tz69ikDLtTSZsPB0dSJSXX3sPQMt1+Brv6Fqa+04Uf0V2K2pwWafE/HS0rTnpcuN8H/emjFe0evhdnQjasuw+GEY+G59gWBzE410AWgwD9irqoL4TR/i5uQXF6H6S/C1tx0b/24F6Di69tfp4O3sgNRQTzNdbabCUZ6H+LXrEEL4Yh3e3rqpulHGTSa4XY7DkaRwHERHD8IXzlPPVbPF0AEEqbEBb+/cJn5eozwPt/MuYuXl2Ox1YvfDGi3SBJPL/wv8n98IMbKser+hIL8RIt1sIdWpB6C13gM46QROWjl9KJlLszmtIh4BpJ+innYRASi04gECAIVYPKCiBxRq4QfKOgIKvXggC4BiKB7IAKBYigfSACim4oGEJlhshR+IBYq3eAD4FzLNyUTM0XqEAAAAAElFTkSuQmCC"),
  clear = Asset.Base64("iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAMKSURBVHgB7ZtBaBNBGIXfFm9tSk9KbqkQb0WJID1pU48q9aqIXtKrbT0ba8zdJNe2B0HRc9EcxdaTCiaB3ixobgVPQus5zjOZsB1XSGdnNnRnPhg2mQ07897O7P75dyeAQq/XWxCb26IsiZJDOugMSiUIgm7kL4TwGVFqvfRDjTNSdyDFi80HUS7BDTgaimI0/JoYVKzDHfGEWqkZgTj7ObH9Ed57cPAT1Uod+/vfcXj4G6edq9fmsfaohGz2nLqrSANeiA8PZA3F37/3MBXCw0xlJvHyVUM1ocEpcDFcU3u+kTrx5EhoqlYaavUSDTg29z/ufkZa+SamtEJuAg5xFDGynTIgCm8AHMd5A85Akxs3r6NQmEP1WR06fPry9tj3+Su3oEP5ySparT00372HDloGUDwbluiaEBf2gX1hITomaE0BnnmJakZSSPFRfToJWgbwjIfdTtoEVTz7ojsKtS+C4zLBpHgS6y6QtAmmxZPYt8GkTLAhnhiJA2ybYEs8MRYI2TLBpniiHQhFITsmO8zkyv8YNfAJH8O0eGLUACI7yI5vbb5GXOQxstmzVgIupsR64QrdkPS0oIbg/t8gHMcbAMfxCRFooF5JozB5NxmlPd02/RSA4/hrADRIOlq02Z6fAnAcbwAcxxsACzCNVVq+A1PwWLayzcYzQmoOb2vzTeTvRn02SPGl5bvD76azQkZHgCo+4q2sExM+ho2UuzEDbGVvbafcjRhgO3Vt04TYBtgWL7FlQiwDkhIvsWGCtgFJi5eYNkHLgHGJl5g0QcuA1te94eekxUtUE/iekA5agVCz2W+4cHluLOIlbJvPtdpt/Zek/KMxOI43AI7jDVArMplJuAQN6IYr8vnzSCtcPKXQoQHb4Zry+moqR8H09NTflWMKHcYBC+gvmhzC93vqtQ3s7ox3/VAQBIgLT2b+wiwel1eiEjSzcuUow7kVuEVdGLzm6tLZtiiLw6Wz/CA2RVEaSDcM+znaFwea8c8kGyylfYr+gsqkR0QPduiif7HfFsJ3wjv+AOBGWzaSXkcaAAAAAElFTkSuQmCC"),
  sizeDown = Asset.Base64("iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAVXSURBVHgB7ZtNbBtFFMffVtxwq57aOKckUtxLKmgioZ7aJnBrwXAiRQUOOAhxIB8SSIiGEgJIgNQ4HBBqioSggnBCoc2tX+kprRQnUnuKpTanOOmpkt2z+/4bbzT7dtPaM7Pr1puftLK9ttb73rx58z5mHRJUq9UT/PI2H1k+Oqg1WKkdE47jrIX+ggXfz8dUtfWBjPs9uR1PeH65wcerlAxgDf1sDY/21E6co+QIDyArZCaHR7+DXx+o35ZKD2lyIk/F4n0qlx/Ti86x40dpdCxH6fRB+VU/FPAHv/nQOwPhPzjzWUsIrpLa+zL9dWlaKmEaU+AV9czU+QstJzyosEyTE9PydBYK8M39Wwu3qVVZ5Skt6NhDCaISYtmJUkAYuwqghJN4BbxEMdHb10Pd3V3U23uYMoc6KZVK0V5emwGW3Y3SJq2vP6RC4a57FFcfUBwgEKqqJ46+9ibZAgK+O/gWnTz1elgU9lQQkF2c+ZsKS3fd97ZYvHPZ9zkyBeSGTrPw2e1R1gXCz1+5ysr4h2wgFWDdB6TTB9yQMzf0nrHw3vVwrf/mfnff28aqD4Cpj4wOhQqOeY7kauHmIpv1PdrY2NwOufF7+IfuTCf7isN0nJMXCYT/89Iv9N23eVpYWCRbWJsCEH7865HAeQj57+z/fMzVnWNA2JOn3uBjINR3TLIS5q9cIx0i8QEYsR9//ipwHoLDkekmV575Q7kSXSVY9wG4ybMhI58/f5EzyxmjzNKtS7CguJYEU82GTzBWwK+//RCY87jpWTZ5W+BaKNCo4D9/CrG6RjFSAJY6OUcxWrrz82nMz18LWEJ3psu9BxO0FbDlqPxzE4LbHHkJrj3LfkXFNNbQVgBCWnX0vcgtaqRT9aJNXbQVkPvYb3oYfZsh605U3GXVb2VYMnXRUkCG556c+whX4wLTQLUCTEdYpA5aCjjS2+P7jOgujtH3gBUUV/31vQxHkTpoKaCvz6/tZU5f40aGw0fitIB0u9/8V2PK3VWWC/d8nzOHukgHrWSorc0fgRWD5eZAyGmKDNHXuYCikkrpLYVaFiDX3WY0UmSJWzcW2C2KkgZlS9o3IWXJCrV8QKVS8QkNn1Au+x2hzdpiGHLZKwmfUC9aFiArtnJZjANUkFRK63pxiJYClpb86/6xkBJW1NiKRaxYANLSOP0AQl+pdDko9aKlADQu1DlnmpE1ikzDEYYXi3rBmPYyKIseNnoA9RBWhzBJw7UVIDMyCP9Rzqw6Uw8okso6RGFJPxfRVkBYXj54OkuDEU4Fr82mYlqHMIoE0a6SaenI2FBoGdsUXHOUr61iowplHAp/8fn3gSgMDRKbloCRl00X/Oenn3xJphgrAKOQ5/q/BJaAmzap3cOvjIzlAiMP0CKzUYSx0htEyRqMn/OPEswWvT6UyxqZq96yutPKMmmxP2i1PY7gBKO+03LoNkax+YHrBwim1OZoW62uhzbbToEVfp+fmjHqO0S+PwAmj25RoxsingWcLfyNqdlHvj8AN/hONueuELoZmgpGHdd6/8xwJIXXSLfIeOVq9BAa3yKzyaZ+vaG2ej3EtkVG4m6Q6utxnWJ7+wGuIRz0bZJCjQHFVUR18A+FiCrNTVPA80LkPuBFY1cBlHB2FSBPNKPE3UyggDX1hKy2thIhxdsVKMBX1UBC04pWsG9fyn1yTLCCOOAEbT00uY2b4k5d4OSlec8POY5DNnB3oXIT5ez4cFg02uk9OYo9aMOULPKs5NGkPjq7zMfA9qOzeMMv/XxMU2uDsB/WPlCTmQITrfYo7Te09UBlnBZRpehYoy1nP8eC31S/eAK1RE6zBHto6AAAAABJRU5ErkJggg=="),
  sizeUp = Asset.Base64("iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAVtSURBVHgB7ZtBbBtFFIbfVtzYVj21cU5JpLiXVNBEQj21TeDWguFEggoccBDiQJJKICEaSgggAVLjcECoKRKCCsIJBZobhYZTqBQnUnuKpTanOOmpkt2z+/6NN5p53tT27Oy69eaTVrbX1nrfmzdv3vwz65CgUqmc4ZdX+cjw0UXtwVr1mHIcZyPwF2z4YT5mKu0PbDzs2+34xvPLv3w8T8kA0TDI0fDgQPXEJUqO8QC2wmZyuPW7+PWe+m2xeJ+mp3JUKNylUukhPe2cOn2SJi5kKZU6Kr8ahAN+4jdv+2dg/FvnP2gLw1Xcg8/SL9dmpRNm0QWeU8/MXL7SdsaDMts0PTUrT2fgAK3v/7f0P7Ur69ylBV0HKEGUAyI7UQ4IYt8BlHAS74BnKCb6B/qot7eH+vuPU/pYN7muSwd5bAYYdreK27S5eZ/y+dveUVi/R3GAQqiinjj5wstkCxj4+vArdPbci0FV2GNBQXZ17lfKr9z23tti+dZf2ufIHJAdHWHjM7utbAqMX7z+NzvjN7KBdID1HJBKHfFKzuzoG6GN96+Ha/2x8KP33jZWcwBCfXxiNNBw9HNMrpZuLnNY36Gtre3dkhu/R37oTXdzrjhOp3nyIoHxP1/7jr74PEdLS8tkC2tdAMZPfjpecx5G/j7/Jx8LDc8xYOzZcy/xMRSYO6bZCYvXb5AJkeQAtNjX335Scx6GI5GZTq788IdzJaZOsJ4DcJMXA1o+d/kqzyznQs0sPV2CDcW1JOhqNnJCaAd8/8NXNX0eNz3PIW8LXAsCjQr+85uAqGuWUEkQQ53so2itRkJThmK9rre4eIONdmmclR2f3nSPdw9hhkjjCNhJVHrfhOE2W16Ca89zXlEJW2sYOwAlrdr6fuUWNTKp+tWmKcYOyL47on1G69ssWfei7A2repRhyDTFyAFp7nuy76NcjQt0AzUK0B0RkSYYOeBEf5/2GdVdHK3vgygorOv6XpqrSBOMHDAwoHt7laevcSPL4RNxRkCqUw//9Zjm7iqr+Tva5/SxHjLBqA7o6NArsEKt3Fwzztej3u9lnbDJAoqK65oNhUYRIMfdViykSInbtBbYF0XJgJIl74fBtRSFRjmgXC5rRiMnlEp6IqxX2zc7F5DIYa8ockKjGEWAVGzlsBgHUJBUiptmdYiRA1ZW9HH/VICEFTW2ahErEYBpaZx5AKWvdLpslEYxcgAWLtQ+F3ZG1ixyGo4yvFAwK8aMh0EpethYA2iEIB0izDTc2AFyRgbj38mOUNRAJJU6RH7FfC5i7ICgefnwSIaGI+wK/jKbSlgdIpQmCC0OkjiSoM/4hVEqlR/W1QWbHfdh+ARfW8WGChW6FP7owy9rqjAskNiMBLS8XHTBf77/3scUltAOQCvkWP+XIBJw02G0e+QVqMCy5QGWyGyIMFbWBiFZg8lLeishbLHWB7msmb7qD6t7jSzTFtcHrS6PozhBq+81HHoLo9j8wPoBiil1cbSjquv5OWWvBdbczJzxuiCIfH8AQh6rRc1uiKgHNEDkm7BhH/n+ANzga5msN0KYztBU0Oq41pvnxyIRXiPdIuPL1VhDaH6LzDaH+j9NLas3QmxbZCTeBqmBPi8pdnYeYQ3hqLZJChoDxFVUdcgP+YiU5pY54Ekh8hzwtLHvAEo4+w6QJ1ohcbcSOGBDPSHV1nYiQLxdgwM0VQMTmnaMgkOHXO/JMcEa6oAztPPQ5C7eFHfmCk9eWvf8kOM4ZANvFyovolycHAuqRrv9J0exB22MkkWOnTyR1EdnV/kY2n10Fm/4ZZCPWWpvUPYj2oeqNlNNR6s+SvsZ7TxQGWdEVCg6Nmgn2S+w4TfVLx4B1Vdb/zIKkJ4AAAAASUVORK5CYII="),
}

function Whiteboard:_init(bounds)
  self:super(bounds)

  self.drawableSurface = DrawableSurface(ui.Bounds{size=bounds.size})
  self:addSubview(self.drawableSurface)

  self.half_width = self.drawableSurface.bounds.size.width/2
  self.half_height = self.drawableSurface.bounds.size.height/2
  self.BUTTON_SIZE = 0.2
  self.SMALL_BUTTON_SIZE = 0.12
  self.BUTTON_DEPTH = 0.05
  self.SPACING = 0.05
  self.FRAME_THICKNESS = 0.025
  self.FRAME_COLOR_RGBA = {0.8, 0.8, 0.8, 1}

  self.PI = 3.14159
  


  -- FRAME
  self.frame = ui.Surface(ui.Bounds{size=ui.Size( self.drawableSurface.bounds.size.width + self.FRAME_THICKNESS*2,
                                                  self.drawableSurface.bounds.size.height + self.FRAME_THICKNESS*2,
                                                  0.05)}:move(0,0,-0.01))
  self.frame:setColor(self.FRAME_COLOR_RGBA)
  self:addSubview(self.frame)

  -- CONTROL PANEL
  self.controlPanel = ui.Surface(ui.Bounds{size=ui.Size( self.drawableSurface.bounds.size.width + self.FRAME_THICKNESS*2,
  self.BUTTON_SIZE + self.FRAME_THICKNESS*2,
  0.05)}:rotate(-self.PI/4, 1, 0, 0):move(0,-self.half_height-self.BUTTON_SIZE/2-self.FRAME_THICKNESS, self.BUTTON_SIZE/2-self.FRAME_THICKNESS))

  self.controlPanel:setColor(self.FRAME_COLOR_RGBA)
  self:addSubview(self.controlPanel)

  -- RESIZE HANDLE
  self.resizeHandle = ui.ResizeHandle(ui.Bounds(self.half_width-self.SMALL_BUTTON_SIZE/2, self.half_height-self.SMALL_BUTTON_SIZE/2, 0.005, self.SMALL_BUTTON_SIZE, self.SMALL_BUTTON_SIZE, 0.001), {1, 1, 0}, {0, 0, 0})
  self:addSubview(self.resizeHandle)

  -- QUIT BUTTON
  self.quitButton = ui.Button(ui.Bounds{size=ui.Size(
      self.SMALL_BUTTON_SIZE,
      self.SMALL_BUTTON_SIZE,
      self.BUTTON_DEPTH)})
  self.quitButton:setDefaultTexture(Whiteboard.assets.quit)
  self.quitButton.onActivated = function()
    self.app:quit()
  end
  self:addSubview(self.quitButton)
  
  -- CLEAR BUTTON
  self.clearButton = ui.Button(ui.Bounds(0,0,0, self.BUTTON_SIZE, self.BUTTON_SIZE, self.BUTTON_DEPTH))
  
  self.clearButton:setDefaultTexture(Whiteboard.assets.clear)
  self.clearButton.onActivated = function()
    self.drawableSurface:clearBoard()
  end
  self.controlPanel:addSubview(self.clearButton)
  
  -- BRUSH SIZE DOWN BUTTON
  self.brushSizeDownButton = ui.Button(ui.Bounds(0,0,0, self.BUTTON_SIZE, self.BUTTON_SIZE, self.BUTTON_DEPTH))
  self.brushSizeDownButton:setDefaultTexture(Whiteboard.assets.sizeDown)
  self.brushSizeDownButton.onActivated = function()
    self.drawableSurface:setBrushSize(self.drawableSurface.brushSize - 1)
  end
  self.controlPanel:addSubview(self.brushSizeDownButton)
  
  -- BRUSH SIZE UP BUTTON
  self.brushSizeUpButton = ui.Button(ui.Bounds(0,0,0, self.BUTTON_SIZE, self.BUTTON_SIZE, self.BUTTON_DEPTH) )
  self.brushSizeUpButton:setDefaultTexture(Whiteboard.assets.sizeUp)
  self.brushSizeUpButton.onActivated = function()
    self.drawableSurface:setBrushSize(self.drawableSurface.brushSize + 1)
  end
  self.controlPanel:addSubview(self.brushSizeUpButton)

  self:layout()
end

function Whiteboard:specification()
  return ui.View.specification(self)
end

function Whiteboard:update()

  if self.resizeHandle.entity ~= nil then 
    local m = mat4.new(self.resizeHandle.entity.components.transform.matrix) -- looks at the resizeHandle's position
    local resizeHandlePosition = m * vec3(0,0,0)

    local newWidth = resizeHandlePosition.x*2 + self.SMALL_BUTTON_SIZE
    local newHeight = resizeHandlePosition.y*2 + self.SMALL_BUTTON_SIZE

    if newWidth <= 1.2 then newWidth = 1.2 end
    if newHeight <= 0.5 then newHeight = 0.5 end

    self:resize(newWidth, newHeight)
  end

  self.drawableSurface:broadcastTextureChanged()

end

function Whiteboard:resize(newWidth, newHeight)
  if self.drawableSurface:resize(newWidth, newHeight) then
    self:layout()
  end
end


function Whiteboard:layout()
  print("Re-layouting")

  -- Set correct position of all UI elements in relation to the drawableSurface  
  self.half_width = self.drawableSurface.bounds.size.width/2
  self.half_height = self.drawableSurface.bounds.size.height/2

  self.frame:setBounds(ui.Bounds{
      size= ui.Size(
        self.drawableSurface.bounds.size.width+self.FRAME_THICKNESS*2,
        self.drawableSurface.bounds.size.height+self.FRAME_THICKNESS*2, 
        self.drawableSurface.bounds.size.depth)
      }:move(0,0,-0.001))
    
  --print("controlPanel width:", self.drawableSurface.bounds.size.width + self.FRAME_THICKNESS*2)
  self.controlPanel:setBounds(ui.Bounds{
    size= ui.Size(
      self.drawableSurface.bounds.size.width + self.FRAME_THICKNESS*2,
      self.BUTTON_SIZE + self.FRAME_THICKNESS*2, 
      0.05)
  }:rotate(-self.PI/4, 1, 0, 0):move(0,-self.half_height-self.BUTTON_SIZE/2-self.FRAME_THICKNESS, self.BUTTON_SIZE/2-self.FRAME_THICKNESS))
  
  -- Buttons laid out in relation to their parent: the controlPanel
  self.clearButton:setBounds(ui.Bounds{pose=ui.Pose(-self.controlPanel.bounds.size.width/2+self.BUTTON_SIZE/2+self.FRAME_THICKNESS, 0, self.BUTTON_DEPTH/2), size=self.clearButton.bounds.size})
  self.brushSizeDownButton:setBounds(ui.Bounds{pose=ui.Pose(self.controlPanel.bounds.size.width/2-self.BUTTON_SIZE/2-self.BUTTON_SIZE-self.FRAME_THICKNESS-self.SPACING, 0, self.BUTTON_DEPTH/2), size=self.brushSizeDownButton.bounds.size})  
  self.brushSizeUpButton:setBounds(ui.Bounds{pose=ui.Pose(self.controlPanel.bounds.size.width/2-self.BUTTON_SIZE/2-self.FRAME_THICKNESS, 0, self.BUTTON_DEPTH/2), size=self.brushSizeUpButton.bounds.size})

  -- Leftovers
  self.quitButton:setBounds(ui.Bounds{pose=ui.Pose(self.half_width - self.SMALL_BUTTON_SIZE/2, self.half_height+self.SPACING + self.SMALL_BUTTON_SIZE/2, self.BUTTON_DEPTH/2), size=self.quitButton.bounds.size})
end

return Whiteboard