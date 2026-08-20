---@class GW2
local GW = select(2, ...)

--[[
    Retail extras for the shared inventory: the item button skin itself is the shared
    central one now; retail only contributes decorators (azerite/corruption overlays,
    the scrap icon) and its own bag filter/cleanup menus.
]]

-- azerite and corrupted item overlays
GW.RegisterItemButtonDecorator(function(button, _, itemIDOrLink, suppressOverlays)
    if suppressOverlays then
        return
    end
    if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemIDOrLink) then
        button.IconOverlay:SetAtlas("AzeriteIconFrame")
        button.IconOverlay:Show()
    elseif C_Item.IsCorruptedItem(itemIDOrLink) then
        button.IconOverlay:SetAtlas("Nzoth-inventory-icon")
        button.IconOverlay:Show()
    end
end)

-- Equipment set marker: the set's OWN icon in the top right corner, so the marker also
-- says WHICH set the item belongs to. Matched by exact bag/slot location, not by item id -
-- a second copy of the same item is not part of the set. The location map is rebuilt
-- lazily and dropped whenever items move or the sets change.
local setItemLocations

local function RebuildSetItemLocations()
    setItemLocations = {}
    for _, setID in ipairs(C_EquipmentSet.GetEquipmentSetIDs()) do
        local _, setIcon = C_EquipmentSet.GetEquipmentSetInfo(setID)
        local locations = C_EquipmentSet.GetItemLocations(setID)
        if locations then
            for _, location in pairs(locations) do
                if location and location > 0 then
                    local locationData = EquipmentManager_GetLocationData(location)
                    if locationData.isBags and locationData.bag and locationData.slot then
                        setItemLocations[locationData.bag .. ":" .. locationData.slot] = setIcon or 134400
                    end
                end
            end
        end
    end
end

local setWatcher = CreateFrame("Frame")
setWatcher:RegisterEvent("EQUIPMENT_SETS_CHANGED")
setWatcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
setWatcher:RegisterEvent("BAG_UPDATE_DELAYED")
setWatcher:SetScript("OnEvent", function() setItemLocations = nil end)

local function SetEquipSetIconShown(button, shown)
    if button.gwEquipSetIcon then
        button.gwEquipSetIcon:SetShown(shown)
        button.gwEquipSetIconBorder:SetShown(shown)
    end
end

GW.RegisterItemButtonDecorator(function(button)
    if not GW.settings.BAG_ITEM_EQUIPMENT_SET_ICON_SHOW then
        SetEquipSetIconShown(button, false)
        return
    end

    if not setItemLocations then
        RebuildSetItemLocations()
    end

    local bagID = button.gwBagID or (button.GetBagID and button:GetBagID())
    local setIcon = bagID and setItemLocations[bagID .. ":" .. button:GetID()]
    if not setIcon then
        SetEquipSetIconShown(button, false)
        return
    end

    if not button.gwEquipSetIcon then
        button.gwEquipSetIcon = button:CreateTexture(nil, "OVERLAY", nil, 3)
        button.gwEquipSetIcon:SetSize(14, 14)
        button.gwEquipSetIcon:SetPoint("TOPRIGHT", -2, -2)
        button.gwEquipSetIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        -- dark backdrop one pixel around the icon: without it the mini icon drowns
        -- in the item art below
        button.gwEquipSetIconBorder = button:CreateTexture(nil, "OVERLAY", nil, 2)
        button.gwEquipSetIconBorder:SetColorTexture(0, 0, 0, 0.9)
        button.gwEquipSetIconBorder:SetPoint("TOPLEFT", button.gwEquipSetIcon, "TOPLEFT", -1, 1)
        button.gwEquipSetIconBorder:SetPoint("BOTTOMRIGHT", button.gwEquipSetIcon, "BOTTOMRIGHT", 1, -1)
    end
    button.gwEquipSetIcon:SetTexture(setIcon)
    SetEquipSetIconShown(button, true)
end)

-- scrappable item icon
GW.RegisterItemButtonDecorator(function(button, _, _)
    if not button.scrapIcon then
        return
    end
    if GW.settings.BAG_ITEM_SCRAP_ICON_SHOW then
        local itemLoc = ItemLocation:CreateFromBagAndSlot(button.gwBagID or button:GetBagID(), button:GetID())
        if itemLoc and itemLoc ~= "" then
            if C_Item.DoesItemExist(itemLoc) and C_Item.CanScrapItem(itemLoc) then
                button.scrapIcon:SetShown(itemLoc)
            else
                button.scrapIcon:SetShown(false)
            end
        end
    else
        button.scrapIcon:SetShown(false)
    end
end)

