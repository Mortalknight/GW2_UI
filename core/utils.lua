local _, GW = ...
local CastScanner = CreateFrame("Frame")

-- Init Tables
CastScanner.db = {}
CastScanner.guid = {}

if UnitIsTapDenied == nil then
    function UnitIsTapDenied()
        if (UnitIsTapped("target")) and (not UnitIsTappedByPlayer("target")) then
            return true
        end
        return false
    end
end

GW.UnitCastingInfo = _G.UnitCastingInfo or function(unit)
	assert(type(unit) == "string", "Usage: UnitCastingInfo(\"unit\")")

	if not UnitExists(unit) then return end

	if unit == "player"  then
		return CastingInfo()
	else
		local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellID
		local unitGUID = UnitGUID(unit)

		if CastScanner.db[unitGUID] and CastScanner.db[unitGUID].startTimeMS then
			if CastScanner.db[unitGUID].startTimeMS + CastScanner.db[unitGUID].castTime > GetTime() then
				if CastScanner.db.channelStatus then return end
				name					= CastScanner.db[unitGUID].name
				text					= CastScanner.db[unitGUID].text
				texture					= CastScanner.db[unitGUID].texture
				startTimeMS				= CastScanner.db[unitGUID].startTimeMS
				endTimeMS				= CastScanner.db[unitGUID].endTimeMS
				isTradeSkill			= CastScanner.db[unitGUID].isTradeSkill
				castID					= CastScanner.db[unitGUID].castID
				notInterruptible		= CastScanner.db[unitGUID].notInterruptible
				spellID					= CastScanner.db[unitGUID].spellID
			elseif CastScanner.db[unitGUID] then
				wipe(CastScanner.db[unitGUID])
			end
		end

		return name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellID
	end
end

GW.UnitChannelInfo = _G.UnitChannelInfo or function(unit)
	assert(type(unit) == "string", "Usage: UnitChannelInfo(\"unit\")")

	if not UnitExists(unit) then return end

	if unit == "player" or UnitGUID(unit) == CastScanner.guid.player then
		return ChannelInfo()
	else
		local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellID
		local unitGUID = UnitGUID(unit)

		if CastScanner.db[unitGUID] and CastScanner.db[unitGUID].startTimeMS then
			if CastScanner.db[unitGUID].startTimeMS + CastScanner.db[unitGUID].castTime > GetTime() then
				if not CastScanner.db[unitGUID].channelStatus then return end
				name					= CastScanner.db[unitGUID].name
				text					= CastScanner.db[unitGUID].text
				texture					= CastScanner.db[unitGUID].texture
				startTimeMS				= CastScanner.db[unitGUID].startTimeMS
				endTimeMS				= CastScanner.db[unitGUID].endTimeMS
				isTradeSkill			= CastScanner.db[unitGUID].isTradeSkill
				castID					= CastScanner.db[unitGUID].castID
				notInterruptible		= CastScanner.db[unitGUID].notInterruptible
				spellID					= CastScanner.db[unitGUID].spellID
			elseif CastScanner.db[unitGUID] then
				wipe(CastScanner.db[unitGUID])
			end
		end
		
		return name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellID
	end
end

GW.countTable = function(T)
    local c = 0
    if T ~= nil and type(T) == 'table' then
        for _ in pairs(T) do
            c = c + 1
        end
    end
    return c
end
 
GW.timeCount = function(numSec, com)
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
 
GW.comma_value = function(n)
    n = GW.round(n)
    local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

GW.round = function(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end

GW.intRound = function(v)
    if v == nil then
        return 0
    end
    vf = math.floor(v)
    if (v - vf) > 0.5 then
        return vf + 1
    end
    return vf
end

GW.dif = function(a,b)
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

GW.lerp = function(v0, v1, t)
    if v0 == nil then
        v0 = 0
    end
    local p = (v1 - v0)
    return v0 + t * p
end

GW.length = function(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

GW.splitString = function(inputstr, sep, sep2, sep3)
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

GW.isnan = function(n)
    return tostring(n) == '-1.#IND'
end