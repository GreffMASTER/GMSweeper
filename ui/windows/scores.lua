local gmui = require "lib.gmui"

local WindowScores = {}

local win = nil

local events = {}

local function checkIfFunc(func)
    if type(func) ~= "function" then return false end
    return true
end

local function windestroy()
    win = nil
    collectgarbage()
    if events['destroy'] then events['destroy']() end
end

function WindowScores.addEvent(eventname,func)
    if type(eventname) ~= "string" then error("Event name must be a string!") end
    events[eventname] = func
end

local function setLists(diffi)
    diffi = diffi or "easy"
    win.children[4].elements = {}
    win.children[5].elements = {}
    for k,v in ipairs(_Scores[diffi]) do
        table.insert(win.children[4].elements,k..". "..v[1])
        table.insert(win.children[5].elements,v[2])
    end
end

function WindowScores.draw()
    if win and win.draw then win:draw() end
end

function WindowScores.mousepressed(x, y, button, istouch, presses)
    if win and win.mousepressed then return win:mousepressed(x, y, button, istouch, presses) end
    return false
end

function WindowScores.mousereleased(x, y, button, istouch, presses)
    if win and win.mousereleased then return win:mousereleased(x, y, button, istouch, presses) end
    return false
end

function WindowScores.mousemoved(mx, my, dx, dy, istouch)
    if win and win.mousemoved then win:mousemoved(mx, my, dx, dy, istouch) end
end

function WindowScores.createWindow(spot)
    spot = spot or 1
    if win then return end
    win = gmui.Window:new {
        xpos = love.graphics.getWidth() / 2 / _Scale - 90,
        ypos = love.graphics.getHeight() / 2 / _Scale - 90,
        w = 180,
        h = 190,
        movable = true,
        minimizable = false,
        title = "Highscores",
        children = {
            gmui.Button:new {
                xpos = 0,
                ypos = 0,
                w = 50,
                h = 20,
                text = "Easy",
                func = function(self)
                    self.disabled = true
                    win.title = "Highscores - Easy"
                    win.children[2].disabled = false
                    win.children[3].disabled = false
                    setLists("easy")
                end
            },
            gmui.Button:new {
                xpos = 60,
                ypos = 0,
                w = 50,
                h = 20,
                text = "Medium",
                func = function(self)
                    self.disabled = true
                    win.title = "Highscores - Medium"
                    win.children[1].disabled = false
                    win.children[3].disabled = false
                    setLists("medium")
                end
            },
            gmui.Button:new {
                xpos = 120,
                ypos = 0,
                w = 50,
                h = 20,
                text = "Hard",
                func = function(self)
                    self.disabled = true
                    win.title = "Highscores - Hard"
                    win.children[1].disabled = false
                    win.children[2].disabled = false
                    setLists("hard")
                end
            },
            gmui.List:new {
                xpos = 4,
                ypos = 28,
                w = 110,
                h = 122,
                clickfunc = function(self)
                    win.children[5].selected = self.selected
                end,
                elements = {}
            },
            gmui.List:new {
                xpos = 120,
                ypos = 28,
                w = 48,
                h = 122,
                clickfunc = function(self)
                    win.children[4].selected = self.selected
                end,
                elements = {}
            },
            gmui.Button:new {
                xpos = 90 - 30,
                ypos = 160,
                w = 60,
                h = 20,
                text = "OK",
                func = windestroy
            }
        }
    }
    if _Mode == "easy" then
        win.children[1].disabled = true
        win.title = "Highscores - Easy"
        setLists("easy")
    elseif _Mode == "medium" then
        win.children[2].disabled = true
        win.title = "Highscores - Medium"
        setLists("medium")
    elseif _Mode == "hard" then
        win.children[3].disabled = true
        win.title = "Highscores - Hard"
        setLists("hard")
    else
        win.children[1].disabled = true
        win.title = "Highscores - Easy"
        setLists("easy")
    end

    if spot > #win.children[4].elements then
        spot = #win.children[4].elements
    end
    
    win.children[4].selected = spot
    win.children[5].selected = spot
    win:updateChildrenPos()
    win.focused = true
    if events['create'] then events['create']() end
end

function WindowScores.destroyWindow()
    windestroy()
end

return WindowScores
