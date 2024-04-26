local _, GW = ...
local CharacterMenuButton_OnLoad = GW.CharacterMenuButton_OnLoad
local CharacterMenuButtonBack_OnLoad = GW.CharacterMenuButtonBack_OnLoad

--local CHARACTER_PANEL_OPEN

local fmMenu
local hideCharframe = true
local prevAddonButtonAnchor = nil
local firstAddonMenuButtonAnchor

local function characterPanelToggle(frame)
    if InCombatLockdown() then
        GW.Notice(ERR_NOT_IN_COMBAT)
        return
    end
    fmMenu:Hide()
    GwPaperDollBagItemList:Hide()
    GwPaperDollOutfits:Hide()
    GwTitleWindow:Hide()

    if frame == nil then
        GwDressingRoom:Hide()
        return
    end

    frame:Show()
    GwDressingRoom:Show()
end
GW.AddForProfiling("paperdoll", "characterPanelToggle", characterPanelToggle)

local function toggleCharacter(tab, onlyShow)
    -- TODO: update bag frame to a secure stack, or at least the currency icon
    if InCombatLockdown() then
        return
    end

    if tab == "ReputationFrame" then
        if not onlyShow then
            GwCharacterWindow:SetAttribute("keytoggle", true)
        end
        GwCharacterWindow:SetAttribute("windowpanelopen", "reputation")
    elseif tab == "TokenFrame" then
        if not onlyShow then
            GwCharacterWindow:SetAttribute("keytoggle", true)
        end
        GwCharacterWindow:SetAttribute("windowpanelopen", "currency")
    else
        -- PaperDollFrame or any other value
        if not onlyShow then
            GwCharacterWindow:SetAttribute("keytoggle", true)
        end
        GwCharacterWindow:SetAttribute("windowpanelopen", "character")
    end
end
GW.AddForProfiling("paperdoll", "toggleCharacter", toggleCharacter)

local function back_OnClick()
    characterPanelToggle(fmMenu)
end
GW.AddForProfiling("paperdoll", "back_OnClick", back_OnClick)

local function menuItem_OnClick(self)
    characterPanelToggle(self.ToggleMe)
end
GW.AddForProfiling("paperdoll", "menuItem_OnClick", menuItem_OnClick)

local function menu_SetupBackButton(_, fmBtn, key)
    fmBtn:SetText(key)
    CharacterMenuButtonBack_OnLoad(fmBtn)
    fmBtn:SetScript("OnClick", back_OnClick)
end
GW.AddForProfiling("paperdoll", "menu_SetupBackButton", menu_SetupBackButton)

local isFirstAddonButton = true
local function addAddonButton(name, setting, showFunction)
    if C_AddOns.IsAddOnLoaded(name) and (setting == nil or setting == true) then
        fmMenu[name] = CreateFrame("Button", nil, fmMenu, "SecureHandlerClickTemplate,GwCharacterMenuButtonTemplate")
        fmMenu[name]:SetText(select(2, C_AddOns.GetAddOnInfo(name)))
        fmMenu[name]:ClearAllPoints()
        fmMenu[name]:SetPoint("TOPLEFT", isFirstAddonButton and firstAddonMenuButtonAnchor or prevAddonButtonAnchor, "BOTTOMLEFT")
        CharacterMenuButton_OnLoad(fmMenu[name])
        fmMenu[name]:SetFrameRef("charwin", GwCharacterWindow)
        fmMenu[name].ui_show = showFunction
        fmMenu[name]:SetAttribute("_onclick", [=[
            local fchar = self:GetFrameRef("charwin")
            if fchar then
                fchar:SetAttribute("windowpanelopen", nil)
            end
            self:CallMethod("ui_show")
        ]=])
        prevAddonButtonAnchor = fmMenu[name]
        isFirstAddonButton = false
    end
end

