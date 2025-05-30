local _, GW = ...
local L = GW.L

StaticPopupDialogs["SET_BN_BROADCAST"] = {
    text = BN_BROADCAST_TOOLTIP,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    editBoxWidth = 350,
    maxLetters = 127,
    OnAccept = function(self) BNSetCustomMessage(self.editBox:GetText()) end,
    OnShow = function(self) self.editBox:SetText(select(4, BNGetInfo()) ) self.editBox:SetFocus() end,
    OnHide = ChatEdit_FocusActiveWindow,
    EditBoxOnEnterPressed = function(self) BNSetCustomMessage(self:GetText()) self:GetParent():Hide() end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3
}

StaticPopupDialogs["GW_CHANGE_BAG_HEADER"] = {
    text = L["New Bag Name"],
    button1 = SAVE,
    button2 = RESET,
    selectCallbackByIndex = true,
    OnButton1 = function(self, data)
        GW.settings["BAG_HEADER_NAME" .. data] = self.editBox:GetText()
        _G["GwBagFrameGwBagHeader" .. data].nameString:SetText(self.editBox:GetText())
    end,
    OnButton2 = function(_, data)
        GW.settings["BAG_HEADER_NAME" .. data] = ""
        if tonumber(data) > 0 then
            local slotID = GetInventorySlotInfo("Bag" .. data - 1 .. "Slot")
            local itemID = GetInventoryItemID("player", slotID)

            if itemID then
                local color = {r = 1, g = 1, b = 1}
                local itemName, _, itemRarity = C_Item.GetItemInfo(itemID)
                if itemRarity then
                    color = GW.GetQualityColor(itemRarity)
                end

                _G["GwBagFrameGwBagHeader" .. data].nameString:SetText(itemName or UNKNOWN)
                _G["GwBagFrameGwBagHeader" .. data].nameString:SetTextColor(color.r, color.g, color.b, 1)
            end
        else
            _G["GwBagFrameGwBagHeader" .. data].nameString:SetText(BACKPACK_TOOLTIP)
        end
    end,
    timeout = 0,
    whileDead = 1,
    hasEditBox = 1,
    maxLetters = 64,
    editBoxWidth = 250,
    closeButton = 1,
}

StaticPopupDialogs["JOIN_DISCORD"] = {
    text = L["Join Discord"],
    button2 = CLOSE,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    hasEditBox = 1,
    hasWideEditBox = true,
    editBoxWidth = 250,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide();
    end,
    OnShow = function(self)
        self:SetWidth(420)
        local editBox = _G[self:GetName() .. "EditBox"]
        editBox:SetText("https://discord.gg/MZZtRWt")
        editBox:SetFocus()
        editBox:HighlightText()
        local button = _G[self:GetName() .. "Button2"]
        button:ClearAllPoints()
        button:SetWidth(200)
        button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
    end,
    preferredIndex = 4
}

StaticPopupDialogs["CONFIG_RELOAD"] = {
    text = L["One or more of the changes you have made require a UI reload."],
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function() C_UI.Reload() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 4
}

StaticPopupDialogs["WARNING_BLIZZARD_ADDONS"] = {
    text = L["It appears one of your AddOns have disabled the AddOn Blizzard_CompactRaidFrames. This can cause errors and other issues. The AddOn will now be re-enabled."],
    button1 = OKAY,
    OnAccept = function() C_AddOns.EnableAddOn("Blizzard_CompactRaidFrames"); ReloadUI() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 4
}