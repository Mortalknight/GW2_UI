local _, GW = ...
local GetSetting = GW.GetSetting

local function ApplyFlightMapSkin()
    if not GetSetting("FLIGHTMAP_SKIN_ENABLED") then return end

    local tex = FlightMapFrame:CreateTexture("bg", "BACKGROUND")
    local w, h = FlightMapFrame:GetSize()
    tex:SetPoint("TOP", FlightMapFrame, "TOP", 10, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    tex:SetSize(w + 120, h + 80 )
    FlightMapFrame.tex = tex

    _G.FlightMapFrameCloseButton:GwSkinButton(true, false)
    _G.FlightMapFrameCloseButton:SetSize(25, 25)
    _G.FlightMapFrameCloseButton:ClearAllPoints()
    _G.FlightMapFrameCloseButton:SetPoint("TOPRIGHT", FlightMapFrame, "TOPRIGHT", 30, 8)
    _G.FlightMapFrameCloseButton:SetParent(FlightMapFrame)

    FlightMapFrame.BorderFrame:Hide()

    --Same for TaxiFrame
    local TaxiFrame = _G.TaxiFrame
    TaxiFrame:GwStripTextures()

    local tex = TaxiFrame:CreateTexture("bg", "BACKGROUND")
    local w, h = TaxiFrame:GetSize()
    tex:SetPoint("TOP", TaxiFrame, "TOP", 0, 20)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    tex:SetSize(w + 100, h + 60 )
    TaxiFrame.tex = tex

    TaxiFrame.CloseButton:GwSkinButton(true, false)
    TaxiFrame.CloseButton:SetSize(25, 25)
    TaxiFrame.CloseButton:ClearAllPoints()
    TaxiFrame.CloseButton:SetPoint("TOPRIGHT", TaxiFrame, "TOPRIGHT", 20, 4)
    TaxiFrame.CloseButton:SetParent(TaxiFrame)
end

local function LoadFlightMapSkin()
    GW.RegisterLoadHook(ApplyFlightMapSkin, "Blizzard_FlightMap", FlightMapFrame)
end
GW.LoadFlightMapSkin = LoadFlightMapSkin