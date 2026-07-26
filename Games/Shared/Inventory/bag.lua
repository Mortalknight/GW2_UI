---@class GW2
local GW = select(2, ...)
local L = GW.L
local UpdateMoney = GW.UpdateMoney
local EnableTooltip = GW.EnableTooltip
local inv

-- the keyring only exists up to wrath, the reagent bag only on retail; both occupy
-- the extra fifth bag bar slot and the extra layout section
local HAS_KEYRING = GW.Classic or GW.TBC or GW.Wrath
local HAS_REAGENT_BAG = GW.Retail
local LAST_BAG_SLOT = (HAS_KEYRING or HAS_REAGENT_BAG) and (NUM_BAG_SLOTS + 1) or NUM_BAG_SLOTS

--[[
    Flavor modules.

    The shared bag core drives the bag bar, layout, events, settings and the frame itself.
    Flavor extras (e.g. the currency display on mists) plug in as modules, registered at
    file scope from the flavors inventory folder (the shared code loads before the flavor
    folders):

        GW.RegisterBagModule({
            onLoadBag = function(f, core) end,                       -- extras once the bag frame exists
            onMenu    = function(f, rootDescription, addCheck) end,  -- extra settings menu entries
        })

    core hands the modules the shared machinery: layoutItems, snapFrameSize, updateBagContainers,
    rescanBagContainers and (from LoadBag on) the inv helpers.
]]
local bagModules = {}
local function RegisterBagModule(module)
    bagModules[#bagModules + 1] = module
end
GW.RegisterBagModule = RegisterBagModule

local function callBagModules(hook, ...)
    for i = 1, #bagModules do
        local fn = bagModules[i][hook]
        if fn then
            fn(...)
        end
    end
end

local core = {}

local function setBagHeaders(frame)
    for i = 1, NUM_BAG_SLOTS do
        local customBagHeaderName = GW.settings["BAG_HEADER_NAME" .. i]
        local header = frame["bagHeader" .. i]
        local slotID = GetInventorySlotInfo("Bag" .. i - 1 .. "Slot")
        local itemID = GetInventoryItemID("player", slotID)

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
    if HAS_KEYRING then
        local customBagHeaderName = GW.settings.BAG_HEADER_NAME5
        frame.bagHeader5.nameString:SetText(strlen(customBagHeaderName) > 0 and customBagHeaderName or KEYRING)
        frame.bagHeader5.nameString:SetTextColor(1, 1, 1, 1)
    elseif HAS_REAGENT_BAG then
        local customBagHeaderName = GW.settings.BAG_HEADER_NAME5
        local itemID = GetInventoryItemID("player", (GetInventorySlotInfo("ReagentBag0Slot")))
        if itemID then
            local r, g, b = 1, 1, 1
            local itemName, _, itemRarity = C_Item.GetItemInfo(itemID)
            if itemRarity then r, g, b = C_Item.GetItemQualityColor(itemRarity) end
            frame.bagHeader5.nameString:SetText(strlen(customBagHeaderName) > 0 and customBagHeaderName or itemName and itemName or UNKNOWN)
            frame.bagHeader5.nameString:SetTextColor(r, g, b, 1)
        else
            frame.bagHeader5:Hide()
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
    -- in combined mode the keyring (classic) or the reagent bag (retail) can be set
    -- off to its own rows with a gap as separation
    local extraBagGap = not sep and (
        (HAS_KEYRING and GW.settings.BAG_SEPARATE_KEYRING and IsBagOpen(KEYRING_CONTAINER))
        or (HAS_REAGENT_BAG and GW.settings.BAG_SEPARATE_REAGENT_BAG and f.Containers[5] and f.Containers[5].gw_num_slots > 0)
    )
    local row = sep and 1 or 0
    if not GW.settings.BAG_ITEM_SIZE or not GW.settings.BAG_ITEM_SPACING_X or not GW.settings.BAG_ITEM_SPACING_Y then
        -- acedb can have the profile defaults detached (logout, profile operations)
        return
    end
    local item_off_x = GW.settings.BAG_ITEM_SIZE + GW.settings.BAG_ITEM_SPACING_X
    local item_off_y = GW.settings.BAG_ITEM_SIZE + GW.settings.BAG_ITEM_SPACING_Y
    local unfinishedRow = false
    local finishedRows = 0

    local iS = BACKPACK_CONTAINER
    local iE = LAST_BAG_SLOT
    local iD = 1
    if rev then
        iE = iS
        iS = LAST_BAG_SLOT
        iD = -1
    end
    parent.unfinishedRow = 0
    parent.finishedRow = 0
    local lcf = inv.layoutContainerFrame
    for i = iS, iE, iD do
        local bag_id = i
        local itemID
        local cf = (HAS_KEYRING and bag_id == 5 and IsBagOpen(KEYRING_CONTAINER)) and f.Containers[KEYRING_CONTAINER] or f.Containers[bag_id]
        local header = parent["bagHeader" .. i]
        if sep then
            if bag_id == 5 and not rev then
                if col ~= 0 then
                    row = row + 2
                else
                    row = row + 1
                end
            end
            header:Show()
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", f, "TOPLEFT", 0, (-row + 1) * item_off_y)
            header:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, (-row + 1) * item_off_y)
        else
            header:Hide()
        end
        if sep and rev and bag_id == 5 and not cf then
            row = 2
        end
        if cf then
            if sep and cf.shouldShow then
                if bag_id == 5 and IsBagOpen(KEYRING_CONTAINER) then
                    if col ~= 0 then col = 0 end
                end
                col, row, unfinishedRow, finishedRows = lcf(cf, max_col, row, col, false, item_off_x, item_off_y)
                cf:Show()
            elseif sep and not cf.shouldShow then
                cf:Hide()
            elseif not sep then
                if extraBagGap and bag_id == 5 and not rev then
                    -- the extra bag comes last: finish the bag rows and leave a gap above it
                    if col ~= 0 then
                        col = 0
                        row = row + 1
                    end
                    row = row + 0.5
                end
                col, row, unfinishedRow, finishedRows = lcf(cf, max_col, row, col, false, item_off_x, item_off_y)
                cf:Show()
                if extraBagGap and bag_id == 5 and rev then
                    -- the extra bag comes first: finish its rows and leave a gap below it
                    if col ~= 0 then
                        col = 0
                        row = row + 1
                    end
                    row = row + 0.5
                end
            end

            if unfinishedRow then parent.unfinishedRow = parent.unfinishedRow  + 1 end
            parent.finishedRow = parent.finishedRow + finishedRows

            if not rev and bag_id < 4 then
                itemID = GetInventoryItemID("player", C_Container.ContainerIDToInventoryID(bag_id))
            elseif rev and bag_id < 5 and bag_id > 0 then
                itemID = GetInventoryItemID("player", C_Container.ContainerIDToInventoryID(bag_id - 1))
            end

            if sep and (bag_id == 0 or itemID or (rev and bag_id == 5)) then
                if col ~= 0 then
                    row = row + 2
                    col = 0
                else
                    row = row + 1
                end
            end
        end
    end

    -- with the extra bag set off, the plain slots/columns row count of snapFrameSize
    -- no longer matches - store the rows the layout actually used
    parent.gw_combined_rows = extraBagGap and (row + (col > 0 and 1 or 0)) or nil

    if GW.settings.BAG_SEPARATE_BAGS then
        setBagHeaders(parent)
    end
