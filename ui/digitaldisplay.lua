local display = {}

local displaybg = love.graphics.newImage("graphics/display_bg.png")
local displaynums = {
    ["-"] = love.graphics.newImage("graphics/display_-.png"),
    ["0"] = love.graphics.newImage("graphics/display_0.png"),
    ["1"] = love.graphics.newImage("graphics/display_1.png"),
    ["2"] = love.graphics.newImage("graphics/display_2.png"),
    ["3"] = love.graphics.newImage("graphics/display_3.png"),
    ["4"] = love.graphics.newImage("graphics/display_4.png"),
    ["5"] = love.graphics.newImage("graphics/display_5.png"),
    ["6"] = love.graphics.newImage("graphics/display_6.png"),
    ["7"] = love.graphics.newImage("graphics/display_7.png"),
    ["8"] = love.graphics.newImage("graphics/display_8.png"),
    ["9"] = love.graphics.newImage("graphics/display_9.png")
}

local function getDigitCount(value)
    return string.len(tostring(value))
end

function display.draw(value,count,x,y)
    value = value or 0
    count = count or getDigitCount(value)
    x = x or 0
    y = y or 0
    if value > 999 then value = 999 end
    if value < -99 then value = -99 end
    for i=0,count-1 do
        love.graphics.draw(displaybg, x+i*22, y)
    end
    local txt = tostring(value)
    local diff = count - string.len(txt)
    for i=1,diff do
        txt = " "..txt
    end 
    for i=0,count-1 do
        if displaynums[txt:sub(i+1,i+1)] then
            love.graphics.draw(displaynums[txt:sub(i+1,i+1)], x+i*22, y)
        end
    end
end

return display