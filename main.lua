local fileparser = require "fileparser"
-- GUI stuff
local display = require "ui.digitaldisplay"
local gmui = require "lib.gmui"

local windows = {
    game = require "ui.windows.game",
    about = require "ui.windows.about",
    scores = require "ui.windows.scores",
    scoreentry = require "ui.windows.scoreentry"
}

local topribbon = nil -- top ribbon
local resetb = nil -- reset button
local sweepstyle = gmui.Style:new({ -- custom style for the grid buttons
    bt_color = {0.6,0.6,0.6}
})

-- Global variables
_Version = "1.1.1"
_GridW = 10
_GridH = 10
_Mines = 10
_Mode = "easy"
_Username = "Player"
_MinScale = 1
_MaxScale = 2
_Scale = love.graphics.getDPIScale()
-- Settings vars (for use in the new game gui)
_SetMode = _Mode
_SetGridW = _GridW
_SetGridH = _GridH
_SetMines = _Mines
_MaxGridW = 10
_MaxGridH = 10
-- Scoreboard
_Scores = {}
_Scores.easy = {}
_Scores.medium = {}
_Scores.hard = {}

for i=1,10 do
    _Scores.easy[i] = {"",999.99}
    _Scores.medium[i] = {"",999.99}
    _Scores.hard[i] = {"",999.99}
end
-- Fonts
local mainfont = love.graphics.newFont(20)
-- Graphics
local faces = {
    love.graphics.newImage("graphics/smileface.png"),
    love.graphics.newImage("graphics/oface.png"),
    love.graphics.newImage("graphics/deadface.png"),
    love.graphics.newImage("graphics/coolface.png"),
    love.graphics.newImage("graphics/sleepface.png")
}
for k,v in pairs(faces) do
    v:setFilter("nearest")
end
local flagg = love.graphics.newImage("graphics/flag.png"); flagg:setFilter("nearest")
local flagcg = love.graphics.newImage("graphics/flagc.png"); flagcg:setFilter("nearest")
local mineg = love.graphics.newImage("graphics/mine.png"); mineg:setFilter("nearest")
local tileg = love.graphics.newImage("graphics/tile.png"); tileg:setWrap("repeat"); tileg:setFilter("nearest")
local tilegrid = love.graphics.newQuad(0, 0, 24*10, 24*10, 24, 24)
-- Danger number colors
local dangercolors = {
    {0,0,1},
    {0,0.5,0},
    {1,0,0},
    {0,0,0.5},
    {0.5,0,0},
    {0,0.5,0.5},
    {1,1,1},
    {0.5,0.5,0.5}
}
-- Playfield canvas
local c_playfield = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
local c_all = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
-- Playfield tables
local buttons = {}
local minefield = {}
local dangers = {}
local failcoords = {0,0}
-- Local variables
local timer = 0
local minesleft = 0
-- States
local started = false
local gameover = false
local youwin = false
local paused = false
local inwindow = false
local redraw = true
-- Local functions
local function getMaxGridDimensions()
    local _, _, flags = love.window.getMode()
    local w, h = love.window.getDesktopDimensions(flags.display)
    w = (w / _Scale - 40) 
    h = (h / _Scale - 80)
    _MaxGridW = math.ceil(w/24) - 1
    _MaxGridH = math.ceil(h/24) - 3
end

local function setWindowResolution(w, h)
    local width = (44 + w*24) * _Scale
    local height = (84 + h*24) * _Scale
    love.window.setMode(width, height)
    topribbon:resize(love.graphics.getWidth(), love.graphics.getHeight())
    redraw = true
end

local function isGameHalted()
    local halted = false
    if paused then halted = true end
    if gameover then halted = true end
    if youwin then halted = true end
    if inwindow then halted = true end
    return halted
end

local function setFace()
    if gameover then
        resetb.icon = faces[3]
    elseif youwin then
        resetb.icon = faces[4]
    elseif paused then
        resetb.icon = faces[5]
    elseif inwindow and paused then
        resetb.icon = faces[5]
    else
        resetb.icon = faces[1]
    end
end

local function setInWindowTrue()
    inwindow = true
    if not gameover and not youwin and started then
        paused = true
    end
    setFace()
