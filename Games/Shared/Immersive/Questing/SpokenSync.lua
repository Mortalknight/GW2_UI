---@class GW2
local GW = select(2, ...)

local function getSpoken()
    local spoken = _G.Spoken
    if spoken and spoken.GetCaption and spoken.SplitCaption and spoken.WordMarks and spoken.RegisterCallback then
        return spoken
    end
end

local function syncEnabled()
    return GW.settings.immersiveQuesting.spokenSync
end

local function createFollower(target)
    local follower = { follow = true, timers = {} }

    local function cancelTimers()
        for _, timer in ipairs(follower.timers) do
            timer:Cancel()
        end
        wipe(follower.timers)
    end

    local function align(spoken, caption)
        follower.clip = caption.clip
        follower.map = false
        follower.firstWord = nil
        local marks = spoken:WordMarks()
        local paragraphs, indexes = {}, {}
        for index, text in ipairs(target.pages()) do
            local words = spoken:SplitCaption(text)
            if words and #words > 0 then
                paragraphs[#paragraphs + 1] = { text = text, words = marks.MarkLinks(text, words) }
                indexes[#paragraphs] = index
            end
        end
        if #paragraphs == 0 then
            return
        end
        local map = marks.Align(caption.words, paragraphs)
        if not map then
            return
        end
        local firstWord = {}
        for wordIndex = 1, #caption.words do
            local hit = map[wordIndex]
            local page = hit and indexes[hit.p]
            if page and not firstWord[page] then
                firstWord[page] = wordIndex
            end
        end
        follower.map = map
        follower.firstWord = firstWord
    end

    local function turnTo(page)
        local current = target.current()
        if follower.lastIndex and current < follower.lastIndex then
            follower.follow = false
        end
        if not follower.follow or not target.active() or page <= current then
            return
        end
        target.goTo(page)
        follower.lastIndex = target.current()
    end

    function follower.Reset()
        cancelTimers()
        follower.clip = nil
        follower.map = nil
        follower.firstWord = nil
        follower.lastIndex = nil
        follower.follow = true
    end

    function follower.Refresh()
        cancelTimers()
        local spoken = getSpoken()
        if not spoken or not syncEnabled() or not target.active() then
            return
        end
        local caption = spoken:GetCaption()
        if not caption or not caption.words or caption.clip.textOnly then
            return
        end
        if caption.clip ~= follower.clip then
            follower.follow = true
            follower.lastIndex = nil
            align(spoken, caption)
        end
        if not follower.map or not follower.follow or not caption.speaking then
            return
        end
        local length = tonumber(caption.clip.length)
        local progress = caption.progress
        local totalWeight = caption.totalWeight
        if not length or length <= 0 or not progress or not totalWeight or totalWeight <= 0 then
            return
        end
        follower.lastIndex = follower.lastIndex or target.current()
        local nextImmediate = 0
        for page, wordIndex in pairs(follower.firstWord) do
            local delay = (caption.words[wordIndex].start / totalWeight - progress) * length
            if delay <= 0 then
                nextImmediate = math.max(nextImmediate, page)
            else
                follower.timers[#follower.timers + 1] = C_Timer.NewTimer(delay, function()
                    turnTo(page)
                end)
            end
        end
        if nextImmediate > 0 then
            turnTo(nextImmediate)
        end
    end

    return follower
end

function GwImmersiveQuestFrameMixin:SpokenEnabled()
    return syncEnabled() and getSpoken() ~= nil
end

function GwImmersiveQuestFrameMixin:ResetSpokenSync()
    if self.spokenFollower then
        self.spokenFollower.Reset()
    end
    self.container.replayButton:Hide()
end

function GwImmersiveQuestFrameMixin:StopFollowingSpoken()
    if self.spokenFollower then
        self.spokenFollower.follow = false
    end
end

function GwImmersiveQuestFrameMixin:RefreshSpokenFollow()
    if self.refreshSpoken then
        self.refreshSpoken()
    end
end

function GwImmersiveQuestFrameMixin:ReplaySpoken()
    local spoken = getSpoken()
    local follower = self.spokenFollower
    if not spoken or not follower or not follower.clip or spoken:GetCurrent() ~= follower.clip then
        return
    end
    spoken:Pause()
    spoken:Resume()
    follower.follow = true
    follower.lastIndex = nil
    self.questStringInt = 0
    self:nextGossip()
    if self.questState ~= "PROGRESS" then
        self.container.summary:Hide()
    end
end

function GwImmersiveQuestFrameMixin:StopSpokenGreeting()
    if not self:SpokenEnabled() or not GW.settings.immersiveQuesting.spokenSkipGreeting then
        return
    end
    local spoken = getSpoken()
    local gossip = spoken.GetSource and spoken:GetSource("gossip")
    if gossip and gossip.StopAll then
        gossip:StopAll()
    end
end

function GW.LoadSpokenSync(frame)
    local spoken = getSpoken()
    if not spoken or not C_AddOns.IsAddOnLoaded("Spoken") then
        return
    end

    local gossipOpen = false

    local questFollower = createFollower({
        active = function()
            return frame:IsShown() and frame.questString ~= nil and #frame.questString > 0
        end,
        pages = function()
            return frame.questString
        end,
        current = function()
            return frame.questStringInt
        end,
        goTo = function(page)
            local count = #frame.questString
            while frame.questStringInt < page and frame.questStringInt < count do
                frame:nextGossip()
            end
        end,
    })
    frame.spokenFollower = questFollower

    local gossipFollower = createFollower({
        active = function()
            return gossipOpen and GW.settings.skins.gossip.enabled and GW.GetGossipGreetingPages ~= nil
        end,
        pages = function()
            return (GW.GetGossipGreetingPages()) or {}
        end,
        current = function()
            local _, index = GW.GetGossipGreetingPages()
            return index or 0
        end,
        goTo = function(page)
            GW.SetGossipGreetingPage(page)
        end,
    })

    local function updateReplayButton()
        local show = syncEnabled() and frame:IsShown() and questFollower.map and questFollower.clip ~= nil
            and spoken:GetCurrent() == questFollower.clip
        frame.container.replayButton:SetShown(show and true or false)
    end

    local refreshPending = false
    local function refresh()
        if refreshPending then
            return
        end
        refreshPending = true
        C_Timer.After(0, function()
            refreshPending = false
            questFollower.Refresh()
            gossipFollower.Refresh()
            updateReplayButton()
        end)
    end
    frame.refreshSpoken = refresh

    frame.container.replayButton:SetText(GW.L["Replay Voice"])
    frame.container.replayButton:SetScript("OnClick", function()
        frame:ReplaySpoken()
    end)

    spoken:RegisterCallback("CLIP_STARTED", refresh)
    spoken:RegisterCallback("AUDIO_CHANGED", refresh)
    spoken:RegisterCallback("CLIP_STOPPED", function(clip, finishedPlaying)
        if finishedPlaying and clip == questFollower.clip and questFollower.map and questFollower.follow
            and frame:IsShown() and syncEnabled() then
            local count = #frame.questString
            if frame.questStringInt < count then
                frame.questStringInt = count - 1
                frame:nextGossip()
            end
        end
        refresh()
    end)

    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("GOSSIP_SHOW")
    watcher:RegisterEvent("GOSSIP_CLOSED")
    watcher:SetScript("OnEvent", function(_, event)
        gossipOpen = event == "GOSSIP_SHOW"
        gossipFollower.Reset()
        refresh()
    end)
end
