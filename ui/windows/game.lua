local gmui = require "lib.gmui"

local WindowGame = {}

local win = nil

local events = {}

local onDestroy = nil
local onCreate = nil
local onNewGame = nil

local widthg = love.graphics.newImage("graphics/width.png"); widthg:setFilter("nearest")
local heightg = love.graphics.newImage("graphics/height.png"); heightg:setFilter("nearest")
local mineg = love.graphics.newImage("graphics/mine.png"); mineg:setFilter("nearest")
local menugridg = love.graphics.newImage("graphics/menugrid.png"); menugridg:setFilter("nearest")

local hold = {false,false}
local holddelay = 0.5

local function checkIfFunc(func)
    if type(func) ~= "function" then return false end
    return true
end

local function windestroy()
    win = nil
    collectgarbage()
    if events['destroy'] then events['destroy']() end
end

function WindowGame.addEvent(eventname,func)
    if type(eventname) ~= "string" then error("Event name must be a string!") end
    events[eventname] = func
end

local tempb = {"gw","gh","mc"}

function WindowGame.update(dt)
    if win and win.update then
        win:update(dt)
        if hold[1] or hold[2] then
            holddelay = holddelay - dt
            if holddelay <= 0 then
                for k,v in pairs(tempb) do
                    if win.children[v].clicked then
                        if hold[1] then
                            win.children[v]:func()
                            break
                        end
                        win.children[v]:altfunc()
                        break
                    end
                end
                holddelay = 0.1
            end
        end
    end
end

function WindowGame.draw()
    if win and win.draw then win:draw() end
end

function WindowGame.mousepressed(x, y, button, istouch, presses)
    if win and win.mousepressed then
        local ret = win:mousepressed(x, y, button, istouch, presses)
        if (win.children.gw.clicked or win.children.gh.clicked or win.children.mc.clicked) and win.children.custom.disabled then
            hold[button] = true
        end
        return ret
    end
    return false
end

function WindowGame.mousereleased(x, y, button, istouch, presses)
    if win and win.mousereleased then
        local ret = win:mousereleased(x, y, button, istouch, presses)
        hold[button] = false
        holddelay = 0.5
        return ret
    end
    return false
end

function WindowGame.mousemoved(mx, my, dx, dy, istouch)
    if win and win.mousemoved then win:mousemoved(mx, my, dx, dy, istouch) end
end

