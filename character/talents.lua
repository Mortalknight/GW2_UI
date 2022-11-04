local _, GW = ...
local CharacterMenuButton_OnLoad = GW.CharacterMenuButton_OnLoad

local function UpdateMenuTreeButtonText(self, text)
    self:SetText(text)
end

local function UpdateMenu(menu)
    local classInfo = C_CreatureInfo.GetClassInfo(GW.myClassID)
	local specName = select(2, GetSpecializationInfoByID(PlayerUtil.GetCurrentSpecID()))

    UpdateMenuTreeButtonText(menu.tree1, classInfo and classInfo.className or UNKNOWN)
    UpdateMenuTreeButtonText(menu.tree2, specName)
end

local function UpdateBackground(container)
    local currentSpecID = PlayerUtil.GetCurrentSpecID()
	local atlas = ClassTalentUtil.GetAtlasForSpecID(currentSpecID)
	if atlas and C_Texture.GetAtlasInfo(atlas) then
        for _, v in pairs(container.tabContainers) do
            v.background:SetAtlas(atlas, TextureKitConstants.UseAtlasSize)

            if not v.maskedAdded then
                --setup background mask
                local mask = v:CreateMaskTexture()
                mask:SetPoint("TOPLEFT", v, "TOPLEFT", 0, 0)
                mask:SetPoint("BOTTOMRIGHT", v, "BOTTOMRIGHT", -2, -228)
                mask:SetTexture("Interface/AddOns/GW2_UI/textures/character/windowbg", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                v.background:AddMaskTexture(mask)

                v.maskedAdded = true
            end
        end
	end
end

local function RefreshCurrencyDisplay(self)
    local configId = ClassTalentFrame.TalentsTab:GetConfigID()
    local talentTreeId = ClassTalentFrame.TalentsTab:GetTalentTreeID()
    local excludeStagedChangesForCurrencies = ClassTalentFrame.TalentsTab.excludeStagedChangesForCurrencies
    local counter, treeCurrencyInfo, textColor

    if configId and configId > 0 and talentTreeId and talentTreeId > 0 then
        treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(configId, talentTreeId, excludeStagedChangesForCurrencies)
    end

    for _, v in pairs(self.tabContainers) do
        counter = treeCurrencyInfo and treeCurrencyInfo[v.index].quantity or 0
        textColor = counter > 0 and GREEN_FONT_COLOR or GRAY_FONT_COLOR

        v.currencyLabel:SetText(TALENT_FRAME_CURRENCY_DISPLAY_FORMAT:format(string.upper(v:GetParent().menuItems[v.index]:GetText())))
        v.currencyAmmount:SetText(counter)
        v.currencyAmmount:SetTextColor(textColor:GetRGBA())
    end
end

local function SetupTreeContainer(fmTalents, index)
    local container = CreateFrame("Frame", "TreeContainer" .. index, fmTalents, "GwTalentskContainerTab")

    container.index = index

    return container
end

local function fmTalentsOnEvent(self, event, ...)
    if event == "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" then
        UpdateMenu(self)
        UpdateBackground(self)
    elseif event == "PLAYER_ENTERING_WORLD" then
        UpdateBackground(self)
    end

    -- Update TalentPoints
    RefreshCurrencyDisplay(self)
end

local function menuItem_OnClick(self)
    local menuItems = self:GetParent().menuItems
    for _, v in pairs(menuItems) do
        v:ClearNormalTexture()
    end
    self:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
end

local function LoadTalents(tabContainer)
    local talentContainer = CreateFrame("Frame", "GwTalentFrame", tabContainer, "SecureHandlerStateTemplate, GwTalentsWindow")
    local fmTalents = CreateFrame("Frame", "GwTalentsMenu", talentContainer, "GwTalentsMenu")
    GwCharacterWindow:SetFrameRef("GwTalentsMenu", fmTalents)

    UpdateMenu(fmTalents)

    fmTalents.menuItems = {}
    fmTalents.menuItems[1] = fmTalents.tree1
    fmTalents.menuItems[2] = fmTalents.tree2

    CharacterMenuButton_OnLoad(fmTalents.tree1, true)
    CharacterMenuButton_OnLoad(fmTalents.tree2, false)
    fmTalents.menuItems[1]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")

    fmTalents.tabContainers = {}
    fmTalents:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    fmTalents:RegisterEvent("PLAYER_TALENT_UPDATE")
    fmTalents:RegisterEvent("PLAYER_ENTERING_WORLD")
    fmTalents:RegisterEvent("TRAIT_TREE_CURRENCY_INFO_UPDATED")
    fmTalents:RegisterEvent("CONFIG_COMMIT_FAILED")
    fmTalents:RegisterEvent("TRAIT_CONFIG_UPDATED")
    fmTalents:RegisterEvent("CONFIG_COMMIT_FAILED")
    fmTalents:RegisterEvent("TRAIT_NODE_CHANGED")
    fmTalents:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")
    fmTalents:SetScript("OnEvent", fmTalentsOnEvent)

    fmTalents.tabContainers[1] = SetupTreeContainer(fmTalents, 1)
    fmTalents.tabContainers[2] = SetupTreeContainer(fmTalents, 2)

    fmTalents.tabContainers[1]:Show()

    fmTalents.tree1:HookScript("OnClick", menuItem_OnClick)
    fmTalents.tree2:HookScript("OnClick", menuItem_OnClick)

    fmTalents.tree1:RegisterForClicks("AnyUp")
    fmTalents.tree1:SetFrameRef("GwTalentsMenu", fmTalents)
    fmTalents.tree1:SetAttribute(
        "_onclick",
        [=[
            self:GetFrameRef('GwTalentsMenu'):SetAttribute('tabopen',1)
        ]=]
    )
    fmTalents.tree2:RegisterForClicks("AnyUp")
    fmTalents.tree2:SetFrameRef("GwTalentsMenu", fmTalents)
    fmTalents.tree2:SetAttribute(
        "_onclick",
        [=[
            self:GetFrameRef('GwTalentsMenu'):SetAttribute('tabopen',2)
        ]=]
    )

    fmTalents:SetFrameRef("GwTalentsTree1Container", fmTalents.tabContainers[1])
    fmTalents:SetFrameRef("GwTalentsTree2Container", fmTalents.tabContainers[2])

    fmTalents:SetAttribute(
        "_onattributechanged",
        [=[
            if name ~= 'tabopen' then return end

            self:GetFrameRef('GwTalentsTree1Container'):Hide()
            self:GetFrameRef('GwTalentsTree2Container'):Hide()
        
            if value == 1 then
                self:GetFrameRef('GwTalentsTree1Container'):Show()
                return
            elseif value == 2 then
                self:GetFrameRef('GwTalentsTree2Container'):Show()
                return
            end
        ]=]
    )
    fmTalents:SetAttribute("tabOpen", 1)

    talentContainer:HookScript(
        "OnShow",
        function()
            if InCombatLockdown() then
                return
            end
            --update here
            RefreshCurrencyDisplay(fmTalents)
        end
    )

    return talentContainer
end
GW.LoadTalents = LoadTalents