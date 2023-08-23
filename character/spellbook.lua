local _, GW = ...
local L = GW.L

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

    if IsSpellKnown(self.spellId, isPet) and self.futureSpellOverrider==nil then
        if not self.isFlyout then
            GameTooltip:SetSpellBookItem(self.spellbookIndex,self.booktype)
        else
            local name, desc = GetFlyoutInfo(self.spellId)
            GameTooltip:AddLine(name)
            GameTooltip:AddLine(desc)
        end
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

local function  spellBookMenu_onLoad(self)
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

    return CreateFrame("Frame", 'GwSpellbookContainerTab' .. tab .. 'GwSpellbookActionBackground' .. SpellbookHeaderIndex, _G['GwSpellbookContainerTab' .. tab], "GwSpellbookActionBackground")
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
local function setButtonStyle(ispassive, spellID, skillType, icon, spellbookIndex, booktype, tab, name, rank, level)
    local _, autostate = GetSpellAutocast(spellbookIndex, booktype)
    local btn =  _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]

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

    btn.rank:SetText(rank and rank or "")
    btn.autocast:SetShown(autostate)
    btn.arrow:SetShown(btn.isFlyout)

    if level then
        if level > GW.mylevel then
            btn.lock:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\spell-lock");
        else
            btn.lock:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\spell-unlock");
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
        btn:SetAttribute("flyoutDirection", 'RIGHT')
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

