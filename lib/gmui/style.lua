local Style = {
    bg_color = {0.5,0.5,0.5,1},
    bg2_color = {0.3,0.3,0.3,1},
    bt_color = {0.5,0.5,0.5,1},
    bt_light_color = {0.8,0.8,0.8,1},
    bt_shad_color = {0.2,0.2,0.2,1},
    bt_hover_color = {0.6,0.6,0.6,1},
    bt_click_color = {0.4,0.4,0.4,1},
    bt_dis_color = {0.3,0.3,0.3,1},

    txt_color = {0,0,0,1},
    txt_dis_color = {0.5,0.5,0.5,1},
    txtbx_bg_color = {1,1,1,1},

    winbar_color = {0.2,0.4,0.7,1},
    winbar_off_color = {0,0.2,0.5,1},
    winbar_txt_color = {1,1,1,1}
}

function Style:new(params)
    params = params or {}
    setmetatable(params,self)
    self.__index = self
    return params
end

return Style
