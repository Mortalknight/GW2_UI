local _, GW = ...
local CharacterMenuButton_OnLoad = GW.CharacterMenuButton_OnLoad
local CharacterMenuButtonBack_OnLoad = GW.CharacterMenuButtonBack_OnLoad

--local CHARACTER_PANEL_OPEN

local fmMenu
local hideCharframe = true
local prevAddonButtonAnchor = nil
local firstAddonMenuButtonAnchor

local dressingRoom
local paperDollBagItemList
local paperDollOutfits
local paperDollTitles

local function characterPanelToggle(frame)
    if InCombatLockdown() then
        GW.Notice(ERR_NOT_IN_COMBAT)
        return
    end
    fmMenu:Hide()
    paperDollBagItemList:Hide()
    paperDollOutfits:Hide()
    paperDollTitles:Hide()

    if frame == nil then
        dressingRoom:Hide()
        return
    end

    frame:Show()
    dressingRoom:Show()
end


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


local function back_OnClick()
    characterPanelToggle(fmMenu)
end


local function menuItem_OnClick(self)
    characterPanelToggle(self.ToggleMe)
end


local function menu_SetupBackButton(_, fmBtn, key)
    fmBtn:SetText(key)
    fmBtn:GetFontString():GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
    CharacterMenuButtonBack_OnLoad(fmBtn)
    fmBtn:SetScript("OnClick", back_OnClick)
end


local isFirstAddonButton = true
local function addAddonButton(name, setting, showFunction)
    if C_AddOns.IsAddOnLoaded(name) and (setting == nil or setting == true) then
        fmMenu[name] = CreateFrame("Button", nil, fmMenu, "SecureHandlerClickTemplate,GwHeroPanelMenuButtonTemplate")
        fmMenu[name]:SetText(select(2, C_AddOns.GetAddOnInfo(name)))
        fmMenu[name]:GetFontString():GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
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
    fmMenu = CreateFrame("Frame", nil, tabContainer, "GwHeroPanelMenuTemplate")
    fmMenu.SetupBackButton = menu_SetupBackButton

    dressingRoom, paperDollBagItemList = GW.LoadPDBagList(fmMenu, tabContainer)
    paperDollOutfits = GW.LoadPDEquipset(fmMenu, tabContainer)
    paperDollTitles = GW.LoadPDTitles(fmMenu, tabContainer)

    fmMenu.equipmentMenu = CreateFrame("Button", nil, fmMenu, "GwHeroPanelMenuButtonTemplate")
    fmMenu.equipmentMenu.ToggleMe = paperDollBagItemList
    fmMenu.equipmentMenu:SetScript("OnClick", menuItem_OnClick)
    fmMenu.equipmentMenu:SetText(BAG_FILTER_EQUIPMENT)
    fmMenu.equipmentMenu:GetFontString():GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
    fmMenu.equipmentMenu:ClearAllPoints()
    fmMenu.equipmentMenu:SetPoint("TOPLEFT", fmMenu, "TOPLEFT")

    fmMenu.outfitsMenu = CreateFrame("Button", nil, fmMenu, "GwHeroPanelMenuButtonTemplate")
    fmMenu.outfitsMenu.ToggleMe = paperDollOutfits
    fmMenu.outfitsMenu:SetScript("OnClick", menuItem_OnClick)
    fmMenu.outfitsMenu:SetText(EQUIPMENT_MANAGER)
    fmMenu.outfitsMenu:GetFontString():GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
    fmMenu.outfitsMenu:ClearAllPoints()
    fmMenu.outfitsMenu:SetPoint("TOPLEFT", fmMenu.equipmentMenu, "BOTTOMLEFT")

    fmMenu.titlesMenu = CreateFrame("Button", nil, fmMenu, "GwHeroPanelMenuButtonTemplate")
    fmMenu.titlesMenu.ToggleMe = paperDollTitles
    fmMenu.titlesMenu:SetScript("OnClick", menuItem_OnClick)
    fmMenu.titlesMenu:SetText(PAPERDOLL_SIDEBAR_TITLES)
    fmMenu.titlesMenu:GetFontString():GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
    fmMenu.titlesMenu:ClearAllPoints()
    fmMenu.titlesMenu:SetPoint("TOPLEFT", fmMenu.outfitsMenu, "BOTTOMLEFT")

    CharacterMenuButton_OnLoad(fmMenu.equipmentMenu, GW.nextHeroPanelMenuButtonShadowOdd)
    CharacterMenuButton_OnLoad(fmMenu.outfitsMenu, GW.nextHeroPanelMenuButtonShadowOdd)
    CharacterMenuButton_OnLoad(fmMenu.titlesMenu, GW.nextHeroPanelMenuButtonShadowOdd)

    -- pull corruption thingy from default paperdoll
    if (CharacterStatsPane and CharacterStatsPane.ItemLevelFrame) then
        local cpt = CharacterStatsPane.ItemLevelFrame.Corruption
        local attr = dressingRoom.stats
        if (cpt and attr) then
            cpt:SetParent(attr)
            cpt:ClearAllPoints()
            cpt:SetPoint("TOPRIGHT", attr, "TOPRIGHT", 22, 28)
        end
    end

    --AddOn Support
    firstAddonMenuButtonAnchor = fmMenu.titlesMenu
    addAddonButton("Pawn", nil, PawnUIShow)
    addAddonButton("Clique", nil, function() ShowUIPanel(CliqueConfig) end)
    addAddonButton("Outfitter", GW.settings.USE_CHARACTER_WINDOW, function() hideCharframe = false Outfitter:OpenUI() end)
    addAddonButton("MyRolePlay", GW.settings.USE_CHARACTER_WINDOW, function() hideCharframe = false ToggleCharacter("MyRolePlayCharacterFrame") end)
    addAddonButton("TalentSetManager", GW.settings.USE_TALENT_WINDOW, function() TalentFrame_LoadUI() if PlayerTalentFrame_Toggle then PlayerTalentFrame_Toggle(TALENTS_TAB) end end)
    addAddonButton("ItemUpgradeTip", nil, function() if ItemUpgradeTip then ItemUpgradeTip:ToggleView() end end)

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
    dressingRoom.background:AddMaskTexture(tabContainer.CharWindow.backgroundMask)
end
GW.LoadPaperDoll = LoadPaperDoll
