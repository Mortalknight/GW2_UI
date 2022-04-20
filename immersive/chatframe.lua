local _, GW = ...
local L = GW.L

local GetSetting = GW.GetSetting

local FindURL_Events = {
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_BN_WHISPER",
    "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_BN_INLINE_TOAST_BROADCAST",
    "CHAT_MSG_GUILD_ACHIEVEMENT",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_OFFICER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_CHANNEL",
    "CHAT_MSG_SAY",
    "CHAT_MSG_YELL",
    "CHAT_MSG_EMOTE",
    "CHAT_MSG_AFK",
    "CHAT_MSG_DND",
    "CHAT_MSG_COMMUNITIES_CHANNEL",
}

local DEFAULT_STRINGS = {
    GUILD = L["G"],
    PARTY = L["P"],
    RAID = L["R"],
    OFFICER = L["O"],
    PARTY_LEADER = L["PL"],
    RAID_LEADER = L["RL"],
    INSTANCE_CHAT = L["I"],
    INSTANCE_CHAT_LEADER = L["IL"],
    PET_BATTLE_COMBAT_LOG = PET_BATTLE_COMBAT_LOG,
}

local hyperlinkTypes = {
    achievement = true,
    apower = true,
    currency = true,
    enchant = true,
    glyph = true,
    instancelock = true,
    item = true,
    keystone = true,
    quest = true,
    spell = true,
    talent = true,
    unit = true
}


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

local throttle = {}
local lfgRoles = {}
local GuidCache = {}
local ClassNames = {}
local Keywords = {}
local hooks = {}
local Smileys = {}
local SmileysForMenu = {}
local socialQueueCache = {}

local SoundTimer

local PLAYER_REALM = gsub(GW.myrealm , "[%s%-]", "")
local PLAYER_NAME = format("%s-%s", GW.myname, PLAYER_REALM)

local tabTexs = {
    "",
    "Selected",
    "Highlight"
}

local rolePaths = {
    TANK = "|TInterface/AddOns/GW2_UI/Textures/party/roleicon-tank:12:12:0:0:64:64:2:56:2:56|t ",
    HEALER = "|TInterface/AddOns/GW2_UI/Textures/party/roleicon-healer:12:12:0:0:64:64:2:56:2:56|t ",
    DAMAGER = "|TInterface/AddOns/GW2_UI/Textures/party/roleicon-dps:15:15:-2:0:64:64:2:56:2:56|t"
}

local gw_fade_frames = {
    QuickJoinToastButton,
    GeneralDockManager,
    ChatFrameChannelButton,
    ChatFrameToggleVoiceDeafenButton,
    ChatFrameToggleVoiceMuteButton
}

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

local function isMessageProtected(message)
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
    local hyperLinkFunc = function(w, _, y)
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
        text = gsub(text, "(%d-)(.-)|4(.-):(.-);", fourString) --stuff where it goes "day" or "days" like played; tech this is wrong but okayish
        return text
    end
end

local function getLines(frame, copyLines)
    local index = 1
    local maxMessages, frameMessages = tonumber(GetSetting("CHAT_MAX_COPY_CHAT_LINES")), frame:GetNumMessages()
    local startLine = frameMessages <= maxMessages and 1 or frameMessages + 1 - maxMessages

    for i = startLine, frame:GetNumMessages() do
        local message, r, g, b = frame:GetMessageInfo(i)
        if message and not isMessageProtected(message) then
            r, g, b = r or 1, g or 1, b or 1            --Set fallback color values
            message = removeIconFromLine(message)       --Remove icons
            message = colorizeLine(message, r, g, b)    --Add text color
            copyLines[index] = message
            index = index + 1
        end
    end

    return index - 1, copyLines
end

local function setButtonPosition(frame)
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

        if QuickJoinToastButton and frame.isDocked ~= nil then
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

        if QuickJoinToastButton and frame.isDocked ~= nil then
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
    for _, v in pairs(CHAT_FRAME_TEXTURES) do
        local object = _G[frameName .. v]
        if object and object:IsShown() then
            UIFrameFadeIn(object, 0.5, object:GetAlpha(), 1)
        end
    end
    if chatFrame.isDocked == 1 then
        for _, v in pairs(gw_fade_frames) do
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

        UIFrameFadeIn(ChatFrame1.Container, 0.5, ChatFrame1.Container:GetAlpha(), 1)
        UIFrameFadeIn(ChatFrameMenuButton, 0.5, ChatFrameMenuButton:GetAlpha(), 1)
    elseif chatFrame.isDocked == nil then
        if chatFrame.Container then
            UIFrameFadeIn(chatFrame.Container, 0.5, chatFrame.Container:GetAlpha(), 1)
        end
    end

    if chatFrame.button then
        UIFrameFadeIn(chatFrame.button, 0.5, chatFrame.button:GetAlpha(), 0.35)
    end
    if chatFrame.buttonEmote then
        UIFrameFadeIn(chatFrame.buttonEmote, 0.5, chatFrame.buttonEmote:GetAlpha(), 0.35)
    end
    if GW_EmoteFrame and GW_EmoteFrame:IsShown() then
        UIFrameFadeIn(GW_EmoteFrame, 0.5, GW_EmoteFrame:GetAlpha(), 1)
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
    if chatFrame.editboxHasFocus or (GW_EmoteFrame and GW_EmoteFrame:IsShown() and GW_EmoteFrame:IsMouseOver()) then
        handleChatFrameFadeIn(chatFrame)
        return
    end

    local chatAlpha = select(6, GetChatWindowInfo(chatFrame:GetID()))
    local frameName = chatFrame:GetName()

    for _, v in pairs(CHAT_FRAME_TEXTURES) do
        local object = _G[frameName .. v]
        if object and object:IsShown() then
            UIFrameFadeOut(object, 2, object:GetAlpha(), 0)
        end
    end
    if chatFrame.isDocked == 1 then
        for _, v in pairs(gw_fade_frames) do
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
        UIFrameFadeOut(ChatFrame1.Container, 2, ChatFrame1.Container:GetAlpha(), chatAlpha)
    elseif chatFrame.isDocked == nil then
        if chatFrame.Container then
            UIFrameFadeOut(chatFrame.Container, 2, chatFrame.Container:GetAlpha(), chatAlpha)
        end
    end

    if chatFrame.button then
        UIFrameFadeOut(chatFrame.button, 2, chatFrame.button:GetAlpha(), 0)
    end
    if chatFrame.buttonEmote then
        UIFrameFadeOut(chatFrame.buttonEmote, 2, chatFrame.buttonEmote:GetAlpha(), 0)
    end
    if GW_EmoteFrame and GW_EmoteFrame:IsShown() then
        UIFrameFadeOut(GW_EmoteFrame, 2, GW_EmoteFrame:GetAlpha(), 0)
    end

    local chatTab = _G[frameName .. "Tab"]
    UIFrameFadeOut(chatTab, 2, chatTab:GetAlpha(), 0)

    UIFrameFadeOut(chatFrame.buttonFrame, 2, chatFrame.buttonFrame:GetAlpha(), 0)
    UIFrameFadeOut(ChatFrameMenuButton, 2, ChatFrameMenuButton:GetAlpha(), 0)

    --check if other Tabs has Containers, which need to fade out
    for i = 1, FCF_GetNumActiveChatFrames() do
        if _G["ChatFrame" .. i].hasContainer and _G["ChatFrame" .. i].isDocked == chatFrame.isDocked and chatFrame:GetID() ~= i then
            UIFrameFadeOut(_G["ChatFrame" .. i].Container, 2, _G["ChatFrame" .. i].Container:GetAlpha(), chatAlpha)
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

local function SetChatEditBoxMessage(message)
    local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
    local editBoxShown = ChatFrameEditBox:IsShown()
    local editBoxText = ChatFrameEditBox:GetText()
    if not editBoxShown then
        ChatEdit_ActivateChat(ChatFrameEditBox)
    end
    if editBoxText and editBoxText ~= "" then
        ChatFrameEditBox:SetText("")
    end
    ChatFrameEditBox:Insert(message)
    ChatFrameEditBox:HighlightText()
end

local SetHyperlink = _G.ItemRefTooltip.SetHyperlink
function _G.ItemRefTooltip:SetHyperlink(data, ...)
    if strsub(data, 1, 3) == "url" then
        local currentLink = strsub(data, 5)
        if currentLink and currentLink ~= "" then
            SetChatEditBoxMessage(currentLink)
        end
    elseif strsub(data, 1, 3) == "squ" then
        local guid = strsub(data, 5)
        if guid and guid ~= "" then
            if GetSetting("USE_SOCIAL_WINDOW") then
                if InCombatLockdown() then return end
                GwSocialWindow:SetAttribute("windowpanelopen", "quicklist")
            else
                if not QuickJoinFrame:IsShown() then
                    ToggleQuickJoinPanel()
                end
            end
            QuickJoinFrame:SelectGroup(guid)
            QuickJoinFrame:ScrollToGroup(guid)
        end
    else
        SetHyperlink(self, data, ...)
    end
end

local hyperLinkEntered
local function OnHyperlinkEnter(self, refString)
    if InCombatLockdown() then return end
    local linkToken = strmatch(refString, "^([^:]+)")
    if hyperlinkTypes[linkToken] then
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(refString)
        GameTooltip:Show()
        hyperLinkEntered = self
    end
end

