local _, GW = ...
local L = GW.L
local CommaValue = GW.CommaValue
local UpdateMoney = GW.UpdateMoney
local EnableTooltip = GW.EnableTooltip
local inv

local BAG_ITEM_LARGE_SIZE = 40
local BAG_ITEM_COMPACT_SIZE = 32
local BAG_ITEM_PADDING = 5

local function setBagHeaders(frame)
    for i = 1, 4 do
        local slotID = GetInventorySlotInfo("Bag" .. i - 1 .. "Slot")
        local itemID = GetInventoryItemID("player", slotID)
        local customBagHeaderName = GW.settings["BAG_HEADER_NAME" .. i]
        local header = frame["bagHeader" .. i]

        if itemID then
            local r, g, b = 1, 1, 1
            local itemName, _, itemRarity = C_Item.GetItemInfo(itemID)
            if itemRarity then r, g, b = C_Item.GetItemQualityColor(itemRarity) end

            header.nameString:SetText(strlen(customBagHeaderName) > 0 and customBagHeaderName or itemName and itemName or UNKNOWN)
            header.nameString:SetTextColor(r, g, b, 1)
        else
            header:Hide()
        end
    end
    local customBagHeaderName = GW.settings.BAG_HEADER_NAME0
    frame.bagHeader0.nameString:SetText(strlen(customBagHeaderName) > 0 and customBagHeaderName or BACKPACK_TOOLTIP)
end

-- adjusts the ItemButton layout flow when the bag window size changes (or on open)
local function layoutBagItems(f)
    local parent = f:GetParent()
    local max_col = parent.gw_bag_cols
    local col = 0
    local rev = GW.settings.BAG_REVERSE_SORT
    local sep = GW.settings.BAG_SEPARATE_BAGS
    local row = sep and 1 or 0
    local item_off = GW.settings.BAG_ITEM_SIZE + BAG_ITEM_PADDING
    local unfinishedRow = false
    local finishedRows = 0

    local iS = BACKPACK_CONTAINER
    local iE = NUM_BAG_SLOTS
    local iD = 1
    if rev then
        iE = iS
        iS = NUM_BAG_SLOTS
        iD = -1
    end
    parent.unfinishedRow = 0
    parent.finishedRow = 0
    local lcf = inv.layoutContainerFrame
    for i = iS, iE, iD do
        local bag_id = i
        local itemID
        local cf = f.Containers[bag_id]
        local header = parent["bagHeader" .. i]
        if sep then
            header:Show()
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", f, "TOPLEFT", 0, (-row + 1) * item_off)
            header:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, (-row + 1) * item_off)
        else
            header:Hide()
        end

        if sep then
            cf:SetShown(cf.shouldShow)
        else
            cf:Show()
        end

        if cf:IsShown() then
            col, row, unfinishedRow, finishedRows = lcf(cf, max_col, row, col, false, item_off)
        end

        parent.unfinishedRow = parent.unfinishedRow + (unfinishedRow and 1 or 0)
        parent.finishedRow = parent.finishedRow + finishedRows
        itemID = GetInventoryItemID("player", C_Container.ContainerIDToInventoryID(bag_id))

        if (sep and (bag_id == 0 or itemID)) then
            if col ~= 0 then
                row = row + 2
                col = 0
            else
                row = row + 1
            end
        end

        finishedRows = 0
        unfinishedRow = false
    end

    if GW.settings.BAG_SEPARATE_BAGS then
        setBagHeaders(parent)
    end
end
GW.AddForProfiling("bag", "layoutBagItems", layoutBagItems)

-- adjusts the ItemButton layout flow when the bag window size changes (or on open)
local function layoutItems(f)
    if f.ItemFrame:IsShown() then
        layoutBagItems(f.ItemFrame)
    end
end
GW.AddForProfiling("bag", "layoutItems", layoutItems)

-- adjusts the bag frame size to snap to the exact row/col sizing of contents
local function snapFrameSize(f)
    local cfs
    if f.ItemFrame:IsShown() then
        cfs = f.ItemFrame.Containers
    end
    inv.snapFrameSize(f, cfs, GW.settings.BAG_ITEM_SIZE, BAG_ITEM_PADDING, 350)
