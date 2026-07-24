---@class GW2
local GW = select(2, ...)
local L = GW.L

local spellbookFrame, spellbookMenu, unknownFrame
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

    if GW.IsSpellKnown(self.spellId, isPet) and self.futureSpellOverrider == nil then
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
    self.attrDummy:SetFrameRef('container5', self.container5)
    self.attrDummy:SetFrameRef('container6', self.container6)
    self.attrDummy:SetFrameRef('container7', self.container7)
    self.attrDummy:SetFrameRef('left', self.left)
    self.attrDummy:SetFrameRef('right', self.right)
    self.attrDummy:SetAttribute('_onattributechanged', ([=[
        if name ~= 'page' then return end

        local p1 = self:GetFrameRef('container1')
        local p2 = self:GetFrameRef('container2')
        local p3 = self:GetFrameRef('container3')
        local p4 = self:GetFrameRef('container4')
        local p5 = self:GetFrameRef('container5')
        local p6 = self:GetFrameRef('container6')
        local p7 = self:GetFrameRef('container7')
        local left = self:GetFrameRef('left')
        local right = self:GetFrameRef('right')
        local numPages = %s
        local currentPage = 1

        if value == "left" then
            if p7:IsVisible() then
                p7:Hide()
                p6:Show()
                currentPage = 6
            elseif p6:IsVisible() then
                p6:Hide()
                p5:Show()
                currentPage = 5
            elseif p5:IsVisible() then
                p5:Hide()
                p4:Show()
                currentPage = 4
            elseif p4:IsVisible() then
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
            elseif p4:IsVisible() then
                p4:Hide()
                p5:Show()
                currentPage = 5
            elseif p5:IsVisible() then
                p5:Hide()
                p6:Show()
                currentPage = 6
            elseif p6:IsVisible() then
                p6:Hide()
                p7:Show()
                currentPage = 7
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

local function getUnknownSpellItem(index)
    local f = unknownFrame.spellItems[index]
    if f then
        return f
    end

    f = CreateFrame("Button", nil, unknownFrame.container, "GwSpellbookUnknownSpell")
    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("CENTER", f, "CENTER", 0, 0)
    mask:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_border.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(40, 40)

    f.mask = mask
    unknownFrame.spellItems[index] = f
    return f
end
local function getUnknownSpellContainer(index)
    local category = unknownFrame.categories[index]
    if category then
        return category
    end

    category = CreateFrame("Button", nil, unknownFrame.container, "GwUnknownSpellCat")
    unknownFrame.categories[index] = category
    return category
end
local function setUnknownSpellButton(self, icon, spellID, rank, ispassive, level, money)
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
        self.highlight:SetTexture('Interface/AddOns/GW2_UI/textures/talents/passive_highlight.png' )
        self.icon:AddMaskTexture(self.mask)
        self.outline:SetTexture('Interface/AddOns/GW2_UI/textures/talents/passive_outline.png')
    else
        self.highlight:SetTexture('Interface/AddOns/GW2_UI/textures/talents/active_highlight.png' )
        self.icon:RemoveMaskTexture(self.mask)
        self.outline:SetTexture('Interface/AddOns/GW2_UI/textures/talents/background_border.png')
    end
    self:SetScript("OnEnter", spell_buttonOnEnter)
    self:SetScript("OnLeave", GameTooltip_Hide)
end

local function depIsTalentAndLearned(name)
    for i = 1, GetNumTalentTabs(false, false) do
        for y = 1, MAX_NUM_TALENTS do
            local talentInfoQuery = {}
            talentInfoQuery.isInspect = false
            talentInfoQuery.isPet = false
            talentInfoQuery.groupIndex = GW.GetTalentSpec()
            talentInfoQuery.specializationIndex = i
            talentInfoQuery.talentIndex = y
            local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)
            if talentInfo and talentInfo.isExceptional then
                local spellInfo = C_Spell.GetSpellInfo(talentInfo.name)
                if spellInfo and name == talentInfo.name then
                    return true, (talentInfo.rank == talentInfo.maxRank and spellInfo.spellID ~= nil and spellInfo.spellID > 0)
                end
            end

        end
    end

    return false, false
end

local function isHigherRankKnownAndThisNot(spellId, isPet)
    if not spellId then return false end
    if GW.IsPlayerSpell(spellId) or GW.IsSpellKnown(spellId, isPet) then return false end
    for i = 1, 60 do
        if GW.Skills[GW.myclass][i] then
            for _ ,reqData in pairs(GW.Skills[GW.myclass][i]) do
                if spellId == reqData.req then
                    isPet = reqData.pet ~= nil and reqData.pet == true
                    if (GW.IsPlayerSpell(reqData[1]) or GW.IsSpellKnown(reqData[1], isPet) or GW.IsSpellInSpellBook (reqData[1], isPet)) and (not GW.IsPlayerSpell(spellId) or not GW.IsSpellKnown(spellId, isPet) or not GW.IsSpellInSpellBook (spellId, isPet)) then
                        return true
                    else
                        return isHigherRankKnownAndThisNot(reqData[1], isPet)
                    end
                end
            end
        end
    end
    return false
end

local function isAnyDependencieKnown(spellData, isPet)
    if GW.IsPlayerSpell(spellData[1]) or GW.IsSpellKnown(spellData[1], isPet) or GW.IsSpellInSpellBook (spellData[1], isPet) then return true end
    if GW.IsPlayerSpell(spellData.req) or GW.IsSpellKnown(spellData.req, isPet) or GW.IsSpellInSpellBook (spellData.req, isPet) then return true end

    return false
end

local function filterUnknownSpell(spellData)
    local isPet = spellData.pet ~= nil and spellData.pet == true
    local show, isHigherKnownAndThisNot = true, isHigherRankKnownAndThisNot(spellData[1], isPet)

    if spellData.faction then
        if spellData.faction ~= GW.myfaction then
            return false
        end
    end

    if spellData.race then
        if type(spellData.race) == "table" then
            local raceMatch = false
            for _, v in pairs(spellData.race) do
                if v == GW.myrace then
                    raceMatch = true
                    break
                end
            end
            if not raceMatch then
                return false
            end
        else
            if spellData.race ~= GW.myrace then
                return false
            end
        end
    end

    if spellData.req then
        if isHigherKnownAndThisNot then
            show = false
        else
            local name = GetSpellInfo(spellData.req)
            local isTalent, learned = depIsTalentAndLearned(name)

            if isTalent then
                if learned then
                    show = not (GW.IsPlayerSpell(spellData[1]) or GW.IsSpellKnown(spellData[1], isPet) or GW.IsSpellInSpellBook (spellData[1], isPet)) and isAnyDependencieKnown(spellData, isPet)
                else
                    show = false
                end
            else
                show = not (GW.IsPlayerSpell(spellData[1]) or GW.IsSpellKnown(spellData[1], isPet) or GW.IsSpellInSpellBook (spellData[1], isPet)) and isAnyDependencieKnown(spellData, isPet)
            end
        end
    elseif isHigherKnownAndThisNot then
        show = false
    elseif GW.IsSpellKnown(spellData[1]) or GW.IsPlayerSpell(spellData[1]) or GW.IsSpellInSpellBook (spellData[1]) then
        show = false
    end

    return show
end

local function updateUnknownTab()
    for i = 1, #unknownFrame.spellItems do
        unknownFrame.spellItems[i]:Hide()
    end
    for i = 1, #unknownFrame.categories do
        unknownFrame.categories[i]:Hide()
    end
    unknownFrame.slider:SetMinMaxValues(0, 0)
    unknownFrame.container.headers = {}

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

    for i = 1, 80 do
        local buttons = {}

        if GW.Skills[GW.myclass][i] then
            for _ ,SpellData in pairs(GW.Skills[GW.myclass][i]) do
                if filterUnknownSpell(SpellData) then
                    local f = getUnknownSpellItem(SPELL_INDEX)
                    f:Show()
                    local _, _, icon =  GetSpellInfo(SpellData[1])
                    local ispassive = IsPassiveSpell(SpellData[1])
                    SpellData.rank = GetSpellSubtext(SpellData[1])
                    SpellData.rank = SpellData.rank and SpellData.rank:gsub(RANK, "") or ""

                    buttons[#buttons + 1] = f
                    setUnknownSpellButton(f, icon, SpellData[1], SpellData.rank and SpellData.rank or nil, ispassive, i, SpellData[2])

                    SPELL_INDEX = SPELL_INDEX + 1
                end
            end
        end
        if #buttons > 0 then
            if i > GW.mylevel or not header then
                lastHeader= header
                header = getUnknownSpellContainer(HEADER_INDEX)
                unknownFrame.container.headers[#unknownFrame.container.headers + 1] = header
                header:Show()
                header:SetHeight(100)
                x = 10
                y = 40
                zebraHeader = zebraHeader + 1
                if zebraHeader > 3 then
                    zebraHeader = 1
                end
                HEADER_INDEX = HEADER_INDEX + 1
            end

            txT = (zebraHeader - 1) * txH

            header.repbg:SetTexture("Interface/AddOns/GW2_UI/textures/talents/art/" .. GW.myClassID)
            header.repbg:SetTexCoord(0, txR, txT / txMH, (txT + txH) / txMH)

            if i <= GW.mylevel then
                header.repbg:SetDesaturated(false)
                header.title:SetText(AVAILABLE)
                header.title:SetTextColor(0.9, 0.9, 0.7, 1)
            else
                header.repbg:SetDesaturated(true)
                header.title:SetText(UNLOCKED_AT_LEVEL:format(i))
                header.title:SetTextColor(0.8,.8,.8,0.5)
            end

            for buttonIndex = 1, #buttons do
                local b = buttons[buttonIndex]

                if lastHeader then
                    header:SetPoint("TOPLEFT", lastHeader, "BOTTOMLEFT", 0, -2)
                else
                    header:SetPoint("TOPLEFT", unknownFrame.container, "TOPLEFT", 1, -((100 * (HEADER_INDEX - 2)) + 20))
                end

                if i <= GW.mylevel then
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
    for i = 1, #unknownFrame.container.headers do
        h = h + unknownFrame.container.headers[i]:GetHeight() + 2
    end

    if #unknownFrame.container.headers < 1 then
        unknownFrame.filltext:Show()
    else
        unknownFrame.filltext:Hide()
    end

    if h <= unknownFrame.container:GetHeight() then
        unknownFrame.slider:Hide()
        unknownFrame.ScrollButtonUp:Hide()
        unknownFrame.ScrollButtonDown:Hide()
    else
        unknownFrame.slider:Show()
        unknownFrame.ScrollButtonUp:Show()
        unknownFrame.ScrollButtonDown:Show()
        unknownFrame.slider.thumb:SetHeight((unknownFrame.container:GetHeight() / h) * unknownFrame.slider:GetHeight())
        unknownFrame.slider:SetMinMaxValues(0, math.max(0, h - unknownFrame.container:GetHeight()))
        unknownFrame.slider:SetValue(0)
    end
end

local function updateSpellbookTab()
    if InCombatLockdown() then
        spellbookMenu:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    local numBooks = GW.ClassicSOD and 6 or 5

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
                        pagingContainer = tabContainer['container' .. pagingID]
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

        setUpPaging(tabContainer)

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

    updateUnknownTab()
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

    unknownFrame = CreateFrame('ScrollFrame', 'GwSpellbookUnknown', spellbookFrame, 'GwSpellbookUnknown')
    unknownFrame.spellItems = {}
    unknownFrame.categories = {}
    local menuItem = CreateFrame('Button', 'GwspellbookTab' .. numBooks + 1, spellbookMenu, 'GwspellbookTab')
    tabMenuItems[numBooks + 1] = menuItem
    menuItem:SetPoint("TOPLEFT", spellbookMenu, "TOPLEFT", 0, -menuItem:GetHeight() * numBooks)
    menuItem.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal, "OUTLINE")
    menuItem.title:SetTextColor(0.7, 0.7, 0.5, 1)
    menuItem.title:SetText(L["Future Spells"])
    menuItem.bg:SetVertexColor(1, 1, 1, ((numBooks + 1) % 2))
    menuItem.hover:SetTexture('Interface/AddOns/GW2_UI/textures/character/menu-hover.png')
    menuItem:ClearNormalTexture()
    menuItem:SetText("")
    unknownFrame.title:SetText(L["Future Spells"])
    spellbookMenu:SetFrameRef('GwSpellbookUnknown', unknownFrame)
    menuItem:SetFrameRef('GwSpellbookMenu', spellbookMenu)
    menuItem:SetAttribute("_onclick", format([=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen', %s)
    ]=], numBooks + 1))

    local futureTab = menuItem:GetName()
    -- pet tab
    petTab:SetFrameRef(futureTab, menuItem)
    petTab:SetAttribute("_onstate-petstate", format([=[
        local numTabs = self:GetFrameRef('GwSpellbookMenu'):GetAttribute("maxContainer")
        if newstate == "nopet" then
            self:GetFrameRef("%s"):SetPoint("TOPLEFT", self:GetFrameRef('GwSpellbookMenu'),"TOPLEFT",0,-44 * (numTabs - 1))
            self:Hide()
            if self:GetFrameRef('GwSpellbookMenu'):GetAttribute('tabopen') then
                self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen', 3)
            end
        elseif newstate == "hasPet" then
            self:GetFrameRef("%s"):SetPoint("TOPLEFT",self:GetFrameRef('GwSpellbookMenu'),"TOPLEFT",0,-44 * numTabs)
            self:Show()
        end
    ]=], futureTab, futureTab))
    RegisterStateDriver(petTab, "petstate", "[target=pet,noexists] nopet; [target=pet,help] hasPet;")


    spellbookMenu:SetAttribute('_onattributechanged', [=[
        if name~='tabopen' then return end

        local numBooks = self:GetAttribute("maxContainer")
        for i = 1, numBooks do
            self:GetFrameRef('GwSpellbookContainerTab' .. i):Hide()
        end
        self:GetFrameRef('GwSpellbookUnknown'):Hide()

        if value >= 1 and value <= numBooks then
            self:GetFrameRef('GwSpellbookContainerTab' .. value):Show()
            return
        end

        if value == (numBooks + 1) then
            self:GetFrameRef('GwSpellbookUnknown'):Show()
            return
        end
    ]=])
    spellbookMenu:SetAttribute('tabopen', 2)

    petTab:HookScript('OnHide', function() spellBookTab_onClick(tabMenuItems[3]) end)

    spellbookMenu:SetScript('OnShow', function()
        if InCombatLockdown() then return end
        updateSpellbookTab()
    end)
    hooksecurefunc('ToggleSpellBook', function()
        if InCombatLockdown() then return end
        GwCharacterWindow:SetAttribute('windowPanelOpen', "spellbook")
    end)

    SpellBookFrame:UnregisterAllEvents()
end
GW.LoadSpellBook = LoadSpellBook
