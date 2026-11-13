---@class GW2
local GW = select(2, ...)

local ImmersiveQuest = {}
local Gossip = {}
local API = {
    VERSION = 1,
    ImmersiveQuest = ImmersiveQuest,
    Gossip = Gossip,
}
GW.PublicAPI = API
GW2_UI_API = API

local function copyList(list)
    local copy = {}
    for index = 1, #list do
        copy[index] = list[index]
    end
    return copy
end
API.CopyList = copyList

function API.Fire(event, ...)
    if EventRegistry then
        EventRegistry:TriggerEvent(event, ...)
    end
end

function ImmersiveQuest.GetFrame()
    return _G.GwImmersiveQuestFrame
end

function ImmersiveQuest.GetPages()
    local frame = _G.GwImmersiveQuestFrame
    if not frame or not frame.questString then
        return {}
    end
    return copyList(frame.questString)
end

function ImmersiveQuest.GetPage()
    local frame = _G.GwImmersiveQuestFrame
    return frame and frame.questStringInt or 0
end

function ImmersiveQuest.GoToPage(page)
    local frame = _G.GwImmersiveQuestFrame
    if not frame or not frame:IsShown() or not frame.questString or #frame.questString == 0 then
        return
    end
    page = math.max(1, math.min(page, #frame.questString))
    while frame.questStringInt < page do
        frame:nextGossip()
    end
    while frame.questStringInt > page do
        frame:prevGossip()
    end
end
