---@class GW2
local GW = select(2, ...)
local L = GW.L
local EnableTooltip = GW.EnableTooltip
local inv

-- The forever bank is a row of bags: the first bank tab is a fixed container, every further tab is a bag slot
-- that is bought and then holds a bag. Blizzard shows them as one paged grid, we show them like the classic bank.
local BANK_TYPE = Enum.BankType.Character
local FIRST_TAB = Enum.BagIndex.CharacterBankTab_1
local BAG_SLOT_CONTAINER = Enum.BagIndex.Characterbanktab
local EMPTY_BAG_ICON = "Interface/PaperDoll/UI-PaperDoll-Slot-Bag"
-- the bank data only arrives with the bank, so the frame is built for every possible tab
local NUM_TABS = Constants.InventoryConstants.NumCharacterBankSlots

local function TabBagID(tabIndex)
    return FIRST_TAB + tabIndex - 1
end

local function TabInventorySlot(tabIndex)
    return C_Bank.BankBagTypeAndIDToInvSlot(BANK_TYPE, tabIndex) + 1
end

local function IsTabPurchased(tabIndex)
    return tabIndex <= C_Bank.FetchNumPurchasedBankTabs(BANK_TYPE)
end

local function IsBankBag(bagID)
    return bagID and bagID >= FIRST_TAB and bagID < FIRST_TAB + NUM_TABS
end

local function GetTabBagName(tabIndex)
    local itemID = tabIndex > 1 and GetInventoryItemID("player", TabInventorySlot(tabIndex))
    if not itemID then return end
    local itemName, _, itemRarity = C_Item.GetItemInfo(itemID)
    return itemName or UNKNOWN, itemRarity
end

-- custom name, bag item name or the bank default
local function SetBankHeaders(frame)
    for tabIndex = 1, NUM_TABS do
        local headerIndex = tabIndex - 1
        local header = frame["bagHeader" .. headerIndex]
        local customName = GW.settings.bags.bank.headerNames[headerIndex]
        if tabIndex == 1 then
            header.nameString:SetText(strlen(customName) > 0 and customName or BANK)
            header.nameString:SetTextColor(1, 1, 1, 1)
        else
            local itemName, itemRarity = GetTabBagName(tabIndex)
            if itemName then
                local color = itemRarity and GW.GetQualityColor(itemRarity) or {r = 1, g = 1, b = 1}
                header.nameString:SetText(strlen(customName) > 0 and customName or itemName)
                header.nameString:SetTextColor(color.r, color.g, color.b, 1)
            else
                header:Hide()
            end
        end
    end
end

local function LayoutItems(f)
    local itemFrame = f.ItemFrame
    local settings = GW.settings.bags.bank
    if not settings.itemSize or not settings.itemSpacingX or not settings.itemSpacingY then
        -- acedb can have the profile defaults detached (logout, profile operations)
        return
    end

    local sep = settings.separateBags
    local itemOffX = settings.itemSize + settings.itemSpacingX
    local itemOffY = settings.itemSize + settings.itemSpacingY
    local col, row = 0, sep and 1 or 0
    local first, last, step = 1, NUM_TABS, 1
    if settings.reverseSort then
        first, last, step = last, first, -1
    end
    f.unfinishedRow = 0
    f.finishedRow = 0
    f.gw_bank_headers = 0

    for tabIndex = first, last, step do
        local cf = itemFrame.Containers[TabBagID(tabIndex)]
        local header = f["bagHeader" .. (tabIndex - 1)]
        local hasContent = tabIndex == 1 or GetTabBagName(tabIndex)

        if sep then
            header:Show()
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", itemFrame, "TOPLEFT", 0, (-row + 1) * itemOffY)
            header:SetPoint("TOPRIGHT", itemFrame, "TOPRIGHT", 0, (-row + 1) * itemOffY)
        else
            header:Hide()
        end

        if not sep or cf.shouldShow then
            local unfinishedRow, finishedRows
            col, row, unfinishedRow, finishedRows = inv.layoutContainerFrame(cf, f.gw_bank_cols, row, col, tabIndex == 1, itemOffX, itemOffY)
            cf:Show()
            if unfinishedRow then f.unfinishedRow = f.unfinishedRow + 1 end
            f.finishedRow = f.finishedRow + finishedRows
        else
            cf:Hide()
        end

        -- close the section under its header: the next header starts on a fresh row
        if sep and hasContent then
            f.gw_bank_headers = f.gw_bank_headers + 1
            if col ~= 0 then
                row = row + 2
                col = 0
            else
                row = row + 1
            end
        end
    end

    if sep then
        SetBankHeaders(f)
    end
