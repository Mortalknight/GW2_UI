---@class GW2
local GW = select(2, ...)

local function addJailersTowerData(block)
    if not GW.Retail then
        return
    end

    if IsInJailersTower() and not (block.currenciesFrame and block.currenciesFrame:IsShown()) then
        --Phantasma
        local phinfo = C_CurrencyInfo.GetCurrencyInfo(1728)
        block:AddObjective("|T3743737:0:0:0:0:64:64:4:60:4:60|t " .. phinfo.quantity .. " " .. phinfo.name, { finished = false, objectiveType = "monster", qty = phinfo.quantity, firstObjectivesYValue = -5 })

        block.numObjectives = block.numObjectives + 1
        local objectiveBlock = block:GetObjectiveBlock(block.numObjectives)
        objectiveBlock:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:ClearLines()
            GameTooltip:SetCurrencyByID(1728)
            GameTooltip:Show()
        end)
        objectiveBlock:HookScript("OnLeave", GameTooltip_Hide)
        objectiveBlock:SetHeight(objectiveBlock:GetHeight() + 10)
    end
end
GW.addJailersTowerData = addJailersTowerData