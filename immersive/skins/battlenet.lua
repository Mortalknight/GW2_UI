local _, GW = ...
local RegisterMovableFrame = GW.RegisterMovableFrame
local GetSetting = GW.GetSetting

local function SkinBNToastFrame()
    local BNToastFrame = _G.BNToastFrame
    BNToastFrame:CreateBackdrop()
    BNToastFrame.BottomRightCorner:Hide()
    BNToastFrame.RightEdge:Hide()
    BNToastFrame.TopRightCorner:Hide()
    BNToastFrame.TopEdge:Hide()
    BNToastFrame.TopLeftCorner:Hide()
    BNToastFrame.LeftEdge:Hide()
    BNToastFrame.BottomLeftCorner:Hide()
    BNToastFrame.BottomEdge:Hide()
    BNToastFrame.Center:Hide()

    local tex = BNToastFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", BNToastFrame, "TOP", 0, 0)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    tex:SetSize(BNToastFrame:GetSize())
    BNToastFrame.tex = tex

    BNToastFrame.CloseButton:SkinButton(true)

    BNToastFrame:HookScript("OnShow", function(self)
        self.tex:SetSize(_G.BNToastFrame:GetSize())

        local point = GetSetting("BNToastPos")
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", self.gwMover)

        -- remove SetPoint after "OnShow" function
        self.ClearAllPoints = GW.NoOp
        self.SetPoint = GW.NoOp
    end)

    RegisterMovableFrame(BNToastFrame, "BNet Frame", "BNToastPos", "VerticalActionBarDummy", nil, nil, {"default", "scaleable"})
end
GW.SkinBNToastFrame = SkinBNToastFrame