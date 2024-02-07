local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionSlider = GW.AddOptionSlider
local addOptionDropdown = GW.AddOptionDropdown
local addOptionButton = GW.AddOptionButton
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local InitPanel = GW.InitPanel
local settingsMenuAddButton = GW.settingsMenuAddButton

local function LoadHudPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:Hide()
    p.sub:Hide()

    local general = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    general.header:SetFont(DAMAGE_TEXT_FONT, 20)
    general.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    general.header:SetText(UIOPTIONS_MENU)
    general.sub:SetFont(UNIT_NAME_FONT, 12)
    general.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    general.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])
    general.header:SetWidth(general.header:GetStringWidth())
    general.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    general.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    general.breadcrumb:SetText(GENERAL)

    local minimap = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    minimap.header:SetFont(DAMAGE_TEXT_FONT, 20)
    minimap.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    minimap.header:SetText(UIOPTIONS_MENU)
    minimap.sub:SetFont(UNIT_NAME_FONT, 12)
    minimap.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    minimap.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])
    minimap.header:SetWidth(minimap.header:GetStringWidth())
    minimap.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    minimap.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    minimap.breadcrumb:SetText(MINIMAP_LABEL)

    local worldmap = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    worldmap.header:SetFont(DAMAGE_TEXT_FONT, 20)
    worldmap.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    worldmap.header:SetText(UIOPTIONS_MENU)
    worldmap.sub:SetFont(UNIT_NAME_FONT, 12)
    worldmap.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    worldmap.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])
    worldmap.header:SetWidth(worldmap.header:GetStringWidth())
    worldmap.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    worldmap.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    worldmap.breadcrumb:SetText(WORLDMAP_BUTTON)

    local fct = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    fct.header:SetFont(DAMAGE_TEXT_FONT, 20)
    fct.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    fct.header:SetText(UIOPTIONS_MENU)
    fct.sub:SetFont(UNIT_NAME_FONT, 12)
    fct.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    fct.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])
    fct.header:SetWidth(fct.header:GetStringWidth())
    fct.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    fct.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    fct.breadcrumb:SetText(COMBAT_TEXT_LABEL)

    createCat(UIOPTIONS_MENU, L["Edit the HUD modules."], p, {general, minimap, worldmap, fct})
    settingsMenuAddButton(UIOPTIONS_MENU, p, {general, minimap, worldmap, fct})

    addOption(general.scroll.scrollchild, L["Show HUD background"], L["The HUD background changes color in the following situations: In Combat, Not In Combat, In Water, Low HP, Ghost"], "HUD_BACKGROUND", GW.ToggleHudBackground)
    addOption(general.scroll.scrollchild, L["Dynamic HUD"], L["Enable or disable the dynamically changing HUD background."], "HUD_SPELL_SWAP", nil, nil, {["HUD_BACKGROUND"] = true})
    addOption(general.scroll.scrollchild, L["AFK Mode"], L["When you go AFK display the AFK screen."], "AFK_MODE", GW.ToggelAfkMode)
    addOption(general.scroll.scrollchild, L["Toggle Compass"], L["Enable or disable the quest tracker compass."], "SHOW_QUESTTRACKER_COMPASS", function() GW.ShowRlPopup = true end, nil, {["QUESTTRACKER_ENABLED"] = true})
    addOption(general.scroll.scrollchild, L["Show Quest XP on Quest Tracker"], nil, "QUESTTRACKER_SHOW_XP", function() GW.UpdateQuestTracker(GwQuesttrackerContainerQuests) end, nil, {["QUESTTRACKER_ENABLED"] = true})
    addOptionSlider(
        general.scroll.scrollchild,
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
    addOptionDropdown(
        general.scroll.scrollchild,
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
    addOption(general.scroll.scrollchild, L["Fade Menu Bar"], L["The main menu icons will fade when you move your cursor away."], "FADE_MICROMENU", function(value) Gw2MicroBarFrame.cf:SetAttribute("shouldFade", value) Gw2MicroBarFrame.cf:SetShown(not value) if value then Gw2MicroBarFrame.cf.fadeOut(Gw2MicroBarFrame.cf) else Gw2MicroBarFrame.cf.fadeIn(Gw2MicroBarFrame.cf) end end)
    addOption(general.scroll.scrollchild, L["Auto Repair"], L["Automatically repair using the following method when visiting a merchant."], "AUTO_REPAIR")
    addOption(general.scroll.scrollchild, DISPLAY_BORDERS, nil, "BORDER_ENABLED", GW.ToggleHudBackground)
    addOption(general.scroll.scrollchild, L["Fade Group Manage Button"], L["The Group Manage Button will fade when you move the cursor away."], "FADE_GROUP_MANAGE_FRAME", function() GW.ShowRlPopup = true end, nil, {["PARTY_FRAMES"] = true})
    addOption(
        general.scroll.scrollchild,
        L["Pixel Perfect Mode"],
        L["Scales the UI into a Pixel Perfect Mode. This is dependent on screen resolution."],
        "PIXEL_PERFECTION",
        function()
            SetCVar("useUiScale", 0)
            GW.PixelPerfection()
        end
    )
    addOptionSlider(
        fct.scroll.scrollchild,
        L["HUD Scale"],
        L["Change the HUD size."],
        "HUD_SCALE",
        GW.UpdateHudScale,
        0.5,
        1.5,
        nil,
        2
    )
    addOptionButton(general.scroll.scrollchild, L["Apply UI scale to all scaleable frames"], L["Applies the UI scale to all frames, which can be scaled in 'Move HUD' mode."], nil, function()
        local scale = GetSetting("HUD_SCALE")
        for _, mf in pairs(GW.scaleableFrames) do
            mf.gw_frame:SetScale(scale)
            mf:SetScale(scale)
            GW.SetSetting(mf.gw_Settings .."_scale", scale)
        end
    end)

    --MINIMAP
    addOption(minimap.scroll.scrollchild, L["Show FPS on minimap"], L["Show FPS on minimap"], "MINIMAP_FPS", GW.ToogleMinimapFpsLable, nil, {["MINIMAP_ENABLED"] = true}, "Minimap")
    addOption(minimap.scroll.scrollchild, L["Show Coordinates on Minimap"], L["Show Coordinates on Minimap"], "MINIMAP_COORDS_TOGGLE", GW.ToogleMinimapCoorsLable, nil, {["MINIMAP_ENABLED"] = true}, "Minimap")
    addOptionDropdown(
        minimap.scroll.scrollchild,
        L["Minimap details"],
        L["Always show Minimap details."],
        "MINIMAP_ALWAYS_SHOW_HOVER_DETAILS",
        GW.SetMinimapHover,
        {"CLOCK", "ZONE", "COORDS"},
        {TIMEMANAGER_TITLE, ZONE, L["Coordinates"]},
        nil,
        {["MINIMAP_ENABLED"] = true},
        true,
        "Minimap"
    )
    addOptionSlider(
        minimap.scroll.scrollchild,
        L["Minimap Scale"],
        L["Change the Minimap size."],
        "MINIMAP_SCALE",
        function()
            local size = GetSetting("MINIMAP_SCALE")
            Minimap:SetSize(size, size)
            Minimap.gwMover:SetSize(size, size)
        end,
        160,
        420,
        nil,
        0,
        {["MINIMAP_ENABLED"] = true},
        1
    )

    --WORLDMAP
    addOption(worldmap.scroll.scrollchild, L["Show Coordinates on World Map"], L["Show Coordinates on World Map"], "WORLDMAP_COORDS_TOGGLE", GW.ToggleWorldMapCoords, nil)

    --FCT
    addOptionDropdown(
        fct.scroll.scrollchild,
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
    addOption(fct.scroll.scrollchild, COMBAT_TEXT_LABEL .. L[": Use Blizzard colors"], nil, "GW_COMBAT_TEXT_BLIZZARD_COLOR", GW.UpdateDameTextSettings, nil, {["GW_COMBAT_TEXT_MODE"] = "GW2"}, "FloatingCombatText")
    addOption(fct.scroll.scrollchild, COMBAT_TEXT_LABEL .. L[": Show numbers with commas"], nil, "GW_COMBAT_TEXT_COMMA_FORMAT", GW.UpdateDameTextSettings, nil, {["GW_COMBAT_TEXT_MODE"] = "GW2"}, "FloatingCombatText")
    addOption(fct.scroll.scrollchild, COMBAT_TEXT_LABEL .. ": " .. L["Show healing numbers"], nil, "GW_COMBAT_TEXT_SHOW_HEALING_NUMBERS", function(value) if value then C_CVar.SetCVar("floatingCombatTextCombatHealing", "0") else C_CVar.SetCVar("floatingCombatTextCombatHealing", "1") end GW.UpdateDameTextSettings() end, nil, {["GW_COMBAT_TEXT_MODE"] = "GW2", ["GW_COMBAT_TEXT_STYLE"] = {EXPANSION_NAME0, "Stacking"}}, "FloatingCombatText")


    addOptionDropdown(
        fct.scroll.scrollchild,
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
        fct.scroll.scrollchild,
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
    addOptionSlider(
        fct.scroll.scrollchild,
        FONT_SIZE,
        nil,
        "GW_COMBAT_TEXT_FONT_SIZE",
        GW.UpdateDameTextSettings,
        2,
        50,
        nil,
        0,
        {["GW_COMBAT_TEXT_MODE"] = "GW2"},
        2,
        "FloatingCombatText",
        nil,
        COMBAT_TEXT_LABEL
    )
    addOptionSlider(
        fct.scroll.scrollchild,
        FONT_SIZE .. ": " .. MISS,
        nil,
        "GW_COMBAT_TEXT_FONT_SIZE_MISS",
        GW.UpdateDameTextSettings,
        2,
        50,
        nil,
        0,
        {["GW_COMBAT_TEXT_MODE"] = "GW2"},
        2,
        "FloatingCombatText",
        nil,
        COMBAT_TEXT_LABEL
    )
    addOptionSlider(
        fct.scroll.scrollchild,
        FONT_SIZE .. ": " .. CRIT_ABBR,
        nil,
        "GW_COMBAT_TEXT_FONT_SIZE_CRIT",
        GW.UpdateDameTextSettings,
        2,
        50,
        nil,
        0,
        {["GW_COMBAT_TEXT_MODE"] = "GW2"},
        2,
        "FloatingCombatText",
        nil,
        COMBAT_TEXT_LABEL
    )
    addOptionSlider(
        fct.scroll.scrollchild,
        FONT_SIZE .. ": " .. BLOCK .. "/" .. ABSORB,
        nil,
        "GW_COMBAT_TEXT_FONT_SIZE_BLOCKED_ABSORBE",
        GW.UpdateDameTextSettings,
        2,
        50,
        nil,
        0,
        {["GW_COMBAT_TEXT_MODE"] = "GW2"},
        2,
        "FloatingCombatText",
        nil,
        COMBAT_TEXT_LABEL
    )
    addOptionSlider(
        fct.scroll.scrollchild,
        FONT_SIZE .. ": " .. L["Crit modifier"],
        L["Used for animations"],
        "GW_COMBAT_TEXT_FONT_SIZE_CRIT_MODIFIER",
        GW.UpdateDameTextSettings,
        0.1,
        50,
        nil,
        2,
        {["GW_COMBAT_TEXT_MODE"] = "GW2"},
        nil,
        "FloatingCombatText",
        nil,
        COMBAT_TEXT_LABEL
    )
    addOptionSlider(
        fct.scroll.scrollchild,
        FONT_SIZE .. ": " .. L["Pet number modifier"],
        nil,
        "GW_COMBAT_TEXT_FONT_SIZE_PET_MODIFIER",
        GW.UpdateDameTextSettings,
        0.1,
        50,
        nil,
        2,
        {["GW_COMBAT_TEXT_MODE"] = "GW2"},
        nil,
        "FloatingCombatText",
        nil,
        COMBAT_TEXT_LABEL
    )


    InitPanel(general, true)
    InitPanel(minimap, true)
    InitPanel(worldmap, true)
    InitPanel(fct, true)
end
GW.LoadHudPanel = LoadHudPanel
