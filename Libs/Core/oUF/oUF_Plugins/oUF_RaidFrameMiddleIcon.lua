local _, ns = ...
local oUF = ns.oUF


local GetRaidTargetIndex = GetRaidTargetIndex

local function Update(self)
	local element = self.MiddleIcon
    local shouldShowIcon = false

    -- Prio list
    -- disconnect
    -- Deadth icon
    -- target marker
    -- Class icon if not classcolor

    -- always in white
    self.Name:SetTextColor(1, 1, 1)
    self.HealthValueText:SetTextColor(1, 1, 1)

    -- disconnect
    if not UnitIsConnected(self.unit) then
        element:SetTexture("Interface/CharacterFrame/Disconnect-Icon")
        element:SetTexCoord(unpack(ns.TexCoords))

        shouldShowIcon = true
    elseif UnitIsDeadOrGhost(self.unit) then -- deathicon
        if self.useClassColor then
            element:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons.png")
        end
        ns.SetDeadIcon(element)
        self.Name:SetTextColor(255, 0, 0)
        self.HealthValueText:SetTextColor(255, 0, 0)

        shouldShowIcon = true
    elseif self.showTargetmarker and GetRaidTargetIndex(self.unit) then -- targetmarker
        local index = GetRaidTargetIndex(self.unit)
        if index then
            element:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcons")
            SetRaidTargetIconTexture(element, index)

            shouldShowIcon = true
        end
    elseif not self.useClassColor and not self.hideClassIcon then -- class icon only if option is active

        local _, _, classIndex = UnitClass(self.unit)
        element:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons.png")
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

local function ForceUpdate(element)
	if(not element.__owner.unit) then return end
	return Update(element.__owner)
end

local function Enable(self)
    if self.MiddleIcon then
        self.MiddleIcon.__owner = self
		self.MiddleIcon.ForceUpdate = ForceUpdate

        self:RegisterEvent("PARTY_MEMBER_DISABLE", Update)
        self:RegisterEvent("PARTY_MEMBER_ENABLE", Update)
        self:RegisterEvent("UNIT_CONNECTION", Update)
        self:RegisterEvent("PLAYER_FLAGS_CHANGED", Update)
        self:RegisterEvent("RAID_TARGET_UPDATE", Update, true)
        self:RegisterEvent("UPDATE_INSTANCE_INFO", Update, true)
        self:RegisterEvent("UNIT_HEALTH", Update)

        if oUF.isClassic then
			self:RegisterEvent('UNIT_HEALTH_FREQUENT', Update)
		end

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
        self:UnregisterEvent("UNIT_HEALTH", Update)

        if oUF.isClassic then
			self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Update)
		end

        self.MiddleIcon:Hide()
    end
end

oUF:AddElement('MiddleIcon', Update, Enable, Disable)
