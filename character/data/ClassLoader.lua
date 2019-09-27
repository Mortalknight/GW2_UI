local _, GW = ...

local tinsert = tinsert
local ipairs = ipairs

if GW.spellsByLevel==nil then
    GW.spellsByLevel = {}
end
GW.currentClass = select(2, UnitClass("player"))

local function filter(spellsByLevel, pred)
    local output = {}
    for level, spells in pairs(spellsByLevel) do
        output[level] = {}
        for _, spell in ipairs(spells) do
            if (pred(spell) == true) then
                tinsert(output[level], spell)
            end
        end
    end
    return output
end
local playerFaction = UnitFactionGroup("player")
function GW.FactionFilter(spellsByLevel)
    return filter(
        spellsByLevel,
        function(spell)
            return spell.faction == nil or spell.faction == playerFaction
        end
    )
end
local playerRace = select(3, UnitRace("player"))
function GW.RaceFilter(spellsByLevel)
    return filter(
        spellsByLevel,
        function(spell)
            if (spell.race == nil and spell.races == nil) then
                return true
            end
            if (spell.races == nil) then
                return spell.race == playerRace
            end
            return spell.races[1] == playerRace or spell.races[2] == playerRace
        end
    )
end



function GW:SetPreviousAbilityMap(t)
    local abilityMap = {}
    for _, abilityIds in ipairs(t) do
        for _, abilityId in ipairs(abilityIds) do
            abilityMap[abilityId] = abilityIds
        end
    end
    self.previousAbilityMap = abilityMap
end
