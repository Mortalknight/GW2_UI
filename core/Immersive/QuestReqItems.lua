local _, GW = ...

GwQuestReqItemsFrameMixin = {}

function GwQuestReqItemsFrameMixin:HasRequiredItems()
    local qReq = self.questReq
    return (qReq.money > 0 or #qReq.currency > 0 or #qReq.stuff > 0)
end

function GwQuestReqItemsFrameMixin:UpdateFrame()
    local qReq = self.questReq
    -- this logic lifted from Blizzard_UIPanels_Game/Mainline/QuestFrame.lua :: QuestFrameProgressItems_Update()
    if qReq.money > 0 then
        MoneyFrame_Update(self.reqMoney, qReq.money)
        self.reqMoney:Show()
        self.reqItem1:ClearAllPoints()
        self.reqItem1:SetPoint("TOPLEFT", self.reqMoney, "BOTTOMLEFT", 0, -5)
    else
        self.reqItem1:ClearAllPoints()
        self.reqItem1:SetPoint("TOPLEFT", self.required, "BOTTOMLEFT", 5, -10)
    end

    local stuff = qReq.stuff
    for i = 1, #stuff do
        local f = self["reqItem" .. i]
        if f then
            f.type = "required"
            f.objectType = "item"
            f:SetID(i)
            local name, texture, numItems = stuff[i][1], stuff[i][2], stuff[i][3]
            SetItemButtonCount(f, numItems)
            SetItemButtonTexture(f, texture)
            f.Name:SetText(name)
            f:Show()
        end
    end

    local currency = qReq.currency
    local btnOffset = #stuff
    for i = 1, #currency do
        local btnIdx = i + btnOffset
        if btnIdx > 6 then
            break
        end
        local f = self["reqItem" .. btnIdx]
        if f then
            f.type = "required"
            f.objectType = "currency"
            f:SetID(i)
            local currencyInfo = currency[i]
            if currencyInfo then
                SetItemButtonCount(f, currencyInfo.requiredAmount)
                SetItemButtonTexture(f, currencyInfo.texture)
                f.Name:SetText(currencyInfo.name)
                f:Show()
            end
        end
    end
end

function GwQuestReqItemsFrameMixin:ClearInfo()
    if self.questReq then
        wipe(self.questReq.stuff)
        wipe(self.questReq.currency)
        self.questReq.money = 0
    else
        self.questReq = {
            stuff = {},
            currency = {},
            money = 0,
        }
    end
    self.reqMoney:Hide()
    for i = 1, 6, 1 do
        local f = self["reqItem" .. i]
        f:Hide()
    end
end

function GwQuestReqItemsFrameMixin:UpdateInfo()
    self:ClearInfo()
    self.questReq.money = GetQuestMoneyToGet()
    for i = GetNumQuestItems(), 1, -1 do
        if (IsQuestItemHidden(i) == 0) then
            tinsert(self.questReq.stuff, 1, {GetQuestItemInfo("required", i)})
        end
    end
    for i = (GW.Retail and GetNumQuestCurrencies() or 0), 1, -1 do
        tinsert(self.questReq.currency, 1, C_QuestOffer.GetQuestRequiredCurrencyInfo(i))
    end
end

function GwQuestReqItemsFrameMixin:OnLoad()
    self.required:SetFont("UNIT_NAME_FONT", 14)
    self.required:SetTextColor(1, 1, 1)
    self.required:SetShadowColor(0, 0, 0, 1)

    for i = 1, 6 do
        local button = self["reqItem" .. i]
        if button then
            GW.HandleItemReward(button, false)
            if button.IconBorder then
                button.IconBorder:Show()
            end
        end
    end

    self:ClearInfo()
end
