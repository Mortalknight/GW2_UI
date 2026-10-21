---@class GW2
local GW = select(2, ...)
local L = GW.L

local C_GuildInfo_GetMOTD = C_GuildInfo and C_GuildInfo.GetMOTD or GetGuildRosterMOTD

local EMOTE_BUTTON_ALPHA = 0.35

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
    "Tab"
}

local chatModuleInit = false

local tabTexs = {
    "",
    "Selected",
    "Active",
    "Highlight"
}

local gw_fade_frames = {
    QuickJoinToastButton,
    GeneralDockManager,
    ChatFrameChannelButton,
    ChatFrameToggleVoiceDeafenButton,
    ChatFrameToggleVoiceMuteButton
}

-- a floating window on the right half of the screen keeps its buttons on the right
local function UsesButtonStrip(frame)
    return GW.settings.chat.buttonsPosition ~= "LEFT" and frame.buttonSide ~= "right"
end

-- pull the chat content into the strip of the hidden button column - the same
-- left anchor the edit box already uses - so text and tabs are flush with the
-- left edge of the chat background while the frame itself stays untouched
-- (its position is owned by edit mode).
-- The scrolling message frame anchors its first visible line to the frame
-- itself and sizes every line to the frame width (SharedXML RefreshLayout), so
-- the lines are shifted into the strip and widened after every relayout;
-- with position LEFT the offset is 0, which restores the default layout
local function AdjustChatLines(frame)
    local buttonFrame = _G[frame:GetName() .. "ButtonFrame"]
    local visibleLines = frame.visibleLines
    if not buttonFrame or not visibleLines then return end

    local offset = UsesButtonStrip(frame) and (buttonFrame:GetWidth() + 2) or 0
    local width = frame:GetWidth() + offset
    for index, fontString in ipairs(visibleLines) do
        if index == 1 then
            local point, relativeTo, relativePoint, _, yOfs = fontString:GetPoint(1)
            local secretAnchor = GW.IsSecretValue(point) or GW.IsSecretValue(relativeTo)
                or GW.IsSecretValue(relativePoint) or GW.IsSecretValue(yOfs)
            -- only rebuild the anchor when GetPoint handed back a complete one: a line
            -- that the engine has not anchored yet (fresh out of the pool while the dock
            -- switches tabs) reports no relative point, and passing that nil on to
            -- SetPoint makes it reject the whole argument list
            if not secretAnchor and point and relativePoint and (relativeTo or fontString:GetParent() ~= nil) then
                -- an explicit parent is what a nil relativeTo means anyway, and it keeps
                -- SetPoint from having to guess at a nil in the middle of the arguments
                fontString:SetPoint(point, relativeTo or fontString:GetParent(), relativePoint, -offset, yOfs or 0)
            end
        end
        fontString:SetWidth(width)
    end
end

local function AdjustFloatingTab(frame)
    if frame.isDocked then return end
    local tab = _G[frame:GetName() .. "Tab"]
    tab:ClearAllPoints()
    local x = UsesButtonStrip(frame) and -(frame.buttonFrame:GetWidth() + 1) or 2
    tab:SetPoint("BOTTOMLEFT", frame.Background, "TOPLEFT", x, 0)
end

local function AdjustChatContent(frame)
    local buttonFrame = _G[frame:GetName() .. "ButtonFrame"]
    if not buttonFrame then return end

    -- the container clips the lines, so it has to cover the strip as well
    if frame.FontStringContainer then
        frame.FontStringContainer:ClearAllPoints()
        if UsesButtonStrip(frame) then
            frame.FontStringContainer:SetPoint("TOPLEFT", buttonFrame, "TOPLEFT", 2, 0)
        else
            frame.FontStringContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        end
        frame.FontStringContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    end

    if frame.RefreshLayout and not frame.gwLineLayoutHooked then
        hooksecurefunc(frame, "RefreshLayout", AdjustChatLines)
        frame.gwLineLayoutHooked = true
    end
    AdjustChatLines(frame)
    AdjustFloatingTab(frame)
end

local function AdjustChatDock()
    if not GeneralDockManager or not ChatFrame1ButtonFrame then return end

    GeneralDockManager:ClearAllPoints()
    if GW.settings.chat.buttonsPosition == "LEFT" then
        GeneralDockManager:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 3)
    else
        GeneralDockManager:SetPoint("BOTTOMLEFT", ChatFrame1ButtonFrame, "TOPLEFT", 0, 3)
    end
    GeneralDockManager:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 0, 3)
end

-- chat controls hover bar --------------------------------------------------
local controlsBar
local controlsButtons

local function ChatControlsFadeIn()
    FCF_FadeInChatFrame(ChatFrame1)
end

local function ChatControlsFadeOut()
    if GW.settings.chat.fade then
        FCF_FadeOutChatFrame(ChatFrame1)
    end
end

local function ControlButtonOnEnter(self)
    if self.gwInChatControlsBar then
        ChatControlsFadeIn()
    end
end

local function ControlButtonOnLeave(self)
    if self.gwInChatControlsBar then
        ChatControlsFadeOut()
    end
end

local function CollectControlsButtons()
    if controlsButtons then return controlsButtons end

    controlsButtons = {}
    local function addButton(button)
        if button then
            -- snapshot the original anchoring, so switching back to LEFT can restore it
            button.gwOrigParent = button:GetParent()
            button.gwOrigPoints = {}
            for i = 1, button:GetNumPoints() do
                local point, relativeTo, relativePoint, xOfs, yOfs = button:GetPoint(i)
                button.gwOrigPoints[i] = {point, relativeTo or button:GetParent(), relativePoint, xOfs, yOfs}
            end
            tinsert(controlsButtons, button)
        end
    end
    addButton(QuickJoinToastButton)
    addButton(not GW.isModern and FriendsMicroButton or nil)
    addButton(ChatFrameMenuButton)
    addButton(ChatFrameChannelButton)
    addButton(GW.isModern and ChatFrameToggleVoiceMuteButton or nil)
    addButton(GW.isModern and ChatFrameToggleVoiceDeafenButton or nil)

    return controlsButtons
end

local function EnsureControlsBar()
    if controlsBar then return controlsBar end

    controlsBar = CreateFrame("Frame", "GwChatButtonsFrame", UIParent)
    controlsBar:SetFrameStrata("MEDIUM")
    controlsBar:EnableMouse(true)
    controlsBar:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    controlsBar:SetScript("OnEnter", ChatControlsFadeIn)
    controlsBar:SetScript("OnLeave", ChatControlsFadeOut)

    return controlsBar
