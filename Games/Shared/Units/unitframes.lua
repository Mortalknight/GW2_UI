---@class GW2
local GW = select(2, ...)
local TimeCount = GW.TimeCount
local GWGetClassColor = GW.GWGetClassColor
local TARGET_FRAME_ART = GW.TARGET_FRAME_ART
local RegisterMovableFrame = GW.RegisterMovableFrame

local IsIn = GW.IsIn
local RoundDec = GW.RoundDec
local LoadAuras = GW.LoadAuras
local PopulateUnitIlvlsCache = GW.PopulateUnitIlvlsCache

-- the text lines of the frames with a text designer, false in the settings means the built-in line
local DEFAULT_TEXT_BLOCKS = {
    nameText = {{k = "leaderIcon"}, {k = "name"}},
    levelText = {{k = "level", colored = true}},
    healthText = {},
    powerText = {},
}

-- the player frame showed its power value, the health globe, the player frame and the pet the health value
local function GetDefaultTextBlocks(unit, line)
    if unit == "player" and line == "powerText" then
        return {{k = "power", mode = "CUR"}}
    elseif line == "healthText" and (unit == "player" or unit == "pet" or unit == "healthGlobe") then
        return {{k = "healthValue", mode = "HEALTH"}}
    elseif line == "absorbText" then
        return {{k = "absorb", mode = "CUR"}}
    elseif (unit == "boss" or unit == "arena") and line == "healthText" then
        return {{k = "healthValue", mode = "PREC"}}
    elseif unit == "boss" and line == "nameText" then
        return {{k = "name"}}
    elseif unit == "boss" and line == "powerText" then
        return {{k = "power", mode = "PREC"}}
    elseif unit == "arena" and line == "nameText" then
        -- like the arena frames showed it: the faction in battlegrounds, the spec in the arena
        return {{k = "factionIcon", onlyBattleground = true}, {k = "roleIcon"}, {k = "name"}, {k = "arenaspec", dash = true}}
    elseif unit == "party" and line == "nameText" then
        return {{k = "leaderIcon"}, {k = "roleIcon"}, {k = "name"}}
    elseif unit == "party" and line == "levelText" then
        return {{k = "level"}}
    end
    return DEFAULT_TEXT_BLOCKS[line]
end

-- boss and arena frames keep their settings with the objectives
local function GetTextSettings(unit)
    return unit == "boss" and GW.settings.objectives.bossFrames or unit == "arena" and GW.settings.objectives.arenaFrames
        or GW.settings.unitframes[unit]
end

function GW.GetUnitFrameTextBlocks(unit, line)
    return GetTextSettings(unit)[line] or GetDefaultTextBlocks(unit, line)
end

local UNIT_FRAME_LINES = {
    {key = "nameText", label = GW.L["Name Line"]},
    {key = "levelText", label = LEVEL},
    {key = "healthText", label = HEALTH},
    {key = "powerText", label = GW.L["Power"]},
}
-- the pet frame has no name and level, boss and arena frames no level
local PET_LINES = {UNIT_FRAME_LINES[3], UNIT_FRAME_LINES[4]}
local OBJECTIVES_LINES = {UNIT_FRAME_LINES[1], UNIT_FRAME_LINES[3], UNIT_FRAME_LINES[4]}

-- the lines of a unit frame in the text designer, frameName is the global of the frame or a function that
-- updates the frames
function GW.GetUnitFrameTextTarget(unit, frameName)
    local isPet = unit == "pet"
    return {
        createPreview = function(parent)
            local builder = GW.UnitFrameTextPreviewBuilders[unit]
            return GW.CreateUnitFrameTextPreview(parent, builder.create(unit), builder.apply)
        end,
        height = not isPet and unit ~= "boss" and unit ~= "arena" and 540 or nil,
        player = unit == "player",
        -- the pet has no name line, names and group icons make no sense there
        categories = isPet and {health = true, power = true, status = true, color = true, text = true} or nil,
        lines = isPet and PET_LINES or (unit == "boss" or unit == "arena") and OBJECTIVES_LINES or UNIT_FRAME_LINES,
        get = function(line) return GW.GetUnitFrameTextBlocks(unit, line) end,
        -- nil goes back to the built-in line
        set = function(line, blocks)
            GetTextSettings(unit)[line] = blocks or false
            if type(frameName) == "function" then
                frameName()
            elseif _G[frameName] then
                _G[frameName]:ApplyTextTags()
            end
        end,
    }
end

local function castingbarOnUpdate(self)
    local frame = self:GetParent()
    if (frame.casting or frame.channeling or frame.empowering) and frame.showCastingbarTimer and self.castingTimeString then
        local durationObject = self:GetTimerDuration()
        if durationObject then
            self.castingTimeString:SetFormattedText("%.1fs", durationObject:GetRemainingDuration())
        end
    end
end

local function CreateUnitFrame(name, revert, animatedPowerbar)
    local template
    if GW.isModern then
        if revert then
            template = "GwNormalUnitFrameInvertPingableModernTemplate"
        else
            template = "GwNormalUnitFramePingableModernTemplate"
        end
    else
        if revert then
            template = "GwNormalUnitFrameInvert"
        else
            template = "GwNormalUnitFrame"
        end
    end
    local f = CreateFrame("Button", name, UIParent, template)
    GW.SetFrameRoleset(f, "unitFrames")

    local hg = f.healthContainer
    f.portrait:ClearAllPoints()
    f.portrait:SetPoint("CENTER", f.portraitAnchor)

    if GW.isModern then
        f.absorbOverlay = hg.health.overDamageAbsorbIndicator
        f.antiHeal      = hg.healAbsorb
        f.health        = hg.health
        f.absorbbg      = hg.damageAbsorb
        f.healPrediction= hg.healPrediction
        f.healthString  = hg.health.healthString
        f.nameString    = hg.health.nameString
        f.levelString   = hg.health.levelString

        f.hpValues = CreateUnitHealPredictionCalculator()
        f.hpValues:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth)
        f.hpValues:SetHealAbsorbClampMode(Enum.UnitHealAbsorbClampMode.CurrentHealth)
        f.hpValues:SetIncomingHealClampMode(Enum.UnitIncomingHealClampMode.MissingHealth)
        f.hpValues:SetHealAbsorbMode(Enum.UnitHealAbsorbMode.ReducedByIncomingHeals)
        f.hpValues:SetIncomingHealOverflowPercent(1)

        --setting up the statusbars
        local anchor1, anchor2 = "LEFT", "RIGHT"

        if revert then
            anchor1 = "RIGHT"
            anchor2 = "LEFT"
        end
        f.healPrediction:ClearAllPoints()
        f.healPrediction:SetPoint("TOP")
        f.healPrediction:SetPoint("BOTTOM")
        f.healPrediction:SetPoint(anchor1, f.health:GetStatusBarTexture(), anchor2)

        f.absorbbg:ClearAllPoints()
        f.absorbbg:SetPoint("TOP")
        f.absorbbg:SetPoint("BOTTOM")
        f.absorbbg:SetPoint(anchor1, f.healPrediction:GetStatusBarTexture(), anchor2)

        f.antiHeal:ClearAllPoints()
        f.antiHeal:SetPoint("TOP")
        f.antiHeal:SetPoint("BOTTOM")
        f.antiHeal:SetPoint(anchor2, f.health:GetStatusBarTexture())
        f.antiHeal:SetReverseFill(true)

        f.absorbOverlay:ClearAllPoints()
        f.absorbOverlay:SetPoint("TOP")
        f.absorbOverlay:SetPoint("BOTTOM")
        f.absorbOverlay:SetPoint(anchor1, f.health, anchor2, revert and 14 or -8, 0)
        f.absorbOverlay:SetWidth(16)

        f.powerbarContainer.powerbar = CreateFrame("StatusBar", name .. "Powerbar", f, "GwStatusPowerBarModernTemplate")
        f.powerbar = f.powerbarContainer.powerbar

        if animatedPowerbar then
            f.powerbar.bar = f.powerbar
        end

        f.castingbarNormal:SetScript("OnUpdate", castingbarOnUpdate)
    else
        f.absorbOverlay = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay
        f.antiHeal      = hg.healPrediction.absorbbg.health.antiHeal
        f.health        = hg.healPrediction.absorbbg.health
        f.absorbbg      = hg.healPrediction.absorbbg
        f.healPrediction= hg.healPrediction
        f.healthString  = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay.healthString
        f.nameString    = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay.nameString
        f.levelString   = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay.levelString

        GW.AddStatusbarAnimation(f.absorbOverlay, true)
        GW.AddStatusbarAnimation(f.antiHeal, true)
        GW.AddStatusbarAnimation(f.health, true)
        GW.AddStatusbarAnimation(f.absorbbg, true)
        GW.AddStatusbarAnimation(f.healPrediction, false)
        GW.AddStatusbarAnimation(f.castingbarNormal, false)

        if animatedPowerbar then
            f.powerbarContainer.powerbar = GW.CreateAnimatedStatusBar(name .. "Powerbar", f, "GwStatusPowerBar", true)
            f.powerbar = f.powerbarContainer.powerbar
            f.powerbar.bar = f.powerbar
            f.powerbar:AddToBarMask(f.powerbar.intensity)
            f.powerbar:AddToBarMask(f.powerbar.intensity2)
            f.powerbar:AddToBarMask(f.powerbar.scrollTexture)
            f.powerbar:AddToBarMask(f.powerbar.scrollTexture2)
            f.powerbar:AddToBarMask(f.powerbar.runeoverlay)
            f.powerbar.runicmask:SetSize(f.powerbar:GetSize())
            f.powerbar.runeoverlay:AddMaskTexture(f.powerbar.runicmask)

            f.powerbar.decay = GW.CreateAnimatedStatusBar(name .. "decay", f.powerbar, nil, true)

            f.powerbar.decay:SetFillAmount(0)
            f.powerbar.decay:SetFrameLevel(f.powerbar.decay:GetFrameLevel() - 1)
            f.powerbar.decay:ClearAllPoints()
            f.powerbar.decay:SetPoint("TOPLEFT", f.powerbar, "TOPLEFT", 0, 0)
            f.powerbar.decay:SetPoint("BOTTOMRIGHT", f.powerbar, "BOTTOMRIGHT", 0, 0)

            f.powerbar.label:SetPoint("LEFT", f.powerbar, "LEFT", 5, 0)
            f.powerbar.label:SetJustifyH("LEFT")
        else
            f.powerbarContainer.powerbar = GW.CreateAnimatedStatusBar(name .. "Powerbar", f, nil, true)
            f.powerbar = f.powerbarContainer.powerbar
        end

        local elements = { f.absorbOverlay, f.antiHeal, f.health, f.absorbbg, f.healPrediction, f.castingbarNormal, f.powerbar}
        for _, element in ipairs(elements) do
            element.customMaskSize = 64
        end

        f.absorbOverlay:SetStatusBarColor(1, 1, 1, 0.66)
    end

    f.powerbarContainer.powerbar:SetSize(213, 3)
    f.powerbar:SetAllPoints(f.powerbarContainer)
    f.powerbar.label:Hide()

    f.absorbbg:SetStatusBarColor(1, 1, 1, 0.66)
    f.healPrediction:SetStatusBarColor(0.58431, 0.9372, 0.2980, 0.60)

    f.frameInvert = revert

    if revert then
        f.healthString:ClearAllPoints()
        f.healthString:SetPoint("RIGHT", f.health, "RIGHT", -5, 0)
        f.healthString:SetJustifyH("RIGHT")
        f.powerbar.label:SetPoint("RIGHT", f.powerbar, "RIGHT", -5, 0)
        f.powerbar.label:SetJustifyH("RIGHT")
        local reverseElements = { f.absorbOverlay, f.antiHeal, f.health, f.absorbbg, f.healPrediction, f.powerbar, f.castingbarNormal, f.powerbar.decay }
        for _, bar in ipairs(reverseElements) do
            if bar and bar.SetReverseFill then
                bar:SetReverseFill(true)
            end
        end
        f.castingbarNormal.internalBar:SetTexCoord(1, 0, 0, 1)
        if f.castingbarSpark then
            f.castingbarSpark:SetTexCoord(1, 0, 0, 1)
        end
    end

    f.powerbar.label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "SHADOW", -2)
    f.healthString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    f.nameString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header, "SHADOW")
    f.threatString:GwSetFontTemplate(STANDARD_TEXT_FONT, GW.Enum.TextSizeType.Small, "SHADOW")
    f.levelString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header, "SHADOW")
    f.castingString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    f.castingbarNormal.castingString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    f.castingbarNormal.castingTimeString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    f.castingTimeString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    f.prestigeString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "OUTLINE")
    f.prestigebg:SetPoint("CENTER", f.prestigeString, "CENTER", -1, 1)
    f.prestigebg:Hide()
    f.prestigeString:Hide()

    f:SetScript("OnEnter", f.OnEnter)
    f:SetScript("OnLeave", GameTooltip_Hide)

    GW.Gw2ClassColorRegister(nil, function() f:UnitFrameData() end)

    return f