end
GW.AddForProfiling("bag", "snapFrameSize", snapFrameSize)

local function updateMoney(self)
    if not self then
        return
    end
    local money = GetMoney()

    local gold = math.floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
    local silver = math.floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
    local copper = mod(money, COPPER_PER_SILVER)

    self.bronze:SetText(copper)
    self.silver:SetText(silver)
    self.gold:SetText(CommaValue(gold))

    UpdateMoney()
end
GW.AddForProfiling("bag", "updateMoney", updateMoney)

local function watchCurrency(self)
    local watchSlot = 1
    local currencyCount = GetCurrencyListSize()
    for i = 1, currencyCount do
        local _, isHeader, _, _, isWatched, count, icon = GetCurrencyListInfo(i)
        if not isHeader and isWatched and watchSlot < 4 then
            self["currency" .. tostring(watchSlot)]:SetText(CommaValue(count))
            self["currency" .. tostring(watchSlot) .. "Texture"]:SetTexture(icon)
            self["currency" .. tostring(watchSlot) .. "Frame"].CurrencyIdx = i
            watchSlot = watchSlot + 1
        end
    end

    for i = watchSlot, 3 do
        self["currency" .. tostring(i)]:SetText("")
        self["currency" .. tostring(i) .. "Texture"]:SetTexture(nil)
        self["currency" .. tostring(watchSlot) .. "Frame"].CurrencyIdx = nil
    end
end
GW.AddForProfiling("bag", "watchCurrency", watchCurrency)

local function updateFreeSpaceString(free, full)
    local space_string = free .. " / " .. full
    GwBagFrame.spaceString:SetText(space_string)
end
GW.AddForProfiling("bag", "updateFreeSpaceString", updateFreeSpaceString)

-- update the number of free bag slots available and set the display for it
local function updateFreeBagSlots()
    inv.updateFreeSlots(GwBagFrame.spaceString, 1, NUM_BAG_SLOTS, BACKPACK_CONTAINER)
end
GW.AddForProfiling("bag", "updateFreeBagSlots", updateFreeBagSlots)

-- update all backpack bag items
local function updateBagContainers(f)
    if f.ItemFrame:IsShown() then
        updateFreeBagSlots()
        layoutItems(f)
        snapFrameSize(f)
    end
end
GW.AddForProfiling("bag", "updateBagContainers", updateBagContainers)

-- rescan ALL bag ItemButtons
local function rescanBagContainers(f)
    for bag_id = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        if bag_id <= NUM_BAG_SLOTS then
            inv.takeItemButtons(f.ItemFrame, bag_id)
        end
    end
    updateBagContainers(f)
end
GW.AddForProfiling("bag", "rescanBagContainers", rescanBagContainers)

-- draws the backpack bag slots in the correct order
local function setBagBarOrder(f)
    local x, y = -40, nil
    local bag_size = 28
    local bag_padding = 4
    local rev = GW.settings.BAG_REVERSE_SORT
    if rev then
        y = 5 - ((bag_size + bag_padding) * NUM_BAG_SLOTS)
    else
        y = 5
    end

    for bag_idx = BACKPACK_CONTAINER, NUM_BAG_SLOTS  do
        local b = f.bags[bag_idx]
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", f, "TOPLEFT", x, y)
        if rev then
            y = y + bag_size + bag_padding
        else
            y = y - bag_size - bag_padding
        end
    end
    return x, y
end
GW.AddForProfiling("bag", "setBagBarOrder", setBagBarOrder)

local function bag_OnClick(self, button)
    -- on left click, ensure that the bag stays open despite default toggle behavior
    if button == "LeftButton" then
        if self.gwHasBag and not IsBagOpen(self:GetID() - CharacterBag0Slot:GetID() + 1) then
            OpenBag(self:GetID() - CharacterBag0Slot:GetID() + 1)
        end
    end
end
GW.AddForProfiling("bag", "bag_OnClick", bag_OnClick)

