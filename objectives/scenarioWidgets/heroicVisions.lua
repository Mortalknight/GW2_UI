local _, GW = ...
local ParseCriteria = GW.ParseCriteria

local function addHeroicVisionsData(block, numCriteria)
    if GW.locationData.mapID == 1469 or GW.locationData.mapID == 1470 then -- Heroic Vision for OG and SW
        local info = C_CurrencyInfo.GetCurrencyInfo(1744) --Corrupted Memento
        numCriteria = numCriteria + 1
        GW.AddScenarioObjectivesBlock(
            block,
            ParseCriteria(info.quantity, 0, info.name),
            false,
            numCriteria,
            "monster",
            info.quantity
        )
    end

    return numCriteria
end
GW.addHeroicVisionsData = addHeroicVisionsData