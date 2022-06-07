local _, GW = ...

local function ApplyChromieTimerSkin()
    if not GW.GetSetting("CHROMIE_TIME_SKIN_ENABLED") then return end

    ChromieTimeFrame.CloseButton:SkinButton(true)
    ChromieTimeFrame.CloseButton:SetSize(20, 20)
    ChromieTimeFrame.SelectButton:SkinButton(false, true)

    ChromieTimeFrame:StripTextures()
    ChromieTimeFrame.Background:Hide()
    local tex = ChromieTimeFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", ChromieTimeFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = ChromieTimeFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    ChromieTimeFrame.tex = tex

    local Title = ChromieTimeFrame.Title
    Title:DisableDrawLayer("BACKGROUND")
    Title:CreateBackdrop(GW.skins.constBackdropFrame, true)

    local InfoFrame = ChromieTimeFrame.CurrentlySelectedExpansionInfoFrame
    InfoFrame:DisableDrawLayer("BACKGROUND")
    InfoFrame:CreateBackdrop(GW.skins.constBackdropFrame, true)
    InfoFrame.Name:SetTextColor(1, 0.8, 0)
    InfoFrame.Description:SetTextColor(1, 1, 1)
end

local function LoadChromieTimerSkin()
    GW.RegisterLoadHook(ApplyChromieTimerSkin, "Blizzard_ChromieTimeUI", ChromieTimeFrame)
end
GW.LoadChromieTimerSkin = LoadChromieTimerSkin