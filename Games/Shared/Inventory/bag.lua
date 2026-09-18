---@class GW2
local GW = select(2, ...)
local L = GW.L
local UpdateMoney = GW.UpdateMoney
local EnableTooltip = GW.EnableTooltip
local inv

local GetInventorySlotInfo = C_PaperDollInfo and C_PaperDollInfo.GetInventorySlotInfo or GetInventorySlotInfo

-- the keyring exists on the classic flavors and on forever, the reagent bag on retail and
-- forever - forever is the one flavor that has both. The reagent bag is a real container
-- right behind the bags, the keyring has its own (negative) container id
local HAS_KEYRING = GW.Classic or GW.TBC or GW.Wrath or GW.Forever
local HAS_REAGENT_BAG = GW.isModern
local KEYRING_CONTAINER = (Enum.BagIndex and Enum.BagIndex.Keyring) or KEYRING_CONTAINER or -2
local REAGENT_CONTAINER = (Enum.BagIndex and Enum.BagIndex.ReagentBag) or (NUM_BAG_SLOTS + 1)
-- the last container id of the contiguous held bag range (backpack, bags, reagent bag)
local LAST_HELD_BAG = HAS_REAGENT_BAG and REAGENT_CONTAINER or NUM_BAG_SLOTS
-- the section headers of the separate view: the held bags use their container id as
-- header index, the extras follow behind them
local REAGENT_HEADER = NUM_BAG_SLOTS + 1
local KEYRING_HEADER = HAS_REAGENT_BAG and (NUM_BAG_SLOTS + 2) or (NUM_BAG_SLOTS + 1)

