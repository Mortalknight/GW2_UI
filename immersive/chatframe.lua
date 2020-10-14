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
local copyLines = {}

local function colorizeLine(text, r, g, b)
    local hexCode = GW.RGBToHex(r, g, b)
    local hexReplacement = format("|r%s", hexCode)

    text = gsub(text, "|r", hexReplacement) --If the message contains color strings then we need to add message color hex code after every "|r"
    text = format("%s%s|r", hexCode, text) --Add message color

    return text
end

local canChangeMessage = function(arg1, id)
    if id and arg1 == "" then return id end
end

local function messageIsProtected(message)
    return message and (message ~= gsub(message, "(:?|?)|K(.-)|k", canChangeMessage))
end

local removeIconFromLine
do
    local raidIconFunc = function(x)
        local x = x ~= "" and _G["RAID_TARGET_" .. x]
        return x and ("{" .. strlower(x) .. "}") or ""
    end
    local stripTextureFunc = function(w, x, y)
        if x == "" then
            return (w ~= "" and w) or (y ~= "" and y) or ""
        end
    end
    local hyperLinkFunc = function(w, x, y)
        if w ~= "" then
            return
        end
        return y
    end
    local fourString = function(v, w, x, y)
        return format("%s%s%s", v, w, (v and v == "1" and x) or y)
    end

    removeIconFromLine = function(text)
        text = gsub(text, "|TInterface/TargetingFrame/UI%-RaidTargetingIcon_(%d+):0|t", raidIconFunc) --converts raid icons into {star} etc, if possible.
        text = gsub(text, "(%s?)(|?)|[TA].-|[ta](%s?)", stripTextureFunc) --strip any other texture out but keep a single space from the side(s).
        text = gsub(text, "(|?)|H(.-)|h(.-)|h", hyperLinkFunc) --strip hyperlink data only keeping the actual text.
        text = gsub(text, "(%d-)(.-)|4(.-):(.-);", fourString) --stuff where it goes 'day' or 'days' like played; tech this is wrong but okayish
        return text
    end
end

local function getLines(frame)
    local index = 1
    for i = 1, frame:GetNumMessages() do
        local message, r, g, b = frame:GetMessageInfo(i)
        if message and not messageIsProtected(message) then
            --Set fallback color values
            r, g, b = r or 1, g or 1, b or 1
            --Remove icons
            message = removeIconFromLine(message)
            --Add text color
            message = colorizeLine(message, r, g, b)
            copyLines[index] = message
            index = index + 1
        end
    end

    return index - 1
end