local function OnHyperlinkLeave()
    if hyperLinkEntered then
        hyperLinkEntered = nil
        GameTooltip:Hide()
    end
end

local function OnMouseWheel(frame)
    if hyperLinkEntered == frame then
        hyperLinkEntered = false
        GameTooltip:Hide()
    end
end

local function ToggleHyperlink(enabled)
    if not enabled then return end
    for _, frameName in ipairs(CHAT_FRAMES) do
        local frame = _G[frameName]
        local hooked = hooks and hooks[frame] and hooks[frame].OnHyperlinkEnter
        if not hooked then
            frame:HookScript("OnHyperlinkEnter", OnHyperlinkEnter)
            frame:HookScript("OnHyperlinkLeave", OnHyperlinkLeave)
            frame:HookScript("OnMouseWheel", OnMouseWheel)
        end
    end
end

local function UpdateChatKeywords()
    wipe(Keywords)

    local keywords = GetSetting("CHAT_KEYWORDS")
    keywords = gsub(keywords, ",%s", ",")

    for stringValue in gmatch(keywords, "[^,]+") do
        if stringValue ~= "" then
            Keywords[stringValue] = true
        end
    end
end
GW.UpdateChatKeywords = UpdateChatKeywords

local protectLinks = {}
local function CheckKeyword(message, author)
    local letSound = not SoundTimer and author ~= PLAYER_NAME and GetSetting("CHAT_KEYWORDS_ALERT_NEW") ~= "None"

    for hyperLink in gmatch(message, "|c%x-|H.-|h.-|h|r") do
        protectLinks[hyperLink] = gsub(hyperLink,"%s","|s")

        if letSound then
            for keyword in pairs(Keywords) do
                if hyperLink == keyword then
                    SoundTimer = C_Timer.NewTimer(5, function() SoundTimer = nil end)
                    PlaySoundFile(GW.Libs.LSM:Fetch("sound", GetSetting("CHAT_KEYWORDS_ALERT_NEW")), "Master")
                    letSound = false
                    break
                end
            end
        end
    end

    for hyperLink, tempLink in pairs(protectLinks) do
        message = gsub(message, GW.EscapeString(hyperLink), tempLink)
    end

    local rebuiltString
    local isFirstWord = true
    for word in gmatch(message, "%s-%S+%s*") do
        if not next(protectLinks) or not protectLinks[gsub(gsub(word, "%s", ""), "|s", " ")] then
            local tempWord = gsub(word, "[%s%p]", "")
            local lowerCaseWord = strlower(tempWord)

            for keyword in pairs(Keywords) do
                if lowerCaseWord == strlower(keyword) or (lowerCaseWord == strlower(GW.myname) and keyword == "%MYNAME%") then
                    local keywordColor = GetSetting("CHAT_KEYWORDS_ALERT_COLOR")
                    word = gsub(word, tempWord, format("%s%s|r",GW.RGBToHex(keywordColor.r, keywordColor.g, keywordColor.b), tempWord))

                    if letSound then
                        SoundTimer = C_Timer.NewTimer(5, function() SoundTimer = nil end)
                        PlaySoundFile(GW.Libs.LSM:Fetch("sound", GetSetting("CHAT_KEYWORDS_ALERT_NEW")), "Master")
                        letSound = false
                    end
                end
            end

            if GetSetting("CHAT_CLASS_COLOR_MENTIONS") then
                tempWord = gsub(word, "^[%s%p]-([^%s%p]+)([%-]?[^%s%p]-)[%s%p]*$", "%1%2")
                lowerCaseWord = strlower(tempWord)
                GW_ClassNames = ClassNames
                local classMatch = ClassNames[lowerCaseWord]
                local wordMatch = classMatch and lowerCaseWord

                if wordMatch then
                    local classColorTable = GW.GWGetClassColor(classMatch, true, true)
                    GW_classColorTable = classColorTable
                    if classColorTable then
                        word = gsub(word, gsub(tempWord, "%-","%%-"), format("\124cff%.2x%.2x%.2x%s\124r", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, tempWord))
                    end
                end
            end
        end

        if isFirstWord then
            rebuiltString = word
            isFirstWord = false
        else
            rebuiltString = rebuiltString .. word
        end
    end

    for hyperLink, tempLink in pairs(protectLinks) do
        rebuiltString = gsub(rebuiltString, GW.EscapeString(tempLink), hyperLink)
        protectLinks[hyperLink] = nil
    end

    return rebuiltString
end


local function InsertEmotions(msg)
    for word in gmatch(msg, "%s-%S+%s*") do
        word = strtrim(word)
        local pattern = GW.EscapeString(word)
        local emoji = Smileys[pattern]
        if emoji and strmatch(msg, "[%s%p]-" .. pattern .. "[%s%p]*") then
            local base64 = GW.Libs.LibBase64:Encode(word)
            msg = gsub(msg, "([%s%p]-)" .. pattern .. "([%s%p]*)", (base64 and ("%1|Helvmoji:%%" .. base64 .. "|h|cFFffffff|r|h") or "%1") .. emoji .. "%2")
        end
    end

    return msg
end

local function GetSmileyReplacementText(msg)
    if not msg or not GetSetting("CHAT_KEYWORDS_EMOJI") or strfind(msg, "/run") or strfind(msg, "/dump") or strfind(msg, "/script") then return msg end
    local outstr = ""
    local origlen = strlen(msg)
    local startpos = 1
    local endpos

    while (startpos <= origlen) do
        local pos = strfind(msg, "|H", startpos, true)
        endpos = pos or origlen
        outstr = outstr .. InsertEmotions(strsub(msg, startpos, endpos))
        startpos = endpos + 1
        if pos ~= nil then
            _, endpos = strfind(msg, "|h.-|h", startpos)
            endpos = endpos or origlen
            if startpos < endpos then
                outstr = outstr .. strsub(msg, startpos, endpos)
                startpos = endpos + 1
            end
        end
    end

    return outstr
end

local function PrintURL(url)
    return "|cFFFFFFFF[|Hurl:" .. url .. "|h" .. url .. "|h]|r "
end

