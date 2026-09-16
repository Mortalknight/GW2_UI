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
            TOGGLECHARACTER1 = "Skills",
            TOGGLECHARACTER3 = "PetPaperDollFrame",
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
    },
    {
        OnLoad = "LoadGlyphes",
        FrameName = "GwGlyphsFrame",
        window = "talent",
        RefName = "GwGlyphsFrame",
        TabIcon = "tabicon-glyph",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/glyph-window-icon.png",
        HeaderText = GLYPHS,
        Bindings = {
            TOGGLEINSCRIPTION = "Glyphes"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "glyphes")
        ]=]
    },
    {
        OnLoad = "LoadCurrency",
        FrameName = "GwCurrencyFrame",
        window = "character",
        RefName = "GwCurrencyFrame",
        TabIcon = "tabicon_currency",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/currency-window-icon.png",
        HeaderText = CURRENCY,
        TooltipText = CURRENCY,
        Bindings = {
            TOGGLECURRENCY = "Currency"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "currency")
        ]=]
    },
    {
        OnLoad = "LoadPvp",
        FrameName = "GwPvpFrame",
        window = "character",
        RefName = "GwPvpFrame",
        TabIcon = "tabicon-pvp",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/pvp-window-icon.png",
        HeaderText = PVP,
        TooltipText = PVP,
        Bindings = {
            TOGGLECHARACTER4 = "Pvp"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "pvp")
        ]=]
    }
}

-- turn click events (generated from key bind overrides) into the correct tab show/hide calls
local charSecure_OnClick = GW.BuildCharacterWindowClickHandler({
    Currency = "currency",
    GearSet = "gearset",
    Glyphes = "glyphes",
    PaperDoll = "paperdoll",
    PetBook = "petbook",
    PetPaperDollFrame = "paperdollpet",
    Pvp = "pvp",
    Reputation = "reputation",
    Skills = "paperdollskills",
    SpellBook = "spellbook",
    Talents = "talents",
    Titles = "titles",
})

local charSecure_OnAttributeChanged = GW.BuildCharacterWindowAttributeChangedHandler({
    managedRefs = {
        "GwPaperDoll",
        "GwHeroPanelMenu",
        "GwDressingRoom",
        "GwReputationFrame",
        "GwPaperSkills",
        "GwPetContainer",
        "GwPaperDollTitles",
        "GwPaperDollOutfits",
        "GwSpellbookFrame",
        "GwTalentsFrame",
        "GwGlyphsFrame",
        "GwCurrencyFrame",
        "GwPvpFrame",
    },
    states = {
        {
            value = "talents",
            toggleRef = "GwTalentsFrame",
            showRefs = {"GwTalentsFrame"},
        },
        {
            value = "glyphes",
            toggleRef = "GwGlyphsFrame",
            showRefs = {"GwGlyphsFrame"},
        },
        {
            value = "currency",
            toggleRef = "GwCurrencyFrame",
            showRefs = {"GwCurrencyFrame"},
        },
        {
            value = "pvp",
            toggleRef = "GwPvpFrame",
            showRefs = {"GwPvpFrame"},
        },
        {
            values = {"spellbook", "petbook"},
            toggleRef = "GwSpellbookFrame",
            showRefs = {"GwSpellbookFrame"},
        },
        {
            value = "paperdoll",
            toggleRef = "GwPaperDoll",
            toggleHiddenRefs = {"GwPaperSkills", "GwPetContainer", "GwPaperDollTitles", "GwPaperDollOutfits"},
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
            value = "titles",
            toggleRef = "GwPaperDollTitles",
            showRefs = {"GwPaperDoll", "GwPaperDollTitles", "GwDressingRoom"},
        },
        {
            value = "gearset",
            toggleRef = "GwPaperDollOutfits",
            showRefs = {"GwPaperDoll", "GwPaperDollOutfits", "GwDressingRoom"},
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
