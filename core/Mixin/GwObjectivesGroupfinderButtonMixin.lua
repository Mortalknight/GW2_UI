GwObjectivesGroupfinderButtonMixin = {}

function GwObjectivesGroupfinderButtonMixin:SetUp(id, isScenario)
	self.id = id
    self.isScenario = isScenario
end

function GwObjectivesGroupfinderButtonMixin:OnEnter()
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine(TOOLTIP_TRACKER_FIND_GROUP_BUTTON, HIGHLIGHT_FONT_COLOR:GetRGB())

	GameTooltip:Show()
end

function GwObjectivesGroupfinderButtonMixin:OnLeave()
	GameTooltip:Hide()
end

function GwObjectivesGroupfinderButtonMixin:OnClick()
	local isFromGreenEyeButton = true
    if not self.isScenario then
	    LFGListUtil_FindQuestGroup(self.id, isFromGreenEyeButton)
    else
        LFGListUtil_FindScenarioGroup(self.id, true)
    end
end