end
GW.CreateUnitFrame = CreateUnitFrame

local function CreateSmallUnitFrame(name)
    local f = CreateFrame("Button", name, UIParent, GW.isModern and "GwNormalUnitFramePingableSmallModernTemplate" or "GwNormalUnitFrameSmall")
    GW.SetFrameRoleset(f, "unitFrames")

    local hg = f.healthContainer

    if GW.isModern then
        f.absorbOverlay = hg.health.overDamageAbsorbIndicator
        f.antiHeal      = hg.healAbsorb
        f.health        = hg.health
        f.absorbbg      = hg.damageAbsorb
        f.healPrediction= hg.healPrediction
        f.healthString  = hg.health.healthString
        f.nameString    = hg.health.nameString
        f.levelString   = hg.health.levelString

        f.powerbarContainer.powerbar = CreateFrame("StatusBar", name .. "Powerbar", f, "GwStatusPowerBarModernTemplate")
        f.powerbar = f.powerbarContainer.powerbar
        f.powerbar:SetAllPoints(f.powerbarContainer)

        f.hpValues = CreateUnitHealPredictionCalculator()
        f.hpValues:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth)
        f.hpValues:SetHealAbsorbClampMode(Enum.UnitHealAbsorbClampMode.CurrentHealth)
        f.hpValues:SetIncomingHealClampMode(Enum.UnitIncomingHealClampMode.MissingHealth)
        f.hpValues:SetHealAbsorbMode(Enum.UnitHealAbsorbMode.ReducedByIncomingHeals)
        f.hpValues:SetIncomingHealOverflowPercent(1)

        --setting up the statusbars
        f.healPrediction:ClearAllPoints()
        f.healPrediction:SetPoint("TOP")
        f.healPrediction:SetPoint("BOTTOM")
        f.healPrediction:SetPoint("LEFT", f.health:GetStatusBarTexture(), "RIGHT")

        f.absorbbg:ClearAllPoints()
        f.absorbbg:SetPoint("TOP")
        f.absorbbg:SetPoint("BOTTOM")
        f.absorbbg:SetPoint("LEFT", f.healPrediction:GetStatusBarTexture(), "RIGHT")

        f.antiHeal:ClearAllPoints()
        f.antiHeal:SetPoint("TOP")
        f.antiHeal:SetPoint("BOTTOM")
        f.antiHeal:SetPoint("RIGHT", f.health:GetStatusBarTexture())
        f.antiHeal:SetReverseFill(true)

        f.absorbOverlay:ClearAllPoints()
        f.absorbOverlay:SetPoint("TOP")
        f.absorbOverlay:SetPoint("BOTTOM")
        f.absorbOverlay:SetPoint("LEFT", f.health, "RIGHT", -8, 0)
        f.absorbOverlay:SetWidth(16)
    else
        f.absorbOverlay = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay
        f.antiHeal      = hg.healPrediction.absorbbg.health.antiHeal
        f.health        = hg.healPrediction.absorbbg.health
        f.absorbbg      = hg.healPrediction.absorbbg
        f.healPrediction= hg.healPrediction
        f.healthString  = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay.healthString
        f.nameString    = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay.nameString
        f.levelString   = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay.levelString

        f.powerbarContainer.powerbar = GW.CreateAnimatedStatusBar(name .. "Powerbar", f, nil, true)
        f.powerbar = f.powerbarContainer.powerbar
        f.powerbar:SetAllPoints(f.powerbarContainer)

        GW.AddStatusbarAnimation(f.absorbOverlay, true)
        GW.AddStatusbarAnimation(f.antiHeal, true)
        GW.AddStatusbarAnimation(f.health, true)
        GW.AddStatusbarAnimation(f.absorbbg, true)
        GW.AddStatusbarAnimation(f.healPrediction, false)
        GW.AddStatusbarAnimation(f.castingbarNormal, false)

        local elements = { f.absorbOverlay, f.antiHeal, f.health, f.absorbbg, f.healPrediction, f.castingbarNormal, f.powerbar }
        for _, element in ipairs(elements) do
            element.customMaskSize = 64
        end

        f.absorbOverlay:SetStatusBarColor(1, 1, 1, 0.66)
    end

    f.absorbbg:SetStatusBarColor(1, 1, 1, 0.66)
    f.healPrediction:SetStatusBarColor(0.58431, 0.9372, 0.2980, 0.60)

    f.healthString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    f.nameString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header, "SHADOW")
    f.levelString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header, "SHADOW")
    f.castingString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    f.castingbarNormal.castingString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    f.castingbarNormal.castingTimeString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")

    f:SetScript("OnEnter", f.OnEnter)
    f:SetScript("OnLeave", GameTooltip_Hide)

    GW.Gw2ClassColorRegister(nil, function() f:UnitFrameData() end)

    return f
end

GwUnitFrameMixin = {}

function GwUnitFrameMixin:OnEnter()
    if self.gwUnit then
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(self.gwUnit)
        GameTooltip:Show()
    end
end

function GwUnitFrameMixin:UpdateHealthbarColor()
    local unit = self.gwUnit
    local healthBar = self.health
    local nameString = self.nameString

    if self.classColor and (UnitIsPlayer(unit) or UnitInPartyIsAI(unit)) then
        local _, englishClass = UnitClass(unit)
        local color = GWGetClassColor(englishClass, true)
        healthBar:SetStatusBarColor(color:GetRGB())
        nameString:SetTextColor(color:GetRGB())
    else
        local unitReaction = UnitReaction(unit, "player")
        local nameColor = unitReaction and GW.Colors.FactionBarColors[unitReaction] or RAID_CLASS_COLORS.PRIEST
        if unitReaction then
            if unitReaction <= 3 then
                nameColor = GW.Colors.UnitFrameReactionColors.Hostile
            elseif unitReaction >= 5 then
                nameColor = GW.Colors.UnitFrameReactionColors.Friendly
            end
        end

        if UnitIsTapDenied(unit) then
            nameColor = GW.Colors.UnitFrameReactionColors.TappedDenied
        end

        healthBar:SetStatusBarColor(nameColor:GetRGB())
        nameString:SetTextColor(nameColor:GetRGB())
    end

    if (UnitLevel(unit) - GW.mylevel) <= -5 then
        local r, g, b = nameString:GetTextColor()
        if GW.IsSecretValue(r) then return end
        nameString:SetTextColor(r + 0.5, g + 0.5, b + 0.5, 1)
    end
end

-- our four prestige portrait arts follow the four art sets of blizzard's honor badges,
-- which start at honor level 5, 25, 70 and 250
local PRESTIGE_TIER_LEVELS = {5, 25, 70, 250}

local function GetPrestigeBorder(honorLevel)
    if GW.IsSecretValue(honorLevel) or not honorLevel then return end
    for tier = #PRESTIGE_TIER_LEVELS, 1, -1 do
        if honorLevel >= PRESTIGE_TIER_LEVELS[tier] then
            return "prestige" .. tier
        end
    end
end

