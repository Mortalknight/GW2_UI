---@class GW2
local GW = select(2, ...)
local L = GW.L

-- Applies the derived font settings of the chosen FONT_STYLE_TEMPLATE; shared by the
-- settings dropdown and the installer font step
local function ApplyFontStyleTemplate()
    if GW.settings.fonts.styleTemplate == "GW2_LEGACY" then
        GW.settings.fonts.size.bigHeader = 16
        GW.settings.fonts.size.header = 14
        GW.settings.fonts.size.normal = 12
        GW.settings.fonts.size.small = 11
        GW.settings.fonts.outline = ""
        GW.settings.fonts.normal = "Interface/AddOns/GW2_UI/fonts/menomonia_old.ttf"
        GW.settings.fonts.headers = "Interface/AddOns/GW2_UI/fonts/headlines_old.ttf"
    elseif GW.settings.fonts.styleTemplate == "BLIZZARD" then
        GW.settings.fonts.size.bigHeader = 16
        GW.settings.fonts.size.header = 14
        GW.settings.fonts.size.normal = 12
        GW.settings.fonts.size.small = 11
        GW.settings.fonts.outline = ""
        GW.settings.fonts.normal = ""
        GW.settings.fonts.headers = ""
    elseif GW.settings.fonts.styleTemplate == "HIGH_CONTRAST" then
        GW.settings.fonts.size.bigHeader = 18
        GW.settings.fonts.size.header = 16
        GW.settings.fonts.size.normal = 14
        GW.settings.fonts.size.small = 12
        GW.settings.fonts.outline = "OUTLINE"
        GW.settings.fonts.normal = "Interface/AddOns/GW2_UI/fonts/menomonia.ttf"
        GW.settings.fonts.headers = ""
    else -- "GW2" standard
        GW.settings.fonts.size.bigHeader = 18
        GW.settings.fonts.size.header = 16
        GW.settings.fonts.size.normal = 14
        GW.settings.fonts.size.small = 12
        GW.settings.fonts.outline = ""
        GW.settings.fonts.normal = "Interface/AddOns/GW2_UI/fonts/menomonia.ttf"
        GW.settings.fonts.headers = ""
    end
    GW.settings.fonts.customNormal = "NONE"
    GW.settings.fonts.customHeader = "NONE"
    GW.updateSettingsFrameSettingsValue("fonts.size.bigHeader", GW.settings.fonts.size.bigHeader, false)
    GW.updateSettingsFrameSettingsValue("fonts.size.header", GW.settings.fonts.size.header, false)
    GW.updateSettingsFrameSettingsValue("fonts.size.normal", GW.settings.fonts.size.normal, false)
    GW.updateSettingsFrameSettingsValue("fonts.size.small", GW.settings.fonts.size.small, false)
end
GW.ApplyFontStyleTemplate = ApplyFontStyleTemplate
GW.FONT_STYLE_TEMPLATES = { "GW2", "GW2_LEGACY", "BLIZZARD", "HIGH_CONTRAST" }
GW.FONT_STYLE_TEMPLATE_NAMES = { "GW 2", "GW 2 Legacy", "Blizzard", "High Contrast" }

local function LoadFontsPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")
    p.panelId = "fonts_general"
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p.header:SetText(L["Fonts"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit font settings."])

    local fontsKeys = {}
    local fontsValues = {}
    tinsert(fontsKeys, "NONE")
    tinsert(fontsValues, L["Use GW2 Text Style Template"])
    for _, font in next, GW.Libs.LSM:List("font") do
        tinsert(fontsKeys, font)
        tinsert(fontsValues, font)
    end

    p:AddOptionDropdown(L["Text Style Templates"], L["Choose from predefined options to customize fonts and text styles, adjusting the appearance of your text."], { getterSetter = "fonts.styleTemplate", callback = function()
            ApplyFontStyleTemplate()
            GW.ShowRlPopup = true -- triggers reload window
        end, optionsList = GW.FONT_STYLE_TEMPLATES, optionNames = GW.FONT_STYLE_TEMPLATE_NAMES, dependence = {["fonts.customNormal"] = {"NONE"},["fonts.customHeader"] = {"NONE"}}})

    p:AddGroupHeader(L["Custom Font Settings"])

    p:AddOptionDropdown(L["Header Font"], nil, { getterSetter = "fonts.customHeader", callback = function() GW.ShowRlPopup = true end, optionsList = fontsKeys, optionNames = fontsValues})
    p:AddOptionDropdown(L["Fonts"], nil, { getterSetter = "fonts.customNormal", callback = function() GW.ShowRlPopup = true end, optionsList = fontsKeys, optionNames = fontsValues})
    p:AddOptionSlider(L["Big Headers"], nil, { getterSetter = "fonts.size.bigHeader", callback = GW.UpdateFontSettings, min = 5, max = 42, decimalNumbers = 0, step = 1})
    p:AddOptionSlider(L["Headers"], nil, { getterSetter = "fonts.size.header", callback = GW.UpdateFontSettings, min = 5, max = 42, decimalNumbers = 0, step = 1})
    p:AddOptionSlider(L["Normal text"], nil, { getterSetter = "fonts.size.normal", callback = GW.UpdateFontSettings, min = 5, max = 42, decimalNumbers = 0, step = 1})
    p:AddOptionSlider(L["Small text"], nil, { getterSetter = "fonts.size.small", callback = GW.UpdateFontSettings, min = 5, max = 42, decimalNumbers = 0, step = 1})

    sWindow:AddSettingsPanel(p, L["Fonts"], L["Edit font settings."])
end
GW.LoadFontsPanel = LoadFontsPanel
