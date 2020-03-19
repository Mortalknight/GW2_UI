local _, GW = ...
local addHoverToButton = GW.skins.addHoverToButton

local function SkinLFGInvitePopup()
    _G.LFGInvitePopup:SetBackdrop(nil)
    _G.LFGInvitePopup.Border:Hide()

    _G.LFGInvitePopupAcceptButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button")
    _G.LFGInvitePopupAcceptButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button")
    _G.LFGInvitePopupAcceptButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button")
    _G.LFGInvitePopupAcceptButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    _G.LFGInvitePopupAcceptButton.Text:SetTextColor(0, 0, 0, 1)
    _G.LFGInvitePopupAcceptButton.Text:SetShadowOffset(0, 0)
    addHoverToButton(_G.LFGInvitePopupAcceptButton)

    _G.LFGInvitePopupDeclineButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button")
    _G.LFGInvitePopupDeclineButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button")
    _G.LFGInvitePopupDeclineButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button")
    _G.LFGInvitePopupDeclineButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    _G.LFGInvitePopupDeclineButton.Text:SetTextColor(0, 0, 0, 1)
    _G.LFGInvitePopupDeclineButton.Text:SetShadowOffset(0, 0)
    addHoverToButton(_G.LFGInvitePopupDeclineButton)

    _G.LFGInvitePopup:SetBackdrop(constBackdropFrame)
end
GW.SkinLFGInvitePopup = SkinLFGInvitePopup