local function FindURL(msg, author, ...)
    if not GetSetting("CHAT_FIND_URL") then -- find url setting here
        msg = CheckKeyword(msg, author)
        msg = GetSmileyReplacementText(msg)
        return false, msg, author, ...
    end

    local text, tag = msg, strmatch(msg, "{(.-)}")
    if tag and ICON_TAG_LIST[strlower(tag)] then
        text = gsub(gsub(text, "(%S)({.-})", "%1 %2"), "({.-})(%S)", "%1 %2")
    end

    text = gsub(gsub(text, "(%S)(|c.-|H.-|h.-|h|r)", "%1 %2"), "(|c.-|H.-|h.-|h|r)(%S)", "%1 %2")
    -- http://example.com
    local newMsg, found = gsub(text, "(%a+)://(%S+)%s?", PrintURL("%1://%2"))
    if found > 0 then return false, GetSmileyReplacementText(CheckKeyword(newMsg, author)), author, ... end
    -- www.example.com
    newMsg, found = gsub(text, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", PrintURL("www.%1.%2"))
    if found > 0 then return false, GetSmileyReplacementText(CheckKeyword(newMsg, author)), author, ... end
    -- example@example.com
    newMsg, found = gsub(text, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", PrintURL("%1@%2%3%4"))
    if found > 0 then return false, GetSmileyReplacementText(CheckKeyword(newMsg, author)), author, ... end
    -- IP address with port 1.1.1.1:1
    newMsg, found = gsub(text, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)(:%d+)%s?", PrintURL("%1.%2.%3.%4%5"))
    if found > 0 then return false, GetSmileyReplacementText(CheckKeyword(newMsg, author)), author, ... end
    -- IP address 1.1.1.1
    newMsg, found = gsub(text, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?", PrintURL("%1.%2.%3.%4"))
    if found > 0 then return false, GetSmileyReplacementText(CheckKeyword(newMsg, author)), author, ... end

    msg = CheckKeyword(msg, author)
    msg = GetSmileyReplacementText(msg)

    return false, msg, author, ...
end

local function DisableChatThrottle()
    wipe(throttle)
end
GW.DisableChatThrottle = DisableChatThrottle

local function PrepareMessage(author, message)
    if author and author ~= "" and message and message ~= "" then
        return strupper(author) .. message
    end
end

local function ChatThrottleHandler(author, message, when)
    local msg = PrepareMessage(author, message)
    if msg then
        for message, object in pairs(throttle) do
            if difftime(when, object.time) >= tonumber(GetSetting("CHAT_SPAM_INTERVAL_TIMER")) then
                throttle[message] = nil
            end
        end

        if not throttle[msg] then
            throttle[msg] = {time = time(), count = 1}
        else
            throttle[msg].count = throttle[msg].count + 1
        end
    end
end

local function ChatThrottleBlockFlag(author, message, when)
    local msg = (author ~= PLAYER_NAME) and (tonumber(GetSetting("CHAT_SPAM_INTERVAL_TIMER")) ~= 0) and PrepareMessage(author, message)

    local object = msg and throttle[msg]

    return object and object.time and object.count and object.count > 1 and (difftime(when, object.time) <= tonumber(GetSetting("CHAT_SPAM_INTERVAL_TIMER"))), object
end

local function ChatThrottleIntervalHandler(message, author, ...)
    local blockFlag, blockObject = ChatThrottleBlockFlag(author, message, time())

    if blockFlag then
        return true
    else
        if blockObject then blockObject.time = time() end
        return FindURL(message, author, ...)
    end
end

local function HandleChatMessageFilter(_, event, message, author, ...)
    if GW.IsIn(event, "CHAT_MSG_CHANNEL", "CHAT_MSG_YELL", "CHAT_MSG_SAY") then
        return ChatThrottleIntervalHandler(message, author, ...)
    else
        return FindURL(message, author, ...)
    end
end

local function ChatFrame_CheckAddChannel(chatFrame, eventType, channelID)
    -- This is called in the event that a user receives chat events for a channel that isn"t enabled for any chat frames.
    -- Minor hack, because chat channel filtering is backed by the client, but driven entirely from Lua.
    -- This solves the issue of Guides abdicating their status, and then re-applying in the same game session, unless ChatFrame_AddChannel
    -- is called, the channel filter will be off even though it"s still enabled in the client, since abdication removes the chat channel and its config.

    -- Only add to default (since multiple chat frames receive the event and we don"t want to add to others)
    if chatFrame ~= DEFAULT_CHAT_FRAME then
        return false;
    end

    -- Only add if the user is joining a channel
    if eventType ~= "YOU_CHANGED" then
        return false;
    end

    -- Only add regional channels
    if not C_ChatInfo.IsChannelRegionalForChannelID(channelID) then
        return false;
    end

    return ChatFrame_AddChannel(chatFrame, C_ChatInfo.GetChannelShortcutForChannelID(channelID)) ~= nil;
end

local function AddTimestamp(msg)
   if CHAT_TIMESTAMP_FORMAT then
        local timeStamp = BetterDate(CHAT_TIMESTAMP_FORMAT, time())

        timeStamp = gsub(timeStamp, " ", "")
        timeStamp = gsub(timeStamp, "AM", " AM")
        timeStamp = gsub(timeStamp, "PM", " PM")
        msg = format("[%s] %s", timeStamp, msg)
    end

    return msg
end

local function AddMessage(self, msg, infoR, infoG, infoB, infoID, accessID, typeID)
    msg = AddTimestamp(msg)

    self.OldAddMessage(self, msg, infoR, infoG, infoB, infoID, accessID, typeID)
end

-- copied from ChatFrame.lua
local function GetPFlag(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
    -- Renaming for clarity:
    local specialFlag = arg6
    local zoneChannelID = arg7
    --local localChannelID = arg8

    if specialFlag ~= "" then
        if specialFlag == "GM" or specialFlag == "DEV" then
            -- Add Blizzard Icon if this was sent by a GM/DEV
            return "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t "
        elseif specialFlag == "GUIDE" then
            if ChatFrame_GetMentorChannelStatus(Enum.PlayerMentorshipStatus.Mentor, C_ChatInfo.GetChannelRulesetForChannelID(zoneChannelID)) == Enum.PlayerMentorshipStatus.Mentor then
                return gsub(NPEV2_CHAT_USER_TAG_GUIDE, "(|A.-|a).+", "%1") .. " "
            end
        elseif specialFlag == "NEWCOMER" then
            if ChatFrame_GetMentorChannelStatus(Enum.PlayerMentorshipStatus.Newcomer, C_ChatInfo.GetChannelRulesetForChannelID(zoneChannelID)) == Enum.PlayerMentorshipStatus.Newcomer then
                return NPEV2_CHAT_USER_TAG_NEWCOMER
            end
        else
            return _G["CHAT_FLAG_" .. specialFlag]
        end
    end

    return ""
end

local function GW_GetPlayerInfoByGUID(guid)
    local data = GuidCache[guid]
    if not data then
        local ok, localizedClass, englishClass, localizedRace, englishRace, sex, name, realm = pcall(GetPlayerInfoByGUID, guid)
        if not (ok and englishClass) then return end

        if realm == "" then realm = nil end
        local shortRealm, nameWithRealm = realm and gsub(realm, "[%s%-]", ""), nil
        if name and name ~= "" then
            nameWithRealm = (shortRealm and name .. "-" .. shortRealm) or name .. "-" .. PLAYER_REALM
        end

        data = {
            localizedClass = localizedClass,
            englishClass = englishClass,
            localizedRace = localizedRace,
            englishRace = englishRace,
            sex = sex,
            name = name,
            realm = realm,
            nameWithRealm = nameWithRealm
        }

        -- add it to ClassNames
        if name then
            ClassNames[strlower(name)] = englishClass
        end
        if nameWithRealm then
            ClassNames[strlower(nameWithRealm)] = englishClass
        end

        -- push into the cache
        GuidCache[guid] = data
    end

    if data then data.classColor = GW.GWGetClassColor(data.englishClass, true, true) end

    return data
end

local function ShortChannel(self)
    return format("|Hchannel:%s|h[%s]|h", self, DEFAULT_STRINGS[strupper(self)] or gsub(self, "channel:", ""))
end
GW.ShortChannel = ShortChannel

local function ChatFrame_MessageEventHandler(frame, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
    if TextToSpeechFrame_MessageEventHandler then
        TextToSpeechFrame_MessageEventHandler(frame, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
    end

    if strsub(event, 1, 8) == "CHAT_MSG" then
        if arg16 then return true end -- hiding sender in letterbox: do NOT even show in chat window (only shows in cinematic frame)

        local chatType = strsub(event, 10)
        local info = ChatTypeInfo[chatType]

        --If it was a GM whisper, dispatch it to the GMChat addon.
        if arg6 == "GM" and chatType == "WHISPER" then
            return
        end

        local chatFilters = ChatFrame_GetMessageEventFilters(event)
        if chatFilters then
            for _, filterFunc in next, chatFilters do
                local filter, new1, new2, new3, new4, new5, new6, new7, new8, new9, new10, new11, new12, new13, new14, new15, new16, new17 = filterFunc(frame, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
                if filter then
                    return true
                elseif new1 then
                    arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = new1, new2, new3, new4, new5, new6, new7, new8, new9, new10, new11, new12, new13, new14, new15, new16, new17
                end
            end
        end

        -- data from populated guid info
        local nameWithRealm, realm
        local data = GW_GetPlayerInfoByGUID(arg12)
        if data then
            realm = data.realm
            nameWithRealm = data.nameWithRealm
        end

        -- fetch the name color to use
        local coloredName = GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)

        local channelLength = strlen(arg4)
        local infoType = chatType

        if type == "VOICE_TEXT" then
            local leader = UnitIsGroupLeader(arg2)
            infoType, type = VoiceTranscription_DetermineChatTypeVoiceTranscription_DetermineChatType(leader)
            info = ChatTypeInfo[infoType]
        elseif chatType == "COMMUNITIES_CHANNEL" or ((strsub(chatType, 1, 7) == "CHANNEL") and (chatType ~= "CHANNEL_LIST") and ((arg1 ~= "INVITE") or (chatType ~= "CHANNEL_NOTICE_USER"))) then
            if arg1 == "WRONG_PASSWORD" then
                local _, popup = StaticPopup_Visible("CHAT_CHANNEL_PASSWORD")
                if popup and strupper(popup.data) == strupper(arg9) then
                    return
                end
            end

            local found = false
            for index, value in pairs(frame.channelList) do
                if channelLength > strlen(value) then
                    -- arg9 is the channel name without the number in front...
                    if (arg7 > 0 and frame.zoneChannelList[index] == arg7) or (strupper(value) == strupper(arg9)) then
                        found = true

                        infoType = "CHANNEL"..arg8
                        info = ChatTypeInfo[infoType]

                        if chatType == "CHANNEL_NOTICE" and arg1 == "YOU_LEFT" then
                            frame.channelList[index] = nil
                            frame.zoneChannelList[index] = nil
                        end
                        break
                    end
                end
            end

            if not found or not info then
                local eventType, channelID = arg1, arg7
                if not ChatFrame_CheckAddChannel(frame, eventType, channelID) then
                    return true
                end
            end
        end

        local chatGroup = Chat_GetChatCategory(chatType)
        local chatTarget = FCFManager_GetChatTarget(chatGroup, arg2, arg8)

        if FCFManager_ShouldSuppressMessage(frame, chatGroup, chatTarget) then
            return true
        end

        if chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" then
            if frame.privateMessageList and not frame.privateMessageList[strlower(arg2)] then
                return true
            elseif frame.excludePrivateMessageList and frame.excludePrivateMessageList[strlower(arg2)] and ((chatGroup == "WHISPER" and GetCVar("whisperMode") ~= "popout_and_inline") or (chatGroup == "BN_WHISPER" and GetCVar("whisperMode") ~= "popout_and_inline")) then
                return true
            end
        end

        if frame.privateMessageList then
            -- Dedicated BN whisper windows need online/offline messages for only that player
            if (chatGroup == "BN_INLINE_TOAST_ALERT" or chatGroup == "BN_WHISPER_PLAYER_OFFLINE") and not frame.privateMessageList[strlower(arg2)] then
                return true
            end

            -- HACK to put certain system messages into dedicated whisper windows
            if chatGroup == "SYSTEM" then
                local matchFound = false
                local message = strlower(arg1)
                for playerName in pairs(frame.privateMessageList) do
                    local playerNotFoundMsg = strlower(format(_G.ERR_CHAT_PLAYER_NOT_FOUND_S, playerName))
                    local charOnlineMsg = strlower(format(_G.ERR_FRIEND_ONLINE_SS, playerName, playerName))
                    local charOfflineMsg = strlower(format(_G.ERR_FRIEND_OFFLINE_S, playerName))
                    if message == playerNotFoundMsg or message == charOnlineMsg or message == charOfflineMsg then
                        matchFound = true
                        break
                    end
                end

                if not matchFound then
                    return true
                end
            end
        end

        if (chatType == "SYSTEM" or chatType == "SKILL" or chatType == "CURRENCY" or chatType == "MONEY" or
            chatType == "OPENING" or chatType == "TRADESKILLS" or chatType == "PET_INFO" or chatType == "TARGETICONS" or chatType == "BN_WHISPER_PLAYER_OFFLINE") then
            frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil)
        elseif chatType == "LOOT" then
            if arg12 == GW.myguid and C_Social.IsSocialEnabled() then
                local itemID, creationContext = GetItemInfoFromHyperlink(arg1)
                if itemID and C_Social.GetLastItem() == itemID then
                    arg1 = arg1 .. " " .. _G.Social_GetShareItemLink(creationContext, true)
                end
            end
            frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil)
        elseif strsub(chatType,1,7) == "COMBAT_" then
            frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil)
        elseif strsub(chatType,1,6) == "SPELL_" then
            frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil)
        elseif strsub(chatType,1,10) == "BG_SYSTEM_" then
            frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil)
        elseif strsub(chatType,1,11) == "ACHIEVEMENT" then
            -- Append [Share] hyperlink
            if arg12 == GW.myguid and C_Social.IsSocialEnabled() then
                local achieveID = GetAchievementInfoFromHyperlink(arg1)
                if achieveID then
                    arg1 = arg1 .. " " .. Social_GetShareAchievementLink(achieveID, true)
                end
            end
            frame:AddMessage(format(arg1, GetPlayerLink(arg2, ("[%s]"):format(coloredName))), info.r, info.g, info.b, info.id, nil, nil)
        elseif strsub(chatType,1,18) == "GUILD_ACHIEVEMENT" then
            local message = format(arg1, GetPlayerLink(arg2, ("[%s]"):format(coloredName)))
            if C_Social.IsSocialEnabled() then
                local achieveID = GetAchievementInfoFromHyperlink(arg1)
                if achieveID then
                    local isGuildAchievement = select(12, GetAchievementInfo(achieveID))
                    if isGuildAchievement then
                        message = message .. " " .. Social_GetShareAchievementLink(achieveID, true)
                    end
                end
            end
            frame:AddMessage(message, info.r, info.g, info.b, info.id, nil, nil)
        elseif chatType == "IGNORED" then
            frame:AddMessage(format(CHAT_IGNORED, arg2), info.r, info.g, info.b, info.id, nil, nil)
        elseif chatType == "FILTERED" then
            frame:AddMessage(format(CHAT_FILTERED, arg2), info.r, info.g, info.b, info.id, nil, nil)
        elseif chatType == "RESTRICTED" then
            frame:AddMessage(CHAT_RESTRICTED_TRIAL, info.r, info.g, info.b, info.id, nil, nil)
        elseif chatType == "CHANNEL_LIST" then
            if channelLength > 0 then
                frame:AddMessage(format(_G["CHAT_" .. chatType .. "_GET"] .. arg1, tonumber(arg8), arg4), info.r, info.g, info.b, info.id, nil, nil)
            else
                frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil)
            end
        elseif chatType == "CHANNEL_NOTICE_USER" then
            local globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"]
            if not globalstring then
                globalstring = _G["CHAT_"..arg1.."_NOTICE"]
            end
            if not globalstring then
                GMError(("Missing global string for %q"):format("CHAT_"..arg1.."_NOTICE_BN"))
                return
            end
            if arg5 ~= "" then
                -- TWO users in this notice (E.G. x kicked y)
                frame:AddMessage(format(globalstring, arg8, arg4, arg2, arg5), info.r, info.g, info.b, info.id, nil, nil)
            elseif arg1 == "INVITE" then
                frame:AddMessage(format(globalstring, arg4, arg2), info.r, info.g, info.b, info.id, nil, nil)
            else
                frame:AddMessage(format(globalstring, arg8, arg4, arg2), info.r, info.g, info.b, info.id, nil, nil)
            end
            if arg1 == "INVITE" and GetCVarBool("blockChannelInvites") then
                frame:AddMessage(CHAT_MSG_BLOCK_CHAT_CHANNEL_INVITE, info.r, info.g, info.b, info.id, nil, nil)
            end
        elseif chatType == "CHANNEL_NOTICE" then
            local accessID = ChatHistory_GetAccessID(chatGroup, arg8)
            local typeID = ChatHistory_GetAccessID(infoType, arg8, arg12)

            if arg1 == "YOU_CHANGED" and C_ChatInfo.GetChannelRuleset(arg8) == Enum.ChatChannelRuleset.Mentor then
                ChatFrame_UpdateDefaultChatTarget(frame)
                ChatEdit_UpdateNewcomerEditBoxHint(frame.editBox)
            else
                if arg1 == "YOU_LEFT" then
                    ChatEdit_UpdateNewcomerEditBoxHint(frame.editBox, arg8)
                end

                local globalstring
                if arg1 == "TRIAL_RESTRICTED" then
                    globalstring = _G.CHAT_TRIAL_RESTRICTED_NOTICE_TRIAL
                else
                    globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"]
                    if not globalstring then
                        globalstring = _G["CHAT_"..arg1.."_NOTICE"]
                        if not globalstring then
                            GMError(("Missing global string for %q"):format("CHAT_"..arg1.."_NOTICE"))
                            return
                        end
                    end
                end

                frame:AddMessage(format(globalstring, arg8, ChatFrame_ResolvePrefixedChannelName(arg4)), info.r, info.g, info.b, info.id, accessID, typeID)
            end
        elseif chatType == "BN_INLINE_TOAST_ALERT" then
            local globalstring = _G["BN_INLINE_TOAST_"..arg1]
            if not globalstring then
                GMError(("Missing global string for %q"):format("BN_INLINE_TOAST_"..arg1))
                return
            end

            local message
            if arg1 == "FRIEND_REQUEST" then
                message = globalstring
            elseif arg1 == "FRIEND_PENDING" then
                message = format(_G.BN_INLINE_TOAST_FRIEND_PENDING, BNGetNumFriendInvites())
            elseif arg1 == "FRIEND_REMOVED" or arg1 == "BATTLETAG_FRIEND_REMOVED" then
                message = format(globalstring, arg2)
            elseif arg1 == "FRIEND_ONLINE" or arg1 == "FRIEND_OFFLINE" then
                local accountInfo = C_BattleNet.GetAccountInfoByID(arg13)
                if not accountInfo then return end
                local client = accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.clientProgram
                if client and client ~= "" then
                    local characterName = BNet_GetValidatedCharacterName(accountInfo.gameAccountInfo.characterName, accountInfo.battleTag, client) or ""
                    local characterNameText = BNet_GetClientEmbeddedTexture(client, 14)..characterName
                    local linkDisplayText = ("[%s] (%s)"):format(arg2, characterNameText)
                    local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, chatGroup, 0)
                    message = format(globalstring, playerLink)
                else
                    local linkDisplayText = ("[%s]"):format(arg2)
                    local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, chatGroup, 0)
                    message = format(globalstring, playerLink)
                end
            else
                local linkDisplayText = ("[%s]"):format(arg2)
                local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, chatGroup, 0)
                message = format(globalstring, playerLink)
            end
            frame:AddMessage(message, info.r, info.g, info.b, info.id, nil, nil)
        elseif chatType == "BN_INLINE_TOAST_BROADCAST" then
            if arg1 ~= "" then
                arg1 = RemoveNewlines(RemoveExtraSpaces(arg1))
                local linkDisplayText = ("[%s]"):format(arg2)
                local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, chatGroup, 0)
                frame:AddMessage(format(BN_INLINE_TOAST_BROADCAST, playerLink, arg1), info.r, info.g, info.b, info.id, nil, nil)
            end
        elseif chatType == "BN_INLINE_TOAST_BROADCAST_INFORM" then
            if arg1 ~= "" then
                frame:AddMessage(BN_INLINE_TOAST_BROADCAST_INFORM, info.r, info.g, info.b, info.id, nil, nil)
            end
        else
            local body

            if chatType == "WHISPER_INFORM" and GMChatFrame_IsGM and GMChatFrame_IsGM(arg2) then
                return
            end

            local showLink = 1
            if strsub(chatType, 1, 7) == "MONSTER" or strsub(chatType, 1, 9) == "RAID_BOSS" then
                showLink = nil
                -- fix blizzard formatting errors from localization strings
                arg1 = gsub(arg1, "%%%d", "%%s")
                arg1 = gsub(arg1, "(%d%%)([^%%%a])", "%1%%%2")
                arg1 = gsub(arg1, "(%d%%)$", "%1%%")
            else
                arg1 = gsub(arg1, "%%", "%%%%")
            end

            -- Search for icon links and replace them with texture links.
            arg1 = C_ChatInfo.ReplaceIconAndGroupExpressions(arg1, arg17, not ChatFrame_CanChatGroupPerformExpressionExpansion(chatGroup)) -- If arg17 is true, don"t convert to raid icons

            --Remove groups of many spaces
            arg1 = RemoveExtraSpaces(arg1)

            local playerLink
            local playerLinkDisplayText = coloredName
            local relevantDefaultLanguage = frame.defaultLanguage
            if chatType == "SAY" or chatType == "YELL" then
                relevantDefaultLanguage = frame.alternativeDefaultLanguage
            end
            local usingDifferentLanguage = (arg3 ~= "") and (arg3 ~= relevantDefaultLanguage)
            local usingEmote = (chatType == "EMOTE") or (chatType == "TEXT_EMOTE")

            if usingDifferentLanguage or not usingEmote then
                playerLinkDisplayText = ("[%s]"):format(coloredName)
            end

            local isCommunityType = chatType == "COMMUNITIES_CHANNEL"
            local playerName, lineID, bnetIDAccount = arg2, arg11, arg13
            if isCommunityType then
                local isBattleNetCommunity = bnetIDAccount ~= nil and bnetIDAccount ~= 0
                local messageInfo, clubId, streamId = C_Club.GetInfoFromLastCommunityChatLine()

                if messageInfo ~= nil then
                    if isBattleNetCommunity then
                        playerLink = GetBNPlayerCommunityLink(playerName, playerLinkDisplayText, bnetIDAccount, clubId, streamId, messageInfo.messageId.epoch, messageInfo.messageId.position)
                    else
                        playerLink = GetPlayerCommunityLink(playerName, playerLinkDisplayText, clubId, streamId, messageInfo.messageId.epoch, messageInfo.messageId.position)
                    end
                else
                    playerLink = playerLinkDisplayText
                end
            else
                if chatType == "BN_WHISPER" or chatType == "BN_WHISPER_INFORM" then
                    playerLink = GetBNPlayerLink(playerName, playerLinkDisplayText, bnetIDAccount, lineID, chatGroup, chatTarget)
                elseif ((chatType == "GUILD" or chatType == "TEXT_EMOTE") or arg14) and (nameWithRealm and nameWithRealm ~= playerName) then
                    playerName = nameWithRealm
                    playerLink = GetPlayerLink(playerName, playerLinkDisplayText, lineID, chatGroup, chatTarget)
                else
                    playerLink = GetPlayerLink(playerName, playerLinkDisplayText, lineID, chatGroup, chatTarget)
                end
            end

            local message = arg1
            if arg14 then --isMobile
                message = ChatFrame_GetMobileEmbeddedTexture(info.r, info.g, info.b)..message
            end

            -- Player Flags
            local pflag = GetPFlag(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)

            -- LFG Role Flags
            local lfgRole = lfgRoles[playerName]
            if lfgRole and (chatType == "PARTY_LEADER" or chatType == "PARTY" or chatType == "RAID" or chatType == "RAID_LEADER" or chatType == "INSTANCE_CHAT" or chatType == "INSTANCE_CHAT_LEADER") then
                pflag = pflag .. lfgRole
            end

            if usingDifferentLanguage then
                local languageHeader = "["..arg3.."] "
                if showLink and (arg2 ~= "") then
                    body = format(_G["CHAT_"..chatType.."_GET"]..languageHeader..message, pflag..playerLink)
                else
                    body = format(_G["CHAT_"..chatType.."_GET"]..languageHeader..message, pflag..arg2)
                end
            else
                if not showLink or arg2 == "" then
                    if chatType == "TEXT_EMOTE" then
                        body = message
                    else
                        body = format(_G["CHAT_"..chatType.."_GET"]..message, pflag..arg2, arg2)
                    end
                else
                    if chatType == "EMOTE" then
                        body = format(_G["CHAT_"..chatType.."_GET"]..message, pflag..playerLink)
                    elseif chatType == "TEXT_EMOTE" and realm then
                        if info.colorNameByClass then
                            body = gsub(message, arg2.."%-"..realm, pflag..gsub(playerLink, "(|h|c.-)|r|h$","%1-"..realm.."|r|h"), 1)
                        else
                            body = gsub(message, arg2.."%-"..realm, pflag..gsub(playerLink, "(|h.-)|h$","%1-"..realm.."|h"), 1)
                        end
                    elseif chatType == "TEXT_EMOTE" then
                        body = gsub(message, arg2, pflag..playerLink, 1)
                    elseif chatType == "GUILD_ITEM_LOOTED" then
                        body = gsub(message, "$s", GetPlayerLink(arg2, playerLinkDisplayText))
                    else
                        body = format(_G["CHAT_"..chatType.."_GET"]..message, pflag..playerLink)
                    end
                end
            end

            -- Add Channel
            if channelLength > 0 then
                body = "|Hchannel:channel:" .. arg8 .. "|h[" .. ChatFrame_ResolvePrefixedChannelName(arg4) .. "]|h " .. body
            end

            if GetSetting("CHAT_SHORT_CHANNEL_NAMES") and (chatType ~= "EMOTE" and chatType ~= "TEXT_EMOTE") then
                if chatType == "RAID_LEADER" or chatType == "PARTY_LEADER" or chatType == "INSTANCE_CHAT_LEADER" then
                    body = gsub(body, "|Hchannel:(.-)|h%[(.-)%]|h", format("|Hchannel:%s|h[%s]|h", (chatType == "PARTY_LEADER" and "PARTY" or chatType == "RAID_LEADER" and "RAID" or chatType == "INSTANCE_CHAT_LEADER" and "INSTANCE_CHAT") , DEFAULT_STRINGS[strupper(chatType)] or gsub(chatType, "channel:", "")))
                else
                    body = gsub(body, "|Hchannel:(.-)|h%[(.-)%]|h", ShortChannel)
                end
                body = gsub(body, "CHANNEL:", "")
                body = gsub(body, "^(.-|h) " .. CHAT_WHISPER_GET:format("~"):gsub("~ ", ""):gsub(": ", ""), "%1")
                body = gsub(body, "^(.-|h) " .. CHAT_SAY_GET:format("~"):gsub("~ ", ""):gsub(": ", ""), "%1")
                body = gsub(body, "^(.-|h) " .. CHAT_YELL_GET:format("~"):gsub("~ ", ""):gsub(": ", ""), "%1")
                body = gsub(body, "<" .. AFK .. ">", "[|cffFF0000" .. AFK .. "|r] ")
                body = gsub(body, "<" .. DND .. ">", "[|cffE7E716" .. DND .. "|r] ")
                body = gsub(body, "^%[" .. RAID_WARNING .. "%]", "[" .. L["RW"] .. "]")
            end

            if not GetSetting("CHAT_ADD_TIMESTAMP_TO_ALL") then
                body = AddTimestamp(body)
            end

            local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget)
            local typeID = ChatHistory_GetAccessID(infoType, chatTarget, arg12 or arg13)

            frame:AddMessage(body, info.r, info.g, info.b, info.id, accessID, typeID)
        end

        if chatType == "WHISPER" or chatType == "BN_WHISPER" then
            ChatEdit_SetLastTellTarget(arg2, chatType)
            FlashClientIcon()
        end

        if not frame:IsShown() then
            if (frame == DEFAULT_CHAT_FRAME and info.flashTabOnGeneral) or (frame ~= DEFAULT_CHAT_FRAME and info.flashTab) then
                if not CHAT_OPTIONS.HIDE_FRAME_ALERTS or chatType == "WHISPER" or chatType == "BN_WHISPER" then
                    if not FCFManager_ShouldSuppressMessageFlash(frame, chatGroup, chatTarget) then
                        FCF_StartAlertFlash(frame)
                    end
                end
            end
        end

        return true
    end
