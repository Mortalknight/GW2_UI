local _, GW = ...

local function Construct_ReadyCheck(frame)
    local readyCheckTexture = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "ARTWORK")
	readyCheckTexture:SetSize(25, 25)
	readyCheckTexture:SetPoint('CENTER', frame, 'CENTER')

	return readyCheckTexture
end
GW.Construct_ReadyCheck = Construct_ReadyCheck

local function UpdateReadyCheckSettings(frame)
    frame.readyTexture = "Interface/AddOns/GW2_UI/textures/party/readycheck.png"
    frame.notReadyTexture = "Interface/AddOns/GW2_UI/textures/party/readycheck.png"
    frame.waitingTexture = "Interface/AddOns/GW2_UI/textures/party/readycheck.png"
end
GW.UpdateReadyCheckSettings = UpdateReadyCheckSettings