---@class GW2
local GW = select(2, ...)

local spellbookFrame, spellbookMenu
local spellbookDirty = true
local tabContainers = {}
local tabMenuItems = {}

local function SpellButton_OnModifiedClick(self)
    local slot = self.spellbookIndex
    local book = self.booktype
    if IsModifiedClick("CHATLINK") then
        if MacroFrameText and MacroFrameText:HasFocus() then
            local spell, subSpell = GetSpellBookItemName(slot, book)
            if spell and not IsPassiveSpell(slot, book) then
                if subSpell and #subSpell > 0 then
                    ChatFrameUtil.InsertLink(spell .. "(" .. subSpell .. ")")
                else
                    ChatFrameUtil.InsertLink(spell)
                end
            end
        else
            local profLink, profId = GetSpellTradeSkillLink(slot, book)
            if profId then
                ChatFrameUtil.InsertLink(profLink)
            else
                ChatFrameUtil.InsertLink(GetSpellLink(slot, book))
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
    local spellBank = self.booktype == "pet" and Enum.SpellBookSpellBank.Pet or Enum.SpellBookSpellBank.Player

    if C_SpellBook.IsSpellInSpellBook(self.spellId, spellBank, false) then
        if not self.isFlyout then
            GameTooltip:SetSpellBookItem(self.spellbookIndex, self.booktype)
        else
            local name, desc = GetFlyoutInfo(self.spellId)
            GameTooltip:AddLine(name)
            GameTooltip:AddLine(desc)
        end
    else
        GameTooltip:SetSpellByID(self.spellId)
        if self.requiredLevel then
            GameTooltip:AddLine(' ')
            if self.requiredLevel <= GW.mylevel then
                GameTooltip:AddLine("|c0423ff2f" .. AVAILABLE .. "|r", 1, 1, 1)
            else
                GameTooltip:AddLine("|c00ff0000" .. UNLOCKED_AT_LEVEL:format(self.requiredLevel) .. "|r", 1, 1, 1)
            end
        end
        if self.money then
            GameTooltip:AddDoubleLine(COSTS_LABEL, GW.FormatMoneyForChat(self.money))
        end
    end
    GW.AddOffGcdTooltipLine(self)
    GameTooltip:Show()
end

local function spellbookButton_onEvent(self)
    if not spellbookFrame:IsShown() or not self.cooldown or not self.spellId then return end
    local cooldownInfo = GW.GetSpellCooldown(self.spellId)

    if cooldownInfo and cooldownInfo.startTime and cooldownInfo.duration then
        if (cooldownInfo.isEnabled == 1) then
            self.cooldown:Hide();
        else
            self.cooldown:Show();
        end
        CooldownFrame_Set(self.cooldown, cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.isEnabled, false, cooldownInfo.modRate)
    else
        self.cooldown:Hide();
    end
end

local function  spellBookMenu_onLoad(self)
    self:RegisterEvent("SPELLS_CHANGED")
    self:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE")
    self:RegisterEvent("SKILL_LINES_CHANGED")
    self:RegisterEvent("PLAYER_GUILD_UPDATE")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    self:RegisterEvent("CHARACTER_POINTS_CHANGED")
end


