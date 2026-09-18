---@class GW2
local GW = select(2, ...)
local PDE = GW.PaperDollEquipment

local SLOT_BACKGROUND = "Interface/AddOns/GW2_UI/textures/character/slot-bg-classic.png"
local PlayerSlots = {
    CharacterHeadSlot = {0, 0.25, 0, 0.125},
    CharacterNeckSlot = {0.25, 0.5, 0, 0.125},
    CharacterShoulderSlot = {0.5, 0.75, 0.25, 0.375},
    CharacterBackSlot = {0.75, 1, 0, 0.125},
    CharacterChestSlot = {0.75, 1, 0.25, 0.375},
    CharacterShirtSlot = {0.75, 1, 0.25, 0.375},
    CharacterTabardSlot = {0.25, 0.5, 0.375, 0.5},
    CharacterWristSlot = {0.75, 1, 0.125, 0.25},
    CharacterHandsSlot = {0, 0.25, 0.375, 0.5},
    CharacterWaistSlot = {0.25, 0.5, 0.25, 0.375},
    CharacterLegsSlot = {0, 0.25, 0.25, 0.375},
    CharacterFeetSlot = {0.5, 0.75, 0.125, 0.25},
    CharacterFinger0Slot = {0.5, 0.75, 0, 0.125},
    CharacterFinger1Slot = {0.5, 0.75, 0, 0.125},
    CharacterTrinket0Slot = {0.5, 0.75, 0.375, 0.5},
    CharacterTrinket1Slot = {0.5, 0.75, 0.375, 0.5},
    CharacterMainHandSlot = {0.25, 0.5, 0.125, 0.25},
    CharacterSecondaryHandSlot = {0, 0.25, 0.125, 0.25},
    CharacterRangedSlot = {0, 0.25, 0.5, 0.625},
    CharacterAmmoSlot = {0.75, 1, 0.375, 0.5},
}
local RELIC_SLOT_COORDS = {0.25, 0.5, 0.5, 0.625}

local STATS_ICON_TEXTURE = "Interface/AddOns/GW2_UI/textures/character/statsicon-classic.png"
local statsIconsSprite = {width = 256, height = 512, colums = 4, rows = 8}
local STATS_ICONS = {
    STRENGTH = {x = 1, y = 5},
    AGILITY = {x = 2, y = 5},
    INTELLECT = {x = 3, y = 5},
    SPIRIT = {x = 4, y = 2},
    STAMINA = {x = 1, y = 2},
    HEALTH = {x = 1, y = 2},
    POWER = {x = 4, y = 2},
    ARMOR = {x = 3, y = 1},
    ARMORPEN = {x = 3, y = 1},
    CRITCHANCE = {x = 2, y = 2},
    HASTE = {x = 1, y = 3},
    HITCHANCE = {x = 4, y = 5},
    EXPERTISE = {x = 4, y = 5},
    SPELLPOWER = {x = 2, y = 3},
    SPELLHEALING = {x = 2, y = 4},
    SPELLPENETRATION = {x = 4, y = 1},
    DODGE = {x = 3, y = 3},
    DEFENSE = {x = 4, y = 3},
    PARRY = {x = 1, y = 1},
    BLOCK = {x = 1, y = 1},
    MOVESPEED = {x = 3, y = 2},
    MAINHAND_DAMAGE = {x = 4, y = 4},
    OFFHAND_DAMAGE = {x = 4, y = 4},
    ATTACK_AP = {x = 1, y = 6},
    RANGED_DAMAGE = {x = 3, y = 6},
    RANGED_ATTACK_AP = {x = 4, y = 6},
    HOLY_RESIST = {x = 1, y = 7},
    FIRE_RESIST = {x = 2, y = 7},
    NATURE_RESIST = {x = 3, y = 7},
    FROST_RESIST = {x = 4, y = 7},
    SHADOW_RESIST = {x = 1, y = 8},
    ARCANE_RESIST = {x = 2, y = 8},
}
local RESISTANCE_STATS = {"ARCANE_RESIST", "FIRE_RESIST", "FROST_RESIST", "NATURE_RESIST", "SHADOW_RESIST"}

-- the shared item button template still carries the azerite overlay, no such items exist here
local function HideAzeriteOverlay(button)
    if button.ResetAzeriteItem then
        button:ResetAzeriteItem()
    end
    if button.AzeriteTexture then
        button.AzeriteTexture:SetAlpha(0)
    end
    if button.AvailableTraitFrame then
        button.AvailableTraitFrame:Hide()
    end
    if button.IconOverlay then
        button.IconOverlay:Hide()
    end
    if not button.gwAzeriteHooked and button.DisplayAsAzeriteItem then
        hooksecurefunc(button, "DisplayAsAzeriteItem", HideAzeriteOverlay)
        hooksecurefunc(button, "DisplayAsAzeriteEmpoweredItem", HideAzeriteOverlay)
        button.gwAzeriteHooked = true
    end
