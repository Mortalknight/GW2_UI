---@class GW2
local GW = select(2, ...)

-- The debuff types the player can remove, read from the dispel spells it knows. The type table changes in place,
-- the aura containers hand it to the aura filters and hear about changes through GW2_UI.DispelTypesChanged.

-- the classic flavors know the old ranks and spell meanings behind the same ids
local isClassic = GW.Classic or GW.TBC or GW.Wrath or GW.Forever

-- the warlock removes magic through spells of its pet
local function PetMagicSpells(spellIDs)
    local rows = {}
    for _, spellID in ipairs(spellIDs) do
        rows[#rows + 1] = {id = spellID, types = {"Magic"}, pet = true}
    end
    return rows
end

-- one row per spell and the types it removes: talent counts once learned instead of looking in the spell book, pet
-- looks in the pet's spell book, requires a second spell (the dispel talents of mists), when limits a row to clients;
-- a spell that removes some types only under a condition gets a row for those
local CLASS_DISPELS = {
    DRUID = {
        {id = 88423, types = {"Magic", "Curse", "Poison"}},                 -- Nature's Cure
        {id = 2782, types = isClassic and {"Curse"} or {"Curse", "Poison"}}, -- Remove Curse / Remove Corruption
        {id = 2893, types = {"Poison"}},                                    -- Abolish Poison
        {id = 8946, types = {"Poison"}},                                    -- Cure Poison
    },
    HUNTER = {
        {id = 459517, types = {"Poison", "Disease"}, talent = true, when = GW.Retail}, -- Emergency Salve
    },
    MAGE = {
        {id = 412113, types = {"Curse", "Magic"}},
        {id = 475, types = {"Curse"}},                                      -- Remove Curse
    },
    MONK = {
        {id = 115450, types = {"Magic"}, requires = GW.Mists and 115451 or nil}, -- Detox (Mistweaver)
        {id = 115450, types = {"Disease", "Poison"}, when = not GW.Retail},
        {id = 218164, types = {"Disease", "Poison"}, when = GW.Retail},      -- Detox
        {id = 388874, types = {"Disease", "Poison"}, talent = true, when = GW.Retail}, -- Improved Detox
    },
    PALADIN = {
        {id = 4987, types = {"Magic"}, requires = GW.Mists and 53551 or nil}, -- Cleanse
        {id = 4987, types = {"Disease", "Poison"}},
        {id = 1152, types = {"Disease", "Poison"}},                         -- Purify
        {id = 213644, types = {"Disease", "Poison"}},                       -- Cleanse Toxins
    },
    PRIEST = {
        {id = 527, types = {"Magic"}},                                      -- Dispel Magic / Purify
        {id = 32375, types = {"Magic"}},                                    -- Mass Dispel
        {id = 213634, types = {"Disease"}, when = GW.Retail},               -- Purify Disease
        {id = 390632, types = {"Disease"}, talent = true, when = GW.Retail}, -- Improved Purify
        {id = 552, types = {"Disease"}, when = not GW.Retail},              -- Abolish Disease
        {id = 528, types = {"Disease"}, when = not GW.Retail},              -- Cure Disease
    },
    SHAMAN = {
        {id = 77130, types = {"Magic", "Curse"}},                           -- Purify Spirit
        {id = 51886, types = {"Curse"}},                                    -- Cleanse Spirit
        {id = 383013, types = {"Poison"}, when = GW.Retail},                -- Poison Cleansing Totem
        {id = 526, types = {"Poison"}, when = isClassic},                   -- Cure Poison
        {id = 2870, types = {"Disease"}, when = isClassic},                 -- Cure Disease
        {id = 8170, types = {"Disease"}, when = isClassic},                 -- Disease Cleansing Totem
    },
    EVOKER = {
        {id = 360823, types = {"Magic", "Poison"}},                         -- Naturalize
        {id = 378438, types = {"Magic"}},                                   -- Scouring Flame
        {id = 365585, types = {"Poison"}},                                  -- Expunge
        {id = 374251, types = {"Poison", "Disease", "Curse", "Bleed"}},     -- Cauterizing Flame
    },
    -- Singe, plus Devour Magic ranks 1-7 on the classic clients and Singe Magic on the others
    WARLOCK = PetMagicSpells(isClassic and {89808, 19505, 19731, 19734, 19736, 27276, 27277, 48011} or {89808, 132411}),
}

-- the types go by name like the auras carry them; a name the type enum does not know is a typo and fails right away
for class, rows in pairs(CLASS_DISPELS) do
    for _, row in ipairs(rows) do
        for _, dispelType in ipairs(row.types) do
            if not GW.Enum.DispelType[dispelType] then
                error(("unknown dispel type %q for %s spell %d"):format(dispelType, class, row.id))
            end
        end
    end
end

-- spells that hurt the dispeller or the target when removed
local BAD_DISPELS = GW.Retail and {
    [34914] = true,  -- Vampiric Touch, horrifies
    [233490] = true, -- Unstable Affliction, silences
} or {}

local myTypes = {}

local function KnowsRow(row)
    local known
    if row.talent then
        known = GW.IsSpellKnown(row.id)
    else
        known = GW.IsSpellInSpellBook(row.id, row.pet)
    end
    return known and (not row.requires or GW.IsSpellInSpellBook(row.requires))
end

local function UpdateMyTypes(_, event, points)
    -- only a spent talent point (a negative change) can teach a dispel
    if event == "CHARACTER_POINTS_CHANGED" and (not points or points > 0) then return end

    -- the classic spell book lists only the highest rank, the lower ones count as unknown otherwise
    local showRanks = GW.Classic and C_CVar.GetCVar("ShowAllSpellRanks") ~= "1"
    if showRanks then
        C_CVar.SetCVar("ShowAllSpellRanks", "1")
    end
    local found = {}
    for _, row in ipairs(CLASS_DISPELS[GW.myclass] or {}) do
        if row.when ~= false and KnowsRow(row) then
            for _, dispelType in ipairs(row.types) do
                found[dispelType] = true
            end
        end
    end
    if showRanks then
        C_CVar.SetCVar("ShowAllSpellRanks", "0")
    end

    local changed = false
    for dispelType in pairs(GW.Enum.DispelType) do
        if myTypes[dispelType] ~= found[dispelType] then
            myTypes[dispelType] = found[dispelType]
            changed = true
        end
    end
    if changed then
        EventRegistry:TriggerEvent("GW2_UI.DispelTypesChanged", myTypes)
    end
end

GW.Dispel = {
    BadDispels = BAD_DISPELS,
}

function GW.Dispel.CanDispel(dispelType)
    -- a secret can not be a table key
    if GW.IsSecretValue(dispelType) or dispelType == nil then return false end
    return myTypes[dispelType] == true
end

function GW.Dispel.GetMyTypes()
    return myTypes
end

local watcher = CreateFrame("Frame")
watcher:SetScript("OnEvent", UpdateMyTypes)
for _, event in ipairs({"PLAYER_LOGIN", "SPELLS_CHANGED", "LEARNED_SPELL_IN_SKILL_LINE", "CHARACTER_POINTS_CHANGED", "PLAYER_TALENT_UPDATE"}) do
    if C_EventUtils.IsEventValid(event) then
        watcher:RegisterEvent(event)
    end
end
if GW.myclass == "WARLOCK" then
    watcher:RegisterUnitEvent("UNIT_PET", "player")
end
