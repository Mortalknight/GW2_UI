local _, GW = ...
local L = GW.L
local EnableTooltip = GW.EnableTooltip
local inv

local BANK_ITEM_LARGE_SIZE = 40
local BANK_ITEM_COMPACT_SIZE = 32
local BANK_ITEM_PADDING = 5

local PURCHASE_TAB_ID = -1

local function fetchPurchasedBankTabData(f)
    f.accountBankPurchasedBankTabData = C_Bank.FetchPurchasedBankTabData(Enum.BankType.Account)
end

-- adjusts the ItemButton layout flow when the bank window size changes (or on open)
local function layoutBankItems(f)
    local max_col = f:GetParent().gw_bank_cols
    local row = 0
    local col = 0
    local rev = GW.settings.BANK_REVERSE_SORT

    local item_off = GW.settings.BAG_ITEM_SIZE  + BANK_ITEM_PADDING

    local iS = NUM_TOTAL_EQUIPPED_BAG_SLOTS
    local iE = NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS
    local iD = 1
    if rev then
        iS = iE
        iE = NUM_TOTAL_EQUIPPED_BAG_SLOTS
        iD = -1
    end

    local lcf = inv.layoutContainerFrame
    for i = iS, iE, iD do
        local bag_id = i
        if bag_id == NUM_TOTAL_EQUIPPED_BAG_SLOTS then
            bag_id = BANK_CONTAINER
        end
        local cf = f.Containers[bag_id]
        col, row = lcf(cf, max_col, row, col, (bag_id == BANK_CONTAINER), item_off)
    end
end
GW.AddForProfiling("bank", "layoutBankItems", layoutBankItems)

-- adjusts the ItemButton layout flow when the bank window size changes (or on open)
local function layoutReagentItems(f)
    local max_col = f:GetParent().gw_bank_cols
    local row = 0
    local col = 0

    local item_off = GW.settings.BAG_ITEM_SIZE + BANK_ITEM_PADDING

    local cf = f.Containers[REAGENTBANK_CONTAINER]
    inv.layoutContainerFrame(cf, max_col, row, col, true, item_off)
end
GW.AddForProfiling("bank", "layoutReagentItems", layoutReagentItems)

-- adjusts the ItemButton layout flow when the bank window size changes (or on open)
local function layoutAccountBankItems(f)
    local max_col = f:GetParent().gw_bank_cols
    local row = 0
    local col = 0

    local item_off = GW.settings.BAG_ITEM_SIZE + BANK_ITEM_PADDING

    local cf = f.Container
    inv.layoutContainerFrame(cf, max_col, row, col, false, item_off)
end
GW.AddForProfiling("bank", "layoutAccountBankItems", layoutAccountBankItems)

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
    elseif f.ReagentFrame:IsShown() and IsReagentBankUnlocked() then
        cfs = f.ReagentFrame.Containers
    elseif f.AccountFrame:IsShown() then
        cfs = f.AccountFrame.Container
    end
    inv.snapFrameSize(f, cfs, GW.settings.BAG_ITEM_SIZE, BANK_ITEM_PADDING, 370)
end
GW.AddForProfiling("bank", "snapFrameSize", snapFrameSize)

-- update the number of free bank slots available and set the display for it
local function updateFreeBankSlots(self)
    local free, _ = inv.updateFreeSlots(GwBankFrame.spaceString, NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS, BANK_CONTAINER)
    local b = self.bags[0]
    if b then
        SetItemButtonCount(b, free)
        b.tooltipAddLine = string.format(NUM_FREE_SLOTS, free)
    end
end
GW.AddForProfiling("bank", "updateFreeBankSlots", updateFreeBankSlots)

-- update the number of free reagent slots available and set the display for it
local function updateFreeReagentSlots()
    inv.updateFreeSlots(GwBankFrame.spaceString, REAGENTBANK_CONTAINER, REAGENTBANK_CONTAINER)
end
GW.AddForProfiling("bank", "updateFreeReagentSlots", updateFreeReagentSlots)

