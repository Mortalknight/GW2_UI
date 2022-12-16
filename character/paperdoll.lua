local _, GW = ...
local CharacterMenuButton_OnLoad = GW.CharacterMenuButton_OnLoad
local CharacterMenuButtonBack_OnLoad = GW.CharacterMenuButtonBack_OnLoad
local GetSetting = GW.GetSetting

--local CHARACTER_PANEL_OPEN

local fmMenu
local hideCharframe = true

local function characterPanelToggle(frame)
    if InCombatLockdown() then
        DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. ERR_NOT_IN_COMBAT):gsub("*", GW.Gw2Color))
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

local nextShadow, nextAnchor
local function addAddonButton(name, setting, shadow, anchor, showFunction)
    if IsAddOnLoaded(name) and (setting == nil or setting == true) then
        fmMenu.buttonName = CreateFrame("Button", nil, fmMenu, "SecureHandlerClickTemplate,GwCharacterMenuButtonTemplate")
        fmMenu.buttonName:SetText(select(2, GetAddOnInfo(name)))
        fmMenu.buttonName:ClearAllPoints()
        fmMenu.buttonName:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT")
        CharacterMenuButton_OnLoad(fmMenu.buttonName, shadow)
        fmMenu.buttonName:SetFrameRef("charwin", GwCharacterWindow)
        fmMenu.buttonName.ui_show = showFunction
        fmMenu.buttonName:SetAttribute("_onclick", [=[
            local fchar = self:GetFrameRef("charwin")
            if fchar then
                fchar:SetAttribute("windowpanelopen", nil)
            end
            self:CallMethod("ui_show")
        ]=])
        nextShadow = not nextShadow
        nextAnchor = fmMenu.buttonName
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

    CharacterMenuButton_OnLoad(fmMenu.equipmentMenu, false)
    CharacterMenuButton_OnLoad(fmMenu.outfitsMenu, true)
    CharacterMenuButton_OnLoad(fmMenu.titlesMenu, false)

    GearManagerPopupFrame:HookScript("OnShow", function(frame)
        if frame.isSkinned then return end
        GW.HandleIconSelectionFrame(frame)
    end)

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
    nextShadow = true
    nextAnchor = fmMenu.titlesMenu
    addAddonButton("Pawn", nil, nextShadow, nextAnchor, PawnUIShow)
    addAddonButton("Clique", GetSetting("USE_SPELLBOOK_WINDOW"), nextShadow, nextAnchor, function() ShowUIPanel(CliqueConfig) end)
    addAddonButton("Outfitter", GetSetting("USE_CHARACTER_WINDOW"), nextShadow, nextAnchor, function() hideCharframe = false Outfitter:OpenUI() end)
    addAddonButton("MyRolePlay", GetSetting("USE_CHARACTER_WINDOW"), nextShadow, nextAnchor, function() hideCharframe = false ToggleCharacter("MyRolePlayCharacterFrame") end)
    addAddonButton("TalentSetManager", GetSetting("USE_TALENT_WINDOW"), nextShadow, nextAnchor, function() TalentFrame_LoadUI() if PlayerTalentFrame_Toggle then PlayerTalentFrame_Toggle(TALENTS_TAB) end end)

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
end
GW.LoadPaperDoll = LoadPaperDoll