end

local function RebuildChatFadeFrames(position)
    wipe(gw_fade_frames)
    tinsert(gw_fade_frames, GeneralDockManager)
    if position == "LEFT" then
        if QuickJoinToastButton then tinsert(gw_fade_frames, QuickJoinToastButton) end
        if ChatFrameChannelButton then tinsert(gw_fade_frames, ChatFrameChannelButton) end
        if ChatFrameToggleVoiceDeafenButton then tinsert(gw_fade_frames, ChatFrameToggleVoiceDeafenButton) end
        if ChatFrameToggleVoiceMuteButton then tinsert(gw_fade_frames, ChatFrameToggleVoiceMuteButton) end
    else
        tinsert(gw_fade_frames, controlsBar)
    end
end

-- background, edit box and social button follow the side blizzard puts the button strip on
local function setButtonPosition(frame)
    local name = frame:GetName()
    local editbox = frame.editBox
    local buttonFrame = _G[name .. "ButtonFrame"]
    local isRight = frame.buttonSide == "right"
    local stripButtons = GW.settings.chat.buttonsPosition == "LEFT"

    local editBoxRight = _G[name .. (GW.isModern and "EditBoxFocusRight" or "EditBoxRight")]
    frame.Container:ClearAllPoints()
    frame.Container:SetPoint("TOPLEFT", frame, "TOPLEFT", isRight and -5 or -35, 5)
    local bottom = frame.isDocked and 0 or (editbox:GetHeight() - (isRight and 0 or 8))
    frame.Container:SetPoint("BOTTOMRIGHT", editBoxRight, "BOTTOMRIGHT", 0, bottom)

    editbox:ClearAllPoints()
    if isRight then
        editbox:SetPoint("TOPLEFT", frame.Background, "BOTTOMLEFT", 0, 0)
        editbox:SetPoint("TOPRIGHT", stripButtons and buttonFrame or frame.Background, "BOTTOMRIGHT", 5, 0)
    else
        editbox:SetPoint("TOPLEFT", buttonFrame, "BOTTOMLEFT", 0, -6)
        editbox:SetPoint("TOPRIGHT", frame.Background, "BOTTOMRIGHT", 5, -6)
    end

    if QuickJoinToastButton and stripButtons and frame.isDocked ~= nil then
        QuickJoinToastButton.ClearAllPoints = nil
        QuickJoinToastButton.SetPoint = nil
        QuickJoinToastButton:ClearAllPoints()
        if isRight then
            QuickJoinToastButton:SetPoint("LEFT", GeneralDockManager, "RIGHT", 30, 4)
        else
            QuickJoinToastButton:SetPoint("RIGHT", GeneralDockManager, "LEFT", -6, 4)
        end
        QuickJoinToastButton.ClearAllPoints = GW.NoOp
        QuickJoinToastButton.SetPoint = GW.NoOp
    end
end

-- applies the configured controls position (LEFT column / TOP or RIGHT hover
-- bar) at runtime; also used as the hot setting callback
function GW.UpdateChatButtonsPosition()
    if not chatModuleInit then return end

    local position = GW.settings.chat.buttonsPosition
    local buttons = CollectControlsButtons()

    if position == "LEFT" then
        if controlsBar then controlsBar:Hide() end

        -- first break the bar anchor chain on ALL buttons, then restore the
        -- original points in a second pass - the original anchors can reference
        -- each other (e.g. mute anchors to deafen), which errors with a circular
        -- dependency while the other button still hangs in the bar chain
        for _, button in ipairs(buttons) do
            if button.gwInChatControlsBar then
                button.ClearAllPoints = nil
                button.SetPoint = nil
                UIFrameFadeRemoveFrame(button)
                button:SetAlpha(1)
                button:SetParent(button.gwOrigParent)
                button:ClearAllPoints()
            end
        end
        for _, button in ipairs(buttons) do
            if button.gwInChatControlsBar then
                for _, pointInfo in ipairs(button.gwOrigPoints) do
                    button:SetPoint(pointInfo[1], pointInfo[2], pointInfo[3], pointInfo[4], pointInfo[5])
                end
                button.gwInChatControlsBar = nil
            end
        end

        -- the classic gw anchor for the social button next to the dock
        local social = QuickJoinToastButton or FriendsMicroButton
        if social then
            social.ClearAllPoints = nil
            social.SetPoint = nil
            social:ClearAllPoints()
            social:SetPoint("RIGHT", GeneralDockManager, "LEFT", -6, 4)
            social.ClearAllPoints = GW.NoOp
            social.SetPoint = GW.NoOp
        end
    else
        local bar = EnsureControlsBar()
        bar:Show()
        bar:ClearAllPoints()
        if position == "TOP" then
            bar:SetPoint("BOTTOMLEFT", GeneralDockManager, "TOPLEFT", 0, 2)
        else
            bar:SetPoint("TOPLEFT", ChatFrame1, "TOPRIGHT", 8, 0)
        end

        local PADDING, SPACING = 6, 4
        local length = PADDING * 2 - SPACING
        local thickness = 0
        local previous
        for _, button in ipairs(buttons) do
            button.ClearAllPoints = nil
            button.SetPoint = nil
            button:SetParent(bar)
            button:ClearAllPoints()
            if position == "TOP" then
                if previous then
                    button:SetPoint("LEFT", previous, "RIGHT", SPACING, 0)
                else
                    button:SetPoint("LEFT", bar, "LEFT", PADDING, 0)
                end
                length = length + button:GetWidth() + SPACING
                thickness = max(thickness, button:GetHeight())
            else
                if previous then
                    button:SetPoint("TOP", previous, "BOTTOM", 0, -SPACING)
                else
                    button:SetPoint("TOP", bar, "TOP", 0, -PADDING)
                end
                length = length + button:GetHeight() + SPACING
                thickness = max(thickness, button:GetWidth())
            end

            -- keep blizzard from moving the buttons out of the bar
            button.ClearAllPoints = GW.NoOp
            button.SetPoint = GW.NoOp
            button.gwInChatControlsBar = true
            if not button.gwControlsHoverHooked then
                button:HookScript("OnEnter", ControlButtonOnEnter)
                button:HookScript("OnLeave", ControlButtonOnLeave)
                button.gwControlsHoverHooked = true
            end

            -- the buttons may have been faded individually; from now on only the bar fades
            UIFrameFadeRemoveFrame(button)
            button:SetAlpha(1)
            previous = button
        end

        thickness = thickness + 10
        if position == "TOP" then
            bar:SetSize(length, thickness)
        else
            bar:SetSize(thickness, length)
        end
    end

    RebuildChatFadeFrames(position)
    AdjustChatDock()

    for _, frameName in ipairs(CHAT_FRAMES) do
        local frame = _G[frameName]
        if frame then
            AdjustChatContent(frame)
            if frame.hasContainer then setButtonPosition(frame) end
            if frame.MarkLayoutDirty then
                frame:MarkLayoutDirty()
            end
        end
    end

    GW.UpdateChatSettings()