-- update all bank items and bank bags
local function updateBankContainers(f)
    if not f.gw_took_bank then
        inv.takeItemButtons(f.ItemFrame, BANK_CONTAINER)
        f.gw_took_bank = true
    end
    if not f.gw_took_reagents then
        inv.takeItemButtons(f.ReagentFrame, REAGENTBANK_CONTAINER)
        f.gw_took_reagents = true
    end
    if f:IsShown() then
        if f.ItemFrame:IsShown() then
            updateFreeBankSlots(f.ItemFrame)
        elseif f.ReagentFrame:IsShown() and IsReagentBankUnlocked() then
            updateFreeReagentSlots()
        end
        layoutItems(f)
        snapFrameSize(f)
    end
end
GW.AddForProfiling("bank", "updateBankContainers", updateBankContainers)

-- rescan ALL bank ItemButtons
local function rescanBankContainers(f)
    for bag_id = NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS do
        inv.takeItemButtons(f.ItemFrame, bag_id)
    end
    updateBankContainers(f)
end
GW.AddForProfiling("bank", "rescanBankContainers", rescanBankContainers)

-- draws the bank bag slots in the correct order
local function setBagBarOrder(f)
    local x = -40
    local y
    local bag_size = 28
    local bag_padding = 4
    local rev = GW.settings.BANK_REVERSE_SORT
    if rev then
        y = -80 - ((bag_size + bag_padding) * NUM_BANKBAGSLOTS)
    else
        y = -80
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
GW.AddForProfiling("bank", "setBagBarOrder", setBagBarOrder)

local function bag_OnClick(self, button)
    -- on left click, test if this is a purchase slot and do purchase confirm,
    -- otherwise ensure that the bag stays open despite default toggle behavior
    if button == "LeftButton" then
        if self.gwHasBag then
            if not IsBagOpen(self:GetBagID()) then
                OpenBag(self:GetBagID()) --taint atm
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
        return self:GetID() + NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES
    end

    for bag_idx = 1, NUM_BANKBAGSLOTS do
        local b = CreateFrame("ItemButton", nil, f, "GwBankBagTemplate")

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
    local b = CreateFrame("ItemButton", nil, f, "GwBankBaseBagTemplate")
    b:SetID(0)
    b.GetBagID = function()
        return BANK_CONTAINER
    end
    inv.reskinBagBar(b)
    local norm = b:GetNormalTexture()
    norm:SetVertexColor(1, 1, 1, 0.75)
    SetItemButtonQuality(b, 1, nil)
    EnableTooltip(b, BANK, "ANCHOR_RIGHT", 0)
    b.icon:SetTexture(413587)
    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b:RegisterForClicks("LeftButtonUp")
    b:SetScript("OnClick", C_Bank.CloseBankFrame)
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
        local inv_id = C_Container.ContainerIDToInventoryID(bag_id)
        local bag_tex = GetInventoryItemTexture("player", inv_id)
        local _, slot_tex = GetInventorySlotInfo("Bag" .. bag_id)

        b.icon:Show()
        b.gwHasBag = false -- flag used by OnClick hook to pop up context menu when valid
        local norm = b:GetNormalTexture()
        norm:SetVertexColor(1, 1, 1, 0.75)
        if bag_tex ~= nil then
            b.gwHasBag = true
            if not IsBagOpen(bag_id) then
                OpenBag(bag_id) -- default open valid bank bags immediately  --TAINT atm
            end
            b.icon:SetTexture(bag_tex)
            local quality = GetInventoryItemQuality("player", inv_id)
            if quality then
                SetItemButtonQuality(b, quality, nil)
            end
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

local function takeOverAccountBankItemButtons(self)
    local idx = 1
    for itemButton in self:EnumerateValidItems() do
        itemButton:SetParent(self.Container)
        itemButton.gw_owner = self.Container
        self.Container.gw_items[idx] = itemButton
        inv.reskinItemButton(itemButton)

        idx = idx + 1
    end

    self.Container.gw_num_slots = self.itemButtonPool:GetNumActive()
    layoutAccountBankItems(self)
    snapFrameSize(self:GetParent())
    local id = self:GetSelectedTabID()
    if id and id > 0 then
        inv.updateFreeSlots(self:GetParent().spaceString, id, id)
    end
