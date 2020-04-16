local _, GW = ...
local SkinScrollBar = GW.skins.SkinScrollBar
local StripTextures = GW.StripTextures
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
    "TabMiddle",
    "Tab",
    "TabText"
}

local tabTexs = {
    "",
    "Selected",
    "Highlight"
}

local gw_fade_frames = {}

local function setButtonPosition(frame)
    local frame = _G["ChatFrame"..frame:GetID()]
    local name = frame:GetName()
    local editbox = _G[name.."EditBox"]

    if frame.buttonSide == "right" then
        frame.Container:ClearAllPoints()
        frame.Container:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 5)
        if not frame.isDocked then
            frame.Container:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxRight"], "BOTTOMRIGHT", 5, editbox:GetHeight() - 0)
        else
            frame.Container:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxRight"], "BOTTOMRIGHT", 5, 0)
        end

        editbox:ClearAllPoints()
        editbox:SetPoint("TOPLEFT", frame.Background, "BOTTOMLEFT", 0, 0)
        editbox:SetPoint("TOPRIGHT", _G[name.."ButtonFrame"], "BOTTOMRIGHT", 0, 0)
    else
        frame.Container:ClearAllPoints()
        frame.Container:SetPoint("TOPLEFT", frame, "TOPLEFT", -35, 5)
        if not frame.isDocked then
            frame.Container:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxRight"], "BOTTOMRIGHT", 0, editbox:GetHeight() - 8)
        else
            frame.Container:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxRight"], "BOTTOMRIGHT", 0, 0)
        end

        editbox:ClearAllPoints()
        editbox:SetPoint("TOPLEFT", _G[name.."ButtonFrame"], "BOTTOMLEFT", 0, 0)
        editbox:SetPoint("TOPRIGHT", frame.Background, "BOTTOMRIGHT", 0, 0)
    end
end

local function setChatBackgroundColor(chatFrame)
    if chatFrame and chatFrame:GetName() then
        local chatframe = strfind(chatFrame:GetName(), "Tab") and string.sub(chatFrame:GetName(), 1,strfind(chatFrame:GetName(), "Tab") - 1) or chatFrame:GetName()
        if _G[chatframe .. "Background"] then
            _G[chatframe .. "Background"]:SetVertexColor(0, 0, 0, 0)
            _G[chatframe .. "Background"]:SetAlpha(0)
            _G[chatframe .. "Background"]:Hide()
            if _G[chatframe .. "ButtonFrameBackground"] then
                _G[chatframe .. "ButtonFrameBackground"]:SetVertexColor(0, 0, 0, 0)
                _G[chatframe .. "ButtonFrameBackground"]:Hide()
                _G[chatframe .. "RightTexture"]:SetVertexColor(0, 0, 0, 1)
            end
        end
    end
end
GW.AddForProfiling("chatframe", "setChatBackgroundColor", setChatBackgroundColor)

local function handleChatFrameFadeIn(chatFrame)
    if not GetSetting("CHATFRAME_FADE") then
        return
    end

    setChatBackgroundColor(chatFrame)
    local frameName = chatFrame:GetName()
    for k, v in pairs(CHAT_FRAME_TEXTURES) do
        local object = _G[chatFrame:GetName() .. v]
        if object and object:IsShown() then
            UIFrameFadeIn(object, 0.5, object:GetAlpha(), 1)
        end
    end

    if chatFrame.isDocked == 1 then
        for k, v in pairs(gw_fade_frames) do
            if v == ChatFrameToggleVoiceDeafenButton or v == ChatFrameToggleVoiceMuteButton then
                if v == ChatFrameToggleVoiceDeafenButton and ChatFrameToggleVoiceDeafenButton:IsShown() then
                    UIFrameFadeIn(v, 0.5, v:GetAlpha(), 1)
                elseif v == ChatFrameToggleVoiceMuteButton and ChatFrameToggleVoiceMuteButton:IsShown() then
                    UIFrameFadeIn(v, 0.5, v:GetAlpha(), 1)
                end
            else
                UIFrameFadeIn(v, 0.5, v:GetAlpha(), 1)
            end   
        end

        UIFrameFadeIn(_G["GwChatContainer" .. 1], 0.5, _G["GwChatContainer" .. 1]:GetAlpha(), 1)
        UIFrameFadeIn(ChatFrameMenuButton, 0.5, ChatFrameMenuButton:GetAlpha(), 1)
    elseif chatFrame.isDocked == nil then
        UIFrameFadeIn(_G["GwChatContainer" .. chatFrame:GetID()], 0.5, _G["GwChatContainer" .. chatFrame:GetID()]:GetAlpha(), 1)
    end

    local chatTab = _G[frameName .. "Tab"]
    UIFrameFadeIn(chatTab, 0.5, chatTab:GetAlpha(), 1)
    UIFrameFadeIn(chatFrame.buttonFrame, 0.5, chatFrame.buttonFrame:GetAlpha(), 1)