end

local function ChatFrame_ConfigEventHandler(...)
    return _G.ChatFrame_ConfigEventHandler(...)
end

local function ChatFrame_SystemEventHandler(frame, event, message, ...)
    return _G.ChatFrame_SystemEventHandler(frame, event, message, ...)
end

local function ChatFrame_OnEvent(frame, event, ...)
    if frame.customEventHandler and frame.customEventHandler(frame, event, ...) then return end
    if ChatFrame_ConfigEventHandler(frame, event, ...) then return end
    if ChatFrame_SystemEventHandler(frame, event, ...) then return end
    if ChatFrame_MessageEventHandler(frame, event, ...) then return end
end

local function FloatingChatFrameOnEvent(...)
    ChatFrame_OnEvent(...)
    FloatingChatFrame_OnEvent(...)
end

local function styleChatWindow(frame)
    local name = frame:GetName()
    _G[name .. "TabText"]:SetFont(DAMAGE_TEXT_FONT, 14)
    _G[name .. "TabText"]:SetTextColor(1, 1, 1)

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
        local fmGCC = CreateFrame("Frame", nil, UIParent, "GwChatContainer")
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
            _G[tab:GetName()..texName.."Right"]:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chattabactiveright")
            _G[tab:GetName()..texName.."Left"]:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chattabactiveleft")
            _G[tab:GetName()..texName.."Middle"]:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chattabactive")

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

    scrollToBottom:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
    scrollToBottom:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
    scrollToBottom:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
    scrollToBottom:SetHeight(24)
    scrollToBottom:SetWidth(24)
    scroll:SkinScrollBar()
    ChatFrameMenuButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/bubble_down")
    ChatFrameMenuButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/bubble_up")
    ChatFrameMenuButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/bubble_down")
    ChatFrameMenuButton:SetHeight(20)
    ChatFrameMenuButton:SetWidth(20)

    frame.buttonFrame.minimizeButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/minimize_button")
    frame.buttonFrame.minimizeButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/minimize_button")
    frame.buttonFrame.minimizeButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/minimize_button")
    frame.buttonFrame.minimizeButton:SetSize(24, 24)
    frame.buttonFrame:StripTextures()

    hooksecurefunc(tab, "SetAlpha", function(t, alpha)
        if alpha ~= 1 and (not t.isDocked or GeneralDockManager.selected:GetID() == t:GetID()) then
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
    _G[name .. "ButtonFrame"]:Hide()

    local a, b, c = select(6, editbox:GetRegions())
    a:SetTexture()
    b:SetTexture()
    c:SetTexture()
    _G[format(editbox:GetName() .. "Left", id)]:Hide()
    _G[format(editbox:GetName() .. "Mid", id)]:Hide()
    _G[format(editbox:GetName() .. "Right", id)]:Hide()
    editbox:ClearAllPoints()
    editbox:SetPoint("TOPLEFT", _G[name .. "ButtonFrame"], "BOTTOMLEFT", 0, 0)
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
        if GetSetting("CHATFRAME_EDITBOX_HIDE") then
            editBox:Hide()
        end
    end)
    local repeatedText

    editbox:HookScript("OnTextChanged", function(self)
        local userInput = self:GetText()

        if tonumber(GetSetting("CHAT_INCOMBAT_TEXT_REPEAT")) ~= 0 and InCombatLockdown() and (not repeatedText or not strfind(userInput, repeatedText, 1, true)) then
            local MIN_REPEAT_CHARACTERS = tonumber(GetSetting("CHAT_INCOMBAT_TEXT_REPEAT"))
            if strlen(userInput) > MIN_REPEAT_CHARACTERS then
                local repeatChar = true
                for i = 1, MIN_REPEAT_CHARACTERS, 1 do
                    local first = -1 - i
                    if strsub(userInput, -i, -i) ~= strsub(userInput, first, first) then
                        repeatChar = false
                        break
                    end
                end
                if repeatChar then
                    repeatedText = userInput
                    self:Hide()
                    return
                end
            end
        end

        if repeatedText then
            repeatedText = nil
        end
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
    frame.button.tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/maximize_button")

    frame.button:SetScript("OnMouseUp", function()
        if not GW2_UICopyChatFrame:IsShown() then
            local copyLines = {}
            local _, fontSize = FCF_GetChatWindowInfo(frame:GetID())
            if fontSize < 10 then fontSize = 12 end
            FCF_SetChatWindowFontSize(frame, frame, 0.01)
            GW2_UICopyChatFrame:Show()
            local lineCt = getLines(frame, copyLines)
            local text = table.concat(copyLines, " \n", 1, lineCt)
            FCF_SetChatWindowFontSize(frame, frame, fontSize)
            GW2_UICopyChatFrame.editBox:SetText(text)
            wipe(copyLines)
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

    --emote bar button
    if GetSetting("CHAT_KEYWORDS_EMOJI") and (id ~= 2 and id ~= 3) then
        frame.buttonEmote = CreateFrame("Frame", nil, frame)
        frame.buttonEmote:EnableMouse(true)
        frame.buttonEmote:SetAlpha(0.35)
        frame.buttonEmote:SetSize(12, 12)
        frame.buttonEmote:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -5)
        frame.buttonEmote:SetFrameLevel(frame:GetFrameLevel() + 5)

        frame.buttonEmote.tex = frame.buttonEmote:CreateTexture(nil, "OVERLAY")
        frame.buttonEmote.tex:SetAllPoints()
        frame.buttonEmote.tex:SetTexture("Interface/AddOns/GW2_UI/textures/emoji/Smile")
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
            frame.buttonEmote.tex:SetTexture("Interface/AddOns/GW2_UI/textures/emoji/OpenMouth")
            frame.buttonEmote.tex:SetDesaturated(false)
            frame.buttonEmote.tex:SetAlpha(1)
        end)

        frame.buttonEmote:SetScript("OnLeave", function()
            GameTooltip:Hide()
            frame.buttonEmote.tex:SetTexture("Interface/AddOns/GW2_UI/textures/emoji/Smile")
            frame.buttonEmote.tex:SetDesaturated(true)
            frame.buttonEmote.tex:SetAlpha(.45)
        end)
    end

    frame.styled = true