local function findHigherRank(t,spellID)
    local si = spellID
    for k,v in pairs(GW.SpellsByLevel) do
        for _,spell in pairs(v) do
            if spell.requiredIds~=nil then
                for _,rid in pairs(spell.requiredIds) do
                    if rid == si  then
                        if not IsSpellKnown(spell.id) then
                            t[#t + 1] = {id=spell.id,level=k,rank=spell.rank}
                            t = findHigherRank(t,spell.id)
                            return t
                        end
                    end
                end
            end
        end
    end
    return t
end

local function getHeaderHeight(pagingContainer,lastHeader)
    local lastColumn = 1
    if lastHeader~=nil then
        lastColumn = lastHeader.column
    end
    local c1 =0
    local c2 =0
    for _, h in pairs(pagingContainer.headers) do
        if h.column == 1 then
        c1=c1 + h.height
        else
            c2=c2 + h.height
        end
    end
    if lastColumn==2 then
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

    self.attrDummy:SetFrameRef('container1', self.container1)
    self.attrDummy:SetFrameRef('container2', self.container2)
    self.attrDummy:SetFrameRef('container3', self.container3)
    self.attrDummy:SetFrameRef('container4', self.container4)
    self.attrDummy:SetFrameRef('left', self.left)
    self.attrDummy:SetFrameRef('right', self.right)
    self.attrDummy:SetAttribute('_onattributechanged', ([=[
        if name ~= 'page' then return end

        local p1 = self:GetFrameRef('container1')
        local p2 = self:GetFrameRef('container2')
        local p3 = self:GetFrameRef('container3')
        local p4 = self:GetFrameRef('container4')
        local left = self:GetFrameRef('left')
        local right = self:GetFrameRef('right')
        local numPages = %s
        local currentPage = 1

        if value == "left" then
            if p4:IsVisible() then
                p4:Hide()
                p3:Show()
                currentPage = 3
            elseif p3:IsVisible() then
                p3:Hide()
                p2:Show()
                currentPage = 2
            elseif p2:IsVisible() then
                p2:Hide()
                p1:Show()
                currentPage = 1
            end
        end
        if value == "right" then
            if p1:IsVisible()  then
                p1:Hide()
                p2:Show()
                currentPage = 2
            elseif p2:IsVisible() then
                p2:Hide()
                p3:Show()
                currentPage = 3
            elseif p3:IsVisible() then
                p3:Hide()
                p4:Show()
                currentPage = 4
            end
        end

        if currentPage >= numPages then
            right:Hide()
        else
            right:Show()
        end
        if currentPage == 1 then
            left:Hide()
        else
            left:Show()
        end
    ]=]):format(self.tabs))
    self.attrDummy:SetAttribute('page', 'left')
end

local UNKNOW_SPELL_MAX_INDEX = 0
local function getUnknownSpellItem(index)
    if _G["GwSpellbookUnknownSpell"..index]~=nil then
        return _G["GwSpellbookUnknownSpell"..index]
    end

    UNKNOW_SPELL_MAX_INDEX = UNKNOW_SPELL_MAX_INDEX + 1;

    local f = CreateFrame("Button","GwSpellbookUnknownSpell"..index, GwSpellbookUnknown.container,"GwSpellbookUnknownSpell")
    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("CENTER", f, 'CENTER', 0, 0)
    mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(40, 40)

    f.mask = mask
    return f
end
local UNKNOW_SPELL_CONTAINER_MAX_INDEX = 0
local function getUnknownSpellContainer(index)
    if _G["GwUnknownSpellCat" .. index] then
        return _G["GwUnknownSpellCat" .. index]
    end

    UNKNOW_SPELL_CONTAINER_MAX_INDEX = UNKNOW_SPELL_CONTAINER_MAX_INDEX + 1

    return CreateFrame("Button", "GwUnknownSpellCat" .. index, GwSpellbookUnknown.container, "GwUnknownSpellCat")
end
local function setUnknowSpellButton(self, icon, spellID, rank, ispassive, level, money)
    self.icon:SetTexture(icon)
    self.spellId = spellID
    self.booktype = "spell"
    self.isFuture = true
    self.isFlyout = false
    self.futureSpellOverrider = true
    self.requiredLevel = level
    self.money = money

    if rank then
        self.rank:SetText(rank)
    else
        self.rank:SetText("")
    end
    self.lock:Hide()
    self.arrow:Hide()
    self.autocast:Hide()

    if ispassive then
        self.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight' )
        self.icon:AddMaskTexture(self.mask)
        self.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_outline')
    else
        self.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight' )
        self.icon:RemoveMaskTexture(self.mask)
        self.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\background_border')
    end
    self:SetScript("OnEnter", spell_buttonOnEnter)
    self:SetScript("OnLeave", GameTooltip_Hide)
end

local function filterUnknownSpell(knownSpellID, spell)
    local show = true

    if  GW.tableContains(knownSpellID, spell.id) then
        show = false
    end

    if spell.isTalent==1 then
        -- if talent is not the first rank, make sure we have the first rank else we dont want to show it
        if spell.baseId~=nil then
            if not GW.tableContains(knownSpellID,spell.baseId) then
                show = false
            end
        else
            -- if talent is the first rank we dont want to show it
            show = false
        end
    elseif spell.isSkill ~= nil and spell.isSkill == 1 then --Check for skills
        show = false
    end

    local filterLower,filter = GW.isHigherRankLearnd(spell.id)

    if filterLower and not filter then
        show = false
    end

    return show
end
local function updateUnknownTab(knownSpellID)
    UNKNOW_SPELL_MAX_INDEX = 0
    for i = 1,UNKNOW_SPELL_MAX_INDEX do
        _G["GwSpellbookUnknownSpell" .. i]:Hide()
    end
    for i = 1,UNKNOW_SPELL_CONTAINER_MAX_INDEX do
        _G["GwUnknownSpellCat" .. i]:Hide()
    end
    GwSpellbookUnknown.slider:SetMinMaxValues(0,0)
    GwSpellbookUnknown.container.headers = {}

    local SPELL_INDEX = 1
    local HEADER_INDEX = 1
    local zebraHeader = 1
    local lastHeader
    local header
    local txR, txT, txH, txMH
    txR = 588 / 1024
    txH = 140
    txMH = 512
    local x = 10
    local y = 50

    for k, v in GW.orderedPairs(GW.SpellsByLevel) do
        local buttons = {}
        for _,spell in pairs(v) do
            if filterUnknownSpell(knownSpellID, spell) then
                local f =  getUnknownSpellItem(SPELL_INDEX)
                f:Show()
                local _, _, icon, _, _, _, spellID =  GetSpellInfo(spell.id)
                local ispassive = IsPassiveSpell(spellID)

                buttons[#buttons + 1] = f
                setUnknowSpellButton(f, icon, spellID, spell.rank, ispassive, k, spell.cost)

                SPELL_INDEX = SPELL_INDEX + 1
            end
        end
        if #buttons > 0 then
            if k > GW.mylevel or not header then
                lastHeader= header
                header = getUnknownSpellContainer(HEADER_INDEX)
                GwSpellbookUnknown.container.headers[#GwSpellbookUnknown.container.headers +1] = header
                header:Show()
                header:SetHeight(100)
                x = 10
                y = 50
                zebraHeader = zebraHeader + 1
                if zebraHeader > 3 then
                    zebraHeader = 1
                end
                HEADER_INDEX =HEADER_INDEX + 1
            end

            txT = (zebraHeader - 1) * txH

            header.repbg:SetTexture("Interface/AddOns/GW2_UI/textures/talents/art/" .. GW.myClassID)
            header.repbg:SetTexCoord(0, txR, txT / txMH, (txT + txH) / txMH)

            if k <= GW.mylevel then
                header.repbg:SetDesaturated(false)
                header.title:SetText(AVAILABLE)
                header.title:SetTextColor(0.9, 0.9, 0.7, 1)
            else
                header.repbg:SetDesaturated(true)
                header.title:SetText(UNLOCKED_AT_LEVEL:format(k))
                header.title:SetTextColor(0.8,.8,.8,0.5)
            end

            for buttonIndex = 1, #buttons do
                local b = buttons[buttonIndex]

                if lastHeader then
                    header:SetPoint("TOPLEFT", lastHeader, "BOTTOMLEFT", 0, -2)
                else
                    header:SetPoint("TOPLEFT", GwSpellbookUnknown.container, "TOPLEFT", 1, -((100 * (HEADER_INDEX - 2)) + 20))
                end

                if k <= GW.mylevel then
                    b.icon:SetDesaturated(false)
                else
                    b.icon:SetDesaturated(true)
                end
                b:ClearAllPoints()
                b:SetParent(header)
                b:SetPoint("TOPLEFT", header, "TOPLEFT", x, -y)
                x = x + b:GetWidth() + 10
                if (x + b:GetWidth() + 10) > header:GetWidth() and #buttons >= buttonIndex then
                    y = y + (b:GetHeight() + 10)
                    x = 10
                    header:SetHeight(50 + y)
                end
            end
        end
    end

    local h = 20
    for i = 1, #GwSpellbookUnknown.container.headers do
        h = h + GwSpellbookUnknown.container.headers[i]:GetHeight() + 2
    end

    if #GwSpellbookUnknown.container.headers < 1 then
        GwSpellbookUnknown.filltext:Show()
    else
        GwSpellbookUnknown.filltext:Hide()
    end

    if h <= GwSpellbookUnknown.container:GetHeight() then
        GwSpellbookUnknown.slider:Hide()
        GwSpellbookUnknown.ScrollButtonUp:Hide()
        GwSpellbookUnknown.ScrollButtonDown:Hide()
    else
        GwSpellbookUnknown.slider:Show()
        GwSpellbookUnknown.ScrollButtonUp:Show()
        GwSpellbookUnknown.ScrollButtonDown:Show()
        GwSpellbookUnknown.slider.thumb:SetHeight((GwSpellbookUnknown.container:GetHeight() / h) * GwSpellbookUnknown.slider:GetHeight())
        GwSpellbookUnknown.slider:SetMinMaxValues(0, math.max(0, h - GwSpellbookUnknown.container:GetHeight()))
        GwSpellbookUnknown.slider:SetValue(0)
    end
end

local function updateSpellbookTab()
    if InCombatLockdown() then
        GwSpellbookMenu:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    local knownSpellID = {}

    for spellBookTabs = 1, 5 do
        local name, texture, offset, numSpells = GetSpellTabInfo(spellBookTabs)
        local BOOKTYPE = 'spell'

        local pagingID = 1
        local pagingContainer = _G['GwSpellbookContainerTab' .. spellBookTabs .. 'container' .. pagingID]
        _G['GwSpellbookContainerTab' .. spellBookTabs].tabs = 1

        SpellbookHeaderIndex = 1
        spellButtonIndex = 1

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
            local skillType = GetSpellBookItemInfo(spellIndex, BOOKTYPE)
            local ispassive = IsPassiveSpell(spellID)
            local icon = GetSpellBookItemTexture(spellIndex, BOOKTYPE)
            local name, rank, spellID = GetSpellBookItemName(spellIndex, BOOKTYPE)

            rank = rank and string.match(rank, "[%d]") or ""
            knownSpellID[#knownSpellID + 1] = spellID

            needNewHeader = true
            if lastName == name then
                needNewHeader = false
            end

            local mainButton = setButtonStyle(ispassive, spellID, skillType, icon, spellIndex, BOOKTYPE, spellBookTabs, name, rank)
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
                header.title:SetText(name)
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
            lastName = name
            lastButton = mainButton

            setUpPaging(_G['GwSpellbookContainerTab' .. spellBookTabs])
        end

        for i = boxIndex, 100 do
            _G['GwSpellbookTab' .. spellBookTabs .. 'Actionbutton' .. i]:SetAlpha(0)
            _G['GwSpellbookTab' .. spellBookTabs .. 'Actionbutton' .. i]:EnableMouse(false)
            _G['GwSpellbookTab' .. spellBookTabs .. 'Actionbutton' .. boxIndex]:SetScript('OnEvent', nil)
        end
        for i = SpellbookHeaderIndex + 1, 100 do
            if _G['GwSpellbookContainerTab' .. spellBookTabs .. 'GwSpellbookActionBackground' .. i] then
                _G['GwSpellbookContainerTab' .. spellBookTabs .. 'GwSpellbookActionBackground' .. i]:Hide()
            end
        end
    end

    updateUnknownTab(knownSpellID)
end

local function spellBookTab_onClick(self)
    GwspellbookTab1.background:Hide()
    GwspellbookTab2.background:Hide()
    GwspellbookTab3.background:Hide()
    GwspellbookTab4.background:Hide()
    GwspellbookTab5.background:Hide()
    GwspellbookTab6.background:Hide()
    self.background:Show()
end

local function LoadSpellBook()
    CreateFrame('Frame', 'GwSpellbook', GwCharacterWindow, 'GwSpellbook')
    CreateFrame('Frame', 'GwSpellbookMenu', GwSpellbook, 'GwSpellbookMenu')

    GwSpellbook.showAllSpellRanks.checkbutton:SetScript("OnClick", function(self)
        SetCVar("ShowAllSpellRanks", self:GetChecked())
        updateSpellbookTab()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)

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
    mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\windowbg-mask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(853, 853)

    for tab = 1, 5 do
        local menuItem = CreateFrame('Button', 'GwspellbookTab' .. tab,GwSpellbookMenu, 'GwspellbookTab')
        menuItem:SetPoint("TOPLEFT", GwSpellbookMenu, "TOPLEFT", 0, -menuItem:GetHeight() * (tab - 1))
        local container = CreateFrame('Frame', 'GwSpellbookContainerTab' .. tab,GwSpellbook, 'GwSpellbookContainerTab')
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
        for i = 1, 100 do
            local f = CreateFrame('Button', 'GwSpellbookTab' .. tab .. 'Actionbutton' .. i, container.container1, 'GwSpellbookActionbutton')
            local mask = UIParent:CreateMaskTexture()
            mask:SetPoint("CENTER", f, 'CENTER', 0, 0)

            mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            mask:SetSize(40, 40)

            f.mask = mask
            f.rank:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINE")
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

    CreateFrame('ScrollFrame', 'GwSpellbookUnknown',GwSpellbook, 'GwSpellbookUnknown')
    local menuItem = CreateFrame('Button', 'GwspellbookTab' .. 6,GwSpellbookMenu, 'GwspellbookTab')
    menuItem:SetPoint("TOPLEFT", GwSpellbookMenu, "TOPLEFT", 0, -menuItem:GetHeight() * (6 - 1))
    menuItem.title:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE")
    menuItem.title:SetTextColor(0.7, 0.7, 0.5, 1)
    menuItem.title:SetText(L["Future Spells"])
    menuItem.bg:SetVertexColor(1, 1, 1, zebra)
    menuItem.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
    menuItem:ClearNormalTexture()
    menuItem:SetText("")
    GwSpellbookUnknown.title:SetText(L["FUTURE_SPELLS"])


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
    GwspellbookTab6:SetFrameRef('GwSpellbookMenu', GwSpellbookMenu)
    GwspellbookTab6:SetAttribute("_onclick", [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen', 6)
    ]=])
    GwspellbookTab5:SetFrameRef('GwspellbookTab6', GwspellbookTab6)
    GwspellbookTab5:SetAttribute("_onstate-petstate", [=[
        if newstate == "nopet" then
            self:GetFrameRef('GwspellbookTab6'):SetPoint("TOPLEFT",self:GetFrameRef('GwSpellbookMenu'),"TOPLEFT",0,-44*4)
            self:Hide()
            if self:GetFrameRef('GwSpellbookMenu'):GetAttribute('tabopen') then
                self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen', 2)
            end
        elseif newstate == "hasPet" then
            self:GetFrameRef('GwspellbookTab6'):SetPoint("TOPLEFT",self:GetFrameRef('GwSpellbookMenu'),"TOPLEFT",0,-44*5)
            self:Show()
        end
    ]=])
    RegisterStateDriver(GwspellbookTab5, "petstate", "[target=pet,noexists] nopet; [target=pet,help] hasPet;")


    GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab1',GwSpellbookContainerTab1)
    GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab2',GwSpellbookContainerTab2)
    GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab3',GwSpellbookContainerTab3)
    GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab4',GwSpellbookContainerTab4)
    GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab5',GwSpellbookContainerTab5)
    GwSpellbookMenu:SetFrameRef('GwSpellbookUnknown',GwSpellbookUnknown)
    GwSpellbookMenu:SetAttribute('_onattributechanged', [=[
        if name~='tabopen' then return end

        self:GetFrameRef('GwSpellbookContainerTab1'):Hide()
        self:GetFrameRef('GwSpellbookContainerTab2'):Hide()
        self:GetFrameRef('GwSpellbookContainerTab3'):Hide()
        self:GetFrameRef('GwSpellbookContainerTab4'):Hide()
        self:GetFrameRef('GwSpellbookContainerTab5'):Hide()
        self:GetFrameRef('GwSpellbookUnknown'):Hide()

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
        if value == 6 then
            self:GetFrameRef('GwSpellbookUnknown'):Show()
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
    GwspellbookTab6:HookScript('OnClick', spellBookTab_onClick)
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