end

local function reskinAccountBagBar(b)
    local bag_size = 28

    b:SetSize(bag_size, bag_size)

    b.Border:Hide()

    if b.Icon then
        b.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        b.Icon:SetAlpha(0.75)
        b.Icon:Show()
    end

    if b.icon then
        b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        b.icon:SetAlpha(0.75)
        b.icon:Show()
    end

    local norm = b:GetNormalTexture()
    if norm then
        norm:SetTexture(nil)
    end

    if not b.IconBorder then
        b.IconBorder = b:CreateTexture(nil, "ARTWORK")
    end

    b.IconBorder:SetAllPoints(b)
    b.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    b.IconBorder:Show()
    hooksecurefunc(b.IconBorder, "SetTexture", function()
        if b.IconBorder:GetTexture() and b.IconBorder:GetTexture() > 0 and b.IconBorder:GetTexture() ~= "Interface/AddOns/GW2_UI/textures/bag/bagitemborder" then
            b.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        end
    end)

    local high = b:GetHighlightTexture()
    high:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    high:SetBlendMode("ADD")
    high:SetAlpha(0.33)
    high:SetSize(bag_size, bag_size)
    high:ClearAllPoints()
    high:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
end

local function accountTabOnClick(self, button)
    if button == "RightButton" and not self:IsPurchaseTab() then
        self:GetParent().TabSettingsMenu:OnOpenTabSettingsRequested(self.tabData.ID)
    end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    if self:IsPurchaseTab() and C_Bank.CanPurchaseBankTab(Enum.BankType.Account) then
        self:GetParent().Container:Hide()
        self:GetParent():ShowPurchasePrompt()
    else
        self:GetParent().Container:Show()
        self:GetParent().PurchasePrompt:Hide()
        self:GetParent():OnBankTabClicked(self.tabData.ID)
        inv.updateFreeSlots(self:GetParent():GetParent().spaceString, self.tabData.ID, self.tabData.ID)
    end
end

local function refreshBankPanel(self)
    if self:ShouldShowLockPrompt() then
		self:ShowLockPrompt()
        self.Container:Hide()
		return
	end

    if self:ShouldShowPurchasePrompt() then
		self:ShowPurchasePrompt();
        self.Container:Hide()
		return;
	end

    local noTabSelected = self.selectedTabID == nil;
	if noTabSelected then
		return;
	end

    takeOverAccountBankItemButtons(self)

    self.Container:Show()
end

local function createAccountBagBar(f)
    local x = -40
    local y = -80
    local bag_size = 28
    local bag_padding = 4

    fetchPurchasedBankTabData(f)
    takeOverAccountBankItemButtons(f)
    f.bankTabPool:ReleaseAll()

    if f.accountBankPurchasedBankTabData then
		for _, bankTabData in ipairs(f.accountBankPurchasedBankTabData) do
            local b = f.bankTabPool:Acquire()
            b:Init(bankTabData)

            b:RegisterForClicks("AnyUp")
            b.OnClick = accountTabOnClick
            b:SetScript("OnClick", b.OnClick)

            reskinAccountBagBar(b)

            b:SetParent(f)
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", f, "TOPLEFT", x, y)
            b:Show()
            y = y - bag_size - bag_padding
        end
    end

    -- ...followed by the button to purchase a new tab (if applicable)
	local showPurchaseTab = C_PlayerInfo.HasAccountInventoryLock() and not C_Bank.HasMaxBankTabs(Enum.BankType.Account)
	if showPurchaseTab then

        local purchaseTabData = {
            ID = PURCHASE_TAB_ID,
        }
        f.PurchaseTab:Init(purchaseTabData)
        reskinAccountBagBar(f.PurchaseTab)
        f.PurchaseTab:SetParent(f)
        f.PurchaseTab:RegisterForClicks("AnyUp")
        f.PurchaseTab:SetScript("OnClick", accountTabOnClick)
		f.PurchaseTab:SetEnabledState(C_Bank.CanPurchaseBankTab(Enum.BankType.Account))

        f.PurchaseTab:ClearAllPoints()
        f.PurchaseTab:SetPoint("TOPLEFT", f, "TOPLEFT", x, y)

        f.PurchaseTab:Show()
    else
        f.PurchaseTab:Hide()
	end
