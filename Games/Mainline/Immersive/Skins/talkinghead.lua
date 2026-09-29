---@class GW2
local GW = select(2, ...)

local BACKGROUND = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png"

local function ScaleTalkingHeadFrame()
    TalkingHeadFrame:SetScale(GW.settings.skins.talkingHead.scale)

    -- the model camera does not follow the new scale by itself
    local model = TalkingHeadFrame.MainFrame.Model
    if model.uiCameraID then
        model:RefreshCamera()
        Model_ApplyUICamera(model, model.uiCameraID)
    end
end
GW.ScaleTalkingHeadFrame = ScaleTalkingHeadFrame

-- every talk sets the atlases of its faction or texture kit again
local function UseOurBackground(texture)
    texture:SetTexture(BACKGROUND)
end

local function ClearArt(texture)
    texture:SetTexture()
end

local function InitTalkingHeadFrame()
    if not GW.settings.skins.talkingHead.enabled then return end
    local frame = TalkingHeadFrame

    -- we place the talking head ourselves, the alert system must not move it
    for i, subSystem in ipairs(AlertFrame.alertFrameSubSystems) do
        if subSystem.anchorFrame == frame then
            tremove(AlertFrame.alertFrameSubSystems, i)
            break
        end
    end

    local background = frame.BackgroundFrame.TextBackground
    UseOurBackground(background)
    hooksecurefunc(background, "SetAtlas", UseOurBackground)
    for _, art in ipairs({frame.PortraitFrame.Portrait, frame.MainFrame.Model.PortraitBg}) do
        ClearArt(art)
        hooksecurefunc(art, "SetAtlas", ClearArt)
    end

    -- gold name and white text with a hard shadow, whatever color the talk brings
    for text, color in pairs({[frame.NameFrame.Name] = {1, 0.82, 0.02}, [frame.TextFrame.Text] = {1, 1, 1}}) do
        GW.LockFontStringColor(text, unpack(color))
        text:SetShadowColor(0, 0, 0, 1)
        text:SetShadowOffset(2, -2)
    end

    local close = frame.MainFrame.CloseButton
    close:GwSkinButton(true)
    close:SetSize(25, 25)
    close:ClearAllPoints()
    close:SetPoint("TOPRIGHT", -30, -8)

    ScaleTalkingHeadFrame()
end

local function LoadTalkingHeadSkin()
    GW.RegisterLoadHook(InitTalkingHeadFrame, "TalkingHead", TalkingHeadFrame)
end
GW.LoadTalkingHeadSkin = LoadTalkingHeadSkin
