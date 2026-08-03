---@class GW2
local GW = select(2, ...)
local L = GW.L
local EnableTooltip = GW.EnableTooltip
local inv

local GetInventorySlotInfo = C_PaperDollInfo and C_PaperDollInfo.GetInventorySlotInfo or GetInventorySlotInfo

local function openAllBankBags()
    for i = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
        if not IsBagOpen(i) then
            OpenBag(i)
        end
    end
end

-- sets the bank header names in separate bags mode: custom name, bag item name or the bank default
local function setBankHeaders(frame)
    for i = 1, NUM_BANKBAGSLOTS do
        local customBagHeaderName = GW.settings["BANK_HEADER_NAME" .. i]
        local header = frame["bagHeader" .. i]
        local itemID = GetInventoryItemID("player", C_Container.ContainerIDToInventoryID(NUM_BAG_SLOTS + i))

        if itemID then
            local r, g, b = 1, 1, 1
            local itemName, _, itemRarity = C_Item.GetItemInfo(itemID)
            if itemRarity then r, g, b = C_Item.GetItemQualityColor(itemRarity) end

            header.nameString:SetText(strlen(customBagHeaderName) > 0 and customBagHeaderName or itemName or UNKNOWN)
            header.nameString:SetTextColor(r, g, b, 1)
        else
            header:Hide()
        end
    end
    local customBagHeaderName = GW.settings.BANK_HEADER_NAME0
    frame.bagHeader0.nameString:SetText(strlen(customBagHeaderName) > 0 and customBagHeaderName or BANK)
    frame.bagHeader0.nameString:SetTextColor(1, 1, 1, 1)
end

-- adjusts the ItemButton layout flow when the bank window size changes (or on open)
local function layoutBankItems(f)
    local parent = f:GetParent()
    local max_col = parent.gw_bank_cols
    local col = 0
    local rev = GW.settings.BANK_REVERSE_SORT
    local sep = GW.settings.BANK_SEPARATE_BAGS
    local row = sep and 1 or 0

    if not GW.settings.BANK_ITEM_SIZE or not GW.settings.BANK_ITEM_SPACING_X or not GW.settings.BANK_ITEM_SPACING_Y then
        -- acedb can have the profile defaults detached (logout, profile operations)
        return
    end
    local item_off_x = GW.settings.BANK_ITEM_SIZE + GW.settings.BANK_ITEM_SPACING_X
    local item_off_y = GW.settings.BANK_ITEM_SIZE + GW.settings.BANK_ITEM_SPACING_Y

    local iS = NUM_BAG_SLOTS
    local iE = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
    local iD = 1
    if rev then
        iS = iE
        iE = NUM_BAG_SLOTS
        iD = -1
    end
    parent.unfinishedRow = 0
    parent.finishedRow = 0

    local lcf = inv.layoutContainerFrame
    for i = iS, iE, iD do
        local bag_id = i
        if bag_id == NUM_BAG_SLOTS then
            bag_id = BANK_CONTAINER
        end
        local cf = f.Containers[bag_id]
        local header = parent["bagHeader" .. (i - NUM_BAG_SLOTS)]
        local itemID
        if bag_id ~= BANK_CONTAINER then
            itemID = GetInventoryItemID("player", C_Container.ContainerIDToInventoryID(bag_id))
        end

        if sep then
            header:Show()
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", f, "TOPLEFT", 0, (-row + 1) * item_off_y)
            header:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, (-row + 1) * item_off_y)
        else
            header:Hide()
        end

        if cf then
            if not sep or cf.shouldShow then
                local unfinishedRow, finishedRows
                col, row, unfinishedRow, finishedRows = lcf(cf, max_col, row, col, (bag_id == BANK_CONTAINER), item_off_x, item_off_y)
                cf:Show()
                if unfinishedRow then parent.unfinishedRow = parent.unfinishedRow + 1 end
                parent.finishedRow = parent.finishedRow + finishedRows
            else
                cf:Hide()
            end

            -- close the section under its header: the next header starts on a fresh row
            if sep and (bag_id == BANK_CONTAINER or itemID) then
                if col ~= 0 then
                    row = row + 2
                    col = 0
                else
                    row = row + 1
                end
            end
        end
    end

    if sep then
        setBankHeaders(parent)
    end
end


