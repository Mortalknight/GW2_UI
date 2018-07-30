local _, GW = ...

local GetSetting = GW.GetSetting

local CHAT_FRAME_TEXTURES = {
    "TopLeftTexture",
    "BottomLeftTexture",
    "TopRightTexture",
    "BottomRightTexture",
    "LeftTexture",
    "RightTexture",
    "BottomTexture",
    "TopTexture",
    --"ResizeButton",

    "EditBox",
    "ResizeButton",
    "ButtonFrameBackground",
    "ButtonFrameTopLeftTexture",
    "ButtonFrameBottomLeftTexture",
    "ButtonFrameTopRightTexture",
    "ButtonFrameBottomRightTexture",
    "ButtonFrameLeftTexture",
    "ButtonFrameRightTexture",
    "ButtonFrameBottomTexture",
    "ButtonFrameTopTexture",
    "EditBoxMid",
    "EditBoxLeft",
    "EditBoxRight",
    "TabSelectedRight",
    "TabSelectedLeft",
    "TabSelectedMiddle",
    "TabRight",
    "TabLeft",
    "TabMiddle"
}

local gw_fade_frames = {}

local function chatFader(frame, to, from)
    UIFrameFadeIn(frame, 2, from, to)
end
GW.AddForProfiling("chatframe", "chatFader", chatFader)

local function setChatBackgroundColor()
    for i = 1, 10 do
        if _G["ChatFrame" .. i .. "Background"] then
            _G["ChatFrame" .. i .. "Background"]:SetVertexColor(0, 0, 0, 0)
            _G["ChatFrame" .. i .. "Background"]:SetAlpha(0)
            _G["ChatFrame" .. i .. "Background"]:Hide()
            if _G["ChatFrame" .. i .. "ButtonFrameBackground"] then
                _G["ChatFrame" .. i .. "ButtonFrameBackground"]:SetVertexColor(0, 0, 0, 0)
                _G["ChatFrame" .. i .. "ButtonFrameBackground"]:Hide()
                _G["ChatFrame" .. i .. "RightTexture"]:SetVertexColor(0, 0, 0, 1)
            end
        end
    end
end
GW.AddForProfiling("chatframe", "setChatBackgroundColor", setChatBackgroundColor)

local function handleChatFrameFadeIn(chatFrame)
    if not GetSetting("CHATFRAME_FADE") then
        return
    end

    setChatBackgroundColor()
    local frameName = chatFrame:GetName()
    for k, v in pairs(CHAT_FRAME_TEXTURES) do
        local object = _G[chatFrame:GetName() .. v]
        if object and object:IsShown() then
            chatFader(object, object:GetAlpha(), 1)
        end
    end

    for k, v in pairs(gw_fade_frames) do
        chatFader(v, v:GetAlpha(), 1)
    end
    local chatTab = _G[frameName .. "Tab"]
    chatFader(chatTab, chatTab:GetAlpha(), 1)
    chatFader(chatFrame.buttonFrame, chatFrame.buttonFrame:GetAlpha(), 1)
    _G[frameName .. "ButtonFrame"]:Show()
    ChatFrameMenuButton:Show()
end
GW.AddForProfiling("chatframe", "handleChatFrameFadeIn", handleChatFrameFadeIn)

local function handleChatFrameFadeOut(chatFrame)
    if not GetSetting("CHATFRAME_FADE") then
        return
    end
    setChatBackgroundColor()
    if chatFrame.editboxHasFocus then
        handleChatFrameFadeIn(chatFrame)
        return
    end

    local frameName = chatFrame:GetName()
    for k, v in pairs(CHAT_FRAME_TEXTURES) do
        local object = _G[chatFrame:GetName() .. v]
        if object and object:IsShown() then
            UIFrameFadeOut(object, 2, object:GetAlpha(), 0)
        end
    end
    for k, v in pairs(gw_fade_frames) do
        UIFrameFadeOut(v, 2, v:GetAlpha(), 0)
    end
    local chatTab = _G[frameName .. "Tab"]
    UIFrameFadeOut(chatTab, 2, chatTab:GetAlpha(), 0)

    UIFrameFadeOut(chatFrame.buttonFrame, 2, chatFrame.buttonFrame:GetAlpha(), 0)
    _G[frameName .. "ButtonFrame"]:Hide()
    ChatFrameMenuButton:Hide()
end
GW.AddForProfiling("chatframe", "handleChatFrameFadeOut", handleChatFrameFadeOut)

