---@class GW2
local GW = select(2, ...)
local L = GW.L

-- the entries mirror the container list in ObjectivesTracker.lua: every container that loads on
-- this client can be ordered, and an entry without a label on this client is skipped
local function GetObjectiveTrackerModuleOrderOptions()
    local types = GW.Enum.ObjectivesNotificationType
    local modules = {
        {key = "Achievement", label = ACHIEVEMENTS, color = types.Achievement, load = not (GW.Classic or GW.TBC)},
        {key = "Campaign", label = TRACKER_HEADER_CAMPAIGN_QUESTS, color = types.Campaign, load = GW.Retail},
        {key = "Quests", label = TRACKER_HEADER_QUESTS or QUESTS_LABEL, color = types.Quest, load = true},
        {key = "Bonus", label = EVENTS_LABEL, color = types.Event, load = GW.isModern},
        {key = "Recipe", label = PROFESSIONS_TRACKER_HEADER_PROFESSION, color = types.Recipe, load = GW.isModern},
        {key = "MonthlyActivity", label = TRACKER_HEADER_MONTHLY_ACTIVITIES, color = types.MonthlyActivity, load = GW.isModern},
        {key = "Collection", label = ADVENTURE_TRACKING_MODULE_HEADER_TEXT, color = types.Recipe, load = GW.isModern},
        {key = "HousingInitiative", label = HOUSING_DASHBOARD_ENDEAVOR, color = types.HousingInitiative, load = GW.Retail},
        {key = "WQT", label = "|cffaaaaaa[AddOn]|r World Quest Tracker", color = types.Event, load = GW.Retail},
        {key = "PetTracker", label = "|cffaaaaaa[AddOn]|r Pet Tracker", color = types.Event, load = GW.Retail},
        {key = "Todoloo", label = "|cffaaaaaa[AddOn]|r Todoloo's", color = types.Event, load = GW.Retail},
    }

    local optionsList = {}
    local optionNames = {}
    for _, module in ipairs(modules) do
        if module.load and module.label then
            optionsList[#optionsList + 1] = module.key
            optionNames[#optionNames + 1] = GW.Colors.ObjectivesTypeColors[module.color]:WrapTextInColorCode(module.label)
        end
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

    p:AddOption(ENABLE, L["Enable the revamped and improved quest tracker."], {getterSetter = "objectives.enabled", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "Objectives", isMasterToggle = true})
    p:AddOptionDropdown(L["Collapse Objectives Automatically"], L["Choose when the Objective Tracker should collapse all sections automatically."], {
        getterSetter = "objectives.autoCollapse",
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
        dependence = {["objectives.enabled"] = true}
    })
    p:AddOption(L["Supertracked Quest to Top"], L["Move the currently supertracked quest to the top of the quest tracker list."], {getterSetter = "objectives.superTrackedOnTop", callback = GW.RefreshObjectivesTrackerLayout, dependence = {["objectives.enabled"] = true}, hidden = not GW.Retail})
    p:AddOption(L["Show Completed Objectives"], L["Show completed quest objectives instead of hiding them."], {getterSetter = "objectives.showCompleted", callback = GW.RefreshObjectivesTrackerLayout, dependence = {["objectives.enabled"] = true}})
    p:AddOption(L["Compact Mode"], L["Reduce spacing and font sizes across the Objective Tracker."], {getterSetter = "objectives.compactMode", callback = GW.RefreshObjectivesTrackerLayout, dependence = {["objectives.enabled"] = true}})
    p:AddOptionSlider(L["Objective Spacing"], L["Scales the gaps between objective lines and between quest blocks. Lower values pack them tighter."], {getterSetter = "objectives.spacing", callback = GW.RefreshObjectivesTrackerLayout, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.05, dependence = {["objectives.enabled"] = true}})
    p:AddOption(L["Toggle Compass"], L["Enable or disable the quest tracker compass."], {getterSetter = "objectives.compass", callback = function() if not (GW.Classic or GW.TBC or GW.Wrath) then GwQuesttrackerContainerBossFrames:SetUpFramePosition(); GwQuesttrackerContainerArenaBGFrames:SetUpFramePosition() end; GwObjectivesNotification:OnUpdate() end, dependence = {["objectives.enabled"] = true}})
    p:AddOption(L["Show Objective Tracker progress bars"], L["If disabled, progress bars will not be shown for various objective tracker items such as quests, achievements, etc."], {getterSetter = "objectives.statusBars", callback = UpdateObjectiveTrackerStatusBarSettings, dependence = {["objectives.enabled"] = true}})
    p:AddOption(L["Show Quest XP in Quest Tracker"], nil, {getterSetter = "objectives.showXp", callback = function() GwQuesttrackerContainerQuests:UpdateLayout() end, dependence = {["objectives.enabled"] = true}, hidden = GW.Retail or GW.Mists})

    p:AddOptionDropdown(L["Quest Tracker Sorting"], nil, { getterSetter = "objectives.sorting", callback = function() GwQuesttrackerContainerQuests:UpdateLayout() end, optionsList = {"DEFAULT", "LEVEL", "ZONE"}, optionNames = {DEFAULT, GUILD_RECRUITMENT_LEVEL, ZONE .. L[" |cFF888888(required Questie)|r"]}, dependence = {["objectives.enabled"] = true}, hidden = GW.Retail})

    local moduleOrderOptions, moduleOrderOptionNames = GetObjectiveTrackerModuleOrderOptions()
    p:AddOptionSortableList(L["Objective Tracker Module Order"], L["Set the order of Objective Tracker modules."], {
        getterSetter = "objectives.moduleOrder",
        callback = GW.ApplyObjectivesTrackerModuleOrder,
        optionsList = moduleOrderOptions,
        optionNames = moduleOrderOptionNames,
        maxVisibleRows = 6,
        dependence = {["objectives.enabled"] = true},
        hidden = GW.Classic or GW.TBC
    })

    sWindow:AddSettingsPanel(p, OBJECTIVES_TRACKER_LABEL, L["Edit objectives settings."])
end
GW.LoadObjectivesPanel = LoadObjectivesPanel
