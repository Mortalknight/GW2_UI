local _, GW = ...
local L = GW.L
local CommaValue = GW.CommaValue
local UpdateMoney = GW.UpdateMoney
local EnableTooltip = GW.EnableTooltip
local inv

local BAG_ITEM_LARGE_SIZE = 40
local BAG_ITEM_COMPACT_SIZE = 32
local BAG_ITEM_PADDING = 5

local function setBagHeaders()
    for i = 1, 5 do
        local slotID = GetInventorySlotInfo(i == 5 and ("ReagentBag0Slot") or ("Bag" .. i - 1 .. "Slot"))
        local itemID = GetInventoryItemID("player", slotID)

        if itemID then
            local r, g, b = 1, 1, 1
            local itemName, _, itemRarity = C_Item.GetItemInfo(itemID)
            if itemRarity then r, g, b = C_Item.GetItemQualityColor(itemRarity) end

            _G["GwBagFrameGwBagHeader" .. i].nameString:SetText(strlen(GW.settings["BAG_HEADER_NAME" .. i]) > 0 and GW.settings["BAG_HEADER_NAME" .. i] or itemName and itemName or UNKNOWN)
            _G["GwBagFrameGwBagHeader" .. i].nameString:SetTextColor(r, g, b, 1)
        else
            _G["GwBagFrameGwBagHeader" .. i]:Hide()
        end
    end
    _G["GwBagFrameGwBagHeader0"].nameString:SetText(strlen(GW.settings.BAG_HEADER_NAME0) > 0 and GW.settings.BAG_HEADER_NAME0 or BACKPACK_TOOLTIP)
end

-- adjusts the ItemButton layout flow when the bag window size changes (or on open)
local function layoutBagItems(f)
    local max_col = f:GetParent().gw_bag_cols
    local col = 0
    local rev = GW.settings.BAG_REVERSE_SORT
    local sep = GW.settings.BAG_SEPARATE_BAGS
    local row = sep and 1 or 0
    local item_off = GW.settings.BAG_ITEM_SIZE + BAG_ITEM_PADDING
    local unfinishedRow = false
    local finishedRows = 0

    local iS = BACKPACK_CONTAINER
    local iE = NUM_TOTAL_EQUIPPED_BAG_SLOTS
    local iD = 1
    if rev then
        iE = iS
        iS = NUM_TOTAL_EQUIPPED_BAG_SLOTS
        iD = -1
    end
    f:GetParent().unfinishedRow = 0
    f:GetParent().finishedRow = 0

    local lcf = inv.layoutContainerFrame
    for i = iS, iE, iD do
        local bag_id = i
        local slotID, itemID
        local cf = f.Containers[bag_id]
        if sep then
            _G["GwBagFrameGwBagHeader" .. bag_id]:Show()
            _G["GwBagFrameGwBagHeader" .. bag_id]:ClearAllPoints()
            _G["GwBagFrameGwBagHeader" .. bag_id]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, (-row + 1) * item_off)
            _G["GwBagFrameGwBagHeader" .. bag_id]:SetWidth(GW.settings.BAG_WIDTH - BAG_ITEM_PADDING)
            _G["GwBagFrameGwBagHeader" .. bag_id].background:SetWidth(GW.settings.BAG_WIDTH - BAG_ITEM_PADDING)
        else
            _G["GwBagFrameGwBagHeader" .. bag_id] :Hide()
        end
        if sep and cf.shouldShow then
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

        if not rev and bag_id <= 3 then
            slotID = GetInventorySlotInfo("Bag" .. bag_id .. "Slot")
            itemID = GetInventoryItemID("player", slotID)
        elseif rev and bag_id <= 4 and bag_id > 0 then
            slotID = GetInventorySlotInfo("Bag" .. bag_id - 1 .. "Slot")
            itemID = GetInventoryItemID("player", slotID)
        end

        if (sep and (bag_id == 0 or bag_id >= 4)) or (sep and itemID) then
            if col ~= 0 then
                row = row + 2
                col = 0
            else
                row = row + 1
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
    local currencyCount = C_CurrencyInfo.GetCurrencyListSize()
    for i = 1, currencyCount do
        local info = C_CurrencyInfo.GetCurrencyListInfo(i)
        if not info.isHeader and info.isShowInBackpack and watchSlot <= 4 then
            self["currency" .. tostring(watchSlot)]:SetText(CommaValue(info.quantity))
            self["currency" .. tostring(watchSlot) .. "Texture"]:SetTexture(info.iconFileID)
            self["currency" .. tostring(watchSlot) .. "Frame"].CurrencyIdx = i
            watchSlot = watchSlot + 1
        end
    end

    for i = watchSlot, 4 do
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
    inv.updateFreeSlots(GwBagFrame.spaceString, 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS, BACKPACK_CONTAINER)
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
    for bag_id = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        inv.takeItemButtons(f.ItemFrame, bag_id)
    end
    updateBagContainers(f)