end

local function setInWindowFalse()
    inwindow = false
    if not gameover and not youwin and started then
        paused = false
    end
    setFace()
end

local function validateParams()
    if _Mode ~= "custom" then return end
    if _GridH < 6 then _GridH = 6 end
    if _GridW < 6 then _GridW = 6 end
    if _GridW > _MaxGridW then _GridW = _MaxGridW end
    if _GridH > _MaxGridH then _GridH = _MaxGridH end
    if _Mines < 1 then
       _Mines = 1
    end
    if _Mines > 999 then
        _Mines = 999
    end
    if _Mines > _GridW * _GridH - 1 then
        _Mines = _GridW * _GridH - 1
    end
end

local function generateMines(count,avoidy,avoidx)
    -- Generate mines
    local left = _Mines
    minefield = {}
    for i=1, _GridH do
        table.insert(minefield,{})
        for j=1, _GridW do
            minefield[i][j] = false
        end
    end
    math.randomseed(os.time())
    while left > 0 do
        local placex = math.random(1,_GridW)
        local placey = math.random(1,_GridH)
        local playerpick = false
        if placex == avoidx and placey == avoidy then playerpick = true end
        if not minefield[placey][placex] and not playerpick then
            minefield[placey][placex] = true
            left = left - 1
        end
    end
end

local function generateDangerNumbers()
    dangers = {}
    for i=1, _GridH do
        table.insert(dangers,{})
        for j=1, _GridW do
            local danger = 0
            if minefield[i][j] then dangers[i][j] = 0
            else
                if minefield[i-1] then if minefield[i-1][j-1] then danger = danger + 1 end end
                if minefield[i-1] then if minefield[i-1][j] then danger = danger + 1 end end
                if minefield[i-1] then if minefield[i-1][j+1] then danger = danger + 1 end end
                if minefield[i][j-1] then danger = danger + 1 end
                if minefield[i][j+1] then danger = danger + 1 end
                if minefield[i+1] then if minefield[i+1][j-1] then danger = danger + 1 end end
                if minefield[i+1] then if minefield[i+1][j] then danger = danger + 1 end end
                if minefield[i+1] then if minefield[i+1][j+1] then danger = danger + 1 end end
                dangers[i][j] = danger
            end
        end
    end
end

local function deleteButtonsWithMines()
    for ky,row in pairs(minefield) do
        for kx,cell in pairs(row) do
            if minefield[ky][kx] then
                if not buttons[ky][kx].flagged then buttons[ky][kx] = nil end
            else
                if buttons[ky][kx] and buttons[ky][kx].flagged then buttons[ky][kx].icon = flagcg end
            end
        end
    end
end

local function floodEmptySpaces(x, y)
    if x>0 and x<_GridW+1 and y>0 and y<_GridH+1 then
        if buttons[y][x] and not buttons[y][x].flagged then
            buttons[y][x] = nil
            if dangers[y][x] == 0 then
                floodEmptySpaces(x+1, y)
                floodEmptySpaces(x-1, y)
                floodEmptySpaces(x, y-1)
                floodEmptySpaces(x, y+1)
                floodEmptySpaces(x+1, y+1)
                floodEmptySpaces(x-1, y-1)
                floodEmptySpaces(x-1, y+1)
                floodEmptySpaces(x+1, y-1)
            end
        else
            return
        end
    end
end

local function checkWinCondition()
    local buttoncount = 0
    for ky,row in pairs(buttons) do
        for kx,cell in pairs(row) do
            buttoncount = buttoncount + 1
        end
    end
    if buttoncount > _Mines then return end -- there are still uncovered tiles that dont have mines

    for ky,row in pairs(buttons) do -- make the rest of the tiles flagged
        for kx,cell in pairs(row) do
            cell.flagged = true
            cell.icon = flagg
        end
    end
    minesleft = 0
    youwin = true
    if _Mode == "custom" then return end
    -- check if new score was made
    for k,v in ipairs(_Scores[_Mode]) do
        if k > 10 then break end
        if timer < v[2] then
            love.mousereleased(0, 0, 1) -- a quirky solution to a quirky problem
            windows.scoreentry.createWindow(timer,k)
            break
        end
    end
