---@class GW2
local GW = select(2, ...)
local BadDispels = GW.Libs.Dispel:GetBadList()
local INDICATORS = GW.INDICATORS
local INDICATOR_CONFIG = {
    TOPLEFT = { point = "TOPLEFT", x = 0.3, y = -0.3 },
    TOP = { point = "TOP", x = 0, y = -0.3 },
    LEFT = { point = "LEFT", x = 0.3, y = 0 },
    TOPRIGHT = { point = "TOPRIGHT", x = -0.3, y = -0.3 },
    CENTER = { point = "CENTER", x = 0, y = 0 },
    RIGHT = { point = "RIGHT", x = -0.3, y = 0 },
}

local function BuildIndicatorSpellIndex(indicators)
    local index = {}
    for mainSpellId, data in pairs(indicators) do
        local includedIds = data[4]
        if includedIds then
            for _, includedId in ipairs(includedIds) do
                index[includedId] = mainSpellId
            end
        end
    end
    return index
end

local function GetIndicatorDataForSpellId(indicators, spellId)
    if GW.IsSecretValue(spellId) or not indicators or not spellId then
        return nil, nil
    end

    local indicator = indicators[spellId]
    if indicator then
        return indicator, spellId
    end

    -- Fallback: check includedIds lists via cached index for indirect matches
    if not indicators.__includedIndex then
        indicators.__includedIndex = BuildIndicatorSpellIndex(indicators)
    end

    local mainSpellId = indicators.__includedIndex[spellId]
    if mainSpellId then
        return indicators[mainSpellId], mainSpellId
    end

    return nil, nil
end

local function Construct_AuraIcon(self, button)
    button.Count:ClearAllPoints()
    button.Count:SetPoint("TOPLEFT")
    button.Count:SetPoint("BOTTOMRIGHT")
    button.Count:SetFont(UNIT_NAME_FONT, 11, "OUTLINE")
    button.Count:SetTextColor(1, 1, 1)
    button.Count:SetJustifyH("CENTER")

    button.Stealable:SetTexture()
    button.Overlay:SetTexture()

    button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button.Icon:ClearAllPoints()
    button.Icon:SetPoint("TOPLEFT", 1, -1)
    button.Icon:SetPoint("BOTTOMRIGHT", -1, 1)

    button.backdrop = button:CreateTexture(nil, "BACKGROUND")
    button.backdrop:ClearAllPoints()
    button.backdrop:SetPoint("TOPLEFT")
    button.backdrop:SetPoint("BOTTOMRIGHT")
    button.backdrop:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/spelliconempty.png")
    button.backdrop:Hide()

    button.background = button:CreateTexture(nil, "BACKGROUND")
    button.background:ClearAllPoints()
    button.background:SetPoint("TOPLEFT")
    button.background:SetPoint("BOTTOMRIGHT")
    button.background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    button.background:Hide()
end
GW.Construct_AuraIcon = Construct_AuraIcon

local function PostUpdateButton(self, button, unit, data, position)
    local parent = self:GetParent()

    if GW.Retail then
        if data.isHarmfulAura then
            local color = C_UnitAuras.GetAuraDispelTypeColor(unit, data.auraInstanceID, self.dispelColorCurve)
            if not color then
                color = GW.Colors.Fallback
            end
            button.background:SetVertexColor(color:GetRGBA())
            button.background:Show()
            button.backdrop:Hide()

            local isDispellable = data.isAuraRaidPlayerDispellable
            local isImportant = data.isAuraImportant
            local size = 16
            if isImportant and isDispellable then
                size = size * GW.GetDebuffScaleBasedOnPrio()
            elseif isImportant then
                size = size * tonumber(parent.raidDebuffScale)
            elseif isDispellable then
                size = size * tonumber(parent.raidDispelDebuffScale)
            end
            button:SetSize(size, size)
        else
            button.background:Hide()
            button.backdrop:Show()
        end
    else
        if data.isHarmfulAura then
            local size = 16
            local isDispellable = data.dispelName and GW.Libs.Dispel:IsDispellableByMe(data.dispelName) or false
            local isImportant = (parent.raidShowImportantInstanceDebuffs and GW.ImportantRaidDebuff[data.spellId]) or false
            if isImportant and isDispellable then
                size = size * GW.GetDebuffScaleBasedOnPrio()
            elseif isImportant then
                size = size * tonumber(parent.raidDebuffScale)
            elseif isDispellable then
                size = size * tonumber(parent.raidDispelDebuffScale)
            end

            if data.dispelName and GW.Colors.DebuffColors[data.dispelName] then
                button.background:SetVertexColor(GW.Colors.DebuffColors[data.dispelName]:GetRGB())
            else
                button.background:SetVertexColor(GW.Colors.DebuffColors.None:GetRGB())
            end

            button:SetSize(size, size)
            button.background:Show()
            button.backdrop:Hide()

            -- redo the position
            self:ForceUpdate(true)
        else
            button.background:Hide()
            button.backdrop:Show()
        end
    end

    -- aura tooltips
    if parent.showAuraTooltipInCombat == "NEVER" then
        button:EnableMouse(false)
    elseif parent.showAuraTooltipInCombat == "ALWAYS" then
        button:EnableMouse(true)
    elseif parent.showAuraTooltipInCombat == "OUT_COMBAT" then
        button:EnableMouse(not InCombatLockdown()) -- this is trigger by an event
    elseif parent.showAuraTooltipInCombat == "IN_COMBAT" then
        button:EnableMouse(InCombatLockdown()) -- this is trigger by an event
    end
