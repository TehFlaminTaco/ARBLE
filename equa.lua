local _eq = {}

function _eq.__call(eq, data, ...)
	if (type(data)~="table" or isEq(data)) then
		return (#eq)(data, ...)
	end
	if(eq.inp)then
		return data[eq.inp] or eq
	end
	local o = {}
	for k,v in pairs(eq.args) do
		if(isEq(v))then
			for k2,v2 in pairs({v(data)}) do
				o[#o+1] = v2
			end
		else
			o[#o+1] = v
		end
	end
	local out = {eq.func(table.unpack(o))}
	if(out[1] and isEq(out[1]) and #({...})>=1)then
		return out[1](...)
	else
		return table.unpack(out)
	end
end

_eq.isEq = true

function isEq(ent)
	return type(ent)=="table" and ent.isEq
end

function get_args(eq, list)
	local list = list or {}
	if(not isEq(eq))then
		return list
	end
	if(eq.inp)then
		for k,v in pairs(list) do
			if v == eq.inp then
				return list
			end
		end
		table.insert(list, eq.inp)
		return list
	end
	if(eq.args)then
		for k,v in pairs(eq.args) do
			get_args(v, list)
		end
		return list
	end
	return list
end

function _eq.__len(eq)
	local args = get_args(eq)
	table.sort(args)
	return function(...)
		local arr = {}
		for k,v in ipairs{...} do
			if(args[k])then
				arr[args[k]] = v
			end
		end
		return eq(arr)
	end
end

local function brak(a)
	return setmetatable({args = {a}, pre = 0, action = "()", format = "(%s)", tex = "\\left({%s}\\right)", func = function(a) return a end}, _eq)
end

-- Order of Operations
-- 0: Brackets. Surpasses everything. Includes function calls.
-- 1: Indicies. a^b, and such.
-- 2: Unary
-- 3: Multiplication / Division / Modulus.
-- 4: Addition / Subtraction
-- 5: Concatenation.

local actions = {}
actions.__add = {func = function(a,b) return a+b end, name = "+", pre = 4, format = "%s+%s", tex = "{%s}+{%s}"}
actions.__sub = {func = function(a,b) return a-b end, name = "-", pre = 4, format = "%s-%s", tex = "{%s}-{%s}"}
actions.__unm = {func = function(a,b) return -a end, name = "-", pre = 2, format = "-%s", tex = "-%s"}
actions.__mul = {func = function(a,b) return a*b end, name = "*", pre = 3, format = function(l,r)return type(l)=="number" and l..r or l.."*"..r end, tex = "{%s} {%s}"}
actions.__div = {func = function(a,b) return a/b end, name = "/", pre = 3, format = "%s/%s", tex = "{%s}\\over{%s}"}
actions.__idiv = {func = function(a,b) return a//b end, name = "//", pre = 3, format = "%s//%s", tex = "\\left\\lfloor{{%s}\\over{%s}}\\right\\rfloor"}
actions.__mod = {func = function(a,b) return a%b end, name = "%", pre = 3, format = "%s%%%s", tex = "{%s}%%{%s}"}
actions.__pow = {func = function(a,b) return a^b end, name = "^", pre = 1, format = "%s^%s", tex = "%s^{%s}"}
actions.__concat = {func = function(a,b) return a..b end, name = "..", pre=5, format = "%s .. %s", tex = "%s .. %s"}
actions.__band = {func = function(a,b) return a&b end, name = "&", pre=5, format = "%s&%s", tex = "%s\\&%s"}
actions.__bor = {func = function(a,b) return a|b end, name = "|", pre=5, format = "%s|%s", tex = "%s|%s"}
actions.__bxor = {func = function(a,b) return a~b end, name = "~", pre=5, format = "%s~%s", tex = "%s~%s"}
actions.__bnot = {func = function(a) return ~a end, name = "~", pre=5, format = "~%s", tex = "~%s"}
actions.__bshl = {func = function(a,b) return a<<b end, name = "<<", pre=5, format = "%s<<%s", tex = "%s>>%s"}
actions.__bshr = {func = function(a,b) return a>>b end, name = ">>", pre=5, format = "%s<<%s", tex = "%s>>%s"}

for k,v in pairs(actions) do
	_eq[k] = function(...)
		local o = setmetatable({}, _eq)
		o.args = {...}
		for k,v2 in pairs(o.args) do
			if(isEq(v2) and v2.pre > v.pre) then
				o.args[k] = brak(v2)
			end
		end

		o.pre = v.pre
		o.format = v.format
		o.tex = v.tex
		o.action = v.name
		o.func = v.func
		return o
	end
end

function _eq.__tostring(a)
	if a.inp then
		return a.inp
	end
	local t = {}
	for k,v in pairs(a.args) do
		if(type(v)=="string")then
			t[k] = ("%q"):format(v)
		else
			t[k] = tostring(v)
			t[k] = tonumber(t[k]) or t[k]
		end
	end
	return type(a.format)=="function" and a.format(table.unpack(t)) or a.format:format(table.unpack(t))
end

for k,v in pairs(math) do
	if(type(v)=="function")then
		local n
		n = function(...)
			local args = {...}
			local old = true
			for k,v in pairs(args) do
				if(isEq(v))then
					old = false
					break
				end
			end
			if old then
				return v(...)
			else
				return setmetatable({args = args, pre = 0, action = k, format = function(...) return k.."("..table.concat({...},",")..")" end, tex = function(...) return "\\text{"..k .."}\\left({"..table.concat({...},",").."}\\right)" end, func = n},_eq)
			end
		end
		math[k] = n
	end
end

function call(...)
	local args = {...}
	local run = true
	for k,v in pairs(args) do
		if(isEq(v))then
			run = false
			break
		end
	end
	if run then
		return table.remove(args,1)(table.unpack(args))
	else
		return setmetatable({args = args, pre = 0, action = "call", format = function(...) return "call("..table.concat({...},",")..")" end, tex = function(...) return "\\text{call}\\left({"..table.concat({...},",").."}\\right)" end, func = call},_eq)
	end
end

function wrap(v, k)
	local n
	n = function(...)
		local args = {...}
		local old = true
		for k,v in pairs(args) do
			if(isEq(v))then
				old = false
				break
			end
		end
		if old then
			return v(...)
		else
			return setmetatable({args = {...}, pre = 0, action = k, format = function(...) return k.."("..table.concat({...},",")..")" end, tex = function(...) return "\\text{"..k .."}\\left({"..table.concat({...},",").."}\\right)" end, func = n},_eq)
		end
	end
	return n
end

function index(tab, i)
	if isEq(tab) or isEq(i) then		
		return setmetatable({args = {tab, i}, pre = 0, action = "index", format = "%s[%s]", tex = function(...) return "\\text{index}\\left({"..table.concat({...},",").."}\\right)" end, func = index},_eq)
	else
		return tab[i]
	end
end

function len(tab)
	if isEq(tab) then		
		return setmetatable({args = {tab}, pre = 0, action = "len", format = function(...) return "len("..table.concat({...},",")..")" end, tex = function(...) return "\\text{len}\\left({"..table.concat({...},",").."}\\right)" end, func = len},_eq)
	else
		return #tab
	end
end

function makeFunky(val)
	if(isEq(val))then
		return #val
	end
	if type(val) == "function" then
		return val
	end
	return function()return val end
end

function truthy(cond)
	if(type(cond) == 'number')then
		cond = cond ~= 0
	end
	return cond
end

function branch(cond,truthy,falsey,...)
	truthy = makeFunky(truthy)
	falsey = makeFunky(falsey)
	if(isEq(cond)) then
		return setmetatable({args = {cond,truthy,falsey,...}, pre=0, action="branch", format = function(...) return "branch("..table.concat({...},",")..")" end, tex = function(...) return "\\text{branch}\\left({"..table.concat({...},",").."}\\right)" end,func = branch},_eq)
	else
		if truthy(cond) then
			return truthy(...)
		else
			return falsey(...)
		end
	end
end

function floop(first,cond,whilst,body,...)
	for k,v in pairs{first,...} do
		if(isEq(v))then
			cond = makeFunky(cond)
			whilst = makeFunky(whilst)
			body = makeFunky(body)
			return setmetatable({args = {first,cond,whilst,body,...}, action = "floop", format = function(...)return "floop("..table.concat({...},',')..")"end, tex = function(...) return "\\text{floop}\\left({"..table.concat({...},",").."}\\right)" end, func = floop},_eq)
		end
	end

	local i = makeFunky(first)()
	local last
	while(truthy(cond(i,...)))do
		last = body(i,...)
		i = whilst(i,...)
	end
	return last
end

function wloop(cond, body, last, ...)
	for k,v in pairs{...} do
		if(isEq(v))then
			cond = makeFunky(cond)
			body = makeFunky(body)
			return setmetatable({args = {cond,body,...}, action = "wloop", format = function(...)return "wloop("..table.concat({...},',')..")"end, tex = function(...) return "\\text{wloop}\\left({"..table.concat({...},",").."}\\right)" end, func = wloop},_eq)
		end
	end
	while(truthy(cond(last,...)))do
		last = body(last,...)
	end
	return last
end

lt = wrap(function(a,b)return a<b and 1 or 0 end, "lt")
gt = wrap(function(a,b)return a>b and 1 or 0 end, "gt")
le = wrap(function(a,b)return a<=b and 1 or 0 end, "le")
ge = wrap(function(a,b)return a>=b and 1 or 0 end, "ge")
orr = wrap(function(a,b)return a or b end, "or")
andd = wrap(function(a,b)return a and b end, "and")

for k,v in pairs(string) do
	if(type(v)=="function")then
		local n
		n = function(...)
			local args = {...}
			local old = true
			for k,v in pairs(args) do
				if(isEq(v) and (v.args or v.inp))then
					old = false
					break
				end
			end
			if old then
				return v(...)
			else
				return setmetatable({args = {...}, pre = 0, action = k, format = function(...) return k.."("..table.concat({...},",")..")" end, tex = function(...) return "\\text{"..k .."}\\left({"..table.concat({...},",").."}\\right)" end, func = n},_eq)
			end
		end
		string[k] = n
	end
end

for k,v in pairs(io) do
	if(type(v)=="function")then
		local n
		n = function(...)
			local args = {...}
			local old = true
			for k,v in pairs(args) do
				if(isEq(v) and (v.args or v.inp))then
					old = false
					break
				end
			end
			if old then
				return v(...)
			else
				return setmetatable({args = {...}, pre = 0, action = k, format = function(...) return k.."("..table.concat({...},",")..")" end, tex = function(...) return "\\text{"..k .."}\\left({"..table.concat({...},",").."}\\right)" end, func = n},_eq)
			end
		end
		io[k] = n
	end
end

_eq.__index = _eq

function toTeX(a)
	if(type(a)=="string")then
		return "\\text{"..a.."}"
	end
	if((not isEq(a)))then
		return a
	end
	if a.inp then
		return a.inp
	end
	local t = {}
	for k,v in pairs(a.args) do
		t[k] = toTeX(v)
		t[k] = tonumber(t[k]) or t[k]
	end
	return type(a.tex)=="function" and a.tex(table.unpack(t)) or a.tex:format(table.unpack(t))
end

setmetatable(_G, {__index = function(a,k)
	return math[k] or string[k] or io[k] or setmetatable({inp = k, pre = 0}, _eq)
end})
