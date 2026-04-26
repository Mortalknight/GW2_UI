---@class GW2
local GW = select(2, ...)

local eventFrame = CreateFrame("Frame")

local function ShouldCollapseObjectives(inCombat)
    local settings = GW.settings.ObjectivesAutoCollapse
    local _, _, difficultyID = GetInstanceInfo()

    if settings.MythicPlus and difficultyID == 8 then
        return true
    end

    if settings.Raid and IsInRaid() then
        return true
    end

    if settings.Party and IsInGroup() and not IsInRaid() then
        return true
    end

    if settings.Delve and GW.Retail and difficultyID == 208 then
        return true
    end

    if settings.Combat and inCombat then
        return true
    end

    return false
end

local function HasAnyAutoCollapseContextEnabled()
    local settings = GW.settings.ObjectivesAutoCollapse
    return settings.MythicPlus or settings.Raid or settings.Party or settings.Delve or settings.Combat
end

local function CollapseContainer(container)
    if not container.collapsed then
        container.collapsedByAutoCollapse = true
        container:CollapseHeader(true, false)
    end
end

local function ReleaseContainer(container)
    if not container.collapsedByAutoCollapse then
        return
    end

    container.collapsedByAutoCollapse = nil
    if container.collapsed then
        container:CollapseHeader(false, true)
    end
end

local function ApplyCollapseState(forceCollapse, inCombat)
    local shouldCollapse = forceCollapse or ShouldCollapseObjectives(inCombat or InCombatLockdown())
    if not GW.QuestTrackerScrollableContainer then return end
    for _, container in ipairs(GW.QuestTrackerScrollableContainer) do
        if container.shouldUpdate ~= nil then
            container.shouldUpdate = false
        end
        if container.CollapseHeader then
            if shouldCollapse then
                CollapseContainer(container)
            else
                ReleaseContainer(container)
            end
        end
    end
end

local function OnEvent(_, event)
    local inCombat = nil
    if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        inCombat = event == "PLAYER_REGEN_DISABLED"
    end
    ApplyCollapseState(nil, inCombat)
end

local function RegisterSupportedEvents()
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

    if not GW.Wrath then
        eventFrame:RegisterEvent("SCENARIO_UPDATE")
        eventFrame:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
    end

    if GW.Retail or GW.Mists then
        eventFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
        eventFrame:RegisterEvent("CHALLENGE_MODE_START")
    end
end

local function ToggleObjectivesAutoCollapse()
    if HasAnyAutoCollapseContextEnabled() then
        RegisterSupportedEvents()
        eventFrame:SetScript("OnEvent", OnEvent)
        ApplyCollapseState()
    else
        eventFrame:UnregisterAllEvents()
        eventFrame:SetScript("OnEvent", nil)
        ApplyCollapseState(false)
    end
end
GW.ToggleObjectivesAutoCollapse = ToggleObjectivesAutoCollapse
