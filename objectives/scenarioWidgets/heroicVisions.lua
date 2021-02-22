local _, GW = ...

local function addHeroicVisionsData(block, numCriteria)
    if GW.locationData.mapID == 1469 or GW.locationData.mapID == 1470 then -- Heroic Vision for OP and SW
        local info = C_CurrencyInfo.GetCurrencyInfo(1744) --Corrupted Memento
        numCriteria = numCriteria + 1
        addObjectiveBlock(
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