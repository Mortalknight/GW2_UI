local _, GW = ...
local RegisterMovableFrame = GW.RegisterMovableFrame

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

local function hook_SetPoint(self, _, anchor)
    if anchor ~= self.gwMover then
        self:ClearAllPoints()
        self:SetPoint(self.gwMover.anchorPoint or "TOPLEFT", self.gwMover, self.gwMover.anchorPoint or "TOPLEFT")
    end
end

local function LoadBNToastSkin()
    if not GW.settings.BNTOASTFRAME_SKIN_ENABLED then return end

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
            bgFile = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png",
            edgeSize = GW.Scale(1)
        })
    end

    BNToastFrame.CloseButton:GwSkinButton(true)

    ReportFrame:GwStripTextures()
    if not ReportFrame.SetBackdrop then
        Mixin(ReportFrame, BackdropTemplateMixin)
        ReportFrame:HookScript("OnSizeChanged", ReportFrame.OnBackdropSizeChanged)
    end

    ReportFrame:SetBackdrop({
        edgeFile = "",
        bgFile = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png",
        edgeSize = GW.Scale(1)
    })

    ReportFrame.Comment:GwStripTextures()
    ReportFrame.Comment:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, 4)
    GW.HandleBlizzardRegions(ReportFrame.Comment)
    ReportFrame.CloseButton:GwSkinButton(true)
    ReportFrame.ReportButton:GwSkinButton(false, true)
    ReportFrame.ReportingMajorCategoryDropdown:GwHandleDropDownBox()

    ReportFrame.CloseButton:SetSize(20, 20)

    BattleTagInviteFrame:GwStripTextures()

    if not BattleTagInviteFrame.SetBackdrop then
        Mixin(BattleTagInviteFrame, BackdropTemplateMixin)
        BattleTagInviteFrame:HookScript("OnSizeChanged", BattleTagInviteFrame.OnBackdropSizeChanged)
    end

    BattleTagInviteFrame:SetBackdrop({
        edgeFile = "",
        bgFile = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png",
        edgeSize = GW.Scale(1)
    })

    for i = 1, BattleTagInviteFrame:GetNumChildren() do
        local child = select(i, BattleTagInviteFrame:GetChildren())
        if child:IsObjectType("Button") then
            child:GwSkinButton(false, true)
        end
    end

    -- do not trigger this code if ElvUI controlls that frame
    if BNToastFrame and BNToastFrame.mover and BNToastFrame.mover:GetName() == "BNETMover" then return end

    RegisterMovableFrame(BNToastFrame, "BNet Frame", "BNToastPos", ALL .. ",Blizzard", nil, {"default", "scaleable"}, nil, BNTostPostDrag, true)

    hooksecurefunc(BNToastFrame, "SetPoint", hook_SetPoint)
end
GW.LoadBNToastSkin = LoadBNToastSkin