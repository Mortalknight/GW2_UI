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
            TOGGLECHARACTER0 = "PaperDoll"
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
    }
}

-- turn click events (generated from key bind overrides) into the correct tab show/hide calls
local charSecure_OnClick = GW.BuildCharacterWindowClickHandler({
    Currency = "currency",
    PaperDoll = "paperdoll",
    Professions = "professions",
    Reputation = "reputation",
})

local charSecure_OnAttributeChanged = GW.BuildCharacterWindowAttributeChangedHandler({
    managedRefs = {
        "GwPaperDoll",
        "GwPaperDollMenu",
        "GwPaperDollDressingRoom",
        "GwPaperDollEquipment",
        "GwPaperDollOutfits",
        "GwPaperDollTitles",
        "GwReputationFrame",
        "GwCurrencyFrame",
        "GwProfessionsFrame",
    },
    states = {
        {
            values = {"paperdoll", "character"},
            toggleRef = "GwPaperDoll",
            toggleHiddenRefs = {"GwPaperDollEquipment", "GwPaperDollOutfits", "GwPaperDollTitles"},
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
            value = "professions",
            toggleRef = "GwProfessionsFrame",
            showRefs = {"GwProfessionsFrame"},
        },
    },
})


GW.RegisterCharacterWindowConfig({
    windowsList = windowsList,
    charSecure_OnClick = charSecure_OnClick,
    charSecure_OnAttributeChanged = charSecure_OnAttributeChanged,
})