end


-- adjusts the ItemButton layout flow when the bag window size changes (or on open)
local function layoutItems(f)
    if f.ItemFrame:IsShown() then
        layoutBagItems(f.ItemFrame)
    end
end


-- adjusts the bag frame size to snap to the exact row/col sizing of contents
local function snapFrameSize(f)
    local cfs
    if f.ItemFrame:IsShown() then
        cfs = f.ItemFrame.Containers
    end
    inv.snapFrameSize(f, cfs, GW.settings.BAG_ITEM_SIZE, GW.settings.BAG_ITEM_SPACING_X, GW.settings.BAG_ITEM_SPACING_Y, 350)
end


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
    self.gold:SetText(GW.GetLocalizedNumber(gold))

    UpdateMoney()
end

-- update the number of free bag slots available and set the display for it
local function updateFreeBagSlots()
    inv.updateFreeSlots(GwBagFrame.spaceString, 1, HAS_REAGENT_BAG and LAST_BAG_SLOT or NUM_BAG_SLOTS, BACKPACK_CONTAINER)
end


-- update all backpack bag items
local function updateBagContainers(f)
    if f.ItemFrame:IsShown() then
        updateFreeBagSlots()
        layoutItems(f)
        snapFrameSize(f)
    end
end


-- rescan ALL bag ItemButtons
local function rescanBagContainers(f)
    for bag_id = BACKPACK_CONTAINER, HAS_REAGENT_BAG and LAST_BAG_SLOT or NUM_BAG_SLOTS do
        GW.SetupOwnContainerItemButtons(f.ItemFrame.Containers[bag_id], bag_id)
    end
    if HAS_KEYRING then
        GW.SetupOwnContainerItemButtons(f.ItemFrame.Containers[KEYRING_CONTAINER], KEYRING_CONTAINER)
    end
    updateBagContainers(f)
