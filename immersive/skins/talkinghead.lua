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

local function InitTalkingHeadFrame()
    UIPARENT_MANAGED_FRAME_POSITIONS.TalkingHeadFrame = nil

    local point = GW.GetSetting("TalkingHeadFrame_pos")
    TalkingHeadFrame:ClearAllPoints()
    TalkingHeadFrame:SetPoint(point.point, UIParent, point.relativePoint, point.xOfs, point.yOfs)

    -- remove TalkingHeadFrame from Alert System
    for i, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
        if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame == TalkingHeadFrame then
            tremove(AlertFrame.alertFrameSubSystems, i)
        end
    end

    GW.RegisterMovableFrame(TalkingHeadFrame, "Talking Head Frame", "TalkingHeadFrame_pos", "VerticalActionBarDummy")

    -- Skin
    hooksecurefunc("TalkingHeadFrame_PlayCurrent", SkinTalkingHeadFrame_OnShow)
end

local function SkinAndPositionTalkingHeadFrame()
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
GW.SkinAndPositionTalkingHeadFrame = SkinAndPositionTalkingHeadFrame
