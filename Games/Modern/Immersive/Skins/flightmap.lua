---@class GW2
local GW = select(2, ...)

local function ApplyFlightMapSkin()
    if not GW.settings.skins.flightMap.enabled then return end

    if FlightMapFrame and not FlightMapFrame.gwSkinned then
        local tex = FlightMapFrame:CreateTexture(nil, "BACKGROUND")
        local w, h = FlightMapFrame:GetSize()
        tex:SetPoint("TOP", FlightMapFrame, "TOP", 10, 25)
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
        tex:SetSize(w + 120, h + 80 )
        FlightMapFrame.tex = tex

        _G.FlightMapFrameCloseButton:GwSkinButton(true, false)
        _G.FlightMapFrameCloseButton:SetSize(25, 25)
        _G.FlightMapFrameCloseButton:ClearAllPoints()
        _G.FlightMapFrameCloseButton:SetPoint("TOPRIGHT", FlightMapFrame, "TOPRIGHT", 30, 8)
        _G.FlightMapFrameCloseButton:SetParent(FlightMapFrame)

        FlightMapFrame.BorderFrame:Hide()
        FlightMapFrame.gwSkinned = true
    end

    --Same for TaxiFrame
    if TaxiFrame and not TaxiFrame.gwSkinned then
        local TaxiFrame = _G.TaxiFrame
        TaxiFrame:GwStripTextures()

        local tex = TaxiFrame:CreateTexture(nil, "BACKGROUND")
        local w, h = TaxiFrame:GetSize()
        tex:SetPoint("TOP", TaxiFrame, "TOP", 0, 20)
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
        tex:SetSize(w + 100, h + 60 )
        TaxiFrame.tex = tex

        TaxiFrame.CloseButton:GwSkinButton(true, false)
        TaxiFrame.CloseButton:SetSize(25, 25)
        TaxiFrame.CloseButton:ClearAllPoints()
        TaxiFrame.CloseButton:SetPoint("TOPRIGHT", TaxiFrame, "TOPRIGHT", 20, 4)
        TaxiFrame.CloseButton:SetParent(TaxiFrame)

        TaxiFrame.gwSkinned = true
    end
end

local function LoadFlightMapSkin()
    GW.RegisterLoadHook(ApplyFlightMapSkin, "Blizzard_FlightMap", FlightMapFrame)
    GW.RegisterLoadHook(ApplyFlightMapSkin, "Blizzard_FlightMap", TaxiFrame)
end
GW.LoadFlightMapSkin = LoadFlightMapSkin