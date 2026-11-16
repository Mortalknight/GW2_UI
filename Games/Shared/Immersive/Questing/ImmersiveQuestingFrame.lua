---@class GW2
local GW = select(2, ...)
local mapBGs = GW.immersiveQuesting.mapBackgrounds
local instanceBGs = GW.immersiveQuesting.instanceBackgrounds
local object_types = GW.immersiveQuesting.objectTypes

GwImmersiveQuestFrameMixin = {}

local WINDOWED_WIDTH = 1024
local WINDOWED_HEIGHT = 512
local ART_ASPECT = 2

local function setCoverTexCoords(texture, aspect)
    local visibleWidth = 1
    local visibleHeight = 1
    if aspect > ART_ASPECT then
        visibleHeight = ART_ASPECT / aspect
    else
        visibleWidth = aspect / ART_ASPECT
    end
    local left = (1 - visibleWidth) / 2
    local top = (1 - visibleHeight) / 2
    texture:SetTexCoord(left, left + visibleWidth, top, top + visibleHeight)
    return left, left + visibleWidth, top, top + visibleHeight
end

local EDGE_WIDTH = 500
local TRAVEL_EXTRA = 0.6
local BRUSH_TOP_EDGE_LAG = 0.55
local BRUSH_SLICES = 32
local BRUSH_SOFT_RANGE = 0.18
local BRUSH_TOP_FILE = "Interface/AddOns/GW2_UI/textures/questview/overlay_top.png"
local BRUSH_BOTTOM_FILE = "Interface/AddOns/GW2_UI/textures/questview/overlay_bottom.png"
local BRUSH_TOP_EDGE = 0.45
local BRUSH_BOTTOM_EDGE = 0.39
local BRUSH_INSET = 0.02
local INTRO_DURATION = 1.9
local MAX_INTRO_STEP = 0.034
local BLEED_FRAMES = 20
local BLEED_MASK_PATH = "Interface/AddOns/GW2_UI/textures/questview/bleed/bleed_%02d.png"
local OUTRO_DURATION = 0.3
local SUMMARY_FULLSCREEN_SCALE = 1.5
local SUMMARY_FULLSCREEN_DROP = 0.09

local function easeInOut(t)
    return t * t * (3 - 2 * t)
end

local function segment(time, from, to)
    return easeInOut(min(1, max(0, (time - from) / (to - from))))
end

local function ensureBleedMasks(self)
    local bandClip = self.container.bandClip
    if self.bleedMasks or not bandClip.CreateMaskTexture then
        return
    end
    local masks = {}
    for index = 1, BLEED_FRAMES do
        local mask = bandClip:CreateMaskTexture()
        mask:SetTexture(BLEED_MASK_PATH:format(index), "CLAMPTOEDGE", "CLAMPTOEDGE")
        mask:SetAllPoints(bandClip)
        masks[index] = mask
    end
    self.bleedLayer = bandClip:CreateTexture(nil, "BACKGROUND", nil, 2)
    self.bleedLayer:Hide()
    if self.bleedPath then
        self.bleedLayer:SetTexture(self.bleedPath)
    end
    self.bleedMasks = masks
end

function GwImmersiveQuestFrameMixin:setBleedTexture(path)
    self.bleedPath = path
    if self.bleedLayer then
        self.bleedLayer:SetTexture(path)
    end
end

local function swapMask(texture, masks, current, target)
    if current == target then
        return target
    end
    if current and current > 0 then
        texture:RemoveMaskTexture(masks[current])
    end
    if target > 0 then
        texture:AddMaskTexture(masks[target])
    end
    return target
end

local function setBandBleed(self, progress)
    local mapBG = self.container.mapBG
    local masks = self.bleedMasks
    if not masks then
        mapBG:SetAlpha(progress)
        return
    end
    local layer = self.bleedLayer
    if progress >= 1 then
        self.bleedBase = swapMask(mapBG, masks, self.bleedBase, 0)
        self.bleedOver = swapMask(layer, masks, self.bleedOver, 0)
        layer:Hide()
        return
    end
    local position = progress * (BLEED_FRAMES - 1)
    local base = math.floor(position)
    self.bleedBase = swapMask(mapBG, masks, self.bleedBase, base + 1)
    self.bleedOver = swapMask(layer, masks, self.bleedOver, base + 2)
    layer:SetAlpha(position - base)
    layer:Show()
end

local function wipeWidth(progress, fullWidth)
    if progress >= 1 then
        return fullWidth
    end
    return max(1, progress * (fullWidth + EDGE_WIDTH * TRAVEL_EXTRA))
end

local function buildBrushSlices(frame, file, uFrom, uTo, vFrom, vTo, width, height)
    local sliceWidth = width / BRUSH_SLICES
    frame.slices = frame.slices or {}
    if not frame.full then
        frame.full = frame:CreateTexture(nil, "BACKGROUND")
        frame.full:SetTexture(file)
        frame.full:SetVertexColor(0, 0, 0, 1)
        frame.full:Hide()
    end
    frame.full:ClearAllPoints()
    frame.full:SetAllPoints(frame)
    frame.full:SetTexCoord(uFrom, uTo, vFrom, vTo)
    frame.settled = nil
    for i = 1, BRUSH_SLICES do
        local slice = frame.slices[i]
        if not slice then
            slice = frame:CreateTexture(nil, "BACKGROUND")
            slice:SetTexture(file)
            slice:SetVertexColor(0, 0, 0, 1)
            frame.slices[i] = slice
        end
        slice:ClearAllPoints()
        slice:SetPoint("TOPLEFT", frame, "TOPLEFT", (i - 1) * sliceWidth, 0)
        slice:SetSize(sliceWidth + 1, height)
        slice:SetTexCoord(uFrom + (uTo - uFrom) * (i - 1) / BRUSH_SLICES, uFrom + (uTo - uFrom) * i / BRUSH_SLICES, vFrom, vTo)
    end
