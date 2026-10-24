---@class GW2
local GW = select(2, ...)
local GetAddOnRestrictionState = C_RestrictedActions and C_RestrictedActions.GetAddOnRestrictionState
local UnregisterInternalEvent = GameEvent and GameEvent.UnregisterInternalEvent

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

-- nil guard: on a client without LE_QUEST_FREQUENCY_WEEKLY a nil frequency would match
function GW.IsRepeatableQuestFrequency(frequency)
    return frequency ~= nil and (frequency == LE_QUEST_FREQUENCY_DAILY or frequency == LE_QUEST_FREQUENCY_WEEKLY)
end

function GW.GetFactionDataByIndex(factionIndex)
    if C_Reputation and C_Reputation.GetFactionDataByIndex then
        return C_Reputation.GetFactionDataByIndex(factionIndex)
    else
        local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain = GetFactionInfo(factionIndex)
        -- the legacy API has no canSetInactive (the 16th value is canBeLFGBonus on the classic
        -- clients); Blizzards classic reputation frame offers "Move to Inactive" for every faction
        -- that has a detail view, so mirror that
        local canSetInactive = not isHeader or hasRep
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

-- the class icon coords, crop trims the round border a little
function GW.GetClassCoords(classFile, crop)
    local coords = CLASS_ICON_TCOORDS[classFile]
    if not coords then
        return 0, 1, 0, 1
    end
    local left, right, top, bottom = unpack(coords)
    if crop then
        return left + 0.022, right - 0.025, top + 0.022, bottom - 0.025
    end
    return left, right, top, bottom
end

local function SetAlphaRecursive(frame, alpha)
    if not frame or not frame.SetAlpha then return end
    if frame.IsForbidden and frame:IsForbidden() then return end
    frame:SetAlpha(alpha)

    if frame.gwSkipAlphaRecursion or (frame.GetObjectType and frame:GetObjectType() == "AuraContainer") then
        return
    end

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
        GW.UpdateAllOwnBagItemButtons()
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
function GW.IsRestrictedAuras()
    return GW.IsRestrictedChallengeMode() or GW.IsRestrictedEncounter() or GW.IsRestrictedCombat() or GW.IsRestrictedPvPMatch()
end

function GW.IsRestrictedInstance()
    return GW.IsRestrictedChallengeMode() or GW.IsRestrictedEncounter()
end

function GW.IsRestrictedPvPMatch()
    return C_CVar.GetCVarBool("addonPvPMatchRestrictionsForced") or GW.CheckRestrictionState("PvPMatch") > 1
end

function GW.IsRestrictedCombat()
    return C_CVar.GetCVarBool("addonCombatRestrictionsForced") or GW.CheckRestrictionState("Combat") > 1
end

function GW.IsRestrictedEncounter()
    return C_CVar.GetCVarBool("addonEncounterRestrictionsForced") or GW.CheckRestrictionState("Encounter") > 1
end

function GW.IsRestrictedChallengeMode()
    return C_CVar.GetCVarBool("addonChallengeModeRestrictionsForced") or GW.CheckRestrictionState("ChallengeMode") > 1
end

function GW.IsRestrictedMap()
    return C_CVar.GetCVarBool("addonMapRestrictionsForced") or GW.CheckRestrictionState("Map") > 1
end

function GW.IsChatRestricted()
    return C_CVar.GetCVarBool("addonChatRestrictionsForced") or GW.CheckRestrictionState("Chat") > 1
end

function GW.UnregisterGameEvent(event)
    if UnregisterInternalEvent then
        UnregisterInternalEvent(event)
    else
        UIParent:UnregisterEvent(event)
    end
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
    elseif GW.Forever then
        xpac = "forever/"
    else
        xpac = "classic/" -- era/sod/hardcore are all on this URL
    end

    return "https://www.wowhead.com/".. xpac .. langShort
end

local function CanChangePanels()
    if InCombatLockdown() then
        UIErrorsFrame:AddExternalErrorMessage(ERR_NOT_IN_COMBAT)
        return false
    end
    return true
end

function GW.ShowQuestLogEntry(questLogIndex, toggle)
    if not CanChangePanels() then return end
    if toggle and QuestLogFrame:IsShown() and QuestLogFrame.selectedButtonID == questLogIndex then
        HideUIPanel(QuestLogFrame)
        return
    end
    ShowUIPanel(QuestLogFrame)
    QuestLog_SetSelection(questLogIndex)
    QuestLog_Update()
end

