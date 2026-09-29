---@class GW2
local GW = select(2, ...)
local L = GW.L
local Tooltip = GW.Tooltip

local LEGACY_KEYSTONE_ITEM = "138019"
local COMPARISON_TOOLTIPS = {}

local function Label(text, value)
    return format("%s%s|r %s", GW.Gw2Color, text, value)
end

-- keystone:item:map:level:affix...; the old keystone item carries its affixes further back.
-- a trailing value below 2 is a flag, not an affix
local function GetKeystoneAffixes(link)
    local fields = {strsplit(":", link)}
    local first = strfind(fields[1], "keystone", 1, true) and 5 or (strfind(fields[1], "item", 1, true) and fields[2] == LEGACY_KEYSTONE_ITEM and 17)
    if not first then
        return
    end
    local affixes = {}
    for i = first, #fields do
        local affixID = tonumber(strmatch(fields[i], "^(%d+)"))
        if affixID then
            tinsert(affixes, affixID)
        end
    end
    if affixes[#affixes] and affixes[#affixes] < 2 then
        tremove(affixes)
    end
    return affixes
end

local function AddKeystoneAffixes(tooltip, link)
    if not (C_ChallengeMode and GW.settings.tooltip.unit.keystoneInfo) or type(link) ~= "string" then
        return
    end
    local affixes = GetKeystoneAffixes(link)
    for _, affixID in ipairs(affixes or {}) do
        local name, description = C_ChallengeMode.GetAffixInfo(affixID)
        if name and description then
            tooltip:AddLine(format("|cff00ff00%s|r - %s", name, description), 0, 1, 0, true)
        end
    end
    if affixes then
        tooltip:Show()
    end
end

-- the classic craft window hands out empty item names for its reagents
local function GetCraftReagentLink(tooltip)
    local owner = tooltip:GetOwner()
    local ownerName = owner and owner.GetName and owner:GetName()
    local reagentIndex = ownerName and tonumber(strmatch(ownerName, "Reagent(%d+)"))
    return reagentIndex and GetCraftReagentItemLink(GetCraftSelectionIndex(), reagentIndex)
end

-- what the bags and the bank hold of it and how far it stacks, with the id modifier its id
local function GetCountLines(link)
    local lines = {}
    local settings = GW.settings.tooltip.item
    local inBags = C_Item.GetItemCount(link)
    if settings.count.Bag then
        tinsert(lines, Label(INVENTORY_TOOLTIP, inBags))
    end
    if settings.count.Bank then
        local total = C_Item.GetItemCount(link, true, nil, settings.countIncludeReagents, settings.countIncludeWarband)
        if total and total > inBags then
            tinsert(lines, Label(BANK, total - inBags))
        end
    end
    if settings.count.Stack then
        local stackSize = select(8, C_Item.GetItemInfo(link))
        if stackSize and stackSize > 1 then
            tinsert(lines, Label(L["Stack Size"], stackSize))
        end
    end
    return lines
end

local function OnItemTooltip(tooltip, data)
    if not COMPARISON_TOOLTIPS[tooltip] or tooltip:IsForbidden() then
        return
    end

    local GetItem = TooltipUtil and TooltipUtil.GetDisplayedItem or tooltip.GetItem
    local name, link = GetItem(tooltip)
    if GW.IsSecretValue(name) or GW.IsSecretValue(link) then
        return
    end
    if name == "" and CraftFrame and CraftFrame:IsShown() then
        link = GetCraftReagentLink(tooltip)
    end

    local itemID = data and GW.NotSecretValue(data.id) and data.id or link and strmatch(link, ":(%w+)")
    local idText = itemID and Tooltip.IsModifierDown() and Label(ID, itemID)
    local counts = link and GetCountLines(link) or {}
    if idText or #counts > 0 then
        tooltip:AddLine(" ")
        for i = 1, math.max(1, #counts) do
            tooltip:AddDoubleLine(i == 1 and idText or " ", counts[i] or " ")
        end
    end

    AddKeystoneAffixes(tooltip, link)
end

GW.RegisterTooltipModule({
    onLoad = function()
        COMPARISON_TOOLTIPS[GameTooltip] = true
        COMPARISON_TOOLTIPS[ShoppingTooltip1] = true
        COMPARISON_TOOLTIPS[ShoppingTooltip2] = true
        Tooltip.OnTooltipData("Item", OnItemTooltip)

        -- keystone chat links are no items
        local function OnHyperlink(tooltip, link)
            if not tooltip:IsForbidden() and GW.NotSecretValue(link) and type(link) == "string" and strfind(link, "keystone:", 1, true) then
                AddKeystoneAffixes(tooltip, link)
            end
        end
        hooksecurefunc(GameTooltip, "SetHyperlink", OnHyperlink)
        hooksecurefunc(ItemRefTooltip, "SetHyperlink", OnHyperlink)

        -- one plain sell price line instead of the money frame
        if TooltipDataProcessor and TooltipDataProcessor.AddLinePreCall and GW.isModern then
            TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.SellPrice, function(tooltip, lineData)
                tooltip:AddLine(SELL_PRICE .. ": " .. GetMoneyString(lineData.price), WHITE_FONT_COLOR:GetRGB())
                return true
            end)
        end
    end,
})