end

local function setBrushLead(frame, lead, width, fromRight)
    local settled = lead >= width * (1 + BRUSH_SOFT_RANGE)
    if settled ~= frame.settled then
        frame.settled = settled
        frame.full:SetShown(settled)
        for _, slice in ipairs(frame.slices) do
            slice:SetShown(not settled)
        end
    end
    if settled then
        return
    end
    local soft = width * BRUSH_SOFT_RANGE
    for i, slice in ipairs(frame.slices) do
        local center = (i - 0.5) * width / BRUSH_SLICES
        local distance = fromRight and (width - center) or center
        slice:SetAlpha(easeInOut(min(1, max(0, (lead - distance) / soft))))
    end
end

local function setWipe(frame, progress, fullWidth)
    if progress >= 1 then
        frame:SetWidth(fullWidth)
        if frame.solid and not frame.solidFull then
            frame.solidFull = true
            frame.solid:ClearAllPoints()
            frame.solid:SetAllPoints(frame)
            frame.edge:Hide()
        end
        return
    end
    frame:SetWidth(max(1, progress * (fullWidth + EDGE_WIDTH * TRAVEL_EXTRA)))
    if frame.solid and frame.solidFull then
        frame.solidFull = false
        frame.edge:Show()
        frame.solid:ClearAllPoints()
        if frame.fromRight then
            frame.solid:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
            frame.solid:SetPoint("BOTTOMLEFT", frame.edge, "BOTTOMRIGHT")
        else
            frame.solid:SetPoint("TOPLEFT", frame, "TOPLEFT")
            frame.solid:SetPoint("BOTTOMRIGHT", frame.edge, "BOTTOMLEFT")
        end
    end
end

function GwImmersiveQuestFrameMixin:applyIntroProgress(time)
    local c = self.container
    local width = self.layoutWidth

    local topProgress = segment(time, 0, 0.75)
    local bottomProgress = segment(time, 0, 0.75)
    setWipe(c.stripeTop, topProgress, width)
    setWipe(c.stripeBottom, bottomProgress, width)
    local settled = width * (1 + BRUSH_SOFT_RANGE)
    setBrushLead(c.brushClipTop, topProgress >= 1 and settled or wipeWidth(topProgress, width) - EDGE_WIDTH * BRUSH_TOP_EDGE_LAG, width, false)
    setBrushLead(c.brushClipBottom, bottomProgress >= 1 and settled or wipeWidth(bottomProgress, width) - EDGE_WIDTH * BRUSH_TOP_EDGE_LAG, width, true)
    setBandBleed(self, segment(time, 0.35, 1.7))

    local textAlpha = segment(time, 0.5, 1.0)
    c.dialog:SetAlpha(textAlpha)
    c.floaty:SetAlpha(textAlpha)
end

function GwImmersiveQuestFrameMixin:stopAnimation()
    self.animationDriver:SetScript("OnUpdate", nil)
    self.fadingOut = false
    self:SetAlpha(1)
end

function GwImmersiveQuestFrameMixin:playIntro()
    local elapsed = 0
    self:stopAnimation()
    self:applyIntroProgress(0)
    self.animationDriver:SetScript("OnUpdate", function(_, delta)
        elapsed = elapsed + min(delta, MAX_INTRO_STEP)
        self:applyIntroProgress(elapsed)
        if elapsed >= INTRO_DURATION then
            self:stopAnimation()
        end
    end)
end

function GwImmersiveQuestFrameMixin:playOutro()
    local elapsed = 0
    self:stopAnimation()
    self.fadingOut = true
    self.animationDriver:SetScript("OnUpdate", function(_, delta)
        elapsed = elapsed + delta
        self:SetAlpha(1 - min(1, elapsed / OUTRO_DURATION))
        if elapsed >= OUTRO_DURATION then
            self:stopAnimation()
            self:HideNow()
        end
    end)
end

function GwImmersiveQuestFrameMixin:HideWithOutro()
    local canAnimate = self.isFullscreen and self:IsShown() and not self.was_showing and not self.fadingOut and not self.in_load and not self.in_cine
    if canAnimate then
        self:playOutro()
    else
        self:HideNow()
    end
end

