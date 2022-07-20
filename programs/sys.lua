require("tools")
--local strings = require("cc.strings")
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
local function main()
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

main()