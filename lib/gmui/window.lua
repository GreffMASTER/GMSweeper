local style = require "lib.gmui.style"
local button = require "lib.gmui.button"

local Window = {
    xpos = 1,
    ypos = 1,
    w = 320,
    h = 240,
    style = style:new(),
    movable = true,
    title = "Window",
    titleal = "center",
    closable = false,
    icon = nil,
    exitfunc = nil,
    updatefunc = nil,
    children = nil,
    window_canvas = nil
}

--Window.window_canvas = love.graphics.newCanvas( w, h )
Window.barhold = false
Window.minimized = false
Window.focused = false

local function togglevis(self)
    self.minimized = not self.minimized
    self.focused = false
end

function Window:draw()
    local tr,tg,tb,ta = love.graphics.getColor()    -- get current color to later reset it

    if not self.minimized then
        love.graphics.setColor(self.style.bt_light_color)
        love.graphics.rectangle("fill",self.xpos-1,self.ypos-1,self.w+2,self.h+2)

        love.graphics.setColor(self.style.bt_shad_color)
        love.graphics.rectangle("fill",self.xpos,self.ypos,self.w+1,self.h+1)

        love.graphics.setColor(self.style.bg_color)
        love.graphics.rectangle("fill",self.xpos,self.ypos,self.w,self.h)

        if self.children then
            for k,v in pairs(self.children) do
                if v.draw then v:draw() end
            end
        end
    end

    -- Draw Window Bar
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("fill",self.xpos,self.ypos-20,self.w+1,20)

    if self.focused then love.graphics.setColor(self.style.winbar_color)
    else love.graphics.setColor(self.style.winbar_off_color) end
    love.graphics.rectangle("fill",self.xpos+1,self.ypos-19,self.w-1,17)

    if self.focused then love.graphics.setColor(self.style.winbar_txt_color)
    else love.graphics.setColor(self.style.txt_dis_color) end
    
    if self.titleal == "left" and self.icon then
        love.graphics.printf(self.title,self.xpos+22,self.ypos+2-20,self.w-22,self.titleal)
    else
        love.graphics.printf(self.title,self.xpos+2,self.ypos+2-20,self.w,self.titleal)
    end

    if self.icon then
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(self.icon,self.xpos+2,self.ypos-18)
    end
    if self.movable then
        if self.exitbutt then self.exitbutt:draw() end
        if self.hidebutt then self.hidebutt:draw() end
    end

    love.graphics.setColor(tr,tg,tb,ta)             -- reset color back to normal
end


function Window:update(dt)
    if self.updatefunc then self:updatefunc(self,dt) end
    if self.children then
        for k,v in pairs(self.children) do
            if v.update then v:update(dt) end
        end
    end
end

function Window:keypressed(key, scancode, isrepeat)
    if not self.minimized and self.focused then
        if self.children then
            for k,v in pairs(self.children) do
                if v.keypressed then v:keypressed(key, scancode, isrepeat) end
            end
        end
    end
end

function Window:keyreleased(key, scancode, isrepeat)
    if not self.minimized and self.focused then
        if self.children then
            for k,v in pairs(self.children) do
                if v.keyreleased then v:keyreleased(key, scancode, isrepeat) end
            end
        end
    end
end

function Window:mousepressed( mx, my, button, istouch, presses )
    if self.movable then
        if mx >= self.xpos and mx <= self.xpos+self.w and my >= self.ypos-20 and my <= self.ypos then
            self.barhold = true
            self.mholdX = mx
            self.mholdY = my
        end
    end

    if self.exitbutt then self.exitbutt:mousepressed( mx, my, button, istouch, presses ) end
    if self.hidebutt then self.hidebutt:mousepressed( mx, my, button, istouch, presses ) end

    if not self.minimized and self.focused then
        if self.children then
            for k,v in pairs(self.children) do
                if v.mousepressed then v:mousepressed( mx, my, button, istouch, presses ) end
            end
        end
    end

    if not self.minimized then
        if mx >= self.xpos and mx <= self.xpos+self.w and my >= self.ypos-20 and my <= self.ypos+self.h then
            self.focused = true
            return true
        else
            self.focused = false
            return false
        end
    end
end

function Window:mousereleased( mx, my, button, istouch, presses )
    self.barhold = false
    if self.exitbutt then self.exitbutt:mousereleased( mx, my, button, istouch, presses ) end
    if self.hidebutt then self.hidebutt:mousereleased( mx, my, button, istouch, presses ) end

    if not self.minimized and self.focused then
        if self.children then
            for k,v in pairs(self.children) do
                if v.mousereleased then v:mousereleased( mx, my, button, istouch, presses ) end
            end
        end
        return true
    else
        return false
    end
end

