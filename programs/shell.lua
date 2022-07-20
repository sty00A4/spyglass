require("tools")

multishell.setTitle(multishell.getCurrent(), "[>_]")
term.clear()
term.setCursorPos(1,1)
local history = {}
while true do
    term.setTextColor(colors.gray) write(" > ") term.setTextColor(colors.white) local input = read(nil, history, shell.complete)
    table.insert(history, input)
    shell.run(input)
    multishell.setTitle(multishell.getCurrent(), "[>_]")
end