---@class GW2
local GW = select(2, ...)

local function LoadFlightMapSkin()
    if not GW.settings.skins.flightMap.enabled then return end

    TaxiFrame:GwStripTextures()

    GW.CreateFrameHeaderWithBody(TaxiFrame, TaxiFrame.TitleText, "Interface/AddOns/GW2_UI/textures/character/addon-window-icon.png", {}, nil, nil, true)
    TaxiFrame.gwHeader.windowIcon:SetSize(48, 48)
    TaxiFrame.gwHeader.windowIcon:ClearAllPoints()
    TaxiFrame.gwHeader.windowIcon:SetPoint("CENTER", TaxiFrame.gwHeader, "BOTTOMLEFT", 6 + 24, 19)

    TaxiFrame:HookScript("OnShow", function()
        GW.SetHeaderPortrait(TaxiFrame.gwHeader, "NPC")
    end)

    TaxiFrame.CloseButton:GwSkinButton(true, false)
    TaxiFrame.CloseButton:SetSize(25, 25)
    TaxiFrame.CloseButton:ClearAllPoints()
    TaxiFrame.CloseButton:SetPoint("TOPRIGHT", TaxiFrame, "TOPRIGHT", 0, 4)
    TaxiFrame.CloseButton:SetParent(TaxiFrame)
end
GW.LoadFlightMapSkin = LoadFlightMapSkin