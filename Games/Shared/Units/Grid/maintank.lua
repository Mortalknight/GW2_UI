---@class GW2
local GW = select(2, ...)

local function GridMaintankStyleRegister(self)
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
GW.GridMaintankStyleRegister = GridMaintankStyleRegister

local function UpdateGridMaintankFrame(frame)
    -- set frame settings
    frame.useClassColor = GW.settings.groupFrames.maintank.classColor
    frame.hideClassIcon = GW.settings.groupFrames.maintank.hideClassIcon
    frame.showResscoureBar = GW.settings.groupFrames.maintank.showPowerBar
    frame.showRealmFlags = GW.settings.groupFrames.maintank.unitFlags
    frame.healthStringFormat = GW.settings.groupFrames.maintank.unitHealth
    frame.showTargetmarker = GW.settings.groupFrames.maintank.unitMarkers
    frame.unitWidth = tonumber(GW.settings.groupFrames.maintank.width)
    frame.unitHeight = tonumber(GW.settings.groupFrames.maintank.height)
    frame.raidShowImportantInstanceDebuffs = GW.settings.groupFrames.maintank.showRaidInstanceDebuffs
    frame.showDebuffs = GW.settings.groupFrames.maintank.showDebuffs
    frame.showOnlyDispelDebuffs = GW.settings.groupFrames.maintank.onlyDispellableDebuffs
    frame.showBuffs = GW.settings.groupFrames.maintank.showBuffs
    frame.showAuraTooltipInCombat = GW.settings.groupFrames.maintank.auraTooltipInCombat
    --frame.missingAuras = GW.FillTable({}, true, strsplit(",", (GW.settings.playerAuras.missingAuras:trim():gsub("%s*,%s*", ","))))
    frame.shortendHealthValue = GW.settings.groupFrames.maintank.shortHealthValues
    frame.showAbsorbBar = GW.settings.groupFrames.maintank.showAbsorbBar

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
    frame.showRoleIcon = GW.settings.groupFrames.maintank.showRoleIcon
    frame.showTankIcon = GW.settings.groupFrames.maintank.showTankIcon
    frame.showLeaderAssistIcon = GW.settings.groupFrames.maintank.showLeaderIcon
    frame.healthBarTexture = GW.settings.groupFrames.maintank.healthBarTexture

    frame.debuffFilters = GW.settings.groupFrames.maintank.debuffFilter
    frame.buffFilters = GW.settings.groupFrames.maintank.buffFilter
    frame.ignoredAuraSpellIDs = GW.settings.groupFrames.maintank.ignoredAuras -- consumed by the retail containers AND the classic aura filter
    frame.pandemicHighlight = GW.settings.groupFrames.maintank.pandemicHighlight
    frame.showDispelIcon = GW.settings.groupFrames.maintank.dispelIcon

    if not InCombatLockdown() then
        frame:SetSize(frame.unitWidth, frame.unitHeight)
        if not frame.isForced then
            frame:ClearAllPoints()
        end

        if GW.settings.groupFrames.maintank.enabled and not frame:IsEnabled() then
            frame:Enable()
        elseif not GW.settings.groupFrames.maintank.enabled and frame:IsEnabled() then
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
    GW.Update_Faderframe(frame, "maintank")

    frame:UpdateAllElements("Gw2_UpdateAllElements")
end
GW.UpdateGridMaintankFrame = UpdateGridMaintankFrame
