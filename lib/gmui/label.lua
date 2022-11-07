local style = require "lib.gmui.style"

local Label = {
    xpos = 0,
    ypos = 0,
    w = 100,
    h = 50,
    style = style:new(),
    color = nil,
    text = "",
    textal = "left",
    href = nil
}

Label.hover = false

function Label:draw()
    local tr,tg,tb,ta = love.graphics.getColor()    -- get current color to later reset it
    if self.color then love.graphics.setColor(self.color)
    else love.graphics.setColor(self.style.txt_color) end
    if type(self.text) == "table" then love.graphics.setColor(1,1,1) end
    love.graphics.printf(self.text,self.x,self.y,self.w,self.textal)
    love.graphics.setColor(tr,tg,tb,ta)             -- reset color back to normal
end

function Label:mousepressed(x, y, button, istouch, presses)
    if self.href then
        if x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h then
            love.system.openURL( self.href )
        end
    end
end

function Label:mousemoved(mx, my, dx, dy, istouch)
    if self.href then
        if mx >= self.x-1 and mx <= self.x + self.w+1 and my >= self.y-1 and my <= self.y + self.h+1 then
            if not self.hover then
                love.mouse.setCursor( love.mouse.getSystemCursor( "hand" ) )
            end
            self.hover = true
        else
            if self.hover then
                love.mouse.setCursor( love.mouse.getSystemCursor( "arrow" ) )
            end
            self.hover = false
        end
    end
end

function Label:new(params)
    params = params or {}
    if params.xpos and params.ypos then
        params.x = params.xpos
        params.y = params.ypos
    end
    setmetatable(params,self)
    self.__index = self
    return params
end

return Label
