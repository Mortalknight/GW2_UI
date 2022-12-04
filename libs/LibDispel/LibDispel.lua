local MAJOR, MINOR = "LibDispel-1.0-GW", 1
assert(LibStub, MAJOR.." requires LibStub")
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local DispelList = {}
lib.DispelList = DispelList

function lib:GetMyDispelTypes()
    return DispelList
end

function lib:IsDispellableByMe(debuffType)
    return DispelList[debuffType]
end

do
    local _, myClass = UnitClass("player")

    local function CheckSpell(spellID, pet)
        return IsSpellKnownOrOverridesKnown(spellID, pet) and true or nil
    end

    local function CheckPetSpells()
        return CheckSpell(89808, true)
    end

    local function UpdateDispels(_, event, arg1)
        if event == "CHARACTER_POINTS_CHANGED" and arg1 > 0 then
            return
        end

        if event == "UNIT_PET" then
            DispelList.Magic = CheckPetSpells()
        elseif myClass == "DRUID" then
            local cure = CheckSpell(88423) -- Nature"s Cure
            local corruption = CheckSpell(2782) -- Remove Corruption
            DispelList.Magic = cure
            DispelList.Curse = cure or corruption
            DispelList.Poison = cure or corruption
        elseif myClass == "MAGE" then
            DispelList.Curse = CheckSpell(475) -- Remove Curse
        elseif myClass == "MONK" then
            local mwDetox = CheckSpell(115450) -- Detox (Mistweaver)
            local detox = mwDetox or CheckSpell(218164) -- Detox (Brewmaster or Windwalker)
            DispelList.Magic = mwDetox
            DispelList.Disease = detox
            DispelList.Poison = detox
        elseif myClass == "PALADIN" then
            local cleanse = CheckSpell(4987) -- Cleanse
            local purify = CheckSpell(1152) -- Purify
            local toxins = cleanse or purify or CheckSpell(213644) -- Cleanse Toxins
            DispelList.Magic = cleanse
            DispelList.Poison = toxins
            DispelList.Disease = toxins
        elseif myClass == "PRIEST" then
            local dispel = CheckSpell(527) -- Dispel Magic
            DispelList.Magic = dispel or CheckSpell(32375)
            DispelList.Disease = (dispel and CheckSpell(390632)) or CheckSpell(213634)
        elseif myClass == "SHAMAN" then
            local purify = CheckSpell(77130) -- Purify Spirit
            local cleanse = purify or CheckSpell(51886) -- Cleanse Spirit

            DispelList.Magic = purify
            DispelList.Curse = cleanse
        elseif myClass == "EVOKER" then
            local naturalize = CheckSpell(360823) -- Naturalize (Preservation)
            local expunge = CheckSpell(365585) -- Expunge (Devastation)
            local cauterizing = CheckSpell(374251) -- Cauterizing Flame (Still need bleed support.)

            DispelList.Magic = naturalize
            DispelList.Poison = naturalize or expunge or cauterizing
            DispelList.Disease = cauterizing
            DispelList.Curse = cauterizing
        end
    end

    local frame = CreateFrame("Frame")
    frame:SetScript("OnEvent", UpdateDispels)
    frame:RegisterEvent("CHARACTER_POINTS_CHANGED")
    frame:RegisterEvent("PLAYER_LOGIN")

    if myClass == "WARLOCK" then
        frame:RegisterUnitEvent("UNIT_PET", "player")
    end

    frame:RegisterEvent("PLAYER_TALENT_UPDATE")
    frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
end
