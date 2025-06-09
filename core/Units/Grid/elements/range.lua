local _, GW = ...


local function Construct_RangeIndicator(frame)
    local range = {
        insideAlpha = 1,
        outsideAlpha = 0.2,
    }

	return range
end
GW.Construct_RangeIndicator = Construct_RangeIndicator

local function Update_RangeIndicator(frame)
    frame.Range.outsideAlpha =  frame.outOfRangeAlphaValue
end
GW.Update_RangeIndicator = Update_RangeIndicator