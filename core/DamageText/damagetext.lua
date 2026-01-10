local _, GW = ...

local math, table, bit = math, table, bit
local UnitGUID = UnitGUID
local GetTime = GetTime
local CreateFrame = CreateFrame
local C_NamePlate = C_NamePlate
local C_NamePlate_GetNamePlates = C_NamePlate.GetNamePlates
local RegisterMovableFrame = GW.RegisterMovableFrame
local ToggleMover = GW.ToggleMover

local AFP = GW.AddProfiling
local MoveTowards = GW.MoveTowards
local getSpriteByIndex = GW.getSpriteByIndex

local unitToGuid = {}
local guidToUnit = {}

local fontStringList = {}
local namePlatesOffsets = {}
local namePlateClassicGrid = {}
local namePlatesCriticalOffsets = {}

local eventHandler = CreateFrame("Frame")

local elementIcons = {
    width = 512,
    height = 256,
    colums = 4,
    rows = 2
}

local colorTable = {
    gw = {
        spell = {r = 1, g = 1, b = 1, a = 1},
        melee = {r = 1, g = 1, b = 1, a = 1},
        pet   = {r = 1, g = 0.2, b = 0.2, a = 1},
        heal  = {r = 25/255, g = 255/255, b = 25/255, a = 1},
    },
    blizzard = {
        spell = {r = 1, g = 1, b = 0, a = 1},
        melee = {r = 1, g = 1, b = 1, a = 1},
        pet   = {r = 1, g = 1, b = 1, a = 1},
        heal  = {r = 25/255, g = 255/255, b = 25/255, a = 1},
    },
}

