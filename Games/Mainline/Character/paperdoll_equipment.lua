---@class GW2
local GW = select(2, ...)
local PDE = GW.PaperDollEquipment
local SetClassIcon = GW.SetClassIcon
local IsIn = GW.IsIn

local SLOT_BACKGROUND = "Interface/AddOns/GW2_UI/textures/character/slot-bg.png"
local PlayerSlots = {
    ["CharacterHeadSlot"] = {0, 0.25, 0, 0.25},
    ["CharacterNeckSlot"] = {0.25, 0.5, 0, 0.25},
    ["CharacterShoulderSlot"] = {0.5, 0.75, 0.5, 0.75},
    ["CharacterBackSlot"] = {0.75, 1, 0, 0.25},
    ["CharacterChestSlot"] = {0.75, 1, 0.5, 0.75},
    ["CharacterShirtSlot"] = {0.75, 1, 0.5, 0.75},
    ["CharacterTabardSlot"] = {0.25, 0.5, 0.75, 1},
    ["CharacterWristSlot"] = {0.75, 1, 0.25, 0.5},
    ["CharacterHandsSlot"] = {0, 0.25, 0.75, 1},
    ["CharacterWaistSlot"] = {0.25, 0.5, 0.5, 0.75},
    ["CharacterLegsSlot"] = {0, 0.25, 0.5, 0.75},
    ["CharacterFeetSlot"] = {0.5, 0.75, 0.25, 0.5},
    ["CharacterFinger0Slot"] = {0.5, 0.75, 0, 0.25},
    ["CharacterFinger1Slot"] = {0.5, 0.75, 0, 0.25},
    ["CharacterTrinket0Slot"] = {0.5, 0.75, 0.75, 1},
    ["CharacterTrinket1Slot"] = {0.5, 0.75, 0.75, 1},
    ["CharacterMainHandSlot"] = {0.25, 0.5, 0.25, 0.5},
    ["CharacterSecondaryHandSlot"] = {0, 0.25, 0.25, 0.5},
}

local STATS_ICONS = {
    STRENGTH = {l = 0.75, r = 1, t = 0.75, b = 1},
    AGILITY = {l = 0.75, r = 1, t = 0.75, b = 1},
    INTELLECT = {l = 0.75, r = 1, t = 0.75, b = 1},
    STAMINA = {l = 0, r = 0.25, t = 0.25, b = 0.5},
    ARMOR = {l = 0.5, r = 0.75, t = 0, b = 0.25},
    CRITCHANCE = {l = 0.25, r = 0.5, t = 0.25, b = 0.5},
    HASTE = {l = 0, r = 0.25, t = 0.5, b = 0.75},
    MASTERY = {l = 0.75, r = 1, t = 0.25, b = 0.5},
    --Needs icon
    MANAREGEN = {l = 0.75, r = 1, t = 0.25, b = 0.5},
    VERSATILITY = {l = 0.25, r = 0.5, t = 0.5, b = 0.75},
    LIFESTEAL = {l = 0.25, r = 0.5, t = 0.75, b = 1},
    --Needs icon
    AVOIDANCE = {l = 0, r = 0.25, t = 0.75, b = 1},
    --DODGE needs icon
    DODGE = {l = 0.5, r = 0.75, t = 0.5, b = 0.75},
    BLOCK = {l = 0.75, r = 1, t = 0.5, b = 0.75},
    PARRY = {l = 0, r = 0.25, t = 0, b = 0.25},
    MOVESPEED = {l = 0.5, r = 0.75, t = 0.75, b = 1},
}

