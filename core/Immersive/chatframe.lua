local _, GW = ...
local L = GW.L

GW.ChatFunctions = {}

local GetMentorChannelStatus = ChatFrameUtil and ChatFrameUtil.GetMentorChannelStatus or ChatFrame_GetMentorChannelStatus
local Chat_GetChatCategory = ChatFrameUtil and ChatFrameUtil.GetChatCategory or Chat_GetChatCategory
local ChatEdit_ActivateChat = ChatFrameUtil and ChatFrameUtil.ActivateChat or ChatEdit_ActivateChat
local ChatEdit_ChooseBoxForSend = ChatFrameUtil and ChatFrameUtil.ChooseBoxForSend or ChatEdit_ChooseBoxForSend
local ChatEdit_SetLastTellTarget = ChatFrameUtil and ChatFrameUtil.SetLastTellTarget or ChatEdit_SetLastTellTarget
local ChatFrame_AddMessageEventFilter = ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter or ChatFrame_AddMessageEventFilter
local GetClientTexture = BNet_GetClientEmbeddedAtlas or BNet_GetClientEmbeddedTexture
local GetMobileEmbeddedTexture = (ChatFrameUtil and ChatFrameUtil.GetMobileEmbeddedTexture) or ChatFrame_GetMobileEmbeddedTexture
local ResolvePrefixedChannelName = (ChatFrameUtil and ChatFrameUtil.ResolvePrefixedChannelName) or ChatFrame_ResolvePrefixedChannelName

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
    "Tab"
}

