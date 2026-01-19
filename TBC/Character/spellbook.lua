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
    button.mask:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_border.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    button.mask:SetSize(40, 40)
    button.mask:SetParent(button)

    button.rank:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINE")
    button.rank:SetTextColor(0.9, 0.9, 0.8, 1)

    button.modifiedClick = SpellButton_OnModifiedClick
    button:RegisterForClicks("AnyDown")
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
        btn.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_highlight.png")
        btn.icon:AddMaskTexture(btn.mask)
        btn.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_outline.png")
    else
        btn.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/active_highlight.png")
        btn.icon:RemoveMaskTexture(btn.mask)
        btn.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/background_border.png")
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

local UNKNOW_SPELL_MAX_INDEX = 0
local function getUnknownSpellItem(index)
    if _G["GwSpellbookUnknownSpell"..index]~=nil then
        return _G["GwSpellbookUnknownSpell"..index]
    end

    UNKNOW_SPELL_MAX_INDEX = UNKNOW_SPELL_MAX_INDEX + 1;

    local f = CreateFrame("Button","GwSpellbookUnknownSpell"..index, GwSpellbookUnknown.container,"GwSpellbookUnknownSpell")
    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("CENTER", f, 'CENTER', 0, 0)
    mask:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_border.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
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
                    if (GW.IsPlayerSpell(reqData[1]) or GW.IsSpellKnown(reqData[1], isPet) or GW.IsSpellKnownOrOverridesKnown (reqData[1], isPet)) and (not GW.IsPlayerSpell(spellId) or not GW.IsSpellKnown(spellId, isPet) or not GW.IsSpellKnownOrOverridesKnown (spellId, isPet)) then
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
    if GW.IsPlayerSpell(spellData[1]) or GW.IsSpellKnown(spellData[1], isPet) or GW.IsSpellKnownOrOverridesKnown (spellData[1], isPet) then return true end
    if GW.IsPlayerSpell(spellData.req) or GW.IsSpellKnown(spellData.req, isPet) or GW.IsSpellKnownOrOverridesKnown (spellData.req, isPet) then return true end

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
            for _, v in pairs(spellData.race) do
                if v ~= GW.myrace then
                    return false
                end
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
                    show = not (GW.IsPlayerSpell(spellData[1]) or GW.IsSpellKnown(spellData[1], isPet) or GW.IsSpellKnownOrOverridesKnown (spellData[1], isPet)) and isAnyDependencieKnown(spellData, isPet)
                else
                    show = false
                end
            else
                show = not (GW.IsPlayerSpell(spellData[1]) or GW.IsSpellKnown(spellData[1], isPet) or GW.IsSpellKnownOrOverridesKnown (spellData[1], isPet)) and isAnyDependencieKnown(spellData, isPet)
            end
        end
    elseif isHigherKnownAndThisNot then
        show = false
    elseif GW.IsSpellKnown(spellData[1]) or GW.IsPlayerSpell(spellData[1]) or GW.IsSpellKnownOrOverridesKnown (spellData[1]) then
        show = false
    end

    return show
end