local PAPERDOLL_STATCATEGORIES = {
    [1] = {
        categoryFrame = "AttributesCategory",
        stats = {
            [1] = {stat = "STRENGTH", primary = LE_UNIT_STAT_STRENGTH},
            [2] = {stat = "AGILITY", primary = LE_UNIT_STAT_AGILITY},
            [3] = {stat = "INTELLECT", primary = LE_UNIT_STAT_INTELLECT},
            [4] = {stat = "STAMINA"},
            [5] = {stat = "ARMOR"},
            [6] = {stat = "MANAREGEN", roles = {"HEALER"}}
        }
    },
    [2] = {
        categoryFrame = "EnhancementsCategory",
        stats = {
            [1] = {stat = "CRITCHANCE", hideAt = 0},
            [2] = {stat = "HASTE", hideAt = 0},
            [3] = {stat = "MASTERY", hideAt = 0},
            [4] = {stat = "VERSATILITY", hideAt = 0},
            [5] = {stat = "DODGE"},
            [6] = {stat = "PARRY", hideAt = 0},
            [7] = {stat = "BLOCK", hideAt = 0},
            [8] = {stat = "AVOIDANCE", hideAt = 0},
            [9] = {stat = "LIFESTEAL", hideAt = 0},
            [10] = {stat = "MOVESPEED", hideAt = 0}
        }
    }
}

---------- azerite and corruption ----------

local function UpdateAzeriteItem(self)
    if not self.styled then
        self.styled = true

        self.AzeriteTexture:SetAlpha(0)
        self.RankFrame.Texture:SetTexture()
        self.RankFrame.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
    end
end

local function UpdateAzeriteEmpoweredItem(self)
    self.AzeriteTexture:SetAtlas("AzeriteIconFrame")
    self.AzeriteTexture:ClearAllPoints()
    self.AzeriteTexture:SetPoint("TOPLEFT", self.AzeriteTexture:GetParent(), "TOPLEFT", 2, -2)
    self.AzeriteTexture:SetPoint("BOTTOMRIGHT", self.AzeriteTexture:GetParent(), "BOTTOMRIGHT", -2, 2)
    self.AzeriteTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.AzeriteTexture:SetDrawLayer("BORDER", 1)
end

local function CorruptionIcon(self)
    local itemLink = GetInventoryItemLink("player", self:GetID())
    self.IconOverlay:SetShown(itemLink and C_Item.IsCorruptedItem(itemLink))
end

local function SetupCorruptionOverlay(button)
    button.IconOverlay:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    button.IconOverlay:SetAllPoints(button)
    button.IconOverlay:SetAtlas("Nzoth-inventory-icon")
    button.IconOverlay:ClearAllPoints()
    button.IconOverlay:SetPoint("TOPLEFT", button.IconOverlay:GetParent(), "TOPLEFT", 1, -1)
    button.IconOverlay:SetPoint("BOTTOMRIGHT", button.IconOverlay:GetParent(), "BOTTOMRIGHT", -1, 1)
end

local function StyleBagItem(button)
    SetupCorruptionOverlay(button)
    UpdateAzeriteEmpoweredItem(button)
    UpdateAzeriteItem(button)
end

local function OnBagItemUpdated(button)
    button:ResetAzeriteItem()
    button.IconOverlay:SetShown(button.itemId and C_Item.IsCorruptedItem(button.itemId))
end

local function OnGrabSlot(slot)
    SetupCorruptionOverlay(slot)
    hooksecurefunc(slot, "DisplayAsAzeriteItem", UpdateAzeriteItem)
    hooksecurefunc(slot, "DisplayAsAzeriteEmpoweredItem", UpdateAzeriteEmpoweredItem)
    slot:HookScript("OnShow", CorruptionIcon)
    slot:HookScript("OnEvent", CorruptionIcon)
end

---------- mythic+ rating ----------

local dungeonScoreRows = {}

