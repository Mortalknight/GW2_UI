---@class GW2
local GW = select(2, ...)

-- battle.net friends in the class color of the character they play right now
local function GetBNetFriendColor(name, bnetAccountID)
    if GW.IsSecretValue(bnetAccountID) or GW.IsSecretValue(name) or not bnetAccountID then
        return name
    end
    local account = C_BattleNet.GetAccountInfoByID(bnetAccountID)
    local game = account and account.gameAccountInfo
    local class = game and game.clientProgram == BNET_CLIENT_WOW and GW.UnlocalizedClassName(game.className)
    if not class then
        return name
    end
    return GW.GWGetClassColor(class, true, true):WrapTextInColorCode(name)
end

GW.RegisterChatModule({
    onSenderName = function(event, name, ...)
        if event == "CHAT_MSG_BN_WHISPER" or event == "CHAT_MSG_BN_WHISPER_INFORM" then
            return GetBNetFriendColor(name, (select(13, ...))) -- arg13, the sender's battle.net account
        end
    end,
})
