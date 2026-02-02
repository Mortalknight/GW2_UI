local _, GW = ...

local function ReskinConfirmIcon(frame)
    GW.HandleIcon(frame.Icon, true)
    GW.HandleIconBorder(frame.IconBorder, frame.Icon.backdrop)
end

local color = GW.GetQualityColor(Enum.ItemQuality.Epic or 4)
local function SkinRewardIcon(itemFrame)
    if not itemFrame.IsSkinned then
        itemFrame:GwCreateBackdrop("Transparent")
        itemFrame:DisableDrawLayer("BORDER")
        itemFrame.Icon:SetPoint("LEFT", 6, 0)
        GW.HandleIcon(itemFrame.Icon, true)
        itemFrame.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
        itemFrame.IsSkinned = true
    end
end

local function SelectReward(reward)
    local selection = reward.confirmSelectionFrame
    if selection then
        WeeklyRewardsFrameNameFrame:Hide()
        ReskinConfirmIcon(selection.ItemFrame)

        local alsoItems = selection.AlsoItemsFrame
        if alsoItems and alsoItems.pool then
            for items in alsoItems.pool:EnumerateActive() do
                ReskinConfirmIcon(items)
            end
        end
    end
end

local function UpdateOverlay(frame)
    local overlay = frame.Overlay
    if overlay then
        overlay:GwStripTextures()
        if not overlay.SetBackdrop then
            _G.Mixin(overlay, _G.BackdropTemplateMixin)
            overlay:HookScript("OnSizeChanged", overlay.OnBackdropSizeChanged)
        end
        overlay:SetBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
        overlay:SetBackdropBorderColor(1, 0.99, 0.85)
    end
end

local function HandleWarning(frame)
    frame:GwStripTextures()
    frame:GwCreateBackdrop("Transparent")
    frame.ExtraBG:Hide()
end

local function UpdateSelection(frame)
    if not frame.backdrop then return end

    if frame.SelectedTexture:IsShown() then
        frame.backdrop:SetBackdropBorderColor(1, 0.8, 0)
    else
        frame.backdrop:SetBackdropBorderColor(0, 0, 0)
    end
end


local function SkinActivityFrame(frame, isObject)
    if not frame then return end


    if isObject then
        if frame.Border then
            frame.Border:SetAlpha(0)
        end

        if frame.ItemFrame then
            hooksecurefunc(frame.ItemFrame, "SetDisplayedItem", SkinRewardIcon)
        elseif frame.UnselectedFrame then
            frame:GwCreateBackdrop("Transparent")
            frame.SelectedTexture:SetAlpha(0)
            frame.UnselectedFrame:SetAlpha(0)

            hooksecurefunc(frame, "SetSelectionState", UpdateSelection)
        end
    else
        if frame.Border then
            frame.Border:SetTexCoord(.926, 1, 0, 1)
            frame.Border:SetPoint("LEFT", frame, "RIGHT", 3, 0)
            frame.Border:SetSize(25, 137)
        end

        if frame.Background and frame.Name then
            frame.Background:SetSize(390, 140)
            frame.Background:SetDrawLayer("ARTWORK", 2)

            frame.Background:GwCreateBackdrop("Transparent")
            frame.Background.backdrop.Center:SetDrawLayer("ARTWORK", 1)

            frame.Name:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
        end
    end
end

local function ReplaceIconString(self, text)
    if self._gw2SetText then return end
    if not text then text = self:GetText() end
    if not text or text == "" then return end

    local newText, count = gsub(text, "24:24:0:%-2", "14:14:0:0:64:64:5:59:5:59")
    if count > 0 and newText ~= text then
        self._gw2SetText = true
        self:SetFormattedText("%s", newText)
        self._gw2SetText = false
    end
end

local function ApplyWeeklyRewardsSkin()
    if not GW.settings.WEEKLY_REWARDS_SKIN_ENABLED then return end

    WeeklyRewardsFrame:GwStripTextures()
    GW.CreateFrameHeaderWithBody(WeeklyRewardsFrame, nil, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon.png", {WeeklyRewardsFrame}, nil, false, true)

    WeeklyRewardsFrame.titleText = WeeklyRewardsFrame:CreateFontString(nil, "OVERLAY")
    WeeklyRewardsFrame.titleText:SetParent(WeeklyRewardsFrame.gwHeader)
    WeeklyRewardsFrame.titleText:SetPoint("BOTTOMLEFT", WeeklyRewardsFrame.gwHeader, "BOTTOMLEFT", 64, 10)
    WeeklyRewardsFrame.titleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 2)
    WeeklyRewardsFrame.titleText:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    WeeklyRewardsFrame.titleText:SetText(RATED_PVP_WEEKLY_VAULT)

    WeeklyRewardsFrame.BorderContainer:GwStripTextures()
    WeeklyRewardsFrame.ConcessionFrame:GwStripTextures()

    WeeklyRewardsFrame.HeaderFrame:GwStripTextures()
    WeeklyRewardsFrame.HeaderFrame:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    WeeklyRewardsFrame.HeaderFrame.backdrop:SetFrameLevel(WeeklyRewardsFrame:GetFrameLevel() + 1)
    WeeklyRewardsFrame.HeaderFrame:ClearAllPoints()
    WeeklyRewardsFrame.HeaderFrame:SetPoint("TOP", 1, -42)
    WeeklyRewardsFrame.HeaderFrame.Text:ClearAllPoints()
    WeeklyRewardsFrame.HeaderFrame.Text:SetPoint("CENTER")

    WeeklyRewardsFrame.CloseButton:GwSkinButton(true)
    WeeklyRewardsFrame.CloseButton:SetSize(25, 25)
    WeeklyRewardsFrame.SelectRewardButton:GwSkinButton(false, true)

    SkinActivityFrame(WeeklyRewardsFrame.RaidFrame)
    SkinActivityFrame(WeeklyRewardsFrame.MythicFrame)
    SkinActivityFrame(WeeklyRewardsFrame.PVPFrame)
    SkinActivityFrame(WeeklyRewardsFrame.WorldFrame)

    for _, activity in pairs(WeeklyRewardsFrame.Activities) do
        SkinActivityFrame(activity, true)
    end

    local rewardText = WeeklyRewardsFrame.ConcessionFrame.RewardsFrame.Text
    if rewardText then
        ReplaceIconString(rewardText)
        hooksecurefunc(rewardText, "SetText", ReplaceIconString)
    end

    if WeeklyRewardExpirationWarningDialog then
        WeeklyRewardExpirationWarningDialog:SetPoint("TOP", WeeklyRewardsFrame, "BOTTOM", 0, -1)
        WeeklyRewardExpirationWarningDialog.NineSlice:HookScript("OnShow", HandleWarning)
    end

    hooksecurefunc(WeeklyRewardsFrame, "SelectReward", SelectReward)
    hooksecurefunc(WeeklyRewardsFrame, "UpdateOverlay", UpdateOverlay)
end

local function LoadWeeklyRewardsSkin()
    GW.RegisterLoadHook(ApplyWeeklyRewardsSkin, "Blizzard_WeeklyRewards", WeeklyRewardsFrame)
end
GW.LoadWeeklyRewardsSkin = LoadWeeklyRewardsSkin
