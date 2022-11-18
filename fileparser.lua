local fileparser = {}

local function gsort(a,b)
    return a[2] < b[2]
end

local diffis = {"easy","medium","hard","custom"}

local function checkForDiffs(str)
    local isintable = false
    for k,v in pairs(diffis) do
        if str == v then isintable = true end
    end
    return isintable
end

local function makeEmptySettings()
    local wfile = love.filesystem.newFile("settings.txt","w")
    wfile:write(_Username.."\n")
    wfile:write("easy")
    wfile:close()
    _SetMode = "easy"
end

function fileparser.loadSettings()
    local sfile = love.filesystem.getInfo("settings.txt")
    if sfile then
        local rfile = love.filesystem.newFile("settings.txt","r")
        local setts = {}
        for line in rfile:lines() do
            table.insert(setts,line)
        end
        rfile:close()
        _Username = setts[1]
        _SetMode = setts[2]
        if _SetMode == "custom" then
            _SetGridW = tonumber(setts[3])
            _SetGridH = tonumber(setts[4])
            _SetMines = tonumber(setts[5])
        end
        if type(_SetMode) ~= "string" then _SetMode = "easy"
        else
            if not checkForDiffs(_SetMode) then _SetMode = "easy" end
        end
        if type(_SetGridW) ~= "number" then _SetGridW = 10 end
        if type(_SetGridH) ~= "number" then _SetGridH = 10 end 
        if type(_SetMines) ~= "number" then _SetMines = 10 end 
    else
        makeEmptySettings()
    end
end

function fileparser.saveSettings()
    local wfile = love.filesystem.newFile("settings.txt","w")
    wfile:write(_Username.."\n")
    wfile:write(_Mode.."\n")
    if _Mode == "custom" then
        wfile:write(tostring(_GridW).."\n")
        wfile:write(tostring(_GridH).."\n")
        wfile:write(tostring(_Mines))
    end
    wfile:close()
end

function fileparser.loadScores(diffi)
    diffi = diffi or "easy"  
    local sfile = love.filesystem.getInfo("scores_"..diffi..".txt")
    if sfile then
        local rfile = love.filesystem.newFile("scores_"..diffi..".txt","r")
        local linecount = 1
        local position = 1
        for line in rfile:lines() do
            if position <= 10 then  -- limit to only 10 scores
                if linecount % 2 == 0 then
                    if type(tonumber(line)) ~= "number" then
                        _Scores[diffi][position][2] = 999.99
                        break
                    end
                    _Scores[diffi][position][2] = tonumber(line)
                    position = position + 1
                else
                    if line == "" then break end
                    _Scores[diffi][position] = {}
                    _Scores[diffi][position][1] = line
                end
                linecount = linecount + 1
            end
        end
    else
        local wfile = love.filesystem.newFile("scores_"..diffi..".txt","w")
        wfile:close()
    end
    table.sort(_Scores[diffi],gsort)
end

function fileparser.saveScores(diffi)
    if diffi == "custom" then return end
    local wfile = love.filesystem.newFile("scores_"..diffi..".txt","w")
    for k,v in ipairs(_Scores[diffi]) do
        if v[1] == "" then break end
        wfile:write(v[1].."\n"..tostring(v[2]).."\n")
    end
    wfile:close()
end

function fileparser.loadScale()
    local sfile = love.filesystem.getInfo("scale.txt")
    if sfile then
        local rfile = love.filesystem.newFile("scale.txt","r")
        local outs = rfile:read()
        rfile:close()
        local out = tonumber(outs)
        if type(out) == "number" then
            if out % 0.5 ~= 0 then
                _Scale = 1
                return
            end
            if out > _MaxScale then out = _MaxScale end
            if out < _MinScale then out = _MinScale end
            _Scale = out
            return
        end
        _Scale = 1
    end
    local wfile = love.filesystem.newFile("scale.txt","w")
    wfile:write(tostring(_Scale))
    wfile:close()
end

function fileparser.saveScale()
    local wfile = love.filesystem.newFile("scale.txt","w")
    wfile:write(tostring(_Scale))
    wfile:close()
end

return fileparser
