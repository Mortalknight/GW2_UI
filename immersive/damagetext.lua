local _, GW = ...
local AddToAnimation = GW.AddToAnimation
local animations = GW.animations
local CommaValue = GW.CommaValue
local playerGUID
local unitToGuid = {}
local guidToUnit = {}

local fontStringList = {}
local namePlatesOffsets = {}
local namePlatesCriticalOffsets = {}

local colorTable ={
    gw = {
        spell = {r = 1, g = 1, b = 1, a = 1},
        melee = {r = 1, g = 1, b = 1, a = 1},
        pet = {r = 1, g = 0.2, b= 0.2, a = 1}
    },
    blizzard = {
        spell = {r = 1, g = 1, b = 0, a = 1},
        melee = {r = 1, g = 1, b = 1, a = 1},
        pet = {r = 1, g = 1, b = 1, a = 1}
    }
}

local NUM_OBJECTS_HARDLIMIT = 20

--Animation settings
local NORMAL_ANIMATION_DURATION = 0.7
local CRITICAL_ANIMATION_DURATION = 1.2

local CRITICAL_SCALE_MODIFIER = 1.5
local PET_SCALE_MODIFIER = 0.7

local NORMAL_ANIMATION_OFFSET_Y = 20

-- Display settings
local USE_BLIZZARD_COLORS
local USE_COMMA_FORMATING


local function animateTextCritical(frame, offsetIndex)
    local aName = frame:GetName()

    AddToAnimation(
        aName,
        0,
        1,
        GetTime(),
        CRITICAL_ANIMATION_DURATION,
        function()
            local p = animations[aName].progress
            local pet_scale = 1
            if frame.pet then
                pet_scale = PET_SCALE_MODIFIER
            end
            if p < 0.25 then
                local scaleFade = p - 0.25

                frame:SetScale(GW.lerp(1 * pet_scale * CRITICAL_SCALE_MODIFIER, pet_scale, scaleFade / 0.25))
            else
                frame:SetScale(pet_scale)
            end

            if offsetIndex == 0 then
                frame:SetPoint("TOP", frame.anchorFrame, "BOTTOM", 0, 0)
            elseif offsetIndex == 1 then
                frame:SetPoint("TOP", frame.anchorFrame, "BOTTOMLEFT", 0, 0)
            elseif offsetIndex== 2 then
                frame:SetPoint("TOP", frame.anchorFrame, "BOTTOMRIGHT", 0, 0)
            end

            if p > 0.7 then
                local alphaFade = p - 0.7
                frame:SetAlpha(GW.lerp(1, 0, alphaFade / 0.3))
            else
                frame:SetAlpha(1)
            end
        end,
        nil,
        function()
            frame:SetScale(1)
            frame:Hide()
        end
    )
end
local function animateTextNormal(frame, offsetIndex)
    local aName = frame:GetName()

    AddToAnimation(
        aName,
        0,
        1,
        GetTime(),
        NORMAL_ANIMATION_DURATION,
        function()
            local p = animations[aName].progress
            local offsetY = NORMAL_ANIMATION_OFFSET_Y * p
            local pet_scale = 1
            if frame.pet then
                pet_scale = PET_SCALE_MODIFIER
            end
            frame:SetScale(1 * pet_scale)
            if offsetIndex == 0 then
                frame:SetPoint("BOTTOM", frame.anchorFrame, "TOP", 0, offsetY)
            elseif offsetIndex== 1 then
                frame:SetPoint("BOTTOM", frame.anchorFrame, "TOPLEFT", 0, offsetY)
            elseif offsetIndex== 2 then
                frame:SetPoint("BOTTOM", frame.anchorFrame, "TOPRIGHT", 0, offsetY)
            end

            if p > 0.7 then
                local alphaFade = p - 0.7
                frame:SetAlpha(GW.lerp(1, 0, alphaFade / 0.3))
            else
                frame:SetAlpha(1)
            end
        end,
        nil,
        function()
            frame:SetScale(1)
            frame:Hide()
        end
    )
end

local createdFramesIndex = 0
local function createNewFontElement(self)
    if createdFramesIndex >= NUM_OBJECTS_HARDLIMIT then
        return nil
    end

    local f = CreateFrame("FRAME", "GwDamageTextElement" .. createdFramesIndex, self, "GwDamageText")
    table.insert(fontStringList, f)
    createdFramesIndex = createdFramesIndex + 1
    return f
end

local function getFontElement(self)
    for _,f in pairs(fontStringList) do
        if not f:IsShown() then
            return f
        end
    end

    local newFrame = createNewFontElement(self)
    if newFrame ~= nil then
        return newFrame
    end
    for _,f in pairs(fontStringList) do
        return f
    end
end
local function setElementData(self, critical, source, missType, blocked, absorbed)
    if missType then
        self.critTexture:Hide()
        self.string:SetFont(DAMAGE_TEXT_FONT, 18, "OUTLINED")
        self.crit = false
    elseif blocked then
        self.critTexture:Hide()
        self.string:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINED")
        self.crit = false
    elseif absorbed then
        self.critTexture:Hide()
        self.string:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINED")
        self.crit = false
    elseif critical then
        self.critTexture:Show()
        self.string:SetFont(DAMAGE_TEXT_FONT, 34, "OUTLINED")
        self.crit = true
    else
        self.critTexture:Hide()
        self.string:SetFont(DAMAGE_TEXT_FONT, 24, "OUTLINED")
        self.crit = false
    end
    self.pet = false

    local colorSource = "spell"
    if source == "pet" or source == "melee" then
        colorSource = source
        if source == "pet" then
            self.pet = true
        end
    end

    local activeColorTable = USE_BLIZZARD_COLORS and colorTable.blizzard or colorTable.gw

    self.string:SetTextColor(activeColorTable[colorSource].r, activeColorTable[colorSource].g, activeColorTable[colorSource].b, activeColorTable[colorSource].a)
