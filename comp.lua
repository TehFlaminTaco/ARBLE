local _comp = {__type="complex"}

_comp.__add = function(ai,bi)
	local new = setmetatable({im = 1, re = 0},_comp)
	if(type(ai)~="complex" or type(bi)~="complex")then
		if(type(bi)=="complex")then
			ai,bi=bi,ai
		end
		new.im = ai.im
		new.re = ai.re + bi
		if(new.im == 0)then
			return new.re
		end
		return new
	end
	local a, b, c, d = ai.re, ai.im, bi.re, bi.im
	new.re = (a+c)
	new.im = (b+d)
	if(new.im == 0)then
		return new.re
	end
	return new
end

_comp.__sub = function(ai,bi)
	local new = setmetatable({im = 1, re = 0},_comp)
	if(type(ai)~="complex" or type(bi)~="complex")then
		if(type(bi)=="complex")then
			ai,bi=bi,ai
		end
		new.im = ai.im
		new.re = ai.re - bi
		if(new.im == 0)then
			return new.re
		end
		return new
	end
	local a, b, c, d = ai.re, ai.im, bi.re, bi.im
	new.re = (a-c)
	new.im = (b-d)
	if(new.im == 0)then
		return new.re
	end
	return new
end

_comp.__mul = function(ai,bi)
	local new = setmetatable({im = 1, re = 0},_comp)
	if(type(ai)~="complex" or type(bi)~="complex")then
		if(type(bi)=="complex")then
			ai,bi=bi,ai
		end
		new.im = ai.im * bi
		new.re = ai.re
		if(new.im == 0)then
			return new.re
		end
		return new
	end
	local a, b, c, d = ai.re, ai.im, bi.re, bi.im
	new.re = (a*c-b*d)
	new.im = (b*c+a*d)
	if(new.im == 0)then
		return new.re
	end
	return new
end

_comp.__div = function(ai,bi)
	local new = setmetatable({im = 1, re = 0},_comp)
	if(type(ai)~="complex" or type(bi)~="complex")then
		if(type(bi)=="complex")then
			ai,bi=bi,ai
		end
		new.im = ai.im / bi
		new.re = ai.re
		if(new.im == 0)then
			return new.re
		end
		return new
	end
	local a, b, c, d = ai.re, ai.im, bi.re, bi.im
	new.re = (a*c+b*d)/(c^2+d^2)
	new.im = (b*c-a*d)/(c^2+d^2)
	if(new.im == 0)then
		return new.re
	end
	return new
end

_comp.__idiv = function(ai,bi)
	local new = setmetatable({im = 1, re = 0},_comp)
	if(type(ai)~="complex" or type(bi)~="complex")then
		if(type(bi)=="complex")then
			ai,bi=bi,ai
		end
		new.im = ai.im // bi
		new.re = ai.re
		if(new.im == 0)then
			return new.re
		end
		return new
	end
	local a, b, c, d = ai.re, ai.im, bi.re, bi.im
	new.re = (a*c+b*d)//(c^2+d^2)
	new.im = (b*c-a*d)//(c^2+d^2)
	if(new.im == 0)then
		return math.floor(new.re)
	end
	return new
end

_comp.__tostring = function(a)
	local s = ""
	if(a.im==0)then
elseif(a.im~=1)then
		s = s .. a.im .."i"
	else
		s = s .. "i"
	end
	if(a.re~=0)then
		s = s .. ((a.re>0)and"+"or"-") .. math.abs(a.re)
	end
	return s
end

i = setmetatable({re = 0, im = 1}, _comp)

local ot = type
function type(...)
	local out = {}
	for k,v in pairs{...} do
		local t = ot(v)
		if(t=="table")then
			local mt = getmetatable(v)
			if(mt and mt.__type)then
				out[k] = mt.__type
			else
				out[k] = t
			end
		else
			out[k] = t
		end
	end
	return table.unpack(out)
end