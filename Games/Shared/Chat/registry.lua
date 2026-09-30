---@class GW2
local GW = select(2, ...)

--[[
    Chat modules.

    The chat stays blizzards: its message handler formats every line and the modules only
    decorate it, through the hooks blizzard offers for that. Register at file scope:

        GW.RegisterChatModule({
            setting      = "findUrl",                           -- GW.settings.chat key or a function that switches it, optional
            events       = GW.CHAT_MESSAGE_EVENTS,              -- the events onMessage runs for
            onMessage    = function(chatFrame, event, msg, ...) end, -- true drops the message, false plus args changes them
            onSenderName = function(event, name, ...) end,      -- the decorated sender name, nil keeps it
            onLine       = function(chatFrame, text, r, g, b, infoID, accessID, typeID, event, ...) end,
                                                                -- the finished line as stored, nil keeps it; chat
                                                                -- messages carry an accessID, system lines do not
            links        = {url = function(data, text, button, chatFrame) end}, -- clicks on GW.CreateChatLink links
            onFrame      = function(chatFrame) end,             -- once for every chat window, whisper windows included
            onLoad       = function() end,
        })

    Blizzard skips the message and sender name hooks for secret values, the line hook does the same.
]]

local LINK_PREFIX = "addon:GW2_UI:"

local modules = {}
local lineModules = {}
local linkHandlers = {}
local hookedFrames = {}
local loaded = false

local AddMessageEventFilter = ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter or ChatFrame_AddMessageEventFilter
local AddSenderNameFilter = ChatFrameUtil and ChatFrameUtil.AddSenderNameFilter

-- the player written messages, the ones worth decorating
GW.CHAT_MESSAGE_EVENTS = {
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE", "CHAT_MSG_CHANNEL",
    "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_BN_INLINE_TOAST_BROADCAST", "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_GUILD_ACHIEVEMENT",
    "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER", "CHAT_MSG_AFK", "CHAT_MSG_DND", "CHAT_MSG_COMMUNITIES_CHANNEL",
}

local function IsEnabled(module)
    if type(module.setting) == "function" then
        return module.setting()
    end
    return not module.setting or GW.settings.chat[module.setting]
end

local function WhenEnabled(module, func)
    return function(...)
        if IsEnabled(module) then
            return func(...)
        end
    end
end

function GW.CreateChatLink(linkType, data, text)
    return format("|H%s%s:%s|h%s|h", LINK_PREFIX, linkType, data, text)
end

local MY_REALM = gsub(GW.myrealm, "[%s%-]", "")

-- chat events leave out the realm of senders from the own one
function GW.GetChatNameWithRealm(name)
    return strfind(name, "-", 1, true) and name or name .. "-" .. MY_REALM
end

-- replace sets the text and marks it for copying, otherwise it goes in at the cursor
function GW.PutIntoChatEditBox(text, replace)
    local editBox = ChatFrameUtil.ChooseBoxForSend()
    if not editBox:IsShown() then
        ChatFrameUtil.ActivateChat(editBox)
    end
    if replace then
        editBox:SetText(text)
        editBox:HighlightText()
    else
        editBox:Insert(text)
    end
end

local function RaidIconToTag(index)
    local name = _G["RAID_TARGET_" .. index]
    return name and "{" .. strlower(name) .. "}" or ""
end

-- "1 |4day:days;" is blizzards plural escape, the text shows one of the two
local function ResolvePlural(count, space, one, many)
    return count .. space .. (count == "1" and one or many)
end

-- a chat line the way the player would type it: colored links (items, spells ...) stay unless
-- linksAsText, other links keep their text, raid icons become {star} again, smileys their code,
-- other textures and colors go
function GW.GetPlainChatLine(text, linksAsText)
    local kept = {}
    text = gsub(text, "|c[^|]*|H.-|h.-|h|r", function(link)
        if linksAsText then
            return link
        end
        tinsert(kept, link)
        return "\001" .. #kept .. "\001"
    end)
    text = gsub(text, "|TInterface\\TargetingFrame\\UI%-RaidTargetingIcon_(%d+):0|t", RaidIconToTag)
    text = gsub(text, "|H(.-)|h(.-)|h", function(data, display)
        return strmatch(data, "^" .. LINK_PREFIX .. "emoji:(.+)") or display
    end)
    text = gsub(text, "|[TA].-|[ta]", "")
    text = gsub(text, "(%d+)(%s*)|4([^:]*):([^;]*);", ResolvePlural)
    text = gsub(gsub(gsub(text, "|c%x%x%x%x%x%x%x%x", ""), "|cn[^:]*:", ""), "|r", "")
    text = gsub(text, "\001(%d+)\001", function(index) return kept[tonumber(index)] end)
    return strtrim(text)
