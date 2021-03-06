local Expect = require "cc.expect"
local expect, field = Expect.expect, Expect.field
string.split = function(s, sep)
    local t, temp = {}, ""
    for i = 1, #s do
        if s:sub(i,i) == sep then table.insert(t, temp) temp = ""
        else temp = temp..s:sub(i,i) end
    end
    table.insert(t, temp)
    return t
end
string.times = function(s, n)
    local str = ""
    for i = 1, n do str = str .. s end
    return str
end
table.entries = function(t)
    local count = 0
    for _, _ in pairs(t) do count = count + 1 end
    return count
end
table.sub = function(t, i, j)
    if not j then j = #t end
    local st = {}
    for idx, v in ipairs(t) do
        if idx >= i and idx <= j then
            table.insert(st, v)
        end
    end
    return st
end
table.find = function(t, f)
    for k, v in pairs(t) do
        local match = f(k, v)
        if match then return match end
    end
    return false
end
table.tostring = function(t, prefix, subprefix)
    if not prefix then prefix = "" end if not subprefix then subprefix = "   " end
    local str = "{\n"
    for k, v in pairs(t) do
        str = str..prefix..subprefix
        if type(k) ~= "number" then str = str..tostring(k).." = " end
        if type(v) == "table" then
            if type(v.repr) == "function" then str = str..v:repr(prefix..subprefix,subprefix) else str = str..table.tostring(v) end
        else str = str..tostring(v)..",\n" end
    end
    return str..prefix.."}"
