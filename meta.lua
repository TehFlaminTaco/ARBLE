local _func = {}
debug.setmetatable(function()end,_func)

local _string = getmetatable("")

_func.__len = function(t)return wrap(t,"func")end

_func.__add = function(a,b)
	return function(...)
		local out = {a(...)}
		for k,v in pairs{b(...)} do
			out[#out+1] = v
		end
		return table.unpack(out)
	end
end

_func.__concat = function(a, b)
	local ac = debug.getinfo(a).nparams
	if(ac == -1 or ac == nil)then
		return function(...)
			local out = {a(...)}
			for k,v in pairs{b(...)} do
				out[#out+1] = v
			end
			return table.unpack(out)
		end
	else
		return function(...)
			local a_args = {}
			local b_args = {}
			local inp = {...}
			for i=1, math.min(#inp, ac) do
				a_args[#a_args+1] = inp[i]
			end
			for i=math.min(#inp, ac)+1, #inp do
				b_args[#b_args+1] = inp[i]
			end
			local out = {a(table.unpack(a_args))}
			for k,v in pairs{b(table.unpack(b_args))} do
				out[#out+1] = v
			end
			return table.unpack(out)
		end
	end
end

function _func.__pow(a,b)
	if(type(a)~="function")then
		a,b = b,a
	end
	if(isEq(b))then
		return getmetatable(b).__pow(a,b)
	end
	return function(...)
		local ret = {...}
		print(b)
		for i=1, b do
			ret = {a(table.unpack(ret))}
		end
		return table.unpack(ret)
	end
end

function _func.__band(f,a)
	if(type(f)=="function")then
		if(isEq(a))then
			return setmetatable({args = {f, a}, pre = 5, action = "call", format = function(...) return table.concat({...},"&") end, tex =  "%s\\left({%s}\\right)", func = function(f,a)return f&a end},_eq)
		else
			return f(a)
		end
	end
end

function _func.__bor(f,a)
	if(isEq(a))then
		return setmetatable({args = {f, a}, pre = 5, action = "call", format = function(...) return table.concat({...},"&") end, tex =  "%s\\left({%s}\\right)", func = function(f,a)return f&a end},_eq)
	else
		return function(...)return f(a,...) end
	end
end

_string.__mod = string.format
_string.__bor = function(s,l) return string.explode(s,l) end
_string.__unm = function(s) return string.reverse(s) end