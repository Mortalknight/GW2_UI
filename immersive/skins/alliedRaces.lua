local _, GW = ...
local AFP = GW.AddProfiling

local function ApplyAlliedRacesUISkin()
    if not GW.GetSetting("ALLIEND_RACES_UI_SKIN_ENABLED") then return end

    AlliedRacesFrame.NineSlice:SetAlpha(0)
    AlliedRacesFramePortrait:SetAlpha(0)
    AlliedRacesFrameBg:SetAlpha(0)
    AlliedRacesFrame.TitleBg:SetAlpha(0)
    AlliedRacesFrame.ModelFrame:StripTextures()

    local tex = AlliedRacesFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", AlliedRacesFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = AlliedRacesFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    AlliedRacesFrame.tex = tex

    AlliedRacesFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    AlliedRacesFrameCloseButton:SkinButton(true)
    AlliedRacesFrameCloseButton:SetSize(20, 20)

    local scrollFrame = AlliedRacesFrame.RaceInfoFrame.ScrollFrame
    scrollFrame.ScrollBar.Border:Hide()
    scrollFrame.ScrollBar.ScrollUpBorder:Hide()
    scrollFrame.ScrollBar.ScrollDownBorder:Hide()
    scrollFrame:SkinScrollFrame()
    scrollFrame.ScrollBar:SkinScrollBar()

    scrollFrame.Child.ObjectivesFrame:StripTextures()
    scrollFrame.Child.ObjectivesFrame:CreateBackdrop(GW.skins.constBackdropFrame, true)

    AlliedRacesFrame.RaceInfoFrame.AlliedRacesRaceName:SetTextColor(1, 0.8, 0)
    scrollFrame.Child.RaceDescriptionText:SetTextColor(1, 1, 1)
    scrollFrame.Child.RacialTraitsLabel:SetTextColor(1, 0.8, 0)


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