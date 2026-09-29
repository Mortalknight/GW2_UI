---@class GW2
local GW = select(2, ...)

local ROLE_ICONS = {
    TANK = "|TInterface/AddOns/GW2_UI/Textures/party/roleicon-tank.png:12:12:0:0:64:64:2:56:2:56|t ",
    HEALER = "|TInterface/AddOns/GW2_UI/Textures/party/roleicon-healer.png:12:12:0:0:64:64:2:56:2:56|t ",
    DAMAGER = "|TInterface/AddOns/GW2_UI/Textures/party/roleicon-dps.png:15:15:-2:0:64:64:2:56:2:56|t",
}
local GROUP_EVENTS = {
    CHAT_MSG_PARTY = true, CHAT_MSG_PARTY_LEADER = true, CHAT_MSG_RAID = true, CHAT_MSG_RAID_LEADER = true,
    CHAT_MSG_INSTANCE_CHAT = true, CHAT_MSG_INSTANCE_CHAT_LEADER = true,
}

-- the role icon of every group member, by Name-Realm like the chat events name the sender
local iconByName = {}

local function AddMember(unit)
    local role = UnitGroupRolesAssigned(unit)
    local name, realm = UnitName(unit)
    if GW.IsSecretValue(role) or GW.IsSecretValue(name) or GW.IsSecretValue(realm) then
        return
    end
    local icon = ROLE_ICONS[role]
    if icon and name then
        -- chat names carry the realm without spaces
        iconByName[GW.GetChatNameWithRealm(realm and realm ~= "" and name .. "-" .. gsub(realm, "[%s%-]", "") or name)] = icon
    end
end

local function UpdateRoles()
    wipe(iconByName)
    if not GW.settings.chat.lfgIcons or not IsInGroup() then
        return
    end
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            AddMember("raid" .. i)
        end
    else
        AddMember("player")
        for i = 1, GetNumSubgroupMembers() do
            AddMember("party" .. i)
        end
    end
end
GW.CollectLfgRolesForChatIcons = UpdateRoles

GW.RegisterChatModule({
    setting = "lfgIcons",
    onLoad = function()
        local watcher = CreateFrame("Frame")
        watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
        watcher:RegisterEvent("GROUP_ROSTER_UPDATE")
        if C_EventUtils.IsEventValid("PLAYER_ROLES_ASSIGNED") then
            watcher:RegisterEvent("PLAYER_ROLES_ASSIGNED")
        end
        watcher:SetScript("OnEvent", UpdateRoles)
        UpdateRoles()
    end,
    onSenderName = function(event, name, _, sender)
        local icon = GROUP_EVENTS[event] and GW.NotSecretValue(sender) and sender and iconByName[GW.GetChatNameWithRealm(sender)]
        if icon then
            return icon .. name
        end
    end,
})
