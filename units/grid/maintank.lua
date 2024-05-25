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
    frame.useClassColor = GW.GetSetting("RAID_CLASS_COLOR_TANK")
    frame.showResscoureBar = GW.GetSetting("RAID_POWER_BARS_TANK")
    frame.healthStringFormat = GW.GetSetting("RAID_UNIT_HEALTH_TANK")
    frame.showTargetmarker = GW.GetSetting("RAID_UNIT_MARKERS_TANK")
    frame.unitWidth = tonumber(GW.GetSetting("RAID_WIDTH_TANK"))
    frame.unitHeight = tonumber(GW.GetSetting("RAID_HEIGHT_TANK"))
    frame.raidShowImportendInstanceDebuffs = GW.GetSetting("RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_TANK")
    frame.showAllDebuffs = GW.GetSetting("RAID_SHOW_DEBUFFS_TANK")
    frame.showOnlyDispelDebuffs = GW.GetSetting("RAID_ONLY_DISPELL_DEBUFFS_TANK")
    frame.showAuraTooltipInCombat = GW.GetSetting("RAID_AURA_TOOLTIP_INCOMBAT_TANK")
    frame.ignoredAuras = GW.FillTable({}, true, strsplit(",", (GW.GetSetting("AURAS_IGNORED"):trim():gsub("%s*,%s*", ","))))
    --frame.missingAuras = GW.FillTable({}, true, strsplit(",", (GW.GetSetting("AURAS_MISSING"):trim():gsub("%s*,%s*", ","))))

    frame.raidIndicators = {}
    for _, pos in ipairs(GW.INDICATORS) do
        frame.raidIndicators[pos] = GW.GetSetting("INDICATOR_" .. pos)
    end
    frame.showRaidIndicatorIcon = GW.GetSetting("INDICATORS_ICON")
    frame.showRaidIndicatorTimer = GW.GetSetting("INDICATORS_TIME")
    frame.raidDebuffScale = GW.GetSetting("RAIDDEBUFFS_Scale")
    frame.raidDispelDebuffScale = GW.GetSetting("DISPELL_DEBUFFS_Scale")
    frame.showRoleIcon = GW.GetSetting("RAID_SHOW_ROLE_ICON_TANK")
    frame.showTankIcon = GW.GetSetting("RAID_SHOW_TANK_ICON_TANK")
    frame.showLeaderAssistIcon = GW.GetSetting("RAID_SHOW_LEADER_ICON_TANK")

    if not InCombatLockdown() then
        frame:SetSize(frame.unitWidth, frame.unitHeight)
        frame:ClearAllPoints()

        if GW.GetSetting("RAID_MAINTANK_FRAMES_ENABLED") and not frame:IsEnabled() then
            frame:Enable()
        elseif not GW.GetSetting("RAID_MAINTANK_FRAMES_ENABLED") and frame:IsEnabled() then
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