-- adjusts the ItemButton layout flow when the bank window size changes (or on open)
local function layoutItems(f)
    if f.ItemFrame:IsShown() then
        layoutBankItems(f.ItemFrame)
    end
end


-- adjusts the bank frame size to snap to the exact row/col sizing of contents
local function snapFrameSize(f)
    local cfs
    if f.ItemFrame:IsShown() then
        cfs = f.ItemFrame.Containers
    end
    inv.snapFrameSize(f, cfs, GW.settings.BANK_ITEM_SIZE, GW.settings.BANK_ITEM_SPACING_X, GW.settings.BANK_ITEM_SPACING_Y, 370)
end


-- update the number of free bank slots available and set the display for it
local function updateFreeBankSlots(self)
    local free, _ = inv.updateFreeSlots(GwBankFrame.spaceString, NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS, BANK_CONTAINER)
    local b = self.bags[0]
    if b then
        SetItemButtonCount(b, free)
        b.tooltipAddLine = string.format(NUM_FREE_SLOTS, free)
    end
end


-- The inherited container tooltip (SetBagItem) returns nothing for the main bank
-- container on classic — its slots are INVENTORY slots there. Mirror blizzards
-- BankFrameItemButton_OnEnter: resolve the inventory slot id and use SetInventoryItem
local function bankSlot_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local hasItem = GameTooltip:SetInventoryItem("player", BankButtonIDToInvSlotID(self:GetID()))
    if not hasItem then
        GameTooltip:Hide()
    else
        GameTooltip:Show()
    end
    CursorUpdate(self)
end

local bankSlotButtonOpts = {
    initButton = function(button)
        if not button.gwBankTooltipFixed then
            button.gwBankTooltipFixed = true
            button:SetScript("OnEnter", bankSlot_OnEnter)
            button.UpdateTooltip = bankSlot_OnEnter
        end
    end,
}

-- update all bank items and bank bags
local function updateBankContainers(f)
    GW.SetupOwnContainerItemButtons(f.ItemFrame.Containers[BANK_CONTAINER], BANK_CONTAINER, GW.settings.BANK_ITEM_SIZE, true, bankSlotButtonOpts)
    if f:IsShown() then
        if f.ItemFrame:IsShown() then
            updateFreeBankSlots(f.ItemFrame)
        end
        layoutItems(f)
        snapFrameSize(f)
    end
end


-- rescan ALL bank ItemButtons
local function rescanBankContainers(f)
    for bag_id = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
        GW.SetupOwnContainerItemButtons(f.ItemFrame.Containers[bag_id], bag_id, GW.settings.BANK_ITEM_SIZE)
    end
    updateBankContainers(f)
end


-- draws the bank bag slots in the correct order
local function setBagBarOrder(f)
    local x = -40
    local y = 5
    local bag_size = 28
    local bag_padding = 4
    local rev = GW.settings.BANK_REVERSE_SORT
    if rev then
        y = 5 - ((bag_size + bag_padding) * NUM_BANKBAGSLOTS)
    end

    for bag_idx = 0, NUM_BANKBAGSLOTS do
        local b = f.bags[bag_idx]
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", f, "TOPLEFT", x, y)
        if rev then
            y = y + bag_size + bag_padding
        else
            y = y - bag_size - bag_padding
        end
    end
end


local function bag_OnClick(self, button)
    -- on left click, test if this is a purchase slot and do purchase confirm,
    -- otherwise ensure that the bag stays open despite default toggle behavior
    if button == "LeftButton" then
        if self.gwHasBag then
            if not IsBagOpen(self:GetBagID()) then
                OpenBag(self:GetBagID())
            end
        elseif self.tooltipText == BANK_BAG_PURCHASE then
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
            -- the confirm dialogs money frame reads BankFrame.nextSlotCost, which
            -- Blizzards (now inert) bank frame no longer maintains — set it here
            -- like Blizzards UpdateBagSlotStatus would
            if BankFrame and GetBankSlotCost then
                BankFrame.nextSlotCost = GetBankSlotCost(GetNumBankSlots())
            end
            StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
        end
    end
end


