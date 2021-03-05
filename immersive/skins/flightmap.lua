local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame

local function LoadFlightMapSkin()
    if not GW.GetSetting("FLIGHTMAP_SKIN_ENABLED") then return end

    FlightMap_LoadUI()

    local FlightMapFrame = _G.FlightMapFrame

    local tex = FlightMapFrame:CreateTexture("bg", "BACKGROUND")
    local w, h = FlightMapFrame:GetSize()
    tex:SetPoint("TOP", FlightMapFrame, "TOP", 10, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    tex:SetSize(w + 120, h + 80 )
    FlightMapFrame.tex = tex

    _G.FlightMapFrameCloseButton:SkinButton(true, false)
    _G.FlightMapFrameCloseButton:SetSize(25, 25)
    _G.FlightMapFrameCloseButton:ClearAllPoints()
    _G.FlightMapFrameCloseButton:SetPoint("TOPRIGHT", FlightMapFrame, "TOPRIGHT", 30, 8)
    _G.FlightMapFrameCloseButton:SetParent(FlightMapFrame)

    FlightMapFrame.BorderFrame:Hide()

    --Same for TaxiFrame
    local TaxiFrame = _G.TaxiFrame
    TaxiFrame:StripTextures()

    local tex = TaxiFrame:CreateTexture("bg", "BACKGROUND")
    local w, h = TaxiFrame:GetSize()
    tex:SetPoint("TOP", TaxiFrame, "TOP", 0, 20)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    tex:SetSize(w + 100, h + 60 )
    TaxiFrame.tex = tex

    TaxiFrame.CloseButton:SkinButton(true, false)
    TaxiFrame.CloseButton:SetSize(25, 25)
    TaxiFrame.CloseButton:ClearAllPoints()
    TaxiFrame.CloseButton:SetPoint("TOPRIGHT", TaxiFrame, "TOPRIGHT", 20, 4)
    TaxiFrame.CloseButton:SetParent(TaxiFrame)
end
GW.LoadFlightMapSkin = LoadFlightMapSkin