---@class GW2
local GW = select(2, ...)

local BAR_TEXTURE = "Interface/Addons/GW2_UI/textures/uistuff/gwstatusbar.png"
local CLOSE_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal.png"
local CLOSE_HOVER_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover.png"

-- the tooltips that get the GW2 UI frame, by global name; blizzards own and those of common addons
local TOOLTIPS = {
    "GameTooltip", "ShoppingTooltip1", "ShoppingTooltip2", "ShoppingTooltip3",
    "ItemRefTooltip", "ItemRefShoppingTooltip1", "ItemRefShoppingTooltip2", "ItemRefShoppingTooltip3",
    "EmbeddedItemTooltip", "FriendsTooltip", "WarCampaignTooltip", "ReputationParagonTooltip", "QuickKeybindTooltip",
    "GameSmallHeaderTooltip", "GarrisonShipyardMapMissionTooltip", "EventTraceTooltip", "FrameStackTooltip",
    "BattlePetTooltip", "FloatingBattlePetTooltip", "PetJournalPrimaryAbilityTooltip", "PetJournalSecondaryAbilityTooltip",
    "PetBattlePrimaryAbilityTooltip", "PetBattlePrimaryUnitTooltip", "FloatingPetBattleAbilityTooltip",
    "WorldMapTooltip", "WorldMapCompareTooltip1", "WorldMapCompareTooltip2", "WorldMapCompareTooltip3",
    "DatatextTooltip", "LibDBIconTooltip", "AtlasLootTooltip", "QuestHelperTooltip", "QuestGuru_QuestWatchTooltip",
    "TRP2_MainTooltip", "TRP2_ObjetTooltip", "TRP2_StaticPopupPersoTooltip", "TRP2_PersoTooltip", "TRP2_MountTooltip",
    "TRP3_MainTooltip", "TRP3_CompanionTooltip", "TRP3_ItemTooltip", "TRP3_NPCTooltip", "TRP3_TargetTooltip", "TRP3_CharacterTooltip",
    "AltoTooltip", "AltoScanningTooltip", "ArkScanTooltipTemplate", "NxTooltipItem", "NxTooltipD", "DBMInfoFrame", "DBMRangeCheck",
    "VengeanceTooltip", "FishingBuddyTooltip", "FishLibTooltip", "HealBot_ScanTooltip", "hbGameTooltip", "PlateBuffsTooltip",
    "LibGroupInSpecTScanTip", "RecountTempTooltip", "VuhDoScanTooltip", "XPerl_BottomTip",
}

local pawnRegistered = false

-- the GW2 UI frame instead of blizzards border; embedded tooltips keep their parents frame
local function SetStyle(tooltip, _, isEmbedded)
    if not tooltip or isEmbedded or tooltip.IsEmbedded or tooltip:IsForbidden() or GW.IsSecretValue(tooltip:GetWidth()) then
        return
    end
    for _, delimiter in pairs({tooltip.Delimiter1, tooltip.Delimiter2}) do
        delimiter:SetTexture()
    end
    if tooltip.NineSlice then
        tooltip.NineSlice:SetAlpha(0)
    end
    tooltip:GwSetFrameTemplate()
    tooltip:SetBackdropBorderColor(0.05, 0.05, 0.05, 1)

    -- pawn colors the border by upgrade, the frame stays dark
    if PawnRegisterThirdPartyTooltip and not pawnRegistered then
        pawnRegistered = true
        PawnRegisterThirdPartyTooltip("GW2_UI", {SetBackdropBorderColor = GW.NoOp})
    end
end

-- skins outside the tooltip modules style their own tooltips the same way
GW.Tooltip.SetStyle = SetStyle

local function SkinBar(bar)
    bar:GwStripTextures()
    bar:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
    bar.backdrop:SetBackdropBorderColor(GW.Colors.Fallback:GetRGBA())
    bar:SetStatusBarTexture(BAR_TEXTURE)
end

-- quest progress from red to green
local function ColorProgressBar(bar)
    local _, maximum = bar:GetMinMaxValues()
    local r, g, b = GW.ColorGradient(maximum > 0 and bar:GetValue() / maximum or 0, 0.8, 0, 0, 0.8, 0.8, 0, 0, 0.8, 0)
    bar:SetStatusBarColor(r, g, b)
    bar.backdrop:SetBackdropColor(r * 0.25, g * 0.25, b * 0.25)
end

local function SkinCloseButton(button)
    button:SetSize(20, 20)
    button:ClearAllPoints()
    button:SetPoint("TOPRIGHT", -3, -3)
end

