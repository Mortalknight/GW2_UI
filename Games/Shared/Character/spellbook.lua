---@class GW2
local GW = select(2, ...)
local L = GW.L

local spellbookFrame
-- the client folders bring the data, the old spell book functions or C_SpellBook
local Book = GW.SpellBookData

local function SpellButton_OnModifiedClick(self)
    local slot, isPet = self.spellbookIndex, self.isPet
    if IsModifiedClick("CHATLINK") then
        if MacroFrameText and MacroFrameText:HasFocus() then
            local spell, subSpell = Book.GetName(slot, isPet)
            if spell and not Book.IsPassive(slot, isPet) then
                if subSpell and strlen(subSpell) > 0 then
                    ChatFrameUtil.InsertLink(spell .. "(" .. subSpell .. ")")
                else
                    ChatFrameUtil.InsertLink(spell)
                end
            end
        else
            ChatFrameUtil.InsertLink(Book.GetTradeSkillLink(slot, isPet) or Book.GetLink(slot, isPet))
        end
    elseif IsModifiedClick("PICKUPACTION") and not InCombatLockdown() and not Book.IsPassive(slot, isPet) then
        Book.Pickup(slot, isPet)
    end
end

local function SpellButton_OnDragStart(self)
    if InCombatLockdown() or self.isPassive or self.isFuture then return end
    Book.Pickup(self.spellbookIndex, self.isPet)
end

-- the spell flyout of mists and forever is a popup that asks its button for these, blizzard brings them with
-- FlyoutButtonMixin
local function GetPopupDirection()
    return "RIGHT"
end
local function IsPopupOpen(self)
    return SpellFlyout:IsAttachedToButton(self)
end
local function ClosePopup(self)
    if self:IsPopupOpen() then
        self:TogglePopup()
    end
end
-- a popup hidden from outside, with the window or by a click elsewhere, lets go of the button again
local function TogglePopup(self)
    if self:IsPopupOpen() then
        EventRegistry:UnregisterCallback("FlyoutPopupEvent.Hidden", self)
        SpellFlyout:DetatchFromButton()
    else
        EventRegistry:RegisterCallback("FlyoutPopupEvent.Hidden", ClosePopup, self)
        SpellFlyout:AttachToButton(self)
    end
end

local function spell_buttonOnEnter(self)
    if self.spellId == nil then return end
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()
    local spellBank = self.isPet and Enum.SpellBookSpellBank.Pet or Enum.SpellBookSpellBank.Player

    if C_SpellBook.IsSpellInSpellBook(self.spellId, spellBank, false) then
        GameTooltip:SetSpellBookItem(self.spellbookIndex, Book.Bank(self.isPet))
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
    GW.AddSpellBadgeTooltipLines(self)
    GameTooltip:Show()
end

-- the duration object needs no comparisons, forever hands secret cooldowns in combat
local function spellbookButton_onEvent(self)
    if not spellbookFrame:IsShown() or not self.cooldown or not self.spellId or self.isFlyout then return end

    local durationObject = C_Spell.GetSpellCooldownDuration(self.spellId)
    if durationObject then
        self.cooldown:SetCooldownFromDurationObject(durationObject)
    else
        self.cooldown:Clear()
    end
end

local MENU_WIDTH = 180
local NUM_COLUMNS = 3
local ENTRY_HEIGHT = 46
local ICON_SIZE = 34
local RANK_ICON_SIZE = 20
local RANK_ROW_LEFT = ICON_SIZE + 14
-- the window is 853 x 627, the pages take what the tab list and the header leave; fixed, a hidden page has no size yet
local PAGE_WIDTH = 853 - MENU_WIDTH
local PAGE_HEIGHT = 627 - 37 - 10 - 40
local ENTRIES_PER_PAGE = NUM_COLUMNS * math.floor(PAGE_HEIGHT / ENTRY_HEIGHT)
local COLUMN_WIDTH = PAGE_WIDTH / NUM_COLUMNS
local RANK_STEP = RANK_ICON_SIZE + 3
local MORE_WIDTH = 26
local RANK_ROW_WIDTH = COLUMN_WIDTH - 6 - RANK_ROW_LEFT - 4
local MAX_RANKS = math.floor(RANK_ROW_WIDTH / RANK_STEP)
local MAX_RANKS_WITH_MORE = math.floor((RANK_ROW_WIDTH - MORE_WIDTH - 4) / RANK_STEP)

