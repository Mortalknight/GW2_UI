local _, GW = ...
local L = GW.L
local GetStorage = GW.GetStorage
local ClearStorage = GW.ClearStorage
local UpdateCharData = GW.UpdateCharData
local FormatMoneyForChat = GW.FormatMoneyForChat

local function GetGraysValue()
    local value = 0

    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                local _, _, rarity, _, _, itype, _, _, _, _, itemPrice = C_Item.GetItemInfo(itemLink)
                if itemPrice then
                    local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                    local stackPrice = itemPrice * (itemInfo.stackCount or 1)
                    if rarity and rarity == 0 and (itype and itype ~= "Quest") and (stackPrice > 0) then
                        value = value + stackPrice
                    end
                end
            end
        end
    end

    return value
end

local function Money_OnClick(self, button)
    if button == "RightButton" then
        if IsShiftKeyDown() then
            MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
                rootDescription:CreateTitle(DELETE)

                local list = GetStorage(nil, "REALM")
                if list then
                    for _, char in pairs(list) do
                        if char and type(char) == "table" then
                            if char.money and char.money >= 0 then
                                rootDescription:CreateButton(format("%s - %s", char.name, char.faction), function()
                                    ClearStorage(nil, char.name)
                                        UpdateCharData()
                                end)
                            end
                        end
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
    local myGold = {}
    local list = GetStorage(nil, "REALM")
    local totalAlliance, totalHorde, totalFactionless = 0, 0, 0
    local resetCountersFormatter = strjoin("", "|cffaaaaaa", L["Reset Session Data: Hold Ctrl + Right Click"], "|r")
    local resetInfoFormatter = strjoin("", "|cffaaaaaa", L["Reset Character Data: Hold Shift + Right Click"], "|r")

    if list then
        for _, char in pairs(list) do
            if char and type(char) == "table" then
                if char.money and char.money >= 0 then
                    tinsert(myGold,
                    {
                        name = char.name,
                        amount = char.money,
                        class = char.class,
                        faction = char.faction
                    })
                    if char.faction and char.faction == "Alliance" then
                        totalAlliance = totalAlliance + char.money
                    elseif char.faction and char.faction == "Horde" then
                        totalHorde = totalHorde + char.money
                    else
                        totalFactionless = totalFactionless + char.money
                    end
                end
            end
        end

        sort(myGold, function(a, b)
            return a.amount > b.amount
        end)

        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:ClearLines()

        GameTooltip:AddLine(L["Session:"])
        GameTooltip:AddDoubleLine(L["Earned:"], FormatMoneyForChat(GW.earnedMoney), 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine(L["Spent:"], FormatMoneyForChat(GW.spentMoney), 1, 1, 1, 1, 1, 1)
        if GW.earnedMoney < GW.spentMoney then
            GameTooltip:AddDoubleLine(L["Deficit:"], FormatMoneyForChat(GW.earnedMoney - GW.spentMoney), 1, 0, 0, 1, 1, 1)
        elseif (GW.earnedMoney - GW.spentMoney) > 0 then
            GameTooltip:AddDoubleLine(L["Profit:"], FormatMoneyForChat(GW.earnedMoney - GW.spentMoney), 0, 1, 0, 1, 1, 1)
        end
        GameTooltip:AddLine(" ")

        -- list all players from the realm
        GameTooltip:AddLine(CHARACTER .. ":")
        for _, g in pairs(myGold) do
            local color = GW.GWGetClassColor(g.class, true, true)
            local factionTexture = ""
            if g.faction and g.faction ~= "" and g.faction ~= "Neutral" then
                factionTexture = format("|TInterface/FriendsFrame/PlusManz-%s:14|t ", g.faction)
            elseif g.faction and g.faction ~= "" and g.faction == "Neutral" then
                factionTexture = "|TInterface/Timer/Panda-Logo:14|t "
            end

            local toonName = format("%s%s", factionTexture, g.name)
            GameTooltip:AddDoubleLine((g.name == GW.myname and toonName .. " |TInterface/COMMON/Indicator-Green:14:14:0:-2|t") or toonName, FormatMoneyForChat(g.amount), color.r, color.g, color.b, 1, 1, 1)
        end

        -- add total gold on realm
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(FRIENDS_LIST_REALM)

        if totalAlliance > 0 and totalHorde > 0 then
            if totalAlliance ~= 0 then GameTooltip:AddDoubleLine(FACTION_ALLIANCE, FormatMoneyForChat(totalAlliance), GW.FACTION_COLOR[2].r, GW.FACTION_COLOR[2].g, GW.FACTION_COLOR[2].b, 1, 1, 1) end
            if totalHorde ~= 0 then GameTooltip:AddDoubleLine(FACTION_HORDE, FormatMoneyForChat(totalHorde), GW.FACTION_COLOR[1].r, GW.FACTION_COLOR[1].g, GW.FACTION_COLOR[1].b, 1, 1, 1) end
            GameTooltip:AddLine(" ")
        end

        GameTooltip:AddDoubleLine(TOTAL .. ":", FormatMoneyForChat(totalAlliance + totalHorde + totalFactionless), 1, 1, 1, 1, 1, 1)
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
        GameTooltip:AddLine(resetCountersFormatter)
        GameTooltip:AddLine(resetInfoFormatter)

        GameTooltip:Show()
    end
end
GW.Money_OnEnter = Money_OnEnter