end

local function BuildCopyChatFrame()
    local frame = CreateFrame("Frame", "GW2_UICopyChatFrame", UIParent)

    tinsert(UISpecialFrames, "GW2_UICopyChatFrame")

    frame.bg = frame:CreateTexture(nil, "ARTWORK")
    frame.bg:SetAllPoints()
    frame.bg:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatframebackground")

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

local function BuildEmoticonTableFrame()
    if not GetSetting("CHAT_KEYWORDS_EMOJI") then return end

    local frame = CreateFrame("Frame", "GW_EmoteFrame", UIParent)
    frame:CreateBackdrop(GW.skins.constBackdropFrame, true, 4, 4)
    frame:SetWidth(160)
    frame:SetHeight(134)
    frame:SetPoint("BOTTOMLEFT", QuickJoinToastButton, "TOPLEFT", 0, 5)
    frame:Hide()
    frame:SetFrameStrata("DIALOG")
    tinsert(UISpecialFrames, "GW_EmoteFrame")

    local icon, row, col, i = nil, 1, 1, 1
    local isIn, alreadyIn = {}, false
    for text, texture in pairs(SmileysForMenu) do
        alreadyIn = false
        for _, v in pairs(isIn) do
            if v.tex == texture then
                alreadyIn = true
                break
            end
        end
        if not alreadyIn then
            icon = CreateFrame("Frame", format("IconButton%d", i), frame)
            icon:SetSize(24, 24)
            icon.text = text
            icon.texture = icon:CreateTexture(nil, "ARTWORK")
            icon.texture:SetTexture(texture:gsub("|T", ""):gsub(":16:16|t", ""))
            icon.texture:SetAllPoints(icon)
            icon:Show()
            icon:SetPoint("TOPLEFT", (col - 1) * 26 + 2, -(row - 1) * 26 - 2)
            icon:SetScript("OnMouseUp",function(self, button)
                if button == "LeftButton" then
                    local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
                    if not ChatFrameEditBox:IsShown() then
                        ChatEdit_ActivateChat(ChatFrameEditBox)
                    end
                    ChatFrameEditBox:Insert(self.text)
                end
                if not GW_EmoteFrame:IsShown() then
                    GW_EmoteFrame:Show()
                else
                    GW_EmoteFrame:Hide()
                end
            end)
            icon:SetScript("OnEnter", function(self)
                self:SetSize(28, 28)
                local point, anchorFrame, anchorPoint, x, y = self:GetPoint()
                self:ClearAllPoints()
                self:SetPoint(point, anchorFrame, anchorPoint, x - 2, y + 2)
                self.texture:SetBlendMode("ADD")
            end)
            icon:SetScript("OnLeave", function(self)
                self:SetSize(24, 24)
                local point, anchorFrame, anchorPoint, x, y = self:GetPoint()
                self:ClearAllPoints()
                self:SetPoint(point, anchorFrame, anchorPoint, x + 2, y - 2)
                self.texture:SetBlendMode("BLEND")
            end)
            icon:EnableMouse(true)
            col = col + 1
            if col > 6 then
                row = row + 1
                col = 1
            end
            i = i + 1
            tinsert(isIn, {tex = texture})
        end
    end
