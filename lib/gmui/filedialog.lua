local window = require "lib.gmui.window"
local button = require "lib.gmui.button"
local list = require "lib.gmui.list"
local style = require "lib.gmui.style"

local darktheme = style:new({
    bg_color = {0.1,0.1,0.1,1},
    bg2_color = {0.3,0.3,0.3,1},

    bt_color = {0.2,0.2,0.2,1},
    bt_light_color = {0.5,0.5,0.5,1},
    bt_shad_color = {0,0,0,1},
    bt_hover_color = {0.3,0.3,0.3,1},
    bt_click_color = {0.1,0.1,0.1,1},
    bt_dis_color = {0.15,0.15,0.15,1},

    txt_color = {0.9,0.9,0.9,1},
    txt_dis_color = {0.4,0.4,0.4,1},

    winbar_color = {0,0.3,0,1},
    winbar_off_color = {0,0.15,0,1},
    winbar_txt_color = {1,1,1,1}
})

local function openFolder()
    return love.system.openURL("file://"..love.filesystem.getSaveDirectory())
end

local function createPathFromTable(tab)
    local path = ""
    for k,v in ipairs(tab) do
        path = path..v.."/"
    end
    return path
end

local FileDialog = {}

local canbutt = button:new({xpos=0,ypos=172,text="Cancel"})
local okbutt = button:new({xpos=168,ypos=172,text="Ok"})
local brwsbutt = button:new({xpos=84,ypos=172,text="Browse",func=openFolder})
local filelist = list:new({w=248,h=164,elements = love.filesystem.getDirectoryItems( "" )})
table.insert(filelist.elements,1,"..")

filelist.path = {""}

filelist.advancePath = function(self,str)
    local newpath = ""

    if str == ".." then
        table.remove(self.path,#self.path)
        newpath = createPathFromTable(self.path)
        self.elements = love.filesystem.getDirectoryItems( newpath )
        table.insert(self.elements,1,"..")
        return
    end
    local temp = {unpack(self.path)}
    table.insert(temp,str)
    local temppath = createPathFromTable(temp)

    local f = love.filesystem.getInfo( temppath )
    if f then
        if f.type == "directory" then
            table.insert(self.path,str)
            newpath = createPathFromTable(self.path)
            self.elements = love.filesystem.getDirectoryItems( newpath )
            table.insert(self.elements,1,"..")
        end
    end
    FileDialog.filepath = newpath
    print(FileDialog.filepath)
end

filelist.pressfunc = {filelist.advancePath,filelist}

FileDialog = window:new({
    xpos=0,
    ypos=0,
    w=256,
    h=200,
    title="File",
    children={canbutt,okbutt,brwsbutt,filelist}
})

FileDialog.filepath = "/"

function FileDialog:setStyle(style)
    self.style = style
    self.hidebutt.style = style
    if self.children then
        for k,v in pairs(self.children) do
            v.style = style
        end
    end
end

return FileDialog
