local _, GW = ...
local SkinButton = GW.skins.SkinButton

local function resizeBNToastFrame()
    local BNToastFrame = _G.BNToastFrame
    BNToastFrame.tex:SetSize(BNToastFrame:GetSize())
end

local function SkinBNToastFrame()
    local BNToastFrame = _G.BNToastFrame

    BNToastFrame:SetBackdrop(nil)

    local tex = BNToastFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", BNToastFrame, "TOP", 0, 0)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    tex:SetSize(BNToastFrame:GetSize())
    BNToastFrame.tex = tex

    SkinButton(BNToastFrame.CloseButton, true)

    BNToastFrame:HookScript("OnShow", resizeBNToastFrame)
end
GW.SkinBNToastFrame = SkinBNToastFrame