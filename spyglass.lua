local tools = require("tools")

multishell.launch({},"spyglass/tools.lua", "table")
multishell.setTitle(2,"tables")
multishell.launch({},"spyglass/tools.lua", "files")
multishell.setTitle(3,"files")
term.setTextColor(colors.white) term.setBackgroundColor(colors.black)
term.clear() term.setCursorPos(1, 1)
--tools.printColor(tools.view(LOG))