function GwUnitFrameMixin:SetUnitPortraitFrame()
    if not self.portrait or not self.background then return end

    local unit = self.gwUnit
    local border = "normal"
    local txt
    local unitLevel = UnitLevel(unit)
    local unitClassification = UnitClassification(unit)
    local canInspect = UnitIsPlayer(unit) and (not (GW.Mists or GW.Wrath) or (not InCombatLockdown() and CheckInteractDistance(unit, 4)) and CanInspect(unit))

    if TARGET_FRAME_ART[unitClassification] then
        border = unitClassification
        if unitLevel == -1 then border = "boss" end
    end

    -- the own frame shows its honor tier with the pvp indicator option
    if unit == "player" then
        if UnitHonorLevel and GW.settings.unitframes.player.pvpIndicator then
            border = GetPrestigeBorder(UnitHonorLevel(unit)) or border
        end
    elseif not (GW.Classic or GW.TBC or GW.Wrath) and canInspect then
        if self.showItemLevel == "ITEM_LEVEL" then
            local guid = UnitGUID(self.gwUnit)
            if GW.NotSecretValue(guid) and guid then
                local cachedIlvl = GW.unitIlvlsCache[guid]
                if cachedIlvl and cachedIlvl.itemLevel then
                    txt = RoundDec(cachedIlvl.itemLevel, 0)
                end
            end
        elseif self.showItemLevel == "PVP_LEVEL" then
            local honorLevel = GW.Retail and UnitHonorLevel(unit) or 0
            border = GetPrestigeBorder(honorLevel) or border
            txt = honorLevel
        end
    end

    if txt then
        self.prestigebg:Show()
        self.prestigeString:Show()
        self.prestigeString:SetText(txt)
    else
        self.prestigebg:Hide()
        self.prestigeString:Hide()
    end

    --if DBM or BigWigs is load, check if target is a boss and set boss frame
    local foundBossMod = false
    if not GW.Retail and DBM and DBM.ModLists then
        local npcId = GW.GetUnitCreatureId(unit)
        if npcId ~= nil then
            for _, mods in pairs(DBM.ModLists) do
                for _, id in ipairs(mods) do
                    local mod = DBM:GetModByName(id)
                    if mod and mod.creatureId == npcId then
                        foundBossMod = true
                        break
                    end
                end
                if foundBossMod then
                    break
                end
            end
        end
    elseif not GW.Retail and BigWigs then
        local npcId = GW.GetUnitCreatureId(unit)
        if npcId ~= nil then
            for _, module in BigWigs:IterateBossModules() do
                if module.enableMobs[npcId] then
                    foundBossMod = true
                    break
                end
            end
        end
    end
    if foundBossMod then
        border = (border == "boss") and "realboss" or "boss"
    end

    self.background:SetTexture(TARGET_FRAME_ART[border])
end

function GwUnitFrameMixin:UpdateAvgItemLevel(guid)
    local selfGuid = UnitGUID(self.gwUnit)
    -- secret guids cannot be compared nor used as cache keys
    if GW.IsSecretValue(guid) or GW.IsSecretValue(selfGuid) or guid ~= selfGuid or not UnitIsPlayer(self.gwUnit) or (GW.Mists and not InCombatLockdown() and not CheckInteractDistance(self.gwUnit, 4)) or not CanInspect(self.gwUnit) then return end

    local itemLevel, retryUnit, retryTable, iLevelDB = GW.GetUnitItemLevel(self.gwUnit)

    if itemLevel == "tooSoon" then
        C_Timer.After(0.05, function()
            local canUpdate = true

            for _, slot in ipairs(retryTable) do
                local slotInfo = GW.GetGearSlotInfo(retryUnit, slot)
                if slotInfo == "tooSoon" then
                    canUpdate = false
                    break
                end
                iLevelDB[slot] = slotInfo.iLvl
            end

            if canUpdate then
                local calculatedIlvl = GW.CalculateAverageItemLevel(iLevelDB, retryUnit)
                PopulateUnitIlvlsCache(guid, calculatedIlvl)
                ClearInspectPlayer()
                self:UnregisterEvent("INSPECT_READY")
                self:SetUnitPortraitFrame()
            end
        end)
    else
        PopulateUnitIlvlsCache(guid, itemLevel)
        self:UnregisterEvent("INSPECT_READY")
        self:SetUnitPortraitFrame()
    end
end

function GwUnitFrameMixin:UpdateRaidMarkers()
    local i = GetRaidTargetIndex(self.gwUnit)
    if i then
        SetRaidTargetIconTexture(self.raidmarker, i)
        self.raidmarker:Show()
    else
        self.raidmarker:Hide()
    end
end

function GwUnitFrameMixin:SetUnitPortrait()
    if not self.portrait then return end
    SetPortraitTexture(self.portrait, self.gwUnit)
    if self.frameInvert then
        self.portrait:SetTexCoord(1, 0, 0, 1)
    end
    self.activePortrait = nil
end

-- name and level are tags of the text designer, here only their colors
function GwUnitFrameMixin:UnitFrameData()
    if self.gwUnit == "player" and self.classColor and UnitIsPlayer(self.gwUnit) then
        local _, englishClass = UnitClass(self.gwUnit)
        local color = GW.GWGetClassColor(englishClass, true)

        self.health:SetStatusBarColor(color:GetRGB())
        self.nameString:SetTextColor(color:GetRGB())
    else
        self:UpdateHealthbarColor()
    end

    self:SetUnitPortrait()
    self:SetUnitPortraitFrame()
    -- the tag events only reach shown texts of the same unit, a new unit and the polled small frames need a push
    self:UpdateTextTags()
end

function GwUnitFrameMixin:UpdatePvpIndicator()
    self.pvp:SetShown(GW.settings.unitframes.player.pvpIndicator)
    self:SelectPvp()
    self:SetUnitPortraitFrame()
end

function GwUnitFrameMixin:SelectPvp()
    local prevFlag = self.pvp.pvpFlag
    if GW.settings.unitframes.player.pvpIndicator and ((GW.Retail and C_PvP.IsWarModeDesired()) or GetPVPDesired() or UnitIsPVP("player") or UnitIsPVPFreeForAll("player")) then
        self.pvp.pvpFlag = true
        if prevFlag ~= true then
            if GW.myfaction == "Horde" then
                self.pvp.ally:Hide()
                self.pvp.horde:Show()
            else
                self.pvp.ally:Show()
                self.pvp.horde:Hide()
            end
        end
    else
        self.pvp.pvpFlag = false
        self.pvp.ally:Hide()
        self.pvp.horde:Hide()
    end
end

function GwUnitFrameMixin:NormalCastBarAnimation(powerPrec)
    self.castingbarNormal:SetFillAmount(powerPrec)
end

function GwUnitFrameMixin:ProtectedCastAnimation(powerPrec)
    local powerBarWidth = self.healthContainer:GetWidth()
    local bit = powerBarWidth / 16
    local spark = bit * math.floor(16 * (powerPrec))
    local segment = math.floor(16 * (powerPrec))
    local sparkPoint = (powerBarWidth * powerPrec) - 20

    self.castingbarSpark:SetWidth(math.min(32, 32 * (powerPrec / 0.10)))
    if self.frameInvert then
        self.castingbarSpark:SetPoint("RIGHT", self.castingbar, "RIGHT", -math.max(0, sparkPoint), 0)
        self.castingbar:SetTexCoord(math.min(1, math.max(0, 0.0625 * segment)), 0, 0, 1)
        self.castingbar:SetWidth(-math.min(powerBarWidth, math.max(1, spark)))
    else
        self.castingbarSpark:SetPoint("LEFT", self.castingbar, "LEFT", math.max(0, sparkPoint), 0)
        self.castingbar:SetTexCoord(0, math.min(1, math.max(0, 0.0625 * segment)), 0, 1)
        self.castingbar:SetWidth(math.min(powerBarWidth, math.max(1, spark)))
    end
end

function GwUnitFrameMixin:ClearInterrupt()
    if self.interruptTimer then
        self.interruptTimer:Cancel()
        self.interruptTimer = nil
    end
    GW.StopAnimation("GwUnitFrame" .. self.gwUnit .. "Shake")
    self.interruptShown = nil
end

-- an interrupted cast stays a moment in red with who interrupted it, after a light shake
function GwUnitFrameMixin:ShowInterrupt(interruptedBy)
    if self.interruptShown then return end
    local bar = self.castingbarNormal
    if not (self.showInterrupts and bar:IsShown() and (self.casting or self.channeling or self.empowering)) then
        self:HideCastBar()
        return
    end

    self.interruptShown = true
    self.casting, self.channeling, self.empowering = false, false, false
    GW.StopAnimation("GwUnitFrame" .. self.gwUnit .. "Cast")

    bar:ClearStages()
    bar.internalBar:SetTexture("Interface/AddOns/GW2_UI/Textures/units/castingbars/" .. GW.CASTINGBAR_TEXTURES.RED.NORMAL .. ".png")
    if GW.isModern then
        bar:GetStatusBarTexture():SetDesaturated(false)
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(1)
    else
        self:NormalCastBarAnimation(1)
    end
    bar.castingTimeString:SetText("")
    GW.SetInterruptText(bar.castingString, interruptedBy)

    local castBG = self.castingbarBackground
    local x = (self.type == "NormalTarget") and -2 or 0
    GW.AddToAnimation("GwUnitFrame" .. self.gwUnit .. "Shake", 0, 1, GetTime(), 0.25, function(p)
        castBG:SetPoint("TOPLEFT", self.powerbar, "BOTTOMLEFT", x + math.sin(p * 42) * 2 * (1 - p), -1)
    end)
    self.interruptTimer = C_Timer.NewTimer(1, function() self:HideCastBar() end)
end

function GwUnitFrameMixin:HideCastBar()
    self:ClearInterrupt()
    local pb = self.powerbar
    local castBG = self.castingbarBackground
    if castBG then
        castBG:Hide()
        castBG:ClearAllPoints()
        castBG:SetPoint("TOPLEFT", pb, "BOTTOMLEFT", (self.type == "NormalTarget") and -2 or 0, 19)
    end

    if self.castingString then self.castingString:Hide() end
    if self.highlight then self.highlight:Hide() end
    if self.castingTimeString then self.castingTimeString:Hide() end
    if self.castingbar then self.castingbar:Hide() end
    if self.castingbarSpark then self.castingbarSpark:Hide() end
    if self.castingbarNormal then self.castingbarNormal:Hide() end

    self.spellID = nil
    self.castID = nil
    self.notInterruptible = nil
    self.channeling = false
    self.casting = false
    self.empowering = false

    self.castingbarNormal:ClearStages()
    self:SetUnitPortrait()
    GW.StopAnimation("GwUnitFrame" .. self.gwUnit .. "Cast")
end

function GwUnitFrameMixin:CastInterruptible(event)
    if not self.castingbarNormal:IsShown() then return end

    self.notInterruptible = event == 'UNIT_SPELLCAST_NOT_INTERRUPTIBLE'

    self.castingbarNormal:GetStatusBarTexture():SetDesaturated(self.notInterruptible)
