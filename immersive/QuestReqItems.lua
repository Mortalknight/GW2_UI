local _, GW = ...

local HandleReward = GW.HandleReward

GwQuestReqItemsFrameMixin = {}
local ReqItemsMixin = GwQuestReqItemsFrameMixin

function ReqItemsMixin:HasRequiredItems()
    local qReq = self.questReq
    return (qReq["money"] > 0 or #qReq["currency"] > 0 or #qReq["stuff"] > 0)
end

function ReqItemsMixin:UpdateFrame()
    local qReq = self.questReq
    -- this logic lifted from Blizzard_UIPanels_Game/Mainline/QuestFrame.lua :: QuestFrameProgressItems_Update()
    if qReq["money"] > 0 then
        MoneyFrame_Update(self.reqMoney, qReq["money"])
        self.reqMoney:Show()
        self.reqItem1:ClearAllPoints()
        self.reqItem1:SetPoint("TOPLEFT", self.reqMoney, "BOTTOMLEFT", 0, -5)
    else
        self.reqItem1:ClearAllPoints()
        self.reqItem1:SetPoint("TOPLEFT", self.required, "BOTTOMLEFT", 5, -10)
    end

    for i = 1, #qReq["stuff"], 1 do
        local f = self["reqItem" .. i]
        f.type = "required"
        f.objectType = "item"
        f:SetID(i)
        local name = qReq["stuff"][i][1]
        local texture = qReq["stuff"][i][2]
        local numItems = qReq["stuff"][i][3]
        SetItemButtonCount(f, numItems)
        SetItemButtonTexture(f, texture)
        f.Name:SetText(name)
        f:Show()
    end

    local btnOffset = #qReq["stuff"]
    for i = 1, #qReq["currency"], 1 do
        local btnIdx = i + btnOffset
        if btnIdx > 6 then
            break
        end
        local f = self["reqItem" .. btnIdx]
        f.type = "required"
        f.objectType = "currency"
        f:SetID(i)
        if qReq["currency"][i] then
            SetItemButtonCount(f, qReq["currency"][i].requiredAmount)
            SetItemButtonTexture(f, qReq["currency"][i].texture)
            f.Name:SetText(qReq["currency"][i].name)
            f:Show()
        end
    end
end

function ReqItemsMixin:ClearInfo()
    if (self.questReq) then
        wipe(self.questReq.stuff)
        wipe(self.questReq.currency)
        self.questReq.money = 0
    else
        self.questReq = {
            ["stuff"] = {},
            ["currency"] = {},
            ["money"] = 0
        }
    end
    self.reqMoney:Hide()
    for i = 1, 6, 1 do
        local f = self["reqItem" .. i]
        f:Hide()
    end
end

function ReqItemsMixin:UpdateInfo()
    self:ClearInfo()
    self.questReq["money"] = GetQuestMoneyToGet()
    for i = GetNumQuestItems(), 1, -1 do
        if (IsQuestItemHidden(i) == 0) then
            tinsert(self.questReq["stuff"], 1, {GetQuestItemInfo("required", i)})
        end
    end
    for i = GetNumQuestCurrencies(), 1, -1 do
        tinsert(self.questReq["currency"], 1, C_QuestOffer.GetQuestRequiredCurrencyInfo(i))
    end
end

function ReqItemsMixin:OnLoad()
    self.required:SetFont("UNIT_NAME_FONT", 14)
    self.required:SetTextColor(1, 1, 1)
    self.required:SetShadowColor(0, 0, 0, 1)

    for i = 1, 6 do
        local button = self["reqItem" .. i]
        if button then
            HandleReward(button, false)
            if button.IconBorder then
                button.IconBorder:Show()
            end
        end
    end

    self:ClearInfo()
end