local function dungeonScore_OnEnter(self)
    local score = C_ChallengeMode.GetOverallDungeonScore() or 0
    local color = C_ChallengeMode.GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(DUNGEON_SCORE, 1, 1, 1)
    GameTooltip:AddLine(DUNGEON_SCORE_TOTAL_SCORE:format(color:WrapTextInColorCode(score)), 1, 1, 1)

    -- season best per dungeon, best score first
    wipe(dungeonScoreRows)
    for _, mapID in ipairs(C_ChallengeMode.GetMapTable() or {}) do
        local name = C_ChallengeMode.GetMapUIInfo(mapID)
        local affixScores, mapScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID)
        local best
        for _, affixScore in ipairs(affixScores or {}) do
            if not best or affixScore.score > best.score then
                best = affixScore
            end
        end
        tinsert(dungeonScoreRows, {
            name = name or UNKNOWN,
            score = mapScore or 0,
            level = best and best.level or 0,
            overTime = best and best.overTime,
        })
    end
    sort(dungeonScoreRows, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        return a.name < b.name
    end)

    if #dungeonScoreRows > 0 then
        GameTooltip:AddLine(" ")
    end
    for _, row in ipairs(dungeonScoreRows) do
        if row.score > 0 then
            local levelColor = row.overTime and LIGHTGRAY_FONT_COLOR or C_ChallengeMode.GetKeystoneLevelRarityColor(row.level) or HIGHLIGHT_FONT_COLOR
            local scoreColor = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(row.score) or HIGHLIGHT_FONT_COLOR
            GameTooltip:AddDoubleLine(row.name, levelColor:WrapTextInColorCode("+" .. row.level) .. "  " .. scoreColor:WrapTextInColorCode(row.score), 1, 1, 1)
        else
            GameTooltip:AddDoubleLine(row.name, "-", 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
        end
    end
    GameTooltip:Show()
end

---------- stats ----------

local function setStatIcon(self, stat)
    local newTexture = "Interface/AddOns/GW2_UI/textures/character/statsicon.png"
    if STATS_ICONS[stat] then
        -- If mastery we use need to use class icon
        if stat == "MASTERY" then
            SetClassIcon(self.icon, GW.myClassID)
            newTexture = "Interface/AddOns/GW2_UI/textures/party/classicons.png"
        else
            self.icon:SetTexCoord(STATS_ICONS[stat].l, STATS_ICONS[stat].r, STATS_ICONS[stat].t, STATS_ICONS[stat].b)
        end
    end

    if newTexture ~= self.icon:GetTexture() then
        self.icon:SetTexture(newTexture)
    end
end

local function updateStats(self)
    PDE.UpdateItemLevel(self)

    local primaryStat = select(6, C_SpecializationInfo.GetSpecializationInfo(GW.myspec, nil, nil, nil, GW.mysex))

    if InCombatLockdown() or GW.IsPaperDollStatsRestricted() then
        GW.CombatQueue:Queue("update character stats", updateStats, {self})
        return
    end
    self.statsFramePool:ReleaseAll()

    -- tiles are collected first and placed by the stats picker afterwards
    local editMode = GW.StatsPicker.IsEditMode(self.stats)
    local entries = {}

    PDE.AddSetBonusTile(self, entries, editMode)

    local dungeonScore = C_ChallengeMode.GetOverallDungeonScore() or 0
    if dungeonScore > 0 then
        local color = C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore) or HIGHLIGHT_FONT_COLOR
        PDE.AddSpecialTile(self, entries, editMode, "DUNGEONSCORE", "M+", dungeonScore, color, dungeonScore_OnEnter)
    elseif editMode then
        PDE.AddSpecialTile(self, entries, editMode, "DUNGEONSCORE", "M+", "-", GRAY_FONT_COLOR, dungeonScore_OnEnter)
    end

    for _, category in ipairs(PAPERDOLL_STATCATEGORIES) do
        for _, stat in ipairs(category.stats) do
            local showStat = true
            if stat.primary and stat.primary ~= primaryStat then
                showStat = false
            end
            if showStat and stat.roles then
                showStat = tContains(stat.roles, GW.myrole)
            end

            local frame = PDE.GetStatListFrame(self)
            PAPERDOLL_STATINFO[stat.stat].updateFunc(frame, "player")

            -- edit mode shows every stat of the spec, hidden ones dimmed by the layout
            local visible = GW.StatsPicker.IsVisible(stat.stat, not stat.hideAt or stat.hideAt ~= frame.numericValue)
            if showStat and (visible or editMode) then
                frame.stat = stat.stat
                frame.gwStatVisible = visible
                setStatIcon(frame, stat.stat)
                tinsert(entries, frame)
            else
                self.statsFramePool:Release(frame)
            end
        end
    end

    PDE.AddDurabilityTile(self, entries)

    -- 301 is the box size from the xml, it grows when the edit mode shows every stat
    GW.StatsPicker.Layout(self.stats, entries, 35, 301)
