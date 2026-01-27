local _, GW = ...

function GW.SkinIgnoreList()
    local IgnoreWindow = FriendsFrame.IgnoreListWindow
    if IgnoreWindow then
        IgnoreWindow:GwStripTextures()
        IgnoreWindow:GwCreateBackdrop(GW.BackdropTemplates.Default)
        GW.HandleTrimScrollBar(IgnoreWindow.ScrollBar, true)
        GW.HandleScrollControls(IgnoreWindow)
        IgnoreWindow.CloseButton:GwSkinButton(true)
    end

    if GW.TBC then
        IgnoreListFrameTop:Hide()
        IgnoreListFrameMiddle:Hide()
        IgnoreListFrameBottom:Hide()

        FriendsFrameIgnorePlayerButton:GwSkinButton(false, true)
        FriendsFrameUnsquelchButton:GwSkinButton(false, true)
        FriendsFrameIgnoreScrollFrame:SetHeight(600)
        FriendsFrameIgnoreScrollFrame:GwSkinScrollFrame()
        FriendsFrameIgnoreScrollFrameScrollBar:GwSkinScrollBar()
    end
end
