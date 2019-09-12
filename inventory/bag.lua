local _, GW = ...
local CommaValue = GW.CommaValue
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local UpdateMoney = GW.UpdateMoney
local GetRealmMoney = GW.GetRealmMoney
local GetCharClass = GW.GetCharClass
local GetRealmStorage = GW.GetRealmStorage
local ClearStorage = GW.ClearStorage
local inv

local BAG_ITEM_SIZE = 40
local BAG_ITEM_LARGE_SIZE = 40
local BAG_ITEM_COMPACT_SIZE = 32
local BAG_ITEM_PADDING = 5
local BAG_WINDOW_SIZE = 480

-- adjusts the ItemButton layout flow when the bag window size changes (or on open)
local function layoutBagItems(f)
    local max_col = f:GetParent().gw_bag_cols
    local row = 0
    local col = 0
    local rev = GetSetting("BAG_REVERSE_SORT")

    local item_off = BAG_ITEM_SIZE + BAG_ITEM_PADDING

    local iS = BACKPACK_CONTAINER
    local iE = NUM_BAG_SLOTS
    local iD = 1
    if rev then
        iE = iS
        iS = NUM_BAG_SLOTS
        iD = -1
    end

    local lcf = inv.layoutContainerFrame
    for i = iS, iE, iD do
        local bag_id = i
        local cf = f.Containers[bag_id]
        col, row = lcf(cf, max_col, row, col, false, item_off)
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

local function watchCurrency(self)
    local watchSlot = 1
    local currencyCount = GetCurrencyListSize()
    for i = 1, currencyCount do
        local _, isHeader, _, _, isWatched, count, icon, _ = GetCurrencyListInfo(i)
        if not isHeader and isWatched and watchSlot < 4 then
            self["currency" .. tostring(watchSlot)]:SetText(count)
            self["currency" .. tostring(watchSlot) .. "Texture"]:SetTexture(icon)
            watchSlot = watchSlot + 1
        end
    end

    for i = watchSlot, 3 do
        self["currency" .. tostring(i)]:SetText("")
        self["currency" .. tostring(i) .. "Texture"]:SetTexture(nil)
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
        inv.takeItemButtons(f.ItemFrame, bag_id)
    end
    updateBagContainers(f)
end
GW.AddForProfiling("bag", "rescanBagContainers", rescanBagContainers)

-- draws the backpack bag slots in the correct order
local function setBagBarOrder(f)
    local x = -40
    local bag_size = 28
    local bag_padding = 4
    local rev = GetSetting("BAG_REVERSE_SORT")
    if rev then
        y = 5 - ((bag_size + bag_padding) * NUM_BAG_SLOTS)
    else
        y = 5
    end

    for bag_idx = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
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
GW.AddForProfiling("bag", "setBagBarOrder", setBagBarOrder)