end

function GwUnitFrameMixin:StartCastbar(event)
    self:ClearInterrupt()
    local barTexture = GW.CASTINGBAR_TEXTURES.YELLOW.NORMAL
    local direction, duration

    if GW.isModern then
        direction = Enum.StatusBarTimerDirection.ElapsedTime
    end

    local name, _, texture, startTime, endTime, _, _, notInterruptible, spellID, castID = UnitCastingInfo(self.gwUnit)
    if name then
        self.casting = true
        if GW.isModern then
            duration = UnitCastingDuration(self.gwUnit)
        end
    else
        local isEmpowered
        name, _, texture, startTime, endTime, _, notInterruptible, spellID, isEmpowered, _, castID = UnitChannelInfo(self.gwUnit)
        barTexture = GW.CASTINGBAR_TEXTURES.GREEN.NORMAL

        if GW.isModern then
            if isEmpowered then
                self.empowering = true
                duration = UnitEmpoweredChannelDuration(self.gwUnit)
            else
                self.channeling = true
                duration = UnitChannelDuration(self.gwUnit)
                direction = Enum.StatusBarTimerDirection.RemainingTime
            end
        else
            self.channeling = true
        end
    end

    self.castingbarNormal.internalBar:SetTexture("Interface/AddOns/GW2_UI/Textures/units/castingbars/" .. barTexture .. ".png")

    if not name or not self.showCastbar then
        self:HideCastBar()
        return
    end

    self.delay = 0
    self.castID = castID
    self.spellID = spellID
    self.notInterruptible = notInterruptible

    if not GW.isModern then
        self.maxValue = (endTime - startTime) / 1000
        startTime, endTime = startTime / 1000, endTime / 1000

        if texture and self.portrait and self.activePortrait ~= texture then
            self.portrait:SetTexture(texture)
            self.activePortrait = texture
            if self.frameInvert then
                self.portrait:SetTexCoord(1, 0, 0, 1)
            else
                self.portrait:SetTexCoord(0, 1, 0, 1)
            end
        end
    end

    local cbBackground = self.castingbarBackground
    cbBackground:Show()
    cbBackground:ClearAllPoints()
    cbBackground:SetPoint("TOPLEFT", self.powerbar, "BOTTOMLEFT", (self.type == "NormalTarget") and -2 or 0, -1)

    self.castingString:SetShown(self.showCastingbarName)
    if self.castingTimeString then
        self.castingTimeString:SetShown(self.showCastingbarTimer and true or false)
    end

    if not GW.isModern and notInterruptible then
        self.castingString:SetText(self.showCastingbarName and name or "")
        self.castingbarNormal:Hide()
        if self.castingbar then self.castingbar:Show() end
        if self.castingbarSpark then self.castingbarSpark:Show() end
    else
        self.castingbarNormal.castingString:SetText(self.showCastingbarName and name or "")
        self.castingString:Hide()
        if self.castingTimeString then self.castingTimeString:Hide() end
        if self.castingbar then self.castingbar:Hide() end
        if self.castingbarSpark then self.castingbarSpark:Hide() end
        self.castingbarNormal:Show()
    end

    if not self.showCastingbarTimer then
        self.castingbarNormal.castingTimeString:SetText("")
        if self.castingTimeString then self.castingTimeString:SetText("") end
    end

    if self.empowering then
        self.castingbarNormal:AddStages(UnitEmpoweredStagePercentages(self.gwUnit, true), self.gwUnit)
    else
        self.castingbarNormal:ClearStages()
    end

    if GW.isModern then
        self.castingbarNormal:SetTimerDuration(duration, Enum.StatusBarInterpolation.Immediate, direction)
        self.castingbarNormal:GetStatusBarTexture():SetDesaturated(notInterruptible)
    else
        GW.AddToAnimation(
            "GwUnitFrame" .. self.gwUnit .. "Cast",
            0,
            1,
            startTime,
            endTime - startTime,
            function(p)
                if self.showCastingbarTimer and self.castingTimeString then
                    if notInterruptible then
                        self.castingTimeString:SetText(TimeCount(endTime - GetTime(), true))
                    else
                        self.castingbarNormal.castingTimeString:SetText(TimeCount(endTime - GetTime(), true))
                    end
                end

                p = self.channeling and (1 - p) or p
                if notInterruptible then
                    self:ProtectedCastAnimation(p)
                else
                    self:NormalCastBarAnimation(p)
                end
            end,
            "noease")
    end
end

function GwUnitFrameMixin:UpdateThreatValues()
    self.threatValue = select(3, UnitDetailedThreatSituation("player", self.gwUnit))

    if GW.IsSecretValue(self.threatValue) or self.threatValue == nil then
        self.threatString:SetText("")
        self.threattabbg:SetAlpha(0.0)
    else
        self.threatString:SetText(RoundDec(self.threatValue, 0) .. "%")
        self.threattabbg:SetAlpha(1.0)
    end
end

function GwUnitFrameMixin:OnEvent(event, unit, ...)
    local secondaryFrame
    if self.gwUnit == "target" then
        secondaryFrame = GwTargetTargetUnitFrame
    elseif self.gwUnit == "focus" then
        secondaryFrame = GwFocusTargetUnitFrame
    end

    local arg1, arg2, arg3, arg4 = ...

    if event == "UNIT_COMBAT" then
        if unit == self.gwUnit then
            CombatFeedback_OnCombatEvent(self, arg1, arg2, arg3, arg4)
        end
    elseif IsIn(event, "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED", "PLAYER_ENTERING_WORLD", "FORCE_UPDATE") then
        if event == "PLAYER_TARGET_CHANGED" and self.gwUnit == "target" and UnitIsPlayer(self.gwUnit) and (self.showItemLevel == "PVP_LEVEL" or self.showItemLevel == "ITEM_LEVEL")
            and (not GW.Mists or (not InCombatLockdown() and CheckInteractDistance(self.gwUnit, 4))) and CanInspect(self.gwUnit) then
            local guid = UnitGUID(self.gwUnit)
            if GW.NotSecretValue(guid) and guid and not GW.unitIlvlsCache[guid] then
                self:RegisterEvent("INSPECT_READY")
                NotifyInspect(self.gwUnit)
            end
        end

        if self.showThreat then
            self:UpdateThreatValues()
        elseif self.threattabbg and self.threattabbg:IsShown() then
            self.threattabbg:Hide()
        end

        if event == "PLAYER_ENTERING_WORLD" and self.gwUnit == "target" then
            wipe(GW.unitIlvlsCache)
        end

        self:UnitFrameData()
        if secondaryFrame then secondaryFrame:UnitFrameData() end
        self:UpdateHealthBar(true)
        if secondaryFrame then secondaryFrame:UpdateHealthBar(true) end

        if IsIn(event, "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED") then
            self:UpdatePowerBar(true)
            if secondaryFrame then  secondaryFrame:UpdatePowerBar(true) end
            if self.Fader and self.Fader.enabled then
                self.Fader:ForceUpdate(event)
            end
        else
            self:UpdatePowerBar()
            if secondaryFrame then secondaryFrame:UpdatePowerBar() end
        end

        self:HideCastBar()
        self:StartCastbar()
        if secondaryFrame then
            secondaryFrame:HideCastBar()
            secondaryFrame:StartCastbar()
        end
        self:UpdateRaidMarkers()
        if secondaryFrame then secondaryFrame:UpdateRaidMarkers() end

        if self.auras.ForceUpdate then -- Classic path; the Retail container refreshes via its own event watcher
            self.auras:ForceUpdate()
        end

        if IsIn(event, "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED") then
            if UnitExists(self.gwUnit) and not C_PlayerInteractionManager.IsReplacingUnit() then
                if UnitIsEnemy(self.gwUnit, "player") then
                    PlaySound(SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
                elseif UnitIsFriend("player", self.gwUnit) then
                    PlaySound(SOUNDKIT.IG_CHARACTER_NPC_SELECT)
                else
                    PlaySound(SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT)
                end
            else
                PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT)
            end
        end
    elseif event == "UNIT_TARGET" then
        if unit == self.gwUnit and secondaryFrame then
            local targetUnit = self.gwUnit .. "target"  -- "targettarget" or "focustarget"
            if UnitExists(targetUnit) then
                secondaryFrame:UnitFrameData()
                secondaryFrame:UpdateHealthBar(true)
                secondaryFrame:UpdatePowerBar(true)
                secondaryFrame:HideCastBar()
                secondaryFrame:StartCastbar()
                secondaryFrame:UpdateRaidMarkers()
            end
        end
    elseif event == "RAID_TARGET_UPDATE" then
        self:UpdateRaidMarkers()
        if secondaryFrame then secondaryFrame:UpdateRaidMarkers() end
    elseif event == "PARTY_LEADER_CHANGED" then
        -- the leader crown sits in front of the name
        if UnitExists(self.gwUnit) then
            self:UnitFrameData()
        end
    elseif event == "INSPECT_READY" then
        if self.gwUnit == "target" then
            if self.showItemLevel == "NONE" then
                self:UnregisterEvent("INSPECT_READY")
            else
                self:UpdateAvgItemLevel(unit) -- with this event the unit is a guid
            end
        end
    elseif event == "UNIT_THREAT_LIST_UPDATE" and self.showThreat then
        self:UpdateThreatValues()
    elseif IsIn(event, "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED") then
        if not self.activePortrait then
            self:SetUnitPortrait()
        end
    elseif GW.UnitIsUnit(unit, self.gwUnit) then
        if event == "UNIT_AURA" then
            GW.UpdateBuffLayout(self, event, unit, ...)
        elseif IsIn(event, "UNIT_MAXHEALTH", "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEALTH", "UNIT_HEALTH_FREQUENT", "UNIT_HEAL_PREDICTION") then
            self:UpdateHealthBar()
        elseif IsIn(event, "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT", "UNIT_DISPLAYPOWER") then
            self:UpdatePowerBar()
        elseif IsIn(event, "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_EMPOWER_START") then
            self:StartCastbar()
        elseif GW.isModern and IsIn(event, "UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "UNIT_SPELLCAST_INTERRUPTIBLE") then
            self:CastInterruptible(event)
        elseif IsIn(event, "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_EMPOWER_UPDATE") then
            self:StartCastbar()
        elseif IsIn(event, "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_EMPOWER_STOP") then
            local interruptedBy = select(event == "UNIT_SPELLCAST_EMPOWER_STOP" and 4 or 3, ...)
            if event == "UNIT_SPELLCAST_INTERRUPTED" or (IsIn(event, "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_EMPOWER_STOP") and (GW.IsSecretValue(interruptedBy) or interruptedBy)) then
                self:ShowInterrupt(interruptedBy)
            elseif not self.interruptShown then
                self:HideCastBar()
            end
        elseif event == "UNIT_FACTION" then
            self:UpdateHealthbarColor()
        end
    end
end

-- the texts of the text designer replace the name and the health text the frame writes itself, the power bar
-- gets a text of its own
-- the text sits on the edge of the bar like the health text, in the middle where the health text does; on a thin
-- bar it reaches over the health bar, so the power bar is lifted above it
function GwUnitFrameMixin:SetupPowerText()
    local powerText = self.powerbar.label
    local offset = GW.settings.unitframes[self.textSettingsKey or self.gwUnit].powerBarTextOffset
    powerText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "SHADOW")
    powerText:ClearAllPoints()
    if self.centeredTexts then
        powerText:SetPoint("CENTER", self.powerbar, "CENTER", offset.x, offset.y)
        powerText:SetJustifyH("CENTER")
    elseif self.frameInvert then
        powerText:SetPoint("RIGHT", self.powerbar, "RIGHT", -offset.x, offset.y)
        powerText:SetJustifyH("RIGHT")
    else
        powerText:SetPoint("LEFT", self.powerbar, "LEFT", offset.x, offset.y)
        powerText:SetJustifyH("LEFT")
    end
    powerText:Show()
    self.powerbar:SetFrameLevel((self.healthContainer or self.health):GetFrameLevel() + 10)
