local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
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

    createCat(OBJECTIVES_TRACKER_LABEL, nil, p, 3, nil, {p}, "Interface/AddOns/GW2_UI/textures/chat/bubble_up")
    settingsMenuAddButton(OBJECTIVES_TRACKER_LABEL, p, 3, nil, {})
    addOption(p.scroll.scrollchild, L["Collapse all objectives in M+"], nil, "OBJECTIVES_COLLAPSE_IN_M_PLUS", function() GW.UpdateChallengeModeObjectivesSettings(); GW.ToggleCollapseObjectivesInChallangeMode() end, nil, {["QUESTTRACKER_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Toggle Compass"], L["Enable or disable the quest tracker compass."], "SHOW_QUESTTRACKER_COMPASS", function() GW.UpdateObjectivesNotificationSettings(); GW.ShowRlPopup = true end, nil, {["QUESTTRACKER_ENABLED"] = true})

    InitPanel(p, true)
end
GW.LoadObjectivesPanel = LoadObjectivesPanel
