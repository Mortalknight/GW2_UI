---@class GW2
local GW = select(2, ...)

local function GridRaidPetStyleRegister(self)
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

    self:DisableElement("MiddleIcon")

    return self
end
GW.GridRaidPetStyleRegister = GridRaidPetStyleRegister

local function UpdateGridRaidPetFrame(frame)
    -- set frame settings
    frame.useClassColor = GW.settings.groupFrames.raidPet.classColor
    frame.hideClassIcon = GW.settings.groupFrames.raidPet.hideClassIcon
    frame.showResscoureBar = GW.settings.groupFrames.raidPet.showPowerBar
    frame.showRealmFlags = GW.settings.groupFrames.raidPet.unitFlags
    frame.healthStringFormat = GW.settings.groupFrames.raidPet.unitHealth
    frame.showTargetmarker = GW.settings.groupFrames.raidPet.unitMarkers
    frame.unitWidth = tonumber(GW.settings.groupFrames.raidPet.width)
    frame.unitHeight = tonumber(GW.settings.groupFrames.raidPet.height)
    frame.raidShowImportantInstanceDebuffs = GW.settings.groupFrames.raidPet.showRaidInstanceDebuffs
    frame.showDebuffs = GW.settings.groupFrames.raidPet.showDebuffs
    frame.showOnlyDispelDebuffs = GW.settings.groupFrames.raidPet.onlyDispellableDebuffs
    frame.showAuraTooltipInCombat = GW.settings.groupFrames.raidPet.auraTooltipInCombat
    --frame.missingAuras = GW.FillTable({}, true, strsplit(",", (GW.settings.playerAuras.missingAuras:trim():gsub("%s*,%s*", ","))))
    frame.shortendHealthValue = GW.settings.groupFrames.raidPet.shortHealthValues
    frame.showAbsorbBar = GW.settings.groupFrames.raidPet.showAbsorbBar

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
    frame.showRoleIcon = GW.settings.groupFrames.raidPet.showRoleIcon
    frame.showTankIcon = GW.settings.groupFrames.raidPet.showTankIcon
    frame.showLeaderAssistIcon = GW.settings.groupFrames.raidPet.showLeaderIcon
    frame.healthBarTexture = GW.settings.groupFrames.raidPet.healthBarTexture

    -- retail filtering
    frame.debuffFilters = GW.settings.groupFrames.raidPet.debuffFilter
    frame.buffFilters = GW.settings.groupFrames.raidPet.buffFilter
    frame.ignoredAuraSpellIDs = GW.settings.groupFrames.raidPet.ignoredAuras -- consumed by the retail containers AND the classic aura filter
    frame.pandemicHighlight = GW.settings.groupFrames.raidPet.pandemicHighlight
    frame.showDispelIcon = GW.settings.groupFrames.raidPet.dispelIcon
    frame.showBuffs = GW.settings.groupFrames.raidPet.showBuffs

    if not InCombatLockdown() then
        frame:DisableElement("MiddleIcon")
        frame:SetSize(frame.unitWidth, frame.unitHeight)
        if not frame.isForced then
            frame:ClearAllPoints()
        end

        if GW.settings.groupFrames.raidPet.enabled and not frame:IsEnabled() then
            frame:Enable()
        elseif not GW.settings.groupFrames.raidPet.enabled and frame:IsEnabled() then
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
    GW.Update_Faderframe(frame, "raidPet")

    frame:UpdateAllElements("Gw2_UpdateAllElements")
end
GW.UpdateGridRaidPetFrame = UpdateGridRaidPetFrame
