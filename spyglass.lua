--shell.run(".spyglass/tools.lua os") os.exit()
-- shell os table files peripheral rednet redstone
local tableTab = multishell.launch(
        {shell=shell,multishell=multishell,textutils=textutils,require=require},
        ".spyglass/tools.lua", "table")
multishell.setTitle(tableTab,"[tables]")
local filesTab = multishell.launch(
        {shell=shell,multishell=multishell,textutils=textutils,require=require},
        ".spyglass/tools.lua", "files")
multishell.setTitle(filesTab,"[files]")
local osTab = multishell.launch(
        {shell=shell,multishell=multishell,os=os,textutils=textutils,require=require},
        ".spyglass/tools.lua", "sys")
multishell.setTitle(osTab,"[sys]")
multishell.setTitle(1,"[#]")
multishell.setFocus(osTab)

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
