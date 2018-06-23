local _, GW = ...
local CountTable = GW.CountTable

local bubbles = {}
local CHAT_BUBBLES_ACTIVE = {}
local safeToChange = false

local function getBubbles(msg)
    local bi

    for i = 1, WorldFrame:GetNumChildren() do
        local v = select(i, WorldFrame:GetChildren())
        local b = v:GetBackdrop()
        local p = v:IsProtected()
        if b ~= nill and not p then
            if
                b.bgFile == "Interface\\Tooltips\\ChatBubble-Background" or
                    b.bgFile == "Interface\\AddOns\\GW2_UI\\textures\\ChatBubble-Background"
             then
                for k = 1, v:GetNumRegions() do
                    local frame = v
                    local v2 = select(k, v:GetRegions())
                    if v2:GetObjectType() == "FontString" then
                        if frame.hasBeenStyled == nil then
                            bi = CountTable(bubbles)
                            local fontstring = v2

                            bubbles[bi] = {}
                            bubbles[bi]["frame"] = frame
                            bubbles[bi]["fontstring"] = fontstring
                            bubbles[bi]["bgFile"] = b.bgFile
                            return bubbles[bi]
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function update_gwChat_bubbles(msg)
    getBubbles(msg)

    for k, v in pairs(bubbles) do
        local bgFrame = v["frame"]
        local fontString = v["fontstring"]
        b = v["bgFile"]

        if fontString ~= nil then
            fontString:SetFont(DAMAGE_TEXT_FONT, 14)
            fontString:SetTextColor(0, 0, 0)

            if bgFrame.hasBeenStyled == nil then
                local backdrop = nil
                bgFrame:SetBackdrop(backdrop)

                bgFrame.hasBeenStyled = true
                local newBubble = CreateFrame("Frame", "GwChatBubble", bgFrame, "GwChatBubble")
                newBubble.string:SetFont(UNIT_NAME_FONT, 14)
                newBubble.string:SetTextColor(0, 0, 0, 1)
                bgFrame:SetScale(0.6)
                newBubble:ClearAllPoints()
                newBubble:SetPoint("TOPLEFT", bgFrame, "TOPLEFT", 0, 0)
                newBubble:SetPoint("BOTTOMRIGHT", bgFrame, "BOTTOMRIGHT", 0, 0)

                newBubble.string:SetText(fontString:GetText())

                bgFrame:HookScript(
                    "OnShow",
                    function()
                        newBubble.string:SetText(fontString:GetText())
                    end
                )
            end
        end
    end
end

local function chatbubbles_OnEvent(self, event, msg, arg2)
    if event == "UPDATE_INSTANCE_INFO" or event == "ZONE_CHANGED" then
        local _, typeOf, _ = GetInstanceInfo()

        if typeOf == nil or typeOf == "scenario" or typeOf == "none" then
            safeToChange = true
        else
            safeToChange = false
        end

        return
    end

    if safeToChange == false then
        return
    end

    local i = CountTable(CHAT_BUBBLES_ACTIVE)
    CHAT_BUBBLES_ACTIVE[i] = {}
    CHAT_BUBBLES_ACTIVE[i]["msg"] = msg
    CHAT_BUBBLES_ACTIVE[i]["time"] = GetTime() + 5
end

local function chatbubbles_OnUpdate()
    if safeToChange == false then
        return
    end

    local wipe = true
    for k, v in pairs(CHAT_BUBBLES_ACTIVE) do
        if v["time"] > GetTime() then
            wipe = false
        end
    end
    if wipe == true then
        CHAT_BUBBLES_ACTIVE = {}
    else
        update_gwChat_bubbles()
    end
end

local function LoadChatBubbles()
    local f = CreateFrame("Frame", nil, nil)

    f:SetScript("OnEvent", chatbubbles_OnEvent)
    f:SetScript("OnUpdate", chatbubbles_OnUpdate)

    f:RegisterEvent("CHAT_MSG_SAY")
    f:RegisterEvent("CHAT_MSG_PARTY")
    f:RegisterEvent("CHAT_MSG_MONSTER_YELL")
    f:RegisterEvent("CHAT_MSG_YELL")
    f:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
    f:RegisterEvent("CHAT_MSG_MONSTER_PARTY")
    f:RegisterEvent("CHAT_MSG_MONSTER_SAY")
    f:RegisterEvent("CHAT_MSG_MONSTER_WHISPER")
    f:RegisterEvent("CHAT_MSG_MONSTER_YELL")
    f:RegisterEvent("UPDATE_INSTANCE_INFO")
    f:RegisterEvent("ZONE_CHANGED")
end
GW.LoadChatBubbles = LoadChatBubbles