end

local function AddSmiley(key, texture, showAtMenu)
    if key and (type(key) == "string" and not strfind(key, ":%%", 1, true)) and texture then
        Smileys[key] = texture
        if showAtMenu then
            SmileysForMenu[key] = texture
        end
    end
end

local function SetupSmileys()
    if next(Smileys) then
        wipe(Smileys)
    end
    if next(SmileysForMenu) then
        wipe(SmileysForMenu)
    end
    -- new keys
    AddSmiley(":angry:", "|TInterface/AddOns/GW2_UI/textures/emoji/Angry:16:16|t", true)
    AddSmiley(":blush:", "|TInterface/AddOns/GW2_UI/textures/emoji/Blush:16:16|t", true)
    AddSmiley(":broken_heart:", "|TInterface/AddOns/GW2_UI/textures/emoji/BrokenHeart:16:16|t", true)
    AddSmiley(":call_me:", "|TInterface/AddOns/GW2_UI/textures/emoji/CallMe:16:16|t", true)
    AddSmiley(":cry:", "|TInterface/AddOns/GW2_UI/textures/emoji/Cry:16:16|t", true)
    AddSmiley(":grin:", "|TInterface/AddOns/GW2_UI/textures/emoji/Grin:16:16|t", true)
    AddSmiley(":heart:", "|TInterface/AddOns/GW2_UI/textures/emoji/Heart:16:16|t", true)
    AddSmiley(":heart_eyes:", "|TInterface/AddOns/GW2_UI/textures/emoji/HeartEyes:16:16|t", true)
    AddSmiley(":joy:", "|TInterface/AddOns/GW2_UI/textures/emoji/Joy:16:16|t", true)
    AddSmiley(":middle_finger:", "|TInterface/AddOns/GW2_UI/textures/emoji/MiddleFinger:16:16|t", true)
    AddSmiley(":ok_hand:", "|TInterface/AddOns/GW2_UI/textures/emoji/OkHand:16:16|t", true)
    AddSmiley(":open_mouth:", "|TInterface/AddOns/GW2_UI/textures/emoji/OpenMouth:16:16|t", true)
    AddSmiley(":poop:", "|TInterface/AddOns/GW2_UI/textures/emoji/Poop:16:16|t", true)
    AddSmiley(":rage:", "|TInterface/AddOns/GW2_UI/textures/emoji/Rage:16:16|t", true)
    AddSmiley(":scream:", "|TInterface/AddOns/GW2_UI/textures/emoji/Scream:16:16|t", true)
    AddSmiley(":scream_cat:", "|TInterface/AddOns/GW2_UI/textures/emoji/ScreamCat:16:16|t", true)
    AddSmiley(":slight_frown:", "|TInterface/AddOns/GW2_UI/textures/emoji/SlightFrown:16:16|t", true)
    AddSmiley(":smile:", "|TInterface/AddOns/GW2_UI/textures/emoji/Smile:16:16|t", true)
    AddSmiley(":smirk:", "|TInterface/AddOns/GW2_UI/textures/emoji/Smirk:16:16|t", true)
    AddSmiley(":sob:", "|TInterface/AddOns/GW2_UI/textures/emoji/Sob:16:16|t", true)
    AddSmiley(":sunglasses:", "|TInterface/AddOns/GW2_UI/textures/emoji/Sunglasses:16:16|t", true)
    AddSmiley(":thinking:", "|TInterface/AddOns/GW2_UI/textures/emoji/Thinking:16:16|t", true)
    AddSmiley(":thumbs_up:", "|TInterface/AddOns/GW2_UI/textures/emoji/ThumbsUp:16:16|t", true)
    AddSmiley(":wink:", "|TInterface/AddOns/GW2_UI/textures/emoji/Wink:16:16|t", true)
    AddSmiley(":zzz:", "|TInterface/AddOns/GW2_UI/textures/emoji/ZZZ:16:16|t", true)
    AddSmiley(":stuck_out_tongue:", "|TInterface/AddOns/GW2_UI/textures/emoji/StuckOutTongue:16:16|t", true)
    AddSmiley(":stuck_out_tongue_closed_eyes:", "|TInterface/AddOns/GW2_UI/textures/emoji/StuckOutTongueClosedEyes:16:16|t", true)

    AddSmiley(",,!,,", "|TInterface/AddOns/GW2_UI/textures/emoji/MiddleFinger:16:16|t")
    AddSmiley(":%-@", "|TInterface/AddOns/GW2_UI/textures/emoji/Angry:16:16|t")
    AddSmiley(":@", "|TInterface/AddOns/GW2_UI/textures/emoji/Angry:16:16|t")
    AddSmiley(":%-%)", "|TInterface/AddOns/GW2_UI/textures/emoji/Smile:16:16|t")
    AddSmiley(":%)", "|TInterface/AddOns/GW2_UI/textures/emoji/Smile:16:16|t")
    AddSmiley(":D", "|TInterface/AddOns/GW2_UI/textures/emoji/Grin:16:16|t")
    AddSmiley(":%-D", "|TInterface/AddOns/GW2_UI/textures/emoji/Grin:16:16|t")
    AddSmiley(";%-D", "|TInterface/AddOns/GW2_UI/textures/emoji/Grin:16:16|t")
    AddSmiley(";D", "|TInterface/AddOns/GW2_UI/textures/emoji/Grin:16:16|t")
    AddSmiley("=D", "|TInterface/AddOns/GW2_UI/textures/emoji/Grin:16:16|t")
    AddSmiley("xD", "|TInterface/AddOns/GW2_UI/textures/emoji/Grin:16:16|t")
    AddSmiley("XD", "|TInterface/AddOns/GW2_UI/textures/emoji/Grin:16:16|t")
    AddSmiley(":%-%(", "|TInterface/AddOns/GW2_UI/textures/emoji/SlightFrown:16:16|t")
    AddSmiley(":%(", "|TInterface/AddOns/GW2_UI/textures/emoji/SlightFrown:16:16|t")
    AddSmiley(":o", "|TInterface/AddOns/GW2_UI/textures/emoji/OpenMouth:16:16|t")
    AddSmiley(":%-o", "|TInterface/AddOns/GW2_UI/textures/emoji/OpenMouth:16:16|t")
    AddSmiley(":%-O", "|TInterface/AddOns/GW2_UI/textures/emoji/OpenMouth:16:16|t")
    AddSmiley(":O", "|TInterface/AddOns/GW2_UI/textures/emoji/OpenMouth:16:16|t")
    AddSmiley(":%-0", "|TInterface/AddOns/GW2_UI/textures/emoji/OpenMouth:16:16|t")
    AddSmiley(":P", "|TInterface/AddOns/GW2_UI/textures/emoji/StuckOutTongue:16:16|t")
    AddSmiley(":%-P", "|TInterface/AddOns/GW2_UI/textures/emoji/StuckOutTongue:16:16|t")
    AddSmiley(":p", "|TInterface/AddOns/GW2_UI/textures/emoji/StuckOutTongue:16:16|t")
    AddSmiley(":%-p", "|TInterface/AddOns/GW2_UI/textures/emoji/StuckOutTongue:16:16|t")
    AddSmiley("=P", "|TInterface/AddOns/GW2_UI/textures/emoji/StuckOutTongue:16:16|t")
    AddSmiley("=p", "|TInterface/AddOns/GW2_UI/textures/emoji/StuckOutTongue:16:16|t")
    AddSmiley(";%-p", "|TInterface/AddOns/GW2_UI/textures/emoji/StuckOutTongueClosedEyes:16:16|t")
    AddSmiley(";p", "|TInterface/AddOns/GW2_UI/textures/emoji/StuckOutTongueClosedEyes:16:16|t")
    AddSmiley(";P", "|TInterface/AddOns/GW2_UI/textures/emoji/StuckOutTongueClosedEyes:16:16|t")
    AddSmiley(";%-P", "|TInterface/AddOns/GW2_UI/textures/emoji/StuckOutTongueClosedEyes:16:16|t")
    AddSmiley(";%-%)", "|TInterface/AddOns/GW2_UI/textures/emoji/Wink:16:16|t")
    AddSmiley(";%)", "|TInterface/AddOns/GW2_UI/textures/emoji/Wink:16:16|t")
    AddSmiley(":S", "|TInterface/AddOns/GW2_UI/textures/emoji/Smirk:16:16|t")
    AddSmiley(":%-S", "|TInterface/AddOns/GW2_UI/textures/emoji/Smirk:16:16|t")
    AddSmiley(":,%(", "|TInterface/AddOns/GW2_UI/textures/emoji/Cry:16:16|t")
    AddSmiley(":,%-%(", "|TInterface/AddOns/GW2_UI/textures/emoji/Cry:16:16|t")
    AddSmiley(":\"%(", "|TInterface/AddOns/GW2_UI/textures/emoji/Cry:16:16|t")
    AddSmiley(":\"%-%(", "|TInterface/AddOns/GW2_UI/textures/emoji/Cry:16:16|t")
    AddSmiley(":F", "|TInterface/AddOns/GW2_UI/textures/emoji/MiddleFinger:16:16|t")
    AddSmiley("<3", "|TInterface/AddOns/GW2_UI/textures/emoji/Heart:16:16|t")
    AddSmiley("</3", "|TInterface/AddOns/GW2_UI/textures/emoji/BrokenHeart:16:16|t")