end

-- the font strings of the lines a frame has, the pet frame has no name and level
function GwUnitFrameMixin:GetTextStrings()
    return {nameText = self.nameString, levelText = self.levelString, healthText = self.healthString,
        powerText = self.powerText or self.powerbar and self.powerbar.label}
end

-- the lines are in the settings of the unit, the health globe keeps its own
function GwUnitFrameMixin:ApplyTextTags()
    self.textTags = true
    self.textStrings = self:GetTextStrings()
    if self.powerbar then
        self:SetupPowerText()
    end
    for line, fontString in pairs(self.textStrings) do
        local blocks = GW.GetUnitFrameTextBlocks(self.textSettingsKey or self.gwUnit, line)
        GW.SetFontStringTag(self, fontString, GW.BuildTagString(blocks))
    end
    self:UpdateTextTags()
end

-- the tags read the unit of the frame, a frame can switch it like the party preview does
function GwUnitFrameMixin:UpdateTextTags()
    if not self.textTags then return end
    self.__unit = self.gwUnit
    for _, fontString in pairs(self.textStrings) do
        fontString:UpdateTag()
    end
end

-- frames of their own build (pet) take the text functions of the unit frames
GW.UnitFrameTextMixin = {
    GetTextStrings = GwUnitFrameMixin.GetTextStrings,
    ApplyTextTags = GwUnitFrameMixin.ApplyTextTags,
    UpdateTextTags = GwUnitFrameMixin.UpdateTextTags,
    SetupPowerText = GwUnitFrameMixin.SetupPowerText,
}

-- sizes and anchors of the bars from the settings, shared by the frame and its text preview
function GwUnitFrameMixin:ApplyBarLayout()
    self.castingbarBackground:SetWidth(GW.settings.unitframes[self.gwUnit].healthBarSize.width)
    self.castingbarNormal:SetWidth(GW.settings.unitframes[self.gwUnit].healthBarSize.width)
    if self.castingbar then
        self.castingbar:SetWidth(GW.settings.unitframes[self.gwUnit].healthBarSize.width)
    end
    self.healthContainer:SetSize(GW.settings.unitframes[self.gwUnit].healthBarSize.width, GW.settings.unitframes[self.gwUnit].healthBarSize.height)
    self.powerbarContainer:SetSize(GW.settings.unitframes[self.gwUnit].healthBarSize.width, GW.settings.unitframes[self.gwUnit].powerBarSize.height) --width is shared

    local powerHeight = self.powerbarContainer:GetHeight()
    local yOffset = (powerHeight + 1) / 2

    self.healthContainer:ClearAllPoints()
    if self.frameInvert then
        self.healthContainer:SetPoint("RIGHT", self.portrait, "LEFT", -4, yOffset)
    else
        self.healthContainer:SetPoint("LEFT", self.portrait, "RIGHT", 4, yOffset)
    end

    self.powerbarContainer:ClearAllPoints()
    if self.frameInvert then
        self.powerbarContainer:SetPoint("TOPRIGHT", self.healthContainer, "BOTTOMRIGHT", 0, -1)
    else
        self.powerbarContainer:SetPoint("TOPLEFT", self.healthContainer, "BOTTOMLEFT", 0, -1)
    end

    self.healthbarBackground:ClearAllPoints()
    if self.frameInvert then
        self.healthbarBackground:SetPoint("TOPRIGHT", self.healthContainer, "TOPRIGHT", 0, 0)
    else
        self.healthbarBackground:SetPoint("TOPLEFT", self.healthContainer, "TOPLEFT", 0, 0)
    end
    self.healthbarBackground:SetSize(self.healthContainer:GetWidth(), self.healthContainer:GetHeight())

    local textOffset = GW.settings.unitframes[self.gwUnit].healthBarTextOffset
    self.healthString:ClearAllPoints()
    if self.frameInvert then
        self.healthString:SetPoint("RIGHT", self.health, "RIGHT", -textOffset.x, textOffset.y)
    else
        self.healthString:SetPoint("LEFT", self.health, "LEFT", textOffset.x, textOffset.y)
    end
    self.nameString:SetWidth(GW.settings.unitframes[self.gwUnit].healthBarSize.width - 15)

    self:SetHeight(40 + self.healthContainer:GetHeight() + self.powerbarContainer:GetHeight())
    self:SetWidth(90 + self.healthContainer:GetWidth())
end

-- parts of a unit frame that only show for a live unit
local PREVIEW_HIDDEN_PARTS = {"threattabbg", "threatString", "castingbarBackground", "castingbarSpark", "castingbar",
    "castingbarNormal", "castingString", "castingTimeString", "highlight", "raidmarker", "prestigebg", "prestigeString",
    "auras", "absorbOverlay", "antiHeal", "absorbbg", "healPrediction", "happiness"}

local function SetPreviewBar(bar, value)
    if bar.SetFillAmount then
        bar:SetFillAmount(value)
    else
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(value)
    end
end

-- the preview of the text designer is a unit frame of the same build as the real one, built by the caller with its
-- art and classColor, without unit and events and with made up values; your own portrait stands in for the unit. The frame art reaches far out,
-- a margin of it stays and the rest is cut off
function GW.CreateUnitFrameTextPreview(parent, frame, apply)
    local preview = CreateFrame("Frame", nil, parent)
    preview:SetClipsChildren(true)
    frame:SetParent(preview)
    frame:SetFrameStrata(parent:GetFrameStrata())
    frame:ClearAllPoints()
    frame:SetPoint("LEFT", 20, 0)
    frame:EnableMouse(false)

    for _, key in ipairs(PREVIEW_HIDDEN_PARTS) do
        if frame[key] then
            frame[key]:Hide()
        end
    end
    if frame.portrait then
        SetPortraitTexture(frame.portrait, "player")
    end

    -- boss and arena frames call their power bar power
    local powerbar = frame.powerbar or frame.power
    SetPreviewBar(frame.health, 0.72)
    SetPreviewBar(powerbar, 0.84)
    local powerColor = GW.Colors.PowerBarCustomColors.MANA
    if powerColor then
        powerbar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
    end
    preview.texts = frame:GetTextStrings()

    function preview:Refresh()
        if apply then
            apply(frame)
        end
        local color = frame.classColor and GWGetClassColor("SHAMAN", true) or GW.Colors.UnitFrameReactionColors.Friendly
        frame.health:SetStatusBarColor(color:GetRGB())
        if frame.nameString then
            frame.nameString:SetTextColor(color:GetRGB())
        end
        if frame.powerbar then
            frame:SetupPowerText()
        end
        self:SetSize(frame:GetWidth() + 20, frame:GetHeight() + 30)
    end
    preview:Refresh()
    return preview
end

-- the health globe: a health and a shield text, each with shadow copies that follow it
local function SetGlobeFont(text, size, sizeOffset)
    text.value:GwSetFontTemplate(DAMAGE_TEXT_FONT, size, nil, sizeOffset)
    text.value:SetShadowColor(1, 1, 1, 0)
    for i, shadow in ipairs(text.shadow) do
        shadow:GwSetFontTemplate(DAMAGE_TEXT_FONT, size, nil, sizeOffset)
        shadow:SetShadowColor(1, 1, 1, 0)
        shadow:SetTextColor(0, 0, 0, 1 / i)
    end
end

local function MirrorShadows(text)
    hooksecurefunc(text.value, "SetText", function(_, ...)
        for _, shadow in ipairs(text.shadow) do shadow:SetText(...) end
    end)
    hooksecurefunc(text.value, "SetFormattedText", function(_, ...)
        for _, shadow in ipairs(text.shadow) do shadow:SetFormattedText(...) end
    end)
end

GW.HealthGlobeTextMixin = {textSettingsKey = "healthGlobe"}

function GW.HealthGlobeTextMixin:GetTextStrings()
    return {healthText = self.text_h.value, absorbText = self.text_a.value}
end

-- a shield text on two rows moves up and gets smaller, like the old value and percent did
function GW.HealthGlobeTextMixin:ApplyTextLayout()
    if not self.gwShadowsMirrored then
        self.gwShadowsMirrored = true
        MirrorShadows(self.text_h)
        MirrorShadows(self.text_a)
    end
    local twoRows = false
    for _, block in ipairs(GW.GetUnitFrameTextBlocks("healthGlobe", "absorbText")) do
        twoRows = twoRows or block.k == "newLine"
    end
    local text = self.text_a
    text.gwPoint = text.gwPoint or {text:GetPoint()}
    text:ClearAllPoints()
    if twoRows then
        text:SetPoint("CENTER", self, "CENTER", 0, 25)
    else
        text:SetPoint(unpack(text.gwPoint))
    end
    SetGlobeFont(text, twoRows and GW.Enum.TextSizeType.Small or GW.Enum.TextSizeType.Normal)
    SetGlobeFont(self.text_h, GW.Enum.TextSizeType.Header, -1)
