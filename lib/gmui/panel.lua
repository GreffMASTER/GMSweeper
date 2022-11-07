local style = require "lib.gmui.style"

local Panel = {
    xpos = 0,
    ypos = 0,
    w = 100,
    h = 100,
    style = style:new(),
    border = "out",
    anchor = "bottom"
}

function Panel:draw()
    local tr,tg,tb,ta = love.graphics.getColor()    -- get current color to later reset it

    if self.border == "out" then
        love.graphics.setColor(self.style.bt_light_color)
        love.graphics.rectangle("fill",self.x-2,self.y-2,self.w+4,self.h+4)

        love.graphics.setColor(self.style.bt_shad_color)
        love.graphics.rectangle("fill",self.x,self.y,self.w+2,self.h+2)

        love.graphics.setColor(self.style.bg_color)
        love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)
    elseif self.border == "in" then
        love.graphics.setColor(self.style.bt_shad_color)
        love.graphics.rectangle("fill",self.x-2,self.y-2,self.w+4,self.h+4)

        love.graphics.setColor(self.style.bt_light_color)
        love.graphics.rectangle("fill",self.x,self.y,self.w+2,self.h+2)

        love.graphics.setColor(self.style.bg_color)
        love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)
    end

    if self.children then
        for k,v in pairs(self.children) do
            if v.draw then v:draw() end
        end
    end

    love.graphics.setColor(tr,tg,tb,ta)             -- reset color back to normal
end

function Panel:update(dt)
    if self.children then
        for k,v in pairs(self.children) do
            if v.update then v:update(dt) end
        end
    end
end

function Panel:mousepressed( mx, my, button, istouch, presses )
    if self.children then
        for k,v in pairs(self.children) do
            if v.mousepressed then v:mousepressed( mx, my, button, istouch, presses ) end
        end
    end
end

function Panel:mousereleased( mx, my, button, istouch, presses )
    if self.children then
        for k,v in pairs(self.children) do
            if v.mousereleased then v:mousereleased( mx, my, button, istouch, presses ) end
        end
    end
end

function Panel:mousemoved( mx, my, dx, dy, istouch )
    if self.children then
        for k,v in pairs(self.children) do
            if v.mousemoved then v:mousemoved( mx, my, dx, dy, istouch ) end
        end
    end
end

function Panel:wheelmoved( x, y )
    if self.children then
        for k,v in pairs(self.children) do
            if v.wheelmoved then v:wheelmoved( x, y ) end
        end
    end
end

function Panel:resize( w, h )
    if self.anchor == "bottom" then

        self.w = w-4
        self.ypos = h-self.h-2
        self.y = self.ypos

        if self.children then
            for k,v in pairs(self.children) do
                if v.resize then v:resize( w, h) end
                v.x = (self.xpos+2) + v.xpos
                v.y = (self.ypos+2) + v.ypos
            end
        end
    elseif self.anchor == "top" then
        self.w = w-4
        self.ypos = 2
        self.y = self.ypos

        if self.children then
            for k,v in pairs(self.children) do
                if v.resize then v:resize( w, h) end
                v.x = (self.xpos+2) + v.xpos
                v.y = (self.ypos+2) + v.ypos
            end
        end
    end
end

function Panel:new(params)
    params = params or {}
    if params.xpos and params.ypos then
        params.x = params.xpos
        params.y = params.ypos
    end

    if params.children then
        for k,v in pairs(params.children) do
            v.x = (params.xpos+2) + v.xpos
            v.y = (params.ypos+2) + v.ypos
            v.h = params.h-4
            v.style = params.style
        end
    end

    setmetatable(params,self)
    self.__index = self
    return params
end

return Panel
