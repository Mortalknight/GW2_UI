local _, GW = ...

local function LoadDetailsProfile()
    if not GW.GetSetting("DETAILS_SKIN_ENABLED") then return end
    local details = _G.Details

    if not details then return end

    local instance = details:GetInstance(1)

    for _, profile in ipairs(instance:GetProfileList()) do
        if profile == "GW2_UI" then
            return
        end
    end

    instance:CreateProfile("GW2_UI")
    instance:ApplyProfile("GW2_UI")
    instance:HideMainIcon(true)
    instance:SetAutoHideMenu(true)
    instance:AttributeMenu(true, -12, 2, "GW2_UI Headlines", 13, {1, 1, 1, 1}, 1, false)
    instance:MenuAnchor(4, 1)
    instance.toolbar_icon_file = "Interface/AddOns/GW2_UI/textures/addonSkins/detailsToolbar"
    instance:ToolbarMenuSetButtons(true, true, true, true, true, false)
    instance:ToolbarMenuSetButtonsOptions(1, false)
    instance:ToolbarMenuButtonsSize(1.1)
    instance:SetBarSpecIconSettings(false)
    instance:SetBarSettings(21, "GW2_UI_Details", true, {0, 0, 0, 0}, "GW2_UI", false, {0, 0, 0, 0.45}, 1, "Interface/AddOns/GW2_UI/textures/addonSkins/detailsClassIcons", false, 0)
    instance:SetBarTextSettings(12, "GW2_UI", {1, 1, 1, 1}, false, false, false, false, false, nil, 1, true, false, nil, true, {0, 0, 0, 1}, true, {0, 0, 0, 1})
    instance:InstanceColor(0, 0, 0, 0, nil, true)
    instance:SetBackgroundColor(0, 0, 0)
    instance:SetBackgroundAlpha(0)
end
GW.LoadDetailsProfile = LoadDetailsProfile