end

local function SocialQueueIsLeader(playerName, leaderName)
    if leaderName == playerName then
        return true
    end

    for i = 1, BNGetNumFriends() do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        if accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline then
            local numGameAccounts = C_BattleNet.GetFriendNumGameAccounts(i)
            if numGameAccounts then
                for y = 1, numGameAccounts do
                    local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(i, y)
                    if gameAccountInfo and (gameAccountInfo.clientProgram == BNET_CLIENT_WOW) and (accountInfo.accountName == playerName) then
                        playerName = gameAccountInfo.characterName
                        if gameAccountInfo.realmName and gameAccountInfo.realmName ~= GW.myrealm then
                            playerName = format("%s-%s", playerName, gsub(gameAccountInfo.realmName, "[%s%-]", ""))
                        end
                        if leaderName == playerName then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

local function RecentSocialQueue(currentTime, msg)
    local previousMessage = false
    if next(socialQueueCache) then
        for guid, tbl in pairs(socialQueueCache) do
            if currentTime and (difftime(currentTime, tbl[1]) >= 180) then
                socialQueueCache[guid] = nil
            elseif msg and (msg == tbl[2]) then
                previousMessage = true
            end
        end
    end
    return previousMessage
end

local function SocialQueueMessage(guid, message)
    if not (guid and message) then return end

    local currentTime = time()
    if RecentSocialQueue(currentTime, message) then return end
    socialQueueCache[guid] = {currentTime, message}

    PlaySound(SOUNDKIT.UI_71_SOCIAL_QUEUEING_TOAST)

    DEFAULT_CHAT_FRAME:AddMessage(strjoin("",  GW.Gw2Color, "GW2 UI:|r ", format("|Hsqu:%s|h%s|h", guid, strtrim(message))))
end

