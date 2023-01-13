local _, GW = ...

local function addHeroicVisionsData(block, numCriteria)
    if GW.Libs.GW2Lib:GetPlayerLocationMapID() == 1469 or GW.Libs.GW2Lib:GetPlayerLocationMapID() == 1470 then -- Heroic Vision for OG and SW
        local info = C_CurrencyInfo.GetCurrencyInfo(1744) --Corrupted Memento
        if info then
            numCriteria = numCriteria + 1
            GW.AddScenarioObjectivesBlock(
                block,
                GW.ParseCriteria(info.quantity, 0, info.name),
                false,
                numCriteria,
                "monster",
                info.quantity
            )
        end
    end

    return numCriteria
end
GW.addHeroicVisionsData = addHeroicVisionsData