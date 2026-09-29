---@class GW2
local GW = select(2, ...)

local BACKGROUND = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png"

-- a talent row: our frame instead of blizzards borders
local function SkinTalent(talent)
    for _, art in ipairs({talent.Border, talent.IconBorder, talent.TierBorder, talent.Background}) do
        art:SetAlpha(0)
    end
    if not talent.SetBackdrop then
        Mixin(talent, BackdropTemplateMixin)
        talent:HookScript("OnSizeChanged", talent.OnBackdropSizeChanged)
    end
    talent:SetBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
    talent:SetBackdropBorderColor(1, 0.99, 0.85)

    GW.HandleIcon(talent.Icon, true)
    talent.Icon:SetPoint("TOPLEFT", 7, -7)
    talent.Highlight:SetColorTexture(1, 1, 1, 0.25)
    GW.KeepTextIconsSmall(talent.InfoText)
end

local function SkinCurrency(currency)
    GW.KeepTextIconsSmall(currency.Text)
end

-- the window gets our background once it has its size
local function SkinWindow(frame)
    if frame.tex then return end
    local width, height = frame:GetSize()
    frame.tex = frame:CreateTexture(nil, "BACKGROUND")
    frame.tex:SetPoint("TOP", frame, "TOP", 0, 25)
    frame.tex:SetSize(width + 50, height + 50)
    frame.tex:SetTexture(BACKGROUND)
    frame.NineSlice:SetAlpha(0)

    local close = frame.CloseButton
    close.Border:SetAlpha(0)
    close:GwSkinButton(true)
    close:SetSize(20, 20)
    close:ClearAllPoints()
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2, 2)
end

local function ApplyCovenantSanctumSkin()
    if not GW.settings.skins.covenantSanctum.enabled then return end
    local frame = CovenantSanctumFrame

    frame.LevelFrame.Level:SetFont(UNIT_NAME_FONT, 20)
    frame.LevelFrame.Background:SetAlpha(0)

    local upgrades = frame.UpgradesTab
    upgrades.Background:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    upgrades.CurrencyBackground:SetAlpha(0)
    GW.SkinPoolFrames(upgrades.CurrencyDisplayGroup.currencyFramePool, SkinCurrency)
    for _, upgrade in ipairs(upgrades.Upgrades) do
        if upgrade.TierBorder then
            upgrade.TierBorder:SetAlpha(0)
        end
    end

    local talents = upgrades.TalentsList
    talents:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    talents.IntroBox.Background:Hide()
    talents.Divider:SetAlpha(0)
    talents.BackgroundTile:SetAlpha(0)
    hooksecurefunc(talents, "Refresh", function(list) GW.SkinPoolFrames(list.talentPool, SkinTalent) end)

    -- the buttons sit above the backdrops
    for _, button in ipairs({upgrades.DepositButton, talents.UpgradeButton}) do
        button:GwSkinButton(false, true)
        button:SetFrameLevel(10)
    end

    frame:HookScript("OnShow", SkinWindow)
end

local function LoadCovenantSanctumSkin()
    GW.RegisterLoadHook(ApplyCovenantSanctumSkin, "Blizzard_CovenantSanctum", CovenantSanctumFrame)
end
GW.LoadCovenantSanctumSkin = LoadCovenantSanctumSkin
