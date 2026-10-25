---@class GW2
local GW = select(2, ...)

-- the wanted buff names, shared by all frames and only split again when the text changes
local missingAurasText, missingAuras
local function GetMissingAuras()
    local text = GW.settings.playerAuras.missingAuras
    if text ~= missingAurasText then
        missingAurasText = text
        missingAuras = GW.FillTable({}, true, strsplit(",", (text:trim():gsub("%s*,%s*", ","))))
    end
    return missingAuras
end

local DEFAULT_TEXT_BLOCKS = {
    nameText = {{k = "mainTankIcon"}, {k = "leaderIcon"}, {k = "assistIcon"}, {k = "roleIcon"}, {k = "name"}},
    healthText = {},
}
local DEFAULT_PET_TEXT_BLOCKS = {
    nameText = {{k = "name"}},
    healthText = {},
}

function GW.GetGridTextBlocks(profile, line, isPet)
    return GW.settings.groupFrames[profile][line] or (isPet and DEFAULT_PET_TEXT_BLOCKS or DEFAULT_TEXT_BLOCKS)[line]
end

local function OnEnter(self)
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    GameTooltip:SetUnit(self.__unit)
    GameTooltip:Show()
end

function GW.GridStyleRegister(self, options)
    self:RegisterForClicks('AnyUp')
    self:SetScript("OnLeave", GameTooltip_Hide)
    self:SetScript("OnEnter", OnEnter)

    self.RaisedElementParent = GW.CreateRaisedElement(self)
    self.Health = GW.Construct_HealthBar(self)
    self.Name = GW.Construct_NameText(self)
    self.HealthValueText = GW.Construct_HealthValueText(self)
    self.Power = GW.Construct_PowerBar(self)
    self.MiddleIcon = GW.Construct_MiddleIcon(self)
    self.ThreatIndicator = GW.Construct_ThreatIndicator(self)
    self.ReadyCheckIndicator = GW.Construct_ReadyCheck(self)
    self.SummonIndicator = GW.Construct_SummonIcon(self)
    self.ResurrectIndicator = GW.Construct_ResurrectionIcon(self)
    if not options.isPet then
        self.PhaseIndicator = GW.Construct_PhaseIcon(self)
        self.PvPClassificationIndicator = GW.Construct_PvPClassificationIcon(self)
    end
    GW.Construct_PredictionBar(self) -- creates only the function regestration
    self.Auras = GW.Construct_Auras(self)
    self.MissingBuffFrame = GW.Construct_MissingAuraIndicator(self)
    self.Fader = GW.Construct_Faderframe(self)

    if options.isPet then
        self:DisableElement("MiddleIcon")
    end

    return self
end

function GW.UpdateGridFrame(frame, profile, options)
    local settings = GW.settings.groupFrames[profile]

    -- set frame settings
    frame.useClassColor = settings.classColor
    frame.hideClassIcon = settings.hideClassIcon
    frame.showResscoureBar = settings.showPowerBar
    frame.showTargetmarker = settings.unitMarkers
    frame.unitWidth = tonumber(settings.width)
    frame.unitHeight = tonumber(settings.height)
    frame.raidShowImportantInstanceDebuffs = settings.showRaidInstanceDebuffs
    frame.showDebuffs = settings.showDebuffs
    frame.showOnlyDispelDebuffs = settings.onlyDispellableDebuffs
    frame.showBuffs = settings.showBuffs
    frame.showAuraTooltipInCombat = settings.auraTooltipInCombat
    frame.missingAuras = options.missingAuras and GetMissingAuras() or nil
    frame.showAbsorbBar = settings.showAbsorbBar

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
    frame.nameTagString = GW.BuildTagString(GW.GetGridTextBlocks(profile, "nameText", options.isPet))
    frame.healthTagString = GW.BuildTagString(GW.GetGridTextBlocks(profile, "healthText", options.isPet))
    frame.healthBarTexture = settings.healthBarTexture

    -- retail filtering
    frame.debuffFilters = settings.debuffFilter
    frame.buffFilters = settings.buffFilter
    frame.ignoredAuraSpellIDs = settings.ignoredAuras -- consumed by the retail containers AND the classic aura filter
    frame.pandemicHighlight = settings.pandemicHighlight
    frame.showDispelIcon = settings.dispelIcon
    frame.showDispelBorder = settings.dispelBorder

    if not InCombatLockdown() then
        if options.isPet then
            frame:DisableElement("MiddleIcon")
        end
        frame:SetSize(frame.unitWidth, frame.unitHeight)
        if not frame.isForced then
            frame:ClearAllPoints()
        end

        local enabled = settings.enabled and (not options.masterSwitch or GW.settings.groupFrames.enabled)
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
    GW.UpdateReadyCheckSettings(frame)
    GW.Update_PredictionBars(frame)
    GW.UpdateAurasSettings(frame)
    GW.Update_MissingAuraIndicator(frame)
    GW.Update_Faderframe(frame, profile)

    frame:UpdateAllElements("Gw2_UpdateAllElements")
end
