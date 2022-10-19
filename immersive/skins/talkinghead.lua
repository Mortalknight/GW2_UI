local _, GW = ...

local function InitTalkingHeadFrame()
    -- remove TalkingHeadFrame from Alert System
    for i, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
        if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame == TalkingHeadFrame then
            tremove(AlertFrame.alertFrameSubSystems, i)
        end
    end

    GW.RegisterMovableFrame(TalkingHeadFrame, "Talking Head Frame", "TalkingHeadFrame_pos", "VerticalActionBarDummy", nil, {"default", "scaleable"})
    TalkingHeadFrame:ClearAllPoints()
    TalkingHeadFrame:SetPoint("TOPLEFT", TalkingHeadFrame.gwMover)

    --Reset Model Camera
    local model = TalkingHeadFrame.MainFrame.Model
    if model.uiCameraID then
        model:RefreshCamera()
        _G.Model_ApplyUICamera(model, model.uiCameraID)
    end

    -- Skin
    TalkingHeadFrame.BackgroundFrame.TextBackground:SetAtlas(nil)
    TalkingHeadFrame.PortraitFrame.Portrait:SetAtlas(nil)
    TalkingHeadFrame.MainFrame.Model.PortraitBg:SetAtlas(nil)

    TalkingHeadFrame.BackgroundFrame.TextBackground.SetAtlas = GW.NoOp
	TalkingHeadFrame.PortraitFrame.Portrait.SetAtlas = GW.NoOp
	TalkingHeadFrame.MainFrame.Model.PortraitBg.SetAtlas = GW.NoOp

    TalkingHeadFrame.NameFrame.Name:SetTextColor(1, 0.82, 0.02)
    TalkingHeadFrame.NameFrame.Name.SetTextColor = GW.NoOp
    TalkingHeadFrame.NameFrame.Name:SetShadowColor(0, 0, 0, 1)
    TalkingHeadFrame.NameFrame.Name:SetShadowOffset(2, -2)

    TalkingHeadFrame.TextFrame.Text:SetTextColor(1, 1, 1)
    TalkingHeadFrame.TextFrame.Text.SetTextColor = GW.NoOp
    TalkingHeadFrame.TextFrame.Text:SetShadowColor(0, 0, 0, 1)
    TalkingHeadFrame.TextFrame.Text:SetShadowOffset(2, -2)

    TalkingHeadFrame.MainFrame.CloseButton:SkinButton(true)
    TalkingHeadFrame.MainFrame.CloseButton:SetSize(25, 25)
    TalkingHeadFrame.MainFrame.CloseButton:ClearAllPoints()
    TalkingHeadFrame.MainFrame.CloseButton:SetPoint("TOPRIGHT", -30, -8)

    TalkingHeadFrame.BackgroundFrame.TextBackground:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
end

local function LoadTalkingHeadSkin()
    GW.RegisterLoadHook(InitTalkingHeadFrame, "Blizzard_TalkingHeadUI", TalkingHeadFrame)
end
GW.LoadTalkingHeadSkin = LoadTalkingHeadSkin
