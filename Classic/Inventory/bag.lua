local _, GW = ...
local L = GW.L
local CommaValue = GW.CommaValue
local UpdateMoney = GW.UpdateMoney
local EnableTooltip = GW.EnableTooltip
local inv

local BAG_ITEM_SIZE = 40
local BAG_ITEM_LARGE_SIZE = 40
local BAG_ITEM_COMPACT_SIZE = 32
local BAG_ITEM_PADDING = 5
local BAG_WINDOW_SIZE = 480

local function setBagHeaders()
    for i = 1, 5 do
        if i < 5 then
            local slotID = GetInventorySlotInfo("Bag" .. i - 1 .. "Slot")
            local itemID = GetInventoryItemID("player", slotID)
            local customBagHeaderName = GW.settings["BAG_HEADER_NAME" .. i]

            if itemID then
                local r, g, b = 1, 1, 1
                local itemName, _, itemRarity = C_Item.GetItemInfo(itemID)
                if itemRarity then r, g, b = C_Item.GetItemQualityColor(itemRarity) end

                _G["GwBagFrameGwBagHeader" .. i].nameString:SetText(strlen(customBagHeaderName) > 0 and customBagHeaderName or itemName and itemName or UNKNOWN)
                _G["GwBagFrameGwBagHeader" .. i].nameString:SetTextColor(r, g, b, 1)
            else
                _G["GwBagFrameGwBagHeader" .. i]:Hide()
            end
        else
            local customBagHeaderName = GW.settings["BAG_HEADER_NAME" .. i]
            _G["GwBagFrameGwBagHeader" .. i].nameString:SetText(strlen(customBagHeaderName) > 0 and customBagHeaderName or KEYRING)
            _G["GwBagFrameGwBagHeader" .. i].nameString:SetTextColor(1, 1, 1, 1)
        end
    end
    local customBagHeaderName = GW.settings.BAG_HEADER_NAME0
    _G["GwBagFrameGwBagHeader0"].nameString:SetText(strlen(customBagHeaderName) > 0 and customBagHeaderName or BACKPACK_TOOLTIP)
end