-- creates the bag slot icons for the ItemFrame
local function createBagBar(f)
    f.bags = {}

    -- steal the existing main backpack button
    local bp = MainMenuBarBackpackButton
    bp:SetParent(f)
    inv.reskinBagBar(bp)
    bp:RegisterForClicks("LeftButtonUp")
    bp:SetChecked(false)
    bp:HookScript("OnMouseDown", inv.bag_OnMouseDown)
    bp.gwBackdrop = true -- checked by some things to see if this is a reskinned button
    f.bags[BACKPACK_CONTAINER] = bp
    hooksecurefunc(
        "MainMenuBarBackpackButton_UpdateFreeSlots",
        function()
            bp.Count:SetText(bp.freeSlots)
        end
    )

    -- create bag slot buttons for equippable bags
    local cb0_id = CharacterBag0Slot:GetID()
    local getInvId = function(self)
        local inv_id, _ = GetInventorySlotInfo(strsub(self:GetName(), 10))
        return inv_id
    end
    for bag_idx = 1, NUM_BAG_SLOTS do
        -- this name MUST have a 9-letter prefix and match the style "CharacterBag0Slot"
        -- because of hard-coded string parsing in PaperDollItemSlotButton_OnLoad
        local name = "GwInvntry" .. "Bag" .. (bag_idx - 1) .. "Slot"
        local b = CreateFrame("CheckButton", name, f, "GwBackpackBagTemplate")

        -- We depend on a number of behaviors from the default BagSlotButtonTemplate.
        -- The ID set here is NOT the usual bag_id; rather it is an offset from the
        -- id of CharacterBag0Slot, used internally by BagSlotButtonTemplate methods.
        b:SetID(cb0_id + bag_idx - 1)
        -- unlike BankItemButtonBagTemplate, we must provide the GetInventorySlot method
        b.GetInventorySlot = getInvId

        -- remove default of capturing right-click also (we handle right-click separately)
        b:RegisterForClicks("LeftButtonUp")
        b:HookScript("OnClick", bag_OnClick)
        b:HookScript("OnMouseDown", inv.bag_OnMouseDown)

        inv.reskinBagBar(b)
        local invID = C_Container.ContainerIDToInventoryID(bag_idx)
        local bagLink = GetInventoryItemLink("player", invID)
        if bagLink then
            GW.SetItemButtonQualityForBags(b, select(3, C_Item.GetItemInfo(bagLink)))
        else
            GW.SetItemButtonQualityForBags(b, 1)
        end

        f.bags[bag_idx] = b
    end
    setBagBarOrder(f)
end
GW.AddForProfiling("bag", "createBagBar", createBagBar)

-- updates the contents of the backpack bag slots
local function updateBagBar(f)
    for bag_idx = 1, NUM_BAG_SLOTS do
        local b = f.bags[bag_idx]
        local inv_id = b:GetInventorySlot()
        local bag_tex = GetInventoryItemTexture("player", inv_id)
        local _, slot_tex = GetInventorySlotInfo("Bag" .. bag_idx)

        b.icon:Show()
        b.gwHasBag = false -- flag used by OnClick hook to pop up context menu when valid
        local norm = b:GetNormalTexture()
        norm:SetVertexColor(1, 1, 1, 0.75)
        if bag_tex ~= nil then
            b.gwHasBag = true
            b.icon:SetTexture(bag_tex)
            if IsInventoryItemLocked(inv_id) then
                b.icon:SetDesaturated(true)
            else
                b.icon:SetDesaturated(false)
            end
        elseif slot_tex ~= nil then
            b.tooltipText = BANK_BAG
            b.icon:SetTexture(slot_tex)
            b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        else
            b.icon:Hide()
        end
        local invID = C_Container.ContainerIDToInventoryID(bag_idx)
        local bagLink = GetInventoryItemLink("player", invID)
        if bagLink then
            GW.SetItemButtonQualityForBags(b, select(3, C_Item.GetItemInfo(bagLink)))
        else
            b:SetChecked(false)
            GW.SetItemButtonQualityForBags(b, 1)
        end
    end
end
GW.AddForProfiling("bag", "updateBagBar", updateBagBar)

