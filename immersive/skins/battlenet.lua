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
        TicketStatusFrameButton.NineSlice
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

    ReportFrame:StripTextures()
    if not ReportFrame.SetBackdrop then
        Mixin(ReportFrame, BackdropTemplateMixin)
        ReportFrame:HookScript("OnSizeChanged", ReportFrame.OnBackdropSizeChanged)
    end

    ReportFrame:SetBackdrop({
        edgeFile = "",
        bgFile = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg",
        edgeSize = GW.Scale(1)
    })

    ReportFrame.Comment:StripTextures()
    ReportFrame.Comment:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true, 4)
    GW.HandleBlizzardRegions(ReportFrame.Comment)
    ReportFrame.CloseButton:SkinButton(true)
    ReportFrame.ReportButton:SkinButton(false, true)
    ReportFrame.ReportingMajorCategoryDropdown:SkinDropDownMenu()

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

    RegisterMovableFrame(BNToastFrame, "BNet Frame", "BNToastPos", "VerticalActionBarDummy", nil, {"default", "scaleable"}, nil, BNTostPostDrag)

    hooksecurefunc(BNToastFrame, "SetPoint", function(self, _, anchor)
        if anchor ~= self.gwMover then
            self:ClearAllPoints()
            self:SetPoint(self.gwMover.anchorPoint or "TOPLEFT", self.gwMover, self.gwMover.anchorPoint or "TOPLEFT")
        end
    end)
end
GW.LoadBNToastSkin = LoadBNToastSkin