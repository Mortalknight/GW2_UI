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
        TooltipText = CHARACTER_BUTTON,
        Bindings = {
            TOGGLECHARACTER0 = "PaperDoll",
            TOGGLECHARACTER4 = "Honor",
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "paperdoll")
        ]=]
    },
    {
        OnLoad = "LoadProfessions",
        FrameName = "GwProfessionsDetailsFrame",
        window = "profession",
        RefName = "GwProfessionsFrame",
        TabIcon = "tabicon_professions",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/professions-window-icon.png",
        HeaderText = TRADE_SKILLS,
        TooltipText = TRADE_SKILLS,
        Bindings = {
            TOGGLEPROFESSIONBOOK = "Professions"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "professions")
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
        TooltipText = REPUTATION,
        Bindings = {
            TOGGLECHARACTER2 = "Reputation"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "reputation")
        ]=]
    },
    {
        OnLoad = "LoadCurrency",
        FrameName = "GwCurrencyDetailsFrame",
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
        OnLoad = "LoadStatistics",
        FrameName = "GwStatisticsDetailsFrame",
        window = "character",
        RefName = "GwStatisticsFrame",
        TabIcon = "tabicon_statistics",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/statistics-window-icon.png",
        HeaderText = STATISTICS,
        TooltipText = STATISTICS,
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "statistics")
        ]=]
    },
}

local charSecure_OnClick = GW.BuildCharacterWindowClickHandler({
    Currency = "currency",
    Honor = "paperdollhonor",
    PaperDoll = "paperdoll",
    PetPaperDollFrame = "paperdollpet",
    Professions = "professions",
    Reputation = "reputation",
    Skills = "paperdollskills",
    Statistics = "statistics",
})

local charSecure_OnAttributeChanged = GW.BuildCharacterWindowAttributeChangedHandler({
    managedRefs = {
        "GwPaperDoll",
        "GwPaperDollMenu",
        "GwPaperDollDressingRoom",
        "GwPaperDollEquipment",
        "GwPaperDollOutfits",
        "GwPaperDollTitles",
        "GwPaperSkills",
        "GwPaperHonor",
        "GwPetContainer",
        "GwProfessionsFrame",
        "GwReputationFrame",
        "GwCurrencyFrame",
        "GwStatisticsFrame",
    },
    states = {
        {
            values = {"paperdoll", "character"},
            toggleRef = "GwPaperDoll",
            toggleHiddenRefs = {"GwPaperDollEquipment", "GwPaperDollOutfits", "GwPaperDollTitles", "GwPaperSkills", "GwPaperHonor", "GwPetContainer"},
            showRefs = {"GwPaperDoll", "GwPaperDollMenu", "GwPaperDollDressingRoom"},
        },
        {
            value = "paperdollequipment",
            toggleRef = "GwPaperDollEquipment",
            showRefs = {"GwPaperDoll", "GwPaperDollDressingRoom", "GwPaperDollEquipment"},
        },
        {
            value = "paperdolloutfits",
            toggleRef = "GwPaperDollOutfits",
            showRefs = {"GwPaperDoll", "GwPaperDollDressingRoom", "GwPaperDollOutfits"},
        },
        {
            value = "paperdolltitles",
            toggleRef = "GwPaperDollTitles",
            showRefs = {"GwPaperDoll", "GwPaperDollDressingRoom", "GwPaperDollTitles"},
        },
        {
            value = "paperdollskills",
            toggleRef = "GwPaperSkills",
            showRefs = {"GwPaperDoll", "GwPaperSkills"},
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
        {
            value = "professions",
            toggleRef = "GwProfessionsFrame",
            showRefs = {"GwProfessionsFrame"},
        },
        {
            value = "reputation",
            toggleRef = "GwReputationFrame",
            showRefs = {"GwReputationFrame"},
        },
        {
            value = "currency",
            toggleRef = "GwCurrencyFrame",
            showRefs = {"GwCurrencyFrame"},
        },
        {
            value = "statistics",
            toggleRef = "GwStatisticsFrame",
            showRefs = {"GwStatisticsFrame"},
        },
    },
})

GW.RegisterCharacterWindowConfig({
    windowsList = windowsList,
    charSecure_OnClick = charSecure_OnClick,
    charSecure_OnAttributeChanged = charSecure_OnAttributeChanged,
})
