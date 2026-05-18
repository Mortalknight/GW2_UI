local MAJOR, MINOR = "LibDispel-1.0-GW", 4
assert(LibStub, MAJOR.." requires LibStub")
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local Classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local Cata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
local TBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local Wrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
local Mists = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC

local DispelList = {} -- List of types the player can dispel
lib.DispelList = DispelList

local BlockList = {} -- Spells blocked
lib.BlockList = BlockList

local BadList = {} -- Spells that backfire when dispelled
lib.BadList = BadList

if Retail then
    -- Bad to dispel spells
    BadList[34914] = "Vampiric Touch"		-- horrifies
    BadList[233490] = "Unstable Affliction"	-- silences

    -- Block spells
    BlockList[140546] = "Fully Mutated"
    BlockList[136184] = "Thick Bones"
    BlockList[136186] = "Clear Mind"
    BlockList[136182] = "Improved Synapses"
    BlockList[136180] = "Keen Eyesight"
    BlockList[105171] = "Deep Corruption"
    BlockList[108220] = "Deep Corruption"
    BlockList[116095] = "Disable" -- slow
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

    local vanilla = Classic or TBC or Wrath
    if vanilla then
        WarlockPetSpells[19505] = "Devour Magic Rank 1"
        WarlockPetSpells[19731] = "Devour Magic Rank 2"
        WarlockPetSpells[19734] = "Devour Magic Rank 3"
        WarlockPetSpells[19736] = "Devour Magic Rank 4"
        WarlockPetSpells[27276] = "Devour Magic Rank 5"
        WarlockPetSpells[27277] = "Devour Magic Rank 6"
        WarlockPetSpells[48011] = "Devour Magic Rank 7"
    else
        WarlockPetSpells[132411] = "Singe Magic" -- Grimoire of Sacrifice
    end

    local function CheckSpell(spellID, pet)
        return GW2_ADDON.IsSpellInSpellBook(spellID, pet)
    end

    local function CheckPetSpells()
        for spellID in next, WarlockPetSpells do
            if CheckSpell(spellID, true) then
                return true
            end
        end
    end

    local function UpdateDispels(_, event, arg1)
        if event == "CHARACTER_POINTS_CHANGED" and (not arg1 or arg1 > 0) then
            return
        end

        local undoRanks = (Classic and GetCVar("ShowAllSpellRanks") ~= "1") and SetCVar("ShowAllSpellRanks", "1")

        if event == "UNIT_PET" then
            DispelList.Magic = CheckPetSpells()
        elseif myClass == "DRUID" then
            local cure = CheckSpell(88423) -- Nature's Cure
            local corruption = CheckSpell(2782) -- Remove Corruption
            DispelList.Magic = cure
            DispelList.Poison = cure or (not Classic and corruption) or CheckSpell(2893) or CheckSpell(8946) -- Abolish Poison / Cure Poison
            DispelList.Curse = cure or corruption
        elseif myClass == "MAGE" then
            local greater = CheckSpell(412113)
            DispelList.Curse = greater or CheckSpell(475) -- Remove Curse
            DispelList.Magic = greater
        elseif myClass == "MONK" then
            local mwDetox = CheckSpell(115450) -- Detox (Mistweaver)
            local detox = (not Retail and mwDetox) or (Retail and (CheckSpell(218164) or GW2_ADDON.IsSpellKnown(388874))) -- Detox (Brewmaster or Windwalker) or Improved Detox (Mistweaver)
            DispelList.Magic = mwDetox and (not Mists or CheckSpell(115451))
            DispelList.Disease = detox
            DispelList.Poison = detox
        elseif myClass == "PALADIN" then
            local cleanse = CheckSpell(4987) -- Cleanse
            local purify = CheckSpell(1152) -- Purify
            local toxins = cleanse or purify or CheckSpell(213644) -- Cleanse Toxins
            DispelList.Magic = cleanse and (not Mists or CheckSpell(53551)) -- Sacred Cleansing
            DispelList.Poison = toxins
            DispelList.Disease = toxins
        elseif myClass == "PRIEST" then
            local dispel = CheckSpell(527) -- Dispel Magic
            DispelList.Magic = dispel or CheckSpell(32375)
            DispelList.Disease = Retail and (GW2_ADDON.IsSpellKnown(390632) or CheckSpell(213634)) or not Retail and (CheckSpell(552) or CheckSpell(528)) -- Purify Disease / Abolish Disease / Cure Disease
        elseif myClass == "SHAMAN" then
            local purify = CheckSpell(77130) -- Purify Spirit
            local cleanse = purify or CheckSpell(51886) -- Cleanse Spirit (Retail/Mists)
            local toxins = (Retail and CheckSpell(383013)) or (Classic and CheckSpell(526)) -- Poison Cleansing Totem (Retail), Cure Poison (Classic / TBC)
            local cureDisease = Classic and CheckSpell(2870) -- Cure Disease
            local diseaseTotem = Classic and CheckSpell(8170) -- Disease Cleansing Totem

            DispelList.Magic = purify
            DispelList.Curse = cleanse
            DispelList.Poison = toxins
            DispelList.Disease = cureDisease or diseaseTotem
        elseif myClass == "EVOKER" then
            local naturalize = CheckSpell(360823) -- Naturalize (Preservation)
            local expunge = CheckSpell(365585) -- Expunge (Devastation)
            local cauterizing = CheckSpell(374251) -- Cauterizing Flame
            local scouringFlame = CheckSpell(378438) -- Scouring Flame (PvP Talent)

            DispelList.Magic = naturalize or scouringFlame
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

    if Retail or TBC or Wrath then
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