end


local function bag_OnClick(self, button)
    -- on left click, ensure that the bag stays open despite default toggle behavior;
    -- on retail a held item is put into the bag first
    if button == "LeftButton" then
        if GW.Retail then
            local hadItem = PutItemInBag(self:GetID())
            if not hadItem and self.gwHasBag and not IsBagOpen(self:GetBagID()) then
                OpenBag(self:GetBagID())
            end
        elseif self.gwHasBag and not IsBagOpen(self:GetID() - CharacterBag0Slot:GetID() + 1) then
            OpenBag(self:GetID() - CharacterBag0Slot:GetID() + 1)
        end
    end
end


-- syncs the keyring buttons pressed state with the keyrings open state
local function updateKeyringButtonState()
    if not HAS_KEYRING or not GWkeyringbutton then
        return
    end
    if IsBagOpen(KEYRING_CONTAINER) then
        GWkeyringbutton.border:Show()
        GWkeyringbutton.IconBorder:Hide()
    else
        GWkeyringbutton.border:Hide()
        GWkeyringbutton.IconBorder:Show()
    end
end


-- creates the keyring toggle button for a flavors bag bar, positioning is up to the caller
local function createKeyringButton(f)
    local parent = f:GetParent()
    local b = CreateFrame("Button", "GWkeyringbutton", f, "GwKeyRingButtonTemp")
    b:SetHighlightTexture('Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png')
    GW.SetItemButtonQualityForBags(b, 1)
    b:SetScript("OnClick",
        function(self)
            local isKeyringBagOpen = IsBagOpen(KEYRING_CONTAINER)
            if isKeyringBagOpen then
                parent.ItemFrame.Containers[KEYRING_CONTAINER].shouldShow = false
                CloseBag(KEYRING_CONTAINER)
                self.border:Hide()
                self.IconBorder:Show()
                updateBagContainers(parent)
                rescanBagContainers(parent)
            else
                parent.ItemFrame.Containers[KEYRING_CONTAINER].shouldShow = true
                OpenBag(KEYRING_CONTAINER)
                self.border:Show()
                self.IconBorder:Hide()
            end
            parent.bagHeader5.icon:SetShown(isKeyringBagOpen)
            parent.bagHeader5.icon2:SetShown(not isKeyringBagOpen)
        end
    )
    return b
end


-- draws the backpack bag slots in the correct order
local function setBagBarOrder(f)
    local x = -40
    local bag_size = 28
    local bag_padding = 4
    local rev = GW.settings.BAG_REVERSE_SORT
    local last = LAST_BAG_SLOT
    local y = rev and (5 - ((bag_size + bag_padding) * last)) or 5

    for bag_idx = BACKPACK_CONTAINER, last do
        local b = f.bags[bag_idx]
        b.ClearAllPoints = nil
        b.SetPoint = nil
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", f, "TOPLEFT", x, y)
        if rev then
            y = y + bag_size + bag_padding
        else
            y = y - bag_size - bag_padding
        end
        -- blizzards bags bar relayouts its bag slot buttons on login and edit mode
        -- updates, lock the stolen buttons in place
        b.ClearAllPoints = GW.NoOp
        b.SetPoint = GW.NoOp
        b:Show()
    end
end


