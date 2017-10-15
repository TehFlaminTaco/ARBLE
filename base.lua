local _basechars = list()
for b=1, 61 do
    _basechars[b] = list()
    for i=0, math.min(9, b-1) do
        _basechars[b][i] = ""..i
    end
    for i=10, math.min(35,b-1) do
        _basechars[b][i] = string.char(i + 55)
    end
    for i=36, math.min(62,b-1) do
        _basechars[b][i] = string.char(i + 61)
    end
end

_basechars[64] = (range(byte('B'),byte('Z'))..range(byte('a'),byte('z'))..range(byte('0'),byte('9'))..list(43, 47)).map(char(a))
_basechars[64][0] = 'A'
_basechars[256] = range(0,255).map(char(a))
_basechars[256][0] = table.remove(_basechars[256],1)
_basechars[254] = range(0,255).map(char(a)).where(nt(eq(a,'"'))&nt(eq(a,'\\')))
_basechars[254][0] = table.remove(_basechars[254],1)
_basechars[92] = range(byte(' '),byte('~')).map(char(a))
_basechars[92][0] = table.remove(_basechars[92],1)
_basechars[90] = range(byte(' '),byte('~')).map(char(a)).where(nt(eq(a,'"'))&nt(eq(a,'\\')))
_basechars[90][0] = table.remove(_basechars[90],1)
base = {}

local _base = {}
base = setmetatable(base, {__call = function(_,b, n, chrs)
    local t = setmetatable({base = b, base_str = chrs or _basechars[b]},_base)
    n = n or 0
    while n > 0 do
        table.insert(t, n % b)
        n = n // b
    end
    return t
end})

_base.__index = base

function _base.__tostring(ent)
    local s = ""
    if(not ent.base_str)then
        return error("Base "..tostring(ent.base).." has no default string! Please supply one!")
    end
    local str = ent.base_str
    if(type(str)=="string")then
        str = explode(str,".")
        str[0] = table.remove(str,1)
    end
    for i=1, #ent do
        s = str[ent[i]] .. s
    end
    return #s==0 and str[0] or s
end

function base.fromstring(val, b, base_str)
    local str = base_str or _basechars[b]
    if(type(str)=="string")then
        str = explode(str,".")
        str[0] = table.remove(str,1)
    end
    local b2 = base(b,0,base_str)
    for s in val:gmatch"." do
        for i=0, b do
            if(str[i] == s)then
                table.insert(b2, 1, i)
                break
            end
        end
    end
    
    return b2
end

function base.to_i(val)
    local n = 0
    for i=1, #val do
        n = n + (val[i]*val.base^(i-1))
    end
    return n
end

function base.translate(val, a, b, base_str_a, base_str_b)
    return base.to_b(base.to_b(val, a, base_str_a), b, base_str_b)
end

function base.to_b(val, b, base_str)
    base_str = base_str or _basechars[b]
    if(type(val) == "number")then
        return base(b, val, base_str)
    elseif(type(val) == "string")then
        return base.fromstring(val, b, base_str)
    elseif(val.base ~= val)then
        return base(b, val:to_i(), base_str)
    else
        return val
    end
end

function base.max_b(a,b)
    if(type(a)~="table" and type(b)~="table")then
        return 10
    end
    if(type(a)=='string' or type(a)=='number')then
        return b.base, b.base_str
    end
    if(type(b)=='string' or type(b)=='number')then
        return a.base, a.base_str
    end
    if(a.base >= b.base)then
        return a.base, a.base_str
    else
        return b.base, b.base_str
    end
end

local make_math = function(func)
    return function(a,b)
        local max_b,str = base.max_b(a,b)
        local b1 = base.to_b(a, max_b)
        local b2 = base.to_b(b, max_b)
        local o = base(max_b,0,str)
        local carry = 0
        for i=1, math.max(#b1, #b2) do
            local v1 = b1[i] or 0
            local v2 = b2[i] or 0
            o[i],carry = func(v1,v2,max_b,carry)
        end
        o[#o+1] = carry
        return o
    end
end

_base.__add = make_math(function(a,b,B,c)return (a + b + c) % B, (a + b + c) // B end)
_base.__mul = make_math(function(a,b,B,c)return (a * b + c) % B, (a * b + c) // B end)