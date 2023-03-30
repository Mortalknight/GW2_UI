local _, GW = ...
local GetSetting = GW.GetSetting

local function ApplyChromieTimerSkin()
    if not GetSetting("CHROMIE_TIME_SKIN_ENABLED") then return end

    ChromieTimeFrame.CloseButton:GwSkinButton(true)
    ChromieTimeFrame.CloseButton:SetSize(20, 20)
    ChromieTimeFrame.SelectButton:GwSkinButton(false, true)

    ChromieTimeFrame:GwStripTextures()
    ChromieTimeFrame.Background:Hide()
    local tex = ChromieTimeFrame:CreateTexture(nil, "BACKGROUND")
    tex:SetPoint("TOP", ChromieTimeFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = ChromieTimeFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    ChromieTimeFrame.tex = tex

    local Title = ChromieTimeFrame.Title
    Title:DisableDrawLayer("BACKGROUND")
    Title:GwCreateBackdrop(GW.skins.constBackdropFrame, true)

    local InfoFrame = ChromieTimeFrame.CurrentlySelectedExpansionInfoFrame
    InfoFrame:DisableDrawLayer("BACKGROUND")
    InfoFrame:GwCreateBackdrop(GW.skins.constBackdropFrame, true)
    InfoFrame.Name:SetTextColor(1, 0.8, 0)
    InfoFrame.Description:SetTextColor(1, 1, 1)
end

local function LoadChromieTimerSkin()
    GW.RegisterLoadHook(ApplyChromieTimerSkin, "Blizzard_ChromieTimeUI", ChromieTimeFrame)
end
GW.LoadChromieTimerSkin = LoadChromieTimerSkin