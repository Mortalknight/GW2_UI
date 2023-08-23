local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionSlider = GW.AddOptionSlider
local addOptionDropdown = GW.AddOptionDropdown
local addOptionButton = GW.AddOptionButton
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local InitPanel = GW.InitPanel

local function LoadHudPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.scroll.scrollchild.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.scroll.scrollchild.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.scroll.scrollchild.header:SetText(UIOPTIONS_MENU)
    p.scroll.scrollchild.sub:SetFont(UNIT_NAME_FONT, 12)
    p.scroll.scrollchild.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.scroll.scrollchild.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])

    createCat(UIOPTIONS_MENU, L["Edit the HUD modules."], p, 3, nil, {p})

    addOption(p.scroll.scrollchild, L["Show HUD background"], L["The HUD background changes color in the following situations: In Combat, Not In Combat, In Water, Low HP, Ghost"], "HUD_BACKGROUND")
    addOption(p.scroll.scrollchild, L["Dynamic HUD"], L["Enable or disable the dynamically changing HUD background."], "HUD_SPELL_SWAP", nil, nil, {["HUD_BACKGROUND"] = true})
    addOption(p.scroll.scrollchild, L["AFK Mode"], L["When you go AFK display the AFK screen."], "AFK_MODE")
    addOption(p.scroll.scrollchild, L["Fade Chat"], L["Allow the chat to fade when not in use."], "CHATFRAME_FADE", nil, nil, {["CHATFRAME_ENABLED"] = true})
    addOptionSlider(
        p.scroll.scrollchild,
        L["Maximum lines of 'Copy Chat Frame'"],
        L["Set the maximum number of lines displayed in the Copy Chat Frame"],
        "CHAT_MAX_COPY_CHAT_LINES",
        nil,
        50,
        500,
        nil,
        0,
        {["CHATFRAME_ENABLED"] = true},
        1
    )
    addOption(p.scroll.scrollchild, L["Toggle Compass"], L["Enable or disable the quest tracker compass."], "SHOW_QUESTTRACKER_COMPASS", nil, nil, {["QUESTTRACKER_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Show Quest XP on Quest Tracker"], nil, "QUESTTRACKER_SHOW_XP", nil, nil, {["QUESTTRACKER_ENABLED"] = true})
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Quest Tracker sorting"],
        nil,
        "QUESTTRACKER_SORTING",
        function() GW.UpdateQuestTracker(GwQuesttrackerContainerQuests) end,
        {"DEFAULT", "LEVEL", "ZONE"},
        {DEFAULT, GUILD_RECRUITMENT_LEVEL, ZONE .. L[" |cFF888888(required Questie)|r"]},
        nil,
        {["QUESTTRACKER_ENABLED"] = true},
        nil
    )
    addOption(p.scroll.scrollchild, L["Advanced Casting Bar"], L["Enable or disable the advanced casting bar."], "CASTINGBAR_DATA", nil, nil, {["CASTINGBAR_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Fade Menu Bar"], L["The main menu icons will fade when you move your cursor away."], "FADE_MICROMENU")
    addOption(p.scroll.scrollchild, L["Auto Repair"], L["Automatically repair using the following method when visiting a merchant."], "AUTO_REPAIR")
    addOption(p.scroll.scrollchild, DISPLAY_BORDERS, nil, "BORDER_ENABLED")
    addOption(p.scroll.scrollchild, L["Show Coordinates on World Map"], L["Show Coordinates on World Map"], "WORLDMAP_COORDS_TOGGLE", nil, nil)
    addOption(p.scroll.scrollchild, L["Show FPS on minimap"], L["Show FPS on minimap"], "MINIMAP_FPS", nil, nil, {["MINIMAP_ENABLED"] = true}, "Minimap")
    addOption(p.scroll.scrollchild, L["Show Coordinates on Minimap"], L["Show Coordinates on Minimap"], "MINIMAP_COORDS_TOGGLE", nil, nil, {["MINIMAP_ENABLED"] = true}, "Minimap")
    addOption(p.scroll.scrollchild, L["Fade Group Manage Button"], L["The Group Manage Button will fade when you move the cursor away."], "FADE_GROUP_MANAGE_FRAME", nil, nil, {["PARTY_FRAMES"] = true})
    addOption(
        p.scroll.scrollchild,
        L["Pixel Perfect Mode"],
        L["Scales the UI into a Pixel Perfect Mode. This is dependent on screen resolution."],
        "PIXEL_PERFECTION",
        function()
            SetCVar("useUiScale", 0)
            GW.PixelPerfection()
        end
    )
    addOption(p.scroll.scrollchild, COMBAT_TEXT_LABEL .. L[": Use Blizzard colors"], nil, "GW_COMBAT_TEXT_BLIZZARD_COLOR", nil, nil, {["GW_COMBAT_TEXT_MODE"] = "GW2"}, "FloatingCombatText")
    addOption(p.scroll.scrollchild, COMBAT_TEXT_LABEL .. L[": Show numbers with commas"], nil, "GW_COMBAT_TEXT_COMMA_FORMAT", nil, nil, {["GW_COMBAT_TEXT_MODE"] = "GW2"}, "FloatingCombatText")
    addOptionSlider(
        p.scroll.scrollchild,
        L["HUD Scale"],
        L["Change the HUD size."],
        "HUD_SCALE",
        GW.UpdateHudScale,
        0.5,
        1.5,
        nil,
        2
    )
    addOptionButton(p.scroll.scrollchild, L["Apply UI scale to all scaleable frames"], L["Applies the UI scale to all frames, which can be scaled in 'Move HUD' mode."], nil, function()
        local scale = GetSetting("HUD_SCALE")
        for _, mf in pairs(GW.scaleableFrames) do
            mf.gw_frame:SetScale(scale)
            mf:SetScale(scale)
            GW.SetSetting(mf.gw_Settings .."_scale", scale)
        end
    end)
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Minimap details"],
        L["Always show Minimap details."],
        "MINIMAP_HOVER",
        GW.SetMinimapHover,
        {"NONE", "ALL", "CLOCK", "ZONE", "COORDS", "CLOCKZONE", "CLOCKCOORDS", "ZONECOORDS"},
        {
            NONE_KEY,
            ALL,
            TIMEMANAGER_TITLE,
            ZONE,
            L["Coordinates"],
            TIMEMANAGER_TITLE .. " + " .. ZONE,
            TIMEMANAGER_TITLE .. " + " .. L["Coordinates"],
            ZONE .. " + " .. L["Coordinates"]
        },
        nil,
        {["MINIMAP_ENABLED"] = true},
        nil,
        "Minimap"
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Minimap Scale"],
        L["Change the Minimap size."],
        "MINIMAP_SCALE",
        function()
            Minimap:SetSize(GetSetting("MINIMAP_SCALE"), GetSetting("MINIMAP_SCALE"))
        end,
        {250, 200, 170},
        {
            LARGE,
            TIME_LEFT_MEDIUM,
            DEFAULT
        },
        nil,
        {["MINIMAP_ENABLED"] = true},
        nil,
        "Minimap"
    )

    addOptionDropdown(
        p.scroll.scrollchild,
        COMBAT_TEXT_LABEL,
        COMBAT_SUBTEXT,
        "GW_COMBAT_TEXT_MODE",
        function(value)
            if value == "GW2" then
                C_CVar.SetCVar("floatingCombatTextCombatDamage", "0")
                if GetSetting("GW_COMBAT_TEXT_SHOW_HEALING_NUMBERS") then
                    C_CVar.SetCVar("floatingCombatTextCombatHealing", "0")
                else
                    C_CVar.SetCVar("floatingCombatTextCombatHealing", "1")
                end
                GW.LoadDamageText(true)
            elseif value == "BLIZZARD" then
                C_CVar.SetCVar("floatingCombatTextCombatDamage", "1")
                C_CVar.SetCVar("floatingCombatTextCombafloatingCombatTextCombatHealingtDamage", "1")
                GW.FloatingCombatTextToggleFormat(false)
            else
                C_CVar.SetCVar("floatingCombatTextCombatDamage", "0")
                C_CVar.SetCVar("floatingCombatTextCombatHealing", "0")
                GW.FloatingCombatTextToggleFormat(false)
            end

        end,
        {"GW2", "BLIZZARD", "OFF"},
        {GW.addonName, "Blizzard", OFF .. " / " .. OTHER .. " " .. ADDONS},
        nil,
        nil,
        nil,
        "FloatingCombatText"
    )
    addOption(p.scroll.scrollchild, COMBAT_TEXT_LABEL .. L[": Use Blizzard colors"], nil, "GW_COMBAT_TEXT_BLIZZARD_COLOR", GW.UpdateDameTextSettings, nil, {["GW_COMBAT_TEXT_MODE"] = "GW2"}, "FloatingCombatText")
    addOption(p.scroll.scrollchild, COMBAT_TEXT_LABEL .. L[": Show numbers with commas"], nil, "GW_COMBAT_TEXT_COMMA_FORMAT", GW.UpdateDameTextSettings, nil, {["GW_COMBAT_TEXT_MODE"] = "GW2"}, "FloatingCombatText")

    addOptionDropdown(
        p.scroll.scrollchild,
        L["GW2 floating combat text style"],
        nil,
        "GW_COMBAT_TEXT_STYLE",
        function() GW.UpdateDameTextSettings(); GW.FloatingCombatTextToggleFormat(true) end,
        {"Default", "Stacking", "Classic"},
        {DEFAULT, L["Stacking"], EXPANSION_NAME0},
        nil,
        {["GW_COMBAT_TEXT_MODE"] = "GW2"},
        nil,
        "FloatingCombatText"
    )

    addOptionDropdown(
        p.scroll.scrollchild,
        L["Classic combat text anchoring"],
        nil,
        "GW_COMBAT_TEXT_STYLE_CLASSIC_ANCHOR",
        function() GW.UpdateDameTextSettings(); GW.FloatingCombatTextToggleFormat(true) end,
        {"Nameplates", "Center"},
        {L["Nameplates"], L["Center of screen"]},
        nil,
        {["GW_COMBAT_TEXT_MODE"] = "GW2", ["GW_COMBAT_TEXT_STYLE"] = EXPANSION_NAME0},
        nil,
        "FloatingCombatText"
    )
    addOption(p.scroll.scrollchild, L["Show healing numbers"], nil, "GW_COMBAT_TEXT_SHOW_HEALING_NUMBERS", function(value) if value then C_CVar.SetCVar("floatingCombatTextCombatHealing", "0") else C_CVar.SetCVar("floatingCombatTextCombatHealing", "1") end GW.UpdateDameTextSettings() end, nil, {["GW_COMBAT_TEXT_MODE"] = "GW2", ["GW_COMBAT_TEXT_STYLE"] = {EXPANSION_NAME0, "Stacking"}}, "FloatingCombatText")






    InitPanel(p, true)
end
GW.LoadHudPanel = LoadHudPanel