local function setButtonPosition(frame)
    local frame = _G["ChatFrame" .. frame:GetID()]
    local name = frame:GetName()
    local editbox = _G[name .. "EditBox"]

    if frame.buttonSide == "right" then
        frame.Container:ClearAllPoints()
        frame.Container:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 5)
        if not frame.isDocked then
            frame.Container:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxFocusRight"], "BOTTOMRIGHT", 5, editbox:GetHeight() - 0)
        else
            frame.Container:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxFocusRight"], "BOTTOMRIGHT", 5, 0)
        end

        editbox:ClearAllPoints()
        editbox:SetPoint("TOPLEFT", frame.Background, "BOTTOMLEFT", 0, 0)
        editbox:SetPoint("TOPRIGHT", _G[name .. "ButtonFrame"], "BOTTOMRIGHT", 0, 0)

        if QuickJoinToastButton then
            QuickJoinToastButton.ClearAllPoints = nil
            QuickJoinToastButton.SetPoint = nil
            QuickJoinToastButton:ClearAllPoints()
            QuickJoinToastButton:SetPoint("LEFT", GeneralDockManager, "RIGHT", 30, -3)

            QuickJoinToastButton.ClearAllPoints = GW.NoOp
            QuickJoinToastButton.SetPoint = GW.NoOp
        end
    else
        frame.Container:ClearAllPoints()
        frame.Container:SetPoint("TOPLEFT", frame, "TOPLEFT", -35, 5)
        if not frame.isDocked then
            frame.Container:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxFocusRight"], "BOTTOMRIGHT", 0, editbox:GetHeight() - 8)
        else
            frame.Container:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxFocusRight"], "BOTTOMRIGHT", 0, 0)
        end

        editbox:ClearAllPoints()
        editbox:SetPoint("TOPLEFT", _G[name .. "ButtonFrame"], "BOTTOMLEFT", 0, -6)
        editbox:SetPoint("TOPRIGHT", frame.Background, "BOTTOMRIGHT", 0, -6)

        if QuickJoinToastButton then
            QuickJoinToastButton.ClearAllPoints = nil
            QuickJoinToastButton.SetPoint = nil
            QuickJoinToastButton:ClearAllPoints()
            QuickJoinToastButton:SetPoint("RIGHT", GeneralDockManager, "LEFT", -6, -3)

            QuickJoinToastButton.ClearAllPoints = GW.NoOp
            QuickJoinToastButton.SetPoint = GW.NoOp
        end
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

        UIFrameFadeIn(_G["GwChatContainer1"], 0.5, _G["GwChatContainer1"]:GetAlpha(), 1)
        UIFrameFadeIn(ChatFrameMenuButton, 0.5, ChatFrameMenuButton:GetAlpha(), 1)
    elseif chatFrame.isDocked == nil then
        if chatFrame.Container then
            UIFrameFadeOut(chatFrame.Container, 2, chatFrame.Container:GetAlpha(), chatAlpha)
        end
    end

    if chatFrame.button then
        UIFrameFadeIn(chatFrame.button, 0.5, chatFrame.button:GetAlpha(), 0.35)
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
        UIFrameFadeOut(_G["GwChatContainer1"], 2, _G["GwChatContainer1"]:GetAlpha(), chatAlpha)
    elseif chatFrame.isDocked == nil then
        if chatFrame.Container then
            UIFrameFadeOut(chatFrame.Container, 2, chatFrame.Container:GetAlpha(), chatAlpha)
        end
    end

    if chatFrame.button then
        UIFrameFadeOut(chatFrame.button, 2, chatFrame.button:GetAlpha(), 0)
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

local function chatBackgroundOnResize(self)
    local w, h = self:GetSize()

    w = math.min(1, w / 512)
    h = math.min(1, h / 512)

    self.texture:SetTexCoord(0, w, 1 - h, 1)