-- the sections of the bag frame in display order, one per container
local BAG_SECTIONS = {}
for bag_id = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
    BAG_SECTIONS[#BAG_SECTIONS + 1] = {id = bag_id, header = bag_id}
end
if HAS_REAGENT_BAG then
    BAG_SECTIONS[#BAG_SECTIONS + 1] = {id = REAGENT_CONTAINER, header = REAGENT_HEADER, isReagentBag = true}
end
if HAS_KEYRING then
    BAG_SECTIONS[#BAG_SECTIONS + 1] = {id = KEYRING_CONTAINER, header = KEYRING_HEADER, isKeyring = true}
end

-- whether a container id belongs to this bag frame
local function isOwnBagID(id)
    return (id >= BACKPACK_CONTAINER and id <= LAST_HELD_BAG) or (HAS_KEYRING and id == KEYRING_CONTAINER)
end

--[[
    Flavor modules.

    The shared bag core drives the bag bar, layout, events, settings and the frame itself.
    Flavor extras (e.g. the currency display on mists) plug in as modules, registered at
    file scope from the flavors inventory folder (the shared code loads before the flavor
    folders):

        GW.RegisterBagModule({
            onLoadBag = function(f) end,                             -- extras once the bag frame exists
            onMenu    = function(f, rootDescription, addCheck) end,  -- extra settings menu entries
        })
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

-- the equipped bag behind a header index: the bag slots for the bags, the reagent bag
-- slot for the reagent bag, nothing for the backpack and the keyring
local function getHeaderBagItemID(headerIndex)
    if headerIndex >= 1 and headerIndex <= NUM_BAG_SLOTS then
        return GetInventoryItemID("player", (GetInventorySlotInfo("Bag" .. headerIndex - 1 .. "Slot")))
    elseif HAS_REAGENT_BAG and headerIndex == REAGENT_HEADER then
        return GetInventoryItemID("player", (GetInventorySlotInfo("ReagentBag0Slot")))
    end
end

-- whether a section has anything to show a header for: the backpack and the keyring
-- always, the bags only while one is equipped in their slot
local function isSectionPresent(section)
    if section.id == BACKPACK_CONTAINER or section.isKeyring then
        return true
    end
    return getHeaderBagItemID(section.header) ~= nil
end

-- sets a headers text: the custom name if one is set, else the bag name in its quality color
local function setHeaderName(header, headerIndex)
    local customName = GW.settings.bags.bag.headerNames[headerIndex]
    if customName and strlen(customName) > 0 then
        header.nameString:SetText(customName)
        header.nameString:SetTextColor(1, 1, 1, 1)
    elseif headerIndex == BACKPACK_CONTAINER then
        header.nameString:SetText(BACKPACK_TOOLTIP)
        header.nameString:SetTextColor(1, 1, 1, 1)
    elseif HAS_KEYRING and headerIndex == KEYRING_HEADER then
        header.nameString:SetText(KEYRING)
        header.nameString:SetTextColor(1, 1, 1, 1)
    else
        local itemID = getHeaderBagItemID(headerIndex)
        local itemName, _, itemRarity
        if itemID then
            itemName, _, itemRarity = C_Item.GetItemInfo(itemID)
        end
        local r, g, b = 1, 1, 1
        if itemRarity then r, g, b = C_Item.GetItemQualityColor(itemRarity) end
        header.nameString:SetText(itemName or UNKNOWN)
        header.nameString:SetTextColor(r, g, b, 1)
    end
end

local function setBagHeaders(frame)
    for _, section in ipairs(BAG_SECTIONS) do
        setHeaderName(frame["bagHeader" .. section.header], section.header)
    end
end

-- the placeholders are always given an explicit bag range: the keyring is not a bag and
-- must never be a drop target, and bag index 5 would be a bank bag on the classic flavors
-- a free slot that actually accepts what is on the cursor: profession bags and the
-- reagent bag only take their own item family, family 0 means a plain bag
local function findFreeSlotForCursor(fromBag, toBag)
    local cursorType, cursorItemID = GetCursorInfo()
    local itemFamily = (cursorType == "item" and cursorItemID) and C_Item.GetItemFamily(cursorItemID) or 0

    for bag = fromBag, toBag do
        local free, family = C_Container.GetContainerNumFreeSlots(bag)
        if free and free > 0 and (not family or family == 0 or (itemFamily and itemFamily > 0 and bit.band(itemFamily, family) > 0)) then
            local slots = C_Container.GetContainerFreeSlots(bag)
            if slots and slots[1] then
                return bag, slots[1]
            end
        end
    end
end

local function countFreeSlots(fromBag, toBag)
    local free = 0
    for bag = fromBag, toBag do
        free = free + (C_Container.GetContainerNumFreeSlots(bag) or 0)
    end
    return free
end

-- each placeholder only serves its own section, so a drop lands where it belongs
local function emptySlot_OnClick(self)
    if not GetCursorInfo() then
        return
    end
    local bag, slot = findFreeSlotForCursor(self.gwFromBag, self.gwToBag)
    if bag then
        C_Container.PickupContainerItem(bag, slot)
    end
end

local function emptySlot_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip_SetTitle(GameTooltip, L["Free Slots"])
    GameTooltip:AddLine(tostring(countFreeSlots(self.gwFromBag, self.gwToBag)), 1, 1, 1)
    GameTooltip:Show()
end

-- one placeholder per section, created on first use: the bags get theirs at the end of
-- the bag rows, the reagent bag its own one behind its own rows
local function getEmptySlot(f, key)
    local slot = f[key]
    if slot then
        return slot
    end

    slot = CreateFrame("Button", nil, f)
    slot:RegisterForClicks("LeftButtonUp")
    slot.backdrop = slot:CreateTexture(nil, "BACKGROUND")
    slot.backdrop:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitembackdrop.png")
    slot.backdrop:SetAllPoints(slot)
    slot.border = slot:CreateTexture(nil, "ARTWORK")
    slot.border:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    slot.border:SetAllPoints(slot)
    slot.count = slot:CreateFontString(nil, "OVERLAY")
    slot.count:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
    slot.count:SetPoint("CENTER", slot, "CENTER", 0, 0)
    slot:SetScript("OnClick", emptySlot_OnClick)
    slot:SetScript("OnReceiveDrag", emptySlot_OnClick)
    slot:SetScript("OnEnter", emptySlot_OnEnter)
    slot:SetScript("OnLeave", GameTooltip_Hide)

    f[key] = slot
    return slot
end

-- closes a section with half a slot of air as separation, returns the new flow position
local function placeEmptySlot(f, key, fromBag, toBag, col, row, max_col, item_off_x, item_off_y)
    local slot = getEmptySlot(f, key)
    local gapX = item_off_x * 0.5
    if col >= max_col then
        col = 0
        row = row + 1
        gapX = 0
    end

    slot.gwFromBag, slot.gwToBag = fromBag, toBag
    slot:SetSize(GW.settings.bags.bag.itemSize, GW.settings.bags.bag.itemSize)
    slot:ClearAllPoints()
    slot:SetPoint("TOPLEFT", f, "TOPLEFT", col * item_off_x + gapX, -row * item_off_y)
    slot.count:SetText(countFreeSlots(fromBag, toBag))
    slot:Show()

    col = col + 1
    if col >= max_col then
        col = 0
        row = row + 1
    end
    return col, row
end

-- finishes a started row and adds `gap` rows of air, returns the new flow position
local function closeRow(col, row, gap)
    if col > 0 then
        col = 0
        row = row + 1
    end
    return col, row + (gap or 0)
end

-- adjusts the ItemButton layout flow when the bag window size changes (or on open)
local function layoutBagItems(f)
    local parent = f:GetParent()
    local settings = GW.settings.bags.bag
    local max_col = parent.gw_bag_cols
    if not max_col or not settings.itemSize or not settings.itemSpacingX or not settings.itemSpacingY then
        -- acedb can have the profile defaults detached (logout, profile operations)
        return
    end
    local rev = settings.reverseSort
    local sep = settings.separateBags
    -- an empty bag would collapse to nothing in the separate view and leave a header
    -- with no slots under it, so the compact flow only applies to the combined one
    local compact = settings.compactEmptySlots == true and not sep
    local item_off_x = settings.itemSize + settings.itemSpacingX
    local item_off_y = settings.itemSize + settings.itemSpacingY
    local lcf = inv.layoutContainerFrame

    local col, row = 0, 0
    local bagSlotPlaced = false
    local reagentSlotPlaced = false

    local numSections = #BAG_SECTIONS
    for n = 1, numSections do
        local section = BAG_SECTIONS[rev and (numSections - n + 1) or n]
        local cf = f.Containers[section.id]
        local header = parent["bagHeader" .. section.header]
        local hasSlots = cf.gw_num_slots > 0
        cf.gw_compact = compact

        if sep then
            -- one header row per present section, its items below while it is expanded
            local present = isSectionPresent(section)
            header:SetShown(present)
            if present then
                header:ClearAllPoints()
                header:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -row * item_off_y)
                header:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -row * item_off_y)
                row = row + 1
                if cf.shouldShow and hasSlots then
                    col, row = lcf(cf, max_col, row, 0, false, item_off_x, item_off_y)
                    col, row = closeRow(col, row)
                    cf:Show()
                else
                    cf:Hide()
                end
            else
                cf:Hide()
            end
        else
            header:Hide()
            -- combined flow; the extra sections (reagent bag, keyring) can be set off from
            -- the bags with half a row of air: above them in normal order, below reversed
            local setOff = hasSlots and (
                (section.isReagentBag and settings.separateReagentBag)
                or (section.isKeyring and settings.separateKeyring)
            )
            if setOff and not rev then
                -- close the bag rows with their own placeholder before the gap
                if compact and not bagSlotPlaced then
                    col, row = placeEmptySlot(f, "gwEmptySlot", BACKPACK_CONTAINER, NUM_BAG_SLOTS, col, row, max_col, item_off_x, item_off_y)
                    bagSlotPlaced = true
                end
                col, row = closeRow(col, row, 0.5)
            end
            col, row = lcf(cf, max_col, row, col, false, item_off_x, item_off_y)
            cf:Show()
            if compact and section.isReagentBag and hasSlots then
                col, row = placeEmptySlot(f, "gwEmptyReagentSlot", REAGENT_CONTAINER, REAGENT_CONTAINER, col, row, max_col, item_off_x, item_off_y)
                reagentSlotPlaced = true
            end
            if setOff and rev then
                col, row = closeRow(col, row, 0.5)
            end
        end
    end

    if compact and not bagSlotPlaced then
        col, row = placeEmptySlot(f, "gwEmptySlot", BACKPACK_CONTAINER, NUM_BAG_SLOTS, col, row, max_col, item_off_x, item_off_y)
    end
    if f.gwEmptySlot and not compact then
        f.gwEmptySlot:Hide()
    end
    if f.gwEmptyReagentSlot and not reagentSlotPlaced then
        f.gwEmptyReagentSlot:Hide()
    end

    -- the rows the layout actually used (headers, gaps and placeholders included),
    -- snapFrameSize sizes the frame by them
    parent.gw_layout_rows = row + (col > 0 and 1 or 0)

    if sep then
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
    inv.snapFrameSize(f, cfs, GW.settings.bags.bag.itemSize, GW.settings.bags.bag.itemSpacingX, GW.settings.bags.bag.itemSpacingY, 350)
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
    inv.updateFreeSlots(GwBagFrame.spaceString, 1, LAST_HELD_BAG, BACKPACK_CONTAINER)
end


-- A pure content change moves no button: the flow only depends on the slot counts, the layout
-- settings, the keyring state and - in compact mode, where empty slots drop out of the flow
-- (layoutContainerFrame) - on which slots are filled. This tracks that fingerprint so an item
-- update does not drag a full relayout of every button behind it. The bag frame is a singleton,
-- so one module wide state array is enough.
local lastLayoutState = {}
local function layoutStateChanged(f)
    local sep = GW.settings.bags.bag.separateBags
    local compact = GW.settings.bags.bag.compactEmptySlots == true and not sep
    local changed = false
    local idx = 1

    local flags = (sep and 1 or 0) + (compact and 2 or 0)
        + ((HAS_KEYRING and IsBagOpen(KEYRING_CONTAINER)) and 4 or 0)
    if lastLayoutState[idx] ~= flags then
        changed, lastLayoutState[idx] = true, flags
    end

    idx = idx + 1
    if lastLayoutState[idx] ~= f.gw_bag_cols then
        changed, lastLayoutState[idx] = true, f.gw_bag_cols
    end

    for _, section in ipairs(BAG_SECTIONS) do
        local cf = f.ItemFrame.Containers[section.id]
        local numSlots = cf and cf.gw_num_slots or 0

        idx = idx + 1
        if lastLayoutState[idx] ~= numSlots then
            changed, lastLayoutState[idx] = true, numSlots
        end

        -- outside of compact mode the empty slots stay in the flow, so which ones hold an
        -- item makes no difference for the layout and does not need to be tracked
        local filled = -1
        if compact and cf and cf.gw_items then
            filled = 0
            for slot = 1, numSlots do
                local button = cf.gw_items[slot]
                if button and button.hasItem then
                    filled = filled + 1
                end
            end
        end

        idx = idx + 1
        if lastLayoutState[idx] ~= filled then
            changed, lastLayoutState[idx] = true, filled
        end
    end

    return changed
end

local function invalidateLayoutState()
    wipe(lastLayoutState)
end


-- update all backpack bag items
local function updateBagContainers(f)
    if f.ItemFrame:IsShown() then
        updateFreeBagSlots()
        if layoutStateChanged(f) then
            layoutItems(f)
            snapFrameSize(f)
        end
    end
end


-- rescan bag ItemButtons; without dirtyBags every container is rescanned, with it only the
-- ones a BAG_UPDATE named - a looted or used item touches one bag, not all of them
local function rescanBagContainers(f, dirtyBags)
    if f.gw_suppressRescan then
        -- a batch of bags is being opened, whoever opens them rescans once at the end
        return
    end
    if not dirtyBags then
        -- the callers of the full rescan are the structural ones (open, bag un/equipped,
        -- keyring toggled): those also change things the layout fingerprint cannot see, like
        -- the header name of a swapped bag, so they always lay out
        invalidateLayoutState()
    end
    for _, section in ipairs(BAG_SECTIONS) do
        if not dirtyBags or dirtyBags[section.id] then
            GW.SetupOwnContainerItemButtons(f.ItemFrame.Containers[section.id], section.id)
        end
    end
    updateBagContainers(f)
end


local function bag_OnClick(self, button)
    -- on left click, ensure that the bag stays open despite default toggle behavior;
    -- on retail a held item is put into the bag first
    if button == "LeftButton" then
        if GW.isModern then
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
    local open = IsBagOpen(KEYRING_CONTAINER)
    GWkeyringbutton.border:SetShown(open)
    GWkeyringbutton.IconBorder:SetShown(not open)

    local header = GwBagFrame and GwBagFrame["bagHeader" .. KEYRING_HEADER]
    if header then
        header.icon:SetShown(open)
        header.icon2:SetShown(not open)
    end
end

-- toggles the keyring bag and brings its button and header in line with the new state;
-- shared by the keyring button and its bag header, which both offer the toggle
local function setKeyringOpen(f, open)
    f.ItemFrame.Containers[KEYRING_CONTAINER].shouldShow = open
    if open then
        OpenBag(KEYRING_CONTAINER)
    else
        CloseBag(KEYRING_CONTAINER)
        rescanBagContainers(f)
    end
    updateKeyringButtonState()
end


-- creates the keyring toggle button for a flavors bag bar, positioning is up to the caller
local function createKeyringButton(f)
    local parent = f:GetParent()
    local b = CreateFrame("Button", "GWkeyringbutton", f, "GwKeyRingButtonTemp")
    b:SetHighlightTexture('Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png')
    GW.SetItemButtonQualityForBags(b, 1)
    b:SetScript("OnClick",
        function()
            setKeyringOpen(parent, not IsBagOpen(KEYRING_CONTAINER))
        end
    )
    return b
end


-- draws the backpack bag slots in the correct order
local function setBagBarOrder(f)
    local x = -40
    local bag_size = 28
    local bag_padding = 4
    local rev = GW.settings.bags.bag.reverseSort
    -- f.bags runs from the backpack at 0 through the bag slots to the extras, # gives the last
    local last = #f.bags
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

        f.bags[bag_idx] = b
    end

    if HAS_REAGENT_BAG then
        -- steal the reagent bag slot button; like the bags it sits at its container id
        local b = CharacterReagentBag0Slot
        b:SetParent(f)
        if b.SetChecked then
            b:SetChecked(false)
        end
        b:RegisterForClicks("LeftButtonUp")
        b:SetScript("OnClick", bag_OnClick)
        b:SetScript("OnMouseDown", inv.bag_OnMouseDown)
        inv.reskinBagBar(b)
        f.bags[REAGENT_CONTAINER] = b
    end
    if HAS_KEYRING then
        -- the keyring is not a bag, its toggle goes behind the bag slots
        f.bags[#f.bags + 1] = createKeyringButton(f)
    end

    setBagBarOrder(f)
end


-- updates the contents of the backpack bag slots
local function updateBagBar(f)
    for bag_idx = 1, LAST_HELD_BAG do
        local b = f.bags[bag_idx]
        local inv_id = C_Container.ContainerIDToInventoryID(bag_idx)
        local bag_tex = GetInventoryItemTexture("player", inv_id)
        local _, slot_tex = GetInventorySlotInfo("Bag" .. bag_idx)

        b.icon:Show()
        b.gwHasBag = false -- flag used by OnClick hook to pop up context menu when valid
        local norm = b:GetNormalTexture()
        if norm then
            norm:SetVertexColor(1, 1, 1, 0.75)
        end
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
        local bagLink = GetInventoryItemLink("player", inv_id)
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
    self:RegisterEvent("QUEST_ACCEPTED")
    self:RegisterEvent("QUEST_REMOVED")
    -- every OpenBag makes blizzard build its container frame, and our hook on that
    -- answers with a full rescan of all containers - opening the whole set would rescan
    -- everything once per bag before the single rescan below does it once more
    self.gw_suppressRescan = true
    if not IsBagOpen(BACKPACK_CONTAINER) then
        OpenBackpack()
    end
    for i = 1, LAST_HELD_BAG do
        if not IsBagOpen(i) then
            OpenBag(i)
        end
    end
    self.gw_suppressRescan = false

    updateKeyringButtonState()
    updateBagBar(self.ItemFrame)
    rescanBagContainers(self)

    if GW.settings.bags.autoSortOnOpen then
        -- the sort button's path, minus its click sound
        if GW_SortBags then GW_SortBags() else C_Container.SortBags() end
    end
end


local function bag_OnHide(self)
    PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
    -- closed by hand (or by anything else): the auto open no longer owns this bag,
    -- so the matching close event must not re-close it later
    self.gwAutoOpenedContext = nil
    self:UnregisterAllEvents()
    if C_NewItems and C_NewItems.ClearAll then
        -- blizzards container frames did this on hide, ours have to now
        C_NewItems.ClearAll()
        -- the slot contents did not change, only their new item state, so the remembered
        -- state has to be dropped for the markers to go on the next open
        GW.InvalidateOwnBagItemButtonStates()
    end
    if BagItemSearchBox then
        -- blizzard leaves the filter active when the bags close, which then hides items
        -- on the next open with no visible reason; SetText drives the templates
        -- OnTextChanged so the item search is really dropped, not just the display
        BagItemSearchBox:SetText("")
        BagItemSearchBox:ClearFocus()
    end
    -- should an error ever leave the batch flag set, closing the bag recovers from it
    self.gw_suppressRescan = false
    wipe(self.gw_dirtyBags)
    self.gw_need_bag_update = false
    self.gw_need_bag_rescan = false
    for i = 1, LAST_HELD_BAG do
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
    -- Containers only holds the ids this flavor actually uses
    return bag and self.ItemFrame.Containers[bag] or nil
end

local function bag_OnEvent(self, event, ...)
    if event == "ITEM_LOCKED" or event == "ITEM_UNLOCKED" then
        -- check if the item un/locked is a character bag and gray it out if so
        local bag = select(1, ...)
        local slot = select(2, ...)
        local cb0_id = CharacterBag0Slot:GetID()

        if slot == nil and bag >= cb0_id and bag <= cb0_id + LAST_HELD_BAG then
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
        if bag_id and isOwnBagID(bag_id) then
            self.gw_dirtyBags[bag_id] = true
            self.gw_need_bag_update = true
        end
    elseif event == "QUEST_ACCEPTED" or event == "QUEST_REMOVED" then
        -- an items quest marker can change without the item itself changing, and the content
        -- updates only look at the container api, so those two need an explicit refresh
        GW.UpdateAllOwnBagItemButtons()
    elseif event == "BAG_UPDATE_DELAYED" then
        if self.gw_need_bag_rescan then
            self.gw_suppressRescan = true
            for bag_id = 1, LAST_HELD_BAG do
                if not IsBagOpen(bag_id) then
                    OpenBag(bag_id)
                end
            end
            if HAS_KEYRING and not IsBagOpen(KEYRING_CONTAINER) then
                OpenBag(KEYRING_CONTAINER)
            end
            self.gw_suppressRescan = false

            updateBagBar(self.ItemFrame)
            updateKeyringButtonState()
        end
        if self.gw_need_bag_rescan or self.gw_need_bag_update then
            -- a bag itself changed (added, removed, swapped): every container can have shifted,
            -- so that case keeps the full rescan
            rescanBagContainers(self, not self.gw_need_bag_rescan and self.gw_dirtyBags or nil)
        end
        wipe(self.gw_dirtyBags)
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
    -- the header id is the section header index; the keyring aside, that is the container id
    local headerIndex = self:GetID()
    if btn == "LeftButton" then
        if HAS_KEYRING and headerIndex == KEYRING_HEADER then
            setKeyringOpen(self:GetParent(), not IsBagOpen(KEYRING_CONTAINER))
        else
            self:GetParent().ItemFrame.Containers[headerIndex].shouldShow = not self.icon:IsShown()
            self.icon:SetShown(not self.icon:IsShown())
            self.icon2:SetShown(not self.icon:IsShown())
        end

        layoutItems(self:GetParent())
        snapFrameSize(self:GetParent())
    elseif btn == "RightButton" then
        GW.ShowPopup({text = L["New Bag Name"],
            OnAccept = function(promptFrame)
                GW.settings.bags.bag.headerNames[headerIndex] = promptFrame.input:GetText()
                setHeaderName(self, headerIndex)
            end,
            hasEditBox = true,
            button1 = SAVE,
            button2 = RESET,
            EditBoxOnEscapePressed = function(popup) popup:Hide() end,
            OnCancel = function()
                GW.settings.bags.bag.headerNames[headerIndex] = ""
                setHeaderName(self, headerIndex)
            end,
            -- the header already shows the effective name (custom or the bags own)
            inputText = self.nameString:GetText()
        })
    end
end

local function bagHeader_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, -45)
    GameTooltip:ClearLines()
    GameTooltip_SetTitle(GameTooltip, L["Right click to customize the bag title."])
    GameTooltip:Show()
end

local function onBagResizeStop(self)
    GW.settings.bags.bag.width = self:GetWidth()
    GwBagFrame.Header:SetWidth(GW.settings.bags.bag.width)
    inv.onMoved(self, "bag", snapFrameSize)
end


local function onBagFrameChangeSize(self, _, _, skip)
    self.Header:SetWidth(self:GetWidth())

    local size = GW.settings.bags.bag.itemSize
    local spacing = GW.settings.bags.bag.itemSpacingX
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

-- Opens the bag with its interaction window (merchant, mail, auction house, bank, trade)
-- and closes it again with it. Only what the auto open opened is closed: a bag the player
-- opened stays, and the ownership dies as soon as the bag is closed by hand (see OnHide).
-- OpenAllBags/CloseAllBags on purpose - they keep Blizzards open state bookkeeping in sync
-- with the hooks this bag is driven by.
local AUTO_OPEN_EVENTS = {
    MERCHANT_SHOW = "merchant", MERCHANT_CLOSED = "merchant",
    MAIL_SHOW = "mail", MAIL_CLOSED = "mail",
    AUCTION_HOUSE_SHOW = "auctionHouse", AUCTION_HOUSE_CLOSED = "auctionHouse",
    BANKFRAME_OPENED = "bank", BANKFRAME_CLOSED = "bank",
    TRADE_SHOW = "trade", TRADE_CLOSED = "trade",
}

local function setupAutoOpenClose(f)
    local watcher = CreateFrame("Frame")
    for event in pairs(AUTO_OPEN_EVENTS) do
        watcher:RegisterEvent(event)
    end
    watcher:SetScript("OnEvent", function(_, event)
        local context = AUTO_OPEN_EVENTS[event]
        local isOpen = not event:find("_CLOSED", 1, true)

        if isOpen then
            -- an already visible bag was opened by someone else, leave it theirs
            if GW.settings.bags.autoOpenContexts[context] and not f:IsShown() then
                f.gwAutoOpenedContext = context
                OpenAllBags()
            end
        elseif f.gwAutoOpenedContext == context then
            f.gwAutoOpenedContext = nil
            if f:IsShown() then
                CloseAllBags()
            end
        end
    end)
end

local function LoadBag(helpers)
    inv = helpers

    -- create bag frame, restore its saved size, and init its many pieces
    local f = CreateFrame("Frame", "GwBagFrame", UIParent, "GwBagFrameTemplate")
    tinsert(UISpecialFrames, "GwBagFrame")
    -- the bag ids a BAG_UPDATE named since the last BAG_UPDATE_DELAYED
    f.gw_dirtyBags = {}
    f:ClearAllPoints()
    f:SetWidth(GW.settings.bags.bag.width)
    f.Header:SetWidth(GW.settings.bags.bag.width)
    onBagFrameChangeSize(f, nil, nil, true)
    f:SetClampedToScreen(true)
    f:SetClampRectInsets(-f.Left:GetWidth(), 0, f.Header:GetHeight() - 10, -35)

    -- setup show/hide
    f:SetScript("OnShow", bag_OnShow)
    f:SetScript("OnHide", bag_OnHide)
    setupAutoOpenClose(f)
    f.buttonClose:SetScript("OnClick", GW.Parent_Hide)

    -- setup movable stuff
    local pos = GW.settings.bags.bag.pos
    f:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    f.mover:RegisterForDrag("LeftButton")
    f.mover.onMoveSetting = "bag"
    f.mover:SetScript("OnDragStart", inv.onMoverDragStart)
    f.mover:SetScript("OnDragStop", inv.onMoverDragStop)

    -- setup resizer stuff
    f:SetResizeBounds(340, 340)
    f:SetScript("OnSizeChanged", onBagFrameChangeSize)
    f.sizer.onResizeStop = onBagResizeStop
    f.sizer:SetScript("OnMouseDown", inv.onSizerMouseDown)
    f.sizer:SetScript("OnMouseUp", inv.onSizerMouseUp)

    -- setup bagheader stuff; the template ships headers for every section any flavor
    -- has (bags, reagent bag, keyring), the ones a flavor does not use never show
    local headerIndex = 0
    while f["bagHeader" .. headerIndex] do
        local header = f["bagHeader" .. headerIndex]
        header.nameString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        header.nameString:SetTextColor(1, 1, 1)
        header.nameString:SetShadowColor(0, 0, 0, 0)
        if HAS_KEYRING and headerIndex == KEYRING_HEADER then
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
    for _, section in ipairs(BAG_SECTIONS) do
        local cf = CreateFrame("Frame", nil, f.ItemFrame)
        cf.gw_items = {}
        cf.gw_num_slots = 0
        cf:SetAllPoints(f.ItemFrame)
        cf:SetID(section.id)
        -- the keyring starts collapsed, it only shows while its bag is open
        cf.shouldShow = not section.isKeyring
        -- the retail item button mixin asks its parent for these
        cf.GetBagID = cf.GetID
        cf.IsCombinedBagContainer = function() return true end
        f.ItemFrame.Containers[section.id] = cf
    end

    -- anytime a ContainerFrame is populated with one of our bagIds, we rescan our buttons
    hooksecurefunc("ContainerFrame_GenerateFrame", function(_, _, id)
        if id and isOwnBagID(id) then
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
    local bindings = GW.isModern and {"TOGGLEBACKPACK", "TOGGLEREAGENTBAG1", "TOGGLEBAG1", "TOGGLEBAG2", "TOGGLEBAG3", "TOGGLEBAG4"} or {"TOGGLEBAG1", "TOGGLEBAG2", "TOGGLEBAG3", "TOGGLEBAG4"}
    for _, b in pairs(bindings) do
        local key = GetBindingKey(b)
        if key then
            SetOverrideBinding(f, false, key, GW.isModern and "OPENALLBAGS" or "TOGGLEBACKPACK")
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

            rootDescription:CreateTitle(L["Layout"])
            inv.addItemSizeMenuEntries(rootDescription, "BAG")
            addCheck(L["Reverse Bag Order"], function() return GW.settings.bags.bag.reverseSort end,
                     function() GW.settings.bags.bag.reverseSort = not GW.settings.bags.bag.reverseSort; layoutItems(f); snapFrameSize(f) end)

            rootDescription:CreateTitle(L["Item Display"])
            addCheck(L["Show Quality Color"], function() return GW.settings.bags.items.qualityBorder end,
                     function() GW.settings.bags.items.qualityBorder = not GW.settings.bags.items.qualityBorder; GW.UpdateAllOwnBagItemButtons() end)
            local compactCheck = addCheck(L["Hide Empty Slots"], function() return GW.settings.bags.bag.compactEmptySlots end,
                     function() GW.settings.bags.bag.compactEmptySlots = not GW.settings.bags.bag.compactEmptySlots; layoutItems(f); snapFrameSize(f) end)
            compactCheck:SetEnabled(function() return not GW.settings.bags.bag.separateBags end)
            compactCheck:SetTooltip(function(tooltip, elementDescription)
                tooltip:SetText(MenuUtil.GetElementText(elementDescription), 1, 1, 1)
                tooltip:AddLine(L["Only available in the combined bag view"], 1, 1, 1, true)
            end)
            if C_NewItems and C_NewItems.IsNewItem then
                addCheck(L["Mark New Items"], function() return GW.settings.bags.items.newItemGlow end,
                         function() GW.settings.bags.items.newItemGlow = not GW.settings.bags.items.newItemGlow; GW.UpdateAllOwnBagItemButtons() end)
            end
            addCheck(L["Mark Unusable Items"], function() return GW.settings.bags.items.markUnusable end,
                     function() GW.settings.bags.items.markUnusable = not GW.settings.bags.items.markUnusable; GW.UpdateAllOwnBagItemButtons() end)
            addCheck(L["Grey out Junk"], function() return GW.settings.bags.items.junkDesaturate end,
                     function() GW.settings.bags.items.junkDesaturate = not GW.settings.bags.items.junkDesaturate; GW.UpdateAllOwnBagItemButtons() end)
            addCheck(L["Show Junk Icon"], function() return GW.settings.bags.items.junkIcon end,
                     function() GW.settings.bags.items.junkIcon = not GW.settings.bags.items.junkIcon; GW.UpdateAllOwnBagItemButtons() end)
            addCheck(L["Show Upgrade Icon"], function() return GW.settings.bags.items.upgradeIcon end,
                     function() GW.settings.bags.items.upgradeIcon = not GW.settings.bags.items.upgradeIcon; GW.UpdateAllOwnBagItemButtons() end)
            addCheck(L["Show Profession Bag Coloring"], function() return GW.settings.bags.professionBagColor end,
                     function() GW.settings.bags.professionBagColor = not GW.settings.bags.professionBagColor; GW.UpdateAllOwnBagItemButtons() end)
            addCheck(L["Show Quality Color for Profession Bags"], function() return GW.settings.bags.professionBagQualityColor end,
                     function() GW.settings.bags.professionBagQualityColor = not GW.settings.bags.professionBagQualityColor; GW.UpdateAllOwnBagItemButtons() end)
            addCheck(SHOW_ITEM_LEVEL:gsub("-\n", ""):gsub("\n", " "), function() return GW.settings.bags.items.showItemLevel end,
                     function() GW.settings.bags.items.showItemLevel = not GW.settings.bags.items.showItemLevel; GW.UpdateAllOwnBagItemButtons() end)
            GW.AddMenuSliderDescription(rootDescription, {
                title = L["Item Level Threshold"],
                minValue = 0,
                maxValue = 1000,
                step = 10,
                getValue = function() return GW.settings.bags.items.levelThreshold end,
                setValue = function(value)
                    value = math.floor(value + 0.5)
                    if GW.settings.bags.items.levelThreshold ~= value then
                        GW.settings.bags.items.levelThreshold = value
                        GW.UpdateAllOwnBagItemButtons()
                    end
                    return value
                end
            })


            -- flavor item display entries (scrap icon on retail, equipment set names on mists)
            callBagModules("onMenu", f, rootDescription, addCheck)

            rootDescription:CreateTitle(L["Loot & Sorting"])
            addCheck(L["Loot to leftmost Bag"], function() return GW.settings.bags.bag.reverseNewLoot end,
                     function() local ns = not GW.settings.bags.bag.reverseNewLoot; C_Container.SetInsertItemsLeftToRight(ns); GW.settings.bags.bag.reverseNewLoot = ns end)
            addCheck(L["Sort to Last Bag"], function() return GW.settings.bags.bag.reverseItemSort end,
                     function() local ns = not GW.settings.bags.bag.reverseItemSort; if GW.isModern then C_Container.SetSortBagsRightToLeft(ns) end; GW.settings.bags.bag.reverseItemSort = ns end)

            addCheck(L["Sort when opening"], function() return GW.settings.bags.autoSortOnOpen end,
                     function() GW.settings.bags.autoSortOnOpen = not GW.settings.bags.autoSortOnOpen end)



            rootDescription:CreateTitle(L["Behavior"])
            local autoOpenMenu = rootDescription:CreateButton(L["Open automatically at"])
            for _, context in ipairs({
                {key = "merchant", label = MERCHANT},
                {key = "mail", label = MAIL_LABEL},
                {key = "auctionHouse", label = AUCTIONS},
                {key = "bank", label = BANK},
                {key = "trade", label = TRADE},
            }) do
                local check = autoOpenMenu:CreateCheckbox(context.label,
                    function() return GW.settings.bags.autoOpenContexts[context.key] end,
                    function() GW.settings.bags.autoOpenContexts[context.key] = not GW.settings.bags.autoOpenContexts[context.key] end)
                check:AddInitializer(function(button, description, menu)
                    GW.BlizzardDropdownCheckButtonInitializer(button, description, menu,
                        function() return GW.settings.bags.autoOpenContexts[context.key] end)
                end)
            end

            rootDescription:CreateTitle(L["Bag Sections"])
            addCheck(L["Separate bags"], function() return GW.settings.bags.bag.separateBags end,
                     function() local ns = not GW.settings.bags.bag.separateBags; GW.settings.bags.bag.separateBags = ns; layoutItems(f); snapFrameSize(f) end)
            if HAS_KEYRING then
                local keyringCheck = addCheck(L["Separate keyring"], function() return GW.settings.bags.bag.separateKeyring end,
                         function() local ns = not GW.settings.bags.bag.separateKeyring; GW.settings.bags.bag.separateKeyring = ns; layoutItems(f); snapFrameSize(f) end)
                keyringCheck:SetEnabled(function() return not GW.settings.bags.bag.separateBags end)
                keyringCheck:SetTooltip(function(tooltip, elementDescription)
                    tooltip:SetText(MenuUtil.GetElementText(elementDescription), 1, 1, 1)
                    tooltip:AddLine(L["Only available in the combined bag view"], 1, 1, 1, true)
                end)
            end
            if HAS_REAGENT_BAG then
                local reagentCheck = addCheck(L["Separate reagent bag"], function() return GW.settings.bags.bag.separateReagentBag end,
                         function() local ns = not GW.settings.bags.bag.separateReagentBag; GW.settings.bags.bag.separateReagentBag = ns; layoutItems(f); snapFrameSize(f) end)
                reagentCheck:SetEnabled(function() return not GW.settings.bags.bag.separateBags end)
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
    f.moneyFrame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end
        if GW.inWorld then
            updateMoney(self:GetParent())
        end
        GW.MoneyOnEvent()
    end)
    f.moneyFrame:RegisterEvent("PLAYER_MONEY")
    f.moneyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    if GW.isModern then
        f.moneyFrame:RegisterEvent("ACCOUNT_MONEY")
    end
    updateMoney(f)

    skinStackSplit()

    -- flavor specific extras once the frame is complete
    callBagModules("onLoadBag", f)

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
