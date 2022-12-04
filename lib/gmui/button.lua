local style = require "lib.gmui.style"

local Button = {
    xpos = 2,
    ypos = 2,
    w = 80,
    h = 20,
    style = style:new(),
    parent = nil,
    text = "",
    textalign = "center",
    icon = nil,
    toggle = false,
    disabled = false,
    onrelease = true,
    func = nil,
    altfunc = nil
}

Button.mpressed = false
Button.hover = false
Button.clicked = false
Button.toggled = false

local cursors = {}

cursors.hand = love.mouse.getSystemCursor( "hand" )
cursors.arrow = love.mouse.getSystemCursor( "arrow" )

function Button:draw()
    local tr,tg,tb,ta = love.graphics.getColor()    -- get current color to later reset it

    if self.clicked or self.toggled then
        love.graphics.setColor(self.style.bt_shad_color)
        love.graphics.rectangle("fill",self.x-2,self.y-2,self.w+4,self.h+4)
        love.graphics.setColor(self.style.bt_light_color)
        love.graphics.rectangle("fill",self.x,self.y,self.w+2,self.h+2)
    else
        love.graphics.setColor(self.style.bt_light_color)
        love.graphics.rectangle("fill",self.x-2,self.y-2,self.w+4,self.h+4)
        love.graphics.setColor(self.style.bt_shad_color)
        love.graphics.rectangle("fill",self.x,self.y,self.w+2,self.h+2)
    end

    if self.disabled then love.graphics.setColor(self.style.bt_dis_color)
    elseif self.clicked or self.toggled then love.graphics.setColor(self.style.bt_click_color)
    elseif self.hover then love.graphics.setColor(self.style.bt_hover_color)
    else love.graphics.setColor(self.style.bt_color) end

    love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)

    if self.disabled then love.graphics.setColor(self.style.txt_dis_color)
    else love.graphics.setColor(self.style.txt_color) end
    if self.icon then
        love.graphics.printf(self.text,self.x+self.icon:getWidth()+4,self.y+(self.h/2)-8,self.w,self.textalign)
    else
        love.graphics.printf(self.text,self.x,self.y+(self.h/2)-8,self.w,self.textalign)
    end

    if self.icon then
        love.graphics.setColor(1,1,1,1)
        if self.textalign == "center" then
            love.graphics.draw(self.icon,self.x+(self.w/2)-(self.icon:getWidth()/2),self.y+(self.h/2)-(self.icon:getHeight()/2))
        else
            love.graphics.draw(self.icon,self.x+2,self.y+(self.h/2)-(self.icon:getHeight()/2))
        end
    end

    love.graphics.setColor(tr,tg,tb,ta)             -- reset color back to normal
end

function Button:disable()
    self.disabled = true
end

function Button:enable()
    self.disabled = false
end

function Button:mousepressed( mx, my, button, istouch, presses )
    self.mpressed = true
    
    if mx >= self.x-1 and mx <= self.x + self.w+1 and my >= self.y-1 and my <= self.y + self.h+1 then
        if not self.diabled then
            if not self.toggle then
                self.clicked = true
            end
        else return 0 end
        if not self.disabled and self.clicked then
            if not self.onrelease then
                if button == 1 then
                    if type(self.func) == "function" then self.func(self)
                    elseif type(self.func) == "table" then self.func[1](self.func[2]) end
                elseif button == 2 then
                    if self.altfunc then
                        if type(self.altfunc) == "function" then self.altfunc(self)
                        elseif type(self.altfunc) == "table" then self.altfunc[1](self.altfunc[2]) end
                    else
                        if type(self.func) == "function" then self.func(self)
                        elseif type(self.func) == "table" then self.func[1](self.func[2]) end
                    end
                end
            end
        end
        return button
    end
    return 0
end

function Button:mousereleased( mx, my, button, istouch, presses )
    self.mpressed = false
    if mx >= self.x-1 and mx <= self.x + self.w+1 and my >= self.y-1 and my <= self.y + self.h+1 then
        if not self.disabled and self.clicked then
            if self.onrelease then
                if button == 1 then
                    if type(self.func) == "function" then self.func(self)
                    elseif type(self.func) == "table" then self.func[1](self.func[2]) end
                elseif button == 2 then
                    if self.altfunc then
                        if type(self.altfunc) == "function" then self.altfunc(self)
                        elseif type(self.altfunc) == "table" then self.altfunc[1](self.altfunc[2]) end
                    else
                        if type(self.func) == "function" then self.func(self)
                        elseif type(self.func) == "table" then self.func[1](self.func[2]) end
                    end
                end
            end
        end
        if not self.diabled and self.clicked then
            if not self.toggle then
                self.clicked = false
            end
            return button
        else return 0 end
    end
    if not self.toggle then
        self.clicked = false
    end
    return 0
end

function Button:mousemoved( mx, my, dx, dy, istouch )
    if mx >= self.x-1 and mx <= self.x + self.w+1 and my >= self.y-1 and my <= self.y + self.h+1 then
        if not self.disabled then
            if self.mpressed then self.clicked = true
            else self.hover = true end
        end
    else
        self.hover = false
        self.clicked = false
    end
end

function Button:new(params)
    params = params or {}
    if params.xpos and params.ypos then
        params.x = params.xpos
        params.y = params.ypos
    end
    setmetatable(params,self)
    self.__index = self
    return params
end

return Button
