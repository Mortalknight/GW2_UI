local _, GW = ...

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
            local name, desc, numSlots, isKnown = GetFlyoutInfo(self.spellId)
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
    end
    GameTooltip:Show()
end

local function spell_buttonOnLeave(self)
    GameTooltip:Hide()
end

local function spellbookButton_onEvent(self)
    if not GwSpellbook:IsShown() then return end

    local start, duration, enable = GetSpellCooldown(self.spellbookIndex, self.booktype)

    if start ~= nil and duration ~= nil and IsSpellKnown(self.spellId) then
        self.cooldown:SetCooldown(start, duration)
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
local function getSpellBookHeader(tab,pagingContainer)
    if _G['GwSpellbookContainerTab' .. tab .. 'GwSpellbookActionBackground' .. SpellbookHeaderIndex] ~= nil then
        local f = _G['GwSpellbookContainerTab' .. tab .. 'GwSpellbookActionBackground' .. SpellbookHeaderIndex]
        return f
    end

    local f = CreateFrame("Frame", 'GwSpellbookContainerTab' .. tab .. 'GwSpellbookActionBackground' .. SpellbookHeaderIndex,  _G['GwSpellbookContainerTab' .. tab], "GwSpellbookActionBackground"   )


    return f
end

local function setHeaderLocation(self,tab,pagingContainer)
    local prev

    if pagingContainer.headers[#pagingContainer.headers] ~=nil then
        prev = pagingContainer.headers[#pagingContainer.headers]
    end
    self:ClearAllPoints()
    self:SetParent(pagingContainer)

    if prev~= nil then
        if ((#pagingContainer.headers+1) % 2)==0 then
            local prev2

            if pagingContainer.headers[#pagingContainer.headers - 1]~=nil then
                prev2 = pagingContainer.headers[#pagingContainer.headers - 1]
            end
            if prev2 ~= nil then
                self:SetPoint("TOPLEFT", prev2, "BOTTOMLEFT", 0, -5)
                self.column = 2
            else
                self:SetPoint("TOPLEFT", prev, "TOPRIGHT", 0, 0)
                self.column = 2
            end
        else
            prev =  pagingContainer.headers[#pagingContainer.headers - 1]
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
local function setButtonStyle(ispassive, isFuture, spellID, skillType, icon, spellbookIndex, booktype, tab, name, rank, level)
    local _, autostate = GetSpellAutocast(spellbookIndex, booktype)

    _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].autocast:Hide()
    if autostate then
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].autocast:Show()
    end

    _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].isPassive = ispassive
    _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].isFuture = (skillType == 'FUTURESPELL')
    _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].isFlyout = (skillType == 'FLYOUT')
    _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].spellbookIndex = spellbookIndex
    _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].booktype = booktype
    _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]:EnableMouse(true)
    _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].spellId = spellID
    _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].requiredLevel = level
    _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].icon:SetTexture(icon)
    _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]:SetAlpha(1)

    if rank ~= nil then
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].rank:SetText(rank)
    else
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].rank:SetText("")
    end
    if level ~= nil then
        if level > GW.mylevel then
            _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].lock:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\spell-lock");
        else
            _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].lock:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\spell-unlock");
        end
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].lock:Show()
    else
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].lock:Hide()
    end

    if booktype == 'pet' then
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]:SetAttribute("type", "spell")
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]:SetAttribute("*spell", spellID)
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]:SetAttribute("type2", "macro")
        if name ~= nil then
            _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]:SetAttribute("*macrotext2", "/petautocasttoggle " .. name)
        end
    else
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]:SetAttribute("type", "spell")
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]:SetAttribute("spell", spellID)
    end
    _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].arrow:Hide()
    _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]:SetScript('OnEvent', spellbookButton_onEvent)

    if skillType == 'FUTURESPELL' then
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].icon:SetDesaturated(true)
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].icon:SetAlpha(0.5)
    elseif skillType == 'FLYOUT' then
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].arrow:Show()
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]:SetAttribute("type", "flyout")
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]:SetAttribute("flyout", spellID)
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]:SetAttribute("flyoutDirection", 'RIGHT')

        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].icon:SetDesaturated(false)
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].icon:SetAlpha(1)
    else
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].icon:SetDesaturated(false)
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].icon:SetAlpha(1)
    end

    if ispassive then
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight' )
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].icon:AddMaskTexture(_G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].mask)
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_outline')
    else
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight' )
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].icon:RemoveMaskTexture(_G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].mask)
        _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex].outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\background_border')
    end
    spellbookButton_onEvent(_G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex])
    _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]:Show()

    return _G['GwSpellbookTab' .. tab .. 'Actionbutton' .. spellButtonIndex]
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
        --self:SetFrameRef('GwSpellbookMenu', GwSpellbookMenu)
    local numPages = self.tabs



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

    local glueMethod = [=[

    if name~='page' then return end

    local p1 = self:GetFrameRef('container1')
    local p2 = self:GetFrameRef('container2')
    local p3 = self:GetFrameRef('container3')
    local p4 = self:GetFrameRef('container4')
    local left = self:GetFrameRef('left')
    local right = self:GetFrameRef('right')
    ]=]
    glueMethod = glueMethod.."local numPages = "..numPages.." "
    glueMethod=glueMethod..[=[

    local currentPage = 1

    if value=="left" then
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
    if value=="right" then
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

    if currentPage>=numPages then
        right:Hide()
    else
        right:Show()
    end
    if currentPage==1 then
        left:Hide()
    else
        left:Show()
    end


    ]=]


    self.attrDummy:SetAttribute('_onattributechanged',glueMethod)
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
    if _G["GwUnknownSpellCat"..index]~=nil then
        return _G["GwUnknownSpellCat"..index]
    end

    UNKNOW_SPELL_CONTAINER_MAX_INDEX = UNKNOW_SPELL_CONTAINER_MAX_INDEX + 1;

    local f = CreateFrame("Button","GwUnknownSpellCat"..index, GwSpellbookUnknown.container,"GwUnknownSpellCat")
    return f
