require("tools")
local strings = require("cc.strings")
local function main(path)
    multishell.setTitle(multishell.getCurrent(), "["..fs.getName(path).."]")
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

local args = {...} if #args == 1 then main(args[1]) end