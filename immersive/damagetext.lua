local _, GW = ...
local AFP = GW.AddProfiling
local AddToAnimation = GW.AddToAnimation
local CommaValue = GW.CommaValue
local playerGUID
local unitToGuid = {}
local guidToUnit = {}

local fontStringList = {}
local namePlatesOffsets = {}
local namePlatesCriticalOffsets = {}

local eventHandler = CreateFrame("Frame")

local settings = {}

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

local STACKING_NORMAL_ANIMATION_DURATION = 7
local STACKING_CRITICAL_ANIMATION_DURATION = 7
local STACKING_NORMAL_ANIMATION_OFFSET_Y = 70

local CRITICAL_SCALE_MODIFIER = 1.5
local PET_SCALE_MODIFIER = 0.7

local NORMAL_ANIMATION_OFFSET_Y = 20

local stackingContainer

local formats = {Default = "Default", Stacking = "Stacking"}

local usedColorTable
local function UpdateSettings()
    settings.useBlizzardColor = GW.GetSetting("GW_COMBAT_TEXT_BLIZZARD_COLOR")
    settings.useCommaFormat = GW.GetSetting("GW_COMBAT_TEXT_COMMA_FORMAT")

    settings.usedFormat = formats.Stacking -- Default

    usedColorTable = settings.useBlizzardColor and colorTable.blizzard or colorTable.gw
end
GW.UpdateDameTextSettings = UpdateSettings