-- creates the bag slot icons for the ItemFrame by stealing blizzards real bag
-- slot buttons, like on retail
local function createBagBar(f)
    f.bags = {}

    -- steal the existing main backpack button
    local bp = MainMenuBarBackpackButton
    bp:SetParent(f)
    inv.reskinBagBar(bp)
    bp:RegisterForClicks("LeftButtonUp")
    if bp.SetChecked then
        bp:SetChecked(false)
    end
    bp:HookScript("OnMouseDown", inv.bag_OnMouseDown)
    bp.gwBackdrop = true -- checked by some things to see if this is a reskinned button
    f.bags[BACKPACK_CONTAINER] = bp
    -- the count is our free slots display inside the bag frame, keep it visible
    -- regardless of blizzards displayFreeBagSlots cvar handling
    local function updateBackpackFreeSlots()
        bp.Count:SetText(bp.freeSlots)
        bp.Count:Show()
    end
    if MainMenuBarBackpackButton_UpdateFreeSlots then
        hooksecurefunc("MainMenuBarBackpackButton_UpdateFreeSlots", updateBackpackFreeSlots)
    else
        hooksecurefunc(bp, "UpdateFreeSlots", updateBackpackFreeSlots)
    end
    updateBackpackFreeSlots()
    GW.SetItemButtonQualityForBags(bp, 1)

    -- steal the bag slot buttons for equippable bags
    for bag_idx = 1, NUM_BAG_SLOTS do
        local b = _G["CharacterBag" .. bag_idx - 1 .. "Slot"]
        b:SetParent(f)
        if b.SetChecked then
            b:SetChecked(false)
        end
        b:RegisterForClicks("LeftButtonUp")
        b:SetScript("OnClick", bag_OnClick)
        b:SetScript("OnMouseDown", inv.bag_OnMouseDown)

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

    if HAS_KEYRING then
        f.bags[NUM_BAG_SLOTS + 1] = createKeyringButton(f)
    elseif HAS_REAGENT_BAG and CharacterReagentBag0Slot then
        -- steal the reagent bag slot button
        local b = CharacterReagentBag0Slot
        b:SetParent(f)
        if b.SetChecked then
            b:SetChecked(false)
        end
        b:RegisterForClicks("LeftButtonUp")
        b:SetScript("OnClick", bag_OnClick)
        b:SetScript("OnMouseDown", inv.bag_OnMouseDown)
        inv.reskinBagBar(b)
        f.bags[NUM_BAG_SLOTS + 1] = b
    end

    setBagBarOrder(f)
end


-- updates the contents of the backpack bag slots
local function updateBagBar(f)
    for bag_idx = 1, HAS_REAGENT_BAG and LAST_BAG_SLOT or NUM_BAG_SLOTS do
        local b = f.bags[bag_idx]
        local inv_id = C_Container.ContainerIDToInventoryID(bag_idx)
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
            if b.SetChecked then
                b:SetChecked(false)
            end
            GW.SetItemButtonQualityForBags(b, 1)
        end
    end
end


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

local function hookOpenBackpack()
    hookOpenBag(BACKPACK_CONTAINER)
end

local function hookCloseBag(bag_id)
    if not bag_id or bag_id ~= BACKPACK_CONTAINER then
        return
    end
    local f = GwBagFrame
    if f:IsShown() then
        C_Timer.After(0, function() f:Hide() end)
    end
end

local function hookCloseBackpack()
    hookCloseBag(BACKPACK_CONTAINER)
end

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

local function hookToggleBag(bag_id)
    if not bag_id or bag_id ~= BACKPACK_CONTAINER then
        return
    end
    hookToggleBackpack()
end


local function bag_OnShow(self)
    PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
    self:RegisterEvent("ITEM_LOCKED")
    self:RegisterEvent("ITEM_UNLOCKED")
    self:RegisterEvent("BAG_UPDATE")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:RegisterEvent("BAG_UPDATE_COOLDOWN")
    self:RegisterEvent("INVENTORY_SEARCH_UPDATE")
    if not IsBagOpen(BACKPACK_CONTAINER) then
        OpenBackpack()
    end
    for i = 1, HAS_REAGENT_BAG and LAST_BAG_SLOT or NUM_BAG_SLOTS do
        if not IsBagOpen(i) then
            OpenBag(i)
        end
    end
    updateKeyringButtonState()
    updateBagBar(self.ItemFrame)
    rescanBagContainers(self)
end


local function bag_OnHide(self)
    PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
    self:UnregisterAllEvents()
    for i = 1, HAS_REAGENT_BAG and LAST_BAG_SLOT or NUM_BAG_SLOTS do
        if IsBagOpen(i) then
            CloseBag(i)
        end
    end
    if IsBagOpen(BACKPACK_CONTAINER) then
        CloseBackpack()
    end
    if HAS_KEYRING and IsBagOpen(KEYRING_CONTAINER) then
        CloseBag(KEYRING_CONTAINER)
    end
end


local function getEventContainer(self, bag)
    if bag and bag >= BACKPACK_CONTAINER and bag <= (HAS_REAGENT_BAG and LAST_BAG_SLOT or NUM_BAG_SLOTS) then
        return self.ItemFrame.Containers[bag]
    elseif HAS_KEYRING and bag == KEYRING_CONTAINER then
        return self.ItemFrame.Containers[KEYRING_CONTAINER]
    end
    return nil
end

