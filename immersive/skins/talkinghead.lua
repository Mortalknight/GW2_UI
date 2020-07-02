local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame

local function SkinTalkingHeadFrame_OnShow()
    local TalkingHeadFrame = _G.TalkingHeadFrame

    TalkingHeadFrame.MainFrame.CloseButton:SkinButton(true)
    TalkingHeadFrame.MainFrame.CloseButton:SetSize(25, 25)
    TalkingHeadFrame.MainFrame.CloseButton:ClearAllPoints()
    TalkingHeadFrame.MainFrame.CloseButton:SetPoint("TOPRIGHT", -30, -8)

    TalkingHeadFrame.BackgroundFrame.TextBackground:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
end

local function SkinTalkingHeadFrame()
    if _G.TalkingHeadFrame then
        hooksecurefunc("TalkingHeadFrame_PlayCurrent", SkinTalkingHeadFrame_OnShow)
    else
        hooksecurefunc("TalkingHead_LoadUI", SkinTalkingHeadFrame)
    end
end
GW.SkinTalkingHeadFrame = SkinTalkingHeadFrame
