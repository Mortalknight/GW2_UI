---@class GW2
local GW = select(2, ...)

local hideCharframe = true

local BLIZZARD_TAB_PANELS = {
    ReputationFrame = "reputation",
    TokenFrame = "currency",
    SkillsFrame = "paperdollskills",
    PVPRankFrame = "paperdollhonor",
    StatisticsFrame = "statistics",
}

local function toggleCharacter(tab, onlyShow)
    if InCombatLockdown() then
        return
    end
    if not onlyShow then
        GwCharacterWindow:SetAttribute("keytoggle", true)
    end
    GwCharacterWindow:SetAttribute("windowpanelopen", BLIZZARD_TAB_PANELS[tab] or "character")
end

local function menu_SetupBackButton(_, fmBtn, key)
    GW.CharacterMenuButtonBack_OnLoad(fmBtn, key, true)
    GW.SetCharacterWindowOpenAttribute(fmBtn, "paperdoll", false)
end

local function AddMenuButton(fmMenu, key, text, previous, odd, target)
    local button = CreateFrame("Button", nil, fmMenu, "SecureHandlerClickTemplate,GwCharacterPanelMenuButtonTemplate")
    button:SetText(text)
    button:GetFontString():GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    button:ClearAllPoints()
    if previous then
        button:SetPoint("TOPLEFT", previous, "BOTTOMLEFT")
    else
        button:SetPoint("TOPLEFT", fmMenu, "TOPLEFT")
    end
    GW.CharacterMenuButton_OnLoad(button, odd, true)
    GW.SetCharacterWindowOpenAttribute(button, target, false)
    fmMenu[key] = button
    return button
end

local function LoadPaperDoll(tabContainer)
    local fmMenu = CreateFrame("Frame", nil, tabContainer, "GwCharacterPanelMenuTemplate,SecureHandlerBaseTemplate")
    GwCharacterWindow:SetHeroPanelMenu(fmMenu)
    fmMenu.SetupBackButton = menu_SetupBackButton

    local button = AddMenuButton(fmMenu, "equipmentMenu", BAG_FILTER_EQUIPMENT, nil, false, "paperdollequipment")
    button = AddMenuButton(fmMenu, "outfitsMenu", EQUIPMENT_MANAGER, button, true, "paperdolloutfits")
    button = AddMenuButton(fmMenu, "titlesMenu", PAPERDOLL_SIDEBAR_TITLES, button, false, "paperdolltitles")
    button = AddMenuButton(fmMenu, "skillsMenu", SKILLS, button, true, "paperdollskills")
    button = AddMenuButton(fmMenu, "honorMenu", PVP, button, false, "paperdollhonor")
    button = AddMenuButton(fmMenu, "petMenu", PET, button, true, "paperdollpet")

    local dressingRoom, paperDollBagItemList = GW.LoadPDBagList(fmMenu, tabContainer)
    local paperDollOutfits = GW.LoadPDEquipset(fmMenu, tabContainer)
    local paperDollTitles = GW.LoadPDTitles(tabContainer, fmMenu)
    local skillsPanel = GW.LoadSkillsPanel(tabContainer, fmMenu)
    local honorPanel = CreateFrame("Frame", "GwPaperHonor", tabContainer, "GwPaperHonor")
    GW.LoadHonorPanel(honorPanel, fmMenu)
    local petContainer = GW.LoadPetPanel(tabContainer, fmMenu)

    GW.SetupPetMenuButton(fmMenu.petMenu)

    GwCharacterWindow:SetFrameRef("GwPaperDollMenu", fmMenu)
    GwCharacterWindow:SetFrameRef("GwPaperDollDressingRoom", dressingRoom)
    GwCharacterWindow:SetFrameRef("GwPaperDollEquipment", paperDollBagItemList)
    GwCharacterWindow:SetFrameRef("GwPaperDollOutfits", paperDollOutfits)
    GwCharacterWindow:SetFrameRef("GwPaperDollTitles", paperDollTitles)
    GwCharacterWindow:SetFrameRef("GwPaperSkills", skillsPanel)
    GwCharacterWindow:SetFrameRef("GwPaperHonor", honorPanel)
    GwCharacterWindow:SetFrameRef("GwPetContainer", petContainer)

    GwCharacterWindow:SetNextAddonMenuButtonShadowState(not fmMenu.petMenu:IsShown())
    GwCharacterWindow:SetNextAddonMenuButtonAnchor(fmMenu.petMenu:IsShown() and fmMenu.petMenu or fmMenu.honorMenu)
    fmMenu.Pawn = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "Pawn",
        showFunction = function() PawnUIShow() end,
        hideOurFrame = true,
    })
    fmMenu.Clique = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "Clique",
        showFunction = function() ShowUIPanel(CliqueConfig) end,
        hideOurFrame = true,
    })
    fmMenu.Outfitter = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "Outfitter",
        setting = GW.settings.windows.character.enabled,
        showFunction = function() hideCharframe = false Outfitter:OpenUI() end,
        hideOurFrame = true,
    })
    fmMenu.MyRolePlay = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "MyRolePlay",
        setting = GW.settings.windows.character.enabled,
        showFunction = function() hideCharframe = false ToggleCharacter("MyRolePlayCharacterFrame") end,
        hideOurFrame = true,
    })
    fmMenu.Ranker = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "Ranker",
        setting = GW.settings.windows.character.enabled,
        showFunction = function()
            RankerMainFrame:SetParent(GwCharacterWindow)
            RankerMainFrame:ClearAllPoints()
            RankerMainFrame:SetPoint("LEFT", GwCharacterWindow, "RIGHT", 0, 0)
            Ranker:ToggleWindow()
        end,
        hideOurFrame = false,
    })

    GW.ToggleCharacterItemInfo(true)
    CharacterFrame:SetScript("OnShow", function()
        if hideCharframe then
            HideUIPanel(CharacterFrame)
        end
        hideCharframe = true
    end)
    CharacterFrame:UnregisterAllEvents()
    hooksecurefunc("ToggleCharacter", toggleCharacter)

    dressingRoom.background:AddMaskTexture(tabContainer.CharWindow.backgroundMask)
end
GW.LoadPaperDoll = LoadPaperDoll
