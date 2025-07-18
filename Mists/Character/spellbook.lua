local _, GW = ...

local function SpellButton_OnModifiedClick(self)
    local slot = self.spellbookIndex
    local book = self.booktype
    if IsModifiedClick("CHATLINK") then
        if MacroFrameText and MacroFrameText:HasFocus() then
            local spell, subSpell = GetSpellBookItemName(slot, book)
            if spell and not IsPassiveSpell(slot, book) then
                if subSpell and strlen(subSpell) > 0 then
                    ChatEdit_InsertLink(spell .. "(" .. subSpell .. ")")
                else
                    ChatEdit_InsertLink(spell)
                end
            end
        else
            local profLink, profId = GetSpellTradeSkillLink(slot, book)
            if profId then
                ChatEdit_InsertLink(profLink)
            else
                ChatEdit_InsertLink(GetSpellLink(slot, book))
            end
        end
    elseif IsModifiedClick("PICKUPACTION") and not InCombatLockdown() and not IsPassiveSpell(slot, book) then
        PickupSpellBookItem(slot, book)
    end
end

local function spell_buttonOnEnter(self)
    if self.spellId == nil then return end
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()
    local isPet = false

    if self.booktype == "pet" then isPet = true end

    if IsSpellKnown(self.spellId, isPet) and self.futureSpellOverrider == nil then
         GameTooltip:SetSpellBookItem(self.spellbookIndex, self.booktype)
    elseif self.isFlyout then
        local name, desc = GetFlyoutInfo(self.spellId)
        GameTooltip:AddLine(name)
        GameTooltip:AddLine(desc)
    else
        GameTooltip:SetSpellByID(self.spellId)
        if self.requiredLevel then
            GameTooltip:AddLine(" ")
            if self.requiredLevel <= GW.mylevel then
                GameTooltip:AddLine("|c0423ff2f" .. AVAILABLE .. "|r", 1, 1, 1)
            else
                GameTooltip:AddLine("|c00ff0000" .. UNLOCKED_AT_LEVEL:format(self.requiredLevel) .. "|r", 1, 1, 1)
            end
        end
    end
    GameTooltip:Show()
end

local function spellbookButton_onEvent(self)
    if not GwSpellbook:IsShown() or not self.cooldown or not self.spellId then return end

    local start, duration, enable, modRate = GetSpellCooldown(self.spellId)

    if start and duration then
        if enable == 1 then
            self.cooldown:Hide()
        else
            self.cooldown:Show()
        end
        CooldownFrame_Set(self.cooldown, start, duration, enable, false, modRate)
    else
        self.cooldown:Hide()
    end
end

local function getSpellBookHeader(self, tab)
    local index = self.container[tab].HeaderIndex
    local header = self.container[tab].headerFrame[index]
    if header then
        return header
    end

    header = CreateFrame("Frame", nil, self.container[tab], "GwSpellbookActionButtonHeaderTemplate")
    header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL, "OUTLINE")
    header.subTitle:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.SMALL, "OUTLINE")
    tinsert(self.container[tab].headerFrame, header)
    return header
end

