---@class GW2
local GW = select(2, ...)

local function Construct_PvPClassificationIcon(frame)
    local pvpIcon = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "ARTWORK")
    pvpIcon:SetSize(16, 16)
    pvpIcon:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)

    return pvpIcon
end
GW.Construct_PvPClassificationIcon = Construct_PvPClassificationIcon
