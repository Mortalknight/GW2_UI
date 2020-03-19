local _, GW = ...
local addHoverToButton = GW.skins.addHoverToButton
local SkinButton = GW.skins.SkinButton

local function SkinLFGInvitePopup()
    _G.LFGInvitePopup:SetBackdrop(nil)
    _G.LFGInvitePopup.Border:Hide()

    SkinButton(_G.LFGInvitePopupAcceptButton, false, true)
    SkinButton(_G.LFGInvitePopupDeclineButton, false, true)

    _G.LFGInvitePopup:SetBackdrop(constBackdropFrame)
end
GW.SkinLFGInvitePopup = SkinLFGInvitePopup