-- the classic quest log abandons its selected entry, like blizzards WatchFrame_AbandonQuest
function GW.AbandonQuestLogEntry(questID)
    local questLogIndex = GetQuestLogIndexByID(questID)
    if not questLogIndex or questLogIndex == 0 or not CanAbandonQuest(questID) then return end

    local lastSelection = GetQuestLogSelection()
    SelectQuestLogEntry(questLogIndex)
    SetAbandonQuest()
    local items = GetAbandonQuestItems()
    if items then
        StaticPopup_Hide("ABANDON_QUEST")
        StaticPopup_Show("ABANDON_QUEST_WITH_ITEMS", GetAbandonQuestName(), items)
    else
        StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS")
        StaticPopup_Show("ABANDON_QUEST", GetAbandonQuestName())
    end
    SelectQuestLogEntry(lastSelection)
end

function GW.ShowQuestDetails(questID)
    if not CanChangePanels() then return end
    QuestMapFrame_OpenToQuestDetails(questID)
end

function GW.GetQuestRewardXP(questID)
    if not GW.settings.objectives.showXp or GW.mylevel >= GetMaxPlayerLevel() then return end
    local xp
    if GW.isModern then
        xp = GetQuestLogRewardXP(questID)
    else
        -- the classic clients ignore the questID and read the selected quest log entry
        local questLogIndex = GetQuestLogIndexByID(questID)
        if not questLogIndex or questLogIndex == 0 then return end
        local selected = GetQuestLogSelection()
        SelectQuestLogEntry(questLogIndex)
        xp = GetQuestLogRewardXP()
        SelectQuestLogEntry(selected)
    end
    if xp and xp > 0 then
        return xp
    end
end

function GW.IsSpellOnBars(spellID)
    local slots = C_ActionBar.FindSpellActionButtons(C_SpellBook.FindBaseSpellByID(spellID) or spellID)
    return slots ~= nil and #slots > 0
end

local function CreateBadgePart(button, size, subLevel, color, point, x)
    local texture = button:CreateTexture(nil, "OVERLAY", nil, subLevel)
    texture:SetSize(size, size)
    texture:SetPoint("CENTER", button, point, x, -3)
    texture:SetColorTexture(color:GetRGB())
    local mask = button:CreateMaskTexture()
    mask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(texture)
    texture:AddMaskTexture(mask)
    texture:Hide()
    return texture
end

function GW.CreateSpellBadges(button)
    button.unboundRing = CreateBadgePart(button, 13, 6, GW.Colors.Fallback, "TOPRIGHT", -3)
    button.unbound = CreateBadgePart(button, 9, 7, GW.Colors.SkinColors.QuestGold, "TOPRIGHT", -3)
    button.offGcdRing = CreateBadgePart(button, 15, 6, GW.Colors.Fallback, "TOPLEFT", 3)
    button.gwOffGcd = button:CreateTexture(nil, "OVERLAY", nil, 7)
    button.gwOffGcd:SetTexture("Interface/AddOns/GW2_UI/textures/icons/clock.png")
    button.gwOffGcd:SetSize(11, 11)
    button.gwOffGcd:SetPoint("CENTER", button.offGcdRing)
    button.gwOffGcd:Hide()
end

function GW.UpdateSpellBadges(button, unbound, offGcd)
    local settings = GW.settings.windows.spellbook
    button.isUnbound = settings.markUnbound and unbound or false
    button.unbound:SetShown(button.isUnbound)
    button.unboundRing:SetShown(button.isUnbound)
    offGcd = settings.markOffGcd and offGcd or false
    button.gwOffGcd:SetShown(offGcd)
    button.offGcdRing:SetShown(offGcd)
end

function GW.UpdateTalentBadges(button)
    local unbound = button.gwBarSpellID ~= nil and GW.settings.windows.spellbook.markUnbound and not GW.IsSpellOnBars(button.gwBarSpellID)
    GW.UpdateSpellBadges(button, unbound, button.isOffGcd)
end

function GW.IsOffGcdSpell(spellID, isPassive)
    if not spellID or spellID <= 0 or not GetSpellBaseCooldown then
        return false
    end
    if isPassive == nil then
        isPassive = C_Spell.IsSpellPassive(spellID)
    end
    if isPassive then
        return false
    end
    local _, gcd = GetSpellBaseCooldown(spellID)
    return gcd == 0
end

function GW.AddSpellBadgeTooltipLines(button)
    if button.gwOffGcd and button.gwOffGcd:IsShown() then
        GameTooltip:AddLine(GW.L["Not on the global cooldown"], GW.Colors.TextColors.LightHeader:GetRGB())
    end
    if button.isUnbound then
        GameTooltip:AddLine(SPELLBOOK_SPELL_NOT_ON_ACTION_BAR or GW.L["Not on any action bar"], GW.Colors.SkinColors.QuestGold:GetRGB())
    end
end

-- the tag text from GetQuestLogTitle is translated, the tag id is not
function GW.GetQuestTagID(questID)
    if C_QuestLog.GetQuestTagInfo then
        local info = C_QuestLog.GetQuestTagInfo(questID)
        return info and info.tagID
    end
    return (GetQuestTagInfo(questID))
