---@class GW2
local GW = select(2, ...)
local L = GW.L

-- "[GW2 UI: name]" in a chat message becomes a link. A click asks the sender for that HUD layout with an addon
-- whisper, the answer comes in pieces and shows as a card with a sketch of the frames to take the layout over
local PREFIX = "GW2UI_LAYOUT"
local CHUNK_SIZE = 240
local TEXT_PATTERN = "%[GW2 UI: ([^%]|]+)%]"
local POINTS = {TOPLEFT = true, TOP = true, TOPRIGHT = true, LEFT = true, CENTER = true, RIGHT = true,
    BOTTOMLEFT = true, BOTTOM = true, BOTTOMRIGHT = true}
local SKETCH_WIDTH, SKETCH_HEIGHT = 300, 170

local requested = {}  -- sender -> layout name while its answer is awaited
local incoming = {}   -- sender -> the pieces so far
local answered = {}   -- requester -> time of the last answer
local card

-- the chat and the addon messages may write a name differently, forever with a space or a dash before the surname
local function Key(name)
    return Ambiguate(GW.GetChatNameWithRealm(name), "none")
end

local function GetMovers()
    local movers = {}
    for _, mover in ipairs(GW.MOVABLE_FRAMES) do
        movers[mover.setting] = mover
    end
    return movers
end

-- the data comes from another player, only known frames with a proper position are taken
local function Decode(data)
    local ok, decoded = pcall(C_EncodingUtil.DecodeBase64, data)
    if not ok or not decoded then return end
    local okDecompress, raw = pcall(C_EncodingUtil.DecompressString, decoded, Enum.CompressionMethod.Deflate)
    if not okDecompress or not raw then return end
    local okCbor, payload = pcall(C_EncodingUtil.DeserializeCBOR, raw)
    if not okCbor or type(payload) ~= "table" or type(payload.frames) ~= "table" then return end

    local movers = GetMovers()
    local frames = {}
    for _, frame in ipairs(payload.frames) do
        local point = type(frame) == "table" and frame.point
        if type(point) == "table" and movers[frame.settingName] and POINTS[point.point] and POINTS[point.relativePoint]
            and type(point.xOfs) == "number" and type(point.yOfs) == "number" then
            tinsert(frames, {settingName = frame.settingName,
                point = {point = point.point, relativePoint = point.relativePoint, xOfs = point.xOfs, yOfs = point.yOfs}})
        end
    end
    return frames
end

local function Encode(layout)
    local payload = {frames = layout.frames}
    local compressed = C_EncodingUtil.CompressString(C_EncodingUtil.SerializeCBOR(payload), Enum.CompressionMethod.Deflate,
        Enum.CompressionLevel.OptimizeForSize)
    return C_EncodingUtil.EncodeBase64(compressed)
end

-- where a frame sits on the screen, from its anchor and the size of its mover; size and offsets are in the scale
-- of the mover
local function GetScreenRect(point, mover)
    local screenWidth, screenHeight = UIParent:GetSize()
    local scale = mover:GetEffectiveScale() / UIParent:GetEffectiveScale()
    local width, height = mover:GetWidth() * scale, mover:GetHeight() * scale
    local x = point.relativePoint:find("LEFT") and 0 or point.relativePoint:find("RIGHT") and screenWidth or screenWidth / 2
    local y = point.relativePoint:find("BOTTOM") and 0 or point.relativePoint:find("TOP") and screenHeight or screenHeight / 2
    x, y = x + point.xOfs * scale, y + point.yOfs * scale
    local left = point.point:find("LEFT") and x or point.point:find("RIGHT") and x - width or x - width / 2
    local bottom = point.point:find("BOTTOM") and y or point.point:find("TOP") and y - height or y - height / 2
    return left, bottom, width, height
end

