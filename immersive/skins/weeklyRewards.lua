local _, GW = ...
local GetSetting = GW.GetSetting

local function UpdateSelection(frame)
    if not frame.backdrop then return end

    if frame.SelectedTexture:IsShown() then
        frame.backdrop:SetBackdropBorderColor(1, 0.8, 0)
    else
        frame.backdrop:SetBackdropBorderColor(0, 0, 0)
    end
end

local r, g, b = GetItemQualityColor(Enum.ItemQuality.Epic or 4)
local function SkinRewardIcon(itemFrame)
    if not itemFrame.IsSkinned then
        itemFrame:GwCreateBackdrop("Transparent")
        itemFrame:DisableDrawLayer("BORDER")
        itemFrame.Icon:SetPoint("LEFT", 6, 0)
        GW.HandleIcon(itemFrame.Icon, true)
        itemFrame.backdrop:SetBackdropBorderColor(r, g, b)
        itemFrame.IsSkinned = true
    end
end

local function SkinActivityFrame(frame, isObject)
    if frame.Border then
        if isObject then
            frame.Border:SetAlpha(0)
            frame.SelectedTexture:SetAlpha(0)
            frame.LockIcon:SetVertexColor(1, 1, 1)--???
            hooksecurefunc(frame, "SetSelectionState", UpdateSelection)
            hooksecurefunc(frame.ItemFrame, "SetDisplayedItem", SkinRewardIcon)
        else
            frame.Border:SetTexCoord(0.926, 1, 0, 1)
            frame.Border:SetSize(25, 137)
            frame.Border:SetPoint("LEFT", frame, "RIGHT", 3, 0)
        end
    end

    if frame.Background then
        frame.Background:GwCreateBackdrop()
    end
end

local function ReplaceIconString(self, text)
    if not text then text = self:GetText() end
    if not text or text == "" then return end

    local newText, count = gsub(text, "24:24:0:%-2", "14:14:0:0:64:64:5:59:5:59")
    if count > 0 then self:SetFormattedText("%s", newText) end
end

local function ReskinConfirmIcon(frame)
    GW.HandleIcon(frame.Icon, true)
    GW.HandleIconBorder(frame.IconBorder, frame.Icon.backdrop)
end

local function ApplyWeeklyRewardsSkin()
    if not GetSetting("WEEKLY_REWARDS_SKIN_ENABLED") then return end

    WeeklyRewardsFrame:GwStripTextures()
    local tex = WeeklyRewardsFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", WeeklyRewardsFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = WeeklyRewardsFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    WeeklyRewardsFrame.tex = tex

    WeeklyRewardsFrame.HeaderFrame:GwStripTextures()
    WeeklyRewardsFrame.HeaderFrame:GwCreateBackdrop(GW.skins.constBackdropFrame, true)
    WeeklyRewardsFrame.HeaderFrame:ClearAllPoints()
    WeeklyRewardsFrame.HeaderFrame:SetPoint("TOP", 1, -42)

    WeeklyRewardsFrame.CloseButton:GwSkinButton(true)
    WeeklyRewardsFrame.CloseButton:SetSize(20, 20)
    WeeklyRewardsFrame.SelectRewardButton:GwSkinButton(false, true)

    SkinActivityFrame(WeeklyRewardsFrame.RaidFrame)
    SkinActivityFrame(WeeklyRewardsFrame.MythicFrame)
    SkinActivityFrame(WeeklyRewardsFrame.PVPFrame)

    for _, activity in pairs(WeeklyRewardsFrame.Activities) do
        SkinActivityFrame(activity, true)
    end

    hooksecurefunc(WeeklyRewardsFrame, "SelectReward", function(reward)
        local selection = reward.confirmSelectionFrame
        if selection then
            _G.WeeklyRewardsFrameNameFrame:Hide()
            ReskinConfirmIcon(selection.ItemFrame)

            local alsoItems = selection.AlsoItemsFrame
            if alsoItems and alsoItems.pool then
                for items in alsoItems.pool:EnumerateActive() do
                    ReskinConfirmIcon(items)
                end
            end
        end
    end)

    hooksecurefunc(WeeklyRewardsFrame, "UpdateOverlay", function()
        local overlay = WeeklyRewardsFrame.Overlay
        if overlay then
            overlay:GwStripTextures()
            if not overlay.SetBackdrop then
                _G.Mixin(overlay, _G.BackdropTemplateMixin)
                overlay:HookScript("OnSizeChanged", overlay.OnBackdropSizeChanged)
            end
            overlay:SetBackdrop(GW.constBackdropFrameColorBorder)
            overlay:SetBackdropBorderColor(1, 0.99, 0.85)
        end
    end)

    local rewardText = WeeklyRewardsFrame.ConcessionFrame.RewardsFrame.Text
    ReplaceIconString(rewardText)
    hooksecurefunc(rewardText, "SetText", ReplaceIconString)
end

local function LoadWeeklyRewardsSkin()
    GW.RegisterLoadHook(ApplyWeeklyRewardsSkin, "Blizzard_WeeklyRewards", WeeklyRewardsFrame)
end
GW.LoadWeeklyRewardsSkin = LoadWeeklyRewardsSkin