end

function GW.GetQuestLevelPrefix(level, tagID)
    if tagID == Enum.QuestTag.Group then
        return "[" .. level .. "|TInterface/AddOns/GW2_UI/textures/icons/quest-group-icon.png:12:12:0:0|t] "
    elseif tagID == Enum.QuestTag.Dungeon then
        return "[" .. level .. "|TInterface/AddOns/GW2_UI/textures/icons/quest-dungeon-icon.png:12:12:0:0|t] "
    elseif tagID then
        return "[" .. level .. "+] "
    end
    return "[" .. level .. "] "
end

-- the quest log groups the quests under zone headers, sort by those and then by level
function GW.SortQuestsByZone(quests)
    local zoneByIndex, zone = {}, ""
    for i = 1, GetNumQuestLogEntries() do
        local title, _, _, isHeader = GetQuestLogTitle(i)
        if isHeader then
            zone = title or ""
        else
            zoneByIndex[i] = zone
        end
    end
    table.sort(quests, function(a, b)
        local zoneA, zoneB = zoneByIndex[a.questLogIndex] or "", zoneByIndex[b.questLogIndex] or ""
        if zoneA == zoneB then
            return a.questLevel < b.questLevel
        end
        return zoneA < zoneB
    end)
end

-- our popup with the wowhead link of a quest, achievement, ...; questie's own popup only exists with questie
function GW.ShowWowheadUrlPopup(linkType, id)
    GW.ShowPopup({text = GW.L["Wowhead URL"],
        hasEditBox = true,
        hideOnEscape = true,
        EditBoxOnEnterPressed = function(popup) popup:Hide() end,
        EditBoxOnEscapePressed = function(popup) popup:Hide() end,
        button2 = CLOSE,
        inputText = GW.GetWowheadLinkForLanguage() .. linkType .. "=" .. id,
    })
end

-- our own quest objects with the fields and methods of blizzards QuestCache: what we put into the shared
-- QuestCache counts as tainted, and blizzards tracker reads it back during PLAYER_ENTERING_WORLD
do
    local QuestObject = {}

    function QuestObject:GetID()
        return self.questID
    end

    function QuestObject:GetQuestLogIndex()
        return C_QuestLog.GetLogIndexForQuestID(self.questID)
    end

    function QuestObject:IsComplete()
        return C_QuestLog.IsComplete(self.questID)
    end

    function QuestObject:IsOnMap()
        return C_QuestLog.IsOnMap(self.questID)
    end

    function QuestObject:IsCampaign()
        if self.campaignID == nil then
            self.campaignID = C_CampaignInfo.GetCampaignID(self.questID)
        end
        return self.campaignID ~= 0
    end

    -- the log info only exists while the quest is in the log, it is read until it was there once
    function QuestObject:Refresh()
        if self.hasQuestLogInfo then return end
        local questLogIndex = C_QuestLog.GetLogIndexForQuestID(self.questID)
        local info = questLogIndex and C_QuestLog.GetInfo(questLogIndex)
        if info then
            self.hasQuestLogInfo = true
            Mixin(self, info)
            -- dynamic data that would go stale, like blizzard drops it
            self.questLogIndex, self.isOnMap, self.isCollapsed, self.hasLocalPOI = nil, nil, nil, nil
        end
    end

    local objects = {}
    GW.QuestCache = {
        Get = function(_, questID)
            local quest = objects[questID]
            if not quest then
                quest = CreateFromMixins(QuestObject)
                quest.questID = questID
                quest.title = ""
                quest.requiredMoney = C_QuestLog.GetRequiredMoney(questID) or 0
                objects[questID] = quest
            end
            quest:Refresh()
            return quest
        end,
    }
end

-- ItemMixin:ContinueOnItemLoad with our own listener: blizzards ItemEventListener is shared, what we put
-- into it counts as tainted once blizzard requests the same item
do
    local pending = {}
    local listener = CreateFrame("Frame")
    listener:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    listener:SetScript("OnEvent", function(_, _, itemID)
        local callbacks = pending[itemID]
        if not callbacks then return end
        pending[itemID] = nil
        for _, callback in ipairs(callbacks) do
            xpcall(callback, geterrorhandler())
        end
    end)

    function GW.ContinueOnItemLoad(item, callback)
        if item:IsItemEmpty() then return end
        if item:IsItemDataCached() then
            callback()
            return
        end
        local itemID = item:GetItemID()
        if pending[itemID] then
            tinsert(pending[itemID], callback)
            return
        end
        -- the load result can fire right inside the request, so the callback is in place before it
        pending[itemID] = {callback}
        C_Item.RequestLoadItemDataByID(itemID)
    end
end