local function layoutFullscreen(self, width, height)
    local c = self.container
    local bandHeight = height * 0.446
    local bandCenterY = -height * 0.02
    local modelHeight = height * 0.92
    local stripeTopHeight = height / 2 - bandCenterY - bandHeight / 2
    local stripeBottomHeight = height / 2 + bandCenterY - bandHeight / 2

    self.layoutWidth = width
    self.maxTextWidth = min(1000, width * 0.55)

    self.border:Hide()
    self.overlayTop:Hide()
    self.backdrop:Hide()

    c:SetSize(width, height)

    c.floaty:ClearAllPoints()
    c.floaty:SetAllPoints(c)
    c.floaty.inset:Hide()

    c.stripeTop:ClearAllPoints()
    c.stripeTop:SetPoint("TOPLEFT", c, "TOPLEFT")
    c.stripeTop:SetHeight(stripeTopHeight)
    c.stripeTop.fromRight = false
    c.stripeTop:Show()

    c.stripeBottom:ClearAllPoints()
    c.stripeBottom:SetPoint("BOTTOMRIGHT", c, "BOTTOMRIGHT")
    c.stripeBottom:SetHeight(stripeBottomHeight)
    c.stripeBottom.fromRight = true
    c.stripeBottom:Show()

    c.stripeTop.edge:SetTexCoord(0, 0, 1, 0, 0, 1, 1, 1)
    c.stripeBottom.edge:SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
    c.stripeTop.edge:SetWidth(EDGE_WIDTH)
    c.stripeBottom.edge:SetWidth(EDGE_WIDTH)
    c.stripeTop.edge:SetVertexColor(0, 0, 0, 1)
    c.stripeBottom.edge:SetVertexColor(0, 0, 0, 1)

    c.bandClip:ClearAllPoints()
    c.bandClip:SetPoint("LEFT", c, "LEFT", 0, bandCenterY)
    c.bandClip:SetSize(width, bandHeight)
    c.bandClip:Show()

    c.mapBG:SetParent(c.bandClip)
    c.mapBG:ClearAllPoints()
    c.mapBG:SetPoint("CENTER", c, "CENTER", 0, bandCenterY)
    c.mapBG:SetSize(width, bandHeight)
    local left, right, top, bottom = setCoverTexCoords(c.mapBG, width / bandHeight)
    ensureBleedMasks(self)
    if self.bleedLayer then
        self.bleedLayer:ClearAllPoints()
        self.bleedLayer:SetAllPoints(c.mapBG)
        self.bleedLayer:SetTexCoord(left, right, top, bottom)
    end

    local brushHeight = bandHeight * 0.4
    c.brushClipTop:ClearAllPoints()
    c.brushClipTop:SetPoint("TOPLEFT", c.bandClip, "TOPLEFT", 0, BRUSH_TOP_EDGE * brushHeight - BRUSH_INSET * bandHeight)
    c.brushClipTop:SetSize(width, brushHeight)
    buildBrushSlices(c.brushClipTop, BRUSH_TOP_FILE, 0, 1, 0, 1, width, brushHeight)
    c.brushClipTop:Show()
    c.brushClipBottom:ClearAllPoints()
    c.brushClipBottom:SetPoint("TOPLEFT", c.bandClip, "BOTTOMLEFT", 0, BRUSH_BOTTOM_EDGE * brushHeight + BRUSH_INSET * bandHeight)
    c.brushClipBottom:SetSize(width, brushHeight)
    buildBrushSlices(c.brushClipBottom, BRUSH_BOTTOM_FILE, 0.09, 0.92, 0.62, 1, width, brushHeight)
    c.brushClipBottom:Show()

    c.blackout_head:ClearAllPoints()
    c.blackout_head:SetPoint("TOPLEFT", c, "TOPLEFT")
    c.blackout_head:SetPoint("TOPRIGHT", c, "TOPRIGHT")
    c.blackout_fade:ClearAllPoints()
    c.blackout_fade:SetPoint("TOPLEFT", c.blackout_head, "BOTTOMLEFT")
    c.blackout_fade:SetPoint("TOPRIGHT", c.blackout_head, "BOTTOMRIGHT")
    c.blackout_fade:SetHeight(32)

    c.playerModel:ClearAllPoints()
    c.playerModel:SetPoint("BOTTOMLEFT", c, "BOTTOMLEFT", width * 0.03, 0)
    c.playerModel:SetSize(min(modelHeight, width * 0.45), modelHeight)

    c.giverModel:ClearAllPoints()
    c.giverModel:SetPoint("BOTTOMRIGHT", c, "BOTTOMRIGHT", width * 0.015, 0)
    c.giverModel:SetSize(width * 0.85, modelHeight)

    c.dialog:ClearAllPoints()
    c.dialog:SetAllPoints(c)
    c.dialog.blackout_feet:Hide()
    c.dialog.text:ClearAllPoints()

    c.summary:SetScale(SUMMARY_FULLSCREEN_SCALE)
    c.summary:ClearAllPoints()
    c.summary:SetPoint("CENTER", c, "CENTER", 0, (bandCenterY - height * SUMMARY_FULLSCREEN_DROP) / SUMMARY_FULLSCREEN_SCALE)

    c.acceptButton:ClearAllPoints()
    c.acceptButton:SetPoint("BOTTOMRIGHT", c, "BOTTOMRIGHT", -48, 40)
    c.cancelButton:ClearAllPoints()
    c.cancelButton:SetPoint("BOTTOMRIGHT", c.acceptButton, "BOTTOMLEFT", -12, 0)
    c.replayButton:ClearAllPoints()
    c.replayButton:SetPoint("BOTTOM", c, "BOTTOM", 0, 40)

    self:applyIntroProgress(INTRO_DURATION)
end

local function layoutWindowed(self)
    local c = self.container

    self:stopAnimation()
    self.maxTextWidth = nil

    self.border:Show()
    self.overlayTop:Show()
    self.backdrop:Show()
    self.backdrop:ClearAllPoints()
    self.backdrop:SetPoint("TOPLEFT", self, "TOPLEFT", 48, -32)
    self.backdrop:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -48, 32)

    c:SetSize(950, 474)

    c.floaty:ClearAllPoints()
    c.floaty:SetSize(952, 474)
    c.floaty:SetPoint("TOP", c, "TOP", 0, 0)
    c.floaty.inset:Show()
    c.floaty:SetAlpha(1)

    c.stripeTop:Hide()
    c.stripeBottom:Hide()
    c.bandClip:Hide()
    c.brushClipTop:Hide()
    c.brushClipBottom:Hide()
    c.bandClip:SetAlpha(1)
    setBandBleed(self, 1)
    c.mapBG:SetAlpha(1)
    c.mapBG:SetParent(c)
    c.mapBG:ClearAllPoints()
    c.mapBG:SetSize(950, 475)
    c.mapBG:SetPoint("TOP", c, "TOP")
    c.mapBG:SetTexCoord(0, 1, 0, 1)

    c.blackout_head:ClearAllPoints()
    c.blackout_head:SetWidth(950)
    c.blackout_head:SetPoint("TOP", c, "TOP")
    c.blackout_fade:ClearAllPoints()
    c.blackout_fade:SetSize(950, 8)
    c.blackout_fade:SetPoint("BOTTOM", c.blackout_head, "BOTTOM", 0, -8)

    c.playerModel:ClearAllPoints()
    c.playerModel:SetSize(474, 474)
    c.playerModel:SetPoint("BOTTOMLEFT", c, "BOTTOMLEFT", 0, 1)

    c.giverModel:ClearAllPoints()
    c.giverModel:SetSize(700, 474)
    c.giverModel:SetPoint("BOTTOMRIGHT", c, "BOTTOMRIGHT", 0, 1)

    c.dialog:ClearAllPoints()
    c.dialog:SetSize(950, 374)
    c.dialog:SetPoint("CENTER", c, "CENTER", 0, -50)
    c.dialog:SetAlpha(1)
    c.dialog.blackout_feet:Show()
    c.dialog.text:ClearAllPoints()
    c.dialog.text:SetPoint("BOTTOM", c.dialog, "BOTTOM", 0, 10)

    c.summary:SetScale(1)
    c.summary:ClearAllPoints()
    c.summary:SetPoint("CENTER", c, "CENTER", 0, -50)

    c.acceptButton:ClearAllPoints()
    c.acceptButton:SetPoint("TOPLEFT", c, "BOTTOMLEFT", 5, 10)
    c.cancelButton:ClearAllPoints()
    c.cancelButton:SetPoint("TOPRIGHT", c, "BOTTOMRIGHT", -5, 10)
    c.replayButton:ClearAllPoints()
    c.replayButton:SetPoint("TOP", c, "BOTTOM", 0, 10)
