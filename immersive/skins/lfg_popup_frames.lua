local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame
local GetSetting = GW.GetSetting

-------------------------------------------------------LFGDungeonReadyStatus-------------------------------------------------------
local function SkinLFGDungeonReadyStatus()
    local SkinLFGDungeonReadyStatus_OnUpdate = function()
        local LFGDungeonReadyStatus = _G.LFGDungeonReadyStatus

        LFGDungeonReadyStatus.Border:Hide()
        LFGDungeonReadyStatusCloseButton:SkinButton(true)
        LFGDungeonReadyStatusCloseButton:SetSize(20, 20)
        LFGDungeonReadyStatusCloseButton:ClearAllPoints()
        LFGDungeonReadyStatusCloseButton:SetPoint("TOPRIGHT", -3, -3)

        LFGDungeonReadyStatus:CreateBackdrop(constBackdropFrame)
    end

    hooksecurefunc("LFGDungeonReadyPopup_Update", SkinLFGDungeonReadyStatus_OnUpdate)
end

-------------------------------------------------------LFGDungeonReadyDialog-------------------------------------------------------
local function SkinLFGDungeonReadyDialog()
    local SkinLFGDungeonReadyDialog_OnUpdate = function()
        local LFGDungeonReadyDialog = _G.LFGDungeonReadyDialog
        LFGDungeonReadyDialog:StripTextures()

        LFGDungeonReadyDialogCloseButton:SkinButton(true)
        LFGDungeonReadyDialogCloseButton:SetSize(20, 20)
        LFGDungeonReadyDialogCloseButton:ClearAllPoints()
        LFGDungeonReadyDialogCloseButton:SetPoint("TOPRIGHT", -3, -3)

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
        LFDRoleCheckPopupAcceptButton:SkinButton(false, true)
        LFDRoleCheckPopupDeclineButton:SkinButton(false, true)
    end


    hooksecurefunc("LFDRoleCheckPopup_Update", SkinLFDRoleCheckPopup_OnUpdate)
end

-------------------------------------------------------LFGInvitePopup-------------------------------------------------------
local function SkinLFGInvitePopup()
    LFGInvitePopup.Border:Hide()

    LFGInvitePopupAcceptButton:SkinButton(false, true)
    LFGInvitePopupDeclineButton:SkinButton(false, true)

    LFGInvitePopup:CreateBackdrop(constBackdropFrame)
end

local function LoadLFGSkins()
    if not GetSetting("LFG_FRAMES_SKIN_ENABLED") then return end

    SkinLFGInvitePopup()
    SkinLFDRoleCheckPopup()
    SkinLFGDungeonReadyDialog()
    SkinLFGDungeonReadyStatus()
end
GW.LoadLFGSkins = LoadLFGSkins
