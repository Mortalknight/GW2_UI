local _, GW = ...
local constBackdropFrame = GW.BackdropTemplates.Default
local GetSetting = GW.GetSetting

-------------------------------------------------------LFGDungeonReadyStatus-------------------------------------------------------
local function SkinLFGDungeonReadyStatus()
    local SkinLFGDungeonReadyStatus_OnUpdate = function()
        LFGDungeonReadyStatus.Border:Hide()
        LFGDungeonReadyStatusCloseButton:GwSkinButton(true)
        LFGDungeonReadyStatusCloseButton:SetSize(20, 20)
        LFGDungeonReadyStatusCloseButton:ClearAllPoints()
        LFGDungeonReadyStatusCloseButton:SetPoint("TOPRIGHT", -3, -3)

        LFGDungeonReadyStatus:GwCreateBackdrop(constBackdropFrame)
    end

    hooksecurefunc("LFGDungeonReadyPopup_Update", SkinLFGDungeonReadyStatus_OnUpdate)
end

-------------------------------------------------------LFGDungeonReadyDialog-------------------------------------------------------
local function SkinLFGDungeonReadyDialog()
    local SkinLFGDungeonReadyDialog_OnUpdate = function()
        LFGDungeonReadyDialog:GwStripTextures()

        LFGDungeonReadyDialogCloseButton:GwSkinButton(true)
        LFGDungeonReadyDialogCloseButton:SetSize(20, 20)
        LFGDungeonReadyDialogCloseButton:ClearAllPoints()
        LFGDungeonReadyDialogCloseButton:SetPoint("TOPRIGHT", -3, -3)

        LFGDungeonReadyDialog.enterButton:GwSkinButton(false, true)
        LFGDungeonReadyDialog.leaveButton:GwSkinButton(false, true)

        LFGDungeonReadyDialog.instanceInfo.underline:Hide()

        LFGDungeonReadyDialog:GwCreateBackdrop(constBackdropFrame)
    end

    hooksecurefunc("LFGDungeonReadyPopup_Update", SkinLFGDungeonReadyDialog_OnUpdate)
end

-------------------------------------------------------LFDRoleCheckPopup-------------------------------------------------------
local function SkinLFDRoleCheckPopup()
    local SkinLFDRoleCheckPopup_OnUpdate = function()
        LFDRoleCheckPopup:GwCreateBackdrop(constBackdropFrame)
        LFDRoleCheckPopup.Border:Hide()
        LFDRoleCheckPopupAcceptButton:GwSkinButton(false, true)
        LFDRoleCheckPopupDeclineButton:GwSkinButton(false, true)
    end


    hooksecurefunc("LFDRoleCheckPopup_Update", SkinLFDRoleCheckPopup_OnUpdate)
end

-------------------------------------------------------LFGInvitePopup-------------------------------------------------------
local function SkinLFGInvitePopup()
    LFGInvitePopup.Border:Hide()

    LFGInvitePopupAcceptButton:GwSkinButton(false, true)
    LFGInvitePopupDeclineButton:GwSkinButton(false, true)

    LFGInvitePopup:GwCreateBackdrop(constBackdropFrame)
end

local function LoadLFGSkins()
    if not GetSetting("LFG_FRAMES_SKIN_ENABLED") then return end

    SkinLFGInvitePopup()
    SkinLFDRoleCheckPopup()
    SkinLFGDungeonReadyDialog()
    SkinLFGDungeonReadyStatus()
end
GW.LoadLFGSkins = LoadLFGSkins
