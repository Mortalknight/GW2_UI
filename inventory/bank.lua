local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local EnableTooltip = GW.EnableTooltip
local inv

local BANK_ITEM_SIZE = 40
local BANK_ITEM_LARGE_SIZE = 40
local BANK_ITEM_COMPACT_SIZE = 32
local BANK_ITEM_PADDING = 5
local BANK_WINDOW_SIZE = 720

-- adjusts the ItemButton layout flow when the bank window size changes (or on open)
local function layoutBankItems(f)
    local max_col = f:GetParent().gw_bank_cols
    local row = 0
    local col = 0
    local rev = GetSetting("BANK_REVERSE_SORT")

    local item_off = BANK_ITEM_SIZE + BANK_ITEM_PADDING

    local iS = NUM_BAG_SLOTS
    local iE = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
    local iD = 1
    if rev then
        iS = iE
        iE = NUM_BAG_SLOTS
        iD = -1
    end

    local lcf = inv.layoutContainerFrame
    for i = iS, iE, iD do
        local bag_id = i
        if bag_id == NUM_BAG_SLOTS then
            bag_id = BANK_CONTAINER
        end
        local cf = f.Containers[bag_id]
        col, row = lcf(cf, max_col, row, col, (bag_id == BANK_CONTAINER), item_off)
    end
end
GW.AddForProfiling("bank", "layoutBankItems", layoutBankItems)

-- adjusts the ItemButton layout flow when the bank window size changes (or on open)
local function layoutItems(f)
    if f.ItemFrame:IsShown() then
        layoutBankItems(f.ItemFrame)
    elseif f.ReagentFrame:IsShown() and IsReagentBankUnlocked() then
        layoutReagentItems(f.ReagentFrame)
    end
end
GW.AddForProfiling("bank", "layoutItems", layoutItems)

-- adjusts the bank frame size to snap to the exact row/col sizing of contents
local function snapFrameSize(f)
    local cfs
    if f.ItemFrame:IsShown() then
        cfs = f.ItemFrame.Containers
    end
    inv.snapFrameSize(f, cfs, BANK_ITEM_SIZE, BANK_ITEM_PADDING, 370)
end
GW.AddForProfiling("bank", "snapFrameSize", snapFrameSize)

-- update the number of free bank slots available and set the display for it
local function updateFreeBankSlots(self)
    local free, _ = inv.updateFreeSlots(GwBankFrame.spaceString, NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS, BANK_CONTAINER)
    local b = self.bags[0]
    if b then
        SetItemButtonCount(b, free)
        b.tooltipAddLine = string.format(NUM_FREE_SLOTS, free)
    end
end
GW.AddForProfiling("bank", "updateFreeBankSlots", updateFreeBankSlots)

-- update all bank items and bank bags
local function updateBankContainers(f)
    if not f.gw_took_bank then
        inv.takeItemButtons(f.ItemFrame, BANK_CONTAINER)
        f.gw_took_bank = true
    end
    if f:IsShown() then
        if f.ItemFrame:IsShown() then
            updateFreeBankSlots(f.ItemFrame)
        end
        layoutItems(f)
        snapFrameSize(f)
    end
end
GW.AddForProfiling("bank", "updateBankContainers", updateBankContainers)

-- rescan ALL bank ItemButtons
local function rescanBankContainers(f)
    for bag_id = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
        inv.takeItemButtons(f.ItemFrame, bag_id)
    end
    updateBankContainers(f)
end
GW.AddForProfiling("bank", "rescanBankContainers", rescanBankContainers)

-- draws the bank bag slots in the correct order
local function setBagBarOrder(f)
    local x, y = -40, nil
    local bag_size = 28
    local bag_padding = 4
    local rev = GetSetting("BANK_REVERSE_SORT")
    if rev then
        y = 5 - ((bag_size + bag_padding) * NUM_BANKBAGSLOTS)
    else
        y = 5
    end

    for bag_idx = 0, NUM_BANKBAGSLOTS do --TOFO = 0
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
GW.AddForProfiling("bank", "setBagBarOrder", setBagBarOrder)

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
            StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
        end
    end
end
GW.AddForProfiling("bank", "bag_OnClick", bag_OnClick)

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
GW.AddForProfiling("bank", "createBagBar", createBagBar)

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
            GW.SetItemButtonQualityForBags(b, select(3, GetItemInfo(bagLink)))
        else
            GW.SetItemButtonQualityForBags(b, 1)
        end

        b.icon:Show()
        b.gwHasBag = false -- flag used by OnClick hook to pop up context menu when valid
        local norm = b:GetNormalTexture()
        norm:SetVertexColor(1, 1, 1, 0.75)
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
                b.icon:SetTexture("Interface/AddOns/GW2_UI/textures/talents/pvp_empty_icon")
                b.icon:SetTexCoord(0.2, 0.8, 0.2, 0.8)
            else
                b.tooltipText = GUILDBANK_TAB_LOCKED
                b.icon:SetTexture("Interface/AddOns/GW2_UI/textures/talents/lock")
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
GW.AddForProfiling("bank", "updateBagBar", updateBagBar)

