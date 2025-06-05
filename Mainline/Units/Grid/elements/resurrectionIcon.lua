local _, GW = ...

local function Construct_ResurrectionIcon(frame)
    local summonIcon = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "ARTWORK")
	summonIcon:SetSize(25, 25)
	summonIcon:SetPoint('CENTER', frame, 'CENTER')

	return summonIcon
end
GW.Construct_ResurrectionIcon = Construct_ResurrectionIcon

local function UpdateResurrectionIconSettings(frame)
    --nothing atm
end
GW.UpdateResurrectionIconSettings = UpdateResurrectionIconSettings