function WindowGame.createWindow()
    if win then return end
    _SetMode = _Mode
    _SetGridW = _GridW
    _SetGridH = _GridH
    _SetMines = _Mines
    win = gmui.Window:new {
        xpos = love.graphics.getWidth() / 2 / _Scale - 90,
        ypos = love.graphics.getHeight() / 2 / _Scale - 90,
        w = 180,
        h = 180,
        movable = true,
        minimizable = false,
        title = "Game Settings",
        children = {
            -- Difficulty buttons
            easy = gmui.Button:new {
                xpos = 4,
                ypos = 20,
                w = 60,
                h = 20,
                text = "Easy",
                func = function(self)
                    self.disabled = true
                    win.children.medium.disabled = false -- Medium
                    win.children.hard.disabled = false -- Hard
                    win.children.custom.disabled = false -- Custom
                    win.children.gw.disabled = true  -- Custom GridW
                    win.children.gh.disabled = true  -- Custom GridH
                    win.children.mc.disabled = true  -- Custom Mines
                    _SetMode = "easy"
                end
            },
            medium = gmui.Button:new {
                xpos = 4,
                ypos = 50,
                w = 60,
                h = 20,
                text = "Medium",
                func = function(self)
                    self.disabled = true
                    win.children.easy.disabled = false
                    win.children.hard.disabled = false
                    win.children.custom.disabled = false
                    win.children.gw.disabled = true  -- Custom GridW
                    win.children.gh.disabled = true  -- Custom GridH
                    win.children.mc.disabled = true  -- Custom Mines
                    _SetMode = "medium"
                end
            },
            hard = gmui.Button:new {
                xpos = 4,
                ypos = 80,
                w = 60,
                h = 20,
                text = "Hard",
                func = function(self)
                    self.disabled = true
                    win.children.easy.disabled = false
                    win.children.medium.disabled = false
                    win.children.custom.disabled = false
                    win.children.gw.disabled = true  -- Custom GridW
                    win.children.gh.disabled = true  -- Custom GridH
                    win.children.mc.disabled = true  -- Custom Mines
                    _SetMode = "hard"
                end
            },
            custom = gmui.Button:new {
                xpos = 4,
                ypos = 110,
                w = 60,
                h = 20,
                text = "Custom",
                func = function(self)
                    self.disabled = true
                    win.children.easy.disabled = false
                    win.children.medium.disabled = false
                    win.children.hard.disabled = false
                    win.children.gw.disabled = false  -- Custom GridW
                    win.children.gh.disabled = false  -- Custom GridH
                    win.children.mc.disabled = false  -- Custom Mines
                    _SetMode = "custom"
                end
            },
            -- Buttons for custom mode
            -- GridW
            gw = gmui.Button:new {
                xpos = 75,
                ypos = 110,
                w = 25,
                h = 20,
                text = tostring(_SetGridW),
                disabled = true,
                onrelease = false,
                func = function(self)
                    _SetGridW = _SetGridW + 1
                    if _SetGridW > _MaxGridW then _SetGridW = 6 end
                    if _SetGridW * _SetGridH - 1 < _SetMines then
                        _SetMines = _SetGridW * _SetGridH - 1
                        win.children.mc.text = tostring(_SetMines)
                    end
                    self.text = tostring(_SetGridW)
                end,
                altfunc = function(self)
                    _SetGridW = _SetGridW - 1
                    if _SetGridW < 6 then _SetGridW = _MaxGridW end
                    if _SetGridW * _SetGridH - 1 < _SetMines then
                        _SetMines = _SetGridW * _SetGridH - 1
                        win.children.mc.text = tostring(_SetMines)
                    end
                    self.text = tostring(_SetGridW)
                end
            },
            -- GridH
            gh = gmui.Button:new {
                xpos = 107,
                ypos = 110,
                w = 25,
                h = 20,
                text = tostring(_SetGridH),
                disabled = true,
                onrelease = false,
                func = function(self)
                    _SetGridH = _SetGridH + 1
                    if _SetGridH > _MaxGridH then _SetGridH = 6 end
                    if _SetGridW * _SetGridH - 1 < _SetMines then
                        _SetMines = _SetGridW * _SetGridH - 1
                        if _SetMines > 999 then _SetMines = 999 end
                        win.children.mc.text = tostring(_SetMines)
                    end
                    self.text = tostring(_SetGridH)
                end,
                altfunc = function(self)
                    _SetGridH = _SetGridH - 1
                    if _SetGridH < 6 then _SetGridH = _MaxGridH end
                    if _SetGridW * _SetGridH - 1 < _SetMines then
                        _SetMines = _SetGridW * _SetGridH - 1
                        if _SetMines > 999 then _SetMines = 999 end
                        win.children.mc.text = tostring(_SetMines)
                    end
                    self.text = tostring(_SetGridH)
                end
            },
            -- Mines
            mc = gmui.Button:new {
                xpos = 139,
                ypos = 110,
                w = 25,
                h = 20,
                text = tostring(_SetMines),
                disabled = true,
                onrelease = false,
                func = function(self)
                    _SetMines = _SetMines + 1
                    if _SetMines > _SetGridW * _SetGridH - 1 then _SetMines = 1 end
                    if _SetMines > 999 then _SetMines = 1 end
                    self.text = tostring(_SetMines)
                end,
                altfunc = function(self)
                    _SetMines = _SetMines - 1
                    if _SetMines < 1 then _SetMines = _SetGridW * _SetGridH - 1 end
                    if _SetMines > 999 then _SetMines = 999 end
                    self.text = tostring(_SetMines)
                end
            },
            -- Bottom buttons
            new = gmui.Button:new {
                xpos = 4,
                ypos = 180 - 30,
                w = 80,
                h = 20,
                text = "New Game",
                func = function()
                    if events['newgame'] then events['newgame']() end
                    windestroy()
                end
            },
            cancel = gmui.Button:new {
                xpos = 180 - 70,
                ypos = 180 - 30,
                w = 60,
                h = 20,
                text = "Cancel",
                func = windestroy
            },
            -- Table
            gmui.UIImage:new {
                xpos = 74,
                ypos = 16,
                w = 20,
                h = 20,
                image = menugridg
            },
            -- Icons
            gmui.UIImage:new {
                xpos = 80,
                ypos = -4,
                w = 20,
                h = 20,
                image = widthg
            },
            gmui.UIImage:new {
                xpos = 110,
                ypos = -4,
                w = 20,
                h = 20,
                image = heightg
            },
            gmui.UIImage:new {
                xpos = 140,
                ypos = -4,
                w = 20,
                h = 20,
                image = mineg
            },
            -- Numbers
            gmui.Label:new {
                xpos = 82,
                ypos = 24,
                w = 94,
                h = 12,
                text = "10   10    10"
            },
            gmui.Label:new {
                xpos = 82,
                ypos = 52,
                w = 94,
                h = 12,
                text = "16   16    40"
            },
            gmui.Label:new {
                xpos = 82,
                ypos = 80,
                w = 94,
                h = 12,
                text = "30   16    99"
            },
            gmui.Label:new {
                xpos = 8,
                ypos = 0,
                w = 60,
                h = 12,
                text = "Difficulty"
            }
        }
    }

    win:updateChildrenPos()
    if _Mode == "easy" then
        win.children.easy.disabled = true
    elseif _Mode == "medium" then
        win.children.medium.disabled = true
    elseif _Mode == "hard" then
        win.children.hard.disabled = true
    elseif _Mode == "custom" then
        win.children.custom.disabled = true
        win.children.gw.disabled = false
        win.children.gh.disabled = false
        win.children.mc.disabled = false
    end
    win.focused = true
    if events['create'] then events['create']() end
end

function WindowGame.destroyWindow()
    windestroy()
end

return WindowGame
