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

local function main(value)
    local scroll, selected = 1
    local str, content = "", {}
    if type(value) == "table" then
        if getmetatable(value) then value = getmetatable(value) end
        local len = 0
        for k, _ in pairs(value) do if #k > len then len = #k end end
        str = "{\n" for k, v in pairs(value) do
            str = str.."\t"..tostring(k)..(" "):times(len-#k).." %gray%=%white% "..tocolored(v).."\n"
            table.insert(content, v)
        end str = str.."}"
    elseif type(value) == "function" then
        if getmetatable(value) then value = getmetatable(value) end
        local len = 0
        for k, _ in pairs(debug.getinfo(value)) do if #k > len then len = #k end end
        str = "{\n" for k, v in pairs(debug.getinfo(value)) do
            str = str.."\t"..tostring(k)..(" "):times(len-#k).." %gray%=%white% "..tocolored(v).."\n"
            table.insert(content, v)
        end str = str.."}"
    else str = tocolored(value) end
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
        -- input
        while true do
            local event, p1, p2, p3 = os.pullEvent()
            -- scrolling
            if event == "mouse_scroll" and (p3 ~= 1 and p3 ~= H) then
                scroll = scroll + p1
                if scroll < 1 then scroll = 1 elseif scroll > #lines-H+3 then scroll = #lines-H+3 else break end
            end
            -- clicking
            if event == "mouse_click" then
                if p3 == 1 then if p2 >= 1 and p2 <= 2 then return end -- back button
                else
                    if content[scroll+p3-3] ~= nil and p3 ~= H then -- if selected anything
                        if selected == scroll+p3-3 and content[selected] ~= value then
                            if type(content[selected]) == "table" or type(content[scroll+p3-3]) == "function" then -- if table or function
                                if content[selected] ~= value then -- if not self select
                                    main(content[selected]) break -- enter
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

return { tocolored = tocolored, printColor = printColor, writeColor = writeColor, main = main }