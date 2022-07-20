if not term.isColor() then
    colors.lime = colors.white
    colors.cyan = colors.white
    colors.yellow = colors.white
    colors.red = colors.white
    colors.green = colors.white
    colors.magenta = colors.white
end
_G.pairsByKeys = function(t, f)
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

_G.tocolored = function(value)
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
_G.printColor = function(text)
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
_G.writeColor = function(text)
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
_G.LOG = {}
_G.log = function(...) table.insert(LOG, {...}) end
_G.message = function(msg)
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
    writeColor("[%confirm%OK%std%]"..(" "):times(w-#"[OK]"+2))
    while true do
        local event, p1, x, y = os.pullEvent()
        if event == "mouse_click" and p1 == 1 and y == math.floor(H/2+h/2) then
            if x >= math.floor(W/2-w/2) and x <= math.floor(W/2-w/2)+#"[OK" then return true end
        end
        if event == "key" and p1 == keys.enter then return true end
    end
end
_G.confirm = function(msg)
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
_G.prompt = function(msg, width, start)
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