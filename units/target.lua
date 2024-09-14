local _, GW = ...
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

    self.debuffIcon.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, "OUTLINE")
    self.debuffIcon.stacks:SetTextColor(255, 255, 255)

    self.cooldown.duration:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    self.cooldown.duration:SetTextColor(255, 255, 255)
end

function GwTargetFrameTemplateDummy_OnLoad(self)
    self.frameName:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    self.frameName:SetShadowColor(0, 0, 0, 1)
    self.frameName:SetShadowOffset(1, -1)
end

function GwTargetFrameSmallTemplateDummy_OnLoad(self)
    self.frameName:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    self.frameName:SetShadowColor(0, 0, 0, 1)
    self.frameName:SetShadowOffset(1, -1)
end

function GwPetFrameDummy_OnLoad(self)
    self.frameName:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    self.frameName:SetShadowColor(0, 0, 0, 1)
    self.frameName:SetShadowOffset(1, -1)
end

function GwCastFrameDummy_OnLoad(self)
    self.frameName:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    self.frameName:SetShadowColor(0, 0, 0, 1)
    self.frameName:SetShadowOffset(1, -1)
end

function GwVerticalActionBarDummy_OnLoad(self)
    self.frameName:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    self.frameName:SetShadowColor(0, 0, 0, 1)
    self.frameName:SetShadowOffset(1, -1)
end
