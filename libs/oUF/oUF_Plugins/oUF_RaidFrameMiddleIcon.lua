local _, ns = ...
local oUF = ns.oUF


local GetRaidTargetIndex = GetRaidTargetIndex

local function Update(self)
	local element = self.MiddleIcon
    local shouldShowIcon = false
    local index = GetRaidTargetIndex(self.unit)

    -- Prio list
    -- disconnect
    -- Deadth icon
    -- target marker
    -- Class icon if not classcolor

    -- disconnect
    if not UnitIsConnected(self.unit) then
        element:SetTexture("Interface/CharacterFrame/Disconnect-Icon")
        element:SetTexCoord(unpack(ns.TexCoords))
        self.Health:SetStatusBarColor(0.3, 0.3, 0.3, 1)

        shouldShowIcon = true
    elseif UnitIsDeadOrGhost(self.unit) then -- deathicon
        if self.useClassColor then
            element:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons")
        end
        ns.SetDeadIcon(element)
        self.Name:SetTextColor(255, 0, 0)

        shouldShowIcon = true
    elseif self.showTargetmarker and index then -- targetmarker
        if index then
            element:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcon_" .. index)
            element:SetTexCoord(unpack(ns.TexCoords))

            shouldShowIcon = true
        end
    elseif not self.useClassColor then -- class icon
        local _, _, classIndex = UnitClass(self.unit)
        element:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons")
        ns.SetClassIcon(element, classIndex)

        shouldShowIcon = true
    end

    if not self.readyCheckInProgress and not self.summonInProgress and not self.resurrectionInProgress then
        element:SetShown(shouldShowIcon)
    else
        element:Hide()
    end
    self._middleIconIsShown = shouldShowIcon
end

local function Enable(self)
    if self.MiddleIcon then
        self:RegisterEvent("PARTY_MEMBER_DISABLE", Update)
        self:RegisterEvent("PARTY_MEMBER_ENABLE", Update)
        self:RegisterEvent("UNIT_CONNECTION", Update)
        self:RegisterEvent("PLAYER_FLAGS_CHANGED", Update)
        self:RegisterEvent("RAID_TARGET_UPDATE", Update, true)
        self:RegisterEvent("UPDATE_INSTANCE_INFO", Update, true)

        return true
    end
end

local function Disable(self)
	if self.MiddleIcon then
        self:UnregisterEvent("PARTY_MEMBER_DISABLE", Update)
        self:UnregisterEvent("PARTY_MEMBER_ENABLE", Update)
        self:UnregisterEvent("UNIT_CONNECTION", Update)
        self:UnregisterEvent("PLAYER_FLAGS_CHANGED", Update)
        self:UnregisterEvent("RAID_TARGET_UPDATE", Update, true)
        self:UnregisterEvent("UPDATE_INSTANCE_INFO", Update, true)


        self.MiddleIcon:Hide()
    end
end

oUF:AddElement('MiddleIcon', Update, Enable, Disable)
