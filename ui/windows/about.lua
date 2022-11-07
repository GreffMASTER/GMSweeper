local gmui = require "lib.gmui"

local WindowAbout = {}

local mineg = love.graphics.newImage("graphics/mine.png")
mineg:setFilter("nearest")

local win = nil

local onDestroy = nil
local onCreate = nil

local function checkIfFunc(func)
    if type(func) ~= "function" then return false end
    return true
end

local function windestroy()
    win = nil
    collectgarbage()
    if onDestroy then onDestroy() end
end

function WindowAbout.addDestroyEvent(func)
    if not checkIfFunc(func) then return end
    onDestroy = func
end

function WindowAbout.addCreateEvent(func)
    if not checkIfFunc(func) then return end
    onCreate = func
end

function WindowAbout.draw()
    if win and win.draw then win:draw() end
end

function WindowAbout.mousepressed(x, y, button, istouch, presses)
    if win and win.mousepressed then win:mousepressed(x, y, button, istouch, presses) end
end

function WindowAbout.mousereleased(x, y, button, istouch, presses)
    if win and win.mousereleased then win:mousereleased(x, y, button, istouch, presses) end
end

function WindowAbout.mousemoved(mx, my, dx, dy, istouch)
    if win and win.mousemoved then win:mousemoved(mx, my, dx, dy, istouch) end
end

function WindowAbout.createWindow()
    if win then return end
    win = gmui.Window:new {
        xpos = love.graphics.getWidth() / 2 - 90,
        ypos = love.graphics.getHeight() / 2 - 80,
        w = 180,
        h = 170,
        movable = true,
        minimizable = false,
        title = "About "..love.window.getTitle(),
        children = {
            gmui.UIImage:new {
                xpos = 90 - 30,
                ypos = 0,
                sx = 3,
                sy = 3,
                image = mineg
            },
            gmui.Label:new {
                xpos = 0,
                ypos = 60,
                w = 174,
                h = 36,
                text = love.window.getTitle().." v.".._Version.."\nPowered by LÖVE+GMUI\nMade by GreffMASTER 2022",
                textal = "center"
            },
            gmui.Label:new {
                xpos = 0,
                ypos = 102,
                w = 174,
                h = 12,
                color = {0,0,1},
                text = "Open save folder",
                textal = "center",
                href = "file://"..love.filesystem.getSaveDirectory()
            },
            gmui.Label:new {
                xpos = 0,
                ypos = 118,
                w = 174,
                h = 12,
                color = {0,0,1},
                text = "View Github page",
                textal = "center",
                href = "https://github.com/GreffMASTER/GMSweeper"
            },
            gmui.Button:new {
                xpos = 90 - 30,
                ypos = 140,
                w = 60,
                h = 20,
                text = "OK",
                func = windestroy
            }
        }
    }
    win:updateChildrenPos()
    win.focused = true
    if onCreate then onCreate() end
end

return WindowAbout
