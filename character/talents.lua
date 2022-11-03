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

local function SetupTreeContainer(fmTalents, index)
    local container = CreateFrame("Frame", "TreeContainer" .. index, fmTalents, "GwTalentskContainerTab")
    local configId = ClassTalentFrame.TalentsTab:GetConfigID()
    local talentTreeId = ClassTalentFrame.TalentsTab:GetTalentTreeID()
    local excludeStagedChangesForCurrencies = ClassTalentFrame.TalentsTab.excludeStagedChangesForCurrencies
    local counter = 0

    if configId and configId > 0 and talentTreeId and talentTreeId > 0 then
        local treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(configId, talentTreeId, excludeStagedChangesForCurrencies)
        counter = treeCurrencyInfo[index].quantity
    end

    local enabled = counter > 0
	local textColor = enabled and GREEN_FONT_COLOR or GRAY_FONT_COLOR

    container.currencyLabel:SetText(TALENT_FRAME_CURRENCY_DISPLAY_FORMAT:format(string.upper(fmTalents.menuItems[index]:GetText())))
    container.currencyAmmount:SetText(counter)
    container.currencyAmmount:SetTextColor(textColor:GetRGBA())
    return container
end

local function fmTalentsOnEvent(self, event, ...)
    UpdateMenu(self)

    -- Update Background
    UpdateBackground(self)
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
    fmTalents:SetScript("OnEvent", fmTalentsOnEvent)

    fmTalents.tabContainers[1] = SetupTreeContainer(fmTalents, 1)
    fmTalents.tabContainers[2] = SetupTreeContainer(fmTalents, 2)

    fmTalents.tabContainers[1]:Show()

    UpdateBackground(fmTalents)

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
        end
    )

    return talentContainer
end
GW.LoadTalents = LoadTalents