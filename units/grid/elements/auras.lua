local _, GW = ...
local DebuffColors = GW.Libs.Dispel:GetDebuffTypeColor()
local BleedList = GW.Libs.Dispel:GetBleedList()
local BadDispels = GW.Libs.Dispel:GetBadList()
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY

local spellIDs = {}
local spellBookSearched = 0


local function Construct_AuraIcon(self, button)
    button.Count:ClearAllPoints()
    button.Count:SetPoint("TOPLEFT")
    button.Count:SetPoint("BOTTOMRIGHT")
    button.Count:SetFont(UNIT_NAME_FONT, 11, "OUTLINED")
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

        if data.dispelName and GW.DebuffColors[data.dispelName] then
            button.background:SetVertexColor(DebuffColors[data.dispelName].r, DebuffColors[data.dispelName].g, DebuffColors[data.dispelName].b)
        else
            button.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
        end

        button:SetSize(size, size)
        button.background:Show()
        button.backdrop:Hide()
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

        return shouldDisplay
    else
        local parent = self:GetParent()

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
                    shouldDisplay = data.name and not (parent.ignoredAuras[data.name] or data.spellId == 6788 and data.sourceUnit and not UnitIsUnit(data.sourceUnit, "player")) -- Don't show "Weakened Soul" from other players
                end
            else
                shouldDisplay = data.name and not (parent.ignoredAuras[data.name] or data.spellId == 6788 and data.sourceUnit and not UnitIsUnit(data.sourceUnit, "player")) -- Don't show "Weakened Soul" from other players
            end
        end

        if parent.showImportendInstanceDebuffs and not shouldDisplay then
            shouldDisplay = isImportant
        end

        return shouldDisplay
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

    auras.size = 14 -- dynamic

    frame:RegisterEvent("PLAYER_REGEN_DISABLED", HandleTooltip, true)
    frame:RegisterEvent("PLAYER_REGEN_ENABLED", HandleTooltip, true)
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

    frame.Auras:ForceUpdate()
end
GW.UpdateAurasSettings = UpdateAurasSettings