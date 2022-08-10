local _, GW = ...

local NUM_CRITTER_PER_TAB = 12

local function LoadCritter()
    local critterFrame = CreateFrame("Frame", "GwCritterFrame", GwCharacterWindow, "GwMountsCritterBaseFrame")
    local critterList = CreateFrame('Frame', 'GwCritterList', critterFrame, 'GwMountsCritterList')

    critterList.neededContainers = math.ceil(GetNumCompanions("CRITTER") / NUM_CRITTER_PER_TAB)
    critterList.maxNumberOfContainers = critterList.neededContainers  + 2

    --Create summon button and set frame level above the model frame
    local summonButton = CreateFrame("Button","GwCritterSummonButton" .. "CRITTER", critterFrame, "GwMountCritterSummonButton" )
    summonButton:SetFrameLevel(critterFrame.model:GetFrameLevel()+1)
    summonButton:RegisterForClicks("AnyUp")
    summonButton:SetScript("OnClick", GW.UserMountCritter)
    summonButton.selectedButton = nil
    critterFrame.summon = summonButton

    critterList.baseFrame = critterFrame

    critterFrame.title:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    critterFrame.title:SetTextColor(0.87, 0.74, 0.29, 1)

    critterList.pages:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    critterList.pages:SetTextColor(0.7, 0.7, 0.5, 1)

    GW.CreateMountsPetsContainersWithButtons(critterList, critterFrame, critterList.maxNumberOfContainers, NUM_CRITTER_PER_TAB, "GwMountsCritterListItem")

    GW.UpdateMountsCritterList(critterList, "CRITTER", NUM_CRITTER_PER_TAB, true)
    GW.SetUpMoutCritterPaging(critterList)

    critterFrame:RegisterEvent("COMPANION_LEARNED")
    critterFrame:RegisterEvent("COMPANION_UNLEARNED")
    critterFrame:RegisterEvent("COMPANION_UPDATE")
    critterFrame:SetScript("OnEvent", function(self, event)
        if (event == "COMPANION_LEARNED" or event == "PLAYER_REGEN_ENABLED") and not InCombatLockdown() then
            -- update needed containers
            if math.ceil(GetNumCompanions("CRITTER") / NUM_CRITTER_PER_TAB) > critterList.neededContainers then
                local oldMaxNumberOfContainers = critterList.maxNumberOfContainers
                critterList.neededContainers = math.ceil(GetNumCompanions("CRITTER") / NUM_CRITTER_PER_TAB)
                critterList.maxNumberOfContainers = critterList.neededContainers  + 2

                critterList.attrDummy:SetAttribute("maxNumberOfContainers", critterList.maxNumberOfContainers)
                critterList.attrDummy:SetAttribute("neededContainers", critterList.neededContainers)

                GW.CreateMountsPetsContainersWithButtons(critterList, critterFrame, critterList.maxNumberOfContainers, NUM_CRITTER_PER_TAB, "GwMountsCritterListItem", oldMaxNumberOfContainers + 1)

                self.attrDummy:SetAttribute('page', 'left')
            end
        elseif event == "COMPANION_LEARNED" and InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
            return
        end

        if not self:IsShown() then return end
        GW.UpdateMountsCritterList(critterList, "CRITTER", NUM_CRITTER_PER_TAB)
    end)
    critterFrame:SetScript("OnSHow", function()
        GW.UpdateMountsCritterList(critterList, "CRITTER", NUM_CRITTER_PER_TAB)
    end)

    -- GwCritterList event handler for updates during combat
    critterFrame:SetScript("OnEvent", function(_, event)
        critterList:UnregisterEvent(event)
        GW.UpdateMountsCritterList(critterList, "CRITTER", NUM_CRITTER_PER_TAB)
    end)









    return critterFrame
end
GW.LoadCritter = LoadCritter