local gmui = require "lib.gmui"

local WindowScoreEntry = {}

local win = nil

local onDestroy = nil
local onCreate = nil

local scorespot = nil
local scoretime = nil

local function checkIfFunc(func)
    if type(func) ~= "function" then return false end
    return true
end

local function windestroy()
    win = nil
    collectgarbage()
    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
    if onDestroy then onDestroy(scorespot) end
end

local function sendScore()
    if string.len(win.children[2].value) < 1 then return end
    _Username = win.children[2].value
    table.insert(_Scores[_Mode],scorespot,{win.children[2].value,tonumber(string.format("%.2f",scoretime))})
    if #_Scores[_Mode] > 10 then table.remove(_Scores[_Mode]) end
    windestroy()
end

function WindowScoreEntry.addDestroyEvent(func)
    if not checkIfFunc(func) then return end
    onDestroy = func
end

function WindowScoreEntry.addCreateEvent(func)
    if not checkIfFunc(func) then return end
    onCreate = func
end

function WindowScoreEntry.update(dt)
    if win and win.update then win:update(dt) end
end

function WindowScoreEntry.draw()
    if win and win.draw then win:draw() end
end

function WindowScoreEntry.keypressed(key, scancode, isrepeat)
    if win then
        if win.keypressed then win:keypressed(key, scancode, isrepeat) end
        if key == "return" and win.children[2].selected then sendScore() end
    end
end

function WindowScoreEntry.keyreleased(key, scancode, isrepeat)
    if win and win.keyreleased then win:keyreleased(key, scancode, isrepeat) end
end

function WindowScoreEntry.mousepressed(x, y, button, istouch, presses)
    if win and win.mousepressed then return win:mousepressed(x, y, button, istouch, presses) end
    return false
end

function WindowScoreEntry.mousereleased(x, y, button, istouch, presses)
    if win and win.mousereleased then return win:mousereleased(x, y, button, istouch, presses) end
    return false
end

function WindowScoreEntry.mousemoved(mx, my, dx, dy, istouch)
    if win and win.mousemoved then win:mousemoved(mx, my, dx, dy, istouch) end
end

function WindowScoreEntry.textinput(text)
    if win and win.textinput then win:textinput(text) end
end

function WindowScoreEntry.createWindow(time,spot)
    scorespot = spot
    scoretime = time
    if win then return end
    local sufix = "th"
    if spot == 1 then
        sufix = "st"
    elseif spot == 2 then
        sufix = "nd"
    elseif spot == 3 then
        sufix = "rd"
    else
        sufix = "th"
    end
    win = gmui.Window:new {
        xpos = love.graphics.getWidth() / 2 - 90,
        ypos = love.graphics.getHeight() / 2 - 90,
        w = 180,
        h = 140,
        movable = true,
        minimizable = false,
        title = "New Highscore!",
        children = {
            gmui.Label:new {
                xpos = 0,
                ypos = 0,
                w = 172,
                h = 20,
                textal = "center",
                text = {
                    {0,0,0}, "You have achieved a time of ",
                    {0,0,1}, string.format("%.2f",time),
                    {0,0,0}, " and managed to get on the ",
                    {0,0,1}, tostring(spot)..sufix,
                    {0,0,0}, " place in the ".._Mode.." difficulty!\nEnter your name below."
                }
            },
            gmui.Textbox:new {
                xpos = 20,
                ypos = 80,
                w = 130,
                h = 16,
                maxsize = 20,
                default = "Player name",
                value = _Username
            },
            gmui.Button:new {
                xpos = 90-30,
                ypos = 110,
                w = 60,
                h = 20,
                text = "OK",
                func = sendScore
            }
        }
    }
    win:updateChildrenPos()
    win.focused = true
    if onCreate then onCreate() end
end

function WindowScoreEntry.isWindowOpen()
    if win then return true end
    return false
end

return WindowScoreEntry
