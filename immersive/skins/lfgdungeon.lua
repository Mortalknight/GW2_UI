local _, GW = ...
local addHoverToButton = GW.skins.addHoverToButton
local constBackdropFrame = GW.skins.constBackdropFrame

-------------------------------------------------------LFGDungeonReadyStatus-------------------------------------------------------
local function SkinLFGDungeonReadyStatus_OnUpdate()
    local LFGDungeonReadyStatus = _G.LFGDungeonReadyStatus

    LFGDungeonReadyStatus:SetBackdrop(nil)
    LFGDungeonReadyStatus.Border:Hide()
    _G.LFGDungeonReadyStatusCloseButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal")
    _G.LFGDungeonReadyStatusCloseButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover")
    _G.LFGDungeonReadyStatusCloseButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover")
    _G.LFGDungeonReadyStatusCloseButton:SetSize(20, 20)
    _G.LFGDungeonReadyStatusCloseButton:ClearAllPoints()
    _G.LFGDungeonReadyStatusCloseButton:SetPoint("TOPRIGHT", -3, -3)

    LFGDungeonReadyStatus:SetBackdrop(constBackdropFrame)
end
local function SkinLFGDungeonReadyStatus()
    hooksecurefunc("LFGDungeonReadyPopup_Update", SkinLFGDungeonReadyStatus_OnUpdate)
end
GW.SkinLFGDungeonReadyStatus = SkinLFGDungeonReadyStatus

-------------------------------------------------------LFGDungeonReadyDialog-------------------------------------------------------
local function SkinLFGDungeonReadyDialog_OnUpdate()
    local LFGDungeonReadyDialog = _G.LFGDungeonReadyDialog

    LFGDungeonReadyDialog:SetBackdrop(nil)
    LFGDungeonReadyDialog.Border:Hide()
    LFGDungeonReadyDialog.background:Hide()
    LFGDungeonReadyDialog.filigree:Hide()
    LFGDungeonReadyDialog.bottomArt:Hide()
    _G.LFGDungeonReadyDialogCloseButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal")
    _G.LFGDungeonReadyDialogCloseButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover")
    _G.LFGDungeonReadyDialogCloseButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover")
    _G.LFGDungeonReadyDialogCloseButton:SetSize(20, 20)
    _G.LFGDungeonReadyDialogCloseButton:ClearAllPoints()
    _G.LFGDungeonReadyDialogCloseButton:SetPoint("TOPRIGHT", -3, -3)

    LFGDungeonReadyDialog.enterButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGDungeonReadyDialog.enterButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGDungeonReadyDialog.enterButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGDungeonReadyDialog.enterButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    LFGDungeonReadyDialog.enterButton.Text:SetTextColor(0, 0, 0, 1)
    LFGDungeonReadyDialog.enterButton.Text:SetShadowOffset(0, 0)
    addHoverToButton(LFGDungeonReadyDialog.enterButton)

    LFGDungeonReadyDialog.leaveButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGDungeonReadyDialog.leaveButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGDungeonReadyDialog.leaveButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button")
    LFGDungeonReadyDialog.leaveButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    LFGDungeonReadyDialog.leaveButton.Text:SetTextColor(0, 0, 0, 1)
    LFGDungeonReadyDialog.leaveButton.Text:SetShadowOffset(0, 0)
    addHoverToButton(LFGDungeonReadyDialog.leaveButton)

    LFGDungeonReadyDialog.instanceInfo.underline:Hide()
    
    LFGDungeonReadyDialog:SetBackdrop(constBackdropFrame)
end
local function SkinLFGDungeonReadyDialog()
    hooksecurefunc("LFGDungeonReadyPopup_Update", SkinLFGDungeonReadyDialog_OnUpdate)
end
GW.SkinLFGDungeonReadyDialog = SkinLFGDungeonReadyDialog