local function animateTextCriticalForStackingFormat(frame)
    local aName = frame:GetName()

    AddToAnimation(
        aName,
        0,
        1,
        GetTime(),
        STACKING_CRITICAL_ANIMATION_DURATION,
        function(p)
            local offsetY = -(STACKING_NORMAL_ANIMATION_OFFSET_Y * p * 2)
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

            frame:SetPoint("BOTTOM", frame.anchorFrame, "TOP", 0, offsetY)

            if p > 0.7 then
                local alphaFade = p - 0.7
                local lerp = GW.lerp(1, 0, alphaFade / 0.3)
                if lerp < 0 then lerp = 0 end
                if lerp > 1 then lerp = 1 end
                frame:SetAlpha(lerp)
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
AFP("animateTextCriticalForStackingFormat", animateTextCriticalForStackingFormat)

local function animateTextNormalForStackingFormat(frame)
    local aName = frame:GetName()

    AddToAnimation(
        aName,
        0,
        1,
        GetTime(),
        STACKING_NORMAL_ANIMATION_DURATION,
        function(p)
            local offsetY = -(STACKING_NORMAL_ANIMATION_OFFSET_Y * p * 2)
            local pet_scale = frame.pet and PET_SCALE_MODIFIER or 1
            frame:SetScale(1 * pet_scale)
            frame:SetPoint("BOTTOM", frame.anchorFrame, "TOP", 0, offsetY)

            if p > 0.7 then
                local alphaFade = p - 0.7
                local lerp = GW.lerp(1, 0, alphaFade / 0.3)
                if lerp < 0 then lerp = 0 end
                if lerp > 1 then lerp = 1 end
                frame:SetAlpha(lerp)
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
AFP("animateTextNormalForStackingFormat", animateTextNormalForStackingFormat)

local function animateTextCriticalForDefaultFormat(frame, offsetIndex)
    local aName = frame:GetName()

    AddToAnimation(
        aName,
        0,
        1,
        GetTime(),
        CRITICAL_ANIMATION_DURATION,
        function(p)
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
                local lerp = GW.lerp(1, 0, alphaFade / 0.3)
                if lerp < 0 then lerp = 0 end
                if lerp > 1 then lerp = 1 end
                frame:SetAlpha(lerp)
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
AFP("animateTextCriticalForDefaultFormat", animateTextCriticalForDefaultFormat)

local function animateTextNormalForDefaultFormat(frame, offsetIndex)
    local aName = frame:GetName()

    AddToAnimation(
        aName,
        0,
        1,
        GetTime(),
        NORMAL_ANIMATION_DURATION,
        function(p)
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
                local lerp = GW.lerp(1, 0, alphaFade / 0.3)
                if lerp < 0 then lerp = 0 end
                if lerp > 1 then lerp = 1 end
                frame:SetAlpha(lerp)
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
AFP("animateTextNormalForDefaultFormat", animateTextNormalForDefaultFormat)

local createdFramesIndex = 0
local function createNewFontElement(self)
    if createdFramesIndex >= NUM_OBJECTS_HARDLIMIT then
        return nil
    end

    local f = CreateFrame("FRAME", "GwDamageTextElement" .. createdFramesIndex, self, "GwDamageText")
    f.string:SetJustifyV("MIDDLE")
    f.id = createdFramesIndex
    table.insert(fontStringList, f)
    createdFramesIndex = createdFramesIndex + 1
    return f
end
AFP("createNewFontElement", createNewFontElement)

local function getFontElement(self)
    for _, f in pairs(fontStringList) do
        if not f:IsShown() then
            return f
        end
    end

    local newFrame = createNewFontElement(self)
    if newFrame ~= nil then
        return newFrame
    end
    for _, f in pairs(fontStringList) do
        return f
    end
end
AFP("getFontElement", getFontElement)

local function getLatestShownElement(frame)
    local returnValue = nil
    local highestId = -1
    for _, f in pairs(fontStringList) do
        if f ~= frame and f:IsShown() and f.id > highestId then
            returnValue = f
            highestId = f.id
        end
    end

    return returnValue
end

local function setElementData(self, critical, source, missType, blocked, absorbed, periodic)
    if missType then
        self.critTexture:Hide()
        self.string:SetFont(DAMAGE_TEXT_FONT, 18, "OUTLINED")
        self.crit = false
    elseif blocked or absorbed then
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
    if periodic then
        self.bleedTexture:Show()
    else
        self.bleedTexture:Hide()
    end

    self.pet = source == "pet"

    local colorSource = (source == "pet" or source == "melee") and source or "spell"

    self.string:SetTextColor(usedColorTable[colorSource].r, usedColorTable[colorSource].g, usedColorTable[colorSource].b, usedColorTable[colorSource].a)

    self:Show()
    self:ClearAllPoints()
end
AFP("setElementData", setElementData)

local function formatDamageValue(amount)
    return settings.useCommaFormat and CommaValue(amount) or amount
end
AFP("formatDamageValue", formatDamageValue)

local function displayDamageText(self, guid, amount, critical, source, missType, blocked, absorbed, periodic)
    local f = getFontElement(self)
    f.string:SetText(missType and getglobal(missType) or blocked and format(TEXT_MODE_A_STRING_RESULT_BLOCK, formatDamageValue(blocked)) or absorbed and format(TEXT_MODE_A_STRING_RESULT_ABSORB, formatDamageValue(absorbed)) or formatDamageValue(amount) .. " ID:" ..f.id)

    if settings.usedFormat == formats.Default then
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
        f.string:SetJustifyV("MIDDLE")

        setElementData(f, critical, source, missType, blocked, absorbed, periodic)

        if namePlatesOffsets[nameplate] == nil then
            namePlatesOffsets[nameplate] = 0
        else
            namePlatesOffsets[nameplate] = namePlatesOffsets[nameplate] + 1
            if namePlatesOffsets[nameplate] > 2 then
                namePlatesOffsets[nameplate] = 0
            end
        end

        if critical and not periodic then
            if namePlatesCriticalOffsets[nameplate] == nil then
                namePlatesCriticalOffsets[nameplate] = 0
            else
                namePlatesCriticalOffsets[nameplate] = namePlatesCriticalOffsets[nameplate] + 1
                if namePlatesCriticalOffsets[nameplate] > 2 then
                    namePlatesCriticalOffsets[nameplate] = 0
                end
            end
            animateTextCriticalForDefaultFormat(f, namePlatesCriticalOffsets[nameplate])
            return
        end
        animateTextNormalForDefaultFormat(f, namePlatesOffsets[nameplate])
    elseif settings.usedFormat == formats.Stacking then
        local lastShownElement = getLatestShownElement(f)
        f.anchorFrame = stackingContainer
        f.string:SetJustifyV("LEFT")

        print(f.anchorFrame.id, f.id)

        setElementData(f, critical, source, missType, blocked, absorbed, periodic)

        -- add to animation here
        if critical and not periodic then
            animateTextCriticalForStackingFormat(f, (lastShownElement and true or false))
        else
            animateTextNormalForStackingFormat(f, (lastShownElement and true or false))
        end
    end
end
AFP("displayDamageText", displayDamageText)

local function handleCombatLogEvent(self, _, event, _, sourceGUID, _, sourceFlags, _, destGUID, _, _, _, ...)
    local targetUnit = guidToUnit[destGUID]
    -- if targetNameplate doesnt exists, ignore
    if settings.usedFormat == formats.Default and not targetUnit then return end
    local _
    if playerGUID == sourceGUID then
        local periodic = false
        if (string.find(event, "_DAMAGE")) then
            local spellName, amount, blocked, absorbed, critical
            if (string.find(event, "SWING")) then
                spellName, amount, _, _, _, blocked, absorbed, critical = "melee", ...
            elseif (string.find(event, "ENVIRONMENTAL")) then
                spellName, amount, _, _, _, blocked, absorbed, critical = ...
              elseif (string.find(event, "PERIODIC")) then
                  _, spellName, _, amount, _, _, _, blocked, absorbed, critical = ...
                  periodic = true
              else
                _, spellName, _, amount, _, _, _, blocked, absorbed, critical = ...
            end
            displayDamageText(self, destGUID, amount, critical, spellName, nil, blocked, absorbed,periodic)
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
AFP("handleCombatLogEvent", handleCombatLogEvent)

local function onNamePlateAdded(_, _, unitID)
    local guid = UnitGUID(unitID)
    if guid then
        unitToGuid[unitID] = guid
        guidToUnit[guid] = unitID
    end
end
AFP("onNamePlateAdded", onNamePlateAdded)

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
AFP("onNamePlateRemoved", onNamePlateRemoved)

local function onCombatLogEvent(self)
    handleCombatLogEvent(self, CombatLogGetCurrentEventInfo())
end
AFP("onNamePlateRemoved", onNamePlateRemoved)

local function ToggleFormat()
    if settings.usedFormat == formats.Default then
        -- hide the other format things
        if stackingContainer then
            -- TODO remove from Move Hud mode
        end

        NUM_OBJECTS_HARDLIMIT = 20

        eventHandler:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        eventHandler:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    elseif settings.usedFormat == formats.Stacking then
        if not stackingContainer then
            stackingContainer = CreateFrame("Frame", "GWTEST", UIParent)
            stackingContainer:SetSize(200, 400)
            stackingContainer:ClearAllPoints()
            GW.RegisterMovableFrame(stackingContainer, GW.L["FCT Container"], "FCT_STACKING_CONTAINER", ALL .. ",FCT", nil, {"default", "scaleable"})
            stackingContainer:ClearAllPoints()
            stackingContainer:SetPoint("TOPLEFT", stackingContainer.gwMover)
        end
        NUM_OBJECTS_HARDLIMIT = 50 -- testing

        eventHandler:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        eventHandler:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")

        wipe(unitToGuid)
        wipe(guidToUnit)

        stackingContainer:Show()
        stackingContainer:EnableMouse(false)
    end
end

local function LoadDamageText()
    UpdateSettings()

    ToggleFormat()

    playerGUID = UnitGUID("player")

    eventHandler:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    eventHandler:SetScript("OnEvent", function(_, event, ...)
        if event == "NAME_PLATE_UNIT_ADDED" then
            onNamePlateAdded(eventHandler, event, ...)
        elseif event == "NAME_PLATE_UNIT_REMOVED" then
            onNamePlateRemoved(eventHandler, event, ...)
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            onCombatLogEvent(eventHandler)
        end
    end)
end
GW.LoadDamageText = LoadDamageText
