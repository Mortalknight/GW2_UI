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

    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p.header:SetText(GENERAL)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(nil)

    createCat(GENERAL, nil, p, {p})
    settingsMenuAddButton(GENERAL, p, {})

    addOptionSlider(
        p.scroll.scrollchild,
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
        p.scroll.scrollchild,
        GW.NewSign .. L["Shorten value prefix style"],
        nil,
        "ShortHealthValuePrefixStyle",
        GW.BuildPrefixValues,
        {"TCHINESE", "CHINESE", "ENGLISH", "GERMAN", "KOREAN", "METRIC"},
        {"萬, 億", "万, 亿", "K, M, B, T", "Tsd, Mio, Mrd, Bio", "천, 만, 억", "k, M, G, T"}
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        GW.NewSign .. L["Number format"],
        L["Will be used for the most numbers"],
        "NumberFormat",
        nil,
        {"POINT", "COMMA"},
        {"1,000,000.00", "1.000.000,00"}
    )
    addOption(p.scroll.scrollchild, L["AFK Mode"], L["When you go AFK, display the AFK screen."], "AFK_MODE", GW.ToggelAfkMode)
    addOptionDropdown(
        p.scroll.scrollchild,
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
        p.scroll.scrollchild,
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

    addGroupHeader(p.scroll.scrollchild, L["Custom Class Colors"])
    addOption(p.scroll.scrollchild, L["Blizzard Class Colors"], nil, "BLIZZARDCLASSCOLOR_ENABLED", function(value)
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
        addOptionColorPicker(p.scroll.scrollchild, name, nil, "Gw2ClassColor" .. tag, GW.private.Gw2ClassColor[tag], GW.privateDefaults.profile.Gw2ClassColor[tag], function(r, g, b, changed)
            GW.UpdateGw2ClassColor(tag, r, g, b, changed)
        end, nil, {["BLIZZARDCLASSCOLOR_ENABLED"] = false}, nil, nil, L["Custom Class Colors"])
    end


    InitPanel(p, true)
end
GW.LoadGeneralPanel = LoadGeneralPanel
