local _, ns = ...
local oUF = ns.oUF


local GetRaidTargetIndex = GetRaidTargetIndex

local CLASS_ICONS = "Interface/AddOns/GW2_UI/textures/party/classicons.png"

-- Prio: disconnect, death, target marker, class icon (only without class colors)
-- the marker index is secret in combat: it only goes to the texture, never into a comparison
local function GetState(self)
    local unit = self.__unit
    if not UnitIsConnected(unit) then
        return "disconnect"
    elseif UnitIsDeadOrGhost(unit) then
        return "dead"
    elseif self.showTargetmarker and GetRaidTargetIndex(unit) then
        return "marker", GetRaidTargetIndex(unit)
    elseif not self.useClassColor and not self.hideClassIcon then
        return "class" .. (select(3, UnitClass(unit)) or 0)
    end
    return "none"
end

local function Update(self)
    local element = self.MiddleIcon
    local state, markerIndex = GetState(self)

    -- runs on every health tick, so only touch the textures when something changed
    if state ~= element.gwState then
        element.gwState = state

        local isDead = state == "dead"
        local gb = isDead and 0 or 1
        self.Name:SetTextColor(1, gb, gb)
        self.HealthValueText:SetTextColor(1, gb, gb)

        if state == "disconnect" then
            element:SetTexture("Interface/CharacterFrame/Disconnect-Icon")
            element:SetTexCoord(unpack(ns.TexCoords))
        elseif isDead then
            element:SetTexture(CLASS_ICONS)
            ns.SetDeadIcon(element)
        elseif state == "marker" then
            element:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcons")
        elseif state ~= "none" then
            element:SetTexture(CLASS_ICONS)
            ns.SetClassIcon(element, select(3, UnitClass(self.__unit)))
        end
    end

    -- another marker keeps the state, so the cell is set every time
    if state == "marker" then
        SetRaidTargetIconTexture(element, markerIndex)
    end

    local shouldShowIcon = state ~= "none"
    element:SetShown(shouldShowIcon and not self.readyCheckInProgress and not self.summonInProgress and not self.resurrectionInProgress)
    self._middleIconIsShown = shouldShowIcon
end

local function ForceUpdate(element)
	if(not element.__owner.__unit) then return end
	element.gwState = nil
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
        if oUF.isClassic then
			self:RegisterEvent('UNIT_HEALTH_FREQUENT', Update)
        else
            self:RegisterEvent("UNIT_HEALTH", Update)
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

        if oUF.isClassic then
			self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Update)
        else
            self:UnregisterEvent("UNIT_HEALTH", Update)
		end

        self.MiddleIcon:Hide()
    end
end

oUF:AddElement('MiddleIcon', Update, Enable, Disable)