end
GW.AddForProfiling("bag", "rescanBagContainers", rescanBagContainers)

-- draws the backpack bag slots in the correct order
local function setBagBarOrder(f)
    local x = -40
    local y
    local bag_size = 28
    local bag_padding = 4
    local rev = GW.settings.BAG_REVERSE_SORT

    f.setBagBarOrderInProgress = true
    if rev then
        y = NUM_TOTAL_EQUIPPED_BAG_SLOTS - ((bag_size + bag_padding) * NUM_TOTAL_EQUIPPED_BAG_SLOTS)
    else
        y = NUM_TOTAL_EQUIPPED_BAG_SLOTS
    end

    for bag_idx = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        local b = f.bags[bag_idx]
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", f, "TOPLEFT", x, y)
        if rev then
            y = y + bag_size + bag_padding
        else
            y = y - bag_size - bag_padding
        end
    end

    f.setBagBarOrderInProgress = false
end
GW.AddForProfiling("bag", "setBagBarOrder", setBagBarOrder)

local function bag_OnClick(self, button)
    -- on left click, ensure that the bag stays open despite default toggle behavior
    if button == "LeftButton" then
        local id = self:GetID();
        local hadItem = PutItemInBag(id)
        if not hadItem and self.gwHasBag and not IsBagOpen(self:GetBagID()) then
            OpenBag(self:GetBagID()) --taint atm
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
    bp:HookScript("OnMouseDown", inv.bag_OnMouseDown)
    bp.gwBackdrop = true -- checked by some things to see if this is a reskinned button
    f.bags[BACKPACK_CONTAINER] = bp
    hooksecurefunc(MainMenuBarBackpackButton,
        "UpdateFreeSlots",
        function()
            bp.Count:SetText(bp.freeSlots)
        end
    )
    SetItemButtonQuality(bp, 1, nil)

    -- create bag slot buttons for equippable bags
    local cb0_id = CharacterBag0Slot:GetID()
    local getInvId = function(self)
        local inv_id, _ = GetInventorySlotInfo(strsub(self:GetName(), 10))
        return inv_id
    end
    for bag_idx = 1, NUM_BAG_SLOTS do
        -- this name MUST have a 9-letter prefix and match the style "CharacterBag0Slot"
        -- because of hard-coded string parsing in PaperDollItemSlotButton_OnLoad
        --local name = "GwInvntryBag" .. (bag_idx - 1) .. "Slot"
        --local b = CreateFrame("ItemButton", name, f, "GwBackpackBagTemplate")
        --b.commandName = ""

        -- We depend on a number of behaviors from the default BagSlotButtonTemplate.
        -- The ID set here is NOT the usual bag_id; rather it is an offset from the
        -- id of CharacterBag0Slot, used internally by BagSlotButtonTemplate methods.
        --b:SetID(cb0_id + bag_idx - 1)
        --b.BagID = bag_idx
        -- unlike BankItemButtonBagTemplate, we must provide the GetInventorySlot method
        --b.GetInventorySlot = getInvId

        -- remove default of capturing right-click also (we handle right-click separately)

        --TEST
        local b = _G["CharacterBag" .. bag_idx - 1 .. "Slot"]
        b:SetParent(f)
        b:RegisterForClicks("LeftButtonUp")
        b:SetScript("OnClick", bag_OnClick)
        b:SetScript("OnMouseDown", inv.bag_OnMouseDown)

        inv.reskinBagBar(b)

        -- Hide default bag bar
        --_G["CharacterBag" .. bag_idx - 1 .. "Slot"]:GwKill()
        --_G["CharacterBag" .. bag_idx - 1 .. "Slot"]:SetScale(0.0001)
       -- _G["CharacterBag" .. bag_idx - 1 .. "Slot"]:SetAlpha(0)

        f.bags[bag_idx] = b
    end

    --Get Reagant Slot
    if CharacterReagentBag0Slot then
        --local name = "GwInvntryReagentBag0Slot"
        --local b = CreateFrame("ItemButton", name, f, "GwBackpackBagTemplate")
        --b.commandName = ""

        -- We depend on a number of behaviors from the default BagSlotButtonTemplate.
        -- The ID set here is NOT the usual bag_id; rather it is an offset from the
        -- id of CharacterBag0Slot, used internally by BagSlotButtonTemplate methods.
        --b:SetID(cb0_id + 5 - 1)
        --b.BagID = 5
        -- unlike BankItemButtonBagTemplate, we must provide the GetInventorySlot method
        --b.GetInventorySlot = getInvId

        -- remove default of capturing right-click also (we handle right-click separately)
        --TEST
        local b = CharacterReagentBag0Slot
        b:SetParent(f)
        b:RegisterForClicks("LeftButtonUp")
        b:SetScript("OnClick", bag_OnClick)
        b:SetScript("OnMouseDown", inv.bag_OnMouseDown)

        inv.reskinBagBar(b)

        f.bags[NUM_BAG_SLOTS + 1] = b
    end

    setBagBarOrder(f)
    hooksecurefunc(CharacterReagentBag0Slot, "SetPoint", function()
        if not f.setBagBarOrderInProgress then
            setBagBarOrder(f)
        end
    end)
