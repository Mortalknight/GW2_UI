---@class GW2
local GW = select(2, ...)
local GetAddOnRestrictionState = C_RestrictedActions and C_RestrictedActions.GetAddOnRestrictionState

function GW.GetSpellCooldown(spellID)
    if not spellID then return end

    if GetSpellCooldown then
        local startTime, duration, isEnabled, modRate = GetSpellCooldown(spellID)
        return {startTime = startTime, duration = duration, isEnabled = isEnabled, modRate = modRate}
    else
        local info = C_Spell.GetSpellCooldown(spellID)
        if info then
            return info
        end
    end
end

-- add tooltip data api
local function CompatibleTooltip(tt)
    if tt.GetTooltipData then return end

    tt.GetTooltipData = function()
        local info = { name = tt:GetName(), lines = {} }
        info.leftTextName = info.name .. "TextLeft"
        info.rightTextName = info.name .. "TextRight"

        for i = 1, tt:NumLines() do
            local left = _G[info.leftTextName..i]
            local leftText = left and left:GetText() or nil

            local right = _G[info.rightTextName..i]
            local rightText = right and right:GetText() or nil

            tinsert(info.lines, i, { lineIndex = i, leftText = leftText, rightText = rightText })
        end

        return info
    end
end
CompatibleTooltip(GameTooltip)
CompatibleTooltip(GW.ScanTooltip)

function GW.IsSpellKnownOrOverridesKnown(spellID, isPet)
    if C_SpellBook and C_SpellBook.IsSpellInSpellBook then
        local spellBank = isPet and Enum.SpellBookSpellBank.Pet or Enum.SpellBookSpellBank.Player
        local includeOverrides = true
        return C_SpellBook.IsSpellInSpellBook(spellID, spellBank, includeOverrides)
    else
        return IsSpellKnownOrOverridesKnown(spellID, isPet)
    end
end

function GW.IsSpellKnown(spellID, isPet)
    if C_SpellBook and C_SpellBook.IsSpellInSpellBook then
        local spellBank = isPet and Enum.SpellBookSpellBank.Pet or Enum.SpellBookSpellBank.Player
        local includeOverrides = false
        return C_SpellBook.IsSpellInSpellBook(spellID, spellBank, includeOverrides)
    else
        return IsSpellKnown(spellID, isPet)
    end
end

function GW.GetWatchedFactionInfo()
    if C_Reputation and C_Reputation.GetWatchedFactionData then
        return C_Reputation.GetWatchedFactionData()
    else
        local name, standing, min, max, value, factionID = GetWatchedFactionInfo()
        local watchedInfo = {
            factionID = factionID,
            name = name,
            description = "",
            reaction = standing,
            currentReactionThreshold = min,
            nextReactionThreshold = max,
            currentStanding = value,
            atWarWith = false,
            canToggleAtWar = false,
            isChild = false,
            isHeader = false,
            isHeaderWithRep = false,
            isCollapsed = false,
            isWatched = false,
            hasBonusRepGain = false,
            canSetInactive = false,
            isAccountWide = false
        }
        return watchedInfo
    end
end

function GW.IsPlayerSpell(spellID)
    if C_SpellBook and C_SpellBook.IsSpellKnown then
        return C_SpellBook.IsSpellKnown(spellID, Enum.SpellBookSpellBank.Player)
    else
        return IsSpellKnown(spellID)
    end
end

function GW.GetFactionDataByIndex(factionIndex)
    if C_Reputation and C_Reputation.GetFactionDataByIndex then
        return C_Reputation.GetFactionDataByIndex(factionIndex)
    else
        local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canSetInactive = GetFactionInfo(factionIndex)
        local factionData = {
            factionID = factionID,
            name = name,
            description = description,
            reaction = standingID,
            currentReactionThreshold = barMin,
            nextReactionThreshold = barMax,
            currentStanding = barValue,
            atWarWith = atWarWith,
            canToggleAtWar = canToggleAtWar,
            isChild = isChild,
            isHeader = isHeader,
            isHeaderWithRep = hasRep,
            isCollapsed = isCollapsed,
            isWatched = isWatched,
            hasBonusRepGain = hasBonusRepGain,
            canSetInactive = canSetInactive,
            isAccountWide = false
        }

        return factionData
    end
