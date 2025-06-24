local _, GW = ...

GwObjectivesAnimationMixin = {}

function GwObjectivesAnimationMixin:NewQuestAnimation()
    self.flare:Show()
    self.flare:SetAlpha(1)
    GW.AddToAnimation(
        self:GetDebugName() .. "flare",
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

function GwObjectivesAnimationMixin:WiggleAnimation()
    if self.animation == nil then
        self.animation = 0
    end
    GW.AddToAnimation(
        self:GetDebugName(),
        0,
        1,
        GetTime(),
        2,
        function(prog)
            self.flare:SetRotation(GW.lerp(0, 1, prog))

            if prog < 0.25 then
                self.texture:SetRotation(GW.lerp(0, -0.5, math.sin((prog / 0.25) * math.pi * 0.5)))
                self.flare:SetAlpha(GW.lerp(0, 1, math.sin((prog / 0.25) * math.pi * 0.5)))
            end
            if prog > 0.25 and prog < 0.75 then
                self.texture:SetRotation(GW.lerp(-0.5, 0.5, math.sin(((prog - 0.25) / 0.5) * math.pi * 0.5)))
            end
            if prog > 0.75 then
                self.texture:SetRotation(GW.lerp(0.5, 0, math.sin(((prog - 0.75) / 0.25) * math.pi * 0.5)))
            end

            if prog > 0.25 then
                self.flare:SetAlpha(GW.lerp(1, 0, ((prog - 0.25) / 0.75)))
            end
        end,
        nil,
        function()
            self:WiggleAnimation()
        end
    )
end
