local _, GW = ...

local function addJailersTowerData(block, numCriteria)
    if IsInJailersTower() then
        local widgetInfo = C_UIWidgetManager.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo(2319)
        local remainingDeathText, remainingDeath = "", ""
        if widgetInfo then
            local currencies = widgetInfo.currencies
            remainingDeathText = currencies[1].tooltip
            remainingDeath = currencies[1].text
        end

        --Phantasma
        local phinfo = C_CurrencyInfo.GetCurrencyInfo(1728)
        numCriteria = numCriteria + 1
        addObjectiveBlock(
            block,
            "|T3743737:0:0:0:0:64:64:4:60:4:60|t " .. phinfo.quantity .. " " .. phinfo.name,
            false,
            numCriteria,
            "monster",
            phinfo.quantity
        )

        local objectiveBlock = GW.GetScenarioObjectivesBlock(block, numCriteria)
        objectiveBlock:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:ClearLines()
            GameTooltip:SetCurrencyByID(1728)
            GameTooltip:Show()
        end)
        objectiveBlock:HookScript("OnLeave", GameTooltip_Hide)

        --reamaning death
        numCriteria = numCriteria + 1
        addObjectiveBlock(
            block,
            "|TInterface/AddOns/GW2_UI/textures/icons/icon-dead:0:0:0:0:64:64:4:60:4:60|t " .. remainingDeath .. " " .. remainingDeathText,
            false,
            numCriteria,
            "monster",
            phinfo.quantity
        )

        -- grab the MawBuffs Button from here
        numCriteria = numCriteria + 1
        local container = _G.ScenarioBlocksFrame.MawBuffsBlock.Container
        objectiveBlock = GW.GetScenarioObjectivesBlock(block, numCriteria)
        objectiveBlock:SetHeight(container:GetHeight())
        container:SetParent(objectiveBlock)
        container:ClearAllPoints()
        container:SetAllPoints()
        objectiveBlock:Show()
        objectiveBlock.ObjectiveText:SetText(text)
        block.height = block.height + objectiveBlock:GetHeight()
        block.numObjectives = block.numObjectives + 1
    end

    return numCriteria
end
GW.addJailersTowerData = addJailersTowerData