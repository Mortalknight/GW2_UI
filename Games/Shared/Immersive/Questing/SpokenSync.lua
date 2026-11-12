---@class GW2
local GW = select(2, ...)

local function getSpoken()
    local spoken = _G.Spoken
    if spoken and spoken.GetCaption and spoken.SplitCaption and spoken.WordMarks then
        return spoken
    end
end

function GwImmersiveQuestFrameMixin:SpokenEnabled()
    return GW.settings.immersiveQuesting.spokenSync and getSpoken() ~= nil
end

function GwImmersiveQuestFrameMixin:ResetSpokenSync()
    self.spokenClip = nil
    self.spokenMap = nil
    self.spokenPages = nil
    self.spokenFollow = true
    self.container.replayButton:Hide()
end

local function alignClip(self, spoken, caption)
    self.spokenClip = caption.clip
    self.spokenMap = false
    local marks = spoken:WordMarks()
    local paragraphs, pages = {}, {}
    for index, sentence in ipairs(self.questString) do
        local words = spoken:SplitCaption(sentence)
        if words and #words > 0 then
            paragraphs[#paragraphs + 1] = { text = sentence, words = marks.MarkLinks(sentence, words) }
            pages[#paragraphs] = index
        end
    end
    if #paragraphs == 0 then
        return
    end
    local map = marks.Align(caption.words, paragraphs)
    if map then
        self.spokenMap = map
        self.spokenPages = pages
        self.container.replayButton:Show()
    end
end

local function pageForWord(self, wordIndex)
    local map = self.spokenMap
    for index = wordIndex, 1, -1 do
        local hit = map[index]
        if hit then
            return self.spokenPages[hit.p]
        end
    end
end

function GwImmersiveQuestFrameMixin:OnSpokenClipStopped(clip, finishedPlaying)
    if not finishedPlaying or clip ~= self.spokenClip or not self.spokenMap or not self.spokenFollow then
        return
    end
    if not self:IsShown() or not self:SpokenEnabled() then
        return
    end
    local count = #self.questString
    if self.questStringInt < count then
        self.questStringInt = count - 1
        self:nextGossip()
    end
end

function GwImmersiveQuestFrameMixin:SpokenTick()
    if not self:SpokenEnabled() or not self.questString or #self.questString == 0 then
        return
    end
    local spoken = getSpoken()
    if not self.spokenCallback and spoken.RegisterCallback then
        self.spokenCallback = spoken:RegisterCallback("CLIP_STOPPED", function(clip, finishedPlaying)
            self:OnSpokenClipStopped(clip, finishedPlaying)
        end)
    end
    local caption = spoken:GetCaption()
    if not caption or not caption.words or caption.clip.textOnly then
        return
    end
    if caption.clip ~= self.spokenClip then
        self.spokenFollow = true
        alignClip(self, spoken, caption)
    end
    if not self.spokenMap or not self.spokenFollow or not caption.speaking or not caption.activeWord then
        return
    end
    local page = pageForWord(self, caption.activeWord)
    if not page then
        return
    end
    local count = #self.questString
    while self.questStringInt < page and self.questStringInt < count do
        self:nextGossip()
    end
end

function GwImmersiveQuestFrameMixin:ReplaySpoken()
    local spoken = getSpoken()
    local clip = self.spokenClip
    if not spoken or not clip or not clip.source then
        return
    end
    pcall(clip.source.Remove, clip.source, clip)
    local ok = pcall(clip.source.Enqueue, clip.source, clip, true)
    if not ok then
        return
    end
    self.spokenClip = nil
    self.spokenFollow = true
    self.questStringInt = 0
    self:nextGossip()
end

function GwImmersiveQuestFrameMixin:StopFollowingSpoken()
    self.spokenFollow = false
end

local narratorHost
local narratorHidden = false
local gossipOpen = false

local function dialogCoversNarrator()
    local immersive = _G.GwImmersiveQuestFrame
    if immersive and immersive:IsShown() then
        return true
    end
    if gossipOpen and GW.settings.skins.gossip.enabled then
        return true
    end
    local greeting = _G.QuestFrameGreetingPanel
    return greeting ~= nil and greeting:IsVisible() and GW.settings.skins.questLog.enabled
end

local function updateNarrator()
    local spoken = getSpoken()
    if not spoken or not spoken.SetPlayerHost then
        return
    end
    local want = GW.settings.immersiveQuesting.spokenSync
        and not C_AddOns.IsAddOnLoaded("DialogueUI")
        and dialogCoversNarrator()
    if want and not narratorHidden then
        if not narratorHost then
            narratorHost = CreateFrame("Frame", nil, UIParent)
            narratorHost:Hide()
        end
        spoken:SetPlayerHost(narratorHost)
        narratorHidden = true
    elseif not want and narratorHidden then
        spoken:SetPlayerHost(nil)
        narratorHidden = false
    end
end

local function scheduleNarratorUpdate()
    C_Timer.After(0, updateNarrator)
end

function GwImmersiveQuestFrameMixin:UpdateSpokenNarrator()
    scheduleNarratorUpdate()
end

function GW.LoadSpokenNarratorHiding()
    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("GOSSIP_SHOW")
    watcher:RegisterEvent("GOSSIP_CLOSED")
    watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    watcher:SetScript("OnEvent", function(_, event)
        gossipOpen = event == "GOSSIP_SHOW"
        scheduleNarratorUpdate()
    end)
    local greeting = _G.QuestFrameGreetingPanel
    if greeting then
        greeting:HookScript("OnShow", scheduleNarratorUpdate)
        greeting:HookScript("OnHide", scheduleNarratorUpdate)
    end
end
