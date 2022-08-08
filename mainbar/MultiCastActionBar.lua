local _, GW = ...

local function LoadMultiCastActionBarFrame()
    local bar = CreateFrame("Frame", "GW2UI_TotemBar", UIParent, "SecureHandlerStateTemplate")

    MultiCastActionBarFrame:SetParent(bar)
    MultiCastActionBarFrame:ClearAllPoints()
    MultiCastActionBarFrame:SetAllPoints()
    GW.RegisterMovableFrame(bar, GW.L["Class Totems"], "TotemBar_pos", "VerticalActionBarDummy", {MultiCastActionBarFrame:GetSize()}, nil, {"default", "scaleable"})
    bar:ClearAllPoints()
    bar:SetPoint("BOTTOMLEFT", bar.gwMover)

end
GW.LoadMultiCastActionBarFrame = LoadMultiCastActionBarFrame