local function onBankResizeStop(self)
    BANK_WINDOW_SIZE = self:GetWidth()
    SetSetting("BANK_WIDTH", BANK_WINDOW_SIZE)
    inv.onMoved(self, "BANK_POSITION", snapFrameSize)
end
GW.AddForProfiling("bank", "onBankResizeStop", onBankResizeStop)

local function onBankFrameChangeSize(self, _, _, skip)
    local cols = inv.colCount(BANK_ITEM_SIZE, BANK_ITEM_PADDING, self:GetWidth())

    if not self.gw_bank_cols or self.gw_bank_cols ~= cols then
        self.gw_bank_cols = cols
        if not skip then
            layoutItems(self)
        end
    end
end
GW.AddForProfiling("bank", "onBankFrameChangeSize", onBankFrameChangeSize)

-- toggles the setting for compact/large icons
local function compactToggle()
    if BANK_ITEM_SIZE == BANK_ITEM_LARGE_SIZE then
        BANK_ITEM_SIZE = BANK_ITEM_COMPACT_SIZE
        SetSetting("BAG_ITEM_SIZE", BANK_ITEM_SIZE)
        inv.resizeInventory()
        return true
    end

    BANK_ITEM_SIZE = BANK_ITEM_LARGE_SIZE
    SetSetting("BAG_ITEM_SIZE", BANK_ITEM_SIZE)
    inv.resizeInventory()
    return false
end
GW.AddForProfiling("bank", "compactToggle", compactToggle)

-- reskin all the base BankFrame ItemButtons
local function reskinBankItemButtons()
    local items = GetContainerNumSlots(BANK_CONTAINER)
    for i = 1, items do
        local iname = "BankFrameItem" .. i
        local b = _G[iname]
        if b then
            inv.reskinItemButton(iname, b)
        end
    end
end
GW.AddForProfiling("bank", "reskinBankItemButtons", reskinBankItemButtons)

local function bank_OnShow(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
    self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
    self:RegisterEvent("ITEM_LOCKED")
    self:RegisterEvent("ITEM_UNLOCKED")
    self:RegisterEvent("BAG_UPDATE")

    -- hide the bank frame off screen
    BankFrame:ClearAllPoints()
    BankFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -2000, 2000)
    BankSlotsFrame:Hide()

    OpenAllBags(self)
    updateBagBar(self.ItemFrame)
    updateBankContainers(self)
end
GW.AddForProfiling("bank", "bank_OnShow", bank_OnShow)

