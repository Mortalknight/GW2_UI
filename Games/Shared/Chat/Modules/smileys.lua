---@class GW2
local GW = select(2, ...)

local EMOJI_PATH = "Interface/AddOns/GW2_UI/textures/emoji/"
local PICKER_COLUMNS = 6
local PICKER_ICON_SIZE = 24
local PICKER_SPACING = 26

-- the named codes are offered in the picker, in this order
local NAMED = {
    {":angry:", "angry"}, {":blush:", "blush"}, {":broken_heart:", "brokenheart"}, {":call_me:", "callme"},
    {":cry:", "cry"}, {":grin:", "grin"}, {":heart:", "heart"}, {":heart_eyes:", "hearteyes"},
    {":joy:", "joy"}, {":middle_finger:", "middlefinger"}, {":ok_hand:", "okhand"}, {":open_mouth:", "openmouth"},
    {":poop:", "poop"}, {":rage:", "rage"}, {":scream:", "scream"}, {":scream_cat:", "screamcat"},
    {":slight_frown:", "slightfrown"}, {":smile:", "smile"}, {":smirk:", "smirk"}, {":sob:", "sob"},
    {":sunglasses:", "sunglasses"}, {":thinking:", "thinking"}, {":thumbs_up:", "thumbsup"}, {":wink:", "wink"},
    {":zzz:", "zzz"}, {":stuck_out_tongue:", "stuckouttongue"}, {":stuck_out_tongue_closed_eyes:", "stuckouttongueclosedeyes"},
}

-- the classic text smileys, replaced but not offered
local SHORT = {
    angry = {":-@", ":@"},
    smile = {":-)", ":)"},
    grin = {":D", ":-D", ";-D", ";D", "=D", "xD", "XD"},
    slightfrown = {":-(", ":("},
    openmouth = {":o", ":-o", ":-O", ":O", ":-0"},
    stuckouttongue = {":P", ":-P", ":p", ":-p", "=P", "=p"},
    stuckouttongueclosedeyes = {";-p", ";p", ";P", ";-P"},
    wink = {";-)", ";)"},
    smirk = {":S", ":-S"},
    cry = {":,(", ":,-(", ":\"(", ":\"-("},
    middlefinger = {":F", ",,!,,"},
    heart = {"<3"},
    brokenheart = {"</3"},
}

local textures = {}

local function IsEnabled()
    return GW.settings.chat.keywords.emoji
end

local function BuildTextures()
    for _, entry in ipairs(NAMED) do
        textures[entry[1]] = EMOJI_PATH .. entry[2] .. ".png"
    end
    for file, codes in pairs(SHORT) do
        for _, code in ipairs(codes) do
            textures[code] = EMOJI_PATH .. file .. ".png"
        end
    end
end

-- the invisible link in front keeps the typed code, so copied chat lines get it back
local function ReplaceCodes(plain)
    return (gsub(plain, "%S+", function(word)
        local texture = textures[word]
        if texture then
            return GW.CreateChatLink("emoji", word, "|cffffffff|r") .. "|T" .. texture .. ":16:16|t"
        end
    end))
end

local function Icon_OnEnter(self)
    self:SetSize(PICKER_ICON_SIZE + 4, PICKER_ICON_SIZE + 4)
    self.texture:SetBlendMode("ADD")
end

local function Icon_OnLeave(self)
    self:SetSize(PICKER_ICON_SIZE, PICKER_ICON_SIZE)
    self.texture:SetBlendMode("BLEND")
end

-- GW_EmoteFrame, the emote buttons of the chat windows toggle it
local function CreatePicker()
    local rows = math.ceil(#NAMED / PICKER_COLUMNS)
    local picker = CreateFrame("Frame", "GW_EmoteFrame", UIParent)
    picker:GwCreateBackdrop(GW.BackdropTemplates.Default, true, 4, 4)
    picker:SetSize(PICKER_COLUMNS * PICKER_SPACING + 4, rows * PICKER_SPACING + 4)
    picker:SetPoint("BOTTOMLEFT", GW.isModern and QuickJoinToastButton or ChatFrame1Tab, "TOPLEFT", 0, 5)
    picker:SetFrameStrata("DIALOG")
    picker:Hide()
    tinsert(UISpecialFrames, "GW_EmoteFrame")

    for index, entry in ipairs(NAMED) do
        local column, row = (index - 1) % PICKER_COLUMNS, math.floor((index - 1) / PICKER_COLUMNS)
        local icon = CreateFrame("Button", nil, picker)
        icon:SetSize(PICKER_ICON_SIZE, PICKER_ICON_SIZE)
        -- centered on its cell, so the hover growth stays in place
        icon:SetPoint("CENTER", picker, "TOPLEFT", 2 + (column + 0.5) * PICKER_SPACING, -2 - (row + 0.5) * PICKER_SPACING)
        icon.texture = icon:CreateTexture(nil, "ARTWORK")
        icon.texture:SetAllPoints()
        icon.texture:SetTexture(textures[entry[1]])
        icon:SetScript("OnEnter", Icon_OnEnter)
        icon:SetScript("OnLeave", Icon_OnLeave)
        icon:SetScript("OnClick", function()
            GW.PutIntoChatEditBox(entry[1])
            picker:Hide()
        end)
    end
end

GW.RegisterChatModule({
    setting = IsEnabled,
    events = GW.CHAT_MESSAGE_EVENTS,
    onLoad = function()
        BuildTextures()
        CreatePicker()
    end,
    onMessage = function(_, _, msg, ...)
        -- scripts stay readable
        if strfind(msg, "^/run") or strfind(msg, "^/dump") or strfind(msg, "^/script") then
            return
        end
        local text = GW.MapChatText(msg, ReplaceCodes)
        if text ~= msg then
            return false, text, ...
        end
    end,
})