end
GW.AddForProfiling("chatframe", "handleChatFrameFadeIn", handleChatFrameFadeIn)

local function handleChatFrameFadeOut(chatFrame)
    if not GetSetting("CHATFRAME_FADE") then
        return
    end

    setChatBackgroundColor(chatFrame)
    if chatFrame.editboxHasFocus then
        handleChatFrameFadeIn(chatFrame)
        return
    end

    local chatAlpha = select(6, GetChatWindowInfo(chatFrame:GetID()))
    local frameName = chatFrame:GetName()
    
    for k, v in pairs(CHAT_FRAME_TEXTURES) do
        local object = _G[chatFrame:GetName() .. v]
        if object and object:IsShown() then
            UIFrameFadeOut(object, 2, object:GetAlpha(), 0)
        end
    end
    if chatFrame.isDocked == 1 then
        for k, v in pairs(gw_fade_frames) do
            if v == ChatFrameToggleVoiceDeafenButton or v == ChatFrameToggleVoiceMuteButton then
                if v == ChatFrameToggleVoiceDeafenButton and ChatFrameToggleVoiceDeafenButton:IsShown() then
                    UIFrameFadeOut(v, 2, v:GetAlpha(), 0)
                elseif v == ChatFrameToggleVoiceMuteButton and ChatFrameToggleVoiceMuteButton:IsShown() then
                    UIFrameFadeOut(v, 2, v:GetAlpha(), 0)
                end
            else
                UIFrameFadeOut(v, 2, v:GetAlpha(), 0)
            end
        end
        UIFrameFadeOut(_G["GwChatContainer" .. 1], 2, _G["GwChatContainer" .. 1]:GetAlpha(), chatAlpha)
    elseif chatFrame.isDocked == nil then
        UIFrameFadeOut(_G["GwChatContainer" .. chatFrame:GetID()], 2, _G["GwChatContainer" .. chatFrame:GetID()]:GetAlpha(), chatAlpha)
        UIFrameFadeOut(chatFrame.buttonFrame, 2, chatFrame.buttonFrame:GetAlpha(), 0)
    end

    local chatTab = _G[frameName .. "Tab"]
    UIFrameFadeOut(chatTab, 2, chatTab:GetAlpha(), 0)

    UIFrameFadeOut(chatFrame.buttonFrame, 2, chatFrame.buttonFrame:GetAlpha(), 0)
    UIFrameFadeOut(ChatFrameMenuButton, 2, ChatFrameMenuButton:GetAlpha(), 0)

    --check if other Tabs has Containers, which need to fade out
    for i = 1, FCF_GetNumActiveChatFrames() do
        if _G["ChatFrame" .. i].hasContainer and _G["ChatFrame" .. i].isDocked == chatFrame.isDocked and chatFrame:GetID() ~= i then
            UIFrameFadeOut(_G["GwChatContainer" .. i], 2, _G["GwChatContainer" .. i]:GetAlpha(), chatAlpha)
        end
    end
end
GW.AddForProfiling("chatframe", "handleChatFrameFadeOut", handleChatFrameFadeOut)

