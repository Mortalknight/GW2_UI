local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local settingsMenuAddButton = GW.settingsMenuAddButton;

local function LoadObjectivesPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(OBJECTIVES_TRACKER_LABEL)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit objectives settings."])

    createCat(OBJECTIVES_TRACKER_LABEL, nil, p, {p})
    settingsMenuAddButton(OBJECTIVES_TRACKER_LABEL, p, {})
    addOption(p.scroll.scrollchild, L["Collapse all objectives in M+"], nil, "OBJECTIVES_COLLAPSE_IN_M_PLUS", function() GW.ToggleCollapseObjectivesInChallangeMode() end, nil, {["QUESTTRACKER_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Toggle Compass"], L["Enable or disable the quest tracker compass."], "SHOW_QUESTTRACKER_COMPASS", function() GW.SetUpBossFramePosition(); GW.SetUpArenaFramePosition(); GW.forceCompassHeaderUpdate() end, nil, {["QUESTTRACKER_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Show Objective Tracker progress bars"], L["If disabled, progress bars will not be shown for various objective tracker items such as quests, achievements, etc."], "QUESTTRACKER_STATUSBARS_ENABLED", function() GW.updateQuestLogLayout(GwQuesttrackerContainerQuests); GW.UpdateAchievementLayout(GwQuesttrackerContainerAchievement); GW.updateBonusObjective(GwQuesttrackerContainerBonusObjectives); GW.UpdateCollectionTrackingLayout(GwQuesttrackerContainerCollection); GW.UpdateMonthlyActivitesTracking(GwQuesttrackerContainerMonthlyActivity); GW.UpdateRecipeTrackingLayout(GwQuesttrackerContainerRecipe); GW.updateCurrentScenario(GwQuesttrackerContainerScenario); GW.QuestTrackerLayoutChanged() end, nil, {["QUESTTRACKER_ENABLED"] = true})

    InitPanel(p, true)
end
GW.LoadObjectivesPanel = LoadObjectivesPanel
