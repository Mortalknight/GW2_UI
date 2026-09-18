---@class GW2
local GW = select(2, ...)

-------------------------------------------------------LFGDungeonReadyStatus-------------------------------------------------------
local function SkinLFGDungeonReadyStatus()
    if not LFGDungeonReadyPopup_Update then return end
    local SkinLFGDungeonReadyStatus_OnUpdate = function()
        LFGDungeonReadyStatus.Border:Hide()
        LFGDungeonReadyStatusCloseButton:GwSkinButton(true)
        LFGDungeonReadyStatusCloseButton:SetSize(20, 20)
        LFGDungeonReadyStatusCloseButton:ClearAllPoints()
        LFGDungeonReadyStatusCloseButton:SetPoint("TOPRIGHT", -3, -3)

        LFGDungeonReadyStatus:GwCreateBackdrop(GW.BackdropTemplates.Default)
    end

    hooksecurefunc("LFGDungeonReadyPopup_Update", SkinLFGDungeonReadyStatus_OnUpdate)
end

-------------------------------------------------------LFGDungeonReadyDialog-------------------------------------------------------
local function SkinLFGDungeonReadyDialog()
    if not LFGDungeonReadyPopup_Update then return end
    local SkinLFGDungeonReadyDialog_OnUpdate = function()
        LFGDungeonReadyDialog:GwStripTextures()

        LFGDungeonReadyDialogCloseButton:GwSkinButton(true)
        LFGDungeonReadyDialogCloseButton:SetSize(20, 20)
        LFGDungeonReadyDialogCloseButton:ClearAllPoints()
        LFGDungeonReadyDialogCloseButton:SetPoint("TOPRIGHT", -3, -3)

        LFGDungeonReadyDialog.enterButton:GwSkinButton(false, true)
        LFGDungeonReadyDialog.leaveButton:GwSkinButton(false, true)

        LFGDungeonReadyDialog.instanceInfo.underline:Hide()

        LFGDungeonReadyDialog:GwCreateBackdrop(GW.BackdropTemplates.Default)
    end

    hooksecurefunc("LFGDungeonReadyPopup_Update", SkinLFGDungeonReadyDialog_OnUpdate)
end

-------------------------------------------------------LFDRoleCheckPopup-------------------------------------------------------
local function SkinLFDRoleCheckPopup()
    if not LFDRoleCheckPopup_Update then return end
    local SkinLFDRoleCheckPopup_OnUpdate = function()
        LFDRoleCheckPopup:GwCreateBackdrop(GW.BackdropTemplates.Default)
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

    LFGInvitePopup:GwCreateBackdrop(GW.BackdropTemplates.Default)
end

local function LoadLFGSkins()
    if not GW.settings.skins.lfgFrames.enabled then return end

    SkinLFGInvitePopup()
    SkinLFDRoleCheckPopup()
    SkinLFGDungeonReadyDialog()
    SkinLFGDungeonReadyStatus()
end
GW.LoadLFGSkins = LoadLFGSkins