end

function GwImmersiveQuestFrameMixin:applyLayout()
    local settings = GW.settings.immersiveQuesting
    self.isFullscreen = settings.fullscreen and true or false

    if self.isFullscreen then
        self:SetScale(UIParent:GetScale())
        self:SetFrameStrata("FULLSCREEN")
        self:SetSize(UIParent:GetWidth(), UIParent:GetHeight())
        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        layoutFullscreen(self, UIParent:GetWidth(), UIParent:GetHeight())
    else
        self:SetScale(UIParent:GetScale() * settings.scale)
        self:SetFrameStrata("HIGH")
        self:SetSize(WINDOWED_WIDTH, WINDOWED_HEIGHT)
        self:applySavedPosition()
        layoutWindowed(self)
    end

    self:applyTitleStyle()
    if self.isFullscreen then
        self.container.blackout_head:SetAlpha(0)
        self.container.blackout_fade:Hide()
        self.container.dialog.text:SetPoint("TOP", self.container.dialog, "TOP", 0, -(self.container.blackout_head:GetHeight() + 24))
    end
    self:applyLockFrame()
end

function GwImmersiveQuestFrameMixin:UiScaleChanged()
    self:applyLayout()
    self.container.playerModel:SetupModel()
    self.container.giverModel:SetupModel()
    if self:IsShown() then
        -- reload internal stuff
        self:showQuestFrame()
    end
    self.defer_ui_change = false
end

local function updateMap(self)
    self.mapId = C_Map.GetBestMapForUnit("player")
    if not self.mapId and self.update_map_attempt < 6 then
        self.update_map_attempt = self.update_map_attempt + 1
        C_Timer.After(0.5, function() updateMap(self) end)
    else
        self.update_map_attempt = 0
        self.update_map_mutex = false
    end
end

function GwImmersiveQuestFrameMixin:UpdateMapId()
    if self.update_map_mutex then
        return
    end
    self.update_map_mutex = true
    updateMap(self)
end

local pat_sep = "[\\.|!|?|\n]%s+"
local pat_uwu = "^<[^>]*>"
local function splitQuest(inputstr)
    local t = {}
    local i = 1

    -- cleanup and normalize the quest text
    inputstr = inputstr:gsub("%|n", "\n") -- normalize escape sequence to LF
    inputstr = inputstr:gsub("[\r\n]+", "\n") -- normalize to LF and collapse multi-line gaps
    inputstr = inputstr:gsub("^%s+", "") -- left trim whitespace
    inputstr = inputstr:gsub("%s+$", "") -- right trim whitespace
    inputstr = inputstr:gsub(" %s+", " ") -- collapse multi-space gaps to a single space
    inputstr = inputstr:gsub("%.%.%.", "…") -- normalize elipsis
    inputstr = inputstr:gsub("%-%-", "—") -- normalize emdash
    inputstr = inputstr:gsub("(%S)—(%S)", "%1 — %2") -- as above
    inputstr = inputstr:gsub(" Co%.", " Co;,;") -- change abbrev period into a pattern we fix back later
    inputstr = inputstr:gsub(" Mk%.", " Mk;,;")

    -- split a string by separators, clean up, and add uwu caps if needed
    local sepString = function(text, uwuflag)
        local sep_s, _ = text:find(pat_sep)
        local uwucap = uwuflag and "<" or ""
        local uwuend = uwuflag and ">" or ""
        if sep_s then
            t[i] = uwucap .. text:sub(1, sep_s):gsub("%s+$", ""):gsub(";,;", ".") .. uwuend
            i = i + 1
            text = text:sub(sep_s + 1):gsub("^%s+", "")
        else
            t[i] = uwucap .. text:gsub("%s+$", ""):gsub(";,;", ".") .. uwuend
            i = i + 1
            text = ""
        end
        return text
    end

    -- check for uwus and recursively split those
    while inputstr ~= "" do
        local uwu_s, uwu_e = inputstr:find(pat_uwu)
        if uwu_s then
            local uwustr = inputstr:sub(uwu_s + 1, uwu_e - 1)
            while uwustr ~= "" do
                uwustr = sepString(uwustr, true)
            end
            inputstr = inputstr:sub(uwu_e + 1):gsub("^%s+", "")
        else
            inputstr = sepString(inputstr)
        end
    end

    return t
end

function GwImmersiveQuestFrameMixin:questTextCompleted()
    if not self.container.summary:IsShown() and not self.container.summary:IsEmpty() then
        UIFrameFadeIn(self.container.summary, 0.1, 0, 1)
    end
    if self.questState == "COMPLETE" then
        self.container.acceptButton:SetText(COMPLETE_QUEST)
        self.container.acceptButton:Show()
    elseif self.questState == "PROGRESS" then
        if self.quest_can_turnin then
            self.container.acceptButton:SetText(CONTINUE)
            self.container.acceptButton:Show()
        else
            local lastLine = self.questString[self.questStringInt]
            if lastLine and string.sub(lastLine, -1) == "?" then
                self.container.playerModel:SetAction("no")
            end
            self.container.acceptButton:Hide()
        end
    else
        self.container.acceptButton:SetText(ACCEPT)
        self.container.acceptButton:Show()
    end