local SpellbookHeaderIndex = 1
local function getSpellBookHeader(container)
    local header = container.headerFrames[SpellbookHeaderIndex]
    if not header then
        header = CreateFrame("Frame", nil, container, "GwSpellbookActionBackground")
        container.headerFrames[SpellbookHeaderIndex] = header
    end

    return header
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
local function setButtonStyle(ispassive, spellID, skillType, icon, spellbookIndex, booktype, container, name, rank, level)
    local _, autostate = GetSpellAutocast(spellbookIndex, booktype)
    local btn = container.buttons[spellButtonIndex]

    btn.isPassive = ispassive
    btn.isFuture = (skillType == 'FUTURESPELL')
    btn.isFlyout = (skillType == 'FLYOUT')
    btn.spellbookIndex = spellbookIndex
    btn.booktype = booktype
    btn:EnableMouse(true)
    btn.spellId = spellID
    btn.requiredLevel = level
    btn.icon:SetTexture(icon)
    GW.UpdateOffGcdIndicator(btn, not btn.isFlyout and spellID or nil, ispassive)
    btn:SetAlpha(1)
    btn:SetAttribute("ispickable", false)

    btn.rank:SetText(rank and rank or "")
    btn.autocast:SetShown(autostate)
    btn.arrow:SetShown(btn.isFlyout)

    if level then
        if level > GW.mylevel then
            btn.lock:SetTexture("Interface/AddOns/GW2_UI/textures/talents/spell-lock.png");
        else
            btn.lock:SetTexture("Interface/AddOns/GW2_UI/textures/talents/spell-unlock.png");
        end
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
        GW.SetSecureAttribute(btn, "flyoutDirection", "RIGHT")
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
        btn.highlight:SetTexture('Interface/AddOns/GW2_UI/textures/talents/passive_highlight.png')
        btn.icon:AddMaskTexture(btn.mask)
        btn.outline:SetTexture('Interface/AddOns/GW2_UI/textures/talents/passive_outline.png')
    else
        btn.highlight:SetTexture('Interface/AddOns/GW2_UI/textures/talents/active_highlight.png')
        btn.icon:RemoveMaskTexture(btn.mask)
        btn.outline:SetTexture('Interface/AddOns/GW2_UI/textures/talents/background_border.png')
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
    for _, h in ipairs(pagingContainer.headers) do
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

local function getNumPages(container)
    local count = 0
    while container["container" .. (count + 1)] do
        count = count + 1
    end
    return count
end

-- the xml brings the first page, further pages come as the spells need them
local function getPagingContainer(container, pagingID)
    local page = container["container" .. pagingID]
    if not page then
        page = CreateFrame("Frame", "$parentcontainer" .. pagingID, container, "GwSpellbookPageTemplate", pagingID)
        container["container" .. pagingID] = page
    end
    return page
end

local function getCurrentPage(container)
    for i = 1, getNumPages(container) do
        if container["container" .. i]:IsShown() then
            return i
        end
    end

    return 1
end

local function setUpPaging(self, targetPage)
    self.left:SetFrameRef("tab", self.attrDummy)
    self.left:SetAttribute("_onclick", [=[
        self:GetFrameRef("tab"):SetAttribute("page", "left")
    ]=])

    self.right:SetFrameRef("tab", self.attrDummy)
    self.right:SetAttribute("_onclick", [=[
        self:GetFrameRef("tab"):SetAttribute("page", "right")
    ]=])
    self.attrDummy:SetAttribute("neededContainers", self.tabs)

    local numPages = getNumPages(self)
    self.attrDummy:SetAttribute("numContainers", numPages)
    for i = 1, numPages do
        self.attrDummy:SetFrameRef("container" .. i, self["container" .. i])
    end
    self.attrDummy:SetFrameRef("left", self.left)
    self.attrDummy:SetFrameRef("right", self.right)
    self.attrDummy:SetAttribute("_onattributechanged", [=[
        if name ~= "page" then return end

        local left = self:GetFrameRef("left")
        local right = self:GetFrameRef("right")

        local maxNumberOfContainers = self:GetAttribute("numContainers")
        local container
        local showNext = false
        local hadSomethingToShow = false

        local currentPage = 1
        local neededContainers = self:GetAttribute("neededContainers")

        if type(value) == "number" then -- jump to a page
            for i = 1, maxNumberOfContainers do
                if i == value then
                    self:GetFrameRef("container" .. i):Show()
                else
                    self:GetFrameRef("container" .. i):Hide()
                end
            end
            currentPage = value
        end

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
    ]=])
    self.attrDummy:SetAttribute("page", math.max(1, math.min(targetPage or 1, self.tabs or 1)))
end

