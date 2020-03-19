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
    "EditBox",
    "ResizeButton",
    "ButtonFrameBackground",
    "ButtonFrameTopLeftTexture",
    "ButtonFrameBottomLeftTexture",
    "ButtonFrameTopRightTexture",
    "ButtonFrameBottomRightTexture",
    "ButtonFrameBottomButton",
    "ButtonFrameDownButton",
    "ButtonFrameUpButton",
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

local function chatFaderIN(frame, from, to)
    UIFrameFadeIn(frame, 0.1, from, to)
end
GW.AddForProfiling("chatframe", "chatFaderIN", chatFaderIN)

local function chatFaderOut(frame, from, to)
    UIFrameFadeOut(frame, 0.3, from, to)
end
GW.AddForProfiling("chatframe", "chatFaderOut", chatFaderOut)

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
            chatFaderIN(object, object:GetAlpha(), 1)
        end
    end

    for k, v in pairs(gw_fade_frames) do
        if v == ChatFrameToggleVoiceDeafenButton or v == ChatFrameToggleVoiceMuteButton then
            if v == ChatFrameToggleVoiceDeafenButton and ChatFrameToggleVoiceDeafenButton:IsShown() then
                chatFaderIN(v, v:GetAlpha(), 1)
            elseif v == ChatFrameToggleVoiceMuteButton and ChatFrameToggleVoiceMuteButton:IsShown() then
                chatFaderIN(v, v:GetAlpha(), 1)
            end
        else
            chatFaderIN(v, v:GetAlpha(), 1)
        end   
    end
    local chatTab = _G[frameName .. "Tab"]
    chatFaderIN(chatTab, chatTab:GetAlpha(), 1)
    chatFaderIN(chatFrame.buttonFrame, chatFrame.buttonFrame:GetAlpha(), 1)
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
            chatFaderOut(object, object:GetAlpha(), 0)
        end
    end
    for k, v in pairs(gw_fade_frames) do
        if v == ChatFrameToggleVoiceDeafenButton or v == ChatFrameToggleVoiceMuteButton then
            if v == ChatFrameToggleVoiceDeafenButton and ChatFrameToggleVoiceDeafenButton:IsShown() then
                chatFaderOut(v, v:GetAlpha(), 0)
            elseif v == ChatFrameToggleVoiceMuteButton and ChatFrameToggleVoiceMuteButton:IsShown() then
                chatFaderOut(v, v:GetAlpha(), 0)
            end
        else
            chatFaderOut(v, v:GetAlpha(), 0)
        end
    end
    local chatTab = _G[frameName .. "Tab"]
    chatFaderOut(chatTab, chatTab:GetAlpha(), 0)

    chatFaderOut(chatFrame.buttonFrame, 2, chatFrame.buttonFrame:GetAlpha(), 0)
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

    _G["ChatFrame" .. useId .. "ButtonFrameBottomButton"]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
    _G["ChatFrame" .. useId .. "ButtonFrameBottomButton"]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_up")
    _G["ChatFrame" .. useId .. "ButtonFrameBottomButton"]:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
    _G["ChatFrame" .. useId .. "ButtonFrameBottomButton"]:SetHeight(24)
    _G["ChatFrame" .. useId .. "ButtonFrameBottomButton"]:SetWidth(24)

    _G["ChatFrame" .. useId .. "ButtonFrameDownButton"]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
    _G["ChatFrame" .. useId .. "ButtonFrameDownButton"]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_up")
    _G["ChatFrame" .. useId .. "ButtonFrameDownButton"]:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
    _G["ChatFrame" .. useId .. "ButtonFrameDownButton"]:SetHeight(24)
    _G["ChatFrame" .. useId .. "ButtonFrameDownButton"]:SetWidth(24)

    _G["ChatFrame" .. useId .. "ButtonFrameUpButton"]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowup_down")
    _G["ChatFrame" .. useId .. "ButtonFrameUpButton"]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowup_up")
    _G["ChatFrame" .. useId .. "ButtonFrameUpButton"]:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowup_down")
    _G["ChatFrame" .. useId .. "ButtonFrameUpButton"]:SetHeight(24)
    _G["ChatFrame" .. useId .. "ButtonFrameUpButton"]:SetWidth(24)
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

    if GetSetting("FONTS_ENABLED") then
        local _, fontSize = GetChatWindowInfo(useId)
        if fontSize > 0 then
            _G["ChatFrame" .. useId]:SetFont(STANDARD_TEXT_FONT, fontSize)
        elseif fontSize == 0 then
            --fontSize will be 0 if it's still at the default (14)
            _G["ChatFrame" .. useId]:SetFont(STANDARD_TEXT_FONT, 14)
        end
    end
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
    local fmGCC = CreateFrame("FRAME", "GwChatContainer", UIParent, "GwChatContainer")
    fmGCC:SetScript("OnSizeChanged", chatBackgroundOnResize)
    fmGCC:SetPoint("TOPLEFT", ChatFrame1, "TOPLEFT", -35, 5)
    fmGCC:SetPoint("BOTTOMRIGHT", ChatFrame1EditBoxRight, "BOTTOMRIGHT", 0, 0)

    for i = 1, FCF_GetNumActiveChatFrames() do
        styleChatWindow(i)
    end

    hooksecurefunc("FCF_NewChatWindow", function()
        for i = 1, FCF_GetNumActiveChatFrames() do
            styleChatWindow(i)
        end
    end)

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
        GwChatContainer,
        GeneralDockManager,
        ChatFrameChannelButton,
        ChatFrameToggleVoiceDeafenButton,
        ChatFrameToggleVoiceMuteButton
    }

    FCF_FadeOutChatFrame(_G["ChatFrame1"])

    --Skin ChatMenus
    local ChatMenus = {
		"ChatMenu",
		"EmoteMenu",
		"LanguageMenu",
		"VoiceMacroMenu",
	}

	for i = 1, #ChatMenus do
        _G[ChatMenus[i]]:HookScript("OnShow", 
            function(self)
                self:SetBackdrop(GW.skins.constBackdropFrame)
            end)
	end
end
GW.LoadChat = LoadChat