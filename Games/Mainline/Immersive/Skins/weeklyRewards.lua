---@class GW2
local GW = select(2, ...)

local LOCK_TEXTURE = "Interface/AddOns/GW2_UI/textures/talents/lock.png"
local epicColor = GW.GetQualityColor(Enum.ItemQuality.Epic or 4)

-- the items of the confirm dialog: square icons, the quality on our frame
local function SkinConfirmItem(item)
    GW.HandleIcon(item.Icon, true)
    GW.HandleIconBorder(item.IconBorder, item.Icon.backdrop)
end

local function SkinRewardIcon(itemFrame)
    if not itemFrame.gwSkinned then
        itemFrame:GwCreateBackdrop("Transparent")
        itemFrame:DisableDrawLayer("BORDER")
        itemFrame.Icon:SetPoint("LEFT", 6, 0)
        GW.HandleIcon(itemFrame.Icon, true)
        itemFrame.backdrop:SetBackdropBorderColor(epicColor.r, epicColor.g, epicColor.b)
        itemFrame.gwSkinned = true
    end
end

-- picking a reward opens the confirm dialog over the vault; its extra items come from a pool
local function SkinConfirmDialog(vault)
    local dialog = vault.confirmSelectionFrame
    if not dialog then return end
    WeeklyRewardsFrameNameFrame:Hide()
    SkinConfirmItem(dialog.ItemFrame)
    local alsoItems = dialog.AlsoItemsFrame
    GW.SkinPoolFrames(alsoItems and alsoItems.pool, SkinConfirmItem)
end

-- the overlay over a locked vault, in our frame with the light border
local function SkinVaultOverlay(vault)
    local overlay = vault.Overlay
    if not overlay then return end
    overlay:GwStripTextures()
    if not overlay.SetBackdrop then
        Mixin(overlay, BackdropTemplateMixin)
        overlay:HookScript("OnSizeChanged", overlay.OnBackdropSizeChanged)
    end
    overlay:SetBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
    overlay:SetBackdropBorderColor(GW.Colors.SkinColors.CreamBorder:GetRGB())
end

local function HandleWarning(frame)
    frame:GwStripTextures()
    frame:GwCreateBackdrop("Transparent")
    frame.ExtraBG:Hide()
end

-- border color tells the state: gold = selected, epic = unlocked reward, dark = locked / none
local function SetStateBorder(frame, selected, unlocked)
    if not frame.backdrop then return end
    if selected then
        frame.backdrop:SetBackdropBorderColor(1, 0.8, 0)
    elseif unlocked then
        frame.backdrop:SetBackdropBorderColor(epicColor.r, epicColor.g, epicColor.b)
    else
        frame.backdrop:SetBackdropBorderColor(GW.Colors.Fallback:GetRGB())
    end
end

---------- activity slots (the 3 x 3 reward boxes) ----------
local function UpdateActivityState(frame)
    local unlocked = frame.CompletedIcon:IsShown()
    if frame.gwLock then
        frame.gwLock:SetShown(not unlocked)
    end
    SetStateBorder(frame, frame.SelectedTexture:IsShown(), unlocked)
end

local function SkinActivity(frame)
    if not frame or frame.gwSkinned then return end
    frame.gwSkinned = true

    -- blizzards bevelled slot art (locked / unlocked atlas) and the selection frames
    frame.Background:SetAlpha(0)
    if frame.Border then
        frame.Border:SetAlpha(0)
    end
    frame.SelectedTexture:SetAlpha(0)
    frame.UnselectedFrame:SetAlpha(0)
    frame:GwCreateBackdrop("Transparent")

    -- own lock for locked slots, sits where the reward item appears later
    frame.gwLock = frame:CreateTexture(nil, "ARTWORK")
    frame.gwLock:SetTexture(LOCK_TEXTURE)
    frame.gwLock:SetSize(34, 34)
    frame.gwLock:SetPoint("CENTER", frame, "CENTER", 0, -8)
    frame.gwLock:SetDesaturated(true)
    frame.gwLock:SetAlpha(0.5)

    frame.Threshold:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    frame.Progress:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)

    if frame.ItemFrame then
        hooksecurefunc(frame.ItemFrame, "SetDisplayedItem", SkinRewardIcon)
    end
    hooksecurefunc(frame, "Refresh", UpdateActivityState)
    hooksecurefunc(frame, "SetSelectionState", UpdateActivityState)
    UpdateActivityState(frame)
end

---------- activity type frames (raid / dungeon / world artwork on the left) ----------
local function SkinActivityType(frame)
    if not frame or frame.gwSkinned then return end
    frame.gwSkinned = true

    if frame.Border then
        frame.Border:SetAlpha(0)
    end

    -- the artwork fills the frame, the gw2 border frames it
    frame:GwCreateBackdrop("Transparent")
    frame.Background:ClearAllPoints()
    frame.Background:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    frame.Background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)

    -- dark strip behind the name for readability on bright artwork
    frame.gwNameShade = frame:CreateTexture(nil, "BORDER")
    frame.gwNameShade:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    frame.gwNameShade:SetVertexColor(0, 0, 0, 0.6)
    frame.gwNameShade:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    frame.gwNameShade:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
    frame.gwNameShade:SetHeight(44)

    frame.Name:ClearAllPoints()
    frame.Name:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -10)
    frame.Name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader)
    frame.Name:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
