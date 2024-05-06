local _, GW = ...
local L = GW.L
GW.spellbook = {}

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
        GameTooltip:AddLine(' ')
        if self.requiredLevel <= GW.mylevel then
            GameTooltip:AddLine("|c0423ff2f" .. AVAILABLE .. "|r", 1, 1, 1)
        else
            GameTooltip:AddLine("|c00ff0000" .. UNLOCKED_AT_LEVEL:format(self.requiredLevel) .. "|r", 1, 1, 1)
        end
        if self.money then
            GameTooltip:AddDoubleLine(COSTS_LABEL, GW.FormatMoneyForChat(self.money))
        end
    end
    GameTooltip:Show()
end
GW.spellbook.spell_buttonOnEnter = spell_buttonOnEnter;

local function spellbookButton_onEvent(self)
    if not GwSpellbook:IsShown() or not self.cooldown or not self.spellId then return end

    local start, duration, enable, modRate = GetSpellCooldown(self.spellId)

    if start and duration then
        if (enable == 1) then
            self.cooldown:Hide();
        else
            self.cooldown:Show();
        end
        CooldownFrame_Set(self.cooldown, start, duration, enable, false, modRate)
    else
        self.cooldown:Hide();
    end
end

local function spellBookMenu_onLoad(self)
    self:RegisterEvent("SPELLS_CHANGED")
    self:RegisterEvent("LEARNED_SPELL_IN_TAB")
    self:RegisterEvent("SKILL_LINES_CHANGED")
    self:RegisterEvent("PLAYER_GUILD_UPDATE")
    self:RegisterEvent("PLAYER_LEVEL_UP")
end

local SpellbookHeaderIndex = 1
local function getSpellBookHeader(tab)
    if _G['GwSpellbookContainerTab' .. tab .. 'GwSpellbookActionBackground' .. SpellbookHeaderIndex] then
        return _G['GwSpellbookContainerTab' .. tab .. 'GwSpellbookActionBackground' .. SpellbookHeaderIndex]
    end

    return CreateFrame("Frame", 'GwSpellbookContainerTab' .. tab .. 'GwSpellbookActionBackground' .. SpellbookHeaderIndex,
        _G['GwSpellbookContainerTab' .. tab], "GwSpellbookActionBackground")
end