local function LoadPaperDoll(tabContainer)
    --local fmPD = CreateFrame("Frame", "GwPaperDoll", tabContainer, "GwPaperDoll")
    GwPaperDoll = tabContainer

    fmMenu = CreateFrame("Frame", nil, tabContainer, "GwCharacterMenu")
    fmMenu.SetupBackButton = menu_SetupBackButton

    GW.LoadPDBagList(fmMenu)
    GW.LoadPDEquipset(fmMenu)
    GW.LoadPDTitles(fmMenu)

    fmMenu.equipmentMenu = CreateFrame("Button", nil, fmMenu, "GwCharacterMenuButtonTemplate")
    fmMenu.equipmentMenu.ToggleMe = GwPaperDollBagItemList
    fmMenu.equipmentMenu:SetScript("OnClick", menuItem_OnClick)
    fmMenu.equipmentMenu:SetText(BAG_FILTER_EQUIPMENT)
    fmMenu.equipmentMenu:ClearAllPoints()
    fmMenu.equipmentMenu:SetPoint("TOPLEFT", fmMenu, "TOPLEFT")

    fmMenu.outfitsMenu = CreateFrame("Button", nil, fmMenu, "GwCharacterMenuButtonTemplate")
    fmMenu.outfitsMenu.ToggleMe = GwPaperDollOutfits
    fmMenu.outfitsMenu:SetScript("OnClick", menuItem_OnClick)
    fmMenu.outfitsMenu:SetText(EQUIPMENT_MANAGER)
    fmMenu.outfitsMenu:ClearAllPoints()
    fmMenu.outfitsMenu:SetPoint("TOPLEFT", fmMenu.equipmentMenu, "BOTTOMLEFT")

    fmMenu.titlesMenu = CreateFrame("Button", nil, fmMenu, "GwCharacterMenuButtonTemplate")
    fmMenu.titlesMenu.ToggleMe = GwTitleWindow
    fmMenu.titlesMenu:SetScript("OnClick", menuItem_OnClick)
    fmMenu.titlesMenu:SetText(PAPERDOLL_SIDEBAR_TITLES)
    fmMenu.titlesMenu:ClearAllPoints()
    fmMenu.titlesMenu:SetPoint("TOPLEFT", fmMenu.outfitsMenu, "BOTTOMLEFT")

    CharacterMenuButton_OnLoad(fmMenu.equipmentMenu, GW.nextHeroPanelMenuButtonShadowOdd)
    CharacterMenuButton_OnLoad(fmMenu.outfitsMenu, GW.nextHeroPanelMenuButtonShadowOdd)
    CharacterMenuButton_OnLoad(fmMenu.titlesMenu, GW.nextHeroPanelMenuButtonShadowOdd)

    -- pull corruption thingy from default paperdoll
    if (CharacterStatsPane and CharacterStatsPane.ItemLevelFrame) then
        local cpt = CharacterStatsPane.ItemLevelFrame.Corruption
        local attr = GwDressingRoom.stats
        if (cpt and attr) then
            cpt:SetParent(attr)
            cpt:ClearAllPoints()
            cpt:SetPoint("TOPRIGHT", attr, "TOPRIGHT", 22, 28)
        end
    end

    --AddOn Support
    firstAddonMenuButtonAnchor = fmMenu.titlesMenu
    addAddonButton("Pawn", nil, PawnUIShow)
    addAddonButton("Clique", GW.settings.USE_SPELLBOOK_WINDOW, function() ShowUIPanel(CliqueConfig) end)
    addAddonButton("Outfitter", GW.settings.USE_CHARACTER_WINDOW, function() hideCharframe = false Outfitter:OpenUI() end)
    addAddonButton("MyRolePlay", GW.settings.USE_CHARACTER_WINDOW, function() hideCharframe = false ToggleCharacter("MyRolePlayCharacterFrame") end)
    addAddonButton("TalentSetManager", GW.settings.USE_TALENT_WINDOW, function() TalentFrame_LoadUI() if PlayerTalentFrame_Toggle then PlayerTalentFrame_Toggle(TALENTS_TAB) end end)

    GW.ToggleCharacterItemInfo(true)
    CharacterFrame:SetScript(
        "OnShow",
        function()
            if hideCharframe then
                HideUIPanel(CharacterFrame)
            end
            hideCharframe = true
        end
    )

    CharacterFrame:UnregisterAllEvents()

    hooksecurefunc("ToggleCharacter", toggleCharacter)
    hooksecurefunc("PaperDollFrame_UpdateCorruptedItemGlows", function(glow)
        for _, v in pairs(GW.char_equipset_SavedItems) do
            if v.HasPaperDollAzeriteItemOverlay then
                v:UpdateCorruptedGlow(ItemLocation:CreateFromEquipmentSlot(v:GetID()), glow)
            end
        end
    end)
    GwDressingRoom.background:AddMaskTexture(GwCharacterWindow.backgroundMask)
end
GW.LoadPaperDoll = LoadPaperDoll