local function updateUnknownTab()
    UNKNOW_SPELL_MAX_INDEX = 0
    for i = 1,UNKNOW_SPELL_MAX_INDEX do
        _G["GwSpellbookUnknownSpell" .. i]:Hide()
    end
    for i = 1,UNKNOW_SPELL_CONTAINER_MAX_INDEX do
        _G["GwUnknownSpellCat" .. i]:Hide()
    end
    GwSpellbookUnknown.slider:SetMinMaxValues(0, 0)
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
                    setUnknowSpellButton(f, icon, SpellData[1], SpellData.rank and SpellData.rank or nil, ispassive, i, SpellData[2])

                    SPELL_INDEX = SPELL_INDEX + 1
                end
            end
        end
        if #buttons > 0 then
            if i > GW.mylevel or not header then
                lastHeader= header
                header = getUnknownSpellContainer(HEADER_INDEX)
                GwSpellbookUnknown.container.headers[#GwSpellbookUnknown.container.headers + 1] = header
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
                    header:SetPoint("TOPLEFT", GwSpellbookUnknown.container, "TOPLEFT", 1, -((100 * (HEADER_INDEX - 2)) + 20))
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

local function buildSubSpellName(spellIndex, specName, isPassive, subSpellName)
    if subSpellName ~= "" then
        return subSpellName
    end
    if specName and specName ~= "" then
        return isPassive and (specName .. ", " .. SPELL_PASSIVE_SECOND) or specName
    end
    if IsTalentSpell(spellIndex, BOOKTYPE) then
        return isPassive and TALENT_PASSIVE or TALENT
    end
    if isPassive then
        return SPELL_PASSIVE
    end
    return ""
end

local function updateSpellbookTab(self)
    if self.updating then return end
    self.updating = true
    if InCombatLockdown() then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self.updating = false
        return
    end

    local showAllRanks = GetCVarBool("ShowAllSpellRanks")

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
            texture = "Interface/AddOns/GW2_UI/textures/talents/tabicon_pet.png"
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
                end
                -- get subtext
                if spellID and (needNewHeader or showAllRanks) then
                    local specs =  {GetSpecsForSpell(spellIndex, BOOKTYPE)}
                    local specName = table.concat(specs, PLAYER_LIST_DELIMITER)
                    local spell = Spell:CreateFromSpellID(spellID)
                    spell:ContinueOnSpellLoad(function()
                        local subSpellName = buildSubSpellName(spellIndex, specName, isPassive, spell:GetSpellSubtext())

                        if showAllRanks then
                            button.rank:SetText(subSpellName:gsub(RANK, "") or "")
                        else
                            button.rank:SetText("")
                        end

                        header.subTitle:SetText(needNewHeader and subSpellName or "")
                    end)
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

    updateUnknownTab()

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

    spellBook:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE")
	spellBook:RegisterEvent("PLAYER_GUILD_UPDATE")
	spellBook:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    spellBook:RegisterEvent("SPELLS_CHANGED")
    spellBook:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE")
    spellBook:RegisterEvent("SKILL_LINES_CHANGED")
    spellBook:RegisterEvent("PLAYER_LEVEL_UP")
    spellBook:SetScript("OnEvent", OnEvent)
    spellBook:Hide()

    spellBook.tabs = {}
    spellBook.container = {}

    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("TOPLEFT", GwCharacterWindow, "TOPLEFT", 0, 0)
    mask:SetTexture("Interface/AddOns/GW2_UI/textures/character/windowbg-mask.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(853, 853)

    spellBook.showAllSpellRanks.checkbutton:SetScript("OnClick", function(self)
        SetCVar("ShowAllSpellRanks", self:GetChecked())
        updateSpellbookTab(spellBook)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)


    for tab = 1, 5 do
        local menuItem = CreateFrame("Button", "GwspellbookTab" .. tab, menu, "GwspellbookTab")
        menuItem:SetPoint("TOPLEFT", menu, "TOPLEFT", 0, -menuItem:GetHeight() * (tab - 1))
        local container = CreateFrame("Frame", "GwSpellbookContainerTab" .. tab, spellBook,  "GwSpellbookContainerTab")
        container.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, "OUTLINE")
        container.title:SetTextColor(0.9, 0.9, 0.7, 1)
        container.pages:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, "OUTLINE", 2)
        container.pages:SetTextColor(0.7, 0.7, 0.5, 1)

       local zebra = tab % 2
        menuItem.title:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
        menuItem.title:SetTextColor(0.7, 0.7, 0.5, 1)
        menuItem.bg:SetVertexColor(1, 1, 1, zebra)
        menuItem.hover:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
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
                self:GetFrameRef('GwSpellbookUnknown'):Hide()

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
                if value == 6 then
                    self:GetFrameRef('GwSpellbookUnknown'):Show()
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

    local container = CreateFrame('ScrollFrame', 'GwSpellbookUnknown', GwSpellbook, 'GwSpellbookUnknown')
    local menuItem = CreateFrame('Button', 'GwspellbookTab6', GwSpellbookMenu, 'GwspellbookTab')
    container.title:SetText(L["Future Spells"])
    container:Hide()
    menuItem:SetPoint("TOPLEFT", GwSpellbookMenu, "TOPLEFT", 0, -menuItem:GetHeight() * 5)
    menuItem.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL, "OUTLINE")
    menuItem.title:SetTextColor(0.7, 0.7, 0.5, 1)
    menuItem.title:SetText(L["Future Spells"])
    local hasPet = GW.myClassID == 3 or GW.myClassID == 9 or GW.myClassID == 6
    menuItem.bg:SetVertexColor(1, 1, 1, ((hasPet and 6 or 5) % 2))
    menuItem.hover:SetTexture('Interface/AddOns/GW2_UI/textures/character/menu-hover.png')
    menuItem:ClearNormalTexture()
    menuItem:SetText("")

    menuItem:SetFrameRef("GwSpellbookMenu", menu)
    menuItem:SetAttribute("_onclick", format([=[self:GetFrameRef("GwSpellbookMenu"):SetAttribute("tabopen", %s)]=], 6))
    menu:SetFrameRef("GwSpellbookUnknown", container)

    tinsert(spellBook.tabs, menuItem)
    tinsert(spellBook.container, container)
    spellBook.tabs[6].buttons = {}
    spellBook.container[6].headerFrame = {}

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