end

local function deleteAllWindows()
    for k,v in pairs(windows) do
        if v.destroyWindow then v.destroyWindow() end
    end
end
-- GRID BUTTON FUNCTIONS
local function leftclick(buttonobj)
    local x = buttonobj.row
    local y = buttonobj.col
    if not started then
        generateMines(_Mines, y, x)
        generateDangerNumbers()
        started = true
    end
    if not buttonobj.flagged then
        if minefield[y][x] then
            gameover = true
            deleteButtonsWithMines()
            failcoords = {x-1,y-1}
        end
        --
        if dangers[y][x] == 0 then floodEmptySpaces(x, y)
        else buttons[y][x] = nil end
    end
    if not gameover then checkWinCondition() end
    redraw = true
    collectgarbage()
end

local function rightclick(buttonobj)
    buttonobj.flagged = not buttonobj.flagged
    if buttonobj.flagged then buttonobj.icon = flagg; minesleft = minesleft - 1
    else buttonobj.icon = nil; minesleft = minesleft + 1 end
    redraw = true
end

local function rescalePlus(but)
    _Scale = _Scale + 0.5
    if _Scale > _MaxScale then _Scale = _MinScale end
    but.text = _Scale.."x"
    setWindowResolution(_GridW,_GridH)
    fileparser.saveScale()
    getMaxGridDimensions()
end

local function rescaleMinus(but)
    _Scale = _Scale - 0.5
    if _Scale < _MinScale then _Scale = _MaxScale end
    but.text = _Scale.."x"
    setWindowResolution(_GridW,_GridH)
    fileparser.saveScale()
    getMaxGridDimensions()
end

-- GAME SETTINGS LOCAL FUNCTIONS
local function resetGame()
    buttons = {}
    collectgarbage()
    for y=1,_GridH do
        table.insert(buttons,{})
        for x=1,_GridW do
            local tmpbutt = gmui.Button:new({
                xpos = x*24,
                ypos = (y*24) + 40,
                w = 20,
                h = 20,
                func = leftclick,
                altfunc = rightclick,
                style = sweepstyle,
                row = x,
                col = y,
                flagged = false
            })
            table.insert(buttons[y],tmpbutt)
        end
    end
    minefield = {}
    dangers = {}
    gameover = false
    youwin = false
    started = false
    paused = false
    redraw = true
    minesleft = _Mines
    timer = 0
    resetb.icon = faces[1]
end

local function startNewGame()
    _Mode = _SetMode
    if _Mode == "easy" then
        _GridW = 10
        _GridH = 10
        _Mines = 10
    elseif _Mode == "medium" then
        _GridW = 16
        _GridH = 16
        _Mines = 40
    elseif _Mode == "hard" then
        _GridW = 30
        _GridH = 16
        _Mines = 99
    elseif _Mode == "custom" then
        _GridW = _SetGridW
        _GridH = _SetGridH
        _Mines = _SetMines
    end
    validateParams()
    fileparser.saveScale()
    fileparser.saveSettings()
    fileparser.saveScores(_Mode)
    setWindowResolution(_GridW, _GridH)
    resetGame()
    tilegrid = love.graphics.newQuad(0, 0, 24*_GridW, 24*_GridH, 24, 24)
    c_playfield = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight()); c_playfield:setFilter("nearest")
    c_all = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight()); c_all:setFilter("nearest")
    resetb.x = love.graphics.getWidth()/2/_Scale - 15 -- Move the reset button to the center
    topribbon.children.scale.xpos = love.graphics.getWidth()/_Scale-38
    topribbon.children.scale.x = love.graphics.getWidth()/_Scale-34
    redraw = true -- redraw the playfield
end

