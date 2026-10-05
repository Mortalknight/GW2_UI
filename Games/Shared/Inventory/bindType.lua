---@class GW2
local GW = select(2, ...)
local L = GW.L

local WARBAND_UNTIL_EQUIPPED = "WUE"
local BIND_TEXT = {
    [Enum.ItemBind and Enum.ItemBind.OnEquip or 2] = L["BoE"],
    [Enum.ItemBind and Enum.ItemBind.OnUse or 3] = L["BoU"],
    [Enum.ItemBind and Enum.ItemBind.ToBnetAccount or 8] = L["BoW"],
    [WARBAND_UNTIL_EQUIPPED] = L["WuE"],
}

local function GetBindText(button, itemIDOrLink)
    local bindType = select(14, C_Item.GetItemInfo(itemIDOrLink))
    if not bindType or not BIND_TEXT[bindType] then return end

    local bagID, slotID = button.gwBagID, button:GetID()
    local info = button.gwItemInfo or C_Container.GetContainerItemInfo(bagID, slotID)
    local location = ItemLocation:CreateFromBagAndSlot(bagID, slotID)
    if (info and info.isBound) or C_Item.IsBound(location) then return end

    if bindType == 2 and C_Item.IsBoundToAccountUntilEquip and C_Item.IsBoundToAccountUntilEquip(location) then
        return BIND_TEXT[WARBAND_UNTIL_EQUIPPED]
    end
    return BIND_TEXT[bindType]
end

GW.RegisterItemButtonDecorator(function(button, quality, itemIDOrLink)
    if not button.gwOwnItemButton then return end

    local text = GW.settings.bags.items.showBindType and GetBindText(button, itemIDOrLink)
    if text and not button.gwBindType then
        button.gwBindType = button:CreateFontString(nil, "OVERLAY")
        button.gwBindType:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
        button.gwBindType:SetPoint("TOP", 0, -2)
    end
    if button.gwBindType then
        local color = GW.GetQualityColor(quality or 1)
        button.gwBindType:SetTextColor(color.r, color.g, color.b)
        button.gwBindType:SetText(text or "")
    end
end)

GW.RegisterBagModule({
    onMenu = function(_, _, addCheck)
        addCheck(L["Show Bind Type"], function() return GW.settings.bags.items.showBindType end,
                 function() GW.settings.bags.items.showBindType = not GW.settings.bags.items.showBindType; GW.UpdateAllOwnBagItemButtons() end)
    end,
})