end

local function CheckFilter(data, filters)
    if not filters or filters.noFilter then return true end

    local player, cancel = data.isAuraPlayer, data.isAuraCancelable
    local other, perma = not player, not cancel

    if GW.Retail then
        return (filters.isAuraPlayer and player)
            or (filters.isAuraRaidPlayerDispellable and data.isAuraRaidPlayerDispellable)
            or (filters.isAuraImportant and data.isAuraImportant and other)
            or (filters.isAuraImportantPlayer and data.isAuraImportant and player)
            or (filters.isAuraCrowdControl and data.isAuraCrowdControl and other)
            or (filters.isAuraCrowdControlPlayer and data.isAuraCrowdControl and player)
            or (filters.isAuraBigDefensive and data.isAuraBigDefensive and other)
            or (filters.isAuraBigDefensivePlayer and data.isAuraBigDefensive and player)
            or (filters.isAuraRaidInCombat and data.isAuraRaidInCombat and other)
            or (filters.isAuraRaidInCombatPlayer and data.isAuraRaidInCombat and player)
            or (filters.isAuraExternalDefensive and data.isAuraExternalDefensive and other)
            or (filters.isAuraExternalDefensivePlayer and data.isAuraExternalDefensive and player)
            or (filters.isAuraCancelable and cancel and other)
            or (filters.isAuraCancelablePlayer and cancel and player)
            or (filters.notAuraCancelable and perma and other)
            or (filters.notAuraCancelablePlayer and perma and player)
            or (filters.isAuraRaid and data.isAuraRaid and other)
            or (filters.isAuraRaidPlayer and data.isAuraRaid and player)
    else
        return (filters.isAuraPlayer and player)
            or (filters.isAuraCancelable and cancel and other)
            or (filters.isAuraCancelablePlayer and cancel and player)
            or (filters.notAuraCancelable and perma and other)
            or (filters.notAuraCancelablePlayer and perma and player)
            or (filters.isAuraRaid and data.isAuraRaid and other)
            or (filters.isAuraRaidPlayer and data.isAuraRaid and player)
    end
end

local function ClearIndicatorFrame(frame)
    frame:Hide()
    frame.auraInstanceId = nil
    frame.isBar = nil
    frame.expires = nil
    frame.duration = nil

    if frame.textFrame then
        frame.textFrame.text:Hide()
    end

    if frame.cooldown then
        frame.cooldown:Hide()
    end

    if frame.isIndicatorBar then
        frame:SetValue(0)
        frame:SetScript("OnUpdate", nil)
    end
end

local function UpdateIndicatorBarValue(self)
    if not self.auraInstanceId or not self.expires or not self.duration or self.duration <= 0 then
        return false
    end

    local value = (self.expires - GetTime()) / self.duration
    if value <= 0 then
        return false
    end

    self:SetValue(math.min(1, value))
    return true
end

local function IndicatorBar_OnUpdate(self)
    if not UpdateIndicatorBarValue(self) then
        ClearIndicatorFrame(self)
    end
end

