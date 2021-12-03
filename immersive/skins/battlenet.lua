local _, GW = ...
local RegisterMovableFrame = GW.RegisterMovableFrame
local GetSetting = GW.GetSetting

local function BNTostPostDrag(self)
    local x, y = self.gwMover:GetCenter()
    local screenHeight = UIParent:GetTop()
    local screenWidth = UIParent:GetRight()

    local anchorPoint
    if y > (screenHeight / 2) then
        anchorPoint = (x > (screenWidth / 2)) and "TOPRIGHT" or "TOPLEFT"
    else
        anchorPoint = (x > (screenWidth / 2)) and "BOTTOMRIGHT" or "BOTTOMLEFT"
    end
    self.gwMover.anchorPoint = anchorPoint

    BNToastFrame:ClearAllPoints()
    BNToastFrame:SetPoint(anchorPoint, self.gwMover)
end

local function LoadBNToastSkin()
    if not GetSetting("BNTOASTFRAME_SKIN_ENABLED") then return end

    local skins = {
        BNToastFrame,
        TimeAlertFrame,
        TicketStatusFrameButton.Background.NineSlice
    }

    for i = 1, #skins do
        if not skins[i].SetBackdrop then
            Mixin(skins[i], BackdropTemplateMixin)
            skins[i]:HookScript("OnSizeChanged", skins[i].OnBackdropSizeChanged)
        end

        skins[i]:SetBackdrop({
            edgeFile = "",
            bgFile = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg",
            edgeSize = GW.Scale(1)
        })
    end

    BNToastFrame.CloseButton:SkinButton(true)

    PlayerReportFrame:StripTextures()
    if not PlayerReportFrame.SetBackdrop then
        Mixin(PlayerReportFrame, BackdropTemplateMixin)
        PlayerReportFrame:HookScript("OnSizeChanged", PlayerReportFrame.OnBackdropSizeChanged)
    end

    PlayerReportFrame:SetBackdrop({
        edgeFile = "",
        bgFile = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg",
        edgeSize = GW.Scale(1)
    })

    PlayerReportFrame.Comment:StripTextures()
    PlayerReportFrame.Comment:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true, 4)
    GW.HandleBlizzardRegions(PlayerReportFrame.Comment)
    PlayerReportFrame.ReportButton:SkinButton(false, true)
    PlayerReportFrame.CancelButton:SkinButton(false, true)

    ReportCheatingDialog:StripTextures()
    ReportCheatingDialogCommentFrame:StripTextures()
    ReportCheatingDialogReportButton:SkinButton(false, true)
    ReportCheatingDialogCancelButton:SkinButton(false, true)

    if not ReportCheatingDialog.SetBackdrop then
        Mixin(ReportCheatingDialog, BackdropTemplateMixin)
        ReportCheatingDialog:HookScript("OnSizeChanged", ReportCheatingDialog.OnBackdropSizeChanged)
    end

    ReportCheatingDialog:SetBackdrop({
        edgeFile = "",
        bgFile = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg",
        edgeSize = GW.Scale(1)
    })

    ReportCheatingDialogCommentFrameEditBox:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true, 4)
    GW.HandleBlizzardRegions(ReportCheatingDialogCommentFrameEditBox)

    BattleTagInviteFrame:StripTextures()

    if not BattleTagInviteFrame.SetBackdrop then
        Mixin(BattleTagInviteFrame, BackdropTemplateMixin)
        BattleTagInviteFrame:HookScript("OnSizeChanged", BattleTagInviteFrame.OnBackdropSizeChanged)
    end

    BattleTagInviteFrame:SetBackdrop({
        edgeFile = "",
        bgFile = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg",
        edgeSize = GW.Scale(1)
    })

    for i = 1, BattleTagInviteFrame:GetNumChildren() do
        local child = select(i, BattleTagInviteFrame:GetChildren())
        if child:IsObjectType("Button") then
            child:SkinButton(false, true)
        end
    end

    RegisterMovableFrame(BNToastFrame, "BNet Frame", "BNToastPos", "VerticalActionBarDummy", nil, nil, {"default", "scaleable"}, nil, BNTostPostDrag)

    hooksecurefunc(BNToastFrame, "SetPoint", function(self, _, anchor)
        if anchor ~= self.gwMover then
            self:ClearAllPoints()
            self:SetPoint(self.gwMover.anchorPoint or 'TOPLEFT', self.gwMover, self.gwMover.anchorPoint or 'TOPLEFT')
        end
    end)
end
GW.LoadBNToastSkin = LoadBNToastSkin