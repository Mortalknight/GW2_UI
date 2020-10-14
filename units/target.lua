
function GwTargetFrameTemplateHealthBar_OnLoad(self)
    self:GetParent().bar = self.bar
end

function GwTargetFrameSmallTemplateHealthBar_OnLoad(self)
    self:GetParent().bar = self.bar
end

function GwBuffIcon_OnLoad(self)
    _G[self:GetName() .. "BuffDuration"]:SetFont(UNIT_NAME_FONT, 11)
    _G[self:GetName() .. "BuffDuration"]:SetTextColor(1, 1, 1)
end

function GwDeBuffIcon_OnLoad(self)
    local mName = self:GetName()

    self.icon = _G[mName .. "IconBuffIcon"]

    _G[mName .. "IconBuffStacks"]:SetFont(UNIT_NAME_FONT, 14, "OUTLINE")
    _G[mName .. "IconBuffStacks"]:SetTextColor(255, 255, 255)

    _G[mName .. "CooldownBuffDuration"]:SetFont(UNIT_NAME_FONT, 14)
    _G[mName .. "CooldownBuffDuration"]:SetTextColor(255, 255, 255)

    _G[mName .. "IconBuffStacks"]:SetFont(UNIT_NAME_FONT, 14, "OUTLINE")
    _G[mName .. "IconBuffStacks"]:SetTextColor(255, 255, 255)

    _G[mName .. "CooldownBuffDuration"]:SetFont(UNIT_NAME_FONT, 14)
    _G[mName .. "CooldownBuffDuration"]:SetTextColor(255, 255, 255)
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

function VerticalActionBarDummy_OnLoad(self)
    self.frameName:SetFont(DAMAGE_TEXT_FONT, 14)
    self.frameName:SetShadowColor(0, 0, 0, 1)
    self.frameName:SetShadowOffset(1, -1)
end
