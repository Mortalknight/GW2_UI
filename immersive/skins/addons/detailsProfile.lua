local _, GW = ...

local function LoadDetailsProfile()
    if not GW.GetSetting("DETAILS_SKIN_ENABLED") then return end
    local details = _G.Details

    if not details then return end

    local instance = details:GetInstance(1)

    local profile = instance:GetProfile("GW2_UI")

    if profile then return end

    local gw2Profile = instance:CreateProfile("GW2_UI")
    --instance:ApplyProfile("GW2_UI")
    gw2Profile:HideMainIcon(true)
    gw2Profile:SetAutoHideMenu(true)
    gw2Profile:AttributeMenu(true, -12, 2, "GW2_UI Headlines", 13, {1, 1, 1, 1}, 1, false)
    gw2Profile:MenuAnchor(4, 1)
    gw2Profile.toolbar_icon_file = "Interface/AddOns/GW2_UI/textures/addonSkins/detailsToolbar"
    gw2Profile:ToolbarMenuSetButtons(true, true, true, true, true, false)
    gw2Profile:ToolbarMenuSetButtonsOptions(1, false)
    gw2Profile:ToolbarMenuButtonsSize(1.1)
    gw2Profile:SetBarSpecIconSettings(false)
    gw2Profile:SetBarSettings(21, "GW2_UI_Details", true, {0, 0, 0, 0}, "GW2_UI", false, {0, 0, 0, 0.45}, 1, "Interface/AddOns/GW2_UI/textures/addonSkins/detailsClassIcons", false, 0)
    gw2Profile:SetBarTextSettings(12, "GW2_UI", {1, 1, 1, 1}, false, false, false, false, false, nil, 1, true, false, nil, true, {0, 0, 0, 1}, true, {0, 0, 0, 1})
    gw2Profile:InstanceColor(0, 0, 0, 0, nil, true)
    gw2Profile:SetBackgroundColor(0, 0, 0)
    gw2Profile:SetBackgroundAlpha(0)
end
GW.LoadDetailsProfile = LoadDetailsProfile