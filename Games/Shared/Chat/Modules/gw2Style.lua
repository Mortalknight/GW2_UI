---@class GW2
local GW = select(2, ...)

local CHANNEL_COLOR = "|cffd0d0d0"

-- light grey channel names, and the sender without brackets
GW.RegisterChatModule({
    setting = "gw2Style",
    onLine = function(_, text, _, _, _, _, accessID)
        -- battle.net names are protected strings, leave those lines alone
        if GW.IsSecretValue(accessID) or not accessID or strfind(text, "|K", 1, true) then
            return
        end
        text = gsub(text, "(|Hchannel:.-|h)(%[.-%])(|h)", "%1" .. CHANNEL_COLOR .. "%2|r%3")
        text = gsub(text, "(|H[BN]*player:[^|]*|h)%[([^%]]*)%](|h)", "%1%2%3", 1)
        return text
    end,
})
