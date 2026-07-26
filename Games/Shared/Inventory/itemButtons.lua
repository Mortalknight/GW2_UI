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

-- vanilla container frames never show blizzards quest banners (ContainerFrame_UpdateQuestItem
-- only hides the texture there), the quest marking comes from our own quest icon instead;
-- on the other flavors only when the client actually provides the banner textures
local hasBlizzardQuestBanners = not GW.Classic and TEXTURE_ITEM_QUEST_BANG ~= nil and TEXTURE_ITEM_QUEST_BORDER ~= nil

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

    -- quest bang and border like blizzards ContainerFrame_UpdateQuestItem
    local questTexture = GetQuestTexture(button)
    if questTexture then
        if not hasBlizzardQuestBanners then
            questTexture:Hide()
        else
            local questInfo = C_Container.GetContainerItemQuestInfo(bagID, slotID)
            if questInfo.questID and not questInfo.isActive then
                questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG)
                questTexture:Show()
            elseif questInfo.questID or questInfo.isQuestItem then
                questTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER)
                questTexture:Show()
            else
                questTexture:Hide()
            end
        end
    end

    if texture then
        ContainerFrame_UpdateCooldown(bagID, button)
        button.hasItem = 1
    else
        if button.cooldown then
            button.cooldown:Hide()
        end
        button.hasItem = nil
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

local function EnsureItemButton(cf, index, iconSize)
    local button = cf.gw_items[index]
    if button then
        return button
    end

    local bagID = cf:GetID()
    local name = "GwContainerItem" .. (bagID >= 0 and bagID or ("N" .. -bagID)) .. "_" .. index
    button = CreateFrame("Button", name, cf, "ContainerFrameItemButtonTemplate")
    button.gwOwnItemButton = true

    -- the templates children are created by name, cache the ones we need
    button.cooldown = _G[name .. "Cooldown"]
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
-- in reverse like blizzards container frame buttons - the layouts iterate accordingly
local function SetupOwnContainerItemButtons(cf, bagID, iconSize, straightIDs)
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
        local button = EnsureItemButton(cf, i, iconSize)
        button:SetID(straightIDs and i or (numSlots - i + 1))
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
            ContainerFrame_UpdateCooldown(bagID, button)
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

-- the bag setting callbacks refresh via blizzards ContainerFrame_UpdateAll, which only updates
-- its own (parked) container frames - keep our visible buttons in sync; hidden ones get rebuilt
-- on the next open anyway (the function does not exist on retail anymore)
if ContainerFrame_UpdateAll then
    hooksecurefunc("ContainerFrame_UpdateAll", function()
        for i = 1, #allItemButtons do
            local button = allItemButtons[i]
            if button:IsVisible() then
                UpdateOwnContainerItemButton(button)
            end
        end
    end)
end
