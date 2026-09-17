---@class GW2
local GW = select(2, ...)

local windowsList = {
    {
        OnLoad = "LoadPaperDoll",
        FrameName = "GwPaperDollDetailsFrame",
        window = "character",
        RefName = "GwPaperDoll",
        TabIcon = "tabicon_character",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/character-window-icon.png",
        HeaderText = CHARACTER,
        Bindings = {
            TOGGLECHARACTER0 = "PaperDoll",
            TOGGLECHARACTER2 = "Reputation",
            TOGGLECHARACTER1 = "Skills",
            TOGGLECHARACTER3 = "PetPaperDollFrame",
            TOGGLECHARACTER4 = "Honor"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "paperdoll")
        ]=]
    },
    {
        OnLoad = "LoadReputation",
        FrameName = "GwReputationDetailsFrame",
        window = "character",
        RefName = "GwReputationFrame",
        TabIcon = "tabicon_reputation",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/reputation-window-icon.png",
        HeaderText = REPUTATION,
        Bindings = {
            TOGGLECHARACTER2 = "Reputation"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "reputation")
        ]=]
    },
    {
        OnLoad = "LoadTalents",
        FrameName = "GwTalentsFrame",
        window = "talent",
        RefName = "GwTalentsFrame",
        TabIcon = "tabicon-talents",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/talents-window-icon.png",
        HeaderText = TALENTS,
        Bindings = {
            TOGGLETALENTS = "Talents"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "talents")
        ]=]
    },
    {
        OnLoad = "LoadSpellBook",
        FrameName = "GwSpellbookFrame",
        window = "spellbook",
        RefName = "GwSpellbookFrame",
        TabIcon = "tabicon_spellbook",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/spellbook-window-icon.png",
        HeaderText = SPELLS,
        Bindings = {
            TOGGLESPELLBOOK = "SpellBook",
            TOGGLEPETBOOK = "PetBook"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "spellbook")
        ]=]
    }
}

-- turn click events (generated from key bind overrides) into the correct tab show/hide calls
local charSecure_OnClick = GW.BuildCharacterWindowClickHandler({
    Honor = "paperdollhonor",
    PaperDoll = "paperdoll",
    PetBook = "petbook",
    PetPaperDollFrame = "paperdollpet",
    Reputation = "reputation",
    Runes = "paperdollengravings",
    Skills = "paperdollskills",
    SpellBook = "spellbook",
    Talents = "talents",
})

local charSecure_OnAttributeChanged = GW.BuildCharacterWindowAttributeChangedHandler({
    managedRefs = {
        "GwPaperDoll",
        "GwHeroPanelMenu",
        "GwDressingRoom",
        "GwReputationFrame",
        "GwPaperSkills",
        "GwEngravingFrame",
        "GwPaperHonor",
        "GwPetContainer",
        "GwSpellbookFrame",
        "GwTalentsFrame",
    },
    states = {
        {
            value = "talents",
            toggleRef = "GwTalentsFrame",
            showRefs = {"GwTalentsFrame"},
        },
        {
            values = {"spellbook", "petbook"},
            toggleRef = "GwSpellbookFrame",
            showRefs = {"GwSpellbookFrame"},
        },
        {
            value = "paperdoll",
            toggleRef = "GwPaperDoll",
            toggleHiddenRefs = {"GwPaperSkills", "GwPetContainer", "GwPaperHonor", "GwEngravingFrame"},
            showRefs = {"GwPaperDoll", "GwHeroPanelMenu", "GwDressingRoom"},
        },
        {
            value = "reputation",
            toggleRef = "GwReputationFrame",
            showRefs = {"GwReputationFrame"},
        },
        {
            value = "paperdollskills",
            toggleRef = "GwPaperSkills",
            showRefs = {"GwPaperDoll", "GwPaperSkills", "GwDressingRoom"},
        },
        {
            value = "paperdollengravings",
            toggleRef = "GwEngravingFrame",
            showRefs = {"GwPaperDoll", "GwEngravingFrame", "GwDressingRoom"},
        },
        {
            value = "paperdollhonor",
            toggleRef = "GwPaperHonor",
            showRefs = {"GwPaperDoll", "GwPaperHonor"},
        },
        {
            value = "paperdollpet",
            toggleRef = "GwPetContainer",
            requiresAttribute = "HasPetUI",
            showRefs = {"GwPaperDoll", "GwPetContainer"},
        },
    },
})

GW.RegisterCharacterWindowConfig({
    windowsList = windowsList,
    charSecure_OnClick = charSecure_OnClick,
    charSecure_OnAttributeChanged = charSecure_OnAttributeChanged,
})
