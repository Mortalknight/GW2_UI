local _, GW = ...

local function GridPartyPetStyleRegister(self)
    self:RegisterForClicks('AnyUp')
    self:SetScript("OnLeave", function()
        GameTooltip_Hide()
    end)
    self:SetScript(
        "OnEnter",
        function(self)
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetUnit(self.unit)
            GameTooltip:Show()
        end
    )

    self.RaisedElementParent = GW.CreateRaisedElement(self)
	self.Health = GW.Construct_HealthBar(self, true)
    self.Name = GW.Construct_NameText(self)
    self.HealthValueText = GW.Construct_HealtValueText(self)
    self.Power = GW.Construct_PowerBar(self)
    self.MiddleIcon = GW.Construct_MiddleIcon(self)
    self.ThreatIndicator = GW.Construct_ThreathIndicator(self)
    self.ReadyCheckIndicator = GW.Construct_ReadyCheck(self)
    self.SummonIndicator = GW.Construct_SummonIcon(self)
    self.ResurrectIndicator = GW.Construct_ResurrectionIcon(self)
    GW.Construct_PredictionBar(self) -- creates only the function regestration
    self.Auras = GW.Construct_Auras(self)
    self.MissingBuffFrame = GW.Construct_MissingAuraIndicator(self)
    self.Fader = GW.Construct_Faderframe(self)

    self:DisableElement("MiddleIcon")

    return self
end
GW.GridPartyPetStyleRegister = GridPartyPetStyleRegister

local function UpdateGridPartyPetFrame(frame)
    -- set frame settings
    frame.useClassColor = GW.settings.PARTY_CLASS_COLOR_PET
    frame.hideClassIcon = GW.settings.PARTY_HIDE_CLASS_ICON_PET
    frame.showResscoureBar = GW.settings.pet_show_powerbar
    frame.showRealmFlags = GW.settings.PARTY_UNIT_FLAGS_PET
    frame.healthStringFormat = GW.settings.PARTY_UNIT_HEALTH_PET
    frame.showTargetmarker = GW.settings.PARTY_UNIT_MARKERS_PET
    frame.unitWidth = tonumber(GW.settings.PARTY_WIDTH_PET)
    frame.unitHeight = tonumber(GW.settings.PARTY_HEIGHT_PET)
    frame.PARTYShowImportantInstanceDebuffs = GW.settings.PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PET
    frame.showDebuffs = GW.settings.PARTY_SHOW_DEBUFFS_PET
    frame.showOnlyDispelDebuffs = GW.settings.PARTY_ONLY_DISPELL_DEBUFFS_PET
    frame.showBuffs = GW.settings.PARTY_PET_SHOW_BUFFS
    frame.showAuraTooltipInCombat = GW.settings.PARTY_AURA_TOOLTIP_INCOMBAT_PET
    frame.ignoredAuras = GW.FillTable({}, true, strsplit(",", (GW.settings.AURAS_IGNORED:trim():gsub("%s*,%s*", ","))))
    --frame.missingAuras = GW.FillTable({}, true, strsplit(",", (GW.settings.AURAS_MISSING:trim():gsub("%s*,%s*", ","))))
    frame.shortendHealthValue = GW.settings.PARTY_SHORT_HEALTH_VALUES_PET
    frame.showAbsorbBar = GW.settings.PARTY_SHOW_ABSORB_BAR_PET

    frame.raidIndicators = {}
    for _, pos in ipairs(GW.INDICATORS) do
        frame.raidIndicators[pos] = GW.settings["INDICATOR_" .. pos]
    end
    frame.showRaidIndicatorIcon = GW.settings.INDICATORS_ICON
    frame.showRaidIndicatorTimer = GW.settings.INDICATORS_TIME
    frame.raidDebuffScale = GW.settings.RAIDDEBUFFS_Scale
    frame.raidDispelDebuffScale = GW.settings.DISPELL_DEBUFFS_Scale
    frame.showRoleIcon = GW.settings.PARTY_SHOW_ROLE_ICON_PET
    frame.showTankIcon = GW.settings.PARTY_SHOW_TANK_ICON_PET
    frame.showLeaderAssistIcon = GW.settings.PARTY_SHOW_LEADER_ICON_PET

    -- retail filtering
    frame.debuffFilters = GW.settings.PARTY_PET_DEBUFF_FILTER
    frame.buffFilters = GW.settings.PARTY_PET_BUFF_FILTER

    if not InCombatLockdown() then
        frame:DisableElement("MiddleIcon")
        frame:SetSize(frame.unitWidth, frame.unitHeight)
        frame:ClearAllPoints()

        if GW.settings.PARTY_PET_FRAMES_ENABLED and not frame:IsEnabled() then
            frame:Enable()
        elseif not GW.settings.PARTY_PET_FRAMES_ENABLED and frame:IsEnabled() then
            frame:Disable()
        end
    end

    GW.Update_Healtbar(frame)
    GW.Update_Powerbar(frame)
    GW.UpdateNameSettings(frame)
    GW.UpdateHealtValueTextSettings(frame)
    GW.UpdateMiddleIconSettings(frame)
    GW.UpdateThreathIndicatorSettings(frame)
    GW.UpdateReadyCheckSettings(frame)
    GW.UpdateSummonIconSettings(frame)
    GW.UpdateResurrectionIconSettings(frame)
    GW.Update_PredictionBars(frame)
    GW.UpdateAurasSettings(frame)
    GW.Update_MissingAuraIndicator(frame)
    GW.Update_Faderframe(frame, "gridPartyPet")

    frame:UpdateAllElements("Gw2_UpdateAllElements")
end
GW.UpdateGridPartyPetFrame = UpdateGridPartyPetFrame
