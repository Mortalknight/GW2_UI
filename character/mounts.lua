local _, GW = ...

--[[
 TODO
Drag and drop (any secure way of handling drag and drop?)
]]

local NUM_MOUNTS_PER_TAB = 12

local function LoadMounts()
    local mountsFrame = CreateFrame("Frame", "GwMountsFrame", GwCharacterWindow, "GwMountsCritterBaseFrame")
    local mountsList = CreateFrame('Frame', 'GwMountsList', GwMountsFrame, 'GwMountsCritterList')

    mountsList.neededContainers = math.ceil(GetNumCompanions("MOUNT") / NUM_MOUNTS_PER_TAB)
    mountsList.maxNumberOfContainers = mountsList.neededContainers  + 2

    --Create summon button and set frame level above the model frame
    local summonButton = CreateFrame("Button","GwMountSummonButton" .. "MOUNT", GwMountsFrame, "GwMountCritterSummonButton" )
    summonButton:SetFrameLevel(mountsFrame.model:GetFrameLevel()+1)
    summonButton:RegisterForClicks("AnyUp")
    summonButton:SetScript("OnClick", GW.UserMountCritter)
    summonButton.selectedButton = nil
    mountsFrame.summon = summonButton

    mountsList.baseFrame = mountsFrame

    mountsFrame.title:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    mountsFrame.title:SetTextColor(0.87, 0.74, 0.29, 1)

    mountsList.pages:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    mountsList.pages:SetTextColor(0.7, 0.7, 0.5, 1)

    GW.CreateMountsPetsContainersWithButtons("MOUNT", mountsList, mountsFrame, mountsList.maxNumberOfContainers, NUM_MOUNTS_PER_TAB, "GwMountsCritterListItem")

    GW.UpdateMountsCritterList(mountsList, "MOUNT", NUM_MOUNTS_PER_TAB, true)
    GW.SetUpMoutCritterPaging(mountsList)

    mountsFrame:RegisterEvent("COMPANION_LEARNED")
    mountsFrame:RegisterEvent("COMPANION_UNLEARNED")
    mountsFrame:RegisterEvent("COMPANION_UPDATE")
    mountsFrame:SetScript("OnEvent", function(self, event)
        if (event == "COMPANION_LEARNED" or event == "PLAYER_REGEN_ENABLED") and not InCombatLockdown() then
            -- update needed containers
            if math.ceil(GetNumCompanions("MOUNT") / NUM_MOUNTS_PER_TAB) > mountsList.neededContainers then
                local oldMaxNumberOfContainers = mountsList.maxNumberOfContainers
                mountsList.neededContainers = math.ceil(GetNumCompanions("MOUNT") / NUM_MOUNTS_PER_TAB)
                mountsList.maxNumberOfContainers = mountsList.neededContainers  + 2

                mountsList.attrDummy:SetAttribute("maxNumberOfContainers", mountsList.maxNumberOfContainers)
                mountsList.attrDummy:SetAttribute("neededContainers", mountsList.neededContainers)

                GW.CreateMountsPetsContainersWithButtons("MOUNT", mountsList, mountsFrame, mountsList.maxNumberOfContainers, NUM_MOUNTS_PER_TAB, "GwMountsCritterListItem", oldMaxNumberOfContainers + 1)

                mountsList.attrDummy:SetAttribute('page', 'left')
            end
        elseif event == "COMPANION_LEARNED" and InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
            return
        end

        if not self:IsShown() then return end
        GW.UpdateMountsCritterList(mountsList, "MOUNT", NUM_MOUNTS_PER_TAB)
    end)
    mountsList:SetScript("OnShow", function()
        GW.UpdateMountsCritterList(mountsList, "MOUNT", NUM_MOUNTS_PER_TAB)
    end)

    -- GwMountsList event handler for updates during combat
    mountsList:SetScript("OnEvent", function(_, event)
        mountsList:UnregisterEvent(event)
        GW.UpdateMountsCritterList(mountsList, "MOUNT", NUM_MOUNTS_PER_TAB)
    end)

    return mountsFrame
end
GW.LoadMounts = LoadMounts
