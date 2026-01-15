local _, GW = ...

local function ApplyFlightMapSkin()
    if not GW.settings.FLIGHTMAP_SKIN_ENABLED then return end

    TaxiFrame:GwStripTextures()

    GW.CreateFrameHeaderWithBody(TaxiFrame, TaxiMerchant, "Interface/AddOns/GW2_UI/textures/character/addon-window-icon.png", nil, nil, nil, true)
    TaxiFrame.gwHeader.windowIcon:SetSize(65, 65)
    TaxiFrame.gwHeader.windowIcon:ClearAllPoints()
    TaxiFrame.gwHeader.windowIcon:SetPoint("CENTER", TaxiFrame.gwHeader.BGLEFT, "LEFT", 25, -5)

    TaxiFrame:HookScript("OnShow", function()
        SetPortraitTexture(TaxiFrame.gwHeader.windowIcon, "NPC")
    end)

    TaxiFrame:SetSize(350, 400)

    TaxiRouteMap:ClearAllPoints()
    TaxiRouteMap:SetPoint("TOP", TaxiFrame, 0, -35)
    TaxiMap:ClearAllPoints()
    TaxiMap:SetPoint("TOP", TaxiFrame, 0, -35)
    TaxiCloseButton:GwSkinButton(true, false)
    TaxiCloseButton:SetSize(25, 25)
    TaxiCloseButton:ClearAllPoints()
    TaxiCloseButton:SetPoint("TOPRIGHT", TaxiFrame, "TOPRIGHT", 0, 4)
    TaxiCloseButton:SetParent(TaxiFrame)
end

local function LoadFlightMapSkin()
    GW.RegisterLoadHook(ApplyFlightMapSkin, "Blizzard_FlightMap", TaxiFrame)
end
GW.LoadFlightMapSkin = LoadFlightMapSkin