local function SetFonts()
    local sizes = GW.settings.tooltip.fontSize
    local bodySize, smallSize = sizes.body, math.max(5, sizes.comparison)
    GameTooltipHeaderText:SetFont(DAMAGE_TEXT_FONT, math.max(5, sizes.header), "")
    GameTooltipText:SetFont(UNIT_NAME_FONT, bodySize, "")
    GameTooltipTextSmall:SetFont(UNIT_NAME_FONT, smallSize, "")
    GameTooltipStatusBar.Text:SetFont(DAMAGE_TEXT_FONT, sizes.healthBar, "OUTLINE")

    if GameTooltip.hasMoney then
        for i = 1, GameTooltip.numMoneyFrames do
            for _, part in ipairs({"PrefixText", "SuffixText", "GoldButtonText", "SilverButtonText", "CopperButtonText"}) do
                _G["GameTooltipMoneyFrame" .. i .. part]:SetFont(UNIT_NAME_FONT, bodySize, "")
            end
        end
    end
    if DatatextTooltip then
        DatatextTooltipTextLeft1:SetFont(UNIT_NAME_FONT, bodySize, "")
        DatatextTooltipTextRight1:SetFont(UNIT_NAME_FONT, bodySize, "")
    end
    for _, comparison in ipairs(GameTooltip.shoppingTooltips) do
        for _, region in ipairs({comparison:GetRegions()}) do
            if region:IsObjectType("FontString") then
                region:SetFont(UNIT_NAME_FONT, smallSize, "")
            end
        end
    end
end
GW.SetTooltipFonts = SetFonts

GW.RegisterTooltipModule({
    onLoad = function()
        for _, name in ipairs(TOOLTIPS) do
            SetStyle(_G[name])
        end
        SetFonts()

        -- status and progress bars inside tooltips
        hooksecurefunc("GameTooltip_ShowStatusBar", function(tooltip)
            local bar = not tooltip:IsForbidden() and tooltip.statusBarPool and tooltip.statusBarPool:GetNextActive()
            if bar and not bar.backdrop then
                SkinBar(bar)
            end
        end)
        hooksecurefunc("GameTooltip_ShowProgressBar", function(tooltip)
            local bar = not tooltip:IsForbidden() and tooltip.progressBarPool and tooltip.progressBarPool:GetNextActive()
            if bar and bar.Bar then
                if not bar.Bar.backdrop then
                    SkinBar(bar.Bar)
                end
                ColorProgressBar(bar.Bar)
            end
        end)

        local itemRefClose = ItemRefTooltip.CloseButton or ItemRefCloseButton
        itemRefClose:GwSkinButton(true)
        SkinCloseButton(itemRefClose)
        if ItemRefTooltip.PawnIconFrame then
            ItemRefTooltip.PawnIconFrame.PawnIconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        end

        if FloatingBattlePetTooltip then
            local close = FloatingBattlePetTooltip.CloseButton
            close:SetNormalTexture(CLOSE_TEXTURE)
            close:SetHighlightTexture(CLOSE_HOVER_TEXTURE)
            close:SetPushedTexture(CLOSE_HOVER_TEXTURE)
            SkinCloseButton(close)
            hooksecurefunc("SharedPetBattleAbilityTooltip_SetAbility", SetStyle)
        end

        QueueStatusFrame:GwStripTextures()
        QueueStatusFrame:GwCreateBackdrop({
            bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png",
            edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-border.png",
            edgeSize = 32,
            insets = {left = 2, right = 2, top = 2, bottom = 2},
        })

        -- the item preview inside the game tooltip
        local itemTooltip = GameTooltip.ItemTooltip
        if itemTooltip then
            GW.HandleIcon(itemTooltip.Icon, true)
            GW.HandleIconBorder(itemTooltip.IconBorder, itemTooltip.Icon.backdrop)
            itemTooltip.Count:ClearAllPoints()
            itemTooltip.Count:SetPoint("BOTTOMRIGHT", itemTooltip.Icon, "BOTTOMRIGHT", 1, 0)
            -- blizzard leaves it on the next tooltip
            GameTooltip:HookScript("OnTooltipCleared", function(tooltip)
                if not tooltip:IsForbidden() then
                    itemTooltip:Hide()
                end
            end)
        end

        if QuestScrollFrame and QuestScrollFrame.StoryTooltip then
            SetStyle(QuestScrollFrame.StoryTooltip)
            SetStyle(QuestScrollFrame.CampaignTooltip)
            QuestScrollFrame.StoryTooltip:SetFrameLevel(4)
        end
    end,
})
