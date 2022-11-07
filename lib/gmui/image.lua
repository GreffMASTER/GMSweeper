local style = require "lib.gmui.style"

local UIImage = {
    xpos = 0,
    ypos = 0,
    w = 100,
    h = 50,
    sx = 1,
    sy = 1,
    style = style:new(),
    image = nil
}

function UIImage:draw()
    local tr,tg,tb,ta = love.graphics.getColor()    -- get current color to later reset it
    if self.image then
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(self.image,self.x,self.y,0,self.sx,self.sy)
    end
    love.graphics.setColor(tr,tg,tb,ta)             -- reset color back to normal
end

function UIImage:new(params)
    params = params or {}
    if params.xpos and params.ypos then
        params.x = params.xpos
        params.y = params.ypos
    end
    setmetatable(params,self)
    self.__index = self
    return params
end

return UIImage