local function UpdateIndicatorStack(frame, parent, applications)
    local text = frame.textFrame.text
    if not parent.showRaidIndicatorStacks then
        text:Hide()
        return
    end

    applications = applications or 0
    if applications > 1 then
        text:SetText(applications)
        text:SetFont(UNIT_NAME_FONT, applications > 9 and 8 or 10, "OUTLINE")
        text:Show()
    else
        text:Hide()
    end
end

local function UpdateIconIndicator(frame, parent, data)
    UpdateIndicatorStack(frame, parent, data.applications)

    if parent.showRaidIndicatorIcon then
        frame.icon:SetTexture(data.icon)
    else
        local color = frame.color
        frame.icon:SetColorTexture(color.r, color.g, color.b)
    end

    if data.expirationTime and data.duration and data.duration > 0 then
        frame.cooldown:SetCooldown(data.expirationTime - data.duration, data.duration)
    else
        frame.cooldown:SetCooldown(0, 0)
    end

    if parent.showRaidIndicatorTimer then
        frame.cooldown:Show()
    else
        frame.cooldown:Hide()
    end

    frame:Show()
end

local function CheckForAuraIndicators(self, parent, isPlayerBuff, data, shouldDisplay)
    local raidIndicators = parent.raidIndicators
    if not isPlayerBuff or not raidIndicators then
        return shouldDisplay
    end

    local indicators = GW.AURAS_INDICATORS[GW.myclass]
    local indicator, indicatorSpellId = GetIndicatorDataForSpellId(indicators, data.spellId)
    if not indicator then
        return shouldDisplay
    end

    for _, pos in ipairs(INDICATORS) do
        if raidIndicators[pos] == indicatorSpellId then
            local frame = self["indicator" .. pos]
            local r, g, b = unpack(indicator)

            frame.isBar = pos == "BAR"
            frame.auraInstanceId = data.auraInstanceID

            if frame.isBar then
                frame.expires = data.expirationTime
                frame.duration = data.duration
                frame:SetScript("OnUpdate", IndicatorBar_OnUpdate)

                if UpdateIndicatorBarValue(frame) then
                    frame:Show()
                else
                    ClearIndicatorFrame(frame)
                end
            else
                frame.color.r = r
                frame.color.g = g
                frame.color.b = b
                UpdateIconIndicator(frame, parent, data)
                shouldDisplay = false
            end
        end
    end

    return shouldDisplay
end

