---@class GW2
local GW = select(2, ...)
local L = GW.L

local function GetObjectiveTrackerModuleOrderOptions()
    local optionsList = {}
    local optionNames = {}

    if not (GW.Classic or GW.TBC) then
        optionsList[#optionsList + 1] = "Achievement"
        optionNames[#optionNames + 1] = GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Achievement]:WrapTextInColorCode(ACHIEVEMENTS)
    end

    if GW.Retail then
        optionsList[#optionsList + 1] = "Campaign"
        optionNames[#optionNames + 1] = GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Campaign]:WrapTextInColorCode(TRACKER_HEADER_CAMPAIGN_QUESTS)
    end

    optionsList[#optionsList + 1] = "Quests"
    optionNames[#optionNames + 1] = GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Quest]:WrapTextInColorCode(TRACKER_HEADER_QUESTS or QUESTS_LABEL)

    if GW.Retail then
        optionsList[#optionsList + 1] = "Bonus"
        optionNames[#optionNames + 1] = GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Event]:WrapTextInColorCode(EVENTS_LABEL)

        optionsList[#optionsList + 1] = "Recipe"
        optionNames[#optionNames + 1] = GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Recipe]:WrapTextInColorCode(PROFESSIONS_TRACKER_HEADER_PROFESSION)

        optionsList[#optionsList + 1] = "MonthlyActivity"
        optionNames[#optionNames + 1] = GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.MonthlyActivity]:WrapTextInColorCode(TRACKER_HEADER_MONTHLY_ACTIVITIES)

        optionsList[#optionsList + 1] = "Collection"
        optionNames[#optionNames + 1] = GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Recipe]:WrapTextInColorCode(ADVENTURE_TRACKING_MODULE_HEADER_TEXT)

        optionsList[#optionsList + 1] = "HousingInitiative"
        optionNames[#optionNames + 1] = GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.HousingInitiative]:WrapTextInColorCode(HOUSING_DASHBOARD_ENDEAVOR)

        optionsList[#optionsList + 1] = "WQT"
        optionNames[#optionNames + 1] = GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Event]:WrapTextInColorCode("|cffaaaaaa[AddOn]|r World Quest Tracker")

        optionsList[#optionsList + 1] = "PetTracker"
        optionNames[#optionNames + 1] = GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Event]:WrapTextInColorCode("|cffaaaaaa[AddOn]|r Pet Tracker")

        optionsList[#optionsList + 1] = "Todoloo"
        optionNames[#optionNames + 1] = GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Event]:WrapTextInColorCode("|cffaaaaaa[AddOn]|r Todoloo's")
    end

    return optionsList, optionNames
end

local function UpdateObjectiveTrackerStatusBarSettings()
    for _, container in ipairs({
        GwQuesttrackerContainerQuests,
        GwQuesttrackerContainerAchievement,
        GwQuesttrackerContainerBonus,
        GwQuesttrackerContainerCollection,
        GwQuesttrackerContainerMonthlyActivity,
        GwQuesttrackerContainerRecipe,
        GwQuesttrackerContainerScenario,
        GwQuesttrackerContainerHousingInitiative
    }) do
        if container and container.UpdateLayout then
            container:UpdateLayout()
        end
    end

    if GwQuestTracker then
        GwQuestTracker:LayoutChanged()
    end
end

local function LoadObjectivesPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")
    p.panelId = "objectives_general"
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p.header:SetText(OBJECTIVES_TRACKER_LABEL)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit objectives settings."])

    p:AddOption(ENABLE, L["Enable the revamped and improved quest tracker."], {getterSetter = "QUESTTRACKER_ENABLED", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "Objectives", isMasterToggle = true})
    p:AddOptionDropdown(L["Collapse Objectives Automatically"], L["Choose when the Objective Tracker should collapse all sections automatically."], {
        getterSetter = "ObjectivesAutoCollapse",
        callback = GW.ToggleObjectivesAutoCollapse,
        optionsList = (function()
            local list = {"Raid", "Party", "Combat"}
            if GW.Retail or GW.Mists then
                tinsert(list, 1, "MythicPlus")
            end
            if GW.Retail then
                tinsert(list, 4, "Delve")
            end
            return list
        end)(),
        optionNames = (function()
            local list = {RAID, PARTY, COMBAT}
            if GW.Retail then
                tinsert(list, 1, L["Mythic+"])
            elseif GW.Mists then
                tinsert(list, 1, L["Challenge Mode"])
            end
            if GW.Retail then
                tinsert(list, 4, L["Delve"])
            end
            return list
        end)(),
        checkbox = true,
        dependence = {["QUESTTRACKER_ENABLED"] = true}
    })
    p:AddOption(L["Supertracked Quest to Top"], L["Move the currently supertracked quest to the top of the quest tracker list."], {getterSetter = "OBJECTIVES_SUPERTRACKED_QUEST_TOP", callback = GW.RefreshObjectivesTrackerLayout, dependence = {["QUESTTRACKER_ENABLED"] = true}, hidden = not GW.Retail})
    p:AddOption(L["Show Completed Objectives"], L["Show completed quest objectives instead of hiding them."], {getterSetter = "OBJECTIVES_SHOW_COMPLETED_OBJECTIVES", callback = GW.RefreshObjectivesTrackerLayout, dependence = {["QUESTTRACKER_ENABLED"] = true}, hidden = not GW.Retail})
    p:AddOption(L["Compact Mode"], L["Reduce spacing and font sizes across the Objective Tracker."], {getterSetter = "OBJECTIVES_TRACKER_COMPACT_MODE", callback = GW.RefreshObjectivesTrackerLayout, dependence = {["QUESTTRACKER_ENABLED"] = true}})
    local moduleOrderOptions, moduleOrderOptionNames = GetObjectiveTrackerModuleOrderOptions()
    p:AddOptionSortableList(L["Objective Tracker Module Order"], L["Set the order of Objective Tracker modules."], {
        getterSetter = "OBJECTIVES_TRACKER_MODULE_ORDER",
        callback = GW.ApplyObjectivesTrackerModuleOrder,
        optionsList = moduleOrderOptions,
        optionNames = moduleOrderOptionNames,
        maxVisibleRows = 6,
        dependence = {["QUESTTRACKER_ENABLED"] = true},
        hidden = GW.Classic or GW.TBC
    })
    p:AddOption(L["Toggle Compass"], L["Enable or disable the quest tracker compass."], {getterSetter = "SHOW_QUESTTRACKER_COMPASS", callback = function() if not (GW.Classic or GW.TBC or GW.Wrath) then GwQuesttrackerContainerBossFrames:SetUpFramePosition(); GwQuesttrackerContainerArenaBGFrames:SetUpFramePosition() end; GwObjectivesNotification:OnUpdate() end, dependence = {["QUESTTRACKER_ENABLED"] = true}})
    p:AddOption(L["Show Objective Tracker progress bars"], L["If disabled, progress bars will not be shown for various objective tracker items such as quests, achievements, etc."], {getterSetter = "QUESTTRACKER_STATUSBARS_ENABLED", callback = UpdateObjectiveTrackerStatusBarSettings, dependence = {["QUESTTRACKER_ENABLED"] = true}, hidden = not GW.Retail})
    p:AddOption(L["Show Quest XP in Quest Tracker"], nil, {getterSetter = "QUESTTRACKER_SHOW_XP", callback = function() GwQuesttrackerContainerQuests:UpdateLayout() end, dependence = {["QUESTTRACKER_ENABLED"] = true}, hidden = GW.Retail or GW.Mists})

    p:AddOptionDropdown(L["Quest Tracker Sorting"], nil, { getterSetter = "QUESTTRACKER_SORTING", callback = function() GwQuesttrackerContainerQuests:UpdateLayout() end, optionsList = {"DEFAULT", "LEVEL", "ZONE"}, optionNames = {DEFAULT, GUILD_RECRUITMENT_LEVEL, ZONE .. L[" |cFF888888(required Questie)|r"]}, dependence = {["QUESTTRACKER_ENABLED"] = true}, hidden = GW.Retail})

    sWindow:AddSettingsPanel(p, OBJECTIVES_TRACKER_LABEL, L["Edit objectives settings."])
end
GW.LoadObjectivesPanel = LoadObjectivesPanel
