local _, GW = ...

local function addWarfrontData(block, numCriteria)
    local scenarioType = select(10, C_Scenario.GetInfo())
    local inWarfront = (scenarioType == LE_SCENARIO_TYPE_WARFRONT)

    if inWarfront then
        local winfo = C_CurrencyInfo.GetCurrencyInfo(1540) -- wood
        local iinfo = C_CurrencyInfo.GetCurrencyInfo(1541) -- iron
        --Wood
        numCriteria = numCriteria + 1
        addObjectiveBlock(
            block,
            ParseCriteria(winfo.quantity, winfo.maxQuantity, winfo.name),
            false,
            numCriteria,
            "progressbar",
            winfo.quantity
        )
        --Iron
        numCriteria = numCriteria + 1
        addObjectiveBlock(
            block,
            ParseCriteria(iinfo.quantity, iinfo.maxQuantity, iinfo.name),
            false,
            numCriteria,
            "progressbar",
            iinfo.quantity / iinfo.maxQuantity * 100
        )
    end

    return numCriteria
end
GW.addWarfrontData = addWarfrontData