function love.conf(t)
    t.identity = "gmsweeper"
    t.appendidentity = true
    t.version = "11.3"
    t.console = false
    t.externalstorage = true

    t.window.title = "GMSweeper"
    t.window.icon = "graphics/mine.png"
    t.window.width = 280
    t.window.height = 320
    
    t.modules.audio = false
    t.modules.data = false
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.sound = false
    t.modules.thread = false
    t.modules.touch = false
    t.modules.video = false
end
