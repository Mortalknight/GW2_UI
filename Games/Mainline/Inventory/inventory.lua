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

-- scrappable item icon
GW.RegisterItemButtonDecorator(function(button, _, _)
    if not button.scrapIcon then
        return
    end
    if GW.settings.BAG_ITEM_SCRAP_ICON_SHOW then
        local itemLoc = ItemLocation:CreateFromBagAndSlot(button.bagID, button:GetID())
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

local function getContainerFrame(bag_id)
    -- ContainerFrame assignment is not guaranteed; only safe approach is to
    -- search every ContainerFrame and check its ID for a match.
    for i = 1, NUM_CONTAINER_FRAMES do
        local cf = _G["ContainerFrame" .. i]
        if cf and cf:GetID() == bag_id then
            return cf
        end
    end

    return nil
end

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
        local cf = getContainerFrame(bag_id)
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
