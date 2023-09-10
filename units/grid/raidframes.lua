local _, GW = ...

local function GW2_GridRaid40StyleRegister(self)
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
    self.Range = {
        insideAlpha = 1,
        outsideAlpha = 1/2,
    }

    return self
end
GW.GW2_GridRaid40StyleRegister = GW2_GridRaid40StyleRegister

local function UpdateGridRaid40Frame(frame)
    -- set frame settings
    frame.useClassColor = GW.GridSettings.raidClassColor.RAID40
    frame.showResscoureBar = GW.GridSettings.raidUnitPowerBar.RAID40
    frame.showRealmFlags = GW.GridSettings.raidUnitFlag.RAID40
    frame.healthStringFormat = GW.GridSettings.raidUnitHealthString.RAID40
    frame.showTargetmarker = GW.GridSettings.raidUnitMarkers.RAID40
    frame.unitWidth = tonumber(GW.GridSettings.raidWidth.RAID40)
    frame.unitHeight = tonumber(GW.GridSettings.raidHeight.RAID40)
    frame.raidShowImportendInstanceDebuffs = GW.GridSettings.raidShowImportendInstanceDebuffs.RAID40
    frame.showAllDebuffs = GW.GridSettings.raidShowDebuffs.RAID40
    frame.showOnlyDispelDebuffs = GW.GridSettings.raidShowOnlyDispelDebuffs.RAID40
    frame.showImportendInstanceDebuffs = GW.GridSettings.raidShowImportendInstanceDebuffs.RAID40
    frame.showAuraTooltipInCombat = GW.GridSettings.raidAuraTooltipInCombat.RAID40
    frame.ignoredAuras = GW.GridSettings.ignored
    frame.missingAuras = GW.GridSettings.missing
    frame.raidIndicators = GW.GridSettings.raidIndicators
    frame.showRaidIndicatorIcon = GW.GridSettings.raidIndicatorIcon
    frame.showRaidIndicatorTimer = GW.GridSettings.raidIndicatorTime
    frame.raidDebuffScale = GW.GridSettings.raidDebuffScale
    frame.raidDispelDebuffScale = GW.GridSettings.raidDispelDebuffScale

    frame:SetSize(frame.unitWidth, frame.unitHeight)
    frame:ClearAllPoints()

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

    frame:UpdateAllElements("RefreshUnit")
end
GW.UpdateGridRaid40Frame = UpdateGridRaid40Frame
