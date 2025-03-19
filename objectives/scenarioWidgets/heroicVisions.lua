local _, GW = ...

local function addHeroicVisionsData(block, numCriteria)
    if GW.Libs.GW2Lib:GetPlayerLocationMapID() == 1469 or GW.Libs.GW2Lib:GetPlayerLocationMapID() == 1470 then -- Heroic Vision for OG and SW
        local info = C_CurrencyInfo.GetCurrencyInfo(1744) --Corrupted Memento
        if info then
            numCriteria = numCriteria + 1
            block:AddObjective(GW.ParseCriteria(info.quantity, 0, info.name), numCriteria, { finished = false, objectiveType = "monster", qty = info.quantity, firstObjectivesYValue = -5 })
        end
    end

    return numCriteria
end
GW.addHeroicVisionsData = addHeroicVisionsData