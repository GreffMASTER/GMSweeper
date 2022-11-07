local style = require "lib.gmui.style"
local utf8 = require "utf8"

local Textbox = {
    xpos = 0,
    ypos = 0,
    w = 100,
    h = 100,
    style = style:new(),
    maxsize = 255,
    value = "",
    default = "Text"
}

Textbox.hover = false
Textbox.selected = false
Textbox.erasemode = false
Textbox.erasedelay = 0.5

function Textbox:update(dt)
    if self.erasemode then
        self.erasedelay = self.erasedelay - dt
        if self.erasedelay <= 0 then
            local byteoffset = utf8.offset(self.value, -1)
            if byteoffset then
                self.value = string.sub(self.value, 1, byteoffset - 1)
            end
            self.erasedelay = 0.025
        end
    end
end

function Textbox:draw()
    love.graphics.setColor(self.style.bt_shad_color)
    love.graphics.rectangle("fill",self.x-2,self.y-2,self.w+4,self.h+4)

    love.graphics.setColor(self.style.bt_light_color)
    love.graphics.rectangle("fill",self.x,self.y,self.w+2,self.h+2)

    love.graphics.setColor(self.style.txtbx_bg_color)
    love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)
    
    self.drawcanvas:renderTo(function()
        love.graphics.clear(0,0,0,0)
        love.graphics.setColor(self.style.txt_color)   
        if self.selected then
            love.graphics.printf(self.value.."|",0,0,self.w * 4)
        else
            if string.len(self.value) < 1 then
                love.graphics.setColor(self.style.txt_dis_color)
                love.graphics.printf(self.default,0,0,self.w * 4)
            else
                love.graphics.printf(self.value,0,0,self.w * 4)
            end
        end
    end)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.drawcanvas,self.x,self.y)
end

function Textbox:keypressed(key, scancode, isrepeat)
    if self.selected then
        if key == "backspace" then
            local byteoffset = utf8.offset(self.value, -1)
            if byteoffset then
                self.value = string.sub(self.value, 1, byteoffset - 1)
            end
            self.erasemode = true
        end
    end
end

function Textbox:keyreleased(key, scancode, isrepeat)
    if key == "backspace" then
        self.erasemode = false
        self.erasedelay = 0.5
    end
end

function Textbox:mousepressed(x, y, button, istouch, presses)
    if x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h then
        self.selected = true
    else
        self.selected = false
    end
end

function Textbox:mousemoved(mx, my, dx, dy, istouch)
    if mx >= self.x-1 and mx <= self.x + self.w+1 and my >= self.y-1 and my <= self.y + self.h+1 then
        if not self.hover then
            love.mouse.setCursor( love.mouse.getSystemCursor( "ibeam" ) )
        end
        self.hover = true
    else
        if self.hover then
            love.mouse.setCursor( love.mouse.getSystemCursor( "arrow" ) )
        end
        self.hover = false
    end
end

function Textbox:textinput(text)
    if self.selected then
        if string.len(self.value) < self.maxsize then
            self.value = self.value .. text
        end
    end
end

function Textbox:new(params)
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

return Textbox