local function UniqueLayoutName(name, sender)
    local base = format("%s (%s)", name, Ambiguate(sender, "short"))
    local layouts, candidate, index = GW.GetAllLayouts(), base, 2
    while layouts[candidate] do
        candidate = base .. " " .. index
        index = index + 1
    end
    return candidate
end

local function CreateCard()
    card = CreateFrame("Frame", "GW2LayoutShareCard", UIParent)
    card:SetSize(SKETCH_WIDTH + 24, SKETCH_HEIGHT + 100)
    card:SetPoint("CENTER")
    card:SetFrameStrata("DIALOG")
    card:EnableMouse(true)
    card:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
    card.backdrop:SetBackdropBorderColor(GW.Colors.Accent:GetRGB())
    tinsert(UISpecialFrames, card:GetName())

    card.title = card:CreateFontString(nil, "OVERLAY")
    card.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    card.title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    card.title:SetPoint("TOPLEFT", 12, -12)

    card.info = card:CreateFontString(nil, "OVERLAY")
    card.info:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    card.info:SetTextColor(GW.Colors.SkinColors.Disabled:GetRGB())
    card.info:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -4)

    card.sketch = CreateFrame("Frame", nil, card)
    card.sketch:SetPoint("TOP", 0, -56)
    card.sketch:SetClipsChildren(true)
    card.sketch.background = card.sketch:CreateTexture(nil, "BACKGROUND")
    card.sketch.background:SetAllPoints()
    card.sketch.background:SetColorTexture(GW.Colors.SkinColors.StatusBarTrack:GetRGBA())
    card.boxes = {}

    card.apply = CreateFrame("Button", nil, card, "GwStandardButton")
    card.apply:SetSize(100, 22)
    card.apply:SetPoint("BOTTOMRIGHT", -12, 10)
    card.apply:SetText(APPLY)

    card.close = CreateFrame("Button", nil, card, "GwStandardButton")
    card.close:SetSize(100, 22)
    card.close:SetPoint("RIGHT", card.apply, "LEFT", -8, 0)
    card.close:SetText(CLOSE)
    card.close:SetScript("OnClick", function() card:Hide() end)
end

-- the own layouts only show, taking one over would share its positions with the copy
local function ShowCard(sender, name, frames, own)
    if not card then
        CreateCard()
    end
    card.title:SetText(format(L["Layout of %s"], Ambiguate(sender, "short")))
    card.info:SetText(name)

    local screenWidth, screenHeight = UIParent:GetSize()
    local scale = math.min(SKETCH_WIDTH / screenWidth, SKETCH_HEIGHT / screenHeight)
    card.sketch:SetSize(screenWidth * scale, screenHeight * scale)
    for _, box in ipairs(card.boxes) do
        box:Hide()
    end
    -- only the frames that are switched on here
    local movers, count = GetMovers(), 0
    for _, frame in ipairs(frames) do
        local mover = movers[frame.settingName]
        if mover and mover.enable and frame.point then
            count = count + 1
            local box = card.boxes[count]
            if not box then
                box = card.sketch:CreateTexture(nil, "ARTWORK")
                box:SetColorTexture(GW.Colors.Accent:GetRGB())
                box:SetAlpha(0.7)
                card.boxes[count] = box
            end
            local left, bottom, width, height = GetScreenRect(frame.point, mover)
            box:ClearAllPoints()
            box:SetPoint("BOTTOMLEFT", card.sketch, "BOTTOMLEFT", left * scale, bottom * scale)
            box:SetSize(math.max(width * scale, 2), math.max(height * scale, 2))
            box:Show()
        end
    end

    card.apply:SetShown(not own)
    card.apply:SetScript("OnClick", function()
        if InCombatLockdown() then
            GW.Notice(L["You cannot move elements during combat!"])
            return
        end
        GW.AddSharedLayout(UniqueLayoutName(name, sender), frames)
        card:Hide()
    end)
    card:Show()
end

