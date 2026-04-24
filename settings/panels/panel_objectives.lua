---@class GW2
local GW = select(2, ...)
local L = GW.L

local function LoadObjectivesPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")
    p.panelId = "objectives_general"
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p.header:SetText(OBJECTIVES_TRACKER_LABEL)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit objectives settings."])

    p:AddOptionDropdown(L["Collapse Objectives Automatically"], L["Choose when the Objective Tracker should collapse all sections automatically."], {
        getterSetter = "ObjectivesAutoCollapse",
        callback = GW.ToggleCollapseObjectivesInChallangeMode,
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
    p:AddOption(L["Toggle Compass"], L["Enable or disable the quest tracker compass."], {getterSetter = "SHOW_QUESTTRACKER_COMPASS", callback = function() if not (GW.Classic or GW.TBC or GW.Wrath) then GwQuesttrackerContainerBossFrames:SetUpFramePosition(); GwQuesttrackerContainerArenaBGFrames:SetUpFramePosition() end; GwObjectivesNotification:OnUpdate() end, dependence = {["QUESTTRACKER_ENABLED"] = true}})
    p:AddOption(L["Show Objective Tracker progress bars"], L["If disabled, progress bars will not be shown for various objective tracker items such as quests, achievements, etc."], {getterSetter = "QUESTTRACKER_STATUSBARS_ENABLED", callback = function() GwQuesttrackerContainerQuests:UpdateLayout(); GwQuesttrackerContainerAchievement:UpdateLayout(); GwQuesttrackerContainerBonus:UpdateLayout(); GwQuesttrackerContainerCollection:UpdateLayout(); GwQuesttrackerContainerMonthlyActivity:UpdateLayout(); GwQuesttrackerContainerRecipe:UpdateLayout(); GwQuesttrackerContainerScenario:UpdateLayout(); GwQuestTracker:LayoutChanged() end, dependence = {["QUESTTRACKER_ENABLED"] = true}, hidden = not GW.Retail})
    p:AddOption(L["Show Quest XP in Quest Tracker"], nil, {getterSetter = "QUESTTRACKER_SHOW_XP", callback = function() GwQuesttrackerContainerQuests:UpdateLayout() end, dependence = {["QUESTTRACKER_ENABLED"] = true}, hidden = GW.Retail or GW.Mists})

    p:AddOptionDropdown(L["Quest Tracker Sorting"], nil, { getterSetter = "QUESTTRACKER_SORTING", callback = function() GwQuesttrackerContainerQuests:UpdateLayout() end, optionsList = {"DEFAULT", "LEVEL", "ZONE"}, optionNames = {DEFAULT, GUILD_RECRUITMENT_LEVEL, ZONE .. L[" |cFF888888(required Questie)|r"]}, dependence = {["QUESTTRACKER_ENABLED"] = true}, hidden = GW.Retail})

    sWindow:AddSettingsPanel(p, OBJECTIVES_TRACKER_LABEL, L["Edit objectives settings."])
end
GW.LoadObjectivesPanel = LoadObjectivesPanel
