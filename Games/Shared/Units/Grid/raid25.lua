---@class GW2
local GW = select(2, ...)

local function GridRaid25StyleRegister(self)
    self:RegisterForClicks('AnyUp')
    self:SetScript("OnLeave", function()
        GameTooltip_Hide()
    end)
    self:SetScript(
        "OnEnter",
        function(self)
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetUnit(self.__unit)
            GameTooltip:Show()
        end
    )

    self.RaisedElementParent = GW.CreateRaisedElement(self)
	self.Health = GW.Construct_HealthBar(self, true)
    self.Name = GW.Construct_NameText(self)
    self.HealthValueText = GW.Construct_HealthValueText(self)
    self.Power = GW.Construct_PowerBar(self)
    self.MiddleIcon = GW.Construct_MiddleIcon(self)
    self.ThreatIndicator = GW.Construct_ThreatIndicator(self)
    self.ReadyCheckIndicator = GW.Construct_ReadyCheck(self)
    self.SummonIndicator = GW.Construct_SummonIcon(self)
    self.ResurrectIndicator = GW.Construct_ResurrectionIcon(self)
    GW.Construct_PredictionBar(self) -- creates only the function regestration
    self.Auras = GW.Construct_Auras(self)
    self.MissingBuffFrame = GW.Construct_MissingAuraIndicator(self)
    self.Fader = GW.Construct_Faderframe(self)

    return self
end
GW.GridRaid25StyleRegister = GridRaid25StyleRegister

local function UpdateGridRaid25Frame(frame)
    -- set frame settings
    frame.useClassColor = GW.settings.groupFrames.raid25.classColor
    frame.hideClassIcon = GW.settings.groupFrames.raid25.hideClassIcon
    frame.showResscoureBar = GW.settings.groupFrames.raid25.showPowerBar
    frame.showRealmFlags = GW.settings.groupFrames.raid25.unitFlags
    frame.healthStringFormat = GW.settings.groupFrames.raid25.unitHealth
    frame.showTargetmarker = GW.settings.groupFrames.raid25.unitMarkers
    frame.unitWidth = tonumber(GW.settings.groupFrames.raid25.width)
    frame.unitHeight = tonumber(GW.settings.groupFrames.raid25.height)
    frame.raidShowImportantInstanceDebuffs = GW.settings.groupFrames.raid25.showRaidInstanceDebuffs
    frame.showDebuffs = GW.settings.groupFrames.raid25.showDebuffs
    frame.showOnlyDispelDebuffs = GW.settings.groupFrames.raid25.onlyDispellableDebuffs
    frame.showBuffs = GW.settings.groupFrames.raid25.showBuffs
    frame.showAuraTooltipInCombat = GW.settings.groupFrames.raid25.auraTooltipInCombat
    frame.missingAuras = GW.FillTable({}, true, strsplit(",", (GW.settings.playerAuras.missingAuras:trim():gsub("%s*,%s*", ","))))
    frame.shortendHealthValue = GW.settings.groupFrames.raid25.shortHealthValues
    frame.showAbsorbBar = GW.settings.groupFrames.raid25.showAbsorbBar
    frame.healthBarTexture = GW.settings.groupFrames.raid25.healthBarTexture

    frame.raidIndicators = {}
    for _, pos in ipairs(GW.INDICATORS) do
        frame.raidIndicators[pos] = GW.settings.groupFrames.indicators.positions[pos]
    end
    frame.showRaidIndicatorIcon = GW.settings.groupFrames.indicators.icon
    frame.showRaidIndicatorTimer = GW.settings.groupFrames.indicators.time
    frame.showRaidIndicatorStacks = GW.settings.groupFrames.indicators.stacks
    frame.raidIndicatorSize = GW.settings.groupFrames.indicators.size
    frame.raidIndicatorBarWidth = GW.settings.groupFrames.indicators.barWidth
    frame.raidDebuffScale = GW.settings.groupFrames.raidDebuffsScale
    frame.raidDispelDebuffScale = GW.settings.groupFrames.dispelDebuffsScale
    frame.showRoleIcon = GW.settings.groupFrames.raid25.showRoleIcon
    frame.showTankIcon = GW.settings.groupFrames.raid25.showTankIcon
    frame.showLeaderAssistIcon = GW.settings.groupFrames.raid25.showLeaderIcon

    -- retail filtering
    frame.debuffFilters = GW.settings.groupFrames.raid25.debuffFilter
    frame.buffFilters = GW.settings.groupFrames.raid25.buffFilter
    frame.ignoredAuraSpellIDs = GW.settings.groupFrames.raid25.ignoredAuras -- consumed by the retail containers AND the classic aura filter
    frame.pandemicHighlight = GW.settings.groupFrames.raid25.pandemicHighlight
    frame.showDispelIcon = GW.settings.groupFrames.raid25.dispelIcon

    if not InCombatLockdown() then
        frame:SetSize(frame.unitWidth, frame.unitHeight)
        if not frame.isForced then
            frame:ClearAllPoints()
        end

        if GW.settings.groupFrames.raid25.enabled and not frame:IsEnabled() then
            frame:Enable()
        elseif not GW.settings.groupFrames.raid25.enabled and frame:IsEnabled() then
            frame:Disable()
        end
    end

    GW.Update_Healthbar(frame)
    GW.Update_Powerbar(frame)
    GW.UpdateNameSettings(frame)
    GW.UpdateHealthValueTextSettings(frame)
    GW.UpdateMiddleIconSettings(frame)
    GW.UpdateThreatIndicatorSettings(frame)
    GW.UpdateReadyCheckSettings(frame)
    GW.UpdateSummonIconSettings(frame)
    GW.UpdateResurrectionIconSettings(frame)
    GW.Update_PredictionBars(frame)
    GW.UpdateAurasSettings(frame)
    GW.Update_MissingAuraIndicator(frame)
    GW.Update_Faderframe(frame, "raid25")

    frame:UpdateAllElements("Gw2_UpdateAllElements")
end
GW.UpdateGridRaid25Frame = UpdateGridRaid25Frame
