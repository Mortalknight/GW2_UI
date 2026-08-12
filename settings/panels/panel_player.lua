---@class GW2
local GW = select(2, ...)
local L = GW.L
local StrUpper = GW.StrUpper

local auraGrowthOptions = {"UP", "DOWN", "UPR", "DOWNR", "UPL_COLUMN", "UPR_COLUMN", "DOWNL_COLUMN", "DOWNR_COLUMN"}
local auraGrowthOptionNames = {L["Rows: left, wrap up"], L["Rows: left, wrap down"], L["Rows: right, wrap up"], L["Rows: right, wrap down"], L["Columns: up, wrap left"], L["Columns: up, wrap right"], L["Columns: down, wrap left"], L["Columns: down, wrap right"]}

local function LoadPlayerPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")

    local p_player = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_player.panelId = "player_general"
    p_player.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_player.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p_player.header:SetText(PLAYER)
    p_player.sub:SetFont(UNIT_NAME_FONT, 12)
    p_player.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_player.sub:SetText(L["Modify the player frame settings."])
    p_player.header:SetWidth(p_player.header:GetStringWidth())
    p_player.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p_player.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p_player.breadcrumb:SetText(GENERAL)

    local p_player_aura = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_player_aura.panelId = "player_aura"
    p_player_aura.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_player_aura.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p_player_aura.header:SetText(PLAYER)
    p_player_aura.header:SetWidth(p_player_aura.header:GetStringWidth())
    p_player_aura.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p_player_aura.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p_player_aura.breadcrumb:SetText(L["Auras"])
    p_player_aura.sub:SetFont(UNIT_NAME_FONT, 12)
    p_player_aura.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_player_aura.sub:SetText(L["Edit player aura settings."])

    local castbar = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    castbar.panelId = "player_castbar"
    castbar.header:SetFont(DAMAGE_TEXT_FONT, 20)
    castbar.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    castbar.header:SetText(PLAYER)
    castbar.sub:SetFont(UNIT_NAME_FONT, 12)
    castbar.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    castbar.sub:SetText(L["Edit player cast bar settings."])
    castbar.header:SetWidth(castbar.header:GetStringWidth())
    castbar.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    castbar.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    castbar.breadcrumb:SetText(L["Cast Bar"])

    local fader = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    fader.panelId = "player_fader"
    fader.header:SetFont(DAMAGE_TEXT_FONT, 20)
    fader.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    fader.header:SetText(PLAYER)
    fader.sub:SetFont(UNIT_NAME_FONT, 12)
    fader.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    fader.sub:SetText("")
    fader.header:SetWidth(fader.header:GetStringWidth())
    fader.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    fader.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    fader.breadcrumb:SetText(L["Fader"])

    local classpower = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    classpower.panelId = "player_classpower"
    classpower.header:SetFont(DAMAGE_TEXT_FONT, 20)
    classpower.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    classpower.header:SetText(PLAYER)
    classpower.sub:SetFont(UNIT_NAME_FONT, 12)
    classpower.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    classpower.sub:SetText("")
    classpower.header:SetWidth(fader.header:GetStringWidth())
    classpower.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    classpower.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    classpower.breadcrumb:SetText(L["Class Power"])

    local totemBar = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    totemBar.panelId = "player_totem"
    totemBar.header:SetFont(DAMAGE_TEXT_FONT, 20)
    totemBar.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    totemBar.header:SetText(PLAYER)
    totemBar.sub:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    totemBar.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    totemBar.sub:SetText("")
    totemBar.header:SetWidth(totemBar.header:GetStringWidth())
    totemBar.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    totemBar.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    totemBar.breadcrumb:SetText(L["Totem Bar"])

    p_player:AddOption(ENABLE, L["Enable the health bar replacement."], {getterSetter = "HEALTHGLOBE_ENABLED", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    p_player:AddOption(L["Power Bar"], L["Replace the default mana/power bar."], {getterSetter = "POWERBAR_ENABLED", callback = function() if GwPlayerPowerBar then GwPlayerPowerBar:ToggleBar(); GW.ClassPowers.UpdateExtraManabar() end end, isMasterToggle = true})
    p_player:AddOption(L["Player frame in target frame style"], nil, {getterSetter = "PLAYER_AS_TARGET_FRAME", callback = function() GW.ShowRlPopup = true end, dependence = {["HEALTHGLOBE_ENABLED"] = true}})
    p_player:AddOption(L["Show alternative background texture"], nil, {getterSetter = "PLAYER_AS_TARGET_FRAME_ALT_BACKGROUND", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    p_player:AddOption(L["Show absorb bar"], nil, {getterSetter = "PLAYER_SHOW_ABSORB_BAR", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath})

    p_player:AddOption(RAID_USE_CLASS_COLORS, nil, {getterSetter = "player_CLASS_COLOR", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    p_player:AddOption(L["PvP Indicator"], nil, {getterSetter = "PLAYER_SHOW_PVP_INDICATOR", dependence = {["HEALTHGLOBE_ENABLED"] = true}})
    p_player:AddOption(L["Shorten health values"], nil, {getterSetter = "PLAYER_UNIT_HEALTH_SHORT_VALUES", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath})
    p_player:AddOption(L["Shorten shield values"], nil, {getterSetter = "PLAYER_UNIT_SHIELD_SHORT_VALUES", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath or GW.Retail})
    p_player:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, { getterSetter = "PLAYER_UNIT_HEALTH", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, optionsList = {"NONE", "PREC", "VALUE", "BOTH"}, optionNames = {NONE, STATUS_TEXT_PERCENT, STATUS_TEXT_VALUE, STATUS_TEXT_BOTH}, dependence = {["HEALTHGLOBE_ENABLED"] = true}})

    local absorbSettingsList = {"NONE", "VALUE"}
    local absorbSettingsNames = {NONE, STATUS_TEXT_VALUE}
    if not GW.Retail then
        tinsert(absorbSettingsList, "PREC")
        tinsert(absorbSettingsList, STATUS_TEXT_PERCENT)
        tinsert(absorbSettingsNames, "BOTH")
        tinsert(absorbSettingsNames, STATUS_TEXT_BOTH)
    end

    p_player:AddOptionDropdown(L["Show Shield Value"], nil, { getterSetter = "PLAYER_UNIT_ABSORB", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, optionsList = absorbSettingsList, optionNames = absorbSettingsNames, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = false}, hidden = GW.Classic or GW.TBC or GW.Wrath})

    local statusBarTexturesOptions, statusBarTexturesLables = GW.GetStatusBarTextures()
    p_player:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "playerFrameHealthBarTexture", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})

    p_player:AddGroupHeader(L["Dodge Bar"])
    p_player:AddOption(GW.NewSign .. L["Show Dodge Bar"], nil, {getterSetter = "showDodgebar", callback = function() if GwDodgeBar then GwDodgeBar:ToggleDodgeBar(); GwDodgeBar:ToggleSkyridingBar() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true}})
    p_player:AddOption(GW.NewSign .. L["Show Dodge Bar Cooldown Text"], L["Show the remaining cooldown of the tracked ability on the dodge bar."], {getterSetter = "DODGEBAR_COOLDOWN_TEXT", callback = function() if GwDodgeBar then GwDodgeBar:SetupBar() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["showDodgebar"] = true}})

    p_player:AddOptionSpellInput(L["Dodge Bar Ability"], L["Enter the spell ID which should be tracked by the dodge bar.\nIf no ID is entered, the default abilities based on your specialization and talents are tracked."], { getterSetter = "PLAYER_TRACKED_DODGEBAR_SPELL_ID", callback = function()
            if GwDodgeBar then
                GwDodgeBar:InitBar()
                GwDodgeBar:SetupBar()
            end
        end, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["showDodgebar"] = true}, isPrivateSetting = true})
    p_player:AddOption(GW.NewSign .. L["Show Skyriding Bar"], nil, {getterSetter = "showSkyridingbar", callback = function() if GwDodgeBar then GwDodgeBar:ToggleSkyridingBar() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true}, hidden = not GW.Retail})

    p_player:AddGroupHeader(L["Size"])
    p_player:AddOptionSlider(L["Scale"], nil, { getterSetter = "player_pos_scale", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})

    p_player:AddOptionSlider(GW.NewSign .. L["Bar Width"], nil, { getterSetter = "playerFrameHealthBarSize.width", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 150, max = 500, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    p_player:AddOptionSlider(GW.NewSign .. L["Healthbar Height"], nil, { getterSetter = "playerFrameHealthBarSize.height", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 5, max = 150, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    p_player:AddOptionSlider(GW.NewSign .. L["Healthbar Text X-Offset"], nil, { getterSetter = "playerFrameHealthBarTextOffset.x", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    p_player:AddOptionSlider(GW.NewSign .. L["Healthbar Text Y-Offset"], nil, { getterSetter = "playerFrameHealthBarTextOffset.y", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})

    p_player:AddOptionSlider(GW.NewSign .. L["Powerbar Height"], nil, { getterSetter = "playerFramePowerBarSize.height", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 1, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    p_player:AddOptionSlider(GW.NewSign .. L["Powerbar Text X-Offset"], nil, { getterSetter = "playerFramePowerBarTextOffset.x", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    p_player:AddOptionSlider(GW.NewSign .. L["Powerbar Text Y-Offset"], nil, { getterSetter = "playerFramePowerBarTextOffset.y", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})


    -- CAST BAR
    castbar:AddOption(ENABLE, L["Enable the GW2 style casting bar."], {getterSetter = "CASTINGBAR_ENABLED", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    castbar:AddOption(L["Ticks"], L["Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste."], {getterSetter = "showPlayerCastBarTicks", dependence = {["CASTINGBAR_ENABLED"] = true}})

    castbar:AddGroupHeader(DISPLAY)
    castbar:AddOption(GW.NewSign .. L["Spell Name"], L["Shows the name of the spell being cast above the bar."], {getterSetter = "CASTINGBAR_SHOW_NAME", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = DISPLAY, dependence = {["CASTINGBAR_ENABLED"] = true}})
    castbar:AddOption(GW.NewSign .. L["Cast Timer"], L["Shows the remaining cast time above the bar."], {getterSetter = "CASTINGBAR_SHOW_TIMER", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = DISPLAY, dependence = {["CASTINGBAR_ENABLED"] = true}})
    castbar:AddOption(GW.NewSign .. L["Latency"], L["Marks the part of the cast that is lost to your latency at the end of the bar."], {getterSetter = "CASTINGBAR_SHOW_LATENCY", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = DISPLAY, dependence = {["CASTINGBAR_ENABLED"] = true}})
    castbar:AddOption(L["Show spell queue window on castingbar"], nil, {getterSetter = "PLAYER_CASTBAR_SHOW_SPELL_QUEUEWINDOW", callback = function() GW.UpdateCastingBarSettings() end, groupHeaderName = DISPLAY, dependence = {["CASTINGBAR_ENABLED"] = true, ["CASTINGBAR_SHOW_LATENCY"] = true}})
    castbar:AddOptionDropdown(GW.NewSign .. L["Spell Icon"], L["Which side of the casting bar the spell icon sits on."], {getterSetter = "CASTINGBAR_ICON_POSITION", callback = function() GW.UpdateCastingBarLayout() end, optionsList = {"LEFT", "RIGHT", "HIDE"}, optionNames = {L["Left"], L["Right"], HIDE}, groupHeaderName = DISPLAY, dependence = {["CASTINGBAR_ENABLED"] = true}})

    castbar:AddGroupHeader(L["Size"])
    castbar:AddOptionSlider(GW.NewSign .. L["Width"], nil, {getterSetter = "CASTINGBAR_WIDTH", callback = function() GW.UpdateCastingBarLayout() end, min = 100, max = 500, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["CASTINGBAR_ENABLED"] = true}})
    castbar:AddOptionSlider(GW.NewSign .. L["Height"], nil, {getterSetter = "CASTINGBAR_HEIGHT", callback = function() GW.UpdateCastingBarLayout() end, min = 6, max = 40, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["CASTINGBAR_ENABLED"] = true}})

    castbar:AddGroupHeader(COLOR)
    castbar:AddOption(GW.NewSign .. L["Custom Colors"], L["Use your own casting bar colors instead of the default textures."], {getterSetter = "CASTINGBAR_CUSTOM_COLORS", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = COLOR, dependence = {["CASTINGBAR_ENABLED"] = true}})
    castbar:AddOptionColorPicker(GW.NewSign .. L["Casting"], nil, {getterSetter = "CASTINGBAR_COLOR_CAST", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = COLOR, dependence = {["CASTINGBAR_ENABLED"] = true, ["CASTINGBAR_CUSTOM_COLORS"] = true}})
    castbar:AddOptionColorPicker(GW.NewSign .. L["Channeling"], nil, {getterSetter = "CASTINGBAR_COLOR_CHANNEL", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = COLOR, dependence = {["CASTINGBAR_ENABLED"] = true, ["CASTINGBAR_CUSTOM_COLORS"] = true}})
    castbar:AddOptionColorPicker(GW.NewSign .. L["Empowered"], nil, {getterSetter = "CASTINGBAR_COLOR_EMPOWER", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = COLOR, dependence = {["CASTINGBAR_ENABLED"] = true, ["CASTINGBAR_CUSTOM_COLORS"] = true}, hidden = not GW.Retail})
    castbar:AddOptionColorPicker(GW.NewSign .. INTERRUPTED, nil, {getterSetter = "CASTINGBAR_COLOR_INTERRUPTED", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = COLOR, dependence = {["CASTINGBAR_ENABLED"] = true, ["CASTINGBAR_CUSTOM_COLORS"] = true}})

    castbar:AddGroupHeader(L["Feedback"])
    castbar:AddOption(GW.NewSign .. L["Empowered Stage Colors"], L["Brightens the casting bar with every empower stage you hold and shows the stage on the bar."], {getterSetter = "CASTINGBAR_EMPOWER_STAGE_COLORS", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = L["Feedback"], dependence = {["CASTINGBAR_ENABLED"] = true}, hidden = not GW.Retail})
    castbar:AddOption(GW.NewSign .. L["Shake On Interrupt"], L["Shakes the casting bar when your cast was interrupted or failed."], {getterSetter = "CASTINGBAR_INTERRUPT_SHAKE", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = L["Feedback"], dependence = {["CASTINGBAR_ENABLED"] = true}})
    castbar:AddOption(GW.NewSign .. L["Sound On Interrupt"], L["Plays a sound when your cast was interrupted or failed."], {getterSetter = "CASTINGBAR_INTERRUPT_SOUND", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = L["Feedback"], dependence = {["CASTINGBAR_ENABLED"] = true}})

    -- AURAS
    p_player_aura:AddOption(ENABLE, L["Move and resize the player auras."], {getterSetter = "PLAYER_BUFFS_ENABLED", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    p_player_aura:AddOptionSpellList(L["Ignored Auras"], L["A list of auras that should never be shown."], { getterSetter = "PLAYER_IGNORED_AURAS", callback = function()
        GW.UpdateAuraHeader(GW2UIPlayerBuffs)
        GW.UpdateAuraHeader(GW2UIPlayerDebuffs)
    end, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, hidden = not GW.Retail})
    p_player_aura:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "PLAYER_PANDEMIC_HIGHLIGHT", callback = GW.UpdateAuraOptionRegions, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, hidden = not GW.Retail})
    p_player_aura:AddOption(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type of auras as a small icon in the corner of the aura."], {getterSetter = "PLAYER_DISPEL_ICON", callback = GW.UpdateAuraOptionRegions, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, hidden = not GW.Retail})
    p_player_aura:AddGroupHeader(L["Buffs"])
    p_player_aura:AddOptionDropdown(L["Player Buff Growth Direction"], nil, { getterSetter = "PlayerBuffs.GrowDirection", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, optionsList = auraGrowthOptions, optionNames = auraGrowthOptionNames, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionDropdown(L["Aura Sorting"], L["Set the sorting order of the auras."], { getterSetter = "PlayerBuffs.Sort", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, optionsList = {"DEFAULT", "EXPIRATION_ASC", "EXPIRATION_DESC", "NAME_ASC", "NAME_DESC"}, optionNames = {DEFAULT, L["Remaining time (ascending)"], L["Remaining time (descending)"], L["Name (ascending)"], L["Name (descending)"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionDropdown(L["Seperate"], L["Indicate whether buffs you cast yourself should be separated before or after."], { getterSetter = "PlayerBuffs.Seperate", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, optionsList = {-1, 0, 1}, optionNames = {L["Other's First"], L["No Sorting"], L["Your Auras First"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionSlider(L["Auras per row"], nil, { getterSetter = "PlayerBuffs.WrapAfter", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = 1, max = 20, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "PlayerBuffs.HorizontalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = -20, max = 50, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "PlayerBuffs.VerticalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = -20, max = 50, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionSlider(L["Max Wraps"], nil, { getterSetter = "PlayerBuffs.MaxWraps", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = 1, max = 32, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionSlider(L["Size"], nil, { getterSetter = "PlayerBuffs.IconSize", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = 10, max = 80, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionSlider(L["Height"], nil, { getterSetter = "PlayerBuffs.IconHeight", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = 10, max = 80, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true, ["PlayerBuffs.KeepSizeRatio"] = false}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOption(L["Keep Size Ratio"], nil, {getterSetter = "PlayerBuffs.KeepSizeRatio", callback = function(value) local widget = GW.FindSettingsWidgetByOption("PlayerBuffs.IconSize"); widget.title:SetText(value == true and L["Size"] or L["Width"]); GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Buffs"]})
    -- No longer feasible on Retail: the AuraContainer system blocks OnShow handlers on aura buttons (secret aspects)
    p_player_aura:AddOption(ANIMATION, L["Shows an animation for new de/buffs"], {getterSetter = "PlayerBuffs.NewAuraAnimation", dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Buffs"], hidden = GW.Retail})

    p_player_aura:AddGroupHeader(L["Debuffs"])
    p_player_aura:AddOptionDropdown(L["Player Debuffs Growth Direction"], nil, { getterSetter = "PlayerDebuffs.GrowDirection", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs, "PlayerDebuffFrame") end, optionsList = auraGrowthOptions, optionNames = auraGrowthOptionNames, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOptionDropdown(L["Aura Sorting"], L["Set the sorting order of the auras."], { getterSetter = "PlayerDebuffs.Sort", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, optionsList = {"DEFAULT", "EXPIRATION_ASC", "EXPIRATION_DESC", "NAME_ASC", "NAME_DESC"}, optionNames = {DEFAULT, L["Remaining time (ascending)"], L["Remaining time (descending)"], L["Name (ascending)"], L["Name (descending)"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOptionDropdown(L["Seperate"], L["Indicate whether buffs you cast yourself should be separated before or after."], { getterSetter = "PlayerDebuffs.Seperate", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, optionsList = {-1, 0, 1}, optionNames = {L["Other's First"], L["No Sorting"], L["Your Auras First"]}, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOptionSlider(L["Auras per row"], nil, { getterSetter = "PlayerDebuffs.WrapAfter", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = 1, max = 20, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "PlayerDebuffs.HorizontalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = -20, max = 50, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "PlayerDebuffs.VerticalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = -20, max = 50, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOptionSlider(L["Max Wraps"], nil, { getterSetter = "PlayerDebuffs.MaxWraps", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = 1, max = 32, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOptionSlider(L["Size"], nil, { getterSetter = "PlayerDebuffs.IconSize", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = 10, max = 80, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOptionSlider(L["Height"], nil, { getterSetter = "PlayerDebuffs.IconHeight", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = 10, max = 80, decimalNumbers = 0, step = 1, dependence = {["PLAYER_BUFFS_ENABLED"] = true, ["PlayerDebuffs.KeepSizeRatio"] = false}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOption(L["Keep Size Ratio"], nil, {getterSetter = "PlayerDebuffs.KeepSizeRatio", callback = function(value) local widget = GW.FindSettingsWidgetByOption("PlayerDebuffs.IconSize"); widget.title:SetText(value == true and L["Size"] or L["Width"]); GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOption(ANIMATION, L["Shows an animation for new de/buffs"], {getterSetter = "PlayerDebuffs.NewAuraAnimation", dependence = {["PLAYER_BUFFS_ENABLED"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})


    -- FADER
    fader:AddOptionDropdown(L["Fader"], nil, { getterSetter = "playerFrameFader", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], TARGET}, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    fader:AddOptionSlider(L["Smooth"], nil, { getterSetter = "playerFrameFader.smooth", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    fader:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "playerFrameFader.minAlpha", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})
    fader:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "playerFrameFader.maxAlpha", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true}})


    -- Classpower
    classpower:AddOption(ENABLE, L["Enable the alternate class powers."], {getterSetter = "CLASS_POWER", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    classpower:AddOption(GW.NewSign .. L["Show value on bar"], nil, {getterSetter = "CLASSPOWER_SHOW_VALUE", callback = function() GW.ClassPowers.UpdateSettings(GwPlayerClassPower); GwPlayerPowerBar:ToggleSettings(); if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["CLASS_POWER"] = true}})
    classpower:AddOptionDropdown(GW.NewSign .. L["Class power anchor"], L["Controls how the class power bar is anchored to its mover."], {
        getterSetter = "CLASSPOWER_ANCHOR_MODE",
        callback = function()
            if GwPlayerClassPower then
                GW.ClassPowers.UpdateSettings(GwPlayerClassPower)
            end
            if GwPlayerPowerBar then
                GwPlayerPowerBar:ToggleSettings()
            end
        end,
        optionsList = {"DEFAULT", "CENTER", "LEFT", "RIGHT"},
        optionNames = {DEFAULT, L["Center"], L["Left"], L["Right"]},
        dependence = {["CLASS_POWER"] = true},
    })
    classpower:AddOptionDropdown(GW.NewSign .. L["Custom resource bar side"], L["Choose which side optional custom resource bars are placed on. Auto flips by class power anchor mode."], {
        getterSetter = "CLASSPOWER_CUSTOMRESOURCEBAR_SIDE",
        callback = function()
            if GwPlayerClassPower then
                GW.ClassPowers.UpdateSettings(GwPlayerClassPower)
            end
        end,
        optionsList = {"AUTO", "LEFT", "RIGHT"},
        optionNames = {L["Auto"], L["Left"], L["Right"]},
        dependence = {["CLASS_POWER"] = true},
    })
    classpower:AddOptionSlider(GW.NewSign .. L["Class power anchor X offset"], L["Fine-tunes the horizontal position of the class power anchor."], {
        getterSetter = "CLASSPOWER_ANCHOR_OFFSET_X",
        callback = function()
            if GwPlayerClassPower then
                GW.ClassPowers.UpdateSettings(GwPlayerClassPower)
            end
        end,
        min = -200,
        max = 200,
        decimalNumbers = 0,
        step = 1,
        dependence = {["CLASS_POWER"] = true},
    })
    classpower:AddOptionSlider(GW.NewSign .. L["Class power anchor Y offset"], L["Fine-tunes the vertical position of the class power anchor."], {
        getterSetter = "CLASSPOWER_ANCHOR_OFFSET_Y",
        callback = function()
            if GwPlayerClassPower then
                GW.ClassPowers.UpdateSettings(GwPlayerClassPower)
            end
        end,
        min = -200,
        max = 200,
        decimalNumbers = 0,
        step = 1,
        dependence = {["CLASS_POWER"] = true},
    })
    classpower:AddOptionSlider(GW.NewSign .. L["Custom resource bar gap"], L["Controls spacing between class power and optional custom resource bars."], {
        getterSetter = "CLASSPOWER_CUSTOMRESOURCEBAR_GAP",
        callback = function()
            if GwPlayerClassPower then
                GW.ClassPowers.UpdateSettings(GwPlayerClassPower)
            end
        end,
        min = 0,
        max = 100,
        decimalNumbers = 0,
        step = 1,
        dependence = {["CLASS_POWER"] = true},
    })
    classpower:AddOption(L["Show classpower bar only in combat"], nil, {getterSetter = "CLASSPOWER_ONLY_SHOW_IN_COMBAT", callback = function() GW.ClassPowers.UpdateVisibilitySetting(GwPlayerClassPower, true) end, dependence = {["CLASS_POWER"] = true}})
    classpower:AddOption(L["Energy/Mana Ticker"], nil, {getterSetter = "PLAYER_ENERGY_MANA_TICK", callback = GW.Update5SrHot,  dependence = {["POWERBAR_ENABLED"] = true}, hidden = GW.Retail or GW.Mists})
    classpower:AddOption(L["5 second rule: display remaining time"], nil, {getterSetter = "PLAYER_5SR_TIMER", callback = GW.Update5SrHot,  dependence = {["POWERBAR_ENABLED"] = true, ["PLAYER_ENERGY_MANA_TICK"] = true}, hidden = GW.Retail or GW.Mists})
    classpower:AddOption(L["Show Energy/Mana Ticker only in combat"], nil, {getterSetter = "PLAYER_ENERGY_MANA_TICK_HIDE_OFC", callback = GW.Update5SrHot,  dependence = {["POWERBAR_ENABLED"] = true, ["PLAYER_ENERGY_MANA_TICK"] = true}, hidden = GW.Retail or GW.Mists})
    classpower:AddOption(L["Show an additional resource bar"], nil, {getterSetter = "PLAYER_AS_TARGET_FRAME_SHOW_RESSOURCEBAR", callback = function() GwPlayerPowerBar:ToggleBar(); GW.ClassPowers.UpdateExtraManabar() end, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["PLAYER_AS_TARGET_FRAME"] = true, ["POWERBAR_ENABLED"] = true}})


    --TOTEMBAR
    totemBar:AddOption(ENABLE, nil, { getterSetter = "TotemBar.enabled", isMasterToggle = true, callback = function() if GwTotemBar then GwTotemBar:UpdateVisibility() end end, dependence = {["HEALTHGLOBE_ENABLED"] = true}, incompatibleAddons = "Actionbars"})
    totemBar:AddOptionDropdown(L["Sorting"], nil, { getterSetter = "TotemBar.sortDirection", callback = function() if GwTotemBar then GwTotemBar:PositionAndSizeUpdate() end end, optionsList = {"ASC", "DSC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["TotemBar.enabled"] = true}, incompatibleAddons = "Actionbars"})
    totemBar:AddOptionDropdown(L["Growth Direction"], nil, { getterSetter = "TotemBar.growDirection", callback = function() if GwTotemBar then GwTotemBar:PositionAndSizeUpdate() end end, optionsList = {"HORIZONTAL", "VERTICAL"}, optionNames = {L["Horizontal"], L["Vertical"]}, dependence = {["HEALTHGLOBE_ENABLED"] = true, ["TotemBar.enabled"] = true}, incompatibleAddons = "Actionbars"})
    totemBar:AddOptionSlider(L["Button Spacing"], nil, {
        getterSetter = "TotemBar.spacing",
        callback = function() if GwTotemBar then GwTotemBar:PositionAndSizeUpdate() end end,
        min = 0,
        max = 10,
        decimalNumbers = 0,
        step = 1,
        dependence = {["HEALTHGLOBE_ENABLED"] = true, ["TotemBar.enabled"] = true},
        incompatibleAddons = "Actionbars"
    })
    totemBar:AddOptionSlider(L["Button Size"], nil, {
        getterSetter = "TotemBar.buttonSize",
        callback = function() if GwTotemBar then GwTotemBar:PositionAndSizeUpdate() end end,
        min = 20,
        max = 60,
        decimalNumbers = 0,
        step = 1,
        dependence = {["HEALTHGLOBE_ENABLED"] = true, ["TotemBar.enabled"] = true},
        incompatibleAddons = "Actionbars"
    })

    sWindow:AddSettingsPanel(p, PLAYER, L["Modify the player frame settings."], {{name = GENERAL, frame = p_player}, {name = L["Cast Bar"], frame = castbar}, {name = L["Auras"], frame = p_player_aura}, {name = L["Fader"], frame = fader}, {name = L["Class Power"], frame = classpower}, {name = L["Totem Bar"], frame = totemBar},})
end
GW.LoadPlayerPanel = LoadPlayerPanel