local function SetButtonSize(btn, size)
    btn:SetSize(size, size)
    btn.outline:SetSize(size * 1.25, size * 1.25)
    btn.highlight:SetSize(size, size)
    btn.mask:SetSize(size, size)
    btn.autocast:SetSize(size * 1.4, size * 1.4)
    btn.arrow:SetSize(size * 0.4, size * 0.8)
    btn.rank:SetFont(DAMAGE_TEXT_FONT, size < ICON_SIZE and 10 or 12, "OUTLINE")
end

-- the hover covers the whole entry, also while the mouse is over one of its icons
local function HideEntryHover(entry)
    if not entry:IsMouseOver() then
        entry.hover:Hide()
    end
end

local function Entry_OnEnter(self)
    self.hover:Show()
    if self.mainButton then
        spell_buttonOnEnter(self.mainButton)
    end
end

local function Entry_OnLeave(self)
    HideEntryHover(self)
    GameTooltip_Hide()
end

-- one entry per spell: the icon left, name and subtext right, lower ranks as small icons under the name
local function GetSpellEntry(self, tab)
    local container = self.container[tab]
    local entry = container.headerFrame[container.HeaderIndex]
    container.HeaderIndex = container.HeaderIndex + 1
    if entry then
        return entry
    end

    entry = CreateFrame("Frame", nil, container, "GwSpellbookActionButtonHeaderTemplate")
    entry:SetHeight(ENTRY_HEIGHT)
    entry:EnableMouse(true)
    entry.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal, "OUTLINE")
    entry.title:ClearAllPoints()
    entry.title:SetPoint("TOPLEFT", RANK_ROW_LEFT, -6)
    entry.title:SetPoint("RIGHT", -4, 0)
    entry.title:SetWordWrap(false)
    entry.subTitle:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small, "OUTLINE")
    entry.subTitle:SetPoint("RIGHT", -4, 0)
    entry.subTitle:SetWordWrap(false)

    entry.hover = entry:CreateTexture(nil, "BACKGROUND")
    entry.hover:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    entry.hover:SetVertexColor(GW.Colors.SkinColors.ListHover:GetRGBA())
    entry.hover:SetAllPoints()
    entry.hover:Hide()

    entry:SetScript("OnEnter", Entry_OnEnter)
    entry:SetScript("OnLeave", Entry_OnLeave)
    tinsert(container.headerFrame, entry)
    return entry
end

-- a flyout is reachable on the bars as a whole, or with every spell of it that is known on its own; mists has no
-- search for flyouts and the one of forever also finds their single spells, so the action slots are looked through
local function IsFlyoutReachable(flyoutID)
    for slot = 1, 180 do
        local actionType, id = GetActionInfo(slot)
        if actionType == "flyout" and id == flyoutID then
            return true
        end
    end
    for slot = 1, select(3, GetFlyoutInfo(flyoutID)) or 0 do
        local spellID, _, isKnown = GetFlyoutSlotInfo(flyoutID, slot)
        if isKnown and not GW.IsSpellOnBars(spellID) then
            return false
        end
    end
    return true
end

-- like blizzard: passives, future and pet spells and auto attacks are never missing; a single spell counts
-- only by itself, also when it belongs to a flyout
local function IsMissingFromBars(button)
    if button.isPassive or button.isFuture or button.isPet then
        return false
    end
    if button.isFlyout then
        return not IsFlyoutReachable(button.spellId)
    end
    if C_Spell.IsAutoAttackSpell(button.spellId) or C_Spell.IsRangedAutoAttackSpell(button.spellId) then
        return false
    end
    return not GW.IsSpellOnBars(button.spellId)
end

-- the rank buttons beside the big icon carry no badges
local function UpdateBadges(button, isRank)
    local unbound = not isRank and GW.settings.windows.spellbook.markUnbound and IsMissingFromBars(button)
    GW.UpdateSpellBadges(button, unbound, not isRank and button.isOffGcd)
end

