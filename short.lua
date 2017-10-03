local prepend = (arg[0]:match(".*[\\/]")or"")
local prependdot = prepend:gsub("[\\/]",".")

require(prependdot.."equa")
require(prependdot.."meta")
local file = table.remove(arg,1) or prepend.."default.lua"


local f = io.open(file, "r")
if not f then
	error("File '"..file.."' not found!")
end
local s = f:read("*ab")

local dat = {load("return("..s..")")}
if(not dat[1])then
	local dat2 = {load("return{"..s.."}")}
	if(dat2[1])then
		dat = dat2
	end
end

if(not dat[1])then
	local dat2 = {load(s)}
	if(dat2[1])then
		dat = dat2
	end
end

if(not dat[1])then
	error(dat[2])
end

local func = table.remove(dat,1)

local val = func()

if(type(val)=="function"or (getmetatable(val) and getmetatable(val).__call))then
	local o = val(table.unpack(arg))
	if o ~= nil then
		print(tostring(o))
	end
elseif type(val)=="table"then
	local s = ""
	local k = ""
	for _,v in ipairs(val) do
		s = s .. k .. tostring(v)
		k = "\n"
	end
	print(s)
elseif val~=nil then
	print(val)
end