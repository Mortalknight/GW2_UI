local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame
local SkinButton = GW.skins.SkinButton

-------------------------------------------------------LFGListInviteDialog-------------------------------------------------------
local function SkinLFGListInviteDialog()
    local SkinLFGListInviteDialog_Show = function()
        local LFGListInviteDialog = _G.LFGListInviteDialog

        LFGListInviteDialog:SetBackdrop(nil)
        LFGListInviteDialog.Border:Hide()

        SkinButton(LFGListInviteDialog.AcceptButton, false, true)
        SkinButton(LFGListInviteDialog.DeclineButton, false, true)
        SkinButton(LFGListInviteDialog.AcknowledgeButton, false, true)

        LFGListInviteDialog:SetBackdrop(constBackdropFrame)
    end
        
    hooksecurefunc("LFGListInviteDialog_Show", SkinLFGListInviteDialog_Show)
end

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

-------------------------------------------------------LFGDungeonReadyStatus-------------------------------------------------------
local function SkinLFGDungeonReadyStatus()
    local SkinLFGDungeonReadyStatus_OnUpdate = function()
        local LFGDungeonReadyStatus = _G.LFGDungeonReadyStatus

        LFGDungeonReadyStatus:SetBackdrop(nil)
        LFGDungeonReadyStatus.Border:Hide()
        SkinButton(_G.LFGDungeonReadyStatusCloseButton, true)
        _G.LFGDungeonReadyStatusCloseButton:SetSize(20, 20)
        _G.LFGDungeonReadyStatusCloseButton:ClearAllPoints()
        _G.LFGDungeonReadyStatusCloseButton:SetPoint("TOPRIGHT", -3, -3)

        LFGDungeonReadyStatus:SetBackdrop(constBackdropFrame)
    end

    hooksecurefunc("LFGDungeonReadyPopup_Update", SkinLFGDungeonReadyStatus_OnUpdate)
end

-------------------------------------------------------LFGDungeonReadyDialog-------------------------------------------------------
local function SkinLFGDungeonReadyDialog()
    local SkinLFGDungeonReadyDialog_OnUpdate = function()
        local LFGDungeonReadyDialog = _G.LFGDungeonReadyDialog

        LFGDungeonReadyDialog:SetBackdrop(nil)
        LFGDungeonReadyDialog.Border:Hide()
        LFGDungeonReadyDialog.background:Hide()
        LFGDungeonReadyDialog.filigree:Hide()
        LFGDungeonReadyDialog.bottomArt:Hide()
        SkinButton(_G.LFGDungeonReadyDialogCloseButton, true)
        _G.LFGDungeonReadyDialogCloseButton:SetSize(20, 20)
        _G.LFGDungeonReadyDialogCloseButton:ClearAllPoints()
        _G.LFGDungeonReadyDialogCloseButton:SetPoint("TOPRIGHT", -3, -3)
    
        SkinButton(LFGDungeonReadyDialog.enterButton, false, true)
        SkinButton(LFGDungeonReadyDialog.leaveButton, false, true)
    
        LFGDungeonReadyDialog.instanceInfo.underline:Hide()
        
        LFGDungeonReadyDialog:SetBackdrop(constBackdropFrame)
    end

    hooksecurefunc("LFGDungeonReadyPopup_Update", SkinLFGDungeonReadyDialog_OnUpdate)
end

-------------------------------------------------------LFDRoleCheckPopup-------------------------------------------------------
local function SkinLFDRoleCheckPopup()
    local SkinLFDRoleCheckPopup_OnUpdate = function()
        local LFDRoleCheckPopup = _G.LFDRoleCheckPopup

        LFDRoleCheckPopup:SetBackdrop(nil)
        LFDRoleCheckPopup:SetBackdrop(constBackdropFrame)
        LFDRoleCheckPopup.Border:Hide()
        SkinButton(_G.LFDRoleCheckPopupAcceptButton, false, true)
        SkinButton(_G.LFDRoleCheckPopupDeclineButton, false, true)
    end


    hooksecurefunc("LFDRoleCheckPopup_Update", SkinLFDRoleCheckPopup_OnUpdate)
end

-------------------------------------------------------LFGInvitePopup-------------------------------------------------------
local function SkinLFGInvitePopup()
    _G.LFGInvitePopup:SetBackdrop(nil)
    _G.LFGInvitePopup.Border:Hide()

    SkinButton(_G.LFGInvitePopupAcceptButton, false, true)
    SkinButton(_G.LFGInvitePopupDeclineButton, false, true)

    _G.LFGInvitePopup:SetBackdrop(constBackdropFrame)
end

local function SkinLFGFrames()
    SkinLFGInvitePopup()
    SkinLFDRoleCheckPopup()
    SkinLFGDungeonReadyDialog()
    SkinLFGDungeonReadyStatus()
    SkinLFGListApplicationDialog()
    SkinLFGListInviteDialog()
end
GW.SkinLFGFrames = SkinLFGFrames