local function setHeaderLocation(self, header, pagingContainer, spellBookTab)
    local prev

    if pagingContainer.headers[#pagingContainer.headers] then
        prev = pagingContainer.headers[#pagingContainer.headers]
    end
    header:ClearAllPoints()
    header:SetParent(pagingContainer)

    if prev then
        if ((#pagingContainer.headers + 1) % 2) == 0 then
            local prev2

            if pagingContainer.headers[#pagingContainer.headers - 1] then
                prev2 = pagingContainer.headers[#pagingContainer.headers - 1]
            end
            if prev2 then
                header:SetPoint("TOPLEFT", prev2, "BOTTOMLEFT", 0, -5)
                header.column = 2
            else
                header:SetPoint("TOPLEFT", prev, "TOPRIGHT", 0, 0)
                header.column = 2
            end
        else
            prev = pagingContainer.headers[#pagingContainer.headers - 1]
            header:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -5)
            header.column = 1
        end
    else
        header:SetPoint("TOPLEFT", pagingContainer, "TOPLEFT", 0, 0)
        header.column = 1
    end

    pagingContainer.headers[#pagingContainer.headers + 1] = header
    self.container[spellBookTab].HeaderIndex = self.container[spellBookTab].HeaderIndex + 1
end

local function GetSpellbookActionButton(tab, container, index)
    local button = tab.buttons[index]

    if button then
        button.isPassive = nil
        button.isFuture = nil
        button.isFlyout = nil
        button.spellbookIndex = nil
        button.booktype = nil
        button.spellId = nil
        button.requiredLevel = nil

        button:SetAttribute("type1", nil)
        button:SetAttribute("type2", nil)
        button:SetAttribute("spell", nil)
        button:SetAttribute("flyout", nil)
        button:SetAttribute("flyoutDirection", nil)
        button:SetAttribute("shift-type1", nil)
        button:SetAttribute("shift-type2", nil)
        button:SetAttribute("*macrotext2", nil)
        button:SetAttribute("ispickable", nil)
        return button
    end

    button = CreateFrame("Button", nil, container, "GwSpellbookActionbutton")
    button.mask = UIParent:CreateMaskTexture()
    button.mask:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.mask:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_border", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    button.mask:SetSize(40, 40)
    button.mask:SetParent(button)

    button.modifiedClick = SpellButton_OnModifiedClick
    button:RegisterForClicks("AnyUp")
    button:RegisterForDrag("LeftButton")
    button:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    button:RegisterEvent("PET_BAR_UPDATE")
    button:SetScript("OnEnter", spell_buttonOnEnter)
    button:HookScript("OnLeave", GameTooltip_Hide)
    button:Hide()

    tinsert(tab.buttons, button)

    return button
end

local function setButtonStyle(btn, isPassive, spellID, slotType, icon, spellbookIndex, booktype, name, requiredLevel, isOffSpec)
    local _, autostate = GetSpellAutocast(spellbookIndex, booktype)
    btn.isPassive = isPassive
    btn.isFuture = (slotType == "FUTURESPELL")
    btn.isFlyout = (slotType == "FLYOUT")
    btn.spellbookIndex = spellbookIndex
    btn.booktype = booktype
    btn:EnableMouse(true)
    btn.spellId = spellID
    btn.icon:SetTexture(icon)
    btn:SetAlpha(1)
    btn:SetAttribute("ispickable", false)

    btn.autocast:SetShown(autostate)
    btn.arrow:SetShown(btn.isFlyout)

    btn:SetScript("OnEvent", spellbookButton_onEvent)

    if btn.isFlyout then
        btn:SetAttribute("type1", "flyout")
        btn:SetAttribute("type2", "flyout")
        btn:SetAttribute("spell", spellID)
        btn:SetAttribute("flyout", spellID)
        btn:SetAttribute("flyoutDirection", "RIGHT")
        btn:SetAttribute("shift-type1", "modifiedClick")
        btn:SetAttribute("shift-type2", "modifiedClick")
    elseif not btn.isFuture and booktype == BOOKTYPE_PET then
        btn:SetAttribute("type1", "spell")
        btn:SetAttribute("type2", "macro")
        btn:SetAttribute("spell", spellID)
        if name ~= nil then
            btn:SetAttribute("*macrotext2", "/petautocasttoggle " .. name)
        end
        btn:SetAttribute("shift-type1", "modifiedClick")
        btn:SetAttribute("shift-type2", "modifiedClick")
    elseif not btn.isFuture then
        btn:SetAttribute("ispickable", not isOffSpec)
        btn:SetAttribute("type1", "spell")
        btn:SetAttribute("type2", "spell")
        btn:SetAttribute("spell", spellID)
        btn:SetAttribute("shift-type1", "modifiedClick")
        btn:SetAttribute("shift-type2", "modifiedClick")
    else
        btn:SetAttribute("shift-type1", "modifiedClick")
        btn:SetAttribute("shift-type2", "modifiedClick")
    end

    if slotType ~= "FUTURESPELL" then
        if slotType == "SPELL" and isOffSpec then
			local level = GetSpellLevelLearned(spellID)
			if level and level > GW.mylevel then
				btn.requiredLevel = level
			end
		end
    else
        if requiredLevel and requiredLevel > GW.mylevel then
            btn.requiredLevel = requiredLevel
        end
    end

    if btn.requiredLevel and btn.requiredLevel > GW.mylevel then
        btn.lock:Show()
    else
        btn.lock:Hide()
    end

    if btn.isFuture then
        btn.icon:SetDesaturated(true)
        btn.icon:SetAlpha(0.5)
    elseif btn.isFlyout then
        btn.icon:SetDesaturated(false)
        btn.icon:SetAlpha(1)
    else
        btn.icon:SetDesaturated(false)
        btn.icon:SetAlpha(1)
    end

    if btn.isPassive then
        btn.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_highlight")
        btn.icon:AddMaskTexture(btn.mask)
        btn.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_outline")
    else
        btn.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/active_highlight")
        btn.icon:RemoveMaskTexture(btn.mask)
        btn.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/background_border")
    end

    btn.icon:SetDesaturated(isOffSpec)

    spellbookButton_onEvent(btn)
    btn:Show()
end

local function getHeaderHeight(pagingContainer, lastHeader)
    local lastColumn = 1
    if lastHeader then
        lastColumn = lastHeader.column
    end
    local c1 = 0
    local c2 = 0
    for _, h in pairs(pagingContainer.headers) do
        if h.column == 1 then
            c1 = c1 + h.height
        else
            c2 = c2 + h.height
        end
    end
    if lastColumn == 2 then
        return c1
    end
    return c2
end

local function setUpPaging(self)
    self.left:SetFrameRef("tab", self.attrDummy)
    self.left:SetAttribute("_onclick", [=[
        self:GetFrameRef("tab"):SetAttribute("page", "left")
    ]=])

    self.right:SetFrameRef("tab", self.attrDummy)
    self.right:SetAttribute("_onclick", [=[
        self:GetFrameRef("tab"):SetAttribute("page", "right")
    ]=])
    self.attrDummy:SetAttribute("neededContainers", self.tabs)

    self.attrDummy:SetFrameRef("container1", self.container1)
    self.attrDummy:SetFrameRef("container2", self.container2)
    self.attrDummy:SetFrameRef("container3", self.container3)
    self.attrDummy:SetFrameRef("container4", self.container4)
    self.attrDummy:SetFrameRef("container5", self.container5)
    self.attrDummy:SetFrameRef("container6", self.container6)
    self.attrDummy:SetFrameRef("container7", self.container7)
    self.attrDummy:SetFrameRef("container8", self.container8)
    self.attrDummy:SetFrameRef("left", self.left)
    self.attrDummy:SetFrameRef("right", self.right)
    self.attrDummy:SetAttribute("_onattributechanged", ([=[
        if name ~= "page" then return end

        local left = self:GetFrameRef("left")
        local right = self:GetFrameRef("right")

        local maxNumberOfContainers = 8
        local container
        local showNext = false
        local hadSomethingToShow = false

        local currentPage = 1
        local neededContainers = self:GetAttribute("neededContainers")

        if value == "left" then -- container -1
            for i = maxNumberOfContainers, 1, -1 do
                container = self:GetFrameRef("container" .. i)
                if container:IsVisible() then
                    container:Hide()
                    showNext = true
                else
                    if showNext then
                        container:Show()
                        showNext = false
                        hadSomethingToShow = true
                        currentPage = i
                    else
                        container:Hide()
                    end
                end

                if i == 1 and not hadSomethingToShow then
                    self:GetFrameRef("container" .. i):Show()
                    currentPage = i
                end
            end
        end
        if value == "right" then -- container +1
            for i = 1, maxNumberOfContainers do
                container = self:GetFrameRef("container" .. i)

                if container:IsVisible() then
                    container:Hide()
                    showNext = true
                else
                    if showNext then
                        container:Show()
                        showNext = false
                        currentPage = i
                    else
                        container:Hide()
                    end
                end
            end
        end
        if currentPage >= neededContainers then
            right:Hide()
        else
            right:Show()
        end
        if currentPage == 1 then
            left:Hide()
        else
            left:Show()
        end
    ]=]))
    self.attrDummy:SetAttribute("page", "left")
end

local function resetSpellbookPages(self)
    for tab = 1, #self.tabs do
        for i = 1, #self.tabs[tab].buttons do
            self.tabs[tab].buttons[i]:SetAlpha(0)
            self.tabs[tab].buttons[i]:EnableMouse(false)
            self.tabs[tab].buttons[i]:SetScript("OnEvent", nil)
        end
    end
    for container = 1, #self.container do
        for i = 1, #self.container[container].headerFrame do
            self.container[container].headerFrame[i]:Hide()
        end
    end
end

local function updateSpellbookTab(self)
    if self.updating then return end
    self.updating = true
    if InCombatLockdown() then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self.updating = false
        return
    end

    resetSpellbookPages(self)

    for spellBookTab = 1, 5 do
        local name, texture, offset, numSpells, _, offSpecID = GetSpellTabInfo(spellBookTab)
        local BOOKTYPE = BOOKTYPE_SPELL

        local pagingID = 1
        local tab = self.tabs[spellBookTab]
        local container = self.container[spellBookTab]
        local pagingContainer = container["container" .. pagingID]
        container.tabs = 1
        container.HeaderIndex = 1

        if spellBookTab == 5 then
            BOOKTYPE = BOOKTYPE_PET
            numSpells = HasPetSpells() or 0
            offset = 0
            name = PET
            texture = "Interface/AddOns/GW2_UI/textures/talents/tabicon_pet"
        end

        local boxIndex = 1
        local lastName = ""
        local lastButton
        local header
        local needNewHeader = true
        local isOffSpec = (offSpecID ~= 0) and (BOOKTYPE == BOOKTYPE_SPELL)

        tab.icon:SetTexture(texture)
        tab.title:SetText(name)
        container.title:SetText(name)
        tab.icon:SetDesaturated(isOffSpec)

        pagingContainer.headers = {}

        for i = 1, numSpells do
            local spellIndex = i + offset
            local slotType, slotID = GetSpellBookItemInfo(spellIndex, BOOKTYPE)
            local icon = GetSpellBookItemTexture(spellIndex, BOOKTYPE)
            local nameSpell, _, spellID = GetSpellBookItemName(spellIndex, BOOKTYPE)
            local isPassive = IsPassiveSpell(spellID)
            local requiredLevel = GetSpellAvailableLevel(spellIndex, BOOKTYPE)

            if nameSpell then
                needNewHeader = true
                if lastName == nameSpell then
                    needNewHeader = false
                end

                local button = GetSpellbookActionButton(tab, pagingContainer, i)
                setButtonStyle(button, isPassive, spellID or slotID, slotType, icon, spellIndex, BOOKTYPE, nameSpell, requiredLevel, isOffSpec)
                if not isPassive then GW.RegisterCooldown(button.cooldown) end
                boxIndex = boxIndex + 1

                if needNewHeader then
                    local currentHeight = getHeaderHeight(pagingContainer, header)
                    if currentHeight > (pagingContainer:GetHeight() - 120) then
                        pagingID = pagingID + 1
                        pagingContainer = container["container" .. pagingID]
                        pagingContainer.headers = {}
                        container.tabs = pagingID
                    end
                    header = getSpellBookHeader(self, spellBookTab)
                    setHeaderLocation(self, header, pagingContainer, spellBookTab)
                    header.title:SetText(nameSpell)
                    header.buttons = 1
                    header.height = 80
                    header:Show()

                    -- get subtext
                    if spellID then
                        local specs =  {GetSpecsForSpell(spellIndex, BOOKTYPE)}
                        local specName = table.concat(specs, PLAYER_LIST_DELIMITER)
                        local spell = Spell:CreateFromSpellID(spellID)
                        spell:ContinueOnSpellLoad(function()
                            local subSpellName = spell:GetSpellSubtext()
                            if subSpellName == "" then
                                if specName and specName ~= "" then
                                    if isPassive then
                                        subSpellName = specName .. ", " .. SPELL_PASSIVE_SECOND
                                    else
                                        subSpellName = specName
                                    end
                                elseif IsTalentSpell(spellIndex, BOOKTYPE) then
                                    if isPassive then
                                        subSpellName = TALENT_PASSIVE
                                    else
                                        subSpellName = TALENT
                                    end
                                elseif isPassive then
                                    subSpellName = SPELL_PASSIVE
                                end
                            end

                            header.subTitle:SetText(subSpellName)
                        end)
                    end
                end

                button:ClearAllPoints()
                button:SetParent(header)
                if needNewHeader then
                    button:SetPoint("TOPLEFT", header, "TOPLEFT", 15, -38)
                    header.firstButton = button
                else
                    if header.buttons == 6 then
                        button:SetPoint("TOPLEFT", header.firstButton, "BOTTOMLEFT", 0, -5)
                        header.height = header.height + 45
                    else
                        button:SetPoint("LEFT", lastButton, "RIGHT", 5, 0)
                    end
                    header.buttons = header.buttons + 1
                end

                header:SetHeight(header.height)
                lastName = nameSpell
                lastButton = button
            end
            setUpPaging(container)
        end
    end
    self.updating = false
end

local function SpellBookTabOnClick(self, spellBook)
    for i = 1, #spellBook.tabs do
        spellBook.tabs[i].background:Hide()
    end
    self.background:Show()
end

local function QueuedUpdate(self)
    self:SetScript("OnUpdate", nil)
    updateSpellbookTab(self)
end

local function OnEvent(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent(event)
        C_Timer.After(0.1, function() updateSpellbookTab(self) end)
        return
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        self:SetScript("OnUpdate", QueuedUpdate)
        return
    end

    if not self:IsShown() then
        return
    end
    self:SetScript("OnUpdate", QueuedUpdate)
end

local function LoadSpellBook()
    local spellBook = CreateFrame("Frame", "GwSpellbook", GwCharacterWindow, "GwSpellbook")
    local menu = CreateFrame("Frame", "GwSpellbookMenu", GwSpellbook, "GwSpellbookMenu")

	spellBook:RegisterEvent("LEARNED_SPELL_IN_TAB")
	spellBook:RegisterEvent("PLAYER_GUILD_UPDATE")
	spellBook:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    spellBook:SetScript("OnEvent", OnEvent)
    spellBook:Hide()

    spellBook.tabs = {}
    spellBook.container = {}

    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("TOPLEFT", GwCharacterWindow, "TOPLEFT", 0, 0)
    mask:SetTexture("Interface/AddOns/GW2_UI/textures/character/windowbg-mask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(853, 853)

    for tab = 1, 5 do
        local menuItem = CreateFrame("Button", "GwspellbookTab" .. tab, menu, "GwspellbookTab")
        menuItem:SetPoint("TOPLEFT", menu, "TOPLEFT", 0, -menuItem:GetHeight() * (tab - 1))
        local container = CreateFrame("Frame", "GwSpellbookContainerTab" .. tab, spellBook, "GwSpellbookContainerTab")
        container.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, "OUTLINE")
        container.title:SetTextColor(0.9, 0.9, 0.7, 1)
        container.pages:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, "OUTLINE", 2)
        container.pages:SetTextColor(0.7, 0.7, 0.5, 1)

        local zebra = tab % 2
        menuItem.title:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
        menuItem.title:SetTextColor(0.7, 0.7, 0.5, 1)
        menuItem.bg:SetVertexColor(1, 1, 1, zebra)
        menuItem.hover:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover")
        menuItem:ClearNormalTexture()
        menuItem:SetText("")

        menuItem:HookScript("OnClick", function(self) SpellBookTabOnClick(self, spellBook) end)

        menuItem:SetFrameRef("GwSpellbookMenu", menu)
        menuItem:SetAttribute("_onclick", format([=[self:GetFrameRef("GwSpellbookMenu"):SetAttribute("tabopen", %s)]=], tab))
        menu:SetFrameRef(format("GwSpellbookContainerTab%s", tab), container)

        if tab == 5 then
            menuItem:HookScript("OnHide", function() SpellBookTabOnClick(spellBook.tabs[2], spellBook) end)

            menuItem:SetFrameRef("GwspellbookTab4", spellBook.tabs[4])
            menuItem:SetAttribute("_onstate-petstate", [=[
                if newstate == "nopet" then
                    self:Hide()
                    if self:GetFrameRef("GwSpellbookMenu"):GetAttribute("tabopen") then
                        self:GetFrameRef("GwSpellbookMenu"):SetAttribute("tabopen", 2)
                    end
                elseif newstate == "hasPet" then
                    self:Show()
                end
            ]=])
            RegisterStateDriver(menuItem, "petstate", "[target=pet,noexists] nopet; [target=pet,help] hasPet;")

            menu:SetAttribute("_onattributechanged", [=[
                if name~="tabopen" then return end

                self:GetFrameRef("GwSpellbookContainerTab1"):Hide()
                self:GetFrameRef("GwSpellbookContainerTab2"):Hide()
                self:GetFrameRef("GwSpellbookContainerTab3"):Hide()
                self:GetFrameRef("GwSpellbookContainerTab4"):Hide()
                self:GetFrameRef("GwSpellbookContainerTab5"):Hide()

                if value == 1 then
                    self:GetFrameRef("GwSpellbookContainerTab1"):Show()
                    return
                end
                if value == 2 then
                    self:GetFrameRef("GwSpellbookContainerTab2"):Show()
                    return
                end
                if value == 3 then
                    self:GetFrameRef("GwSpellbookContainerTab3"):Show()
                    return
                end
                if value == 4 then
                    self:GetFrameRef("GwSpellbookContainerTab4"):Show()
                    return
                end
                if value == 5 then
                    self:GetFrameRef("GwSpellbookContainerTab5"):Show()
                    return
                end
            ]=])
        end

        container:SetShown(tab == 3)
        tinsert(spellBook.tabs, menuItem)
        tinsert(spellBook.container, container)
        spellBook.tabs[tab].buttons = {}
        spellBook.container[tab].headerFrame = {}
    end

    menu:SetAttribute("tabOpen", 2)
    menu:SetScript("OnShow", function()
        if InCombatLockdown() then return end
        updateSpellbookTab(spellBook)
    end)
    hooksecurefunc("ToggleSpellBook", function()
        if InCombatLockdown() then return end
        GwCharacterWindow:SetAttribute("windowPanelOpen", "spellbook")
        updateSpellbookTab(spellBook)
    end)

    SpellBookFrame:UnregisterAllEvents()

    updateSpellbookTab(spellBook)

    return spellBook
end
GW.LoadSpellBook = LoadSpellBook