end

-- blizzard colors and shows its background again on tab and fade updates
local function HideBlizzardChatBackground(chatFrame)
    local name = chatFrame:GetName()
    local background = _G[name .. "Background"]
    if not background then return end
    background:SetVertexColor(0, 0, 0, 0)
    background:SetAlpha(0)
    background:Hide()
    local buttonFrameBackground = _G[name .. "ButtonFrameBackground"]
    if buttonFrameBackground then
        buttonFrameBackground:SetVertexColor(0, 0, 0, 0)
        buttonFrameBackground:Hide()
        _G[name .. "RightTexture"]:SetVertexColor(0, 0, 0, 1)
    end
end


-- the parts of a chat window fade together; its background goes to the window alpha of the chat settings
local function FadeChatFrame(chatFrame, fadeIn)
    local fade, duration = fadeIn and UIFrameFadeIn or UIFrameFadeOut, fadeIn and 0.5 or 2
    local function FadeTo(frame, alpha)
        if frame then
            fade(frame, duration, frame:GetAlpha(), alpha)
        end
    end
    local partAlpha = fadeIn and 1 or 0
    local backgroundAlpha = fadeIn and 1 or select(6, GetChatWindowInfo(chatFrame:GetID()))
    local frameName = chatFrame:GetName()

    for _, v in pairs(CHAT_FRAME_TEXTURES) do
        local object = _G[frameName .. v]
        if object and object:IsShown() then
            FadeTo(object, partAlpha)
        end
    end
    if chatFrame.isDocked == 1 then
        for _, v in pairs(gw_fade_frames) do
            if (v ~= ChatFrameToggleVoiceDeafenButton and v ~= ChatFrameToggleVoiceMuteButton) or v:IsShown() then
                FadeTo(v, partAlpha)
            end
        end
        if fadeIn or chatFrame.Container then
            FadeTo(ChatFrame1.Container, backgroundAlpha)
        end
    elseif chatFrame.isDocked == nil then
        FadeTo(chatFrame.Container, backgroundAlpha)
    end
    if not ChatFrameMenuButton.gwInChatControlsBar and (not fadeIn or chatFrame.isDocked == 1) then
        FadeTo(ChatFrameMenuButton, partAlpha)
    end

    FadeTo(chatFrame.copyButton, partAlpha)
    FadeTo(chatFrame.buttonEmote, fadeIn and EMOTE_BUTTON_ALPHA or 0)
    if GW_EmoteFrame and GW_EmoteFrame:IsShown() then
        FadeTo(GW_EmoteFrame, partAlpha)
    end
    FadeTo(_G[frameName .. "Tab"], partAlpha)
    FadeTo(chatFrame.buttonFrame, partAlpha)
end

-- blizzard resets these on dock and window changes
local function ApplyChatFrameFading(frame)
    FCFTab_UpdateAlpha(frame)
    frame:SetTimeVisible(100)
    frame:SetFading(GW.settings.chat.fade)
end

local function handleChatFrameFadeIn(chatFrame, force)
    if not GW.settings.chat.fade and not force then
        return
    end

    chatFrame:ResetAllFadeTimes()
    chatFrame:SetFading(false)
    HideBlizzardChatBackground(chatFrame)
    FadeChatFrame(chatFrame, true)
end

local function handleChatFrameFadeOut(chatFrame, force)
    if not GW.settings.chat.fade and not force then
        return
    end
    HideBlizzardChatBackground(chatFrame)
    if chatFrame.editboxHasFocus or (GW_EmoteFrame and GW_EmoteFrame:IsShown() and GW_EmoteFrame:IsMouseOver()) then
        handleChatFrameFadeIn(chatFrame)
        return
    end
    chatFrame:SetFading(GW.settings.chat.fade)
    FadeChatFrame(chatFrame, false)

    -- the backgrounds of the other tabs in the same dock go with it
    local chatAlpha = select(6, GetChatWindowInfo(chatFrame:GetID()))
    for i = 1, FCF_GetNumActiveChatFrames() do
        local other = _G["ChatFrame" .. i]
        if other.hasContainer and other.isDocked == chatFrame.isDocked and chatFrame:GetID() ~= i then
            UIFrameFadeOut(other.Container, 2, other.Container:GetAlpha(), chatAlpha)
        end
    end
end


local function chatBackgroundOnResize(self)
    local w, h = self:GetSize()

    w = math.min(1, w / 512)
    h = math.min(1, h / 512)

    self.texture:SetTexCoord(0, w, 1 - h, 1)
end


-- the guild message of the day comes a few seconds after the login lines instead of in between;
-- the chat windows leave it out at login, we print it ourselves and hand it back to them
local MOTD_DELAY, MOTD_TRIES = 5, 5
tDeleteItem(ChatTypeGroup.GUILD, "GUILD_MOTD")

-- the background of a chat window and its dock; the classic edit box has no focus art
local function EnsureChatContainer(frame, isDocked)
    if frame.hasContainer or not (isDocked == 1 or (isDocked == nil and frame:IsShown())) then
        return false
    end
    local container = CreateFrame("Frame", nil, UIParent, "GwChatContainer")
    container:SetScript("OnSizeChanged", chatBackgroundOnResize)
    if not frame.isDocked then container.EditBox:Hide() end
    frame.Container = container
    frame.hasContainer = true
    setButtonPosition(frame)
    return true
end

