local _, GW = ...
local GW_UF = GW.oUF
local GetSetting = GW.GetSetting

local headers = {}

local settings = {
    raidClassColor = {},
    raidUnitHealthString = {},
    raidUnitFlag = {},
    raidUnitMarkers = {},
    raidUnitPowerBar = {},
    raidAuraTooltipInCombat = {},
    raidShowDebuffs = {},
    raidShowOnlyDispelDebuffs = {},
    raidShowImportendInstanceDebuffs = {},
    raidIndicators = {},

    raidWidth = {},
    raidHeight = {}
}

local settingsEventFrame = CreateFrame("Frame")

local function UpdateSettings()
    settings.fontEnabled = GetSetting("FONTS_ENABLED")
    settings.aurasIgnored = GetSetting("AURAS_IGNORED")
    settings.aurasMissing = GetSetting("AURAS_MISSING")
    settings.raidDebuffScale = GetSetting("RAIDDEBUFFS_Scale")
    settings.raidDispelDebuffScale = GetSetting("DISPELL_DEBUFFS_Scale")
    settings.raidIndicatorIcon = GetSetting("INDICATORS_ICON")
    settings.raidIndicatorTime = GetSetting("INDICATORS_TIME")

    settings.raidClassColor.PARTY = GetSetting("RAID_CLASS_COLOR_PARTY")
    settings.raidClassColor.RAID_PET = GetSetting("RAID_CLASS_COLOR_PET")
    settings.raidClassColor.RAID = GetSetting("RAID_CLASS_COLOR")

    settings.raidUnitHealthString.PARTY = GetSetting("RAID_UNIT_HEALTH_PARTY")
    settings.raidUnitHealthString.RAID_PET = GetSetting("RAID_UNIT_HEALTH_PET")
    settings.raidUnitHealthString.RAID = GetSetting("RAID_UNIT_HEALTH")

    settings.raidUnitFlag.PARTY = GetSetting("RAID_UNIT_FLAGS_PARTY")
    settings.raidUnitFlag.RAID_PET = GetSetting("RAID_UNIT_FLAGS_PET")
    settings.raidUnitFlag.RAID = GetSetting("RAID_UNIT_FLAGS")

    settings.raidUnitMarkers.PARTY = GetSetting("RAID_UNIT_MARKERS_PARTY")
    settings.raidUnitMarkers.RAID_PET = GetSetting("RAID_UNIT_MARKERS_PET")
    settings.raidUnitMarkers.RAID = GetSetting("RAID_UNIT_MARKERS")

    settings.raidUnitPowerBar.PARTY = GetSetting("RAID_POWER_BARS_PARTY")
    settings.raidUnitPowerBar.RAID_PET = GetSetting("RAID_POWER_BARS_PET")
    settings.raidUnitPowerBar.RAID = GetSetting("RAID_POWER_BARS")

    settings.raidAuraTooltipInCombat.PARTY = GetSetting("RAID_AURA_TOOLTIP_INCOMBAT_PARTY")
    settings.raidAuraTooltipInCombat.RAID_PET = GetSetting("RAID_AURA_TOOLTIP_INCOMBAT_PET")
    settings.raidAuraTooltipInCombat.RAID = GetSetting("RAID_AURA_TOOLTIP_INCOMBAT")

    settings.raidShowDebuffs.PARTY = GetSetting("RAID_SHOW_DEBUFFS_PARTY")
    settings.raidShowDebuffs.RAID_PET = GetSetting("RAID_SHOW_DEBUFFS_PET")
    settings.raidShowDebuffs.RAID = GetSetting("RAID_SHOW_DEBUFFS")

    settings.raidShowOnlyDispelDebuffs.PARTY = GetSetting("RAID_ONLY_DISPELL_DEBUFFS_PARTY")
    settings.raidShowOnlyDispelDebuffs.RAID_PET = GetSetting("RAID_ONLY_DISPELL_DEBUFFS_PET")
    settings.raidShowOnlyDispelDebuffs.RAID = GetSetting("RAID_ONLY_DISPELL_DEBUFFS")

    settings.raidShowImportendInstanceDebuffs.PARTY = GetSetting("RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PARTY")
    settings.raidShowImportendInstanceDebuffs.RAID_PET = GetSetting("RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PET")
    settings.raidShowImportendInstanceDebuffs.RAID = GetSetting("RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF")

    settings.raidWidth.RAID = GetSetting("RAID_WIDTH")
    settings.raidHeight.RAID = GetSetting("RAID_HEIGHT")
    settings.raidAnchor = GetSetting("RAID_ANCHOR")

    ----for _, pos in ipairs(INDICATORS) do
        --settings.raidIndicators[pos] = GetSetting("INDICATOR_" .. pos, true)
    --end

    --missing = FillTable(missing, true, strsplit(",", (settings.aurasMissing:trim():gsub("%s*,%s*", ","))))
    --ignored = FillTable(ignored, true, strsplit(",", (settings.aurasIgnored:trim():gsub("%s*,%s*", ","))))

    -- Update this settings on a spec switch
    if not settingsEventFrame.isSetup then
        settingsEventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        settingsEventFrame:SetScript("OnEvent", UpdateSettings)

        settingsEventFrame.isSetup = true
    end

    for profile, header in pairs(headers) do
		for _, child in ipairs({ header:GetChildren() }) do
            GW.UpdateGridFrames(child, profile)
        end
	end
