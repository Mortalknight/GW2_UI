local _, GW = ...

local function LoadFlightMapSkin()
    if not GW.settings.FLIGHTMAP_SKIN_ENABLED then return end

    TaxiFrame:GwStripTextures()

    GW.CreateFrameHeaderWithBody(TaxiFrame, TaxiFrame.TitleText, "Interface/AddOns/GW2_UI/textures/character/addon-window-icon", {}, nil, nil, true)
    TaxiFrame.gwHeader.windowIcon:SetSize(65, 65)
    TaxiFrame.gwHeader.windowIcon:ClearAllPoints()
    TaxiFrame.gwHeader.windowIcon:SetPoint("CENTER", TaxiFrame.gwHeader.BGLEFT, "LEFT", 25, -5)

    TaxiFrame:HookScript("OnShow", function()
        SetPortraitTexture(TaxiFrame.gwHeader.windowIcon, "NPC")
    end)

    TaxiFrame.CloseButton:GwSkinButton(true, false)
    TaxiFrame.CloseButton:SetSize(25, 25)
    TaxiFrame.CloseButton:ClearAllPoints()
    TaxiFrame.CloseButton:SetPoint("TOPRIGHT", TaxiFrame, "TOPRIGHT", 0, 4)
    TaxiFrame.CloseButton:SetParent(TaxiFrame)
end
GW.LoadFlightMapSkin = LoadFlightMapSkin