local function bank_OnHide(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    self:UnregisterAllEvents()
    self:RegisterEvent("BANKFRAME_OPENED")
    self:RegisterEvent("BANKFRAME_CLOSED")
    CloseBankFrame()
end
GW.AddForProfiling("bank", "bank_OnHide", bank_OnHide)

local function bank_OnEvent(self, event, ...)
    if event == "BANKFRAME_OPENED" then
        self:Show()
    elseif event == "BANKFRAME_CLOSED" then
        self:Hide()
    elseif event == "PLAYERBANKSLOTS_CHANGED" then
        local slot = select(1, ...)
        if slot > NUM_BANKGENERIC_SLOTS then
            -- a bank bag was un/equipped
            for bag_id = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
                if not IsBagOpen(bag_id) then
                    OpenBag(bag_id)
                end
            end
            updateBagBar(self.ItemFrame)
            rescanBankContainers(self)
        else
            -- an item was added to or removed from the base bank
            if self.ItemFrame:IsShown() then
                updateFreeBankSlots(self.ItemFrame)
            end
        end
    elseif event == "PLAYERBANKBAGSLOTS_CHANGED" then
        -- the # of bank bag slots has changed
        updateBagBar(self.ItemFrame)
    elseif event == "ITEM_LOCKED" or event == "ITEM_UNLOCKED" then
        -- check if the item un/locked is a bank bag and gray it out if so
        local bag = select(1, ...)
        local slot = select(2, ...)
        if bag == BANK_CONTAINER and slot > NUM_BANKGENERIC_SLOTS then
            local bag_id = slot - NUM_BANKGENERIC_SLOTS
            local b = self.ItemFrame.bags[bag_id]
            if b and b.icon and b.icon.SetDesaturated then
                if event == "ITEM_LOCKED" then
                    b.icon:SetDesaturated(true)
                else
                    b.icon:SetDesaturated(false)
                end
            end
        end
    elseif event == "BAG_UPDATE" then
        local bag_id = select(1, ...)
        if bag_id == BANK_CONTAINER or bag_id > NUM_BAG_SLOTS then
            if self.ItemFrame:IsShown() then
                updateFreeBankSlots(self.ItemFrame)
            end
        end
    end
end
GW.AddForProfiling("bank", "bank_OnEvent", bank_OnEvent)

local function LoadBank(helpers)
    inv = helpers

    BANK_WINDOW_SIZE = GetSetting("BANK_WIDTH")
    BANK_ITEM_SIZE = GetSetting("BAG_ITEM_SIZE")
    if BANK_ITEM_SIZE > 40 then
        BANK_ITEM_SIZE = 40
        SetSetting("BAG_ITEM_SIZE", 40)
    end

    -- create bank frame, restore its saved size, and init its many pieces
    local f = CreateFrame("Frame", "GwBankFrame", UIParent, "GwBankFrameTemplate")
    tinsert(UISpecialFrames, "GwBankFrame")
    f:ClearAllPoints()
    f:SetWidth(BANK_WINDOW_SIZE)
    onBankFrameChangeSize(f, nil, nil, true)

    -- setup show/hide
    f:SetScript("OnShow", bank_OnShow)
    f:SetScript("OnHide", bank_OnHide)
    f.buttonClose:SetScript("OnClick", GW.Parent_Hide)

    -- re-hide the BankFrame any time it gets repositioned by UIParent stuff
    hooksecurefunc(BankFrame, "Raise", function()
        BankFrame:ClearAllPoints()
        BankFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -2000, 2000)
        BankSlotsFrame:Hide()
    end)

    -- setup movable stuff
    local pos = GetSetting("BANK_POSITION")
    f:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    f.mover:RegisterForDrag("LeftButton")
    f.mover.onMoveSetting = "BANK_POSITION"
    f.mover:SetScript("OnDragStart", inv.onMoverDragStart)
    f.mover:SetScript("OnDragStop", inv.onMoverDragStop)

    -- setup resizer stuff
    f:SetMinResize(508, 340)
    f:SetScript("OnSizeChanged", onBankFrameChangeSize)
    f.sizer.onResizeStop = onBankResizeStop
    f.sizer:SetScript("OnMouseDown", inv.onSizerMouseDown)
    f.sizer:SetScript("OnMouseUp", inv.onSizerMouseUp)

    -- reskin all the BankFrame ItemButtons
    reskinBankItemButtons()

    -- take the original search box
    local BankItemSearchBox = CreateFrame("EditBox", "BankItemSearchBox", f, "BagSearchBoxTemplate")
    inv.reskinSearchBox(BankItemSearchBox)
    inv.relocateSearchBox(BankItemSearchBox, f)

    -- when we take ownership of ItemButtons, we need parent containers with IDs
    -- set to the ID (bagId) of the original ContainerFrame we stole it from, in order
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
        f.ItemFrame.Containers[bag_id] = cf
    end

    -- anytime a ContainerFrame is populated with a bank bagId, we take its buttons
    hooksecurefunc("ContainerFrame_GenerateFrame", function(_, _, id)
        if id > NUM_BAG_SLOTS and id <= NUM_BAG_SLOTS + NUM_BANKBAGSLOTS then
            rescanBankContainers(f)
        end
    end)

    -- don't let anyone close bank bags while the bank is open
    hooksecurefunc("ToggleAllBags", function()
        if GwBankFrame:IsShown() then
            for i = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
                if not IsBagOpen(i) then
                    OpenBag(i)
                end
            end
        end
    end)
    hooksecurefunc("ToggleBackpack", function()
        if GwBankFrame:IsShown() then
            for i = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
                if not IsBagOpen(i) then
                    OpenBag(i)
                end
            end
        end
    end)

    -- create our bank bag slots
    createBagBar(f.ItemFrame)

    -- skin some things not done in XML
    f.headerString:SetFont(DAMAGE_TEXT_FONT, 20)
    f.headerString:SetText(BANK)
    f.spaceString:SetFont(UNIT_NAME_FONT, 12)
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
    do
        EnableTooltip(f.buttonSettings, BAG_SETTINGS_TOOLTIP)
        local dd = f.buttonSettings.dropdown
        dd:CreateBackdrop(GW.skins.constBackdropFrame)
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

        dd.compactBank.checkbutton:SetScript(
            "OnClick",
            function(self)
                self:SetChecked(compactToggle())
                dd:Hide()
            end
        )

        dd.bagOrder.checkbutton:SetScript(
            "OnClick",
            function()
                local newStatus = not GetSetting("BANK_REVERSE_SORT")
                dd.bagOrder.checkbutton:SetChecked(newStatus)
                SetSetting("BANK_REVERSE_SORT", newStatus)

                ContainerFrame_UpdateAll()
            end
        )

        dd.compactBank.checkbutton:SetChecked(GetSetting("BAG_ITEM_SIZE") == BANK_ITEM_COMPACT_SIZE)
        dd.bagOrder.checkbutton:SetChecked(GetSetting("BANK_REVERSE_SORT"))

        -- setup bag setting title locals
        dd.compactBank.title:SetText(L["Compact Icons"])
        dd.bagOrder.title:SetText(L["Reverse Bag Order"])
    end

    -- return a callback that should be called when item size changes
    local changeItemSize = function()
        BANK_ITEM_SIZE = GetSetting("BAG_ITEM_SIZE")
        reskinBankItemButtons()
        layoutItems(f)
        snapFrameSize(f)
    end
    return changeItemSize
end
GW.LoadBank = LoadBank