local historyTypes = {
    CHAT_MSG_WHISPER			= "WHISPER",
    CHAT_MSG_WHISPER_INFORM		= "WHISPER",
    CHAT_MSG_BN_WHISPER			= "WHISPER",
    CHAT_MSG_BN_WHISPER_INFORM	= "WHISPER",
    CHAT_MSG_GUILD				= "GUILD",
    CHAT_MSG_GUILD_ACHIEVEMENT	= "GUILD",
    CHAT_MSG_PARTY			= "PARTY",
    CHAT_MSG_PARTY_LEADER	= "PARTY",
    CHAT_MSG_RAID			= "RAID",
    CHAT_MSG_RAID_LEADER	= "RAID",
    CHAT_MSG_RAID_WARNING	= "RAID",
    CHAT_MSG_INSTANCE_CHAT			= "INSTANCE",
    CHAT_MSG_INSTANCE_CHAT_LEADER	= "INSTANCE",
    CHAT_MSG_CHANNEL		= "CHANNEL",
    CHAT_MSG_SAY			= "SAY",
    CHAT_MSG_YELL			= "YELL",
    CHAT_MSG_OFFICER		= "OFFICER",
    CHAT_MSG_EMOTE			= "EMOTE"
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
local ignoreChats = {[2] = "Log", [3] = "Voice"}
local copyLines = {}

local SoundTimer

local PLAYER_REALM = gsub(GW.myrealm , "[%s%-]", "")
local PLAYER_NAME = format("%s-%s", GW.myname, PLAYER_REALM)

local tabTexs = {
    "",
    "Selected",
    "Active",
    "Highlight"
}

local rolePaths = {
    TANK = "|TInterface/AddOns/GW2_UI/Textures/party/roleicon-tank.png:12:12:0:0:64:64:2:56:2:56|t ",
    HEALER = "|TInterface/AddOns/GW2_UI/Textures/party/roleicon-healer.png:12:12:0:0:64:64:2:56:2:56|t ",
    DAMAGER = "|TInterface/AddOns/GW2_UI/Textures/party/roleicon-dps.png:15:15:-2:0:64:64:2:56:2:56|t"
}

local gw_fade_frames = {
    QuickJoinToastButton,
    GeneralDockManager,
    ChatFrameChannelButton,
    ChatFrameToggleVoiceDeafenButton,
    ChatFrameToggleVoiceMuteButton
}

local gw2StaffIcon = "|TInterface/AddOns/GW2_UI/Textures/chat/dev_label.png:14:14|t"
local gw2StaffList = {
    -- Glow
    ["Zâmarâ-Antonidas"] = gw2StaffIcon,
    ["Sàphy-Antonidas"] = gw2StaffIcon,
    ["Shâdowfall-Antonidas"] = gw2StaffIcon,
    ["Winglord-Antonidas"] = gw2StaffIcon,
    ["Zâmârâ-Antonidas"] = gw2StaffIcon,
    ["Mâgus-Aegwynn"] = gw2StaffIcon,
    ["Flôffi-Aegwynn"] = gw2StaffIcon,
    -- SHOODOX
    ["Blish-Thrall"] = gw2StaffIcon,
    ["Blish-Arthas"] = gw2StaffIcon,
    ["Hildegunde-ArgentDawn"] = gw2StaffIcon,
    ["Notburga-ArgentDawn"] = gw2StaffIcon,
    ["Aderna-Arthas"] = gw2StaffIcon,
    ["Wan-Malfurion"] = gw2StaffIcon,
    ["Funda-Malfurion"] = gw2StaffIcon,
    ["Glühdirne-Arthas"] = gw2StaffIcon,
    ["Ticksick-Arthas"] = gw2StaffIcon,
    ["Meep-Arthas"] = gw2StaffIcon,
    ["Hiniche-Arthas"] = gw2StaffIcon,
    ["Trodar-Madmortem"] = gw2StaffIcon,
    ["Lætitia-ArgentDawn"] = gw2StaffIcon,
    ["Fuyubara-ArgentDawn"] = gw2StaffIcon,
    ["Blish-Proudmoore"] = gw2StaffIcon,
    ["Notburga-Proudmoore"] = gw2StaffIcon,
    ["Sisi-Proudmoore"] = gw2StaffIcon,
    --Belazor
    ["Ilyxiana-Ravencrest"] = gw2StaffIcon,
}

local chatModuleInit = false

do
    local accessIndex = 1
    local accessInfo = {}	-- keyed by token
    local accessType = {}	-- indexed
    local accessTarget = {}	-- indexed
    local accessSender = {}	-- indexed

    local function GetToken(chatType, chatTarget, chanSender) -- ChatHistory_GetToken
        local target = chatTarget and strlower(chatTarget) or ""
        local sender = GW.NotSecretValue(chanSender) and chanSender and strlower(chanSender) or ""

        return format("%s;;%s;;%s", strlower(chatType), target, sender)
    end

    function GW.ChatFunctions:GetAccessID(chatType, chatTarget, chanSender) -- ChatHistory_GetAccessID
        local token = GetToken(chatType, chatTarget, chanSender)
        if not accessInfo[token] then
            accessInfo[token] = accessIndex

            accessType[accessIndex] = chatType
            accessTarget[accessIndex] = chatTarget
            accessSender[accessIndex] = chanSender

            accessIndex = accessIndex + 1
        end

        return accessInfo[token]
    end

    function GW.ChatFunctions:GetAccessType(accessID) -- ChatHistory_GetChatType
        return accessType[accessID], accessTarget[accessID], accessSender[accessID]
    end

    function GW.ChatFunctions:GetAllAccessIDsByChanSender(chanSender) -- ChatHistory_GetAllAccessIDsByChanSender
        local senders = {}

        for accessID, sender in next, accessSender do
            if strlower(sender) == strlower(chanSender) then
                senders[#senders + 1] = accessID
            end
        end

        return senders
    end
end

local function GW_GetPlayerInfoByGUID(guid)
    if GW.IsSecretValue(guid) then return end

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

    if data then data.classColor = GW.GWGetClassColor(data.englishClass, true, true, true) end

    return data
end

function GW.ChatFunctions:GetColoredName(event, _, arg2, _, _, _, _, _, arg8, _, _, _, arg12)
    if not arg2 then return end -- guild deaths is called here with no arg2

    if GW.IsSecretValue(arg2) then
        return arg2
    end

    local chatType = strsub(event, 10)
    local subType = strsub(chatType, 1, 7)
    if subType == "WHISPER" then
        chatType = "WHISPER"
    elseif subType == "CHANNEL" then
        chatType = "CHANNEL" .. arg8
    end

    -- ambiguate guild chat names
    local name = Ambiguate(arg2, (chatType == "GUILD" and "guild") or "none")

    -- handle the class color
    local ShouldColorChatByClass = _G.ChatFrameUtil and _G.ChatFrameUtil.ShouldColorChatByClass or _G.Chat_ShouldColorChatByClass
    local info = name and arg12 and _G.ChatTypeInfo[chatType]
    if info and ShouldColorChatByClass(info) then
        local data = GW_GetPlayerInfoByGUID(arg12)
        local color = data and data.classColor
        if color then
            return format("|cff%.2x%.2x%.2x%s|r", color.r * 255, color.g * 255, color.b * 255, name)
        end
    end

    return name
end

do
    local function GetLink(linkType, displayText, ...)
        local text = ""
        for i, value in next, { ... } do
            text = text .. (i == 1 and format("|H%s:", linkType) or ":") .. value
        end

        return text .. (displayText and format("|h%s|h", displayText) or "|h")
    end

    function GW.ChatFunctions:GetPlayerLink(characterName, displayText, lineID, chatType, chatTarget)
        if lineID or chatType or chatTarget then
            return GetLink(LinkTypes.Player, displayText, characterName, lineID or 0, chatType or 0, GW.NotSecretValue(chatTarget) and chatTarget or "")
        else
            return GetLink(LinkTypes.Player, displayText, characterName)
        end
    end

    function GW.ChatFunctions:GetBNPlayerLink(name, displayText, bnetIDAccount, lineID, chatType, chatTarget)
        return GetLink(LinkTypes.BNPlayer, displayText, name, bnetIDAccount, lineID or 0, chatType, chatTarget)
    end
end

local function colorizeLine(text, r, g, b)
    local hexCode = GW.RGBToHex(r, g, b)
    return format("%s%s|r", hexCode, text)
end

local canChangeMessage = function(arg1, id)
    if id and arg1 == "" then return id end
end

function GW.ChatFunctions:IsMessageProtected(message)
    if GW.IsSecretValue(message) then return true end

    return message and (message ~= gsub(message, "(:?|?)|K(.-)|k", canChangeMessage))
end

local removeIconFromLine
do
    local raidIconFunc = function(x)
        x = x ~= "" and _G["RAID_TARGET_" .. x]
        return x and ("{" .. strlower(x) .. "}") or ""
    end
    local stripTextureFunc = function(w, x, y)
        if x == "" then
            return (w ~= "" and w) or (y ~= "" and y) or ""
        end
    end
    local hyperLinkFunc = function(w, x, y)
        if w ~= "" then return end
        local emoji = (x~="" and x) and strmatch(x, "gwuimoji:%%(.+)")
        return (emoji and GW.Libs.Deflate:DecodeForPrint(emoji)) or y
    end
    local fourString = function(v, w, x, y)
        return format("%s%s%s", v, w, (v and v == "1" and x) or y)
    end

    removeIconFromLine = function(text)
        text = gsub(text, [[|TInterface\TargetingFrame\UI%-RaidTargetingIcon_(%d+):0|t]], raidIconFunc) --converts raid icons into {star} etc, if possible.
        text = gsub(text, "(%s?)(|?)|[TA].-|[ta](%s?)", stripTextureFunc) --strip any other texture out but keep a single space from the side(s).
        text = gsub(text, "(|?)|H(.-)|h(.-)|h", hyperLinkFunc) --strip hyperlink data only keeping the actual text.
        text = gsub(text, "(%d+)(.-)|4(.-):(.-);", fourString) --stuff where it goes "day" or "days" like played; tech this is wrong but okayish
        return text
    end
end

local function getLines(frame)
    local index = 1
    local maxMessages, frameMessages = tonumber(GW.settings.CHAT_MAX_COPY_CHAT_LINES), frame:GetNumMessages()
    local startLine = frameMessages <= maxMessages and 1 or frameMessages + 1 - maxMessages

    for i = startLine, frameMessages do
        local message, r, g, b = frame:GetMessageInfo(i)
        if message and not GW.ChatFunctions:IsMessageProtected(message) then
            r, g, b = r or 1, g or 1, b or 1
            message = removeIconFromLine(message)
            message = colorizeLine(message, r, g, b)
            copyLines[index] = message
            index = index + 1
        end
    end

    return index - 1
end

local function ShowCopyChatFrame(frame)
    if not GW2_UICopyChatFrame:IsShown() then
        local count = getLines(frame)
        local text = table.concat(copyLines, " \n", 1, count)
        GW2_UICopyChatFrameEditBox:SetText(text)
        GW2_UICopyChatFrame:Show()
    else
        GW2_UICopyChatFrameEditBox:SetText("")
        GW2_UICopyChatFrame:Hide()
    end
end

local function CopyButtonOnMouseUp(self, btn)
    local chat = self:GetParent()
    if btn == "RightButton" and chat:GetID() == 1 then
        local menu = ChatMenu
        if menu then
            menu:ClearAllPoints()

            local point = GW.GetScreenQuadrant(self)
            if strfind(point, "LEFT") then
                menu:SetPoint("BOTTOMLEFT", self, "TOPRIGHT")
            else
                menu:SetPoint("BOTTOMRIGHT", self, "TOPLEFT")
            end

            ToggleFrame(menu)
        else
            ChatFrameMenuButton:OpenMenu()
        end
    else
        ShowCopyChatFrame(chat)
    end
end

local function setButtonPosition(frame)
    local name = frame:GetName()
    local editbox = _G[name .. "EditBox"]

    if frame.buttonSide == "right" then
        frame.Container:ClearAllPoints()
        frame.Container:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 5)
        local anchorFrame = not GW.Retail and _G[name .. "EditBoxRight"] or _G[name .. "EditBoxFocusRight"]
        if not frame.isDocked then
            frame.Container:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMRIGHT", 5, editbox:GetHeight() - 0)
        else
            frame.Container:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMRIGHT", 5, 0)
        end

        editbox:ClearAllPoints()
        editbox:SetPoint("TOPLEFT", frame.Background, "BOTTOMLEFT", 0, 0)
        editbox:SetPoint("TOPRIGHT", _G[name .. "ButtonFrame"], "BOTTOMRIGHT", 0, 0)

        if QuickJoinToastButton and frame.isDocked ~= nil then
            QuickJoinToastButton.ClearAllPoints = nil
            QuickJoinToastButton.SetPoint = nil
            QuickJoinToastButton:ClearAllPoints()
            QuickJoinToastButton:SetPoint("LEFT", GeneralDockManager, "RIGHT", 30, 4)

            QuickJoinToastButton.ClearAllPoints = GW.NoOp
            QuickJoinToastButton.SetPoint = GW.NoOp
        end
    else
        frame.Container:ClearAllPoints()
        frame.Container:SetPoint("TOPLEFT", frame, "TOPLEFT", -35, 5)
        local anchorFrame = not GW.Retail and _G[name .. "EditBoxRight"] or _G[name .. "EditBoxFocusRight"]
        if not frame.isDocked then
            frame.Container:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMRIGHT", 5, editbox:GetHeight() - 8)
        else
            frame.Container:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMRIGHT", 5, 0)
        end

        editbox:ClearAllPoints()
        editbox:SetPoint("TOPLEFT", _G[name .. "ButtonFrame"], "BOTTOMLEFT", 0, -6)
        editbox:SetPoint("TOPRIGHT", frame.Background, "BOTTOMRIGHT", 0, -6)

        if QuickJoinToastButton and frame.isDocked ~= nil then
            QuickJoinToastButton.ClearAllPoints = nil
            QuickJoinToastButton.SetPoint = nil
            QuickJoinToastButton:ClearAllPoints()
            QuickJoinToastButton:SetPoint("RIGHT", GeneralDockManager, "LEFT", -6, 4)

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

local function handleChatFrameFadeIn(chatFrame, force)
    if not GW.settings.CHATFRAME_FADE and not force then
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

    if chatFrame.copyButton then
        UIFrameFadeIn(chatFrame.copyButton, 0.5, chatFrame.copyButton:GetAlpha(), 0.35)
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

local function handleChatFrameFadeOut(chatFrame, force)
    if not GW.settings.CHATFRAME_FADE and not force then
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
        if chatFrame.Container then
            UIFrameFadeOut(ChatFrame1.Container, 2, ChatFrame1.Container:GetAlpha(), chatAlpha)
        end
    elseif chatFrame.isDocked == nil then
        if chatFrame.Container then
            UIFrameFadeOut(chatFrame.Container, 2, chatFrame.Container:GetAlpha(), chatAlpha)
        end
    end

    if chatFrame.copyButton then
        UIFrameFadeOut(chatFrame.copyButton, 2, chatFrame.copyButton:GetAlpha(), 0)
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

local function HyperLinkedURL(data)
    if strsub(data, 1, 3) == "url" then
        local currentLink = strsub(data, 5)
        if currentLink and currentLink ~= "" then
            SetChatEditBoxMessage(currentLink)
        end
    end
end

local function HyperLinkedSQU(data)
    if strsub(data, 1, 3) == "squ" then
        if GW.settings.USE_SOCIAL_WINDOW then
            if InCombatLockdown() then return end
            GwSocialWindow:SetAttribute("windowpanelopen", "quicklist")
        else
            if not QuickJoinFrame:IsShown() then
                ToggleQuickJoinPanel()
            end
        end

        local guid = strsub(data, 5)
        if guid and guid ~= "" then
            QuickJoinFrame:SelectGroup(guid)
            QuickJoinFrame:ScrollToGroup(guid)
        end
    end
end

local function HyperLinkedCPL(data)
    local chatID = strsub(data, 5)
    local chat = _G[format("ChatFrame%d", chatID)]
    if not chat then return end

    local cursorX, cursorY = GetCursorPosition()
    local scale = chat:GetEffectiveScale() --blizzard does this with `scale = UIParent:GetScale()`
    local posX, posY = (cursorX / scale), (cursorY / scale)

    local _, index = chat:FindCharacterAndLineIndexAtCoordinate(posX, posY)
    if not index then return end

    local line = chat.visibleLines and chat.visibleLines[index]
    local msg = line and line.messageInfo and line.messageInfo.message
    if msg and not GW.ChatFunctions:IsMessageProtected(msg) then
        msg = gsub(msg,"|c(%x-)|H(.-)|h(.-)|h|r","\10c%1\10H%2\10h%3\10h\10r") -- strip colors and trim but not hyperlinks
        msg = gsub(msg,"||","\11") -- for printing item lines from /dump, etc
        msg = GW.StripString(removeIconFromLine(msg))
        msg = gsub(msg,"\11","||")
        msg = gsub(msg,"\10c(%x-)\10H(.-)\10h(.-)\10h\10r","|c%1|H%2|h%3|h|r")

        if msg ~= "" then
            SetChatEditBoxMessage(msg)
        end
    end
end

do
    local funcs = {
        cpl = HyperLinkedCPL,
        squ = HyperLinkedSQU,
        url = HyperLinkedURL
    }

    local SetHyperlink = _G.ItemRefTooltip.SetHyperlink
    function _G.ItemRefTooltip:SetHyperlink(data, ...)
        if strsub(data, 1, 6) ~= "gwtime" then
            local func = funcs[strsub(data, 1, 3)]
            if func then
                func(data)
            else
                SetHyperlink(self, data, ...)
            end
        end
    end
end

local hyperLinkEntered
local function OnHyperlinkEnter(self, refString)
    if InCombatLockdown() or not GW.settings.CHAT_HYPERLINK_TOOLTIP then return end
    local linkToken = strmatch(refString, "^([^:]+)")
    if hyperlinkTypes[linkToken] then
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(refString)
        GameTooltip:Show()
        hyperLinkEntered = self
    end
end

local function OnHyperlinkLeave()
    if not GW.settings.CHAT_HYPERLINK_TOOLTIP then return end
    if hyperLinkEntered then
        hyperLinkEntered = nil
        GameTooltip:Hide()
    end
end

local function OnMouseWheel(frame)
    if not GW.settings.CHAT_HYPERLINK_TOOLTIP then return end
    if hyperLinkEntered == frame then
        hyperLinkEntered = false
        GameTooltip:Hide()
    end
end

local function SetupHyperlink()
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

    local keywords = GW.settings.CHAT_KEYWORDS
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
    local letSound = not SoundTimer and author ~= PLAYER_NAME and GW.settings.CHAT_KEYWORDS_ALERT_NEW ~= "None"

    for hyperLink in gmatch(message, "|c%x-|H.-|h.-|h|r") do
        protectLinks[hyperLink] = gsub(hyperLink,"%s","|s")

        if letSound then
            for keyword in pairs(Keywords) do
                if hyperLink == keyword then
                    SoundTimer = C_Timer.NewTimer(5, function() SoundTimer = nil end)
                    PlaySoundFile(GW.Libs.LSM:Fetch("sound", GW.settings.CHAT_KEYWORDS_ALERT_NEW), "Master")
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
                    local keywordColor = GW.private.CHAT_KEYWORDS_ALERT_COLOR
                    word = gsub(word, tempWord, format("%s%s|r", GW.RGBToHex(keywordColor.r, keywordColor.g, keywordColor.b), tempWord))

                    if letSound then
                        SoundTimer = C_Timer.NewTimer(5, function() SoundTimer = nil end)
                        PlaySoundFile(GW.Libs.LSM:Fetch("sound", GW.settings.CHAT_KEYWORDS_ALERT_NEW), "Master")
                        letSound = false
                    end
                end
            end

            if GW.settings.CHAT_CLASS_COLOR_MENTIONS then
                tempWord = gsub(word, "^[%s%p]-([^%s%p]+)([%-]?[^%s%p]-)[%s%p]*$", "%1%2")
                lowerCaseWord = strlower(tempWord)
                local classMatch = ClassNames[lowerCaseWord]
                local wordMatch = classMatch and lowerCaseWord

                if wordMatch then
                    local classColorTable = GW.GWGetClassColor(classMatch, true, true, true)
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
            local encode = GW.Libs.Deflate:EncodeForPrint(word)
            msg = gsub(msg, "([%s%p]-)" .. pattern .. "([%s%p]*)", (encode and ("%1|Hgwuimoji:%%" .. encode .. "|h|cFFffffff|r|h") or "%1") .. emoji .. "%2")
        end
    end

    return msg
end

local function GetSmileyReplacementText(msg)
    if not msg or not GW.settings.CHAT_KEYWORDS_EMOJI or strfind(msg, "/run") or strfind(msg, "/dump") or strfind(msg, "/script") then return msg end
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

local function ReplaceProtocol(self, arg1, arg2)
    local str = self .. "://" .. arg1
    return (self == "Houtfit") and str .. arg2 or PrintURL(str)
end

local function FindURL(msg, author, ...)
    if not GW.settings.CHAT_FIND_URL then -- find url setting here
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
    local newMsg, found = gsub(text, "(%a+)://(%S+)(%s?)", ReplaceProtocol)
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
    if GW.IsSecretValue(author) or GW.IsSecretValue(message) then return end

    if author and author ~= "" and message and message ~= "" then
        return strupper(author) .. message
    end
end

local function ChatThrottleHandler(author, message, when)
    local msg = PrepareMessage(author, message)
    if msg then
        for savedMessage, object in pairs(throttle) do
            if difftime(when, object.time) >= GW.settings.CHAT_SPAM_INTERVAL_TIMER then
                throttle[savedMessage] = nil
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
    local msg = (author ~= PLAYER_NAME) and GW.settings.CHAT_SPAM_INTERVAL_TIMER ~= 0 and PrepareMessage(author, message)

    local object = msg and throttle[msg]

    return object and object.time and object.count and object.count > 1 and (difftime(when, object.time) <= GW.settings.CHAT_SPAM_INTERVAL_TIMER), object
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

local function GetBNFirstToonClassColor(id)
    if not id then return end
    for i = 1, BNGetNumFriends() do
        local info = C_BattleNet.GetFriendAccountInfo(i)
        if info and info.bnetAccountID == id then
            for y = 1, C_BattleNet.GetFriendNumGameAccounts(i) do
                local gameInfo = C_BattleNet.GetFriendGameAccountInfo(i, y)
                if gameInfo and gameInfo.clientProgram == BNET_CLIENT_WOW and gameInfo.className and gameInfo.className ~= "" then
                    return gameInfo.className
                end
            end

            break
        end
    end
end

local function GetBNFriendColor(name, id, useBTag)
    local info = C_BattleNet.GetAccountInfoByID(id)
    local BNET_TAG = info and info.isBattleTagFriend and info.battleTag and strmatch(info.battleTag, "([^#]+)")
    local TAG = useBTag and BNET_TAG

    local Class
    local gameInfo = info and info.gameAccountID and C_BattleNet.GetGameAccountInfoByID(info.gameAccountID)
    if gameInfo and gameInfo.className then
        Class = GW.UnlocalizedClassName(gameInfo.className)
    else
        local firstToonClass = GetBNFirstToonClassColor(id)
        if firstToonClass then
            Class = GW.UnlocalizedClassName(firstToonClass)
        else
            return TAG or name, BNET_TAG
        end
    end

    local Color = Class and GW.GWGetClassColor(Class, true, true, true)
    return (Color and format("|c%s%s|r", Color.colorStr, TAG or name)) or TAG or name, BNET_TAG
end
GW.GetBNFriendColor = GetBNFriendColor

-- chat histroy
local function DisplayChatHistory()
    local data = GW.private.ChatHistoryLog
    if not (data and next(data)) then return end

    if not GW_GetPlayerInfoByGUID(GW.myguid) then
        GW.Wait(0.1, DisplayChatHistory)
        return
    end

    SoundTimer = true -- ignore sounds

    for _, chat in ipairs(CHAT_FRAMES) do
        for _, d in ipairs(data) do
            if type(d) == "table" then
                for _, messageType in pairs(_G[chat].messageTypeList) do
                    local historyType, skip = historyTypes[d[50]]
                    if historyType then -- let others go by..
                        if not GW.settings.showHistory[historyType] then skip = true end
                    end
                    if not skip and gsub(strsub(d[50],10),"_INFORM","") == messageType then
                        if d[1] and not GW.ChatFunctions:IsMessageProtected(d[1]) then
                            GW.ChatFrame_MessageEventHandler(_G[chat],d[50],d[1],d[2],d[3],d[4],d[5],d[6],d[7],d[8],d[9],d[10],d[11],d[12],d[13],d[14],d[15],d[16],d[17],"GW2UI_ChatHistory",d[51],d[52],d[53])
                        end
                    end
                end
            end
        end
    end

    SoundTimer = nil
end

tremove(ChatTypeGroup.GUILD, 2)
local function DelayGuildMOTD()
    local delay, checks, delayFrame, chat = 0, 0, CreateFrame("Frame")
    tinsert(ChatTypeGroup.GUILD, 2, "GUILD_MOTD")
    delayFrame:SetScript("OnUpdate", function(self, elapsed)
        delay = delay + elapsed
        if delay < 5 then return end
        local msg = GetGuildRosterMOTD()
        if msg and strlen(msg) > 0 then
            for _, frame in ipairs(CHAT_FRAMES) do
                chat = _G[frame]
                if chat and chat:IsEventRegistered("CHAT_MSG_GUILD") then
                    GW.ChatFrame_SystemEventHandler(chat, "GUILD_MOTD", msg)
                    chat:RegisterEvent("GUILD_MOTD")
                end
            end
            self:SetScript("OnUpdate", nil)
        else -- 5 seconds sometimes to fast, limit to 5 checks
            delay, checks = 0, checks + 1
            if checks >= 5 then
                self:SetScript("OnUpdate", nil)
            end
        end
    end)
end
local function SaveChatHistory(event, ...)
    local historyType = historyTypes[event]
    if historyType then
        if not GW.settings.showHistory[historyType] then return end
    end

    if GW.settings.CHAT_SPAM_INTERVAL_TIMER ~= 0 and (event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" or event == "CHAT_MSG_CHANNEL") then
        local message, author = ...
        local when = time()

        if GW.NotSecretValue(message) or GW.NotSecretValue(author) then
            ChatThrottleHandler(author, message, when)

            if ChatThrottleBlockFlag(author, message, when) then
                return
            end
        end
    end

    if not GW.settings.chatHistory then return end
    local data = GW.private.ChatHistoryLog
    if not data then return end

    local tempHistory = {}
    for i = 1, select("#", ...) do
        if GW.NotSecretValue(select(i, ...) ) then
            tempHistory[i] = select(i, ...) or false
        end
    end

    if #tempHistory > 0 and not GW.ChatFunctions:IsMessageProtected(tempHistory[1]) then
        tempHistory[50] = event
        tempHistory[51] = time()

        local coloredName, battleTag
        if tempHistory[13] and tempHistory[13] > 0 then coloredName, battleTag = GetBNFriendColor(tempHistory[2], tempHistory[13], true) end
        if battleTag then tempHistory[53] = battleTag end -- store the battletag, only when the person is known by battletag, so we can replace arg2 later in the function
        tempHistory[52] = coloredName or GW.ChatFunctions:GetColoredName(event, ...)

        tinsert(data, tempHistory)
        while #data >= GW.settings.historySize do
            tremove(data, 1)
        end
    end
end

local function ChatFrame_CheckAddChannel(chatFrame, eventType, channelID)
    -- This is called in the event that a user receives chat events for a channel that isn't enabled for any chat frames.
    -- Minor hack, because chat channel filtering is backed by the client, but driven entirely from Lua.
    -- This solves the issue of Guides abdicating their status, and then re-applying in the same game session, unless ChatFrame_AddChannel
    -- is called, the channel filter will be off even though it's still enabled in the client, since abdication removes the chat channel and its config.

    -- Only add to default (since multiple chat frames receive the event and we don't want to add to others)
    if chatFrame ~= DEFAULT_CHAT_FRAME then
        return false;
    end

    -- Only add if the user is joining a channel
    if eventType ~= "YOU_CHANGED" then
        return false;
    end

    -- Only add regional channels
    if GW.Retail then
        if not C_ChatInfo.IsChannelRegionalForChannelID(channelID) then
            return false;
        end
    end

    local channelName = C_ChatInfo.GetChannelShortcutForChannelID(channelID)
    if not channelName then
        return false
    end
    local AddChannel = chatFrame.AddChannel or ChatFrame_AddChannel
    return AddChannel(chatFrame, C_ChatInfo.GetChannelShortcutForChannelID(channelID)) ~= nil
end

local function AddMessageEdits(frame, msg, alwaysAddTimestamp, isHistory, historyTime)
    local isProtected = GW.ChatFunctions:IsMessageProtected(msg)
    if isProtected or (not isProtected and (strmatch(msg, "^%s*$") or strmatch(msg, "^|Hgwtime|h") or strmatch(msg, "^|Hcpl:"))) then
        return msg
    end

    local historyTimestamp
    if isHistory == "GW2UI_ChatHistory" then historyTimestamp = historyTime end

    if GW.settings.timeStampFormat and GW.settings.timeStampFormat ~= "NONE" and (GW.settings.CHAT_ADD_TIMESTAMP_TO_ALL or alwaysAddTimestamp) then
        local timeStamp = BetterDate(GW.settings.timeStampFormat, historyTimestamp or time())
        timeStamp = gsub(timeStamp, " ", "")
        timeStamp = gsub(timeStamp, "AM", " AM")
        timeStamp = gsub(timeStamp, "PM", " PM")

        if GW.settings.CHAT_USE_GW2_STYLE then
            msg = format("|Hgwtime|h|c%s[%s]|r|h %s", "FF888888", timeStamp, msg)
        else
            msg = format("|Hgwtime|h[%s]|h %s", timeStamp, msg)
        end
    end

    -- color channel in light grey
    if GW.settings.CHAT_USE_GW2_STYLE then
        -- color channel in light grey
        msg = msg:gsub(" |Hchannel:(.-)|h%[(.-)%]|h", function(channelLink, channelTag)
            return string.format("|Hchannel:%s|h|c%s[%s]|r|h", channelLink, "FFD0D0D0", channelTag)
        end)

        -- remove square brackets from message name in chat
        msg = msg:gsub("|h%[(|c(.-)|r)%]|h: ", function(coloredPlayer)
            return string.format("|h%s|h: ", coloredPlayer)
        end)
    end

    if GW.settings.copyChatLines then
        msg = format("|Hcpl:%s|h%s|h %s", frame:GetID(), format("|T%s:14|t", "Interface/AddOns/GW2_UI/textures/uistuff/arrow_right.png"), msg)
    end

    return msg
end

local function AddMessage(self, msg, infoR, infoG, infoB, infoID, accessID, typeID, event, eventArgs, msgFormatter, isHistory, historyTime)
    local body = AddMessageEdits(self, msg, nil, isHistory, historyTime)
    self.OldAddMessage(self, body, infoR, infoG, infoB, infoID, accessID, typeID, event, eventArgs, msgFormatter)
end

-- copied from ChatFrame.lua
local function GetPFlag(specialFlag, zoneChannelID, unitGUID)
    local flag = ""
    if specialFlag ~= "" then
        if specialFlag == "GM" or specialFlag == "DEV" then
            -- Add Blizzard Icon if this was sent by a GM/DEV
            flag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t "
        elseif specialFlag == "GUIDE" then
            if GetMentorChannelStatus(Enum.PlayerMentorshipStatus.Mentor, C_ChatInfo.GetChannelRulesetForChannelID(zoneChannelID)) == Enum.PlayerMentorshipStatus.Mentor then
                flag = gsub(NPEV2_CHAT_USER_TAG_GUIDE, "(|A.-|a).+", "%1") .. " "
            end
        elseif specialFlag == "NEWCOMER" then
            if GetMentorChannelStatus(Enum.PlayerMentorshipStatus.Newcomer, C_ChatInfo.GetChannelRulesetForChannelID(zoneChannelID)) == Enum.PlayerMentorshipStatus.Newcomer then
                flag = NPEV2_CHAT_USER_TAG_NEWCOMER
            end
        else
            flag = _G["CHAT_FLAG_" .. specialFlag]
        end
    end

    if GW.Retail and unitGUID and GW.NotSecretValue(unitGUID) then
        if C_ChatInfo.IsTimerunningPlayer(unitGUID) then
            flag = flag .. format("|A:timerunning-glues-icon-small:%s:%s:0:0|a ", 12, 10)
        end

        if C_RecentAllies.IsRecentAllyByGUID(unitGUID) then
            flag = flag .. format("|A:friendslist-recentallies-yellow:%s:%s:0:0|a ", 11, 11)
        end
    end

    return flag
end

--Copied from FrameXML ChatFrame.lua and modified to add CUSTOM_CLASS_COLORS
local seenGroups = {}
local function ChatFrame_ReplaceIconAndGroupExpressions(message, noIconReplacement, noGroupReplacement)
    wipe(seenGroups)

    local ICON_LIST, ICON_TAG_LIST, GROUP_TAG_LIST = _G.ICON_LIST, _G.ICON_TAG_LIST, _G.GROUP_TAG_LIST
    for tag in gmatch(message, "%b{}") do
        local term = strlower(gsub(tag, "[{}]", ""))
        if not noIconReplacement and ICON_TAG_LIST[term] and ICON_LIST[ICON_TAG_LIST[term]] then
            message = gsub(message, tag, ICON_LIST[ICON_TAG_LIST[term]] .. "0|t")
        elseif not noGroupReplacement and GROUP_TAG_LIST[term] then
            local groupIndex = GROUP_TAG_LIST[term]
            if not seenGroups[groupIndex] then
                seenGroups[groupIndex] = true
                local groupList = "["
                for i = 1, GetNumGroupMembers() do
                    local name, _, subgroup, _, _, classFileName = GetRaidRosterInfo(i)
                    if name and subgroup == groupIndex then
                        local classColorTable = GW.GWGetClassColor(classFileName, true, true)
                        if classColorTable then
                            name = format("|cff%.2x%.2x%.2x%s|r", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, name)
                        end
                        groupList = groupList..(groupList == "[" and "" or _G.PLAYER_LIST_DELIMITER)..name
                    end
                end
                if groupList ~= "[" then
                    groupList = groupList.."]"
                    message = gsub(message, tag, groupList, 1)
                end
            end
        end
    end

    return message
end

-- Clone of FCFManager_GetChatTarget as it doesn't exist on Classic ERA
local function FCFManager_GetChatTarget(chatGroup, playerTarget, channelTarget)
    local chatTarget
    if chatGroup == "CHANNEL" then
        chatTarget = tostring(channelTarget)
    elseif chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" then
        chatTarget = GW.NotSecretValue(playerTarget) and strsub(playerTarget, 1, 2) ~= "|K" and strupper(playerTarget) or playerTarget
    end

    return chatTarget
end

local function ShortChannel(self)
    return format("|Hchannel:%s|h[%s]|h", self, DEFAULT_STRINGS[strupper(self)] or gsub(self, "channel:", ""))
end
GW.ShortChannel = ShortChannel

-- Clone from ChatFrame.xml with changes
local function FlashTabIfNotShown(frame, info, chatType, chatGroup, chatTarget)
    if frame:IsShown() then return end

    local allowAlerts = ((frame ~= DEFAULT_CHAT_FRAME and info.flashTab) or (frame == DEFAULT_CHAT_FRAME and info.flashTabOnGeneral)) and ((chatType == "WHISPER" or chatType == "BN_WHISPER") or (CHAT_OPTIONS and not CHAT_OPTIONS.HIDE_FRAME_ALERTS))
    if allowAlerts and not FCFManager_ShouldSuppressMessageFlash(frame, chatGroup, chatTarget) then
        FCF_StartAlertFlash(frame)
    end
end

local function MessageFormatter(frame, info, chatType, chatGroup, chatTarget, channelLength, coloredName, historySavedName, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, isHistory, historyTime, historyName, historyBTag)
    local body

    if chatType == "WHISPER_INFORM" and GMChatFrame_IsGM and GMChatFrame_IsGM(arg2) then
        return
    end

    local showLink = true
    local isProtected = GW.ChatFunctions:IsMessageProtected(arg1)
    local bossMonster = strsub(chatType, 1, 9) == "RAID_BOSS" or strsub(chatType, 1, 7) == "MONSTER"
    if bossMonster then
        showLink = false
        -- fix blizzard formatting errors from localization strings
        if not isProtected then
            arg1 = gsub(arg1, "(%d%s?%%)([^%%%a])", "%1%%%2") -- escape percentages that need it [broken since SL?]
            arg1 = gsub(arg1, "(%d%s?%%)$", "%1%%") -- escape percentages on the end
            arg1 = gsub(arg1, "^%%o", "%%s") -- replace %o to %s [broken in cata classic?]: "%o gular zila amanare rukadare." from "Cabal Zealot"
        end
    elseif not isProtected then
        arg1 = gsub(arg1, "%%", "%%%%") -- escape any % characters, as it may otherwise cause an 'invalid option in format' error
    end

    --Remove groups of many spaces
    if not isProtected then
        arg1 = RemoveExtraSpaces(arg1)

        -- Search for icon links and replace them with texture links.
        -- If arg17 is true, don't convert to raid icons
        if ChatFrameUtil and ChatFrameUtil.CanChatGroupPerformExpressionExpansion then
			arg1 = ChatFrame_ReplaceIconAndGroupExpressions(arg1, arg17, not ChatFrameUtil.CanChatGroupPerformExpressionExpansion(chatGroup))
		else
			arg1 = ChatFrame_ReplaceIconAndGroupExpressions(arg1, arg17, not ChatFrame_CanChatGroupPerformExpressionExpansion(chatGroup))
        end
    end

    -- Get class colored name for BattleNet friend
    if chatType == "BN_WHISPER" or chatType == "BN_WHISPER_INFORM" then
        coloredName = historySavedName or GetBNFriendColor(arg2, arg13)
    end

    local nameWithRealm, realm
    local data = GW_GetPlayerInfoByGUID(arg12)
    if data then
        realm = data.realm
        nameWithRealm = data.nameWithRealm
    end

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
    local playerName, lineID, bnetIDAccount = (nameWithRealm ~= arg2 and nameWithRealm) or arg2, arg11, arg13
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
    elseif chatType == "BN_WHISPER" or chatType == "BN_WHISPER_INFORM" then
        playerLink = GW.ChatFunctions:GetBNPlayerLink(playerName, playerLinkDisplayText, bnetIDAccount, lineID, chatGroup, chatTarget)
    else
        playerLink = GW.ChatFunctions:GetPlayerLink(playerName, playerLinkDisplayText, lineID, chatGroup, chatTarget)
    end

    local isMobile = arg14 and GetMobileEmbeddedTexture(info.r, info.g, info.b)
    local message = format("%s%s", isMobile or "", arg1)

    -- Player Flags
    local pflag = GetPFlag(arg6, arg7, arg12)
    if not bossMonster and GW.NotSecretValue(arg12) and GW.NotSecretValue(playerName) then
        local lfgRole = (chatType == "PARTY_LEADER" or chatType == "PARTY" or chatType == "RAID" or chatType == "RAID_LEADER" or chatType == "INSTANCE_CHAT" or chatType == "INSTANCE_CHAT_LEADER") and lfgRoles[playerName]
        if lfgRole then
            pflag = pflag .. lfgRole
        end

        local gw2Icon = gw2StaffList[playerName]
        if gw2Icon then
            pflag = pflag .. gw2Icon
        end
    end

    local senderLink = showLink and playerLink or arg2
    if usingDifferentLanguage then
    body = format(_G["CHAT_" .. chatType .. "_GET"] .. "[%s] %s", pflag .. senderLink, arg3, message)
    elseif not isProtected and chatType == "GUILD_ITEM_LOOTED" then
        body = gsub(message, "$s", senderLink, 1)
    elseif not isProtected and realm and chatType == "TEXT_EMOTE" then
        local classLink = playerLink and (info.colorNameByClass and gsub(playerLink, "(|h|c.-)|r|h$","%1-"..realm.."|r|h") or gsub(playerLink, "(|h.-)|h$","%1-"..realm.."|h"))
        body = classLink and gsub(message, arg2.."%-"..realm, pflag..classLink, 1) or message
    elseif chatType == "TEXT_EMOTE" then
        body = (GW.NotSecretValue(arg2) and arg2 ~= senderLink) and gsub(message, arg2, senderLink, 1) or message
    elseif not showLink then
        body = format(_G["CHAT_"..chatType.."_GET"]..message, pflag..senderLink)
    else
        body = format(_G["CHAT_"..chatType.."_GET"]..message, pflag..senderLink)
    end

    -- Add Channel
    if channelLength > 0 then
        body = "|Hchannel:channel:" .. arg8 .. "|h[" .. ResolvePrefixedChannelName(arg4) .. "]|h " .. body
    end

    if not isProtected and GW.settings.CHAT_SHORT_CHANNEL_NAMES and (chatType ~= "EMOTE" and chatType ~= "TEXT_EMOTE") then
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

    return body
end

local function ChatFrame_MessageEventHandler(frame, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, isHistory, historyTime, historyName, historyBTag)
    local notChatHistory, historySavedName
    if isHistory == "GW2UI_ChatHistory" then
        if historyBTag then arg2 = historyBTag end -- swap arg2 (which is a |k string) to btag name
        historySavedName = historyName
    else
        notChatHistory = true
    end

    local isProtected = GW.IsSecretValue(arg2)

    if TextToSpeechFrame_MessageEventHandler and notChatHistory then
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

        if ChatFrameUtil and ChatFrameUtil.ProcessMessageEventFilters then
            local filtered, new1, new2, new3, new4, new5, new6, new7, new8, new9, new10, new11, new12, new13, new14, new15, new16, new17 = ChatFrameUtil.ProcessMessageEventFilters(frame, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
            if filtered then
                return true
            else
                arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = new1, new2, new3, new4, new5, new6, new7, new8, new9, new10, new11, new12, new13, new14, new15, new16, new17
            end
        else
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
        end

        -- fetch the name color to use
        local coloredName = historySavedName or GW.ChatFunctions:GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)

        local channelLength = strlen(arg4)
        local infoType = chatType

        if chatType == "VOICE_TEXT" and not GetCVarBool("speechToText") then
            return
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

            if chatGroup == "SYSTEM" then
                local matchFound = false
                local message = strlower(arg1)
                for playerName in pairs(frame.privateMessageList) do
                    local playerNotFoundMsg = strlower(format(ERR_CHAT_PLAYER_NOT_FOUND_S, playerName))
                    local charOnlineMsg = strlower(format(ERR_FRIEND_ONLINE_SS, playerName, playerName))
                    local charOfflineMsg = strlower(format(ERR_FRIEND_OFFLINE_S, playerName))
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
            frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
        elseif chatType == "LOOT" then
            frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
        elseif strsub(chatType, 1, 7) == "COMBAT_" then
            frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
        elseif strsub(chatType, 1, 6) == "SPELL_" then
            frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
        elseif strsub(chatType, 1, 10) == "BG_SYSTEM_" then
            frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
        elseif strsub(chatType, 1, 11) == "ACHIEVEMENT" then
            -- Append [Share] hyperlink
            frame:AddMessage(format(arg1, GW.ChatFunctions:GetPlayerLink(arg2, format("[%s]", coloredName))), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
        elseif strsub(chatType, 1, 18) == "GUILD_ACHIEVEMENT" then
            frame:AddMessage(format(arg1, GW.ChatFunctions:GetPlayerLink(arg2, format("[%s]", coloredName))), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
        elseif chatType == "PING" then
            frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
        elseif chatType == "IGNORED" then
            frame:AddMessage(format(CHAT_IGNORED, arg2), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
        elseif chatType == "FILTERED" then
            frame:AddMessage(format(CHAT_FILTERED, arg2), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
        elseif chatType == "RESTRICTED" then
            frame:AddMessage(CHAT_RESTRICTED_TRIAL, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
        elseif chatType == "CHANNEL_LIST" then
            if channelLength > 0 then
                frame:AddMessage(format(_G["CHAT_"..chatType.."_GET"]..arg1, tonumber(arg8), arg4), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
            else
                frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
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
                frame:AddMessage(format(globalstring, arg8, arg4, arg2, arg5), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
            elseif arg1 == "INVITE" then
                frame:AddMessage(format(globalstring, arg4, arg2), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
            else
                frame:AddMessage(format(globalstring, arg8, arg4, arg2), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
            end
            if arg1 == "INVITE" and GetCVarBool("blockChannelInvites") then
                frame:AddMessage(CHAT_MSG_BLOCK_CHAT_CHANNEL_INVITE, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
            end
        elseif chatType == "CHANNEL_NOTICE" then
            local accessID = GW.ChatFunctions:GetAccessID(chatGroup, arg8)
            local typeID = GW.ChatFunctions:GetAccessID(infoType, arg8, arg12)

            if GW.Retail and arg1 == "YOU_CHANGED" and C_ChatInfo.GetChannelRuleset(arg8) == Enum.ChatChannelRuleset.Mentor then
                frame:UpdateDefaultChatTarget()
                frame.editBox:UpdateNewcomerEditBoxHint()
            else
                if GW.Retail and arg1 == "YOU_LEFT" then
                    frame.editBox:UpdateNewcomerEditBoxHint(arg8)
                end

                local globalstring
                if arg1 == "TRIAL_RESTRICTED" then
                    globalstring = CHAT_TRIAL_RESTRICTED_NOTICE_TRIAL
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

                frame:AddMessage(format(globalstring, arg8, ResolvePrefixedChannelName(arg4)), info.r, info.g, info.b, info.id, accessID, typeID, nil, nil, nil, isHistory, historyTime)
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
                message = format(BN_INLINE_TOAST_FRIEND_PENDING, BNGetNumFriendInvites())
            elseif arg1 == "FRIEND_REMOVED" or arg1 == "BATTLETAG_FRIEND_REMOVED" then
                message = format(globalstring, arg2)
            elseif arg1 == "FRIEND_ONLINE" or arg1 == "FRIEND_OFFLINE" then
                local accountInfo = C_BattleNet.GetAccountInfoByID(arg13)
                local gameInfo = accountInfo and accountInfo.gameAccountInfo
                if gameInfo and gameInfo.clientProgram and gameInfo.clientProgram ~= "" then
                    if C_Texture.GetTitleIconTexture then
                            C_Texture.GetTitleIconTexture(gameInfo.clientProgram, Enum.TitleIconVersion.Small, function(success, texture)
                            if success then
                                local characterName = BNet_GetValidatedCharacterNameWithClientEmbeddedTexture(gameInfo.characterName, accountInfo.battleTag, texture, 32, 32, 10)
                                local linkDisplayText = format("[%s] (%s)", arg2, characterName)
                                local playerLink = GW.ChatFunctions:GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, chatGroup, 0)
                                frame:AddMessage(format(globalstring, playerLink), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)

                                if notChatHistory then
                                    FlashTabIfNotShown(frame, info, chatType, chatGroup, chatTarget)
                                end
                            end
                        end)

                        return
                    else
                        local clientTexture = GetClientTexture(gameInfo.clientProgram, 14)
                        local charName = BNet_GetValidatedCharacterName(gameInfo.characterName, accountInfo.battleTag, gameInfo.clientProgram) or ""
                        local linkDisplayText = format("[%s] (%s%s)", arg2, clientTexture, charName)
                        local playerLink = GW.ChatFunctions:GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, chatGroup, 0)
                        message = format(globalstring, playerLink)
                    end
                else
                    local linkDisplayText = format("[%s]", arg2)
                    local playerLink = GW.ChatFunctions:GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, chatGroup, 0)
                    message = format(globalstring, playerLink)
                end
            else
                local linkDisplayText = format("[%s]", arg2)
                local playerLink = GW.ChatFunctions:GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, chatGroup, 0)
                message = format(globalstring, playerLink)
            end
            frame:AddMessage(message, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
        elseif chatType == "BN_INLINE_TOAST_BROADCAST" then
            if arg1 ~= "" then
                arg1 = RemoveNewlines(RemoveExtraSpaces(arg1))
                local linkDisplayText = ("[%s]"):format(arg2)
                local playerLink = GW.ChatFunctions:GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, chatGroup, 0)
                frame:AddMessage(format(BN_INLINE_TOAST_BROADCAST, playerLink, arg1), info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
            end
        elseif chatType == "BN_INLINE_TOAST_BROADCAST_INFORM" then
            if arg1 ~= "" then
                frame:AddMessage(BN_INLINE_TOAST_BROADCAST_INFORM, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
            end
        else
            -- The message formatter is captured so that the original message can be reformatted when a censored message
            -- is approved to be shown. We only need to pack the event args if the line was censored, as the message transformation
            -- step is the only code that needs these arguments. See ItemRef.lua "censoredmessage".
            local isChatLineCensored, eventArgs, msgFormatter = C_ChatInfo.IsChatLineCensored(arg11) -- arg11: lineID
            if isChatLineCensored then
                eventArgs = SafePack(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
                msgFormatter = function(msg) -- to translate the message on click [Show Message]
                    local body = MessageFormatter(frame, info, chatType, chatGroup, chatTarget, channelLength, coloredName, historySavedName, msg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, isHistory, historyTime, historyName, historyBTag)
                    return AddMessageEdits(frame, body, not GW.settings.CHAT_ADD_TIMESTAMP_TO_ALL, isHistory, historyTime)
                end
            end

            local accessID = GW.ChatFunctions:GetAccessID(chatGroup, chatTarget)
            local typeID = GW.ChatFunctions:GetAccessID(infoType, chatTarget, arg12 or arg13)
            local body = isChatLineCensored and arg1 or MessageFormatter(frame, info, chatType, chatGroup, chatTarget, channelLength, coloredName, historySavedName, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, isHistory, historyTime, historyName, historyBTag)

            frame:AddMessage(body, info.r, info.g, info.b, info.id, accessID, typeID, event, eventArgs, msgFormatter, isHistory, historyTime)
        end

        if notChatHistory and (chatType == "WHISPER" or chatType == "BN_WHISPER") then
            if not isProtected then
                ChatEdit_SetLastTellTarget(arg2, chatType)
            end
            FlashClientIcon()
        end

        if notChatHistory then
            FlashTabIfNotShown(frame, info, chatType, chatGroup, chatTarget)
        end

        return true
    elseif event == "CHAT_MSG_OFFICERVOICE_CHAT_CHANNEL_TRANSCRIBING_CHANGED" then
        if not frame.isTranscribing and arg2 then
            local info = _G.ChatTypeInfo.SYSTEM
            frame:AddMessage(_G.SPEECH_TO_TEXT_STARTED, info.r, info.g, info.b, info.id, nil, nil, nil, nil, nil, isHistory, historyTime)
        end

        frame.isTranscribing = arg2
    end
end
GW.ChatFrame_MessageEventHandler = ChatFrame_MessageEventHandler

local function ChatFrame_ConfigEventHandler(...)
    local configEventhandler = _G.ChatFrameMixin and _G.ChatFrameMixin.ConfigEventHandler or _G.ChatFrame_ConfigEventHandler
    return configEventhandler(...)
end

local function ChatFrame_SystemEventHandler(...)
    local systemEventHandler = _G.ChatFrameMixin and _G.ChatFrameMixin.SystemEventHandler or _G.ChatFrame_SystemEventHandler
    return systemEventHandler(...)
end
GW.ChatFrame_SystemEventHandler = ChatFrame_SystemEventHandler

local function ChatFrame_OnEvent(frame, ...)
    if frame.customEventHandler and frame.customEventHandler(frame, ...) then return end

    if ChatFrame_ConfigEventHandler(frame, ...) then return end
    if ChatFrame_SystemEventHandler(frame, ...) then return end
    if ChatFrame_MessageEventHandler(frame, ...) then return end
end

local function FloatingChatFrameOnEvent(...)
    ChatFrame_OnEvent(...)

    if _G.FloatingChatFrame_OnEvent then
        _G.FloatingChatFrame_OnEvent(...)
    end
end

local function ChatFrame_OnMouseScroll(self, delta)
    local numScrollMessages = GW.settings.CHAT_NUM_SCROLL_MESSAGES or 3
    if delta < 0 then
        if IsShiftKeyDown() then
            self:ScrollToBottom()
        elseif IsAltKeyDown() then
            self:ScrollDown()
        else
            for _ = 1, numScrollMessages do
                self:ScrollDown()
            end
        end
    elseif delta > 0 then
        if IsShiftKeyDown() then
            self:ScrollToTop()
        elseif IsAltKeyDown() then
            self:ScrollUp()
        else
            for _ = 1, numScrollMessages do
                self:ScrollUp()
            end
        end

        if GW.settings.CHAT_SCROLL_DOWN_INTERVAL ~= 0 then
            if self.ScrollTimer then
                self.ScrollTimer:Cancel()
            end

            self.ScrollTimer = C_Timer.NewTimer(GW.settings.CHAT_SCROLL_DOWN_INTERVAL, function() self:ScrollToBottom() end)
        end
    end
end

local function ChatFrame_SetScript(self, script, func)
    if script == "OnMouseWheel" and func ~= ChatFrame_OnMouseScroll then
        self:SetScript(script, ChatFrame_OnMouseScroll)
    end
end

local function GetTab(chat)
    if not chat.tab then
        chat.tab = _G[format("ChatFrame%sTab", chat:GetID())]
    end

    return chat.tab
end
do
    local charCount
    local function CountLinkCharacters(self)
        charCount = charCount + (strlen(self) + 4) -- 4 is ending "|h|r"
    end

    local repeatedText
    local function EditBoxOnTextChanged(self)
        local userInput = self:GetText()
        local len = strlen(userInput)

        if GW.settings.CHAT_INCOMBAT_TEXT_REPEAT ~= 0 and InCombatLockdown() and (not repeatedText or not strfind(userInput, repeatedText, 1, true)) then
            local MIN_REPEAT_CHARACTERS = tonumber(GW.settings.CHAT_INCOMBAT_TEXT_REPEAT)
            if len > MIN_REPEAT_CHARACTERS then
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

        charCount = 0
        gsub(userInput, "(|c%x-|H.-|h).-|h|r", CountLinkCharacters)
        if charCount ~= 0 then len = len - charCount end

        self.characterCount:SetText(len > 0 and (255 - len) or "")

        if repeatedText then
            repeatedText = nil
        end

        if repeatedText then
            repeatedText = nil
        end
    end
    GW.ChatFrameEditBoxOnTextChanged = EditBoxOnTextChanged
end

local function styleChatWindow(frame)
    local name = frame:GetName()
    local tab = GetTab(frame)
    tab.Text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    tab.Text:SetTextColor(1, 1, 1)

    if frame.styled then return end

    frame:SetFrameLevel(4)

    local id = frame:GetID()
    local _, fontSize, _, _, _, _, _, _, isDocked = GetChatWindowInfo(id)

    local editbox = frame.editBox
    local scroll = frame.ScrollBar
    local scrollToBottom = frame.ScrollToBottomButton
    local background = _G[name .. "Background"]

    if not frame.hasContainer and (isDocked == 1 or (isDocked == nil and frame:IsShown())) then
        local fmGCC = CreateFrame("Frame", nil, UIParent, "GwChatContainer")
        fmGCC:SetScript("OnSizeChanged", chatBackgroundOnResize)
        fmGCC:SetPoint("TOPLEFT", frame, "TOPLEFT", -35, 5)

        local anchorFrame = not GW.Retail and _G[name .. "EditBoxRight"] or _G[name .. "EditBoxFocusRight"]
        if not frame.isDocked then
            fmGCC:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMRIGHT", 5, editbox:GetHeight() - 8)
        else
            fmGCC:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMRIGHT", 5, 0)
        end
        if not frame.isDocked then fmGCC.EditBox:Hide() end
        frame.Container = fmGCC
        frame.hasContainer = true
    end

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

        if (GW.Retail and texName == "Active") or (not GW.Retail and texName == "Selected") then
            if left then
                left:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chattabactiveleft.png")
                if GW.Retail then
                    left:ClearAllPoints()
                    left:SetPoint("TOPRIGHT", tab.Left, "TOPRIGHT", 0, 2)
                end
                left:SetBlendMode("BLEND")
                left:SetVertexColor(1, 1, 1, 1)
            end

            if middle then
                middle:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chattabactive.png")
                if GW.Retail then
                    middle:ClearAllPoints()
                    middle:SetPoint("LEFT", tab.Middle, "LEFT", 0, 2)
                    middle:SetPoint("RIGHT", tab.Middle, "RIGHT", 0, 2 )
                end
                middle:SetBlendMode("BLEND")
                middle:SetVertexColor(1, 1, 1, 1)
            end
            if right then
                right:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chattabactiveright.png")
                if GW.Retail then
                    right:ClearAllPoints()
                    right:SetPoint("TOPRIGHT", tab.Right, "TOPRIGHT", 0, 2)
                end
                right:SetBlendMode("BLEND")
                right:SetVertexColor(1, 1, 1, 1)
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
    if scroll then
        GW.HandleTrimScrollBar(scroll)
        GW.HandleScrollControls(frame)
    end

    if not GW.Retail then
        _G[name .. "ButtonFrameBottomButton"]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\uistuff\\arrowdown_down.png")
        _G[name .. "ButtonFrameBottomButton"]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\uistuff\\arrowdown_up.png")
        _G[name .. "ButtonFrameBottomButton"]:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\uistuff\\arrowdown_down.png")
        _G[name .. "ButtonFrameBottomButton"]:SetHeight(24)
        _G[name .. "ButtonFrameBottomButton"]:SetWidth(24)

        _G[name .. "ButtonFrameDownButton"]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\uistuff\\arrowdown_down.png")
        _G[name .. "ButtonFrameDownButton"]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\uistuff\\arrowdown_up.png")
        _G[name .. "ButtonFrameDownButton"]:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\uistuff\\arrowdown_down.png")
        _G[name .. "ButtonFrameDownButton"]:SetHeight(24)
        _G[name .. "ButtonFrameDownButton"]:SetWidth(24)

        _G[name .. "ButtonFrameUpButton"]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\uistuff\\arrowup_down.png")
        _G[name .. "ButtonFrameUpButton"]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\uistuff\\arrowup_up.png")
        _G[name .. "ButtonFrameUpButton"]:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\uistuff\\arrowup_down.png")
        _G[name .. "ButtonFrameUpButton"]:SetHeight(24)
        _G[name .. "ButtonFrameUpButton"]:SetWidth(24)
    end

    ChatFrameMenuButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/bubble_down.png")
    ChatFrameMenuButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/bubble_up.png")
    ChatFrameMenuButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/bubble_down.png")
    ChatFrameMenuButton:SetHeight(20)
    ChatFrameMenuButton:SetWidth(20)

    if frame.buttonFrame.minimizeButton then
        frame.buttonFrame.minimizeButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/minimize_button.png")
        frame.buttonFrame.minimizeButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/minimize_button.png")
        frame.buttonFrame.minimizeButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/minimize_button.png")
        frame.buttonFrame.minimizeButton:SetSize(24, 24)
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

    tab.Text:SetTextColor(1, 1, 1)
    hooksecurefunc(tab.Text, "SetTextColor", function(tt, r, g, b)
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
    frame:GwStripTextures(true)
    _G[name .. "ButtonFrame"]:Hide()

    if GW.Retail then
        local a, b, c = select(6, editbox:GetRegions())
        a:GwKill()
        b:GwKill()
        c:GwKill()
    end

    editbox:ClearAllPoints()
    editbox:SetPoint("TOPLEFT", _G[name .. "ButtonFrame"], "BOTTOMLEFT", 0, 0)
    editbox:SetPoint("TOPRIGHT", background, "BOTTOMRIGHT", 0, 0)
    editbox:SetAltArrowKeyMode(false)
    editbox.editboxHasFocus = false
    editbox:Hide()
    GW.SkinTextBox(_G[name .. "EditBoxMid"], _G[name .. "EditBoxLeft"], _G[name .. "EditBoxRight"])
    if _G[name .. "EditBoxFocusMid"] then
        GW.SkinTextBox(_G[name .. "EditBoxFocusMid"], _G[name .. "EditBoxFocusLeft"], _G[name .. "EditBoxFocusRight"])
    end

    --Character count
    local charCount = editbox:CreateFontString(nil, "ARTWORK")
    charCount:SetFont(UNIT_NAME_FONT, 11, "")
    charCount:SetTextColor(190, 190, 190, 0.4)
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
        if GW.settings.CHATFRAME_EDITBOX_HIDE then
            editBox:Hide()
        end
    end)

    editbox:HookScript("OnTextChanged", GW.ChatFrameEditBoxOnTextChanged)

    if GW.settings.CHAT_USE_GW2_STYLE then
        local chatFont = GW.Libs.LSM:Fetch("font", "GW2_UI_Chat")
        local _, fontHeight, fontFlags = frame:GetFont()
        frame:SetFont(chatFont, fontHeight or 14, fontFlags)
        editbox:SetFont(chatFont, fontHeight or 14, fontFlags)
        _G[editbox:GetName() .. "Header"]:SetFont(chatFont, fontHeight or 14, fontFlags)
    elseif GW.settings.FONT_STYLE_TEMPLATE ~= "BLIZZARD" and fontSize then
        if fontSize > 0 then
            frame:SetFont(STANDARD_TEXT_FONT, fontSize, "")
        elseif fontSize == 0 then
            frame:SetFont(STANDARD_TEXT_FONT, 14, "")
        end
    end

    if frame.hasContainer then setButtonPosition(frame) end

    --copy chat button
    frame.copyButton = CreateFrame("Frame", nil, frame)
    frame.copyButton:EnableMouse(true)
    frame.copyButton:SetAlpha(0.35)
    frame.copyButton:SetSize(20, 22)
    frame.copyButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", GW.Retail and 20 or 0, GW.Retail and 26 or 4)
    frame.copyButton:SetFrameLevel(frame:GetFrameLevel() + 5)

    frame.copyButton.tex = frame.copyButton:CreateTexture(nil, "OVERLAY")
    frame.copyButton.tex:SetAllPoints()
    frame.copyButton.tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/maximize_button.png")

    frame.copyButton:SetScript("OnMouseUp", CopyButtonOnMouseUp)

    frame.copyButton:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
    frame.copyButton:SetScript("OnLeave", function(self)
        if GetTab(self:GetParent()).Text:IsShown() then
            self:SetAlpha(0.35)
        else
            self:SetAlpha(0)
        end
    end)

    --emote bar button
    if GW.settings.CHAT_KEYWORDS_EMOJI and (id ~= 2 and id ~= 3) then
        frame.buttonEmote = CreateFrame("Frame", "BUTTON_EMOTE", frame)
        frame.buttonEmote:EnableMouse(true)
        frame.buttonEmote:SetAlpha(0.35)
        frame.buttonEmote:SetSize(12, 12)
        frame.buttonEmote:SetPoint("TOPRIGHT", frame, "TOPRIGHT", GW.Retail and 0 or -20, GW.Retail and 22 or 0)
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
            frame.buttonEmote.tex:SetAlpha(1)
        end)

        frame.buttonEmote:SetScript("OnLeave", function()
            GameTooltip:Hide()
            frame.buttonEmote.tex:SetTexture("Interface/AddOns/GW2_UI/textures/emoji/smile.png")
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
    frame.bg:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatframebackground.png")

    frame:SetSize(700, 200)
    frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 15)
    frame:Hide()
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetResizable(true)
    frame:SetResizeBounds(350, 100)
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

    local editBox = CreateFrame("EditBox", "GW2_UICopyChatFrameEditBox", frame)
    editBox:SetHeight(200)
    editBox:SetMultiLine(true)
    editBox:SetMaxLetters(99999)
    editBox:EnableMouse(true)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject("ChatFontNormal")
    if GW.settings.CHAT_USE_GW2_STYLE then
        local chatFont = GW.Libs.LSM:Fetch("font", "GW2_UI_Chat")
        local _, fonzSize = editBox:GetFont()
        editBox:SetFont(chatFont, fonzSize or 14, "")
    end
    editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    editBox:SetScript("OnTextChanged", function(_, userInput)
        if userInput then return end
        local _, maxValue = GW2_UICopyChatFrameScrollFrame.ScrollBar:GetMinMaxValues()
        for _ = 1, maxValue do
            ScrollFrameTemplate_OnMouseWheel(GW2_UICopyChatFrameScrollFrame, -1)
        end
    end)
    frame.editBox = editBox

    local scrollFrame = CreateFrame("ScrollFrame", "GW2_UICopyChatFrameScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)
    scrollFrame:SetScript("OnSizeChanged", function(_, width, height)
        GW2_UICopyChatFrameEditBox:SetSize(width, height)
    end)
    scrollFrame:HookScript("OnVerticalScroll", function(scroll, offset)
        GW2_UICopyChatFrameEditBox:SetHitRectInsets(0, 0, offset, (GW2_UICopyChatFrameEditBox:GetHeight() - offset - scroll:GetHeight()))
    end)
    frame.scrollFrame = scrollFrame

    scrollFrame:SetScrollChild(editBox)
    editBox:SetWidth(scrollFrame:GetWidth())
    scrollFrame.ScrollBar:GwSkinScrollBar()
    scrollFrame:GwSkinScrollFrame()

    frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.close:SetPoint("TOPRIGHT")
    frame.close:SetFrameLevel(frame.close:GetFrameLevel() + 1)
    frame.close:EnableMouse(true)
    frame.close:SetSize(20, 20)
    frame.close:GwSkinButton(true)
end

local function BuildEmoticonTableFrame()
    local frame = CreateFrame("Frame", "GW_EmoteFrame", UIParent)
    frame:GwCreateBackdrop(GW.BackdropTemplates.Default, true, 4, 4)
    frame:SetWidth(160)
    frame:SetHeight(134)
    frame:SetPoint("BOTTOMLEFT", GW.Retail and QuickJoinToastButton or ChatFrame1Tab, "TOPLEFT", 0, 5)
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
            icon = CreateFrame("Frame", nil, frame)
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

    if not GW.settings.CHAT_KEYWORDS_EMOJI then
        frame:Hide()
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
    AddSmiley(":angry:", "|TInterface/AddOns/GW2_UI/textures/emoji/angry.png:16:16|t", true)
    AddSmiley(":blush:", "|TInterface/AddOns/GW2_UI/textures/emoji/blush.png:16:16|t", true)
    AddSmiley(":broken_heart:", "|TInterface/AddOns/GW2_UI/textures/emoji/brokenheart.png:16:16|t", true)
    AddSmiley(":call_me:", "|TInterface/AddOns/GW2_UI/textures/emoji/callme.png:16:16|t", true)
    AddSmiley(":cry:", "|TInterface/AddOns/GW2_UI/textures/emoji/cry.png:16:16|t", true)
    AddSmiley(":grin:", "|TInterface/AddOns/GW2_UI/textures/emoji/grin.png:16:16|t", true)
    AddSmiley(":heart:", "|TInterface/AddOns/GW2_UI/textures/emoji/heart.png:16:16|t", true)
    AddSmiley(":heart_eyes:", "|TInterface/AddOns/GW2_UI/textures/emoji/hearteyes.png:16:16|t", true)
    AddSmiley(":joy:", "|TInterface/AddOns/GW2_UI/textures/emoji/joy.png:16:16|t", true)
    AddSmiley(":middle_finger:", "|TInterface/AddOns/GW2_UI/textures/emoji/middlefinger.png:16:16|t", true)
    AddSmiley(":ok_hand:", "|TInterface/AddOns/GW2_UI/textures/emoji/okhand.png:16:16|t", true)
    AddSmiley(":open_mouth:", "|TInterface/AddOns/GW2_UI/textures/emoji/openmouth.png:16:16|t", true)
    AddSmiley(":poop:", "|TInterface/AddOns/GW2_UI/textures/emoji/poop.png:16:16|t", true)
    AddSmiley(":rage:", "|TInterface/AddOns/GW2_UI/textures/emoji/rage.png:16:16|t", true)
    AddSmiley(":scream:", "|TInterface/AddOns/GW2_UI/textures/emoji/scream.png:16:16|t", true)
    AddSmiley(":scream_cat:", "|TInterface/AddOns/GW2_UI/textures/emoji/screamcat.png:16:16|t", true)
    AddSmiley(":slight_frown:", "|TInterface/AddOns/GW2_UI/textures/emoji/slightfrown.png:16:16|t", true)
    AddSmiley(":smile:", "|TInterface/AddOns/GW2_UI/textures/emoji/smile.png:16:16|t", true)
    AddSmiley(":smirk:", "|TInterface/AddOns/GW2_UI/textures/emoji/smirk.png:16:16|t", true)
    AddSmiley(":sob:", "|TInterface/AddOns/GW2_UI/textures/emoji/sob.png:16:16|t", true)
    AddSmiley(":sunglasses:", "|TInterface/AddOns/GW2_UI/textures/emoji/sunglasses.png:16:16|t", true)
    AddSmiley(":thinking:", "|TInterface/AddOns/GW2_UI/textures/emoji/thinking.png:16:16|t", true)
    AddSmiley(":thumbs_up:", "|TInterface/AddOns/GW2_UI/textures/emoji/thumbsup.png:16:16|t", true)
    AddSmiley(":wink:", "|TInterface/AddOns/GW2_UI/textures/emoji/wink.png:16:16|t", true)
    AddSmiley(":zzz:", "|TInterface/AddOns/GW2_UI/textures/emoji/zzz.png:16:16|t", true)
    AddSmiley(":stuck_out_tongue:", "|TInterface/AddOns/GW2_UI/textures/emoji/stuckouttongue.png:16:16|t", true)
    AddSmiley(":stuck_out_tongue_closed_eyes:", "|TInterface/AddOns/GW2_UI/textures/emoji/stuckouttongueclosedeyes.png:16:16|t", true)

    AddSmiley(",,!,,", "|TInterface/AddOns/GW2_UI/textures/emoji/middlefinger.png:16:16|t")
    AddSmiley(":%-@", "|TInterface/AddOns/GW2_UI/textures/emoji/angry.png:16:16|t")
    AddSmiley(":@", "|TInterface/AddOns/GW2_UI/textures/emoji/angry.png:16:16|t")
    AddSmiley(":%-%)", "|TInterface/AddOns/GW2_UI/textures/emoji/smile.png:16:16|t")
    AddSmiley(":%)", "|TInterface/AddOns/GW2_UI/textures/emoji/smile.png:16:16|t")
    AddSmiley(":D", "|TInterface/AddOns/GW2_UI/textures/emoji/grin.png:16:16|t")
    AddSmiley(":%-D", "|TInterface/AddOns/GW2_UI/textures/emoji/grin.png:16:16|t")
    AddSmiley(";%-D", "|TInterface/AddOns/GW2_UI/textures/emoji/grin.png:16:16|t")
    AddSmiley(";D", "|TInterface/AddOns/GW2_UI/textures/emoji/grin.png:16:16|t")
    AddSmiley("=D", "|TInterface/AddOns/GW2_UI/textures/emoji/grin.png:16:16|t")
    AddSmiley("xD", "|TInterface/AddOns/GW2_UI/textures/emoji/grin.png:16:16|t")
    AddSmiley("XD", "|TInterface/AddOns/GW2_UI/textures/emoji/grin.png:16:16|t")
    AddSmiley(":%-%(", "|TInterface/AddOns/GW2_UI/textures/emoji/slightfrown.png:16:16|t")
    AddSmiley(":%(", "|TInterface/AddOns/GW2_UI/textures/emoji/slightfrown.png:16:16|t")
    AddSmiley(":o", "|TInterface/AddOns/GW2_UI/textures/emoji/openmouth.png:16:16|t")
    AddSmiley(":%-o", "|TInterface/AddOns/GW2_UI/textures/emoji/openmouth.png:16:16|t")
    AddSmiley(":%-O", "|TInterface/AddOns/GW2_UI/textures/emoji/openmouth.png:16:16|t")
    AddSmiley(":O", "|TInterface/AddOns/GW2_UI/textures/emoji/openmouth.png:16:16|t")
    AddSmiley(":%-0", "|TInterface/AddOns/GW2_UI/textures/emoji/openmouth.png:16:16|t")
    AddSmiley(":P", "|TInterface/AddOns/GW2_UI/textures/emoji/stuckouttongue.png:16:16|t")
    AddSmiley(":%-P", "|TInterface/AddOns/GW2_UI/textures/emoji/stuckouttongue.png:16:16|t")
    AddSmiley(":p", "|TInterface/AddOns/GW2_UI/textures/emoji/stuckouttongue.png:16:16|t")
    AddSmiley(":%-p", "|TInterface/AddOns/GW2_UI/textures/emoji/stuckouttongue.png:16:16|t")
    AddSmiley("=P", "|TInterface/AddOns/GW2_UI/textures/emoji/stuckouttongue.png:16:16|t")
    AddSmiley("=p", "|TInterface/AddOns/GW2_UI/textures/emoji/stuckouttongue.png:16:16|t")
    AddSmiley(";%-p", "|TInterface/AddOns/GW2_UI/textures/emoji/stuckouttongueclosedeyes.png:16:16|t")
    AddSmiley(";p", "|TInterface/AddOns/GW2_UI/textures/emoji/stuckouttongueclosedeyes.png:16:16|t")
    AddSmiley(";P", "|TInterface/AddOns/GW2_UI/textures/emoji/stuckouttongueclosedeyes.png:16:16|t")
    AddSmiley(";%-P", "|TInterface/AddOns/GW2_UI/textures/emoji/stuckouttongueclosedeyes.png:16:16|t")
    AddSmiley(";%-%)", "|TInterface/AddOns/GW2_UI/textures/emoji/wink.png:16:16|t")
    AddSmiley(";%)", "|TInterface/AddOns/GW2_UI/textures/emoji/wink.png:16:16|t")
    AddSmiley(":S", "|TInterface/AddOns/GW2_UI/textures/emoji/smirk.png:16:16|t")
    AddSmiley(":%-S", "|TInterface/AddOns/GW2_UI/textures/emoji/smirk.png:16:16|t")
    AddSmiley(":,%(", "|TInterface/AddOns/GW2_UI/textures/emoji/cry.png:16:16|t")
    AddSmiley(":,%-%(", "|TInterface/AddOns/GW2_UI/textures/emoji/cry.png:16:16|t")
    AddSmiley(":\"%(", "|TInterface/AddOns/GW2_UI/textures/emoji/cry.png:16:16|t")
    AddSmiley(":\"%-%(", "|TInterface/AddOns/GW2_UI/textures/emoji/cry.png:16:16|t")
    AddSmiley(":F", "|TInterface/AddOns/GW2_UI/textures/emoji/middlefinger.png:16:16|t")
    AddSmiley("<3", "|TInterface/AddOns/GW2_UI/textures/emoji/heart.png:16:16|t")
    AddSmiley("</3", "|TInterface/AddOns/GW2_UI/textures/emoji/brokenheart.png:16:16|t")
end

local function CollectLfgRolesForChatIcons()
    if not GW.settings.CHAT_SHOW_LFG_ICONS or not IsInGroup() then return end
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
end
GW.CollectLfgRolesForChatIcons = CollectLfgRolesForChatIcons

local function SocialQueueIsLeader(playerName, leaderName)
    if leaderName == playerName then
        return true
    end

    for i = 1, BNGetNumFriends() do
        local info = C_BattleNet.GetAccountInfoByID(i)
        if info and info.accountName  then
            for y = 1, C_BattleNet.GetFriendNumGameAccounts(i) do
                local gameInfo = C_BattleNet.GetFriendGameAccountInfo(i, y)
                if gameInfo and gameInfo.clientProgram == BNET_CLIENT_WOW and info.accountName == playerName then
                    playerName = gameInfo.characterName

                    if gameInfo.realmName and gameInfo.realmName ~= GW.myrealm then
                        playerName = format("%s-%s", playerName, gsub(gameInfo.realmName, "[%s%-]", ""))
                    end

                    if leaderName == playerName then
                        return true
                    end
                end
            end
        end
    end
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

    GW.Notice(format("|Hsqu:%s|h%s|h", guid, strtrim(message)))
end

local function SocialQueueEvent(...)
    if not GW.settings.CHAT_SOCIAL_LINK then return end
    local guid = select(1, ...)
    local numAddedItems = select(2, ...)
    if numAddedItems == 0 or not guid then return end

    local players = GW.Retail and C_SocialQueue.GetGroupMembers(guid) or nil
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

    local queues = GW.Retail and C_SocialQueue.GetGroupQueues(guid) or nil
    local firstQueue = queues and queues[1]
    local isLFGList = firstQueue and firstQueue.queueData and firstQueue.queueData.queueType == "lfglist"

    if isLFGList and firstQueue and firstQueue.eligible then
        local activityID, name, leaderName, activityInfo, isLeader

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

local function UpdateSettings()
    if not chatModuleInit then return end
    for _, frameName in ipairs(CHAT_FRAMES) do
        local frame = _G[frameName]
        if frame and frame:IsShown() then
            frame:SetFading(GW.settings.CHATFRAME_FADE)
            if GW.settings.CHATFRAME_FADE then
                handleChatFrameFadeOut(frame, true)
            else
                handleChatFrameFadeIn(frame, true)
            end
        end
    end
end
GW.UpdateChatSettings = UpdateSettings

local function LoadChat()
    DelayGuildMOTD()

    if not GW.settings.CHATFRAME_ENABLED or GW.ShouldBlockIncompatibleAddon("Chat") then return end
    local eventFrame = CreateFrame("Frame")

    chatModuleInit = true

    if QuickJoinToastButton then
        QuickJoinToastButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton-highlight.png")
        QuickJoinToastButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton.png")
        QuickJoinToastButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton-highlight.png")
        QuickJoinToastButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton-highlight.png")
        QuickJoinToastButton:SetSize(25, 25)
        QuickJoinToastButton:ClearAllPoints()
        QuickJoinToastButton:SetPoint("RIGHT", GeneralDockManager, "LEFT", -6, 4)
        QuickJoinToastButton.QueueCount:GwKill()
        local _, _, fontFlags = QuickJoinToastButton.FriendCount:GetFont()
        QuickJoinToastButton.FriendCount:SetFont(_, 14, fontFlags)
        QuickJoinToastButton.FriendsButton:GwStripTextures(true)
        QuickJoinToastButton.FriendCount:SetTextColor(1, 1, 1)
        QuickJoinToastButton.FriendCount:SetShadowOffset(1, 1)
        QuickJoinToastButton.FriendCount:SetPoint("TOP", QuickJoinToastButton, "BOTTOM", 1, 1)

        if GW.settings.CHAT_SOCIAL_LINK then
            QuickJoinToastButton.Toast:GwKill()
            QuickJoinToastButton.Toast2:GwKill()
        end

        QuickJoinToastButton.ClearAllPoints = GW.NoOp
        QuickJoinToastButton.SetPoint = GW.NoOp
    end

    if not GW.Retail then
        FriendsMicroButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton-highlight.png")
        FriendsMicroButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton.png")
        FriendsMicroButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton-highlight.png")
        FriendsMicroButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/socialchatbutton-highlight.png")
        FriendsMicroButton:SetSize(25, 25)
        FriendsMicroButton:ClearAllPoints()
        FriendsMicroButton:SetPoint("RIGHT", GeneralDockManager, "LEFT", -6, 4)
        FriendsMicroButton.ClearAllPoints = GW.NoOp
        FriendsMicroButton.SetPoint = GW.NoOp
        local _, _, fontFlags = FriendsMicroButtonCount:GetFont()
        FriendsMicroButtonCount:SetFont(_, 14, fontFlags)
        FriendsMicroButtonCount:SetTextColor(1, 1, 1)
        FriendsMicroButtonCount:SetShadowOffset(1, 1)
        FriendsMicroButtonCount:SetPoint("TOP", FriendsMicroButton, "BOTTOM", 1, 1)
    end

    for _, frameName in ipairs(CHAT_FRAMES) do
        local frame = _G[frameName]
        -- possible fix for chatframe floating max error
        frame.oldAlpha = frame.oldAlpha and frame.oldAlpha or DEFAULT_CHATFRAME_ALPHA
        styleChatWindow(frame)
        FCFTab_UpdateAlpha(frame)
        frame:SetTimeVisible(100)
        frame:SetFading(GW.settings.CHATFRAME_FADE)
        frame:SetMaxLines(2500)

        local allowHooks = not ignoreChats[frame:GetID()]
        if allowHooks and not frame.OldAddMessage then
            --Don't add timestamps to combat log, they don't work.
            --This usually taints, but LibChatAnims should make sure it doesn't
            frame.OldAddMessage = frame.AddMessage
            frame.AddMessage = AddMessage
        end

        if not frame.scriptsSet then
            if allowHooks then
                frame:SetScript("OnEvent", FloatingChatFrameOnEvent)
            end

            frame:SetScript("OnMouseWheel", ChatFrame_OnMouseScroll)
            hooksecurefunc(frame, "SetScript", ChatFrame_SetScript)
            frame.scriptsSet = true
        end
    end

    hooksecurefunc("FCF_SetTemporaryWindowType", function(chatFrame)
        styleChatWindow(chatFrame)
        FCFTab_UpdateAlpha(chatFrame)
        chatFrame:SetTimeVisible(100)
        chatFrame:SetFading(GW.settings.CHATFRAME_FADE)
    end)

    hooksecurefunc("FCF_DockUpdate", function()
        for _, frameName in ipairs(CHAT_FRAMES) do
            local frame = _G[frameName]
            local _, _, _, _, _, _, _, _, isDocked = GetChatWindowInfo(frame:GetID())
            local editbox = _G[frameName .. "EditBox"]
            styleChatWindow(frame)
            FCFTab_UpdateAlpha(frame)
            frame:SetTimeVisible(100)
            frame:SetFading(GW.settings.CHATFRAME_FADE)
            if not frame.hasContainer and (isDocked == 1 or (isDocked == nil and frame:IsShown())) then
                local fmGCC = CreateFrame("FRAME", nil, UIParent, "GwChatContainer")
                fmGCC:SetScript("OnSizeChanged", chatBackgroundOnResize)
                fmGCC:SetPoint("TOPLEFT", frame, "TOPLEFT", -35, 5)

                local anchorFrame = not GW.Retail and _G[frameName .. "EditBoxRight"] or _G[frameName .. "EditBoxFocusRight"]
                if not frame.isDocked then
                    fmGCC:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMRIGHT", 5, editbox:GetHeight() - 8)
                else
                    fmGCC:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMRIGHT", 5, 0)
                end
                if not frame.isDocked then fmGCC.EditBox:Hide() end
                frame.Container = fmGCC
                frame.hasContainer = true
            elseif frame.hasContainer then
                frame.Container:SetShown(frame:IsShown())
            elseif frame.isDocked and frame:IsShown() and frame:GetID() > 1 then
                ChatFrame1.Container:Show()
            end
        end
    end)

    SetupHyperlink()
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
                chatFrame.minFrame:GwStripTextures(true)
                chatFrame.minFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
                _G[chatFrame.minFrame:GetName() .. "MaximizeButton"]:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/maximize_button.png")
                _G[chatFrame.minFrame:GetName() .. "MaximizeButton"]:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/maximize_button.png")
                _G[chatFrame.minFrame:GetName() .. "MaximizeButton"]:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/maximize_button.png")
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
        frame:SetFading(GW.settings.CHATFRAME_FADE)
        if not frame.hasContainer and (isDocked == 1 or (isDocked == nil and frame:IsShown())) then
            local fmGCC = CreateFrame("FRAME", nil, UIParent, "GwChatContainer")
            fmGCC:SetScript("OnSizeChanged", chatBackgroundOnResize)
            fmGCC:SetPoint("TOPLEFT", frame, "TOPLEFT", -35, 5)
            if not frame.isDocked then
                fmGCC:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxFocusRight"], "BOTTOMRIGHT", 5, editbox:GetHeight() - 8)
            else
                fmGCC:SetPoint("BOTTOMRIGHT", _G[name .. "EditBoxFocusRight"], "BOTTOMRIGHT", 5, 0)
            end
            if not frame.isDocked then fmGCC.EditBox:Hide() end
            frame.Container = fmGCC
            frame.hasContainer = true
        elseif frame.hasContainer then
            frame.Container:Show()
        end
        --Set Button and container position after drag for every container
        for _, frameName in ipairs(CHAT_FRAMES) do
            local frameForPosition = _G[frameName]
            if frameForPosition:IsShown() and frameForPosition.hasContainer then setButtonPosition(frameForPosition) end
        end
    end)

    hooksecurefunc(
        "FCFTab_UpdateColors",
        function(self)
            local left = GW.Retail and self.ActiveLeft or self.leftSelectedTexture
            local right = GW.Retail and self.ActiveRight or self.rightSelectedTexture
            local middle = GW.Retail and self.ActiveMiddle or self.middleSelectedTexture
            self:GetFontString():SetTextColor(1, 1, 1)
            left:SetVertexColor(1, 1, 1)
            middle:SetVertexColor(1, 1, 1)
            right:SetVertexColor(1, 1, 1)

            local leftHighlight = GW.Retail and self.HighlightLeft or self.leftHighlightTexture
            local rightHighlight= GW.Retail and self.HighlightRight or self.rightSelectedTexture
            local middleHighlight = GW.Retail and self.HighlightMiddle or self.middleHighlightTexture
            leftHighlight:SetVertexColor(1, 1, 1)
            middleHighlight:SetVertexColor(1, 1, 1)
            rightHighlight:SetVertexColor(1, 1, 1)
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

    if GW.settings.chatHistory then DisplayChatHistory() end

    for _, frameName in ipairs(CHAT_FRAMES) do
        local frame = _G[frameName]
        if frame and frame:IsShown() then
            if GW.settings.CHATFRAME_FADE then
                handleChatFrameFadeOut(frame, true)
            else
                handleChatFrameFadeIn(frame, true)
            end
        end
    end

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

    CombatLogQuickButtonFrame_CustomProgressBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")

    CombatLogQuickButtonFrame_CustomTexture:Hide()
    BuildCopyChatFrame()
    BuildEmoticonTableFrame()

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
            if GW.Retail then
                ChatFrameToggleVoiceMuteButton:Show()
                ChatFrameToggleVoiceDeafenButton:Show()
            end
        else
            self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/chat/channel_button_normal_highlight.png")
            self:SetNormalTexture("Interface/AddOns/GW2_UI/textures/chat/channel_button_normal.png")
            self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/chat/channel_button_normal_highlight.png")
            self.Flash:SetTexture("Interface/AddOns/GW2_UI/textures/chat/channel_button_normal_highlight.png")
            if GW.Retail then
                ChatFrameToggleVoiceMuteButton:Hide()
                ChatFrameToggleVoiceDeafenButton:Hide()
            end
        end
    end)
    if GW.Retail then
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

    -- events for functions
    if GW.Retail then
        eventFrame:RegisterEvent("SOCIAL_QUEUE_UPDATE")
    end
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("CVAR_UPDATE")
    eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            CollectLfgRolesForChatIcons()

            ChatFrameChannelButton:UpdateVisibleState()
            if GW.Retail then
                ChatFrameToggleVoiceMuteButton:UpdateVisibleState()
                ChatFrameToggleVoiceDeafenButton:UpdateVisibleState()
            end
        elseif event == "GROUP_ROSTER_UPDATE" then
            CollectLfgRolesForChatIcons()
        elseif event == "SOCIAL_QUEUE_UPDATE" then
            SocialQueueEvent(...)
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
        else
            SaveChatHistory(event, ...)
        end
    end)
end
GW.LoadChat = LoadChat