end

local function formatDamageValue(amount)
    return USE_COMMA_FORMATING and CommaValue(amount) or amount
end

local function displayDamageText(self, guid, amount, critical, source, missType, blocked, absorbed)
    local f = getFontElement(self)
    f.string:SetText(missType and getglobal(missType) or blocked and format(TEXT_MODE_A_STRING_RESULT_BLOCK, formatDamageValue(blocked)) or absorbed and format(TEXT_MODE_A_STRING_RESULT_ABSORB, formatDamageValue(absorbed)) or formatDamageValue(amount))

    local nameplate
    local unit = guidToUnit[guid]

    if unit then
        nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    end

    if nameplate == nil then
        return
    end

    f.anchorFrame = nameplate
    f.unit = unit

    setElementData(f, critical, source, missType, blocked, absorbed)

    f:Show()
    f:ClearAllPoints()

    if namePlatesOffsets[nameplate] == nil then
        namePlatesOffsets[nameplate] = 0
    else
        namePlatesOffsets[nameplate] = namePlatesOffsets[nameplate] + 1
        if namePlatesOffsets[nameplate] > 2 then
            namePlatesOffsets[nameplate] = 0
        end
    end

    if critical then
        if namePlatesCriticalOffsets[nameplate] == nil then
            namePlatesCriticalOffsets[nameplate] = 0
        else
            namePlatesCriticalOffsets[nameplate] = namePlatesCriticalOffsets[nameplate] + 1
            if namePlatesCriticalOffsets[nameplate] > 2 then
                namePlatesCriticalOffsets[nameplate] = 0
            end
        end
        animateTextCritical(f, namePlatesCriticalOffsets[nameplate])
        return
    end
    animateTextNormal(f, namePlatesOffsets[nameplate])
end

local function handleCombatLogEvent(self, _, event, _, sourceGUID, _, sourceFlags, _, destGUID, _, _, _, ...)
    local targetUnit = guidToUnit[destGUID]
    -- if targetNameplate doesnt exists, ignore
    if not targetUnit then return end

    if playerGUID == sourceGUID then
        if (string.find(event, "_DAMAGE")) then
            local spellName, amount, blocked, absorbed, critical
            if (string.find(event, "SWING")) then
                spellName, amount, _, _, _, blocked, absorbed, critical = "melee", ...
            elseif (string.find(event, "ENVIRONMENTAL")) then
                spellName, amount, _, _, _, blocked, absorbed, critical = ...
            else
                _, spellName, _, amount, _, _, _, blocked, absorbed, critical = ...
            end
            displayDamageText(self, destGUID, amount, critical, spellName, nil, blocked, absorbed)
        elseif (string.find(event, "_MISSED")) then
            local missType
            if (string.find(event, "RANGE") or string.find(event, "SPELL")) then
                missType = select(4,...)
            elseif (string.find(event, "SWING")) then
                missType = ...
            else
                _, _, _, missType = ...
            end
            displayDamageText(self, destGUID, nil, nil, nil, missType)
        end
    elseif (bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0 or bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) > 0) and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 then -- caster is player pet
        if (string.find(event, "_DAMAGE")) then
            local amount, _, _, _, _, blocked, absorbed, critical
            if (string.find(event, "SWING")) then
                _, amount, _, _, _, blocked, absorbed, critical = "pet", ...
            elseif (string.find(event, "ENVIRONMENTAL")) then
                _, amount, _, _, _, blocked, absorbed, critical = ...
            else
                _, _, _, amount, _, _, _, blocked, absorbed, critical = ...
            end
            displayDamageText(self, destGUID, amount, critical, "pet", nil, blocked, absorbed)
        elseif (string.find(event, "_MISSED")) then
            local missType
            if (string.find(event, "RANGE") or string.find(event, "SPELL")) then
                missType = select(4,...)
            elseif (string.find(event, "SWING")) then
                missType = ...
            end
            displayDamageText(self, destGUID, nil, nil, "pet", missType)
        end
    end
end

local function onNamePlateAdded(_, _, unitID)
    local guid = UnitGUID(unitID)

    unitToGuid[unitID] = guid
    guidToUnit[guid] = unitID
end

local function onNamePlateRemoved(_, _, unitID)
    local guid = unitToGuid[unitID]

    unitToGuid[unitID] = nil
    guidToUnit[guid] = nil

    for _,f in pairs(fontStringList) do
        if f.unit ~= nil and f.unit == unitID then
            f:Hide()
        end
    end
end

local function onCombatLogEvent(self)
    handleCombatLogEvent(self, CombatLogGetCurrentEventInfo())
end

local function LoadDamageText()
    playerGUID = UnitGUID("player")
    USE_BLIZZARD_COLORS = GW.GetSetting("GW_COMBAT_TEXT_BLIZZARD_COLOR")
    USE_COMMA_FORMATING = GW.GetSetting("GW_COMBAT_TEXT_COMMA_FORMAT")

    local f = CreateFrame("Frame")
    f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    f:SetScript("OnEvent", function(_, event, ...)
        if event == "NAME_PLATE_UNIT_ADDED" then
            onNamePlateAdded(f, event, ...)
        elseif event == "NAME_PLATE_UNIT_REMOVED" then
            onNamePlateRemoved(f, event, ...)
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            onCombatLogEvent(f, event, ...)
        end
    end)
end
GW.LoadDamageText = LoadDamageText
