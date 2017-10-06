#!/usr/bin/env lua
local prepend = (arg[0]:match(".*[\\/]")or"")
package.path = package.path .. ";" .. prepend .. "?.lua";
require("equa.equa")
require("meta")
require("list")
require("globals")

local file = table.remove(arg,1) or prepend.."default.lua"

for i=1, #arg do
	local v = arg[i]
	if type(v)=="string" then
		arg[i] = load('return '..v)()
	end
end

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

local val = func(...)

if(type(val)=="function"or (getmetatable(val) and getmetatable(val).__call))then
	if(isEq(val))then
		val = #val
	end
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