-- shell os table files peripheral rednet redstone
local tableTab = multishell.launch({shell=shell,multishell=multishell},".spyglass/tools.lua", "table")
multishell.setTitle(tableTab,"[tables]")
local filesTab = multishell.launch({shell=shell,multishell=multishell},".spyglass/tools.lua", "files")
multishell.setTitle(filesTab,"[files]")
multishell.setTitle(1,"[#]")

term.clear()
term.setCursorPos(1,1)
local history = {}
while true do
    term.setTextColor(colors.gray) write(" > ") term.setTextColor(colors.white) local input = read(nil, history, shell.complete)
    table.insert(history, input)
    shell.run(input)
    multishell.setTitle(1,"[#]")
end
--tools.printColor(tools.view(LOG))