end
local function setUnknowSpellButton(self,icon,spellID,rank,ispassive,level)
    self.icon:SetTexture(icon)
    self.spellId = spellID
    self.booktype = "spell"
    self.isFuture = true
    self.isFlyout = false
    self.futureSpellOverrider = true
    self.requiredLevel = level

    if rank ~= nil then
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
    self:SetScript("OnEnter",spell_buttonOnEnter)
    self:SetScript("OnLeave",spell_buttonOnLeave)
end

local function filterUnknownSpell(knownSpellID,spell)
    local show = true

    if  GW.tableContains(knownSpellID,spell.id) then
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
    for i=1,UNKNOW_SPELL_MAX_INDEX do
        _G["GwSpellbookUnknownSpell"..i]:Hide()
    end
    for i=1,UNKNOW_SPELL_CONTAINER_MAX_INDEX do
        _G["GwUnknownSpellCat"..i]:Hide()
    end
    GwSpellbookUnknown.slider:SetMinMaxValues(0,0)
    GwSpellbookUnknown.container.headers = {}

    local SPELL_INDEX = 1
    local HEADER_INDEX = 1
    local zebraHeader = 1
    local lastHeader
    local header
    local _, _, classID = UnitClass('player')
    local txR, txT, txH, txMH
    txR = 588 / 1024
    txH = 140
    txMH = 512
    local x = 10
    local y = 50

    for k,v in GW.orderedPairs(GW.SpellsByLevel) do
        local buttons = {}
        for _,spell in pairs(v) do
            if  filterUnknownSpell(knownSpellID,spell) then
                local f =  getUnknownSpellItem(SPELL_INDEX)
                f:Show()
                local name, rank, icon, castingTime, minRange, maxRange, spellID =  GetSpellInfo(spell.id)
                local ispassive = IsPassiveSpell(spellID)

                buttons[#buttons + 1] = f
                setUnknowSpellButton(f,icon,spellID,spell.rank,ispassive,k)


                SPELL_INDEX = SPELL_INDEX + 1
            end
        end
        if #buttons > 0 then

            if k > GW.mylevel or header==nil then
                lastHeader= header
                header = getUnknownSpellContainer(HEADER_INDEX)
                GwSpellbookUnknown.container.headers[#GwSpellbookUnknown.container.headers +1] = header
                header:Show()
                header:SetHeight(100)
                x = 10
                y = 50
                zebraHeader = zebraHeader + 1
                if zebraHeader>3 then
                    zebraHeader = 1
                end
                HEADER_INDEX =HEADER_INDEX + 1
            end

            txT = (zebraHeader - 1) * txH

            header.repbg:SetTexture("Interface/AddOns/GW2_UI/textures/talents/art/" .. classID)
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

                if lastHeader~=nil then
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
                if (x + b:GetWidth() + 10) > header:GetWidth() then
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
    if InCombatLockdown() then return end

    local knownSpellID = {}

    for spellBookTabs = 1, 5 do
        local name, texture, offset, numSpells = GetSpellTabInfo(spellBookTabs)
        local BOOKTYPE = 'spell'

        local pagingID = 1;
        local pagingContainer = _G['GwSpellbookContainerTab' .. spellBookTabs..'container'..pagingID]
        _G['GwSpellbookContainerTab' .. spellBookTabs].tabs = 1

        SpellbookHeaderIndex = 1
        spellButtonIndex = 1

        if spellBookTabs == 5 then
            BOOKTYPE='pet'
            numSpells = HasPetSpells()
            offset = 0
            name = PET
            texture = "Interface\\AddOns\\GW2_UI\\textures\\talents\\tabicon_pet"
            if numSpells == nil then
                numSpells = 0
            end
        end
        _G['GwspellbookTab' .. spellBookTabs].icon:SetTexture(texture)
        _G['GwspellbookTab' .. spellBookTabs].title:SetText(name)
        _G['GwSpellbookContainerTab' .. spellBookTabs].title:SetText(name)

        local boxIndex = 1
        local lastSkillid = 0
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

            rank = string.match(rank, "[%d]")
            knownSpellID[#knownSpellID + 1] = spellID

            --[[ --TODO: Need new spells for TBC
            --find requiredTalentID if needed
            for k, v in pairs(GW.SpellsByLevel) do
                for _, spell in pairs(v) do
                    if spell.id == spellID and spell.rank ~= nil then
                        rank = spell.rank
                    end
                end
            end

            for k, v in pairs(GW.SpellsByLevel) do
                for _, spell in pairs(v) do
                    local contains
                    if spell.requiredIds ~= nil then
                        if spell.id == spellID then
                            contains = GW.tableContains(spell.requiredIds, lastSkillid)
                        end
                        if contains then
                            needNewHeader = false
                        end
                    end
                end
            end
            ]]

            needNewHeader = true
            if lastName == name then
                needNewHeader = false
            end

            local mainButton = setButtonStyle(ispassive, isFuture, spellID, skillType, icon, spellIndex, BOOKTYPE, spellBookTabs, name, rank)
            spellButtonIndex = spellButtonIndex + 1
            boxIndex = boxIndex + 1

            local unlearnd = {}
            --unlearnd = findHigherRank(unlearnd, spellID)  --TODO: Need new spells for TBC

            if needNewHeader then
                local currentHeight = getHeaderHeight(pagingContainer,header)
                if currentHeight>(pagingContainer:GetHeight() - 120 ) then
                    pagingID = pagingID + 1;
                    pagingContainer = _G['GwSpellbookContainerTab' .. spellBookTabs..'container'..pagingID]
                    pagingContainer.headers = {}
                    pagingContainer.column1 = 0
                    pagingContainer.column2 = 0
                    _G['GwSpellbookContainerTab' .. spellBookTabs].tabs = pagingID

                end
                header = getSpellBookHeader(spellBookTabs,pagingContainer)
                setHeaderLocation(header,spellBookTabs,pagingContainer)
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

            --[[ --TODO: Need new spells for TBC
            local lastBox = mainButton
            for _, unknownSpellID in pairs(unlearnd) do

                local unKnownChildButton = setButtonStyle(ispassive, isFuture, unknownSpellID.id, 'FUTURESPELL', icon, spellIndex, BOOKTYPE, spellBookTabs, name, unknownSpellID.rank, unknownSpellID.level)


                unKnownChildButton:ClearAllPoints()
                unKnownChildButton:SetParent(header)
                if header.buttons == 6 then
                    unKnownChildButton:SetPoint("TOPLEFT", header.firstButton, "BOTTOMLEFT", 0, -5)
                    header.height = header.height + 45
                else
                    unKnownChildButton:SetPoint("LEFT", lastBox, "RIGHT", 5, 0)
                end
                spellButtonIndex = spellButtonIndex + 1
                boxIndex = boxIndex + 1
                lastBox = unKnownChildButton
                header.buttons = header.buttons +1
            end
            ]]
            header:SetHeight(header.height)
            --lastSkillid = spellID --TODO: Need new spells for TBC
            lastName = name
            lastButton = mainButton

            setUpPaging(_G['GwSpellbookContainerTab' .. spellBookTabs])
        end

        for i = boxIndex, 100 do
            _G['GwSpellbookTab' .. spellBookTabs .. 'Actionbutton' .. i]:SetAlpha(0)
            _G['GwSpellbookTab' .. spellBookTabs .. 'Actionbutton' .. i]:EnableMouse(false)
            _G['GwSpellbookTab' .. spellBookTabs .. 'Actionbutton' .. boxIndex]:SetScript('OnEvent', nil)
        end
    end

    --updateUnknownTab(knownSpellID)
end

local function spellBookTab_onClick(self)
    GwspellbookTab1.background:Hide()
    GwspellbookTab2.background:Hide()
    GwspellbookTab3.background:Hide()
    GwspellbookTab4.background:Hide()
    GwspellbookTab5.background:Hide()
    --GwspellbookTab6.background:Hide()
    self.background:Show()
end

local function LoadSpellBook()
    CreateFrame('Frame', 'GwSpellbook', GwCharacterWindow, 'GwSpellbook')
    CreateFrame('Frame', 'GwSpellbookMenu', GwSpellbook, 'GwSpellbookMenu')

    spellBookMenu_onLoad(GwSpellbookMenu)
    GwSpellbook:Hide()
    GwSpellbookMenu:SetScript('OnEvent', function()
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
        menuItem:SetNormalTexture(nil)
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
            f:HookScript('OnEnter', spell_buttonOnEnter)
            f:HookScript('OnLeave', spell_buttonOnLeave)
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

    --[[
    CreateFrame('ScrollFrame', 'GwSpellbookUnknown',GwSpellbook, 'GwSpellbookUnknown')
    local menuItem = CreateFrame('Button', 'GwspellbookTab' .. 6,GwSpellbookMenu, 'GwspellbookTab')
    menuItem:SetPoint("TOPLEFT", GwSpellbookMenu, "TOPLEFT", 0, -menuItem:GetHeight() * (6 - 1))
    menuItem.title:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE")
    menuItem.title:SetTextColor(0.7, 0.7, 0.5, 1)
    menuItem.title:SetText(L["Future Spells"])
    menuItem.bg:SetVertexColor(1, 1, 1, zebra)
    menuItem.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
    menuItem:SetNormalTexture(nil)
    menuItem:SetText("")
    GwSpellbookUnknown.title:SetText(L["Future Spells"])
    ]]

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
    --GwspellbookTab6:SetFrameRef('GwSpellbookMenu', GwSpellbookMenu)
    --GwspellbookTab6:SetAttribute("_onclick", [=[
    --    self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen', 6)
    --]=])
    --GwspellbookTab5:SetFrameRef('GwspellbookTab6', GwspellbookTab6)
    GwspellbookTab5:SetAttribute("_onstate-petstate", [=[
        if newstate == "nopet" then
            --self:GetFrameRef('GwspellbookTab6'):SetPoint("TOPLEFT",self:GetFrameRef('GwSpellbookMenu'),"TOPLEFT",0,-44*4)
            self:Hide()
            if self:GetFrameRef('GwSpellbookMenu'):GetAttribute('tabopen') then
                self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen', 2)
            end
        elseif newstate == "hasPet" then
            --self:GetFrameRef('GwspellbookTab6'):SetPoint("TOPLEFT",self:GetFrameRef('GwSpellbookMenu'),"TOPLEFT",0,-44*5)
            self:Show()
        end
    ]=])
    RegisterStateDriver(GwspellbookTab5, "petstate", "[target=pet,noexists] nopet; [target=pet,help] hasPet;")


    GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab1',GwSpellbookContainerTab1)
    GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab2',GwSpellbookContainerTab2)
    GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab3',GwSpellbookContainerTab3)
    GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab4',GwSpellbookContainerTab4)
    GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab5',GwSpellbookContainerTab5)
    --GwSpellbookMenu:SetFrameRef('GwSpellbookUnknown',GwSpellbookUnknown)
    GwSpellbookMenu:SetAttribute('_onattributechanged', [=[
        if name~='tabopen' then return end

        self:GetFrameRef('GwSpellbookContainerTab1'):Hide()
        self:GetFrameRef('GwSpellbookContainerTab2'):Hide()
        self:GetFrameRef('GwSpellbookContainerTab3'):Hide()
        self:GetFrameRef('GwSpellbookContainerTab4'):Hide()
        self:GetFrameRef('GwSpellbookContainerTab5'):Hide()
        --self:GetFrameRef('GwSpellbookUnknown'):Hide()


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
        --if value == 6 then
            --self:GetFrameRef('GwSpellbookUnknown'):Show()
            --return
        --end
    ]=])
    GwSpellbookMenu:SetAttribute('tabOpen', 2)

    GwspellbookTab1:HookScript('OnClick', spellBookTab_onClick)
    GwspellbookTab2:HookScript('OnClick', spellBookTab_onClick)
    GwspellbookTab3:HookScript('OnClick', spellBookTab_onClick)
    GwspellbookTab4:HookScript('OnClick', spellBookTab_onClick)
    GwspellbookTab5:HookScript('OnClick', spellBookTab_onClick)
    GwspellbookTab5:HookScript('OnHide', function() spellBookTab_onClick(GwspellbookTab2) end)
    --GwspellbookTab6:HookScript('OnClick', spellBookTab_onClick)
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
