---@class GW2
local GW = select(2, ...)
local bossFrames = {}

local TEST_BOSSES = {
    {name = "Ragnaros", health = 0.72, power = 0.4, cast = "Wrath of Ragnaros", castTime = 2.5, auras = {{spellID = 589, dispelType = GW.Enum.DispelType.Magic}, {spellID = 172, dispelType = GW.Enum.DispelType.Magic}}},
    {name = "Majordomo Executus", health = 0.45, power = 0.8, cast = "Magic Reflection", castTime = 4, notInterruptible = true, auras = {{spellID = 18499}}},
    {name = "Flamewaker Healer", health = 1, power = 1},
}

GwBossFrameMixin = CreateFromMixins(GwObjectivesUnitFrameMixin)

function GwBossFrameMixin:UpdateRaidMarkers()
    local index = GetRaidTargetIndex(self.gwUnit)
    if index then
        SetRaidTargetIconTexture(self.marker, index)
        self.marker:Show()
        self.icon:Hide()
    else
        self.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-boss.png")
        self.icon:Show()
        self.marker:Hide()
    end
end

function GwBossFrameMixin:UpdateHealthbarColor()
    local unitReaction = UnitReaction(self.gwUnit, "player")
    local nameColor = (unitReaction and GW.Colors.FactionBarColors[unitReaction]) or RAID_CLASS_COLORS.PRIEST

    if unitReaction then
        if unitReaction <= 3 then nameColor = GW.Colors.UnitFrameReactionColors.Hostile end
        if unitReaction >= 5 then nameColor = GW.Colors.UnitFrameReactionColors.Friendly end
    end

    if UnitIsTapDenied(self.gwUnit) then
        nameColor = GW.Colors.UnitFrameReactionColors.TappedDenied
    end
    self.health:SetStatusBarColor(nameColor:GetRGB())
end

function GwBossFrameMixin:UpdateAll()
    self:UpdateName()
    self:UpdateHealth()
    self:UpdatePower()
    self:UpdateRaidMarkers()
    self:UpdateHealthbarColor()
    self:UpdateCastbar(GW.settings.objectives.bossFrames.castbar)
end

function GwBossFrameMixin:ApplySettings()
    self:ApplyAuraSettings(GW.settings.objectives.bossFrames.auras)
    if self:IsShown() and not self.gwTest then
        self:UpdateCastbar(GW.settings.objectives.bossFrames.castbar)
    end
end

function GwBossFrameMixin:OnShow()
    self.container:UpdateCompass()
    self.container:UpdateBossFrameHeight()
    if self.gwTest then return end
    self:UpdateAll()
end

function GwBossFrameMixin:OnHide()
    self:HideCastbar()
    self.container:UpdateBossFrameHeight()
    self.container:UpdateCompass()
end

function GwBossFrameMixin:OnEvent(event, unit)
    if GW.IsIn(event, "UNIT_MAXHEALTH", "UNIT_HEALTH", "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT", "UNIT_NAME_UPDATE", "UNIT_FACTION") then
        if unit ~= self.gwUnit then return end
    end
    if not self:IsShown() or self.gwTest then return end

    if self:IsCastbarEvent(event) then
        self:UpdateCastbar(GW.settings.objectives.bossFrames.castbar)
    elseif event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" then
        self:UpdateHealth()
    elseif event == "UNIT_MAXPOWER" or event == "UNIT_POWER_FREQUENT" then
        self:UpdatePower()
    elseif event == "PLAYER_TARGET_CHANGED" then
        self:UpdateName()
    elseif event == "RAID_TARGET_UPDATE" then
        self:UpdateRaidMarkers()
    elseif event == "UNIT_FACTION" then
        self:UpdateHealthbarColor()
    elseif event == "PLAYER_ENTERING_WORLD" or event == "UNIT_NAME_UPDATE" or event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
        self:UpdateAll()
        self.container:UpdateBossFrameHeight()
    end
end

function GwBossFrameMixin:StartTest(data)
    UnregisterUnitWatch(self)
    self.gwTest = true
    self.name:SetText(data.name)
    self.health:SetMinMaxValues(0, 1)
    self.health:SetValue(data.health)
    self.health.value:SetText(GW.RoundInt(data.health * 100) .. "%")
    self.health:SetStatusBarColor(GW.Colors.UnitFrameReactionColors.Hostile:GetRGB())
    self.power:SetMinMaxValues(0, 1)
    self.power:SetValue(data.power)
    self.power.value:SetText(GW.RoundInt(data.power * 100) .. "%")
    self.power:SetStatusBarColor(GW.Colors.PowerBarCustomColors.MANA:GetRGB())
    self.icon:Show()
    self.marker:Hide()
    if data.cast and GW.settings.objectives.bossFrames.castbar then
        self:ShowTestCastbar(data.cast, data.castTime, data.notInterruptible)
    else
        self:HideCastbar()
    end
    self:SetTestAuras(data.auras, GW.settings.objectives.bossFrames.auras)
    self:Show()
end

function GwBossFrameMixin:StopTest()
    self.gwTest = nil
    self:SetTestAuras(nil)
    self:HideCastbar()
    self:Hide()
    RegisterUnitWatch(self)
end

local function UpdateBossFramesHealthbarColor()
    for _, frame in pairs(bossFrames) do
        if frame:IsShown() then
            frame:UpdateHealthbarColor()
        end
    end