local function updateSpellbookTab()
    if InCombatLockdown() then
        spellbookMenu:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    local numBooks = GW.ClassicSOD and 6 or 5
    local currentPages = {}

    for spellBookTabs = 1, numBooks do
        currentPages[spellBookTabs] = getCurrentPage(tabContainers[spellBookTabs])
    end

    for spellBookTabs = 1, numBooks do
        local name, texture, offset, numSpells = GetSpellTabInfo(spellBookTabs)
        local BOOKTYPE = 'spell'

        local tabContainer = tabContainers[spellBookTabs]
        local menuItem = tabMenuItems[spellBookTabs]
        local pagingID = 1
        local pagingContainer = tabContainer['container' .. pagingID]
        tabContainer.tabs = 1

        SpellbookHeaderIndex = 1
        spellButtonIndex = 1

        if spellBookTabs == numBooks then
            BOOKTYPE = 'pet'
            numSpells = HasPetSpells() or 0
            offset = 0
            name = PET
            texture = "Interface/AddOns/GW2_UI/textures/talents/tabicon_pet.png"
        end
        menuItem.icon:SetTexture(texture)
        menuItem.title:SetText(name)
        tabContainer.title:SetText(name)

        local boxIndex = 1
        local lastName = ""
        local lastButton
        local header
        local needNewHeader

        pagingContainer.column1 = 0
        pagingContainer.column2 = 0
        pagingContainer.headers = {}

        for i = 1, numSpells do
            local spellIndex = i + offset
            local skillType = GetSpellBookItemInfo(spellIndex, BOOKTYPE)
            local icon = GetSpellBookItemTexture(spellIndex, BOOKTYPE)
            local nameSpell, rank, spellID = GetSpellBookItemName(spellIndex, BOOKTYPE)
            local ispassive = IsPassiveSpell(spellID)

            -- skip hidden spellbook slots like blizzard does, on sod the rune book contains hidden placeholder spells for not yet learned runes
            if not IsSpellHidden(spellIndex, BOOKTYPE) and nameSpell then
                rank = rank and rank:gsub(RANK, "") or ""

                needNewHeader = true
                if lastName == nameSpell then
                    needNewHeader = false
                end

                local mainButton = setButtonStyle(ispassive, spellID, skillType, icon, spellIndex, BOOKTYPE, tabContainer, nameSpell, rank)
                mainButton.modifiedClick = SpellButton_OnModifiedClick
                if not ispassive then GW.RegisterCooldown(mainButton.cooldown) end
                spellButtonIndex = spellButtonIndex + 1
                boxIndex = boxIndex + 1

                if needNewHeader then
                    local currentHeight = getHeaderHeight(pagingContainer, header)
                    if currentHeight > (pagingContainer:GetHeight() - 120) then
                        pagingID = pagingID + 1
                        pagingContainer = getPagingContainer(tabContainer, pagingID)
                        pagingContainer.headers = {}
                        pagingContainer.column1 = 0
                        pagingContainer.column2 = 0
                        tabContainer.tabs = pagingID

                    end
                    header = getSpellBookHeader(tabContainer)
                    setHeaderLocation(header, pagingContainer)
                    header.title:SetText(nameSpell)
                    header.buttons = 1
                    header.height = 80
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
        end

        setUpPaging(tabContainer, currentPages[spellBookTabs])

        for i = boxIndex, #tabContainer.buttons do
            local btn = tabContainer.buttons[i]
            btn:SetAlpha(0)
            btn:EnableMouse(false)
            btn:SetScript('OnEvent', nil)
        end
        for i = SpellbookHeaderIndex, #tabContainer.headerFrames do
            tabContainer.headerFrames[i]:Hide()
        end
    end

    spellbookDirty = false
end

local function spellBookTab_onClick(self)
    for i = 1, #tabMenuItems do
        tabMenuItems[i].background:Hide()
    end
    self.background:Show()
end