end

local function SnapFrameSize(f)
    local settings = GW.settings.bags.bank
    inv.snapFrameSize(f, f.ItemFrame.Containers, settings.itemSize, settings.itemSpacingX, settings.itemSpacingY, 370)
end

local function UpdateFreeBankSlots(f)
    local free = inv.updateFreeSlots(f.spaceString, FIRST_TAB, TabBagID(NUM_TABS))
    local baseBag = f.ItemFrame.bags[1]
    SetItemButtonCount(baseBag, free)
    baseBag.tooltipAddLine = string.format(NUM_FREE_SLOTS, free)
end

local function RescanBankContainers(f)
    local size = GW.settings.bags.bank.itemSize
    for tabIndex = 1, NUM_TABS do
        GW.SetupOwnContainerItemButtons(f.ItemFrame.Containers[TabBagID(tabIndex)], TabBagID(tabIndex), size, tabIndex == 1)
    end
    if f:IsShown() then
        UpdateFreeBankSlots(f)
        LayoutItems(f)
        SnapFrameSize(f)
    end
end

local function SetBagBarOrder(itemFrame)
    local bagSize, bagPadding = 28, 4
    local y = 5
    local step = -(bagSize + bagPadding)
    if GW.settings.bags.bank.reverseSort then
        y = 5 + step * (NUM_TABS - 1)
        step = -step
    end

    for tabIndex = 1, NUM_TABS do
        local b = itemFrame.bags[tabIndex]
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", itemFrame, "TOPLEFT", -40, y)
        y = y + step
    end
end

local function IsNextPurchasableTab(tabIndex)
    return tabIndex == C_Bank.FetchNumPurchasedBankTabs(BANK_TYPE) + 1 and C_Bank.CanPurchaseBankTab(BANK_TYPE)
end

local function BagSlot_Pickup(self)
    if IsTabPurchased(self.tabIndex) then
        C_Container.PickupContainerItem(BAG_SLOT_CONTAINER, self.tabIndex)
    end
end

local function BagSlot_OnClick(self, button)
    if button ~= "LeftButton" then return end
    if IsTabPurchased(self.tabIndex) then
        BagSlot_Pickup(self)
    elseif IsNextPurchasableTab(self.tabIndex) then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        StaticPopup_Show("CONFIRM_BUY_BANK_TAB", nil, nil, {bankType = BANK_TYPE})
    end
end

local function BagSlot_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if not (self.gwHasBag and GameTooltip:SetBagItem(BAG_SLOT_CONTAINER, self.tabIndex)) then
        GameTooltip:SetText(self.tooltipText)
        if IsNextPurchasableTab(self.tabIndex) then
            local tabData = C_Bank.FetchNextPurchasableBankTabData(BANK_TYPE)
            if tabData then
                GameTooltip:AddLine(GetMoneyString(tabData.tabCost), 1, 1, 1)
            end
        end
    end
    GameTooltip:Show()
    CursorUpdate(self)
end

local function CreateBagBar(itemFrame)
    itemFrame.bags = {}

    -- the fixed first tab, it holds no bag
    local base = CreateFrame("Button", nil, itemFrame, "GwBankBaseBagTemplate")
    inv.reskinBagBar(base)
    base:GetNormalTexture():SetVertexColor(1, 1, 1, 0.75)
    GW.SetItemButtonQualityForBags(base, 1)
    EnableTooltip(base, BANK, "ANCHOR_RIGHT", 0)
    base.icon:SetTexture(133633)
    base.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    itemFrame.bags[1] = base

    for tabIndex = 2, NUM_TABS do
        local b = CreateFrame("Button", nil, itemFrame, "GwBankBaseBagTemplate")
        b.tabIndex = tabIndex
        b:RegisterForClicks("LeftButtonUp")
        b:RegisterForDrag("LeftButton")
        b:SetScript("OnClick", BagSlot_OnClick)
        b:SetScript("OnDragStart", BagSlot_Pickup)
        b:SetScript("OnReceiveDrag", BagSlot_Pickup)
        b:SetScript("OnEnter", BagSlot_OnEnter)
        b:SetScript("OnLeave", GameTooltip_Hide)
        inv.reskinBagBar(b)
        itemFrame.bags[tabIndex] = b
    end

    SetBagBarOrder(itemFrame)
