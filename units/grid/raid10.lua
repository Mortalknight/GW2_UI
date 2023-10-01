local _, GW = ...

local function GW2_GridRaid10StyleRegister(self)
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
GW.GW2_GridRaid10StyleRegister = GW2_GridRaid10StyleRegister

local function UpdateGridRaid10Frame(frame)
    -- set frame settings
    frame.useClassColor = GW.GridSettings.raidClassColor.RAID10
    frame.showResscoureBar = GW.GridSettings.raidUnitPowerBar.RAID10
    frame.showRealmFlags = GW.GridSettings.raidUnitFlag.RAID10
    frame.healthStringFormat = GW.GridSettings.raidUnitHealthString.RAID10
    frame.showTargetmarker = GW.GridSettings.raidUnitMarkers.RAID10
    frame.unitWidth = tonumber(GW.GridSettings.raidWidth.RAID10)
    frame.unitHeight = tonumber(GW.GridSettings.raidHeight.RAID10)
    frame.raidShowImportendInstanceDebuffs = GW.GridSettings.raidShowImportendInstanceDebuffs.RAID10
    frame.showAllDebuffs = GW.GridSettings.raidShowDebuffs.RAID10
    frame.showOnlyDispelDebuffs = GW.GridSettings.raidShowOnlyDispelDebuffs.RAID10
    frame.showImportendInstanceDebuffs = GW.GridSettings.raidShowImportendInstanceDebuffs.RAID10
    frame.showAuraTooltipInCombat = GW.GridSettings.raidAuraTooltipInCombat.RAID10
    frame.ignoredAuras = GW.GridSettings.ignored
    frame.missingAuras = GW.GridSettings.missing
    frame.raidIndicators = GW.GridSettings.raidIndicators
    frame.showRaidIndicatorIcon = GW.GridSettings.raidIndicatorIcon
    frame.showRaidIndicatorTimer = GW.GridSettings.raidIndicatorTime
    frame.raidDebuffScale = GW.GridSettings.raidDebuffScale
    frame.raidDispelDebuffScale = GW.GridSettings.raidDispelDebuffScale

    if GW.GridSettings.enabled.RAID10 and not frame:IsEnabled() then
		frame:Enable()
	elseif not GW.GridSettings.enabled.RAID10 and frame:IsEnabled() then
		frame:Disable()
	end

    if not InCombatLockdown() then
        frame:SetSize(frame.unitWidth, frame.unitHeight)
        frame:ClearAllPoints()
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
GW.UpdateGridRaid10Frame = UpdateGridRaid10Frame
