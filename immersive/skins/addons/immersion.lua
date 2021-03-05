local _, GW = ...

local function LoadImmersionAddonSkin()
    if not GW.GetSetting("IMMERSIONADDON_SKIN_ENABLED") then return end

    local ImmersionFrame = _G.ImmersionFrame

    if ImmersionFrame then
        ImmersionFrame.TalkBox.MainFrame.CloseButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal")
        ImmersionFrame.TalkBox.MainFrame.CloseButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover")
        ImmersionFrame.TalkBox.MainFrame.CloseButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover")
        ImmersionFrame.TalkBox.MainFrame.CloseButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal")
        ImmersionFrame.TalkBox.MainFrame.CloseButton:SetSize(25, 25)
        ImmersionFrame.TalkBox.MainFrame.CloseButton:ClearAllPoints()
        ImmersionFrame.TalkBox.MainFrame.CloseButton:SetPoint("TOPRIGHT", -30, -8)

        ImmersionFrame.TalkBox.BackgroundFrame.TextBackground:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

        ImmersionFrame.TalkBox.Hilite:Hide()

        ImmersionFrame.TalkBox.MainFrame.Indicator:SetPoint("TOPRIGHT", -56, -13)
    end
end
GW.LoadImmersionAddonSkin = LoadImmersionAddonSkin