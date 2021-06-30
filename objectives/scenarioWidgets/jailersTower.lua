local _, GW = ...

local function addJailersTowerData(block, numCriteria)
    if IsInJailersTower() then
        local widgetInfo = C_UIWidgetManager.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo(3302)
        local remainingDeathText, remainingDeath
        if widgetInfo and widgetInfo.currencies and widgetInfo.currencies[2] then
            local currencies = widgetInfo.currencies
            remainingDeathText = currencies[2].tooltip
            remainingDeath = currencies[2].text
        end

        --Phantasma
        local phinfo = C_CurrencyInfo.GetCurrencyInfo(1728)
        numCriteria = numCriteria + 1
        GW.AddScenarioObjectivesBlock(
            block,
            "|T3743737:0:0:0:0:64:64:4:60:4:60|t " .. phinfo.quantity .. " " .. phinfo.name,
            false,
            numCriteria,
            "monster",
            phinfo.quantity
        )

        local objectiveBlock = GW.GetScenarioObjectivesBlock(block, numCriteria)
        objectiveBlock:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:ClearLines()
            GameTooltip:SetCurrencyByID(1728)
            GameTooltip:Show()
        end)
        objectiveBlock:HookScript("OnLeave", GameTooltip_Hide)
        objectiveBlock:SetHeight(objectiveBlock:GetHeight() + 10)

        --reamaning death
        if remainingDeath then
            numCriteria = numCriteria + 1
            GW.AddScenarioObjectivesBlock(
                block,
                "|TInterface/AddOns/GW2_UI/textures/icons/icon-dead:0:0:0:0:64:64:4:60:4:60|t " .. remainingDeath .. " " .. remainingDeathText,
                false,
                numCriteria,
                "monster",
                phinfo.quantity
            )
        end

        -- grab new bar
        numCriteria = numCriteria + 1
        local container = TopScenarioWidgetContainerBlock
        objectiveBlock = GW.GetScenarioObjectivesBlock(block, numCriteria)
        objectiveBlock:SetHeight(container:GetHeight() + 1)
        container:SetParent(objectiveBlock)
        container:ClearAllPoints()
        container:SetAllPoints()
        objectiveBlock:Show()
        objectiveBlock.ObjectiveText:SetText("")
        block.height = block.height + objectiveBlock:GetHeight()
        block.numObjectives = block.numObjectives + 1

        -- grab the MawBuffs Button from here
        numCriteria = numCriteria + 1
        local container = _G.ScenarioBlocksFrame.MawBuffsBlock.Container
        objectiveBlock = GW.GetScenarioObjectivesBlock(block, numCriteria)
        objectiveBlock:SetHeight(container:GetHeight())
        container:SetParent(objectiveBlock)
        container:ClearAllPoints()
        container:SetAllPoints()
        objectiveBlock:Show()
        objectiveBlock.ObjectiveText:SetText("")
        block.height = block.height + objectiveBlock:GetHeight()
        block.numObjectives = block.numObjectives + 1

         -- grab new auras
         numCriteria = numCriteria + 1
         local container = BottomScenarioWidgetContainerBlock
         objectiveBlock = GW.GetScenarioObjectivesBlock(block, numCriteria)
         objectiveBlock:SetHeight(container:GetHeight() + 10)
         container:SetParent(objectiveBlock)
         container:ClearAllPoints()
         container:SetPoint("TOPLEFT")
         container:SetPoint("BOTTOMLEFT")
         objectiveBlock:Show()
         objectiveBlock.ObjectiveText:SetText("")
         block.height = block.height + objectiveBlock:GetHeight()
         block.numObjectives = block.numObjectives + 1
    end

    return numCriteria
end
GW.addJailersTowerData = addJailersTowerData