local function styleChatWindow(useId)
    local cf = _G["ChatFrame" .. useId]
    local cfeb = _G["ChatFrame" .. useId .. "EditBox"]
    local cfbg = _G["ChatFrame" .. useId .. "Background"]

    if not cf or not cfeb or not cfbg then
        return
    end

    if not cf.gwhasBeenHooked then
        if cf == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) then
            cfeb:Show()
        end

        cfeb.editboxHasFocus = false
        cfeb:HookScript(
            "OnEditFocusGained",
            function()
                cf.editboxHasFocus = true
                cf:SetScript(
                    "OnUpdate",
                    function()
                        handleChatFrameFadeIn(cf)
                    end
                )

                FCF_FadeInChatFrame(cf)
                cfeb:SetText("")
            end
        )

        cfeb:HookScript(
            "OnEditFocusLost",
            function()
                cf:SetScript("OnUpdate", nil)
                cf.editboxHasFocus = false
                FCF_FadeOutChatFrame(cf)
            end
        )

        cfeb:HookScript(
            "OnHide",
            function(self)
                if cf == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) then
                    self:Show()
                end
            end
        )

        hooksecurefunc(
            _G["ChatFrame" .. useId .. "EditBoxHeader"],
            "SetTextColor",
            function()
                if not string.find(_G["ChatFrame" .. useId .. "EditBoxHeader"]:GetText(), "%[") then
                    local newText = string.gsub(_G["ChatFrame" .. useId .. "EditBoxHeader"]:GetText(), ": ", "")
                    _G["ChatFrame" .. useId .. "EditBoxHeader"]:SetText("[" .. newText .. "] ")
                end
            end
        )

        cf.gwhasBeenHooked = true
    end

    cf.ScrollToBottomButton:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
    cf.ScrollToBottomButton:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_up")
    cf.ScrollToBottomButton:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
    cf.ScrollToBottomButton:SetHeight(24)
    cf.ScrollToBottomButton:SetWidth(24)
    ChatFrameMenuButton:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\bubble_down")
    ChatFrameMenuButton:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\bubble_up")
    ChatFrameMenuButton:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\bubble_down")

    ChatFrameMenuButton:SetHeight(20)
    ChatFrameMenuButton:SetWidth(20)

    _G["ChatFrame" .. useId .. "TabSelectedRight"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\chattabactiveright")
    _G["ChatFrame" .. useId .. "TabSelectedLeft"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\chattabactiveleft")
    _G["ChatFrame" .. useId .. "TabSelectedMiddle"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\chattabactive")

    _G["ChatFrame" .. useId .. "TabMiddle"]:SetHeight(40)
    _G["ChatFrame" .. useId .. "TabLeft"]:SetHeight(40)
    _G["ChatFrame" .. useId .. "TabRight"]:SetHeight(40)

    _G["ChatFrame" .. useId .. "TabLeft"]:SetPoint("BOTTOM", GeneralDockManager, "BOTTOM", 0, -4)
    _G["ChatFrame" .. useId .. "TabMiddle"]:SetPoint("BOTTOM", GeneralDockManager, "BOTTOM", 0, -4)

    _G["ChatFrame" .. useId .. "TabSelectedRight"]:SetBlendMode("BLEND")
    _G["ChatFrame" .. useId .. "TabSelectedLeft"]:SetBlendMode("BLEND")
    _G["ChatFrame" .. useId .. "TabSelectedMiddle"]:SetBlendMode("BLEND")

    _G["ChatFrame" .. useId .. "TabSelectedRight"]:SetVertexColor(1, 1, 1, 1)
    _G["ChatFrame" .. useId .. "TabSelectedLeft"]:SetVertexColor(1, 1, 1, 1)
    _G["ChatFrame" .. useId .. "TabSelectedMiddle"]:SetVertexColor(1, 1, 1, 1)

    _G["ChatFrame" .. useId .. "TabText"]:SetFont(DAMAGE_TEXT_FONT, 14)
    _G["ChatFrame" .. useId .. "TabText"]:SetTextColor(1, 1, 1)

    _G["ChatFrame" .. useId .. "TabHighlightMiddle"]:SetTexture(nil)
    _G["ChatFrame" .. useId .. "TabHighlightRight"]:SetTexture(nil)
    _G["ChatFrame" .. useId .. "TabHighlightLeft"]:SetTexture(nil)

    _G["ChatFrame" .. useId .. "TabMiddle"]:SetTexture(nil)
    _G["ChatFrame" .. useId .. "TabLeft"]:SetTexture(nil)
    _G["ChatFrame" .. useId .. "TabRight"]:SetTexture(nil)

    _G["ChatFrame" .. useId .. "ButtonFrameTopTexture"]:SetTexture(nil)
    _G["ChatFrame" .. useId .. "ButtonFrameRightTexture"]:SetTexture(nil)
    _G["ChatFrame" .. useId .. "ButtonFrameLeftTexture"]:SetTexture(nil)
    _G["ChatFrame" .. useId .. "ButtonFrameBottomTexture"]:SetTexture(nil)
    _G["ChatFrame" .. useId .. "TopTexture"]:SetTexture(nil)
    _G["ChatFrame" .. useId .. "BottomTexture"]:SetTexture(nil)
    _G["ChatFrame" .. useId .. "RightTexture"]:SetTexture(nil)
    _G["ChatFrame" .. useId .. "LeftTexture"]:SetTexture(nil)

    cfeb:ClearAllPoints()
    cfeb:SetPoint("TOPLEFT", _G["ChatFrame" .. useId .. "ButtonFrame"], "BOTTOMLEFT", 0, 0)
    cfeb:SetPoint("TOPRIGHT", cfbg, "BOTTOMRIGHT", 0, 0)

    _G["ChatFrame" .. useId .. "EditBoxRight"]:SetTexture(nil)
    _G["ChatFrame" .. useId .. "EditBoxLeft"]:SetTexture(nil)
    _G["ChatFrame" .. useId .. "EditBoxMid"]:SetTexture(nil)

    _G["ChatFrame" .. useId .. "EditBoxFocusRight"]:SetTexture(nil)
    _G["ChatFrame" .. useId .. "EditBoxFocusLeft"]:SetTexture(nil)
    _G["ChatFrame" .. useId .. "EditBoxFocusMid"]:SetTexture(nil)
end
GW.AddForProfiling("chatframe", "styleChatWindow", styleChatWindow)

local function chatBackgroundOnResize(self)
    local w, h = self:GetSize()

    w = math.min(1, w / 512)
    h = math.min(1, h / 512)

    self.texture:SetTexCoord(0, w, 1 - h, 1)
end
GW.AddForProfiling("chatframe", "chatBackgroundOnResize", chatBackgroundOnResize)

local function LoadChat()
    if QuickJoinToastButton ~= nil then
        QuickJoinToastButton:SetDisabledTexture("Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down")
        QuickJoinToastButton:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down")
        QuickJoinToastButton:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down")
        QuickJoinToastButton:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down")
        QuickJoinToastButton:SetWidth(25)
        QuickJoinToastButton:SetHeight(25)
        QuickJoinToastButton:ClearAllPoints()
        QuickJoinToastButton:SetPoint("RIGHT", GeneralDockManager, "LEFT", -3, -3)
    end

    local fmGCC = CreateFrame("FRAME", "GwChatContainer", UIParent, "GwChatContainer")
    fmGCC:SetScript("OnSizeChanged", chatBackgroundOnResize)
    fmGCC:SetPoint("TOPLEFT", ChatFrame1, "TOPLEFT", -35, 5)
    fmGCC:SetPoint("BOTTOMRIGHT", ChatFrame1EditBoxFocusRight, "BOTTOMRIGHT", 0, 0)

    for i = 1, 10 do
        styleChatWindow(i)
    end

    hooksecurefunc(
        "FCFTab_UpdateColors",
        function(self, selected)
            self:GetFontString():SetTextColor(1, 1, 1)
            self.leftSelectedTexture:SetVertexColor(1, 1, 1)
            self.middleSelectedTexture:SetVertexColor(1, 1, 1)
            self.rightSelectedTexture:SetVertexColor(1, 1, 1)

            self.leftHighlightTexture:SetVertexColor(1, 1, 1)
            self.middleHighlightTexture:SetVertexColor(1, 1, 1)
            self.rightHighlightTexture:SetVertexColor(1, 1, 1)
            self.glow:SetVertexColor(1, 1, 1)
        end
    )

    hooksecurefunc("FCF_FadeOutChatFrame", handleChatFrameFadeOut)
    hooksecurefunc("FCF_FadeInChatFrame", handleChatFrameFadeIn)
    hooksecurefunc("FCFTab_UpdateColors", setChatBackgroundColor)

    gw_fade_frames = {
        QuickJoinToastButton,
        GwChatContainer,
        GeneralDockManager,
        ChatFrameChannelButton
    }

    FCF_FadeOutChatFrame(_G["ChatFrame1"])
end
GW.LoadChat = LoadChat
