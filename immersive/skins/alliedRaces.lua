local _, GW = ...
local AFP = GW.AddProfiling

local function ApplyAlliedRacesUISkin()
    if not GW.settings.ALLIEND_RACES_UI_SKIN_ENABLED then return end

    AlliedRacesFrame.NineSlice:SetAlpha(0)
    AlliedRacesFramePortrait:SetAlpha(0)
    AlliedRacesFrameBg:SetAlpha(0)
    AlliedRacesFrame.ModelScene:GwStripTextures()

    select(2, AlliedRacesFrame.ModelScene:GetRegions()):Hide()

    local tex = AlliedRacesFrame:CreateTexture(nil, "BACKGROUND")
    tex:SetPoint("TOP", AlliedRacesFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = AlliedRacesFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    AlliedRacesFrame.tex = tex

    AlliedRacesFrame.Banner:Hide()

    AlliedRacesFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    AlliedRacesFrameCloseButton:GwSkinButton(true)
    AlliedRacesFrameCloseButton:SetSize(20, 20)

    GW.HandleTrimScrollBar(AlliedRacesFrame.RaceInfoFrame.ScrollFrame.ScrollBar)
    GW.HandleScrollControls(AlliedRacesFrame.RaceInfoFrame.ScrollFrame)

    AlliedRacesFrame.FrameBackground:GwStripTextures()
    AlliedRacesFrame.FrameBackground:GwCreateBackdrop(GW.BackdropTemplates.Default, true)

    AlliedRacesFrame.RaceInfoFrame.ScrollFrame.Child:GwStripTextures()
    AlliedRacesFrame.RaceInfoFrame.ScrollFrame.Child.ObjectivesFrame:GwStripTextures()
    AlliedRacesFrame.RaceInfoFrame.ScrollFrame.Child.ObjectivesFrame:GwCreateBackdrop(GW.BackdropTemplates.Default, true)

    AlliedRacesFrame.RaceInfoFrame.AlliedRacesRaceName:SetTextColor(1, 0.8, 0)
    AlliedRacesFrame.RaceInfoFrame.ScrollFrame.Child.RaceDescriptionText:SetTextColor(1, 1, 1)
    AlliedRacesFrame.RaceInfoFrame.ScrollFrame.Child.RacialTraitsLabel:SetTextColor(1, 0.8, 0)


    AlliedRacesFrame:HookScript("OnShow", function(self)
        for button in self.abilityPool:EnumerateActive() do
            select(3, button:GetRegions()):Hide()
            GW.HandleIcon(button.Icon, true)

            button.Text:SetTextColor(1, 1, 1)
        end
    end)
end
AFP("ApplyAlliedRacesUISkin", ApplyAlliedRacesUISkin)

local function LoadAlliedRacesUISkin()
    GW.RegisterLoadHook(ApplyAlliedRacesUISkin, "Blizzard_AlliedRacesUI", AlliedRacesFrame)
end
GW.LoadAlliedRacesUISkin = LoadAlliedRacesUISkin