end
GW.AddForProfiling("chatframe", "chatBackgroundOnResize", chatBackgroundOnResize)

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
    local scroll = frame.ScrollBar
    local scrollToBottom = frame.ScrollToBottomButton
    local background = _G[name .. "Background"]

    if not frame.hasContainer and (isDocked == 1 or isDocked == nil) then
        local fmGCC = CreateFrame("FRAME", "GwChatContainer" .. id, UIParent, "GwChatContainer")
        fmGCC:SetScript("OnSizeChanged", chatBackgroundOnResize)
        fmGCC:SetPoint("TOPLEFT", frame, "TOPLEFT", -35, 5)
        if not frame.isDocked then
            fmGCC:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxFocusRight"], "BOTTOMRIGHT", 0, editbox:GetHeight() - 8)
        else
            fmGCC:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxFocusRight"], "BOTTOMRIGHT", 0, 0)
        end
        if not frame.isDocked then fmGCC.EditBox:Hide() end
        frame.Container = fmGCC
        frame.hasContainer = true
    end

    for _, texName in pairs(tabTexs) do
        if texName == "Selected" then
            _G[tab:GetName()..texName.."Right"]:SetTexture("Interface/AddOns/GW2_UI/textures/chattabactiveright")
            _G[tab:GetName()..texName.."Left"]:SetTexture("Interface/AddOns/GW2_UI/textures/chattabactiveleft")
            _G[tab:GetName()..texName.."Middle"]:SetTexture("Interface/AddOns/GW2_UI/textures/chattabactive")
            
            _G[tab:GetName()..texName.."Right"]:SetBlendMode("BLEND")
            _G[tab:GetName()..texName.."Left"]:SetBlendMode("BLEND")
            _G[tab:GetName()..texName.."Middle"]:SetBlendMode("BLEND")

            _G[tab:GetName()..texName.."Right"]:SetVertexColor(1, 1, 1, 1)
            _G[tab:GetName()..texName.."Left"]:SetVertexColor(1, 1, 1, 1)
            _G[tab:GetName()..texName.."Middle"]:SetVertexColor(1, 1, 1, 1)
        elseif texName == "" then
            _G[tab:GetName()..texName.."Right"]:SetPoint("BOTTOMLEFT", background, "TOPLEFT", 0, 4)
            _G[tab:GetName()..texName.."Left"]:SetPoint("BOTTOMLEFT", background, "TOPLEFT", 0, 4)
            _G[tab:GetName()..texName.."Middle"]:SetPoint("BOTTOMLEFT", background, "TOPLEFT", 0, 4)

            _G[tab:GetName()..texName.."Right"]:SetHeight(40)
            _G[tab:GetName()..texName.."Left"]:SetHeight(40)
            _G[tab:GetName()..texName.."Middle"]:SetHeight(40)

            _G[tab:GetName()..texName.."Left"]:SetTexture()
            _G[tab:GetName()..texName.."Middle"]:SetTexture()
            _G[tab:GetName()..texName.."Right"]:SetTexture()
        else
            _G[tab:GetName()..texName.."Left"]:SetTexture()
            _G[tab:GetName()..texName.."Middle"]:SetTexture()
            _G[tab:GetName()..texName.."Right"]:SetTexture()
        end
    end
    
    scrollToBottom:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    scrollToBottom:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrowdown_up")
    scrollToBottom:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    scrollToBottom:SetHeight(24)
    scrollToBottom:SetWidth(24)
    scroll:SkinScrollBar()
    ChatFrameMenuButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/bubble_down")
    ChatFrameMenuButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/bubble_up")
    ChatFrameMenuButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/bubble_down")
    ChatFrameMenuButton:SetHeight(20)
    ChatFrameMenuButton:SetWidth(20)

    frame.buttonFrame.minimizeButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/minimize_button")
    frame.buttonFrame.minimizeButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/minimize_button")
    frame.buttonFrame.minimizeButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/minimize_button")
    frame.buttonFrame.minimizeButton:SetSize(24, 24)
    frame.buttonFrame:StripTextures()

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
    frame:StripTextures(true)
    _G[name.."ButtonFrame"]:Hide()
    
    local a, b, c = select(6, editbox:GetRegions())
    a:SetTexture()
    b:SetTexture()
    c:SetTexture()
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

    if GetSetting("FONTS_ENABLED") and fontSize then
        if fontSize > 0 then
            frame:SetFont(STANDARD_TEXT_FONT, fontSize)
        elseif fontSize == 0 then
            frame:SetFont(STANDARD_TEXT_FONT, 14)
        end
    end

    if frame.hasContainer then setButtonPosition(frame) end

    --copy chat button
    frame.button = CreateFrame("Frame", nil, frame)
    frame.button:EnableMouse(true)
    frame.button:SetAlpha(0.35)
    frame.button:SetSize(20, 22)
    frame.button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 20, 0)
    frame.button:SetFrameLevel(frame:GetFrameLevel() + 5)

    frame.button.tex = frame.button:CreateTexture(nil, "OVERLAY")
    frame.button.tex:SetAllPoints()
    frame.button.tex:SetTexture("Interface/AddOns/GW2_UI/textures/maximize_button")

    frame.button:SetScript("OnMouseUp", function(_, btn)
        if not GW2_UICopyChatFrame:IsShown() then
            local _, fontSize = FCF_GetChatWindowInfo(frame:GetID())
            if fontSize < 10 then fontSize = 12 end
            FCF_SetChatWindowFontSize(frame, frame, 0.01)
            GW2_UICopyChatFrame:Show()
            local lineCt = getLines(frame)
            local text = table.concat(copyLines, " \n", 1, lineCt)
            FCF_SetChatWindowFontSize(frame, frame, fontSize)
            GW2_UICopyChatFrame.editBox:SetText(text)
        else
            GW2_UICopyChatFrame:Hide()
        end
    end)

    frame.button:SetScript("OnEnter", function(button) button:SetAlpha(1) end)
    frame.button:SetScript("OnLeave", function(button)
        if _G[button:GetParent():GetName() .. "TabText"]:IsShown() then
            button:SetAlpha(0.35)
        else
            button:SetAlpha(0)
        end
    end)

    frame.styled = true
