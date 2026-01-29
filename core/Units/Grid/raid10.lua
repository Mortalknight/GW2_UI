local _, GW = ...

local function GridRaid10StyleRegister(self)
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
    self.PrivateAuras = GW.Construct_PrivateAura(self)
    self.Fader = GW.Construct_Faderframe(self)

    return self
end
GW.GridRaid10StyleRegister = GridRaid10StyleRegister

local function UpdateGridRaid10Frame(frame)
    -- set frame settings
    frame.useClassColor = GW.settings.RAID_CLASS_COLOR_RAID10
    frame.hideClassIcon = GW.settings.RAID_HIDE_CLASS_ICON_RAID10
    frame.showResscoureBar = GW.settings.raid10_show_powerbar
    frame.showRealmFlags = GW.settings.RAID_UNIT_FLAGS_RAID10
    frame.healthStringFormat = GW.settings.RAID_UNIT_HEALTH_RAID10
    frame.showTargetmarker = GW.settings.RAID_UNIT_MARKERS_RAID10
    frame.unitWidth = tonumber(GW.settings.RAID_WIDTH_RAID10)
    frame.unitHeight = tonumber(GW.settings.RAID_HEIGHT_RAID10)
    frame.raidShowImportantInstanceDebuffs = GW.settings.RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_RAID10
    frame.showDebuffs = GW.settings.RAID_SHOW_DEBUFFS_RAID10
    frame.showOnlyDispelDebuffs = GW.settings.RAID_ONLY_DISPELL_DEBUFFS_RAID10
    frame.showAuraTooltipInCombat = GW.settings.RAID_AURA_TOOLTIP_INCOMBAT_RAID10
    frame.ignoredAuras = GW.FillTable({}, true, strsplit(",", (GW.settings.AURAS_IGNORED:trim():gsub("%s*,%s*", ","))))
    frame.missingAuras = GW.FillTable({}, true, strsplit(",", (GW.settings.AURAS_MISSING:trim():gsub("%s*,%s*", ","))))
    frame.shortendHealthValue = GW.settings.RAID_SHORT_HEALTH_VALUES_RAID10
    frame.showAbsorbBar = GW.settings.RAID_SHOW_ABSORB_BAR_RAID10

    frame.raidIndicators = {}
    for _, pos in ipairs(GW.INDICATORS) do
        frame.raidIndicators[pos] = GW.settings["INDICATOR_" .. pos]
    end
    frame.showRaidIndicatorIcon = GW.settings.INDICATORS_ICON
    frame.showRaidIndicatorTimer = GW.settings.INDICATORS_TIME
    frame.raidDebuffScale = GW.settings.RAIDDEBUFFS_Scale
    frame.raidDispelDebuffScale = GW.settings.DISPELL_DEBUFFS_Scale
    frame.showRoleIcon = GW.settings.RAID_SHOW_ROLE_ICON_RAID10
    frame.showTankIcon = GW.settings.RAID_SHOW_TANK_ICON_RAID10
    frame.showLeaderAssistIcon = GW.settings.RAID_SHOW_LEADER_ICON_RAID10

    -- retail filtering
    frame.showPlayerDebuffs = GW.settings.RAID_10_AURAS.playerDebuff
    frame.showRaidDebuffs = GW.settings.RAID_10_AURAS.raidDebuff
    frame.showPlayerBuffs = GW.settings.RAID_10_AURAS.playerBuff
    frame.showRaidBuffs = GW.settings.RAID_10_AURAS.raidBuff
    frame.showDefensiveBuffs  = GW.settings.RAID_10_AURAS.defensiveBuff

    if not InCombatLockdown() then
        frame:SetSize(frame.unitWidth, frame.unitHeight)
        frame:ClearAllPoints()

        if GW.settings.RAID10_ENABLED and not frame:IsEnabled() then
            frame:Enable()
        elseif not GW.settings.RAID10_ENABLED and frame:IsEnabled() then
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
    GW.UpdatePrivateAurasSettings(frame)
    GW.Update_Faderframe(frame, "grid10")

    frame:UpdateAllElements("Gw2_UpdateAllElements")
end
GW.UpdateGridRaid10Frame = UpdateGridRaid10Frame
