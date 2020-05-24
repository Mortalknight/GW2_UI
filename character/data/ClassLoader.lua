local _, GW = ...

local tinsert = tinsert
local ipairs = ipairs

if GW.spellsByLevel == nil then
    GW.spellsByLevel = {}
end

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

function GW.FactionFilter(spellsByLevel)
    return filter(
        spellsByLevel,
        function(spell)
            return spell.faction == nil or spell.faction == GW.myfaction
        end
    )
end

function GW.RaceFilter(spellsByLevel)
    return filter(
        spellsByLevel,
        function(spell)
            if (spell.race == nil and spell.races == nil) then
                return true
            end
            if (spell.races == nil) then
                return spell.race == GW.myrace
            end
            return spell.races[1] == GW.myrace or spell.races[2] == GW.myrace
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

function GW.isHigherRankLearnd(spellId)
    if (GW.previousAbilityMap == nil) then
        return false, nil
    end

    if (not GW.previousAbilityMap[spellId]) then
        return false, nil
    end

    local spellIndex, knownIndex = 0, 0
    for i, otherId in ipairs(GW.previousAbilityMap[spellId]) do
        if (otherId == spellId) then
            spellIndex = i
        end
        if (IsSpellKnown(otherId) or IsPlayerSpell(otherId)) then
            knownIndex = i
        end
    end
    return true, knownIndex <= spellIndex
end
