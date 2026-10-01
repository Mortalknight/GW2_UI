---@class GW2
local GW = select(2, ...)

-- the classes of everyone who wrote in chat so far, by lower case name and name-realm
local classByName = {}
local numNames = 0
local MAX_NAMES = 1000

local function Remember(name, class)
    if not classByName[name] then
        numNames = numNames + 1
    end
    classByName[name] = class
end

local function RememberSender(guid)
    if GW.IsSecretValue(guid) or not guid or guid == "" then
        return
    end
    local ok, _, class, _, _, _, name, realm = pcall(GetPlayerInfoByGUID, guid)
    if not ok or GW.IsSecretValue(class) or GW.IsSecretValue(name) or GW.IsSecretValue(realm) or not (class and name and name ~= "") then
        return
    end
    if numNames >= MAX_NAMES then
        wipe(classByName)
        numNames = 0
        Remember(strlower(GW.myname), GW.myclass)
    end
    Remember(strlower(name), class)
    if realm and realm ~= "" then
        Remember(strlower(name .. "-" .. gsub(realm, "[%s%-]", "")), class)
    end
end

local function ColorNames(plain)
    return (gsub(plain, "[^%s%p]+", function(word)
        local class = classByName[strlower(word)]
        if class then
            return GW.GWGetClassColor(class, true, true):WrapTextInColorCode(word)
        end
    end))
end

GW.RegisterChatModule({
    setting = "classColorMentions",
    events = GW.CHAT_MESSAGE_EVENTS,
    onLoad = function()
        Remember(strlower(GW.myname), GW.myclass)
    end,
    onMessage = function(_, _, msg, ...)
        RememberSender(select(11, ...)) -- ... starts at arg2, so this is arg12, the sender guid
        local text = GW.MapChatText(msg, ColorNames)
        if text ~= msg then
            return false, text, ...
        end
    end,
})
