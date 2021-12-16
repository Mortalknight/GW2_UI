local _, GW = ...

local function addWarfrontData(block, numCriteria)
    local scenarioType = select(10, C_Scenario.GetInfo())
    local inWarfront = (scenarioType == LE_SCENARIO_TYPE_WARFRONT)

    if inWarfront then
        local winfo = C_CurrencyInfo.GetCurrencyInfo(1540) -- wood
        local iinfo = C_CurrencyInfo.GetCurrencyInfo(1541) -- iron
        --Wood
        if winfo then
            numCriteria = numCriteria + 1
            GW.AddScenarioObjectivesBlock(
                block,
                GW.ParseCriteria(winfo.quantity, winfo.maxQuantity, winfo.name),
                false,
                numCriteria,
                "progressbar",
                winfo.quantity
            )
        end
        --Iron
        if iinfo then
            numCriteria = numCriteria + 1
            GW.AddScenarioObjectivesBlock(
                block,
                GW.ParseCriteria(iinfo.quantity, iinfo.maxQuantity, iinfo.name),
                false,
                numCriteria,
                "progressbar",
                iinfo.quantity / iinfo.maxQuantity * 100
            )
        end
    end

    return numCriteria
end
GW.addWarfrontData = addWarfrontData