end
GW.AddForProfiling("bag", "createBagBar", createBagBar)

-- updates the contents of the backpack bag slots
local function updateBagBar(f)
    for bag_idx = 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        local b = f.bags[bag_idx]
        local inv_id = C_Container.ContainerIDToInventoryID(bag_idx) --b:GetInventorySlot()
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
    end
end
GW.AddForProfiling("bag", "updateBagBar", updateBagBar)

local function onBagResizeStop(self)
    GW.settings.BAG_WIDTH = self:GetWidth()
    inv.onMoved(self, "BAG_POSITION", snapFrameSize)
end
GW.AddForProfiling("bag", "onBagResizeStop", onBagResizeStop)

local function onBagFrameChangeSize(self, _, _, skip)
    local cols = inv.colCount(GW.settings.BAG_ITEM_SIZE, BAG_ITEM_PADDING, self:GetWidth())

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
    self:RegisterEvent("CVAR_UPDATE")
    if not IsBagOpen(BACKPACK_CONTAINER) then
        OpenBackpack() --TODO: taint atm
    end
    for i = 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        if not IsBagOpen(i) then
            OpenBag(i) --TODO: taint atm
        end
    end

    updateBagBar(self.ItemFrame)
    rescanBagContainers(self)
    inv.reskinItemButtons()
end
GW.AddForProfiling("bag", "bag_OnShow", bag_OnShow)

local function bag_OnHide(self)
    PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
    self:UnregisterAllEvents()
    for i = 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        if IsBagOpen(i) then
            CloseBag(i)
        end
    end
    if IsBagOpen(BACKPACK_CONTAINER) then
        CloseBackpack()
    end
    if self.buttonSettings.dropdown:IsShown() then
        self.buttonSettings.dropdown:Hide()
    end
end
GW.AddForProfiling("bag", "bag_OnHide", bag_OnHide)

