local _, GW = ...

local isOnUpdateHooked = false
local function addEmberCourtData(container, numCriteria)
    if GW.Libs.GW2Lib:GetPlayerLocationMapID()== 1644 then
        if BottomScenarioWidgetContainerBlock.WidgetContainer:GetHeight() > 1.1 then
            numCriteria = numCriteria + 1

            local objectiveBlock = container.block:GetObjectiveBlock(numCriteria)
            BottomScenarioWidgetContainerBlock.gwBlock = objectiveBlock
            objectiveBlock:SetHeight(max(BottomScenarioWidgetContainerBlock.height, BottomScenarioWidgetContainerBlock.WidgetContainer:GetHeight()))
            BottomScenarioWidgetContainerBlock.SetParent = nil
            BottomScenarioWidgetContainerBlock.ClearAllPoints = nil
            BottomScenarioWidgetContainerBlock.SetPoint = nil
            BottomScenarioWidgetContainerBlock:SetParent(objectiveBlock)
            BottomScenarioWidgetContainerBlock:ClearAllPoints()
            BottomScenarioWidgetContainerBlock:SetPoint("TOP", 0, 15)
            BottomScenarioWidgetContainerBlock.SetParent = GW.NoOp
            BottomScenarioWidgetContainerBlock.ClearAllPoints = GW.NoOp
            BottomScenarioWidgetContainerBlock.SetPoint = GW.NoOp
            objectiveBlock:Show()
            objectiveBlock.ObjectiveText:SetText("")
            container.block.height = container.block.height + objectiveBlock:GetHeight() + 15
            container.block.numObjectives = container.block.numObjectives + 1
            objectiveBlock.hasObjectToHide = true
            objectiveBlock.objectToHide = BottomScenarioWidgetContainerBlock
            objectiveBlock.resetParent = true
        end
    end

    return numCriteria
end
GW.addEmberCourtData = addEmberCourtData