local function bag_OnEvent(self, event, ...)
    if event == "ITEM_LOCKED" or event == "ITEM_UNLOCKED" then
        -- check if the item un/locked is a character bag and gray it out if so
        local bag = select(1, ...)
        local slot = select(2, ...)
        local cb0_id = CharacterBag0Slot:GetID()

        if slot == nil and bag >= cb0_id and bag <= cb0_id + (HAS_REAGENT_BAG and LAST_BAG_SLOT or NUM_BAG_SLOTS) then
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
        elseif slot ~= nil then
            -- lock state of one of our own item buttons
            GW.UpdateOwnContainerLockedState(getEventContainer(self, bag), slot)
        end
    elseif event == "BAG_UPDATE" then
        local bag_id = select(1, ...)
        if (bag_id <= (HAS_REAGENT_BAG and LAST_BAG_SLOT or NUM_BAG_SLOTS) and bag_id >= BACKPACK_CONTAINER) or (HAS_KEYRING and bag_id == KEYRING_CONTAINER) then
            self.gw_need_bag_update = true
        end
    elseif event == "BAG_UPDATE_DELAYED" then
        if self.gw_need_bag_rescan then
            for bag_id = 1, HAS_REAGENT_BAG and LAST_BAG_SLOT or NUM_BAG_SLOTS do
                if not IsBagOpen(bag_id) then
                    OpenBag(bag_id)
                end
            end
            if HAS_KEYRING and not IsBagOpen(KEYRING_CONTAINER) then
                OpenBag(KEYRING_CONTAINER)
            end
            updateBagBar(self.ItemFrame)
            updateKeyringButtonState()
        end
        if self.gw_need_bag_rescan or self.gw_need_bag_update then
            rescanBagContainers(self)
        end
        self.gw_need_bag_rescan = false
        self.gw_need_bag_update = false
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


local function bagHeader_OnClick(self, btn)
    local bag_id = self:GetID()
    if btn == "LeftButton" then
        if HAS_KEYRING and bag_id == 5 then
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
            self:GetParent().ItemFrame.Containers[bag_id].shouldShow = not self.icon:IsShown()
            self.icon:SetShown(not self.icon:IsShown())
            self.icon2:SetShown(not self.icon:IsShown())
        end

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

-- the shared machinery handed to the flavor modules
core.layoutItems = layoutItems
core.snapFrameSize = snapFrameSize
core.updateBagContainers = updateBagContainers
core.rescanBagContainers = rescanBagContainers

local function onBagResizeStop(self)
    GW.settings.BAG_WIDTH = self:GetWidth()
    GwBagFrame.Header:SetWidth(GW.settings.BAG_WIDTH)
    inv.onMoved(self, "BAG_POSITION", snapFrameSize)
end


local function onBagFrameChangeSize(self, _, _, skip)
    self.Header:SetWidth(self:GetWidth())

    local size = GW.settings.BAG_ITEM_SIZE
    local spacing = GW.settings.BAG_ITEM_SPACING_X
    if not size or not spacing then
        -- OnSizeChanged can fire while acedb has the profile defaults detached
        -- (logout, profile operations) - values equal to a default read as nil then
        return
    end
    local cols = inv.colCount(size, spacing, self:GetWidth())

    if not self.gw_bag_cols or self.gw_bag_cols ~= cols then
        self.gw_bag_cols = cols
        if not skip then
            layoutItems(self)
        end
    end
end


local function setBagItemSize(value)
    local size = inv.normalizeBagItemSize(value)
    if GW.settings.BAG_ITEM_SIZE ~= size then
        GW.settings.BAG_ITEM_SIZE = size
        inv.resizeInventory()
    end
    return size
end

local function setBagItemSpacing(settingKey, normalizeFunc, value)
    local spacing = normalizeFunc(value)
    if GW.settings[settingKey] ~= spacing then
        GW.settings[settingKey] = spacing
        inv.resizeInventory()
    end
    return spacing
end

local function addBagSliderControl(rootDescription, title, config, getValueFunc, setValueFunc)
    GW.AddMenuSliderDescription(rootDescription, {
        title = title,
        minValue = config.minValue,
        maxValue = config.maxValue,
        step = config.step,
        getValue = getValueFunc,
        setValue = setValueFunc
    })
end