end

function GW.HealthGlobeTextMixin:ApplyTextTags()
    GwUnitFrameMixin.ApplyTextTags(self)
    self:ApplyTextLayout()
end

-- the globe in the text preview; the classic clients have the bars nested in each other
local function CreateHealthGlobeTextPreview(parent)
    local preview = CreateFrame("Frame", nil, parent)
    local hg = CreateFrame("Button", "GW2_PlayerFrameTextPreview", preview,
        GW.isModern and "GwHealthGlobeModernTmpl" or "GwHealthGlobeTmpl")
    if GW.isModern then
        hg.health:SetOrientation("VERTICAL")
        hg.health:SetMinMaxValues(0, 1)
        hg.health:SetValue(0.72)
        hg.healAbsorb:Hide()
    else
        hg.health = hg.healPrediction.absorbbg.candy.health
        hg.text_h = hg.health.antiHeal.absorbOverlay.text_h
        hg.text_a = hg.health.antiHeal.absorbOverlay.text_a
        hg.health.antiHeal.absorbOverlay.repair:Hide()
        for _, bar in pairs({hg.health.antiHeal.absorbOverlay, hg.health.antiHeal, hg.health, hg.healPrediction.absorbbg.candy,
            hg.healPrediction.absorbbg, hg.healPrediction}) do
            GW.AddStatusbarAnimation(bar, true)
            bar:SetOrientation("VERTICAL")
            bar:SetFillAmount(0)
        end
        hg.health:SetFillAmount(0.72 - 0.035)
        hg.healPrediction.absorbbg.candy:SetFillAmount(0.72)
    end
    Mixin(hg, GW.HealthGlobeTextMixin)
    hg.gwUnit = "player"
    hg:EnableMouse(false)
    -- the template fixes a low frame level, the background of the designer would cover the globe
    hg:SetFrameStrata(parent:GetFrameStrata())
    hg:SetFrameLevel(preview:GetFrameLevel() + 1)
    hg:SetPoint("TOPLEFT", 8, -8)
    preview:SetSize(hg:GetWidth() + 16, hg:GetHeight() + 16)
    preview.texts = hg:GetTextStrings()
    -- the shield text moves with the rows of its line
    function preview:Refresh()
        hg:ApplyTextLayout()
    end
    preview:Refresh()
    return preview
end

function GW.GetHealthGlobeTextTarget()
    return {
        createPreview = CreateHealthGlobeTextPreview,
        player = true,
        -- the globe only shows health and shield
        categories = {health = true, color = true, text = true},
        lines = {
            {key = "healthText", label = HEALTH},
            {key = "absorbText", label = GW.L["Shield"]},
        },
        get = function(line) return GW.GetUnitFrameTextBlocks("healthGlobe", line) end,
        -- nil goes back to the built-in line
        set = function(line, blocks)
            GW.settings.unitframes.healthGlobe[line] = blocks or false
            if GW2_PlayerFrame then
                GW2_PlayerFrame:ApplyTextTags()
            end
        end,
    }
end

function GW.UpdateFilters(frame)
    for i = 1, 2 do
        local db = i == 1 and frame.buffAdvancedFilters or frame.debuffAdvancedFilters
        local isPlayer = db.isAuraPlayer
        local isCancelable = db and db.isAuraCancelable
        local isCancelablePlayer = db and db.isAuraCancelablePlayer
        local notCancelable = db and db.notAuraCancelable
        local notCancelablePlayer = db and db.notAuraCancelablePlayer
        local isRaid = db and db.isAuraRaid
        local isRaidPlayer = db and db.isAuraRaidPlayer

        local shared = isPlayer or isCancelable or isCancelablePlayer or notCancelable or notCancelablePlayer or isRaid or isRaidPlayer
        db.noFilter = not shared
    end
end

-- Aura part of ToggleSettings, split out for onSettingsRefresh — combat safe,
-- unlike the full settings pass (protected unitframe)
function GwUnitFrameMixin:ApplyAuraSettings(unit)
    unit = unit or self.gwUnit:lower()
    local cfg = self.aurasContainer.gwConfig
    local debuffCfg = self.debuffsContainer.gwConfig
    local buffFilter = GW.settings.unitframes[unit].buffFilter

    -- growth direction: inverted frames grow to the left, "auras on top" grows upward
    -- (the auras frame extends DOWNWARD from its anchor, so when growing up the
    -- container's bottom sits on the auras frame's top edge — like the old engine)
    local growLeft = self.frameInvert and true or false
    local growUp = self.auraPositionTop and true or false
    local side = growLeft and "RIGHT" or "LEFT"
    local anchorPoint = (growUp and "BOTTOM" or "TOP") .. side

    for _, containerCfg in next, { cfg, debuffCfg } do
        containerCfg.growLeft = growLeft
        containerCfg.growUp = growUp
        containerCfg.anchorPoint = anchorPoint
        containerCfg.maximumLineSize = self.healthContainer:GetWidth() + 4
    end

    self.aurasContainer:ClearAllPoints()
    self.aurasContainer:SetPoint(anchorPoint, self.auras, "TOP" .. side)

    -- the debuff block hangs below the buff container (above it when growing up);
    -- the buff container sizes itself to its content, so the debuff block follows
    -- the buff line count automatically. With buffs disabled it takes their place.
    self.debuffsContainer:ClearAllPoints()
    if buffFilter == "none" then
        self.debuffsContainer:SetPoint(anchorPoint, self.auras, "TOP" .. side)
    elseif growUp then
        self.debuffsContainer:SetPoint("BOTTOM" .. side, self.aurasContainer, "TOP" .. side, 0, 4)
    else
        self.debuffsContainer:SetPoint("TOP" .. side, self.aurasContainer, "BOTTOM" .. side, 0, -4)
    end

    -- filters/sizes/sort/ignore list (triggers the layout — growth fields above
    -- have to be in place already)
    GW.ApplyAuraContainerSettings(self.aurasContainer, self.debuffsContainer, {
        smallSize = GW.settings.unitframes[unit].auraSmallSize,
        bigSize = GW.settings.unitframes[unit].auraBigSize,
        buffFilter = buffFilter,
        debuffFilter = GW.settings.unitframes[unit].debuffFilter,
        buffAdvanced = GW.settings.unitframes[unit].buffFilterAdvanced,
        debuffAdvanced = GW.settings.unitframes[unit].debuffFilterAdvanced,
        sort = GW.settings.unitframes[unit].auraSort,
        excludeSpellIDs = GW.settings.unitframes[unit].ignoredAuras,
    })
end

function GwUnitFrameMixin:ToggleSettings()
    local unit = self.gwUnit:lower()

    -- statusbar texture
    local textureKey =  GW.settings.unitframes[unit].healthBarTexture
    if textureKey == GW.DEFAULT_UNITFRAME_STATUSBAR_TEXTURE then
        self.antiHeal:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/antiheal.png")
        self.health:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/statusbar.png")
        self.absorbbg:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/absorb.png")
        self.healPrediction:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")

        self.absorbbg:SetStatusBarColor(1, 1, 1, 0.66)
    else
        local texture = GW.Libs.LSM:Fetch("statusbar", textureKey)
        self.antiHeal:SetStatusBarTexture(texture)
        self.health:SetStatusBarTexture(texture)
        self.absorbbg:SetStatusBarTexture(texture)
        self.healPrediction:SetStatusBarTexture(texture)

        self.absorbbg:SetStatusBarColor(248/255, 232/255, 159/255, 0.66)
    end

    self.classColor = GW.settings.unitframes[unit].classColor
    self.showCastbar = GW.settings.unitframes[unit].showCastbar
    self.showAbsorbBar = GW.settings.unitframes[unit].showAbsorbBar

    self.showCastingbarName = GW.settings.unitframes[unit].castingbarShowName
    self.showInterrupts = GW.settings.unitframes[unit].castingbarShowInterrupt
    self.showCastingbarTimer = GW.settings.unitframes[unit].castingbarShowTimer

    self.displayBuffs = GW.settings.unitframes[unit].buffFilter == "none" and 0 or 32
    self.auras.buffFilter = GW.settings.unitframes[unit].buffFilter
    self.auras.buffAdvancedFilters = GW.settings.unitframes[unit].buffFilterAdvanced

    self.displayDebuffs = GW.settings.unitframes[unit].debuffFilter == "none" and 0 or 40
    self.auras.debuffFilter = GW.settings.unitframes[unit].debuffFilter
    self.auras.debuffAdvancedFilters = GW.settings.unitframes[unit].debuffFilterAdvanced
    GW.UpdateFilters(self.auras)

    self.auras.smallSize = GW.settings.unitframes[unit].auraSmallSize
    self.auras.bigSize = GW.settings.unitframes[unit].auraBigSize
    self.auras.ignoredAuraSpellIDs = GW.settings.unitframes[unit].ignoredAuras -- Classic engine; Retail runs via container excludeSpellIDs

    self:ApplyTextTags()

    self.showItemLevel = GW.settings.unitframes[unit].itemLevel

    if GW.settings.unitframes[unit].threatValue ~= nil then
        self.showThreat = GW.settings.unitframes[unit].threatValue
    end

    self.auraPositionTop = GW.settings.unitframes[unit].aurasOnTop

    self.backgroundOverlay:SetShown(GW.settings.unitframes[unit].altBackground)

    self.auras:ClearAllPoints()
    if self.auraPositionTop then
        if self.frameInvert then
            self.auras:SetPoint("TOPRIGHT", self.levelString, "TOPRIGHT", -2, 17)
        else
            self.auras:SetPoint("TOPLEFT", self.nameString, "TOPLEFT", 2, 17)
        end
    else
        local comboOffset = (GW.settings.unitframes[unit].hookComboPoints and (GW.myClassID == 4 or GW.myClassID == 11) and -23) or -15
        if self.frameInvert then
            self.auras:SetPoint("TOPRIGHT", self.castingbarBackground, "BOTTOMRIGHT", 2, comboOffset)
        else
            self.auras:SetPoint("TOPLEFT", self.castingbarBackground, "BOTTOMLEFT", 2, comboOffset)
        end
    end

    self:SetScale(GW.settings.unitframes[self.gwUnit].scale)
    self:ApplyBarLayout()

    self.auras:SetWidth(self.healthContainer:GetWidth() + 4)
    self.auras.maxWidth = self.healthContainer:GetWidth() + 4

    if GW.isModern and self.aurasContainer then
        self:ApplyAuraSettings(unit)
    end

    self:OnEvent("FORCE_UPDATE")

    --frame fader
    local frameFaderSettings = GW.settings.unitframes[unit].fader
    if frameFaderSettings.hover or frameFaderSettings.combat or frameFaderSettings.casting or frameFaderSettings.dynamicflight or frameFaderSettings.health or frameFaderSettings.vehicle or frameFaderSettings.playertarget or frameFaderSettings.unittarget then
        GW.FrameFadeEnable(self)
        self.Fader:SetOption("Hover", frameFaderSettings.hover)
        self.Fader:SetOption("Combat", frameFaderSettings.combat)
        self.Fader:SetOption("Casting", frameFaderSettings.casting)
        self.Fader:SetOption("DynamicFlight", frameFaderSettings.dynamicflight)
        self.Fader:SetOption("Smooth", (frameFaderSettings.smooth > 0 and frameFaderSettings.smooth) or nil)
        self.Fader:SetOption("MinAlpha", frameFaderSettings.minAlpha)
        self.Fader:SetOption("MaxAlpha", frameFaderSettings.maxAlpha)
        self.Fader:SetOption("Health", frameFaderSettings.health)
        self.Fader:SetOption("Vehicle", frameFaderSettings.vehicle)
        self.Fader:SetOption("UnitTarget", frameFaderSettings.unittarget)
        self.Fader:SetOption("PlayerTarget", frameFaderSettings.playertarget)

        self.Fader:ClearTimers()
        self.Fader.configTimer = C_Timer.NewTimer(0.25, function() self.Fader:ForceUpdate() end)
    elseif self.Fader then
        GW.FrameFadeDisable(self)
    end

    if GwPlayerClassPower then
        GW.ClassPowers.UpdateSettings(GwPlayerClassPower)
    end

    if unit == "target" then
        GW.LoadComboBarOnTargetFrame(self)
    end
