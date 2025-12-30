local _, GW = ...
local L = GW.L

local function LoadGeneralPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")

    local general = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    general.panelId = "general_general"
    general.header:SetFont(DAMAGE_TEXT_FONT, 20)
    general.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    general.header:SetText(GENERAL)
    general.sub:SetFont(UNIT_NAME_FONT, 12)
    general.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    general.sub:SetText(nil)
    general.header:SetWidth(general.header:GetStringWidth())
    general.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    general.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    general.breadcrumb:SetText(GENERAL)

    local classcolors = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    classcolors.panelId = "general_classcolors"
    classcolors.header:SetFont(DAMAGE_TEXT_FONT, 20)
    classcolors.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    classcolors.header:SetText(GENERAL)
    classcolors.sub:SetFont(UNIT_NAME_FONT, 12)
    classcolors.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    classcolors.sub:SetText(nil)
    classcolors.header:SetWidth(classcolors.header:GetStringWidth())
    classcolors.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    classcolors.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    classcolors.breadcrumb:SetText(L["Custom Class Colors"])

    local blizzardFix = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    blizzardFix.panelId = "general_blizzardfix"
    blizzardFix.header:SetFont(DAMAGE_TEXT_FONT, 20)
    blizzardFix.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    blizzardFix.header:SetText(GENERAL)
    blizzardFix.sub:SetFont(UNIT_NAME_FONT, 12)
    blizzardFix.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    blizzardFix.sub:SetText(nil)
    blizzardFix.header:SetWidth(blizzardFix.header:GetStringWidth())
    blizzardFix.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    blizzardFix.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    blizzardFix.breadcrumb:SetText(L["Blizzard Fixes"])

    general:AddOptionSlider(L["Shorten values decimal length"], L["Controls the amount of decimals used for shorted values"], { getterSetter = "ShortHealthValuesDecimalLength", callback = GW.BuildPrefixValues, min = 0, max = 4, decimalNumbers = 0, step = 1, hidden = true})
    general:AddOptionDropdown(L["Shorten value prefix style"], nil, { getterSetter = "ShortHealthValuePrefixStyle", callback = GW.BuildPrefixValues, optionsList = {"TCHINESE", "CHINESE", "ENGLISH", "GERMAN", "KOREAN", "METRIC"}, optionNames = {"萬, 億", "万, 亿", "K, M, B, T", "Tsd, Mio, Mrd, Bio", "천, 만, 억", "k, M, G, T"}, hidden = true})
    general:AddOptionDropdown(L["Number format"], L["Will be used for the most numbers"], { getterSetter = "NumberFormat", optionsList = {"POINT", "COMMA"}, optionNames = {"1,000,000.00", "1.000.000,00"}, hidden = GW.Retail})
    general:AddOption(L["AFK Mode"], L["When you go AFK, display the AFK screen."], {getterSetter = "AFK_MODE", callback = GW.ToggelAfkMode})
    general:AddOptionDropdown(L["Auto Repair"], L["Automatically repair using the following method when visiting a merchant."], { getterSetter = "AUTO_REPAIR", optionsList = {"NONE", "PLAYER", "GUILD"}, optionNames = {NONE_KEY, PLAYER, GUILD}})
    general:AddOptionSlider(L["Extended Vendor"], L["The number of pages shown in the merchant frame. Set 1 to disable."], { getterSetter = "EXTENDED_VENDOR_NUM_PAGES", callback = function() GW.ShowRlPopup = true end, min = 1, max = 6, decimalNumbers = 0, step = 1})

    classcolors:AddOption(L["Blizzard Class Colors"], nil, {getterSetter = "BLIZZARDCLASSCOLOR_ENABLED", callback = function(value)
        for i = 1, #CLASS_SORT_ORDER do
            local _, tag = GetClassInfo(i)
            local settingsButton = GW.FindSettingsWidgetByOption("Gw2ClassColor." .. tag)
            local color = value == true and RAID_CLASS_COLORS[tag] or settingsButton.getDefault()

            settingsButton.button.bg:SetColorTexture(color.r,  color.g,  color.b)
            GW.UpdateGw2ClassColor(tag, color.r, color.g, color.b, true)
        end
    end, groupHeaderName = L["Custom Class Colors"]})

    for i = 1, #CLASS_SORT_ORDER do
        local name, tag = GetClassInfo(i)
        classcolors:AddOptionColorPicker(name, nil, {getterSetter = "Gw2ClassColor." .. tag, callback = function(r, g, b, changed) GW.UpdateGw2ClassColor(tag, r, g, b, changed) end, groupHeaderName = L["Custom Class Colors"], dependence = {["BLIZZARDCLASSCOLOR_ENABLED"] = false}, isPrivateSetting = true})
    end

    -- blizzard fixes
    blizzardFix:AddOption(GUILD_NEWS, L["This will fix the current Guild News jam."], {getterSetter = "FixGuildNewsSpam", callback = function() GW:FixBlizzardIssues() end})

    sWindow:AddSettingsPanel(p, GENERAL, nil, {{name = GENERAL, frame = general}, {name = L["Custom Class Colors"], frame = classcolors}, {name = L["Blizzard Fixes"], frame = blizzardFix}})
end
GW.LoadGeneralPanel = LoadGeneralPanel