end

local MAX_TEXT_WIDTH = 750
function GwImmersiveQuestFrameMixin:setBalancedText(text)
    local t = self.container.dialog.text
    local maxWidth = self.maxTextWidth or MAX_TEXT_WIDTH
    t:SetWidth(maxWidth)
    t:SetText(text)
    local needed = t:GetStringWidth()
    if needed > (2 * maxWidth) then
        local balanced = math.floor(needed / 3) + 50
        if balanced < maxWidth then
            t:SetWidth(balanced)
        end
    elseif needed > maxWidth then
        local balanced = math.floor(needed / 2) + 50
        if balanced < maxWidth then
            t:SetWidth(balanced)
        end
    end
end

function GwImmersiveQuestFrameMixin:nextGossip()
    self.questStringInt = self.questStringInt + 1
    local qStringInt = self.questStringInt
    local count = #self.questString

    if qStringInt <= count then
        self:setBalancedText(self.questString[qStringInt])
        self.container.giverModel:setQuestGiverAnimation(count, self.questString, qStringInt)
        if qStringInt ~= 1 then
            PlaySound(906)
        end
        if qStringInt == count then
            self:questTextCompleted()
        else
            self.container.acceptButton:SetText(GW.L["Skip to End"])
            self.container.acceptButton:Show()
        end
    else
        self.questStringInt = count
        self:questTextCompleted()
    end
end

function GwImmersiveQuestFrameMixin:prevGossip()
    if self.questStringInt == 1 then
        return
    end
    self:StopFollowingSpoken()
    self.questStringInt = max(self.questStringInt - 1, 1)
    local qStringInt = self.questStringInt
    local count = #self.questString

    if qStringInt <= count then
        self:setBalancedText(self.questString[qStringInt])
        self.container.giverModel:setQuestGiverAnimation(count, self.questString, qStringInt)
        if qStringInt ~= 1 then
            PlaySound(906)
        end
        self.container.acceptButton:SetText(GW.L["Skip to End"])
        self.container.acceptButton:Show()
        if self.questState ~= "PROGRESS" then
            self.container.summary:Hide()
        end
    else
        self:questTextCompleted()
    end
end

function GwImmersiveQuestFrameMixin:HideBlizzQuestFrame()
    -- cannot actually hide it as we are stealing its elements/events and need it
    -- to remain technically shown for the duration
    QuestFrame:SetAlpha(0.0)
end

function GwImmersiveQuestFrameMixin:UnhideBlizzQuestFrame()
    QuestFrame:SetAlpha(1.0)
end

local default_map = "Misc/default"
local function getMapBackground(self)
    local map_id = (self.mapId ~= 0 and self.mapId) or C_Map.GetBestMapForUnit("player") or 0
    if map_id == 0 then
        GW.Debug("map - no id:", map_id)
        return default_map
    end
    local map_bg
    repeat
        local map = C_Map.GetMapInfo(map_id)
        if map then
            GW.Debug("map - id:", map.mapID, "| name:", map.name, "| type:", map.mapType, "| parent:", map.parentMapID)
            if map.mapType == Enum.UIMapType.Dungeon or map.mapType == Enum.UIMapType.Orphan then
                local _, _, _, _, _, _, _, instanceID, _ = GetInstanceInfo()
                GW.Debug("map - instance id:", instanceID)
                map_bg = instanceBGs[instanceID]
            end
            if not map_bg then
                map_bg = mapBGs[map.mapID] or mapBGs[map.parentMapID]
            end
            map_id = map.parentMapID
        end
    until not map or map_bg or map.parentMapID == 0
    return map_bg or default_map
end

function GwImmersiveQuestFrameMixin:showQuestFrame()
    local map_bg = getMapBackground(self)
    local bandPath = "Interface/AddOns/GW2_UI/textures/questview/backgrounds/" .. map_bg .. ".jpg"
    self.container.mapBG:SetTexture(bandPath)
    self:setBleedTexture(bandPath)

    self.container.floaty.title:SetText(GetTitleText())

    local npc_name, _ = UnitName("questnpc")
    if canaccessvalue and not canaccessvalue(npc_name) then
        -- in some situations we cannot read this secret value, everything that
        -- checks this should have functional (though sometimes ugly) fallbacks
        npc_name = "Secret Value"
    end
    local is_self = UnitIsUnit("questnpc", "player")
    local is_dead = UnitIsDead("questnpc")

    local PC_kit = self.recent_player_choice and PlayerChoiceFrame and PlayerChoiceFrame.uiTextureKit
    GW.Debug("quest giver - name:", npc_name, "| self:", is_self, "| dead:", is_dead, "| PC_kit:", PC_kit)

    self:Show()

    local pm = self.container.playerModel
    local gm = self.container.giverModel
    if GW.Retail and is_self and PC_kit then
        -- a recent player choice popup was made, use the relevant kit/board
        gm:SetBoardUnit(PC_kit, self.mapId)
    elseif is_self then
        -- typical for auto-accepted quests, story pushes, etc.; have the player read a scroll
        pm:SetAction("read")
    elseif is_dead then
        -- quest giver is a dead NPC; have the player kneel
        pm:SetAction("kneel")
    else
        -- attempt to set the questnpc unit, check for success
        local did_set_unit = gm:SetQuestUnit()
        GW.Debug("attempted set unit:", did_set_unit)
        if not did_set_unit then
            -- could not set the model automatically, try to figure out some common cases
            -- (TODO: some of these use English localized names, which only works for English clients)
            if GW.NotSecretValue(npc_name) then
                if npc_name == "Warchief's Command Board" then
                    gm:SetBoardUnit("horde")
                elseif npc_name == "Hero's Call Board" then
                    gm:SetBoardUnit("alliance")
                elseif object_types[npc_name] then
                    gm:SetModelUnit(object_types[npc_name])
                else
                    -- if we can't figure out a better option, have the player read a scroll
                    pm:SetAction("read")
                end
            else
                pm:SetAction("read")
            end
        end
    end
