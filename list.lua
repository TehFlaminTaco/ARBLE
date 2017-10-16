list = {}
local _list = {}
function _list.__index(l,key)
    if list[key] then
        return function(...)
            return list[key](l,...)
        end
    end
end

list = setmetatable(list,{__call = function(k,...)return wrap(function(...)
    return setmetatable({...},_list)
end,"list")(...) end})

_list.__tostring = function(l)
    return '[' .. l.join(", ") .. ']'
end

function funkItUp(func, argList)
    if(type(argList)~="table")then
        argList = {argList}
    end
    return function(...)
        local newArg = {}
        for k,v in ipairs{...} do
            for k2,v2 in ipairs(argList) do
                if(v2 == k)then
                    v = makeFunky(v)
                    break
                end
            end
            newArg[k] = v
        end
        return func(table.unpack(newArg))
    end
end

range = funkItUp(wrap(function(a, b, funky, ...)
    if funky then
        funky = makeFunky(funky)
    end
    local l = list()
    for i=a, b, a<=b and 1 or -1 do
        l[#l+1] = funky and funky(i,...) or i
    end
    return l
end,"range"),3)

list.forEach = funkItUp(wrap(function(list, funk,...)
    funk = makeFunky(funk)
    for k,v in ipairs(list) do
        local v = funk(v,k,list,...)
        if(v)then
            return v
        end
    end
end,"forEach"),2)

list.map = funkItUp(wrap(function(inplist, funk,...)
    funk = makeFunky(funk)
    local newList = list()
    for k,v in ipairs(inplist) do
        newList[k] = funk(v,k,inplist,newList,...)
    end
    return newList
end,"map"),2)

list.reduce = funkItUp(wrap(function(a,b,...)
    local val
    b = makeFunky(b)
    for k,v in ipairs(a) do
        if(val == nil)then
            val = v
        else
            val = b(val,v,...)
        end
    end
    return val
end,"reduce"),2)

list.cumulate = funkItUp(wrap(function(a,b,...)
    local newList = list()
    local val
    b = makeFunky(b)
    for k,v in ipairs(a) do
        if(val == nil)then
            val = v
        else
            val = b(val,v,...)
        end
        newList[#newList+1] = val
    end
    return newList
end,"cumulate"),2)

list.fold = funkItUp(wrap(function(a,b,...)
    local newList = list()
    local val
    b = makeFunky(b)
    for k,v in ipairs(a) do
        if(val == nil)then
            val = v
        else
            newList[#newList+1] = b(val,v,...)
            val = v
        end
    end
    return newList
end,"fold"),2)

list.sum = wrap(#list.reduce(a,a+b), "sum")
list.product = wrap(#list.reduce(a,a*b), "product")

list.c_cat = wrap(function(a,b)
    if(getmetatable(a)~=_list)then
        a = list(a)
    end
    if(getmetatable(b)~=_list)then
        b = list(b)
    end
    local l = list()
    for k,v in ipairs(a) do
        l[#l+1] = v
    end
    for k,v in ipairs(b) do
        l[#l+1] = v
    end
    return l
end,"c_cat")

_list.__concat = function(a,b)
    return list.c_cat(a,b)
end

list.where = funkItUp(wrap(function(l,f,...)
    local nlist = list()
    f = makeFunky(f)
    for k,v in ipairs(l) do
        if(truthy(f(v,k,l,...)))then
            nlist[#nlist+1] = v
        end
    end
    return nlist
end,"where"),2)

list.split = funkItUp(wrap(function(l,n,f,...)
    local nlist = list()
    if f then
        f = makeFunky(f)
    end
    if(type(l)=='string')then
        return split(explode(l),n,f,...).map(join(a))
    end
    for i=1, #l, n do
        local _nl = list()
        for c=i, math.min(#l,i+n-1) do
            _nl[#_nl+1] = l[c]
        end
        nlist[#nlist+1] = f and f(_nl) or _nl
    end
    return nlist
end,"split"),3)

string.explode = funkItUp(wrap(function(str,match,func,...)
    if func then
        func = makeFunky(func)
    end
    match = match or "."
    local l = list()
    for s in str:gmatch(match) do
        l[#l+1] = func and func(s,...) or s
    end
    return l
end,"explode"),3)

list.join = wrap(function(l,str)
    str = tostring(str or "")
    local c = ""
    local s = ""
    for k,v in ipairs(l) do
        s = s .. c .. tostring(v)
        c = str
    end
    return s
end,"join")

list.contains = wrap(function(l,v)
    for k,v2 in ipairs(l) do
        if v2 == v then
            return true
        end
    end
    return false
end,"contains")

list.unique = wrap(function(l)
    local nList = list()
    for k,v in ipairs(l) do
        if(not list.contains(nList,v))then
            nList[#nList+1] = v
        end
    end
    return nList
end,"unique")

list.compare = wrap(function(a,b)
    if(#a ~= #b)then
        return false
    end
    for k,v in ipairs(a) do
        if b[k] ~= v then
            return false
        end
    end
    return true
end,"compare")

_list.__eq = list.compare

function _list.__bnot(l)
    local newList = list()
    local size = reduce(map(l,len),max)
    for i=1, size do
        newList[i] = list()
    end
    for i=1, #l do
        local _l = l[i]
        for c=1, size do
            if(_l[c])then
                newList[c][i] = _l[c]
            else
                newList[c][i] = nil
            end
        end
    end
    return newList
end

_list.__unm = function(l) return string.reverse(l) end

_list.__band = list.where
_list.__bor = list.map
_list.__div = list.reduce
_list.__idiv = list.fold

local __g = getmetatable(_G)
local i = __g.__index
__g.__index = function(a,k)return list[k] or i(a,k)end