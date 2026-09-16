---@class GW2
local GW = select(2, ...)
local L = GW.L

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
    fader.sub:SetText(L["Controls when the player frame fades in and out."])
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
    classpower.sub:SetText(L["Edit class resources like combo points or runes."])
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
    totemBar.sub:SetText(L["Edit the totem bar settings."])
    totemBar.header:SetWidth(totemBar.header:GetStringWidth())
    totemBar.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    totemBar.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    totemBar.breadcrumb:SetText(L["Totem Bar"])

    p_player:AddOption(ENABLE, L["Enable the health bar replacement."], {getterSetter = "unitframes.healthGlobe.enabled", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    p_player:AddOption(L["Power Bar"], L["Replace the default mana/power bar."], {getterSetter = "powerBar.enabled", callback = function() if GwPlayerPowerBar then GwPlayerPowerBar:ToggleBar(); GW.ClassPowers.UpdateExtraManabar() end end, isMasterToggle = true})
    p_player:AddOption(L["Player frame in target frame style"], nil, {getterSetter = "unitframes.player.enabled", callback = function() GW.ShowRlPopup = true end, dependence = {["unitframes.healthGlobe.enabled"] = true}})
    p_player:AddOption(L["Show alternative background texture"], nil, {getterSetter = "unitframes.player.altBackground", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}})
    p_player:AddOption(L["Show absorb bar"], nil, {getterSetter = "unitframes.player.showAbsorbBar", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath})

    p_player:AddOption(RAID_USE_CLASS_COLORS, nil, {getterSetter = "unitframes.player.classColor", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}})
    p_player:AddOption(L["PvP Indicator"], nil, {getterSetter = "unitframes.player.pvpIndicator", dependence = {["unitframes.healthGlobe.enabled"] = true}})
    p_player:AddOption(L["Shorten health values"], nil, {getterSetter = "unitframes.healthGlobe.shortHealthValues", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["unitframes.healthGlobe.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath})
    p_player:AddOption(L["Shorten shield values"], nil, {getterSetter = "unitframes.healthGlobe.shortShieldValues", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["unitframes.healthGlobe.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath or GW.Retail})
    p_player:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, { getterSetter = "unitframes.healthGlobe.healthValue", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, optionsList = {"NONE", "PREC", "VALUE", "BOTH"}, optionNames = {NONE, STATUS_TEXT_PERCENT, STATUS_TEXT_VALUE, STATUS_TEXT_BOTH}, dependence = {["unitframes.healthGlobe.enabled"] = true}})

    local absorbSettingsList = {"NONE", "VALUE"}
    local absorbSettingsNames = {NONE, STATUS_TEXT_VALUE}
    if not GW.Retail then
        tinsert(absorbSettingsList, "PREC")
        tinsert(absorbSettingsList, STATUS_TEXT_PERCENT)
        tinsert(absorbSettingsNames, "BOTH")
        tinsert(absorbSettingsNames, STATUS_TEXT_BOTH)
    end

    p_player:AddOptionDropdown(L["Show Shield Value"], nil, { getterSetter = "unitframes.healthGlobe.absorbValue", callback = function() if GW2_PlayerFrame then GW2_PlayerFrame:ToggleSettings() end; if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, optionsList = absorbSettingsList, optionNames = absorbSettingsNames, dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = false}, hidden = GW.Classic or GW.TBC or GW.Wrath})

    local statusBarTexturesOptions, statusBarTexturesLables = GW.GetStatusBarTextures()
    p_player:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "unitframes.player.healthBarTexture", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}})

    p_player:AddGroupHeader(L["Dodge Bar"])
    p_player:AddOption(GW.NewSign .. L["Show Dodge Bar"], nil, {getterSetter = "hud.dodgeBar.enabled", callback = function() if GwDodgeBar then GwDodgeBar:ToggleDodgeBar(); GwDodgeBar:ToggleSkyridingBar() end end, dependence = {["unitframes.healthGlobe.enabled"] = true}})
    p_player:AddOption(GW.NewSign .. L["Show Dodge Bar Cooldown Text"], L["Show the remaining cooldown of the tracked ability on the dodge bar."], {getterSetter = "hud.dodgeBar.cooldownText", callback = function() if GwDodgeBar then GwDodgeBar:SetupBar() end end, dependence = {["unitframes.healthGlobe.enabled"] = true, ["hud.dodgeBar.enabled"] = true}})

    p_player:AddOptionSpellInput(L["Dodge Bar Ability"], L["Enter the spell ID which should be tracked by the dodge bar.\nIf no ID is entered, the default abilities based on your specialization and talents are tracked."], { getterSetter = "PLAYER_TRACKED_DODGEBAR_SPELL_ID", callback = function()
            if GwDodgeBar then
                GwDodgeBar:InitBar()
                GwDodgeBar:SetupBar()
            end
        end, dependence = {["unitframes.healthGlobe.enabled"] = true, ["hud.dodgeBar.enabled"] = true}, isPrivateSetting = true})
    p_player:AddOption(GW.NewSign .. L["Show Skyriding Bar"], nil, {getterSetter = "hud.skyridingBar", callback = function() if GwDodgeBar then GwDodgeBar:ToggleSkyridingBar() end end, dependence = {["unitframes.healthGlobe.enabled"] = true}, hidden = not GW.Retail})

    p_player:AddGroupHeader(L["Size"])
    p_player:AddOptionSlider(L["Scale"], nil, { getterSetter = "unitframes.player.scale", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Size"], dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}})

    p_player:AddOptionSlider(GW.NewSign .. L["Bar Width"], nil, { getterSetter = "unitframes.player.healthBarSize.width", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 150, max = 500, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}})
    p_player:AddOptionSlider(GW.NewSign .. L["Healthbar Height"], nil, { getterSetter = "unitframes.player.healthBarSize.height", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 5, max = 150, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}})
    p_player:AddOptionSlider(GW.NewSign .. L["Healthbar Text X-Offset"], nil, { getterSetter = "unitframes.player.healthBarTextOffset.x", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}})
    p_player:AddOptionSlider(GW.NewSign .. L["Healthbar Text Y-Offset"], nil, { getterSetter = "unitframes.player.healthBarTextOffset.y", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}})

    p_player:AddOptionSlider(GW.NewSign .. L["Powerbar Height"], nil, { getterSetter = "unitframes.player.powerBarSize.height", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 1, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}})
    p_player:AddOptionSlider(GW.NewSign .. L["Powerbar Text X-Offset"], nil, { getterSetter = "unitframes.player.powerBarTextOffset.x", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}})
    p_player:AddOptionSlider(GW.NewSign .. L["Powerbar Text Y-Offset"], nil, { getterSetter = "unitframes.player.powerBarTextOffset.y", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}})


    -- CAST BAR
    castbar:AddOption(ENABLE, L["Enable the GW2 style casting bar."], {getterSetter = "castingbar.enabled", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    castbar:AddOption(L["Ticks"], L["Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste."], {getterSetter = "castingbar.ticks", dependence = {["castingbar.enabled"] = true}})

    castbar:AddGroupHeader(DISPLAY)
    castbar:AddOption(GW.NewSign .. L["Spell Name"], L["Shows the name of the spell being cast above the bar."], {getterSetter = "castingbar.showName", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = DISPLAY, dependence = {["castingbar.enabled"] = true}})
    castbar:AddOption(GW.NewSign .. L["Cast Timer"], L["Shows the remaining cast time above the bar."], {getterSetter = "castingbar.showTimer", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = DISPLAY, dependence = {["castingbar.enabled"] = true}})
    castbar:AddOption(GW.NewSign .. L["Latency"], L["Marks the part of the cast that is lost to your latency at the end of the bar."], {getterSetter = "castingbar.showLatency", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = DISPLAY, dependence = {["castingbar.enabled"] = true}})
    castbar:AddOption(L["Show spell queue window on castingbar"], nil, {getterSetter = "castingbar.spellQueueWindow", callback = function() GW.UpdateCastingBarSettings() end, groupHeaderName = DISPLAY, dependence = {["castingbar.enabled"] = true, ["castingbar.showLatency"] = true}})
    castbar:AddOptionDropdown(GW.NewSign .. L["Spell Icon"], L["Which side of the casting bar the spell icon sits on."], {getterSetter = "castingbar.iconPosition", callback = function() GW.UpdateCastingBarLayout() end, optionsList = {"LEFT", "RIGHT", "HIDE"}, optionNames = {L["Left"], L["Right"], HIDE}, groupHeaderName = DISPLAY, dependence = {["castingbar.enabled"] = true}})

    castbar:AddGroupHeader(L["Size"])
    castbar:AddOptionSlider(GW.NewSign .. L["Width"], nil, {getterSetter = "castingbar.width", callback = function() GW.UpdateCastingBarLayout() end, min = 100, max = 500, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["castingbar.enabled"] = true}})
    castbar:AddOptionSlider(GW.NewSign .. L["Height"], nil, {getterSetter = "castingbar.height", callback = function() GW.UpdateCastingBarLayout() end, min = 6, max = 40, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["castingbar.enabled"] = true}})

    castbar:AddGroupHeader(COLOR)
    castbar:AddOption(GW.NewSign .. L["Custom Colors"], L["Use your own casting bar colors instead of the default textures."], {getterSetter = "castingbar.customColors", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = COLOR, dependence = {["castingbar.enabled"] = true}})
    castbar:AddOptionColorPicker(GW.NewSign .. L["Casting"], nil, {getterSetter = "castingbar.colors.cast", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = COLOR, dependence = {["castingbar.enabled"] = true, ["castingbar.customColors"] = true}})
    castbar:AddOptionColorPicker(GW.NewSign .. L["Channeling"], nil, {getterSetter = "castingbar.colors.channel", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = COLOR, dependence = {["castingbar.enabled"] = true, ["castingbar.customColors"] = true}})
    castbar:AddOptionColorPicker(GW.NewSign .. L["Empowered"], nil, {getterSetter = "castingbar.colors.empower", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = COLOR, dependence = {["castingbar.enabled"] = true, ["castingbar.customColors"] = true}, hidden = not GW.Retail})
    castbar:AddOptionColorPicker(GW.NewSign .. INTERRUPTED, nil, {getterSetter = "castingbar.colors.interrupted", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = COLOR, dependence = {["castingbar.enabled"] = true, ["castingbar.customColors"] = true}})

    castbar:AddGroupHeader(L["Feedback"])
    castbar:AddOption(GW.NewSign .. L["Empowered Stage Colors"], L["Brightens the casting bar with every empower stage you hold and shows the stage on the bar."], {getterSetter = "castingbar.colors.empowerStages", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = L["Feedback"], dependence = {["castingbar.enabled"] = true}, hidden = not GW.Retail})
    castbar:AddOption(GW.NewSign .. L["Shake On Interrupt"], L["Shakes the casting bar when your cast was interrupted or failed."], {getterSetter = "castingbar.interruptShake", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = L["Feedback"], dependence = {["castingbar.enabled"] = true}})
    castbar:AddOption(GW.NewSign .. L["Sound On Interrupt"], L["Plays a sound when your cast was interrupted or failed."], {getterSetter = "castingbar.interruptSound", callback = function() GW.UpdateCastingBarLayout() end, groupHeaderName = L["Feedback"], dependence = {["castingbar.enabled"] = true}})

    -- AURAS
    p_player_aura:AddOption(ENABLE, L["Move and resize the player auras."], {getterSetter = "playerAuras.enabled", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    p_player_aura:AddOptionSpellList(L["Ignored Auras"], L["A list of auras that should never be shown."], { getterSetter = "playerAuras.ignoredAuras", callback = function()
        GW.UpdateAuraHeader(GW2UIPlayerBuffs)
        GW.UpdateAuraHeader(GW2UIPlayerDebuffs)
    end, dependence = {["playerAuras.enabled"] = true}, hidden = not GW.Retail})
    p_player_aura:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "playerAuras.pandemicHighlight", callback = GW.UpdateAuraOptionRegions, dependence = {["playerAuras.enabled"] = true}, hidden = not GW.Retail})
    p_player_aura:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "playerAuras.dispelIcon", callback = GW.UpdateAuraOptionRegions, dependence = {["playerAuras.enabled"] = true}, hidden = not GW.Retail})
    p_player_aura:AddGroupHeader(L["Buffs"])
    p_player_aura:AddOptionDropdown(L["Player Buff Growth Direction"], nil, { getterSetter = "playerAuras.buffs.GrowDirection", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, optionsList = auraGrowthOptions, optionNames = auraGrowthOptionNames, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionDropdown(L["Aura Sorting"], L["Set the sorting order of the auras."], { getterSetter = "playerAuras.buffs.Sort", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, optionsList = {"DEFAULT", "EXPIRATION_ASC", "EXPIRATION_DESC", "NAME_ASC", "NAME_DESC"}, optionNames = {DEFAULT, L["Remaining time (ascending)"], L["Remaining time (descending)"], L["Name (ascending)"], L["Name (descending)"]}, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionDropdown(L["Seperate"], L["Indicate whether buffs you cast yourself should be separated before or after."], { getterSetter = "playerAuras.buffs.Seperate", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, optionsList = {-1, 0, 1}, optionNames = {L["Other's First"], L["No Sorting"], L["Your Auras First"]}, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionSlider(L["Auras per row"], nil, { getterSetter = "playerAuras.buffs.WrapAfter", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = 1, max = 20, decimalNumbers = 0, step = 1, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "playerAuras.buffs.HorizontalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = -20, max = 50, decimalNumbers = 0, step = 1, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "playerAuras.buffs.VerticalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = -20, max = 50, decimalNumbers = 0, step = 1, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionSlider(L["Max Wraps"], nil, { getterSetter = "playerAuras.buffs.MaxWraps", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = 1, max = 32, decimalNumbers = 0, step = 1, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionSlider(L["Size"], nil, { getterSetter = "playerAuras.buffs.IconSize", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = 10, max = 80, decimalNumbers = 0, step = 1, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOptionSlider(L["Height"], nil, { getterSetter = "playerAuras.buffs.IconHeight", callback = function() GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, min = 10, max = 80, decimalNumbers = 0, step = 1, dependence = {["playerAuras.enabled"] = true, ["playerAuras.buffs.KeepSizeRatio"] = false}, groupHeaderName = L["Buffs"]})
    p_player_aura:AddOption(L["Keep Size Ratio"], nil, {getterSetter = "playerAuras.buffs.KeepSizeRatio", callback = function(value) local widget = GW.FindSettingsWidgetByOption("playerAuras.buffs.IconSize"); widget.title:SetText(value == true and L["Size"] or L["Width"]); GW.UpdateAuraHeader(GW2UIPlayerBuffs) end, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Buffs"]})
    -- No longer feasible on Retail: the AuraContainer system blocks OnShow handlers on aura buttons (secret aspects)
    p_player_aura:AddOption(ANIMATION, L["Shows an animation for new de/buffs"], {getterSetter = "playerAuras.buffs.NewAuraAnimation", dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Buffs"], hidden = GW.Retail})

    p_player_aura:AddGroupHeader(L["Debuffs"])
    p_player_aura:AddOptionDropdown(L["Player Debuffs Growth Direction"], nil, { getterSetter = "playerAuras.debuffs.GrowDirection", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, optionsList = auraGrowthOptions, optionNames = auraGrowthOptionNames, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOptionDropdown(L["Aura Sorting"], L["Set the sorting order of the auras."], {
        getterSetter = "playerAuras.debuffs.Sort", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, optionsList = {"DEFAULT", "EXPIRATION_ASC", "EXPIRATION_DESC", "NAME_ASC", "NAME_DESC"}, optionNames = {DEFAULT, L["Remaining time (ascending)"], L["Remaining time (descending)"], L["Name (ascending)"], L["Name (descending)"]}, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Debuffs"]
    })
    p_player_aura:AddOptionDropdown(L["Seperate"], L["Indicate whether buffs you cast yourself should be separated before or after."], { getterSetter = "playerAuras.debuffs.Seperate", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, optionsList = {-1, 0, 1}, optionNames = {L["Other's First"], L["No Sorting"], L["Your Auras First"]}, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOptionSlider(L["Auras per row"], nil, { getterSetter = "playerAuras.debuffs.WrapAfter", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = 1, max = 20, decimalNumbers = 0, step = 1, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOptionSlider(L["Horizontal Spacing"], nil, { getterSetter = "playerAuras.debuffs.HorizontalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = -20, max = 50, decimalNumbers = 0, step = 1, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOptionSlider(L["Vertical Spacing"], nil, { getterSetter = "playerAuras.debuffs.VerticalSpacing", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = -20, max = 50, decimalNumbers = 0, step = 1, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOptionSlider(L["Max Wraps"], nil, { getterSetter = "playerAuras.debuffs.MaxWraps", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = 1, max = 32, decimalNumbers = 0, step = 1, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOptionSlider(L["Size"], nil, { getterSetter = "playerAuras.debuffs.IconSize", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = 10, max = 80, decimalNumbers = 0, step = 1, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOptionSlider(L["Height"], nil, { getterSetter = "playerAuras.debuffs.IconHeight", callback = function() GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, min = 10, max = 80, decimalNumbers = 0, step = 1, dependence = {["playerAuras.enabled"] = true, ["playerAuras.debuffs.KeepSizeRatio"] = false}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOption(L["Keep Size Ratio"], nil, {getterSetter = "playerAuras.debuffs.KeepSizeRatio", callback = function(value) local widget = GW.FindSettingsWidgetByOption("playerAuras.debuffs.IconSize"); widget.title:SetText(value == true and L["Size"] or L["Width"]); GW.UpdateAuraHeader(GW2UIPlayerDebuffs) end, dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Debuffs"]})
    p_player_aura:AddOption(ANIMATION, L["Shows an animation for new de/buffs"], {getterSetter = "playerAuras.debuffs.NewAuraAnimation", dependence = {["playerAuras.enabled"] = true}, groupHeaderName = L["Debuffs"], hidden = GW.Retail})


    -- FADER
    fader:AddOptionDropdown(L["Fader"], nil, { getterSetter = "unitframes.player.fader", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], TARGET}, dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    fader:AddOptionSlider(L["Smooth"], nil, { getterSetter = "unitframes.player.fader.smooth", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}})
    fader:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "unitframes.player.fader.minAlpha", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}})
    fader:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "unitframes.player.fader.maxAlpha", callback = function() if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true}})


    -- Classpower
    classpower:AddOption(ENABLE, L["Enable the alternate class powers."], {getterSetter = "classpower.enabled", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    classpower:AddOption(GW.NewSign .. L["Show value on bar"], nil, {getterSetter = "classpower.showValue", callback = function() GW.ClassPowers.UpdateSettings(GwPlayerClassPower); GwPlayerPowerBar:ToggleSettings(); if GwPlayerUnitFrame then GwPlayerUnitFrame:ToggleSettings() end end, dependence = {["classpower.enabled"] = true}})
    classpower:AddOptionDropdown(GW.NewSign .. L["Class power anchor"], L["Controls how the class power bar is anchored to its mover."], {
        getterSetter = "classpower.anchorMode",
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
        dependence = {["classpower.enabled"] = true},
    })
    classpower:AddOptionDropdown(GW.NewSign .. L["Custom resource bar side"], L["Choose which side optional custom resource bars are placed on. Auto flips by class power anchor mode."], {
        getterSetter = "classpower.customResourceBarSide",
        callback = function()
            if GwPlayerClassPower then
                GW.ClassPowers.UpdateSettings(GwPlayerClassPower)
            end
        end,
        optionsList = {"AUTO", "LEFT", "RIGHT"},
        optionNames = {L["Auto"], L["Left"], L["Right"]},
        dependence = {["classpower.enabled"] = true},
    })
    classpower:AddOptionSlider(GW.NewSign .. L["Class power anchor X offset"], L["Fine-tunes the horizontal position of the class power anchor."], {
        getterSetter = "classpower.anchorOffsetX",
        callback = function()
            if GwPlayerClassPower then
                GW.ClassPowers.UpdateSettings(GwPlayerClassPower)
            end
        end,
        min = -200,
        max = 200,
        decimalNumbers = 0,
        step = 1,
        dependence = {["classpower.enabled"] = true},
    })
    classpower:AddOptionSlider(GW.NewSign .. L["Class power anchor Y offset"], L["Fine-tunes the vertical position of the class power anchor."], {
        getterSetter = "classpower.anchorOffsetY",
        callback = function()
            if GwPlayerClassPower then
                GW.ClassPowers.UpdateSettings(GwPlayerClassPower)
            end
        end,
        min = -200,
        max = 200,
        decimalNumbers = 0,
        step = 1,
        dependence = {["classpower.enabled"] = true},
    })
    classpower:AddOptionSlider(GW.NewSign .. L["Custom resource bar gap"], L["Controls spacing between class power and optional custom resource bars."], {
        getterSetter = "classpower.customResourceBarGap",
        callback = function()
            if GwPlayerClassPower then
                GW.ClassPowers.UpdateSettings(GwPlayerClassPower)
            end
        end,
        min = 0,
        max = 100,
        decimalNumbers = 0,
        step = 1,
        dependence = {["classpower.enabled"] = true},
    })
    classpower:AddOption(L["Show classpower bar only in combat"], nil, {getterSetter = "classpower.onlyInCombat", callback = function() GW.ClassPowers.UpdateVisibilitySetting(GwPlayerClassPower, true) end, dependence = {["classpower.enabled"] = true}})
    classpower:AddOption(L["Energy/Mana Ticker"], nil, {getterSetter = "unitframes.player.energyManaTick", callback = GW.Update5SrHot,  dependence = {["powerBar.enabled"] = true}, hidden = GW.Retail or GW.Mists})
    classpower:AddOption(L["5 second rule: display remaining time"], nil, {getterSetter = "unitframes.player.fiveSecondRuleTimer", callback = GW.Update5SrHot,  dependence = {["powerBar.enabled"] = true, ["unitframes.player.energyManaTick"] = true}, hidden = GW.Retail or GW.Mists})
    classpower:AddOption(L["Show Energy/Mana Ticker only in combat"], nil, {getterSetter = "unitframes.player.energyManaTickHideOutOfCombat", callback = GW.Update5SrHot,  dependence = {["powerBar.enabled"] = true, ["unitframes.player.energyManaTick"] = true}, hidden = GW.Retail or GW.Mists})
    classpower:AddOption(L["Show an additional resource bar"], nil, {getterSetter = "unitframes.player.showResourceBar", callback = function() GwPlayerPowerBar:ToggleBar(); GW.ClassPowers.UpdateExtraManabar() end, dependence = {["unitframes.healthGlobe.enabled"] = true, ["unitframes.player.enabled"] = true, ["powerBar.enabled"] = true}})


    --TOTEMBAR
    totemBar:AddOption(ENABLE, nil, { getterSetter = "totemBar.enabled", isMasterToggle = true, callback = function() if GwTotemBar then GwTotemBar:UpdateVisibility() end end, dependence = {["unitframes.healthGlobe.enabled"] = true}, incompatibleAddons = "Actionbars"})
    totemBar:AddOptionDropdown(L["Sorting"], nil, { getterSetter = "totemBar.sortDirection", callback = function() if GwTotemBar then GwTotemBar:PositionAndSizeUpdate() end end, optionsList = {"ASC", "DSC"}, optionNames = {L["Ascending"], L["Descending"]}, dependence = {["unitframes.healthGlobe.enabled"] = true, ["totemBar.enabled"] = true}, incompatibleAddons = "Actionbars"})
    totemBar:AddOptionDropdown(L["Growth Direction"], nil, { getterSetter = "totemBar.growDirection", callback = function() if GwTotemBar then GwTotemBar:PositionAndSizeUpdate() end end, optionsList = {"HORIZONTAL", "VERTICAL"}, optionNames = {L["Horizontal"], L["Vertical"]}, dependence = {["unitframes.healthGlobe.enabled"] = true, ["totemBar.enabled"] = true}, incompatibleAddons = "Actionbars"})
    totemBar:AddOptionSlider(L["Button Spacing"], nil, {
        getterSetter = "totemBar.spacing",
        callback = function() if GwTotemBar then GwTotemBar:PositionAndSizeUpdate() end end,
        min = 0,
        max = 10,
        decimalNumbers = 0,
        step = 1,
        dependence = {["unitframes.healthGlobe.enabled"] = true, ["totemBar.enabled"] = true},
        incompatibleAddons = "Actionbars"
    })
    totemBar:AddOptionSlider(L["Button Size"], nil, {
        getterSetter = "totemBar.buttonSize",
        callback = function() if GwTotemBar then GwTotemBar:PositionAndSizeUpdate() end end,
        min = 20,
        max = 60,
        decimalNumbers = 0,
        step = 1,
        dependence = {["unitframes.healthGlobe.enabled"] = true, ["totemBar.enabled"] = true},
        incompatibleAddons = "Actionbars"
    })

    sWindow:AddSettingsPanel(p, PLAYER, L["Modify the player frame settings."], {{name = GENERAL, frame = p_player}, {name = L["Cast Bar"], frame = castbar}, {name = L["Auras"], frame = p_player_aura}, {name = L["Fader"], frame = fader}, {name = L["Class Power"], frame = classpower}, {name = L["Totem Bar"], frame = totemBar},})
end
GW.LoadPlayerPanel = LoadPlayerPanel