-- adjusts the ItemButton layout flow when the bag window size changes (or on open)
local function layoutBagItems(f)
    local max_col = f:GetParent().gw_bag_cols
    local col = 0
    local rev = GW.settings.BAG_REVERSE_SORT
    local sep = GW.settings.BAG_SEPARATE_BAGS
    local row = sep and 1 or 0
    local item_off = BAG_ITEM_SIZE + BAG_ITEM_PADDING
    local unfinishedRow = false
    local finishedRows = 0

    local iS = BACKPACK_CONTAINER
    local iE = NUM_BAG_SLOTS + 1
    local iD = 1
    if rev then
        iE = iS
        iS = NUM_BAG_SLOTS + 1
        iD = -1
    end
    f:GetParent().unfinishedRow = 0
    f:GetParent().finishedRow = 0
    local lcf = inv.layoutContainerFrame
    for i = iS, iE, iD do
        local bag_id = i
        local slotID, itemID
        local cf = IsBagOpen(KEYRING_CONTAINER) and bag_id == 5 and f.Containers[KEYRING_CONTAINER] or f.Containers[bag_id]

        if sep then
            if bag_id == 5 and not rev then
                if col ~= 0 then
                    row = row + 2
                else
                    row = row + 1
                end
            end
            _G["GwBagFrameGwBagHeader" .. bag_id]:Show()
            _G["GwBagFrameGwBagHeader" .. bag_id]:ClearAllPoints()
            _G["GwBagFrameGwBagHeader" .. bag_id]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, (-row + 1) * item_off)
            _G["GwBagFrameGwBagHeader" .. bag_id]:SetWidth(BAG_WINDOW_SIZE - BAG_ITEM_PADDING)
            _G["GwBagFrameGwBagHeader" .. bag_id].background:SetWidth(BAG_WINDOW_SIZE - BAG_ITEM_PADDING)
        else
            _G["GwBagFrameGwBagHeader" .. bag_id] :Hide()
        end
        if sep and rev and bag_id == 5 and not cf then
            row = 2
        end
        if cf then
            if sep and cf.shouldShow then
                if IsBagOpen(KEYRING_CONTAINER) and bag_id == 5 then
                    if col ~= 0 then col = 0 end
                end
                col, row, unfinishedRow, finishedRows = lcf(cf, max_col, row, col, false, item_off)
                cf:Show()
            elseif sep and not cf.shouldShow then
                cf:Hide()
            elseif not sep then
                col, row, unfinishedRow, finishedRows = lcf(cf, max_col, row, col, false, item_off)
                cf:Show()
            end

            if unfinishedRow then f:GetParent().unfinishedRow = f:GetParent().unfinishedRow  + 1 end
            f:GetParent().finishedRow = f:GetParent().finishedRow + finishedRows

            if not rev and bag_id < 4 then
                slotID = GetInventorySlotInfo("Bag" .. bag_id .. "Slot")
                itemID = GetInventoryItemID("player", slotID)
            elseif rev and bag_id < 5 and bag_id > 0 then
                slotID = GetInventorySlotInfo("Bag" .. bag_id - 1 .. "Slot")
                itemID = GetInventoryItemID("player", slotID)
            end

            if (sep and bag_id == 0) or (sep and itemID) or (sep and rev and bag_id == 5) then
                if col ~= 0 then
                    row = row + 2
                    col = 0
                else
                    row = row + 1
                end
            end
        end
    end
    setBagHeaders()
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
    inv.snapFrameSize(f, cfs, BAG_ITEM_SIZE, BAG_ITEM_PADDING, 350)
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
    for bag_id = BACKPACK_CONTAINER, NUM_BAG_SLOTS + 1 do
        if bag_id <= NUM_BAG_SLOTS then
            inv.takeItemButtons(f.ItemFrame, bag_id)
        else
            inv.takeItemButtons(f.ItemFrame, KEYRING_CONTAINER)
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
    local x, y = setBagBarOrder(f)
    --Add Keyringbutton here
    local b = CreateFrame("Button", "GWkeyringbutton", f, "GwKeyRingButtonTemp")
    b:SetPoint("TOPLEFT", f, "TOPLEFT", x, y)
    b:SetHighlightTexture('Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress')
    GW.SetItemButtonQualityForBags(b, 1)
    b:SetScript("OnClick",
        function(self)
            if IsBagOpen(KEYRING_CONTAINER) then
                GwBagFrame.ItemFrame.Containers[KEYRING_CONTAINER].shouldShow = false
                CloseBag(KEYRING_CONTAINER)
                self.border:Hide()
                self.IconBorder:Show()
                updateBagContainers(GwBagFrame)
                rescanBagContainers(GwBagFrame)
            else
                GwBagFrame.ItemFrame.Containers[KEYRING_CONTAINER].shouldShow = true
                OpenBag(KEYRING_CONTAINER)
                self.border:Show()
                self.IconBorder:Hide()
            end
            GwBagFrameGwBagHeader5.icon:SetShown(IsBagOpen(KEYRING_CONTAINER))
            GwBagFrameGwBagHeader5.icon2:SetShown(not IsBagOpen(KEYRING_CONTAINER))
        end
    )
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
    if IsBagOpen(KEYRING_CONTAINER) then
        GWkeyringbutton.border:Show()
        GWkeyringbutton.IconBorder:Hide()
    else
        GWkeyringbutton.border:Hide()
        GWkeyringbutton.IconBorder:Show()
    end
end
GW.AddForProfiling("bag", "updateBagBar", updateBagBar)

local function onBagResizeStop(self)
    BAG_WINDOW_SIZE = self:GetWidth()
    GW.settings.BAG_WIDTH = BAG_WINDOW_SIZE
    GwBagFrame.Header:SetWidth(BAG_WINDOW_SIZE)
    inv.onMoved(self, "BAG_POSITION", snapFrameSize)
end
GW.AddForProfiling("bag", "onBagResizeStop", onBagResizeStop)