local function SetMainButton(entry, button)
    entry.mainButton = button
    SetButtonSize(button, ICON_SIZE)
    button:ClearAllPoints()
    button:SetParent(entry)
    button:SetPoint("LEFT", entry, "LEFT", 6, 0)
    -- rank numbers only where the ranks of a spell share an entry
    button.rank:SetShown(#entry.ranks > 0)
    UpdateBadges(button)
end

local function MoreButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(format("%s 1-%d", RANK, self.numHidden), 1, 1, 1)
    GameTooltip:Show()
end

-- the "+N" button and the bar it opens; the ranks are secure buttons, so the bar is toggled by a secure snippet
local function GetMoreButton(entry)
    if entry.moreButton then
        return entry.moreButton
    end
    local flyout = CreateFrame("Frame", nil, entry)
    flyout:SetPoint("TOPLEFT", entry, "TOPLEFT", RANK_ROW_LEFT - 4, -44)
    flyout:SetHeight(RANK_ICON_SIZE + 8)
    flyout:SetFrameLevel(entry:GetFrameLevel() + 20)
    flyout:GwCreateBackdrop(GW.BackdropTemplates.Default)
    flyout:Hide()

    local more = CreateFrame("Button", nil, entry, "SecureHandlerClickTemplate")
    more:SetSize(MORE_WIDTH, RANK_ICON_SIZE)
    more:SetPoint("TOPLEFT", entry, "TOPLEFT", RANK_ROW_LEFT, -22)
    more:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    more.text = more:CreateFontString(nil, "OVERLAY")
    more.text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small, "OUTLINE")
    more.text:SetTextColor(GW.Colors.SkinColors.QuestGold:GetRGB())
    more.text:SetPoint("CENTER")
    more:SetFrameRef("flyout", flyout)
    more:SetAttribute("_onclick", [=[
        local flyout = self:GetFrameRef("flyout")
        if flyout:IsShown() then flyout:Hide() else flyout:Show() end
    ]=])
    more:SetScript("OnEnter", MoreButton_OnEnter)
    more:SetScript("OnLeave", GameTooltip_Hide)
    more.flyout = flyout
    entry.moreButton = more
    return more
end

-- once all ranks of an entry are known: the highest that fit stay in the row, the rest go into the bar
local function LayoutRanks(entry)
    local ranks = entry.ranks
    local more = entry.moreButton
    if #ranks <= MAX_RANKS then
        if more then
            more:Hide()
            more.flyout:Hide()
        end
        return
    end

    more = GetMoreButton(entry)
    local numHidden = #ranks - MAX_RANKS_WITH_MORE
    more.numHidden = numHidden
    more.text:SetText("+" .. numHidden)
    more:Show()
    more.flyout:Hide()
    more.flyout:SetWidth(numHidden * RANK_STEP + 5)

    for index, button in ipairs(ranks) do
        button:ClearAllPoints()
        if index <= numHidden then
            button:SetParent(more.flyout)
            button:SetPoint("TOPLEFT", more.flyout, "TOPLEFT", 4 + (index - 1) * RANK_STEP, -4)
        else
            button:SetPoint("TOPLEFT", entry, "TOPLEFT", RANK_ROW_LEFT + MORE_WIDTH + 4 + (index - numHidden - 1) * RANK_STEP, -22)
        end
    end
end