end
string.join = function(s, t)
    local str = ""
    for _, v in pairs(t) do
        str = str .. tostring(v) .. s
    end
    return str:sub(1, #str-#s)
end
table.contains = function(t, val) return table.find(t, (function(_, v) return v == val end)) end
table.containsStart = function(t, val) return table.find(t, (function(_, v) return v:sub(1,#val) == val end)) end
table.containsKey = function(t, key) return table.find(t, (function(k, _) return k == key end)) end
table.entries = function(t)
    local count = 0
    for _, __ in pairs(t) do count = count + 1 end
    return count
end
table.keyOfValue = function(t, val)
    for k, v in pairs(t) do
        if v == val then return k end
    end
end
string.letters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
                   "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N",
                   "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "_" }
string.digits = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
local function printColor(...)
    for j, w in ipairs({...}) do
        if j > 1 then write("\t") end
        local text = tostring(w)
        local prod, temp, i = {}, "", 1
        while text:sub(i,i) ~= "" do
            if text:sub(i,i) == "%" then
                table.insert(prod, temp) temp = "" i=i+1
                while text:sub(i,i) ~= "" and text:sub(i,i) ~= "%" do
                    temp = temp .. text:sub(i,i)
                    i=i+1
                end
                i=i+1
                if colors[temp] then table.insert(prod, colors[temp]) else table.insert(prod, colors.white) end
                temp = ""
            else
                temp = temp .. text:sub(i,i)
                i=i+1
            end
        end
        table.insert(prod, temp)
        for _, v in ipairs(prod) do
            if type(v) == "number" then term.setTextColor(v)
            else write(v) end
        end
    end
    print()
end
local function writeColor(...)
    for j, w in ipairs({...}) do
        if j > 1 then write("\t") end
        local text = tostring(w)
        local prod, temp, i = {}, "", 1
        while text:sub(i,i) ~= "" do
            if text:sub(i,i) == "%" then
                table.insert(prod, temp) temp = "" i=i+1
                while text:sub(i,i) ~= "" and text:sub(i,i) ~= "%" do
                    temp = temp .. text:sub(i,i)
                    i=i+1
                end
                i=i+1
                if colors[temp] then table.insert(prod, colors[temp]) else table.insert(prod, colors.white) end
                temp = ""
            else
                temp = temp .. text:sub(i,i)
                i=i+1
            end
        end
        table.insert(prod, temp)
        for _, v in ipairs(prod) do
            if type(v) == "number" then term.setTextColor(v)
            else write(v) end
        end
    end
end

local symbols = {
    ["end"] = ".",
    ["call"] = "!",
    ["sep"] = ",",
    ["assign"] = "=",
    ["bodyIn"] = "{",
    ["bodyOut"] = "}",
    ["if"] = "?", ["else"] = "~?", ["elseif"] = "*?",
    ["while"] = ":?", ["for"] = ":",
    ["add"] = "+",
    ["sub"] = "-",
    ["mul"] = "*",
    ["div"] = "/",
    ["eq"] = "==",
    ["ne"] = "~=",
    ["lt"] = "<",
    ["gt"] = ">",
    ["le"] = "<=",
    ["ge"] = ">=",
    ["and"] = "&",
    ["or"] = "|",
    ["not"] = "~",
    ["concat"] = "..",
    ["len"] = "#",
    ["evalIn"] = "(",
    ["evalOut"] = ")",
}

local function Position(idx, ln, col, fn, text)
    --expect(1, idx, "number") expect(2, ln, "number") expect(3, col, "number")
    --expect(4, fn, "string") expect(5, text, "string")
    return setmetatable(
            {
                idx = idx, ln = ln, col = col, fn = fn, text = text,
                copy = function(s) return Position(s.idx, s.ln, s.col, s.fn, s.text) end,
                line = function(s) return s.text:split("\n")[s.ln] end,
                sub = function(s) return s.text:sub(s.idx, s.idx) end,
            },
            { __name = "Position" }
    )
end
local function PositionRange(start, stop)
    expect(1, start, "table") expect(2, stop, "table")
    return setmetatable(
            {
                start = start, stop = stop, fn = start.fn, text = start.text,
                copy = function(s) return PositionRange(s.start:copy(), s.stop:copy()) end,
                lines = function(s) return ("\n"):join(table.sub(s.text:split("\n"), s.start.ln, s.stop.ln)) end,
                sub = function(s) return s.text:sub(s.start.idx, s.stop.idx) end,
            },
            { __name = "PositionRange" }
    )
end
local function mark(pr)
    local lines = table.sub(pr.text:split("\n"), pr.start.ln, pr.stop.ln)
    local str = ""
    if #lines > 1 then
        return pr:lines()
    end
    for i = 1, #lines[1] do
        if i == pr.start.col then str = str.."%red%" end
        if i == pr.stop.col+1 then str = str.."%white%" end
        str = str..lines[1]:sub(i,i)
    end
    return str
end
local function Error(type_, detail, pr)
    expect(1, type_, "string") expect(2, detail, "string") expect(3, pr, "table")
    return setmetatable(
            {
                type = type_, detail = detail, pr = pr:copy(), fn = pr.fn, text = pr.text,
                copy = function(s) return Error(s.type, s.detail, s.pr:copy()) end,
            },
            { __name = "Error", __tostring = function(s)
                return "%red%in "..s.fn.."\n"
                ..s.type..": "..s.detail.."\n%white%\n"
                ..mark(s.pr)
            end }
    )
end

local function Token(type_, value, pr)
    expect(1, type_, "string") expect(3, pr, "table")
    return setmetatable(
            {
                type = type_, value = value, pr = pr:copy(),
                copy = function(s) return Token(s.type, s.value, s.pr:copy()) end
            },
            { __name = "Token", __tostring = function(s)
                if s.value then return "["..s.type..":%green%"..s.value.."%white%]"
                else return "["..s.type.."]" end
            end }
    )
end

local function lex(fn, text)
    expect(1, fn, "string")
    expect(2, text, "string")
    local tokens, pos, char = {}, Position(0, 1, 0, fn, text)
    local function update() char = pos:sub() end
    local function advance()
        pos.idx = pos.idx + 1
        pos.col = pos.col + 1
        update()
        if pos:sub() == "\n" then
            pos.ln = pos.ln + 1
            pos.col = 0
        end
    end
    advance()
    local function main()
        if char == " " or char == "\t" then advance() return end
        if char == "\n" then table.insert(tokens, Token("nl",nil,PositionRange(pos:copy(), pos:copy()))) advance() return end
        if table.contains(string.letters, char) then
            local start, stop = pos:copy(), pos:copy()
            local id = char
            advance()
            while (table.contains(string.letters, char) or table.contains(string.digits, char)) and char ~= "" do
                id = id .. char
                stop = pos:copy()
                advance()
            end
            if id == "true" or id == "false" then
                table.insert(tokens, Token("bool",id=="true",PositionRange(start, stop))) return
            end
            if id == "nil" then
                table.insert(tokens, Token("nil",nil,PositionRange(start, stop))) return
            end
            table.insert(tokens, Token("id",id,PositionRange(start, stop))) return
        end
        if table.contains(string.digits, char) then
            local start, stop = pos:copy(), pos:copy()
            local number, dots = char, 0
            advance()
            while (table.contains(string.digits, char) or char == ".") and char ~= "" do
                if char == "." then dots = dots + 1 if dots == 2 then break end end
                number = number .. char
                stop = pos:copy()
                advance()
            end
            table.insert(tokens, Token("number",tonumber(number),PositionRange(start, stop))) return
        end
        if char == '"' then
            local start, stop = pos:copy(), pos:copy()
            local str = ""
            advance()
            while char ~= '"' and char ~= "" do
                str = str .. char
                stop = pos:copy()
                advance()
            end
            if char == '"' then stop = pos:copy() end
            advance()
            table.insert(tokens, Token("string",str,PositionRange(start, stop))) return
        end
        if table.containsStart(symbols, char) then
            local start, stop = pos:copy(), pos:copy()
            local symbol = char
            advance()
            while table.containsStart(symbols, symbol..char) and char ~= "" do
                symbol = symbol..char
                stop = pos:copy()
                advance()
            end
            if not table.contains(symbols, symbol) then return Error("syntax error", "unrecognized symbol") end
            table.insert(tokens, Token(table.keyOfValue(symbols, symbol),nil,PositionRange(start, stop))) return
        end
        return Error("syntax error", "character not recognized", PositionRange(pos:copy(), pos:copy()))
    end
    while char ~= "" do local err = main() if err then return nil, err end end
    return tokens
end

local function Node(type_, index, pr)
    expect(1, type_, "string") expect(2, index, "table") expect(3, pr, "table")
    return setmetatable(
            {
                index = index, type = type_, pr = pr:copy(),
                repr = function(s, prefix, subprefix)
                    if not prefix then prefix = "" end if not subprefix then subprefix = "   " end
                    local str = s.type.."{\n"
                    for k, v in pairs(s.index) do
                        if type(v) == "table" then
                            if type(v.repr) == "function" then
                                str = str..prefix..subprefix..tostring(k)..": "..v:repr(prefix..subprefix,subprefix).."\n"
                            else str = str..prefix..subprefix..tostring(k)..": "..table.tostring(v,prefix..subprefix,subprefix).."\n" end
                        else str = str..prefix..subprefix..tostring(k)..": "..tostring(v).."\n" end
                    end
                    return str..prefix.."}"
                end,
                copy = function(s) return Node(s.type, s.index, s.pr:copy()) end
            },
            { __name = "Node", __index = function(s, k)
                if k == "type" or k == "pr" or k == "repr" or k == "copy" then return rawget(s, k) end
                return s.index[k]
            end }
    )
end

local function parse(tokens)
    expect(1, tokens, "table")
    local idx, tok = 0
    local function update()
        tok = tokens[idx]
        if tok == nil then
            tok = Token("<eof>",nil,PositionRange(tokens[#tokens].pr.stop:copy(),tokens[#tokens].pr.stop:copy()))
        end
    end
    local function advance() idx=idx+1 update() end
    advance()
    local function binOp(f1, ops, f2)
        local start, stop = tok.pr.start:copy(), tok.pr.stop:copy()
        if not f2 then f2 = f1 end
        local left, err = f1() if err then return left, err end
        while table.contains(ops, tok.type) do
            local op, right = tok.type
            advance()
            right, err = f2() if err then return right, err end
            stop = tok.pr.stop:copy()
            left = Node("binOp", {op=op,left=left,right=right}, PositionRange(start, stop))
        end
        return left
    end
    local function unOpLeft(f1, ops)
        local start, stop = tok.pr.start:copy(), tok.pr.stop:copy()
        if table.contains(ops, tok.type) then
            local op = tok.type
            advance()
            local node, err = f1() if err then return node, err end
            stop = tok.pr.stop:copy()
            return Node("unOp",{op=op,node=node},PositionRange(start, stop))
        end
        return f1()
    end
    local function unOpRight(f1, ops)
        local start, stop = tok.pr.start:copy(), tok.pr.stop:copy()
        local node, err = f1() if err then return node, err end
        if table.contains(ops, tok.type) then
            local op = tok.type
            stop = tok.pr.stop:copy()
            advance()
            return Node("unOp",{op=op,node=node},PositionRange(start, stop))
        end
        return node
    end
    local body, op, expr, logic, not_, comp, arith, term, len, factor, atom, number, bool, string, id, if_, while_, for_
    if_ = function()
        local start, stop = tok.pr.start:copy(), tok.pr.stop:copy()
        advance()
        local cases, bodies, case, body_, elsebody, err = {}, {}
        while tok.type ~= "<eof>" do
            case, err = expr() if err then return case, err end
            table.insert(cases, case)
            if tok.type == "bodyIn" then advance() body_, err = body({"bodyOut"}) if err then return body_, err end
            else body_, err = op() if err then return body_, err end end
            table.insert(bodies, body_)
            stop = body_.pr.stop:copy()
            if tok.type ~= "elseif" then break end
            advance()
        end
        if tok.type == "else" then
            advance()
            if tok.type == "bodyIn" then advance() body_, err = body({"bodyOut"}) if err then return body_, err end
            else body_, err = op() if err then return body_, err end end
            elsebody = body_
            stop = elsebody.pr.stop:copy()
        end
        return Node("if",{cases=cases,bodies=bodies,elsebody=elsebody},PositionRange(start, stop))
    end
    id = function() local tok_=tok:copy() advance() return Node("id",{path={tok_.value}},tok_.pr:copy()) end
    string = function() local tok_=tok:copy() advance() return Node("string",{value=tok_.value},tok_.pr:copy()) end
    bool = function() local tok_=tok:copy() advance() return Node("bool",{value=tok_.value},tok_.pr:copy()) end
    number = function() local tok_=tok:copy() advance() return Node("number",{value=tok_.value},tok_.pr:copy()) end
    atom = function()
        if tok.type == "number" then return number() end
        if tok.type == "bool" then return bool() end
        if tok.type == "string" then return string() end
        if tok.type == "nil" then return Node("nil",{},tok.pr:copy()) end
        if tok.type == "id" then return id() end
        if tok.type == "evalIn" then
            advance()
            local node, err = expr() if err then return node, err end
            if tok.type ~= "evalOut" then return node, Error("syntax error", "expected ')'", tok.pr:copy()) end
            advance()
            return node
        end
        if tok.type == "if" then return if_() end
        if tok.type == "while" then return while_() end
        if tok.type == "for" then return for_() end
        return tok:copy(), Error("syntax error","expected number/boolean/string/nil/id, got "..tok.type,tok.pr:copy())
    end
    factor = function() return unOpLeft(atom, {"sub"}) end
    len = function() return unOpLeft(atom, {"len"}) end
    term = function() return binOp(factor, {"mul","div"}) end
    arith = function() return binOp(term, {"add","sub"}) end
    comp = function() return binOp(arith, {"eq","ne","lt","gt","le","ge"}) end
    not_ = function() return unOpLeft(comp, {"not"}) end
    logic = function() return binOp(not_, {"and","or"}) end
    expr = function() return logic() end
    op = function()
        local start, stop = tok.pr.start:copy(), tok.pr.stop:copy()
        local left, err = expr() if err then return left, err end
        if tok.type == "assign" then
            if left.type ~= "id" then return left, Error("syntax error", "cannot assign "..left.type, left.pr:copy()) end
            advance()
            local right right, err = expr() if err then return right, err end
            stop = right.pr.stop:copy()
            left = Node("assign",{id=left,value=right},PositionRange(start, stop))
        elseif tok.type == "call" then
            if left.type ~= "id" then return left, Error("syntax error", "cannot assign "..left.type, left.pr:copy()) end
            advance()
            local args = {}
            while tok.type ~= "end" and tok.type ~= "<eof>" do
                local right right, err = expr() if err then return right, err end
                table.insert(args, right)
                stop = right.pr.stop:copy()
                if tok.type == "sep" then advance() end
            end
            left = Node("call",{id=left,args=args},PositionRange(start, stop))
        end
        if tok.type == "end" then advance() end
        return left
    end
    body = function(endTokens)
        if endTokens == nil then endTokens = { "<eof>" } end
        expect(1, endTokens, "table")
        local start, stop = tok.pr.start:copy(), tok.pr.stop:copy()
        local ops = {}
        while not table.contains(endTokens, tok.type) do
            while tok.type == "nl" do advance() end
            local node, err = op() if err then return node, err end
            table.insert(ops, node)
            while tok.type == "nl" do advance() end
            if tok.type == "<eof>" then break end
        end
        stop = tok.pr.stop:copy()
        advance()
        if #ops == 0 then return end
        if #ops == 1 then return ops[1]
        else return Node("body",ops, PositionRange(start, stop)) end
    end
    return body()
end

local function operate(ast)
    local visit, nodes
    local delete = {{}}
    nodes = {
        number = function(node) return node.value end,
        string = function(node) return node.value end,
        bool = function(node) return node.value end,
        ["nil"] = function() return end,
        id = function(node, context)
            local head = context
            local path = ""
            for _, id in ipairs(node.path) do
                if type(head) ~= "table" then return head, false, Error("id error", "cannot index "..type(head), node.pr.copy()) end
                path = path .. id .. "."
                head = head[id]
            end
            return head
        end,
        idHead = function(node, context)
            local head = context
            local path = ""
            for i, id in ipairs(node.path) do
                if i == #node.path then break end
                if type(head) ~= "table" then return head, false, Error("id error", "cannot index "..type(head), node.pr.copy()) end
                path = path .. id .. "."
                head = head[id]
            end
            return head
        end,
        binOp = function(node, context)
            local left, right, err
            left, _, err = visit(node.left, context) if err then return left, false, err end
            right, _, err = visit(node.right, context) if err then return right, false, err end
            if node.op == "add" then
                if type(left) ~= "number" then return left, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.left.pr:copy()) end
                if type(right) ~= "number" then return right, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.right.pr:copy()) end
                return left + right
            end
            if node.op == "sub" then
                if type(left) ~= "number" then return left, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.left.pr:copy()) end
                if type(right) ~= "number" then return right, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.right.pr:copy()) end
                return left - right
            end
            if node.op == "mul" then
                if type(left) ~= "number" then return left, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.left.pr:copy()) end
                if type(right) ~= "number" then return right, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.right.pr:copy()) end
                return left * right
            end
            if node.op == "div" then
                if type(left) ~= "number" then return left, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.left.pr:copy()) end
                if type(right) ~= "number" then return right, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.right.pr:copy()) end
                return left / right
            end
            if node.op == "eq" then return left == right end
            if node.op == "ne" then return left ~= right end
            if node.op == "lt" then
                if type(left) ~= "number" then return left, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.left.pr:copy()) end
                if type(right) ~= "number" then return right, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.right.pr:copy()) end
                return left < right
            end
            if node.op == "gt" then
                if type(left) ~= "number" then return left, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.left.pr:copy()) end
                if type(right) ~= "number" then return right, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.right.pr:copy()) end
                return left > right
            end
            if node.op == "le" then
                if type(left) ~= "number" then return left, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.left.pr:copy()) end
                if type(right) ~= "number" then return right, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.right.pr:copy()) end
                return left <= right
            end
            if node.op == "ge" then
                if type(left) ~= "number" then return left, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.left.pr:copy()) end
                if type(right) ~= "number" then return right, false, Error("value error","attempt do perform "..node.op.." with "..type(left).." and "..type(right),node.right.pr:copy()) end
                return left >= right
            end
            if node.op == "and" then return left and right end
            if node.op == "or" then return left or right end
            return node, false, Error("operation error", "cannot do "..tostring(node.op).." as an binary operation")
        end,
        unOp = function(node, context)
            local value, _, err = visit(node.node, context) if err then return value, false, err end
            if node.op == "sub" then
                if type(value) ~= "number" then return value, false, Error("value error","attempt do perform "..node.op.." with "..type(value),node.value.pr:copy()) end
                return -value
            end
            if node.op == "len" then
                if type(value) ~= "string" and type(value) ~= "table" then return value, false, Error("value error","attempt do perform "..node.op.." with "..type(value),node.value.pr:copy()) end
                return #value
            end
            if node.op == "not" then return not value end
            return node, false, Error("operation error", "cannot do "..tostring(node.op).." as an unary operation")
        end,
        assign = function(node, context)
            local head, value, err
            value, _, err = visit(node.value, context)
            head, _, err = nodes.idHead(node.id, context) if err then return nil, false, err end
            head[node.id.path[#node.id.path]] = value
            table.insert(delete[#delete], {head=head,index=node.id.path[#node.id.path]})
            return value
        end,
        call = function(node, context)
            local args, func, err = {}
            func, _, err = visit(node.id, context)
            for _, arg in pairs(node.args) do
                local value value, __, err = visit(arg, context) if err then return nil, false, err end
                table.insert(args, value)
            end
            func(table.unpack(args))
        end,
        body = function(node, context)
            table.insert(delete, {})
            for _, n in ipairs(node.index) do
                local value, returning, err = visit(n, context) if err then return nil, false, err end
                if returning then return value, returning end
            end
            for _, v in ipairs(delete[#delete]) do v.head[v.index] = nil end
            table.remove(delete)
        end,
        ["if"] = function(node, context)
            local value, err
            for i, case in ipairs(node.cases) do
                value, _, err = visit(case, context) if err then return value, false, err end
                if value then return visit(node.bodies[i], context) end
            end
            if node.elsebody then return visit(node.elsebody, context) end
        end,
    }
    visit = function(node, context)
        expect(1, node, "table") expect(2, context, "table")
        if nodes[node.type] then return nodes[node.type](node, context) end
        return nil, false, Error("not implemented", node.type, node.pr:copy())
    end
    return visit(ast, _G)
end

local function runfile(fn)
    expect(1, fn, "string")
    local file = fs.open(fn, "r")
    if not file then error("file not found: '"..fn.."' ", 2) end
    local text = file.readAll()
    local tokens, ast, returning, value, err
    tokens, err = lex(fn, text) if err then printColor(err) return nil, false, err end
    --for _, tok in ipairs(tokens) do writeColor(tostring(tok)) write(" ") end print("\n")
    ast, err = parse(tokens) if err then printColor(err) return nil, false, err end
    --if ast then print(ast:repr()) end print("\n")
    value, returning, err = operate(ast) if err then printColor(err) return end
    if value ~= nil then print(value) end
    return value
end

local args = {...}
if #args > 0 then
    if args[1] == "-rf" then
        if type(args[2]) == "string" then runfile(args[2]) end
    end
end