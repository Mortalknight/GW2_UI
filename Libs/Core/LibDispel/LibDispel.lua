local MAJOR, MINOR = "LibDispel-1.0-GW", 3
assert(LibStub, MAJOR.." requires LibStub")
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local Classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local Cata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
local TBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC

local DebuffColors = {}
DebuffColors.none = {r = 220 / 255, g = 0, b = 0}
DebuffColors.Curse = {r = 97 / 255, g = 72 / 255, b = 177 / 255}
DebuffColors.Disease = {r = 177 / 255, g = 114 / 255, b = 72 / 255}
DebuffColors.Magic = {r = 72 / 255, g = 94 / 255, b = 177 / 255}
DebuffColors.Poison = {r = 94 / 255, g = 177 / 255, b = 72 / 255}
DebuffColors.Bleed = { r = 1, g = 0.2, b = 0.6 }
DebuffColors.BadDispel = { r = 0.05, g = 0.85, b = 0.94 }
DebuffColors.Stealable = { r = 0.93, g = 0.91, b = 0.55 }
DebuffColors.Enrage = CreateColor(243/255, 95/255, 245/255)
DebuffColors[""] = DebuffColors.none
lib.DebuffTypeColor = DebuffColors

local DispelList = {} -- List of types the player can dispel
lib.DispelList = DispelList

local BlockList = {} -- Spells blocked from AuraHighlight
lib.BlockList = BlockList

local BadList = {} -- Spells that backfire when dispelled
lib.BadList = BadList

function lib:GetDebuffTypeColor()
    return DebuffColors
end

function lib:GetBadList()
    return BadList
end

function lib:GetBlockList()
    return BlockList
end

function lib:GetMyDispelTypes()
    return DispelList
end

function lib:IsDispellableByMe(debuffType)
    return DispelList[debuffType]
end

do
    local _, myClass = UnitClass("player")

    local WarlockPetSpells = {
        [89808] = "Singe"
    }

    if Retail then
        WarlockPetSpells[132411] = "Singe Magic" -- Grimoire of Sacrifice
    else
        WarlockPetSpells[19505] = "Devour Magic Rank 1"
        WarlockPetSpells[19731] = "Devour Magic Rank 2"
        WarlockPetSpells[19734] = "Devour Magic Rank 3"
        WarlockPetSpells[19736] = "Devour Magic Rank 4"
        WarlockPetSpells[27276] = "Devour Magic Rank 5"
        WarlockPetSpells[27277] = "Devour Magic Rank 6"
        WarlockPetSpells[48011] = "Devour Magic Rank 7"
    end

    local function CheckSpell(spellID, pet)
        return GW2_ADDON.IsSpellKnownOrOverridesKnown(spellID, pet)
    end

    local function CheckPetSpells()
        for spellID in next, WarlockPetSpells do
            if CheckSpell(spellID, true) then
                return true
            end
        end
    end

    local function CheckTalentClassic(tabIndex, talentIndex)
        local _, _, _, _, rank = GetTalentInfo(tabIndex, talentIndex)
        return (rank and rank > 0) or nil
    end

    local function UpdateDispels(_, event, arg1)
        if event == "CHARACTER_POINTS_CHANGED" and arg1 > 0 then
            return
        end

        local undoRanks = (Classic and GetCVar("ShowAllSpellRanks") ~= "1") and SetCVar("ShowAllSpellRanks", "1")

        if event == "UNIT_PET" then
            DispelList.Magic = CheckPetSpells()
        elseif myClass == "DRUID" then
            local cure = Retail and CheckSpell(88423) -- Nature"s Cure
            local corruption = CheckSpell(2782) -- Remove Corruption
            DispelList.Magic = cure or (Cata and corruption and CheckTalentClassic(3, 15)) -- Nature"s Cure Talent
            DispelList.Poison = cure or (not Classic and corruption) or CheckSpell(2893) or CheckSpell(8946) -- Abolish Poison / Cure Poison
            DispelList.Curse = cure or corruption
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
            DispelList.Magic = cleanse and (not Cata or CheckTalentClassic(1, 7)) -- Sacred Cleansing
            DispelList.Poison = toxins
            DispelList.Disease = toxins
        elseif myClass == "PRIEST" then
            local dispel = CheckSpell(527) -- Dispel Magic
            DispelList.Magic = dispel or CheckSpell(32375)
            DispelList.Disease = Retail and (GW2_ADDON.IsSpellKnown(390632) or CheckSpell(213634)) or not Retail and (CheckSpell(552) or CheckSpell(528)) -- Purify Disease / Abolish Disease / Cure Disease
        elseif myClass == "SHAMAN" then
            local purify = Retail and CheckSpell(77130) -- Purify Spirit
            local cleanse = purify or CheckSpell(51886) -- Cleanse Spirit (Retail/Cata)
            local improvedCleanse = Cata and cleanse and CheckTalentClassic(3, 14) -- Improved Cleanse Spirit
            local toxins = Retail and CheckSpell(383013) or CheckSpell(526) -- Poison Cleansing Totem (Retail), Cure Toxins (Classic)
            local cureDisease = Classic and CheckSpell(2870) -- Cure Disease
            local diseaseTotem = Classic and CheckSpell(8170) -- Disease Cleansing Totem

            DispelList.Magic = purify or improvedCleanse
            DispelList.Curse = cleanse
            DispelList.Poison = toxins
            DispelList.Disease = cureDisease or diseaseTotem
        elseif myClass == "EVOKER" then
            local naturalize = CheckSpell(360823) -- Naturalize (Preservation)
            local expunge = CheckSpell(365585) -- Expunge (Devastation)
            local cauterizing = CheckSpell(374251) -- Cauterizing Flame

            DispelList.Magic = naturalize
            DispelList.Poison = naturalize or expunge or cauterizing
            DispelList.Disease = cauterizing
            DispelList.Curse = cauterizing
            DispelList.Bleed = cauterizing
        end

        if undoRanks then
            SetCVar("ShowAllSpellRanks", "0")
        end
    end

-- setup events
    if not lib.frame then
        lib.frame = CreateFrame("Frame")
    else -- we are resetting it
        lib.frame:UnregisterAllEvents()
    end

    local frame = lib.frame
    frame:SetScript("OnEvent", UpdateDispels)
    frame:RegisterEvent("CHARACTER_POINTS_CHANGED")
    frame:RegisterEvent("PLAYER_LOGIN")

    if Retail or TBC then
        frame:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE")
    else
        frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
    end

    if not Classic then
        frame:RegisterEvent("PLAYER_TALENT_UPDATE")
    end

    if myClass == "WARLOCK" then
        frame:RegisterUnitEvent("UNIT_PET", "player")
    end
end
