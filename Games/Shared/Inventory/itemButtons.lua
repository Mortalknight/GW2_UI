---@class GW2
local GW = select(2, ...)

--[[
    Own container item buttons.

    Replaces taking blizzards multi purpose ContainerFrameXItemY buttons, which fights with
    blizzards own layout and update code (anchor family errors, frame rotation, relayouts).
    The buttons inherit ContainerFrameItemButtonTemplate, so all click/drag/use/split/tooltip
    behavior keeps working through the inherited handlers, driven by the parents bag id
    (container:SetID) and the buttons slot id (button:SetID) - the same mechanism the taken
    buttons relied on. Only the content updates are done here via the C_Container api,
    mirroring blizzards ContainerFrame_Update.

    The buttons are stored in cf.gw_items with cf.gw_num_slots, so the existing layout code
    (layoutContainerFrame) keeps working unchanged. Like blizzards buttons, gw_items[1] gets
    the highest slot id, since the layout iterates the list backwards.
]]

local allItemButtons = {}

-- the skin repurposes the templates quest texture as our own quest icon on every
-- flavor (the retail default), the content update here only toggles it

-- blizzards cooldown helper only exists on the classic flavors
local function updateCooldown(bagID, button)
    if ContainerFrame_UpdateCooldown then
        ContainerFrame_UpdateCooldown(bagID, button)
        return
    end
    local cooldown = button.cooldown
    if not cooldown then
        return
    end
    local start, duration, enable = C_Container.GetContainerItemCooldown(bagID, button:GetID())
    CooldownFrame_Set(cooldown, start, duration, enable)
    if duration > 0 and enable == 0 then
        SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4)
    else
        SetItemButtonTextureVertexColor(button, 1, 1, 1)
    end
end

local function GetQuestTexture(button)
    if not button.IconQuestTexture then
        button.IconQuestTexture = _G[button:GetName() .. "IconQuestTexture"]
    end
    return button.IconQuestTexture
end

local function UpdateOwnContainerItemButton(button)
    local bagID = button:GetParent():GetID()
    local slotID = button:GetID()

    local info = C_Container.GetContainerItemInfo(bagID, slotID)
    local texture = info and info.iconFileID
    local itemCount = info and info.stackCount
    local locked = info and info.isLocked
    local quality = info and info.quality
    local readable = info and info.isReadable
    local isFiltered = info and info.isFiltered
    local itemID = info and info.itemID

    SetItemButtonTexture(button, texture)
    SetItemButtonQuality(button, quality, itemID)
    SetItemButtonCount(button, itemCount)
    SetItemButtonDesaturated(button, locked)

    -- toggle the quest icon (the skin owns the textures look)
    local questTexture = GetQuestTexture(button)
    if questTexture then
        local questInfo = C_Container.GetContainerItemQuestInfo(bagID, slotID)
        questTexture:SetShown(questInfo and (questInfo.questID ~= nil or questInfo.isQuestItem == true) or false)
    end

    if texture then
        updateCooldown(bagID, button)
        button.hasItem = 1
    else
        if button.cooldown then
            button.cooldown:Hide()
        end
        button.hasItem = nil
    end
    -- the retail button mixin tracks its item state itself
    if button.SetHasItem then
        button:SetHasItem(texture)
    end
    button.readable = readable

    if GameTooltip:IsOwned(button) then
        if info then
            button.UpdateTooltip(button)
        else
            GameTooltip:Hide()
        end
    end

    if button.searchOverlay then
        button.searchOverlay:SetShown(isFiltered == true)
    end
end
GW.UpdateOwnContainerItemButton = UpdateOwnContainerItemButton