-- creates the bank bag slot icons for the ItemFrame
local function createBagBar(f)
    f.bags = {}

    local getBagId = function(self)
        return self:GetID() + NUM_BAG_SLOTS
    end

    for bag_idx = 1, NUM_BANKBAGSLOTS do
        local b = CreateFrame("Button", nil, f, "GwBankBagTemplate")

        -- We depend on a number of behaviors from the default BankItemButtonBagTemplate.
        -- The ID set here is NOT the usual bag_id; rather it is a 1-based index of bank
        -- bags used by helper methods provided by BankItemButtonBagTemplate.
        b:SetID(bag_idx)
        -- unlike BagSlotButtonTemplate, we must provide the GetBagID method ourself
        b.GetBagID = getBagId

        -- remove default of capturing right-click also (we handle right-click separately)
        b:RegisterForClicks("LeftButtonUp")
        b:HookScript("OnClick", bag_OnClick)
        b:HookScript("OnMouseDown", inv.bag_OnMouseDown)

        inv.reskinBagBar(b)

        f.bags[bag_idx] = b
    end

    -- create a fake bag frame for the base bank slots
    local b = CreateFrame("Button", nil, f, "GwBankBaseBagTemplate")
    b:SetID(0)
    b.GetBagID = function()
        return BANK_CONTAINER
    end
    inv.reskinBagBar(b)
    local norm = b:GetNormalTexture()
    norm:SetVertexColor(1, 1, 1, 0.75)
    GW.SetItemButtonQualityForBags(b, 1, nil)
    EnableTooltip(b, BANK, "ANCHOR_RIGHT", 0)
    b.icon:SetTexture(133633)
    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b:RegisterForClicks("LeftButtonUp")
    b:SetScript("OnClick", CloseBankFrame)
    f.bags[0] = b

    setBagBarOrder(f)
end


-- updates the contents of the bank bag slots
local function updateBagBar(f)
    local bank_slots, full = GetNumBankSlots()
    for bag_idx = 1, NUM_BANKBAGSLOTS do
        local b = f.bags[bag_idx]
        local bag_id = b:GetBagID()
        local inv_id = b:GetInventorySlot()
        local bag_tex = GetInventoryItemTexture("player", inv_id)
        local _, slot_tex = GetInventorySlotInfo("Bag" .. bag_idx)
        local bagLink = GetInventoryItemLink("player", inv_id)

        if bagLink then
            GW.SetItemButtonQualityForBags(b, select(3, C_Item.GetItemInfo(bagLink)))
        else
            GW.SetItemButtonQualityForBags(b, 1)
        end

        b.icon:Show()
        b.gwHasBag = false -- flag used by OnClick hook to pop up context menu when valid
        b.tooltipText = nil
        local norm = b:GetNormalTexture()
        norm:SetVertexColor(1, 1, 1, 0.75)
        b.icon:SetDesaturated(false)
        if bag_tex ~= nil then
            b.gwHasBag = true
            if not IsBagOpen(bag_id) then
                OpenBag(bag_id) -- default open valid bank bags immediately
            end
            b.icon:SetTexture(bag_tex)
            if IsInventoryItemLocked(inv_id) then
                b.icon:SetDesaturated(true)
            else
                b.icon:SetDesaturated(false)
            end
        elseif bag_idx > bank_slots then
            if not full and bag_idx == bank_slots + 1 then
                b.tooltipText = BANK_BAG_PURCHASE
                b.icon:SetTexture("Interface/AddOns/GW2_UI/textures/talents/pvp_empty_icon.png")
                b.icon:SetTexCoord(0.2, 0.8, 0.2, 0.8)
            else
                b.tooltipText = GUILDBANK_TAB_LOCKED
                b.icon:SetTexture("Interface/AddOns/GW2_UI/textures/talents/lock.png")
                b.icon:SetTexCoord(0.15, 0.85, 0.07, 0.85)
            end
        elseif slot_tex ~= nil then
            b.tooltipText = BANK_BAG
            b.icon:SetTexture(slot_tex)
            b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        else
            b.icon:Hide()
        end
    end
end


local function onBankResizeStop(self)
    GW.settings.BANK_WIDTH = self:GetWidth()
    inv.onMoved(self, "BANK_POSITION", snapFrameSize)
end


