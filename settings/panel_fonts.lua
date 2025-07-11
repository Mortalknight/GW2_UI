local _, GW = ...
local L = GW.L
local addOptionDropdown = GW.AddOptionDropdown
local addGroupHeader = GW.AddGroupHeader
local addOptionSlider = GW.AddOptionSlider
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel

local function LoadFontsPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p.header:SetText(L["Fonts"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit font settings."])

    createCat(L["Fonts"], nil, p, {p}, true)

    local fontsKeys = {}
    local fontsValues = {}
    tinsert(fontsKeys, "NONE")
    tinsert(fontsValues, L["Use GW2 Text Style Template"])
    for _, font in next, GW.Libs.LSM:List("font") do
        tinsert(fontsKeys, font)
        tinsert(fontsValues, font)
    end

    addOptionDropdown(p.scroll.scrollchild, L["Text Style Templates"], L["Choose from predefined options to customize fonts and text styles, adjusting the appearance of your text."], { getterSetter = "FONT_STYLE_TEMPLATE", callback = function() -- Im adding this inline for now
            if GW.settings.FONT_STYLE_TEMPLATE == "GW2_LEGACY" then
                GW.settings["FONTS_BIG_HEADER_SIZE"] = 16
                GW.settings["FONTS_HEADER_SIZE"] = 14
                GW.settings["FONTS_NORMAL_SIZE"] = 12
                GW.settings["FONTS_SMALL_SIZE"] = 11
                GW.settings["FONTS_OUTLINE"] = ""
                GW.settings["FONT_NORMAL"] = "Interface/AddOns/GW2_UI/fonts/menomonia_old.ttf"
                GW.settings["FONT_HEADERS"] = "Interface/AddOns/GW2_UI/fonts/headlines_old.ttf"
            elseif GW.settings.FONT_STYLE_TEMPLATE == "BLIZZARD" then
                GW.settings["FONTS_BIG_HEADER_SIZE"] = 16
                GW.settings["FONTS_HEADER_SIZE"] = 14
                GW.settings["FONTS_NORMAL_SIZE"] = 12
                GW.settings["FONTS_SMALL_SIZE"] = 11
                GW.settings["FONTS_OUTLINE"] = ""
                GW.settings["FONT_NORMAL"] = ""
                GW.settings["FONT_HEADERS"] = ""
            elseif GW.settings.FONT_STYLE_TEMPLATE == "HIGH_CONTRAST" then
                GW.settings["FONTS_BIG_HEADER_SIZE"] = 18
                GW.settings["FONTS_HEADER_SIZE"] = 16
                GW.settings["FONTS_NORMAL_SIZE"] = 14
                GW.settings["FONTS_SMALL_SIZE"] = 12
                GW.settings["FONTS_OUTLINE"] = "OUTLINE"
                GW.settings["FONT_NORMAL"] = "Interface/AddOns/GW2_UI/fonts/menomonia.ttf"
                GW.settings["FONT_HEADERS"] = ""
            else -- "GW2" standard
                GW.settings["FONTS_BIG_HEADER_SIZE"] = 18
                GW.settings["FONTS_HEADER_SIZE"] = 16
                GW.settings["FONTS_NORMAL_SIZE"] = 14
                GW.settings["FONTS_SMALL_SIZE"] = 12
                GW.settings["FONTS_OUTLINE"] = ""
                GW.settings["FONT_NORMAL"] = "Interface/AddOns/GW2_UI/fonts/menomonia.ttf"
                GW.settings["FONT_HEADERS"] = ""
            end
            GW.settings.CUSTOM_FONT_NORMAL = "NONE"
            GW.settings.CUSTOM_FONT_HEADER = "NONE"
            GW.updateSettingsFrameSettingsValue("FONTS_BIG_HEADER_SIZE", GW.settings["FONTS_BIG_HEADER_SIZE"], false)
            GW.updateSettingsFrameSettingsValue("FONTS_HEADER_SIZE", GW.settings["FONTS_HEADER_SIZE"], false)
            GW.updateSettingsFrameSettingsValue("FONTS_NORMAL_SIZE", GW.settings["FONTS_NORMAL_SIZE"], false)
            GW.updateSettingsFrameSettingsValue("FONTS_SMALL_SIZE", GW.settings["FONTS_SMALL_SIZE"], false)

            GW.ShowRlPopup = true -- triggers reload window
        end, optionsList = {"GW2", "GW2_LEGACY", "BLIZZARD", "HIGH_CONTRAST"}, optionNames = {"GW 2", "GW 2 Legacy", "Blizzard", "Hight Contrast"}, dependence = {["CUSTOM_FONT_NORMAL"] = {"NONE"},["CUSTOM_FONT_HEADER"] = {"NONE"}}})

    addGroupHeader(p.scroll.scrollchild, L["Custom Font Settings"])

    addOptionDropdown(p.scroll.scrollchild, L["Header Font"], nil, { getterSetter = "CUSTOM_FONT_HEADER", callback = function() GW.ShowRlPopup = true end, optionsList = fontsKeys, optionNames = fontsValues})
    addOptionDropdown(p.scroll.scrollchild, L["Fonts"], nil, { getterSetter = "CUSTOM_FONT_NORMAL", callback = function() GW.ShowRlPopup = true end, optionsList = fontsKeys, optionNames = fontsValues})
    addOptionSlider(p.scroll.scrollchild, L["Big Headers"], nil, { getterSetter = "FONTS_BIG_HEADER_SIZE", callback = GW.UpdateFontSettings, min = 5, max = 42, decimalNumbers = 0, step = 1})
    addOptionSlider(p.scroll.scrollchild, L["Headers"], nil, { getterSetter = "FONTS_HEADER_SIZE", callback = GW.UpdateFontSettings, min = 5, max = 42, decimalNumbers = 0, step = 1})
    addOptionSlider(p.scroll.scrollchild, L["Normal text"], nil, { getterSetter = "FONTS_NORMAL_SIZE", callback = GW.UpdateFontSettings, min = 5, max = 42, decimalNumbers = 0, step = 1})
    addOptionSlider(p.scroll.scrollchild, L["Small text"], nil, { getterSetter = "FONTS_SMALL_SIZE", callback = GW.UpdateFontSettings, min = 5, max = 42, decimalNumbers = 0, step = 1})

    InitPanel(p, true)
end
GW.LoadFontsPanel = LoadFontsPanel