end

local function onBankResizeStop(self)
    GW.settings.BANK_WIDTH = self:GetWidth()
    inv.onMoved(self, "BANK_POSITION", snapFrameSize)
end
GW.AddForProfiling("bank", "onBankResizeStop", onBankResizeStop)

local function onBankFrameChangeSize(self, _, _, skip)
    local cols = inv.colCount(GW.settings.BAG_ITEM_SIZE, BANK_ITEM_PADDING, self:GetWidth())

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
    if GW.settings.BAG_ITEM_SIZE == BANK_ITEM_LARGE_SIZE then
        GW.settings.BAG_ITEM_SIZE = BANK_ITEM_COMPACT_SIZE
        inv.resizeInventory()
        return true
    end

    GW.settings.BAG_ITEM_SIZE = BANK_ITEM_LARGE_SIZE
    inv.resizeInventory()
    return false
end
GW.AddForProfiling("bank", "compactToggle", compactToggle)

-- reskin all the base BankFrame ItemButtons
local function reskinBankItemButtons()
    local items = C_Container.GetContainerNumSlots(BANK_CONTAINER)
    for i = 1, items do
        local iname = "BankFrameItem" .. i
        local b = _G[iname]
        if b then
            inv.reskinItemButton(b)
        end
    end
end
GW.AddForProfiling("bank", "reskinBankItemButtons", reskinBankItemButtons)

-- reskin all the ReagentBankFrame ItemButtons
local function reskinReagentItemButtons()
    local items = C_Container.GetContainerNumSlots(REAGENTBANK_CONTAINER)
    for i = 1, items do
        local iname = "ReagentBankFrameItem" .. i
        local b = _G[iname]
        if b then
            inv.reskinItemButton(b)
        end
    end
end
GW.AddForProfiling("bank", "reskinReagentItemButtons", reskinReagentItemButtons)

local function bank_OnShow(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
    self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
    self:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")
    self:RegisterEvent("ITEM_LOCKED")
    self:RegisterEvent("ITEM_UNLOCKED")
    self:RegisterEvent("BAG_UPDATE")
    self:RegisterEvent("REAGENTBANK_PURCHASED")

    -- hide the bank frame off screen
    BankFrame:ClearAllPoints()
    BankFrame:SetClampedToScreen(false)
    BankFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -2000, 2000)
    BankSlotsFrame:GwKill()
    BankItemAutoSortButton:Hide()

    -- make the reagent bank initialize itself
    ReagentBankFrame_OnShow(ReagentBankFrame)
    if not self.gw_reagent_skinned then
        reskinReagentItemButtons()
        self.gw_reagent_skinned = true
    end

    OpenAllBags(self) --taints
    createAccountBagBar(self.AccountFrame)
    updateBagBar(self.ItemFrame)
    updateBankContainers(self)
    inv.reskinItemButtons()
end
GW.AddForProfiling("bank", "bank_OnShow", bank_OnShow)

