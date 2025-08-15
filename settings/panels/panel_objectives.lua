local _, GW = ...
local L = GW.L

local function LoadObjectivesPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p.header:SetText(OBJECTIVES_TRACKER_LABEL)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit objectives settings."])

    p:AddOption(L["Collapse all objectives in M+"], nil, {getterSetter = "OBJECTIVES_COLLAPSE_IN_M_PLUS", callback = GW.ToggleCollapseObjectivesInChallangeMode, dependence = {["QUESTTRACKER_ENABLED"] = true}, hidden = not GW.Retail})
    p:AddOption(L["Toggle Compass"], L["Enable or disable the quest tracker compass."], {getterSetter = "SHOW_QUESTTRACKER_COMPASS", callback = function() if not GW.Classic then GwQuesttrackerContainerBossFrames:SetUpFramePosition(); GwQuesttrackerContainerArenaBGFrames:SetUpFramePosition() end; GwObjectivesNotification:OnUpdate() end, dependence = {["QUESTTRACKER_ENABLED"] = true}})
    p:AddOption(L["Show Objective Tracker progress bars"], L["If disabled, progress bars will not be shown for various objective tracker items such as quests, achievements, etc."], {getterSetter = "QUESTTRACKER_STATUSBARS_ENABLED", callback = function() GwQuesttrackerContainerQuests:UpdateLayout(); GwQuesttrackerContainerAchievement:UpdateLayout(); GwQuesttrackerContainerBonus:UpdateLayout(); GwQuesttrackerContainerCollection:UpdateLayout(); GwQuesttrackerContainerMonthlyActivity:UpdateLayout(); GwQuesttrackerContainerRecipe:UpdateLayout(); GwQuesttrackerContainerScenario:UpdateLayout(); GwQuestTracker:LayoutChanged() end, dependence = {["QUESTTRACKER_ENABLED"] = true}, hidden = not GW.Retail})
    p:AddOptionDropdown(L["Quest Tracker sorting"], nil, { getterSetter = "QUESTTRACKER_SORTING", callback = function() GwQuesttrackerContainerQuests:UpdateLayout() end, optionsList = {"DEFAULT", "LEVEL", "ZONE"}, optionNames = {DEFAULT, GUILD_RECRUITMENT_LEVEL, ZONE .. L[" |cFF888888(required Questie)|r"]}, dependence = {["QUESTTRACKER_ENABLED"] = true}, hidden = GW.Retail})

    sWindow:AddSettingsPanel(p, OBJECTIVES_TRACKER_LABEL, L["Edit objectives settings."])
end
GW.LoadObjectivesPanel = LoadObjectivesPanel
