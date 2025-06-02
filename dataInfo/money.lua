local _, GW = ...
local L = GW.L
local GetStorage = GW.GetStorage
local ClearStorage = GW.ClearStorage
local UpdateCharData = GW.UpdateCharData
local FormatMoneyForChat = GW.FormatMoneyForChat

local ALLIANCE_ICON = "|TInterface/AddOns/GW2_UI/Textures/social/GameIcons/Launcher/Alliance:13:13|t"
local HORDE_ICON = "|TInterface/AddOns/GW2_UI/Textures/social/GameIcons/Launcher/Horde:13:13|t"
local NEUTRAL_ICON = "|TInterface/Timer/Panda-Logo:14|t "

local function GetGraysValue()
    local total = 0
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                local _, _, rarity, _, _, itemType, _, _, _, _, itemPrice = C_Item.GetItemInfo(itemLink)
                if itemPrice and rarity == 0 and itemType ~= "Quest" then
                    local item = C_Container.GetContainerItemInfo(bag, slot)
                    total = total + itemPrice * (item.stackCount or 1)
                end
            end
        end
    end

    return total
end

local function Money_OnClick(self, button)
    if button == "RightButton" then
        if IsShiftKeyDown() then
            MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
                rootDescription:CreateTitle(DELETE)
                for _, char in pairs(GetStorage(nil, "REALM") or {}) do
                    if char and type(char) == "table" and char.money and char.money >= 0 then
                        rootDescription:CreateButton(format("%s - %s", char.name, char.faction), function()
                            ClearStorage(nil, char.name)
                            UpdateCharData()
                        end)
                    end
                end
            end)
        elseif IsControlKeyDown() then
            GW.earnedMoney = 0
            GW.spentMoney = 0
        end
        self:GetScript("OnEnter")(self)
    end

end
GW.Money_OnClick = Money_OnClick

local function Money_OnEnter(self)
    local list = GetStorage(nil, "REALM")
    if not list then return end

    local chars, totalAlliance, totalHorde, totalNeutral = {}, 0, 0, 0
    for _, char in pairs(list) do
        if char and type(char) == "table" and char.money and char.money >= 0 then
            local entry = {
                name = char.name,
                amount = char.money,
                class = char.class,
                faction = char.faction or "Neutral"
            }
            tinsert(chars, entry)

            if entry.faction == "Alliance" then
                totalAlliance = totalAlliance + entry.amount
            elseif entry.faction == "Horde" then
                totalHorde = totalHorde + entry.amount
            else
                totalNeutral = totalNeutral + entry.amount
            end
        end
    end

    sort(chars, function(a, b) return a.amount > b.amount end)

    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:ClearLines()

    GameTooltip:AddLine(L["Session:"])
    GameTooltip:AddDoubleLine(L["Earned:"], FormatMoneyForChat(GW.earnedMoney), 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine(L["Spent:"], FormatMoneyForChat(GW.spentMoney), 1, 1, 1, 1, 1, 1)

    local profit = GW.earnedMoney - GW.spentMoney
    if profit ~= 0 then
        local label = profit > 0 and L["Profit:"] or L["Deficit:"]
        local r, g = profit > 0 and 0 or 1, profit > 0 and 1 or 0
        GameTooltip:AddDoubleLine(label, FormatMoneyForChat(abs(profit)), r, g, 0, 1, 1, 1)
    end

    GameTooltip:AddLine(" ")

    -- list all players from the realm
    GameTooltip:AddLine(CHARACTER .. ":")
    for _, g in pairs(chars) do
        local color = GW.GWGetClassColor(g.class, true, true)
        local icon = g.faction == "Alliance" and ALLIANCE_ICON or g.faction == "Horde" and HORDE_ICON or NEUTRAL_ICON
        local label = format("%s%s", icon, g.name)
        if g.name == GW.myname then
            label = label .. " |TInterface/COMMON/Indicator-Green:14:14:0:-2|t"
        end
        GameTooltip:AddDoubleLine(label, FormatMoneyForChat(g.amount), color.r, color.g, color.b, 1, 1, 1)
    end

    -- add total gold on realm
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(FRIENDS_LIST_REALM)

    if totalAlliance > 0 and totalHorde > 0 then
        if totalAlliance > 0 then GameTooltip:AddDoubleLine(FACTION_ALLIANCE, FormatMoneyForChat(totalAlliance), GW.FACTION_COLOR[2].r, GW.FACTION_COLOR[2].g, GW.FACTION_COLOR[2].b, 1, 1, 1) end
        if totalHorde > 0 then GameTooltip:AddDoubleLine(FACTION_HORDE, FormatMoneyForChat(totalHorde), GW.FACTION_COLOR[1].r, GW.FACTION_COLOR[1].g, GW.FACTION_COLOR[1].b, 1, 1, 1) end
        GameTooltip:AddLine(" ")
    end

    GameTooltip:AddDoubleLine(TOTAL .. ":", FormatMoneyForChat(totalAlliance + totalHorde + totalNeutral), 1, 1, 1, 1, 1, 1)
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(L["Warband:"], FormatMoneyForChat(C_Bank.FetchDepositedMoney(Enum.BankType.Account) or 0), 1, 1, 1, 1, 1, 1)

    GameTooltip:AddLine(" ")
    C_WowTokenPublic.UpdateMarketPrice()
    GameTooltip:AddDoubleLine(TOKEN_FILTER_LABEL .. ":", FormatMoneyForChat(C_WowTokenPublic.GetCurrentMarketPrice() or 0), 0, 0.8, 1, 1, 1, 1)

    local grayValue = GetGraysValue()
    if grayValue > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(L["Grays"] , FormatMoneyForChat(grayValue), nil, nil, nil, 1, 1, 1)
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cffaaaaaa" .. L["Reset Session Data: Hold Ctrl + Right Click"] .. "|r")
    GameTooltip:AddLine("|cffaaaaaa" .. L["Reset Character Data: Hold Shift + Right Click"] .. "|r")

    GameTooltip:Show()
end
GW.Money_OnEnter = Money_OnEnter