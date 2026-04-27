---@class GW2
local GW = select(2, ...)

local windowsList = {
    {
        OnLoad = "LoadPaperDoll",
        FrameName = "GwPaperDollDetailsFrame",
        SettingName = "USE_CHARACTER_WINDOW",
        RefName = "GwPaperDoll",
        TabIcon = "tabicon_character",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/character-window-icon.png",
        HeaderText = CHARACTER,
        Bindings = {
            TOGGLECHARACTER0 = "PaperDoll",
            TOGGLECHARACTER3 = "PetPaperDollFrame",
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "paperdoll")
        ]=]
    },
    {
        OnLoad = "LoadReputation",
        FrameName = "GwReputationDetailsFrame",
        SettingName = "USE_CHARACTER_WINDOW",
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
        SettingName = "USE_TALENT_WINDOW",
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
        SettingName = "USE_SPELLBOOK_WINDOW",
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
        SettingName = "USE_TALENT_WINDOW",
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
        SettingName = "USE_CHARACTER_WINDOW",
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
        OnLoad = "LoadProfessions",
        FrameName = "GwProfessionsFrame",
        SettingName = "USE_CHARACTER_WINDOW",
        RefName = "GwProfessionsFrame",
        TabIcon = "tabicon_professions",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/professions-window-icon.png",
        HeaderText = TRADE_SKILLS,
        TooltipText = TRADE_SKILLS,
        Bindings = {
            TOGGLEPROFESSIONBOOK = "Professions",
            TOGGLECHARACTER1 = "Professions"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "professions")
        ]=]
    }
}

-- turn click events (generated from key bind overrides) into the correct tab show/hide calls
local charSecure_OnClick = GW.BuildCharacterWindowClickHandler({
    Currency = "currency",
    Equipemnt = "equipment",
    GearSet = "gearset",
    Glyphes = "glyphes",
    PaperDoll = "paperdoll",
    PetBook = "petbook",
    PetPaperDollFrame = "paperdollpet",
    Professions = "professions",
    Reputation = "reputation",
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
        "GwPetContainer",
        "GwPaperDollTitles",
        "GwPaperDollOutfits",
        "GwPaperDollEquipment",
        "GwSpellbookFrame",
        "GwTalentsFrame",
        "GwGlyphsFrame",
        "GwCurrencyFrame",
        "GwProfessionsFrame",
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
            values = {"spellbook", "petbook"},
            toggleRef = "GwSpellbookFrame",
            showRefs = {"GwSpellbookFrame"},
        },
        {
            value = "professions",
            toggleRef = "GwProfessionsFrame",
            showRefs = {"GwProfessionsFrame"},
        },
        {
            value = "paperdoll",
            toggleRef = "GwPaperDoll",
            toggleHiddenRefs = {"GwPetContainer", "GwPaperDollTitles", "GwPaperDollOutfits", "GwPaperDollEquipment"},
            showRefs = {"GwPaperDoll", "GwHeroPanelMenu", "GwDressingRoom"},
        },
        {
            value = "reputation",
            toggleRef = "GwReputationFrame",
            showRefs = {"GwReputationFrame"},
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
            value = "equipment",
            toggleRef = "GwPaperDollEquipment",
            showRefs = {"GwPaperDoll", "GwPaperDollEquipment", "GwDressingRoom"},
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
