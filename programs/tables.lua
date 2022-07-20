require("tools")
local strings = require("cc.strings")

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
            local number = prompt("number", 16) if not number then return end
            if number:match("^%-?%d+$") then t[k] = tonumber(number:match("^%-?%d+$")) return true end
            return false
        end,
        ["boolean"] = {
            "true", "false",
            ["true"] = function(t, k) t[k] = true return true end,
            ["false"] = function(t, k) t[k] = false return true end
        },
        ["string"] = function(t, k)
            local str = prompt("string", 16) if not str then return end
            t[k] = str return true
        end,
        ["nil"] = function(t, k) t[k] = nil return true end,
        ["cancel"] = function() return true end,
    },
}
local function main(value)
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
                                    main(value[content[selected]]) break -- enter
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

multishell.setTitle(multishell.getCurrent(), "[tables]")
main(_G)