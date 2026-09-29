---@class GW2
local GW = select(2, ...)

-- the classic clients show the player auras through blizzards secure aura header
if GW.isModern then return end

local BadDispels = GW.Libs.Dispel:GetBadList()

local SHORT_AURA_DURATION = 121 -- up to here an aura shows the cooldown swipe
local NEW_AURA_WINDOW = 0.5
local REFRESH_INTERVAL = 0.1
local ENCHANT_REFRESH_INTERVAL = 1

-- the sort settings the modern aura bars share, as secure header attributes
local SORT = {
    DEFAULT = {method = "INDEX", direction = "+"},
    EXPIRATION_ASC = {method = "TIME", direction = "+"},
    EXPIRATION_DESC = {method = "TIME", direction = "-"},
    NAME_ASC = {method = "NAME", direction = "+"},
    NAME_DESC = {method = "NAME", direction = "-"},
}

local VISIBILITY_SNIPPET = [[
    local header = self:GetFrameRef("AuraHeader")
    if newstate == 0 then header:Hide() else header:Show() end
]]

local INITIAL_CONFIG_SNIPPET = [[
    local header = self:GetParent()
    self:SetWidth(header:GetAttribute("config-width"))
    self:SetHeight(header:GetAttribute("config-height"))
]]

local function GetSettings(button)
    return GW.settings.playerAuras[button.header.auraKey]
end

-- short auras show the swipe and a big timer, long ones, endless ones and weapon enchants a small one
local function SetTimerLayout(button, short, stacks)
    local key = short and "short" or "long"
    local manyStacks = stacks and stacks > 99
    if button.timerLayout == key and button.manyStacks == manyStacks then
        return
    end
    button.timerLayout, button.manyStacks = key, manyStacks

    local size = short and GW.Enum.TextSizeType.Normal or GW.Enum.TextSizeType.Small
    button.status.duration:GwSetFontTemplate(UNIT_NAME_FONT, size, "SHADOW", -1)
    if manyStacks then
        button.status.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "SHADOWOUTLINE", -2)
    else
        button.status.stacks:GwSetFontTemplate(UNIT_NAME_FONT, size, "SHADOWOUTLINE")
    end

    local inset = short and 0 or 2
    button.status:ClearAllPoints()
    button.status:SetPoint("TOPLEFT", 4, short and -4 or -6)
    button.status:SetPoint("BOTTOMRIGHT", -4, short and 4 or 2)
    button.border:ClearAllPoints()
    button.border:SetPoint("TOPLEFT", inset, -inset * 2)
    button.border:SetPoint("BOTTOMRIGHT", -inset, 0)
end

local function ClearTimer(button)
    button.expiration = nil
    button.cooldown:Hide()
    button.status.duration:SetText("")
    SetTimerLayout(button, false, button.stacks)
end

local function ShowTimer(button, expiration, duration, noSwipe)
    local short = not noSwipe and duration < SHORT_AURA_DURATION
    button.expiration = expiration
    button.nextTextUpdate = 0
    SetTimerLayout(button, short, button.stacks)
    if short then
        button.cooldown:SetCooldown(expiration - duration, duration)
        button.cooldown:Show()
    else
        button.cooldown:Hide()
    end
end

local function SetBorderColor(button, dispelType, spellID)
    local color
    if button.enchantIndex then
        color = GW.Colors.DebuffColors.Curse
    elseif button.header.filter == "HELPFUL" then
        color = GW.Colors.Fallback
    elseif dispelType and BadDispels[spellID] and GW.Libs.Dispel:IsDispellableByMe(dispelType) then
        color = GW.Colors.DebuffColors.BadDispel
    else
        color = GW.Colors.DebuffColors[dispelType] or GW.Colors.DebuffColors.None
    end
    button.border.inner:SetVertexColor(color:GetRGB())
end

-- a new aura that was just applied zooms in
local function UpdateAura(button, index)
    local aura = C_UnitAuras.GetAuraDataByIndex(button.header:GetAttribute("unit"), index, button.header.filter)
    if not aura then
        button.auraInstanceID = nil
        ClearTimer(button)
        return
    end

    local isNew = aura.auraInstanceID ~= button.auraInstanceID
    button.auraInstanceID = aura.auraInstanceID
    button.stacks = aura.applications
    button.status.icon:SetTexture(aura.icon)
    button.status.stacks:SetText(aura.applications > 1 and aura.applications or "")
    SetBorderColor(button, aura.dispelName, aura.spellId)

    if aura.duration > 0 and aura.expirationTime then
        ShowTimer(button, aura.expirationTime, aura.duration)
        if isNew and GetSettings(button).NewAuraAnimation and GetTime() - (aura.expirationTime - aura.duration) < NEW_AURA_WINDOW then
            button.agZoomIn:Play()
        end
    else
        ClearTimer(button)
    end
end

