local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame
local SkinButton = GW.skins.SkinButton

-------------------------------------------------------LFGListInviteDialog-------------------------------------------------------
local function SkinLFGListInviteDialog_Show()
    local LFGListInviteDialog = _G.LFGListInviteDialog

    LFGListInviteDialog:SetBackdrop(nil)
    LFGListInviteDialog.Border:Hide()

    SkinButton(LFGListInviteDialog.AcceptButton, false, true)
    SkinButton(LFGListInviteDialog.DeclineButton, false, true)
    SkinButton(LFGListInviteDialog.AcknowledgeButton, false, true)

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

    SkinButton(LFGListApplicationDialog.SignUpButton, false, true)
    SkinButton(LFGListApplicationDialog.CancelButton, false, true)

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