local _, GW = ...

local function LoadQuickJoinList(tabContainer)
    local quickjoin = CreateFrame("Frame", "GwQuickJoinWindow", tabContainer, "GWQuickJoinFrame")
    tabContainer.TabFrame.GwNotifyText:SetText("0")
    tabContainer.TabFrame.GwNotifyText:Show()
    tabContainer.TabFrame.GwNotifyRed:Hide()

    GwSocialWindow:HookScript("OnShow", function()
        local num = #C_SocialQueue.GetAllGroups()
        tabContainer.TabFrame.GwNotifyText:SetText(num)
        tabContainer.TabFrame.GwNotifyRed:SetShown(num > 0)
    end)

    local quickJoinQueueEventFrame = CreateFrame("Frame")
    quickJoinQueueEventFrame:RegisterEvent("SOCIAL_QUEUE_UPDATE")
    quickJoinQueueEventFrame:RegisterEvent("GROUP_LEFT")
    quickJoinQueueEventFrame:RegisterEvent("GROUP_JOINED")
    quickJoinQueueEventFrame:SetScript("OnEvent", function()
        if not GwSocialWindow:IsVisible() then return end
        local num = #C_SocialQueue.GetAllGroups()
        tabContainer.TabFrame.GwNotifyText:SetText(num)
        tabContainer.TabFrame.GwNotifyRed:SetShown(num > 0)
    end)

    QuickJoinFrame:SetParent(quickjoin)
    QuickJoinFrame:ClearAllPoints()
    QuickJoinFrame:SetPoint("TOPLEFT", quickjoin, "TOPLEFT", 0, 0)
    QuickJoinFrame:SetPoint("BOTTOMRIGHT", quickjoin, "BOTTOMRIGHT", 0, 0)

    QuickJoinFrame.ScrollFrame:SetParent(quickjoin)
    QuickJoinFrame.ScrollFrame:ClearAllPoints()
    QuickJoinFrame.ScrollFrame:SetPoint("TOPLEFT", quickjoin, "TOPLEFT", 0, -15)
    QuickJoinFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", quickjoin, "BOTTOMRIGHT", 0, 0)

    QuickJoinFrame.ScrollFrame.scrollBar:SkinScrollBar()
    QuickJoinFrame.ScrollFrame.scrollBar:SetWidth(3)
    QuickJoinFrame.ScrollFrame:SkinScrollFrame()
    QuickJoinScrollFrameMiddle:Hide()
    QuickJoinFrame.ScrollFrame.ScrollChild:ClearAllPoints()
    QuickJoinFrame.ScrollFrame.ScrollChild:SetAllPoints(QuickJoinFrame.ScrollFrame)

    QuickJoinFrame.JoinQueueButton:SetParent(quickjoin)
    QuickJoinFrame.JoinQueueButton:ClearAllPoints()
    QuickJoinFrame.JoinQueueButton:SetPoint("BOTTOMRIGHT", quickjoin, "BOTTOMRIGHT", 0, -30)
    QuickJoinFrame.JoinQueueButton:SkinButton(false, true)
    QuickJoinFrame.JoinQueueButton:SetScript("OnClick", function()
        QuickJoinFrame:JoinQueue()
    end)

    HybridScrollFrame_CreateButtons(QuickJoinFrame.ScrollFrame, "QuickJoinButtonTemplate")

    local buttons = QuickJoinFrame.ScrollFrame.buttons
    for i = 1, #buttons do
        local button = buttons[i]
        button:SetSize(460, 25)
    end

    QuickJoinFrame.ScrollFrame.ScrollChild:SetHeight(560)
    QuickJoinFrame.ScrollFrame:UpdateScrollChildRect()

    QuickJoinFrame:UpdateScrollFrame()
    QuickJoinFrame:UpdateJoinButtonState()

    hooksecurefunc("HybridScrollFrame_Update", function(self)
        if self == QuickJoinFrame.ScrollFrame then
            self.ScrollChild:SetHeight(560)
            self:UpdateScrollChildRect()
        end
    end)

    QuickJoinToastButton:SetScript("OnClick", function(self, button)
        if InCombatLockdown() then return end
        if KeybindFrames_InQuickKeybindMode() then
            self:QuickKeybindButtonOnClick(button)
        elseif self.displayedToast then
            GwSocialWindow:SetAttribute("windowpanelopen", "quicklist")
            QuickJoinFrame:SelectGroup(self.displayedToast.guid)
            QuickJoinFrame:ScrollToGroup(self.displayedToast.guid)
        else
            GwSocialWindow:SetAttribute("windowpanelopen", "friendlist")
        end
    end)

    --QuickJoinFrame:OnShow()
end
GW.LoadQuickJoinList = LoadQuickJoinList