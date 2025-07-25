local _, GW = ...

local function addJailersTowerData(block, numCriteria)
    if GW.Retail and IsInJailersTower() then
        --Phantasma
        local phinfo = C_CurrencyInfo.GetCurrencyInfo(1728)
        numCriteria = numCriteria + 1
        block:AddObjective("|T3743737:0:0:0:0:64:64:4:60:4:60|t " .. phinfo.quantity .. " " .. phinfo.name, numCriteria, { finished = false, objectiveType = "monster", qty = phinfo.quantity, firstObjectivesYValue = -5 })

        local objectiveBlock = block:GetObjectiveBlock(numCriteria)
        objectiveBlock:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:ClearLines()
            GameTooltip:SetCurrencyByID(1728)
            GameTooltip:Show()
        end)
        objectiveBlock:HookScript("OnLeave", GameTooltip_Hide)
        objectiveBlock:SetHeight(objectiveBlock:GetHeight() + 10)

        -- grab the MawBuffs Button from here
        numCriteria = numCriteria + 1
        objectiveBlock = block:GetObjectiveBlock(numCriteria)
        objectiveBlock:SetHeight(ScenarioObjectiveTracker.MawBuffsBlock:GetHeight()) --.Container
        ScenarioObjectiveTracker.MawBuffsBlock.Container:SetParent(objectiveBlock)
        ScenarioObjectiveTracker.MawBuffsBlock.Container:ClearAllPoints()
        ScenarioObjectiveTracker.MawBuffsBlock.Container:SetAllPoints()
        objectiveBlock:Show()
        objectiveBlock.ObjectiveText:SetText("")
        block.height = block.height + objectiveBlock:GetHeight()
        block.numObjectives = block.numObjectives + 1
        objectiveBlock.hasObjectToHide = true
        objectiveBlock.objectToHide = ScenarioObjectiveTracker.MawBuffsBlock
    end

    return numCriteria
end
GW.addJailersTowerData = addJailersTowerData