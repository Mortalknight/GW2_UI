local _, GW = ...
local DebuffColors = GW.Libs.Dispel:GetDebuffTypeColor()
local BleedList = GW.Libs.Dispel:GetBleedList()
local BadDispels = GW.Libs.Dispel:GetBadList()
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local INDICATORS = GW.INDICATORS

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
    button.backdrop:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/spelliconempty")
    button.backdrop:Hide()

    button.background = button:CreateTexture(nil, "BACKGROUND")
    button.background:ClearAllPoints()
    button.background:SetPoint("TOPLEFT")
    button.background:SetPoint("BOTTOMRIGHT")
    button.background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
    button.background:Hide()
end
GW.Construct_AuraIcon = Construct_AuraIcon

local function PostUpdateButton(self, button, unit, data, position)
    local parent = self:GetParent()
    if button.isHarmful then
        local size = 16
        local isDispellable = data.dispelName and GW.Libs.Dispel:IsDispellableByMe(data.dispelName) or false
        local isImportant = (parent.raidShowImportendInstanceDebuffs and GW.ImportendRaidDebuff[data.spellId]) or false
        if isImportant or isDispellable then
            if isImportant and isDispellable then
                size = size * GW.GetDebuffScaleBasedOnPrio()
            elseif isImportant then
                size = size * tonumber(parent.raidDebuffScale)
            elseif isDispellable then
                size = size * tonumber(parent.raidDispelDebuffScale)
            end
        end

        if data.dispelName and DebuffColors[data.dispelName] then
            button.background:SetVertexColor(DebuffColors[data.dispelName].r, DebuffColors[data.dispelName].g, DebuffColors[data.dispelName].b)
        else
            button.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
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