local function LoadSpellBook(tabContainer)
    spellbookFrame = CreateFrame('Frame', 'GwSpellbook', tabContainer, 'GwSpellbook')
    spellbookMenu = CreateFrame('Frame', 'GwSpellbookMenu', spellbookFrame, 'GwSpellbookMenu')

    spellbookFrame.showAllSpellRanks.checkbutton:SetScript("OnClick", function(self)
        SetCVar("ShowAllSpellRanks", self:GetChecked())
        updateSpellbookTab()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    spellBookMenu_onLoad(spellbookMenu)
    spellbookMenu:RegisterEvent("PLAYER_ENTERING_WORLD")
    spellbookMenu:SetScript('OnEvent', function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            self:UnregisterEvent(event)
            C_Timer.After(0.1, updateSpellbookTab)
        elseif event == "PLAYER_REGEN_ENABLED" then
            self:UnregisterEvent("PLAYER_REGEN_ENABLED")
            updateSpellbookTab()
        end

        if not spellbookFrame:IsShown() then
            spellbookDirty = true
            return
        end
        updateSpellbookTab()
    end)

    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("TOPLEFT", GwCharacterWindow, 'TOPLEFT', 0, 0)
    mask:SetTexture("Interface/AddOns/GW2_UI/textures/character/windowbg-mask.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(853, 853)

    local numBooks = GW.ClassicSOD and 6 or 5
    spellbookMenu:SetAttribute("maxContainer", numBooks)
    local petTab
    for tab = 1, numBooks do
        local menuItem = CreateFrame('Button', 'GwspellbookTab' .. tab, spellbookMenu, 'GwspellbookTab')
        tabMenuItems[tab] = menuItem
        menuItem:SetPoint("TOPLEFT", spellbookMenu, "TOPLEFT", 0, -menuItem:GetHeight() * (tab - 1))
        local container = CreateFrame('Frame', 'GwSpellbookContainerTab' .. tab, spellbookFrame, 'GwSpellbookContainerTab')
        tabContainers[tab] = container
        container.headerFrames = {}
        container.buttons = {}
        container.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, "OUTLINE")
        container.title:SetTextColor(0.9, 0.9, 0.7, 1)
        container.pages:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, "OUTLINE", 2)
        container.pages:SetTextColor(0.7, 0.7, 0.5, 1)
        container:Hide()

        if tab == numBooks then
            petTab = menuItem
        end

        local zebra = tab % 2
        menuItem.title:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
        menuItem.title:SetTextColor(0.7, 0.7, 0.5, 1)
        menuItem.bg:SetVertexColor(1, 1, 1, zebra)
        menuItem.hover:SetTexture('Interface/AddOns/GW2_UI/textures/character/menu-hover.png')
        menuItem:ClearNormalTexture()
        menuItem:SetText("")
        menuItem:HookScript('OnClick', spellBookTab_onClick)

        menuItem:SetFrameRef('GwSpellbookMenu', spellbookMenu)
        menuItem:SetAttribute("_onclick", format([=[
            self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen', %s)
        ]=], tab))
        spellbookMenu:SetFrameRef(format('GwSpellbookContainerTab%s', tab), container)

        local line = 0
        local x = 0
        local y = 0
        for i = 1, 100 do
            local f = CreateFrame('Button', 'GwSpellbookTab' .. tab .. 'Actionbutton' .. i, container.container1, 'GwSpellbookActionbutton')
            container.buttons[i] = f
            mask = UIParent:CreateMaskTexture()
            mask:SetPoint("CENTER", f, 'CENTER', 0, 0)

            mask:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_border.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            mask:SetSize(40, 40)

            f.mask = mask
            f.rank:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small, "OUTLINE")
            f.rank:SetTextColor(0.9, 0.9, 0.8, 1)
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
            if line==5 then
                x = 0
                y = y + 1
                line = 0
            end
        end
    end

    -- pet tab
    petTab:SetAttribute("_onstate-petstate", [=[
        if newstate == "nopet" then
            self:Hide()
            if self:GetFrameRef('GwSpellbookMenu'):GetAttribute('tabopen') then
                self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen', 3)
            end
        elseif newstate == "hasPet" then
            self:Show()
        end
    ]=])
    RegisterStateDriver(petTab, "petstate", "[target=pet,noexists] nopet; [target=pet,help] hasPet;")


    spellbookMenu:SetAttribute('_onattributechanged', [=[
        if name~='tabopen' then return end

        local numBooks = self:GetAttribute("maxContainer")
        for i = 1, numBooks do
            self:GetFrameRef('GwSpellbookContainerTab' .. i):Hide()
        end

        if value >= 1 and value <= numBooks then
            self:GetFrameRef('GwSpellbookContainerTab' .. value):Show()
        end
    ]=])
    spellbookMenu:SetAttribute('tabopen', 2)

    petTab:HookScript('OnHide', function() spellBookTab_onClick(tabMenuItems[3]) end)

    spellbookMenu:SetScript('OnShow', function()
        if InCombatLockdown() or not spellbookDirty then return end
        updateSpellbookTab()
    end)
    hooksecurefunc('ToggleSpellBook', function()
        if InCombatLockdown() then return end
        GwCharacterWindow:SetAttribute('windowPanelOpen', "spellbook")
    end)

    SpellBookFrame:UnregisterAllEvents()
end
GW.LoadSpellBook = LoadSpellBook
