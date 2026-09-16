---@class GW2
local GW = select(2, ...)

local function GridRaid40StyleRegister(self)
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
GW.GridRaid40StyleRegister = GridRaid40StyleRegister

local function UpdateGridRaid40Frame(frame)
    -- set frame settings
    frame.useClassColor = GW.settings.groupFrames.raid40.classColor
    frame.hideClassIcon = GW.settings.groupFrames.raid40.hideClassIcon
    frame.showResscoureBar = GW.settings.groupFrames.raid40.showPowerBar
    frame.showRealmFlags = GW.settings.groupFrames.raid40.unitFlags
    frame.healthStringFormat = GW.settings.groupFrames.raid40.unitHealth
    frame.showTargetmarker = GW.settings.groupFrames.raid40.unitMarkers
    frame.unitWidth = tonumber(GW.settings.groupFrames.raid40.width)
    frame.unitHeight = tonumber(GW.settings.groupFrames.raid40.height)
    frame.showAuraTooltipInCombat = GW.settings.groupFrames.raid40.auraTooltipInCombat
    frame.missingAuras = GW.FillTable({}, true, strsplit(",", (GW.settings.playerAuras.missingAuras:trim():gsub("%s*,%s*", ","))))
    frame.shortendHealthValue = GW.settings.groupFrames.raid40.shortHealthValues
    frame.showAbsorbBar = GW.settings.groupFrames.raid40.showAbsorbBar

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
    frame.showRoleIcon = GW.settings.groupFrames.raid40.showRoleIcon
    frame.showTankIcon = GW.settings.groupFrames.raid40.showTankIcon
    frame.showLeaderAssistIcon = GW.settings.groupFrames.raid40.showLeaderIcon
    frame.healthBarTexture = GW.settings.groupFrames.raid40.healthBarTexture

    frame.raidShowImportantInstanceDebuffs = GW.settings.groupFrames.raid40.showRaidInstanceDebuffs

    frame.showDebuffs = GW.settings.groupFrames.raid40.showDebuffs
    frame.showOnlyDispelDebuffs = GW.settings.groupFrames.raid40.onlyDispellableDebuffs

    frame.showBuffs = GW.settings.groupFrames.raid40.showBuffs

    -- retail filtering
    frame.debuffFilters = GW.settings.groupFrames.raid40.debuffFilter
    frame.buffFilters = GW.settings.groupFrames.raid40.buffFilter
    frame.ignoredAuraSpellIDs = GW.settings.groupFrames.raid40.ignoredAuras -- consumed by the retail containers AND the classic aura filter
    frame.pandemicHighlight = GW.settings.groupFrames.raid40.pandemicHighlight
    frame.showDispelIcon = GW.settings.groupFrames.raid40.dispelIcon

    if not InCombatLockdown() then
        frame:SetSize(frame.unitWidth, frame.unitHeight)
        if not frame.isForced then
            frame:ClearAllPoints()
        end

        local enabled = GW.settings.groupFrames.enabled and GW.settings.groupFrames.raid40.enabled
        if enabled and not frame:IsEnabled() then
            frame:Enable()
        elseif not enabled and frame:IsEnabled() then
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
    GW.Update_Faderframe(frame, "raid40")

    frame:UpdateAllElements("Gw2_UpdateAllElements")
end
GW.UpdateGridRaid40Frame = UpdateGridRaid40Frame