-- a higher rank takes the big icon, the one before moves into the small row under the name
local function AddRank(entry, button)
    local previous = entry.mainButton
    SetButtonSize(previous, RANK_ICON_SIZE)
    previous:ClearAllPoints()
    previous:SetPoint("TOPLEFT", entry, "TOPLEFT", RANK_ROW_LEFT + #entry.ranks * (RANK_ICON_SIZE + 3), -22)
    tinsert(entry.ranks, previous)
    previous.rank:Show()
    UpdateBadges(previous, true)
    entry.subTitle:SetText("")
    SetMainButton(entry, button)
end

local function GetSpellbookActionButton(tab, container, index)
    local button = tab.buttons[index]

    if button then
        button.isPassive = nil
        button.isFuture = nil
        button.isFlyout = nil
        button.spellbookIndex = nil
        button.isPet = nil
        button.spellId = nil
        button.requiredLevel = nil

        button:SetAttribute("type1", nil)
        button:SetAttribute("type2", nil)
        button:SetAttribute("spell", nil)
        button:SetAttribute("flyout", nil)
        GW.SetSecureAttribute(button, "flyoutDirection", nil)
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

    GW.CreateSpellBadges(button)

    button.modifiedClick = SpellButton_OnModifiedClick
    button:RegisterForClicks("AnyUp")
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", SpellButton_OnDragStart)
    if SpellFlyout and SpellFlyout.AttachToButton then
        button.popupOffset = 0
        button.popupCrossAxisSize = 47
        button.GetPopupDirection = GetPopupDirection
        button.IsPopupOpen = IsPopupOpen
        button.TogglePopup = TogglePopup
        button.ClosePopup = ClosePopup
    end
    button:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    button:RegisterEvent("PET_BAR_UPDATE")
    button:SetScript("OnEnter", function(btn)
        spell_buttonOnEnter(btn)
        local entry = btn:GetParent()
        if entry.hover then entry.hover:Show() end
    end)
    button:SetScript("OnLeave", function(btn)
        GameTooltip_Hide()
        local entry = btn:GetParent()
        if entry.hover then HideEntryHover(entry) end
    end)
    button:Hide()

    tinsert(tab.buttons, button)

    return button
end

local function setButtonStyle(btn, isPassive, spellID, slotType, icon, spellbookIndex, isPet, name, requiredLevel, isOffSpec)
    local _, autostate = Book.GetAutoCast(spellbookIndex, isPet)
    btn.isPassive = isPassive
    btn.isFuture = (slotType == "FUTURESPELL")
    btn.isFlyout = (slotType == "FLYOUT")
    btn.spellbookIndex = spellbookIndex
    btn.isPet = isPet
    btn:EnableMouse(true)
    btn.spellId = spellID
    btn.icon:SetTexture(icon)
    btn.isOffGcd = not btn.isFlyout and GW.IsOffGcdSpell(spellID, isPassive)
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
        GW.SetSecureAttribute(btn, "flyoutDirection", "RIGHT")
        btn:SetAttribute("shift-type1", "modifiedClick")
        btn:SetAttribute("shift-type2", "modifiedClick")
    elseif not btn.isFuture and isPet then
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
    btn:SetAttribute("useOnKeyDown", false)

    if slotType ~= "FUTURESPELL" then
        if slotType == "SPELL" and isOffSpec then
			local level = C_Spell.GetSpellLevelLearned(spellID)
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

local function getNumPages(container)
    local count = 0
    while container["container" .. (count + 1)] do
        count = count + 1
    end
    return count
end

local function UpdatePageText(page)
    local container = page:GetParent()
    container.pages:SetText((container.tabs or 1) > 1 and (page:GetID() .. " / " .. container.tabs) or "")
end

local function SetUpPage(container, page)
    page:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 40)
    page:HookScript("OnShow", UpdatePageText)
end

-- the xml brings the first page, further pages come as the spells need them
local function getPagingContainer(container, pagingID)
    local page = container["container" .. pagingID]
    if not page then
        page = CreateFrame("Frame", "$parentcontainer" .. pagingID, container, "GwSpellbookPageTemplate", pagingID)
        SetUpPage(container, page)
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
    self.attrDummy:SetAttribute("_onattributechanged", ([=[
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
    ]=]))
    self.attrDummy:SetAttribute("page", math.max(1, math.min(targetPage or 1, self.tabs or 1)))
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

local function buildSubSpellName(spellIndex, isPet, specName, isPassive, subSpellName)
    if subSpellName ~= "" then
        return subSpellName
    end
    if specName and specName ~= "" then
        return isPassive and (specName .. ", " .. SPELL_PASSIVE_SECOND) or specName
    end
    if Book.IsTalent(spellIndex, isPet) then
        return isPassive and TALENT_PASSIVE or TALENT
    end
    if isPassive then
        return SPELL_PASSIVE
    end
    return ""
end

local function SpellBookTabOnClick(self, spellBook)
    for i = 1, #spellBook.tabs do
        spellBook.tabs[i].background:Hide()
    end
    self.background:Show()
end

