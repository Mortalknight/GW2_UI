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
            block:AddObjective(GW.ParseCriteria(winfo.quantity, winfo.maxQuantity, winfo.name), numCriteria, { finished = false, objectiveType = "progressbar", qty = winfo.quantity, firstObjectivesYValue = -5 })
        end
        --Iron
        if iinfo then
            numCriteria = numCriteria + 1
            block:AddObjective(GW.ParseCriteria(iinfo.quantity, iinfo.maxQuantity, iinfo.name), numCriteria, { finished = false, objectiveType = "progressbar", qty = iinfo.quantity / iinfo.maxQuantity * 100, firstObjectivesYValue = -5 })
        end
    end

    return numCriteria
end
GW.addWarfrontData = addWarfrontData