local function ShowGuildMOTD(try)
    local motd = not InCombatLockdown() and C_GuildInfo_GetMOTD()
    if motd and motd ~= "" then
        for _, frameName in ipairs(CHAT_FRAMES) do
            local chatFrame = _G[frameName]
            if chatFrame and chatFrame:IsEventRegistered("CHAT_MSG_GUILD") then
                if chatFrame.SystemEventHandler then
                    chatFrame:SystemEventHandler("GUILD_MOTD", motd)
                else
                    ChatFrame_SystemEventHandler(chatFrame, "GUILD_MOTD", motd)
                end
                chatFrame:RegisterEvent("GUILD_MOTD")
            end
        end
    elseif try < MOTD_TRIES then
        C_Timer.After(MOTD_DELAY, function() ShowGuildMOTD(try + 1) end)
    end
end

local function DelayGuildMOTD()
    tinsert(ChatTypeGroup.GUILD, "GUILD_MOTD")
    C_Timer.After(MOTD_DELAY, function() ShowGuildMOTD(1) end)
end
local function GetTab(chat)
    if not chat.tab then
        chat.tab = _G[format("ChatFrame%sTab", chat:GetID())]
    end

    return chat.tab
end

local CHAT_TAB_SIDES_PADDING = 20 -- local in Blizzards FloatingChatFrame.lua
local CHAT_TAB_SECRET_WIDTH = 90 -- CHAT_TAB_DOCKED_MAX_WIDTH, local as well
-- mainline only: classic tabs have a fixed width middle art that PanelTemplates_TabResize sizes around the text
local function EnforceTabSize(chatFrame)
    local tab = GetTab(chatFrame)
    if not GW.isModern or not tab or not tab.Text then return end

    local padding = tab.sizePadding or 0

    -- FCF_HasSecretName (local in Blizzards code)
    if chatFrame.chatTarget and (chatFrame.chatType == "WHISPER" or chatFrame.chatType == "BN_WHISPER") then
        tab.Text:SetWidth(CHAT_TAB_SECRET_WIDTH - CHAT_TAB_SIDES_PADDING - padding)
        tab:SetWidth(CHAT_TAB_SECRET_WIDTH)
        return
    end

    tab.Text:SetWidth(0)
    local textWidth = tab.Text:GetStringWidth()
    if GW.IsSecretValue(textWidth) then return end

    tab.Text:SetWidth(textWidth)
    tab:SetWidth(textWidth + CHAT_TAB_SIDES_PADDING + padding)
end

local function AlignScrollBar(chatFrame)
    local scroll, button = chatFrame.ScrollBar, chatFrame.ScrollToBottomButton
    if not (chatFrame.gwScrollBarSkinned and button:IsShown()) then return end
    local inset = (button:GetWidth() - scroll:GetWidth()) / 2
    local buttonLeft, frameRight = button:GetLeft(), chatFrame:GetRight()
    local shift = buttonLeft and frameRight and (buttonLeft - frameRight) or 0
    scroll:ClearAllPoints()
    scroll:SetPoint("TOPLEFT", chatFrame, "TOPRIGHT", shift + inset, 0)
    scroll:SetPoint("BOTTOMLEFT", button, "TOPLEFT", inset, 2)
end

