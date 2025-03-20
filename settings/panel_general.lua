local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local settingsMenuAddButton = GW.settingsMenuAddButton
local addOptionSlider = GW.AddOptionSlider
local addOptionDropdown = GW.AddOptionDropdown
local addGroupHeader = GW.AddGroupHeader
local addOptionColorPicker = GW.AddOptionColorPicker

local function LoadGeneralPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.header:Hide()
    p.sub:Hide()

    local general = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
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

    local classcolors = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    classcolors.header:SetFont(DAMAGE_TEXT_FONT, 20)
    classcolors.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    classcolors.header:SetText(L["Custom Class Colors"])
    classcolors.sub:SetFont(UNIT_NAME_FONT, 12)
    classcolors.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    classcolors.sub:SetText(nil)
    classcolors.header:SetWidth(classcolors.header:GetStringWidth())
    classcolors.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    classcolors.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    classcolors.breadcrumb:SetText(L["Custom Class Colors"])

    local blizzardFix = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    blizzardFix.header:SetFont(DAMAGE_TEXT_FONT, 20)
    blizzardFix.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    blizzardFix.header:SetText(L["Blizzard Fixes"])
    blizzardFix.sub:SetFont(UNIT_NAME_FONT, 12)
    blizzardFix.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    blizzardFix.sub:SetText(nil)
    blizzardFix.header:SetWidth(classcolors.header:GetStringWidth())
    blizzardFix.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    blizzardFix.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    blizzardFix.breadcrumb:SetText(L["Blizzard Fixes"])

    createCat(GENERAL, nil, p, {general, classcolors, blizzardFix})
    settingsMenuAddButton(GENERAL, p, {general, classcolors, blizzardFix})

    addOptionSlider(
        general.scroll.scrollchild,
        GW.NewSign .. L["Shorten values decimal length"],
        L["Controls the amount of decimals used for shorted values"],
        "ShortHealthValuesDecimalLength",
        GW.BuildPrefixValues,
        0,
        4,
        nil,
        0,
        nil,
        1
    )
    addOptionDropdown(
        general.scroll.scrollchild,
        GW.NewSign .. L["Shorten value prefix style"],
        nil,
        "ShortHealthValuePrefixStyle",
        GW.BuildPrefixValues,
        {"TCHINESE", "CHINESE", "ENGLISH", "GERMAN", "KOREAN", "METRIC"},
        {"萬, 億", "万, 亿", "K, M, B, T", "Tsd, Mio, Mrd, Bio", "천, 만, 억", "k, M, G, T"}
    )
    addOptionDropdown(
        general.scroll.scrollchild,
        GW.NewSign .. L["Number format"],
        L["Will be used for the most numbers"],
        "NumberFormat",
        nil,
        {"POINT", "COMMA"},
        {"1,000,000.00", "1.000.000,00"}
    )
    addOption(general.scroll.scrollchild, L["AFK Mode"], L["When you go AFK, display the AFK screen."], "AFK_MODE", GW.ToggelAfkMode)
    addOptionDropdown(
        general.scroll.scrollchild,
        L["Auto Repair"],
        L["Automatically repair using the following method when visiting a merchant."],
        "AUTO_REPAIR",
        nil,
        {"NONE", "PLAYER", "GUILD"},
        {
            NONE_KEY,
            PLAYER,
            GUILD,
        }
    )
    addOptionSlider(
        general.scroll.scrollchild,
        L["Extended Vendor"],
        L["The number of pages shown in the merchant frame. Set 1 to disable."],
        "EXTENDED_VENDOR_NUM_PAGES",
        function() GW.ShowRlPopup = true end,
        1,
        6,
        nil,
        0,
        nil,
        1
    )

    addOption(classcolors.scroll.scrollchild, L["Blizzard Class Colors"], nil, "BLIZZARDCLASSCOLOR_ENABLED", function(value)
        for i = 1, #CLASS_SORT_ORDER do
            local _, tag = GetClassInfo(i)
            local settingsButton = _G["Gw2ClassColor" .. tag]
            local color = value == true and RAID_CLASS_COLORS[tag] or GW.privateDefaults.profile.Gw2ClassColor[tag]

            settingsButton.getterSetter = {r = color.r, g = color.g, b = color.b, colorStr = nil}
            settingsButton.button.bg:SetColorTexture(color.r,  color.g,  color.b)
            GW.UpdateGw2ClassColor(tag, color.r, color.g, color.b, true)
        end
    end, nil, nil, nil, nil, L["Custom Class Colors"])

    for i = 1, #CLASS_SORT_ORDER do
        local name, tag = GetClassInfo(i)
        addOptionColorPicker(classcolors.scroll.scrollchild, name, nil, "Gw2ClassColor" .. tag, GW.private.Gw2ClassColor[tag], GW.privateDefaults.profile.Gw2ClassColor[tag], function(r, g, b, changed)
            GW.UpdateGw2ClassColor(tag, r, g, b, changed)
        end, nil, {["BLIZZARDCLASSCOLOR_ENABLED"] = false}, nil, nil, L["Custom Class Colors"])
    end

    -- blizzard fixes
    addOption(blizzardFix.scroll.scrollchild, GW.NewSign .. GUILD_NEWS, L["This will fix the current Guild News jam."], "FixGuildNewsSpam", GW.FixBlizzardIssues)
    addOption(blizzardFix.scroll.scrollchild, GW.NewSign .. L["CPU Profiling"], L["If enable it will disable the CPU Profiling CVar. Which can cause some performance issues and should not be enabled by default"], "forceDisableCPUProfiler", GW.FixBlizzardIssues)

    InitPanel(general, true)
    InitPanel(classcolors, true)
    InitPanel(blizzardFix, true)
end
GW.LoadGeneralPanel = LoadGeneralPanel
