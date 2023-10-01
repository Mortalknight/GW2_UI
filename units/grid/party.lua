local _, GW = ...

local function GW2_GridPartyStyleRegister(self)
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
    self.Range = GW.Construct_RangeIndicator(self)

    return self
end
GW.GW2_GridPartyStyleRegister = GW2_GridPartyStyleRegister

local function UpdateGridPartyFrame(frame)
    -- set frame settings
    frame.useClassColor = GW.GridSettings.raidClassColor.PARTY
    frame.showResscoureBar = GW.GridSettings.raidUnitPowerBar.PARTY
    frame.showRealmFlags = GW.GridSettings.raidUnitFlag.PARTY
    frame.healthStringFormat = GW.GridSettings.raidUnitHealthString.PARTY
    frame.showTargetmarker = GW.GridSettings.raidUnitMarkers.PARTY
    frame.unitWidth = tonumber(GW.GridSettings.raidWidth.PARTY)
    frame.unitHeight = tonumber(GW.GridSettings.raidHeight.PARTY)
    frame.raidShowImportendInstanceDebuffs = GW.GridSettings.raidShowImportendInstanceDebuffs.PARTY
    frame.showAllDebuffs = GW.GridSettings.raidShowDebuffs.PARTY
    frame.showOnlyDispelDebuffs = GW.GridSettings.raidShowOnlyDispelDebuffs.PARTY
    frame.showImportendInstanceDebuffs = GW.GridSettings.raidShowImportendInstanceDebuffs.PARTY
    frame.showAuraTooltipInCombat = GW.GridSettings.raidAuraTooltipInCombat.PARTY
    frame.ignoredAuras = GW.GridSettings.ignored
    frame.missingAuras = GW.GridSettings.missing
    frame.raidIndicators = GW.GridSettings.raidIndicators
    frame.showRaidIndicatorIcon = GW.GridSettings.raidIndicatorIcon
    frame.showRaidIndicatorTimer = GW.GridSettings.raidIndicatorTime
    frame.raidDebuffScale = GW.GridSettings.raidDebuffScale
    frame.raidDispelDebuffScale = GW.GridSettings.raidDispelDebuffScale

    if GW.GridSettings.enabled.PARTY and not frame:IsEnabled() then
		frame:Enable()
	elseif not GW.GridSettings.enabled.PARTY and frame:IsEnabled() then
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
    GW.Update_RangeIndicator(frame)

    frame:UpdateAllElements("Gw2_UpdateAllElements")
end
GW.UpdateGridPartyFrame = UpdateGridPartyFrame