local function styleChatWindow(frame)
    local name = frame:GetName()
    GW.SetupChatModulesForFrame(frame)
    local tab = GetTab(frame)
    tab.Text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    -- blizzard swaps the tab font objects on hover and select
    local fontObject = tab.Text:GetFontObject()
    tab:SetNormalFontObject(fontObject)
    tab:SetHighlightFontObject(fontObject)
    tab:SetDisabledFontObject(fontObject)
    tab.Text:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    if GW.isModern then
        EnforceTabSize(frame)
    else
        PanelTemplates_TabResize(tab, tab.sizePadding or 0)
    end

    if frame.styled then return end

    frame:SetFrameLevel(4)

    local id = frame:GetID()
    local _, fontSize, _, _, _, _, _, _, isDocked = GetChatWindowInfo(id)

    local editbox = frame.editBox
    local scroll = frame.ScrollBar
    local scrollToBottom = frame.ScrollToBottomButton
    local background = _G[name .. "Background"]

    EnsureChatContainer(frame, isDocked)

    if id == 3 then
        SetChatWindowShown(id, GetCVarBool("speechToText"))
        if frame.hasContainer then
            frame.Container:SetShown(GetCVarBool("speechToText"))
        end
        FloatingChatFrame_Update(id)
        FCF_DockUpdate()
    end

    for _, texName in pairs(tabTexs) do
        local t, l, m, r = name .. "Tab", texName .. "Left", texName .. "Middle", texName .. "Right"
        local main = _G[t]
        local left = _G[t .. l] or (main and main[l])
        local middle = _G[t .. m] or (main and main[m])
        local right = _G[t .. r] or (main and main[r])

        if (GW.isModern and texName == "Active") or (not GW.isModern and texName == "Selected") then
            if left then
                left:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chattabactiveleft.png")
                if GW.isModern then
                    left:ClearAllPoints()
                    left:SetPoint("TOPRIGHT", tab.Left, "TOPRIGHT", 0, 2)
                end
                left:SetBlendMode("BLEND")
                left:SetVertexColor(GW.Colors.FallbackWhite:GetRGBA())
            end

            if middle then
                middle:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chattabactive.png")
                if GW.isModern then
                    middle:ClearAllPoints()
                    middle:SetPoint("LEFT", tab.Middle, "LEFT", 0, 2)
                    middle:SetPoint("RIGHT", tab.Middle, "RIGHT", 0, 2 )
                end
                middle:SetBlendMode("BLEND")
                middle:SetVertexColor(GW.Colors.FallbackWhite:GetRGBA())
            end
            if right then
                right:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chattabactiveright.png")
                if GW.isModern then
                    right:ClearAllPoints()
                    right:SetPoint("TOPRIGHT", tab.Right, "TOPRIGHT", 0, 2)
                end
                right:SetBlendMode("BLEND")
                right:SetVertexColor(GW.Colors.FallbackWhite:GetRGBA())
            end
        else
            if left then left:SetTexture() end
            if middle then middle:SetTexture() end
            if right then right:SetTexture() end
        end

        if left then left:SetHeight(28) end
        if middle then middle:SetHeight(28) end
        if right then right:SetHeight(28) end
    end

    scrollToBottom:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
    scrollToBottom:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up.png")
    scrollToBottom:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
    scrollToBottom.Flash:GwKill()
    scrollToBottom:SetSize(24, 24)
    scrollToBottom:SetPoint("BOTTOMRIGHT", frame.ResizeButton, "TOPRIGHT", 7, -2)
    -- mainline only, the classic chat windows have no scroll bar
    if scroll then
        GW.SkinSlimScrollBar(scroll)
        frame.gwScrollBarSkinned = true
        AlignScrollBar(frame)
    end

    if not GW.isModern then
        for button, arrow in pairs({BottomButton = "arrowdown", DownButton = "arrowdown", UpButton = "arrowup"}) do
            local scrollButton = _G[name .. "ButtonFrame" .. button]
            scrollButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/" .. arrow .. "_down.png")
            scrollButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/" .. arrow .. "_up.png")
            scrollButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/" .. arrow .. "_down.png")
            scrollButton:SetSize(24, 24)
        end
    end

    ChatFrameMenuButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/bubble_down.png")
    ChatFrameMenuButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/bubble_up.png")
    ChatFrameMenuButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/bubble_down.png")
    ChatFrameMenuButton:SetHeight(20)
    ChatFrameMenuButton:SetWidth(20)

    local minimizeButton = frame.buttonFrame.minimizeButton
    if minimizeButton then
        minimizeButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/minimize_button.png")
        minimizeButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/minimize_button.png")
        minimizeButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/minimize_button.png")
        minimizeButton:SetSize(20, 20)
        frame.buttonFrame:GwStripTextures()
    end

    if not tab.Left then tab.Left = _G[name .. "TabLeft"] or _G[name .. "Tab"].Left end

    hooksecurefunc(tab, "SetAlpha", function(t, alpha)
        if alpha ~= 1 and (not t.isDocked or GeneralDockManager.selected:GetID() == t:GetID()) then
            t:SetAlpha(1)
        elseif alpha < 0.6 then
            t:SetAlpha(0.6)
        end
    end)

    tab.Text:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    hooksecurefunc(tab.Text, "SetTextColor", function(tt, r, g, b)
        local white = GW.Colors.FallbackWhite
        if r ~= white.r or g ~= white.g or b ~= white.b then
            tt:SetTextColor(white:GetRGB())
        end
    end)

    if tab.conversationIcon then
        tab.conversationIcon:ClearAllPoints()
        tab.conversationIcon:SetPoint("RIGHT", tab.text, "LEFT", -1, 0)
    end

    frame:SetClampRectInsets(0,0,0,0)
    frame:SetClampedToScreen(false)
    frame:GwStripTextures(true)
    _G[name .. "ButtonFrame"]:Hide()

    if GW.isModern then
        local a, b, c = select(6, editbox:GetRegions())
        a:GwKill()
        b:GwKill()
        c:GwKill()
    end

    editbox:ClearAllPoints()
    editbox:SetPoint("TOPLEFT", _G[name .. "ButtonFrame"], "BOTTOMLEFT", 0, 0)
    editbox:SetPoint("TOPRIGHT", background, "BOTTOMRIGHT", 5, 0)
    editbox:SetAltArrowKeyMode(false)
    editbox.editboxHasFocus = false
    editbox:Hide()
    -- the chat fade brings the alpha of the art back, so it loses its texture; the right ends stay at the box
    -- edge, other chat buttons hang on them
    for _, part in ipairs({"Left", "Mid", "Right", "FocusLeft", "FocusMid", "FocusRight"}) do
        local texture = _G[name .. "EditBox" .. part]
        if texture then
            texture:SetTexture(nil)
        end
    end
    for _, part in ipairs({"Right", "FocusRight"}) do
        local texture = _G[name .. "EditBox" .. part]
        if texture then
            texture:ClearAllPoints()
            texture:SetPoint("TOPRIGHT")
            texture:SetPoint("BOTTOMRIGHT")
            texture:SetWidth(1)
        end
    end
    GW.AddEditBoxBackground(editbox, 0)

    --Character count
    local charCount = editbox:CreateFontString(nil, "ARTWORK")
    charCount:SetFont(UNIT_NAME_FONT, 11, "")
    local countColor = GW.Colors.SkinColors.SubText
    charCount:SetTextColor(countColor.r, countColor.g, countColor.b, 0.4)
    charCount:SetPoint("TOPRIGHT", editbox, "TOPRIGHT", -5, 0)
    charCount:SetPoint("BOTTOMRIGHT", editbox, "BOTTOMRIGHT", -5, 0)
    charCount:SetJustifyH("CENTER")
    charCount:SetWidth(40)
    editbox.characterCount = charCount

    editbox:HookScript("OnEditFocusGained", function(editBox)
        frame.editboxHasFocus = true
        FCF_FadeInChatFrame(frame)
        editBox:Show()
    end)
    editbox:HookScript("OnEditFocusLost", function(editBox)
        frame.editboxHasFocus = false
        FCF_FadeOutChatFrame(frame)
        if GW.settings.chat.hideEditBox then
            editBox:Hide()
        end
    end)

    if GW.settings.chat.gw2Style then
        local chatFont = GW.Libs.LSM:Fetch("font", "GW2_UI_Chat")
        local _, fontHeight, fontFlags = frame:GetFont()
        frame:SetFont(chatFont, fontHeight or 14, fontFlags)
        editbox:SetFont(chatFont, fontHeight or 14, fontFlags)
        _G[editbox:GetName() .. "Header"]:SetFont(chatFont, fontHeight or 14, fontFlags)
    elseif GW.settings.fonts.styleTemplate ~= "BLIZZARD" and fontSize then
        if fontSize > 0 then
            frame:SetFont(STANDARD_TEXT_FONT, fontSize, "")
        elseif fontSize == 0 then
            frame:SetFont(STANDARD_TEXT_FONT, 14, "")
        end
    end

    if frame.hasContainer then setButtonPosition(frame) end

    --emote bar button
    if GW.settings.chat.keywords.emoji and (id ~= 2 and id ~= 3) then
        frame.buttonEmote = CreateFrame("Button", nil, frame)
        frame.buttonEmote:EnableMouse(true)
        frame.buttonEmote:SetAlpha(EMOTE_BUTTON_ALPHA)
        frame.buttonEmote:SetSize(12, 12)
        frame.buttonEmote:SetPoint("TOPRIGHT", frame, "TOPRIGHT", GW.isModern and 0 or -20, GW.isModern and 22 or 0)
        frame.buttonEmote:SetFrameLevel(frame:GetFrameLevel() + 5)

        frame.buttonEmote.tex = frame.buttonEmote:CreateTexture(nil, "OVERLAY")
        frame.buttonEmote.tex:SetAllPoints()
        frame.buttonEmote.tex:SetTexture("Interface/AddOns/GW2_UI/textures/emoji/smile.png")
        frame.buttonEmote.tex:SetDesaturated(true)

        frame.buttonEmote:SetScript("OnMouseUp", function()
            if not GW_EmoteFrame:IsShown() then
                GW_EmoteFrame:Show()
            else
                GW_EmoteFrame:Hide()
            end
        end)

        frame.buttonEmote:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 6)
            GameTooltip:AddLine(L["Click to open Emoticon Frame"])
            GameTooltip:Show()
            frame.buttonEmote.tex:SetTexture("Interface/AddOns/GW2_UI/textures/emoji/openmouth.png")
            frame.buttonEmote.tex:SetDesaturated(false)
            frame.buttonEmote:SetAlpha(1)
        end)

        frame.buttonEmote:SetScript("OnLeave", function()
            GameTooltip:Hide()
            frame.buttonEmote.tex:SetTexture("Interface/AddOns/GW2_UI/textures/emoji/smile.png")
            frame.buttonEmote.tex:SetDesaturated(true)
            frame.buttonEmote:SetAlpha(EMOTE_BUTTON_ALPHA)
        end)
    end

    -- the text covers the button strip, so the minimize button moves up to the tab row
    if minimizeButton then
        minimizeButton:ClearAllPoints()
        if frame.buttonEmote then
            minimizeButton:SetPoint("RIGHT", frame.buttonEmote, "LEFT", -4, 0)
        else
            minimizeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", GW.isModern and 0 or -20, GW.isModern and 26 or 4)
        end
    end

    -- pull the message text into the button column strip (TOP/RIGHT button mode)
    AdjustChatContent(frame)

    frame.styled = true