local function FilterAura(self, unit, data)
    local parent = self:GetParent()
    local shouldDisplay = false
    local isImportant, isDispellable

    if GW.Retail then
        local isDebuff = data.isHarmfulAura

        if isDebuff then
            if not parent.showDebuffs then
                return shouldDisplay
            end
            return CheckFilter(data, parent.debuffFilters)
        else
            if parent.showBuffs then
                shouldDisplay = CheckFilter(data, parent.buffFilters)
            end

            return CheckForAuraIndicators(self, parent, data.isAuraPlayer, data, shouldDisplay)
        end
    else
        if data.isHelpfulAura then
            local isPlayerBuff = data.sourceUnit == "player" or data.sourceUnit == "pet" or data.sourceUnit == "vehicle"

            if parent.showBuffs then
                local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(data.spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
                if hasCustom then
                    shouldDisplay = showForMySpec or (alwaysShowMine and (data.sourceUnit == "player" or data.sourceUnit == "pet" or data.sourceUnit == "vehicle"))
                else
                    shouldDisplay = (data.sourceUnit == "player" or data.sourceUnit == "pet" or data.sourceUnit == "vehicle") and (data.canApplyAura or data.isAuraPlayer) and not SpellIsSelfBuff(data.spellId)
                end

                if shouldDisplay and parent.ignoredAuras then
                    shouldDisplay = data.name and not parent.ignoredAuras[data.name]
                end
            end

            return CheckForAuraIndicators(self, parent, isPlayerBuff, data, shouldDisplay)
        else
            isDispellable = data.dispelName and GW.Libs.Dispel:IsDispellableByMe(data.dispelName) or false
            isImportant = (parent.raidShowImportantInstanceDebuffs and GW.ImportantRaidDebuff[data.spellId]) or false

            if data.dispelName and BadDispels[data.spellId] and GW.Libs.Dispel:IsDispellableByMe(data.dispelName) then
                data.dispelName = "BadDispel"
            end

            if parent.showDebuffs then
                if parent.showOnlyDispelDebuffs then
                    if isDispellable then
                        shouldDisplay = data.name and not (parent.ignoredAuras and parent.ignoredAuras[data.name] or data.spellId == 6788 and data.sourceUnit and GW.UnitNotUnit(data.sourceUnit, "player")) -- Don't show "Weakened Soul" from other players
                    end
                else
                    shouldDisplay = data.name and not (parent.ignoredAuras and parent.ignoredAuras[data.name] or data.spellId == 6788 and data.sourceUnit and GW.UnitNotUnit(data.sourceUnit, "player")) -- Don't show "Weakened Soul" from other players
                end
            end

            if parent.raidShowImportantInstanceDebuffs and not shouldDisplay then
                shouldDisplay = isImportant
            end

            return shouldDisplay
        end
    end
end

-- Update indicator data
local function PostProcessAuraData(self, unit, data)
    for _, pos in ipairs(INDICATORS) do
        local frame = self["indicator" .. pos]
        if frame and frame.auraInstanceId and frame.auraInstanceId == data.auraInstanceID then
            if frame.isBar then
                frame.expires = data.expirationTime
                frame.duration = data.duration
                frame:SetScript("OnUpdate", IndicatorBar_OnUpdate)

                if not UpdateIndicatorBarValue(frame) then
                    ClearIndicatorFrame(frame)
                end
            else
                UpdateIconIndicator(frame, self:GetParent(), data)
            end
        end
    end

    return data
end

local function PostUpdateInfoRemovedAuraID(self, auraInstanceID)
    for _, pos in ipairs(INDICATORS) do
        local frame = self["indicator" .. pos]
        if frame and frame.auraInstanceId and frame.auraInstanceId == auraInstanceID then
            ClearIndicatorFrame(frame)
        end
    end
end

local function PreUpdateAuras(self, unit, isFullUpdate)
    if not isFullUpdate then return end
    for _, pos in ipairs(INDICATORS) do
        local frame = self["indicator" .. pos]
        if frame then
            ClearIndicatorFrame(frame)
        end
    end
end

local function HandleTooltip(self, event)
    self.Auras:ForceUpdate()
end

local function CreateAuraIndicator(frame, pos)
    local config = INDICATOR_CONFIG[pos]
    if not config then return nil end

    local indicator = CreateFrame("Frame", nil, frame, "GwGridFrameAuraIndicator")

    indicator:SetPoint(config.point, frame, config.point, config.x, config.y)
    indicator.color = { r = 1, g = 1, b = 1 }
    indicator.cooldown:HookScript("OnCooldownDone", function()
        ClearIndicatorFrame(indicator)
    end)

    return indicator
end

local function Construct_Auras(frame)
    local auras = CreateFrame('Frame', '$parentAuras', frame)
    auras:SetSize(frame:GetSize())
    auras:SetFrameLevel(frame.RaisedElementParent.AuraLevel)

    -- init settings
    auras.initialAnchor = "BOTTOMRIGHT"
    auras.growthX = "LEFT"
    auras.spacingX = 1
    auras.spacingY = 1
    auras.disableCooldown = true
    auras.reanchorIfVisibleChanged = true

    auras.PostCreateButton = Construct_AuraIcon
    auras.PostUpdateButton = PostUpdateButton
    auras.FilterAura = FilterAura

    auras.PostUpdateInfoRemovedAuraID = PostUpdateInfoRemovedAuraID
    auras.PostProcessAuraData = PostProcessAuraData
    auras.PreUpdate = PreUpdateAuras

    auras.size = 14 -- dynamic

    frame:RegisterEvent("PLAYER_REGEN_DISABLED", HandleTooltip, true)
    frame:RegisterEvent("PLAYER_REGEN_ENABLED", HandleTooltip, true)

    -- construct the aura indicators
    for _, pos in ipairs(INDICATORS) do
        if INDICATOR_CONFIG[pos] then
            auras["indicator" .. pos] = CreateAuraIndicator(frame, pos)
        end
    end

    local indicatorBar = CreateFrame("StatusBar", '$parentIndicatorBar', frame)
    indicatorBar:SetFrameLevel(20)
    indicatorBar:SetOrientation("VERTICAL")
    indicatorBar:SetMinMaxValues(0, 1)
    indicatorBar:SetSize(2, 2)
    indicatorBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 3, 0)
    indicatorBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, 0)
    indicatorBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    indicatorBar:SetStatusBarColor(1, 0.5, 0)
    indicatorBar.isIndicatorBar = true
    indicatorBar:Hide()

    indicatorBar.bg = indicatorBar:CreateTexture(nil, "BORDER")
    indicatorBar.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    indicatorBar.bg:SetPoint("TOPLEFT", indicatorBar, "TOPLEFT", 0, 1)
    indicatorBar.bg:SetPoint("BOTTOMRIGHT", indicatorBar, "BOTTOMRIGHT", 1, -1)
    indicatorBar.bg:SetVertexColor(0, 0, 0, 1)
    auras.indicatorBAR = indicatorBar

    if GW.Retail or GW.Mists then
        auras.dispelColorCurve = C_CurveUtil.CreateColorCurve()
        auras.dispelColorCurve:SetType(Enum.LuaCurveType.Step)
        for _, dispelIndex in next, GW.Enum.DispelType do
            if GW.Colors.DebuffColors[dispelIndex] then
                auras.dispelColorCurve:AddPoint(dispelIndex, GW.Colors.DebuffColors[dispelIndex])
            end
        end
    end

	return auras
