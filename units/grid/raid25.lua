local _, GW = ...

local function GW2_GridRaid25StyleRegister(self)
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
    self.Range = GW.Construct_RangeIndicator(self)

    return self
end
GW.GW2_GridRaid25StyleRegister = GW2_GridRaid25StyleRegister

local function UpdateGridRaid25Frame(frame)
    -- set frame settings
    frame.useClassColor = GW.GridSettings.raidClassColor.RAID25
    frame.showResscoureBar = GW.GridSettings.raidUnitPowerBar.RAID25
    frame.showRealmFlags = GW.GridSettings.raidUnitFlag.RAID25
    frame.healthStringFormat = GW.GridSettings.raidUnitHealthString.RAID25
    frame.showTargetmarker = GW.GridSettings.raidUnitMarkers.RAID25
    frame.unitWidth = tonumber(GW.GridSettings.raidWidth.RAID25)
    frame.unitHeight = tonumber(GW.GridSettings.raidHeight.RAID25)
    frame.raidShowImportendInstanceDebuffs = GW.GridSettings.raidShowImportendInstanceDebuffs.RAID25
    frame.showAllDebuffs = GW.GridSettings.raidShowDebuffs.RAID25
    frame.showOnlyDispelDebuffs = GW.GridSettings.raidShowOnlyDispelDebuffs.RAID25
    frame.showImportendInstanceDebuffs = GW.GridSettings.raidShowImportendInstanceDebuffs.RAID25
    frame.showAuraTooltipInCombat = GW.GridSettings.raidAuraTooltipInCombat.RAID25
    frame.ignoredAuras = GW.GridSettings.ignored
    frame.missingAuras = GW.GridSettings.missing
    frame.raidIndicators = GW.GridSettings.raidIndicators
    frame.showRaidIndicatorIcon = GW.GridSettings.raidIndicatorIcon
    frame.showRaidIndicatorTimer = GW.GridSettings.raidIndicatorTime
    frame.raidDebuffScale = GW.GridSettings.raidDebuffScale
    frame.raidDispelDebuffScale = GW.GridSettings.raidDispelDebuffScale
    frame.showRoleIcon = GW.GridSettings.showRoleIcon.RAID25
    frame.showTankIcon = GW.GridSettings.showTankIcon.RAID25
    frame.showLeaderAssistIcon = GW.GridSettings.showLeaderAssistIcon.RAID25

    if not InCombatLockdown() then
        frame:SetSize(frame.unitWidth, frame.unitHeight)
        frame:ClearAllPoints()

        if GW.GridSettings.enabled.RAID25 and not frame:IsEnabled() then
            frame:Enable()
        elseif not GW.GridSettings.enabled.RAID25 and frame:IsEnabled() then
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
    GW.Update_RangeIndicator(frame)

    frame:UpdateAllElements("Gw2_UpdateAllElements")
end
GW.UpdateGridRaid25Frame = UpdateGridRaid25Frame
