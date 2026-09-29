---@class GW2
local GW = select(2, ...)
local L = GW.L

local SHORT_NAMES = {
    GUILD = L["G"], OFFICER = L["O"], PARTY = L["P"], PARTY_LEADER = L["PL"], RAID = L["R"], RAID_LEADER = L["RL"],
    INSTANCE_CHAT = L["I"], INSTANCE_CHAT_LEADER = L["IL"],
}
local AFK_FLAG, AFK_SHORT = "<" .. AFK .. ">", "[|cffff0000" .. AFK .. "|r]"
local DND_FLAG, DND_SHORT = "<" .. DND .. ">", "[|cffe7e716" .. DND .. "|r]"

-- the labels come from blizzards own chat strings, so every locale works without a list of its own
local shortLabels = {}
local speechVerbs = {}
local raidWarningLabel

local function EscapePattern(text)
    return (gsub(text, "%p", "%%%0"))
end

local function BuildLabels()
    for chatType, short in pairs(SHORT_NAMES) do
        local label = strmatch(_G["CHAT_" .. chatType .. "_GET"] or "", "|h%[(.-)%]|h")
        if label then
            shortLabels[label] = short
        end
    end
    -- "[Name] says: hi" becomes "[Name]: hi"
    for _, chatType in ipairs({"SAY", "YELL", "WHISPER"}) do
        local verb = strmatch(_G["CHAT_" .. chatType .. "_GET"] or "", "^%%s (.-):")
        if verb then
            tinsert(speechVerbs, "^(.-|h) " .. EscapePattern(verb) .. ":")
        end
    end
    local warning = strmatch(CHAT_RAID_WARNING_GET or "", "^%[(.-)%]")
    raidWarningLabel = warning and "%[" .. EscapePattern(warning) .. "%]"
end

-- "[2. Trade - City]" becomes "[2]", "[Guild]" becomes "[G]"
local function ShortenLink(target, label)
    local short = shortLabels[label] or strmatch(target, "^channel:(%d+)")
    if short then
        return format("|Hchannel:%s|h[%s]|h", target, short)
    end
end

local function ShortenLine(_, text)
    -- battle.net names are protected strings, leave those lines alone
    if strfind(text, "|K", 1, true) then
        return
    end

    text = gsub(text, "|Hchannel:(.-)|h%[(.-)%]|h", ShortenLink)
    for _, pattern in ipairs(speechVerbs) do
        text = gsub(text, pattern, "%1:", 1)
    end
    if raidWarningLabel then
        text = gsub(text, raidWarningLabel, "[" .. L["RW"] .. "]", 1)
    end
    text = gsub(text, EscapePattern(AFK_FLAG), AFK_SHORT)
    text = gsub(text, EscapePattern(DND_FLAG), DND_SHORT)
    return text
end

GW.RegisterChatModule({
    setting = "shortChannelNames",
    onLoad = BuildLabels,
    onLine = ShortenLine,
})