local function bag_OnEvent(self, event, ...)
    if event == "ITEM_LOCKED" or event == "ITEM_UNLOCKED" then
        -- check if the item un/locked is a character bag and gray it out if so
        local bag = select(1, ...)
        local slot = select(2, ...)
        local cb0_id = CharacterBag0Slot:GetID()

        if slot == nil and bag >= cb0_id and bag <= cb0_id + NUM_TOTAL_EQUIPPED_BAG_SLOTS then
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
        if bag_id <= NUM_TOTAL_EQUIPPED_BAG_SLOTS and bag_id >= BACKPACK_CONTAINER then
            self.gw_need_bag_update = true
        end
    elseif event == "BAG_UPDATE_DELAYED" then
        if self.gw_need_bag_rescan then
            for bag_id = 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
                if not IsBagOpen(bag_id) then
                    OpenBag(bag_id) --TODO: taint atm
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
    elseif event == "CVAR_UPDATE" then
        local cvarName, cvarValue = ...
        if cvarName == "combinedBags" and cvarValue == "1" then
            SetCVar("combinedBags", "0")
        end
    end
end
GW.AddForProfiling("bag", "bag_OnEvent", bag_OnEvent)

local function bagHeader_OnClick(self, btn)
    local bag_id = string.sub(self:GetName(), -1)
    if btn == "LeftButton" then
        if self.icon:IsShown() then
            -- collaps
            self:GetParent().ItemFrame.Containers[tonumber(bag_id)].shouldShow = false
        else
            -- expand
            self:GetParent().ItemFrame.Containers[tonumber(bag_id)].shouldShow = true
        end
        self.icon:SetShown(not self.icon:IsShown())
        self.icon2:SetShown(not self.icon:IsShown())

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
    ContainerFrameCombinedBags:SetScript("OnShow", nil)
    ContainerFrameCombinedBags:SetScript("OnHide", nil)
    ContainerFrameCombinedBags:SetParent(GW.HiddenFrame)
    ContainerFrameCombinedBags:ClearAllPoints()
    ContainerFrameCombinedBags:SetPoint("BOTTOM")
    SetCVar("combinedBags", 0)

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
    onBagFrameChangeSize(f, nil, nil, true)
    f:SetClampedToScreen(true)

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
    f:SetResizeBounds(340, 340)
    f:SetScript("OnSizeChanged", onBagFrameChangeSize)
    f.sizer.onResizeStop = onBagResizeStop
    f.sizer:SetScript("OnMouseDown", inv.onSizerMouseDown)
    f.sizer:SetScript("OnMouseUp", inv.onSizerMouseUp)

    -- setup bagheader stuff
    for i = 0, 5 do
        _G["GwBagFrameGwBagHeader" .. i].nameString:SetFont(UNIT_NAME_FONT, 12, "")
        _G["GwBagFrameGwBagHeader" .. i].nameString:SetTextColor(1, 1, 1)
        _G["GwBagFrameGwBagHeader" .. i].nameString:SetShadowColor(0, 0, 0, 0)
        _G["GwBagFrameGwBagHeader" .. i].icon2:Hide()
        _G["GwBagFrameGwBagHeader" .. i]:SetScript("OnClick", bagHeader_OnClick)
        _G["GwBagFrameGwBagHeader" .. i]:SetScript("OnClick", bagHeader_OnClick)
        _G["GwBagFrameGwBagHeader" .. i]:SetScript("OnEnter", bagHeader_OnEnter)
        _G["GwBagFrameGwBagHeader" .. i]:SetScript("OnLeave", GameTooltip_Hide)
    end

    -- take the original search box
    inv.reskinSearchBox(BagItemSearchBox)
    hooksecurefunc(ContainerFrame1,
        "UpdateSearchBox",
        function()
            inv.relocateSearchBox(BagItemSearchBox, f)
        end
    )
    inv.relocateSearchBox(BagItemSearchBox, f)

    -- when we take ownership of ItemButtons, we need parent containers with IDs
    -- set to the ID (bagId) of the original ContainerFrame we stole it from, in order
    -- for all of the inherited ItemButton functionality to work normally
    f.ItemFrame.Containers = {}
    for bag_id = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        local cf = CreateFrame("Frame", nil, f.ItemFrame)
        cf.gw_items = {}
        cf.gw_num_slots = 0
        cf:SetAllPoints(f.ItemFrame)
        cf:SetID(bag_id)
        --cf.BagID = bag_id
        cf.shouldShow = true
        cf.IsCombinedBagContainer = function() return true end
        f.ItemFrame.Containers[bag_id] = cf
    end

    -- anytime a ContainerFrame is populated with a backpack bagId, we take its buttons
    hooksecurefunc("ContainerFrame_GenerateFrame", function(frame, _, id)
        if id >= BACKPACK_CONTAINER and id <= NUM_BAG_SLOTS then
            --rescanBagContainers(f) -- Testing if this is causing the delay
            if frame.ExtraBagSlotsHelpBox then
                local h = frame.ExtraBagSlotsHelpBox
                h:ClearAllPoints()
                h:SetPoint("RIGHT", f, "TOPLEFT", -60, -90)
            end
        end
    end)

    -- create our backpack bag slots
    createBagBar(f.ItemFrame)

    -- skin some things not done in XML
    f.headerString:SetFont(DAMAGE_TEXT_FONT, 20, "")
    f.headerString:SetText(INVENTORY_TOOLTIP)
    f.spaceString:SetFont(UNIT_NAME_FONT, 12, "")
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
    local bindings = {"TOGGLEBACKPACK", "TOGGLEREAGENTBAG1", "TOGGLEBAG1", "TOGGLEBAG2", "TOGGLEBAG3", "TOGGLEBAG4"}
    for _, b in pairs(bindings) do
        local key = GetBindingKey(b)
        if key then
            SetOverrideBinding(f, true, key, "OPENALLBAGS")
            SetOverrideBinding(f, false, key, "OPENALLBAGS")
        end
    end

    -- setup settings button and its dropdown items
    f.buttonSort:HookScript(
        "OnClick",
        function()
            PlaySound(SOUNDKIT.UI_BAG_SORTING_01)
            C_Container.SortBags()
        end
    )
    EnableTooltip(f.buttonSort, BAG_CLEANUP_BAGS)
    do
        EnableTooltip(f.buttonSettings, BAG_SETTINGS_TOOLTIP)
        local dd = f.buttonSettings.dropdown
        dd:GwCreateBackdrop(GW.BackdropTemplates.Default)
        f.buttonSettings:HookScript(
            "OnClick",
            function(self)
                if dd:IsShown() then
                    dd:Hide()
                else
                    -- check if the dropdown need to grow up or down
                    local _, y = self:GetCenter()
                    local screenHeight = UIParent:GetTop()
                    local position
                    if y > (screenHeight / 2) then
                        position = "TOPRIGHT"
                    else
                        position = "BOTTOMRIGHT"
                    end
                    dd:ClearAllPoints()
                    dd:SetPoint(position, dd:GetParent(), "LEFT", 0, -5)
                    dd:Show()
                end
            end
        )

        dd.compactBags.checkbutton:HookScript(
            "OnClick",
            function(self)
                self:SetChecked(compactToggle())
                dd:Hide()
            end
        )

        dd.newOrder.checkbutton:HookScript(
            "OnClick",
            function()
                -- FOR TAINT testing
                --local newStatus = not GW.settings.BAG_REVERSE_NEW_LOOT
                --C_Container.SetInsertItemsLeftToRight(newStatus)
                --dd.newOrder.checkbutton:SetChecked(newStatus)
                --GW.settings.BAG_REVERSE_NEW_LOOT = newStatus
                --GW.
                dd:Hide()
            end
        )
        -- set it back to default, only once
        if not GW.settings.Reset_Container_Loot_Order then
            C_Container.SetInsertItemsLeftToRight(false)
            GW.settings.Reset_Container_Loot_Order = true
        end

        dd.sortOrder.checkbutton:HookScript(
            "OnClick",
            function()
                local newStatus = not GW.settings.BAG_ITEMS_REVERSE_SORT
                C_Container.SetSortBagsRightToLeft(newStatus)
                dd.sortOrder.checkbutton:SetChecked(newStatus)
                GW.settings.BAG_ITEMS_REVERSE_SORT = newStatus
                dd:Hide()
            end
        )

        dd.bagOrder.checkbutton:HookScript(
            "OnClick",
            function()
                local newStatus = not GW.settings.BAG_REVERSE_SORT
                dd.bagOrder.checkbutton:SetChecked(newStatus)
                GW.settings.BAG_REVERSE_SORT = newStatus
                layoutItems(f)
                snapFrameSize(f)
            end
        )

        dd.itemBorder.checkbutton:HookScript(
            "OnClick",
            function()
                local newStatus = not GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW
                dd.itemBorder.checkbutton:SetChecked(newStatus)
                GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW = newStatus
                ContainerFrame_UpdateAll() -- this is tainting
            end
        )

        dd.junkIcon.checkbutton:HookScript(
            "OnClick",
            function()
                local newStatus = not GW.settings.BAG_ITEM_JUNK_ICON_SHOW
                dd.junkIcon.checkbutton:SetChecked(newStatus)
                GW.settings.BAG_ITEM_JUNK_ICON_SHOW = newStatus
                ContainerFrame_UpdateAll()  --this is tainting
            end
        )

        dd.scrapIcon.checkbutton:HookScript(
            "OnClick",
            function()
                local newStatus = not GW.settings.BAG_ITEM_SCRAP_ICON_SHOW
                dd.scrapIcon.checkbutton:SetChecked(newStatus)
                GW.settings.BAG_ITEM_SCRAP_ICON_SHOW = newStatus
                ContainerFrame_UpdateAll() -- this is tainting
            end
        )

        dd.upgradeIcon.checkbutton:HookScript(
            "OnClick",
            function()
                local newStatus = not GW.settings.BAG_ITEM_UPGRADE_ICON_SHOW
                dd.upgradeIcon.checkbutton:SetChecked(newStatus)
                GW.settings.BAG_ITEM_UPGRADE_ICON_SHOW = newStatus
                ContainerFrame_UpdateAll()  --this is tainting
            end
        )

        dd.professionColor.checkbutton:HookScript(
            "OnClick",
            function()
                local newStatus = not GW.settings.BAG_PROFESSION_BAG_COLOR
                dd.professionColor.checkbutton:SetChecked(newStatus)
                GW.settings.BAG_PROFESSION_BAG_COLOR = newStatus
                ContainerFrame_UpdateAll() --this is tainting
            end
        )

        dd.vendorGrays.checkbutton:HookScript(
            "OnClick",
            function()
                local newStatus = not GW.settings.BAG_VENDOR_GRAYS
                dd.vendorGrays.checkbutton:SetChecked(newStatus)
                GW.settings.BAG_VENDOR_GRAYS = newStatus
                GW.SetupVendorJunk(newStatus)
            end
        )

        dd.showItemLvl.checkbutton:HookScript(
            "OnClick",
            function()
                local newStatus = not GW.settings.BAG_SHOW_ILVL
                dd.showItemLvl.checkbutton:SetChecked(newStatus)
                GW.settings.BAG_SHOW_ILVL = newStatus
                ContainerFrame_UpdateAll() --this is tainting
            end
        )

        dd.separateBags.checkbutton:HookScript(
            "OnClick",
            function()
                local newStatus = not GW.settings.BAG_SEPARATE_BAGS
                dd.separateBags.checkbutton:SetChecked(newStatus)
                GW.settings.BAG_SEPARATE_BAGS = newStatus
                layoutItems(f)
                snapFrameSize(f)
                dd:Hide()
            end
        )

        dd.compactBags.checkbutton:SetChecked(GW.settings.BAG_ITEM_SIZE == BAG_ITEM_COMPACT_SIZE)
        dd.newOrder.checkbutton:SetChecked(GW.settings.BAG_REVERSE_NEW_LOOT)
        dd.sortOrder.checkbutton:SetChecked(GW.settings.BAG_ITEMS_REVERSE_SORT)
        dd.bagOrder.checkbutton:SetChecked(GW.settings.BAG_REVERSE_SORT)
        dd.itemBorder.checkbutton:SetChecked(GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW)
        dd.junkIcon.checkbutton:SetChecked(GW.settings.BAG_ITEM_JUNK_ICON_SHOW)
        dd.scrapIcon.checkbutton:SetChecked(GW.settings.BAG_ITEM_SCRAP_ICON_SHOW)
        dd.upgradeIcon.checkbutton:SetChecked(GW.settings.BAG_ITEM_UPGRADE_ICON_SHOW)
        dd.professionColor.checkbutton:SetChecked(GW.settings.BAG_PROFESSION_BAG_COLOR)
        dd.vendorGrays.checkbutton:SetChecked(GW.settings.BAG_VENDOR_GRAYS)
        dd.showItemLvl.checkbutton:SetChecked(GW.settings.BAG_SHOW_ILVL)
        dd.separateBags.checkbutton:SetChecked(GW.settings.BAG_SEPARATE_BAGS)

        GW.SetupVendorJunk(dd.vendorGrays.checkbutton:GetChecked())

        -- setup bag setting title locals
        dd.compactBags.title:SetText(L["Compact Icons"])
        dd.newOrder.title:SetText(L["Loot to leftmost Bag"])
        dd.sortOrder.title:SetText(L["Sort to Last Bag"])
        dd.itemBorder.title:SetText(L["Show Quality Color"])
        dd.junkIcon.title:SetText(L["Show Junk Icon"])
        dd.scrapIcon.title:SetText(L["Show Scrap Icon"])
        dd.upgradeIcon.title:SetText(L["Show Upgrade Icon"])
        dd.bagOrder.title:SetText(L["Reverse Bag Order"])
        dd.professionColor.title:SetText(L["Show Profession Bag Coloring"])
        dd.vendorGrays.title:SetText(L["Sell junk automatically"])
        dd.showItemLvl.title:SetText(SHOW_ITEM_LEVEL)
        dd.separateBags.title:SetText(L["Separate bags"])
    end

    -- setup money frame
    f.bronze:SetFont(UNIT_NAME_FONT, 12, "")
    f.bronze:SetTextColor(177 / 255, 97 / 255, 34 / 255)
    f.silver:SetFont(UNIT_NAME_FONT, 12, "")
    f.silver:SetTextColor(170 / 255, 170 / 255, 170 / 255)
    f.gold:SetFont(UNIT_NAME_FONT, 12, "")
    f.gold:SetTextColor(221 / 255, 187 / 255, 68 / 255)

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
    f.currency1:SetFont(UNIT_NAME_FONT, 12, "")
    f.currency1:SetTextColor(1, 1, 1)
    f.currency2:SetFont(UNIT_NAME_FONT, 12, "")
    f.currency2:SetTextColor(1, 1, 1)
    f.currency3:SetFont(UNIT_NAME_FONT, 12, "")
    f.currency3:SetTextColor(1, 1, 1)
    f.currency4:SetFont(UNIT_NAME_FONT, 12, "")
    f.currency4:SetTextColor(1, 1, 1)

    -- set warch currencies tooltips
    f.currency1Frame:SetScript("OnEnter", function(self)
        if not self.CurrencyIdx then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()
        GameTooltip:SetCurrencyToken(self.CurrencyIdx)
        GameTooltip:Show()
    end)
    f.currency2Frame:SetScript("OnEnter", function(self)
        if not self.CurrencyIdx then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()
        GameTooltip:SetCurrencyToken(self.CurrencyIdx)
        GameTooltip:Show()
    end)
    f.currency3Frame:SetScript("OnEnter", function(self)
        if not self.CurrencyIdx then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()
        GameTooltip:SetCurrencyToken(self.CurrencyIdx)
        GameTooltip:Show()
    end)
    f.currency4Frame:SetScript("OnEnter", function(self)
        if not self.CurrencyIdx then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()
        GameTooltip:SetCurrencyToken(self.CurrencyIdx)
        GameTooltip:Show()
    end)

    f.currency:SetScript("OnEvent", function(self)
        if GW.inWorld then
            watchCurrency(self:GetParent())
        end
    end)
    f.currency:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    hooksecurefunc(
        C_CurrencyInfo, "SetCurrencyBackpack",
        function()
            watchCurrency(f)
        end
    )
    watchCurrency(f)

    -- return a callback that should be called when item size changes
    local changeItemSize = function()
        layoutItems(f)
        snapFrameSize(f)
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
    smsj.text:SetText(L["Selling junk"])

    f.smsj = smsj

    return changeItemSize
end
GW.LoadBag = LoadBag