end

local function PetBattleFrame_Display()
    if RemoveFrameLock then
        RemoveFrameLock("PETBATTLES")
    end

    -- we want to display the pet battle tab now since it is faded initially without mousing over
    for _, frameName in ipairs(CHAT_FRAMES) do
        local chat = _G[frameName]
        if (chat and chat.isTemporary) and (not chat.hasBeenFaded and chat.chatType == "PET_BATTLE_COMBAT_LOG") and not chat:IsShown() then
            FCF_FadeInChatFrame(chat)
        end
    end
end

local function UpdateSettings()
    if not chatModuleInit then return end
    for _, frameName in ipairs(CHAT_FRAMES) do
        local frame = _G[frameName]
        if frame and frame:IsShown() then
            frame:SetFading(GW.settings.chat.fade)
            if GW.settings.chat.fade then
                if not frame.hasBeenFaded then
                    handleChatFrameFadeOut(frame, true)
                end
            else
                handleChatFrameFadeIn(frame, true)
            end
        end
    end
end
GW.UpdateChatSettings = UpdateSettings

-- blizzard offers only a few chat font sizes; its list must not be replaced, that taints the whole tab menu
local EXTRA_CHAT_FONT_SIZES = {6, 7, 8, 9, 10, 11, 13, 15, 17, 19}
local function AddChatFontSizes(owner, rootDescription)
    local fontSizeMenu
    for _, description in rootDescription:EnumerateElementDescriptions() do
        if MenuUtil.GetElementText(description) == FONT_SIZE then
            fontSizeMenu = description
            break
        end
    end
    local chatFrame = fontSizeMenu and FCF_GetChatFrameByID(owner:GetID())
    if not chatFrame then return end

    local _, fontHeight = chatFrame:GetFont()
    local current = floor(fontHeight + 0.5)
    local function IsSelected(height) return height == current end
    local function SetSelected(height) FCF_SetChatWindowFontSize(nil, chatFrame, height) end

    for _, height in ipairs(EXTRA_CHAT_FONT_SIZES) do
        local index = 1
        for _, description in fontSizeMenu:EnumerateElementDescriptions() do
            if (description:GetData() or 0) < height then
                index = index + 1
            end
        end
        fontSizeMenu:Insert(MenuUtil.CreateRadio(format(FONT_SIZE_TEMPLATE, height), IsSelected, SetSelected, height), index)
    end
end