end

-- Camelot builds the stat tooltip key from the localized stat name, which only resolves on English clients
local STAT_TOOLTIP_KEYS = {
    [LE_UNIT_STAT_STRENGTH or 1] = "STRENGTH",
    [LE_UNIT_STAT_AGILITY or 2] = "AGILITY",
    [LE_UNIT_STAT_STAMINA or 3] = "STAMINA",
    [LE_UNIT_STAT_INTELLECT or 4] = "INTELLECT",
    [LE_UNIT_STAT_SPIRIT or 5] = "SPIRIT",
}

local function MirrorStatTooltipStrings()
    local _, classFileName = UnitClass("player")
    for statIndex, englishName in pairs(STAT_TOOLTIP_KEYS) do
        local localizedName = _G["SPELL_STAT" .. statIndex .. "_NAME"]
        if localizedName then
            for _, prefix in ipairs({strupper(classFileName), "DEFAULT"}) do
                local localizedKey = prefix .. "_" .. strupper(localizedName) .. "_TOOLTIP"
                local englishKey = prefix .. "_" .. englishName .. "_TOOLTIP"
                if _G[localizedKey] == nil and _G[englishKey] then
                    _G[localizedKey] = _G[englishKey]
                end
            end
        end
    end
end

---------- stats ----------

local function setStatIcon(self, stat)
    local sprite = STATS_ICONS[stat]
    if sprite then
        self.icon:SetTexCoord(GW.getSprite(statsIconsSprite, sprite.x, sprite.y))
    else
        self.icon:SetTexCoord(0, 0.25, 0, 0.125)
    end
    if self.icon:GetTexture() ~= STATS_ICON_TEXTURE then
        self.icon:SetTexture(STATS_ICON_TEXTURE)
    end
    self.icon:SetDesaturated(false)
end

local function AddStatTile(self, entries, statKey, hideAt, editMode)
    if not PAPERDOLL_STATINFO[statKey] then return end
    local frame = PDE.GetStatListFrame(self)
    frame.unit = "player"
    PAPERDOLL_STATINFO[statKey].updateFunc(frame, "player")

    local visible = GW.StatsPicker.IsVisible(statKey, not hideAt or hideAt ~= frame.numericValue)
    if visible or editMode then
        frame.stat = statKey
        frame.gwStatVisible = visible
        setStatIcon(frame, statKey)
        tinsert(entries, frame)
    else
        self.statsFramePool:Release(frame)
    end
end

local function updateStats(self)
    PDE.UpdateItemLevel(self)

    if InCombatLockdown() or GW.IsPaperDollStatsRestricted() then
        GW.CombatQueue:Queue("update character stats", updateStats, {self})
        return
    end
    self.statsFramePool:ReleaseAll()

    local editMode = GW.StatsPicker.IsEditMode(self.stats)
    local entries = {}

    PDE.AddSetBonusTile(self, entries, editMode)

    for _, category in ipairs(PAPERDOLL_STATCATEGORIES) do
        if category.unit ~= "pet" then
            for _, stat in ipairs(category.stats) do
                if not stat.showFunc or stat.showFunc() then
                    AddStatTile(self, entries, stat.stat, stat.hideAt, editMode)
                end
            end
        end
    end
    for _, statKey in ipairs(RESISTANCE_STATS) do
        AddStatTile(self, entries, statKey, 0, editMode)
    end

    PDE.AddDurabilityTile(self, entries)
    GW.StatsPicker.Layout(self.stats, entries, 35)
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
    self.characterData:SetText(LEVEL .. " " .. GW.mylevel .. " " .. GW.myLocalizedRace .. " " .. GW.myLocalizedClass)
end

local function stats_OnEvent(self, event, ...)
    local unit = ...
    local parent = self:GetParent()
    if event == "PLAYER_ENTERING_WORLD" or ((event == "UNIT_MODEL_CHANGED" or event == "UNIT_NAME_UPDATE") and unit == "player") then
        parent.model:SetUnit("player", false)
        updateUnitData(parent)
        return
    end
    if not GW.inWorld then
        return
    end
    if event == "UNIT_LEVEL" and unit == "player" then
        updateUnitData(parent)
    end
    if type(unit) ~= "string" or unit == "player" then
        self:SetScript("OnUpdate", stats_QueuedUpdate)
    end
end