end

local function BuildCopyChatFrame()
    local frame = CreateFrame("Frame", "GW2_UICopyChatFrame", UIParent)

    tinsert(UISpecialFrames, "GW2_UICopyChatFrame")

    frame.bg = frame:CreateTexture(nil, "ARTWORK")
    frame.bg:SetAllPoints()
    frame.bg:SetTexture("Interface/AddOns/GW2_UI/textures/chatframebackground")

    frame:SetSize(700, 200)
    frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 15)
    frame:Hide()
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetResizable(true)
    frame:SetMinResize(350, 100)
    frame:SetScript("OnMouseDown", function(copyChat, button)
        if button == "LeftButton" and not copyChat.isMoving then
            copyChat:StartMoving()
            copyChat.isMoving = true
        elseif button == "RightButton" and not copyChat.isSizing then
            copyChat:StartSizing()
            copyChat.isSizing = true
        end
    end)
    frame:SetScript("OnMouseUp", function(copyChat, button)
        if button == "LeftButton" and copyChat.isMoving then
            copyChat:StopMovingOrSizing()
            copyChat.isMoving = false
        elseif button == "RightButton" and copyChat.isSizing then
            copyChat:StopMovingOrSizing()
            copyChat.isSizing = false
        end
    end)
    frame:SetScript("OnHide", function(copyChat)
        if copyChat.isMoving or copyChat.isSizing then
            copyChat:StopMovingOrSizing()
            copyChat.isMoving = false
            copyChat.isSizing = false
        end
    end)
    frame:SetFrameStrata("DIALOG")

    frame.scrollArea = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -30)
    frame.scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)
    frame.scrollArea.ScrollBar:SkinScrollBar()
    frame.scrollArea:SetScript("OnSizeChanged", function(scroll)
        frame.editBox:SetWidth(scroll:GetWidth())
        frame.editBox:SetHeight(scroll:GetHeight())
    end)
    frame.scrollArea:HookScript("OnVerticalScroll", function(scroll, offset)
        frame.editBox:SetHitRectInsets(0, 0, offset, (frame.editBox:GetHeight() - offset - scroll:GetHeight()))
    end)

    frame.editBox = CreateFrame("EditBox", nil, frame)
    frame.editBox:SetMultiLine(true)
    frame.editBox:SetMaxLetters(99999)
    frame.editBox:EnableMouse(true)
    frame.editBox:SetAutoFocus(false)
    frame.editBox:SetFontObject(ChatFontNormal)
    frame.editBox:SetWidth(frame.scrollArea:GetWidth())
    frame.editBox:SetHeight(200)
    frame.editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame.scrollArea:SetScrollChild(frame.editBox)
    frame.editBox:SetScript("OnTextChanged", function(_, userInput)
        if userInput then return end
        local _, max = frame.scrollArea.ScrollBar:GetMinMaxValues()
        for _ = 1, max do
            ScrollFrameTemplate_OnMouseWheel(frame.scrollArea, -1)
        end
    end)

    frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.close:SetPoint("TOPRIGHT")
    frame.close:SetFrameLevel(frame.close:GetFrameLevel() + 1)
    frame.close:EnableMouse(true)
    frame.close:SetSize(20, 20)
    frame.close:SkinButton(true)