local function createUiElements()
    -- Add window events
    for k,w in pairs(windows) do
        if k == "game" then
            w.addEvent('newgame',startNewGame)
        end
        if k == "scoreentry" then
            w.addEvent('destroy',function(spot)
                fileparser.saveScores(_Mode)
                fileparser.saveSettings()
                windows.scores.createWindow(spot)
            end)
            w.addEvent('create',setInWindowTrue)
        else
            w.addEvent('destroy',setInWindowFalse)
            w.addEvent('create',setInWindowTrue)
        end
    end

    resetb = gmui.Button:new {  -- Reset button
        xpos = love.graphics.getWidth()/2 - 15,
        ypos = 26,
        w = 30,
        h = 30,
        icon = faces[1],
        func = resetGame,
        style = sweepstyle
    }

    topribbon = gmui.Panel:new {    -- Top ribbon
        xpos = 2,
        ypos = 2,
        w = love.graphics.getWidth()-4,
        h = 16,
        anchor = "top",
        border = "in",
        children = {
            game = gmui.Button:new {   -- New game button
                xpos = 0,
                ypos = 0,
                w = 40,
                h = 14,
                text = "Game",
                func = function() deleteAllWindows(); windows.game.createWindow() end
            },
            scores = gmui.Button:new {   -- Scores button
                xpos = 44,
                ypos = 0,
                w = 42,
                h = 14,
                text = "Scores",
                func = function() deleteAllWindows(); windows.scores.createWindow(1) end
            },
            about = gmui.Button:new {   -- About button
                xpos = 90,
                ypos = 0,
                w = 40,
                h = 14,
                text = "About",
                func = function() deleteAllWindows(); windows.about.createWindow() end
            },
            scale = gmui.Button:new {
                xpos = love.graphics.getWidth() / _Scale - 32,
                ypos = 0,
                w = 30,
                h = 14,
                text = _Scale.."x",
                func = rescalePlus,
                altfunc = rescaleMinus
            }
        }
    } -- top ribbon end
end
-- CALLBACK FUNCTIONS
function love.load(args)
    getMaxGridDimensions()
    fileparser.loadScale()
    fileparser.loadSettings()
    fileparser.loadScores("easy")
    fileparser.loadScores("medium")
    fileparser.loadScores("hard")
    -- Parse arguments
    if #args > 0 then
        _SetMode = "custom"
        _SetGridW = tonumber(args[1])
        if args[2] then _SetGridH = tonumber(args[2])
        else _SetGridH = _SetGridW end
        if args[3] then _SetMines = tonumber(args[3])
        else _SetMines = math.max(_SetGridW, _SetGridH) end
    end
    createUiElements()
    startNewGame()
end

function love.update(dt)
    if timer < 999 and not isGameHalted() and started then timer = timer + dt end
    if inwindow then
        for k,w in pairs(windows) do
            if w.update then w.update(dt) end
        end
    end
end

function love.draw()
    c_all:renderTo(function()
        love.graphics.clear(0,0,0)
        resetb:draw()   -- Draw reset button
        -- Draw number displays
        display.draw(minesleft,3,love.graphics.getWidth() / 2 / _Scale - 94,20)
        display.draw(math.floor(timer),3,love.graphics.getWidth() / 2 / _Scale + 30,20)
        -- Draw background tiles
        love.graphics.draw(tileg, tilegrid, 22, 62)
        if not paused then
            if redraw then -- Redraw playfield
                -- Draw on playfield canvas
                c_playfield:renderTo(function()
                    love.graphics.clear(0,0,0,0)
                    -- Draw buttons (covered tiles)
                    for ky,row in pairs(buttons) do
                        for kx,cell in pairs(row) do
                            cell:draw()
                        end
                    end
                    -- Draw danger numbers
                    for ky,row in pairs(dangers) do
                        for kx,cell in pairs(row) do
                            if cell > 0 and not buttons[ky][kx] then 
                                love.graphics.setColor(dangercolors[cell])
                                love.graphics.printf(cell,mainfont,kx*24 + 4,ky*24+39, 24)
                            end
                        end
                    end
                    -- Draw game over state
                    if gameover then
                        -- Draw fail position
                        love.graphics.setColor(1,0,0)
                        love.graphics.rectangle("fill",failcoords[1]*24+22,failcoords[2]*24+62,24,24)
                        love.graphics.setColor(1,1,1)
                        -- Draw mines
                        for ky,row in pairs(minefield) do
                            for kx,cell in pairs(row) do
                                if cell then
                                    if not buttons[ky][kx] then love.graphics.draw(mineg,kx*24+1,ky*24+41) end
                                end
                            end
                        end
                    end
                end)
                redraw = false
            end
            love.graphics.setColor(1,1,1)
            love.graphics.draw(c_playfield) -- Draw playfield
            -- Draw only the clicked button on the field
            for ky,row in pairs(buttons) do
                for kx,cell in pairs(row) do
                    if cell.clicked then cell:draw(); break end
                end
            end 
        end
        topribbon:draw()    -- Draw top ribbon
        -- Draw windows
        if inwindow then
            for k,w in pairs(windows) do
                if w.draw then w.draw() end
            end
        end
    end)
    love.graphics.draw(c_all,0,0,0,_Scale,_Scale)