end

-- runs func over the plain text of a message; links, textures and atlas icons stay as they are
function GW.MapChatText(msg, func)
    local parts, position = {}, 1
    while true do
        local start, stop = strfind(msg, "|H.-|h.-|h", position)
        local textureStart, textureStop = strfind(msg, "|[TA].-|[ta]", position)
        if textureStart and (not start or textureStart < start) then
            start, stop = textureStart, textureStop
        end
        if not start then
            break
        end
        tinsert(parts, func(strsub(msg, position, start - 1)))
        tinsert(parts, strsub(msg, start, stop))
        position = stop + 1
    end
    tinsert(parts, func(strsub(msg, position)))
    return table.concat(parts)
end

local function RunLineModules(chatFrame, text, ...)
    if GW.IsSecretValue(text) or type(text) ~= "string" then
        return
    end

    local newText = text
    for _, module in ipairs(lineModules) do
        if IsEnabled(module) then
            newText = module.onLine(chatFrame, newText, ...) or newText
        end
    end
    if newText == text then
        return
    end

    -- the hook runs right after the line was stored and before it draws; an identical older
    -- line was already changed when it came in, so the first match is the new one; older
    -- lines may be secret, those are never the new one
    local done = false
    chatFrame:TransformMessages(function(message)
        if not done and GW.NotSecretValue(message) and message == text then
            done = true
            return true
        end
    end, function(_, ...)
        return newText, ...
    end)
end

-- the stored line, not the AddMessage arguments: wrappers in between may still have changed it
local function OnAddMessage(chatFrame)
    local numMessages = chatFrame:GetNumMessages()
    if numMessages > 0 then
        RunLineModules(chatFrame, chatFrame:GetMessageInfo(numMessages))
    end
end

-- every chat frame, the temporary whisper windows included; the combat log has lines of its own
function GW.SetupChatModulesForFrame(chatFrame)
    if hookedFrames[chatFrame] or chatFrame == COMBATLOG then
        return
    end
    hookedFrames[chatFrame] = true
    hooksecurefunc(chatFrame, "AddMessage", OnAddMessage)
    -- modules hooked later catch up on the frames that exist by then
    if not loaded then
        return
    end
    for _, module in ipairs(modules) do
        if module.onFrame then
            module.onFrame(chatFrame)
        end
    end
end

local function Pack(...)
    return { n = select("#", ...), ... }
end

-- blizzard runs the message filters once for every chat window, before it checks whether the
-- window shows that message; the modules only look at the message, so the first window works
-- the result out and the others reuse it (arg11 is the unique line id of the message)
local function CreateMessageFilter(module)
    local lastEvent, lastLineID, lastResult
    return function(chatFrame, event, ...)
        if not IsEnabled(module) then
            return
        end
        local lineID = select(11, ...)
        if GW.IsSecretValue(lineID) or not lineID or lineID == 0 then
            return module.onMessage(chatFrame, event, ...)
        end
        if lineID ~= lastLineID or event ~= lastEvent then
            lastEvent, lastLineID = event, lineID
            lastResult = Pack(module.onMessage(chatFrame, event, ...))
        end
        return unpack(lastResult, 1, lastResult.n)
    end
end

local function OnSetItemRef(_, link, text, button, chatFrame)
    if GW.IsSecretValue(link) then
        return
    end
    local linkType, data = strmatch(link, "^" .. LINK_PREFIX .. "([^:]+):?(.*)")
    local handler = linkType and linkHandlers[linkType]
    if handler then
        handler(data, text, button, chatFrame)
    end
end

local function HookModule(module)
    if module.onMessage and module.events then
        local filter = CreateMessageFilter(module)
        for _, event in ipairs(module.events) do
            AddMessageEventFilter(event, filter)
        end
    end
    if module.onSenderName and AddSenderNameFilter then
        AddSenderNameFilter(WhenEnabled(module, module.onSenderName))
    end
    if module.onLine then
        tinsert(lineModules, module)
    end
    for linkType, handler in pairs(module.links or {}) do
        linkHandlers[linkType] = WhenEnabled(module, handler)
    end
    if module.onFrame then
        for chatFrame in pairs(hookedFrames) do
            module.onFrame(chatFrame)
        end
    end
    if module.onLoad then
        module.onLoad()
    end
end

function GW.RegisterChatModule(module)
    tinsert(modules, module)
    if loaded then
        HookModule(module)
    end
end

-- once the chat is ours; modules check their setting on every call, so toggling needs no reload
function GW.LoadChatModules()
    if loaded then
        return
    end
    loaded = true

    EventRegistry:RegisterCallback("SetItemRef", OnSetItemRef)
    for _, module in ipairs(modules) do
        HookModule(module)
    end
end
