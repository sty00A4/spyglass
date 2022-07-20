require("tools")
local strings = require("cc.strings")
local function strBytes(bytes)
    local unit = "B"
    local units = {"KB","MB","GB","TB"}
    for _, u in ipairs(units) do
        if bytes / 1000 >= 1 then bytes = math.ceil(bytes / 1000) unit = u else break end
    end
    return tostring(bytes)..unit
end
local function getFilesView(path)
    local str, list, sizes, wNames, wSizes = "", fs.list(path), {}, 0, 0
    for _, name in ipairs(list) do if #name > wNames then wNames = #name end end
    for i, name in ipairs(list) do
        local size
        if fs.isDir(path.."/"..name) then size = "<D>"
        else size = strBytes(fs.getSize(path.."/"..name)) end
        sizes[i] = size
        if #size > wSizes then wSizes = #size end
    end
    for i, name in ipairs(list) do
        if fs.isDir(path.."/"..name) then str = str.."%dir%"..name..(" "):times(wNames-#name).."  "..sizes[i].."%std%\n"
        else str = str..name..(" "):times(wNames-#name).."  %light%"..sizes[i].."%std%\n" end
        if #name > wNames then wNames = #name end
    end
    return str, list, sizes
end
local fileButtons = {
    "new", "open", "delete", "rename", "run",
    ["new"] = {
        "file", "dir",
        ["file"] = function(path)
            local _, H = term.getSize()
            local fn = prompt("file name", 16) if not fn then return end
            local ext = ""
            local split = fn:split(".") if #split > 1 then ext = split[#split] end
            local file = fs.open(path..fn, "w") file:write("") file:close()
        end,
        ["dir"] = function(path)
            local _, H = term.getSize()
            local dn = prompt("file name", 16) if not dn then return end
            return fs.makeDir(path..dn)
        end,
    },
    ["open"] = {
        "view", "edit", "paint",
        ["view"] = function(path, file)
            if not file then return end
            local tab = multishell.launch({shell=shell,multishell=multishell,textutils=textutils,require=require}, ".spyglass/programs/view.lua", path..file)
            multishell.setTitle(tab, "[" .. file .. "]")
            multishell.setFocus(tab)
        end,
        ["edit"] = function(path, file)
            if not file then return end
            local editTab = multishell.launch({shell=shell,multishell=multishell,textutils=textutils,require=require},".spyglass/programs/edit.lua", path..file)
            multishell.setTitle(editTab,"["..file.."]")
            multishell.setFocus(editTab)
        end,
        ["paint"] = function(path, file)
            if not file then return end
            local editTab = multishell.launch({shell=shell,multishell=multishell,textutils=textutils,require=require},".spyglass/programs/paint.lua", path..file)
            multishell.setTitle(editTab,"["..file.."]")
            multishell.setFocus(editTab)
        end,
    },
    ["delete"] = function(path, file)
        if not file then return end
        if confirm("do you wanna delete "..path..file.."?") then return fs.delete(path..file) end
    end,
    ["run"] = function(path, file)
        if not file then return end
        local runTab = multishell.launch({shell=shell,multishell=multishell,textutils=textutils,require=require}, path..file)
        multishell.setTitle(runTab,"["..path..file.."]")
        multishell.setFocus(runTab)
    end,
    ["rename"] = function(path, file)
        local name = prompt("rename "..file.." to", 16, file)
        shell.run("rename "..path..file.." "..path..name)
        multishell.setTitle(multishell.getCurrent(), "[files]")
    end
}
local function main(path)
    multishell.setTitle(1, "#")
    local str, list = getFilesView(path)
    local scroll, selected = 1
    local buttonMenu, buttonPoses = fileButtons, {}
    while true do
        local W, H = term.getSize()
        term.setTextColor(colors.std) term.setBackgroundColor(colors.bg)
        term.clear() term.setCursorPos(1, 1)
        term.setTextColor(colors.bg) term.setBackgroundColor(colors.red) write("< ")
        term.setTextColor(colors.std) term.setBackgroundColor(colors.bg)
        printColor(" %info%/"..strings.ensure_width(path, W-2).."%std%")
        local lines = str:split("\n")
        local sub = table.sub(lines, scroll, scroll+H-4)
        for i, v in ipairs(sub) do
            if scroll + i - 1 == selected then term.setBackgroundColor(colors.light) end
            printColor(strings.ensure_width(v, W))
            term.setBackgroundColor(colors.bg)
        end
        term.setCursorPos(1, H-1) term.setBackgroundColor(colors.bg)
        term.clearLine()
        printColor("%light%"..("-"):times(W).."%std%", W)
        term.clearLine()
        for _, label in ipairs(buttonMenu) do
            local start = term.getCursorPos()
            writeColor("%light%[%std%"..label.."%light%]%std%")
            local stop = term.getCursorPos()
            buttonPoses[label] = { start = start, stop = stop }
        end
        while true do
            local event, p1, p2, p3 = os.pullEvent()
            if event == "mouse_click" and p1 == 1 then
                if p3 == H then
                    for label, pos in pairs(buttonPoses) do
                        if p2 >= pos.start and p2 <= pos.stop then
                            if type(buttonMenu[label]) == "table" then
                                buttonMenu = buttonMenu[label] break
                            elseif type(buttonMenu[label]) == "function" then
                                term.setCursorPos(1, H)
                                term.clearLine()
                                buttonMenu[label](path, list[selected])
                                str, list = getFilesView(path)
                                buttonMenu = fileButtons
                                selected = nil
                                break
                            end
                        end
                    end
                    break
                elseif p3 > 1 then
                    if scroll+p3-2 == selected then
                        if list[selected] then
                            if fs.isDir(path.."/"..list[selected]) then
                                main(path..list[selected].."/") break
                            end
                        end
                    else selected = scroll+p3-2 break end
                elseif p3 == 1 and (p2 >= 1 and p2 <= 2) and path ~= "" then
                    return
                end
                selected = nil
            end
            if event == "mouse_scroll" then
                if p3 > 1 then
                    scroll = scroll + p1
                    if scroll < 1 then scroll = 1 elseif scroll > #lines-H+4 then scroll = #lines-H+4 else break end
                end
            end
        end
    end
end

local args = {...} if #args == 1 then main(args[1]) else main("") end