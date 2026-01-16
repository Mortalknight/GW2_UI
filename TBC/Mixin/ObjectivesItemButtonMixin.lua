GwObjectivesItemButtonMixin = {}

function GwObjectivesItemButtonMixin:UpdateCooldown()
   local itemCooldown = self.Cooldown
	local start, duration, enable = GetQuestLogSpecialItemCooldown(self.questLogIndex)
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