end

local function UpdateBagBar(itemFrame)
    local maxTabs = C_Bank.FetchMaxNumBankTabs(BANK_TYPE)
    for tabIndex = 2, NUM_TABS do
        local b = itemFrame.bags[tabIndex]
        b:SetShown(tabIndex <= maxTabs)
        local invSlot = TabInventorySlot(tabIndex)
        local bagTexture = GetInventoryItemTexture("player", invSlot)
        local bagLink = GetInventoryItemLink("player", invSlot)

        GW.SetItemButtonQualityForBags(b, bagLink and select(3, C_Item.GetItemInfo(bagLink)) or 1)
        b:GetNormalTexture():SetVertexColor(1, 1, 1, 0.75)
        b.icon:SetDesaturated(false)
        b.gwHasBag = bagTexture ~= nil

        if bagTexture then
            b.icon:SetTexture(bagTexture)
            b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            b.icon:SetDesaturated(IsInventoryItemLocked(invSlot))
            b.tooltipText = BANK_BAG
        elseif IsTabPurchased(tabIndex) then
            b.icon:SetTexture(EMPTY_BAG_ICON)
            b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            b.tooltipText = BANK_BAG
        elseif IsNextPurchasableTab(tabIndex) then
            b.icon:SetTexture("Interface/AddOns/GW2_UI/textures/talents/pvp_empty_icon.png")
            b.icon:SetTexCoord(0.2, 0.8, 0.2, 0.8)
            b.tooltipText = BANK_BAG_PURCHASE
        else
            b.icon:SetTexture("Interface/AddOns/GW2_UI/textures/talents/lock.png")
            b.icon:SetTexCoord(0.15, 0.85, 0.07, 0.85)
            b.tooltipText = GUILDBANK_TAB_LOCKED
        end
    end
end

local function OnBankResizeStop(self)
    GW.settings.bags.bank.width = self:GetWidth()
    inv.onMoved(self, "bank", SnapFrameSize)
end

local function OnBankFrameChangeSize(self, _, _, skip)
    local size = GW.settings.bags.bank.itemSize
    local spacing = GW.settings.bags.bank.itemSpacingX
    if not size or not spacing then
        -- OnSizeChanged can fire while acedb has the profile defaults detached
        return
    end
    local cols = inv.colCount(size, spacing, self:GetWidth())
    if self.gw_bank_cols ~= cols then
        self.gw_bank_cols = cols
        if not skip then
            LayoutItems(self)
        end
    end
end

-- blizzards bank frame stays open off screen: bag items only deposit into the bank while it is shown
local function HideBlizzardBankFrame()
    BankFrame:ClearAllPoints()
    BankFrame:SetClampedToScreen(false)
    BankFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -2000, 2000)
end

local BANK_EVENTS = {
    "BAG_UPDATE", "BAG_UPDATE_DELAYED", "BAG_UPDATE_COOLDOWN", "BAG_CONTAINER_UPDATE", "BANK_TABS_CHANGED",
    "PLAYERBANKSLOTS_CHANGED", "ITEM_LOCKED", "ITEM_UNLOCKED", "INVENTORY_SEARCH_UPDATE",
}

