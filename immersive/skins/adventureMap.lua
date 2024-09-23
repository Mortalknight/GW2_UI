local _, GW = ...

local function SkinRewards()
    for reward in AdventureMapQuestChoiceDialog.rewardPool:EnumerateActive() do
        if not reward.IsSkinned then
            reward.ItemNameBG:GwStripTextures()
            reward.ItemNameBG:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)


            GW.HandleItemButton(reward)
            GW.HandleIcon(reward.Icon)
            reward.Icon:SetDrawLayer('OVERLAY')

            reward.IsSkinned = true
        end
    end
end

local function ApplyAdventureMapSkin()
    if not GW.settings.ADVENTURE_MAP_SKIN_ENABLED then return end

    --Quest Choise
    AdventureMapQuestChoiceDialog:GwStripTextures()
    AdventureMapQuestChoiceDialog:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    -- Rewards
    hooksecurefunc(AdventureMapQuestChoiceDialog, 'RefreshRewards', SkinRewards)
    -- Quick Fix for the Font Color
    AdventureMapQuestChoiceDialog.Details.Child.TitleHeader:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    AdventureMapQuestChoiceDialog.Details.Child.DescriptionText:SetTextColor(1, 1, 1)
    AdventureMapQuestChoiceDialog.Details.Child.ObjectivesHeader:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    AdventureMapQuestChoiceDialog.Details.Child.ObjectivesText:SetTextColor(1, 1, 1)
    --Buttons
    GW.HandleTrimScrollBar(AdventureMapQuestChoiceDialog.Details.ScrollBar)
    GW.HandleScrollControls(AdventureMapQuestChoiceDialog.Details)
    AdventureMapQuestChoiceDialog.CloseButton:GwSkinButton(true)
    AdventureMapQuestChoiceDialog.AcceptButton:GwSkinButton(false, true)
    AdventureMapQuestChoiceDialog.DeclineButton:GwSkinButton(false, true)
end

local function LoadAdventureMapSkin()
    GW.RegisterLoadHook(ApplyAdventureMapSkin, "Blizzard_AdventureMap", AdventureMapQuestChoiceDialog)
end
GW.LoadAdventureMapSkin = LoadAdventureMapSkin