local _, GW = ...

local function TopCenterPosition(self, _, b)
    local holder = _G.UIWidgetTopCenterContainerFrame.gwMover
    if b and (b ~= holder) then
        self:ClearAllPoints()
        self:SetPoint("CENTER", holder, "CENTER")
    end
end

local function WidgetUISetup()
    GW.RegisterMovableFrame(_G.UIWidgetTopCenterContainerFrame, "TopWidget", "TopCenterWidget_pos", "VerticalActionBarDummy", {58, 58}, nil, {"default", "scaleable"})
    _G.UIWidgetTopCenterContainerFrame:ClearAllPoints()
    _G.UIWidgetTopCenterContainerFrame:SetPoint("CENTER", _G.UIWidgetTopCenterContainerFrame.gwMover, "CENTER")

    hooksecurefunc(_G.UIWidgetTopCenterContainerFrame, "SetPoint", TopCenterPosition)
end
GW.WidgetUISetup = WidgetUISetup