local function bag_OnClick(self, button, down)
    -- on left click, ensure that the bag stays open despite default toggle behavior
    if button == "LeftButton" then
        if self.gwHasBag and not IsBagOpen(self:GetBagID()) then
            OpenBag(self:GetBagID())
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
    hooksecurefunc(
        "MainMenuBarBackpackButton_UpdateFreeSlots",
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
        local name = "GwInvntry" .. "Bag" .. (bag_idx - 1) .. "Slot"
        local b = CreateFrame("ItemButton", name, f, "GwBackpackBagTemplate")

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
    end
end
GW.AddForProfiling("bag", "updateBagBar", updateBagBar)

local function onBagResizeStop(self)
    BAG_WINDOW_SIZE = self:GetWidth()
    SetSetting("BAG_WIDTH", BAG_WINDOW_SIZE)
    inv.onMoved(self, "BAG_POSITION", snapFrameSize)
end
GW.AddForProfiling("bag", "onBagResizeStop", onBagResizeStop)

local function onBagFrameChangeSize(self, width, height, skip)
    local cols = inv.colCount(BAG_ITEM_SIZE, BAG_ITEM_PADDING, self:GetWidth())

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
        SetSetting("BAG_ITEM_SIZE", BAG_ITEM_SIZE)
        inv.resizeInventory()
        return GwLocalization["EXPAND_ICONS"]
    end

    BAG_ITEM_SIZE = BAG_ITEM_LARGE_SIZE
    SetSetting("BAG_ITEM_SIZE", BAG_ITEM_SIZE)
    inv.resizeInventory()
    return GwLocalization["COMPACT_ICONS"]
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
        if bag_id <= NUM_BAG_SLOTS and bag_id >= BACKPACK_CONTAINER then
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

local function LoadBag(helpers)
    inv = helpers

    BAG_WINDOW_SIZE = GetSetting("BAG_WIDTH")
    BAG_ITEM_SIZE = GetSetting("BAG_ITEM_SIZE")
    if BAG_ITEM_SIZE > 40 then
        BAG_ITEM_SIZE = 40
        SetSetting("BAG_ITEM_SIZE", 40)
    end

    -- create bag frame, restore its saved size, and init its many pieces
    local f = CreateFrame("Frame", "GwBagFrame", UIParent, "GwBagFrameTemplate")
    tinsert(UISpecialFrames, "GwBagFrame")
    f.gw_state = "closed"
    f:ClearAllPoints()
    f:SetWidth(BAG_WINDOW_SIZE)
    onBagFrameChangeSize(f, nil, nil, true)

    -- setup show/hide
    f:SetScript("OnShow", bag_OnShow)
    f:SetScript("OnHide", bag_OnHide)
    f.buttonClose:SetScript("OnClick", GW.Parent_Hide)

    -- setup movable stuff
    local pos = GetSetting("BAG_POSITION")
    f:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    f.mover:RegisterForDrag("LeftButton")
    f.mover.onMoveSetting = "BAG_POSITION"
    f.mover:SetScript("OnDragStart", inv.onMoverDragStart)
    f.mover:SetScript("OnDragStop", inv.onMoverDragStop)

    -- setup resizer stuff
    f:SetMinResize(508, 340)
    f:SetScript("OnSizeChanged", onBagFrameChangeSize)
    f.sizer.onResizeStop = onBagResizeStop
    f.sizer:SetScript("OnMouseDown", inv.onSizerMouseDown)
    f.sizer:SetScript("OnMouseUp", inv.onSizerMouseUp)

    -- take the original search box
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
        f.ItemFrame.Containers[bag_id] = cf
    end

    -- anytime a ContainerFrame is populated with a backpack bagId, we take its buttons
    hooksecurefunc("ContainerFrame_GenerateFrame", function(frame, size, id)
        if id >= BACKPACK_CONTAINER and id <= NUM_BAG_SLOTS then
            rescanBagContainers(f)
        end
    end)

    -- create our backpack bag slots
    createBagBar(f.ItemFrame)

    -- skin some things not done in XML
    f.headerString:SetFont(DAMAGE_TEXT_FONT, 24)
    f.headerString:SetText(INVENTORY_TOOLTIP)
    f.spaceString:SetFont(UNIT_NAME_FONT, 12)
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
        function(self)
            PlaySound(SOUNDKIT.UI_BAG_SORTING_01)
            SortBags()
        end
    )
    f.buttonSort:HookScript(
        "OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, -40)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(BAG_CLEANUP_BAGS, 1, 1, 1)
            GameTooltip:Show()
        end
    )
    f.buttonSort:HookScript("OnLeave", GameTooltip_Hide)
    do
        local dd = f.buttonSettings.dropdown
        f.buttonSettings:HookScript(
            "OnClick",
            function(self)
                if dd:IsShown() then
                    dd:Hide()
                else
                    dd:Show()
                end
            end
        )

        dd.compactBags:HookScript(
            "OnClick",
            function(self)
                self:SetText(compactToggle())
                dd:Hide()
            end
        )

        dd.newOrder:HookScript(
            "OnClick",
            function(self)
                if GetInsertItemsLeftToRight() then
                    dd.newOrder:SetText(GwLocalization["BAG_NEW_ORDER_LAST"])
                    SetInsertItemsLeftToRight(false)
                else
                    dd.newOrder:SetText(GwLocalization["BAG_NEW_ORDER_FIRST"])
                    SetInsertItemsLeftToRight(true)
                end
                dd:Hide()
            end
        )

        dd.sortOrder:HookScript(
            "OnClick",
            function(self)
                if GetSortBagsRightToLeft() then
                    dd.sortOrder:SetText(GwLocalization["BAG_SORT_ORDER_FIRST"])
                    SetSortBagsRightToLeft(false)
                else
                    dd.sortOrder:SetText(GwLocalization["BAG_SORT_ORDER_LAST"])
                    SetSortBagsRightToLeft(true)
                end
                dd:Hide()
            end
        )

        dd.bagOrder:HookScript(
            "OnClick",
            function(self)
                if GetSetting("BAG_REVERSE_SORT") then
                    dd.bagOrder:SetText(GwLocalization["BAG_ORDER_REVERSE"])
                    SetSetting("BAG_REVERSE_SORT", false)
                else
                    dd.bagOrder:SetText(GwLocalization["BAG_ORDER_NORMAL"])
                    SetSetting("BAG_REVERSE_SORT", true)
                end
                setBagBarOrder(f.ItemFrame)
                layoutItems(f)
                dd:Hide()
            end
        )

        dd.itemBorder:HookScript(
            "OnClick",
            function(self)
                if GetSetting("BAG_ITEM_BORDER_HIDE") then
                    dd.itemBorder:SetText(COLORBLIND_ITEM_QUALITY .. ": " .. GARRISON_DEACTIVATE_FOLLOWER)
                    SetSetting("BAG_ITEM_BORDER_HIDE", false)
                else
                    dd.itemBorder:SetText(COLORBLIND_ITEM_QUALITY .. ": " .. ACTIVATE)
                    SetSetting("BAG_ITEM_BORDER_HIDE", true)
                end
                setBagBarOrder(f.ItemFrame)
                layoutItems(f)
                dd:Hide()
            end
        )

        if BAG_ITEM_SIZE == BAG_ITEM_LARGE_SIZE then
            dd.compactBags:SetText(GwLocalization["COMPACT_ICONS"])
        else
            dd.compactBags:SetText(GwLocalization["EXPAND_ICONS"])
        end
        if GetInsertItemsLeftToRight() then
            dd.newOrder:SetText(GwLocalization["BAG_NEW_ORDER_FIRST"])
        else
            dd.newOrder:SetText(GwLocalization["BAG_NEW_ORDER_LAST"])
        end
        if GetSortBagsRightToLeft() then
            dd.sortOrder:SetText(GwLocalization["BAG_SORT_ORDER_LAST"])
        else
            dd.sortOrder:SetText(GwLocalization["BAG_SORT_ORDER_FIRST"])
        end
        if GetSetting("BAG_REVERSE_SORT") then
            dd.bagOrder:SetText(GwLocalization["BAG_ORDER_NORMAL"])
        else
            dd.bagOrder:SetText(GwLocalization["BAG_ORDER_REVERSE"])
        end
        if GetSetting("BAG_ITEM_BORDER_HIDE") then
            dd.itemBorder:SetText(COLORBLIND_ITEM_QUALITY .. ": " .. ACTIVATE)
        else
            dd.itemBorder:SetText(COLORBLIND_ITEM_QUALITY .. ": " .. GARRISON_DEACTIVATE_FOLLOWER)
        end
    end

    -- setup money frame
    f.bronze:SetFont(UNIT_NAME_FONT, 12)
    f.bronze:SetTextColor(177 / 255, 97 / 255, 34 / 255)
    f.silver:SetFont(UNIT_NAME_FONT, 12)
    f.silver:SetTextColor(170 / 255, 170 / 255, 170 / 255)
    f.gold:SetFont(UNIT_NAME_FONT, 12)
    f.gold:SetTextColor(221 / 255, 187 / 255, 68 / 255)

    -- money frame tooltip
    f.moneyFrame:SetScript(
        "OnEnter",
        function(self)
            local list, total = GetRealmMoney()
            if list then
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:ClearLines()

                -- list all players from the realm+faction
                local _, realm = UnitFullName("player")
                GameTooltip:AddDoubleLine(realm .. " " .. TOTAL, nil, nil, nil, 1, 1, 1)
                for name, money in pairs(list) do
                    local color = select(4, GetClassColor(GetCharClass(name)))
                    SetTooltipMoney(GameTooltip, money, "TOOLTIP", ("|c%s%s|r:"):format(color, name))
                end

                -- add total gold on realm+faction
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                SetTooltipMoney(GameTooltip, total, "TOOLTIP", TOTAL .. ":")

                GameTooltip:Show()

                -- align money frames to the right
                local maxWidth = 0
                for i = 1, GameTooltip.shownMoneyFrames do
                    local name = "GameTooltipMoneyFrame" .. i
                    local textWidth = _G[name .. "PrefixText"]:GetWidth()
                    local moneyWidth = select(4, _G[name .. "CopperButton"]:GetPoint(1))
                    maxWidth = max(maxWidth, textWidth + moneyWidth)
                end
                for i = 1, GameTooltip.shownMoneyFrames do
                    local name = "GameTooltipMoneyFrame" .. i
                    local textWidth = _G[name .. "PrefixText"]:GetWidth()
                    _G[name .. "CopperButton"]:SetPoint("RIGHT", name .. "PrefixText", "RIGHT", maxWidth - textWidth, 0)
                end
            end
        end
    )

    -- clear money storage on right-click
    f.moneyFrame:SetScript(
        "OnClick",
        function(self, button)
            if button == "RightButton" then
                ClearStorage(GetRealmStorage("MONEY"))
                UpdateMoney()
                self:GetScript("OnEnter")(self)
            end
        end
    )

    -- update money when applicable
    f.moneyFrame:SetScript(
        "OnEvent",
        function(self, event, ...)
            if not GW.inWorld then
                return
            end
            if event == "PLAYER_MONEY" then
                updateMoney(self:GetParent())
            end
        end
    )
    f.moneyFrame:RegisterEvent("PLAYER_MONEY")
    updateMoney(f)

    f.currency:SetScript(
        "OnClick",
        function(self, button)
            -- TODO: cannot do this properly until we make the whole bag frame secure
            if not InCombatLockdown() then
                ToggleCharacter("TokenFrame")
            end
        end
    )

    -- setup watch currencies
    f.currency1:SetFont(UNIT_NAME_FONT, 12)
    f.currency1:SetTextColor(1, 1, 1)
    f.currency2:SetFont(UNIT_NAME_FONT, 12)
    f.currency2:SetTextColor(1, 1, 1)
    f.currency3:SetFont(UNIT_NAME_FONT, 12)
    f.currency3:SetTextColor(1, 1, 1)

    f.currency:SetScript(
        "OnEvent",
        function(self, event, ...)
            if not GW.inWorld then
                return
            end
            if event == "CURRENCY_DISPLAY_UPDATE" then
                watchCurrency(self:GetParent())
            end
        end
    )
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
        BAG_ITEM_SIZE = GetSetting("BAG_ITEM_SIZE")
        layoutItems(f)
        snapFrameSize(f)
        -- TODO: update the text on the compact icons config option
    end
    return changeItemSize
end
GW.LoadBag = LoadBag