local function bank_OnHide(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    self:UnregisterAllEvents()
    self:RegisterEvent("BANKFRAME_OPENED")
    self:RegisterEvent("BANKFRAME_CLOSED")
    C_Bank.CloseBankFrame()
    if self.buttonSettings.dropdown:IsShown() then
        self.buttonSettings.dropdown:Hide()
    end
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
            for bag_id = NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS do
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
        if bag_id == BANK_CONTAINER or bag_id > NUM_TOTAL_EQUIPPED_BAG_SLOTS and not self.AccountFrame:IsShown() then
            if self.ItemFrame:IsShown() then
                updateFreeBankSlots(self.ItemFrame)
            end
        elseif bag_id == REAGENTBANK_CONTAINER then
            if self.ReagentFrame:IsShown() and IsReagentBankUnlocked() then
                updateFreeReagentSlots()
            end
        elseif self.AccountFrame:IsShown() then
            if self.AccountFrame.selectedTabID == bag_id then
                inv.updateFreeSlots(self.spaceString, bag_id, bag_id)
            end
        end
    elseif event == "PLAYERREAGENTBANKSLOTS_CHANGED" then
        if self.ReagentFrame:IsShown() and IsReagentBankUnlocked() then
            updateFreeReagentSlots()
        end
    elseif event == "REAGENTBANK_PURCHASED" then
        ReagentBankFrameUnlockInfo:Hide()
        ReagentBankFrameUnlockInfo:ClearAllPoints()
        ReagentBankFrameUnlockInfo:SetParent(ReagentBankFrame)
        updateBankContainers(self)
        self.ReagentFrame.DepositAll:Show()
    end
end
GW.AddForProfiling("bank", "bank_OnEvent", bank_OnEvent)

local function tab_OnEnter(self)
    self.Icon:SetBlendMode("ADD")
end
GW.AddForProfiling("bank", "tab_OnEnter", tab_OnEnter)

local function tab_OnLeave(self)
    self.Icon:SetBlendMode("BLEND")
end
GW.AddForProfiling("bank", "tab_OnLeave", tab_OnLeave)

local function SkinAccountBankTabMenu(self)
    if self.isSkinned then return end
    -- skin tab menu
    local checkBoxes = {
        self.DepositSettingsMenu.AssignEquipmentCheckbox,
        self.DepositSettingsMenu.AssignConsumablesCheckbox,
        self.DepositSettingsMenu.AssignProfessionGoodsCheckbox,
        self.DepositSettingsMenu.AssignReagentsCheckbox,
        self.DepositSettingsMenu.AssignJunkCheckbox,
        self.DepositSettingsMenu.IgnoreCleanUpCheckbox,
    }

    self:GwStripTextures()
    self:EnableMouse(true)
    GW.HandleIconSelectionFrame(self)

    self.DepositSettingsMenu.ExpansionFilterDropdown:GwHandleDropDownBox()
    self.DepositSettingsMenu.ExpansionFilterDropdown:SetWidth(120)
    for _, checkBox in pairs(checkBoxes) do
        if checkBox then
            checkBox:GwSkinCheckButton()
            checkBox:SetSize(15, 15)
        end
    end

    self.isSkinned = true
end

local function LoadBank(helpers)
    inv = helpers

    if GW.settings.BAG_ITEM_SIZE > 40 then
        GW.settings.BAG_ITEM_SIZE = 40
    end

    -- create bank frame, restore its saved size, and init its many pieces
    local f = CreateFrame("Frame", "GwBankFrame", UIParent, "GwBankFrameTemplate")
    tinsert(UISpecialFrames, "GwBankFrame")
    f:ClearAllPoints()
    f:SetWidth(GW.settings.BANK_WIDTH)
    onBankFrameChangeSize(f, nil, nil, true)
    f:SetClampedToScreen(true)

    -- setup show/hide
    f:SetScript("OnShow", bank_OnShow)
    f:SetScript("OnHide", bank_OnHide)
    f.buttonClose:SetScript("OnClick", GW.Parent_Hide)

    -- re-hide the BankFrame any time it gets repositioned by UIParent stuff
    hooksecurefunc(BankFrame, "Raise", function()
        BankFrame:ClearAllPoints()
        BankFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -2000, 2000)
        BankSlotsFrame:GwKill()
        BankItemAutoSortButton:Hide()
    end)

    -- setup movable stuff
    local pos = GW.settings.BANK_POSITION
    f:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    f.mover:RegisterForDrag("LeftButton")
    f.mover.onMoveSetting = "BANK_POSITION"
    f.mover:SetScript("OnDragStart", inv.onMoverDragStart)
    f.mover:SetScript("OnDragStop", inv.onMoverDragStop)

    -- setup resizer stuff
    f:SetResizeBounds(340, 340)
    f:SetScript("OnSizeChanged", onBankFrameChangeSize)
    f.sizer.onResizeStop = onBankResizeStop
    f.sizer:SetScript("OnMouseDown", inv.onSizerMouseDown)
    f.sizer:SetScript("OnMouseUp", inv.onSizerMouseUp)

    -- take the original search box
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
            bag_id = i + NUM_TOTAL_EQUIPPED_BAG_SLOTS - 1
        end
        local cf = CreateFrame("Frame", nil, f.ItemFrame)
        cf.gw_items = {}
        cf.gw_num_slots = 0
        cf:SetAllPoints(f.ItemFrame)
        cf:SetID(bag_id)
        cf.IsCombinedBagContainer = function() return true end
        --cf.BagID = bag_id
        f.ItemFrame.Containers[bag_id] = cf
    end
    f.ReagentFrame.Containers = {}
    local cf = CreateFrame("Frame", nil, f.ReagentFrame)
    cf.gw_items = {}
    cf.gw_num_slots = 0
    cf:SetAllPoints(f.ReagentFrame)
    cf:SetID(REAGENTBANK_CONTAINER)
    cf.IsCombinedBagContainer = function() return true end
    f.ReagentFrame.Containers[REAGENTBANK_CONTAINER] = cf

    --AccountBank Tab Settings
    cf = CreateFrame("Frame", nil, f.AccountFrame)
    cf:SetAllPoints(f.AccountFrame)
    cf.gw_items = {}
    cf.gw_num_slots = 0
    f.AccountFrame.Container = cf

    f.AccountFrame.ShouldShowPurchasePrompt = function(self)
        fetchPurchasedBankTabData(self)
        return C_Bank.CanPurchaseBankTab(Enum.BankType.Account) and (not self.accountBankPurchasedBankTabData or (self.accountBankPurchasedBankTabData and #self.accountBankPurchasedBankTabData == 0))
    end

    f.AccountFrame.TabSettingsMenu = CreateFrame("Frame", nil, f, "BankPanelTabSettingsMenuTemplate")
    f.AccountFrame.TabSettingsMenu.SetSelectedTab = function(self, selectedTabID)
        local alreadySelected = self:GetSelectedTabID() == selectedTabID;
        if alreadySelected then
            return;
        end

        fetchPurchasedBankTabData(f.AccountFrame)

        if not f.AccountFrame.accountBankPurchasedBankTabData then
            self.selectedTabData = nil
        else
            for _, tabData in ipairs(f.AccountFrame.accountBankPurchasedBankTabData) do
                if tabData.ID == selectedTabID then
                    self.selectedTabData = tabData
                    break
                end
            end
        end

        if self:IsShown() then
            self:Update()
        end
    end
    f.AccountFrame.TabSettingsMenu:Hide()
    f.AccountFrame.TabSettingsMenu:OnLoad()
    f.AccountFrame.TabSettingsMenu:SetScript("OnShow", function()
        f.AccountFrame.TabSettingsMenu:OnShow()
        SkinAccountBankTabMenu(f.AccountFrame.TabSettingsMenu)
    end)
    f.AccountFrame.TabSettingsMenu:SetScript("OnHide", f.AccountFrame.TabSettingsMenu.OnHide)

    f.AccountFrame.ItemDepositFrame.DepositButton:GwSkinButton(false, true)
    f.AccountFrame.ItemDepositFrame.DepositButton:ClearAllPoints()
    f.AccountFrame.ItemDepositFrame.DepositButton:SetPoint("TOPLEFT", f.AccountFrame, "BOTTOMLEFT", 5, -6)
    f.AccountFrame.ItemDepositFrame.IncludeReagentsCheckbox:ClearAllPoints()
    f.AccountFrame.ItemDepositFrame.IncludeReagentsCheckbox:SetPoint("TOPLEFT", f.AccountFrame, "BOTTOMLEFT", 5, 20)
    f.AccountFrame.ItemDepositFrame.IncludeReagentsCheckbox:GwSkinCheckButton()
    f.AccountFrame.ItemDepositFrame.IncludeReagentsCheckbox:SetSize(15, 15)
    f.AccountFrame.ItemDepositFrame.IncludeReagentsCheckbox.Text:SetTextColor(1, 1, 1)
    hooksecurefunc(f.AccountFrame.ItemDepositFrame, "SetEnabled", function(_, enabled)
        local fontColor = enabled and WHITE_FONT_COLOR or GRAY_FONT_COLOR
        f.AccountFrame.ItemDepositFrame.IncludeReagentsCheckbox.Text:SetTextColor(fontColor:GetRGB())
    end)
    f.AccountFrame.MoneyFrame:GwStripTextures()
    f.AccountFrame.MoneyFrame.WithdrawButton:GwSkinButton(false, true)
    f.AccountFrame.MoneyFrame.DepositButton:GwSkinButton(false, true)
    f.AccountFrame.MoneyFrame.MoneyDisplay:ClearAllPoints()
    f.AccountFrame.MoneyFrame.MoneyDisplay:SetPoint("BOTTOMRIGHT", f.AccountFrame, "BOTTOMRIGHT", 3, -27)

    hooksecurefunc(f.AccountFrame.Header, "SetShown", function(self) self:Hide() end)
    hooksecurefunc(f.AccountFrame, "RefreshBankTabs", createAccountBagBar)
    hooksecurefunc(f.AccountFrame, "RefreshBankPanel", refreshBankPanel)
    hooksecurefunc(f.AccountFrame, "GenerateItemSlotsForSelectedTab", takeOverAccountBankItemButtons)
    hooksecurefunc(C_Bank, "PurchaseBankTab", function() createAccountBagBar(f.AccountFrame) end)

    -- reskin all the BankFrame ItemButtons
    reskinBankItemButtons()

    -- anytime a ContainerFrame is populated with a bank bagId, we take its buttons
    hooksecurefunc("ContainerFrame_GenerateFrame", function(_, _, id)
        if id > NUM_TOTAL_EQUIPPED_BAG_SLOTS and id <= NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS then
            rescanBankContainers(f)
        end
    end)

    -- don't let anyone close bank bags while the bank is open
    hooksecurefunc("ToggleAllBags", function()
        if GwBankFrame:IsShown() then
            for i = NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS do
                if not IsBagOpen(i) then
                    OpenBag(i)
                end
            end
        end
    end)
    hooksecurefunc("ToggleBackpack", function()
        if GwBankFrame:IsShown() then
            for i = NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS do
                if not IsBagOpen(i) then
                    OpenBag(i)
                end
            end
        end
    end)

    -- create our bank bag slots
    createBagBar(f.ItemFrame)

    -- skin some things not done in XML
    f.headerString:SetFont(DAMAGE_TEXT_FONT, 20, "")
    f.headerString:SetText(BANK)
    f.spaceString:SetFont(UNIT_NAME_FONT, 12, "")
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
                C_Container.SortBankBags()
            elseif self:GetParent().ReagentFrame:IsShown() and IsReagentBankUnlocked() then
                C_Container.SortReagentBankBags()
            elseif self:GetParent().AccountFrame:IsShown() and IsReagentBankUnlocked() then
                C_Container.SortAccountBankBags()
            end
        end
    )
    EnableTooltip(f.buttonSort, BAG_CLEANUP_BANK)

    do
        EnableTooltip(f.buttonSettings, BAG_SETTINGS_TOOLTIP)
        local dd = f.buttonSettings.dropdown
        dd:GwCreateBackdrop(GW.BackdropTemplates.Default)
        f.buttonSettings:SetScript(
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
                local newStatus = not GW.settings.BANK_REVERSE_SORT
                dd.bagOrder.checkbutton:SetChecked(newStatus)
                GW.settings.BANK_REVERSE_SORT = newStatus
                ContainerFrame_UpdateAll() --this is tainting
            end
        )

        dd.itemBorder.checkbutton:HookScript(
            "OnClick",
            function()
                local newStatus = not GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW
                dd.itemBorder.checkbutton:SetChecked(newStatus)
                GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW = newStatus
                ContainerFrame_UpdateAll() --this is tainting
            end
        )

        dd.compactBank.checkbutton:SetChecked(GW.settings.BAG_ITEM_SIZE == BANK_ITEM_COMPACT_SIZE)
        dd.bagOrder.checkbutton:SetChecked(GW.settings.BANK_REVERSE_SORT)
        dd.itemBorder.checkbutton:SetChecked(GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW)

        -- setup bag setting icons locals
        dd.compactBank.title:SetText(L["Compact Icons"])
        dd.bagOrder.title:SetText(L["Reverse Bag Order"])
        dd.itemBorder.title:SetText(L["Show Quality Color"])
    end

    -- setup bank/reagent switching tabs
    f.ItemTab:SetScript("OnEnter", tab_OnEnter)
    f.ItemTab:SetScript("OnLeave", tab_OnLeave)
    f.ItemTab:SetScript(
        "OnClick",
        function(self)
            BankFrame.selectedTab = 1 -- for right-clicking things into bank
            local bf = self:GetParent()
            if bf.ItemFrame:IsShown() then
                return
            end
            bf.ItemFrame:Show()
            bf.ReagentFrame:Hide()
            bf.AccountFrame:Hide()
            bf.buttonSort.tooltipText = BAG_CLEANUP_BANK
            updateBankContainers(bf)
        end
    )
    EnableTooltip(f.ItemTab, BANK)
    f.ReagentTab:SetScript("OnEnter", tab_OnEnter)
    f.ReagentTab:SetScript("OnLeave", tab_OnLeave)
    f.ReagentTab:SetScript(
        "OnClick",
        function(self)
            BankFrame.selectedTab = 2 -- for right-clicking things into bank
            local bf = self:GetParent()
            if bf.ReagentFrame:IsShown() then
                return
            end
            bf.ItemFrame:Hide()
            bf.ReagentFrame:Show()
            bf.AccountFrame:Hide()
            bf.buttonSort.tooltipText = BAG_CLEANUP_REAGENT_BANK
            updateBankContainers(bf)
        end
    )
    EnableTooltip(f.ReagentTab, REAGENT_BANK)

    f.AccountTab:SetScript("OnEnter", tab_OnEnter)
    f.AccountTab:SetScript("OnLeave", tab_OnLeave)
    f.AccountTab:SetScript(
        "OnClick",
        function(self)
            BankFrame.selectedTab = 3 -- for right-clicking things into bank
            local bf = self:GetParent()
            if bf.AccountFrame:IsShown() then
                return
            end
            bf.ItemFrame:Hide()
            bf.ReagentFrame:Hide()
            bf.AccountFrame:Show()
            bf.buttonSort.tooltipText = BAG_CLEANUP_ACCOUNT_BANK
            updateBankContainers(bf)
        end
    )
    EnableTooltip(f.AccountTab, ACCOUNT_BANK_PANEL_TITLE)

    -- setup reagent bank stuff
    f.ReagentFrame.DepositAll:SetText(REAGENTBANK_DEPOSIT)
    f.ReagentFrame.DepositAll:SetScript(
        "OnClick",
        function()
            DepositReagentBank()
        end
    )
    if IsReagentBankUnlocked() then
        f.ReagentFrame.DepositAll:Show()
    else
        -- steal the original help/purchase window
        local hf = ReagentBankFrame.UnlockInfo
        hf:SetParent(f.ReagentFrame)
        MoneyFrame_Update(hf.CostMoneyFrame, GetReagentBankCost())
        hf:ClearAllPoints()
        hf:SetPoint("TOPLEFT", f.ReagentFrame, "TOPLEFT", 0, 0)
        hf:SetPoint("BOTTOMRIGHT", f.ReagentFrame, "BOTTOMRIGHT", 0, 0)
        hf:Show()
    end

    -- return a callback that should be called when item size changes
    local changeItemSize = function()
        reskinBankItemButtons()
        reskinReagentItemButtons()
        takeOverAccountBankItemButtons(f.AccountFrame)
        layoutItems(f)
        snapFrameSize(f)
    end
    return changeItemSize
end
GW.LoadBank = LoadBank
