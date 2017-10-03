local func = {}
debug.setmetatable(function()end,func)

func.__len = function(t)return wrap(t,"func")end

func.__add = function(a,b)
	return function(...)
		local out = {a(...)}
		for k,v in pairs{b(...)} do
			out[#out+1] = v
		end
		return table.unpack(out)
	end
end

func.__concat = function(a, b)
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