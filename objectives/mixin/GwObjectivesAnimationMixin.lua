local _, GW = ...

GwObjectivesAnimationMixin = {}

function GwObjectivesAnimationMixin:NewQuestAnimation()
    self.flare:Show()
    self.flare:SetAlpha(1)
    GW.AddToAnimation(
        self:GetName() .. "flare",
        0,
        1,
        GetTime(),
        1,
        function(step)
            self:SetWidth(300 * step)
            self.flare:SetSize(300 * (1 - step), 300 * (1 - step))
            self.flare:SetRotation(2 * step)

            if step > 0.75 then
                self.flare:SetAlpha((step - 0.75) / 0.25)
            end
        end,
        nil,
        function()
            self.flare:Hide()
        end
    )
end