local function setHeaderLocation(self, pagingContainer)
    local prev

    if pagingContainer.headers[#pagingContainer.headers] then
        prev = pagingContainer.headers[#pagingContainer.headers]
    end
    self:ClearAllPoints()
    self:SetParent(pagingContainer)

    if prev then
        if ((#pagingContainer.headers + 1) % 2) == 0 then
            local prev2

            if pagingContainer.headers[#pagingContainer.headers - 1] then
                prev2 = pagingContainer.headers[#pagingContainer.headers - 1]
            end
            if prev2 then
                self:SetPoint("TOPLEFT", prev2, "BOTTOMLEFT", 0, -5)
                self.column = 2
            else
                self:SetPoint("TOPLEFT", prev, "TOPRIGHT", 0, 0)
                self.column = 2
            end
        else
            prev = pagingContainer.headers[#pagingContainer.headers - 1]
            self:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -5)
            self.column = 1
        end
    else
        self:SetPoint("TOPLEFT", pagingContainer, "TOPLEFT", 0, 0)
        self.column = 1
    end

    pagingContainer.headers[#pagingContainer.headers + 1] = self
    SpellbookHeaderIndex = SpellbookHeaderIndex + 1
end

local spellButtonIndex = 1
local function setButtonStyle(ispassive, spellID, skillType, icon, spellbookIndex, booktype, tab, name, level)
    local _, autostate = GetSpellAutocast(name, booktype)
    local btn = _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]

    btn.isPassive = ispassive
    btn.isFuture = (skillType == 'FUTURESPELL')
    btn.isFlyout = (skillType == 'FLYOUT')
    btn.spellbookIndex = spellbookIndex
    btn.booktype = booktype
    btn:EnableMouse(true)
    btn.spellId = spellID
    btn.requiredLevel = level
    btn.icon:SetTexture(icon)
    btn:SetAlpha(1)
    btn:SetAttribute("ispickable", false)

    btn.autocast:SetShown(autostate)
    btn.arrow:SetShown(btn.isFlyout)

    if level and level > GW.mylevel then
        btn.lock:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\spell-lock");
        btn.lock:Show()
    else
        btn.lock:Hide()
    end

    btn:SetScript('OnEvent', spellbookButton_onEvent)

    if btn.isFlyout then
        btn:SetAttribute("type1", "flyout")
        btn:SetAttribute("type2", "flyout")
        btn:SetAttribute("spell", spellID)
        btn:SetAttribute("flyout", spellID)
        btn:SetAttribute("flyoutDirection", 'RIGHT')
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
        btn:SetAttribute("ispickable", true)
        btn:SetAttribute("type1", "spell")
        btn:SetAttribute("type2", "spell")
        btn:SetAttribute("spell", spellID)
        btn:SetAttribute("shift-type1", "modifiedClick")
        btn:SetAttribute("shift-type2", "modifiedClick")
    else
        btn:SetAttribute("shift-type1", "modifiedClick")
        btn:SetAttribute("shift-type2", "modifiedClick")
    end


    if skillType == 'FUTURESPELL' then
        btn.icon:SetDesaturated(true)
        btn.icon:SetAlpha(0.5)
    elseif skillType == 'FLYOUT' then
        btn.icon:SetDesaturated(false)
        btn.icon:SetAlpha(1)
    else
        btn.icon:SetDesaturated(false)
        btn.icon:SetAlpha(1)
    end

    if ispassive then
        btn.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight')
        btn.icon:AddMaskTexture(btn.mask)
        btn.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_outline')
    else
        btn.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight')
        btn.icon:RemoveMaskTexture(btn.mask)
        btn.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\background_border')
    end
    spellbookButton_onEvent(btn)
    btn:Show()

    return btn
end

local function getHeaderHeight(pagingContainer, lastHeader)
    local lastColumn = 1
    if lastHeader ~= nil then
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
    self.left:SetFrameRef('tab', self.attrDummy)
    self.left:SetAttribute("_onclick", [=[
        self:GetFrameRef('tab'):SetAttribute('page', 'left')
    ]=])

    self.right:SetFrameRef('tab', self.attrDummy)
    self.right:SetAttribute("_onclick", [=[
        self:GetFrameRef('tab'):SetAttribute('page', 'right')
    ]=])
    self.attrDummy:SetAttribute('neededContainers', self.tabs)

    self.attrDummy:SetFrameRef('container1', self.container1)
    self.attrDummy:SetFrameRef('container2', self.container2)
    self.attrDummy:SetFrameRef('container3', self.container3)
    self.attrDummy:SetFrameRef('container4', self.container4)
    self.attrDummy:SetFrameRef('container5', self.container5)
    self.attrDummy:SetFrameRef('container6', self.container6)
    self.attrDummy:SetFrameRef('left', self.left)
    self.attrDummy:SetFrameRef('right', self.right)
    self.attrDummy:SetAttribute('_onattributechanged', ([=[
        if name ~= 'page' then return end


        local left = self:GetFrameRef('left')
        local right = self:GetFrameRef('right')

        local maxNumberOfContainers = 6
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
    self.attrDummy:SetAttribute('page', 'left')
end

local function resetSpellbookPage(spellBookTabs)
    for i = 1, 300 do
        _G['GwSpellbookTab' .. spellBookTabs .. 'Actionbutton' .. i]:SetAlpha(0)
        _G['GwSpellbookTab' .. spellBookTabs .. 'Actionbutton' .. i]:EnableMouse(false)
        _G['GwSpellbookTab' .. spellBookTabs .. 'Actionbutton' .. i]:SetScript('OnEvent', nil)
    end
    for i = 1 , 300 do
        if _G['GwSpellbookContainerTab' .. spellBookTabs .. 'GwSpellbookActionBackground' .. i] then
            _G['GwSpellbookContainerTab' .. spellBookTabs .. 'GwSpellbookActionBackground' .. i]:Hide()
        end
    end
end

local function updateSpellbookTab()
    if InCombatLockdown() then
        GwSpellbookMenu:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    for spellBookTabs = 1, 5 do
        local name, texture, offset, numSpells = GetSpellTabInfo(spellBookTabs)
        local BOOKTYPE = 'spell'

        local pagingID = 1
        local pagingContainer = _G['GwSpellbookContainerTab' .. spellBookTabs .. 'container' .. pagingID]
        _G['GwSpellbookContainerTab' .. spellBookTabs].tabs = 1

        SpellbookHeaderIndex = 1
        spellButtonIndex = 1
        resetSpellbookPage(spellBookTabs)

        if spellBookTabs == 5 then
            BOOKTYPE = 'pet'
            numSpells = HasPetSpells() or 0
            offset = 0
            name = PET
            texture = "Interface\\AddOns\\GW2_UI\\textures\\talents\\tabicon_pet"
        end
        _G['GwspellbookTab' .. spellBookTabs].icon:SetTexture(texture)
        _G['GwspellbookTab' .. spellBookTabs].title:SetText(name)
        _G['GwSpellbookContainerTab' .. spellBookTabs].title:SetText(name)

        local boxIndex = 1
        local lastName = ""
        local lastButton
        local header
        local needNewHeader = true

        pagingContainer.column1 = 0
        pagingContainer.column2 = 0
        pagingContainer.headers = {}

        for i = 1, numSpells do
            local spellIndex = i + offset
            local skillType, flyoutId = GetSpellBookItemInfo(spellIndex, BOOKTYPE)
            local icon = GetSpellBookItemTexture(spellIndex, BOOKTYPE)
            local nameSpell, _, spellID = GetSpellBookItemName(spellIndex, BOOKTYPE)
            local ispassive = IsPassiveSpell(spellID)
            local requiredLevel = GetSpellAvailableLevel(spellIndex, BOOKTYPE)

            if nameSpell then
                needNewHeader = true
                if lastName == nameSpell then
                    needNewHeader = false
                end

                local mainButton = setButtonStyle(ispassive, spellID or flyoutId, skillType, icon, spellIndex, BOOKTYPE, spellBookTabs, nameSpell, requiredLevel)
                mainButton.modifiedClick = SpellButton_OnModifiedClick
                if not ispassive then GW.RegisterCooldown(mainButton.cooldown) end
                spellButtonIndex = spellButtonIndex + 1
                boxIndex = boxIndex + 1

                if needNewHeader then
                    local currentHeight = getHeaderHeight(pagingContainer, header)
                    if currentHeight > (pagingContainer:GetHeight() - 120) then
                        pagingID = pagingID + 1
                        pagingContainer = _G['GwSpellbookContainerTab' .. spellBookTabs .. 'container' .. pagingID]
                        pagingContainer.headers = {}
                        pagingContainer.column1 = 0
                        pagingContainer.column2 = 0
                        _G['GwSpellbookContainerTab' .. spellBookTabs].tabs = pagingID
                    end
                    header = getSpellBookHeader(spellBookTabs)
                    setHeaderLocation(header, pagingContainer)
                    header.title:SetText(nameSpell)
                    header.buttons = 1
                    header.height = 80
                    header:Show()
                end

                mainButton:ClearAllPoints()
                mainButton:SetParent(header)
                if needNewHeader then
                    mainButton:SetPoint("TOPLEFT", header, "TOPLEFT", 15, -35)
                    header.firstButton = mainButton
                else
                    if header.buttons == 6 then
                        mainButton:SetPoint("TOPLEFT", header.firstButton, "BOTTOMLEFT", 0, -5)
                        header.height = header.height + 45
                    else
                        mainButton:SetPoint("LEFT", lastButton, "RIGHT", 5, 0)
                    end
                    header.buttons = header.buttons + 1
                end

                header:SetHeight(header.height)
                lastName = nameSpell
                lastButton = mainButton
            end
            setUpPaging(_G['GwSpellbookContainerTab' .. spellBookTabs])
        end
    end
end

local function spellBookTab_onClick(self)
    GwspellbookTab1.background:Hide()
    GwspellbookTab2.background:Hide()
    GwspellbookTab3.background:Hide()
    GwspellbookTab4.background:Hide()
    GwspellbookTab5.background:Hide()
    self.background:Show()
end

local function LoadSpellBook()
    CreateFrame('Frame', 'GwSpellbook', GwCharacterWindow, 'GwSpellbook')
    CreateFrame('Frame', 'GwSpellbookMenu', GwSpellbook, 'GwSpellbookMenu')

    spellBookMenu_onLoad(GwSpellbookMenu)
    GwSpellbookMenu:RegisterEvent("PLAYER_ENTERING_WORLD")
    GwSpellbook:Hide()
    GwSpellbookMenu:SetScript('OnEvent', function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            self:UnregisterEvent(event)
            C_Timer.After(0.1, updateSpellbookTab)
        elseif event == "PLAYER_REGEN_ENABLED" then
            self:UnregisterEvent("PLAYER_REGEN_ENABLED")
            updateSpellbookTab()
        end

        if not GwSpellbook:IsShown() then
            return
        end
        updateSpellbookTab()
    end)

    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("TOPLEFT", GwCharacterWindow, 'TOPLEFT', 0, 0)
    mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\windowbg-mask", "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE")
    mask:SetSize(853, 853)

    for tab = 1, 5 do
        local menuItem = CreateFrame('Button', 'GwspellbookTab' .. tab, GwSpellbookMenu, 'GwspellbookTab')
        menuItem:SetPoint("TOPLEFT", GwSpellbookMenu, "TOPLEFT", 0, -menuItem:GetHeight() * (tab - 1))
        local container = CreateFrame('Frame', 'GwSpellbookContainerTab' .. tab, GwSpellbook, 'GwSpellbookContainerTab')
        container.title:SetFont(DAMAGE_TEXT_FONT, 16, "OUTLINE")
        container.title:SetTextColor(0.9, 0.9, 0.7, 1)
        container.pages:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
        container.pages:SetTextColor(0.7, 0.7, 0.5, 1)

        local zebra = tab % 2
        menuItem.title:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE")
        menuItem.title:SetTextColor(0.7, 0.7, 0.5, 1)
        menuItem.bg:SetVertexColor(1, 1, 1, zebra)
        menuItem.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
        menuItem:ClearNormalTexture()
        menuItem:SetText("")

        local line = 0
        local x = 0
        local y = 0
        for i = 1, 300 do
            local f = CreateFrame('Button', 'GwSpellbookTab' .. tab .. 'Actionbutton' .. i, container.container1,
                'GwSpellbookActionbutton')
            local mask = UIParent:CreateMaskTexture()
            mask:SetPoint("CENTER", f, 'CENTER', 0, 0)

            mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border", "CLAMPTOBLACKADDITIVE",
                "CLAMPTOBLACKADDITIVE")
            mask:SetSize(40, 40)

            f.mask = mask
            mask:SetParent(f)
            f:SetPoint('TOPLEFT', container, 'TOPLEFT', (50 * x), (-70) + (-50 * y))
            f:RegisterForClicks("AnyUp")
            f:RegisterForDrag("LeftButton")
            f:RegisterEvent("SPELL_UPDATE_COOLDOWN")
            f:RegisterEvent("PET_BAR_UPDATE")
            f:SetScript('OnEnter', spell_buttonOnEnter)
            f:HookScript('OnLeave', GameTooltip_Hide)
            f:Hide()

            line = line + 1
            x = x + 1
            if line == 5 then
                x = 0
                y = y + 1
                line = 0
            end
        end
    end

    GwSpellbookContainerTab1:Hide()
    GwSpellbookContainerTab2:Hide()
    GwSpellbookContainerTab3:Show()
    GwSpellbookContainerTab4:Hide()
    GwSpellbookContainerTab5:Hide()

    GwspellbookTab1:SetFrameRef('GwSpellbookMenu', GwSpellbookMenu)
    GwspellbookTab1:SetAttribute("_onclick", [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen', 1)
    ]=])
    GwspellbookTab2:SetFrameRef('GwSpellbookMenu', GwSpellbookMenu)
    GwspellbookTab2:SetAttribute("_onclick", [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen', 2)
    ]=])
    GwspellbookTab3:SetFrameRef('GwSpellbookMenu', GwSpellbookMenu)
    GwspellbookTab3:SetAttribute("_onclick", [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen', 3)
    ]=])
    GwspellbookTab4:SetFrameRef('GwSpellbookMenu', GwSpellbookMenu)
    GwspellbookTab4:SetAttribute("_onclick", [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen', 4)
        ]=])
    GwspellbookTab5:SetFrameRef('GwSpellbookMenu', GwSpellbookMenu)
    GwspellbookTab5:SetAttribute("_onclick", [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen', 5)
    ]=])
    GwspellbookTab5:SetFrameRef('GwspellbookTab4', GwspellbookTab4)
    GwspellbookTab5:SetAttribute("_onstate-petstate", [=[
        if newstate == "nopet" then
            self:Hide()
            if self:GetFrameRef('GwSpellbookMenu'):GetAttribute('tabopen') then
                self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen', 2)
            end
        elseif newstate == "hasPet" then
            self:Show()
        end
    ]=])
    RegisterStateDriver(GwspellbookTab5, "petstate", "[target=pet,noexists] nopet; [target=pet,help] hasPet;")


    GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab1', GwSpellbookContainerTab1)
    GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab2', GwSpellbookContainerTab2)
    GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab3', GwSpellbookContainerTab3)
    GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab4', GwSpellbookContainerTab4)
    GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab5', GwSpellbookContainerTab5)
    GwSpellbookMenu:SetAttribute('_onattributechanged', [=[
        if name~='tabopen' then return end

        self:GetFrameRef('GwSpellbookContainerTab1'):Hide()
        self:GetFrameRef('GwSpellbookContainerTab2'):Hide()
        self:GetFrameRef('GwSpellbookContainerTab3'):Hide()
        self:GetFrameRef('GwSpellbookContainerTab4'):Hide()
        self:GetFrameRef('GwSpellbookContainerTab5'):Hide()

        if value == 1 then
            self:GetFrameRef('GwSpellbookContainerTab1'):Show()
            return
        end
        if value == 2 then
            self:GetFrameRef('GwSpellbookContainerTab2'):Show()
            return
        end
        if value == 3 then
            self:GetFrameRef('GwSpellbookContainerTab3'):Show()
            return
        end
        if value == 4 then
            self:GetFrameRef('GwSpellbookContainerTab4'):Show()
            return
        end
        if value == 5 then
            self:GetFrameRef('GwSpellbookContainerTab5'):Show()
            return
        end
    ]=])
    GwSpellbookMenu:SetAttribute('tabOpen', 2)

    GwspellbookTab1:HookScript('OnClick', spellBookTab_onClick)
    GwspellbookTab2:HookScript('OnClick', spellBookTab_onClick)
    GwspellbookTab3:HookScript('OnClick', spellBookTab_onClick)
    GwspellbookTab4:HookScript('OnClick', spellBookTab_onClick)
    GwspellbookTab5:HookScript('OnClick', spellBookTab_onClick)
    GwspellbookTab5:HookScript('OnHide', function() spellBookTab_onClick(GwspellbookTab2) end)
    GwSpellbookMenu:SetScript('OnShow', function()
        if InCombatLockdown() then return end
        updateSpellbookTab()
    end)
    hooksecurefunc('ToggleSpellBook', function()
        if InCombatLockdown() then return end
        GwCharacterWindow:SetAttribute('windowPanelOpen', "spellbook")
    end)
    --hooksecurefunc('ToggleSpellBook',gwToggleSpellbook)

    SpellBookFrame:UnregisterAllEvents()

    return GwSpellbook
end
GW.LoadSpellBook = LoadSpellBook
