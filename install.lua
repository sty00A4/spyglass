term.clear() term.setCursorPos(1, 1)
print("installing spyglass")
print("tools")
shell.run("wget https://raw.githubusercontent.com/sty00A4/spyglass/main/tools.lua .spyglass/tools.lua")
print("settings")
shell.run("wget https://raw.githubusercontent.com/sty00A4/spyglass/main/settings.lua .spyglass/settings.lua")
print("home")
shell.run("wget https://raw.githubusercontent.com/sty00A4/spyglass/main/home.lua .spyglass/home.lua")
print("installing spyglass programs")
print("edit")
shell.run("wget https://raw.githubusercontent.com/sty00A4/spyglass/main/programs/edit.lua .spyglass/programs/edit.lua")
print("paint")
shell.run("wget https://raw.githubusercontent.com/sty00A4/spyglass/main/programs/paint.lua .spyglass/programs/paint.lua")
print("files")
shell.run("wget https://raw.githubusercontent.com/sty00A4/spyglass/main/programs/files.lua .spyglass/programs/files.lua")
print("shell")
shell.run("wget https://raw.githubusercontent.com/sty00A4/spyglass/main/programs/shell.lua .spyglass/programs/shell.lua")
print("sys")
shell.run("wget https://raw.githubusercontent.com/sty00A4/spyglass/main/programs/sys.lua .spyglass/programs/sys.lua")
print("tables")
shell.run("wget https://raw.githubusercontent.com/sty00A4/spyglass/main/programs/tables.lua .spyglass/programs/tables.lua")
print("view")
shell.run("wget https://raw.githubusercontent.com/sty00A4/spyglass/main/programs/view.lua .spyglass/programs/view.lua")
print("startup")
local f = fs.open("startup.lua", "w") f.write('shell.run(".spyglass/home.lua")') f:close()
os.reboot()