end

---------- concessions ("or take the currency") ----------
local function UpdateConcessionState(frame)
    SetStateBorder(frame, frame.SelectedTexture:IsShown(), true)
end

local function SkinConcession(frame)
    if not frame or frame.gwSkinned then return end
    frame.gwSkinned = true

    frame.Background:SetAlpha(0)
    frame.SelectedTexture:SetAlpha(0)
    frame.UnselectedFrame:SetAlpha(0)
    frame:GwCreateBackdrop("Transparent")

    if frame.RewardsFrame then
        if frame.RewardsFrame.Label then
            frame.RewardsFrame.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        end
        if frame.RewardsFrame.Text then
            frame.RewardsFrame.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        end
    end

    hooksecurefunc(frame, "SetSelectionState", UpdateConcessionState)
    UpdateConcessionState(frame)
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
    if not GW.settings.skins.weeklyRewards.enabled then return end

    WeeklyRewardsFrame:GwStripTextures()
    GW.CreateFrameHeaderWithBody(WeeklyRewardsFrame, nil, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon.png", {WeeklyRewardsFrame}, nil, false, true)

    WeeklyRewardsFrame.titleText = WeeklyRewardsFrame:CreateFontString(nil, "OVERLAY")
    WeeklyRewardsFrame.titleText:SetParent(WeeklyRewardsFrame.gwHeader)
    WeeklyRewardsFrame.titleText:SetPoint("BOTTOMLEFT", WeeklyRewardsFrame.gwHeader, "BOTTOMLEFT", 64, 10)
    WeeklyRewardsFrame.titleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
    WeeklyRewardsFrame.titleText:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    WeeklyRewardsFrame.titleText:SetText(RATED_PVP_WEEKLY_VAULT)

    WeeklyRewardsFrame.BorderContainer:GwStripTextures()
    WeeklyRewardsFrame.ConcessionsFrame:GwStripTextures()

    -- intro text: plain line with a separator instead of a boxed panel
    local header = WeeklyRewardsFrame.HeaderFrame
    header:GwStripTextures()
    header:ClearAllPoints()
    header:SetPoint("TOP", 1, -42)
    header.Text:ClearAllPoints()
    header.Text:SetPoint("CENTER", header, "CENTER", 0, 4)
    header.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    header.Text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    header.gwLine = header:CreateTexture(nil, "ARTWORK")
    header.gwLine:SetColorTexture(GW.Colors.SkinColors.HeaderBorder:GetRGBA())
    header.gwLine:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 60, 12)
    header.gwLine:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -60, 12)
    header.gwLine:SetHeight(1)

    WeeklyRewardsFrame.CloseButton:GwSkinButton(true)
    WeeklyRewardsFrame.CloseButton:SetSize(25, 25)
    WeeklyRewardsFrame.SelectRewardButton:GwSkinButton(false, true)
    if WeeklyRewardsFrame.SelectRewardButton.Background then
        WeeklyRewardsFrame.SelectRewardButton.Background:SetAlpha(0) -- blizzards decorative plate behind the button
    end

    if WeeklyRewardsFrame.PreviousRewardNotification then
        WeeklyRewardsFrame.PreviousRewardNotification:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    end

    SkinActivityType(WeeklyRewardsFrame.RaidFrame)
    SkinActivityType(WeeklyRewardsFrame.MythicFrame)
    SkinActivityType(WeeklyRewardsFrame.PVPFrame)
    SkinActivityType(WeeklyRewardsFrame.WorldFrame)

    -- Activities holds the concession rows (no Threshold) first, then the reward slots
    for _, activity in pairs(WeeklyRewardsFrame.Activities) do
        if activity.Threshold then
            SkinActivity(activity)
        else
            SkinConcession(activity)
        end
    end

    local concessions = WeeklyRewardsFrame.ConcessionsFrame
    if concessions.HeaderText then
        concessions.HeaderText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        concessions.HeaderText:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end
    if concessions.Rewards then
        if concessions.Rewards.Text then
            ReplaceIconString(concessions.Rewards.Text)
            hooksecurefunc(concessions.Rewards.Text, "SetText", ReplaceIconString)
        end
    end

    if WeeklyRewardExpirationWarningDialog then
        WeeklyRewardExpirationWarningDialog:SetPoint("TOP", WeeklyRewardsFrame, "BOTTOM", 0, -1)
        WeeklyRewardExpirationWarningDialog.NineSlice:HookScript("OnShow", HandleWarning)
    end

    hooksecurefunc(WeeklyRewardsFrame, "SelectReward", SkinConfirmDialog)
    hooksecurefunc(WeeklyRewardsFrame, "UpdateOverlay", SkinVaultOverlay)
end

function GW.LoadWeeklyRewardsSkin()
    GW.RegisterLoadHook(ApplyWeeklyRewardsSkin, "Blizzard_WeeklyRewards", WeeklyRewardsFrame)
end
