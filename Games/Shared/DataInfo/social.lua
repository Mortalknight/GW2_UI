---@class GW2
local GW = select(2, ...)

-- the building blocks the friends and the guild tooltip share
local Social = {}
GW.Social = Social

Social.SAME_PLACE_COLOR = GW.Colors.SkinColors.Positive
Social.OTHER_PLACE_COLOR = CreateColor(0.65, 0.65, 0.65)
Social.IN_GROUP_MARK = "|cffaaaaaa*|r"
Social.TIMERUNNING_ICON = CreateAtlasMarkup("timerunning-glues-icon-small", 12, 10)

local AFK_TAG = " |cffff9900<" .. AFK .. ">|r"
local DND_TAG = " |cffff3333<" .. DND .. ">|r"

function Social.GetStatusTag(isAFK, isDND)
    return isAFK and AFK_TAG or isDND and DND_TAG or ""
end

function Social.GetPlaceColor(isSame)
    return isSame and Social.SAME_PLACE_COLOR or Social.OTHER_PLACE_COLOR
end

function Social.IsGroupMember(name, realm)
    if realm and realm ~= "" and realm ~= GW.myrealm then
        name = name .. "-" .. realm
    end
    local inParty, inRaid = UnitInParty(name), UnitInRaid(name)
    if GW.IsSecretValue(inParty) or GW.IsSecretValue(inRaid) then
        return false
    end
    return (inParty or inRaid) and true or false
end

-- level in its difficulty color, name in its class color; class is the english token
function Social.FormatCharacter(level, name, class)
    local classColor = GW.GWGetClassColor(class, true, true)
    if not level or level == 0 then
        return classColor:WrapTextInColorCode(name)
    end
    local levelColor = GetQuestDifficultyColor(level)
    return GW.RGBToHex(levelColor.r, levelColor.g, levelColor.b, nil, level .. "|r ") .. classColor:WrapTextInColorCode(name)
end

-- the tooltip a micro button shows on its own, the social lists go below it
function Social.StartMicroButtonTooltip(button)
    -- blizzards micro button has just shown its own tooltip with the same owner, a new owner call alone
    -- keeps the size of the last tooltip
    GameTooltip:Hide()
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip_SetTitle(GameTooltip, button.tooltipText)
    if not button:IsEnabled() then
        local reason = button.factionGroup == "Neutral" and FEATURE_NOT_AVAILBLE_PANDAREN
            or button.minLevel and format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, button.minLevel)
            or button.disabledTooltip and GetValueOrCallFunction(button, "disabledTooltip")
        if reason then
            GameTooltip_AddErrorLine(GameTooltip, reason, true)
        end
    end
end

function Social.Invite(target, guid, isBNet)
    local inviteType = guid and GetDisplayedInviteType(guid) or "INVITE"
    if inviteType == "REQUEST_INVITE" then
        if isBNet then
            BNRequestInviteFriend(target)
        else
            C_PartyInfo.RequestInviteFromUnit(target)
        end
    elseif inviteType == "INVITE" or inviteType == "SUGGEST_INVITE" then
        if isBNet then
            C_BattleNet.InviteFriend(target)
        else
            C_PartyInfo.InviteUnit(target)
        end
    end
end
