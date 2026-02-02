local _, GW = ...

local function HandleIconString(self, text)
    if self._gw2SetText then return end
    if not text then text = self:GetText() end
    if not text or text == "" then return end

    local new, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:0:0:64:64:5:59:5:59|t")
    if count > 0 and new ~= text then
        self._gw2SetText = true
        self:SetFormattedText("%s", new)
        self._gw2SetText = false
    end
end

local function ReskinTalents(self)
    for frame in self.talentPool:EnumerateActive() do
        if not frame.IsSkinned then
            frame.Border:SetAlpha(0)
            frame.IconBorder:SetAlpha(0)
            frame.TierBorder:SetAlpha(0)
            frame.Background:SetAlpha(0)

            if not frame.SetBackdrop then
                _G.Mixin(frame, _G.BackdropTemplateMixin)
                frame:HookScript("OnSizeChanged", frame.OnBackdropSizeChanged)
            end
            frame:SetBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
            frame:SetBackdropBorderColor(1, 0.99, 0.85)

            GW.HandleIcon(frame.Icon, true)
            frame.Icon:SetPoint("TOPLEFT", 7, -7)
            frame.Highlight:SetColorTexture(1, 1, 1, 0.25)

            HandleIconString(frame.InfoText)
            hooksecurefunc(frame.InfoText, "SetText", HandleIconString)

            frame.IsSkinned = true
        end
    end
end

local function ReplaceCurrencies(displayGroup)
    for frame in displayGroup.currencyFramePool:EnumerateActive() do
        if not frame.IsSkinned then
            HandleIconString(frame.Text)
            hooksecurefunc(frame.Text, "SetText", HandleIconString)

            frame.IsSkinned = true
        end
    end
end

local function ApplyCovenantSanctumSkin()
    if not GW.settings.CONCENANT_SANCTUM_SKIN_ENABLED then return end

    CovenantSanctumFrame.LevelFrame.Level:SetFont(UNIT_NAME_FONT, 20)

    CovenantSanctumFrame.LevelFrame.Background:SetAlpha(0)

    local UpgradesTab = CovenantSanctumFrame.UpgradesTab
    UpgradesTab.Background:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    UpgradesTab.DepositButton:GwSkinButton(false, true)
    UpgradesTab.DepositButton:SetFrameLevel(10)
    UpgradesTab.CurrencyBackground:SetAlpha(0)
    ReplaceCurrencies(UpgradesTab.CurrencyDisplayGroup)

    for _, upgrade in ipairs(UpgradesTab.Upgrades) do
        if upgrade.TierBorder then
            upgrade.TierBorder:SetAlpha(0)
        end
    end

    local TalentList = CovenantSanctumFrame.UpgradesTab.TalentsList
    TalentList:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    TalentList.UpgradeButton:GwSkinButton(false, true)
    TalentList.UpgradeButton:SetFrameLevel(10)
    TalentList.IntroBox.Background:Hide()
    hooksecurefunc(TalentList, "Refresh", ReskinTalents)

    TalentList.Divider:SetAlpha(0)
    TalentList.BackgroundTile:SetAlpha(0)

    CovenantSanctumFrame:HookScript("OnShow", function()
        if not CovenantSanctumFrame.IsSkinned then
            --CovenantSanctumFrame:GwCreateBackdrop(GW.BackdropTemplates.Default, true)

            local tex = CovenantSanctumFrame:CreateTexture(nil, "BACKGROUND")
            tex:SetPoint("TOP", CovenantSanctumFrame, "TOP", 0, 25)
            tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
            local w, h = CovenantSanctumFrame:GetSize()
            tex:SetSize(w + 50, h + 50)
            CovenantSanctumFrame.tex = tex
            CovenantSanctumFrame.NineSlice:SetAlpha(0)

            CovenantSanctumFrame.CloseButton.Border:SetAlpha(0)
            CovenantSanctumFrame.CloseButton:GwSkinButton(true)
            CovenantSanctumFrame.CloseButton:SetSize(20, 20)
            CovenantSanctumFrame.CloseButton:ClearAllPoints()
            CovenantSanctumFrame.CloseButton:SetPoint("TOPRIGHT", CovenantSanctumFrame, "TOPRIGHT", 2, 2)

            CovenantSanctumFrame.IsSkinned = true
        end
    end)
end

local function LoadCovenantSanctumSkin()
    GW.RegisterLoadHook(ApplyCovenantSanctumSkin, "Blizzard_CovenantSanctum", CovenantSanctumFrame)
end
GW.LoadCovenantSanctumSkin = LoadCovenantSanctumSkin
