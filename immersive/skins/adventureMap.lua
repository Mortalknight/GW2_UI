local _, GW = ...

local function SkinRewards()
    local pool = AdventureMapQuestChoiceDialog.rewardPool
    local objects = pool and pool.activeObjects
    if not objects then return end

    for reward in pairs(objects) do
        if not reward.IsSkinned then
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
    AdventureMapQuestChoiceDialog.Details.Child.TitleHeader:SetTextColor(1, 1, 1)
    AdventureMapQuestChoiceDialog.Details.Child.DescriptionText:SetTextColor(1, 1, 1)
    AdventureMapQuestChoiceDialog.Details.Child.ObjectivesHeader:SetTextColor(1, 1, 1)
    AdventureMapQuestChoiceDialog.Details.Child.ObjectivesText:SetTextColor(1, 1, 1)
    --Buttons
    AdventureMapQuestChoiceDialog.CloseButton:GwSkinButton(true)
    AdventureMapQuestChoiceDialog.Details:GwSkinScrollFrame()
    AdventureMapQuestChoiceDialog.Details.ScrollBar:GwSkinScrollBar()
    AdventureMapQuestChoiceDialog.AcceptButton:GwSkinButton(false, true)
    AdventureMapQuestChoiceDialog.DeclineButton:GwSkinButton(false, true)
end

local function LoadAdventureMapSkin()
    GW.RegisterLoadHook(ApplyAdventureMapSkin, "Blizzard_AdventureMap", AdventureMapQuestChoiceDialog)
end
GW.LoadAdventureMapSkin = LoadAdventureMapSkin