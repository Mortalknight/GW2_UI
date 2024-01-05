local _, GW = ...

local function GW2_GridMaintankStyleRegister(self)
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

    self.bg = self:CreateTexture(nil, 'BORDER')
    self.bg:SetPoint("TOPLEFT", 0, 0)
    self.bg:SetPoint("BOTTOMRIGHT", 0, 0)
    self.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
    self.bg:SetVertexColor(0, 0, 0, 1)
    self.bg.multiplier = 1

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
GW.GW2_GridMaintankStyleRegister = GW2_GridMaintankStyleRegister

local function UpdateGridMaintankFrame(frame)
    -- set frame settings
    frame.useClassColor = GW.GridSettings.raidClassColor.TANK
    frame.showResscoureBar = GW.GridSettings.raidUnitPowerBar.TANK
    frame.showRealmFlags = GW.GridSettings.raidUnitFlag.TANK
    frame.healthStringFormat = GW.GridSettings.raidUnitHealthString.TANK
    frame.showTargetmarker = GW.GridSettings.raidUnitMarkers.TANK
    frame.unitWidth = tonumber(GW.GridSettings.raidWidth.TANK)
    frame.unitHeight = tonumber(GW.GridSettings.raidHeight.TANK)
    frame.raidShowImportendInstanceDebuffs = GW.GridSettings.raidShowImportendInstanceDebuffs.TANK
    frame.showAllDebuffs = GW.GridSettings.raidShowDebuffs.TANK
    frame.showOnlyDispelDebuffs = GW.GridSettings.raidShowOnlyDispelDebuffs.TANK
    frame.showImportendInstanceDebuffs = GW.GridSettings.raidShowImportendInstanceDebuffs.TANK
    frame.showAuraTooltipInCombat = GW.GridSettings.raidAuraTooltipInCombat.TANK
    frame.ignoredAuras = GW.GridSettings.ignored
    --frame.missingAuras = GW.GridSettings.missing
    frame.raidIndicators = GW.GridSettings.raidIndicators
    frame.showRaidIndicatorIcon = GW.GridSettings.raidIndicatorIcon
    frame.showRaidIndicatorTimer = GW.GridSettings.raidIndicatorTime
    frame.raidDebuffScale = GW.GridSettings.raidDebuffScale
    frame.raidDispelDebuffScale = GW.GridSettings.raidDispelDebuffScale
    frame.showRoleIcon = GW.GridSettings.showRoleIcon.TANK
    frame.showTankIcon = GW.GridSettings.showTankIcon.TANK
    frame.showLeaderAssistIcon = GW.GridSettings.showLeaderAssistIcon.TANK

    if not InCombatLockdown() then
        frame:SetSize(frame.unitWidth, frame.unitHeight)
        frame:ClearAllPoints()

        if GW.GridSettings.enabled.TANK and not frame:IsEnabled() then
            frame:Enable()
        elseif not GW.GridSettings.enabled.TANK and frame:IsEnabled() then
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
    GW.Update_RangeIndicator(frame)

    frame:UpdateAllElements("Gw2_UpdateAllElements")
end
GW.UpdateGridMaintankFrame = UpdateGridMaintankFrame