local function Bank_OnShow(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    FrameUtil.RegisterFrameForEvents(self, BANK_EVENTS)
    HideBlizzardBankFrame()
    OpenAllBags(self)
    UpdateBagBar(self.ItemFrame)
    RescanBankContainers(self)
end

local function Bank_OnHide(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    FrameUtil.UnregisterFrameForEvents(self, BANK_EVENTS)
    CloseAllBags(self)
    C_Bank.CloseBankFrame()
end

local function Bank_OnEvent(self, event, ...)
    if event == "BANKFRAME_OPENED" then
        self:Show()
    elseif event == "BANKFRAME_CLOSED" then
        self:Hide()
    elseif event == "BAG_UPDATE" then
        if IsBankBag(...) then
            self.gw_need_bank_update = true
        end
    elseif event == "BAG_UPDATE_DELAYED" then
        if self.gw_need_bank_update then
            self.gw_need_bank_update = false
            RescanBankContainers(self)
        end
    elseif event == "BAG_CONTAINER_UPDATE" or event == "BANK_TABS_CHANGED" or event == "PLAYERBANKSLOTS_CHANGED" then
        UpdateBagBar(self.ItemFrame)
        RescanBankContainers(self)
    elseif event == "ITEM_LOCKED" or event == "ITEM_UNLOCKED" then
        local bag, slot = ...
        if bag == BAG_SLOT_CONTAINER then
            local b = self.ItemFrame.bags[slot]
            if b then
                b.icon:SetDesaturated(event == "ITEM_LOCKED")
            end
        elseif IsBankBag(bag) and slot then
            GW.UpdateOwnContainerLockedState(self.ItemFrame.Containers[bag], slot)
        end
    elseif event == "BAG_UPDATE_COOLDOWN" then
        for _, cf in pairs(self.ItemFrame.Containers) do
            GW.UpdateOwnContainerCooldowns(cf)
        end
    elseif event == "INVENTORY_SEARCH_UPDATE" then
        for _, cf in pairs(self.ItemFrame.Containers) do
            GW.UpdateOwnContainerSearchResults(cf)
        end
    end
end

local function BankHeader_OnClick(self, button)
    local headerIndex = self:GetID()
    local f = self:GetParent()
    if button == "LeftButton" then
        f.ItemFrame.Containers[TabBagID(headerIndex + 1)].shouldShow = not self.icon:IsShown()
        self.icon:SetShown(not self.icon:IsShown())
        self.icon2:SetShown(not self.icon:IsShown())
        LayoutItems(f)
        SnapFrameSize(f)
    elseif button == "RightButton" then
        local function DefaultName()
            return headerIndex == 0 and BANK or GetTabBagName(headerIndex + 1) or UNKNOWN
        end
        GW.ShowPopup({
            text = L["New Bag Name"],
            hasEditBox = true,
            button1 = SAVE,
            button2 = RESET,
            inputText = strlen(GW.settings.bags.bank.headerNames[headerIndex]) > 0 and GW.settings.bags.bank.headerNames[headerIndex] or DefaultName(),
            OnAccept = function(popup)
                GW.settings.bags.bank.headerNames[headerIndex] = popup.input:GetText()
                SetBankHeaders(f)
            end,
            OnCancel = function()
                GW.settings.bags.bank.headerNames[headerIndex] = ""
                SetBankHeaders(f)
            end,
            EditBoxOnEscapePressed = function(popup) popup:Hide() end,
        })
    end
end

local function BankHeader_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, -45)
    GameTooltip:ClearLines()
    GameTooltip_SetTitle(GameTooltip, L["Right click to customize the bag title."])
    GameTooltip:Show()
end

local function LoadBank(helpers)
    inv = helpers

    local f = CreateFrame("Frame", "GwBankFrame", UIParent, "GwBankFrameTemplate")
    tinsert(UISpecialFrames, "GwBankFrame")
    f:ClearAllPoints()
    f:SetWidth(GW.settings.bags.bank.width)
    OnBankFrameChangeSize(f, nil, nil, true)
    f:SetClampedToScreen(true)
    f:SetClampRectInsets(-f.Left:GetWidth(), 0, f.Header:GetHeight() - 10, -35)

    f:SetScript("OnShow", Bank_OnShow)
    f:SetScript("OnHide", Bank_OnHide)
    f.buttonClose:SetScript("OnClick", GW.Parent_Hide)
    hooksecurefunc(BankFrame, "Raise", HideBlizzardBankFrame)

    local pos = GW.settings.bags.bank.pos
    f:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    f.mover:RegisterForDrag("LeftButton")
    f.mover.onMoveSetting = "bank"
    f.mover:SetScript("OnDragStart", inv.onMoverDragStart)
    f.mover:SetScript("OnDragStop", inv.onMoverDragStop)

    f:SetResizeBounds(508, 340)
    f:SetScript("OnSizeChanged", OnBankFrameChangeSize)
    f.sizer.onResizeStop = OnBankResizeStop
    f.sizer:SetScript("OnMouseDown", inv.onSizerMouseDown)
    f.sizer:SetScript("OnMouseUp", inv.onSizerMouseUp)

    local headerIndex = 0
    while f["bagHeader" .. headerIndex] do
        local header = f["bagHeader" .. headerIndex]
        header.nameString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        header.nameString:SetTextColor(1, 1, 1)
        header.nameString:SetShadowColor(0, 0, 0, 0)
        header.icon2:Hide()
        header:Hide()
        header:SetScript("OnClick", BankHeader_OnClick)
        header:SetScript("OnEnter", BankHeader_OnEnter)
        header:SetScript("OnLeave", GameTooltip_Hide)
        headerIndex = headerIndex + 1
    end

    inv.reskinSearchBox(BankItemSearchBox)
    inv.relocateSearchBox(BankItemSearchBox, f)
    -- blizzards sort button hangs off the search box and would follow it into our frame
    BankFrame.BankPanel.AutoSortButton:Hide()

    -- our item buttons need parent containers with the bag id set for the inherited ItemButton behaviour
    f.ItemFrame.Containers = {}
    for tabIndex = 1, NUM_TABS do
        local cf = CreateFrame("Frame", nil, f.ItemFrame)
        cf.gw_items = {}
        cf.gw_num_slots = 0
        cf:SetAllPoints(f.ItemFrame)
        cf:SetID(TabBagID(tabIndex))
        cf.shouldShow = true
        f.ItemFrame.Containers[TabBagID(tabIndex)] = cf
    end

    CreateBagBar(f.ItemFrame)

    f.headerString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
    f.headerString:SetText(BANK)
    f.spaceString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    f.spaceString:SetTextColor(1, 1, 1)
    f.spaceString:SetShadowColor(0, 0, 0, 0)

    f:SetScript("OnEvent", Bank_OnEvent)
    f:RegisterEvent("BANKFRAME_OPENED")
    f:RegisterEvent("BANKFRAME_CLOSED")

    f.buttonSort:HookScript("OnClick", function()
        PlaySound(SOUNDKIT.UI_BAG_SORTING_01)
        C_Container.SortBank(BANK_TYPE)
    end)
    EnableTooltip(f.buttonSort, BAG_CLEANUP_BANK)
    EnableTooltip(f.buttonSettings, BAG_SETTINGS_TOOLTIP)
    f.buttonSettings:SetScript("OnClick", function(self)
        MenuUtil.CreateContextMenu(self, function(_, rootDescription)
            local function AddCheck(label, getter, setter)
                local check = rootDescription:CreateCheckbox(label, getter, setter)
                check:AddInitializer(function(button, description, menu)
                    GW.BlizzardDropdownCheckButtonInitializer(button, description, menu, getter)
                end)
            end

            inv.addItemSizeMenuEntries(rootDescription, "BANK")
            AddCheck(L["Reverse Bag Order"], function() return GW.settings.bags.bank.reverseSort end, function()
                GW.settings.bags.bank.reverseSort = not GW.settings.bags.bank.reverseSort
                SetBagBarOrder(f.ItemFrame)
                LayoutItems(f)
                SnapFrameSize(f)
            end)
            AddCheck(L["Show Quality Color"], function() return GW.settings.bags.items.qualityBorder end, function()
                GW.settings.bags.items.qualityBorder = not GW.settings.bags.items.qualityBorder
                GW.UpdateAllOwnBagItemButtons()
            end)
            AddCheck(L["Separate bags"], function() return GW.settings.bags.bank.separateBags end, function()
                GW.settings.bags.bank.separateBags = not GW.settings.bags.bank.separateBags
                LayoutItems(f)
                SnapFrameSize(f)
            end)
        end)
    end)

    return function()
        OnBankFrameChangeSize(f, nil, nil, true)
        LayoutItems(f)
        SnapFrameSize(f)
    end
end
GW.LoadBank = LoadBank