end

function GW.IsFactionActive(factionIndex)
    if C_Reputation and C_Reputation.IsFactionActive then
        return C_Reputation.IsFactionActive(factionIndex)
    else
        return IsFactionInactive(factionIndex) == false
    end
end

function GW.SetFactionActive(factionIndex, active)
    if C_Reputation and C_Reputation.SetFactionActive then
        C_Reputation.SetFactionActive(factionIndex, active)
    else
        if active then
            SetFactionActive(factionIndex)
        else
            SetFactionInactive(factionIndex)
        end
    end
end

function GW.CropRatio(width, height, mult)
    local left, right, top, bottom = 0.05, 0.95, 0.05, 0.95
    if not mult then mult = 0.5 end

    if not height or height == 0 then
        return left, right, top, bottom
    end

    local ratio = width / height
    if ratio > 1 then
        local trimAmount = (1 - (1 / ratio)) * mult
        top = top + trimAmount
        bottom = bottom - trimAmount
    else
        local trimAmount = (1 - ratio) * mult
        left = left + trimAmount
        right = right - trimAmount
    end

    return left, right, top, bottom
end

function GW.GetClassCoords(classFile, crop, get)
    local t = CLASS_ICON_TCOORDS[classFile]
    if not t then return 0, 1, 0, 1 end

    if get then
        return t
    elseif type(crop) == "number" then
        return t[1] + crop, t[2] - crop, t[3] + crop, t[4] - crop
    elseif crop then
        return t[1] + 0.022, t[2] - 0.025, t[3] + 0.022, t[4] - 0.025
    else
        return t[1], t[2], t[3], t[4]
    end
end

local function SetAlphaRecursive(frame, alpha)
    if not frame or not frame.SetAlpha then return end
    frame:SetAlpha(alpha)

    local numChildren = frame:GetNumChildren()
    if numChildren == 0 then
        return
    end

    for _, child in ipairs({frame:GetChildren()}) do
        SetAlphaRecursive(child, alpha)
    end
end
GW.SetAlphaRecursive = SetAlphaRecursive

local function SafeGetParent(obj)
    if type(obj) ~= "table" then
        return nil
    end

    local hasMethod = obj.GetParent and type(obj.GetParent) == "function"
    if hasMethod then
        local ok, parent = pcall(obj.GetParent, obj)
        if ok then
            return parent
        end
    end

    return nil
end
GW.SafeGetParent = SafeGetParent


--Pawn integration
do
    local PawnLoaded = false
    local frame = CreateFrame("Frame")
    local upgradeCache = {}
    local pending = {}
    local limit = 2 / 60 / 4
    local resetInterval = 1 / 8
    local timerResetsAt = 0
    local left = 0
    local lastRefresh = 0

    local function PostRefresh(forceUpdate)
        local now = GetTime()
        if (now - lastRefresh < 0.1) and not forceUpdate then
            return
        end
        lastRefresh = now
        ContainerFrame_UpdateAll()
    end

    local function OnEvent(self, event, ...)
        if event == "ADDON_LOADED" and not PawnLoaded then
            local name = ...
            if name == "Pawn" or C_AddOns.IsAddOnLoaded("Pawn") then
                hooksecurefunc("PawnInvalidateBestItems", PostRefresh)
                hooksecurefunc("PawnResetTooltips", PostRefresh)
                self:UnregisterEvent("ADDON_LOADED")
                PawnLoaded = true
                PostRefresh(true)
            end
        elseif event == "PLAYER_EQUIPMENT_CHANGED" then
            local slot = ...
            if slot >= C_Container.ContainerIDToInventoryID(1) then
                return
            end
            PostRefresh(true)
            upgradeCache = {}
        end
    end

    frame:RegisterEvent("PLAYER_LEVEL_UP")
    frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    frame:RegisterEvent("ADDON_LOADED")
    frame:SetScript("OnEvent", OnEvent)

    local function ShouldPawnShow(itemLink)
        local classID = select(6, C_Item.GetItemInfoInstant(itemLink))
        return PawnLoaded and (classID == Enum.ItemClass.Armor or classID == Enum.ItemClass.Weapon)
    end

    local function GetPawnUpgradeStatus(itemLink)
        if upgradeCache[itemLink] ~= nil then
            return upgradeCache[itemLink]
        end

        local start = GetTimePreciseSec()

        if start >= timerResetsAt then
            timerResetsAt = start + resetInterval
            left = limit
        elseif left <= 0 then
            return nil
        end

        local result = PawnShouldItemLinkHaveUpgradeArrowUnbudgeted(itemLink)
        local elapsed = GetTimePreciseSec() - start

        left = left - elapsed
        if result ~= nil then
            upgradeCache[itemLink] = result
            return result
        end

        if C_Item.IsItemDataCachedByID(itemLink) then
            upgradeCache[itemLink] = false
            return false
        end
        return nil
    end

    local function OnUpdate(self)
        for _, data in pairs(pending) do
            local result = GetPawnUpgradeStatus(data.itemLink)
            if result ~= nil then
                data.button.UpgradeIcon:SetShown(result)
                pending[data.itemLink] = nil
            end
        end

        if next(pending) == nil then
            self:SetScript("OnUpdate", nil)
            PostRefresh()
        end
    end

    function GW.RegisterPawnUpgradeIcon(button, itemLink)
        local result = upgradeCache[itemLink]
        if result ~= nil then
            button.UpgradeIcon:SetShown(result)
        end

        result = ShouldPawnShow(itemLink) and GetPawnUpgradeStatus(itemLink)
        if result == nil then
            pending[itemLink] = {button = button, itemLink = itemLink}
            frame:SetScript("OnUpdate", OnUpdate)
        else
            upgradeCache[itemLink] = result
            button.UpgradeIcon:SetShown(result)
        end
    end
