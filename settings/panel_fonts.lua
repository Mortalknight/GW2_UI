local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local addGroupHeader = GW.AddGroupHeader
local addOptionSlider = GW.AddOptionSlider
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local settingsMenuAddButton = GW.settingsMenuAddButton;



local function LoadFontsPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(L["Fonts"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit font settings."])

    createCat(L["Fonts"], nil, p, {p})
    settingsMenuAddButton(L["Fonts"], p, {})
   
    local fonts = {}
    for _, font in next, GW.Libs.LSM:List("font") do
        tinsert(fonts, font)
    end

    print(GW.settings["FONT_STYLE_TEMPLATE"],
            GW.settings["FONTS_BIG_HEADER_SIZE"],
            GW.settings["FONTS_HEADER_SIZE"],
            GW.settings["FONTS_NORMAL_SIZE"],
            GW.settings["FONTS_SMALL_SIZE"],
            GW.settings["FONTS_OUTLINE"] ,
            GW.settings["FONT_NORMAL"]) 
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Text Style Templates"],
        L["Choose from predefined options to customize fonts and text styles, adjusting the appearance of your text."],
        "FONT_STYLE_TEMPLATE",
        function() -- Im adding this inline for now
    
            if GW.settings.FONT_STYLE_TEMPLATE == "GW2_LEGACY" then 
                GW.settings["FONTS_BIG_HEADER_SIZE"] = 16
                GW.settings["FONTS_HEADER_SIZE"] = 14
                GW.settings["FONTS_NORMAL_SIZE"] = 12
                GW.settings["FONTS_SMALL_SIZE"] = 11
                GW.settings["FONTS_OUTLINE"] =  nil
                GW.settings["FONT_NORMAL"] = "Interface/AddOns/GW2_UI/fonts/menomonia_old.ttf"

            elseif GW.settings.FONT_STYLE_TEMPLATE == "BLIZZARD" then
                GW.settings["FONTS_BIG_HEADER_SIZE"] = 16
                GW.settings["FONTS_HEADER_SIZE"] = 14
                GW.settings["FONTS_NORMAL_SIZE"] = 12
                GW.settings["FONTS_SMALL_SIZE"] = 11
                GW.settings["FONTS_OUTLINE"] =  nil
                GW.settings["FONT_NORMAL"] = ""
                

            elseif GW.settings.FONT_STYLE_TEMPLATE == "HIGH_CONTRAST" then

                GW.settings["FONTS_BIG_HEADER_SIZE"] = 18
                GW.settings["FONTS_HEADER_SIZE"] = 16
                GW.settings["FONTS_NORMAL_SIZE"] = 14
                GW.settings["FONTS_SMALL_SIZE"] = 12
                GW.settings["FONTS_OUTLINE"] =  "OUTLINE"
                GW.settings["FONT_NORMAL"] = "Interface/AddOns/GW2_UI/fonts/menomonia.ttf"

            else -- "GW2" standard
                GW.settings["FONTS_BIG_HEADER_SIZE"] = 18
                GW.settings["FONTS_HEADER_SIZE"] = 16
                GW.settings["FONTS_NORMAL_SIZE"] = 14
                GW.settings["FONTS_SMALL_SIZE"] = 12
                GW.settings["FONTS_OUTLINE"] =  nil
                GW.settings["FONT_NORMAL"] = "Interface/AddOns/GW2_UI/fonts/menomonia.ttf"
            end
            GW.settings.CUSTOM_FONT_NORMAL = false
            GW.updateSettingsFrameSettingsValue("FONTS_BIG_HEADER_SIZE", GW.settings["FONTS_BIG_HEADER_SIZE"],false)
            GW.updateSettingsFrameSettingsValue("FONTS_HEADER_SIZE", GW.settings["FONTS_HEADER_SIZE"],false)
            GW.updateSettingsFrameSettingsValue("FONTS_NORMAL_SIZE", GW.settings["FONTS_NORMAL_SIZE"],false)
            GW.updateSettingsFrameSettingsValue("FONTS_SMALL_SIZE", GW.settings["FONTS_SMALL_SIZE"],false)

            print(GW.settings["FONT_STYLE_TEMPLATE"],
            GW.settings["FONTS_BIG_HEADER_SIZE"],
            GW.settings["FONTS_HEADER_SIZE"],
            GW.settings["FONTS_NORMAL_SIZE"],
            GW.settings["FONTS_SMALL_SIZE"],
            GW.settings["FONTS_OUTLINE"] ,
            GW.settings["FONT_NORMAL"]) 
            
         end,
        {"GW2", "GW2_LEGACY","BLIZZARD","HIGH_CONTRAST"},
        {
            "GW 2",
            "GW 2 Legacy",
            "Blizzard",
            "Hight Contrast",
        }
    )

    addGroupHeader(p.scroll.scrollchild,  L["Custom Font Settings"])

    addOptionDropdown(
        p.scroll.scrollchild,
        L["Fonts"],
        nil,
        "CUSTOM_FONT_NORMAL",
        function()
           
        end,
        fonts,
        fonts,
        nil,
        nil,
        nil,
        nil,
        nil,
        false
    )
    addOptionSlider(
        p.scroll.scrollchild,
        L["Big Headers"],
        nil,
        "FONTS_BIG_HEADER_SIZE",
        nil,
        5,
        42,
        nil,
        0,
        nil,
        1
    )
    addOptionSlider(
        p.scroll.scrollchild,
        L["Headers"],
        nil,
        "FONTS_HEADER_SIZE",
        nil,
        5,
        42,
        nil,
        0,
        nil,
        1
    )
    addOptionSlider(
        p.scroll.scrollchild,
        L["Normal"],
        nil,
        "FONTS_NORMAL_SIZE",
        nil,
        5,
        42,
        nil,
        0,
        nil,
        1
    )
    addOptionSlider(
        p.scroll.scrollchild,
        L["Small"],
        nil,
        "FONTS_SMALL_SIZE",
        nil,
        5,
        42,
        nil,
        0,
        nil,
        1
    )


    InitPanel(p, true)
end
GW.LoadFontsPanel = LoadFontsPanel