local function onBagResizeStop(self)
    GW.settings.BAG_WIDTH = self:GetWidth()
    GwBagFrame.Header:SetWidth(GW.settings.BAG_WIDTH)
    inv.onMoved(self, "BAG_POSITION", snapFrameSize)
end
GW.AddForProfiling("bag", "onBagResizeStop", onBagResizeStop)

local function onBagFrameChangeSize(self, _, _, skip)
    local cols = inv.colCount(GW.settings.BAG_ITEM_SIZE, BAG_ITEM_PADDING, self:GetWidth())

    self.Header:SetWidth(self:GetWidth())
    if not self.gw_bag_cols or self.gw_bag_cols ~= cols then
        self.gw_bag_cols = cols
        if not skip then
            layoutItems(self)
        end
    end
end
GW.AddForProfiling("bag", "onBagFrameChangeSize", onBagFrameChangeSize)

-- toggles the setting for compact/large icons
local function compactToggle()
    if GW.settings.BAG_ITEM_SIZE == BAG_ITEM_LARGE_SIZE then
        GW.settings.BAG_ITEM_SIZE = BAG_ITEM_COMPACT_SIZE
        inv.resizeInventory()
        return true
    end

    GW.settings.BAG_ITEM_SIZE = BAG_ITEM_LARGE_SIZE
    inv.resizeInventory()
    return false
end
GW.AddForProfiling("bag", "compactToggle", compactToggle)

-- deal with all the stupid permutations in which these can be called
local function hookOpenBag(bag_id)
    if not bag_id or bag_id ~= BACKPACK_CONTAINER then
        return
    end
    local f = GwBagFrame
    if not f:IsShown() then
        C_Timer.After(0, function() f:Show() end)
    end
end
GW.AddForProfiling("bag", "hookOpenBag", hookOpenBag)
local function hookOpenBackpack()
    hookOpenBag(BACKPACK_CONTAINER)
end
GW.AddForProfiling("bag", "hookOpenBackpack", hookOpenBackpack)
local function hookCloseBag(bag_id)
    if not bag_id or bag_id ~= BACKPACK_CONTAINER then
        return
    end
    local f = GwBagFrame
    if f:IsShown() then
        C_Timer.After(0, function() f:Hide() end)
    end
end
GW.AddForProfiling("bag", "hookCloseBag", hookCloseBag)
local function hookCloseBackpack()
    hookCloseBag(BACKPACK_CONTAINER)
end
GW.AddForProfiling("bag", "hookCloseBackpack", hookCloseBackpack)
local function hookToggleBackpack()
    local f = GwBagFrame
    if IsBagOpen(0) then
        if not f:IsShown() then
            C_Timer.After(0, function() f:Show() end)
        end
    else
        if f:IsShown() then
            C_Timer.After(0, function() f:Hide() end)
        end
    end
end
GW.AddForProfiling("bag", "hookToggleBackpack", hookToggleBackpack)
local function hookToggleBag(bag_id)
    if not bag_id or bag_id ~= BACKPACK_CONTAINER then
        return
    end
    hookToggleBackpack()
end
GW.AddForProfiling("bag", "hookToggleBag", hookToggleBag)

local function bag_OnShow(self)
    PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
    self:RegisterEvent("ITEM_LOCKED")
    self:RegisterEvent("ITEM_UNLOCKED")
    self:RegisterEvent("BAG_UPDATE")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    if not IsBagOpen(BACKPACK_CONTAINER) then
        OpenBackpack()
    end
    for i = 1, NUM_BAG_SLOTS do
        if not IsBagOpen(i) then
            OpenBag(i)
        end
    end

    updateBagBar(self.ItemFrame)
    updateBagContainers(self)
end
GW.AddForProfiling("bag", "bag_OnShow", bag_OnShow)

local function bag_OnHide(self)
    PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
    self:UnregisterAllEvents()
    for i = 1, NUM_BAG_SLOTS do
        if IsBagOpen(i) then
            CloseBag(i)
        end
    end
    if IsBagOpen(BACKPACK_CONTAINER) then
        CloseBackpack()
    end
