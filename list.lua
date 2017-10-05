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

range = wrap(function(a, b, funky, ...)
    if funky then
        funky = makeFunky(funky)
    end
    local l = list()
    for i=a, b, a<=b and 1 or -1 do
        l[#l+1] = funky and funky(i,...) or i
    end
    return l
end,"range")

list.forEach = wrap(function(list, funk,...)
    funk = makeFunky(funk)
    for k,v in ipairs(list) do
        local v = funk(v,k,list,...)
        if(v)then
            return v
        end
    end
end,"forEach")

list.map = wrap(function(inplist, funk,...)
    funk = makeFunky(funk)
    local newList = list()
    for k,v in ipairs(inplist) do
        newList[k] = funk(v,k,inplist,newList,...)
    end
    return newList
end,"map")

list.reduce = wrap(function(a,b,...)
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
end,"reduce")

list.cumulate = wrap(function(a,b,...)
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
end,"cumulate")

list.fold = wrap(function(a,b,...)
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
end,"fold")

list.sum = wrap(#list.reduce(a,#(a+b)), "sum")
list.product = wrap(#list.reduce(a,#(a*b)), "product")

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

list.where = wrap(function(l,f,...)
    local nlist = list()
    f = makeFunky(f)
    for k,v in ipairs(l) do
        if(truthy(f(v,k,l,...)))then
            nlist[#nlist+1] = v
        end
    end
    return nlist
end,"where")

list.split = wrap(function(l,n,f,...)
    local nlist = list()
    if f then
        f = makeFunky(f)
    end
    for i=1, #l, n do
        local _nl = list()
        for c=i, math.min(#l,i+n-1) do
            _nl[#_nl+1] = f and f(l[c],...) or l[c]
        end
        nlist[#nlist+1] = _nl
    end
    return nlist
end,"split")

string.explode = function(str,match,func,...)
    if func then
        func = makeFunky(func)
    end
    local l = list()
    for s in str:gmatch(match) do
        l[#l+1] = func and func(s,...) or s
    end
    return l
end

list.join = function(l,str)
    str = tostring(str or "")
    local c = ""
    local s = ""
    for k,v in ipairs(l) do
        s = s .. c .. tostring(v)
        c = str
    end
    return s
end

local __g = getmetatable(_G)
local i = __g.__index
__g.__index = function(a,k)return list[k] or i(a,k)end