end
GW.Construct_Auras = Construct_Auras

local function UpdateFilters(frame)
    for i = 1, 2 do
        local db = i == 1 and frame.buffFilters or frame.debuffFilters
        local isPlayer = db.isAuraPlayer
        local isRaidPlayerDispellable = db.isAuraRaidPlayerDispellable
        local isImportant = db.isAuraImportant
        local isImportantPlayer = db.isAuraImportantPlayer
        local isCrowdControl = db.isAuraCrowdControl
        local isCrowdControlPlayer = db.isAuraCrowdControlPlayer
        local isBigDefensive = db.isAuraBigDefensive
        local isBigDefensivePlayer = db.isAuraBigDefensivePlayer
        local isRaidInCombat = db.isAuraRaidInCombat
        local isRaidInCombatPlayer = db.isAuraRaidInCombatPlayer
        local isExternalDefensive = db.isAuraExternalDefensive
        local isExternalDefensivePlayer = db.isAuraExternalDefensivePlayer
        local isCancelable = db and db.isAuraCancelable
        local isCancelablePlayer = db and db.isAuraCancelablePlayer
        local notCancelable = db and db.notAuraCancelable
        local notCancelablePlayer = db and db.notAuraCancelablePlayer
        local isRaid = db and db.isAuraRaid
        local isRaidPlayer = db and db.isAuraRaidPlayer

        local shared = isPlayer or isCancelable or isCancelablePlayer or notCancelable or notCancelablePlayer or isRaid or isRaidPlayer
        if GW.Retail then
            db.noFilter = not (shared or isRaidPlayerDispellable or isImportant or isImportantPlayer or isCrowdControl or isCrowdControlPlayer or isBigDefensive or isBigDefensivePlayer or isRaidInCombat or isRaidInCombatPlayer or isExternalDefensive or isExternalDefensivePlayer)
        else
            db.noFilter = not shared
        end
    end
end

local function UpdateIndicatorSettings(frame)
    local indicatorSize = tonumber(frame.raidIndicatorSize) or 13
    local indicatorBarWidth = tonumber(frame.raidIndicatorBarWidth) or 2

    for _, pos in ipairs(INDICATORS) do
        if INDICATOR_CONFIG[pos] then
            local indicator = frame.Auras["indicator" .. pos]
            indicator:SetSize(indicatorSize, indicatorSize)
        end
    end

    frame.Auras.indicatorBAR:SetWidth(indicatorBarWidth)
end

local function UpdateAurasSettings(frame)
    frame.Auras:ClearAllPoints()
    frame.Auras:SetPoint('TOPLEFT', frame, 'TOPLEFT')
    if frame.showResscoureBar == "ALL" or frame.showResscoureBar == "HEALER" then
        frame.Auras:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 5)
    else
        frame.Auras:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 2)
    end

    frame.Auras:SetSize(frame.unitWidth - 2, frame.unitHeight - 2)
    frame.Auras.forceShow = frame.forceShowAuras
    UpdateIndicatorSettings(frame)
    UpdateFilters(frame)

    frame.Auras:ForceUpdate()
end
GW.UpdateAurasSettings = UpdateAurasSettings