end
GW.AddForProfiling("bag", "bag_OnHide", bag_OnHide)

local function bag_OnEvent(self, event, ...)
    if event == "ITEM_LOCKED" or event == "ITEM_UNLOCKED" then
        -- check if the item un/locked is a character bag and gray it out if so
        local bag = select(1, ...)
        local slot = select(2, ...)
        local cb0_id = CharacterBag0Slot:GetID()

        if slot == nil and bag >= cb0_id and bag <= cb0_id + NUM_BAG_SLOTS then
            local bag_id = bag - cb0_id + 1
            local b = self.ItemFrame.bags[bag_id]
            if b and b.icon and b.icon.SetDesaturated then
                if event == "ITEM_LOCKED" then
                    b.icon:SetDesaturated(true)
                else
                    b.icon:SetDesaturated(false)
                end
            end
            self.gw_need_bag_rescan = true
        end
    elseif event == "BAG_UPDATE" then
        local bag_id = select(1, ...)
        if (bag_id <= NUM_BAG_SLOTS and bag_id >= BACKPACK_CONTAINER) then
            self.gw_need_bag_update = true
        end
    elseif event == "BAG_UPDATE_DELAYED" then
        if self.gw_need_bag_rescan then
            for bag_id = 1, NUM_BAG_SLOTS do
                if not IsBagOpen(bag_id) then
                    OpenBag(bag_id)
                end
            end
            updateBagBar(self.ItemFrame)
            rescanBagContainers(self)
            self.gw_need_bag_rescan = false
        end
        if self.gw_need_bag_update then
            self.gw_need_bag_update = false
            if self.ItemFrame:IsShown() then
                updateFreeBagSlots()
            end
        end
    end
end
GW.AddForProfiling("bag", "bag_OnEvent", bag_OnEvent)

local function bagHeader_OnClick(self, btn)
    local bag_id = self:GetID()
    if btn == "LeftButton" then
        self:GetParent().ItemFrame.Containers[bag_id].shouldShow = not self.icon:IsShown()
        self.icon:SetShown(not self.icon:IsShown())
        self.icon2:SetShown(not self.icon:IsShown())

        layoutItems(self:GetParent())
        snapFrameSize(self:GetParent())
    elseif btn == "RightButton" then
        GW.ShowPopup({text = L["New Bag Name"],
            OnAccept = function(promptFrame)
                GW.settings["BAG_HEADER_NAME" .. bag_id] = promptFrame.input:GetText()
                self.nameString:SetText(GW.settings["BAG_HEADER_NAME" .. bag_id])
            end,
            hasEditBox = true,
            button1 = SAVE,
            button2 = RESET,
            EditBoxOnEscapePressed = function(popup) popup:Hide() end,
            OnCancel = function()
                GW.settings["BAG_HEADER_NAME" .. bag_id] = ""
                if bag_id > 0 then
                    local slotID = GetInventorySlotInfo("Bag" .. bag_id - 1 .. "Slot")
                    local itemID = GetInventoryItemID("player", slotID)

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
                    self.nameString:SetText(BACKPACK_TOOLTIP)
                end
            end,
            inputText = (function()
                local customName = GW.settings["BAG_HEADER_NAME" .. bag_id]
                if string.len(customName) == 0 then
                    customName = nil
                end
                if bag_id > 0 then
                    local slotID = GetInventorySlotInfo("Bag" .. bag_id - 1 .. "Slot")
                    local itemID = GetInventoryItemID("player", slotID)

                    if itemID then
                        local itemName = C_Item.GetItemInfo(itemID)
                        return customName or itemName or UNKNOWN
                    end
                else
                    return customName or BACKPACK_TOOLTIP
                end
            end)()}
        )
    end
end

local function bagHeader_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, -45)
    GameTooltip:ClearLines()
    GameTooltip_SetTitle(GameTooltip, L["Right click to customize the bag title."])
    GameTooltip:Show()
end