local function onBagFrameChangeSize(self, _, _, skip)
    local cols = inv.colCount(BAG_ITEM_SIZE, BAG_ITEM_PADDING, self:GetWidth())

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
    if BAG_ITEM_SIZE == BAG_ITEM_LARGE_SIZE then
        BAG_ITEM_SIZE = BAG_ITEM_COMPACT_SIZE
        GW.settings.BAG_ITEM_SIZE = BAG_ITEM_SIZE
        inv.resizeInventory()
        return true
    end

    BAG_ITEM_SIZE = BAG_ITEM_LARGE_SIZE
    GW.settings.BAG_ITEM_SIZE = BAG_ITEM_SIZE
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
    if IsBagOpen(KEYRING_CONTAINER) then
        GWkeyringbutton.border:Show()
        GWkeyringbutton.IconBorder:Hide()
    else
        GWkeyringbutton.border:Hide()
        GWkeyringbutton.IconBorder:Show()
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
    if IsBagOpen(KEYRING_CONTAINER) then
        CloseBag(KEYRING_CONTAINER)
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
        if (bag_id <= NUM_BAG_SLOTS and bag_id >= BACKPACK_CONTAINER) or bag == KEYRING_CONTAINER then
            self.gw_need_bag_update = true
        end
    elseif event == "BAG_UPDATE_DELAYED" then
        if self.gw_need_bag_rescan then
            for bag_id = 1, NUM_BAG_SLOTS do
                if not IsBagOpen(bag_id) then
                    OpenBag(bag_id)
                end
            end
            if not IsBagOpen(KEYRING_CONTAINER) then
                OpenBag(KEYRING_CONTAINER)
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
    local bag_id = string.sub(self:GetName(), -1)
    if btn == "LeftButton" then
        if tonumber(bag_id) == 5 then
            if IsBagOpen(KEYRING_CONTAINER) then
                self:GetParent().ItemFrame.Containers[KEYRING_CONTAINER].shouldShow = false
                CloseBag(KEYRING_CONTAINER)
                GWkeyringbutton.border:Hide()
                GWkeyringbutton.IconBorder:Show()
                updateBagContainers(GwBagFrame)
                rescanBagContainers(GwBagFrame)
            else
                self:GetParent().ItemFrame.Containers[KEYRING_CONTAINER].shouldShow = true
                OpenBag(KEYRING_CONTAINER)
                GWkeyringbutton.border:Show()
                GWkeyringbutton.IconBorder:Hide()
            end
            self.icon:SetShown(IsBagOpen(KEYRING_CONTAINER))
            self.icon2:SetShown(not IsBagOpen(KEYRING_CONTAINER))
        else
            self:GetParent().ItemFrame.Containers[tonumber(bag_id)].shouldShow = not self.icon:IsShown()
            self.icon:SetShown(not self.icon:IsShown())
            self.icon2:SetShown(not self.icon:IsShown())
        end

        layoutItems(self:GetParent())
        snapFrameSize(self:GetParent())
    elseif btn == "RightButton" then
        StaticPopup_Show("GW_CHANGE_BAG_HEADER", nil, nil, bag_id)
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

    BAG_WINDOW_SIZE = GW.settings.BAG_WIDTH
    BAG_ITEM_SIZE = GW.settings.BAG_ITEM_SIZE
    if BAG_ITEM_SIZE > 40 then
        BAG_ITEM_SIZE = 40
        GW.settings.BAG_ITEM_SIZE = 40
    end

    -- create bag frame, restore its saved size, and init its many pieces
    local f = CreateFrame("Frame", "GwBagFrame", UIParent, "GwBagFrameTemplate")
    tinsert(UISpecialFrames, "GwBagFrame")
    f.gw_state = "closed"
    f:ClearAllPoints()
    f:SetWidth(BAG_WINDOW_SIZE)
    f.Header:SetWidth(BAG_WINDOW_SIZE)
    onBagFrameChangeSize(f, nil, nil, true)

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
    for i = 0, 5 do
        local header = _G["GwBagFrameGwBagHeader" .. i]
        header.nameString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        header.nameString:SetTextColor(1, 1, 1)
        header.nameString:SetShadowColor(0, 0, 0, 0)
        if i == 5 then
            header.icon:Hide()
            header.icon2:Show()
        else
            header.icon2:Hide()
        end
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
    for bag_id = BACKPACK_CONTAINER, NUM_BAG_SLOTS + 1 do
        local cf = CreateFrame("Frame", nil, f.ItemFrame)
        cf.gw_items = {}
        cf.gw_num_slots = 0
        cf:SetAllPoints(f.ItemFrame)
        cf:SetID(bag_id)
        cf.shouldShow = bag_id <= NUM_BAG_SLOTS
        f.ItemFrame.Containers[(bag_id <= NUM_BAG_SLOTS and bag_id or KEYRING_CONTAINER)] = cf
    end

    --Keyring Button here to Containers
    local cf = CreateFrame("Frame", nil, f.ItemFrame)
    cf.gw_items = {}
    cf.gw_num_slots = 0
    cf:SetAllPoints(f.ItemFrame)
    cf:SetID(KEYRING_CONTAINER)
    f.ItemFrame.Containers[KEYRING_CONTAINER] = cf

    -- anytime a ContainerFrame is populated with a backpack bagId, we take its buttons
    hooksecurefunc("ContainerFrame_GenerateFrame", function(_, _, id)
        if (id >= BACKPACK_CONTAINER and id <= NUM_BAG_SLOTS) or id == KEYRING_CONTAINER then
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

    -- return a callback that should be called when item size changes
    local changeItemSize = function()
        BAG_ITEM_SIZE = GW.settings.BAG_ITEM_SIZE
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
