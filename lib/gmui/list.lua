local style = require "lib.gmui.style"

local List = {
    xpos = 0,
    ypos = 0,
    w = 128,
    h = 128,
    style = style:new(),
    textal = "left",
    elements = {},
    clickfunc = nil,
    pressfunc = nil,
    selected = ""
}

List.hover = false

function List:draw()
    local tr,tg,tb,ta = love.graphics.getColor()    -- get current color to later reset it
    
    love.graphics.setColor(self.style.bt_shad_color)
    love.graphics.rectangle("fill",self.x-2,self.y-2,self.w+4,self.h+4)

    love.graphics.setColor(self.style.bt_light_color)
    love.graphics.rectangle("fill",self.x,self.y,self.w+2,self.h+2)

    love.graphics.setColor(self.style.bg_color)
    love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)

    love.graphics.setColor(self.style.txt_color)
    self.drawcanvas:renderTo(function()
        love.graphics.clear(0,0,0,0)
        for k,v in ipairs(self.elements) do

            if k >= self.h/12 then break end
            if k == self.selected then
                love.graphics.setColor(self.style.bg2_color)
                love.graphics.rectangle("fill",0,12*(k-1),self.w,13)
            end
    
            love.graphics.setColor(self.style.txt_color)
            love.graphics.printf(v,2,12*(k-1)-2,self.w*4,self.textal)
        end
    end)

    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.drawcanvas,self.x,self.y)

    --love.graphics.setColor(self.style.bg2_color)
    --love.graphics.rectangle("fill",self.x+self.w-20,self.y,20,self.h)

    love.graphics.setColor(tr,tg,tb,ta)
end

function List:mousepressed( mx, my, button, istouch, presses )
    if mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h then
        for k,v in ipairs(self.elements) do
            if my >= 12*(k-1)+self.y and my <= 12*(k-1)+self.y+12 then
                self.selected = k
            end
        end
        if self.clickfunc then self.clickfunc(self) end
        if presses == 2 then
            if type(self.pressfunc) == "function" then self.pressfunc(self.selected)
            elseif type(self.pressfunc) == "table" then self.pressfunc[1](self.pressfunc[2],self.selected) end
        end
    end
end

function List:mousemoved( mx, my, dx, dy, istouch )
    if mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h then
        self.hover = true
    else
        self.hover = false
    end
end

function List:wheelmoved( x, y )
    if self.hover then
        print("y"..y)
    end
end

function List:getSelectedElement()
    return self.elements[self.selected]
end

function List:new(params)
    params = params or {}

    if params.xpos and params.ypos then
        params.x = params.xpos
        params.y = params.ypos
    end

    params.drawcanvas = love.graphics.newCanvas(params.w,params.h)

    setmetatable(params,self)
    self.__index = self
    return params
end

return List
