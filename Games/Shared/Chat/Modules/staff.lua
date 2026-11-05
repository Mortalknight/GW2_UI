---@class GW2
local GW = select(2, ...)

local STAFF_TEXTURE = "Interface/AddOns/GW2_UI/Textures/chat/dev_label.png"
local STAFF_ICON = "|T" .. STAFF_TEXTURE .. ":14:14|t"
local TOOLTIP_STAFF_ICON = "|TInterface/AddOns/GW2_UI/Textures/chat/dev_label.png:11:11|t"

-- the GW2 UI team, by Name-Realm
local STAFF = {
    -- Glow
    ["Zâmarâ-Antonidas"] = true, ["Sàphy-Antonidas"] = true, ["Shâdowfall-Antonidas"] = true, ["Winglord-Antonidas"] = true,
    ["Zâmârâ-Antonidas"] = true, ["Mâgus-Aegwynn"] = true, ["Flôffi-Aegwynn"] = true, ["Sâphìra-Thunderstrike"] = true,
    ["Rhosk-Aschenhain"] = true,
    -- SHOODOX
    ["Blish-Thrall"] = true, ["Blish-Arthas"] = true, ["Hildegunde-ArgentDawn"] = true, ["Notburga-ArgentDawn"] = true,
    ["Aderna-Arthas"] = true, ["Wan-Malfurion"] = true, ["Funda-Malfurion"] = true, ["Glühdirne-Arthas"] = true,
    ["Ticksick-Arthas"] = true, ["Meep-Arthas"] = true, ["Hiniche-Arthas"] = true, ["Trodar-Madmortem"] = true,
    ["Lætitia-ArgentDawn"] = true, ["Fuyubara-ArgentDawn"] = true, ["Blish-Proudmoore"] = true, ["Notburga-Proudmoore"] = true,
    ["Sisi-Proudmoore"] = true,
    -- Belazor
    ["Ilyxiana-Ravencrest"] = true,
    -- Zoelie
    ["Zoelie-Nightslayer"] = true,
    ["Zoelia-Nightslayer"] = true,
    ["Zoefia-Dreamscythe"] = true,
    ["Zoelie-Tatezama"] = true
}

-- on forever the realm is the surname, so entries there are "Firstname-Surname"
function GW.GetStaffIcon(unit)
    local name, realm = UnitFullName(unit)
    if not name or GW.IsSecretValue(name) or GW.IsSecretValue(realm) then return end
    if realm and realm ~= "" then
        name = name .. "-" .. realm
    end
    return STAFF[GW.GetChatNameWithRealm(name)] and TOOLTIP_STAFF_ICON or nil
end

-- a player link draws only its first icon, with the role icon in front the staff icon got lost,
-- so the icons in front of the name move out of the link
local function MoveIconsOutOfLink(link, bracket, name, close)
    if not strfind(name, STAFF_TEXTURE, 1, true) then
        return
    end
    local icons = ""
    while true do
        local icon, rest = strmatch(name, "^(|T.-|t ?)(.*)$")
        if not icon then
            break
        end
        icons, name = icons .. icon, rest
    end
    -- the gw2 style removes the brackets inside the link, without it the icons stay inside them
    if GW.settings.chat.gw2Style then
        return icons .. link .. bracket .. name .. close
    end
    return bracket .. icons .. link .. name .. close
end

GW.RegisterChatModule({
    onSenderName = function(_, name, _, sender)
        if GW.NotSecretValue(sender) and sender and STAFF[GW.GetChatNameWithRealm(sender)] then
            return STAFF_ICON .. name
        end
    end,
    onLine = function(_, text, _, _, _, _, accessID)
        if GW.IsSecretValue(accessID) or not accessID or not strfind(text, STAFF_TEXTURE, 1, true) then
            return
        end
        return (gsub(text, "(|Hplayer:[^|]*|h)(%[?)(.-)(|h)", MoveIconsOutOfLink, 1))
    end,
})
