---@class GW2
local GW = select(2, ...)

GwObjectivesItemButtonMixin = {}

function GwObjectivesItemButtonMixin:UpdateCooldown()
   local itemCooldown = self.Cooldown
	local start, duration, enable = GetQuestLogSpecialItemCooldown(self.questLogIndex)
	-- in combat the cooldown values are secret to our insecure execution: the
	-- bare setter accepts them, the CooldownFrame_Set comparisons would throw.
	-- The vertex color needs a readable state and keeps its last value then
	if GW.IsSecretValue(start) or GW.IsSecretValue(duration) or GW.IsSecretValue(enable) then
		itemCooldown:SetCooldown(start, duration)
		return
	end
	CooldownFrame_Set(itemCooldown, start, duration, enable)
	if ( duration and duration > 0 and enable and enable == 0 ) then
		SetItemButtonTextureVertexColor(self, 0.4, 0.4, 0.4)
	else
		SetItemButtonTextureVertexColor(self, 1, 1, 1)
	end
end

function GwObjectivesItemButtonMixin:OnUpdate(elapsed)
    -- Handle range indicator
	local rangeTimer = self.rangeTimer
	if ( rangeTimer ) then
		rangeTimer = rangeTimer - elapsed
		if ( rangeTimer <= 0 ) then
			local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(self.questLogIndex)
			if ( not charges or charges ~= self.charges ) then
				return
			end
			local count = self.HotKey
			local valid = IsQuestLogSpecialItemInRange(self.questLogIndex)
			if ( valid == 0 ) then
				count:Show()
				count:SetVertexColor(1.0, 0.1, 0.1)
			elseif ( valid == 1 ) then
				count:Show()
				count:SetVertexColor(0.6, 0.6, 0.6)
			else
				count:Hide()
			end
			rangeTimer = TOOLTIP_UPDATE_TIME
		end

		self.rangeTimer = rangeTimer
	end
end

function GwObjectivesItemButtonMixin:OnEvent(event)
    if ( event == "PLAYER_TARGET_CHANGED" ) then
		self.rangeTimer = -1
	elseif ( event == "BAG_UPDATE_COOLDOWN" ) then
		self:UpdateCooldown()
	end
end

function GwObjectivesItemButtonMixin:OnShow()
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("BAG_UPDATE_COOLDOWN")
end

function GwObjectivesItemButtonMixin:OnHide()
    self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
end

function GwObjectivesItemButtonMixin:OnEnter()
    if not self.questLogIndex then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetQuestLogSpecialItem(self.questLogIndex)
end