local function ContainerFrame_IsHeldBag(id)
    return id >= Enum.BagIndex.Backpack and id <= NUM_TOTAL_BAG_FRAMES;
end


local function ContainerFrame_IsCharacterBankTab(id)
	return id >= Enum.BagIndex.CharacterBankTab_1 and id <= Enum.BagIndex.CharacterBankTab_6
end


local function ContainerFrame_IsAccountBankTab(id)
	return id >= Enum.BagIndex.AccountBankTab_1 and id <= Enum.BagIndex.AccountBankTab_5;
end


local function ContainerFrame_IsBankTab(id)
    return ContainerFrame_IsCharacterBankTab(id) or ContainerFrame_IsAccountBankTab(id)
end


local function ContainerFrame_IsBackpack(id)
    return id == Enum.BagIndex.Backpack;
end


local function AddButtons_BagFilters(description, bagID)
    if not ContainerFrame_CanContainerUseFilterMenu(bagID) then
        return
    end

    description:CreateTitle(BAG_FILTER_ASSIGN_TO)

    local function IsSelected(flag)
        return C_Container.GetBagSlotFlag(bagID, flag)
    end

    local function SetSelected(flag)
        local value = not IsSelected(flag)
        C_Container.SetBagSlotFlag(bagID, flag, value)
        ContainerFrameSettingsManager:SetFilterFlag(bagID, flag, value)
    end

    for i, flag in ContainerFrameUtil_EnumerateBagGearFilters() do
        local checkbox = description:CreateCheckbox(BAG_FILTER_LABELS[flag], IsSelected, SetSelected, flag)
        checkbox:SetResponse(MenuResponse.Close)
        checkbox:AddInitializer(GW.BlizzardDropdownCheckButtonInitializer)
    end
end


local function AddButtons_BagCleanup(description, bagID)
    description:CreateTitle(BAG_FILTER_IGNORE);

    do
        local function IsSelected()
            if ContainerFrame_IsBackpack(bagID) then
                return C_Container.GetBackpackAutosortDisabled();
            end
            return C_Container.GetBagSlotFlag(bagID, Enum.BagSlotFlags.DisableAutoSort);
        end

        local function SetSelected()
            local value = not IsSelected();
            if ContainerFrame_IsBackpack(bagID) then
                C_Container.SetBackpackAutosortDisabled(value);
            else
                C_Container.SetBagSlotFlag(bagID, Enum.BagSlotFlags.DisableAutoSort, value);
            end
        end

        local checkbox = description:CreateCheckbox(BAG_FILTER_CLEANUP, IsSelected, SetSelected);
        checkbox:SetResponse(MenuResponse.Close)
        checkbox:AddInitializer(GW.BlizzardDropdownCheckButtonInitializer)
    end

    -- ignore junk selling from this bag or backpack
    if not ContainerFrame_IsBankTab(bagID) then
        local function IsSelected()
            if ContainerFrame_IsBackpack(bagID) then
                return C_Container.GetBackpackSellJunkDisabled();
            end
            return C_Container.GetBagSlotFlag(bagID, Enum.BagSlotFlags.ExcludeJunkSell);
        end

        local function SetSelected()
            local value = not IsSelected();
            if ContainerFrame_IsBackpack(bagID) then
                C_Container.SetBackpackSellJunkDisabled(value);
            else
                C_Container.SetBagSlotFlag(bagID, Enum.BagSlotFlags.ExcludeJunkSell, value);
            end
        end

        local checkbox = description:CreateCheckbox(SELL_ALL_JUNK_ITEMS_EXCLUDE_FLAG, IsSelected, SetSelected);
        checkbox:SetResponse(MenuResponse.Close);
        checkbox:AddInitializer(GW.BlizzardDropdownCheckButtonInitializer)
    end
end


local function bag_OnMouseDown(self, button)
    if button ~= "RightButton" then
        return
    end
    if not self.GetBagID then
        return
    end

    local bag_id = self:GetBagID()
    if self.gwHasBag or bag_id == BACKPACK_CONTAINER then
        local cf = GW.GetBagContainerFrame(bag_id)
        if cf then
            MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
                rootDescription:SetMinimumWidth(1)
                if not (ContainerFrame_IsHeldBag(bag_id) or ContainerFrame_IsBankTab(bag_id)) then
                    return
                end

                AddButtons_BagFilters(rootDescription, bag_id);
                AddButtons_BagCleanup(rootDescription, bag_id);
            end)
        end
    end
end


GW.BagSlotOnMouseDown = bag_OnMouseDown
