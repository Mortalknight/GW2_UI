local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local settingsMenuAddButton = GW.settingsMenuAddButton;

local function LoadObjectivesPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p.header:SetText(OBJECTIVES_TRACKER_LABEL)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit objectives settings."])

    createCat(OBJECTIVES_TRACKER_LABEL, nil, p, {p})
    settingsMenuAddButton(OBJECTIVES_TRACKER_LABEL, p, {})
    addOption(p.scroll.scrollchild, L["Collapse all objectives in M+"], nil, {getterSetter = "OBJECTIVES_COLLAPSE_IN_M_PLUS", callback = GW.ToggleCollapseObjectivesInChallangeMode, dependence = {["QUESTTRACKER_ENABLED"] = true}})
    addOption(p.scroll.scrollchild, L["Toggle Compass"], L["Enable or disable the quest tracker compass."], {getterSetter = "SHOW_QUESTTRACKER_COMPASS", callback = function() GwQuesttrackerContainerBossFrames:SetUpFramePosition(); GwQuesttrackerContainerArenaBGFrames:SetUpFramePosition(); GwObjectivesNotification:OnUpdate() end, dependence = {["QUESTTRACKER_ENABLED"] = true}})
    addOption(p.scroll.scrollchild, L["Show Objective Tracker progress bars"], L["If disabled, progress bars will not be shown for various objective tracker items such as quests, achievements, etc."], {getterSetter = "QUESTTRACKER_STATUSBARS_ENABLED", callback = function() GwQuesttrackerContainerQuests:UpdateLayout(); GwQuesttrackerContainerAchievement:UpdateLayout(); GwQuesttrackerContainerBonus:UpdateLayout(); GwQuesttrackerContainerCollection:UpdateLayout(); GwQuesttrackerContainerMonthlyActivity:UpdateLayout(); GwQuesttrackerContainerRecipe:UpdateLayout(); GwQuesttrackerContainerScenario:UpdateLayout(); GwQuestTracker:LayoutChanged() end, dependence = {["QUESTTRACKER_ENABLED"] = true}})
    InitPanel(p, true)
end
GW.LoadObjectivesPanel = LoadObjectivesPanel
