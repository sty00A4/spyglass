local tools = require("tools")

-- shell os table files peripheral rednet redstone
local tableTab = multishell.launch({},"spyglass/tools.lua", "table")
multishell.setTitle(tableTab,"tables")
local filesTab = multishell.launch({},"spyglass/tools.lua", "files")
multishell.setTitle(filesTab,"files")
multishell.setTitle(1,"#")
multishell.setFocus(filesTab)
term.setTextColor(colors.white) term.setBackgroundColor(colors.black)
term.clear() term.setCursorPos(1, 1)
--tools.printColor(tools.view(LOG))