end

local function LoadChat()
    local shouldFading = GetSetting("CHATFRAME_FADE")

    if QuickJoinToastButton then
        QuickJoinToastButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/LFDMicroButton-Down")
        QuickJoinToastButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/LFDMicroButton-Down")
        QuickJoinToastButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/LFDMicroButton-Down")
        QuickJoinToastButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/LFDMicroButton-Down")
        QuickJoinToastButton:SetWidth(25)
        QuickJoinToastButton:SetHeight(25)
        QuickJoinToastButton:ClearAllPoints()
        QuickJoinToastButton:SetPoint("RIGHT", GeneralDockManager, "LEFT", -6, -3)
        QuickJoinToastButton.FriendsButton:Hide()

        QuickJoinToastButton.ClearAllPoints = GW.NoOp
        QuickJoinToastButton.SetPoint = GW.NoOp
    end

    for i = 1, FCF_GetNumActiveChatFrames() do
        local frame = _G["ChatFrame" .. i]
        styleChatWindow(frame)
        FCFTab_UpdateAlpha(frame)
        frame:SetTimeVisible(100)
        frame:SetFading(shouldFading)
    end

    hooksecurefunc("FCF_SetTemporaryWindowType", function(chatFrame, chatType, chatTarget)
        styleChatWindow(chatFrame)
        FCFTab_UpdateAlpha(chatFrame)
        chatFrame:SetTimeVisible(100)
        chatFrame:SetFading(shouldFading)
    end)

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
        if chatFrame.minimized then
            local id = chatFrame:GetID()
            _G["GwChatContainer" .. id]:SetAlpha(0)
            if not chatFrame.minFrame.minimiizeStyled then
                chatFrame.minFrame:StripTextures(true)
                chatFrame.minFrame:CreateBackdrop(GW.skins.constBackdropFrame)
                _G[chatFrame.minFrame:GetName() .. "MaximizeButton"]:SetNormalTexture("Interface/AddOns/GW2_UI/textures/maximize_button")
                _G[chatFrame.minFrame:GetName() .. "MaximizeButton"]:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/maximize_button")
                _G[chatFrame.minFrame:GetName() .. "MaximizeButton"]:SetPushedTexture("Interface/AddOns/GW2_UI/textures/maximize_button")
                _G[chatFrame.minFrame:GetName() .. "MaximizeButton"]:SetSize(20, 20)
                chatFrame.minFrame.minimiizeStyled = true
            end
        end
    end)

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
                fmGCC:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxFocusRight"], "BOTTOMRIGHT", 0, editbox:GetHeight() - 8)
            else
                fmGCC:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxFocusRight"], "BOTTOMRIGHT", 0, 0)
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
        QuickJoinToastButton,
        GeneralDockManager,
        ChatFrameChannelButton,
        ChatFrameToggleVoiceDeafenButton,
        ChatFrameToggleVoiceMuteButton
    }

    for i = 1, FCF_GetNumActiveChatFrames() do
        if _G["ChatFrame" .. i] then
            FCF_FadeOutChatFrame(_G["ChatFrame" .. i])
        end
    end
    FCF_FadeOutChatFrame(_G["ChatFrame1"])

    for _, frameName in pairs(_G.CHAT_FRAMES) do
        _G[frameName .. "Tab"]:SetScript("OnDoubleClick", nil)
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
                self:StripTextures()
                self:CreateBackdrop(GW.skins.constBackdropFrame)
            end)
    end

    _G.CombatLogQuickButtonFrame_CustomTexture:Hide()
    BuildCopyChatFrame()  
end
GW.LoadChat = LoadChat
