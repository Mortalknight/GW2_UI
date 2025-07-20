GwObjectivesItemButtonMixin = {}

function GwObjectivesItemButtonMixin:SetItem(block)
    local validTexture
    local isFound = false

    for bag = 0 , 5 do
        for slot = 0 , 24 do
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            if itemInfo and block.sourceItemId == itemInfo.itemID then
                validTexture = itemInfo.iconFileID
                isFound = true
                break
            end
        end
    end

    -- Edge case to find "equipped" quest items since they will no longer be in the players bag
    if (not isFound) then
        for j = 13, 18 do
            local itemID = GetInventoryItemID("player", j)
            local texture = GetInventoryItemTexture("player", j)
            if block.sourceItemId == itemID then
                validTexture = texture
                isFound = true
                break
            end
        end
    end

    if validTexture and isFound then
        self.itemID = tonumber(block.sourceItemId)
        self.questID = block.questID
        self.charges = C_Item.GetItemCount(self.itemID, nil, true)
        self.rangeTimer = -1

        self:SetAttribute("item", "item:" .. tostring(self.itemID))
        self:SetNormalTexture(validTexture)
        self:SetPushedTexture(validTexture)
        self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")
        self:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
        self:GetPushedTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)

        -- Cooldown Updates
        self.Cooldown:SetPoint("CENTER", self, "CENTER", 0, 0)
        self.Cooldown:Hide()

        -- Range Updates
        self.HotKey:SetText("●")
        self.HotKey:Hide()

        -- Charges Updates
        self.count:Hide()
        if self.charges > 1 then
            self.count:SetText(self.charges)
            self.count:Show()
        end

        self.UpdateButton(self)

        return true
    end

    return false
end

function GwObjectivesItemButtonMixin:UpdateButton()
    if not self.itemID or not self:IsVisible() then
        return
    end

    local start, duration, enabled = C_Container.GetItemCooldown(self.itemID)

    if enabled and duration > 3 and enabled == 1 then
        self.Cooldown:Show()
        self.Cooldown:SetCooldown(start, duration)
    else
        self.Cooldown:Hide()
    end
end

function GwObjectivesItemButtonMixin:OnEvent(event)
    if event == "PLAYER_TARGET_CHANGED" then
        self.rangeTimer = -1
        self.HotKey:Hide()

    elseif (event == "BAG_UPDATE_COOLDOWN") then
        self.UpdateButton(self)
    end
end

function GwObjectivesItemButtonMixin:OnUpdate(elapsed)
    if not self.itemID or not self:IsVisible() then
        return
    end

    local charges = C_Item.GetItemCount(self.itemID, nil, true)
    if (not charges or charges ~= self.charges) then
        self.count:Hide()
        self.charges = C_Item.GetItemCount(self.itemID, nil, true)
        if self.charges > 1 then
            self.count:SetText(self.charges)
            self.count:Show()
        end
    end

    if UnitExists("target") and (not UnitIsFriend("player", "target") or (not InCombatLockdown())) then

        if not self.itemName then
            self.itemName = C_Item.GetItemInfo(self.itemID)
        end

        local rangeTimer = self.rangeTimer
        if (rangeTimer) then
            rangeTimer = rangeTimer - elapsed

            if (rangeTimer <= 0) then

                local isInRange = C_Item.IsItemInRange(self.itemName, "target")

                if isInRange == false then
                    self.HotKey:SetVertexColor(1.0, 0.1, 0.1)
                    self.HotKey:Show()

                elseif isInRange == true then
                    self.HotKey:SetVertexColor(0.6, 0.6, 0.6)
                    self.HotKey:Show()
                end

                rangeTimer = 0.3
            end

            self.rangeTimer = rangeTimer
        end
    end
end

function GwObjectivesItemButtonMixin:OnShow()
    self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("BAG_UPDATE_COOLDOWN")
end

function GwObjectivesItemButtonMixin:OnHide()
    self:UnregisterEvent("PLAYER_TARGET_CHANGED")
    self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
end

function GwObjectivesItemButtonMixin:OnEnter()
    if not self.itemID then return end
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:SetHyperlink("item:"..tostring(self.itemID)..":0:0:0:0:0:0:0")
    GameTooltip:Show()
end

function GwObjectivesItemButtonMixin:FakeHide()
    self:SetScript("OnEnter", nil)
    self:SetScript("OnLeave", nil)

    self:ClearNormalTexture()
    self:ClearPushedTexture()
    self:ClearHighlightTexture()
end
