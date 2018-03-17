if UnitIsTapDenied == nil then
    function UnitIsTapDenied()
        if (UnitIsTapped("target")) and (not UnitIsTappedByPlayer("target")) then
            return true
        end
        return false
    end
end

function countTable(T)
    local c = 0
    if T ~= nil and type(T) == 'table' then
        for _ in pairs(T) do
            c = c + 1
        end
    end
    return c
end
 
function timeCount(numSec, com)
    local nSeconds = tonumber(numSec)
    if nSeconds == nil then
        nSeconds = 0
    end
    if nSeconds == 0 then
        return '0'
    end
    
    local nHours = math.floor(nSeconds/3600)
    if nHours > 0 then
        return nHours .. 'h'
    end
    
    local nMins = math.floor(nSeconds/60)
    if nMins > 0 then
        return nMins .. 'm'
    end

    if com ~= nil then
        local nMilsecs = math.max(math.floor((nSeconds * 10^1) + 0.5) / (10^1), 0)
        return nMilsecs .. 's'
    end
    
    local nSecs = math.max(math.floor(nSeconds), 0)
    return nSecs .. 's'
end
 
function comma_value(n)
    n = round(n)
    local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

function round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end

function intRound(v)
    if v == nil then
        return 0
    end
    vf = math.floor(v)
    if (v - vf) > 0.5 then
        return vf + 1
    end
    return vf
end

function dif(a,b)
    if a == nil then
        a = 0
    end
    if b == nil then
        b = 0
    end
    
    if a > b then
        return a - b
    else
        return b - a
    end
end

function lerp(v0, v1, t)
    if v0 == nil then
        v0 = 0
    end
    local p = (v1 - v0)
    return v0 + t * p
end

function length(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

function splitString(inputstr, sep, sep2, sep3)
    if sep == nil then
        sep = "%s"
    end
    inputstr = inputstr:gsub ('\n','')
    local t = {} ; i = 1
    for str in string.gmatch(inputstr, "([^" .. sep .. "|" .. sep2 .. "|" .. sep3 .. "]+)") do
        st, en, cap1, cap2, cap3 = string.find (inputstr, str)
        if en ~= nil then
            s = string.sub (inputstr, en + 1, en + 1)
            if s ~= nil or s ~= '' then
                str =  str..s
            end
        end
        t[i] = str
        i = i + 1
    end
    return t
end

function isnan(n)
    return tostring(n) == '-1.#IND'
end
