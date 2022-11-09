function love.conf(t)
    t.identity = "gmsweeper"
    t.version = "11.3"
    t.window.vsync = true
    t.window.title = "GMSweeper"
    t.window.width = 280
    t.window.height = 320
    t.window.resizable = false
    t.modules.joystick = false
    t.modules.physics = false
    t.window.usedpiscale = false
    t.externalstorage = true
    t.console = false
    t.window.icon = "graphics/mine.png"
end