local function SocialQueueEvent(...)
    if not GetSetting("CHAT_SOCIAL_LINK") then return end
    local guid = select(1, ...)
    local numAddedItems = select(2, ...)
    if numAddedItems == 0 or not guid then return end

    local players = C_SocialQueue.GetGroupMembers(guid)
    if not players then return end

    local firstMember, numMembers, extraCount, coloredName = players[1], #players, "", ""
    local playerName, nameColor = SocialQueueUtil_GetRelationshipInfo(firstMember.guid, nil, firstMember.clubId)
    if numMembers > 1 then
        extraCount = format(" +%s", numMembers - 1)
    end
    if playerName and playerName ~= "" then
        coloredName = format("%s%s|r%s", nameColor, playerName, extraCount)
    else
        coloredName = format("{%s%s}", UNKNOWN, extraCount)
    end

    local queues = C_SocialQueue.GetGroupQueues(guid)
    local firstQueue = queues and queues[1]
    local isLFGList = firstQueue and firstQueue.queueData and firstQueue.queueData.queueType == "lfglist"

    if isLFGList and firstQueue and firstQueue.eligible then
        local activityID, name, leaderName, activitiyInfoTable, isLeader

        if firstQueue.queueData.lfgListID then
            local searchResultInfo = C_LFGList.GetSearchResultInfo(firstQueue.queueData.lfgListID)
            if searchResultInfo then
                activityID, name, leaderName = searchResultInfo.activityID, searchResultInfo.name, searchResultInfo.leaderName
                isLeader = SocialQueueIsLeader(playerName, leaderName)
            end
        end

        if activityID or firstQueue.queueData.activityID then
            activityInfo = C_LFGList.GetActivityInfoTable(activityID or firstQueue.queueData.activityID)
        end

        if name then
            SocialQueueMessage(guid, format("%s %s: |cffFFFF00[%s: %s]|r", coloredName, (isLeader and L["is looking for members"]) or L["joined a group"], (activityInfo and activityInfo.fullName) or UNKNOWN, name))
        else
            SocialQueueMessage(guid, format("%s %s: |cffFFFF00[%s]|r", coloredName, (isLeader and L["is looking for members"]) or L["joined a group"], (activityInfo and activityInfo.fullName) or UNKNOWN))
        end
    elseif firstQueue then
        local output, outputCount, queueCount = "", "", 0
        for _, queue in pairs(queues) do
            if type(queue) == "table" and queue.eligible then
                local queueName = (queue.queueData and SocialQueueUtil_GetQueueName(queue.queueData)) or ""
                if queueName ~= "" then
                    if output == "" then
                        output = gsub(queueName, "\n.+","")
                        queueCount = queueCount + select(2, gsub(queueName, "\n",""))
                    else
                        queueCount = queueCount + 1 + select(2, gsub(queueName, "\n",""))
                    end
                end
            end
        end
        if output ~= "" then
            if queueCount > 0 then outputCount = format(LFG_LIST_AND_MORE, queueCount) end
            SocialQueueMessage(guid, format("%s %s: |cffFFFF00[%s %s]|r", coloredName, gsub(SOCIAL_QUEUE_QUEUED_FOR, ":%s?$", ""), output, outputCount))
        end
    end
end

local ignoreChats = {[2] = "Log", [3] = "Voice"}
local function LoadChat()
    local shouldFading = GetSetting("CHATFRAME_FADE")
    local eventFrame = CreateFrame("Frame")

    if QuickJoinToastButton then
        QuickJoinToastButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/icons/LFDMicroButton-Down")
        QuickJoinToastButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/icons/LFDMicroButton-Down")
        QuickJoinToastButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/icons/LFDMicroButton-Down")
        QuickJoinToastButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/icons/LFDMicroButton-Down")
        QuickJoinToastButton:SetSize(25, 25)
        QuickJoinToastButton:ClearAllPoints()
        QuickJoinToastButton:SetPoint("RIGHT", GeneralDockManager, "LEFT", -6, -3)
        QuickJoinToastButton.FriendsButton:StripTextures(true)
        QuickJoinToastButton.QueueButton:StripTextures(true)
        QuickJoinToastButton.FriendCount:SetTextColor(0, 0, 0)
        QuickJoinToastButton.FriendCount:SetShadowOffset(1, 1)
        QuickJoinToastButton.QueueCount:SetTextColor(0, 0, 0)
        QuickJoinToastButton.QueueCount:SetShadowOffset(1, 1)

        if GetSetting("CHAT_SOCIAL_LINK") then
            QuickJoinToastButton.Toast:Kill()
            QuickJoinToastButton.Toast2:Kill()
        end

        QuickJoinToastButton.ClearAllPoints = GW.NoOp
        QuickJoinToastButton.SetPoint = GW.NoOp
    end

    for i = 1, FCF_GetNumActiveChatFrames() do
        local frame = _G["ChatFrame" .. i]
        -- possible fix for chatframe floating max error
        frame.oldAlpha = frame.oldAlpha and frame.oldAlpha or DEFAULT_CHATFRAME_ALPHA
        styleChatWindow(frame)
        FCFTab_UpdateAlpha(frame)
        frame:SetTimeVisible(100)
        frame:SetFading(shouldFading)
        frame:SetMaxLines(2500)

        local allowHooks = not ignoreChats[frame:GetID()]
        if allowHooks and not frame.OldAddMessage then
            --Don"t add timestamps to combat log, they don"t work.
            --This usually taints, but LibChatAnims should make sure it doesn"t.
            if GetSetting("CHAT_ADD_TIMESTAMP_TO_ALL") then
                frame.OldAddMessage = frame.AddMessage
                frame.AddMessage = AddMessage
            end
        end

        if not frame.scriptsSet then
            if allowHooks then
                frame:SetScript("OnEvent", FloatingChatFrameOnEvent)
            end

            frame.scriptsSet = true
        end
    end

    hooksecurefunc("FCF_SetTemporaryWindowType", function(chatFrame)
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

    ToggleHyperlink(GetSetting("CHAT_HYPERLINK_TOOLTIP"))
    UpdateChatKeywords()
    SetupSmileys()

    hooksecurefunc("FCF_Close", function(frame)
        if frame.Container then
            frame.Container:Hide()
        end
    end)

    hooksecurefunc("FCF_MinimizeFrame", function(chatFrame)
        if chatFrame.minimized then
            if chatFrame.Container then chatFrame.Container:SetAlpha(0) end
            if not chatFrame.minFrame.minimiizeStyled then
                chatFrame.minFrame:StripTextures(true)
                chatFrame.minFrame:CreateBackdrop(GW.skins.constBackdropFrame)
                _G[chatFrame.minFrame:GetName() .. "MaximizeButton"]:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/maximize_button")
                _G[chatFrame.minFrame:GetName() .. "MaximizeButton"]:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/maximize_button")
                _G[chatFrame.minFrame:GetName() .. "MaximizeButton"]:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/maximize_button")
                _G[chatFrame.minFrame:GetName() .. "MaximizeButton"]:SetSize(20, 20)
                chatFrame.minFrame.minimiizeStyled = true
            end
        end
    end)

    hooksecurefunc("FCFTab_OnDragStop", function(self)
        local frame = _G["ChatFrame" .. self:GetID()]
        local name = frame:GetName()
        local editbox = _G[name.."EditBox"]
        local id = frame:GetID()
        local _, _, _, _, _, _, _, _, isDocked = GetChatWindowInfo(id)

        FCFTab_UpdateAlpha(frame)
        frame:SetTimeVisible(100)
        frame:SetFading(shouldFading)
        if not frame.hasContainer and (isDocked == 1 or isDocked == nil) then
            local fmGCC = CreateFrame("FRAME", nil, UIParent, "GwChatContainer")
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
        function(self)
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

    for _, event in pairs(FindURL_Events) do
        ChatFrame_AddMessageEventFilter(event, HandleChatMessageFilter)
        local nType = strsub(event, 10)
        if nType ~= "AFK" and nType ~= "DND" and nType ~= "COMMUNITIES_CHANNEL" then
            eventFrame:RegisterEvent(event)
        end
    end

    for i = 1, FCF_GetNumActiveChatFrames() do
        if _G["ChatFrame" .. i] then
            FCF_FadeOutChatFrame(_G["ChatFrame" .. i])
        end
    end
    FCF_FadeOutChatFrame(ChatFrame1)

    for _, frameName in pairs(CHAT_FRAMES) do
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


    CombatLogQuickButtonFrame_CustomProgressBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")

    CombatLogQuickButtonFrame_CustomTexture:Hide()
    BuildCopyChatFrame()
    BuildEmoticonTableFrame()

    -- events for functions
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("SOCIAL_QUEUE_UPDATE")
    eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
            if not GetSetting("CHAT_SHOW_LFG_ICONS") or not IsInGroup() then return end
            wipe(lfgRoles)

            local playerRole = UnitGroupRolesAssigned("player")
            if playerRole then
                lfgRoles[PLAYER_NAME] = rolePaths[playerRole]
            end

            local unit = (IsInRaid() and "raid" or "party")
            for i = 1, GetNumGroupMembers() do
                if UnitExists(unit .. i) and not UnitIsUnit(unit .. i, "player") then
                    local role = UnitGroupRolesAssigned(unit .. i)
                    local name, realm = UnitName(unit .. i)

                    if role and name then
                        name = (realm and realm ~= "" and name .. "-" .. realm) or name .. "-" .. PLAYER_REALM
                        lfgRoles[name] = rolePaths[role]
                    end
                end
            end
        elseif event == "SOCIAL_QUEUE_UPDATE" then
            SocialQueueEvent(...)
        elseif tonumber(GetSetting("CHAT_SPAM_INTERVAL_TIMER")) ~= 0 and (event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" or event == "CHAT_MSG_CHANNEL") then
            local message, author = ...
            local when = time()
            ChatThrottleHandler(author, message, when)
        end
    end)
end
GW.LoadChat = LoadChat
