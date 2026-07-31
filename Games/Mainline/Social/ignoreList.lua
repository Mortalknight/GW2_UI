---@class GW2
local GW = select(2, ...)

function GW.SkinIgnoreList()
    local IgnoreFrame = SocialUIFrame.IgnoreListFrame
    if not IgnoreFrame then return end

    IgnoreFrame:GwStripTextures()
    IgnoreFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
    IgnoreFrame:ClearAllPoints()
    IgnoreFrame:SetPoint("TOPLEFT", SocialUIFrame.gwHeader, "BOTTOMRIGHT", 45, 1)
    IgnoreFrame.BlockButton:GwSkinButton(false, true)
    IgnoreFrame.BlockButton:GwSkinNegativeButton()
    IgnoreFrame.UnblockButton:GwSkinButton(false, true)
    IgnoreFrame.CloseButton:GwSkinButton(true)
    GW.HandleTrimScrollBar(IgnoreFrame.ScrollBar)
    GW.HandleScrollControls(IgnoreFrame)
    hooksecurefunc(IgnoreFrame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
end
