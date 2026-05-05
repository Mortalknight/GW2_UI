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
    general.sub:SetText(nil)
    general.header:SetWidth(general.header:GetStringWidth())
    general.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    general.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    general.breadcrumb:SetText(GENERAL)

    local components = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    components.panelId = "general_components"
    components.header:SetFont(DAMAGE_TEXT_FONT, 20)
    components.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    components.header:SetText(GENERAL)
    components.sub:SetFont(UNIT_NAME_FONT, 12)
    components.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    components.sub:SetText(L["Enable and disable components"])
    components.header:SetWidth(components.header:GetStringWidth())
    components.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    components.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    components.breadcrumb:SetText(L["Components"])

    local uiWindows = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    uiWindows.panelId = "general_uiwindows"
    uiWindows.header:SetFont(DAMAGE_TEXT_FONT, 20)
    uiWindows.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    uiWindows.header:SetText(GENERAL)
    uiWindows.sub:SetFont(UNIT_NAME_FONT, 12)
    uiWindows.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    uiWindows.sub:SetText(L["Enable or disable UI window replacements."])
    uiWindows.header:SetWidth(uiWindows.header:GetStringWidth())
    uiWindows.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    uiWindows.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    uiWindows.breadcrumb:SetText(L["UI Windows"])

    local classcolors = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    classcolors.panelId = "general_classcolors"
    classcolors.header:SetFont(DAMAGE_TEXT_FONT, 20)
    classcolors.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    classcolors.header:SetText(GENERAL)
    classcolors.sub:SetFont(UNIT_NAME_FONT, 12)
    classcolors.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    classcolors.sub:SetText(nil)
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
    blizzardFix.sub:SetText(nil)
    blizzardFix.header:SetWidth(blizzardFix.header:GetStringWidth())
    blizzardFix.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    blizzardFix.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    blizzardFix.breadcrumb:SetText(L["Blizzard Fixes"])

    general:AddOption(CAMERA_FOLLOWING_STYLE .. ": " .. DYNAMIC, nil, {getterSetter = "DYNAMIC_CAM",
        callback = function(value)
            C_CVar.SetCVar("test_cameraDynamicPitch", value and "1" or "0")
            C_CVar.SetCVar("cameraKeepCharacterCentered", value and "0" or "1")
            C_CVar.SetCVar("cameraReduceUnexpectedMovement", value and "0" or "1")
        end, incompatibleAddons = "DynamicCam", isMasterToggle = true})
    general:AddOptionSlider(L["Shorten values decimal length"], L["Controls the amount of decimals used for shorted values"], { getterSetter = "ShortHealthValuesDecimalLength", callback = GW.BuildPrefixValues, min = 0, max = 4, decimalNumbers = 0, step = 1, hidden = true})
    general:AddOptionDropdown(L["Shorten value prefix style"], nil, { getterSetter = "ShortHealthValuePrefixStyle", callback = GW.BuildPrefixValues, optionsList = {"TCHINESE", "CHINESE", "ENGLISH", "GERMAN", "KOREAN", "METRIC"}, optionNames = {"萬, 億", "万, 亿", "K, M, B, T", "Tsd, Mio, Mrd, Bio", "천, 만, 억", "k, M, G, T"}, hidden = true})
    general:AddOptionDropdown(L["Number format"], L["Will be used for the most numbers"] .. (GW.Retail and L[" For Retail: Not used for secret numbers."] or ""), { getterSetter = "NumberFormat", optionsList = {"POINT", "COMMA"}, optionNames = {"1,000,000.00", "1.000.000,00"}})
    general:AddOption(L["AFK Mode"], L["When you go AFK, display the AFK screen."], {getterSetter = "AFK_MODE", callback = GW.ToggelAfkMode})
    general:AddOptionDropdown(L["Auto Repair"], L["Automatically repair using the following method when visiting a merchant."], { getterSetter = "AUTO_REPAIR", optionsList = {"NONE", "PLAYER", "GUILD"}, optionNames = {NONE_KEY, PLAYER, GUILD}})
    general:AddOption(L["Sell junk automatically"], L["Automatically sell poor quality items when visiting a merchant."], {getterSetter = "BAG_VENDOR_GRAYS", callback = GW.SetupVendorJunk})
    general:AddOptionSlider(L["Extended Vendor"], L["The number of pages shown in the merchant frame. Set 1 to disable."], { getterSetter = "EXTENDED_VENDOR_NUM_PAGES", callback = function() GW.ShowRlPopup = true end, min = 1, max = 6, decimalNumbers = 0, step = 1})

    components:AddOption(INVENTORY_TOOLTIP, L["Enable the unified inventory interface."], {getterSetter = "BAGS_ENABLED", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "Inventory", isMasterToggle = true})
    components:AddOption(BATTLEGROUND, nil, {getterSetter = "USE_BATTLEGROUND_HUD", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail, isMasterToggle = true})
   

    uiWindows:AddOption(BINDING_NAME_TOGGLECHARACTER0, L["Replace the default character window."], {getterSetter = "USE_CHARACTER_WINDOW", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    uiWindows:AddOption(L["Show character item info"], L["Display gems and enchants on the GW2 character panel"], {getterSetter = "SHOW_CHARACTER_ITEM_INFO", callback = function() if not (GW.Classic or GW.TBC or GW.Wrath) then GW.ToggleCharacterItemInfo() end end, dependence = {["USE_CHARACTER_WINDOW"] = true}})
    uiWindows:AddOption(TALENTS, L["Enable the talents, specialization, and spellbook replacement."], {getterSetter = "USE_TALENT_WINDOW", callback = function() GW.ShowRlPopup = true end, hidden = GW.Retail, isMasterToggle = true})
    uiWindows:AddOption(SPELLBOOK_ABILITIES_BUTTON, nil, {getterSetter = "USE_SPELLBOOK_WINDOW", callback = function() GW.ShowRlPopup = true end, hidden = GW.Retail, isMasterToggle = true})
    uiWindows:AddOption(TRADE_SKILLS, L["Enable the profession replacement."], {getterSetter = "USE_PROFESSION_WINDOW", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail, isMasterToggle = true})
    uiWindows:AddOption(FRIENDS, nil, {getterSetter = "USE_SOCIAL_WINDOW", callback = function() GW.ShowRlPopup = true end, hidden = not (GW.Retail or GW.TBC), isMasterToggle = true})

    classcolors:AddOption(L["Blizzard Class Colors"], nil, {getterSetter = "BLIZZARDCLASSCOLOR_ENABLED", callback = function(value)
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
            classcolors:AddOptionColorPicker(classInfo.className, nil, {getterSetter = "Gw2ClassColor." .. classInfo.classFile, callback = function(r, g, b, changed) GW.UpdateGw2ClassColor(classInfo.classFile, r, g, b, changed) end, groupHeaderName = L["Custom Class Colors"], dependence = {["BLIZZARDCLASSCOLOR_ENABLED"] = false}, isPrivateSetting = true})
        end
    end

    -- blizzard fixes
    blizzardFix:AddOption(GUILD_NEWS, L["This will fix the current Guild News jam."], {getterSetter = "FixGuildNewsSpam", callback = function() GW:FixBlizzardIssues() end})

    sWindow:AddSettingsPanel(p, GENERAL, nil, {{name = GENERAL, frame = general}, {name = L["UI Windows"], frame = uiWindows}, {name = L["Components"], frame = components}, {name = L["Custom Class Colors"], frame = classcolors}, {name = L["Blizzard Fixes"], frame = blizzardFix}})
end
GW.LoadGeneralPanel = LoadGeneralPanel