end
GW.UpdateBossFramesHealthbarColor = UpdateBossFramesHealthbarColor

local function UpdateBossFramesSettings()
    for _, frame in ipairs(bossFrames) do
        frame:ApplySettings()
    end
    if bossFrames[1] and bossFrames[1].gwTest then
        for i, data in ipairs(TEST_BOSSES) do
            bossFrames[i]:StartTest(data)
        end
    end
end
GW.UpdateBossFramesSettings = UpdateBossFramesSettings

-- secure frames: only out of combat, and the test ends when a fight starts
local testWatcher = CreateFrame("Frame")
testWatcher:SetScript("OnEvent", function()
    GW.ToggleBossFramesTest(false)
end)

function GW.ToggleBossFramesTest(enable)
    if #bossFrames == 0 or InCombatLockdown() then return end
    local active = bossFrames[1].gwTest == true
    if enable == nil then
        enable = not active
    elseif enable == active then
        return enable
    end

    if enable then
        for i, data in ipairs(TEST_BOSSES) do
            bossFrames[i]:StartTest(data)
        end
        testWatcher:RegisterEvent("PLAYER_REGEN_DISABLED")
    else
        for i = 1, #TEST_BOSSES do
            bossFrames[i]:StopTest()
        end
        testWatcher:UnregisterEvent("PLAYER_REGEN_DISABLED")
    end
    return enable
end

GwObjectivesBossContainerMixin = {}

function GwObjectivesBossContainerMixin:UpdateBossFrameHeight()
    local height = GW.GetFixedSlotContainerHeight(bossFrames)
    self:SetHeight(height)
end

-- the compass names the first boss still shown
function GwObjectivesBossContainerMixin:UpdateCompass()
    for _, frame in ipairs(bossFrames) do
        if frame:IsShown() then
            GwObjectivesNotification:SetNotification("boss", {title = frame.gwTest and frame.name:GetText() or UnitName(frame.gwUnit)})
            return
        end
    end
    GwObjectivesNotification:SetNotification("boss", nil)
end

function GwObjectivesBossContainerMixin:SetUpFramePosition()
    local yOffset = GW.settings.objectives.compass and 70 or 0

    for idx, frame in pairs(bossFrames) do
        if idx == 1 then
            frame:SetPoint("TOPRIGHT", GwQuestTracker, "TOPRIGHT", 0, -yOffset)
        else
            frame:SetPoint("TOPRIGHT", bossFrames[idx - 1], "BOTTOMRIGHT", 0, 0)
        end
    end
end

function GwObjectivesBossContainerMixin:RegisterFrame(i)
    local bossFrame = CreateFrame("Button", "GwBossFrame" .. i, GwQuestTracker, GW.isModern and "GwQuestTrackerBossFramePingableTemplate" or "GwQuestTrackerBossFrameTemplate")
    GW.SetFrameRoleset(bossFrame, "unitFrames")
    local unit = "boss" .. i
    Mixin(bossFrame, GwBossFrameMixin)

    bossFrame.id = i
    bossFrame.gwUnit = unit
    bossFrame.guid = UnitGUID(unit)
    bossFrame.container = self

    bossFrame:SetAttribute("unit", unit)
    bossFrame:SetAttribute("*type1", "target")
    bossFrame:SetAttribute("*type2", "togglemenu")

    GW.AddToClique(bossFrame)
    RegisterUnitWatch(bossFrame)
    bossFrame:EnableMouse(true)
    bossFrame:RegisterForClicks("AnyDown")

    bossFrame.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "SHADOW")
    bossFrame.marker:Hide()

    bossFrame.icon:SetVertexColor(GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Boss]:GetRGB())

    bossFrame:InitCastbarAndAuras({ "INSTANCE_ENCOUNTER_ENGAGE_UNIT", "PLAYER_ENTERING_WORLD" }, {
        { key = "debuffs", filter = "HARMFUL|PLAYER", candidateFilters = { nameplateShowPersonal = true }, maxFrameCount = 3, isDebuff = true },
        { key = "buffs", filter = "HELPFUL|IMPORTANT", maxFrameCount = 2, showStealable = true },
    })
    bossFrame:ApplySettings()

    bossFrame:RegisterEvent("RAID_TARGET_UPDATE")
    bossFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    bossFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    bossFrame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
    bossFrame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    bossFrame:RegisterUnitEvent("UNIT_HEALTH", unit)
    bossFrame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    bossFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
    bossFrame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)
    bossFrame:RegisterUnitEvent("UNIT_FACTION", unit)
    bossFrame:RegisterCastbarEvents()

    bossFrame:SetScript("OnEvent", bossFrame.OnEvent)
    bossFrame:SetScript("OnShow", bossFrame.OnShow)
    bossFrame:SetScript("OnHide", bossFrame.OnHide)
    bossFrame:SetScript("OnEnter", bossFrame.OnEnter)
    bossFrame:SetScript("OnLeave", bossFrame.OnLeave)

    return bossFrame
end

function GwObjectivesBossContainerMixin:InitModule()
    for i = 1, 5 do
        bossFrames[i] = self:RegisterFrame(i)
    end
    self:SetUpFramePosition()
    C_Timer.After(0.01, function() self:UpdateBossFrameHeight() end)
end
