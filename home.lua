term.clear() term.setCursorPos(1, 1)
require("tools")
local spSetting = require("settings")
if type(spSetting.colors) == "table" then for name, color in pairs(spSetting.colors) do colors[name] = color end end
local function settingsTable(t, prefix)
    if not prefix then prefix = "" end
    for name, value in pairs(t) do
        if type(value) == "table" then
            settingsTable(value, prefix..tostring(name)..".")
        else
            settings.define(prefix..tostring(name))
            settings.set(prefix..tostring(name), value)
        end
    end
end
settingsTable(spSetting, "spyglass.")

local buttons = {
    shell = { program=".spyglass/programs/shell.lua" },
    sys = { program=".spyglass/programs/sys.lua" },
    files = { program=".spyglass/programs/files.lua" },
    tables = { program=".spyglass/programs/tables.lua" },
}
local layout = {
    { "shell", "sys", "files", "tables" },
}
multishell.setTitle(multishell.getCurrent(),"[#]")
if type(spSetting.start_programs) == "table" then
    for i, path in ipairs(spSetting.start_programs) do
        local tab = multishell.launch({shell=shell,multishell=multishell,os=os,textutils=textutils,require=require}, path)
        if k == 1 then multishell.setFocus(tab) end
    end
end
while true do
    local W, H = term.getSize()
    local buttonPoses, BX, BY, BW, BH = {}, 1, 3, W, 1
    for y, row in ipairs(layout) do
        if type(row) == "table" then
            for x, name in ipairs(row) do
                if type(name) == "string" then
                    buttonPoses[name] = { x1 = math.floor(BX + (x - 1) * (BW / #row)),
                                          x2 = math.floor(BX + (x - 1) * (BW / #row)) + #name+2,
                                          y1 = BY + (y - 1) * (BH / #layout), y2 = BY + (y - 1) * (BH / #layout) }
                end
            end
        end
    end
    term.clear() term.setCursorPos(W/2-#"SPYGLASS"/2, 1)
    writeColor("%info%SPYGLASS%std%")
    for name, pos in pairs(buttonPoses) do
        term.setCursorPos(pos.x1, pos.y1) writeColor("%light%[%std%"..name.."%light%]%std%")
    end
    local event, k, x, y = os.pullEvent()
    log(event, k, x, y)
    if event == "mouse_click" then
        for name, pos in pairs(buttonPoses) do
            if (x >= pos.x1 and x <= pos.x2) and (y >= pos.y1 and y <= pos.y2) then
                local tab = multishell.launch(
                        {shell=shell,multishell=multishell,os=os,textutils=textutils,require=require},
                        buttons[name].program)
                if k == 1 then multishell.setFocus(tab) end
                break
            end
        end
    end
end