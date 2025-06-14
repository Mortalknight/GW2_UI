GwObjectivesItemButtonMixin = {}

function GwObjectivesItemButtonMixin:OnUpdate(elapsed)
    -- Handle range indicator
	local rangeTimer = self.rangeTimer;
	if ( rangeTimer ) then
		rangeTimer = rangeTimer - elapsed;
		if ( rangeTimer <= 0 ) then
			local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(self:GetID());
			if ( not charges or charges ~= self.charges ) then
				self:GetParent():GetParent():UpdateLayout()
				return;
			end
			local count = _G[self:GetName().."HotKey"];
			local valid = IsQuestLogSpecialItemInRange(self:GetID());
			if ( valid == 0 ) then
				count:Show();
				count:SetVertexColor(1.0, 0.1, 0.1);
			elseif ( valid == 1 ) then
				count:Show();
				count:SetVertexColor(0.6, 0.6, 0.6);
			else
				count:Hide();
			end
			rangeTimer = TOOLTIP_UPDATE_TIME;
		end

		self.rangeTimer = rangeTimer;
	end
end

function GwObjectivesItemButtonMixin:OnEvent(event)
    if ( event == "PLAYER_TARGET_CHANGED" ) then
		self.rangeTimer = -1;
	elseif ( event == "BAG_UPDATE_COOLDOWN" ) then
		WatchFrameItem_UpdateCooldown(self);
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
    if not self.itemID then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetQuestLogSpecialItem(self.itemID)
end
