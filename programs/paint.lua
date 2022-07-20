local args = {...}
if #args >= 1 then multishell.setTitle(multishell.getCurrent(), "["..fs.getName(args[1]).."]") shell.run("paint "..args[1]) end