local function onBankFrameChangeSize(self, _, _, skip)
    local size = GW.settings.BANK_ITEM_SIZE
    local spacing = GW.settings.BANK_ITEM_SPACING_X
    if not size or not spacing then
        -- OnSizeChanged can fire while acedb has the profile defaults detached
        -- (logout, profile operations) - values equal to a default read as nil then
        return
    end
    local cols = inv.colCount(size, spacing, self:GetWidth())

    if not self.gw_bank_cols or self.gw_bank_cols ~= cols then
        self.gw_bank_cols = cols
        if not skip then
            layoutItems(self)
        end
    end
end


local function bank_OnShow(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
    self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
    self:RegisterEvent("ITEM_LOCKED")
    self:RegisterEvent("ITEM_UNLOCKED")
    self:RegisterEvent("BAG_UPDATE")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:RegisterEvent("BAG_UPDATE_COOLDOWN")
    self:RegisterEvent("INVENTORY_SEARCH_UPDATE")

    OpenAllBags(self)
    updateBagBar(self.ItemFrame)
    rescanBankContainers(self)
end


local function bank_OnHide(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    self:UnregisterAllEvents()
    self:RegisterEvent("BANKFRAME_OPENED")
    self:RegisterEvent("BANKFRAME_CLOSED")
    CloseBankFrame()
end


local function bank_OnEvent(self, event, ...)
    if event == "BANKFRAME_OPENED" then
        self:Show()
    elseif event == "BANKFRAME_CLOSED" then
        self:Hide()
    elseif event == "PLAYERBANKSLOTS_CHANGED" then
        local slot = select(1, ...)
        if slot > NUM_BANKGENERIC_SLOTS then
            -- a bank bag was un/equipped
            openAllBankBags()
            updateBagBar(self.ItemFrame)
            rescanBankContainers(self)
        else
            -- an item was added to or removed from the base bank
            local cf = self.ItemFrame.Containers[BANK_CONTAINER]
            if cf and cf.gw_items and cf.gw_items[slot] then
                GW.UpdateOwnContainerItemButton(cf.gw_items[slot])
            end
            if self.ItemFrame:IsShown() then
                updateFreeBankSlots(self.ItemFrame)
            end
        end
    elseif event == "PLAYERBANKBAGSLOTS_CHANGED" then
        -- the # of bank bag slots has changed
        updateBagBar(self.ItemFrame)
    elseif event == "ITEM_LOCKED" or event == "ITEM_UNLOCKED" then
        local bag = select(1, ...)
        local slot = select(2, ...)
        if bag == BANK_CONTAINER and slot and slot > NUM_BANKGENERIC_SLOTS then
            -- the item un/locked is a bank bag, gray it out
            local bag_id = slot - NUM_BANKGENERIC_SLOTS
            local b = self.ItemFrame.bags[bag_id]
            if b and b.icon and b.icon.SetDesaturated then
                if event == "ITEM_LOCKED" then
                    b.icon:SetDesaturated(true)
                else
                    b.icon:SetDesaturated(false)
                end
            end
        elseif bag == BANK_CONTAINER and slot then
            GW.UpdateOwnContainerLockedState(self.ItemFrame.Containers[BANK_CONTAINER], slot)
        elseif bag and slot and bag > NUM_BAG_SLOTS and bag <= NUM_BAG_SLOTS + NUM_BANKBAGSLOTS then
            GW.UpdateOwnContainerLockedState(self.ItemFrame.Containers[bag], slot)
        end
    elseif event == "BAG_UPDATE" then
        local bag_id = select(1, ...)
        if bag_id == BANK_CONTAINER or bag_id > NUM_BAG_SLOTS then
            self.gw_need_bank_update = true
        end
    elseif event == "BAG_UPDATE_DELAYED" then
        if self.gw_need_bank_update then
            self.gw_need_bank_update = false
            rescanBankContainers(self)
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


local function bankHeader_OnClick(self, btn)
    local idx = self:GetID()
    local parent = self:GetParent()
    if btn == "LeftButton" then
        local bag_id = idx == 0 and BANK_CONTAINER or (NUM_BAG_SLOTS + idx)
        parent.ItemFrame.Containers[bag_id].shouldShow = not self.icon:IsShown()
        self.icon:SetShown(not self.icon:IsShown())
        self.icon2:SetShown(not self.icon:IsShown())

        layoutItems(parent)
        snapFrameSize(parent)
    elseif btn == "RightButton" then
        GW.ShowPopup({text = L["New Bag Name"],
            OnAccept = function(promptFrame)
                GW.settings["BANK_HEADER_NAME" .. idx] = promptFrame.input:GetText()
                self.nameString:SetText(GW.settings["BANK_HEADER_NAME" .. idx])
            end,
            hasEditBox = true,
            button1 = SAVE,
            button2 = RESET,
            EditBoxOnEscapePressed = function(popup) popup:Hide() end,
            OnCancel = function()
                GW.settings["BANK_HEADER_NAME" .. idx] = ""
                if idx > 0 then
                    local itemID = GetInventoryItemID("player", C_Container.ContainerIDToInventoryID(NUM_BAG_SLOTS + idx))

                    if itemID then
                        local color = {r = 1, g = 1, b = 1}
                        local itemName, _, itemRarity = C_Item.GetItemInfo(itemID)
                        if itemRarity then
                            color = GW.GetQualityColor(itemRarity)
                        end

                        self.nameString:SetText(itemName or UNKNOWN)
                        self.nameString:SetTextColor(color.r, color.g, color.b, 1)
                    end
                else
                    self.nameString:SetText(BANK)
                end
            end,
        inputText = (function()
            local customName = GW.settings["BANK_HEADER_NAME" .. idx]
                if string.len(customName) == 0 then
                    customName = nil
                end
                if idx > 0 then
                    local itemID = GetInventoryItemID("player", C_Container.ContainerIDToInventoryID(NUM_BAG_SLOTS + idx))

                    if itemID then
                        local itemName = C_Item.GetItemInfo(itemID)
                        return customName or itemName or UNKNOWN
                    end
                else
                    return customName or BANK
                end
        end)()}
        )
    end
end

local function bankHeader_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, -45)
    GameTooltip:ClearLines()
    GameTooltip_SetTitle(GameTooltip, L["Right click to customize the bag title."])
    GameTooltip:Show()
end

local function LoadBank(helpers)
    inv = helpers

    -- create bank frame, restore its saved size, and init its many pieces
    local f = CreateFrame("Frame", "GwBankFrame", UIParent, "GwBankFrameTemplate")
    tinsert(UISpecialFrames, "GwBankFrame")
    f:ClearAllPoints()
    f:SetWidth(GW.settings.BANK_WIDTH)
    onBankFrameChangeSize(f, nil, nil, true)
    f:SetClampedToScreen(true)
    f:SetClampRectInsets(-f.Left:GetWidth(), 0, f.Header:GetHeight() - 10, -35)

    -- setup show/hide
    f:SetScript("OnShow", bank_OnShow)
    f:SetScript("OnHide", bank_OnHide)
    f.buttonClose:SetScript("OnClick", GW.Parent_Hide)

    -- make blizzards bank frame inert once, we only use its open/close lifecycle
    inv.disableBlizzardFrame(BankFrame, true)
    if GW.Mists then
        BankSlotsFrame:GwKill()
    else
        BankSlotsFrame:Hide()
    end

    -- setup movable stuff
    local pos = GW.settings.BANK_POSITION
    f:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    f.mover:RegisterForDrag("LeftButton")
    f.mover.onMoveSetting = "BANK_POSITION"
    f.mover:SetScript("OnDragStart", inv.onMoverDragStart)
    f.mover:SetScript("OnDragStop", inv.onMoverDragStop)

    -- setup resizer stuff
    f:SetResizeBounds(508, 340)
    f:SetScript("OnSizeChanged", onBankFrameChangeSize)
    f.sizer.onResizeStop = onBankResizeStop
    f.sizer:SetScript("OnMouseDown", inv.onSizerMouseDown)
    f.sizer:SetScript("OnMouseUp", inv.onSizerMouseUp)

    -- setup bagheader stuff; the template ships headers for the largest flavor,
    -- flavors with fewer bank bags simply never show the leftover ones
    local headerIndex = 0
    while f["bagHeader" .. headerIndex] do
        local header = f["bagHeader" .. headerIndex]
        header.nameString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        header.nameString:SetTextColor(1, 1, 1)
        header.nameString:SetShadowColor(0, 0, 0, 0)
        header.icon2:Hide()
        header:Hide()
        header:SetScript("OnClick", bankHeader_OnClick)
        header:SetScript("OnEnter", bankHeader_OnEnter)
        header:SetScript("OnLeave", GameTooltip_Hide)
        headerIndex = headerIndex + 1
    end

    -- take the original search box
    local BankItemSearchBox = CreateFrame("EditBox", "BankItemSearchBox", f, "BagSearchBoxTemplate")
    inv.reskinSearchBox(BankItemSearchBox)
    inv.relocateSearchBox(BankItemSearchBox, f)

    -- our own item buttons need parent containers with IDs set to the bagId, in order
    -- for all of the inherited ItemButton functionality to work normally
    f.ItemFrame.Containers = {}
    for i = 1, NUM_BANKBAGSLOTS + 1 do
        local bag_id
        if i == 1 then
            bag_id = BANK_CONTAINER
        else
            bag_id = i + NUM_BAG_SLOTS - 1
        end
        local cf = CreateFrame("Frame", nil, f.ItemFrame)
        cf.gw_items = {}
        cf.gw_num_slots = 0
        cf:SetAllPoints(f.ItemFrame)
        cf:SetID(bag_id)
        cf.shouldShow = true
        f.ItemFrame.Containers[bag_id] = cf
    end

    -- anytime a ContainerFrame is populated with a bank bagId, we rescan our buttons
    hooksecurefunc("ContainerFrame_GenerateFrame", function(_, _, id)
        if id > NUM_BAG_SLOTS and id <= NUM_BAG_SLOTS + NUM_BANKBAGSLOTS then
            rescanBankContainers(f)
        end
    end)

    -- don't let anyone close bank bags while the bank is open
    hooksecurefunc("ToggleAllBags", function()
        if GwBankFrame:IsShown() then
            openAllBankBags()
        end
    end)
    hooksecurefunc("ToggleBackpack", function()
        if GwBankFrame:IsShown() then
            openAllBankBags()
        end
    end)

    -- create our bank bag slots
    createBagBar(f.ItemFrame)

    -- skin some things not done in XML
    f.headerString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
    f.headerString:SetText(BANK)
    f.spaceString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    f.spaceString:SetTextColor(1, 1, 1)
    f.spaceString:SetShadowColor(0, 0, 0, 0)

    -- setup initial events (more are added when open in bank_OnEvent)
    f:SetScript("OnEvent", bank_OnEvent)
    f:RegisterEvent("BANKFRAME_OPENED")
    f:RegisterEvent("BANKFRAME_CLOSED")

    -- setup settings button and its dropdown items
    f.buttonSort:HookScript(
        "OnClick",
        function(self)
            PlaySound(SOUNDKIT.UI_BAG_SORTING_01)
            if self:GetParent().ItemFrame:IsShown() then
                GW_SortBankBags()
            end
        end
    )
    EnableTooltip(f.buttonSort, BAG_CLEANUP_BANK)
    EnableTooltip(f.buttonSettings, BAG_SETTINGS_TOOLTIP)
    f.buttonSettings:SetScript("OnClick", function(self)
        MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)

            local function addCheck(label, getter, setter)
                local check = rootDescription:CreateCheckbox(label, getter, setter)
                check:AddInitializer(function(button, description, menu)
                    GW.BlizzardDropdownCheckButtonInitializer(button, description, menu, getter)
                end)
            end

            inv.addItemSizeMenuEntries(rootDescription, "BANK")
            addCheck(L["Reverse Bag Order"], function() return GW.settings.BANK_REVERSE_SORT end,
                     function() GW.settings.BANK_REVERSE_SORT = not GW.settings.BANK_REVERSE_SORT; setBagBarOrder(f.ItemFrame); layoutItems(f); snapFrameSize(f) end)
            addCheck(L["Show Quality Color"], function() return GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW end, function() GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW = not GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW; GW.UpdateAllOwnBagItemButtons() end)
            addCheck(L["Separate bags"], function() return GW.settings.BANK_SEPARATE_BAGS end,
                     function() local ns = not GW.settings.BANK_SEPARATE_BAGS; GW.settings.BANK_SEPARATE_BAGS = ns; layoutItems(f); snapFrameSize(f) end)
        end)
    end)

    -- return a callback that should be called when item size changes
    local changeItemSize = function()
        onBankFrameChangeSize(f, nil, nil, true)
        layoutItems(f)
        snapFrameSize(f)
    end
    return changeItemSize
end
GW.LoadBank = LoadBank