local function GenerateExplosiveGrid(maxDistance)
    local result = {}
    local queue = {}
    local visited = {}
    local neighborOrder = {
        {1, 0}, {0, -1}, {0, 1}, {-1, 0},
        {-1, -1}, {1, -1}, {1, 1}, {-1, 1},
    }
    local function key(x, y)
        return x .. "," .. y
    end

    visited[key(0, 0)] = true
    queue[1] = {0, 0}
    local head = 1
    while head <= #queue do
        local current = queue[head]
        head = head + 1
        local cx, cy = current[1], current[2]
        for _, offset in ipairs(neighborOrder) do
            local nx, ny = cx + offset[1], cy + offset[2]
            if math.abs(nx) <= maxDistance and math.abs(ny) <= maxDistance and not visited[key(nx, ny)] then
                visited[key(nx, ny)] = true
                result[#result + 1] = {x = nx, y = ny}
                queue[#queue + 1] = {nx, ny}
            end
        end
    end
    return result
end

local classicGridData = GenerateExplosiveGrid(10)
local NUM_OBJECTS_HARDLIMIT = 20

--Animation settings
local NORMAL_ANIMATION_DURATION = 0.7
local CRITICAL_ANIMATION_DURATION = 1.2
local STACKING_NORMAL_ANIMATION_DURATION = 1
local STACKING_CRITICAL_ANIMATION_DURATION = 1
local STACKING_NORMAL_ANIMATION_OFFSET_Y = 10
local STACKING_NORMAL_ANIMATION_OFFSET_X = -20
local STACKING_MOVESPEED = 1

local CLASSIC_NUM_HITS = 0
local CLASSIC_AVARAGE_HIT = 0
local NORMAL_ANIMATION_OFFSET_Y = 20

local stackingContainer
local ClassicDummyFrame

local formats = {Default = "Default", Stacking = "Stacking", Classic = "Classic"}

local NORMAL_ANIMATION
local CRITICAL_ANIMATION
local NUM_ACTIVE_FRAMES = 0

local usedColorTable
local function UpdateSettings()
    usedColorTable = GW.settings.GW_COMBAT_TEXT_BLIZZARD_COLOR and colorTable.blizzard or colorTable.gw
end
GW.UpdateDameTextSettings = UpdateSettings

local function getSchoolIndex(school)
    if school == 1 then return 0
    elseif school == 2 then return 1
    elseif school == 4 then return 6
    elseif school == 8 then return 2
    elseif school == 16 then return 5
    elseif school == 32 then return 3
    elseif school == 64 then return 4
    else return false end
end
local function getSchoolIconMap(self, school)
    local iconID = getSchoolIndex(school)
    if iconID then
        self:SetTexCoord(getSpriteByIndex(elementIcons, iconID))
        return true
    end
    return false
end

local function getDurationModifier()
    return math.max(1, NUM_ACTIVE_FRAMES / 10)
end

local function calcAvarageHit(amount)
    if CLASSIC_NUM_HITS > 100 then return end
    CLASSIC_NUM_HITS = CLASSIC_NUM_HITS + 1
    CLASSIC_AVARAGE_HIT = CLASSIC_AVARAGE_HIT + amount
end

local function getAvrageHitModifier(amount, critical, forAdd)
    if not amount then
        return forAdd and 0 or 1
    end
    local a = CLASSIC_AVARAGE_HIT / CLASSIC_NUM_HITS
    local n = math.min(1.5, math.max(0.7, (amount / a)))
    return critical and (n / 2) or n
end

local function classicPositionGrid(namePlate)
    if not namePlateClassicGrid[namePlate] then
        namePlateClassicGrid[namePlate] = {}
    end
    for i = 1, 100 do
        if not namePlateClassicGrid[namePlate][i] then
            namePlateClassicGrid[namePlate][i] = true
            return i, classicGridData[i].x, classicGridData[i].y
        end
    end
    return nil, 1, 0
end

--STACKING
local function stackingContainerOnUpdate()
    local activeCount = #stackingContainer.activeFrames
    if activeCount <= 0 then return end
    local index = 0
    local newOffsetValue = -((activeCount * (20 / 2)))
    local currentOffsetValue = stackingContainer.offsetValue or 0
    stackingContainer.offsetValue = MoveTowards(currentOffsetValue, newOffsetValue, STACKING_MOVESPEED)
    for _, f in ipairs(stackingContainer.activeFrames) do
        local offsetY = 20 * index + stackingContainer.offsetValue + (f.offsetY or 0)
        if not f.oldOffsetY then f.oldOffsetY = offsetY end
        f.oldOffsetY = MoveTowards(f.oldOffsetY, offsetY, activeCount)
        f:ClearAllPoints()
        f:SetPoint("CENTER", stackingContainer, "CENTER", (f.offsetX or 0), f.oldOffsetY)
        index = index + 1
    end
end

local function animateTextCriticalForStackingFormat(frame)
    frame.oldOffsetY = nil
    GW.AddToAnimation(frame:GetDebugName(), 0, 1, GetTime(), STACKING_CRITICAL_ANIMATION_DURATION,
        function(p)
            local offsetY = -(STACKING_NORMAL_ANIMATION_OFFSET_Y * p)
            frame.offsetY = offsetY
            frame.offsetX = 0
            if p < 0.25 then
                local scaleFade = p - 0.25
                frame.offsetX = GW.lerp(STACKING_NORMAL_ANIMATION_OFFSET_X, 0, scaleFade / 0.25)
                frame:SetScale(GW.lerp(1 * frame.textScaleModifier * math.max(0.1, tonumber(GW.settings.GW_COMBAT_TEXT_FONT_SIZE_CRIT_MODIFIER)), frame.textScaleModifier, scaleFade / 0.25))
            else
                frame:SetScale(frame.textScaleModifier)
            end
            frame:SetAlpha(p > 0.7 and math.min(1, math.max(0, GW.lerp(1, 0, (p - 0.7) / 0.3))) or 1)
        end,
        nil,
        function()
            table.remove(stackingContainer.activeFrames, 1)
            frame:SetScale(1)
            frame:Hide()
        end
    )
end
AFP("animateTextCriticalForStackingFormat", animateTextCriticalForStackingFormat)

local function animateTextNormalForStackingFormat(frame)
    frame.oldOffsetY = nil
    GW.AddToAnimation(frame:GetDebugName(), 0, 1, GetTime(), STACKING_NORMAL_ANIMATION_DURATION,
        function(p)
            frame.offsetX = 0
            frame:SetScale(1 * frame.textScaleModifier)
            frame.offsetY = -(STACKING_NORMAL_ANIMATION_OFFSET_Y * p)
            if p < 0.25 then
                frame.offsetX = GW.lerp(STACKING_NORMAL_ANIMATION_OFFSET_X, 0, (p - 0.25) / 0.25)
            end
            frame:SetAlpha(p > 0.7 and math.min(1, math.max(0, GW.lerp(1, 0, (p - 0.7) / 0.3))) or 1)
        end,
        nil,
        function()
            table.remove(stackingContainer.activeFrames, 1)
            frame:SetScale(1)
            frame:Hide()
        end
    )
end
AFP("animateTextNormalForStackingFormat", animateTextNormalForStackingFormat)

-- DEFAULT
local function animateTextCriticalForDefaultFormat(frame, offsetIndex)
    GW.AddToAnimation(frame:GetDebugName(), 0, 1, GetTime(), CRITICAL_ANIMATION_DURATION,
        function(p)
            if not frame.anchorFrame or not frame.anchorFrame:IsShown() then
                frame.anchorFrame = ClassicDummyFrame
            end
            if p < 0.25 then
                frame:SetScale(GW.lerp(1 * frame.textScaleModifier * math.max(0.1, tonumber(GW.settings.GW_COMBAT_TEXT_FONT_SIZE_CRIT_MODIFIER)), frame.textScaleModifier, p / 0.25))
            else
                frame:SetScale(frame.textScaleModifier)
            end
            if offsetIndex == 0 then
                frame:SetPoint("TOP", frame.anchorFrame, "BOTTOM", 0, 0)
            elseif offsetIndex == 1 then
                frame:SetPoint("TOP", frame.anchorFrame, "BOTTOMLEFT", 0, 0)
            elseif offsetIndex == 2 then
                frame:SetPoint("TOP", frame.anchorFrame, "BOTTOMRIGHT", 0, 0)
            end
            frame:SetAlpha(p > 0.7 and math.min(1, math.max(0, GW.lerp(1, 0, (p - 0.7) / 0.3))) or 1)
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
    GW.AddToAnimation(frame:GetDebugName(), 0, 1, GetTime(), NORMAL_ANIMATION_DURATION,
        function(p)
            if not frame.anchorFrame or not frame.anchorFrame:IsShown() then
                frame.anchorFrame = ClassicDummyFrame

            end
            local offsetY = NORMAL_ANIMATION_OFFSET_Y * p
            frame:SetScale(1 * frame.textScaleModifier)
            if offsetIndex == 0 then
                frame:SetPoint("BOTTOM", frame.anchorFrame, "TOP", 0, offsetY)
            elseif offsetIndex == 1 then
                frame:SetPoint("BOTTOM", frame.anchorFrame, "TOPLEFT", 0, offsetY)
            elseif offsetIndex == 2 then
                frame:SetPoint("BOTTOM", frame.anchorFrame, "TOPRIGHT", 0, offsetY)
            end
            frame:SetAlpha(p > 0.7 and math.min(1, math.max(0, GW.lerp(1, 0, (p - 0.7) / 0.3))) or 1)
        end,
        nil,
        function()
            frame:SetScale(1)
            frame:Hide()
        end
    )
end
AFP("animateTextNormalForDefaultFormat", animateTextNormalForDefaultFormat)

--CLASSIC
local function animateTextCriticalForClassicFormat(frame, gridIndex, x, y)
    NUM_ACTIVE_FRAMES = NUM_ACTIVE_FRAMES + 1
    GW.AddToAnimation(frame:GetDebugName(), 0, 1, GetTime(),
        math.min(CRITICAL_ANIMATION_DURATION * 2, (CRITICAL_ANIMATION_DURATION * (frame.dynamicScaleAdd + math.max(0.1, tonumber(GW.settings.GW_COMBAT_TEXT_FONT_SIZE_CRIT_MODIFIER)))) / getDurationModifier()),
        function(p)
            if not frame.anchorFrame or not frame.anchorFrame:IsShown() then
                frame.anchorFrame = ClassicDummyFrame
                classicPositionGrid(frame.anchorFrame)
            end
            if p < 0.05 and not frame.periodic then
                frame:SetScale(math.max(0.1, GW.lerp(2 * frame.dynamicScale * frame.textScaleModifier * math.max(0.1, tonumber(GW.settings.GW_COMBAT_TEXT_FONT_SIZE_CRIT_MODIFIER)), frame.dynamicScaleAdd, p / 0.05)))
            else
                frame:SetScale(math.max(0.1, frame.dynamicScale * frame.textScaleModifier * math.max(0.1, tonumber(GW.settings.GW_COMBAT_TEXT_FONT_SIZE_CRIT_MODIFIER))))
            end
            frame:SetPoint("CENTER", frame.anchorFrame, "CENTER", 50 * x, 50 * y)
            frame:SetAlpha(p > 0.9 and math.min(1, math.max(0, GW.lerp(1, 0, (p - 0.9) / 0.1))) or 1)
        end,
        nil,
        function()
            if namePlateClassicGrid[frame.anchorFrame] and gridIndex then
                namePlateClassicGrid[frame.anchorFrame][gridIndex] = nil
            end
            frame:SetScale(1)
            frame:Hide()
            NUM_ACTIVE_FRAMES = NUM_ACTIVE_FRAMES - 1
        end
    )
end
AFP("animateTextCriticalForClassicFormat", animateTextCriticalForClassicFormat)

local function animateTextNormalForClassicFormat(frame, gridIndex, x, y)
    NUM_ACTIVE_FRAMES = NUM_ACTIVE_FRAMES + 1
    GW.AddToAnimation(frame:GetDebugName(), 0, 1, GetTime(), NORMAL_ANIMATION_DURATION / getDurationModifier(),
        function(p)
            if not frame.anchorFrame or not frame.anchorFrame:IsShown() then
                frame.anchorFrame = ClassicDummyFrame
                classicPositionGrid(frame.anchorFrame)
            end
            frame:SetPoint("CENTER", frame.anchorFrame, "CENTER", 50 * x, 50 * y)
            if p < 0.10 and not frame.periodic then
                frame:SetScale(math.max(0.1, GW.lerp(1.2 * frame.dynamicScale * frame.textScaleModifier, frame.dynamicScaleAdd, p / 0.10)))
            else
                frame:SetScale(math.max(0.1, frame.dynamicScale * frame.textScaleModifier))
            end
            frame:SetAlpha(p > 0.9 and math.min(1, math.max(0, GW.lerp(1, 0, (p - 0.9) / 0.1))) or 1)
        end,
        nil,
        function()
            if namePlateClassicGrid[frame.anchorFrame] and gridIndex then
                namePlateClassicGrid[frame.anchorFrame][gridIndex] = nil
            end
            frame:SetScale(1)
            frame:Hide()
            NUM_ACTIVE_FRAMES = NUM_ACTIVE_FRAMES - 1
        end
    )
end
AFP("animateTextNormalForClassicFormat", animateTextNormalForClassicFormat)

local createdFramesIndex = 0
local function createNewFontElement(self)
    if createdFramesIndex >= NUM_OBJECTS_HARDLIMIT then
        --optional: return nil
    end
    local f = CreateFrame("FRAME", "GwDamageTextElement" .. createdFramesIndex, self, "GwDamageText")
    f.string:SetJustifyV("MIDDLE")
    f.string:SetJustifyH("Left")
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
    if newFrame then return newFrame end
    for _, f in pairs(fontStringList) do
        return f
    end
end
AFP("getFontElement", getFontElement)

local function setElementData(self, critical, source, missType, blocked, absorbed, periodic, school)
    if missType then
        self.critTexture:Hide()
        self.string:SetFont(DAMAGE_TEXT_FONT, GW.settings.GW_COMBAT_TEXT_FONT_SIZE_MISS, "OUTLINE")
        self.crit = false
    elseif blocked or absorbed then
        self.critTexture:Hide()
        self.string:SetFont(DAMAGE_TEXT_FONT, GW.settings.GW_COMBAT_TEXT_FONT_SIZE_BLOCKED_ABSORBE, "OUTLINE")
        self.crit = false
    elseif critical then
        self.critTexture:Show()
        self.string:SetFont(DAMAGE_TEXT_FONT, GW.settings.GW_COMBAT_TEXT_FONT_SIZE_CRIT, "OUTLINE")
        self.crit = true
    else
        self.critTexture:Hide()
        self.string:SetFont(DAMAGE_TEXT_FONT, GW.settings.GW_COMBAT_TEXT_FONT_SIZE, "OUTLINE")
        self.crit = false
    end

    if periodic and getSchoolIconMap(self.bleedTexture, school) then
        self.bleedTexture:Show()
        self.peroidicBackground:Show()
    else
        self.bleedTexture:Hide()
        self.peroidicBackground:Hide()
    end

    self.pet = (source == "pet")
    self.textScaleModifier = self.pet and math.max(0.1, tonumber(GW.settings.GW_COMBAT_TEXT_FONT_SIZE_PET_MODIFIER)) or 1
    self.periodic = periodic

    local colorSource = (source == "pet" or source == "melee") and source or (source == "heal" and "heal") or "spell"
    local col = usedColorTable[colorSource]
    self.string:SetTextColor(col.r, col.g, col.b, col.a)
    self:Show()
    self:ClearAllPoints()
end
AFP("setElementData", setElementData)

local function formatDamageValue(amount)
    local formatFunction = GW.settings.GW_COMBAT_TEXT_SHORT_VALUES and GW.ShortValue or (GW.settings.GW_COMBAT_TEXT_COMMA_FORMAT and GW.GetLocalizedNumber or nil)
    return formatFunction and formatFunction(amount) or amount
end
AFP("formatDamageValue", formatDamageValue)

local function displayDamageText(self, guid, amount, critical, source, missType, blocked, absorbed, periodic, school)
    local f = getFontElement(self)
    f.string:SetText(missType and _G[missType] or blocked and format(TEXT_MODE_A_STRING_RESULT_BLOCK, formatDamageValue(blocked)) or absorbed and format(TEXT_MODE_A_STRING_RESULT_ABSORB, formatDamageValue(absorbed)) or formatDamageValue(amount))

    if GW.settings.GW_COMBAT_TEXT_STYLE == formats.Default or GW.settings.GW_COMBAT_TEXT_STYLE == formats.Classic then
        local nameplate
        if GW.settings.GW_COMBAT_TEXT_STYLE_CLASSIC_ANCHOR == "Center" and GW.settings.GW_COMBAT_TEXT_STYLE == formats.Classic then
            nameplate = ClassicDummyFrame
        else
            local unit = guidToUnit[guid]
            if unit then
                nameplate = C_NamePlate.GetNamePlateForUnit(unit)
                f.unit = unit
            end
            if not nameplate then
                nameplate = ClassicDummyFrame
            end
        end
        if amount and amount > 0 then
            calcAvarageHit(amount)
        end
        f.anchorFrame = nameplate
        f.dynamicScale = getAvrageHitModifier(amount, critical)
        f.dynamicScaleAdd = getAvrageHitModifier(amount, critical, true)
        setElementData(f, critical, source, missType, blocked, absorbed, periodic, school)
        namePlatesOffsets[nameplate] = (namePlatesOffsets[nameplate] or -1) + 1
        if namePlatesOffsets[nameplate] > 2 then namePlatesOffsets[nameplate] = 0 end

        if critical then
            namePlatesCriticalOffsets[nameplate] = (namePlatesCriticalOffsets[nameplate] or -1) + 1
            if namePlatesCriticalOffsets[nameplate] > 2 then namePlatesCriticalOffsets[nameplate] = 0 end
            if GW.settings.GW_COMBAT_TEXT_STYLE == formats.Default then
                CRITICAL_ANIMATION(f, namePlatesCriticalOffsets[nameplate])
            else
                CRITICAL_ANIMATION(f, classicPositionGrid(nameplate))
            end
            return
        end
        if GW.settings.GW_COMBAT_TEXT_STYLE == formats.Default then
            NORMAL_ANIMATION(f, namePlatesOffsets[nameplate])
        else
            NORMAL_ANIMATION(f, classicPositionGrid(nameplate))
        end
    elseif GW.settings.GW_COMBAT_TEXT_STYLE == formats.Stacking then
        f.anchorFrame = stackingContainer
        stackingContainer.activeFrames[#stackingContainer.activeFrames + 1] = f
        setElementData(f, critical, source, missType, blocked, absorbed, periodic, school)
        if critical then
            CRITICAL_ANIMATION(f)
        else
            NORMAL_ANIMATION(f)
        end
    end
end
AFP("displayDamageText", displayDamageText)

local function handleCombatLogEvent(self, _, event, _, sourceGUID, _, sourceFlags, _, destGUID, _, _, _, ...)
    if not destGUID then return end

    local isMine = GW.myguid == sourceGUID
    local isPet = bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
    local isGuardianOrPet = isPet and (bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0 or bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) > 0)
    if not isMine and not isGuardianOrPet then
        return
    end

    local isDamage = event:find("_DAMAGE", 1, true)
    local isMiss = not isDamage and event:find("_MISSED", 1, true)
    local isHeal = not isDamage and not isMiss and event:find("_HEAL", 1, true)

    -- Damage events
    if isDamage then
        local spellName, amount, blocked, absorbed, critical, localElement
        local periodic = event:find("PERIODIC", 1, true)
        if event:find("SWING", 1, true) then
            spellName, amount, _, _, _, blocked, absorbed, critical = "melee", ...
        elseif event:find("ENVIRONMENTAL", 1, true) then
            spellName, amount, _, _, _, blocked, absorbed, critical = ...
        else
            _, spellName, localElement, amount, _, _, _, blocked, absorbed, critical = ...
        end
        displayDamageText(self, destGUID, amount, critical, isGuardianOrPet and "pet" or spellName, nil, blocked, absorbed, periodic, localElement)
        return
    end

    -- Miss events
    if isMiss then
        local missType
        if event:find("RANGE", 1, true) or event:find("SPELL", 1, true) then
            missType = select(4, ...)
        elseif event:find("SWING", 1, true) then
            missType = ...
        elseif not isGuardianOrPet then
            _, _, _, missType = ...
        end
        displayDamageText(self, destGUID, nil, nil, isGuardianOrPet and "pet" or nil, missType)
        return
    end

    -- Heal events (only relevant styles)
    if isHeal and ((GW.settings.GW_COMBAT_TEXT_STYLE == formats.Stacking) or (GW.settings.GW_COMBAT_TEXT_STYLE == formats.Classic and GW.settings.GW_COMBAT_TEXT_STYLE_CLASSIC_ANCHOR == "Center")) and GW.settings.GW_COMBAT_TEXT_SHOW_HEALING_NUMBERS then
        local amount, overhealing, absorbed, critical = select(4, ...)
        if amount and amount > (overhealing or 0) then
            displayDamageText(self, destGUID, (amount - overhealing), critical, "heal", nil, nil, (absorbed and absorbed > 0) and absorbed or nil)
        end
    end
end
AFP("handleCombatLogEvent", handleCombatLogEvent)

local function freeClassicGrid(namePlate)
    local grid = namePlateClassicGrid[namePlate]
    if grid then wipe(grid) end
end

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
    freeClassicGrid(unitID)
    if GW.settings.GW_COMBAT_TEXT_STYLE == formats.Classic or GW.settings.GW_COMBAT_TEXT_STYLE == formats.Default then
        return
    end
    for _, f in pairs(fontStringList) do
        if f.unit and f.unit == unitID  then
            f:Hide()
        end
    end
end
AFP("onNamePlateRemoved", onNamePlateRemoved)

local function RescanAllNameplates()
    for _, frame in pairs(C_NamePlate_GetNamePlates(false)) do
        local guid = UnitGUID(frame.namePlateUnitToken)
        if guid then
            unitToGuid[frame.namePlateUnitToken] = guid
            guidToUnit[guid] = frame.namePlateUnitToken
        end
    end
end

local function ToggleFormat(activate)
    if activate then
        GW.Libs.GW2Lib:RegisterCombatEvent(eventHandler, "_DAMAGE", handleCombatLogEvent)
        GW.Libs.GW2Lib:RegisterCombatEvent(eventHandler, "_MISSED", handleCombatLogEvent)
        GW.Libs.GW2Lib:RegisterCombatEvent(eventHandler, "_HEAL", handleCombatLogEvent)


        eventHandler:RegisterEvent("CVAR_UPDATE")
        eventHandler:SetScript("OnEvent", function(_, event, ...)
            if event == "NAME_PLATE_UNIT_ADDED" then
                onNamePlateAdded(eventHandler, event, ...)
            elseif event == "NAME_PLATE_UNIT_REMOVED" then
                onNamePlateRemoved(eventHandler, event, ...)
            elseif event == "CVAR_UPDATE" then
                local eventName, value = ...
                if eventName == "floatingCombatTextCombatDamage" and value == "1" then
                    C_CVar.SetCVar("floatingCombatTextCombatDamage", "0")
                elseif eventName == "floatingCombatTextCombatHealing" then
                    C_CVar.SetCVar("floatingCombatTextCombatHealing", (GW.settings.GW_COMBAT_TEXT_SHOW_HEALING_NUMBERS and "0" or "1"))
                end
            end
        end)

        if GW.settings.GW_COMBAT_TEXT_STYLE == formats.Default or GW.settings.GW_COMBAT_TEXT_STYLE == formats.Classic then
            ToggleMover(stackingContainer.gwMover, false)
            stackingContainer:SetScript("OnUpdate", nil)
            stackingContainer:Hide()
            ClassicDummyFrame:Show()
            wipe(stackingContainer.activeFrames)
            NUM_OBJECTS_HARDLIMIT = 20
            if GW.settings.GW_COMBAT_TEXT_STYLE == formats.Classic then
                CRITICAL_ANIMATION = animateTextCriticalForClassicFormat
                NORMAL_ANIMATION = animateTextNormalForClassicFormat
                if GW.settings.GW_COMBAT_TEXT_STYLE_CLASSIC_ANCHOR == "Nameplates" then
                    eventHandler:RegisterEvent("NAME_PLATE_UNIT_ADDED")
                    eventHandler:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
                    RescanAllNameplates()
                else
                    eventHandler:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
                    eventHandler:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
                    wipe(unitToGuid)
                    wipe(guidToUnit)
                end
            else
                CRITICAL_ANIMATION = animateTextCriticalForDefaultFormat
                NORMAL_ANIMATION = animateTextNormalForDefaultFormat
                eventHandler:RegisterEvent("NAME_PLATE_UNIT_ADDED")
                eventHandler:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
                RescanAllNameplates()
                wipe(namePlateClassicGrid)
            end
        elseif GW.settings.GW_COMBAT_TEXT_STYLE == formats.Stacking then
            ClassicDummyFrame:Hide()
            CRITICAL_ANIMATION = animateTextCriticalForStackingFormat
            NORMAL_ANIMATION = animateTextNormalForStackingFormat
            NUM_OBJECTS_HARDLIMIT = 50
            eventHandler:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
            eventHandler:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
            wipe(unitToGuid)
            wipe(guidToUnit)
            wipe(namePlateClassicGrid)
            wipe(stackingContainer.activeFrames)
            stackingContainer:SetScript("OnUpdate", stackingContainerOnUpdate)
            stackingContainer:Show()
            ToggleMover(stackingContainer.gwMover, true)
        end
    else
        eventHandler:UnregisterAllEvents()
        eventHandler:SetScript("OnEvent", nil)
        GW.Libs.GW2Lib:UnregisterAllCombatEvents(eventHandler)
        wipe(unitToGuid)
        wipe(guidToUnit)
        ToggleMover(stackingContainer.gwMover, false)
        stackingContainer:SetScript("OnUpdate", nil)
        stackingContainer:Hide()
        ClassicDummyFrame:Hide()
    end
end
GW.FloatingCombatTextToggleFormat = ToggleFormat

local function LoadDamageText(activate)
    UpdateSettings()

    -- Create the needed frames
    stackingContainer = CreateFrame("Frame", nil, UIParent)
    stackingContainer:SetSize(200, 400)
    stackingContainer:EnableMouse(false)
    RegisterMovableFrame(stackingContainer, GW.L["FCT Container"], "FCT_STACKING_CONTAINER", ALL .. ",FCT", nil, {"default", "scaleable"})
    stackingContainer:ClearAllPoints()
    stackingContainer:SetPoint("TOPLEFT", stackingContainer.gwMover)
    stackingContainer.activeFrames = {}

    ClassicDummyFrame = CreateFrame("Frame", nil, UIParent)
    ClassicDummyFrame:ClearAllPoints()
    ClassicDummyFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    ClassicDummyFrame:SetSize(100, 50)
    ClassicDummyFrame:EnableMouse(false)

    ToggleFormat(activate)
end
GW.LoadDamageText = LoadDamageText
