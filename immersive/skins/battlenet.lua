local _, GW = ...

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

    BNToastFrame.CloseButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal")
    BNToastFrame.CloseButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover")
    BNToastFrame.CloseButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover")

    BNToastFrame:HookScript("OnShow", resizeBNToastFrame)
end
GW.SkinBNToastFrame = SkinBNToastFrame