local function EnsureItemButton(cf, index, iconSize, opts)
    local button = cf.gw_items[index]
    if button then
        return button
    end

    local bagID = cf:GetID()
    local name = "GwContainerItem" .. (bagID >= 0 and bagID or ("N" .. -bagID)) .. "_" .. index
    button = CreateFrame(opts and opts.frameType or "Button", name, cf, opts and opts.template or "ContainerFrameItemButtonTemplate")
    button.gwOwnItemButton = true

    -- the templates children are created by name on the classic flavors and by
    -- parent key on retail, cache the ones we need
    button.cooldown = _G[name .. "Cooldown"] or button.Cooldown
    GetQuestTexture(button)

    -- the extended slot advert and new item visuals of the template default to shown,
    -- blizzard hides them in its own update pass, so we do it once at creation
    if ContainerFrameItemButton_SetForceExtended then
        ContainerFrameItemButton_SetForceExtended(button, false)
    end
    if button.NewItemTexture then
        button.NewItemTexture:Hide()
    end
    if button.BattlepayItemTexture then
        button.BattlepayItemTexture:Hide()
    end

    if GW.SkinBagItemButton then
        GW.SkinBagItemButton(button, iconSize)
        button.__gwSkinned = true
    end

    cf.gw_items[index] = button
    allItemButtons[#allItemButtons + 1] = button
    return button
end

-- (re)builds the own item buttons of one of our containers to match the bags current size.
-- iconSize is only used for the initial skinning of newly created buttons. straightIDs assigns
-- the slot ids in list order like the old bank frame buttons, without it the ids are assigned
-- in reverse like blizzards container frame buttons - the layouts iterate accordingly.
-- opts can carry a frameType/template override and an initButton callback for buttons that
-- need more than the parent bag id and slot id (the retail bank item buttons)
local function SetupOwnContainerItemButtons(cf, bagID, iconSize, straightIDs, opts)
    if not cf then
        return
    end
    if not cf.gw_items then
        cf.gw_items = {}
    end

    -- the keyring only shows while its bag is open, like the old take logic
    local numSlots = 0
    if bagID ~= KEYRING_CONTAINER or IsBagOpen(KEYRING_CONTAINER) then
        numSlots = C_Container.GetContainerNumSlots(bagID)
    end
    cf.gw_num_slots = numSlots

    for i = 1, numSlots do
        local button = EnsureItemButton(cf, i, iconSize, opts)
        local slotID = straightIDs and i or (numSlots - i + 1)
        button:SetID(slotID)
        if opts and opts.initButton then
            opts.initButton(button, bagID, slotID)
        end
        button:Show()
        UpdateOwnContainerItemButton(button)
    end

    -- hide leftovers from a previously bigger bag
    for i = numSlots + 1, #cf.gw_items do
        cf.gw_items[i]:Hide()
    end
end
GW.SetupOwnContainerItemButtons = SetupOwnContainerItemButtons

local function UpdateOwnContainerItemButtons(cf)
    if not cf or not cf.gw_items then
        return
    end
    for i = 1, cf.gw_num_slots or 0 do
        local button = cf.gw_items[i]
        if button then
            UpdateOwnContainerItemButton(button)
        end
    end
end
GW.UpdateOwnContainerItemButtons = UpdateOwnContainerItemButtons

-- ITEM_LOCKED / ITEM_UNLOCKED, updates one slot or all when no slot is given
local function UpdateOwnContainerLockedState(cf, slotID)
    if not cf or not cf.gw_items then
        return
    end
    local bagID = cf:GetID()
    for i = 1, cf.gw_num_slots or 0 do
        local button = cf.gw_items[i]
        if button and (not slotID or button:GetID() == slotID) then
            local info = C_Container.GetContainerItemInfo(bagID, button:GetID())
            SetItemButtonDesaturated(button, info and info.isLocked)
        end
    end
end
GW.UpdateOwnContainerLockedState = UpdateOwnContainerLockedState

local function UpdateOwnContainerCooldowns(cf)
    if not cf or not cf.gw_items then
        return
    end
    local bagID = cf:GetID()
    for i = 1, cf.gw_num_slots or 0 do
        local button = cf.gw_items[i]
        if button and button.hasItem then
            updateCooldown(bagID, button)
        end
    end
end
GW.UpdateOwnContainerCooldowns = UpdateOwnContainerCooldowns

local function UpdateOwnContainerSearchResults(cf)
    if not cf or not cf.gw_items then
        return
    end
    local bagID = cf:GetID()
    for i = 1, cf.gw_num_slots or 0 do
        local button = cf.gw_items[i]
        if button and button.searchOverlay then
            local info = C_Container.GetContainerItemInfo(bagID, button:GetID())
            button.searchOverlay:SetShown((info and info.isFiltered) == true)
        end
    end
end
GW.UpdateOwnContainerSearchResults = UpdateOwnContainerSearchResults

-- used by the flavor reskin sweeps to apply size and style setting changes
local function ForEachOwnBagItemButton(func)
    for i = 1, #allItemButtons do
        func(allItemButtons[i])
    end
end
GW.ForEachOwnBagItemButton = ForEachOwnBagItemButton

-- central refresh for the bag/bank setting callbacks and integrations (e.g. pawn): updates
-- all visible own item buttons and keeps blizzards (parked) container frames in sync where
-- the function still exists; hidden buttons get rebuilt on the next open anyway
local function UpdateAllOwnBagItemButtons()
    if ContainerFrame_UpdateAll then
        ContainerFrame_UpdateAll()
    end
    for i = 1, #allItemButtons do
        local button = allItemButtons[i]
        if button:IsVisible() then
            UpdateOwnContainerItemButton(button)
        end
    end
end
GW.UpdateAllOwnBagItemButtons = UpdateAllOwnBagItemButtons
