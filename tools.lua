if not term.isColor() then
    colors.lime = colors.white
    colors.cyan = colors.white
    colors.yellow = colors.white
    colors.red = colors.white
end
string.split = function(s, sep)
    local t, temp = {}, ""
    for i = 1, #s do
        if s:sub(i,i) == sep then table.insert(t, temp) temp = ""
        else temp = temp..s:sub(i,i) end
    end
    table.insert(t, temp)
    return t
end
string.times = function(s, n)
    local str = ""
    for i = 1, n do str = str .. s end
    return str
end
table.entries = function(t)
    local count = 0
    for _, _ in pairs(t) do count = count + 1 end
    return count
end
table.sub = function(t, i, j)
    if not j then j = #t end
    local st = {}
    for idx, v in ipairs(t) do
        if idx >= i and idx <= j then
            table.insert(st, v)
        end
    end
    return st
end

local function tocolored(value)
    if type(value) == "number" or type(value) == "boolean" or type(value) == "nil" then return "%cyan%"..tostring(value).."%white%" end
    if type(value) == "string" then return '%red%"'..tostring(value)..'"%white%' end
    if type(value) == "table" then
        if getmetatable(value) then if getmetatable(value).__tostring then return tostring(value) end end
        return '%yellow%table%white%:   %cyan%'..tostring(value):sub(#"table: ")..'%white%'
    end
    if type(value) == "function" then return '%yellow%function%white%:%cyan%'..tostring(value):sub(#"function: ")..'%white%' end
    if type(value) == "thread" then return '%yellow%thread%white%:%cyan%'..tostring(value):sub(#"thread: ")..'%white%' end
    if type(value) == "userdata" then return '%yellow%userdata%white%:%cyan%'..tostring(value):sub(#"userdata: ")..'%white%' end
    return tostring(value)
end
local function printColor(text)
    local prod, temp, i = {}, "", 1
    while text:sub(i,i) ~= "" do
        if text:sub(i,i) == "%" then
            table.insert(prod, temp) temp = "" i=i+1
            while text:sub(i,i) ~= "" and text:sub(i,i) ~= "%" do
                temp = temp .. text:sub(i,i)
                i=i+1
            end
            i=i+1
            if colors[temp] then table.insert(prod, colors[temp]) else table.insert(prod, colors.white) end
            temp = ""
        else
            temp = temp .. text:sub(i,i)
            i=i+1
        end
    end
    table.insert(prod, temp)
    for _, v in ipairs(prod) do
        if type(v) == "number" then term.setTextColor(v)
        else write(v) end
    end
    print()
end
local function writeColor(text)
    local prod, temp, i = {}, "", 1
    while text:sub(i,i) ~= "" do
        if text:sub(i,i) == "%" then
            table.insert(prod, temp) temp = "" i=i+1
            while text:sub(i,i) ~= "" and text:sub(i,i) ~= "%" do
                temp = temp .. text:sub(i,i)
                i=i+1
            end
            i=i+1
            if colors[temp] then table.insert(prod, colors[temp]) else table.insert(prod, colors.white) end
            temp = ""
        else
            temp = temp .. text:sub(i,i)
            i=i+1
        end
    end
    table.insert(prod, temp)
    for _, v in ipairs(prod) do
        if type(v) == "number" then term.setTextColor(v)
        else write(v) end
    end
end
LOG = {}
local function log(v) table.insert(LOG, v) end
-- tables
local function getTableView(value)
    if type(value) == "table" then
        if getmetatable(value) then value = getmetatable(value) end
        local len = 0
        for k, _ in pairs(value) do if #tostring(k) > len then len = #tostring(k) end end
        local str, content = "{\n", {}
        for k, v in pairs(value) do
            str = str.."\t"..tostring(k)..(" "):times(len-#tostring(k)).." %gray%=%white% "..tocolored(v).."\n"
            table.insert(content, k)
        end
        str = str.."}"
        return str, content
    end
    if type(value) == "function" then
        if getmetatable(value) then value = getmetatable(value) end
        local len = 0
        for k, _ in pairs(debug.getinfo(value)) do if #tostring(k) > len then len = #tostring(k) end end
        local str, content = "{\n", {}
        for k, v in pairs(debug.getinfo(value)) do
            str = str.."\t"..tostring(k)..(" "):times(len-#k).." %gray%=%white% "..tocolored(v).."\n"
            table.insert(content, k)
        end
        str = str.."}"
        return str, content
    end
    return tocolored(value)
end
local tableButtons = {
    "[set]",
    ["[set]"] = {
        "number", "boolean", "string", "nil", "cancel",
        ["number"] = function(t, k)
            local number = read()
            if number:match("^%-?%d+$") then t[k] = tonumber(number:match("^%-?%d+$")) return true end
            return false
        end,
        ["boolean"] = {
            "true", "false",
            ["true"] = function(t, k) t[k] = true return true end,
            ["false"] = function(t, k) t[k] = false return true end
        },
        ["string"] = function(t, k) t[k] = read() return false end,
        ["nil"] = function(t, k) t[k] = nil return false end,
        ["cancel"] = function() return true end,
    },
}
local function tableView(value)
    log(value)
    local scroll, selected = 1
    local buttonMenu = tableButtons
    local buttonPoses = {}
    local str, content = getTableView(value)
    while true do
        local W, H = term.getSize()
        term.setTextColor(colors.white) term.setBackgroundColor(colors.black)
        term.clear() term.setCursorPos(1, 1)
        term.setTextColor(colors.black) term.setBackgroundColor(colors.red) write("< ") term.setBackgroundColor(colors.black)
        printColor(" "..tocolored(value))
        -- show table
        local lines = str:split("\n")
        local sub = table.sub(lines, scroll, scroll+H-3)
        for i, v in ipairs(sub) do
            if scroll + i - 2 == selected then term.setBackgroundColor(colors.gray) end
            printColor(v)
            term.setBackgroundColor(colors.black)
        end
        -- buttons
        term.setCursorPos(1, H)
        term.setBackgroundColor(colors.gray)
        for _, label in ipairs(buttonMenu) do
            local start = term.getCursorPos()
            write(" "..label.." ")
            local stop = term.getCursorPos()
            buttonPoses[label] = { start = start, stop = stop }
        end
        term.setBackgroundColor(colors.black)
        -- input
        while true do
            local event, p1, p2, p3 = os.pullEvent()
            if term.getPosition then
                local xoff, yoff = term.getPosition()
                p2 = p2 - (xoff-1) p3 = p3 - (yoff-1)
            end
            -- scrolling
            if event == "mouse_scroll" and (p3 ~= 1 and p3 ~= H) then
                scroll = scroll + p1
                if scroll < 1 then scroll = 1 elseif scroll > #lines-H+3 then scroll = #lines-H+3 else break end
            end
            -- clicking
            if event == "mouse_click" and p1 == 1 then
                if p3 == 1 and (p2 >= 1 and p2 <= 2) and value ~= _G then return -- back button
                elseif p3 == H then
                    for label, pos in pairs(buttonPoses) do
                        if p2 >= pos.start and p2 <= pos.stop then
                            if type(buttonMenu[label]) == "table" then
                                buttonMenu = buttonMenu[label] break
                            elseif type(buttonMenu[label]) == "function" then
                                term.setCursorPos(1, H)
                                term.clearLine()
                                buttonMenu[label](value, content[selected])
                                str, content = getTableView(value)
                                buttonMenu = tableButtons
                                break
                            end
                        end
                    end
                    break
                else
                    if content[scroll+p3-3] ~= nil and p3 ~= H then -- if selected anything
                        if selected == scroll+p3-3 and value[content[selected]] ~= value then
                            if type(value[content[selected]]) == "table" or type(value[content[selected]]) == "function" then -- if table or function
                                if value[content[selected]] ~= value then -- if not self select
                                    tableView(value[content[selected]]) break -- enter
                                end
                            end
                        else
                            selected = scroll+p3-3 break -- select
                        end
                    end
                end
            end
        end
    end
end
-- files
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
        if fs.isDir(path.."/"..name) then str = str.."%green%"..name..(" "):times(wNames-#name).."  "..sizes[i].."%white%\n"
        else str = str..name..(" "):times(wNames-#name).."  %gray%"..sizes[i].."%white%\n" end
        if #name > wNames then wNames = #name end
    end
    return str, list, sizes
end
local function viewFile(path)
    --if not path then return end
    local file = fs.open(path, "r")
    --if not file then return end
    local ext
    if #path:split(".") > 1 then ext = #path:split(".")[#path:split(".")] end
    local text = file:readAll()
    local scroll, ctrl = 1, false
    while true do
        local W, H = term.getSize()
        term.setTextColor(colors.white) term.setBackgroundColor(colors.black)
        term.clear() term.setCursorPos(1, 1)
        term.setTextColor(colors.black) term.setBackgroundColor(colors.red)
        write(" X ")
        term.setTextColor(colors.white) term.setBackgroundColor(colors.black)
        printColor(" %magenta%"..path.."%white%")
        local lines = text:split("\n")
        local sub = table.sub(lines, scroll, scroll+H-3)
        for _, v in ipairs(sub) do
            print(v:sub(1,W))
            term.setBackgroundColor(colors.black)
        end
        while true do
            local event, p1, p2, p3 = os.pullEvent()
            if event == "mouse_scroll" then
                if ctrl then scroll = scroll + p1 * 10 else scroll = scroll + p1 end
                if scroll < 1 then scroll = 1 elseif scroll > #lines-H+3 then scroll = #lines-H+3 else break end
            end
            if event == "mouse_click" and p1 == 1 then
                if p3 == 1 and (p2 >= 1 and p2 <= 3) then
                    return
                end
            end
            if event == "key" then
                if p1 == keys.leftCtrl then ctrl = true end
            end
            if event == "key_up" then
                if p1 == keys.leftCtrl then ctrl = false end
            end
        end
    end
end
local fileButtons = {
    "[open]", "[edit]", "[delete]", "[run]",
    ["[open]"] = function(path, file)
        if not file then return end
        local tab = multishell.launch({shell=shell,multishell=multishell},".spyglass/tools.lua", "view", path..file)
        multishell.setTitle(tab,"["..file.."]")
        multishell.setFocus(tab)
    end,
    ["[edit]"] = function(path, file)
        if not file then return end
        local editTab = multishell.launch({shell=shell,multishell=multishell},".spyglass/tools.lua", "edit", path..file)
        multishell.setTitle(editTab,"["..path..file.."]")
        multishell.setFocus(editTab)
    end,
    ["[delete]"] = function(path, file)
        if not file then return end
        return fs.delete(path..file)
    end,
    ["[run]"] = function(path, file)
        if not file then return end
        local runTab = multishell.launch({shell=shell,multishell=multishell},".spyglass/tools.lua", "run", path..file)
        multishell.setTitle(runTab,"["..path..file.."]")
        multishell.setFocus(runTab)
    end,
}
local function fileView(path)
    multishell.setTitle(1, "#")
    local str, list = getFilesView(path)
    local scroll, selected = 1
    local buttonMenu, buttonPoses = fileButtons, {}
    while true do
        local W, H = term.getSize()
        term.setTextColor(colors.white) term.setBackgroundColor(colors.black)
        term.clear() term.setCursorPos(1, 1)
        term.setTextColor(colors.black) term.setBackgroundColor(colors.red) write("< ")
        term.setTextColor(colors.white) term.setBackgroundColor(colors.black)
        printColor(" %magenta%/"..path.."%white%")
        local lines = str:split("\n")
        local sub = table.sub(lines, scroll, scroll+H-3)
        for i, v in ipairs(sub) do
            if scroll + i - 1 == selected then term.setBackgroundColor(colors.gray) end
            printColor(v)
            term.setBackgroundColor(colors.black)
        end
        term.setCursorPos(1, H)
        term.setBackgroundColor(colors.gray)
        for _, label in ipairs(buttonMenu) do
            local start = term.getCursorPos()
            write(" "..label.." ")
            local stop = term.getCursorPos()
            buttonPoses[label] = { start = start, stop = stop }
        end
        term.setBackgroundColor(colors.black)
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
                                fileView(path..list[selected].."/") break
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
                    if scroll < 1 then scroll = 1 elseif scroll > #lines-H+3 then scroll = #lines-H+3 else break end
                end
            end
        end
    end
end

local args = {...}
if #args >= 1 then
    if args[1] == "table" then tableView(_G) end
    if args[1] == "files" then fileView("") end
    if not args[2] then return end
    if args[1] == "view" then viewFile(args[2]) end
    if args[1] == "edit" then shell.run("edit "..args[2]) end
    if args[1] == "run" then shell.run(args[2]) end
end

return { tocolored = tocolored, printColor = printColor, writeColor = writeColor, tableView = tableView,
         fileView = fileView, getTableView = getTableView, getFilesView = getFilesView, viewFile = viewFile }