-- the own links carry "!" as sender, forever writes the own name with the surname in the chat
local function RequestLayout(sender, name)
    if sender == "!" then
        sender = UnitName("player")
        local layout = GW.GetLayoutByName(name)
        if layout then
            ShowCard(sender, name, layout.frames, true)
        else
            GW.Notice(L["The layout is no longer there."])
        end
        return
    end
    local key = Key(sender)
    requested[key], incoming[key] = name, nil
    C_ChatInfo.SendAddonMessage(PREFIX, "?" .. name, "WHISPER", GW.GetChatNameWithRealm(sender))
    C_Timer.After(5, function()
        if requested[key] == name then
            requested[key] = nil
            GW.Notice(format(L["No answer from %s."], Ambiguate(sender, "short")))
        end
    end)
end

local function Answer(sender, name)
    local key = Key(sender)
    if answered[key] and GetTime() - answered[key] < 3 then return end
    answered[key] = GetTime()

    local layout = GW.GetLayoutByName(name)
    if not layout then
        C_ChatInfo.SendAddonMessage(PREFIX, "!", "WHISPER", sender)
        return
    end
    local data = Encode(layout)
    local total = math.ceil(#data / CHUNK_SIZE)
    for index = 1, total do
        local piece = strsub(data, (index - 1) * CHUNK_SIZE + 1, index * CHUNK_SIZE)
        C_ChatInfo.SendAddonMessage(PREFIX, index .. "/" .. total .. ":" .. piece, "WHISPER", sender)
    end
end

local function Receive(sender, message)
    local key = Key(sender)
    local name = requested[key]
    if not name then return end
    if message == "!" then
        requested[key] = nil
        GW.Notice(L["The layout is no longer there."])
        return
    end
    local index, total, piece = strmatch(message, "^(%d+)/(%d+):(.*)$")
    index, total = tonumber(index), tonumber(total)
    if not index or index > total then return end

    incoming[key] = incoming[key] or {}
    incoming[key][index] = piece
    for i = 1, total do
        if not incoming[key][i] then return end
    end
    local data = table.concat(incoming[key], "", 1, total)
    requested[key], incoming[key] = nil, nil
    local frames = Decode(data)
    if frames and #frames > 0 then
        ShowCard(sender, name, frames)
    end
end

-- the answers work without the chat of GW2 UI, only the links need it
local comm = CreateFrame("Frame")
comm:RegisterEvent("CHAT_MSG_ADDON")
comm:SetScript("OnEvent", function(_, _, prefix, message, channel, sender)
    if prefix ~= PREFIX or GW.IsSecretValue(message) then return end
    if strsub(message, 1, 1) == "?" and channel == "WHISPER" then
        Answer(sender, strsub(message, 2))
    else
        Receive(sender, message)
    end
end)
C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)

-- battle.net whispers have no character to ask
local EVENTS = {}
for _, event in ipairs(GW.CHAT_MESSAGE_EVENTS) do
    if not strfind(event, "_BN_", 1, true) then
        tinsert(EVENTS, event)
    end
end

GW.RegisterChatModule({
    events = EVENTS,
    onMessage = function(_, event, msg, author, ...)
        -- in the own whispers the author is the other one, the layout is ours
        local guid = select(10, ...)
        local own = strfind(event, "_INFORM", 1, true) or (not GW.IsSecretValue(guid) and guid == UnitGUID("player"))
        local sender = own and "!" or author
        local linked = GW.MapChatText(msg, function(text)
            return (gsub(text, TEXT_PATTERN, function(name)
                return GW.CreateChatLink("layout", sender .. ":" .. name, GW.Colors.Accent:WrapTextInColorCode("[GW2 UI: " .. name .. "]"))
            end))
        end)
        if linked ~= msg then
            return false, linked, author, ...
        end
    end,
    links = {layout = function(data)
        local sender, name = strmatch(data, "^([^:]+):(.+)$")
        if sender then
            RequestLayout(sender, name)
        end
    end},
})
