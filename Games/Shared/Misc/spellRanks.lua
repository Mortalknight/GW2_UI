---@class GW2
local GW = select(2, ...)

-- a newly learned rank replaces the rank just below it on the action bars; lower ranks someone keeps for
-- downranking stay. Only out of combat and with an empty cursor, else after the fight
if not (GW.Classic or GW.TBC or GW.Wrath) then return end

local MAX_ACTION_SLOTS = 120
local GetSpellName = C_Spell and C_Spell.GetSpellName or function(spellID) return (GetSpellInfo(spellID)) end
local pending = {}

local function GetRank(spellID)
    local subtext = GetSpellSubtext(spellID)
    return subtext and tonumber(subtext:match("%d+"))
end

local function ReplaceLowerRank(spellID)
    local name, rank = GetSpellName(spellID), GetRank(spellID)
    if not name or not rank or rank < 2 then return end
    for slot = 1, MAX_ACTION_SLOTS do
        local actionType, id = GetActionInfo(slot)
        if actionType == "spell" and id ~= spellID and GetSpellName(id) == name and GetRank(id) == rank - 1 then
            PickupSpell(spellID)
            PlaceAction(slot)
            ClearCursor()
        end
    end
end

local function ProcessPending()
    if InCombatLockdown() or GetCursorInfo() then return end
    for spellID in pairs(pending) do
        pending[spellID] = nil
        ReplaceLowerRank(spellID)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function(_, event, spellID)
    if not GW.settings.general.autoSpellRank then return end
    if event == "LEARNED_SPELL_IN_SKILL_LINE" and spellID then
        pending[spellID] = true
    end
    ProcessPending()
end)
