local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame
local SkinButton = GW.skins.SkinButton

-------------------------------------------------------LFGDungeonReadyStatus-------------------------------------------------------
local function SkinLFGDungeonReadyStatus_OnUpdate()
    local LFGDungeonReadyStatus = _G.LFGDungeonReadyStatus

    LFGDungeonReadyStatus:SetBackdrop(nil)
    LFGDungeonReadyStatus.Border:Hide()
    SkinButton(_G.LFGDungeonReadyStatusCloseButton, true)
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
    SkinButton(_G.LFGDungeonReadyDialogCloseButton, true)
    _G.LFGDungeonReadyDialogCloseButton:SetSize(20, 20)
    _G.LFGDungeonReadyDialogCloseButton:ClearAllPoints()
    _G.LFGDungeonReadyDialogCloseButton:SetPoint("TOPRIGHT", -3, -3)

    SkinButton(LFGDungeonReadyDialog.enterButton, false, true)
    SkinButton(LFGDungeonReadyDialog.leaveButton, false, true)

    LFGDungeonReadyDialog.instanceInfo.underline:Hide()
    
    LFGDungeonReadyDialog:SetBackdrop(constBackdropFrame)
end
local function SkinLFGDungeonReadyDialog()
    hooksecurefunc("LFGDungeonReadyPopup_Update", SkinLFGDungeonReadyDialog_OnUpdate)
end
GW.SkinLFGDungeonReadyDialog = SkinLFGDungeonReadyDialog