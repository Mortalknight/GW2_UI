local _, GW = ...

function GW.SkinQuickJoinList()
    if not GW.Retail then return end

    FriendsFrameTab4.GwNotifyText:SetText("0")
    FriendsFrameTab4.GwNotifyText:Show()
    FriendsFrameTab4.GwNotifyRed:Hide()

    local num = #C_SocialQueue.GetAllGroups()
    FriendsFrameTab4.GwNotifyText:SetText(num)
    FriendsFrameTab4.GwNotifyRed:SetShown(num > 0)

    QuickJoinFrame:HookScript("OnShow", function()
        num = #C_SocialQueue.GetAllGroups()
        FriendsFrameTab4.GwNotifyText:SetText(num)
        FriendsFrameTab4.GwNotifyRed:SetShown(num > 0)
    end)

    local quickJoinQueueEventFrame = CreateFrame("Frame")
    quickJoinQueueEventFrame:RegisterEvent("SOCIAL_QUEUE_UPDATE")
    quickJoinQueueEventFrame:RegisterEvent("GROUP_LEFT")
    quickJoinQueueEventFrame:RegisterEvent("GROUP_JOINED")
    quickJoinQueueEventFrame:SetScript("OnEvent", function()
        if not QuickJoinFrame:IsShown() then return end
        num = #C_SocialQueue.GetAllGroups()
        FriendsFrameTab4.GwNotifyText:SetText(num)
        FriendsFrameTab4.GwNotifyRed:SetShown(num > 0)
    end)

    hooksecurefunc(QuickJoinFrame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
    QuickJoinFrame.JoinQueueButton:GwSkinButton(false, true)
    GW.HandleTrimScrollBar(QuickJoinFrame.ScrollBar, true)
    GW.HandleScrollControls(QuickJoinFrame)
end