-- skins blizzards stack split popup; the modern frame exists on all current clients,
-- every child is guarded anyway in case a flavor differs
local function skinStackSplit()
    if not StackSplitFrame then
        return
    end
    StackSplitFrame:GwStripTextures()
    StackSplitFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)

    if StackSplitFrame.OkayButton then
        StackSplitFrame.OkayButton:GwSkinButton(false, true)
    end
    if StackSplitFrame.CancelButton then
        StackSplitFrame.CancelButton:GwSkinButton(false, true)
    end

    if StackSplitFrame.RightButton then
        GW.HandleNextPrevButton(StackSplitFrame.RightButton, "right")
        StackSplitFrame.RightButton:SetSize(25, 25)
        StackSplitFrame.RightButton:SetPoint("LEFT", StackSplitFrame, "CENTER", 51, 18)
    end
    if StackSplitFrame.LeftButton then
        GW.HandleNextPrevButton(StackSplitFrame.LeftButton, "left")
        StackSplitFrame.LeftButton:SetSize(25, 25)
        StackSplitFrame.LeftButton:SetPoint("RIGHT", StackSplitFrame, "CENTER", -50, 18)
    end

    StackSplitFrame.textboxbg = StackSplitFrame:CreateTexture(nil, "BACKGROUND")
    StackSplitFrame.textboxbg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg.png")
    StackSplitFrame.textboxbg:SetPoint("TOPLEFT", 35, -20)
    StackSplitFrame.textboxbg:SetPoint("BOTTOMRIGHT", -35, 55)
end

