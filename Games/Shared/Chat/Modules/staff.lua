---@class GW2
local GW = select(2, ...)

local STAFF_ICON = "|TInterface/AddOns/GW2_UI/Textures/chat/dev_label.png:14:14|t"
local TOOLTIP_STAFF_ICON = "|TInterface/AddOns/GW2_UI/Textures/chat/dev_label.png:11:11|t"

-- the GW2 UI team, by Name-Realm
local STAFF = {
    -- Glow
    ["Zâmarâ-Antonidas"] = true, ["Sàphy-Antonidas"] = true, ["Shâdowfall-Antonidas"] = true, ["Winglord-Antonidas"] = true,
    ["Zâmârâ-Antonidas"] = true, ["Mâgus-Aegwynn"] = true, ["Flôffi-Aegwynn"] = true, ["Sâphìra-Thunderstrike"] = true,
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

GW.RegisterChatModule({
    onSenderName = function(_, name, _, sender)
        if GW.NotSecretValue(sender) and sender and STAFF[GW.GetChatNameWithRealm(sender)] then
            return STAFF_ICON .. name
        end
    end,
})
