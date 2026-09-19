---@class GW2
local GW = select(2, ...)

local MAP_SIZE = 580
local MAP_INSET_TOP = 46

local function SkinFlightMapFrame()
    if FlightMapFrame.gwSkinned then return end
    FlightMapFrame.gwSkinned = true

    local tex = FlightMapFrame:CreateTexture(nil, "BACKGROUND")
    local w, h = FlightMapFrame:GetSize()
    tex:SetPoint("TOP", FlightMapFrame, "TOP", 10, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
    tex:SetSize(w + 120, h + 80)
    FlightMapFrame.tex = tex

    FlightMapFrameCloseButton:GwSkinButton(true, false)
    FlightMapFrameCloseButton:SetSize(25, 25)
    FlightMapFrameCloseButton:ClearAllPoints()
    FlightMapFrameCloseButton:SetPoint("TOPRIGHT", FlightMapFrame, "TOPRIGHT", 30, 8)
    FlightMapFrameCloseButton:SetParent(FlightMapFrame)

    FlightMapFrame.BorderFrame:Hide()
end

local function SkinTaxiFrame()
    TaxiFrame:GwStripTextures()
    TaxiFrame:SetSize(MAP_SIZE + 10, MAP_SIZE + MAP_INSET_TOP + 14)

    GW.CreateFrameHeaderWithBody(TaxiFrame, TaxiFrame.TitleText, "Interface/AddOns/GW2_UI/textures/character/worldmap-window-icon.png", nil, nil, nil, true)
    TaxiFrame.gwHeader.windowIcon:SetSize(48, 48)
    TaxiFrame.gwHeader.windowIcon:ClearAllPoints()
    TaxiFrame.gwHeader.windowIcon:SetPoint("CENTER", TaxiFrame.gwHeader, "BOTTOMLEFT", 30, 19)

    TaxiFrame.InsetBg:ClearAllPoints()
    TaxiFrame.InsetBg:SetPoint("TOPLEFT", TaxiFrame, "TOPLEFT", 5, -MAP_INSET_TOP)
    TaxiFrame.InsetBg:SetSize(MAP_SIZE, MAP_SIZE)

    TaxiFrame.CloseButton:GwSkinButton(true, false)
    TaxiFrame.CloseButton:SetSize(25, 25)
    TaxiFrame.CloseButton:ClearAllPoints()
    TaxiFrame.CloseButton:SetPoint("TOPRIGHT", TaxiFrame, "TOPRIGHT", -6, 4)

    TaxiFrame:HookScript("OnShow", function()
        GW.SetHeaderPortrait(TaxiFrame.gwHeader, "npc")
    end)
end

local function LoadFlightMapSkin()
    if not GW.settings.skins.flightMap.enabled then return end

    SkinTaxiFrame()
    GW.RegisterLoadHook(SkinFlightMapFrame, "Blizzard_FlightMap", FlightMapFrame)
end
GW.LoadFlightMapSkin = LoadFlightMapSkin