-- one tab: its button in the list and its page container
local function CreateTab(spellBook, key)
    local menu = spellBook.menu
    local menuItem = CreateFrame("Button", "GwspellbookTab" .. key, menu, "GwspellbookTab")
    menuItem:SetWidth(MENU_WIDTH - 10)
    menuItem.icon:SetSize(28, 28)
    menuItem.title:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    menuItem.title:SetTextColor(0.7, 0.7, 0.5, 1)
    menuItem.hover:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    menuItem:ClearNormalTexture()
    menuItem:SetText("")
    menuItem:HookScript("OnClick", function(self) SpellBookTabOnClick(self, spellBook) end)
    menuItem:SetFrameRef("GwSpellbookMenu", menu)
    menuItem.buttons = {}

    local container = CreateFrame("Frame", "GwSpellbookContainerTab" .. key, spellBook, "GwSpellbookContainerTab")
    container:ClearAllPoints()
    container:SetPoint("TOPLEFT", spellBook, "TOPLEFT", MENU_WIDTH, -37)
    container:SetPoint("BOTTOMRIGHT", spellBook, "BOTTOMRIGHT", 0, 10)
    container.headerbg:SetPoint("BOTTOMRIGHT", container, "TOPRIGHT")
    -- a little of the details background top left, over the whole page it swallows the window
    local detailBg = GW.CreateDetailsBackgroundTexture(container)
    detailBg:SetPoint("TOPLEFT", container, "TOPLEFT")
    detailBg:SetSize(PAGE_WIDTH * 0.6, PAGE_HEIGHT * 0.4)
    detailBg:SetAlpha(0.6)
    SetUpPage(container, container.container1)
    container.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, "OUTLINE")
    container.title:SetTextColor(0.9, 0.9, 0.7, 1)
    container.pages:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, "OUTLINE", 2)
    container.pages:SetTextColor(0.7, 0.7, 0.5, 1)
    container.headerFrame = {}
    container:Hide()
    menuItem.container = container
    return menuItem
end

-- as many spell tabs as the client has, created when they come (the era client sends its tabs late) and only out of
-- combat, the tabs are secure; the pet book stays last
local function SetUpTabs(self)
    local numSpellTabs = #self.spellTabs
    for i = numSpellTabs + 1, Book.GetNumTabs() do
        tinsert(self.spellTabs, CreateTab(self, i))
    end

    wipe(self.tabs)
    wipe(self.container)
    for _, tab in ipairs(self.spellTabs) do
        tinsert(self.tabs, tab)
    end
    tinsert(self.tabs, self.petTab)
    for i, tab in ipairs(self.tabs) do
        self.container[i] = tab.container
        tab.bg:SetVertexColor(1, 1, 1, i % 2)
        tab:SetAttribute("_onclick", format([=[self:GetFrameRef("GwSpellbookMenu"):SetAttribute("tabopen", %d)]=], i))
        self.menu:SetFrameRef("GwSpellbookContainerTab" .. i, tab.container)
    end
    self.numTabs = #self.tabs
    self.menu:SetAttribute("numTabs", self.numTabs)

    -- new tabs: show the open one again, its index may have moved
    if #self.spellTabs > numSpellTabs and self.menu:GetAttribute("tabopen") then
        self.menu:SetAttribute("tabopen", self.menu:GetAttribute("tabopen"))
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

    SetUpTabs(self)
    local currentPages = {}

    for spellBookTab = 1, self.numTabs do
        currentPages[spellBookTab] = getCurrentPage(self.container[spellBookTab])
    end

    resetSpellbookPages(self)
    -- an older subtext lookup must not write into an entry that shows another spell by now
    self.layoutID = (self.layoutID or 0) + 1
    local layoutID = self.layoutID
    local shownTabs = 0

    for spellBookTab = 1, self.numTabs do
        local isPet = spellBookTab == self.numTabs
        local name, texture, offset, numSpells, isOffSpec = Book.GetTab(spellBookTab)

        local pagingID = 1
        local tab = self.tabs[spellBookTab]
        local container = self.container[spellBookTab]
        local pagingContainer = container["container" .. pagingID]
        container.tabs = 1
        container.HeaderIndex = 1

        if isPet then
            numSpells = C_SpellBook.HasPetSpells() or 0
            offset = 0
            isOffSpec = false
            name = PET
            texture = "Interface/AddOns/GW2_UI/textures/talents/tabicon_pet.png"
        end

        -- the tabs the client has close up, the pet tab shows and hides itself with the pet
        if not isPet then
            tab:SetShown(name ~= nil)
        end
        if name or isPet then
            tab:ClearAllPoints()
            tab:SetPoint("TOPLEFT", tab:GetParent(), "TOPLEFT", 0, -tab:GetHeight() * shownTabs)
            shownTabs = shownTabs + 1
        end

        tab.icon:SetTexture(texture)
        tab.title:SetText(name)
        container.title:SetText(name)
        tab.icon:SetDesaturated(isOffSpec)

        local numEntries = 0
        local buttonIndex = 0
        local entry, lastName

        for i = 1, numSpells or 0 do
            local spellIndex = i + offset
            local slotType, slotID, spellID, nameSpell, icon, isPassive, requiredLevel = Book.GetItem(spellIndex, isPet)

            if nameSpell and Book.ShouldShow(spellIndex, isPet) then
                buttonIndex = buttonIndex + 1
                local button = GetSpellbookActionButton(tab, pagingContainer, buttonIndex)
                setButtonStyle(button, isPassive, spellID or slotID, slotType, icon, spellIndex, isPet, nameSpell, requiredLevel, isOffSpec)
                if not isPassive then GW.RegisterCooldown(button.cooldown) end

                if entry and lastName == nameSpell then
                    AddRank(entry, button)
                else
                    if numEntries >= ENTRIES_PER_PAGE then
                        pagingID = pagingID + 1
                        pagingContainer = getPagingContainer(container, pagingID)
                        container.tabs = pagingID
                        numEntries = 0
                    end
                    entry = GetSpellEntry(self, spellBookTab)
                    entry:SetParent(pagingContainer)
                    entry:ClearAllPoints()
                    entry:SetPoint("TOPLEFT", pagingContainer, "TOPLEFT", (numEntries % NUM_COLUMNS) * COLUMN_WIDTH, -math.floor(numEntries / NUM_COLUMNS) * ENTRY_HEIGHT)
                    entry:SetWidth(COLUMN_WIDTH - 6)
                    entry.title:SetText(nameSpell)
                    entry.subTitle:SetText("")
                    entry.ranks = {}
                    entry.hover:Hide()
                    entry:Show()
                    SetMainButton(entry, button)
                    numEntries = numEntries + 1
                end

                if spellID then
                    local specName = Book.GetSpecNames(spellIndex, isPet)
                    local spell = Spell:CreateFromSpellID(spellID)
                    local spellEntry = entry
                    spell:ContinueOnSpellLoad(function()
                        if self.layoutID ~= layoutID then return end
                        local subSpellName = buildSubSpellName(spellIndex, isPet, specName, isPassive, spell:GetSpellSubtext())
                        local rank = subSpellName:find(RANK, 1, true) and subSpellName:match("%d+")
                        button.rank:SetText(rank or "")
                        if #spellEntry.ranks == 0 then
                            spellEntry.subTitle:SetText(subSpellName)
                        end
                    end)
                end

                lastName = nameSpell
            end
        end

        for index = 1, container.HeaderIndex - 1 do
            LayoutRanks(container.headerFrame[index])
        end

        setUpPaging(container, currentPages[spellBookTab])
        for page = 1, getNumPages(container) do
            if container["container" .. page]:IsShown() then
                UpdatePageText(container["container" .. page])
            end
        end
    end

    self.spellbookDirty = false
    self.updating = false