-- enchant buttons are TempEnchant1 to 3: main hand, off hand, ranged
local function UpdateTempEnchant(button)
    local _, mainHand, _, _, _, offHand, _, _, _, ranged = GetWeaponEnchantInfo()
    local remaining = select(button.enchantIndex, mainHand, offHand, ranged)
    if not remaining then
        ClearTimer(button)
        return
    end
    button.stacks = nil
    button.status.icon:SetTexture(GetInventoryItemTexture("player", button:GetID()))
    button.status.stacks:SetText("")
    SetBorderColor(button)
    ShowTimer(button, GetTime() + remaining / 1000, remaining / 1000, true)
end

local function UpdateTooltip(button)
    GameTooltip:ClearLines()
    if button:GetAttribute("index") then
        GameTooltip:SetUnitAura(button.header:GetAttribute("unit"), button:GetID(), button.header.filter)
    elseif button:GetAttribute("target-slot") then
        GameTooltip:SetInventoryItem("player", button:GetID())
    end
end

local function OnUpdate(button, elapsed)
    if button.expiration then
        button.nextTextUpdate = button.nextTextUpdate - elapsed
        if button.nextTextUpdate <= 0 then
            local remaining = button.expiration - GetTime()
            if remaining < 0.1 then
                ClearTimer(button)
            else
                local text, nextUpdate = GW.GetTimeInfo(remaining)
                button.status.duration:SetText(text)
                button.nextTextUpdate = nextUpdate
            end
        end
    end

    button.sinceRefresh = (button.sinceRefresh or 0) + elapsed
    if button.sinceRefresh >= REFRESH_INTERVAL then
        button.sinceEnchantRefresh = (button.sinceEnchantRefresh or 0) + button.sinceRefresh
        button.sinceRefresh = 0
        if GameTooltip:IsOwned(button) then
            UpdateTooltip(button)
        end
        -- poisons and oils can be renewed without any attribute changing
        if button.enchantIndex and button.sinceEnchantRefresh >= ENCHANT_REFRESH_INTERVAL then
            button.sinceEnchantRefresh = 0
            UpdateTempEnchant(button)
        end
    end
end

-- the secure header hands each button its aura or weapon slot through these attributes
local function OnAttributeChanged(button, attribute, value)
    if attribute == "index" then
        UpdateAura(button, value)
    elseif attribute == "target-slot" and button.enchantIndex then
        UpdateTempEnchant(button)
    end
end

local function OnEnter(button)
    if not GameTooltip:IsForbidden() and button:IsVisible() then
        GameTooltip:SetOwner(button, "ANCHOR_BOTTOMLEFT", -5, -5)
        UpdateTooltip(button)
        GameTooltip:Show()
    end
end

local function UpdateIconSize(button, resize)
    local db = GetSettings(button)
    local width = db.IconSize
    local height = db.KeepSizeRatio and width or db.IconHeight
    if resize then
        button:SetSize(width, height)
    end
    if db.KeepSizeRatio then
        button.status.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    else
        button.status.icon:SetTexCoord(GW.CropRatio(width, height))
    end
end

local function CreateZoomAnimation(button)
    local group = button:CreateAnimationGroup()
    local alpha = group:CreateAnimation("Alpha")
    alpha:SetDuration(0.25)
    alpha:SetFromAlpha(0.85)
    alpha:SetToAlpha(1)
    local scale = group:CreateAnimation("Scale")
    scale:SetDuration(0.25)
    scale:SetScaleFrom(2.5, 2.5)
    scale:SetScaleTo(1, 1)
    button.agZoomIn = group
end

-- OnLoad of GwAuraSecureTmpl, the secure header creates the buttons from it
function GwAuraSecureTmpl_OnLoad(self)
    if self.gwInit then
        return
    end
    self.gwInit = true
    self.header = self:GetParent()
    self.enchantIndex = tonumber(strmatch(self:GetName(), "TempEnchant(%d)$"))

    self.cooldown:SetDrawBling(false)
    self.cooldown:SetDrawEdge(false)
    self.cooldown:SetHideCountdownNumbers(true)
    CreateZoomAnimation(self)
    ClearTimer(self)
    UpdateIconSize(self)

    self:SetScript("OnAttributeChanged", OnAttributeChanged)
    self:SetScript("OnUpdate", OnUpdate)
    self:SetScript("OnEnter", OnEnter)
    self:SetScript("OnLeave", GameTooltip_Hide)
end