local STATS_EVENTS = {
    "PLAYER_ENTERING_WORLD", "CHARACTER_POINTS_CHANGED", "UNIT_MODEL_CHANGED", "UNIT_LEVEL", "UNIT_STATS",
    "UNIT_RANGEDDAMAGE", "UNIT_ATTACK_POWER", "UNIT_RANGED_ATTACK_POWER", "UNIT_ATTACK", "UNIT_SPELL_HASTE",
    "UNIT_RESISTANCES", "UNIT_DEFENSE", "SKILL_LINES_CHANGED", "COMBAT_RATING_UPDATE", "UNIT_NAME_UPDATE",
    "BAG_UPDATE", "PLAYER_EQUIPMENT_CHANGED", "PLAYERBANKSLOTS_CHANGED", "PLAYER_AVG_ITEM_LEVEL_UPDATE",
    "PLAYER_DAMAGE_DONE_MODS", "SPELL_POWER_CHANGED", "UNIT_INVENTORY_CHANGED", "UPDATE_INVENTORY_ALERTS", "SPEED_UPDATE",
}

local function RegisterStatsEvents(frame)
    for _, event in ipairs(STATS_EVENTS) do
        pcall(frame.RegisterEvent, frame, event)
    end
    frame:RegisterUnitEvent("UNIT_DAMAGE", "player")
    frame:RegisterUnitEvent("UNIT_ATTACK_SPEED", "player")
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    frame:RegisterUnitEvent("UNIT_AURA", "player")
end

local function CharacterSlots(dressingRoom)
    return {
        {CharacterHeadSlot, dressingRoom.gear, "TOPLEFT", "TOPLEFT", 0, 0, 50},
        {CharacterShoulderSlot, CharacterHeadSlot, "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterChestSlot, CharacterShoulderSlot, "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterWristSlot, CharacterChestSlot, "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterHandsSlot, CharacterWristSlot, "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterWaistSlot, CharacterHandsSlot, "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterLegsSlot, CharacterWaistSlot, "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterFeetSlot, CharacterLegsSlot, "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterMainHandSlot, CharacterFeetSlot, "TOPLEFT", "BOTTOMLEFT", 0, -20, 50},
        {CharacterSecondaryHandSlot, CharacterMainHandSlot, "TOPLEFT", "TOPRIGHT", 5, 0, 50},
        {CharacterRangedSlot, CharacterMainHandSlot, "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterAmmoSlot, CharacterRangedSlot, "TOPLEFT", "TOPRIGHT", 5, 0, 50},

        {CharacterTabardSlot, dressingRoom.stats, "TOPRIGHT", "BOTTOMRIGHT", -5, -20, 40},
        {CharacterShirtSlot, CharacterTabardSlot, "TOPRIGHT", "BOTTOMRIGHT", 0, -5, 40},
        {CharacterTrinket0Slot, CharacterTabardSlot, "TOPRIGHT", "TOPLEFT", -5, 0, 40},
        {CharacterTrinket1Slot, CharacterTrinket0Slot, "TOPRIGHT", "BOTTOMRIGHT", 0, -5, 40},
        {CharacterFinger0Slot, CharacterTrinket0Slot, "TOPRIGHT", "TOPLEFT", -5, 0, 40},
        {CharacterFinger1Slot, CharacterFinger0Slot, "TOPRIGHT", "BOTTOMRIGHT", 0, -5, 40},
        {CharacterNeckSlot, CharacterFinger0Slot, "TOPRIGHT", "TOPLEFT", -5, 0, 40},
        {CharacterBackSlot, CharacterNeckSlot, "TOPRIGHT", "BOTTOMRIGHT", 0, -5, 40},
    }
end

-- the xml ScrollChild hangs its parentKey on the scroll frame, not on the stats box
local function SetupStatsScroll(stats)
    stats.tiles = stats.scroll.tiles or stats.scroll:GetScrollChild()
    stats.gwTileParent = stats.tiles
    ScrollUtil.InitScrollFrameWithScrollBar(stats.scroll, stats.scrollBar)
    GW.HandleTrimScrollBar(stats.scrollBar)
    stats.scrollBar:SetHideIfUnscrollable(true)
    return stats.tiles
end

local function LoadPDBagList(fmMenu, parent)
    MirrorStatTooltipStrings()

    -- paladins, shamans and druids carry a relic instead of a ranged weapon and have no ammo
    local hasRelicSlot = UnitHasRelicSlot("player")
    if hasRelicSlot then
        PlayerSlots.CharacterRangedSlot = RELIC_SLOT_COORDS
    end

    local fmGDR, fmGPDBIL = PDE.CreateBagList(fmMenu, parent, {
        characterSlots = CharacterSlots,
        slotBackground = SLOT_BACKGROUND,
        playerSlots = PlayerSlots,
        statsTileParent = SetupStatsScroll,
        updateStats = updateStats,
        updateUnitData = updateUnitData,
        onGrabSlot = HideAzeriteOverlay,
        styleBagItem = HideAzeriteOverlay,
    })

    fmGDR.stats:SetScript("OnEvent", stats_OnEvent)
    RegisterStatsEvents(fmGDR.stats)

    CharacterAmmoSlot:SetShown(not hasRelicSlot)
    PaperDollItemSlotButton_Update(CharacterRangedSlot)

    return fmGDR, fmGPDBIL
end
GW.LoadPDBagList = LoadPDBagList