end

function GwUnitFrameMixin:ToggleTargetFrameCombatFeedback()
    if GW.settings.unitframes.target.floatingCombatText then
        self:RegisterEvent("UNIT_COMBAT")
        self:SetScript("OnUpdate", CombatFeedback_OnUpdate)
    else
        self:UnregisterEvent("UNIT_COMBAT")
        self:SetScript("OnUpdate", nil)
    end
end

function GW.AddUnitFramePortraitMask(unitframe)
    unitframe.portrait.mask = unitframe:CreateMaskTexture()
    unitframe.portrait.mask:SetPoint("CENTER", unitframe.portrait, "CENTER", 0, 0)
    unitframe.portrait.mask:SetTexture(186178, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    unitframe.portrait.mask:SetSize(58, 58)
    unitframe.portrait:AddMaskTexture(unitframe.portrait.mask)
end

-- background, class color and bar layout of target, focus and player in the text preview
local function ApplyUnitFramePreview(frame)
    local settings = GW.settings.unitframes[frame.gwUnit]
    frame.backgroundOverlay:SetShown(settings.altBackground)
    frame.classColor = settings.classColor
    frame:ApplyBarLayout()
end

-- target and focus in the text preview, built like LoadUnitFrame does; inverting needs a reload like the frame
local function CreateUnitFramePreview(unit)
    local unitframe = CreateUnitFrame("Gw" .. unit .. "UnitFrameTextPreview", GW.settings.unitframes[unit].invert)
    unitframe.gwUnit = unit
    GW.AddUnitFramePortraitMask(unitframe)
    if unitframe.frameInvert then
        unitframe.backgroundOverlay:SetPoint("CENTER", -15, -5)
    end
    unitframe.background:SetTexture(TARGET_FRAME_ART.normal)
    return unitframe
end
GW.SetUnitFrameTextPreviewBuilder("target", CreateUnitFramePreview, ApplyUnitFramePreview)
GW.SetUnitFrameTextPreviewBuilder("focus", CreateUnitFramePreview, ApplyUnitFramePreview)

-- the player frame in the text preview, built like LoadPlayerFrame does
local function CreatePlayerFramePreview()
    local frame = CreateUnitFrame("GwPlayerUnitFrameTextPreview", false, true)
    frame.gwUnit = "player"
    Mixin(frame, GwPlayerUnitFrameMixin)
    GW.AddUnitFramePortraitMask(frame)
    frame.background:SetTexture(TARGET_FRAME_ART.normal)
    return frame
end
GW.SetUnitFrameTextPreviewBuilder("player", CreatePlayerFramePreview, ApplyUnitFramePreview)

local function LoadUnitFrame(unit, frameInvert)
    local unitframe = CreateUnitFrame("Gw" .. unit .."UnitFrame", frameInvert)
    unit = unit:lower()
    unitframe.gwUnit = unit
    unitframe.type = "NormalTarget"

    if GW.isModern then
        -- 12.1: unit frame auras run through the AuraContainer factory; sizes, filters,
        -- direction and anchoring are applied in ToggleSettings right below.
        -- The container only refreshes on UNIT_AURA — a target/focus switch changes
        -- the unit BEHIND the token, so it needs an explicit UpdateAllAuras trigger
        local refreshEvents = { unit == "target" and "PLAYER_TARGET_CHANGED" or "PLAYER_FOCUS_CHANGED", "PLAYER_ENTERING_WORLD" }

        unitframe.aurasContainer = GW.CreateUnitAuraContainer({
            name = "Gw" .. unit .. "AuraContainer",
            unit = unit,
            pandemicEnabled = function() return GW.settings.unitframes[unit].pandemicHighlight end,
            dispelIconEnabled = function() return GW.settings.unitframes[unit].dispelIcon end,
            parent = unitframe,
            tooltipAnchor = { "ANCHOR_BOTTOMLEFT", -5, -5 },
            refreshEvents = refreshEvents,
            elementSpacing = 3,
            lineSpacing = 4,
            -- one refresh hook covers both containers; must stay combat safe
            onSettingsRefresh = function() unitframe:ApplyAuraSettings() end,
            groups = {
                -- ONE group per aura type — any second group duplicates secret auras
                { key = "buffs", filter = "HELPFUL", size = 20, maxFrameCount = 32, showStealable = true, showPandemic = true },
            },
        })
        -- Debuffs live in their OWN container anchored below the buff container (which
        -- sizes itself to its content): the debuff block always starts on its own line
        -- while own and other debuffs flow together like the buffs do. The flow layout
        -- cannot express a line break on "whichever debuff group has content first",
        -- and counting auras from insecure code is blocked while auras are secret.
        unitframe.debuffsContainer = GW.CreateUnitAuraContainer({
            name = "Gw" .. unit .. "DebuffContainer",
            unit = unit,
            pandemicEnabled = function() return GW.settings.unitframes[unit].pandemicHighlight end,
            dispelIconEnabled = function() return GW.settings.unitframes[unit].dispelIcon end,
            parent = unitframe,
            tooltipAnchor = { "ANCHOR_BOTTOMLEFT", -5, -5 },
            refreshEvents = refreshEvents,
            elementSpacing = 3,
            lineSpacing = 4,
            groups = {
                { key = "debuffs", filter = "HARMFUL", size = 24, maxFrameCount = 40, isDebuff = true, showPandemic = true, showDispelIcon = true },
            },
        })
    else
        LoadAuras(unitframe)
    end

    RegisterMovableFrame(unitframe, unit == "target" and TARGET or FOCUS, "unitframes." .. unit, "Unitframe")

    unitframe:ClearAllPoints()
    unitframe:SetPoint("CENTER", unitframe.gwMover, "CENTER")

    GW.AddUnitFramePortraitMask(unitframe)

    if unitframe.frameInvert then
        unitframe.backgroundOverlay:SetPoint("CENTER", -15, -5)
        unitframe.healthContainer:ClearAllPoints()
        unitframe.healthContainer:SetPoint("RIGHT", unitframe.healthbarBackground, "RIGHT", -1, 0)
    end

    unitframe.castingbarNormal.Pips = {}

    unitframe:SetAttribute("*type1", "target")
    unitframe:SetAttribute("*type2", "togglemenu")
    unitframe:SetAttribute("unit", unit)
    RegisterUnitWatch(unitframe)
    unitframe:EnableMouse(true)
    unitframe:RegisterForClicks("AnyDown")
    GW.AddToClique(unitframe)

    unitframe:ToggleSettings()
    unitframe:SetScript("OnEvent", unitframe.OnEvent)

    unitframe:RegisterEvent("PLAYER_ENTERING_WORLD")
    unitframe:RegisterEvent("RAID_TARGET_UPDATE")
    unitframe:RegisterEvent("PARTY_LEADER_CHANGED")
    unitframe:RegisterUnitEvent("UNIT_HEALTH", unit)
    unitframe:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    unitframe:RegisterUnitEvent("UNIT_TARGET", unit)
    unitframe:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
    unitframe:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    if not GW.isModern then -- on Modern the AuraContainer handles aura updates itself
        unitframe:RegisterUnitEvent("UNIT_AURA", unit)
    end
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unit)
    unitframe:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit)
    unitframe:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit)
    unitframe:RegisterUnitEvent("UNIT_DISPLAYPOWER", unit)

    if GW.isModern or GW.Mists then
        unitframe:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit)
    end

    if GW.Retail then
        unitframe:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", unit)
        unitframe:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", unit)
        unitframe:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", unit)
    end

    if GW.Classic then
        unitframe:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unit)
    end

    unitframe:RegisterUnitEvent("UNIT_FACTION", unit)
    unitframe:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", unit)
    unitframe:RegisterEvent("PORTRAITS_UPDATED")
    if unit == "target" then
        unitframe:RegisterEvent("PLAYER_TARGET_CHANGED")
        unitframe:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit)
    elseif unit == "focus" then
        unitframe:RegisterEvent("PLAYER_FOCUS_CHANGED")
    end

    if unit == "target" then
        unitframe.feedbackText = unitframe:CreateFontString(nil, "OVERLAY")
        unitframe.feedbackText:SetFont(DAMAGE_TEXT_FONT, 30, "")
        unitframe.feedbackText:SetPoint("CENTER", unitframe.portrait, "CENTER")
        unitframe.feedbackText:Hide()
        unitframe.feedbackFontHeight = 30
        unitframe:ToggleTargetFrameCombatFeedback()
    end

    return unitframe