end
GW.UpdateCharacterStats = function()
    if GwDressingRoom then
        updateStats(GwDressingRoom)
    end
end

local function stats_QueuedUpdate(self)
    self:SetScript("OnUpdate", nil)
    updateStats(self:GetParent())
end

local function updateUnitData(self)
    self.characterName:SetText(UnitPVPName("player"))
    local name = select(2, C_SpecializationInfo.GetSpecializationInfo(GW.myspec, false, false, nil, GW.mysex))

    if name ~= nil then
        local data = LEVEL .. " " .. GW.mylevel .. " " .. name .. " " .. GW.myLocalizedClass
        self.characterData:SetWidth(180)
        self.characterData:SetText(data)
    end
end

local function stats_OnEvent(self, event, ...)
    local unit = ...
    local parent = self:GetParent()
    if (IsIn(event, "UNIT_MODEL_CHANGED", "UNIT_NAME_UPDATE") and unit == "player") or event == "PLAYER_ENTERING_WORLD" then
        parent.model:SetUnit("player", false)
        updateUnitData(parent)
        return
    end

    if not GW.inWorld then
        return
    end

    if unit == "player" then
        if event == "UNIT_LEVEL" then
            updateUnitData(parent)
        elseif IsIn(event, "UNIT_DAMAGE", "UNIT_ATTACK_SPEED", "UNIT_RANGEDDAMAGE", "UNIT_ATTACK", "UNIT_STATS", "UNIT_RANGED_ATTACK_POWER", "UNIT_SPELL_HASTE",
                "UNIT_MAXHEALTH", "UNIT_AURA", "UNIT_RESISTANCES", "SPEED_UPDATE") then
            self:SetScript("OnUpdate", stats_QueuedUpdate)
        end
    end
    if IsIn(event,"COMBAT_RATING_UPDATE", "MASTERY_UPDATE", "SPEED_UPDATE", "LIFESTEAL_UPDATE", "AVOIDANCE_UPDATE", "BAG_UPDATE", "PLAYER_EQUIPMENT_CHANGED",
            "PLAYERBANKSLOTS_CHANGED", "PLAYER_AVG_ITEM_LEVEL_UPDATE", "PLAYER_DAMAGE_DONE_MODS", "CHALLENGE_MODE_MAPS_UPDATE") then
        self:SetScript("OnUpdate", stats_QueuedUpdate)
    elseif (event == "PLAYER_TALENT_UPDATE") then
        updateUnitData(parent)
        self:SetScript("OnUpdate", stats_QueuedUpdate)
    elseif event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "COLOR_OVERRIDES_RESET" or event == "COLOR_OVERRIDE_UPDATED" then
        updateStats(parent)
    elseif (event == "SPELL_POWER_CHANGED") then
        self:SetScript("OnUpdate", stats_QueuedUpdate)
    end
end

local function RegisterStatsEvents(frame)
    local events = {
        "PLAYER_ENTERING_WORLD",
        "CHARACTER_POINTS_CHANGED",
        "UNIT_MODEL_CHANGED",
        "UNIT_LEVEL",
        "UNIT_STATS",
        "UNIT_RANGEDDAMAGE",
        "UNIT_ATTACK_POWER",
        "UNIT_RANGED_ATTACK_POWER",
        "UNIT_ATTACK",
        "UNIT_SPELL_HASTE",
        "UNIT_RESISTANCES",
        "PLAYER_GUILD_UPDATE",
        "SKILL_LINES_CHANGED",
        "COMBAT_RATING_UPDATE",
        "MASTERY_UPDATE",
        "SPEED_UPDATE",
        "LIFESTEAL_UPDATE",
        "AVOIDANCE_UPDATE",
        "KNOWN_TITLES_UPDATE",
        "UNIT_NAME_UPDATE",
        "PLAYER_TALENT_UPDATE",
        "BAG_UPDATE",
        "PLAYER_EQUIPMENT_CHANGED",
        "PLAYERBANKSLOTS_CHANGED",
        "PLAYER_AVG_ITEM_LEVEL_UPDATE",
        "PLAYER_DAMAGE_DONE_MODS",
        "ACTIVE_TALENT_GROUP_CHANGED",
        "COLOR_OVERRIDES_RESET",
        "COLOR_OVERRIDE_UPDATED",
        "SPELL_POWER_CHANGED",
        "CHARACTER_ITEM_FIXUP_NOTIFICATION",
        "CHALLENGE_MODE_MAPS_UPDATE",
    }

    for _, event in ipairs(events) do
        frame:RegisterEvent(event)
    end
    frame:RegisterUnitEvent("UNIT_DAMAGE", "player")
    frame:RegisterUnitEvent("UNIT_ATTACK_SPEED", "player")
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    frame:RegisterUnitEvent("UNIT_AURA", "player")
end

