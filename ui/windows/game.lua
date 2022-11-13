local gmui = require "lib.gmui"

local WindowGame = {}

local win = nil

local onDestroy = nil
local onCreate = nil
local onNewGame = nil

local widthg = love.graphics.newImage("graphics/width.png")
local heightg = love.graphics.newImage("graphics/height.png")
local mineg = love.graphics.newImage("graphics/mine.png")
local menugridg = love.graphics.newImage("graphics/menugrid.png")

local function checkIfFunc(func)
    if type(func) ~= "function" then return false end
    return true
end

local function windestroy()
    win = nil
    collectgarbage()
    if onDestroy then onDestroy() end
end

function WindowGame.addDestroyEvent(func)
    if not checkIfFunc(func) then return end
    onDestroy = func
end

function WindowGame.addCreateEvent(func)
    if not checkIfFunc(func) then return end
    onCreate = func
end

function WindowGame.addNewGameEvent(func)
    if not checkIfFunc(func) then return end
    onNewGame = func
end

function WindowGame.draw()
    if win and win.draw then win:draw() end
end

function WindowGame.mousepressed(x, y, button, istouch, presses)
    if win and win.mousepressed then return win:mousepressed(x, y, button, istouch, presses) end
    return false
end

function WindowGame.mousereleased(x, y, button, istouch, presses)
    if win and win.mousereleased then return win:mousereleased(x, y, button, istouch, presses) end
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
        xpos = love.graphics.getWidth() / 2 - 90,
        ypos = love.graphics.getHeight() / 2 - 90,
        w = 180,
        h = 180,
        movable = true,
        minimizable = false,
        title = "Game Settings",
        children = {
            -- Difficulty buttons
            gmui.Button:new {
                xpos = 4,
                ypos = 20,
                w = 60,
                h = 20,
                text = "Easy",
                func = function(self)
                    self.disabled = true
                    win.children[2].disabled = false -- Medium
                    win.children[3].disabled = false -- Hard
                    win.children[4].disabled = false -- Custom
                    win.children[5].disabled = true  -- Custom GridW
                    win.children[6].disabled = true  -- Custom GridH
                    win.children[7].disabled = true  -- Custom Mines
                    _SetMode = "easy"
                end
            },
            gmui.Button:new {
                xpos = 4,
                ypos = 50,
                w = 60,
                h = 20,
                text = "Medium",
                func = function(self)
                    self.disabled = true
                    win.children[1].disabled = false
                    win.children[3].disabled = false
                    win.children[4].disabled = false
                    win.children[5].disabled = true
                    win.children[6].disabled = true
                    win.children[7].disabled = true
                    _SetMode = "medium"
                end
            },
            gmui.Button:new {
                xpos = 4,
                ypos = 80,
                w = 60,
                h = 20,
                text = "Hard",
                func = function(self)
                    self.disabled = true
                    win.children[1].disabled = false
                    win.children[2].disabled = false
                    win.children[4].disabled = false
                    win.children[5].disabled = true
                    win.children[6].disabled = true
                    win.children[7].disabled = true
                    _SetMode = "hard"
                end
            },
            gmui.Button:new {
                xpos = 4,
                ypos = 110,
                w = 60,
                h = 20,
                text = "Custom",
                func = function(self)
                    self.disabled = true
                    win.children[1].disabled = false
                    win.children[2].disabled = false
                    win.children[3].disabled = false
                    win.children[5].disabled = false
                    win.children[6].disabled = false
                    win.children[7].disabled = false
                    _SetMode = "custom"
                end
            },
            -- Buttons for custom mode
            -- GridW
            gmui.Button:new {
                xpos = 75,
                ypos = 110,
                w = 25,
                h = 20,
                text = tostring(_SetGridW),
                disabled = true,
                func = function(self)
                    _SetGridW = _SetGridW + 1
                    if _SetGridW > _MaxGridW then _SetGridW = 6 end
                    if _SetGridW * _SetGridH - 1 < _SetMines then
                        _SetMines = _SetGridW * _SetGridH - 1
                        win.children[7].text = tostring(_SetMines)
                    end
                    self.text = tostring(_SetGridW)
                end,
                altfunc = function(self)
                    _SetGridW = _SetGridW - 1
                    if _SetGridW < 6 then _SetGridW = _MaxGridW end
                    if _SetGridW * _SetGridH - 1 < _SetMines then
                        _SetMines = _SetGridW * _SetGridH - 1
                        win.children[7].text = tostring(_SetMines)
                    end
                    self.text = tostring(_SetGridW)
                end
            },
            -- GridH
            gmui.Button:new {
                xpos = 107,
                ypos = 110,
                w = 25,
                h = 20,
                text = tostring(_SetGridH),
                disabled = true,
                func = function(self)
                    _SetGridH = _SetGridH + 1
                    if _SetGridH > _MaxGridH then _SetGridH = 6 end
                    if _SetGridW * _SetGridH - 1 < _SetMines then
                        _SetMines = _SetGridW * _SetGridH - 1
                        if _SetMines > 999 then _SetMines = 999 end
                        win.children[7].text = tostring(_SetMines)
                    end
                    self.text = tostring(_SetGridH)
                end,
                altfunc = function(self)
                    _SetGridH = _SetGridH - 1
                    if _SetGridH < 6 then _SetGridH = _MaxGridH end
                    if _SetGridW * _SetGridH - 1 < _SetMines then
                        _SetMines = _SetGridW * _SetGridH - 1
                        if _SetMines > 999 then _SetMines = 999 end
                        win.children[7].text = tostring(_SetMines)
                    end
                    self.text = tostring(_SetGridH)
                end
            },
            -- Mines
            gmui.Button:new {
                xpos = 139,
                ypos = 110,
                w = 25,
                h = 20,
                text = tostring(_SetMines),
                disabled = true,
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
            gmui.Button:new {
                xpos = 4,
                ypos = 180 - 30,
                w = 80,
                h = 20,
                text = "New Game",
                func = function()
                    if onNewGame then onNewGame() end
                    windestroy()
                end
            },
            gmui.Button:new {
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
        win.children[1].disabled = true
    elseif _Mode == "medium" then
        win.children[2].disabled = true
    elseif _Mode == "hard" then
        win.children[3].disabled = true
    elseif _Mode == "custom" then
        win.children[4].disabled = true
        win.children[5].disabled = false
        win.children[6].disabled = false
        win.children[7].disabled = false
    end
    win.focused = true
    if onCreate then onCreate() end
end

function WindowGame.destroyWindow()
    windestroy()
end

return WindowGame