end

function GwImmersiveQuestFrameMixin:clearDialog()
    if (self.questString) then
        wipe(self.questString)
        wipe(self.questReqText)
    else
        self.questString = {}
        self.questReqText = {}
    end
    self.questStringInt = 0
end

function GwImmersiveQuestFrameMixin:clearQuestReq()
    self.questState = "NONE"
    self.was_showing = false
    self.quest_id = nil
    self.quest_idx = nil
    self.quest_can_turnin = false
    self.update_map_attempt = 0
    self.update_map_mutex = false
    self:clearDialog()
    self:ResetSpokenSync()
    self.container.summary:ClearInfo()
    self.container.summary:Hide()
    self.container.acceptButton:SetText(CONTINUE)
    self.container.acceptButton:Hide()
    self.container.cancelButton:SetText(CANCEL)
    self.container.cancelButton:Hide()
end

-- the dialog only takes the keyboard out of combat: in combat the key propagation can't be switched,
-- the dialog would keep the keys of the player
local function EnableDialogKeys(self, enable)
    self:EnableKeyboard(enable)
    if enable then
        self:SetPropagateKeyboardInput(true)
    end
end

function GwImmersiveQuestFrameMixin:OnShow()
    if _G.GwImmersiveQuestDebugFrame then
        _G.GwImmersiveQuestDebugFrame:Show()
    end
    if not InCombatLockdown() then
        EnableDialogKeys(self, true)
    end
    self:SetScript("OnKeyDown", self.OnKeyDown)
    if self.was_showing then
        -- this was just a temporary hide from the load/cinematic handler, don't setup
        return
    end
    self.container.FadeIn:Play()
    if self.isFullscreen then
        self:playIntro()
    end
end

function GwImmersiveQuestFrameMixin:OnHide()
    if _G.GwImmersiveQuestDebugFrame then
        _G.GwImmersiveQuestDebugFrame:Hide()
    end
    self:EnableKeyboard(false)
    self:SetScript("OnKeyDown", nil)
    if self.was_showing then
        -- this is just a temporary hide from the load/cinematic handler, don't clean up
        return
    end
    self.container.summary:ReleaseRewards()
    self:UnhideBlizzQuestFrame()
end

local function getQuestIndex(quest_id)
    if C_QuestLog.GetLogIndexForQuestID then
        return C_QuestLog.GetLogIndexForQuestID(quest_id)
    else
        return GetQuestLogIndexByID(quest_id)
    end
end

local function deferShow(self)
    if self.in_cine or self.in_load then
        -- defer actually opening this frame until after load/cinematic finishes
        self.needs_showing = true
    else
        self.needs_showing = false
        if self.fadingOut then
            self:stopAnimation()
            self:showQuestFrame()
        elseif not self:IsShown() then
            self:showQuestFrame()
        end
        self:nextGossip()
        self:RefreshSpokenFollow()
    end
end

function GwImmersiveQuestFrameMixin:evQuestProgress()
    self:StopSpokenGreeting()
    self:HideBlizzQuestFrame()
    self:clearQuestReq()

    self.questState = "PROGRESS"
    self.quest_id = GetQuestID()
    self.quest_idx = getQuestIndex(self.quest_id)
    self.quest_can_turnin = IsQuestCompletable()
    GW.Debug("progress - questID:", self.quest_id, "| index:", self.quest_idx)
    if self.quest_idx then
        local _, objective_text = GetQuestLogQuestText(self.quest_idx)
        self.container.summary:SetObjectiveText(objective_text)
    end
    self.container.summary:UpdateInfo(self.quest_id, self.quest_idx, self.questState)
    self.questString = splitQuest(GetProgressText())
    self.container.cancelButton:SetShown(not QuestFrame.autoQuest)
    self.container.cancelButton:SetText(CANCEL)

    UIFrameFadeIn(self.container.summary, 0.1, 0, 1)
    deferShow(self)
end

function GwImmersiveQuestFrameMixin:evQuestDetail(questStartItemID)
    if not QuestFrame:IsShown() then
        return
    end
    self:StopSpokenGreeting()
    -- blizzard writes its hidden quest text out before it shows the rewards, with a sound each frame
    if QuestFrameDetailPanel.fading then
        QuestFrameDetailPanel.fadingProgress = 1024
    end
    if self.questState ~= "COMPLETING" then
        self:HideBlizzQuestFrame()
        self:clearQuestReq()
        self.questState = "OFFER"
        self.container.cancelButton:SetText(DECLINE)
    else
        self.questStringInt = 0
        self.container.cancelButton:SetText(CANCEL)
    end
    self.container.cancelButton:SetShown(not QuestFrame.autoQuest)
    self.quest_id = GetQuestID()
    self.quest_idx = getQuestIndex(self.quest_id)
    GW.Debug("detail - questID:", self.quest_id, "| index:", self.quest_idx, "| auto:", QuestFrame.autoQuest)
    self.container.summary:SetObjectiveText(GetObjectiveText())
    self.container.summary:UpdateInfo(self.quest_id, self.quest_idx, self.questState)
    self.questString = splitQuest(GetQuestText())
    if self.questState ~= "COMPLETING" and not self.container.summary:IsEmpty() then
        tinsert(self.questString, "")
    end
    deferShow(self)
end