function Window:mousemoved( mx, my, dx, dy, istouch )
    if self.barhold then

        self.xpos = self.xpos + mx - self.mholdX
        self.ypos = self.ypos + my - self.mholdY
        self.mholdX = mx
        self.mholdY = my

        if self.xpos < 0 then self.xpos = 0 end
        if self.ypos < 0+20 then self.ypos = 0+20 end
        if self.xpos > love.graphics.getWidth()-self.w then self.xpos = love.graphics.getWidth()-self.w end
        if self.ypos > love.graphics.getHeight()-self.h then self.ypos = love.graphics.getHeight()-self.h end

        if self.exitbutt then
            self.exitbutt.x = self.xpos + self.exitbutt.xpos
            self.exitbutt.y = self.ypos + self.exitbutt.ypos
        end

        if self.hidebutt then
            self.hidebutt.x = self.xpos + self.hidebutt.xpos
            self.hidebutt.y = self.ypos + self.hidebutt.ypos
        end
        
        if self.children then
            for k,v in pairs(self.children) do
                v.x = (self.xpos+4) + v.xpos
                v.y = (self.ypos+4) + v.ypos
                if v.updateposition then v:updateposition() end
            end
        end
    end

    if self.exitbutt then self.exitbutt:mousemoved( mx, my, dx, dy, istouch ) end
    if self.hidebutt then self.hidebutt:mousemoved( mx, my, dx, dy, istouch ) end

    if not self.minimized and self.focused then
        if self.children then
            for k,v in pairs(self.children) do
                if v.mousemoved then v:mousemoved( mx, my, dx, dy, istouch ) end
            end
        end
    end
end

function Window:wheelmoved( x, y )
    if not self.minimized and self.focused then
        if self.children then
            for k,v in pairs(self.children) do
                if v.wheelmoved then v:wheelmoved( x, y ) end
            end
        end
    end
end

function Window:textinput(text)
    if not self.minimized and self.focused then
        if self.children then
            for k,v in pairs(self.children) do
                if v.textinput then v:textinput(text) end
            end
        end
    end
end

function Window:resize( w, h )
    if self.xpos + self.w > w then self.xpos = w - self.w end
    if self.ypos > w then self.ypos = h end

    if self.exitbutt then
        self.exitbutt.x = self.xpos + self.exitbutt.xpos
        self.exitbutt.y = self.ypos + self.exitbutt.ypos
    end

    if self.hidebutt then
        self.hidebutt.x = self.xpos + self.hidebutt.xpos
        self.hidebutt.y = self.ypos + self.hidebutt.ypos
    end
    
    if self.children then
        for k,v in pairs(self.children) do
            v.x = (self.xpos+4) + v.xpos
            v.y = (self.ypos+4) + v.ypos
            if v.updateposition then v:updateposition() end
        end
    end
end

function Window:updateChildrenPos( )
    if self.children then
        for k,v in pairs(self.children) do
            v.x = (self.xpos+4) + v.xpos
            v.y = (self.ypos+4) + v.ypos
            if v.updateposition then v:updateposition() end
        end
    end
end

function Window:new(params)
    params = params or {}

    local bbfset = 15

    if params.closable then
        params.exitbutt = button:new({xpos=params.w-bbfset, ypos = -16, w=12, h=12, text = "X", textal = "center", style=params.style})
        params.exitbutt.x = params.xpos + params.exitbutt.xpos;params.exitbutt.y = params.ypos + params.exitbutt.ypos
        bbfset = 30
    end

    if params.minimizable then
        params.hidebutt = button:new({
            xpos=params.w-bbfset,
            ypos = -16,
            w=12,
            h=12,
            text = "-",
            textal = "center",
            style=params.style,
            toggle=true,
            func={togglevis,params}
        })   
        params.hidebutt.x = params.xpos + params.hidebutt.xpos
        params.hidebutt.y = params.ypos + params.hidebutt.ypos
    end
    
    if params.ypos < 20 then
        params.ypos = 20
        if params.minimizable then
            params.hidebutt.y = params.ypos + params.hidebutt.ypos
        end
    end

    if params.icon and params.icon:type() == "Image" then
        local newicon = love.graphics.newCanvas(16,16)
        
        newicon:renderTo(function()
            love.graphics.clear()
            love.graphics.setBlendMode("alpha", "premultiplied")
            love.graphics.setColor(1,1,1,1)
            love.graphics.scale(16/params.icon:getWidth(),16/params.icon:getHeight())
            love.graphics.draw(params.icon)
            love.graphics.scale(1,1)
            love.graphics.setBlendMode("alpha", "alphamultiply")
        end)
        params.icon = newicon
    end

    if params.children then
        for k,v in pairs(params.children) do
            v.x = (params.xpos+4) + v.xpos
            v.y = (params.ypos+4) + v.ypos
            v.style = params.style
            v.parent = params
        end
    end

    setmetatable(params,self)
    self.__index = self
    return params
end

return Window