local function CharacterSlots(dressingRoom)
    return {
        -- Format: {SlotFrame, AnchorParent, AnchorPoint, RelativePoint, XOffset, YOffset, Size}
        {CharacterHeadSlot,      dressingRoom.gear,         "TOPLEFT", "TOPLEFT",    0,  0, 50},
        {CharacterShoulderSlot,  CharacterHeadSlot,         "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterChestSlot,     CharacterShoulderSlot,     "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterWristSlot,     CharacterChestSlot,        "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterHandsSlot,     CharacterWristSlot,        "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterWaistSlot,     CharacterHandsSlot,        "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterLegsSlot,      CharacterWaistSlot,        "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterFeetSlot,      CharacterLegsSlot,         "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterMainHandSlot,  CharacterFeetSlot,         "TOPLEFT", "BOTTOMLEFT", 0, -20, 50},
        {CharacterSecondaryHandSlot, CharacterMainHandSlot, "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},

        {CharacterTabardSlot,    dressingRoom.stats,    "TOPRIGHT", "BOTTOMRIGHT", -5, -20, 40},
        {CharacterShirtSlot,     CharacterTabardSlot,   "TOPRIGHT", "BOTTOMRIGHT",  0, -5, 40},
        {CharacterTrinket0Slot,  CharacterTabardSlot,   "TOPRIGHT", "TOPLEFT",     -5, 0, 40},
        {CharacterTrinket1Slot,  CharacterTrinket0Slot, "TOPRIGHT", "BOTTOMRIGHT",  0, -5, 40},
        {CharacterFinger0Slot,   CharacterTrinket0Slot, "TOPRIGHT", "TOPLEFT",     -5, 0, 40},
        {CharacterFinger1Slot,   CharacterFinger0Slot,  "TOPRIGHT", "BOTTOMRIGHT",  0, -5, 40},
        {CharacterNeckSlot,      CharacterFinger0Slot,  "TOPRIGHT", "TOPLEFT",     -5, 0, 40},
        {CharacterBackSlot,      CharacterNeckSlot,     "TOPRIGHT", "BOTTOMRIGHT",  0, -5, 40},
    }
end

local function LoadPDBagList(fmMenu, parent)
    local fmGDR, fmGPDBIL = PDE.CreateBagList(fmMenu, parent, {
        characterSlots = CharacterSlots,
        slotBackground = SLOT_BACKGROUND,
        playerSlots = PlayerSlots,
        updateStats = updateStats,
        updateUnitData = updateUnitData,
        onGrabSlot = OnGrabSlot,
        styleBagItem = StyleBagItem,
        onBagItemUpdated = OnBagItemUpdated,
    })

    fmGDR.stats:SetScript("OnEvent", stats_OnEvent)
    RegisterStatsEvents(fmGDR.stats)

    -- the mythic+ rating tile needs the season map data, it arrives via CHALLENGE_MODE_MAPS_UPDATE
    fmGDR:HookScript("OnShow", function() C_MythicPlus.RequestMapInfo() end)

    return fmGDR, fmGPDBIL
end
GW.LoadPDBagList = LoadPDBagList