end
GW.UpdateGridSettings = UpdateSettings

local settings2 = {
    maxAllowedGroups = 8,
    spacing = 0,
    border = 1,

}

local function CreateRaisedText(raised)
	local text = raised:CreateFontString(nil, 'OVERLAY')
	text:SetFont(UNIT_NAME_FONT, 11)
    text:SetShadowOffset(-1, -1)
    text:SetShadowColor(0, 0, 0, 1)

	return text
end
GW.CreateRaisedText = CreateRaisedText

local function CreateRaisedElement(frame)
	local raised = CreateFrame('Frame', nil, frame)
	local level = frame:GetFrameLevel() + 100
	raised:SetFrameLevel(level)
	raised.__owner = frame

	-- layer levels (level +1 is icons)
	raised.AuraLevel = level
	raised.AuraBarLevel = level + 10
	raised.RaidDebuffLevel = level + 15
	raised.AuraWatchLevel = level + 20

	raised.TextureParent = CreateFrame('Frame', nil, raised)

	return raised
end


local function AfterStyleCallback(self)
    print("AfterStyleCallback", self)

end

local function Style(self)
    --self:SetSize(settings.raidWidth*2, settings.raidHeight*2)

    self:RegisterForClicks('AnyUp')
    self:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        if UnitGUID(self.unit) ~= UnitGUID("target") then
            --self.Health.bg:SetVertexColor(0, 0, 0, 1)
        end
    end)
    self:SetScript(
        "OnEnter",
        function(self)
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetUnit(self.unit)
            GameTooltip:Show()
            --self.Health.bg:SetVertexColor(1, 1, 1, 1)
        end
    )

    self.RaisedElementParent = CreateRaisedElement(self)
	self.Health = GW.Construct_HealthBar(self, true)
    self.Name = GW.Construct_NameText(self)
    self.HealthValueText = GW.Construct_HealtValueText(self)
    self.Power = GW.Construct_PowerBar(self)
    self.MiddleIcon = GW.Construct_MiddleIcon(self)
    self.ThreatIndicator = GW.Construct_ThreathIndicator(self)
    self.ReadyCheckIndicator = GW.Construct_ReadyCheck(self)
    self.SummonIndicator = GW.Construct_SummonIcon(self)
    self.ResurrectIndicator = GW.Construct_ResurrectionIcon(self)
    GW.Construct_PredictionBar(self)

    return self
end

local function UpdateGridFrames(frame, profile)
    -- set frame settings
    frame.useClassColor = settings.raidClassColor[profile]
    frame.showResscoureBar = settings.raidUnitPowerBar[profile]
    frame.showRealmFlags = settings.raidUnitFlag[profile]
    frame.healthStringFormat = settings.raidUnitHealthString[profile]
    frame.showTargetmarker = settings.raidUnitMarkers[profile]

    frame:SetSize(settings.raidWidth[profile], settings.raidHeight[profile])

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


    -- Update header values
    headers['RAID']:ClearAllPoints()
    headers['RAID']:SetPoint(settings.raidAnchor, GwRaidFrameContainerNEW, settings.raidAnchor, 0, 0)

    frame:UpdateAllElements("RefreshUnit")
end
GW.UpdateGridFrames = UpdateGridFrames

local function Setup(self)
    self:RegisterInitCallback(AfterStyleCallback)
	self:SetActiveStyle('GW2_Grid')

	local header = self:SpawnHeader(nil, nil, 'custom [group:party] show; [@raid3,exists] show; [@raid26,exists] show; show',
		'showParty', true,
		'showRaid', true,
		'showPlayer', true,
		'yOffset', 0,
		'groupBy', 'ASSIGNEDROLE',
		'groupingOrder', 'TANK,HEALER,DAMAGER',
		'oUF-initialConfigFunction', [[
			self:SetHeight(19)
			self:SetWidth(126)
		]]
	)
	header.UpdateFrames = UpdateGridFrames

    headers['RAID'] = header

    -- test movable
    local container = CreateFrame("Frame", "GwRaidFrameContainerNEW", UIParent, "GwRaidFrameContainer")
    GW.RegisterMovableFrame(container, RAID_FRAMES_LABEL .. "NEW", "raid_pos_new",  ALL .. ",Unitframe,Raid", nil, {"default", "default"})
    container:ClearAllPoints()
    container:SetPoint("TOPLEFT", container.gwMover)

    header:SetPoint(settings.raidAnchor, container, settings.raidAnchor, 0, 0)
end
local function Initialize()
    GW.Create_Tags()
    GW_UF:RegisterStyle('GW2_Grid', Style)
    GW_UF:Factory(Setup)

    UpdateSettings()
end
GW.InitializeRaidFrames = Initialize