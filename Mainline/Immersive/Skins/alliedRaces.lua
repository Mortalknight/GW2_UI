local _, GW = ...

local function ApplyAlliedRacesUISkin()
    if not GW.settings.ALLIEND_RACES_UI_SKIN_ENABLED then return end

    AlliedRacesFrame.NineSlice:SetAlpha(0)
    AlliedRacesFramePortrait:SetAlpha(0)
    AlliedRacesFrameBg:SetAlpha(0)
    AlliedRacesFrame.ModelScene:GwStripTextures()
    AlliedRacesFrame.ModelScene:ClearAllPoints()
    AlliedRacesFrame.ModelScene:SetPoint("LEFT", 0, -9)
    AlliedRacesFrame.ModelScene:SetHeight(565)

    select(2, AlliedRacesFrame.ModelScene:GetRegions()):Hide()

    GW.CreateFrameHeaderWithBody(AlliedRacesFrame, AlliedRacesFrameTitleText, "Interface/AddOns/GW2_UI/textures/icons/auction-window-icon.png", {AlliedRacesFrame.RaceInfoFrame}, nil, false, true)

    AlliedRacesFrame.Banner:Hide()
    AlliedRacesFrame.RaceInfoFrame.tex:ClearAllPoints()
    AlliedRacesFrame.RaceInfoFrame.tex:SetPoint("TOPLEFT", AlliedRacesFrame.RaceInfoFrame, "TOPLEFT", -35, -30)
    AlliedRacesFrame.RaceInfoFrame.tex:SetPoint("BOTTOMRIGHT", AlliedRacesFrame.RaceInfoFrame, "BOTTOMRIGHT", 0, 0)

    AlliedRacesFrameCloseButton:GwSkinButton(true)
    AlliedRacesFrameCloseButton:SetSize(20, 20)

    GW.HandleTrimScrollBar(AlliedRacesFrame.RaceInfoFrame.ScrollFrame.ScrollBar)
    GW.HandleScrollControls(AlliedRacesFrame.RaceInfoFrame.ScrollFrame)

    AlliedRacesFrame.FrameBackground:GwStripTextures()

    AlliedRacesFrame.RaceInfoFrame.ScrollFrame.Child:GwStripTextures()
    AlliedRacesFrame.RaceInfoFrame.ScrollFrame.Child.ObjectivesFrame:GwStripTextures()

    GW.AddDetailsBackground(AlliedRacesFrame.RaceInfoFrame.ScrollFrame.Child.ObjectivesFrame)
    AlliedRacesFrame.RaceInfoFrame.AlliedRacesRaceName:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    AlliedRacesFrame.RaceInfoFrame.ScrollFrame.Child.RaceDescriptionText:SetTextColor(1, 1, 1)
    AlliedRacesFrame.RaceInfoFrame.ScrollFrame.Child.RacialTraitsLabel:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

    AlliedRacesFrame:HookScript("OnShow", function(self)
        for button in self.abilityPool:EnumerateActive() do
            select(3, button:GetRegions()):Hide()
            GW.HandleIcon(button.Icon, true)

            button.Text:SetTextColor(1, 1, 1)
        end
    end)
end


local function LoadAlliedRacesUISkin()
    GW.RegisterLoadHook(ApplyAlliedRacesUISkin, "Blizzard_AlliedRacesUI", AlliedRacesFrame)
end
GW.LoadAlliedRacesUISkin = LoadAlliedRacesUISkin