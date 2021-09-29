local _, GW = ...
local RegisterMovableFrame = GW.RegisterMovableFrame

local function SkinBNToastFrame()
    local BNToastFrame = _G.BNToastFrame

    BNToastFrame:SetBackdrop(nil)

    local tex = BNToastFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", BNToastFrame, "TOP", 0, 0)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    tex:SetSize(BNToastFrame:GetSize())
    BNToastFrame.tex = tex

    BNToastFrame.CloseButton:SkinButton(true)

    BNToastFrame:HookScript("OnShow", function(self)
        self.tex:SetSize(_G.BNToastFrame:GetSize())

        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", self.gwMover)

        -- remove SetPoint after "OnShow" function
        self.ClearAllPoints =GW.NoOp
        self.SetPoint = GW.NoOp
    end)

    RegisterMovableFrame(BNToastFrame, "BNet Frame", "BNToastPos", "VerticalActionBarDummy", nil, nil, {"default", "scaleable"})
end
GW.SkinBNToastFrame = SkinBNToastFrame