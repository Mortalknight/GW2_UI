
function GwTargetFrameTemplateHealthBar_OnLoad(self)
    self:GetParent().bar = self.bar
end

function GwTargetFrameSmallTemplateHealthBar_OnLoad(self)
    self:GetParent().bar = self.bar
end

function GwBuffIcon_OnLoad(self)
    self.buffDuration:SetFont(UNIT_NAME_FONT, 11)
    self.buffDuration:SetTextColor(1, 1, 1)
end

function GwDeBuffIcon_OnLoad(self)
    self.icon = self.debuffIcon.icon

    self.debuffIcon.stacks:SetFont(UNIT_NAME_FONT, 14, "OUTLINE")
    self.debuffIcon.stacks:SetTextColor(255, 255, 255)

    self.cooldown.duration:SetFont(UNIT_NAME_FONT, 14)
    self.cooldown.duration:SetTextColor(255, 255, 255)
end

function GwTargetFrameTemplateDummy_OnLoad(self)
    self.frameName:SetFont(DAMAGE_TEXT_FONT, 14)
    self.frameName:SetShadowColor(0, 0, 0, 1)
    self.frameName:SetShadowOffset(1, -1)
end

function GwTargetFrameSmallTemplateDummy_OnLoad(self)
    self.frameName:SetFont(DAMAGE_TEXT_FONT, 14)
    self.frameName:SetShadowColor(0, 0, 0, 1)
    self.frameName:SetShadowOffset(1, -1)
end

function GwPetFrameDummy_OnLoad(self)
    self.frameName:SetFont(DAMAGE_TEXT_FONT, 14)
    self.frameName:SetShadowColor(0, 0, 0, 1)
    self.frameName:SetShadowOffset(1, -1)
end

function GwCastFrameDummy_OnLoad(self)
    self.frameName:SetFont(DAMAGE_TEXT_FONT, 14)
    self.frameName:SetShadowColor(0, 0, 0, 1)
    self.frameName:SetShadowOffset(1, -1)
end

function GwVerticalActionBarDummy_OnLoad(self)
    self.frameName:SetFont(DAMAGE_TEXT_FONT, 14)
    self.frameName:SetShadowColor(0, 0, 0, 1)
    self.frameName:SetShadowOffset(1, -1)
end
