---@class GW2
local GW = select(2, ...)
local L = GW.L

local HIGHEST_CLASS_ID = 13 -- api does not work in none retail clients

local function LoadGeneralPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")

    local general = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    general.panelId = "general_general"
    general.header:SetFont(DAMAGE_TEXT_FONT, 20)
    general.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    general.header:SetText(GENERAL)
    general.sub:SetFont(UNIT_NAME_FONT, 12)
    general.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    general.sub:SetText(L["Edit general interface settings."])
    general.header:SetWidth(general.header:GetStringWidth())
    general.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    general.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    general.breadcrumb:SetText(GENERAL)

    local classcolors = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    classcolors.panelId = "general_classcolors"
    classcolors.header:SetFont(DAMAGE_TEXT_FONT, 20)
    classcolors.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    classcolors.header:SetText(GENERAL)
    classcolors.sub:SetFont(UNIT_NAME_FONT, 12)
    classcolors.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    classcolors.sub:SetText(L["Define your own class colors."])
    classcolors.header:SetWidth(classcolors.header:GetStringWidth())
    classcolors.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    classcolors.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    classcolors.breadcrumb:SetText(L["Custom Class Colors"])

    local blizzardFix = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    blizzardFix.panelId = "general_blizzardfix"
    blizzardFix.header:SetFont(DAMAGE_TEXT_FONT, 20)
    blizzardFix.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    blizzardFix.header:SetText(GENERAL)
    blizzardFix.sub:SetFont(UNIT_NAME_FONT, 12)
    blizzardFix.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    blizzardFix.sub:SetText(L["Toggle fixes for known Blizzard interface issues."])
    blizzardFix.header:SetWidth(blizzardFix.header:GetStringWidth())
    blizzardFix.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    blizzardFix.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    blizzardFix.breadcrumb:SetText(L["Blizzard Fixes"])

    general:AddOptionSlider(L["Shorten values decimal length"], L["Controls the amount of decimals used for shorted values"], { getterSetter = "unitframes.shortValueDecimals", callback = GW.BuildPrefixValues, min = 0, max = GW.Retail and 3 or 4, decimalNumbers = 0, step = 1})
    general:AddOptionDropdown(L["Shorten value prefix style"], nil, { getterSetter = "unitframes.shortValuePrefixStyle", callback = GW.BuildPrefixValues, optionsList = {"TCHINESE", "CHINESE", "ENGLISH", "GERMAN", "KOREAN", "METRIC"}, optionNames = {"萬, 億", "万, 亿", "K, M, B, T", "Tsd, Mio, Mrd, Bio", "천, 만, 억", "k, M, G, T"}})
    general:AddOptionDropdown(L["Number format"], L["Will be used for the most numbers"] .. (GW.Retail and L[" For Retail: Not used for secret numbers."] or ""), { getterSetter = "general.numberFormat", optionsList = {"POINT", "COMMA"}, optionNames = {"1,000,000.00", "1.000.000,00"}})
    general:AddOption(L["AFK Mode"], L["When you go AFK, display the AFK screen."], {getterSetter = "general.afkMode", callback = GW.ToggelAfkMode})
    general:AddOption(GW.NewSign .. L["Show Lua errors"], L["Shows Blizzard's error window for every Lua error and the GW2 error icon in the micro menu."] .. (BugGrabber and ("\n\n" .. L["BugSack is loaded and collects the errors anyway."]) or ""), {
        getter = function() return C_CVar.GetCVarBool("scriptErrors") end,
        setter = function(value) C_CVar.SetCVar("scriptErrors", value and "1" or "0") end,
        getDefault = function() return false end,
    })
    general:AddOption(GW.NewSign .. L["Hide error messages in combat"], L["Hides messages like 'Not enough rage' while in combat."], {getterSetter = "general.hideErrorsInCombat"})
    general:AddOption(CAMERA_FOLLOWING_STYLE .. ": " .. DYNAMIC, nil, {getterSetter = "general.dynamicCam",
        callback = function(value)
            C_CVar.SetCVar("test_cameraDynamicPitch", value and "1" or "0")
            C_CVar.SetCVar("cameraKeepCharacterCentered", value and "0" or "1")
            C_CVar.SetCVar("cameraReduceUnexpectedMovement", value and "0" or "1")
        end, incompatibleAddons = "DynamicCam"})

    general:AddOptionSlider(L["Extended Vendor"], L["The number of pages shown in the merchant frame. Set 1 to disable."], { getterSetter = "bags.extendedVendorPages", callback = function() GW.ShowRlPopup = true end, min = 1, max = 6, decimalNumbers = 0, step = 1})

    general:AddGroupHeader(L["Automation"])
    general:AddOptionDropdown(L["Auto Repair"], L["Automatically repair using the following method when visiting a merchant."], { getterSetter = "general.autoRepair", optionsList = {"NONE", "PLAYER", "GUILD"}, optionNames = {NONE_KEY, PLAYER, GUILD}})
    general:AddOption(L["Sell junk automatically"], L["Automatically sell poor quality items when visiting a merchant."], {getterSetter = "bags.vendorGrays", callback = GW.SetupVendorJunk})
    general:AddOption(GW.NewSign .. L["Accept group invites"], L["Accepts group invites from friends and guild members, not while you are queued."], {getterSetter = "general.autoAcceptInvite"})
    general:AddOption(GW.NewSign .. L["Set role from specialization"], L["Sets your group role to the role of your current specialization."], {getterSetter = "general.autoSetRole"})
    general:AddOption(GW.NewSign .. L["Track reputation automatically"], L["Watches the faction you just gained reputation with."], {getterSetter = "general.autoTrackReputation"})
    general:AddOption(GW.NewSign .. L["Fill in delete confirmation"], L["Fills in the confirmation word when deleting a valuable item."], {getterSetter = "general.autoFillDelete"})
    general:AddOption(GW.NewSign .. L["Fast loot"], L["Loots all items at once when auto loot is active."], {getterSetter = "general.fastLoot"})
    general:AddOption(GW.NewSign .. L["Release in battlegrounds"], L["Releases your spirit when you die in a battleground, not while a soulstone or similar is waiting."], {getterSetter = "general.autoReleasePvP"})
    general:AddOption(GW.NewSign .. L["Train all button"], L["Adds a button to trainers that learns everything you can afford."], {getterSetter = "general.trainAllButton", callback = function() GW.ShowRlPopup = true end})

    general:AddGroupHeader(L["Scale"])
    general:AddOption(L["Pixel Perfect Mode"], L["Scales the UI into a Pixel Perfect Mode. This is dependent on screen resolution."], {getterSetter = "general.pixelPerfection", callback = function() C_CVar.SetCVar("useUiScale", "0") GW.PixelPerfection() end})
    general:AddOptionSlider(L["HUD Scale"], L["Change the HUD size."], { getterSetter = "hud.scale", callback = function() GW.UpdateHudScale(); GW.ShowRlPopup = true end, isPercent = true, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01})
    general:AddOptionButton(L["Apply to all"], L["Applies the UI scale to all frames which can be scaled in 'Move HUD' mode."], {callback =
        function()
            local scale = GW.settings.hud.scale
            for _, mf in pairs(GW.scaleableFrames) do
                mf.parent:SetScale(scale)
                mf:SetScale(scale)
                GW.GetSetting(mf.setting).scale = scale
            end
        end})

    classcolors:AddOption(L["Blizzard Class Colors"], nil, {getterSetter = "general.blizzardClassColors", callback = function(value)
        for i = 1, HIGHEST_CLASS_ID do
            local classInfo = C_CreatureInfo.GetClassInfo(i)
            if classInfo then
                local settingsButton = GW.FindSettingsWidgetByOption("Gw2ClassColor." .. classInfo.classFile)
                local color = value == true and RAID_CLASS_COLORS[classInfo.classFile] or settingsButton.getDefault()

                settingsButton.button.bg:SetColorTexture(color.r,  color.g,  color.b)
                GW.UpdateGw2ClassColor(classInfo.classFile, color.r, color.g, color.b, true)
            end
        end
    end, groupHeaderName = L["Custom Class Colors"]})

    for i = 1, HIGHEST_CLASS_ID do
        local classInfo = C_CreatureInfo.GetClassInfo(i)
        if classInfo then
            classcolors:AddOptionColorPicker(classInfo.className, nil, {getterSetter = "Gw2ClassColor." .. classInfo.classFile, callback = function(r, g, b, changed) GW.UpdateGw2ClassColor(classInfo.classFile, r, g, b, changed) end, groupHeaderName = L["Custom Class Colors"], dependence = {["general.blizzardClassColors"] = false}, isPrivateSetting = true})
        end
    end

    -- blizzard fixes
    blizzardFix:AddOption(GUILD_NEWS, L["This will fix the current Guild News jam."], {getterSetter = "general.fixGuildNewsSpam", callback = function() GW:FixBlizzardIssues() end})

    sWindow:AddSettingsPanel(p, GENERAL, L["Edit general interface settings."], {{name = GENERAL, frame = general}, {name = L["Custom Class Colors"], frame = classcolors}, {name = L["Blizzard Fixes"], frame = blizzardFix}})
end
GW.LoadGeneralPanel = LoadGeneralPanel