local function UpdateAuraHeader(header)
    if not header then
        return
    end

    local db = GW.settings.playerAuras[header.auraKey]
    local grow = GW.GetAuraGrowDirection(db.GrowDirection)
    local width = db.IconSize
    local height = db.KeepSizeRatio and width or db.IconHeight
    local wrapAfter = (db.WrapAfter and db.WrapAfter >= 1 and db.WrapAfter <= 20) and db.WrapAfter or 7
    local stepX = grow.x * (db.HorizontalSpacing + width)
    local stepY = grow.y * (db.VerticalSpacing + height)
    local sort = SORT[db.Sort] or SORT.DEFAULT

    header:SetAttribute("config-width", width)
    header:SetAttribute("config-height", height)
    header:SetAttribute("template", "GwAuraSecureTmpl")
    header:SetAttribute("weaponTemplate", header.filter == "HELPFUL" and "GwAuraSecureTmpl" or nil)
    header:SetAttribute("sortMethod", sort.method)
    header:SetAttribute("sortDirection", sort.direction)
    header:SetAttribute("separateOwn", db.Seperate)
    header:SetAttribute("wrapAfter", wrapAfter)
    header:SetAttribute("maxWraps", db.MaxWraps)
    header:SetAttribute("point", grow.point)
    -- rows step sideways and wrap up or down, columns the other way round
    if grow.column then
        header:SetAttribute("minWidth", width + 1)
        header:SetAttribute("minHeight", ((wrapAfter == 1 and 0 or db.VerticalSpacing) + height) * wrapAfter)
        header:SetAttribute("xOffset", 0)
        header:SetAttribute("yOffset", stepY)
        header:SetAttribute("wrapXOffset", stepX)
        header:SetAttribute("wrapYOffset", 0)
    else
        header:SetAttribute("minWidth", ((wrapAfter == 1 and 0 or db.HorizontalSpacing) + width) * wrapAfter)
        header:SetAttribute("minHeight", height + 1)
        header:SetAttribute("xOffset", stepX)
        header:SetAttribute("yOffset", 0)
        header:SetAttribute("wrapXOffset", 0)
        header:SetAttribute("wrapYOffset", stepY)
    end
    header:SetAttribute("initialConfigFunction", INITIAL_CONFIG_SNIPPET)

    -- the header does not hide the buttons beyond a smaller maximum on its own
    local maxButtons = db.MaxWraps * wrapAfter
    for index, button in ipairs({header:GetChildren()}) do
        if button.gwInit then
            UpdateIconSize(button, true)
        end
        if index > maxButtons and button:IsShown() then
            button:Hide()
        end
    end

    -- the debuffs follow the buffs until they are moved on their own
    header:ClearAllPoints()
    if header.filter == "HARMFUL" and not header.isMoved then
        header:SetPoint(grow.below, GW2UIPlayerBuffs, grow.below, 0, stepY)
    else
        header:SetPoint(grow.point, header.gwMover, grow.point, 0, 0)
    end
end
GW.UpdateAuraHeader = UpdateAuraHeader

local function CreateHeader(filter)
    local isBuffs = filter == "HELPFUL"
    local header = CreateFrame("Frame", isBuffs and "GW2UIPlayerBuffs" or "GW2UIPlayerDebuffs", UIParent, "SecureAuraHeaderTemplate")
    header.filter = filter
    header.auraKey = isBuffs and "buffs" or "debuffs"
    header:SetClampedToScreen(true)
    -- only the player and the vehicle matter, not every unit
    header:UnregisterEvent("UNIT_AURA")
    header:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
    header:SetAttribute("unit", "player")
    header:SetAttribute("filter", filter)
    RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")

    local visibility = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
    SecureHandlerSetFrameRef(visibility, "AuraHeader", header)
    visibility:SetAttribute("_onstate-customVisibility", VISIBILITY_SNIPPET)
    RegisterStateDriver(visibility, "customVisibility", "[petbattle] 0; 1")

    if isBuffs then
        header:SetAttribute("consolidateDuration", -1)
        header:SetAttribute("consolidateTo", 0)
        header:SetAttribute("includeWeapons", 1)
        GW.RegisterMovableFrame(header, SHOW_BUFFS, "playerAuras.buffs", "Blizzard,Aura", {316, 100}, {GW.MoverOption.Scale}, true)

        -- renewed enchants right away where the client says so, the buttons also look every second
        if C_EventUtils.IsEventValid("WEAPON_ENCHANT_CHANGED") then
            visibility:RegisterEvent("WEAPON_ENCHANT_CHANGED")
            visibility:SetScript("OnEvent", function()
                for _, button in ipairs({header:GetChildren()}) do
                    if button.enchantIndex and button:IsShown() then
                        UpdateTempEnchant(button)
                    end
                end
            end)
        end
    else
        GW.RegisterMovableFrame(header, SHOW_DEBUFFS, "playerAuras.debuffs", "Blizzard,Aura", {316, 60}, {GW.MoverOption.Scale}, true)
    end

    -- keep the header on its mover once it was dragged
    hooksecurefunc(header.gwMover, "StopMovingOrSizing", function()
        if not InCombatLockdown() then
            local point = GW.GetAuraGrowDirection(GW.settings.playerAuras[header.auraKey].GrowDirection).point
            header:ClearAllPoints()
            header:SetPoint(point, header.gwMover, point, 0, 0)
        end
    end)

    UpdateAuraHeader(header)
    header:Show()
    return header
end

function GW.LoadPlayerAuras(lm)
    for _, blizzardFrame in pairs({BuffFrame, TemporaryEnchantFrame, ConsolidatedBuffs, DebuffFrame}) do
        blizzardFrame:GwKill()
    end

    local buffs = CreateHeader("HELPFUL")
    lm:RegisterBuffFrame(buffs)
    lm:RegisterDebuffFrame(CreateHeader("HARMFUL"))

    if PetBattleFrame then
        PetBattleFrame:SetFrameLevel(buffs:GetFrameLevel() + 5)
    end
end
