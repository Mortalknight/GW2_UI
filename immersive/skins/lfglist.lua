local _, GW = ...
local addHoverToButton = GW.skins.addHoverToButton
local constBackdropFrame = GW.skins.constBackdropFrame

-------------------------------------------------------LFGListInviteDialog-------------------------------------------------------
local function SkinLFGListInviteDialog_Show()
    local LFGListInviteDialog = _G.LFGListInviteDialog

    LFGListInviteDialog:SetBackdrop(nil)
    LFGListInviteDialog.Border:Hide()
    LFGListInviteDialog.AcceptButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGListInviteDialog.AcceptButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGListInviteDialog.AcceptButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGListInviteDialog.AcceptButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    LFGListInviteDialog.AcceptButton.Text:SetTextColor(0, 0, 0, 1)
    LFGListInviteDialog.AcceptButton.Text:SetShadowOffset(0, 0)
    addHoverToButton(LFGListInviteDialog.AcceptButton)

    LFGListInviteDialog.DeclineButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGListInviteDialog.DeclineButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGListInviteDialog.DeclineButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGListInviteDialog.DeclineButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    LFGListInviteDialog.DeclineButton.Text:SetTextColor(0, 0, 0, 1)
    LFGListInviteDialog.DeclineButton.Text:SetShadowOffset(0, 0)
    addHoverToButton(LFGListInviteDialog.DeclineButton)

    LFGListInviteDialog.AcknowledgeButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGListInviteDialog.AcknowledgeButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGListInviteDialog.AcknowledgeButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGListInviteDialog.AcknowledgeButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    LFGListInviteDialog.AcknowledgeButton.Text:SetTextColor(0, 0, 0, 1)
    LFGListInviteDialog.AcknowledgeButton.Text:SetShadowOffset(0, 0)
    addHoverToButton(LFGListInviteDialog.AcknowledgeButton)

    LFGListInviteDialog:SetBackdrop(constBackdropFrame)
end
local function SkinLFGListInviteDialog()
    hooksecurefunc("LFGListInviteDialog_Show", SkinLFGListInviteDialog_Show)
end
GW.SkinLFGListInviteDialog = SkinLFGListInviteDialog

------------------------------------------------------LFGListApplicationDialog-------------------------------------------------------
local function SkinLFGListApplicationDialog()
    local LFGListApplicationDialog = _G.LFGListApplicationDialog

    LFGListApplicationDialog:SetBackdrop(nil)
    LFGListApplicationDialog.Border:Hide()
    LFGListApplicationDialog.SignUpButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGListApplicationDialog.SignUpButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGListApplicationDialog.SignUpButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGListApplicationDialog.SignUpButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    LFGListApplicationDialog.SignUpButton.Text:SetTextColor(0, 0, 0, 1)
    LFGListApplicationDialog.SignUpButton.Text:SetShadowOffset(0, 0)
    addHoverToButton(LFGListApplicationDialog.SignUpButton)

    LFGListApplicationDialog.CancelButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGListApplicationDialog.CancelButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGListApplicationDialog.CancelButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGListApplicationDialog.CancelButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    LFGListApplicationDialog.CancelButton.Text:SetTextColor(0, 0, 0, 1)
    LFGListApplicationDialog.CancelButton.Text:SetShadowOffset(0, 0)
    addHoverToButton(LFGListApplicationDialog.CancelButton)

    local r = {LFGListApplicationDialog.Description:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            c:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar-bg")
        end
    end
    LFGListApplicationDialog.Description.ScrollBar.ScrollUpButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")
    LFGListApplicationDialog.Description.ScrollBar.ScrollUpButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")
    LFGListApplicationDialog.Description.ScrollBar.ScrollUpButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")
    LFGListApplicationDialog.Description.ScrollBar.ScrollUpButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")

    LFGListApplicationDialog.Description.ScrollBar.ScrollDownButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    LFGListApplicationDialog.Description.ScrollBar.ScrollDownButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    LFGListApplicationDialog.Description.ScrollBar.ScrollDownButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    LFGListApplicationDialog.Description.ScrollBar.ScrollDownButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    LFGListApplicationDialog:SetBackdrop(constBackdropFrame)
end
GW.SkinLFGListApplicationDialog = SkinLFGListApplicationDialog