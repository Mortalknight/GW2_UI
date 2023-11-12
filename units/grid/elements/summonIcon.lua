local _, GW = ...

local function Construct_SummonIcon(frame)
    local summonIcon = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "ARTWORK")
	summonIcon:SetSize(25, 25)
	summonIcon:SetPoint('CENTER', frame, 'CENTER')

	return summonIcon
end
GW.Construct_SummonIcon = Construct_SummonIcon

local function UpdateSummonIconSettings(frame)
    --nothing atm
end
GW.UpdateSummonIconSettings = UpdateSummonIconSettings