local function LoadBag(helpers)
    inv = helpers
    core.inv = helpers

    GW.settings.BAG_ITEM_SIZE = inv.normalizeBagItemSize(GW.settings.BAG_ITEM_SIZE)
    GW.settings.BAG_ITEM_SPACING_X = inv.normalizeBagItemSpacingX(GW.settings.BAG_ITEM_SPACING_X)
    GW.settings.BAG_ITEM_SPACING_Y = inv.normalizeBagItemSpacingY(GW.settings.BAG_ITEM_SPACING_Y)

    -- create bag frame, restore its saved size, and init its many pieces
    local f = CreateFrame("Frame", "GwBagFrame", UIParent, "GwBagFrameTemplate")
    tinsert(UISpecialFrames, "GwBagFrame")
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
    f:SetResizeBounds(340, 340)
    f:SetScript("OnSizeChanged", onBagFrameChangeSize)
    f.sizer.onResizeStop = onBagResizeStop
    f.sizer:SetScript("OnMouseDown", inv.onSizerMouseDown)
    f.sizer:SetScript("OnMouseUp", inv.onSizerMouseUp)

    -- setup bagheader stuff; the template ships a keyring header, flavors
    -- without a keyring simply never show it
    local headerIndex = 0
    while f["bagHeader" .. headerIndex] do
        local header = f["bagHeader" .. headerIndex]
        header.nameString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        header.nameString:SetTextColor(1, 1, 1)
        header.nameString:SetShadowColor(0, 0, 0, 0)
        if HAS_KEYRING and headerIndex == 5 then
            header.icon:Hide()
            header.icon2:Show()
        else
            header.icon2:Hide()
        end
        header:Hide()
        header:SetScript("OnClick", bagHeader_OnClick)
        header:SetScript("OnEnter", bagHeader_OnEnter)
        header:SetScript("OnLeave", GameTooltip_Hide)
        headerIndex = headerIndex + 1
    end

    -- take the original search box
    local BagItemSearchBox = CreateFrame("EditBox", "BagItemSearchBox", f, "BagSearchBoxTemplate")
    inv.reskinSearchBox(BagItemSearchBox)
    if ContainerFrame_Update then
        hooksecurefunc(
            "ContainerFrame_Update",
            function()
                inv.relocateSearchBox(BagItemSearchBox, f)
            end
        )
    else
        hooksecurefunc(ContainerFrame1, "UpdateSearchBox", function()
            inv.relocateSearchBox(BagItemSearchBox, f)
        end)
    end
    inv.relocateSearchBox(BagItemSearchBox, f)

    -- our own item buttons need parent containers with IDs set to the bagId, in order
    -- for all of the inherited ItemButton functionality to work normally
    f.ItemFrame.Containers = {}
    for bag_id = BACKPACK_CONTAINER, HAS_REAGENT_BAG and LAST_BAG_SLOT or NUM_BAG_SLOTS do
        local cf = CreateFrame("Frame", nil, f.ItemFrame)
        cf.gw_items = {}
        cf.gw_num_slots = 0
        cf:SetAllPoints(f.ItemFrame)
        cf:SetID(bag_id)
        cf.shouldShow = true
        -- the retail item button mixin asks its parent for these
        cf.GetBagID = cf.GetID
        cf.IsCombinedBagContainer = function() return true end
        f.ItemFrame.Containers[bag_id] = cf
    end

    if HAS_KEYRING then
        local cf = CreateFrame("Frame", nil, f.ItemFrame)
        cf.gw_items = {}
        cf.gw_num_slots = 0
        cf:SetAllPoints(f.ItemFrame)
        cf:SetID(KEYRING_CONTAINER)
        cf.GetBagID = cf.GetID
        cf.IsCombinedBagContainer = function() return true end
        f.ItemFrame.Containers[KEYRING_CONTAINER] = cf
    end

    -- anytime a ContainerFrame is populated with a backpack bagId, we rescan our buttons
    hooksecurefunc("ContainerFrame_GenerateFrame", function(_, _, id)
        if (id >= BACKPACK_CONTAINER and id <= (HAS_REAGENT_BAG and LAST_BAG_SLOT or NUM_BAG_SLOTS)) or (HAS_KEYRING and id == KEYRING_CONTAINER) then
            rescanBagContainers(f)
        end
    end)

    -- anytime a ContainerFrame is shown we set the stolen backpack button back to unchecked
    if ContainerFrame_OnShow then
        hooksecurefunc("ContainerFrame_OnShow", function()
            if MainMenuBarBackpackButton.SetChecked then
                MainMenuBarBackpackButton:SetChecked(false)
            end
            GW.SetItemButtonQualityForBags(MainMenuBarBackpackButton, 1)
        end)
    end

    -- create our backpack bag slots
    createBagBar(f.ItemFrame)

    -- skin some things not done in XML
    f.headerString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
    f.headerString:SetText(INVENTORY_TOOLTIP)
    f.spaceString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
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
    local bindings = GW.Retail and {"TOGGLEBACKPACK", "TOGGLEREAGENTBAG1", "TOGGLEBAG1", "TOGGLEBAG2", "TOGGLEBAG3", "TOGGLEBAG4"} or {"TOGGLEBAG1", "TOGGLEBAG2", "TOGGLEBAG3", "TOGGLEBAG4"}
    for _, b in pairs(bindings) do
        local key = GetBindingKey(b)
        if key then
            SetOverrideBinding(f, false, key, GW.Retail and "OPENALLBAGS" or "TOGGLEBACKPACK")
        end
    end

    -- setup settings button and its dropdown items
    f.buttonSort:HookScript(
        "OnClick",
        function()
            PlaySound(SOUNDKIT.UI_BAG_SORTING_01)
            if GW_SortBags then
                GW_SortBags()
            else
                C_Container.SortBags()
            end
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
                return check
            end

            addBagSliderControl(rootDescription, L["Icon Size"], inv.bagItemSizeConfig, function() return GW.settings.BAG_ITEM_SIZE end, setBagItemSize)
            addBagSliderControl(rootDescription, L["Slot Spacing X"], inv.bagItemSpacingXConfig, function() return GW.settings.BAG_ITEM_SPACING_X end, function(value) return setBagItemSpacing("BAG_ITEM_SPACING_X", inv.normalizeBagItemSpacingX, value) end)
            addBagSliderControl(rootDescription, L["Slot Spacing Y"], inv.bagItemSpacingYConfig, function() return GW.settings.BAG_ITEM_SPACING_Y end, function(value) return setBagItemSpacing("BAG_ITEM_SPACING_Y", inv.normalizeBagItemSpacingY, value) end)
            addCheck(L["Loot to leftmost Bag"], function() return GW.settings.BAG_REVERSE_NEW_LOOT end,
                     function() local ns = not GW.settings.BAG_REVERSE_NEW_LOOT; C_Container.SetInsertItemsLeftToRight(ns); GW.settings.BAG_REVERSE_NEW_LOOT = ns end)
            addCheck(L["Sort to Last Bag"], function() return GW.settings.BAG_ITEMS_REVERSE_SORT end,
                     function() local ns = not GW.settings.BAG_ITEMS_REVERSE_SORT; if GW.Retail then C_Container.SetSortBagsRightToLeft(ns) end; GW.settings.BAG_ITEMS_REVERSE_SORT = ns end)
            addCheck(L["Reverse Bag Order"], function() return GW.settings.BAG_REVERSE_SORT end,
                     function() GW.settings.BAG_REVERSE_SORT = not GW.settings.BAG_REVERSE_SORT; layoutItems(f); snapFrameSize(f) end)
            addCheck(L["Show Quality Color"], function() return GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW end,
                     function() GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW = not GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW; GW.UpdateAllOwnBagItemButtons() end)
            addCheck(L["Show Junk Icon"], function() return GW.settings.BAG_ITEM_JUNK_ICON_SHOW end,
                     function() GW.settings.BAG_ITEM_JUNK_ICON_SHOW = not GW.settings.BAG_ITEM_JUNK_ICON_SHOW; GW.UpdateAllOwnBagItemButtons() end)
            addCheck(L["Show Upgrade Icon"], function() return GW.settings.BAG_ITEM_UPGRADE_ICON_SHOW end,
                     function() GW.settings.BAG_ITEM_UPGRADE_ICON_SHOW = not GW.settings.BAG_ITEM_UPGRADE_ICON_SHOW; GW.UpdateAllOwnBagItemButtons() end)
            addCheck(L["Show Profession Bag Coloring"], function() return GW.settings.BAG_PROFESSION_BAG_COLOR end,
                     function() GW.settings.BAG_PROFESSION_BAG_COLOR = not GW.settings.BAG_PROFESSION_BAG_COLOR; GW.UpdateAllOwnBagItemButtons() end)
            addCheck(L["Show Quality Color for Profession Bags"], function() return GW.settings.BAG_PROFESSION_BAG_QUALITY_COLOR end,
                     function() GW.settings.BAG_PROFESSION_BAG_QUALITY_COLOR = not GW.settings.BAG_PROFESSION_BAG_QUALITY_COLOR; GW.UpdateAllOwnBagItemButtons() end)
            addCheck(SHOW_ITEM_LEVEL:gsub("-\n", ""):gsub("\n", " "), function() return GW.settings.BAG_SHOW_ILVL end,
                     function() GW.settings.BAG_SHOW_ILVL = not GW.settings.BAG_SHOW_ILVL; GW.UpdateAllOwnBagItemButtons() end)

            -- flavor specific entries (e.g. equipment set names on mists)
            callBagModules("onMenu", f, rootDescription, addCheck)

            addCheck(L["Separate bags"], function() return GW.settings.BAG_SEPARATE_BAGS end,
                     function() local ns = not GW.settings.BAG_SEPARATE_BAGS; GW.settings.BAG_SEPARATE_BAGS = ns; layoutItems(f); snapFrameSize(f) end)
            if HAS_KEYRING then
                local keyringCheck = addCheck(L["Separate keyring"], function() return GW.settings.BAG_SEPARATE_KEYRING end,
                         function() local ns = not GW.settings.BAG_SEPARATE_KEYRING; GW.settings.BAG_SEPARATE_KEYRING = ns; layoutItems(f); snapFrameSize(f) end)
                keyringCheck:SetEnabled(function() return not GW.settings.BAG_SEPARATE_BAGS end)
                keyringCheck:SetTooltip(function(tooltip, elementDescription)
                    tooltip:SetText(MenuUtil.GetElementText(elementDescription), 1, 1, 1)
                    tooltip:AddLine(L["Only available in the combined bag view"], 1, 1, 1, true)
                end)
            elseif HAS_REAGENT_BAG then
                local reagentCheck = addCheck(L["Separate reagent bag"], function() return GW.settings.BAG_SEPARATE_REAGENT_BAG end,
                         function() local ns = not GW.settings.BAG_SEPARATE_REAGENT_BAG; GW.settings.BAG_SEPARATE_REAGENT_BAG = ns; layoutItems(f); snapFrameSize(f) end)
                reagentCheck:SetEnabled(function() return not GW.settings.BAG_SEPARATE_BAGS end)
                reagentCheck:SetTooltip(function(tooltip, elementDescription)
                    tooltip:SetText(MenuUtil.GetElementText(elementDescription), 1, 1, 1)
                    tooltip:AddLine(L["Only available in the combined bag view"], 1, 1, 1, true)
                end)
            end
        end)
    end)

    -- setup money frame
    for _, frameName in ipairs({"bronze", "silver", "gold"}) do
        f[frameName]:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
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
        GW.MoneyOnEvent()
    end)
    f.moneyFrame:RegisterEvent("PLAYER_MONEY")
    if GW.Retail then
        f.moneyFrame:RegisterEvent("ACCOUNT_MONEY")
    end
    updateMoney(f)

    skinStackSplit()

    -- flavor specific extras once the frame is complete
    callBagModules("onLoadBag", f, core)

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
    smsj.text:SetText(L["Selling Junk"])

    f.smsj = smsj

    return changeItemSize
end
GW.LoadBag = LoadBag