end

function love.keypressed(key, scancode, isrepeat)
    if inwindow then
        for k,w in pairs(windows) do
            if w.keypressed then w.keypressed(key, scancode, isrepeat) end
        end
    end
end

function love.keyreleased(key, scancode, isrepeat)
    if inwindow then
        for k,w in pairs(windows) do
            if w.keyreleased then w.keyreleased(key, scancode, isrepeat) end
        end
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    x = x / _Scale
    y = y / _Scale
    -- Playefield pressed logic
    if not isGameHalted() then
        if x > 20 and x < 24 * _GridW + 20 and y > 60 and y < 24 * _GridH + 60 then
            if button == 1 then resetb.icon = faces[2] end -- Set main button to :o face
            for ky,row in pairs(buttons) do
                for kx,cell in pairs(row) do
                    cell:mousepressed(x, y, button, istouch, presses)
                end
            end
        end
    end
    -- Reset button pressed logic
    if not inwindow then
        resetb:mousepressed(x, y, button, istouch, presses)
    end
    -- Window pressed logic
    local onwindow = false
    if inwindow then
        for k,w in pairs(windows) do
            if w.mousepressed then
                if w.mousepressed(x, y, button, istouch, presses) then onwindow = true end
            end
        end
    end
    -- Ribbon pressed logic
    if not windows.scoreentry.isWindowOpen() and not onwindow then topribbon:mousepressed(x, y, button, istouch, presses) end
end

function love.mousereleased(x, y, button, istouch, presses)
    x = x / _Scale
    y = y / _Scale
    -- Playefield released logic
    if not isGameHalted() then
        for ky,row in pairs(buttons) do
            for kx,cell in pairs(row) do
                cell:mousereleased(x, y, button, istouch, presses)
            end
        end
    end
    -- Reset button released logic
    if not inwindow then
        resetb:mousereleased(x, y, button, istouch, presses)
        setFace()
    end
    -- Window released logic
    local onwindow = false
    if inwindow then
        for k,w in pairs(windows) do
            if w.mousereleased then
                if w.mousereleased(x, y, button, istouch, presses) then onwindow = true end
            end
        end
    end
    -- Ribbon released logic
    if not windows.scoreentry.isWindowOpen() and not onwindow then topribbon:mousereleased(x, y, button, istouch, presses) end
end

function love.mousemoved(mx, my, dx, dy, istouch)
    mx = mx / _Scale
    my = my / _Scale
    -- Playfield mmoved logic
    if mx > 20 and mx < 24 * _GridW + 20 and my > 60 and my < 24 * _GridH + 60 then
        if not isGameHalted() then
            for ky,row in pairs(buttons) do
                for kx,cell in pairs(row) do
                    if cell.mousemoved then cell:mousemoved(mx, my, dx, dy, istouch) end
                end
            end
        end
    end
    -- Rest of mmoved logic
    topribbon:mousemoved(mx, my, dx, dy, istouch)
    if not inwindow then
        resetb:mousemoved(mx, my, dx, dy, istouch)
        return
    end
    -- Window mmoved logic
    if inwindow then
        for k,w in pairs(windows) do
            if w.mousemoved then w.mousemoved(mx, my, dx, dy, istouch) end
        end
    end
end

function love.focus(focus)
    if started and not gameover and not youwin then
        paused = not focus
        if paused then resetb.icon = faces[5]
        else resetb.icon = faces[1] end
    end
end

love.textinput = windows.scoreentry.textinput