local function styleChatWindow(frame)
    local name = frame:GetName()
    _G[name.."TabText"]:SetFont(DAMAGE_TEXT_FONT, 14)
    _G[name.."TabText"]:SetTextColor(1, 1, 1)

    if frame.styled then return end

    frame:SetFrameLevel(4)

    local id = frame:GetID()
    local _, fontSize, _, _, _, _, _, _, isDocked = GetChatWindowInfo(id)

    local tab = _G[name.."Tab"]
    local editbox = _G[name.."EditBox"]
    local background = _G[name .. "Background"]

    if not frame.hasContainer and (isDocked == 1 or isDocked == nil) then
        local fmGCC = CreateFrame("FRAME", "GwChatContainer" .. id, UIParent, "GwChatContainer")
        fmGCC:SetScript("OnSizeChanged", chatBackgroundOnResize)
        fmGCC:SetPoint("TOPLEFT", frame, "TOPLEFT", -35, 5)
        if not frame.isDocked then
            fmGCC:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxRight"], "BOTTOMRIGHT", 0, editbox:GetHeight() - 8)
        else
            fmGCC:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxRight"], "BOTTOMRIGHT", 0, 0)
        end
        if not frame.isDocked then fmGCC.EditBox:Hide() end
        frame.Container = fmGCC
        frame.hasContainer = true
    end
    
    for _, texName in pairs(tabTexs) do
        if texName == "Selected" then
            _G[tab:GetName()..texName.."Right"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\chattabactiveright")
            _G[tab:GetName()..texName.."Left"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\chattabactiveleft")
            _G[tab:GetName()..texName.."Middle"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\chattabactive")
            
            _G[tab:GetName()..texName.."Right"]:SetBlendMode("BLEND")
            _G[tab:GetName()..texName.."Left"]:SetBlendMode("BLEND")
            _G[tab:GetName()..texName.."Middle"]:SetBlendMode("BLEND")

            _G[tab:GetName()..texName.."Right"]:SetVertexColor(1, 1, 1, 1)
            _G[tab:GetName()..texName.."Left"]:SetVertexColor(1, 1, 1, 1)
            _G[tab:GetName()..texName.."Middle"]:SetVertexColor(1, 1, 1, 1)
        elseif texName == "" then
            _G[tab:GetName()..texName.."Right"]:SetHeight(40)
            _G[tab:GetName()..texName.."Left"]:SetHeight(40)
            _G[tab:GetName()..texName.."Middle"]:SetHeight(40)

            _G[tab:GetName()..texName.."Left"]:SetPoint("BOTTOMLEFT", background, "TOPLEFT", 0, -4)
            _G[tab:GetName()..texName.."Middle"]:SetPoint("BOTTOMLEFT", background, "TOPLEFT", 0, -4)

            _G[tab:GetName()..texName.."Left"]:SetTexture()
            _G[tab:GetName()..texName.."Middle"]:SetTexture()
            _G[tab:GetName()..texName.."Right"]:SetTexture()
        else
            _G[tab:GetName()..texName.."Left"]:SetTexture()
            _G[tab:GetName()..texName.."Middle"]:SetTexture()
            _G[tab:GetName()..texName.."Right"]:SetTexture()
        end
    end

    _G[name .. "ButtonFrameBottomButton"]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
    _G[name .. "ButtonFrameBottomButton"]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_up")
    _G[name .. "ButtonFrameBottomButton"]:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
    _G[name .. "ButtonFrameBottomButton"]:SetHeight(24)
    _G[name .. "ButtonFrameBottomButton"]:SetWidth(24)

    _G[name .. "ButtonFrameDownButton"]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
    _G[name .. "ButtonFrameDownButton"]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_up")
    _G[name .. "ButtonFrameDownButton"]:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
    _G[name .. "ButtonFrameDownButton"]:SetHeight(24)
    _G[name .. "ButtonFrameDownButton"]:SetWidth(24)

    _G[name .. "ButtonFrameUpButton"]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowup_down")
    _G[name .. "ButtonFrameUpButton"]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowup_up")
    _G[name .. "ButtonFrameUpButton"]:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowup_down")
    _G[name .. "ButtonFrameUpButton"]:SetHeight(24)
    _G[name .. "ButtonFrameUpButton"]:SetWidth(24)
    
    ChatFrameMenuButton:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\bubble_down")
    ChatFrameMenuButton:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\bubble_up")
    ChatFrameMenuButton:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\bubble_down")
    ChatFrameMenuButton:SetHeight(20)
    ChatFrameMenuButton:SetWidth(20)

    hooksecurefunc(tab, "SetAlpha", function(t, alpha)
        if alpha ~= 1 and (not t.isDocked or _G.GeneralDockManager.selected:GetID() == t:GetID()) then
            t:SetAlpha(1)
        elseif alpha < 0.6 then
            t:SetAlpha(0.6)
        end
    end)
    
    tab.text = _G[name.."TabText"]
    tab.text:SetTextColor(1, 1, 1)
    hooksecurefunc(tab.text, "SetTextColor", function(tt, r, g, b)
        local rR, gG, bB = 1, 1, 1
        if r ~= rR or g ~= gG or b ~= bB then
            tt:SetTextColor(rR, gG, bB)
        end
    end)
    
    if tab.conversationIcon then
        tab.conversationIcon:ClearAllPoints()
        tab.conversationIcon:SetPoint("RIGHT", tab.text, "LEFT", -1, 0)
    end
    
    frame:SetClampRectInsets(0,0,0,0)
    frame:SetClampedToScreen(false)
    StripTextures(frame, true)
    _G[name.."ButtonFrame"]:Hide()
    
    _G[format(editbox:GetName() .. "Left", id)]:Hide()
    _G[format(editbox:GetName() .. "Mid", id)]:Hide()
    _G[format(editbox:GetName() .. "Right", id)]:Hide()
    editbox:ClearAllPoints()
    editbox:SetPoint("TOPLEFT", _G[name.."ButtonFrame"], "BOTTOMLEFT", 0, 0)
    editbox:SetPoint("TOPRIGHT", background, "BOTTOMRIGHT", 0, 0)
    editbox:SetAltArrowKeyMode(false)
    editbox.editboxHasFocus = false
    editbox:Hide()

    editbox:HookScript("OnEditFocusGained", function(editBox)
        frame.editboxHasFocus = true
        frame:SetScript(
            "OnUpdate",
            function()
                handleChatFrameFadeIn(frame)
            end
        )
        FCF_FadeInChatFrame(frame)
        editBox:Show()
    end)
    editbox:HookScript("OnEditFocusLost", function(editBox)
        frame:SetScript("OnUpdate", nil)
        frame.editboxHasFocus = false
        FCF_FadeOutChatFrame(frame)
        editBox:Hide()
    end)

    if GetSetting("FONTS_ENABLED") then
        if fontSize > 0 then
            frame:SetFont(STANDARD_TEXT_FONT, fontSize)
        elseif fontSize == 0 then
            frame:SetFont(STANDARD_TEXT_FONT, 14)
        end
    end

    if frame.hasContainer then setButtonPosition(frame) end

    frame.styled = true
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
    hooksecurefunc("FCF_DockUpdate", function()
        for i = 1, FCF_GetNumActiveChatFrames() do
            local frame = _G["ChatFrame" .. i]
            styleChatWindow(frame)
            FCFTab_UpdateAlpha(frame)
            frame:SetTimeVisible(100)
            frame:SetFading(shouldFading)
        end
    end)
    hooksecurefunc("FCF_Close", function(frame)
        if frame.Container then
            frame.Container:Hide()
        end
    end)

    hooksecurefunc("FCF_MinimizeFrame", function(chatFrame)
        _G["GwChatContainer" .. chatFrame:GetID()]:SetAlpha(0)
    end)

    for i = 1, FCF_GetNumActiveChatFrames() do
        local frame = _G["ChatFrame" .. i]
        styleChatWindow(frame)
        FCFTab_UpdateAlpha(frame)
        frame:SetTimeVisible(100)
        frame:SetFading(shouldFading)
    end
    hooksecurefunc("FCFTab_OnDragStop", function(frame)
        local frame = _G["ChatFrame"..frame:GetID()]
        local name = frame:GetName()
        local editbox = _G[name.."EditBox"]
        local id = frame:GetID()
        local _, _, _, _, _, _, _, _, isDocked = GetChatWindowInfo(id)

        FCFTab_UpdateAlpha(frame)
        frame:SetTimeVisible(100)
        frame:SetFading(shouldFading)
        if not frame.hasContainer and (isDocked == 1 or isDocked == nil) then
            local fmGCC = CreateFrame("FRAME", "GwChatContainer" .. id, UIParent, "GwChatContainer")
            fmGCC:SetScript("OnSizeChanged", chatBackgroundOnResize)
            fmGCC:SetPoint("TOPLEFT", frame, "TOPLEFT", -35, 5)
            if not frame.isDocked then
                fmGCC:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxRight"], "BOTTOMRIGHT", 0, editbox:GetHeight() - 8)
            else
                fmGCC:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxRight"], "BOTTOMRIGHT", 0, 0)
            end
            if not frame.isDocked  then fmGCC.EditBox:Hide() end
            frame.Container = fmGCC
            frame.hasContainer = true
        elseif frame.hasContainer then
            frame.Container:Show()
        end
        --Set Button and container position after drag for every container
        for i = 1, FCF_GetNumActiveChatFrames() do
            if _G["ChatFrame" .. i].hasContainer then setButtonPosition(_G["ChatFrame" .. i]) end
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
        GeneralDockManager,
        ChatFrameChannelButton,
        ChatFrameToggleVoiceDeafenButton,
        ChatFrameToggleVoiceMuteButton
    }

    for i = 1, FCF_GetNumActiveChatFrames() do
        FCF_FadeOutChatFrame(_G["ChatFrame" .. i])
    end

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