local _, GW = ...

local function Construct_PrivateAura(frame)
    local privateAuraHolder = CreateFrame('Frame', '$parentPrivateAuras', frame.RaisedElementParent)
    privateAuraHolder:SetSize(frame:GetSize())
    privateAuraHolder:SetFrameLevel(20)

    for i = 1, 2 do
        local privateAura = CreateFrame("Frame", nil, privateAuraHolder, "GwPrivateAuraTmpl")
        privateAura:SetPoint("CENTER", privateAuraHolder, i == 1 and -9 or 9, 0)
        privateAura.auraIndex = i
        privateAura:SetSize(15, 15)
        local auraAnchor = {
            unitToken = frame.unit,
            auraIndex = privateAura.auraIndex,
            -- The parent frame of an aura anchor must have a valid rect with a non-zero
            -- size. Each private aura will anchor to all points on its parent,
            -- providing a tooltip when mouseovered.
            parent = privateAura,
            -- An optional cooldown spiral can be configured to represent duration.
            showCountdownFrame = true,
            showCountdownNumbers = true,
            -- An optional icon can be created and shown for the aura. Omitting this
            -- will display no icon.
            iconInfo = {
                iconWidth = 15,
                iconHeight = 15,
                iconAnchor = {
                    point = "CENTER",
                    relativeTo = privateAura.status,
                    relativePoint = "CENTER",
                    offsetX = 0,
                    offsetY = 0,
                },
            },
        }
        -- Anchors can be removed (and the aura hidden) via the RemovePrivateAuraAnchor
        -- API, passing it the anchor index returned from the Add function.
        privateAura.anchorIndex = C_UnitAuras.AddPrivateAuraAnchor(auraAnchor)
    end

	return privateAuraHolder
end
GW.Construct_PrivateAura = Construct_PrivateAura

local function UpdatePrivateAurasSettings(frame)

end
GW.UpdatePrivateAurasSettings = UpdatePrivateAurasSettings