function GwImmersiveQuestFrameMixin:evQuestComplete()
    self:StopSpokenGreeting()
    if (self.questState ~= "COMPLETING") then
        self:HideBlizzQuestFrame()
        self:clearQuestReq()
    else
        self.questStringInt = 0
    end
    self.container.cancelButton:SetText(CANCEL)
    self.container.cancelButton:SetShown(not QuestFrame.autoQuest)
    self.questState = "COMPLETE"
    self.quest_id = GetQuestID()
    self.quest_idx = getQuestIndex(self.quest_id)
    GW.Debug("complete - questID:", self.quest_id, "| index:", self.quest_idx, "| auto:", QuestFrame.autoQuest)
    self.container.summary:ClearInfo()
    self.container.summary:UpdateInfo(self.quest_id, self.quest_idx, self.questState)
    self.questString = splitQuest(GetRewardText())
    local qText = self.questReqText
    if (#qText > 0) then
        for i = #qText, 1, -1 do
            tinsert(self.questString, 1, qText[i])
        end
    end
    deferShow(self)
end

function GwImmersiveQuestFrameMixin:evQuestFinished()
    if self.questState ~= "COMPLETING" then
        self:clearQuestReq()
        self:Hide()
    end
    -- else, we expect a QUEST_COMPLETE event to follow shortly
end

local function acceptQuest(self)
    if (QuestFlagsPVP()) then
        QuestFrame.dialog = StaticPopup_Show("CONFIRM_ACCEPT_PVP_QUEST")
    else
        if (QuestFrame.autoQuest) then
            AcknowledgeAutoAcceptQuest()
        else
            AcceptQuest()
            CloseQuest()
        end
    end
    if self:IsShown() then
        self:Hide()
    end
end

local function turnInQuest(self)
    self.questState = "COMPLETING"
    self:clearDialog()
    self.container.summary:ClearInfo()
    self.container.summary:Hide()
    self.container.acceptButton:Hide()
    self.container.cancelButton:Hide()
    self.container.playerModel:SetAction("yes")
    CompleteQuest()
end

local function completeQuest(self)
    if (GetNumQuestChoices() == 0) then
        GetQuestReward(0)
        CloseQuest()
    elseif (GetNumQuestChoices() == 1) then
        GetQuestReward(1)
        CloseQuest()
    else
        if (QuestInfoFrame.itemChoice == 0) then
            QuestChooseRewardError()
        else
            GetQuestReward(QuestInfoFrame.itemChoice)
            CloseQuest()
        end
    end
end

local function advance(self, is_click, skip_to_end)
    local count = #self.questString
    local click_accept = GW.settings.immersiveQuesting.clickAccept
    if self.questStringInt < count then
        if skip_to_end then
            self.questStringInt = count - 1
        end
        self:nextGossip()
    else
        if self.questState == "PROGRESS" then
            if self.quest_can_turnin then
                turnInQuest(self)
            end
        elseif self.questState == "OFFER" then
            if not is_click or click_accept then
                acceptQuest(self)
            end
        elseif self.questState == "COMPLETE" then
            if not is_click or click_accept then
                completeQuest(self)
            end
        end
    end
end

function GwImmersiveQuestFrameMixin:OnKeyDown(key)
    local inCombat = InCombatLockdown()
    local interact1, interact2 = GetBindingKey("INTERACTTARGET")
    if key == "SPACE" or ((key == interact1 and interact1 ~= nil) or (key == interact2 and interact2 ~= nil)) then
        if not inCombat then
            self:SetPropagateKeyboardInput(false)
        end
        advance(self)
    elseif key == "BACKSPACE" then
        if not inCombat then
            self:SetPropagateKeyboardInput(false)
        end
        self:prevGossip()
    elseif not inCombat then
        self:SetPropagateKeyboardInput(true)
    end
end

local function dialog_OnMouseUp(self, button, isInside)
    if not isInside or (button ~= "LeftButton" and button ~= "RightButton") then
        return
    end
    local qview = self:GetParent():GetParent()
    if button == "RightButton" then
        qview:prevGossip()
    else
        advance(qview, true)
    end
end

local function accept_OnClick(self)
    local qview = self:GetParent():GetParent()
    advance(qview, false, true)
end

local function cancel_OnClick()
    CloseQuest()
end

local function deferredHide(self)
    if self:IsShown() then
        self.was_showing = true
        self:Hide()
    else
        self.was_showing = false
    end
end

local function deferredShow(self)
    if self.in_cine or self.in_load then
        return
    end
    if self.was_showing then
        self:Show()
        C_Timer.After(0, function() self.was_showing = false end)
    elseif self.needs_showing then
        self.needs_showing = false
        self:HideBlizzQuestFrame()
        -- usually this path happens because a cinematic finished
        -- whatever re-shows the UI is probably doing a timed fadein
        -- so we need to re-hide the quest window again just in case
        C_Timer.After(0.11, function() self:HideBlizzQuestFrame() end)
        self:showQuestFrame()
        self:nextGossip()
    end
end

function GwImmersiveQuestFrameMixin:OnEvent(event, ...)
    GW.Debug("event handling", event, ...)
    if event == "ADDON_LOADED" then
        self:evAddonLoaded(...)
    elseif event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
        if not self.defer_ui_change then
            -- pause one frame for cvars but don't queue multiple of these
            self.defer_ui_change = true
            C_Timer.After(0, function() self:UiScaleChanged() end)
        end
    elseif event == "LOADING_SCREEN_ENABLED" then
        self.in_load = true
        deferredHide(self)
    elseif event == "LOADING_SCREEN_DISABLED" then
        self.in_load = false
        self:UpdateMapId()
        deferredShow(self)
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
        self:UpdateMapId()
    elseif event == "QUEST_PROGRESS" then
        self:evQuestProgress()
    elseif event == "QUEST_DETAIL" then
        self:evQuestDetail(...)
    elseif event == "QUEST_COMPLETE" then
        self:evQuestComplete()
    elseif event == "QUEST_FINISHED" then
        self:evQuestFinished()
    elseif event == "CINEMATIC_START" then
        local is_real = select(1, ...)
        if is_real then
            self.in_cine = true
            deferredHide(self)
        end
    elseif event == "CINEMATIC_STOP" then
        self.in_cine = false
        deferredShow(self)
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        if self:IsShown() then
            EnableDialogKeys(self, event == "PLAYER_REGEN_ENABLED")
        end
    elseif event == "PLAYER_CHOICE_CLOSE" then
        self.recent_player_choice = true
        C_Timer.After(2, function () self.recent_player_choice = false end)
    end
end

function GwImmersiveQuestFrameMixin:OnDragStop()
    self:StopMovingOrSizing()
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    local pos = GW.settings.immersiveQuesting.pos
    local sf = GW.settings.immersiveQuesting.scale
    pos.point = point
    pos.relativePoint = relativePoint
    pos.xOfs = xOfs * sf
    pos.yOfs = yOfs * sf
    pos.hasMoved = true
end

function GwImmersiveQuestFrameMixin:applySavedPosition()
    local pos = GW.settings.immersiveQuesting.pos
    local sf = GW.settings.immersiveQuesting.scale
    self:ClearAllPoints()
    if pos.hasMoved then
        self:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs / sf, pos.yOfs / sf)
    else
        self:SetPoint("CENTER", UIParent, "CENTER")
    end
