local _, GW = ...

local function SkinTalkingHeadFrame_OnShow()
    local TalkingHeadFrame = _G.TalkingHeadFrame

    TalkingHeadFrame.MainFrame.CloseButton:SkinButton(true)
    TalkingHeadFrame.MainFrame.CloseButton:SetSize(25, 25)
    TalkingHeadFrame.MainFrame.CloseButton:ClearAllPoints()
    TalkingHeadFrame.MainFrame.CloseButton:SetPoint("TOPRIGHT", -30, -8)

    TalkingHeadFrame.BackgroundFrame.TextBackground:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
end

local function InitTalkingHeadFrame()
    UIPARENT_MANAGED_FRAME_POSITIONS.TalkingHeadFrame = nil

    -- remove TalkingHeadFrame from Alert System
    for i, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
        if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame == TalkingHeadFrame then
            tremove(AlertFrame.alertFrameSubSystems, i)
        end
    end

    GW.RegisterMovableFrame(TalkingHeadFrame, "Talking Head Frame", "TalkingHeadFrame_pos", "VerticalActionBarDummy", nil, nil, {"default", "scaleable"})
    TalkingHeadFrame:ClearAllPoints()
    TalkingHeadFrame:SetPoint("TOPLEFT", TalkingHeadFrame.gwMover)

    --Reset Model Camera
    local model = TalkingHeadFrame.MainFrame.Model
    if model.uiCameraID then
        model:RefreshCamera()
        _G.Model_ApplyUICamera(model, model.uiCameraID)
    end

    -- Skin
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
    hooksecurefunc("TalkingHeadFrame_PlayCurrent", SkinTalkingHeadFrame_OnShow)
end

local function LoadTalkingHeadSkin()
    if not GW.GetSetting("TALKINGHEAD_SKIN_ENABLED") then return end

    if IsAddOnLoaded("Blizzard_TalkingHeadUI") then
        InitTalkingHeadFrame()
    else
        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_ENTERING_WORLD")
        f:SetScript("OnEvent", function(self, event)
            self:UnregisterEvent(event)
            _G.TalkingHead_LoadUI()
            InitTalkingHeadFrame()
        end)
    end
end
GW.LoadTalkingHeadSkin = LoadTalkingHeadSkin
