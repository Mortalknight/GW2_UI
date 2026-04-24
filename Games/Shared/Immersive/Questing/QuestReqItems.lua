---@class GW2
local GW = select(2, ...)

GwImmersiveQuestingReqItemsFrameMixin = {}

function GwImmersiveQuestingReqItemsFrameMixin:HasRequiredItems()
    local qReq = self.questReq
    return (qReq.money > 0 or #qReq.currency > 0 or #qReq.stuff > 0)
end

function GwImmersiveQuestingReqItemsFrameMixin:UpdateFrame()
    local qReq = self.questReq
    -- this logic lifted from Blizzard_UIPanels_Game/Mainline/QuestFrame.lua :: QuestFrameProgressItems_Update()
    if qReq["money"] > 0 then
        MoneyFrame_Update(self.reqMoney, qReq.money)
        self.reqMoney:Show()
        self.reqItem1:ClearAllPoints()
        self.reqItem1:SetPoint("TOPLEFT", self.reqMoney, "BOTTOMLEFT", 0, -5)
    else
        self.reqItem1:ClearAllPoints()
        self.reqItem1:SetPoint("TOPLEFT", self.required, "BOTTOMLEFT", 5, -10)
    end

    for i = 1, #qReq.stuff do
        local f = self["reqItem" .. i]
        local r = qReq.stuff[i]

        f.type = "required"
        f.objectType = "item"
        f:SetID(i)
        SetItemButtonCount(f, r.count)

        if (not r.name or r.name == "") and r.id then
            -- if item not cached but we have an ID to use then do a modern lookup
            GW.Debug("doing fancy modern item lookup for id:", r.id)
            local item = Item:CreateFromItemID(r.id)
            item:ContinueOnItemLoad(function()
                GW.Debug("in item load callback for id:", r.id)
                SetItemButtonTexture(f, item:GetItemIcon())
                f.Name:SetText(item:GetItemName())
                f:Show()
            end)
        else
            -- otherwise, take what we've got
            SetItemButtonTexture(f, r.icon)
            f.Name:SetText(r.name)
            f:Show()
        end
    end

    local btnOffset = #qReq.stuff
    for i = 1, #qReq.currency, 1 do
        local btnIdx = i + btnOffset
        if btnIdx > 6 then
            break
        end
        local f = self["reqItem" .. btnIdx]
        f.type = "required"
        f.objectType = "currency"
        f:SetID(i)
        if qReq.currency[i] then
            SetItemButtonCount(f, qReq.currency[i].requiredAmount)
            SetItemButtonTexture(f, qReq.currency[i].texture)
            f.Name:SetText(qReq.currency[i].name)
            f:Show()
        end
    end
end

function GwImmersiveQuestingReqItemsFrameMixin:ClearInfo()
    if (self.questReq) then
        wipe(self.questReq.stuff)
        wipe(self.questReq.currency)
        self.questReq.money = 0
    else
        self.questReq = {
            stuff = {},
            currency = {},
            money = 0
        }
    end
    self.reqMoney:Hide()
    for i = 1, 6, 1 do
        local f = self["reqItem" .. i]
        f:Hide()
    end
end

function GwImmersiveQuestingReqItemsFrameMixin:UpdateInfo()
    self.questReq.money = GetQuestMoneyToGet()
    local item_idx = 1
    for i = 1, GetNumQuestItems() do
        if (IsQuestItemHidden(i) == 0) then
            local name, icon, count, _, _, item_id = GetQuestItemInfo("required", i)
            self.questReq.stuff[item_idx] = {id = item_id, name = name, icon = icon, count = count}
            GW.Debug("quest item req - id:", item_id, "| name:", name, "| count:", count)
            item_idx = item_idx + 1
        end
    end
    for i = 1, GetNumQuestCurrencies() do
        self.questReq.currency[i] = C_QuestOffer.GetQuestRequiredCurrencyInfo(i)
    end
end
