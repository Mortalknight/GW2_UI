---@class GW2
local GW = select(2, ...)

-- a quick back and forth plays the sound once
local SOUND_COOLDOWN = 3

local lastSound = 0

local function PlayWhisperSound()
    local sound = GW.settings.chat.whisperSound
    if not sound or sound == "None" or GetTime() - lastSound < SOUND_COOLDOWN then
        return
    end
    lastSound = GetTime()
    PlaySoundFile(GW.Libs.LSM:Fetch("sound", sound), "Master")
end

GW.RegisterChatModule({
    onLoad = function()
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("CHAT_MSG_WHISPER")
        frame:RegisterEvent("CHAT_MSG_BN_WHISPER")
        frame:SetScript("OnEvent", PlayWhisperSound)
    end,
})
