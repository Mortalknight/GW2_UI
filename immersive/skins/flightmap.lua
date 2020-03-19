local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame

local function SkinFlightMap()
    FlightMap_LoadUI()

    local FlightMapFrame = _G.FlightMapFrame

    local tex = FlightMapFrame:CreateTexture("bg", "BACKGROUND")
    local w, h = FlightMapFrame:GetSize()
    tex:SetPoint("TOP", FlightMapFrame, "TOP", 10, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    tex:SetSize(w + 120, h + 80 )
    FlightMapFrame.tex = tex

    _G.FlightMapFrameCloseButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal")
    _G.FlightMapFrameCloseButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover")
    _G.FlightMapFrameCloseButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover")
    _G.FlightMapFrameCloseButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal")
    _G.FlightMapFrameCloseButton:SetSize(25, 25)
    _G.FlightMapFrameCloseButton:ClearAllPoints()
    _G.FlightMapFrameCloseButton:SetPoint("TOPRIGHT", FlightMapFrame, "TOPRIGHT", 30, 8)
    _G.FlightMapFrameCloseButton:SetParent(FlightMapFrame)

    FlightMapFrame.BorderFrame:Hide()
end
GW.SkinFlightMap = SkinFlightMap