end

function GW.UnitExists(unit)
    if GW.IsSecretUnit(unit) then return end

    return unit and (UnitExists(unit) or UnitIsVisible(unit))
end

function GW.SafeValuesDiffer(a, b)
    if GW.IsSecretValue(a) or GW.IsSecretValue(b) then
        -- Avoid direct comparison on secret values; force a safe "changed" state.
        return true
    end

    return a ~= b
end

function GW.IsNilOrEmptyNonSecretString(value)
    if value == nil then
        return true
    end

    if GW.IsSecretValue(value) then
        return false
    end

    return value == ""
end

function GW.UnitEffectiveLevel(unit)
    if GW.Retail or GW.Mists or GW.Wrath or GW.TBC then
        return UnitEffectiveLevel(unit)
    else
        return UnitLevel(unit)
    end
end

function GW.UnitIsAFK(unit)
    local afk = UnitIsAFK(unit)

    return GW.NotSecretValue(afk) and afk or nil
end

function GW.UnitIsDND(unit)
    local dnd = UnitIsDND(unit)

    return GW.NotSecretValue(dnd) and dnd or nil
end

function GW.CheckRestrictionState(which)
    local enum = Enum.AddOnRestrictionType or {}
    local ok, state = pcall(GetAddOnRestrictionState, enum[which] or which)
    if not ok then return 0 end

    return state
end

function GW.IsPaperDollStatsRestricted()
    return GW.CheckRestrictionState("ChallengeMode") > 1 or GW.CheckRestrictionState("Encounter") > 1 or GW.CheckRestrictionState("Combat") > 1 or GW.CheckRestrictionState("PvPMatch") > 1
end

function GW.IsChatRestricted()
    return C_CVar.GetCVarBool("addonChatRestrictionsForced") or GW.CheckRestrictionState("ChallengeMode") > 1 or GW.CheckRestrictionState("Encounter") > 1 or GW.CheckRestrictionState("PvPMatch") > 1
end

function GW.GetWowheadLinkForLanguage()
    local langShort = string.sub(GW.mylocal, 1, 2) .. "/"
    if langShort == "en/" then
        langShort = ""
    elseif langShort == "zh/" then
        langShort = "cn/"
    end

    local xpac
    if GW.Mists then
        xpac = "mop-classic/"
    elseif GW.Cata then
        xpac = "cata/"
    elseif GW.Wrath then
        xpac = "wotlk/"
    elseif GW.TBC then
        xpac = "tbc/"
    elseif GW.Retail then
        xpac = ""
    else
        xpac = "classic/" -- era/sod/hardcore are all on this URL
    end

    return "https://www.wowhead.com/".. xpac .. langShort
end