end

local function QueuedUpdate(self)
    self:SetScript("OnUpdate", nil)
    updateSpellbookTab(self)
end

local function RefreshBadges(self)
    for _, container in ipairs(self.container) do
        for _, entry in ipairs(container.headerFrame) do
            if entry:IsShown() and entry.mainButton then
                UpdateBadges(entry.mainButton)
            end
        end
    end
end

local function OnEvent(self, event)
    if event == "ACTIONBAR_SLOT_CHANGED" then
        RefreshBadges(self)
        return
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent(event)
        C_Timer.After(0.1, function() updateSpellbookTab(self) end)
        return
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        self:SetScript("OnUpdate", QueuedUpdate)
        return
    end

    if not self:IsShown() then
        self.spellbookDirty = true
        return
    end
    self:SetScript("OnUpdate", QueuedUpdate)
end


local function LoadSpellBook(tabContainer)
    local spellBook = CreateFrame("Frame", "GwSpellbook", tabContainer, "GwSpellbook")
    spellbookFrame = spellBook
    local menu = CreateFrame("Frame", "GwSpellbookMenu", spellBook, "GwSpellbookMenu")
    menu:SetWidth(MENU_WIDTH)
    menu:GetRegions():SetWidth(MENU_WIDTH)

    spellBook:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE")
	spellBook:RegisterEvent("PLAYER_GUILD_UPDATE")
	spellBook:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
    spellBook:RegisterEvent("SPELLS_CHANGED")
    spellBook:RegisterEvent("SKILL_LINES_CHANGED")
    spellBook:RegisterEvent("PLAYER_LEVEL_UP")
    spellBook:RegisterEvent("CHARACTER_POINTS_CHANGED")
    spellBook:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    spellBook:SetScript("OnEvent", OnEvent)

    spellBook.menu = menu
    spellBook.tabs = {}
    spellBook.container = {}
    spellBook.spellTabs = {}

    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("TOPLEFT", GwCharacterWindow, "TOPLEFT", 0, 0)
    mask:SetTexture("Interface/AddOns/GW2_UI/textures/character/windowbg-mask.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(853, 853)

    -- the cog holds the options of blizzards spell book where the client has them, and our badge
    local settings = CreateFrame("DropdownButton", nil, spellBook)
    settings:SetSize(24, 24)
    settings:SetPoint("TOPRIGHT", -10, -8)
    settings:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/mainmenumicrobutton-up.png")
    settings:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/mainmenumicrobutton-down.png")
    settings:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/mainmenumicrobutton-down.png")
    settings.menuPoint = "TOPRIGHT"
    settings.menuRelativePoint = "BOTTOMRIGHT"
    local newEntries = GW.CreateMenuNewTracker("spellbook", settings)
    settings:SetupMenu(function(_, rootDescription)
        newEntries:Begin(rootDescription)

        local function AddCheck(label, IsSelected, toggle, key)
            local check = rootDescription:CreateCheckbox(newEntries:Label(label, key), IsSelected, toggle)
            check:AddInitializer(function(button, description, dropdownMenu)
                GW.BlizzardDropdownCheckButtonInitializer(button, description, dropdownMenu, IsSelected)
            end)
        end

        -- the cvars blizzards spell book uses too; on the classic clients the client itself leaves the lower ranks out
        local function AddCVarOption(label, cvar, inverted)
            AddCheck(label, function() return GetCVarBool(cvar) ~= (inverted == true) end, function()
                SetCVar(cvar, not GetCVarBool(cvar))
                updateSpellbookTab(spellBook)
            end, cvar)
        end
        for _, option in ipairs(Book.GetOptions()) do
            AddCVarOption(option.label, option.cvar, option.inverted)
        end
        if Book.HasRanks and GW.myclass ~= "ROGUE" and GW.myclass ~= "WARRIOR" then
            AddCVarOption(SHOW_ALL_SPELL_RANKS, "ShowAllSpellRanks")
        end

        local function AddBadgeOption(label, key)
            AddCheck(label, function() return GW.settings.windows.spellbook[key] end, function()
                GW.settings.windows.spellbook[key] = not GW.settings.windows.spellbook[key]
                RefreshBadges(spellBook)
            end, "windows.spellbook." .. key)
        end
        AddBadgeOption(L["Mark spells not on an action bar"], "markUnbound")
        AddBadgeOption(L["Mark spells off the global cooldown"], "markOffGcd")
        newEntries:Finish()
    end)
    spellBook.buttonSettings = settings


    menu:SetAttribute("_onattributechanged", [=[
        if name ~= "tabopen" then return end
        for i = 1, self:GetAttribute("numTabs") do
            local container = self:GetFrameRef("GwSpellbookContainerTab" .. i)
            if i == value then
                container:Show()
            else
                container:Hide()
            end
        end
    ]=])

    -- the pet book is the last tab, shown only with a pet
    local petTab = CreateTab(spellBook, "Pet")
    petTab:HookScript("OnHide", function() SpellBookTabOnClick(spellBook.tabs[2], spellBook) end)
    petTab:SetAttribute("_onstate-petstate", [=[
        if newstate == "nopet" then
            self:Hide()
            if self:GetFrameRef("GwSpellbookMenu"):GetAttribute("tabopen") then
                self:GetFrameRef("GwSpellbookMenu"):SetAttribute("tabopen", 2)
            end
        elseif newstate == "hasPet" then
            self:Show()
        end
    ]=])
    RegisterStateDriver(petTab, "petstate", "[target=pet,noexists] nopet; [target=pet,help] hasPet;")
    spellBook.petTab = petTab
    SetUpTabs(spellBook)

    menu:SetAttribute("tabopen", 2)
    menu:SetScript("OnShow", function()
        if InCombatLockdown() or spellBook.spellbookDirty == false then return end
        updateSpellbookTab(spellBook)
    end)
    if ToggleSpellBook then
        hooksecurefunc("ToggleSpellBook", function()
            if InCombatLockdown() then return end
            GwCharacterWindow:SetAttribute("windowPanelOpen", "spellbook")
        end)
    end
    if SpellBookFrame then
        SpellBookFrame:UnregisterAllEvents()
    end

    updateSpellbookTab(spellBook)
end
GW.LoadSpellBook = LoadSpellBook