local function LoadBag(helpers)
    inv = helpers

    if GW.settings.BAG_ITEM_SIZE > 40 then
        GW.settings.BAG_ITEM_SIZE = 40
    end

    -- create bag frame, restore its saved size, and init its many pieces
    local f = CreateFrame("Frame", "GwBagFrame", UIParent, "GwBagFrameTemplate")
    tinsert(UISpecialFrames, "GwBagFrame")
    f.gw_state = "closed"
    f:ClearAllPoints()
    f:SetWidth(GW.settings.BAG_WIDTH)
    f.Header:SetWidth(GW.settings.BAG_WIDTH)
    onBagFrameChangeSize(f, nil, nil, true)
    f:SetClampedToScreen(true)
	f:SetClampRectInsets(-f.Left:GetWidth(), 0, f.Header:GetHeight() - 10, -35)

    -- setup show/hide
    f:SetScript("OnShow", bag_OnShow)
    f:SetScript("OnHide", bag_OnHide)
    f.buttonClose:SetScript("OnClick", GW.Parent_Hide)

    -- setup movable stuff
    local pos = GW.settings.BAG_POSITION
    f:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    f.mover:RegisterForDrag("LeftButton")
    f.mover.onMoveSetting = "BAG_POSITION"
    f.mover:SetScript("OnDragStart", inv.onMoverDragStart)
    f.mover:SetScript("OnDragStop", inv.onMoverDragStop)

    -- setup resizer stuff
    f:SetResizeBounds(304, 340)
    f:SetScript("OnSizeChanged", onBagFrameChangeSize)
    f.sizer.onResizeStop = onBagResizeStop
    f.sizer:SetScript("OnMouseDown", inv.onSizerMouseDown)
    f.sizer:SetScript("OnMouseUp", inv.onSizerMouseUp)

    -- setup bagheader stuff
    for i = 0, 4 do
        local header = f["bagHeader" .. i]
        header.nameString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        header.nameString:SetTextColor(1, 1, 1)
        header.nameString:SetShadowColor(0, 0, 0, 0)
        header.icon2:Hide()
        header:SetScript("OnClick", bagHeader_OnClick)
        header:SetScript("OnEnter", bagHeader_OnEnter)
        header:SetScript("OnLeave", GameTooltip_Hide)
    end

    -- take the original search box
    -- Create bag item search box
    local BagItemSearchBox = CreateFrame("EditBox", "BagItemSearchBox", f, "BagSearchBoxTemplate")
    inv.reskinSearchBox(BagItemSearchBox)
    hooksecurefunc(
        "ContainerFrame_Update",
        function()
            inv.relocateSearchBox(BagItemSearchBox, f)
        end
    )
    inv.relocateSearchBox(BagItemSearchBox, f)

    -- when we take ownership of ItemButtons, we need parent containers with IDs
    -- set to the ID (bagId) of the original ContainerFrame we stole it from, in order
    -- for all of the inherited ItemButton functionality to work normally
    f.ItemFrame.Containers = {}
    for bag_id = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local cf = CreateFrame("Frame", nil, f.ItemFrame)
        cf.gw_items = {}
        cf.gw_num_slots = 0
        cf:SetAllPoints(f.ItemFrame)
        cf:SetID(bag_id)
        cf.shouldShow = bag_id <= NUM_BAG_SLOTS
        f.ItemFrame.Containers[(bag_id <= NUM_BAG_SLOTS and bag_id)] = cf
    end

    -- anytime a ContainerFrame is populated with a backpack bagId, we take its buttons
    hooksecurefunc("ContainerFrame_GenerateFrame", function(_, _, id)
        if (id >= BACKPACK_CONTAINER and id <= NUM_BAG_SLOTS) then
            rescanBagContainers(f)
        end
    end)

    -- anytime a ContainerFrame shown we set it to unchecked and set the border
    hooksecurefunc("ContainerFrame_OnShow", function()
        MainMenuBarBackpackButton:SetChecked(false)
        GW.SetItemButtonQualityForBags(MainMenuBarBackpackButton, 1)
    end)

    -- create our backpack bag slots
    createBagBar(f.ItemFrame)

    -- skin some things not done in XML
    f.headerString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 2)
    f.headerString:SetText(INVENTORY_TOOLTIP)
    f.spaceString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    f.spaceString:SetTextColor(1, 1, 1)
    f.spaceString:SetShadowColor(0, 0, 0, 0)

    -- setup initial events (more are added when open in bag_OnEvent)
    f:SetScript("OnEvent", bag_OnEvent)
    hooksecurefunc("OpenBag", hookOpenBag)
    hooksecurefunc("CloseBag", hookCloseBag)
    hooksecurefunc("ToggleBag", hookToggleBag)
    hooksecurefunc("OpenBackpack", hookOpenBackpack)
    hooksecurefunc("CloseBackpack", hookCloseBackpack)
    hooksecurefunc("ToggleBackpack", hookToggleBackpack)
    local bindings = {"TOGGLEBAG1", "TOGGLEBAG2", "TOGGLEBAG3", "TOGGLEBAG4"}
    for _, b in pairs(bindings) do
        local key = GetBindingKey(b)
        if key then
            SetOverrideBinding(f, false, key, "TOGGLEBACKPACK")
        end
    end

    -- setup settings button and its dropdown items
    f.buttonSort:HookScript(
        "OnClick",
        function()
            PlaySound(SOUNDKIT.UI_BAG_SORTING_01)
            GW_SortBags()
        end
    )
    EnableTooltip(f.buttonSort, BAG_CLEANUP_BAGS)
    EnableTooltip(f.buttonSettings, BAG_SETTINGS_TOOLTIP)
    f.buttonSettings:SetScript("OnClick", function(self)
        MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
            local function addCheck(label, getter, setter)
                local check = rootDescription:CreateCheckbox(label, getter, setter)
                check:AddInitializer(function(button, description, menu)
                    GW.BlizzardDropdownCheckButtonInitializer(button, description, menu, getter)
                end)
            end

            addCheck(L["Compact Icons"], function() return GW.settings.BAG_ITEM_SIZE == BAG_ITEM_COMPACT_SIZE end, compactToggle)
            addCheck(L["Loot to leftmost Bag"], function() return GW.settings.BAG_REVERSE_NEW_LOOT end,
                     function() local ns = not GW.settings.BAG_REVERSE_NEW_LOOT; C_Container.SetInsertItemsLeftToRight(ns); GW.settings.BAG_REVERSE_NEW_LOOT = ns end)
            addCheck(L["Sort to Last Bag"], function() return GW.settings.BAG_ITEMS_REVERSE_SORT end,
                     function() local ns = not GW.settings.BAG_ITEMS_REVERSE_SORT; GW.settings.BAG_ITEMS_REVERSE_SORT = ns end)
            addCheck(L["Reverse Bag Order"], function() return GW.settings.BAG_REVERSE_SORT end,
                     function() GW.settings.BAG_REVERSE_SORT = not GW.settings.BAG_REVERSE_SORT; layoutItems(f); snapFrameSize(f) end)
            addCheck(L["Show Quality Color"], function() return GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW end,
                     function() GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW = not GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW; ContainerFrame_UpdateAll() end)
            addCheck(L["Show Junk Icon"], function() return GW.settings.BAG_ITEM_JUNK_ICON_SHOW end,
                     function() GW.settings.BAG_ITEM_JUNK_ICON_SHOW = not GW.settings.BAG_ITEM_JUNK_ICON_SHOW; ContainerFrame_UpdateAll() end)
            addCheck(L["Show Upgrade Icon"], function() return GW.settings.BAG_ITEM_UPGRADE_ICON_SHOW end,
                     function() GW.settings.BAG_ITEM_UPGRADE_ICON_SHOW = not GW.settings.BAG_ITEM_UPGRADE_ICON_SHOW; ContainerFrame_UpdateAll() end)
            addCheck(L["Show Profession Bag Coloring"], function() return GW.settings.BAG_PROFESSION_BAG_COLOR end,
                     function() GW.settings.BAG_PROFESSION_BAG_COLOR = not GW.settings.BAG_PROFESSION_BAG_COLOR; ContainerFrame_UpdateAll() end)
            addCheck(SHOW_ITEM_LEVEL:gsub("-\n", ""):gsub("\n", " "), function() return GW.settings.BAG_SHOW_ILVL end,
                     function() GW.settings.BAG_SHOW_ILVL = not GW.settings.BAG_SHOW_ILVL; ContainerFrame_UpdateAll() end)
            addCheck(L["Sell junk automatically"], function() return GW.settings.BAG_VENDOR_GRAYS end,
                     function() local ns = not GW.settings.BAG_VENDOR_GRAYS; GW.settings.BAG_VENDOR_GRAYS = ns; GW.SetupVendorJunk(ns) end)
            addCheck(L["Show Equipment Set Name"], function() return GW.settings.BAG_SHOW_EQUIPMENT_SET_NAME end,
                     function() GW.settings.BAG_SHOW_EQUIPMENT_SET_NAME = not GW.settings.BAG_SHOW_EQUIPMENT_SET_NAME; ContainerFrame_UpdateAll() end)
            addCheck(L["Separate bags"], function() return GW.settings.BAG_SEPARATE_BAGS end,
                     function() local ns = not GW.settings.BAG_SEPARATE_BAGS; GW.settings.BAG_SEPARATE_BAGS = ns; layoutItems(f); snapFrameSize(f) end)
        end)
    end)

    GW.SetupVendorJunk(GW.settings.BAG_VENDOR_GRAYS)

    -- setup money frame
    for _, frameName in ipairs({"bronze", "silver", "gold"}) do
        f[frameName]:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    end
    f.bronze:SetTextColor(177/255, 97/255, 34/255)
    f.silver:SetTextColor(170/255, 170/255, 170/255)
    f.gold:SetTextColor(221/255, 187/255, 68/255)

    -- money frame tooltip
    f.moneyFrame:SetScript("OnEnter", GW.Money_OnEnter)
    f.moneyFrame:SetScript("OnClick", GW.Money_OnClick)

    -- update money when applicable
    f.moneyFrame:SetScript("OnEvent", function(self)
        if GW.inWorld then
            updateMoney(self:GetParent())
        end
    end)
    f.moneyFrame:RegisterEvent("PLAYER_MONEY")
    updateMoney(f)

    f.currency:SetScript("OnClick", function()
        -- TODO: cannot do this properly until we make the whole bag frame secure
        if not InCombatLockdown() then
            ToggleCharacter("TokenFrame")
        end
    end)

    -- setup watch currencies
    for i = 1, 3 do
        local currencyFrame = f["currency" .. i]
        currencyFrame:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        currencyFrame:SetTextColor(1, 1, 1)
        f["currency" .. i .. "Frame"]:SetScript("OnEnter", function(self)
            if self.CurrencyIdx then
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                GameTooltip:ClearLines()
                GameTooltip:SetCurrencyToken(self.CurrencyIdx)
                GameTooltip:Show()
            end
        end)
    end

    f.currency:SetScript("OnEvent", function(self)
        if GW.inWorld then
            watchCurrency(self:GetParent())
        end
    end)
    f.currency:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    hooksecurefunc(
        "SetCurrencyBackpack",
        function()
            watchCurrency(f)
        end
    )
    watchCurrency(f)

    -- return a callback that should be called when item size changes
    local changeItemSize = function()
        layoutItems(f)
        snapFrameSize(f)
        -- TODO: update the text on the compact icons config option
    end

    for i = 0, 3 do
        _G["CharacterBag" .. i .. "Slot"]:Hide()
    end

    -- Create sell junk banner
    local smsj = CreateFrame("FRAME", nil, MerchantFrame)
    smsj:ClearAllPoints()
    smsj:SetPoint("BOTTOMLEFT", 4, 4)
    smsj:SetSize(160, 22)
    smsj:SetToplevel(true)
    smsj:Hide()

    smsj.shadow = smsj:CreateTexture(nil, "BACKGROUND")
    smsj.shadow:SetAllPoints()
    smsj.shadow:SetColorTexture(0.1, 0.1, 0.1, 1.0)

    smsj.text = smsj:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    smsj.text:SetAllPoints();
    smsj.text:SetText(L["Selling Junk"])

    f.smsj = smsj

    return changeItemSize
end
GW.LoadBag = LoadBag