end
GW.LoadUnitFrame = LoadUnitFrame

GwTargetUnitFrameMixin = {}

function GwTargetUnitFrameMixin:OnUpdate(elapsed)
    if self.totalElapsed > 0 then
        self.totalElapsed = self.totalElapsed - elapsed
        return
    end
    self.totalElapsed = 0.25
    if not UnitExists(self.gwUnit) then
        return
    end

    self:UpdateRaidMarkers()
    self:UnitFrameData()
    self:UpdateHealthBar(true)
    self:UpdatePowerBar(true)
    if not self.interruptShown then
        self:StartCastbar()
    end
    -- targettarget and focustarget get no unit events, the fader follows the polling too
    local fader = self.Fader
    if fader and fader.enabled and fader.count and fader.count > 0 then
        fader:ForceUpdate("OnUpdate")
    end
end

-- targettarget and focustarget have no unit events of their own: the interrupts of every unit are checked
-- against them, channels and empowers only count with an interrupter
local INTERRUPT_EVENTS = GW.isModern and {"UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_EMPOWER_STOP"} or {"UNIT_SPELLCAST_INTERRUPTED"}

function GwTargetUnitFrameMixin:OnInterruptEvent(event, unit, ...)
    local interruptedBy = select(event == "UNIT_SPELLCAST_EMPOWER_STOP" and 4 or 3, ...)
    if event ~= "UNIT_SPELLCAST_INTERRUPTED" and not (GW.IsSecretValue(interruptedBy) or interruptedBy) then
        return
    end
    if GW.UnitIsUnit(unit, self.gwUnit) then
        self:ShowInterrupt(interruptedBy)
    end
end

function GwTargetUnitFrameMixin:ToggleSettings()
    self.classColor = GW.settings.unitframes[self.parentUnitId].classColor
    self.showCastbar = GW.settings.unitframes[self.gwUnit].showCastbar
    self.showAbsorbBar = GW.settings.unitframes[self.gwUnit].showAbsorbBar
    self.showInterrupts = self.showCastbar and GW.settings.unitframes[self.gwUnit].castingbarShowInterrupt
    for _, event in ipairs(INTERRUPT_EVENTS) do
        if self.showInterrupts then
            self:RegisterEvent(event)
        else
            self:UnregisterEvent(event)
        end
    end

    -- statusbar texture
    local textureKey =  GW.settings.unitframes[self.gwUnit].healthBarTexture
    if textureKey == GW.DEFAULT_UNITFRAME_STATUSBAR_TEXTURE then
        self.antiHeal:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/antiheal.png")
        self.health:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/statusbar.png")
        self.absorbbg:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/absorb.png")
        self.healPrediction:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")

        self.absorbbg:SetStatusBarColor(1, 1, 1, 0.66)
    else
        local texture = GW.Libs.LSM:Fetch("statusbar", textureKey)
        self.antiHeal:SetStatusBarTexture(texture)
        self.health:SetStatusBarTexture(texture)
        self.absorbbg:SetStatusBarTexture(texture)
        self.healPrediction:SetStatusBarTexture(texture)

        self.absorbbg:SetStatusBarColor(248/255, 232/255, 159/255, 0.66)
    end

    self.backgroundOverlay:SetShown(GW.settings.unitframes[self.parentUnitId].altBackground)

    local frameFaderSettings = GW.settings.unitframes[self.gwUnit].fader
    if frameFaderSettings.hover or frameFaderSettings.combat or frameFaderSettings.casting or frameFaderSettings.dynamicflight or frameFaderSettings.health or frameFaderSettings.vehicle or frameFaderSettings.playertarget or frameFaderSettings.unittarget then
        GW.FrameFadeEnable(self)
        self.Fader:SetOption("Hover", frameFaderSettings.hover)
        self.Fader:SetOption("Combat", frameFaderSettings.combat)
        self.Fader:SetOption("Casting", frameFaderSettings.casting)
        self.Fader:SetOption("DynamicFlight", frameFaderSettings.dynamicflight)
        self.Fader:SetOption("Smooth", (frameFaderSettings.smooth > 0 and frameFaderSettings.smooth) or nil)
        self.Fader:SetOption("MinAlpha", frameFaderSettings.minAlpha)
        self.Fader:SetOption("MaxAlpha", frameFaderSettings.maxAlpha)
        self.Fader:SetOption("Health", frameFaderSettings.health)
        self.Fader:SetOption("Vehicle", frameFaderSettings.vehicle)
        self.Fader:SetOption("UnitTarget", frameFaderSettings.unittarget)
        self.Fader:SetOption("PlayerTarget", frameFaderSettings.playertarget)

        self.Fader:ClearTimers()
        self.Fader.configTimer = C_Timer.NewTimer(0.25, function() self.Fader:ForceUpdate() end)
    elseif self.Fader then
        GW.FrameFadeDisable(self)
    end

    self:SetScale(GW.settings.unitframes[self.gwUnit].scale)
    self:ApplyBarLayout()

    self:ApplyTextTags()

    self.parentUnitFrame:OnEvent("FORCE_UPDATE")
end

-- sizes and anchors of the bars from the settings, shared by the frame and its text preview
function GwTargetUnitFrameMixin:ApplyBarLayout()
    self.healthContainer:SetSize(GW.settings.unitframes[self.gwUnit].healthBarSize.width, GW.settings.unitframes[self.gwUnit].healthBarSize.height)
    self.powerbarContainer:SetSize(GW.settings.unitframes[self.gwUnit].healthBarSize.width, GW.settings.unitframes[self.gwUnit].powerBarSize.height) -- width is shared
    self.castingbarBackground:SetWidth(GW.settings.unitframes[self.gwUnit].healthBarSize.width)
    self.castingbarNormal:SetWidth(GW.settings.unitframes[self.gwUnit].healthBarSize.width)
    if self.castingbar then
        self.castingbar:SetWidth(GW.settings.unitframes[self.gwUnit].healthBarSize.width)
    end

    local powerHeight = self.powerbarContainer:GetHeight()
    local yOffset = (powerHeight + 1) / 2

    self.healthContainer:ClearAllPoints()
    self.healthContainer:SetPoint("LEFT", self, "LEFT", 0, yOffset)

    self.powerbarContainer:ClearAllPoints()
    if self.frameInvert then
        self.powerbarContainer:SetPoint("TOPRIGHT", self.healthContainer, "BOTTOMRIGHT", 0, -1)
    else
        self.powerbarContainer:SetPoint("TOPLEFT", self.healthContainer, "BOTTOMLEFT", 0, -1)
    end

    self.healthbarBackground:ClearAllPoints()
    if self.frameInvert then
        self.healthbarBackground:SetPoint("TOPRIGHT", self.healthContainer, "TOPRIGHT", 0, 0)
    else
        self.healthbarBackground:SetPoint("TOPLEFT", self.healthContainer, "TOPLEFT", 0, 0)
    end
    self.healthbarBackground:SetSize(self.healthContainer:GetWidth(), self.healthContainer:GetHeight())

    self:SetHeight(40 + self.healthContainer:GetHeight() + self.powerbarContainer:GetHeight())
    self:SetWidth(self.healthContainer:GetWidth() + 2)

    self.nameString:SetWidth(GW.settings.unitframes[self.gwUnit].healthBarSize.width - 15)

    local textOffset = GW.settings.unitframes[self.gwUnit].healthBarTextOffset
    self.healthString:ClearAllPoints()
    self.healthString:SetPoint("LEFT", self.health, "LEFT", textOffset.x, textOffset.y)
end

function GwTargetUnitFrameMixin:ToggleUnitFrame()
    if GW.settings.unitframes[self.gwUnit].enabled then
        self:SetScript("OnUpdate", self.OnUpdate)
        RegisterUnitWatch(self)
    else
        self:SetScript("OnUpdate", nil)
        UnregisterUnitWatch(self)
        RegisterStateDriver(self, "visibility", "hide")
    end
end

-- target of target and focus target in the text preview, they take color and background from their parent frame
local function CreateSmallUnitFramePreview(unit)
    local unitframe = CreateSmallUnitFrame("Gw" .. unit .. "UnitFrameTextPreview")
    unitframe.gwUnit = unit
    return unitframe
end

local function ApplySmallUnitFramePreview(frame)
    local parentSettings = GW.settings.unitframes[frame.gwUnit:gsub("target$", "")]
    frame.backgroundOverlay:SetShown(parentSettings.altBackground)
    frame.classColor = parentSettings.classColor
    frame:ApplyBarLayout()
end
GW.SetUnitFrameTextPreviewBuilder("targettarget", CreateSmallUnitFramePreview, ApplySmallUnitFramePreview)
GW.SetUnitFrameTextPreviewBuilder("focustarget", CreateSmallUnitFramePreview, ApplySmallUnitFramePreview)

local function LoadTargetOfUnit(unit, parentUnitFrame)
    local f = CreateSmallUnitFrame("Gw" .. unit .. "TargetUnitFrame")
    local unitID = unit:lower() .. "target"
    f.type = "SmallTarget"
    f.gwUnit = unitID

    f.parentUnitFrame = parentUnitFrame
    f.parentUnitId = unit:lower()

    f.castingbarNormal.Pips = {}
    f:SetScript("OnEvent", f.OnInterruptEvent)

    RegisterMovableFrame(f, unit == "Focus" and MINIMAP_TRACKING_FOCUS or SHOW_TARGET_OF_TARGET_TEXT, "unitframes." .. unitID, "Unitframe")

    f:ClearAllPoints()
    f:SetPoint("LEFT", f.gwMover)

    f:SetAttribute("*type1", "target")
    f:SetAttribute("*type2", "togglemenu")
    f:SetAttribute("unit", unitID)
    f:EnableMouse(true)
    f:RegisterForClicks("AnyDown")

    GW.AddToClique(f)

    f:ToggleSettings()

    f.debuffFilter = nil

    f.totalElapsed = 0.15

    f:ToggleUnitFrame()
end
GW.LoadTargetOfUnit = LoadTargetOfUnit
