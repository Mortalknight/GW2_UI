---@class GW2
local GW = select(2, ...)

local EVENTS = CopyTable(GW.CHAT_MESSAGE_EVENTS)
tinsert(EVENTS, "CHAT_MSG_LOOT")

local ICON_FORMAT = "|T%s:0:0:0:0:100:100:10:90:10:90|t"

local GEAR = {
    [Enum.ItemClass.Weapon] = true,
    [Enum.ItemClass.Armor] = true,
}

-- the icon goes in front of the color, the level behind the link: inside the brackets questie reads
-- "[name (number)]" as a quest link. Copied lines drop it again (GW.GetPlainChatLine)
local function DecorateLink(color, link)
    local itemString = strmatch(link, "^|H(item:[^|]+)|h")
    if not itemString then return end

    local _, _, _, equipLoc, icon, classID = C_Item.GetItemInfoInstant(itemString)
    if not icon then return end

    local suffix = ""
    if GEAR[classID] and equipLoc ~= "" and equipLoc ~= "INVTYPE_NON_EQUIP_IGNORE" then
        local itemLevel = C_Item.GetDetailedItemLevelInfo(color .. link .. "|r")
        if itemLevel and itemLevel > 1 then
            suffix = " (" .. itemLevel .. ")"
        end
    end
    return format(ICON_FORMAT, icon) .. color .. link .. suffix .. "|r"
end

GW.RegisterChatModule({
    setting = "itemLinkInfo",
    events = EVENTS,
    onMessage = function(_, _, msg, ...)
        local text = gsub(msg, "(|c[^|]*)(|Hitem:.-|h.-|h)|r", DecorateLink)
        if text ~= msg then
            return false, text, ...
        end
    end,
})
