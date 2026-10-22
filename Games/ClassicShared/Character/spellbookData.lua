---@class GW2
local GW = select(2, ...)

-- the spell book data of vanilla, tbc, wrath and mists, with the old spell book functions; the shared spellbook
-- asks only this, with isPet for the pet book
local function Bank(isPet)
    return isPet and BOOKTYPE_PET or BOOKTYPE_SPELL
end

GW.SpellBookData = {
    -- mists has no spell ranks anymore
    HasRanks = not GW.Mists,
    Bank = Bank,
    GetNumTabs = GetNumSpellTabs,
    GetTab = function(tab)
        if tab > GetNumSpellTabs() then return end
        local name, texture, offset, numSpells, _, offSpecID = GetSpellTabInfo(tab)
        return name, texture, offset, numSpells, (offSpecID or 0) ~= 0
    end,
    GetItem = function(index, isPet)
        local slotType, slotID = GetSpellBookItemInfo(index, Bank(isPet))
        local name, _, spellID = GetSpellBookItemName(index, Bank(isPet))
        return slotType, slotID, spellID, name, GetSpellBookItemTexture(index, Bank(isPet)), IsPassiveSpell(spellID),
            GetSpellAvailableLevel(index, Bank(isPet))
    end,
    GetName = function(index, isPet) return GetSpellBookItemName(index, Bank(isPet)) end,
    IsPassive = function(index, isPet) return IsPassiveSpell(index, Bank(isPet)) end,
    GetLink = function(index, isPet) return GetSpellLink(index, Bank(isPet)) end,
    GetTradeSkillLink = function(index, isPet)
        local link, skillLineID = GetSpellTradeSkillLink(index, Bank(isPet))
        return skillLineID and link
    end,
    Pickup = function(index, isPet) PickupSpellBookItem(index, Bank(isPet)) end,
    GetAutoCast = function(index, isPet) return GetSpellAutocast(index, Bank(isPet)) end,
    IsTalent = function(index, isPet) return IsTalentSpell(index, Bank(isPet)) end,
    GetSpecNames = function(index, isPet) return table.concat({GetSpecsForSpell(index, Bank(isPet))}, PLAYER_LIST_DELIMITER) end,
    -- like blizzard before wrath, season of discovery keeps placeholders for runes not learned yet
    ShouldShow = function(index, isPet)
        return not ((GW.Classic or GW.TBC) and IsSpellHidden(index, Bank(isPet)))
    end,
    GetOptions = function() return {} end,
}
