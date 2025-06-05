local _, GW = ...

local function Construct_MiddleIcon(frame)
    local middleIcon = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "ARTWORK")
	middleIcon:SetSize(25, 25)
	middleIcon:SetPoint('CENTER', frame, 'CENTER')

	return middleIcon
end
GW.Construct_MiddleIcon = Construct_MiddleIcon

local function UpdateMiddleIconSettings(frame)
    -- nothing atm
end
GW.UpdateMiddleIconSettings = UpdateMiddleIconSettings