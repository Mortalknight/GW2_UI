local _, GW = ...

local function Construct_MissingAuraIndicator(frame)
    local missingbuffFrame = CreateFrame('StatusBar', '$parent_MissingBuffIndicatorFrame', frame)

    missingbuffFrame:SetFrameLevel(21)

	return missingbuffFrame
end
GW.Construct_MissingAuraIndicator = Construct_MissingAuraIndicator

local function Update_MissingAuraIndicator(frame)
    local missingbuffFrame = frame.MissingBuffFrame
    missingbuffFrame:SetHeight(16)
    missingbuffFrame:ClearAllPoints()
    missingbuffFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    missingbuffFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 16)
end
GW.Update_MissingAuraIndicator = Update_MissingAuraIndicator