local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame

-------------------------------------------------------LFGListInviteDialog-------------------------------------------------------
local function SkinLFGListInviteDialog()
    local SkinLFGListInviteDialog_Show = function()
        local LFGListInviteDialog = _G.LFGListInviteDialog

        LFGListInviteDialog.Border:Hide()

        LFGListInviteDialog.AcceptButton:SkinButton(false, true)
        LFGListInviteDialog.DeclineButton:SkinButton(false, true)
        LFGListInviteDialog.AcknowledgeButton:SkinButton(false, true)

        LFGListInviteDialog:CreateBackdrop(constBackdropFrame)
    end
        
    hooksecurefunc("LFGListInviteDialog_Show", SkinLFGListInviteDialog_Show)
end

------------------------------------------------------LFGListApplicationDialog-------------------------------------------------------
local function SkinLFGListApplicationDialog()
    local LFGListApplicationDialog = _G.LFGListApplicationDialog

    LFGListApplicationDialog.Border:Hide()

    LFGListApplicationDialog.SignUpButton:SkinButton(false, true)
    LFGListApplicationDialog.CancelButton:SkinButton(false, true)

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
    LFGListApplicationDialog:CreateBackdrop(constBackdropFrame)
end

-------------------------------------------------------LFGDungeonReadyStatus-------------------------------------------------------
local function SkinLFGDungeonReadyStatus()
    local SkinLFGDungeonReadyStatus_OnUpdate = function()
        local LFGDungeonReadyStatus = _G.LFGDungeonReadyStatus

        LFGDungeonReadyStatus.Border:Hide()
        _G.LFGDungeonReadyStatusCloseButton:SkinButton(true)
        _G.LFGDungeonReadyStatusCloseButton:SetSize(20, 20)
        _G.LFGDungeonReadyStatusCloseButton:ClearAllPoints()
        _G.LFGDungeonReadyStatusCloseButton:SetPoint("TOPRIGHT", -3, -3)

        LFGDungeonReadyStatus:CreateBackdrop(constBackdropFrame)
    end

    hooksecurefunc("LFGDungeonReadyPopup_Update", SkinLFGDungeonReadyStatus_OnUpdate)
end

-------------------------------------------------------LFGDungeonReadyDialog-------------------------------------------------------
local function SkinLFGDungeonReadyDialog()
    local SkinLFGDungeonReadyDialog_OnUpdate = function()
        local LFGDungeonReadyDialog = _G.LFGDungeonReadyDialog
        LFGDungeonReadyDialog.Border:Hide()
        LFGDungeonReadyDialog.background:Hide()
        LFGDungeonReadyDialog.filigree:Hide()
        LFGDungeonReadyDialog.bottomArt:Hide()
        _G.LFGDungeonReadyDialogCloseButton:SkinButton(true)
        _G.LFGDungeonReadyDialogCloseButton:SetSize(20, 20)
        _G.LFGDungeonReadyDialogCloseButton:ClearAllPoints()
        _G.LFGDungeonReadyDialogCloseButton:SetPoint("TOPRIGHT", -3, -3)
    
        LFGDungeonReadyDialog.enterButton:SkinButton(false, true)
        LFGDungeonReadyDialog.leaveButton:SkinButton(false, true)
    
        LFGDungeonReadyDialog.instanceInfo.underline:Hide()
        
        LFGDungeonReadyDialog:CreateBackdrop(constBackdropFrame)
    end

    hooksecurefunc("LFGDungeonReadyPopup_Update", SkinLFGDungeonReadyDialog_OnUpdate)
end

-------------------------------------------------------LFDRoleCheckPopup-------------------------------------------------------
local function SkinLFDRoleCheckPopup()
    local SkinLFDRoleCheckPopup_OnUpdate = function()
        local LFDRoleCheckPopup = _G.LFDRoleCheckPopup

        LFDRoleCheckPopup:CreateBackdrop(constBackdropFrame)
        LFDRoleCheckPopup.Border:Hide()
        _G.LFDRoleCheckPopupAcceptButton:SkinButton(false, true)
        _G.LFDRoleCheckPopupDeclineButton:SkinButton(false, true)
    end


    hooksecurefunc("LFDRoleCheckPopup_Update", SkinLFDRoleCheckPopup_OnUpdate)
end

-------------------------------------------------------LFGInvitePopup-------------------------------------------------------
local function SkinLFGInvitePopup()
    _G.LFGInvitePopup.Border:Hide()

    _G.LFGInvitePopupAcceptButton:SkinButton(false, true)
    _G.LFGInvitePopupDeclineButton:SkinButton(false, true)

    _G.LFGInvitePopup:CreateBackdrop(constBackdropFrame)
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
