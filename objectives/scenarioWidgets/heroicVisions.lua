local _, GW = ...

local mapIds = {
    [1469] = true,
    [1470] = true,
    [2403] = true,
    [2404] = true
}

local function addHeroicVisionsData(block, numCriteria)
    local mapId = GW.Libs.GW2Lib:GetPlayerLocationMapID()
    if mapIds[mapId] then -- Heroic Vision for OG and SW
        local info = C_CurrencyInfo.GetCurrencyInfo(1744) --Corrupted Memento
        if info then
            numCriteria = numCriteria + 1
            block:AddObjective(GW.ParseCriteria(info.quantity, 0, info.name), numCriteria, { finished = false, objectiveType = "monster", qty = info.quantity, firstObjectivesYValue = -5 })
        end
    end

    return numCriteria
end
GW.addHeroicVisionsData = addHeroicVisionsData