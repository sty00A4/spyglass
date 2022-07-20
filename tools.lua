if not term.isColor() then
    colors.lime = colors.white
    colors.cyan = colors.white
    colors.yellow = colors.white
    colors.red = colors.white
    colors.green = colors.white
    colors.magenta = colors.white
end
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
settingsTable(spSetting)
local function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
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
    for _ = 1, n do str = str .. s end
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
local strings = require("cc.strings")

local function tocolored(value)
    if type(value) == "number" or type(value) == "boolean" or type(value) == "nil" then return "%cyan%"..tostring(value).."%std%" end
    if type(value) == "string" then return '%strings%"'..tostring(value)..'"%std%' end
    if type(value) == "table" then
        if getmetatable(value) then if getmetatable(value).__tostring then return tostring(value) end end
        return '%val%table%std%:   %number%'..tostring(value):sub(#"table: ")..'%std%'
    end
    if type(value) == "function" then return '%val%function%std%:%cyan%'..tostring(value):sub(#"function: ")..'%std%' end
    if type(value) == "thread" then return '%val%thread%std%:%cyan%'..tostring(value):sub(#"thread: ")..'%std%' end
    if type(value) == "userdata" then return '%val%userdata%std%:%cyan%'..tostring(value):sub(#"userdata: ")..'%std%' end
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
            if colors[temp] then table.insert(prod, colors[temp]) else table.insert(prod, colors.std) end
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
    if type(text) ~= "string" then error("expected string", 2) end
    local prod, temp, i = {}, "", 1
    while text:sub(i,i) ~= "" do
        if text:sub(i,i) == "%" then
            table.insert(prod, temp) temp = "" i=i+1
            while text:sub(i,i) ~= "" and text:sub(i,i) ~= "%" do
                temp = temp .. text:sub(i,i)
                i=i+1
            end
            i=i+1
            if colors[temp] then table.insert(prod, colors[temp]) else table.insert(prod, colors.std) end
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
local function confirm(msg)
    local W, H = term.getSize()
    term.setBackgroundColor(colors.light)
    local lines = strings.wrap(msg, W/2)
    local w, h = 0, #lines+2
    for _, line in ipairs(lines) do if #line > w then w = #line end end
    for i, line in pairs(lines) do
        term.setCursorPos(W/2-w/2, H/2-h/2+i)
        writeColor((" "):times((w-#line)/2+1)..line..(" "):times((w-#line)/2+1))
    end
    term.setCursorPos(math.floor(W/2-w/2), math.floor(H/2+h/2)-1)
    writeColor((" "):times(w+2))
    term.setCursorPos(math.floor(W/2-w/2), math.floor(H/2+h/2))
    writeColor("[%confirm%YES%std%][%cancel%NO%std%]"..(" "):times(w-#"[YES][NO]"+2))
    while true do
        local event, p1, x, y = os.pullEvent()
        if event == "mouse_click" and p1 == 1 and y == math.floor(H/2+h/2) then
            if x >= math.floor(W/2-w/2) and x <= math.floor(W/2-w/2)+#"[YES" then return true end
            if x >= math.floor(W/2-w/2)+#"[YES" and x <= math.floor(W/2-w/2)+#"[YES"+#"[NO]" then return false end
        end
        if event == "key" and p1 == keys.enter then return true end
    end
end
local function prompt(msg, width, start)
    local W, H = term.getSize()
    term.setBackgroundColor(colors.light)
    local lines = strings.wrap(msg, W/2)
    local w, h = width+2, #lines+4
    local input = start or ""
    for _, line in ipairs(lines) do if #line > w then w = #line end end
    for i, line in pairs(lines) do
        term.setCursorPos(W/2-w/2, H/2-h/2+i)
        writeColor((" "):times((w-#line)/2+1)..line..(" "):times((w-#line)/2+1))
    end
    --space
    term.setCursorPos(math.floor(W/2-w/2), math.floor(H/2+h/2)-3) writeColor((" "):times(w+2))
    -- input
    term.setCursorPos(math.floor(W/2-w/2), math.floor(H/2+h/2)-2) writeColor((" "):times(w+2))
    term.setBackgroundColor(colors.light)
    -- space
    term.setCursorPos(math.floor(W/2-w/2), math.floor(H/2+h/2)-1) writeColor((" "):times(w+2))
    -- enter
    term.setCursorPos(math.floor(W/2-w/2), math.floor(H/2+h/2))
    writeColor("[%confirm%OK%std%][%cancel%CANCEL%std%]"..(" "):times(w-#"[OK][CANCEL]"+2))
    while true do
        term.setCursorBlink(true)
        term.setCursorPos(math.floor(W/2-width/2), math.floor(H/2+h/2)-2)
        term.setBackgroundColor(colors.bg) term.setTextColor(colors.std)
        writeColor((" "):times(width+1))
        term.setCursorPos(math.floor(W/2-width/2), math.floor(H/2+h/2)-2)
        write(input)
        local event, p1, x, y = os.pullEvent()
        term.setCursorBlink(false)
        if event == "mouse_click" and p1 == 1 and y == math.floor(H/2+h/2) then
            if x >= math.floor(W/2-w/2) and x <= math.floor(W/2-w/2)+#"[OK" then return input end
            if x >= math.floor(W/2-w/2)+#"[OK" and x <= math.floor(W/2-w/2)+#"[OK"+#"[CANCEL]" then return false end
        end
        if event == "char" and #input <= width then input = input..p1 end
        if event == "key" then
            if p1 == keys.enter then return input end
            if p1 == keys.backspace then input = input:sub(1,#input-1) end
        end
    end
end
-- tables
local function getTableView(value)
    if type(value) == "table" then
        if getmetatable(value) then value = getmetatable(value) end
        local len = 0
        for k, _ in pairs(value) do if #tostring(k) > len then len = #tostring(k) end end
        local str, content = "{\n", {}
        for k, v in pairs(value) do
            str = str.."\t"..tostring(k)..(" "):times(len-#tostring(k)).." %light%=%std% "..tocolored(v).."\n"
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
            str = str.."\t"..tostring(k)..(" "):times(len-#k).." %light%=%std% "..tocolored(v).."\n"
            table.insert(content, k)
        end
        str = str.."}"
        return str, content
    end
    return tocolored(value)
end
local tableButtons = {
    "set",
    ["set"] = {
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
        term.setTextColor(colors.std) term.setBackgroundColor(colors.bg)
        term.clear() term.setCursorPos(1, 1)
        term.setTextColor(colors.bg) term.setBackgroundColor(colors.red) write("< ") term.setBackgroundColor(colors.bg)
        printColor((strings.ensure_width(" "..tocolored(value), W)))
        -- show table
        local lines = str:split("\n")
        local sub = table.sub(lines, scroll, scroll+H-4)
        for i, v in ipairs(sub) do
            if scroll + i - 2 == selected then term.setBackgroundColor(colors.light) end
            printColor(v)
            term.setBackgroundColor(colors.bg)
        end
        -- buttons
        term.setCursorPos(1, H-1) term.setBackgroundColor(colors.bg)
        term.clearLine()
        printColor("%light%"..("-"):times(W).."%std%")
        term.clearLine()
        for _, label in ipairs(buttonMenu) do
            local start = term.getCursorPos()
            writeColor("%light%[%std%"..label.."%light%]%std%")
            local stop = term.getCursorPos()
            buttonPoses[label] = { start = start, stop = stop }
        end
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
                if scroll < 1 then scroll = 1 elseif scroll > #lines-H+4 then scroll = #lines-H+4 else break end
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
        if fs.isDir(path.."/"..name) then str = str.."%dir%"..name..(" "):times(wNames-#name).."  "..sizes[i].."%std%\n"
        else str = str..name..(" "):times(wNames-#name).."  %light%"..sizes[i].."%std%\n" end
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
        term.setTextColor(colors.std) term.setBackgroundColor(colors.bg)
        term.clear() term.setCursorPos(1, 1)
        term.setTextColor(colors.bg) term.setBackgroundColor(colors.red)
        write(" X ")
        term.setTextColor(colors.std) term.setBackgroundColor(colors.bg)
        printColor(" %info%"..strings.ensure_width(path, W-1).."%std%")
        local lines = text:split("\n")
        local sub = table.sub(lines, scroll, scroll+H-3)
        for _, v in ipairs(sub) do
            print(v:sub(1,W))
            term.setBackgroundColor(colors.bg)
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
    "new", "open", "delete", "run",
    ["new"] = function(path)
        local _, H = term.getSize()
        term.setCursorPos(1, H) term.clearLine()
        writeColor("%light%file name: %std%")
        local fn = read()
        local ext = ""
        local split = fn:split(".") if #split > 1 then ext = split[#split] end
        local file = fs.open(path..fn, "w") file:write("") file:close()
    end,
    ["open"] = {
        "view", "edit", "paint",
        ["view"] = function(path, file)
            if not file then return end
            local tab = multishell.launch({shell=shell,multishell=multishell,textutils=textutils,require=require}, ".spyglass/tools.lua", "view", path .. file)
            multishell.setTitle(tab, "[" .. file .. "]")
            multishell.setFocus(tab)
        end,
        ["edit"] = function(path, file)
            if not file then return end
            local editTab = multishell.launch({shell=shell,multishell=multishell,textutils=textutils,require=require},".spyglass/tools.lua", "edit", path..file)
            multishell.setTitle(editTab,"["..path..file.."]")
            multishell.setFocus(editTab)
        end,
        ["paint"] = function(path, file)
            if not file then return end
            local editTab = multishell.launch({shell=shell,multishell=multishell,textutils=textutils,require=require},".spyglass/tools.lua", "paint", path..file)
            multishell.setTitle(editTab,"["..path..file.."]")
            multishell.setFocus(editTab)
        end,
    },
    ["delete"] = function(path, file)
        if not file then return end
        if confirm("do you wanna delete "..path..file.."?") then return fs.delete(path..file) end
    end,
    ["run"] = function(path, file)
        if not file then return end
        local runTab = multishell.launch({shell=shell,multishell=multishell,textutils=textutils,require=require},".spyglass/tools.lua", "run", path..file)
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
        printColor(strings.ensure_width("%light%"..("-"):times(W).."%std%", W))
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
                    if scroll < 1 then scroll = 1 elseif scroll > #lines-H+4 then scroll = #lines-H+4 else break end
                end
            end
        end
    end
end

local function getComputerType()
    local str = ""
    if term.isColor() then str = "advanced " end
    if commands then str = "command " end
    if turtle then str = str.."turtle"
    elseif pocket then str = str.."pocket computer"
    else str = str.."computer" end
    return str
end
local sysButtons = {
    "set", "change label", "shutdown", "reboot",
    ["change label"] = function() local name=prompt("computer label",18,os.computerLabel()) if name then os.setComputerLabel(name) end end,
    ["shutdown"] = function() if confirm("are you sure you wanna shutdown?") then os.shutdown() end end,
    ["reboot"] = function() if confirm("are you sure you wanna reboot?") then os.reboot() end end,
    ["set"] = {
        "number", "boolean", "string", "nil", "cancel",
        ["number"] = function(opt)
            local number = read()
            if number:match("^%-?%d+$") then settings.set(opt,tonumber(number:match("^%-?%d+$"))) return true end
            return false
        end,
        ["boolean"] = {
            "true", "false",
            ["true"] = function(opt) settings.set(opt,true) return true end,
            ["false"] = function(opt) settings.set(opt,false) return true end
        },
        ["string"] = function(opt) settings.set(opt,read()) return false end,
        ["nil"] = function(opt) settings.set(opt,nil) return false end,
        ["cancel"] = function() return true end,
    },
}
local function getSettings(W)
    local str, list, lengths, w = "", {}, {}, 0
    for _, name in pairsByKeys(settings.getNames()) do
        table.insert(list, name)
        if #name > w then w = #name end
    end
    for i, name in ipairs(list) do
        if #(name..(" "):times(w-#name).." = "..tostring(settings.get(name, nil)).."\n") > W then
            str = str.."%std%"..name..(" "):times(w-#name).."%light% = ...\n"
        else
            str = str.."%std%"..name..(" "):times(w-#name).."%light% = "..tocolored(settings.get(name, nil)).."\n"
        end
    end
    return str, list, lengths
end
local function sysView()
    multishell.setTitle(1, "#")
    local W, H = term.getSize()
    local str, list, lengths = getSettings(W)
    local scroll, selected = 1
    local buttonMenu, buttonPoses = sysButtons, {}
    while true do
        W, H = term.getSize()
        term.setTextColor(colors.std) term.setBackgroundColor(colors.bg)
        term.clear()
        term.setCursorPos(1, 1) writeColor("%info%"..
            tostring(os.version())..", "..
            tostring(getComputerType())..", #"..
            tostring(os.computerID())..", "..
            tostring(os.computerLabel() or ""))
        term.setCursorPos(1, 2) term.setTextColor(colors.std)
        local lines = str:split("\n")
        local sub = table.sub(lines, scroll, scroll+H-4)
        for i, v in ipairs(sub) do
            if scroll + i - 1 == selected then term.setBackgroundColor(colors.light) end
            writeColor(v)
            print()
            term.setBackgroundColor(colors.bg)
        end
        term.setCursorPos(1, H-1) term.setBackgroundColor(colors.bg)
        term.clearLine()
        printColor("%light%"..("-"):times(W).."%std%")
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
                                buttonMenu[label](list[selected])
                                str, list = getSettings(W)
                                buttonMenu = sysButtons
                                selected = nil
                                break
                            end
                        end
                    end
                    break
                elseif p3 > 1 then
                    if scroll+p3-2 ~= selected then selected = scroll+p3-2 break end
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

local args = {...}
if #args >= 1 then
    if args[1] == "table" then tableView(_G) end
    if args[1] == "files" then fileView("") end
    if args[1] == "sys" then sysView() end
    if not args[2] then return end
    if args[1] == "view" then viewFile(args[2]) end
    if args[1] == "edit" then shell.run("edit "..args[2]) end
    if args[1] == "paint" then shell.run("paint "..args[2]) end
    if args[1] == "run" then shell.run(args[2]) end
end

return { tocolored = tocolored, printColor = printColor, writeColor = writeColor, tableView = tableView,
         fileView = fileView, getTableView = getTableView, getFilesView = getFilesView, viewFile = viewFile }