local function FilterAura(self, unit, data)
    local parent = self:GetParent()
    local shouldDisplay = false
    local isImportant, isDispellable

    if data.isHelpful then
        -- missing buffs: needs a custom plugin

        local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(data.spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
        if hasCustom then
            shouldDisplay = showForMySpec or (alwaysShowMine and (data.sourceUnit == "player" or data.sourceUnit == "pet" or data.sourceUnit == "vehicle"))
        else
            shouldDisplay = (data.sourceUnit == "player" or data.sourceUnit == "pet" or data.sourceUnit == "vehicle") and (data.canApplyAura or data.isPlayerAura) and not SpellIsSelfBuff(data.spellId)
        end

        if shouldDisplay and parent.ignoredAuras then
            shouldDisplay = data.name and not parent.ignoredAuras[data.name]
        end

        -- check here for indicators
        -- indicators
        local indicators = GW.AURAS_INDICATORS[GW.myclass]
        local indicator = indicators[data.spellId]
        if indicator then
            for _, pos in ipairs(INDICATORS) do
                if parent.raidIndicators and parent.raidIndicators[pos] and parent.raidIndicators[pos] == (indicator[4] or data.spellId) then
                    local frame = self["indicator" .. pos]
                    local r, g, b = unpack(indicator)

                    frame.isBar = pos == "BAR"
                    if frame.isBar then
                        frame.expires = data.expirationTime
                        frame.duration = data.duration
                    else
                        -- Stacks
                        if data.applications > 1 then
                            frame.text:SetText(data.applications)
                            frame.text:SetFont(UNIT_NAME_FONT, data.applications > 9 and 9 or 11, "OUTLINE")
                            frame.text:Show()
                        else
                            frame.text:Hide()
                        end

                        -- Icon
                        if parent.showRaidIndicatorIcon then
                            frame.icon:SetTexture(data.icon)
                        else
                            frame.icon:SetColorTexture(r, g, b)
                        end

                        -- Cooldown
                        frame.cooldown:SetCooldown(data.expirationTime - data.duration, data.duration)
                        if not frame.cooldown.hooked then
                            frame.cooldown:HookScript("OnCooldownDone", function()
                                frame:Hide()
                                frame.auraInstanceId = nil
                                frame.isBar = nil
                            end)
                        end
                        if parent.showRaidIndicatorTimer then
                            frame.cooldown:Show()
                        else
                            frame.cooldown:Hide()
                        end

                        -- do not show that buff as normal buff
                        shouldDisplay = false
                    end
                    frame.auraInstanceId = data.auraInstanceID
                    frame:Show()
                end
            end
        end

        return shouldDisplay
    else
        isDispellable = data.dispelName and GW.Libs.Dispel:IsDispellableByMe(data.dispelName) or false
        isImportant = (parent.raidShowImportendInstanceDebuffs and GW.ImportendRaidDebuff[data.spellId]) or false

        if data.dispelName and BadDispels[data.spellId] and GW.Libs.Dispel:IsDispellableByMe(data.dispelName) then
            data.dispelName = "BadDispel"
        end
        if not data.dispelName and BleedList[data.spellId] and GW.Libs.Dispel:IsDispellableByMe("Bleed") and DebuffColors.Bleed then
            data.dispelName = "Bleed"
        end

        if parent.showAllDebuffs then
            if parent.showOnlyDispelDebuffs then
                if isDispellable then
                    shouldDisplay = data.name and not (parent.ignoredAuras and parent.ignoredAuras[data.name] or data.spellId == 6788 and data.sourceUnit and not UnitIsUnit(data.sourceUnit, "player")) -- Don't show "Weakened Soul" from other players
                end
            else
                shouldDisplay = data.name and not (parent.ignoredAuras and parent.ignoredAuras[data.name] or data.spellId == 6788 and data.sourceUnit and not UnitIsUnit(data.sourceUnit, "player")) -- Don't show "Weakened Soul" from other players
            end
        end

        if parent.raidShowImportendInstanceDebuffs and not shouldDisplay then
            shouldDisplay = isImportant
        end

        return shouldDisplay
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
            else
                frame.cooldown:SetCooldown(data.expirationTime - data.duration, data.duration)
            end
        end
    end

    return data
end

local function PostUpdateInfoRemovedAuraID(self, auraInstanceID)
    for _, pos in ipairs(INDICATORS) do
        local frame = self["indicator" .. pos]
        if frame and frame.auraInstanceId and frame.auraInstanceId == auraInstanceID then
            frame:Hide()
            frame.isBar = nil
            frame.auraInstanceId = nil
        end
    end
end

local function HandleTooltip(self, event)
    self.Auras:ForceUpdate()
end

local function Construct_Auras(frame)
    local auras = CreateFrame('Frame', '$parentAuras', frame)
    auras:SetSize(frame:GetSize())
    auras:SetFrameLevel(20)

    -- init settings
    auras.initialAnchor = "BOTTOMRIGHT"
    auras['growth-x'] = "LEFT"
    auras['spacing-x'] = 2
    auras['spacing-y'] = 2
    auras.disableCooldown = true
    auras.reanchorIfVisibleChanged = true

    auras.PostCreateButton = Construct_AuraIcon
    auras.PostUpdateButton = PostUpdateButton
    auras.FilterAura = FilterAura
    auras.PostUpdateInfoRemovedAuraID = PostUpdateInfoRemovedAuraID
    auras.PostProcessAuraData = PostProcessAuraData

    auras.size = 14 -- dynamic

    frame:RegisterEvent("PLAYER_REGEN_DISABLED", HandleTooltip, true)
    frame:RegisterEvent("PLAYER_REGEN_ENABLED", HandleTooltip, true)


    -- construct the aura indicators
    local indicatorTopleft = CreateFrame("Frame", '$parentIndicatorTopleft', frame, "GwGridFrameAuraIndicator")
    indicatorTopleft:SetPoint("TOPLEFT", frame, "TOPLEFT", 0.3, -0.3)
    indicatorTopleft:SetFrameLevel(20)
    auras.indicatorTOPLEFT = indicatorTopleft

    local indicatorTop = CreateFrame("Frame", '$parentIndicatorTop', frame, "GwGridFrameAuraIndicator")
    indicatorTop:SetPoint("TOP", frame, "TOP", 0, -0.3)
    indicatorTop:SetFrameLevel(20)
    auras.indicatorTOP = indicatorTop

    local indicatorLeft = CreateFrame("Frame", '$parentIndicatorLeft', frame, "GwGridFrameAuraIndicator")
    indicatorLeft:SetPoint("LEFT", frame, "LEFT", 0.3, 0)
    indicatorLeft:SetFrameLevel(20)
    auras.indicatorLEFT = indicatorLeft

    local indicatorTopright = CreateFrame("Frame", '$parentIndicatorTopright', frame, "GwGridFrameAuraIndicator")
    indicatorTopright:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -0.3, -0.3)
    indicatorTopright:SetFrameLevel(20)
    auras.indicatorTOPRIGHT = indicatorTopright

    local indicatorCenter = CreateFrame("Frame", '$parentIndicatorCenter', frame, "GwGridFrameAuraIndicator")
    indicatorCenter:SetPoint("CENTER", frame, "CENTER", 0, 0)
    indicatorCenter:SetFrameLevel(20)
    auras.indicatorCENTER = indicatorCenter

    local indicatorRight = CreateFrame("Frame", '$parentIndicatorRight', frame, "GwGridFrameAuraIndicator")
    indicatorRight:SetPoint("RIGHT", frame, "RIGHT", -0.3, 0)
    indicatorRight:SetFrameLevel(20)
    auras.indicatorRIGHT = indicatorRight

    local indicatorBar = CreateFrame("StatusBar", '$parentIndicatorBar', frame)
    indicatorBar:SetFrameLevel(20)
    indicatorBar:SetOrientation("VERTICAL")
    indicatorBar:SetMinMaxValues(0, 1)
    indicatorBar:SetSize(2, 2)
    indicatorBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 3, 0)
    indicatorBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, 0)
    indicatorBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
    indicatorBar:SetStatusBarColor(1, 0.5, 0)
    indicatorBar:SetScript("OnUpdate", function(self)
        if self:IsShown() and self.expires and self.duration then
            self:SetValue(math.max(0, math.min(1, (self.expires - GetTime()) / self.duration)))
        end
    end)
    indicatorBar:Hide()

    indicatorBar.bg = indicatorBar:CreateTexture(nil, "BORDER")
    indicatorBar.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
    indicatorBar.bg:SetPoint("TOPLEFT", indicatorBar, "TOPLEFT", 0, 1)
    indicatorBar.bg:SetPoint("BOTTOMRIGHT", indicatorBar, "BOTTOMRIGHT", 1, -1)
    indicatorBar.bg:SetVertexColor(0, 0, 0, 1)
    auras.indicatorBAR = indicatorBar

	return auras
end
GW.Construct_Auras = Construct_Auras

local function UpdateAurasSettings(frame)
    frame.Auras:ClearAllPoints()
    frame.Auras:SetPoint('TOPLEFT', frame, 'TOPLEFT')
    if frame.showResscoureBar then
        frame.Auras:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 5)
    else
        frame.Auras:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 2)
    end

    frame.Auras.initialAnchor = "BOTTOMRIGHT"
    frame.Auras['growth-x'] = "LEFT"
    frame.Auras['spacing-x'] = 2
    frame.Auras['spacing-y'] = 2
    frame.Auras:SetSize(frame.unitWidth - 2, frame.unitHeight - 2)
    frame.Auras.forceShow = frame.forceShowAuras

    frame.Auras:ForceUpdate()
end
GW.UpdateAurasSettings = UpdateAurasSettings