end

function GwImmersiveQuestFrameMixin:resetPosition()
    GW.settings.immersiveQuesting.pos.hasMoved = false
    self:applySavedPosition()
end

function GwImmersiveQuestFrameMixin:applyLockFrame()
    local lf = GW.settings.immersiveQuesting.lockFrame or GW.settings.immersiveQuesting.fullscreen
    if not lf then
        self:RegisterForDrag("LeftButton")
        self:SetScript("OnDragStart", self.StartMoving)
        self:SetScript("OnDragStop", self.OnDragStop)
    else
        self:SetScript("OnDragStart", nil)
        self:SetScript("OnDragStop", nil)
        self:RegisterForDrag()
    end
end

function GwImmersiveQuestFrameMixin:applyTitleStyle()
    local style = GW.settings.immersiveQuesting.titleStyle
    if style == "THIN" then
        self.container.blackout_head:SetHeight(48)
        self.container.blackout_head:SetAlpha(1.0)
        self.container.blackout_fade:Show()
        self.container.floaty.title:SetHeight(48)
    elseif style == "TRANSPARENT" then
        self.container.blackout_head:SetHeight(80)
        self.container.blackout_head:SetAlpha(0.0)
        self.container.blackout_fade:Hide()
        self.container.floaty.title:SetHeight(80)
    else
        self.container.blackout_head:SetHeight(96)
        self.container.blackout_head:SetAlpha(1.0)
        self.container.blackout_fade:Show()
        self.container.floaty.title:SetHeight(96)
    end
end

function GW.LoadImmersiveQuesting()
    if not GW.settings.immersiveQuesting.enabled or GW.ShouldBlockIncompatibleAddon("ImmersiveQuesting") then return end

    local frame = CreateFrame("Frame", "GwImmersiveQuestFrame", nil, "GwImmersiveQuestFrameTemplate")
    frame.mapId = 0
    frame.updateAttempts = 0
    frame.animationDriver = CreateFrame("Frame", nil, frame)
    frame.HideNow = frame.Hide
    frame.Hide = frame.HideWithOutro

    frame.border:SetTextureSliceMargins(32, 32, 32, 32)
    frame.border:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    frame.container.floaty.inset:SetTextureSliceMargins(64, 64, 64, 64)
    frame.container.floaty.inset:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)

    frame:UiScaleChanged()
    frame:applyLockFrame()
    frame:applyTitleStyle()

    frame:SetScript("OnShow", frame.OnShow)
    frame:SetScript("OnHide", frame.OnHide)
    frame:SetScript("OnEvent", frame.OnEvent)

    frame:RegisterEvent("UI_SCALE_CHANGED")
    frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
    frame:RegisterEvent("LOADING_SCREEN_DISABLED")
    frame:RegisterEvent("LOADING_SCREEN_ENABLED")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    frame:RegisterEvent("ZONE_CHANGED")
    frame:RegisterEvent("ZONE_CHANGED_INDOORS")
    frame:RegisterEvent("QUEST_DETAIL")
    frame:RegisterEvent("QUEST_FINISHED")
    frame:RegisterEvent("QUEST_COMPLETE")
    frame:RegisterEvent("QUEST_PROGRESS")
    frame:RegisterEvent("CINEMATIC_START")
    frame:RegisterEvent("CINEMATIC_STOP")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    if GW.Retail then
        frame:RegisterEvent("PLAYER_CHOICE_CLOSE")
        frame:RegisterEvent("PLAYER_CHOICE_UPDATE")
    end

    frame.container.dialog:SetScript("OnMouseUp", dialog_OnMouseUp)
    frame.container.cancelButton:SetScript("OnClick", cancel_OnClick)
    frame.container.acceptButton:SetScript("OnClick", accept_OnClick)

    frame:clearQuestReq()
    GW.Gamepad.RegisterWindow(frame, {
        -- blizzards quest frame stays shown behind ours
        replaces = QuestFrame,
        startButton = function(f)
            return f.container.acceptButton:IsShown() and f.container.acceptButton or f.container.dialog
        end,
        bindings = {PAD3 = frame.container.acceptButton},
        icons = {PAD2 = frame.container.cancelButton},
        legend = {
            {"PAD1", ACTION_LABEL_SELECT},
            {"DIRPAD", FRAME_ACTION_NAVIGATE},
            {"PAD2", FRAME_ACTION_CLOSE},
        },
    })
    frame.SmartNavigationCloseHandler = function()
        CloseQuest()
        return true
    end
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame.container.playerModel:OnLoad()
    GW.LoadSpokenSync(frame)

    --GW.LoadImmersiveQuestionDebugFrame()
end
