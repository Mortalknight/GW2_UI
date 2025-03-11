local _, GW = ...

GwQuestTrackerObjectiveMixin = {}
function GwQuestTrackerObjectiveMixin:OnShow()
    if not self.notChangeSize then
        self:SetHeight(50)
    end
    self.StatusBar.statusbarBg:Show()
end

function GwQuestTrackerObjectiveMixin:OnHide()
    if not self.notChangeSize then
        self:SetHeight(20)
    end
    self.StatusBar.statusbarBg:Hide()
end

local function statusBarSetValue(self, v)
    local f = self:GetParent()
    if not f then
        return
    end
    local min, mx = f.StatusBar:GetMinMaxValues()

    local width = math.max(1, math.min(10, 10 * ((v / mx) / 0.1)))
    f.StatusBar.Spark:SetPoint("RIGHT", f.StatusBar, "LEFT", 280 * (v / mx), 0)
    f.StatusBar.Spark:SetWidth(width)
    if f.StatusBar.precentage == nil or f.StatusBar.precentage == false then
        f.StatusBar.progress:SetText(v .. " / " .. mx)
    elseif f.isMythicKeystone then
        f.StatusBar.progress:SetText(GW.RoundDec((v / mx) * 100, 2) .. "%")
    else
        f.StatusBar.progress:SetText(math.floor((v / mx) * 100) .. "%")
    end

    f.StatusBar.Spark:SetShown(v ~= mx and v ~= min)
end

function GwQuestTrackerObjectiveMixin:OnLoad()
    self.ObjectiveText:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    self.StatusBar.progress:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    self.TimerBar.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    hooksecurefunc(self.StatusBar, "SetValue", statusBarSetValue)
end
