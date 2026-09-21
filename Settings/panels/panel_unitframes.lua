---@class GW2
local GW = select(2, ...)
local L = GW.L

local unitInfoOptions = GW.Retail and {"ITEM_LEVEL", "PVP_LEVEL", "NONE"} or {"ITEM_LEVEL", "NONE"}
local unitInfoOptionNames = GW.Retail and {STAT_AVERAGE_ITEM_LEVEL, L["PvP Level"], NONE} or {STAT_AVERAGE_ITEM_LEVEL, NONE}

local function UpdateUnitFrameReactionColors()
    GW.UpdateUnitFrameReactionColors()

    if GwTargetUnitFrame then
        GwTargetUnitFrame:UnitFrameData()
    end
    if GwTargetTargetUnitFrame then
        GwTargetTargetUnitFrame:UnitFrameData()
    end
    if GwFocusUnitFrame then
        GwFocusUnitFrame:UnitFrameData()
    end
    if GwFocusTargetUnitFrame then
        GwFocusTargetUnitFrame:UnitFrameData()
    end
    if GW.UpdatePartyFrames then
        GW.UpdatePartyFrames()
    end
    if GW.UpdateBossFramesHealthbarColor then
        GW.UpdateBossFramesHealthbarColor()
    end
end

local function LoadTargetPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")

    local general = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    general.panelId = "unitframes_general"
    general.header:SetFont(DAMAGE_TEXT_FONT, 20)
    general.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    general.header:SetText(UNITFRAME_LABEL)
    general.sub:SetFont(UNIT_NAME_FONT, 12)
    general.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    general.sub:SetText(L["Edit general unitframe settings."])
    general.header:SetWidth(general.header:GetStringWidth())
    general.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    general.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    general.breadcrumb:SetText(GENERAL)

    local pPlayerPet = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    pPlayerPet.panelId = "player_pet"
    pPlayerPet.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pPlayerPet.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    pPlayerPet.header:SetText(UNITFRAME_LABEL)
    pPlayerPet.sub:SetFont(UNIT_NAME_FONT, 12)
    pPlayerPet.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pPlayerPet.sub:SetText(L["Modify the player pet frame settings."])
    pPlayerPet.header:SetWidth(pPlayerPet.header:GetStringWidth())
    pPlayerPet.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    pPlayerPet.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    pPlayerPet.breadcrumb:SetText(PET)

    local p_target = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_target.panelId = "target_general"
    p_target.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_target.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p_target.header:SetText(UNITFRAME_LABEL)
    p_target.sub:SetFont(UNIT_NAME_FONT, 12)
    p_target.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_target.sub:SetText(L["Modify the target frame settings."])
    p_target.header:SetWidth(p_target.header:GetStringWidth())
    p_target.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p_target.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p_target.breadcrumb:SetText(TARGET)

    local pTargetOfTarget = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    pTargetOfTarget.panelId = "target_of_target"
    pTargetOfTarget.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pTargetOfTarget.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    pTargetOfTarget.header:SetText(UNITFRAME_LABEL)
    pTargetOfTarget.sub:SetFont(UNIT_NAME_FONT, 12)
    pTargetOfTarget.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pTargetOfTarget.sub:SetText(L["Modify the target of target frame settings."])
    pTargetOfTarget.header:SetWidth(pTargetOfTarget.header:GetStringWidth())
    pTargetOfTarget.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    pTargetOfTarget.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    pTargetOfTarget.breadcrumb:SetText(SHOW_TARGET_OF_TARGET_TEXT)

    local p_focus = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_focus.panelId = "focus_general"
    p_focus.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_focus.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p_focus.header:SetText(UNITFRAME_LABEL)
    p_focus.sub:SetFont(UNIT_NAME_FONT, 12)
    p_focus.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_focus.sub:SetText(L["Modify the focus frame settings."])
    p_focus.header:SetWidth(p_focus.header:GetStringWidth())
    p_focus.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p_focus.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p_focus.breadcrumb:SetText(FOCUS)

    local pTargetOfFocus = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    pTargetOfFocus.panelId = "target_of_focus"
    pTargetOfFocus.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pTargetOfFocus.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    pTargetOfFocus.header:SetText(UNITFRAME_LABEL)
    pTargetOfFocus.sub:SetFont(UNIT_NAME_FONT, 12)
    pTargetOfFocus.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pTargetOfFocus.sub:SetText(L["Modify the target of focus frame settings."])
    pTargetOfFocus.header:SetWidth(pTargetOfFocus.header:GetStringWidth())
    pTargetOfFocus.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    pTargetOfFocus.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    pTargetOfFocus.breadcrumb:SetText(L["Focus target"])

    local party = CreateFrame("Frame", nil, p, "GwSettingsPanelPreviewTmpl")
    party.panelId = "party_general"
    party.header:SetFont(DAMAGE_TEXT_FONT, 20)
    party.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    party.header:SetText(UNITFRAME_LABEL)
    party.header:SetWidth(party.header:GetStringWidth())
    party.sub:SetFont(UNIT_NAME_FONT, 12)
    party.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    party.sub:SetText(L["Modify the party frame settings."])
    party.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    party.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    -- "Party Frames", not just "Party": the raid style party grid has its own page under
    -- Group Frames and users kept mixing the two up while both were labelled "Party"
    party.breadcrumb:SetText(L["Party Frames"])
    party.preview:SetWidth(party.preview:GetFontString():GetStringWidth() + 5)
    party.preview:SetScript("OnClick", function()
        if InCombatLockdown() then return end
        if GW.IsPartyFramesPreviewActive and GW.IsPartyFramesPreviewActive() then
            GW.TogglePartyPreview()
            GW.DeactivateSettingsPreview("unitframes.party.enabled")
        else
            GW.ActivateSettingsPreview("unitframes.party.enabled", function()
                if GW.IsPartyFramesPreviewActive() then GW.TogglePartyPreview() end
            end)
            GW.TogglePartyPreview()
        end
    end)
    party.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Party Frames"], 1, 1, 1)
        GameTooltip:Show()
    end)
    party.preview:SetScript("OnLeave", GameTooltip_Hide)
    -- the frames are only replaced when the grid module is actually loaded, so
    -- RAID_STYLE_PARTY alone must not disable the preview (see PARTY_GRID_REPLACES_FRAMES)
    local function IsPartyGridReplacingFrames()
        return GW.settings.groupFrames.enabled == true and GW.settings.groupFrames.party.enabled == true
    end
    party.preview:SetEnabled(GW.settings.unitframes.party.enabled == true and not IsPartyGridReplacingFrames())

    local panels = {
        {name = GENERAL, frame = general},
        {name = PET, frame = pPlayerPet},
        {name = TARGET, frame = p_target},
        {name = SHOW_TARGET_OF_TARGET_TEXT, frame = pTargetOfTarget},
    }

    if not GW.Classic then
        table.insert(panels, {name = FOCUS, frame = p_focus})
        table.insert(panels, {name = L["Focus target"], frame = pTargetOfFocus})
    end

    table.insert(panels, {name = L["Party Frames"], frame = party})

    local playerTag = " |cFF888888(" .. PLAYER .. ")|r"
    local otherTag = " |cFF888888(" .. OTHER .. ")|r"
    local buffOptions = {"all", "advanced", "none"}
    local buffOptionNames = {ALL, L["Advanced Filtering"], NONE}
    local debuffOptions = {"all", "player", "advanced", "none"}
    local debuffOptionNames = {ALL, PLAYER, L["Advanced Filtering"], NONE}

    -- Retail: tri-state filters, one list (single group per aura type);
    -- classic keeps the old boolean per-side list (old filter engine)
    local advancedAuraOptions, advancedAuraOptionsNames, advancedAuraOptionsOther, advancedAuraOptionsNamesOther
    if GW.Retail then
        advancedAuraOptions = {
            "HEADER", "isAuraPlayer", "isAuraRaidPlayerDispellable", "isAuraStealable", "isAuraBoss", "isAuraPriority", "isAuraRole",
            "HEADER", "isAuraRaid", "isAuraRaidInCombat", "isAuraCancelable", "isAuraCrowdControl", "isAuraBigDefensive", "isAuraExternalDefensive", "isAuraImportant"
        }
        advancedAuraOptionsNames = {
            L["Aura Properties"], PLAYER, L["Dispellable"], L["Stealable"], L["Boss Aura"], L["Priority Debuff"], L["Role Aura"],
            FILTERS, RAID, RAID_FRAMES_LABEL, L["Is Cancelable"], L["Crowd Control"], L["Big Defensive"], L["External Defensives"], L["Important"]
        }
        advancedAuraOptionsOther = {}
        advancedAuraOptionsNamesOther = {}
    else
        advancedAuraOptions = {"isAuraPlayer", "isAuraRaidPlayerDispellable", "HEADER", "isAuraRaidPlayer", "isAuraCancelablePlayer", "notAuraCancelablePlayer"}
        advancedAuraOptionsNames = {PLAYER,  L["Dispellable"], PLAYER, RAID .. playerTag, L["Is Cancelable"] .. playerTag, L["Not Cancelable"] .. playerTag}
        advancedAuraOptionsOther = {"HEADER", "isAuraRaid", "isAuraCancelable", "notAuraCancelable"}
        advancedAuraOptionsNamesOther = {OTHER, RAID .. otherTag, L["Is Cancelable"] .. otherTag, L["Not Cancelable"] .. otherTag}
    end

    local statusBarTexturesOptions, statusBarTexturesLables = GW.GetStatusBarTextures()

    if not GW.Retail then
        -- classic only: the "Dungeon & Raid Debuffs" preset of the old filter engine
        tinsert(debuffOptions, 2, "importent")
        tinsert(debuffOptionNames, 2, L["Dungeon & Raid Debuffs"])
    end

    for i = 1, #advancedAuraOptionsOther do
        tinsert(advancedAuraOptions, advancedAuraOptionsOther[i])
        tinsert(advancedAuraOptionsNames, advancedAuraOptionsNamesOther[i])
    end

    --GENERAL
    general:AddGroupHeader(L["Reaction Colors"])
    general:AddOptionColorPicker(FRIENDLY, L["Color used for friendly unit frames."], {getterSetter = "unitframes.reactionColors.Friendly", callback = UpdateUnitFrameReactionColors, groupHeaderName = L["Reaction Colors"]})
    general:AddOptionColorPicker(ENEMY, L["Color used for enemy unit frames."], {getterSetter = "unitframes.reactionColors.Hostile", callback = UpdateUnitFrameReactionColors, groupHeaderName = L["Reaction Colors"]})
    general:AddOptionColorPicker(L["Tapped"], L["Color used for tapped unit frames."], {getterSetter = "unitframes.reactionColors.TappedDenied", callback = UpdateUnitFrameReactionColors, groupHeaderName = L["Reaction Colors"]})

    --PET
    pPlayerPet:AddOption(ENABLE, L["Use the GW2 UI improved Pet bar."], {getterSetter = "unitframes.pet.enabled", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "PetFrame", isMasterToggle = true})
    pPlayerPet:AddOption(L["Display Portrait Damage"], L["Display Portrait Damage on this frame"], {getterSetter = "unitframes.pet.floatingCombatText", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleCombatFeedback() end end, dependence = {["unitframes.pet.enabled"] = true}, group = "portrait"})
    pPlayerPet:AddOption(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, L["Show health as a numerical value."], {getterSetter = "unitframes.pet.healthValueRaw", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:UpdateSettings() end end, dependence = {["unitframes.pet.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "healthText"})
    pPlayerPet:AddOption(RAID_HEALTH_TEXT_PERC, L["Display health as a percentage. Can be used as well as, or instead of Health Value."], {getterSetter = "unitframes.pet.healthValuePercent", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:UpdateSettings() end end, dependence = {["unitframes.pet.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "healthText"})
    pPlayerPet:AddOption(L["Shorten health values"], nil, {getterSetter = "unitframes.pet.shortHealthValues", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:UpdateSettings() end end, dependence = {["unitframes.pet.enabled"] = true}, hidden = not GW.Retail, group = "healthText"})
    pPlayerPet:AddOption(L["Show absorb bar"], nil, {getterSetter = "unitframes.pet.showAbsorbBar", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:UpdateSettings() end end, dependence = {["unitframes.pet.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "healthBars"})
    pPlayerPet:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "unitframes.pet.healthBarTexture", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:UpdateSettings() end end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["unitframes.pet.enabled"] = true}, group = "healthBars"})

    pPlayerPet:AddGroupHeader(AURAS)
    pPlayerPet:AddOption(L["Show auras below"], nil, {getterSetter = "unitframes.pet.aurasUnder", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleAuraPosition() end end, dependence = {["unitframes.pet.enabled"] = true}})
    pPlayerPet:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "unitframes.pet.pandemicHighlight", callback = GW.UpdateAuraOptionRegions, dependence = {["unitframes.pet.enabled"] = true}, hidden = not GW.Retail})
    pPlayerPet:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "unitframes.pet.dispelIcon", callback = GW.UpdateAuraOptionRegions, dependence = {["unitframes.pet.enabled"] = true}, hidden = not GW.Retail})
    pPlayerPet:AddOptionDropdown(L["Buffs"], L["Display the target's buffs."], { getterSetter = "unitframes.pet.buffFilter", callback = function() GwPlayerPetFrame:UpdateSettings() end, optionsList = buffOptions, optionNames = buffOptionNames, dependence = {["unitframes.pet.enabled"] = true}, groupHeaderName = AURAS})
    pPlayerPet:AddOptionNote(L["Every selected filter narrows the display further - only auras matching all selected filters are shown. No selection shows everything."]
        .. "\n" .. L["Clicking an entry cycles through three states: off (ignored) - check (only auras with this property are shown) - red cross (auras with this property are hidden)."], {
        isVisible = function() return GW.settings.unitframes.pet.buffFilter == "advanced" or GW.settings.unitframes.pet.debuffFilter == "advanced" end,
        group = "advancedAuraNote",
    })
    pPlayerPet:AddOptionDropdown(L["Buffs: Advanced Filtering"], L["Every selected filter narrows the display further - only auras matching all selected filters are shown. No selection shows everything."], { getterSetter = "unitframes.pet.buffFilterAdvanced",
        callback = function() GwPlayerPetFrame:UpdateSettings() end,
        optionsList = advancedAuraOptions,
        optionNames = advancedAuraOptionsNames,
        dependence = {["unitframes.pet.enabled"] = true, ["unitframes.pet.buffFilter"] = {"advanced"}},
        checkbox = true,
        triState = GW.Retail,
        groupHeaderName = AURAS}
    )

    pPlayerPet:AddOptionDropdown(L["Debuffs"], L["Display the target's debuffs."], { getterSetter = "unitframes.pet.debuffFilter", callback = function() GwPlayerPetFrame:UpdateSettings() end, optionsList = debuffOptions, optionNames = debuffOptionNames, dependence = {["unitframes.pet.enabled"] = true}, groupHeaderName = AURAS})
    pPlayerPet:AddOptionDropdown(L["Debuffs: Advanced Filtering"], L["Every selected filter narrows the display further - only auras matching all selected filters are shown. No selection shows everything."], { getterSetter = "unitframes.pet.debuffFilterAdvanced",
        callback = function() GwPlayerPetFrame:UpdateSettings() end,
        optionsList = advancedAuraOptions,
        optionNames = advancedAuraOptionsNames,
        dependence = {["unitframes.pet.enabled"] = true, ["unitframes.pet.debuffFilter"] = {"advanced"}},
        checkbox = true,
        triState = GW.Retail,
        groupHeaderName = AURAS}
    )
    pPlayerPet:AddOptionSpellList(L["Ignored Auras"], L["A list of auras that should never be shown."], { getterSetter = "unitframes.pet.ignoredAuras", callback = function() GwPlayerPetFrame:UpdateSettings() end, dependence = {["unitframes.pet.enabled"] = true}, groupHeaderName = AURAS})
    pPlayerPet:AddOptionDropdown(L["Aura Sorting"], L["Set the sorting order of the auras."], {
        getterSetter = "unitframes.pet.auraSort", callback = function() GwPlayerPetFrame:UpdateSettings() end, optionsList = {"DEFAULT", "EXPIRATION_ASC", "EXPIRATION_DESC", "NAME_ASC", "NAME_DESC"}, optionNames = {DEFAULT, L["Remaining time (ascending)"], L["Remaining time (descending)"], L["Name (ascending)"], L["Name (descending)"]}, dependence = {["unitframes.pet.enabled"] = true}, groupHeaderName = AURAS, hidden = not GW.Retail
    })
    pPlayerPet:AddGroupHeader(L["Fader"])
    pPlayerPet:AddOptionDropdown(L["Fader"], nil, { getterSetter = "unitframes.pet.fader", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["unitframes.pet.enabled"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    pPlayerPet:AddOptionSlider(L["Smooth"], nil, { getterSetter = "unitframes.pet.fader.smooth", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["unitframes.pet.enabled"] = true}})
    pPlayerPet:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "unitframes.pet.fader.minAlpha", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["unitframes.pet.enabled"] = true}})
    pPlayerPet:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "unitframes.pet.fader.maxAlpha", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:ToggleFaderOptions() end end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["unitframes.pet.enabled"] = true}})

    pPlayerPet:AddGroupHeader(L["Size"])
    pPlayerPet:AddOptionSlider(L["Scale"], nil, { getterSetter = "unitframes.pet.scale", callback = function() if GwPlayerPetFrame then GwPlayerPetFrame:UpdateSettings() end end, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Size"], dependence =  {["unitframes.pet.enabled"] = true}})


    --TARGET
    p_target:AddOption(ENABLE, L["Enable the target frame replacement."], {getterSetter = "unitframes.target.enabled", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    p_target:AddOption(SHOW_ENEMY_CAST, nil, {getterSetter = "unitframes.target.showCastbar", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.target.enabled"] = true}, group = "castbar"})
    p_target:AddOption(GW.NewSign .. L["Spell Name"], L["Shows the name of the spell being cast on the casting bar."], {getterSetter = "unitframes.target.castingbarShowName", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.target.enabled"] = true}, group = "castbar"})
    p_target:AddOption(GW.NewSign .. L["Cast Timer"], L["Shows the remaining cast time on the casting bar."], {getterSetter = "unitframes.target.castingbarShowTimer", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.target.enabled"] = true}, group = "castbar"})
    p_target:AddOption(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, L["Show health as a numerical value."], {getterSetter = "unitframes.target.healthValue", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.target.enabled"] = true}, group = "healthText"})
    p_target:AddOption(RAID_HEALTH_TEXT_PERC, L["Display health as a percentage. Can be used as well as, or instead of Health Value."], {getterSetter = "unitframes.target.healthValueType", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.target.enabled"] = true}, group = "healthText"})
    p_target:AddOption(L["Shorten health values"], nil, {getterSetter = "unitframes.target.shortValues", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.target.enabled"] = true}, hidden = not GW.Retail, group = "healthText"})
    p_target:AddOption(L["Show Threat"], L["Show Threat"], {getterSetter = "unitframes.target.threatValue", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.target.enabled"] = true}, group = "unitInfo"})
    p_target:AddOption(L["Show Combo Points on Target"], L["Show combo points on target, below the health bar."], {getterSetter = "unitframes.target.hookComboPoints", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.target.enabled"] = true}, group = "unitInfo"})
    p_target:AddOptionDropdown(L["Display additional information (ilvl, pvp level)"], L["Display the average item level, prestige level for friendly units or disable it."], { getterSetter = "unitframes.target.itemLevel", callback = function() GwTargetUnitFrame:ToggleSettings() end, optionsList = unitInfoOptions, optionNames = unitInfoOptionNames, dependence = {["unitframes.target.enabled"] = true}, hidden = GW.Classic, group = "unitInfo"})
    p_target:AddOption(L["Display Portrait Damage"], L["Display Portrait Damage on this frame"], {getterSetter = "unitframes.target.floatingCombatText", callback = function() GwTargetUnitFrame:ToggleTargetFrameCombatFeedback() end, dependence = {["unitframes.target.enabled"] = true}, group = "portrait"})
    p_target:AddOption(L["Invert target frame"], nil, {getterSetter = "unitframes.target.invert", callback = function() GW.ShowRlPopup = true end, dependence = {["unitframes.target.enabled"] = true}, group = "frameAppearance"})
    p_target:AddOption(L["Show alternative background texture"], nil, {getterSetter = "unitframes.target.altBackground", callback = function() GwTargetUnitFrame:ToggleSettings(); GwTargetTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.target.enabled"] = true}, group = "frameAppearance"})
    p_target:AddOption(CLASS_COLORS, L["Display the class color as the health bar."], {getterSetter = "unitframes.target.classColor", callback = function() GwTargetUnitFrame:ToggleSettings(); GwTargetTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.target.enabled"] = true}, group = "healthBars"})
    p_target:AddOption(L["Show absorb bar"], nil, {getterSetter = "unitframes.target.showAbsorbBar", callback = function() GwTargetUnitFrame:ToggleSettings(); GwTargetTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.target.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "healthBars"})
    p_target:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "unitframes.target.healthBarTexture", callback = function() GwTargetUnitFrame:ToggleSettings() end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["unitframes.target.enabled"] = true}, group = "healthBars"})

    p_target:AddGroupHeader(AURAS)
    p_target:AddOption(BUFFS_ON_TOP, nil, {getterSetter = "unitframes.target.aurasOnTop", callback = function() GwTargetUnitFrame:ToggleSettings() end, groupHeaderName = AURAS, dependence = {["unitframes.target.enabled"] = true}})
    p_target:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "unitframes.target.pandemicHighlight", callback = GW.UpdateAuraOptionRegions, dependence = {["unitframes.target.enabled"] = true}, hidden = not GW.Retail})
    p_target:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "unitframes.target.dispelIcon", callback = GW.UpdateAuraOptionRegions, dependence = {["unitframes.target.enabled"] = true}, hidden = not GW.Retail})
    p_target:AddOptionDropdown(L["Buffs"], L["Display the target's buffs."], { getterSetter = "unitframes.target.buffFilter", callback = function() GwTargetUnitFrame:ToggleSettings() end, optionsList = buffOptions, optionNames = buffOptionNames, dependence = {["unitframes.target.enabled"] = true}, groupHeaderName = AURAS})
    p_target:AddOptionNote(L["Every selected filter narrows the display further - only auras matching all selected filters are shown. No selection shows everything."]
        .. "\n" .. L["Clicking an entry cycles through three states: off (ignored) - check (only auras with this property are shown) - red cross (auras with this property are hidden)."], {
        isVisible = function() return GW.settings.unitframes.target.buffFilter == "advanced" or GW.settings.unitframes.target.debuffFilter == "advanced" end,
        group = "advancedAuraNote",
    })
    p_target:AddOptionDropdown(L["Buffs: Advanced Filtering"], L["Every selected filter narrows the display further - only auras matching all selected filters are shown. No selection shows everything."], { getterSetter = "unitframes.target.buffFilterAdvanced",
        callback = function() GwTargetUnitFrame:ToggleSettings() end,
        optionsList = advancedAuraOptions,
        optionNames = advancedAuraOptionsNames,
        dependence = {["unitframes.target.enabled"] = true, ["unitframes.target.buffFilter"] = {"advanced"}},
        checkbox = true,
        triState = GW.Retail,
        groupHeaderName = AURAS}
    )

    p_target:AddOptionDropdown(L["Debuffs"], L["Display the target's debuffs."], { getterSetter = "unitframes.target.debuffFilter", callback = function() GwTargetUnitFrame:ToggleSettings() end, optionsList = debuffOptions, optionNames = debuffOptionNames, dependence = {["unitframes.target.enabled"] = true}, groupHeaderName = AURAS})
    p_target:AddOptionDropdown(L["Debuffs: Advanced Filtering"], L["Every selected filter narrows the display further - only auras matching all selected filters are shown. No selection shows everything."], { getterSetter = "unitframes.target.debuffFilterAdvanced",
        callback = function() GwTargetUnitFrame:ToggleSettings() end,
        optionsList = advancedAuraOptions,
        optionNames = advancedAuraOptionsNames,
        dependence = {["unitframes.target.enabled"] = true, ["unitframes.target.debuffFilter"] = {"advanced"}},
        checkbox = true,
        triState = GW.Retail,
        groupHeaderName = AURAS}
    )
    p_target:AddOptionSlider(GW.Retail and L["Buff size"] or L["Aura size"], nil, { getterSetter = "unitframes.target.auraSmallSize", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 10, max = 40, decimalNumbers = 0, step = 1, groupHeaderName = AURAS, dependence = {["unitframes.target.enabled"] = true}})
    p_target:AddOptionSlider(GW.Retail and L["Debuff size"] or L["Own aura size"], nil, { getterSetter = "unitframes.target.auraBigSize", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 10, max = 40, decimalNumbers = 0, step = 1, groupHeaderName = AURAS, dependence = {["unitframes.target.enabled"] = true}})
    p_target:AddOptionSpellList(L["Ignored Auras"], L["A list of auras that should never be shown."], { getterSetter = "unitframes.target.ignoredAuras", callback = function() GwTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.target.enabled"] = true}, groupHeaderName = AURAS})
    p_target:AddOptionDropdown(L["Aura Sorting"], L["Set the sorting order of the auras."], {
        getterSetter = "unitframes.target.auraSort", callback = function() GwTargetUnitFrame:ToggleSettings() end, optionsList = {"DEFAULT", "EXPIRATION_ASC", "EXPIRATION_DESC", "NAME_ASC", "NAME_DESC"}, optionNames = {DEFAULT, L["Remaining time (ascending)"], L["Remaining time (descending)"], L["Name (ascending)"], L["Name (descending)"]}, dependence = {["unitframes.target.enabled"] = true}, groupHeaderName = AURAS, hidden = not GW.Retail
    })


    p_target:AddGroupHeader(L["Fader"])
    p_target:AddOptionDropdown(L["Fader"], nil, { getterSetter = "unitframes.target.fader", callback = function() GwTargetUnitFrame:ToggleSettings() end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["unitframes.target.enabled"] = true}, checkbox = true, groupHeaderName = L["Fader"]})
    p_target:AddOptionSlider(L["Smooth"], nil, { getterSetter = "unitframes.target.fader.smooth", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["unitframes.target.enabled"] = true}})
    p_target:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "unitframes.target.fader.minAlpha", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["unitframes.target.enabled"] = true}})
    p_target:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "unitframes.target.fader.maxAlpha", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence =  {["unitframes.target.enabled"] = true}})

    p_target:AddGroupHeader(L["Size"])
    p_target:AddOptionSlider(L["Scale"], nil, { getterSetter = "unitframes.target.scale", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Size"], dependence =  {["unitframes.target.enabled"] = true}})

    p_target:AddOptionSlider(GW.NewSign .. L["Bar Width"], nil, { getterSetter = "unitframes.target.healthBarSize.width", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 150, max = 500, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.target.enabled"] = true}})
    p_target:AddOptionSlider(GW.NewSign .. L["Healthbar Height"], nil, { getterSetter = "unitframes.target.healthBarSize.height", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 5, max = 150, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.target.enabled"] = true}})
    p_target:AddOptionSlider(GW.NewSign .. L["Healthbar Text X-Offset"], nil, { getterSetter = "unitframes.target.healthBarTextOffset.x", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.target.enabled"] = true}})
    p_target:AddOptionSlider(GW.NewSign .. L["Healthbar Text Y-Offset"], nil, { getterSetter = "unitframes.target.healthBarTextOffset.y", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.target.enabled"] = true}})
    p_target:AddOptionSlider(GW.NewSign .. L["Powerbar Height"], nil, { getterSetter = "unitframes.target.powerBarSize.height", callback = function() GwTargetUnitFrame:ToggleSettings() end, min = 1, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.target.enabled"] = true}})


    --TARGET OF TARGET
    pTargetOfTarget:AddOption(SHOW_TARGET_OF_TARGET_TEXT, L["Enable the target of target frame."], {getterSetter = "unitframes.targettarget.enabled", callback = function() GwTargetTargetUnitFrame:ToggleUnitFrame() end, dependence = {["unitframes.target.enabled"] = true}})
    pTargetOfTarget:AddOption(SHOW_ENEMY_CAST, nil, {getterSetter = "unitframes.targettarget.showCastbar", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.target.enabled"] = true, ["unitframes.targettarget.enabled"] = true}})
    pTargetOfTarget:AddOption(L["Show absorb bar"], nil, {getterSetter = "unitframes.targettarget.showAbsorbBar", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.target.enabled"] = true, ["unitframes.targettarget.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath})

    pTargetOfTarget:AddGroupHeader(L["Fader"])
    pTargetOfTarget:AddOptionDropdown(L["Fader"], nil, {
        getterSetter = "unitframes.targettarget.fader", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["unitframes.target.enabled"] = true, ["unitframes.targettarget.enabled"] = true}, checkbox = true, groupHeaderName = L["Fader"]
    })
    pTargetOfTarget:AddOptionSlider(L["Smooth"], nil, { getterSetter = "unitframes.targettarget.fader.smooth", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["unitframes.target.enabled"] = true, ["unitframes.targettarget.enabled"] = true}})
    pTargetOfTarget:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "unitframes.targettarget.fader.minAlpha", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["unitframes.target.enabled"] = true, ["unitframes.targettarget.enabled"] = true}})
    pTargetOfTarget:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "unitframes.targettarget.fader.maxAlpha", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["unitframes.target.enabled"] = true, ["unitframes.targettarget.enabled"] = true}})
    pTargetOfTarget:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "unitframes.targettarget.healthBarTexture", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["unitframes.target.enabled"] = true, ["unitframes.targettarget.enabled"] = true}})

    pTargetOfTarget:AddGroupHeader(L["Size"])
    pTargetOfTarget:AddOptionSlider(L["Scale"], nil, { getterSetter = "unitframes.targettarget.scale", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Size"], dependence = {["unitframes.target.enabled"] = true, ["unitframes.targettarget.enabled"] = true}})
    pTargetOfTarget:AddOptionSlider(GW.NewSign .. L["Bar Width"], nil, { getterSetter = "unitframes.targettarget.healthBarSize.width", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 50, max = 500, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.target.enabled"] = true, ["unitframes.targettarget.enabled"] = true}})
    pTargetOfTarget:AddOptionSlider(GW.NewSign .. L["Healthbar Height"], nil, { getterSetter = "unitframes.targettarget.healthBarSize.height", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 5, max = 150, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.target.enabled"] = true, ["unitframes.targettarget.enabled"] = true}})
    pTargetOfTarget:AddOptionSlider(GW.NewSign .. L["Powerbar Height"], nil, { getterSetter = "unitframes.targettarget.powerBarSize.height", callback = function() GwTargetTargetUnitFrame:ToggleSettings() end, min = 1, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.target.enabled"] = true, ["unitframes.targettarget.enabled"] = true}})

    --FOCUS
    p_focus:AddOption(ENABLE, L["Enable the focus target frame replacement."], {getterSetter = "unitframes.focus.enabled", callback = function() GW.ShowRlPopup = true end, hidden = GW.Classic, isMasterToggle = true})
    p_focus:AddOption(SHOW_ENEMY_CAST, nil, {getterSetter = "unitframes.focus.showCastbar", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic, group = "castbar"})
    p_focus:AddOption(GW.NewSign .. L["Spell Name"], L["Shows the name of the spell being cast on the casting bar."], {getterSetter = "unitframes.focus.castingbarShowName", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic, group = "castbar"})
    p_focus:AddOption(GW.NewSign .. L["Cast Timer"], L["Shows the remaining cast time on the casting bar."], {getterSetter = "unitframes.focus.castingbarShowTimer", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic, group = "castbar"})
    p_focus:AddOption(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, L["Show health as a numerical value."], {getterSetter = "unitframes.focus.healthValue", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic, group = "healthText"})
    p_focus:AddOption(RAID_HEALTH_TEXT_PERC, L["Display health as a percentage. Can be used as well as, or instead of Health Value."], {getterSetter = "unitframes.focus.healthValueType", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic, group = "healthText"})
    p_focus:AddOption(L["Shorten health values"], nil, {getterSetter = "unitframes.focus.shortValues", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic, group = "healthText"})
    p_focus:AddOption(L["Invert focus frame"], nil, {getterSetter = "unitframes.focus.invert", callback = function() GW.ShowRlPopup = true end, dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic, group = "frameAppearance"})
    p_focus:AddOption(L["Show alternative background texture"], nil, {getterSetter = "unitframes.focus.altBackground", callback = function() GwFocusUnitFrame:ToggleSettings(); GwFocusTargetUnitFrame:ToggleUnitFrame() end, dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic, group = "frameAppearance"})
    p_focus:AddOption(CLASS_COLORS, L["Display the class color as the health bar."], {getterSetter = "unitframes.focus.classColor", callback = function() GwFocusUnitFrame:ToggleSettings(); GwFocusTargetUnitFrame:ToggleUnitFrame() end, dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic, group = "healthBars"})
    p_focus:AddOption(L["Show absorb bar"], nil, {getterSetter = "unitframes.focus.showAbsorbBar", callback = function() GwFocusUnitFrame:ToggleSettings(); GwFocusTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath, group = "healthBars"})
    p_focus:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "unitframes.focus.healthBarTexture", callback = function() GwFocusUnitFrame:ToggleSettings() end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic, group = "healthBars"})
    p_focus:AddOptionDropdown(L["Display additional information (ilvl, pvp level)"], L["Display the average item level, prestige level for friendly units or disable it."], { getterSetter = "unitframes.focus.itemLevel", callback = function() GwFocusUnitFrame:ToggleSettings() end, optionsList = unitInfoOptions, optionNames = unitInfoOptionNames, dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic, group = "unitInfo"})

    p_focus:AddGroupHeader(AURAS)
    p_focus:AddOption(BUFFS_ON_TOP, nil, {getterSetter = "unitframes.focus.aurasOnTop", callback = function() GwFocusUnitFrame:ToggleSettings() end, groupHeaderName = AURAS, dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic})
    p_focus:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "unitframes.focus.pandemicHighlight", callback = GW.UpdateAuraOptionRegions, dependence = {["unitframes.focus.enabled"] = true}, hidden = not GW.Retail})
    p_focus:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]}, getterSetter = "unitframes.focus.dispelIcon", callback = GW.UpdateAuraOptionRegions, dependence = {["unitframes.focus.enabled"] = true}, hidden = not GW.Retail})
    p_focus:AddOptionDropdown(L["Buffs"], L["Display the focus's buffs."], { getterSetter = "unitframes.focus.buffFilter", callback = function() GwFocusUnitFrame:ToggleSettings() end, optionsList = buffOptions, optionNames = buffOptionNames, dependence = {["unitframes.focus.enabled"] = true}, groupHeaderName = AURAS})
    p_focus:AddOptionNote(L["Every selected filter narrows the display further - only auras matching all selected filters are shown. No selection shows everything."]
        .. "\n" .. L["Clicking an entry cycles through three states: off (ignored) - check (only auras with this property are shown) - red cross (auras with this property are hidden)."], {
        isVisible = function() return GW.settings.unitframes.focus.buffFilter == "advanced" or GW.settings.unitframes.focus.debuffFilter == "advanced" end,
        group = "advancedAuraNote",
    })
    p_focus:AddOptionDropdown(L["Buffs: Advanced Filtering"], L["Every selected filter narrows the display further - only auras matching all selected filters are shown. No selection shows everything."], { getterSetter = "unitframes.focus.buffFilterAdvanced",
        callback = function() GwFocusUnitFrame:ToggleSettings() end,
        optionsList = advancedAuraOptions,
        optionNames = advancedAuraOptionsNames,
        dependence = {["unitframes.focus.enabled"] = true, ["unitframes.focus.buffFilter"] = {"advanced"}},
        checkbox = true,
        triState = GW.Retail,
        groupHeaderName = AURAS}
    )

    p_focus:AddOptionDropdown(L["Debuffs"], L["Display the focus's debuffs."], { getterSetter = "unitframes.focus.debuffFilter", callback = function() GwFocusUnitFrame:ToggleSettings() end, optionsList = debuffOptions, optionNames = debuffOptionNames, dependence = {["unitframes.focus.enabled"] = true}, groupHeaderName = AURAS})
    p_focus:AddOptionDropdown(L["Debuffs: Advanced Filtering"], L["Every selected filter narrows the display further - only auras matching all selected filters are shown. No selection shows everything."], { getterSetter = "unitframes.focus.debuffFilterAdvanced",
        callback = function() GwFocusUnitFrame:ToggleSettings() end,
        optionsList = advancedAuraOptions,
        optionNames = advancedAuraOptionsNames,
        dependence = {["unitframes.focus.enabled"] = true, ["unitframes.focus.debuffFilter"] = {"advanced"}},
        checkbox = true,
        triState = GW.Retail,
        groupHeaderName = AURAS}
    )
    p_focus:AddOptionSlider(GW.Retail and L["Buff size"] or L["Aura size"], nil, { getterSetter = "unitframes.focus.auraSmallSize", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 10, max = 40, decimalNumbers = 0, step = 1, groupHeaderName = AURAS, dependence = {["unitframes.focus.enabled"] = true}})
    p_focus:AddOptionSlider(GW.Retail and L["Debuff size"] or L["Own aura size"], nil, { getterSetter = "unitframes.focus.auraBigSize", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 10, max = 40, decimalNumbers = 0, step = 1, groupHeaderName = AURAS, dependence = {["unitframes.focus.enabled"] = true}})
    p_focus:AddOptionSpellList(L["Ignored Auras"], L["A list of auras that should never be shown."], { getterSetter = "unitframes.focus.ignoredAuras", callback = function() GwFocusUnitFrame:ToggleSettings() end, dependence = {["unitframes.focus.enabled"] = true}, groupHeaderName = AURAS})
    p_focus:AddOptionDropdown(L["Aura Sorting"], L["Set the sorting order of the auras."], {
        getterSetter = "unitframes.focus.auraSort", callback = function() GwFocusUnitFrame:ToggleSettings() end, optionsList = {"DEFAULT", "EXPIRATION_ASC", "EXPIRATION_DESC", "NAME_ASC", "NAME_DESC"}, optionNames = {DEFAULT, L["Remaining time (ascending)"], L["Remaining time (descending)"], L["Name (ascending)"], L["Name (descending)"]}, dependence = {["unitframes.focus.enabled"] = true}, groupHeaderName = AURAS, hidden = not GW.Retail
    })


    p_focus:AddGroupHeader(L["Fader"], {hidden = GW.Classic})
    p_focus:AddOptionDropdown(L["Fader"], nil, { getterSetter = "unitframes.focus.fader", callback = function() GwFocusUnitFrame:ToggleSettings() end, optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"}, optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, L["Vehicle"], L["Unit Target"], L["Player Target"]}, dependence = {["unitframes.focus.enabled"] = true}, checkbox = true, groupHeaderName = L["Fader"], hidden = GW.Classic})
    p_focus:AddOptionSlider(L["Smooth"], nil, { getterSetter = "unitframes.focus.fader.smooth", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic})
    p_focus:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "unitframes.focus.fader.minAlpha", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic})
    p_focus:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "unitframes.focus.fader.maxAlpha", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic})

    p_focus:AddGroupHeader(L["Size"])
    p_focus:AddOptionSlider(L["Scale"], nil, { getterSetter = "unitframes.focus.scale", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Size"], dependence =  {["unitframes.focus.enabled"] = true}})
    p_focus:AddOptionSlider(GW.NewSign .. L["Bar Width"], nil, { getterSetter = "unitframes.focus.healthBarSize.width", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 150, max = 500, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.focus.enabled"] = true}})
    p_focus:AddOptionSlider(GW.NewSign .. L["Healthbar Height"], nil, { getterSetter = "unitframes.focus.healthBarSize.height", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 5, max = 150, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.focus.enabled"] = true}})
    p_focus:AddOptionSlider(GW.NewSign .. L["Healthbar Text X-Offset"], nil, { getterSetter = "unitframes.focus.healthBarTextOffset.x", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.focus.enabled"] = true}})
    p_focus:AddOptionSlider(GW.NewSign .. L["Healthbar Text Y-Offset"], nil, { getterSetter = "unitframes.focus.healthBarTextOffset.y", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = -100, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.focus.enabled"] = true}})
    p_focus:AddOptionSlider(GW.NewSign .. L["Powerbar Height"], nil, { getterSetter = "unitframes.focus.powerBarSize.height", callback = function() GwFocusUnitFrame:ToggleSettings() end, min = 1, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.focus.enabled"] = true}})

    --TARGET OF FOCUS
    pTargetOfFocus:AddOption(MINIMAP_TRACKING_FOCUS, L["Display the focus target frame."], {getterSetter = "unitframes.focustarget.enabled", callback = function() GwFocusTargetUnitFrame:ToggleUnitFrame() end, dependence = {["unitframes.focus.enabled"] = true}, hidden = GW.Classic})
    pTargetOfFocus:AddOption(SHOW_ENEMY_CAST, nil, {getterSetter = "unitframes.focustarget.showCastbar", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.focus.enabled"] = true, ["unitframes.focustarget.enabled"] = true}, hidden = GW.Classic})
    pTargetOfFocus:AddOption(L["Show absorb bar"], nil, {getterSetter = "unitframes.focustarget.showAbsorbBar", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, dependence = {["unitframes.focus.enabled"] = true, ["unitframes.focustarget.enabled"] = true}, hidden = GW.Classic or GW.TBC or GW.Wrath})

    pTargetOfFocus:AddGroupHeader(L["Fader"], {hidden = GW.Classic})
    pTargetOfFocus:AddOptionDropdown(L["Fader"], nil, {
        getterSetter = "unitframes.focustarget.fader",
        callback = function()
            GwFocusTargetUnitFrame:ToggleSettings()
        end,
        optionsList = {"casting", "combat", "hover", "dynamicflight", "vehicle", "unittarget", "playertarget"},
        optionNames = {L["Casting"], COMBAT, L["Hover"], DYNAMIC_FLIGHT, UNIT_TARGET, L["Vehicle"], L["Unit Target"], L["Player Target"]},
        dependence = {["unitframes.focus.enabled"] = true, ["unitframes.focustarget.enabled"] = true},
        checkbox = true,
        groupHeaderName = L["Fader"],
        hidden = GW.Classic
    })
    pTargetOfFocus:AddOptionSlider(L["Smooth"], nil, { getterSetter = "unitframes.focustarget.fader.smooth", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 0, max = 3, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["unitframes.focus.enabled"] = true, ["unitframes.focustarget.enabled"] = true}, hidden = GW.Classic})
    pTargetOfFocus:AddOptionSlider(L["Min Alpha"], nil, { getterSetter = "unitframes.focustarget.fader.minAlpha", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["unitframes.focus.enabled"] = true, ["unitframes.focustarget.enabled"] = true}, hidden = GW.Classic})
    pTargetOfFocus:AddOptionSlider(L["Max Alpha"], nil, { getterSetter = "unitframes.focustarget.fader.maxAlpha", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 0, max = 1, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Fader"], dependence = {["unitframes.focus.enabled"] = true, ["unitframes.focustarget.enabled"] = true}, hidden = GW.Classic})
    pTargetOfFocus:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "unitframes.focustarget.healthBarTexture", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["unitframes.focus.enabled"] = true, ["unitframes.focustarget.enabled"] = true}, hidden = GW.Classic})

    pTargetOfFocus:AddGroupHeader(L["Size"])
    pTargetOfFocus:AddOptionSlider(L["Scale"], nil, { getterSetter = "unitframes.focustarget.scale", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 0.5, max = 1.5, decimalNumbers = 2, step = 0.01, groupHeaderName = L["Size"], dependence = {["unitframes.focus.enabled"] = true, ["unitframes.focustarget.enabled"] = true}})
    pTargetOfFocus:AddOptionSlider(GW.NewSign .. L["Bar Width"], nil, { getterSetter = "unitframes.focustarget.healthBarSize.width", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 50, max = 500, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.focus.enabled"] = true, ["unitframes.focustarget.enabled"] = true}})
    pTargetOfFocus:AddOptionSlider(GW.NewSign .. L["Healthbar Height"], nil, { getterSetter = "unitframes.focustarget.healthBarSize.height", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 5, max = 150, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.focus.enabled"] = true, ["unitframes.focustarget.enabled"] = true}})
    pTargetOfFocus:AddOptionSlider(GW.NewSign .. L["Powerbar Height"], nil, { getterSetter = "unitframes.focustarget.powerBarSize.height", callback = function() GwFocusTargetUnitFrame:ToggleSettings() end, min = 1, max = 100, decimalNumbers = 0, step = 1, groupHeaderName = L["Size"], dependence = {["unitframes.focus.enabled"] = true, ["unitframes.focustarget.enabled"] = true}})

    -- Party
    -- the whole page depends on {PARTY_FRAMES = true, PARTY_GRID_REPLACES_FRAMES = false};
    -- these two notes name whichever of the two conditions is currently failing
    party:AddOptionNote(format(L["The party grid has taken over: '%s' is enabled under %s, so the stylised party frames are hidden and the settings below have no effect."], USE_RAID_STYLE_PARTY_FRAMES, L["Group Frames"] .. " - " .. L["Party Grid"]), {
        isVisible = function() return IsPartyGridReplacingFrames() end,
        group = "partyPageNote",
    })
    party:AddOptionNote(format(L["The party frames are turned off: enable '%s' below to use them."], ENABLE), {
        isVisible = function() return not IsPartyGridReplacingFrames() and GW.settings.unitframes.party.enabled ~= true end,
        group = "partyPageNote",
    })
    party:AddOption(ENABLE, L["Replace the default UI group frames."], {getterSetter = "unitframes.party.enabled", callback = function() GW.ShowRlPopup = true end, isMasterToggle = true})
    party:AddOption(L["Show both party frames and party grid"], format(L["If enabled, this will show both the stylised party frames as well as the grid frame. This setting has no effect if '%s' is enabled."], USE_RAID_STYLE_PARTY_FRAMES), {getterSetter = "groupFrames.party.withPartyFrames", callback = function()
        GW.UpdateGridSettings("party", true)
        -- this toggle also decides whether the party grid is displayed, so the preview
        -- button on the party grid page has to follow along
        if GW.UpdatePartyGridPreviewState then GW.UpdatePartyGridPreviewState() end
    end, dependence = {["unitframes.party.enabled"] = true, ["groupFrames.enabled"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false}, group = "frameDisplay"})
    -- deliberately without a dependence: when the grid took over, every other option on
    -- this page is greyed out and this link is the only thing left that still explains why
    party:AddOptionButton(L["Go to the party grid settings"], L["The stylised party frames and the raid style party grid are two separate displays, each with its own settings page. This opens the other one."], {
        callback = function() GW.GetSettingsTabFrame():OpenSettingsToPanel("raid_party") end,
        forceNewLine = true,
        group = "partyPageLink",
    })
    party:AddOption(SHOW_BUFFS, nil, {getterSetter = "unitframes.party.showBuffs", callback = GW.UpdatePartyFrames, dependence = {["unitframes.party.enabled"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false}, group = "playerAuras"})
    party:AddOption(SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, {getterSetter = "unitframes.party.showDebuffs", callback = GW.UpdatePartyFrames, dependence = {["unitframes.party.enabled"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false}, group = "playerAuras"})
    party:AddOption(DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispel."], {getterSetter = "unitframes.party.onlyDispellableDebuffs", callback = GW.UpdatePartyFrames, dependence = {["unitframes.party.enabled"] = true, ["unitframes.party.showDebuffs"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false}, group = "playerAuras"})
    party:AddOption(GW.NewSign .. L["Pandemic Highlight"], L["Highlights your own auras while they are inside their refresh window, where refreshing adds the remaining time on top."], {getterSetter = "unitframes.party.pandemicHighlight", callback = GW.UpdateAuraOptionRegions, dependence = {["unitframes.party.enabled"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false}, hidden = not GW.Retail, group = "playerAuras"})
    party:AddOptionDropdown(GW.NewSign .. L["Show Dispel Type Icon"], L["Shows the dispel type as a small icon in the corner of the aura - on every aura with a dispel type, or only on those your group can dispel."], {optionsList = {"OFF", "ALL", "DISPELLABLE"}, optionNames = {OFF, ALL, L["Only Dispellable"]},
        getterSetter = "unitframes.party.dispelIcon", callback = GW.UpdateAuraOptionRegions, dependence = {["unitframes.party.enabled"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false}, hidden = not GW.Retail, group = "playerAuras"
    })
    party:AddOptionSpellList(L["Ignored Auras"], L["A list of auras that should never be shown."], { getterSetter = "unitframes.party.ignoredAuras", callback = GW.UpdatePartyFrames, dependence = {["unitframes.party.enabled"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false}, group = "playerAuras"})
    party:AddOption(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], {getterSetter = "unitframes.party.showRaidInstanceDebuffs", callback = GW.UpdatePartyFrames, dependence = {["unitframes.party.enabled"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false}, group = "playerAuras"})
    party:AddOption(L["Player frame in group"], L["Show your player frame as part of the group"], {getterSetter = "unitframes.party.showPlayer", callback = function() GW.UpdatePlayerInPartySetting() end, dependence = {["unitframes.party.enabled"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false}, group = "frameContent"})
    party:AddOption(COMPACT_UNIT_FRAME_PROFILE_DISPLAYPETS, nil, {getterSetter = "unitframes.party.showPets", callback = function() GW.UpdatePartyPetVisibility() end, dependence = {["unitframes.party.enabled"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false}, group = "frameContent"});
    party:AddOption(L["Shorten health values"], nil, {getterSetter = "unitframes.party.shortHealthValues", callback = GW.UpdatePartyFrames, dependence = {["unitframes.party.enabled"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false}, group = "healthText"});
    party:AddOptionDropdown(COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, nil, {
        getterSetter = "unitframes.party.healthValue", callback = GW.UpdatePartyFrames, optionsList = {"NONE", "PREC", "HEALTH", "LOSTHEALTH"}, optionNames = {COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH}, dependence = {["unitframes.party.enabled"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false}, group = "healthText"
    })
    party:AddOptionDropdown(L["Orientation"], L["Choose whether party frames are arranged vertically or horizontally."], { getterSetter = "unitframes.party.orientation", callback = function() GW.UpdatePartyLayout() end, optionsList = {"VERTICAL", "HORIZONTAL"}, optionNames = {L["Vertical"], L["Horizontal"]}, dependence = {["unitframes.party.enabled"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false}, group = "layout"})
    party:AddOptionSlider(L["Frame Spacing"], nil, { getterSetter = "unitframes.party.spacing", callback = function() GW.UpdatePartyLayout() end, min = 0, max = 100, decimalNumbers = 0, step = 1, dependence = {["unitframes.party.enabled"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false}, group = "layout"})
    party:AddOptionSlider(L["Aura size"], nil, { getterSetter = "unitframes.party.auraIconSize", callback = GW.UpdatePartyFrames, min = 10, max = 40, decimalNumbers = 0, step = 2, dependence = {["unitframes.party.enabled"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false, ["unitframes.party.orientation"] = {"VERTICAL"}}, group = "layout"})
    party:AddOptionDropdown(L["Healthbar texture"], nil, { getterSetter = "unitframes.party.healthBarTexture", callback = function() GW.UpdatePartyFrames() end, optionsList = statusBarTexturesOptions, optionNames = statusBarTexturesLables, dependence = {["unitframes.party.enabled"] = true, ["PARTY_GRID_REPLACES_FRAMES"] = false}, group = "healthBars"})

    sWindow:AddSettingsPanel(p, UNITFRAME_LABEL, L["Edit general unitframe settings."], panels)
end
GW.LoadTargetPanel = LoadTargetPanel
