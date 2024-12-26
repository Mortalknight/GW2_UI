local _, GW = ...
function GwTargetFrameTemplateHealthBar_OnLoad(self)
    self:GetParent().bar = self.bar
end

function GwTargetFrameSmallTemplateHealthBar_OnLoad(self)
    self:GetParent().bar = self.bar
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
