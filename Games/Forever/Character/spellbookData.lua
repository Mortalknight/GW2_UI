---@class GW2
local GW = select(2, ...)

-- the spell book data of forever, with C_SpellBook; the shared spellbook asks only this, with isPet for the pet book
local ITEM_TYPES = {
    [Enum.SpellBookItemType.Spell] = "SPELL",
    [Enum.SpellBookItemType.FutureSpell] = "FUTURESPELL",
    [Enum.SpellBookItemType.PetAction] = "PETACTION",
    [Enum.SpellBookItemType.Flyout] = "FLYOUT",
}

local function Bank(isPet)
    return isPet and Enum.SpellBookSpellBank.Pet or Enum.SpellBookSpellBank.Player
end

GW.SpellBookData = {
    HasRanks = true,
    Bank = Bank,
    GetNumTabs = C_SpellBook.GetNumSpellBookSkillLines,
    -- the professions answer behind the counted skill lines, blizzard shows only the counted ones
    GetTab = function(tab)
        if tab > C_SpellBook.GetNumSpellBookSkillLines() then return end
        local info = C_SpellBook.GetSpellBookSkillLineInfo(tab)
        if not info or info.shouldHide then return end
        return info.name, info.iconID, info.itemIndexOffset, info.numSpellBookItems, (info.offSpecID or 0) ~= 0
    end,
    GetItem = function(index, isPet)
        local info = C_SpellBook.GetSpellBookItemInfo(index, Bank(isPet))
        if not info then return end
        return ITEM_TYPES[info.itemType], info.actionID, info.spellID, info.name, info.iconID, info.isPassive,
            C_SpellBook.GetSpellBookItemLevelLearned(index, Bank(isPet))
    end,
    GetName = function(index, isPet) return C_SpellBook.GetSpellBookItemName(index, Bank(isPet)) end,
    IsPassive = function(index, isPet) return C_SpellBook.IsSpellBookItemPassive(index, Bank(isPet)) end,
    GetLink = function(index, isPet) return C_SpellBook.GetSpellBookItemLink(index, Bank(isPet)) end,
    GetTradeSkillLink = function(index, isPet) return C_SpellBook.GetSpellBookItemTradeSkillLink(index, Bank(isPet)) end,
    Pickup = function(index, isPet) C_SpellBook.PickupSpellBookItem(index, Bank(isPet)) end,
    GetAutoCast = function(index, isPet) return C_SpellBook.GetSpellBookItemAutoCast(index, Bank(isPet)) end,
    IsTalent = function(index, isPet) return C_SpellBook.IsClassTalentSpellBookItem(index, Bank(isPet)) end,
    GetSpecNames = function() return "" end,
    -- the filters of blizzards spell book: passives, lower ranks, flyouts or their loose spells
    ShouldShow = function(index, isPet)
        local bank = Bank(isPet)
        if GetCVarBool("spellBookHidePassives") and C_SpellBook.IsSpellBookItemPassive(index, bank) then
            return false
        end
        if not GetCVarBool("ShowAllSpellRanks") and C_SpellBook.IsSpellBookItemLowRank(index, bank) then
            return false
        end
        if not InputUtil.IsGamepadUIEnabled() and GetCVarBool("spellBookHideFlyouts") then
            return C_SpellBook.GetSpellBookItemType(index, bank) ~= Enum.SpellBookItemType.Flyout
        end
        return not C_SpellBook.IsSpellBookItemLooseFlyoutMember(index, bank)
    end,
    -- blizzards filter options, they share its cvars; "use flyouts" is the inverted spellBookHideFlyouts
    GetOptions = function()
        local options = {{label = SPELLBOOK_FILTER_PASSIVES, cvar = "spellBookHidePassives"}}
        if not InputUtil.IsGamepadUIEnabled() then
            tinsert(options, {label = SPELLBOOK_USE_FLYOUTS, cvar = "spellBookHideFlyouts", inverted = true})
        end
        return options
    end,
}