local function LoadChat()
    DelayGuildMOTD()
    Menu.ModifyMenu("MENU_FCF_TAB", AddChatFontSizes)

    if not GW.settings.chat.enabled or GW.ShouldBlockIncompatibleAddon("Chat") then return end
    local eventFrame = CreateFrame("Frame")

    chatModuleInit = true
    GW.LoadChatModules()

    if QuickJoinToastButton then
        QuickJoinToastButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton-highlight.png")
        QuickJoinToastButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton.png")
        QuickJoinToastButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton-highlight.png")
        QuickJoinToastButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton-highlight.png")
        QuickJoinToastButton:SetSize(25, 25)
        if GW.settings.chat.buttonsPosition == "LEFT" then
            QuickJoinToastButton:ClearAllPoints()
            QuickJoinToastButton:SetPoint("RIGHT", GeneralDockManager, "LEFT", -6, 4)
        end
        QuickJoinToastButton.QueueCount:GwKill()
        local _, _, fontFlags = QuickJoinToastButton.FriendCount:GetFont()
        QuickJoinToastButton.FriendCount:SetFont(_, 14, fontFlags)
        QuickJoinToastButton.FriendsButton:GwStripTextures(true)
        QuickJoinToastButton.FriendCount:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
        QuickJoinToastButton.FriendCount:SetShadowOffset(1, 1)
        QuickJoinToastButton.FriendCount:SetPoint("TOP", QuickJoinToastButton, "BOTTOM", 1, 1)

        if GW.settings.chat.buttonsPosition == "LEFT" then
            QuickJoinToastButton.ClearAllPoints = GW.NoOp
            QuickJoinToastButton.SetPoint = GW.NoOp
        end
    end

    if not GW.isModern then
        FriendsMicroButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton-highlight.png")
        FriendsMicroButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton.png")
        FriendsMicroButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton-highlight.png")
        FriendsMicroButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton-highlight.png")
        FriendsMicroButton:SetSize(25, 25)
        if GW.settings.chat.buttonsPosition == "LEFT" then
            FriendsMicroButton:ClearAllPoints()
            FriendsMicroButton:SetPoint("RIGHT", GeneralDockManager, "LEFT", -6, 4)
            FriendsMicroButton.ClearAllPoints = GW.NoOp
            FriendsMicroButton.SetPoint = GW.NoOp
        end
        local _, _, fontFlags = FriendsMicroButtonCount:GetFont()
        FriendsMicroButtonCount:SetFont(_, 14, fontFlags)
        FriendsMicroButtonCount:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
        FriendsMicroButtonCount:SetShadowOffset(1, 1)
        FriendsMicroButtonCount:SetPoint("TOP", FriendsMicroButton, "BOTTOM", 1, 1)
    end

    -- before the styling below, that already runs dock updates which colour the selected tab
    hooksecurefunc(
        "FCFTab_UpdateColors",
        function(self)
            local left = GW.isModern and self.ActiveLeft or self.leftSelectedTexture
            local right = GW.isModern and self.ActiveRight or self.rightSelectedTexture
            local middle = GW.isModern and self.ActiveMiddle or self.middleSelectedTexture
            local white = GW.Colors.FallbackWhite
            left:SetVertexColor(white:GetRGB())
            middle:SetVertexColor(white:GetRGB())
            right:SetVertexColor(white:GetRGB())

            local leftHighlight = GW.isModern and self.HighlightLeft or self.leftHighlightTexture
            local rightHighlight= GW.isModern and self.HighlightRight or self.rightHighlightTexture
            local middleHighlight = GW.isModern and self.HighlightMiddle or self.middleHighlightTexture
            leftHighlight:SetVertexColor(white:GetRGB())
            middleHighlight:SetVertexColor(white:GetRGB())
            rightHighlight:SetVertexColor(white:GetRGB())
            self.glow:SetVertexColor(white:GetRGB())

            local chatFrame = _G["ChatFrame" .. self:GetID()]
            if chatFrame then
                HideBlizzardChatBackground(chatFrame)
            end
        end
    )

    for _, frameName in ipairs(CHAT_FRAMES) do
        local frame = _G[frameName]
        -- the classic fade code runs max() on oldAlpha without a fallback; on modern clients writing it taints the chat and the gamepad ui
        if not GW.isModern then
            frame.oldAlpha = frame.oldAlpha or DEFAULT_CHATFRAME_ALPHA
        end
        styleChatWindow(frame)
        ApplyChatFrameFading(frame)
        frame:SetMaxLines(500)
    end

    hooksecurefunc("FCF_SetTemporaryWindowType", function(chatFrame)
        styleChatWindow(chatFrame)
        ApplyChatFrameFading(chatFrame)
    end)

    if FCFDock_UpdateTabs then
        hooksecurefunc("FCFDock_UpdateTabs", function(dock)
            for _, chatFrame in ipairs(dock.DOCKED_CHAT_FRAMES) do
                EnforceTabSize(chatFrame)
            end
        end)
    end
    if FCF_SetWindowName then
        hooksecurefunc("FCF_SetWindowName", function(chatFrame)
            EnforceTabSize(chatFrame)
        end)
    end
    hooksecurefunc("PanelTemplates_TabResize", function(tab)
        local name = tab.GetName and tab:GetName()
        local id = name and strmatch(name, "^ChatFrame(%d+)Tab$")
        if id and _G["ChatFrame" .. id] then
            EnforceTabSize(_G["ChatFrame" .. id])
        end
    end)

    hooksecurefunc("FCF_DockUpdate", function()
        for _, frameName in ipairs(CHAT_FRAMES) do
            local frame = _G[frameName]
            local _, _, _, _, _, _, _, _, isDocked = GetChatWindowInfo(frame:GetID())
            styleChatWindow(frame)
            AdjustChatContent(frame) -- the engine resets the text container on layout updates
            ApplyChatFrameFading(frame)
            if not EnsureChatContainer(frame, isDocked) then
                if frame.hasContainer then
                    frame.Container:SetShown(frame:IsShown())
                elseif frame.isDocked and frame:IsShown() and frame:GetID() > 1 then
                    ChatFrame1.Container:Show()
                end
            end
        end
    end)

    hooksecurefunc("FCF_Close", function(frame)
        if frame.Container then
            frame.Container:Hide()
        end
    end)

    hooksecurefunc("FCF_MinimizeFrame", function(chatFrame)
        if chatFrame.minimized then
            if chatFrame.Container then chatFrame.Container:SetAlpha(0) end
            local minFrame = chatFrame.minFrame
            if not minFrame.minimizeStyled then
                minFrame:GwStripTextures(true)
                minFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
                -- same font object for every state, otherwise the button brings back the yellow on hover
                minFrame:SetNormalFontObject(GameFontHighlight)
                minFrame:SetHighlightFontObject(GameFontHighlight)
                minFrame:SetDisabledFontObject(GameFontHighlight)
                local text = minFrame:GetFontString()
                text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
                text:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
                local maximizeButton = _G[minFrame:GetName() .. "MaximizeButton"]
                maximizeButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/maximize_button.png")
                maximizeButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/maximize_button.png")
                maximizeButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/maximize_button.png")
                maximizeButton:SetSize(20, 20)
                minFrame.minimizeStyled = true
            end
        end
    end)

    hooksecurefunc("FCFTab_OnDragStop", function(self)
        local frame = _G["ChatFrame" .. self:GetID()]
        local _, _, _, _, _, _, _, _, isDocked = GetChatWindowInfo(frame:GetID())

        ApplyChatFrameFading(frame)
        if not EnsureChatContainer(frame, isDocked) and frame.hasContainer then
            frame.Container:Show()
        end
        --Set Button and container position after drag for every container
        for _, frameName in ipairs(CHAT_FRAMES) do
            local frameForPosition = _G[frameName]
            if frameForPosition:IsShown() and frameForPosition.hasContainer then setButtonPosition(frameForPosition) end
        end
    end)

    -- blizzard calls it on every frame while a tab is dragged
    hooksecurefunc("FCF_SetButtonSide", function(frame)
        if frame.gwButtonSide == frame.buttonSide then return end
        frame.gwButtonSide = frame.buttonSide
        AdjustChatContent(frame)
        if frame.hasContainer then setButtonPosition(frame) end
    end)
    hooksecurefunc("FCF_SetTabPosition", AdjustFloatingTab)
    if FCF_UpdateScrollbarAnchors then
        hooksecurefunc("FCF_UpdateScrollbarAnchors", AlignScrollBar)
    end
    hooksecurefunc("FCF_FadeOutChatFrame", handleChatFrameFadeOut)
    hooksecurefunc("FCF_FadeInChatFrame", handleChatFrameFadeIn)

    for _, frameName in pairs(CHAT_FRAMES) do
        _G[frameName .. "Tab"]:SetScript("OnDoubleClick", nil)
    end

    for _, menu in next, { ChatMenu, EmoteMenu, LanguageMenu, VoiceMacroMenu } do
        menu:HookScript("OnShow",
            function(self)
                self:GwStripTextures()
                self:GwCreateBackdrop(GW.BackdropTemplates.Default)
            end)
    end

    if CombatLogQuickButtonFrame_CustomProgressBar then
        CombatLogQuickButtonFrame_CustomProgressBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
        CombatLogQuickButtonFrame_CustomTexture:Hide()
    end

    -- prevent the voice tab from showing if disabled
    hooksecurefunc("VoiceTranscriptionFrame_UpdateVisibility", function(self)
        local showVoice = GetCVarBool("speechToText")
        SetChatWindowShown(self:GetID(), showVoice)
        ChatFrame3Tab:SetShown(showVoice)
        FloatingChatFrame_Update(self:GetID())
        FCF_DockUpdate()
        if ChatFrame3.hasContainer then
            ChatFrame3.Container:SetShown(showVoice)
        end
    end)

    -- set custom textures for chat channel buttons (chats/voice, mute mic/sound)
    ChatFrameChannelButton:SetHeight(20)
    ChatFrameChannelButton:SetWidth(20)
    ChatFrameChannelButton.Flash:SetHeight(20)
    ChatFrameChannelButton.Flash:SetWidth(20)
    ChatFrameChannelButton.Icon:GwKill()
    hooksecurefunc(ChatFrameChannelButton, "SetIconToState", function(self, joined)
        if joined then
            self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/channel_button_vc_highlight.png")
            self:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/channel_button_vc.png")
            self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/channel_button_vc_highlight.png")
            self.Flash:SetTexture("Interface/AddOns/GW2_UI/textures/chat/channel_button_vc_highlight.png")
            if GW.isModern then
                ChatFrameToggleVoiceMuteButton:Show()
                ChatFrameToggleVoiceDeafenButton:Show()
            end
        else
            self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/channel_button_normal_highlight.png")
            self:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/channel_button_normal.png")
            self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/channel_button_normal_highlight.png")
            self.Flash:SetTexture("Interface/AddOns/GW2_UI/textures/chat/channel_button_normal_highlight.png")
            if GW.isModern then
                ChatFrameToggleVoiceMuteButton:Hide()
                ChatFrameToggleVoiceDeafenButton:Hide()
            end
        end
    end)
    if GW.isModern then
        ChatFrameToggleVoiceMuteButton:SetHeight(20)
        ChatFrameToggleVoiceMuteButton:SetWidth(20)
        ChatFrameToggleVoiceMuteButton.Icon:GwKill()
        hooksecurefunc(ChatFrameToggleVoiceMuteButton, "SetIconToState", function(self, state)
            if state == MUTE_SILENCE_STATE_NONE then -- mic on
                self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_on_highlight.png")
                self:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_on.png")
                self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_on_highlight.png")
            elseif state == MUTE_SILENCE_STATE_MUTE then -- mic off
                self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_off_highlight.png")
                self:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_off.png")
                self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_off_highlight.png")
            elseif state == MUTE_SILENCE_STATE_SILENCE then -- mic silenced on
                self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_silenced_on_highlight.png")
                self:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_silenced_on.png")
                self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_silenced_on_highlight.png")
            elseif state == MUTE_SILENCE_STATE_MUTE_AND_SILENCE then -- mic silenced off
                self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_silenced_off_highlight.png")
                self:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_silenced_off.png")
                self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_silenced_off_highlight.png")
            end
        end)
        ChatFrameToggleVoiceDeafenButton:SetHeight(20)
        ChatFrameToggleVoiceDeafenButton:SetWidth(20)
        ChatFrameToggleVoiceDeafenButton.Icon:GwKill()
        hooksecurefunc(ChatFrameToggleVoiceDeafenButton, "SetIconToState", function(self, deafened)
            if deafened then
                self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_sound_off_highlight.png")
                self:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_sound_off.png")
                self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_sound_off_highlight.png")
            else
                self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_sound_on_highlight.png")
                self:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_sound_on.png")
                self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/channel_vc_sound_on_highlight.png")
            end
        end)
    end

    -- apply the configured controls position (hover bar / classic column);
    -- must run after the buttons got their sizes above
    GW.UpdateChatButtonsPosition()

    -- blizzard re-anchors the dock whenever the primary dock frame changes
    if FCFDock_SetPrimary then
        hooksecurefunc("FCFDock_SetPrimary", AdjustChatDock)
    end

    -- re-apply the text container anchors after all sizing is done and whenever
    -- a chat frame changes size (the engine resets the container on relayout)
    for _, frameName in ipairs(CHAT_FRAMES) do
        local frame = _G[frameName]
        if frame then
            AdjustChatContent(frame)
            if not frame.gwContentSizeHook then
                frame:HookScript("OnSizeChanged", AdjustChatContent)
                frame.gwContentSizeHook = true
            end
        end
    end

    if GW.Mists then -- allow chat to stay shown
        hooksecurefunc("PetBattleFrame_Display", PetBattleFrame_Display)
    end

    -- events for functions
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("CVAR_UPDATE")
    eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            ChatFrameChannelButton:UpdateVisibleState()
            if GW.isModern then
                ChatFrameToggleVoiceMuteButton:UpdateVisibleState()
                ChatFrameToggleVoiceDeafenButton:UpdateVisibleState()
            end
        elseif event == "CVAR_UPDATE" then
            if ... == "ENABLE_SPEECH_TO_TEXT_TRANSCRIPTION" then
                local showVoice = GetCVarBool("speechToText")
                SetChatWindowShown(3, showVoice)
                ChatFrame3Tab:SetShown(showVoice)
                if ChatFrame3.hasContainer then
                    ChatFrame3.Container:SetShown(showVoice)
                end
                FloatingChatFrame_Update(3)
                FCF_DockUpdate()
            end
        end
    end)
end
GW.LoadChat = LoadChat
