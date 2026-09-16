---@class GW2
local GW = select(2, ...)
local L = GW.L

-- Alert toasts: the skin of blizzards alert systems (achievements, loot, dungeons, garrisons ...), our own
-- alert system for level ups, mail, repairs, calendar invites, rares and call to arms, and the previews of
-- both for the notification settings.

local ICON_SIZE = 45
local BORDER_IDLE = {0.3, 0.3, 0.3}
local FLARE_TEXTURE = "Interface/AddOns/GW2_UI/textures/hud/level-up-flare.png"

-- blizzards loot border atlases name the quality of the item shown
local LOOT_BORDER_QUALITY = {
    ["loottoast-itemborder-white"] = Enum.ItemQuality.Common,
    ["loottoast-itemborder-green"] = Enum.ItemQuality.Uncommon,
    ["loottoast-itemborder-blue"] = Enum.ItemQuality.Rare,
    ["loottoast-itemborder-purple"] = Enum.ItemQuality.Epic,
    ["loottoast-itemborder-orange"] = Enum.ItemQuality.Legendary,
    ["loottoast-itemborder-heirloom"] = Enum.ItemQuality.Heirloom,
    ["loottoast-itemborder-artifact"] = Enum.ItemQuality.Artifact,
}

-- how far the toast background reaches beyond the blizzard frame: left, top, right, bottom
local BACKDROP_OFFSETS = {
    achievement = {-10, 0, 5, 0}, -- around the Background texture
    criteria = {-25, 15, 27, -10},
    dungeon = {-25, 15, 27, -10},
    worldQuest = {-10, 0, 0, 0},
    guildChallenge = {-25, 5, 20, 0},
    invasion = {-15, 0, 0, 0},
    scenario = {-15, 0, 0, 0},
    legendary = {25, -15, 5, 20},
    loot = {-25, 15, 227, -15}, -- around the icon holder, the text runs to the right of it
    delivered = {-15, 5, 10, 10},
    digsite = {-15, 0, 5, 0},
    recipe = {-15, 5, 0, 10},
    garrison = {-5, 0, 0, 0},
    follower = {-5, 0, 0, 10},
}

local constBackdropAlertFrame = {
    bgFile = "Interface/AddOns/GW2_UI/textures/hud/toast-bg.png",
    edgeFile = "",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.BackdropTemplates.AlertFrame = constBackdropAlertFrame

local constBackdropLevelUpAlertFrame = {
    bgFile = "Interface/AddOns/GW2_UI/textures/hud/toast-levelup.png",
    edgeFile = "",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.BackdropTemplates.LevelUpAlertFrame = constBackdropLevelUpAlertFrame

---------- shared pieces ----------
local function forceAlpha(self, alpha, forced)
    if alpha ~= 1 and forced ~= true then
        self:SetAlpha(1, true)
    end
end
GW.ForceAlpha = forceAlpha

local function KeepVisible(frame)
    frame:SetAlpha(1)
    if frame.glow then
        frame.glow.suppressGlow = true
    end
    if frame.gwAlphaHooked then return end
    frame.gwAlphaHooked = true
    hooksecurefunc(frame, "SetAlpha", forceAlpha)
end

local function StopFlare(frame)
    frame.flareIcon.animationGroup:Stop()
end

local function AddFlare(frame, flareFrame, offsetX, offsetY)
    if not flareFrame then return end
    if not frame.flareIcon then
        frame.flareIcon = flareFrame
        frame:HookScript("OnHide", StopFlare)
    end
    if flareFrame.animationGroup then return end

    flareFrame.animationGroup = flareFrame:CreateAnimationGroup()
    flareFrame.animationGroup:SetLooping("REPEAT")
    for _, degrees in ipairs({2000, -2000}) do
        local flare = flareFrame:CreateTexture(nil, "BACKGROUND")
        flare:SetTexture(FLARE_TEXTURE)
        flare:SetPoint("CENTER", offsetX or 0, offsetY or 0)
        flare:SetSize(120, 120)
        local rotation = flareFrame.animationGroup:CreateAnimation("Rotation")
        rotation:SetTarget(flare)
        rotation:SetDegrees(degrees)
        rotation:SetDuration(60)
        rotation:SetSmoothing("OUT")
        rotation:SetOrder(1)
    end
end

local FLASH_PEAK = 0.55
local function AddIntroGlow(frame)
    local flash = frame.backdrop:CreateTexture(nil, "OVERLAY")
    flash:SetTexture(constBackdropAlertFrame.bgFile)
    flash:SetBlendMode("ADD")
    flash:SetVertexColor(1, 1, 1)
    flash:SetAllPoints(frame.backdrop)
    flash:SetAlpha(0)

    local group = flash:CreateAnimationGroup()
    local fadeIn = group:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(FLASH_PEAK)
    fadeIn:SetDuration(0.15)
    fadeIn:SetOrder(1)
    local fadeOut = group:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(FLASH_PEAK)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.7)
    fadeOut:SetSmoothing("OUT")
    fadeOut:SetOrder(2)
    frame.gwGlow = group
end

local function AddToastBackdrop(frame, key, anchor)
    if frame.backdrop then return end
    local offsets = BACKDROP_OFFSETS[key]
    anchor = anchor or frame
    frame:GwCreateBackdrop(constBackdropAlertFrame)
    frame.backdrop:SetPoint("TOPLEFT", anchor, "TOPLEFT", offsets[1], offsets[2])
    frame.backdrop:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", offsets[3], offsets[4])
    AddIntroGlow(frame)
end

local function ColorBorder(backdrop, quality)
    local color = quality and GW.GetBagItemQualityColor(quality)
    if color then
        backdrop:SetBackdropBorderColor(color.r, color.g, color.b, 1)
    else
        backdrop:SetBackdropBorderColor(BORDER_IDLE[1], BORDER_IDLE[2], BORDER_IDLE[3], 1)
    end
end

local function FrameIcon(frame, icon, withoutBorder, flareX, flareY)
    -- atlases bring their own coordinates
    if not icon:GetAtlas() then
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end
    if icon.b then return icon.b end

    local holder = CreateFrame("Frame", nil, frame)
    holder:SetAllPoints(icon)
    icon:SetParent(holder)
    if not withoutBorder then
        GW.HandleIcon(icon, true, GW.BackdropTemplates.DefaultWithColorableBorder, true)
        ColorBorder(icon.backdrop)
    end
    icon.b = holder
    AddFlare(frame, holder, flareX, flareY)
    return holder
end

local function ColorIconBorder(icon, quality)
    ColorBorder(icon.backdrop, quality)
end

local function ColorIconBorderByAtlas(icon, border)
    ColorIconBorder(icon, border and LOOT_BORDER_QUALITY[border:GetAtlas()])
end

local function Kill(...)
    for i = 1, select("#", ...) do
        local object = select(i, ...)
        if object then
            object:GwKill()
        end
    end
end

local function KillUnkeyedTextures(frame)
    local keyed = {}
    for _, value in pairs(frame) do
        if type(value) == "table" then
            keyed[value] = true
        end
    end
    for _, region in next, {frame:GetRegions()} do
        if region:IsObjectType("Texture") and not region:IsObjectType("MaskTexture") and not keyed[region] then
            region:GwKill()
        end
    end
end

local function KillRegionsWithAtlas(frame, atlases)
    for _, region in next, {frame:GetRegions()} do
        if region:IsObjectType("Texture") and atlases[region:GetAtlas()] then
            region:GwKill()
        end
    end
end

local function SetTitle(title)
    title:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    title:SetTextColor(1, 1, 1)
end

local function SetName(name, quality)
    name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    if quality == false then return end
    local color = quality and GW.GetBagItemQualityColor(quality)
    if color then
        name:SetTextColor(color.r, color.g, color.b)
    else
        name:SetTextColor(1, 1, 1)
    end
end

local function SetTexts(title, name, quality)
    if title then SetTitle(title) end
    if name then SetName(name, quality) end
end

local function SetUnkeyedTitles(frame, ...)
    local keep = {...}
    for _, region in next, {frame:GetRegions()} do
        if region:IsObjectType("FontString") and not tContains(keep, region) then
            SetTitle(region)
        end
    end
end

local function SkinRewardFrames(frame)
    for _, reward in ipairs(frame.RewardFrames or {}) do
        if not reward.gwSkinned then
            reward.gwSkinned = true
            if reward.CircleMask then
                reward.texture:RemoveMaskTexture(reward.CircleMask)
            end
            for _, region in next, {reward:GetRegions()} do
                if region:IsObjectType("Texture") and not region:IsObjectType("MaskTexture") and region ~= reward.texture then
                    region:GwKill()
                end
            end
            reward.texture:SetSize(24, 24)
            GW.HandleIcon(reward.texture, true, GW.BackdropTemplates.DefaultWithColorableBorder, true)
            ColorBorder(reward.texture.backdrop)
        end
    end
end

local function GetLinkQuality(itemLink)
    return itemLink and select(3, C_Item.GetItemInfo(itemLink))
end

---------- achievements ----------
local function skinAchievementAlert(frame)
    KeepVisible(frame)
    AddToastBackdrop(frame, "achievement", frame.Background)
    frame.Background:SetTexture()
    Kill(frame.OldAchievement, frame.glow, frame.shine, frame.GuildBanner, frame.GuildBorder, frame.Icon.Overlay)
    SetTexts(frame.Unlocked, frame.Name)

    frame.Icon.Texture:SetSize(ICON_SIZE, ICON_SIZE)
    frame.Icon.Texture:ClearAllPoints()
    frame.Icon.Texture:SetPoint("LEFT", frame, 7, 0)
    FrameIcon(frame, frame.Icon.Texture)
end

local function skinCriteriaAlert(frame)
    KeepVisible(frame)
    AddToastBackdrop(frame, "criteria")
    Kill(frame.Background, frame.glow, frame.shine, frame.Icon.Bling, frame.Icon.Overlay)
    SetTexts(frame.Unlocked, frame.Name)

    frame.Icon.Texture:SetSize(ICON_SIZE, ICON_SIZE)
    FrameIcon(frame, frame.Icon.Texture)
end

---------- encounters ----------
local function skinWorldQuestCompleteAlert(frame)
    KeepVisible(frame)
    if not frame.gwSkinned then
        frame.gwSkinned = true
        AddToastBackdrop(frame, "worldQuest")
        Kill(frame.shine, frame.ToastBackground)
        KillUnkeyedTextures(frame)
        frame.QuestTexture:SetDrawLayer("ARTWORK")
    end
    SetTexts(frame.ToastText, frame.QuestName)
    FrameIcon(frame, frame.QuestTexture)
    SkinRewardFrames(frame)
end

local function skinDungeonCompletionAlert(frame)
    KeepVisible(frame)
    AddToastBackdrop(frame, "dungeon")
    Kill(frame.shine, frame.glowFrame, frame.glowFrame and frame.glowFrame.glow, frame.raidArt, frame.dungeonArt,
        frame.dungeonArt1, frame.dungeonArt2, frame.dungeonArt3, frame.dungeonArt4, frame.heroicIcon)
    SetTexts(frame.completionText, frame.instanceName)

    frame.dungeonTexture:SetDrawLayer("OVERLAY")
    frame.dungeonTexture:ClearAllPoints()
    frame.dungeonTexture:SetPoint("LEFT", frame, 7, 0)
    FrameIcon(frame, frame.dungeonTexture)
    SkinRewardFrames(frame)
end

local function skinGuildChallengeAlert(frame)
    KeepVisible(frame)
    AddToastBackdrop(frame, "guildChallenge")
    KillUnkeyedTextures(frame)
    Kill(frame.glow, frame.shine, frame.EmblemBorder)
    SetTexts(frame.Type, frame.Count)
    SetUnkeyedTitles(frame, frame.Type, frame.Count)

    frame.EmblemIcon:ClearAllPoints()
    frame.EmblemIcon:SetPoint("LEFT", frame.backdrop, 25, 0)
    frame.EmblemBackground:ClearAllPoints()
    frame.EmblemBackground:SetPoint("LEFT", frame.backdrop, 25, 0)
    if not frame.EmblemIcon.b then
        local holder = CreateFrame("Frame", nil, frame)
        holder:SetAllPoints(frame.EmblemIcon)
        frame.EmblemBackground:SetParent(holder)
        frame.EmblemBackground:SetDrawLayer("BORDER")
        frame.EmblemIcon:SetParent(holder)
        frame.EmblemIcon:SetDrawLayer("ARTWORK")
        frame.EmblemIcon:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true, 3, 3)
        ColorBorder(frame.EmblemIcon.backdrop)
        frame.EmblemIcon.b = holder
        AddFlare(frame, holder)
    end
    SetLargeGuildTabardTextures("player", frame.EmblemIcon)
end

local function skinInvasionAlert(frame)
    KeepVisible(frame)
    if frame.gwSkinned then return end
    frame.gwSkinned = true

    AddToastBackdrop(frame, "invasion")
    local art, icon = frame:GetRegions()
    if art:GetAtlas() == "legioninvasion-Toast-Frame" then
        art:GwKill()
    end
    if icon and icon:IsObjectType("Texture") and icon:GetTexture() == 236293 then
        icon:SetDrawLayer("OVERLAY")
        FrameIcon(frame, icon)
    end
    SetTexts(nil, frame.ZoneName)
    SetUnkeyedTitles(frame, frame.ZoneName)
    SkinRewardFrames(frame)
end

local function skinScenarioAlert(frame)
    KeepVisible(frame)
    AddToastBackdrop(frame, "scenario")
    KillRegionsWithAtlas(frame, {["Toast-IconBG"] = true, ["Toast-Frame"] = true})
    Kill(frame.shine, frame.glowFrame, frame.glowFrame.glow)
    SetTexts(nil, frame.dungeonName)
    SetUnkeyedTitles(frame, frame.dungeonName)

    frame.dungeonTexture:SetDrawLayer("OVERLAY")
    frame.dungeonTexture:ClearAllPoints()
    frame.dungeonTexture:SetPoint("LEFT", frame.backdrop, 30, 0)
    FrameIcon(frame, frame.dungeonTexture)
    SkinRewardFrames(frame)
end

---------- loot ----------
local function skinLegendaryItemAlert(frame, itemLink)
    if not frame.gwSkinned then
        frame.gwSkinned = true
        Kill(frame.Background, frame.Background2, frame.Background3, frame.Ring1, frame.Particles1, frame.Particles2,
            frame.Particles3, frame.Starglow, frame.glow, frame.shine)
        frame.Icon:SetDrawLayer("ARTWORK")
        AddToastBackdrop(frame, "legendary")
        SetUnkeyedTitles(frame, frame.ItemName)
    end
    local quality = GetLinkQuality(itemLink)
    SetName(frame.ItemName, quality)
    FrameIcon(frame, frame.Icon)
    ColorIconBorder(frame.Icon, quality)
end

local function AddLootBackdrop(frame, holder)
    AddToastBackdrop(frame, "loot", holder)
end
local function skinLootWonAlert(frame)
    KeepVisible(frame)
    Kill(frame.Background, frame.glow, frame.shine, frame.BGAtlas, frame.PvPBackground, frame.RatedPvPBackground)

    local lootItem = frame.lootItem or frame
    lootItem.IconBorder:GwKill()
    if lootItem.SpecRing then
        lootItem.SpecRing:SetTexture("")
    end
    lootItem.Icon:SetDrawLayer("BORDER")
    AddLootBackdrop(frame, FrameIcon(frame, lootItem.Icon))
    ColorIconBorderByAtlas(lootItem.Icon, lootItem.IconBorder)
    SetTexts(frame.Label, frame.ItemName, false)
end

local function skinLootUpgradeAlert(frame, itemLink)
    KeepVisible(frame)
    Kill(frame.Background, frame.BorderGlow, frame.Sheen, frame.BaseQualityBorder, frame.UpgradeQualityBorder)
    frame.Icon:SetDrawLayer("BORDER", 5)
    AddLootBackdrop(frame, FrameIcon(frame, frame.Icon))
    ColorIconBorder(frame.Icon, GetLinkQuality(itemLink))
    SetTitle(frame.TitleText)
    for _, key in ipairs({"BaseQualityItemName", "UpgradeQualityItemName", "WhiteText", "WhiteText2"}) do
        SetName(frame[key], false)
    end
end

local function skinMoneyWonAlert(frame)
    KeepVisible(frame)
    Kill(frame.Background, frame.IconBorder)
    AddLootBackdrop(frame, FrameIcon(frame, frame.Icon))
    SetTitle(frame.Label)
end

local function skinDeliveredAlert(frame, background)
    KeepVisible(frame)
    AddToastBackdrop(frame, "delivered")
    Kill(background, frame.glow, frame.shine)
    SetTexts(frame.Title, frame.Description)
    frame.Icon:ClearAllPoints()
    frame.Icon:SetPoint("LEFT", frame.backdrop, 25, 0)
    FrameIcon(frame, frame.Icon)
end

local function skinEntitlementDeliveredAlert(frame)
    skinDeliveredAlert(frame, frame.Background)
end

local function skinRafRewardDeliveredAlert(frame)
    skinDeliveredAlert(frame, frame.StandardBackground)
end

---------- professions ----------
local function skinDigsiteCompleteAlert(frame)
    KeepVisible(frame)
    AddToastBackdrop(frame, "digsite")
    Kill(frame.glow, frame.shine, (frame:GetRegions()))
    SetTexts(frame.Title, frame.DigsiteType)

    frame.DigsiteTypeTexture:SetDrawLayer("ARTWORK", 7)
    frame.DigsiteTypeTexture:ClearAllPoints()
    frame.DigsiteTypeTexture:SetPoint("LEFT", frame.backdrop, 25, -18)
    FrameIcon(frame, frame.DigsiteTypeTexture, true, -20, 16)
end

local function skinNewRecipeLearnedAlert(frame)
    KeepVisible(frame)
    AddToastBackdrop(frame, "recipe")
    Kill(frame.glow, frame.shine, (frame:GetRegions()))
    SetTexts(frame.Title, frame.Name)

    frame.Icon:SetMask("")
    frame.Icon:SetDrawLayer("BORDER", 5)
    frame.Icon:SetSize(ICON_SIZE, ICON_SIZE)
    frame.Icon:ClearAllPoints()
    frame.Icon:SetPoint("LEFT", frame.backdrop, 30, 0)
    FrameIcon(frame, frame.Icon)
end

---------- honor, pets, mounts, toys, cosmetics ----------
local function skinHonorAwardedAlert(frame)
    KeepVisible(frame)
    Kill(frame.Background, frame.IconBorder)
    AddLootBackdrop(frame, FrameIcon(frame, frame.Icon))
    SetTitle(frame.Label)
end

local function skinNewItemAlert(frame)
    KeepVisible(frame)
    Kill(frame.Background, frame.IconBorder, frame.glow, frame.shine)
    frame.Icon:SetMask("")
    frame.Icon:SetDrawLayer("BORDER", 5)
    AddLootBackdrop(frame, FrameIcon(frame, frame.Icon))
    ColorIconBorderByAtlas(frame.Icon, frame.IconBorder)
    SetTexts(frame.Label, frame.Name, false)
end

---------- garrisons ----------
local function SkinMissionType(frame)
    frame.MissionType:SetSize(ICON_SIZE, ICON_SIZE)
    frame.MissionType:SetDrawLayer("ARTWORK")
    frame.MissionType:ClearAllPoints()
    frame.MissionType:SetPoint("LEFT", frame.backdrop, 30, 0)
    FrameIcon(frame, frame.MissionType)
end

local function skinGarrisonFollowerAlert(frame, _, _, _, quality)
    KeepVisible(frame)
    if not frame.gwSkinned then
        frame.gwSkinned = true
        Kill(frame.glow, frame.shine)
        frame.FollowerBG:SetAlpha(0)
        frame.DieIcon:SetAlpha(0)
        KillRegionsWithAtlas(frame, {["Garr_MissionToast"] = true})
        AddToastBackdrop(frame, "follower")

        local portrait = frame.PortraitFrame
        portrait.PortraitRing:Hide()
        portrait.PortraitRingQuality:SetTexture()
        portrait.LevelBorder:SetAlpha(0)
        portrait.Level:ClearAllPoints()
        portrait.Level:SetPoint("TOP", portrait.Portrait, "BOTTOM", 0, -2)

        portrait.Portrait:SetTexCoord(0.146, 0.854, 0.146, 0.854)

        local square = CreateFrame("Frame", nil, portrait, "BackdropTemplate")
        square:SetFrameLevel(portrait:GetFrameLevel() + 1)
        square:SetPoint("TOPLEFT", portrait.Portrait, "TOPLEFT", -1, 1)
        square:SetPoint("BOTTOMRIGHT", portrait.Portrait, "BOTTOMRIGHT", 1, -1)
        square:SetBackdrop(GW.BackdropTemplates.ColorableBorderOnly)
        portrait.squareBG = square
        if portrait.PortraitRingCover then
            portrait.PortraitRingCover:SetColorTexture(0, 0, 0)
            portrait.PortraitRingCover:SetAllPoints(square)
        end
        local flareHolder = CreateFrame("Frame", nil, frame)
        flareHolder:SetFrameLevel(math.max(portrait:GetFrameLevel() - 1, 0))
        flareHolder:SetAllPoints(portrait.Portrait)
        AddFlare(frame, flareHolder)
    end
    ColorBorder(frame.PortraitFrame.squareBG, quality)
    SetTexts(frame.Title, frame.Name, quality)
end

local function skinGarrisonShipFollowerAlert(frame, _, _, _, _, _, quality)
    KeepVisible(frame)
    if not frame.gwSkinned then
        frame.gwSkinned = true
        Kill(frame.glow, frame.shine, frame.Background)
        frame.FollowerBG:SetAlpha(0)
        frame.DieIcon:SetAlpha(0)
        AddToastBackdrop(frame, "garrison")
        frame.Class:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -2)
    end
    SetTexts(frame.Title, frame.Name, quality)
end

local function skinGarrisonTalentAlert(frame)
    KeepVisible(frame)
    if not frame.gwSkinned then
        frame.gwSkinned = true
        Kill(frame.glow, frame.shine, (frame:GetRegions()))
        AddToastBackdrop(frame, "garrison")
    end
    SetTexts(frame.Title, frame.Name)
    FrameIcon(frame, frame.Icon)
end

local function skinGarrisonBuildingAlert(frame)
    KeepVisible(frame)
    if not frame.gwSkinned then
        frame.gwSkinned = true
        Kill(frame.glow, frame.shine, (frame:GetRegions()))
        AddToastBackdrop(frame, "garrison")
    end
    SetTexts(frame.Title, frame.Name)
    FrameIcon(frame, frame.Icon)
end

local function skinGarrisonMissionAlert(frame)
    KeepVisible(frame)
    if not frame.gwSkinned then
        frame.gwSkinned = true
        Kill(frame.glow, frame.shine, frame.IconBG, frame.Background, frame.EncounterIcon.EliteOverlay, frame.EncounterIcon.RareOverlay)
        AddToastBackdrop(frame, "garrison")
    end
    SetTexts(frame.Title, frame.Name)
    SkinMissionType(frame)
end

local function skinGarrisonShipMissionAlert(frame)
    KeepVisible(frame)
    if not frame.gwSkinned then
        frame.gwSkinned = true
        Kill(frame.glow, frame.shine, frame.Background)
        AddToastBackdrop(frame, "garrison")
    end
    SetTexts(frame.Title, frame.Name)
    SkinMissionType(frame)
end

local function skinGarrisonRandomMissionAlert(frame)
    KeepVisible(frame)
    if not frame.gwSkinned then
        frame.gwSkinned = true
        Kill(frame.glow, frame.shine, frame.Background, frame.Blank, frame.IconBG)
        AddToastBackdrop(frame, "garrison")
    end
    SetTexts(frame.Title)
    SkinMissionType(frame)
end

---------- our own alert system ----------
local function IgnoreVignette(vignetteID, name)
    GW.settings.ALERTFRAME_NOTIFICATION_RARE_IGNORED[vignetteID] = name
    GW.Notice(format(L["%s is now ignored, the list is in the notification settings."], name))
    local widget = GW.FindSettingsWidgetByOption("ALERTFRAME_NOTIFICATION_RARE_IGNORED")
    if widget and widget.RefreshSpellList then
        widget:RefreshSpellList()
    end
end

local function GW2_UIAlertFrame_OnClick(self, button)
    if self.delay == -1 then
        self.delay = 0
    end
    if button == "RightButton" and IsShiftKeyDown() and self.vignetteID then
        IgnoreVignette(self.vignetteID, self.vignetteName)
    end
    if self.onClick then
        if AlertFrame_OnClick(self, button) then return end -- right click hides the frame
        self.onClick(self, button)
    elseif self.onClick == false then
        AlertFrame_OnClick(self, button)
    end
end

local function GW2_UIAlertFrame_OnEnter(self)
    if not self.vignetteID then return end
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(self.vignetteName, 1, 1, 1)
    GameTooltip:AddLine(format("|cFF888888ID %d|r", self.vignetteID))
    GameTooltip:AddLine(L["Shift + right click: ignore this rare"], 1, 0.82, 0)
    GameTooltip:Show()
end

local function GW2_UIAlertFrame_OnLeave(self)
    GameTooltip:Hide()
    if self.delay ~= -1 then
        AlertFrame_ResumeOutAnimation(self)
    end
end

local function GW2_UIAlertFrame_OnIconEnter(self)
    local spellID = self:GetParent().spellID
    if not spellID then return end
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:ClearLines()
    GameTooltip:SetSpellByID(spellID)
    GameTooltip:Show()
end

local function GW2_UIAlertFrame_SetUp(frame, name, delay, toptext, onClick, icon, levelup, spellID, targetName, vignetteID)
    AchievementAlertFrame_SetUp(frame, 2416, true)
    frame.Name:SetFormattedText(name)
    frame.Unlocked:SetFormattedText(toptext or "")
    SetTexts(frame.Unlocked, frame.Name)
    frame.onClick = onClick
    frame.delay = delay
    frame.spellID = spellID
    frame.levelup = levelup
    frame.vignetteID = vignetteID
    frame.vignetteName = targetName

    if not frame.gwSkinned then
        frame.gwSkinned = true
        frame:HookScript("OnClick", GW2_UIAlertFrame_OnClick)
        frame:HookScript("OnEnter", GW2_UIAlertFrame_OnEnter)
        frame:SetScript("OnLeave", GW2_UIAlertFrame_OnLeave)
        frame:RegisterForClicks("AnyUp", "AnyDown")
        frame.Icon:SetScript("OnEnter", GW2_UIAlertFrame_OnIconEnter)
        frame.Icon:SetScript("OnLeave", GameTooltip_Hide)
        AddToastBackdrop(frame, "achievement", frame.Background)
    end
    KeepVisible(frame)
    frame.backdrop:SetBackdrop(levelup and constBackdropLevelUpAlertFrame or constBackdropAlertFrame)

    if not InCombatLockdown() and targetName then
        frame:SetAttribute("type", "macro")
        frame:SetAttribute("macrotext", "/target " .. targetName)
    end

    frame.Background:SetTexture()
    Kill(frame.OldAchievement, frame.glow, frame.shine, frame.GuildBanner, frame.GuildBorder, frame.Icon.Overlay)

    frame.Icon.Texture:ClearAllPoints()
    frame.Icon.Texture:SetPoint("LEFT", frame, 7, 0)
    if icon and C_Texture.GetAtlasInfo(icon) then
        frame.Icon.Texture:SetAtlas(icon)
    else
        frame.Icon.Texture:SetTexture(icon)
    end
    FrameIcon(frame, frame.Icon.Texture, true)
end

---------- our alerts: what triggers them ----------
local toastQueue = {} -- collects new spells so a spec change does not toast every spell of the new spec
local hasMail = false
local bagsFull = false
local hasVaultRewards = false
local showRepair = true
local numInvites = 0
local callToArmsTime = 0
local guildInviteCache = {}
local DURABILITY_SLOTS = {
    {1, INVTYPE_HEAD}, {3, INVTYPE_SHOULDER}, {5, INVTYPE_ROBE}, {6, INVTYPE_WAIST}, {9, INVTYPE_WRIST},
    {10, INVTYPE_HAND}, {7, INVTYPE_LEGS}, {8, INVTYPE_FEET}, {16, INVTYPE_WEAPONMAINHAND},
    {17, INVTYPE_WEAPONOFFHAND}, {18, INVTYPE_RANGED},
}
local REPAIR_THRESHOLD = 20

-- skyriding basics are learned silently on every new character, no toast for them
local ignoreDragonRidingSpells = {
    [372608] = true,
    [372610] = true,
    [374990] = true,
    [361584] = true,
}

-- fallback for paragon reward quests of factions the reputation API does not list at that moment (collapsed
-- headers); [questID] = factionID
local PARAGON_QUEST_ID = {
    -- Legion
    [48976] = 2170, -- Argussian Reach
    [46777] = 2045, -- Armies of Legionfall
    [48977] = 2165, -- Army of the Light
    [46745] = 1900, -- Court of Farondis
    [46747] = 1883, -- Dreamweavers
    [46743] = 1828, -- Highmountain Tribes
    [46748] = 1859, -- The Nightfallen
    [46749] = 1894, -- The Wardens
    [46746] = 1948, -- Valarjar
    -- Battle for Azeroth
    [54453] = 2164, -- Champions of Azeroth
    [58096] = 2415, -- Rajani
    [55348] = 2391, -- Rustbolt Resistance
    [54451] = 2163, -- Tortollan Seekers
    [58097] = 2417, -- Uldum Accord
    [54460] = 2156, -- Talanji's Expedition
    [54455] = 2157, -- The Honorbound
    [53982] = 2373, -- The Unshackled
    [54461] = 2158, -- Voldunai
    [54462] = 2103, -- Zandalari Empire
    [54456] = 2161, -- Order of Embers
    [54458] = 2160, -- Proudmoore Admiralty
    [54457] = 2162, -- Storm's Wake
    [54454] = 2159, -- The 7th Legion
    [55976] = 2400, -- Waveblade Ankoan
    -- Shadowlands
    [61100] = 2413, -- Court of Harvesters
    [61097] = 2407, -- The Ascended
    [61095] = 2410, -- The Undying Army
    [61098] = 2465, -- The Wild Hunt
    [64012] = 2470, -- The Death Advance
    [64266] = 2472, -- The Archivist's Codex
    [64267] = 2432, -- Ve'nari
    [64867] = 2478, -- The Enlightened
    -- Dragonflight
    [66156] = 2507, -- Dragonscale Expedition
    [76425] = 2574, -- Dream Wardens
    [66511] = 2511, -- Iskaara Tuskarr
    [75290] = 2564, -- Loamm Niffen
    [65606] = 2503, -- Maruuk Centaur
    [71023] = 2510, -- Valdrakken Accord
    -- The War Within
    [79219] = 2590, -- Council of Dornogal
    [79218] = 2570, -- Hallowfall Arathi
    [79220] = 2594, -- The Assembly of the Deep
    [79196] = 2600, -- The Severed Threads
    [83739] = 2605, -- The General
    [83740] = 2607, -- The Vizier
    [83738] = 2601, -- The Weaver
    [85805] = 2653, -- Cartels of Undermine
    [85471] = 2685, -- Gallagio Loyalty Rewards Club
    [85806] = 2673, -- Bilgewater Cartel
    [85807] = 2675, -- Blackwater Cartel
    [85808] = 2669, -- Darkfuse Solutions
    [85809] = 2677, -- Steamwheedle Cartel
    [85810] = 2671, -- Venture Company
}

GW.VignetteNames = {
    [4024] = "Soul Cage",
    [4578] = "Gateway to Hero's Rest",
    [4583] = "Gateway to Hero's Rest",
    [4553] = "Recoverable Corpse",
    [4581] = "Grappling Growth",
    [4582] = "Ripe Purian",
    [4602] = "Aimless Soul",
    [4617] = "Imprisoned Soul",
    [5020] = "Console",
    [5485] = "Tuskarr Tacklebox",
}

local VignetteExclusionMapIDs = {
    [579] = true, -- Lunarfall: Alliance garrison
    [585] = true, -- Frostwall: Horde garrison
    [646] = true, -- Scenario: The Broken Shore
    [1911] = true, -- Thorgast
    [1912] = true, -- Thorgast
}

local function PlayAlertSound(setting)
    PlaySoundFile(GW.Libs.LSM:Fetch("sound", GW.settings[setting]), "Master")
end

local function isUsefulAtlas(info)
    local atlas = info.atlasName
    return atlas and (strfind(atlas, "[Vv]ignette") or atlas == "nazjatar-nagaevent")
end

local function GetParagonFaction(questID)
    local isParagon = C_Reputation.IsFactionParagonForCurrentPlayer or C_Reputation.IsFactionParagon
    if isParagon and C_Reputation.GetNumFactions then
        for i = 1, C_Reputation.GetNumFactions() do
            local data = C_Reputation.GetFactionDataByIndex(i)
            if data and not data.isHeader and isParagon(data.factionID) then
                local _, _, rewardQuestID = C_Reputation.GetFactionParagonInfo(data.factionID)
                if rewardQuestID == questID then
                    return data
                end
            end
        end
    end
    local factionID = PARAGON_QUEST_ID[questID]
    return factionID and C_Reputation.GetFactionDataByID(factionID)
end

local function GetRoleShortage()
    local forTank, forHealer, forDamage = false, false, false
    for i = 1, GetNumRandomDungeons() do
        local dungeonID = GetLFGRandomDungeonInfo(i)
        for shortageIndex = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
            local eligible, tank, healer, damage = GetLFGRoleShortageRewards(dungeonID, shortageIndex)
            if eligible then
                forTank, forHealer, forDamage = forTank or tank, forHealer or healer, forDamage or damage
            end
        end
    end
    return forTank, forHealer, forDamage
end

local function GetLowestDurability()
    local lowest, lowestSlot = 1, nil
    for _, slot in ipairs(DURABILITY_SLOTS) do
        if GetInventoryItemLink("player", slot[1]) then
            local current, max = GetInventoryItemDurability(slot[1])
            if current and max and max > 0 and current / max < lowest then
                lowest, lowestSlot = current / max, slot[2]
            end
        end
    end
    return lowest, lowestSlot
end

local function GetGuildInvites()
    local numGuildInvites = 0
    local date = C_DateAndTime.GetCurrentCalendarTime()
    for index = 1, C_Calendar.GetNumGuildEvents() do
        local info = C_Calendar.GetGuildEventInfo(index)
        local monthOffset = info.month - date.month
        for i = 1, C_Calendar.GetNumDayEvents(monthOffset, info.monthDay) do
            local event = C_Calendar.GetDayEvent(monthOffset, info.monthDay, i)
            if event.inviteStatus == CALENDAR_INVITESTATUS_NOT_SIGNEDUP and not guildInviteCache[info.eventID] then
                numGuildInvites = numGuildInvites + 1
                guildInviteCache[info.eventID] = true
            end
        end
    end
    return numGuildInvites
end

local function toggleCalendar()
    if not CalendarFrame then C_AddOns.LoadAddOn("Blizzard_Calendar") end
    ShowUIPanel(CalendarFrame)
end

---------- the toasts themselves, used by the events and by the previews in the settings ----------
local ICONS = "Interface/AddOns/GW2_UI/textures/icons/"

local function ShowCalendarAlert(text)
    GW.AlertSystem:AddAlert(text, nil, CALENDAR_STATUS_INVITED, toggleCalendar, ICONS .. "clock.png", false)
end

local function ShowLevelUpAlert(level, talentPoints, numNewPvpTalentSlots)
    GW.AlertSystem:AddAlert(LEVEL_UP_YOU_REACHED .. " " .. LEVEL .. " " .. level, nil, PLAYER_LEVEL_UP, false, ICONS .. "icon-levelup.png", true)
    if talentPoints and talentPoints > 0 then
        GW.AlertSystem:AddAlert(LEVEL_UP_TALENT_MAIN, nil, LEVEL_UP_TALENT_SUB, false, ICONS .. "talent-icon.png", false)
    end
    if GW.Retail and C_SpecializationInfo.CanPlayerUsePVPTalentUI() and numNewPvpTalentSlots and numNewPvpTalentSlots > 0 then
        GW.AlertSystem:AddAlert(LEVEL_UP_PVP_TALENT_MAIN, nil, BONUS_TALENTS, false, ICONS .. "talent-icon.png", false)
    end
    PlayAlertSound("ALERTFRAME_NOTIFICATION_LEVEL_UP_SOUND")
end

local function ShowSpellAlert(name, icon, spellID)
    GW.AlertSystem:AddAlert(SPELL_BUCKET_ABILITIES_UNLOCKED, nil, name, false, icon, false, spellID)
end

local function ShowMailAlert()
    GW.AlertSystem:AddAlert(HAVE_MAIL, nil, MAIL_LABEL, false, ICONS .. "mail-window-icon.png", false)
    PlayAlertSound("ALERTFRAME_NOTIFICATION_NEW_MAIL_SOUND")
end

local function ShowRepairAlert(slotName, value)
    GW.AlertSystem:AddAlert(format(L["%s slot needs to repair, current durability is %d."], slotName, value), nil, MINIMAP_TRACKING_REPAIR, false, ICONS .. "repair.png", false)
    PlayAlertSound("ALERTFRAME_NOTIFICATION_REPAIR_SOUND")
end

local function ShowParagonAlert(factionName, questText)
    local text = GW.RGBToHex(0.22, 0.37, 0.98) .. factionName .. "|r"
    GW.AlertSystem:AddAlert(questText or "", nil, text, false, "Interface/Icons/Achievement_Quests_Completed_08", false)
    PlayAlertSound("ALERTFRAME_NOTIFICATION_PARAGON_SOUND")
end

local function ShowRareAlert(name, atlas, vignetteID)
    local nameColored = format("|cff00c0fa%s|r", name:utf8sub(1, 28))
    GW.AlertSystem:AddAlert(L["has appeared on the Minimap!"], nil, nameColored, false, atlas, false, nil, name, vignetteID)
end

local function ShowCallToArmsAlert(roles)
    GW.AlertSystem:AddAlert(format(LFG_CALL_TO_ARMS, roles), nil, BATTLEGROUND_HOLIDAY, false, ICONS .. "garrison-up.png", false)
    PlayAlertSound("ALERTFRAME_NOTIFICATION_CALL_TO_ARMS_SOUND")
end

local function ShowBagsFullAlert()
    GW.AlertSystem:AddAlert(ERR_INV_FULL, nil, INVTYPE_BAG, false, "Interface/Icons/INV_Misc_Bag_08", false)
    PlayAlertSound("ALERTFRAME_NOTIFICATION_BAGS_FULL_SOUND")
end

local function ShowVaultAlert()
    GW.AlertSystem:AddAlert(MYTHIC_PLUS_COLLECT_GREAT_VAULT, nil, RATED_PVP_WEEKLY_VAULT, WeeklyRewards_ShowUI, "greatVault-whole-normal", false)
    PlayAlertSound("ALERTFRAME_NOTIFICATION_GREAT_VAULT_SOUND")
end

-- group member spells worth a toast; classic clients only, retail hides the caster behind secret values
local function ShowGroupSpellAlert(spellID, text, setting)
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    GW.AlertSystem:AddAlert(text, nil, spellInfo.name, false, spellInfo.iconID, false)
    PlayAlertSound(setting)
end

local ROLE_COLORS = {TANK = "|cff00B2EE", HEALER = "|cff00EE00", DAMAGER = "|cffd62c35"}
local function ColorRole(role, wanted)
    return wanted and ROLE_COLORS[role] .. _G[role] .. "|r" or ""
end

-- the play buttons in the notification settings, keyed like the settings without their prefix
local function PlayerName()
    return UnitName("player")
end
GW.AlertPreviews = {
    LEVEL_UP = function() ShowLevelUpAlert(UnitLevel("player"), 1) end,
    NEW_SPELL = function()
        local spellInfo = C_Spell.GetSpellInfo(8690) -- Hearthstone
        ShowSpellAlert(spellInfo.name, spellInfo.iconID, 8690)
        PlayAlertSound("ALERTFRAME_NOTIFICATION_NEW_SPELL_SOUND")
    end,
    NEW_MAIL = ShowMailAlert,
    REPAIR = function() ShowRepairAlert(INVTYPE_HEAD, 15) end,
    PARAGON = function()
        local watched = C_Reputation and C_Reputation.GetWatchedFactionData and C_Reputation.GetWatchedFactionData()
        ShowParagonAlert(watched and watched.name or L["Paragon"], L["Paragon chest"])
    end,
    RARE = function()
        ShowRareAlert(PlayerName(), "VignetteKillElite")
        PlayAlertSound("ALERTFRAME_NOTIFICATION_RARE_SOUND")
    end,
    CALENDAR_INVITE = function()
        ShowCalendarAlert(L["You have %s pending calendar invite(s)."]:format(1))
        PlayAlertSound("ALERTFRAME_NOTIFICATION_CALENDAR_INVITE_SOUND")
    end,
    CALL_TO_ARMS = function() ShowCallToArmsAlert(ColorRole("TANK", true) .. " " .. ColorRole("HEALER", true) .. " " .. ColorRole("DAMAGER", true)) end,
    BAGS_FULL = ShowBagsFullAlert,
    GREAT_VAULT = ShowVaultAlert,
    MAGE_TABLE = function() ShowGroupSpellAlert(190336, format(L["%s created a table of Conjured Refreshments."], PlayerName()), "ALERTFRAME_NOTIFICATION_MAGE_TABLE_SOUND") end,
    RITUAL_OF_SUMMONING = function() ShowGroupSpellAlert(698, format(L["%s is performing a Ritual of Summoning."], PlayerName()), "ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING_SOUND") end,
    SPOULWELL = function() ShowGroupSpellAlert(29893, format(L["%s created a Soulwell."], PlayerName()), "ALERTFRAME_NOTIFICATION_SPOULWELL_SOUND") end,
    MAGE_PORTAL = function() ShowGroupSpellAlert(10059, format(L["%s placed a portal to %s."], PlayerName(), C_Spell.GetSpellInfo(10059).name:gsub("^.+:%s+", "")), "ALERTFRAME_NOTIFICATION_MAGE_PORTAL_SOUND") end,
}

for key, preview in pairs(GW.AlertPreviews) do
    GW.AlertPreviews[key] = function()
        if GW.AlertSystem then
            preview()
        end
    end
end

local function WithItem(itemID, callback)
    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function() callback(item:GetItemLink()) end)
end

local BLIZZARD_PREVIEWS = {
    {"achievement", ACHIEVEMENT_UNLOCKED, "AchievementAlertSystem", function() AchievementAlertSystem:AddAlert(6) end},
    {"criteria", ACHIEVEMENT_PROGRESSED, "CriteriaAlertSystem", function() CriteriaAlertSystem:AddAlert(6, (select(2, GetAchievementInfo(6)))) end},
    {"loot", LOOT, "LootAlertSystem", function() WithItem(50818, function(link) LootAlertSystem:AddAlert(link, 1, nil, nil, nil, false, false, nil, false, false) end) end},
    {"lootUpgrade", ITEM_UPGRADE, "LootUpgradeAlertSystem", function() WithItem(50818, function(link) LootUpgradeAlertSystem:AddAlert(link, 1, nil, Enum.ItemQuality.Rare) end) end},
    {"legendary", ITEM_QUALITY5_DESC, "LegendaryItemAlertSystem", function() WithItem(19019, function(link) LegendaryItemAlertSystem:AddAlert(link) end) end},
    {"money", MONEY, "MoneyWonAlertSystem", function() MoneyWonAlertSystem:AddAlert(1234567) end},
    {"honor", HONOR, "HonorAwardedAlertSystem", function() HonorAwardedAlertSystem:AddAlert(250) end},
    {"dungeon", DUNGEON_COMPLETED, "DungeonCompletionAlertSystem", function()
        DungeonCompletionAlertSystem:AddAlert({name = DUNGEONS, subtypeID = LFG_SUBTYPEID_HEROIC, iconTextureFile = "Interface/Icons/Achievement_Boss_Ragnaros", moneyAmount = 123456, experienceGained = 0, numRewards = 0, rewards = {}})
    end},
    {"scenario", SCENARIOS, "ScenarioAlertSystem", function()
        ScenarioAlertSystem:AddAlert({name = SCENARIOS, iconTextureFile = "Interface/Icons/Achievement_Boss_Ragnaros", moneyAmount = 123456, experienceGained = 0, numRewards = 0, rewards = {}})
    end},
    {"worldQuest", WORLD_QUEST_COMPLETE, "WorldQuestCompleteAlertSystem", function()
        WorldQuestCompleteAlertSystem:AddAlert({questID = 0, taskName = QUESTS_LABEL, icon = "Interface/Icons/INV_Misc_Map02", money = 123456, xp = 0})
    end},
    {"guildChallenge", GUILD, "GuildChallengeAlertSystem", function() GuildChallengeAlertSystem:AddAlert(1, 2, 7) end},
    {"digsite", PROFESSIONS_ARCHAEOLOGY, "DigsiteCompleteAlertSystem", function()
        local raceName, raceTexture = GetArchaeologyRaceInfo(1)
        if raceName then
            DigsiteCompleteAlertSystem:AddAlert(raceName, raceTexture)
        end
    end},
    {"pet", PETS, "NewPetAlertSystem", function()
        local petID, _, owned = C_PetJournal.GetPetInfoByIndex(1)
        if petID and owned then
            NewPetAlertSystem:AddAlert(petID)
        end
    end},
    {"mount", MOUNTS, "NewMountAlertSystem", function()
        local mountID = C_MountJournal.GetMountIDs()[1]
        if mountID then
            NewMountAlertSystem:AddAlert(mountID)
        end
    end},
    {"toy", TOY_BOX, "NewToyAlertSystem", function() WithItem(54452, function() NewToyAlertSystem:AddAlert(54452) end) end},
    {"entitlement", BLIZZARD_STORE, "EntitlementDeliveredAlertSystem", function()
        EntitlementDeliveredAlertSystem:AddAlert(Enum.WoWEntitlementType.Item, "Interface/Icons/INV_Misc_Gift_01", BLIZZARD_STORE, 0, false)
    end},
    {"follower", GARRISON_FOLLOWERS, "GarrisonFollowerAlertSystem", function()
        local info = C_Garrison.GetFollowerInfo(204)
        if info then
            GarrisonFollowerAlertSystem:AddAlert(204, info.name, info.level, info.quality, false, info)
        end
    end},
    {"mission", GARRISON_MISSIONS, "GarrisonMissionAlertSystem", function()
        GarrisonMissionAlertSystem:AddAlert({name = GARRISON_MISSIONS, typeAtlas = "GarrMission_MissionIcon-Combat", followerTypeID = Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower, missionID = 0})
    end},
}

GW.BlizzardAlertPreviews = {keys = {}, names = {}, show = {}}
for _, entry in ipairs(BLIZZARD_PREVIEWS) do
    if _G[entry[3]] then
        tinsert(GW.BlizzardAlertPreviews.keys, entry[1])
        tinsert(GW.BlizzardAlertPreviews.names, entry[2])
        GW.BlizzardAlertPreviews.show[entry[1]] = entry[4]
    end
end

---------- what triggers them ----------
local function alertEvents()
    if CalendarFrame and CalendarFrame:IsShown() then return false end
    local num = C_Calendar.GetNumPendingInvites()
    if num == numInvites then return false end
    numInvites = num
    if num > 0 then
        ShowCalendarAlert(L["You have %s pending calendar invite(s)."]:format(num))
        return true
    end
    return false
end

local function alertGuildEvents()
    if CalendarFrame and CalendarFrame:IsShown() then return false end
    local num = GetGuildInvites()
    if num > 0 then
        ShowCalendarAlert(L["You have %s pending guild event(s)."]:format(num))
        return true
    end
    return false
end

local function CLEUHandling(_, _, subEvent, _, _, srcName, _, _, _, _, _, _, spellID)
    if not (IsInRaid() or IsInGroup()) or not spellID or not srcName then return end
    local groupStatus = GW.IsGroupMember(srcName)
    if not groupStatus or groupStatus == 3 then return end

    if subEvent == "SPELL_CAST_SUCCESS" then
        if GW.settings.ALERTFRAME_NOTIFICATION_MAGE_TABLE and spellID == 190336 then -- Refreshment Table
            ShowGroupSpellAlert(spellID, format(L["%s created a table of Conjured Refreshments."], srcName), "ALERTFRAME_NOTIFICATION_MAGE_TABLE_SOUND")
        end
    elseif subEvent == "SPELL_CREATE" then
        if GW.settings.ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING and spellID == 698 then -- Ritual of Summoning
            ShowGroupSpellAlert(spellID, format(L["%s is performing a Ritual of Summoning."], srcName), "ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING_SOUND")
        elseif GW.settings.ALERTFRAME_NOTIFICATION_SPOULWELL and spellID == 29893 then -- Soul Well
            ShowGroupSpellAlert(spellID, format(L["%s created a Soulwell."], srcName), "ALERTFRAME_NOTIFICATION_SPOULWELL_SOUND")
        elseif GW.settings.ALERTFRAME_NOTIFICATION_MAGE_PORTAL and GW.MagePortals[spellID] then
            local destination = C_Spell.GetSpellInfo(spellID).name:gsub("^.+:%s+", "")
            ShowGroupSpellAlert(spellID, format(L["%s placed a portal to %s."], srcName, destination), "ALERTFRAME_NOTIFICATION_MAGE_PORTAL_SOUND")
        end
    end
end

local function OnLevelUp(level, talentPoints, numNewPvpTalentSlots)
    ShowLevelUpAlert(level, talentPoints, numNewPvpTalentSlots)
    for _, v in pairs(toastQueue) do
        if v.event == "LEARNED_SPELL_IN_SKILL_LINE" then
            v.event = ""
        end
    end
end

local function OnSpellLearned(spellID)
    if ignoreDragonRidingSpells[spellID] then return end
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    toastQueue[#toastQueue + 1] = {name = spellInfo.name, spellID = spellID, icon = spellInfo.iconID, event = "LEARNED_SPELL_IN_SKILL_LINE"}
    C_Timer.After(1.5, function()
        for _, v in pairs(toastQueue) do
            ShowSpellAlert(v.name, v.icon, v.spellID)
        end
        wipe(toastQueue)
        PlayAlertSound("ALERTFRAME_NOTIFICATION_NEW_SPELL_SOUND")
    end)
end

local function OnMailUpdate()
    if InCombatLockdown() then return end
    local newMail = HasNewMail()
    if hasMail == newMail then return end
    hasMail = newMail
    if hasMail then
        ShowMailAlert()
    end
end

local function OnDurabilityUpdate()
    local lowest, slotName = GetLowestDurability()
    local value = floor(lowest * 100)
    if not showRepair or not slotName or value >= REPAIR_THRESHOLD then return end
    showRepair = false
    C_Timer.After(30, function() showRepair = true end)
    ShowRepairAlert(slotName, value)
end

local function OnQuestAccepted(questID)
    local factionData = GetParagonFaction(questID)
    if not factionData then return end
    ShowParagonAlert(factionData.name, GetQuestLogCompletionText(C_QuestLog.GetLogIndexForQuestID(questID)))
end

local function PrintVignetteToChat(vignetteGUID, vignetteInfo, mapID)
    local position = mapID and C_VignetteInfo.GetVignettePosition(vignetteGUID, mapID)
    local place = ""
    if position then
        local x, y = position:GetXY()
        place = format(" |cffffff00|Hworldmap:%d:%d:%d|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a%s]|h|r", mapID, x * 10000, y * 10000, MAP_PIN_HYPERLINK)
    end
    GW.Notice(format("|cff00c0fa%s|r %s%s", vignetteInfo.name, L["has appeared on the Minimap!"], place))
end

local function OnVignetteUpdated(self, vignetteGUID, onMinimap)
    local mapID = GW.Libs.GW2Lib:GetPlayerLocationMapID()
    if not onMinimap or VignetteExclusionMapIDs[mapID] then return end
    if IsInGroup() or IsInRaid() or IsPartyLFG() or C_PartyInfo.IsPartyWalkIn() then return end

    local vignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
    if not vignetteInfo or not C_Texture.GetAtlasInfo(vignetteInfo.atlasName) then return end
    if not isUsefulAtlas(vignetteInfo) then return end
    local ignored = GW.settings.ALERTFRAME_NOTIFICATION_RARE_IGNORED
    if ignored[vignetteInfo.vignetteID] then
        if ignored[vignetteInfo.vignetteID] == true then
            ignored[vignetteInfo.vignetteID] = vignetteInfo.name
        end
        return
    end
    if vignetteGUID == self.lastMinimapRare.id then return end

    GW.Debug("Minimap vignette with id", vignetteInfo.vignetteID, "and name", vignetteInfo.name, "appeared on the minimap.")
    ShowRareAlert(vignetteInfo.name, vignetteInfo.atlasName, vignetteInfo.vignetteID)
    if GW.settings.ALERTFRAME_NOTIFICATION_RARE_CHAT then
        PrintVignetteToChat(vignetteGUID, vignetteInfo, mapID)
    end
    self.lastMinimapRare.id = vignetteGUID

    local now = GetTime()
    if now > self.lastMinimapRare.time + 20 then
        PlayAlertSound("ALERTFRAME_NOTIFICATION_RARE_SOUND")
        self.lastMinimapRare.time = now
    end
end

local function OnRandomDungeonInfo()
    if IsInGroup(LE_PARTY_CATEGORY_HOME) or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then return end
    local forTank, forHealer, forDamage = GetRoleShortage()
    local isTank, isHealer, isDamage = C_LFGList.GetAvailableRoles()
    local tank = ColorRole("TANK", isTank and forTank)
    local healer = ColorRole("HEALER", isHealer and forHealer)
    local damager = ColorRole("DAMAGER", isDamage and forDamage)
    if tank == "" and healer == "" and damager == "" then return end

    local now = GetTime()
    if now - callToArmsTime <= 20 then return end
    callToArmsTime = now
    ShowCallToArmsAlert(tank .. " " .. healer .. " " .. damager)
end

local function OnBagUpdate()
    local free = 0
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local freeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(bag)
        if bagFamily == 0 then
            free = free + freeSlots
        end
    end
    local full = free == 0
    if bagsFull == full then return end
    bagsFull = full
    if full then
        ShowBagsFullAlert()
    end
end

local function OnWeeklyRewardsUpdate()
    local available = C_WeeklyRewards.HasAvailableRewards()
    if hasVaultRewards == available then return end
    hasVaultRewards = available
    if available then
        ShowVaultAlert()
    end
end

local function AlertContainerFrameOnEvent(self, event, ...)
    local settings = GW.settings
    if event == "PLAYER_LEVEL_UP" and settings.ALERTFRAME_NOTIFICATION_LEVEL_UP then
        local level, _, _, talentPoints, numNewPvpTalentSlots = ...
        OnLevelUp(level, talentPoints, numNewPvpTalentSlots)
    elseif event == "LEARNED_SPELL_IN_SKILL_LINE" and settings.ALERTFRAME_NOTIFICATION_NEW_SPELL and not self.ignoreNewSpells then
        OnSpellLearned(...)
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" and settings.ALERTFRAME_NOTIFICATION_NEW_SPELL then
        C_Timer.After(0.5, function()
            for k, v in pairs(toastQueue) do
                if v.event == "LEARNED_SPELL_IN_SKILL_LINE" then
                    toastQueue[k] = nil
                end
            end
        end)
    elseif event == "BAG_UPDATE_DELAYED" and settings.ALERTFRAME_NOTIFICATION_BAGS_FULL then
        OnBagUpdate()
    elseif event == "WEEKLY_REWARDS_UPDATE" and settings.ALERTFRAME_NOTIFICATION_GREAT_VAULT then
        OnWeeklyRewardsUpdate()
    elseif event == "UPDATE_PENDING_MAIL" and settings.ALERTFRAME_NOTIFICATION_NEW_MAIL then
        OnMailUpdate()
    elseif event == "UPDATE_INVENTORY_DURABILITY" and settings.ALERTFRAME_NOTIFICATION_REPAIR then
        OnDurabilityUpdate()
    elseif event == "QUEST_ACCEPTED" and settings.ALERTFRAME_NOTIFICATION_PARAGON then
        OnQuestAccepted(...)
    elseif event == "VIGNETTE_MINIMAP_UPDATED" and settings.ALERTFRAME_NOTIFICATION_RARE then
        OnVignetteUpdated(self, ...)
    elseif event == "CALENDAR_UPDATE_PENDING_INVITES" and settings.ALERTFRAME_NOTIFICATION_CALENDAR_INVITE then
        if alertEvents() or alertGuildEvents() then
            PlayAlertSound("ALERTFRAME_NOTIFICATION_CALENDAR_INVITE_SOUND")
        end
    elseif event == "CALENDAR_UPDATE_GUILD_EVENTS" and settings.ALERTFRAME_NOTIFICATION_CALENDAR_INVITE then
        if alertGuildEvents() then
            PlayAlertSound("ALERTFRAME_NOTIFICATION_CALENDAR_INVITE_SOUND")
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(7, function() AlertContainerFrameOnEvent(self, "CALENDAR_UPDATE_PENDING_INVITES") end)
        -- the login fires LEARNED_SPELL_IN_SKILL_LINE for spells the character already knows
        self.ignoreNewSpells = true
        C_Timer.After(3, function() self.ignoreNewSpells = false end)
    elseif event == "LFG_UPDATE_RANDOM_INFO" and settings.ALERTFRAME_NOTIFICATION_CALL_TO_ARMS then
        OnRandomDungeonInfo()
    end
end

---------- load ----------
function GW.LoadAlertSystem()
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end

    if GW.settings.ALERTFRAME_SKIN_ENABLED then
        local systems = {
            {AchievementAlertSystem, skinAchievementAlert},
            {CriteriaAlertSystem, skinCriteriaAlert},
            {DungeonCompletionAlertSystem, skinDungeonCompletionAlert},
            {WorldQuestCompleteAlertSystem, skinWorldQuestCompleteAlert},
            {GuildChallengeAlertSystem, skinGuildChallengeAlert},
            {InvasionAlertSystem, skinInvasionAlert},
            {ScenarioAlertSystem, skinScenarioAlert},
            {LegendaryItemAlertSystem, skinLegendaryItemAlert},
            {LootAlertSystem, skinLootWonAlert},
            {LootUpgradeAlertSystem, skinLootUpgradeAlert},
            {MoneyWonAlertSystem, skinMoneyWonAlert},
            {DigsiteCompleteAlertSystem, skinDigsiteCompleteAlert},
            {NewRecipeLearnedAlertSystem, skinNewRecipeLearnedAlert},
            {HonorAwardedAlertSystem, skinHonorAwardedAlert},
            {NewPetAlertSystem, skinNewItemAlert},
            {NewMountAlertSystem, skinNewItemAlert},
            {NewToyAlertSystem, skinNewItemAlert},
            {GarrisonFollowerAlertSystem, skinGarrisonFollowerAlert},
            {GarrisonShipFollowerAlertSystem, skinGarrisonShipFollowerAlert},
            {GarrisonTalentAlertSystem, skinGarrisonTalentAlert},
            {GarrisonBuildingAlertSystem, skinGarrisonBuildingAlert},
            {GarrisonMissionAlertSystem, skinGarrisonMissionAlert},
            {GarrisonShipMissionAlertSystem, skinGarrisonShipMissionAlert},
            {GarrisonRandomMissionAlertSystem, skinGarrisonRandomMissionAlert},
        }
        if GW.Retail then
            tinsert(systems, {MonthlyActivityAlertSystem, skinCriteriaAlert})
            tinsert(systems, {EntitlementDeliveredAlertSystem, skinEntitlementDeliveredAlert})
            tinsert(systems, {RafRewardDeliveredAlertSystem, skinRafRewardDeliveredAlert})
            tinsert(systems, {NewCosmeticAlertFrameSystem, skinNewItemAlert})
           hooksecurefunc("LootWonAlertFrame_SetUp", function(frame, ...)
                if frame == BonusRollLootWonFrame then
                    skinLootWonAlert(frame, ...)
                end
            end)
            hooksecurefunc("MoneyWonAlertFrame_SetUp", function(frame)
                if frame == BonusRollMoneyWonFrame then
                    skinMoneyWonAlert(frame)
                end
            end)
        end
        for _, entry in ipairs(systems) do
            hooksecurefunc(entry[1], "setUpFunction", entry[2])
        end
    end

    hooksecurefunc("AlertFrame_PlayIntroAnimation", function(self)
        if self.flareIcon then
            self.flareIcon.animationGroup:Play()
        end
        if self.gwGlow then
            self.gwGlow:Play()
        end
        if self.shine and self.backdrop then
            self.shine.animIn:Stop()
            self.shine:Hide()
        end
    end)

    if not GW.settings.ALERTFRAME_ENABLED then return end

    local container = CreateFrame("Frame", nil, UIParent)
    GW.AlertContainerFrame = container
    container:SetSize(300, 5)
    local point = GW.settings.AlertPos
    container:SetPoint(point.point, UIParent, point.relativePoint, point.xOfs, point.yOfs)

    local function postDragFunction(self)
        local _, y = self.gwMover:GetCenter()
        local direction = y > UIParent:GetTop() / 2 and COMBAT_TEXT_SCROLL_DOWN or COMBAT_TEXT_SCROLL_UP
        self.gwMover.text:SetText(L["Alert Frames"] .. " (" .. direction .. ")")
    end
    GW.RegisterMovableFrame(container, L["Alert Frames"], "AlertPos", "Blizzard,Widgets", {300, 5}, nil, nil, postDragFunction)

    container:RegisterEvent("PLAYER_LEVEL_UP")
    container:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    container:RegisterEvent("UPDATE_PENDING_MAIL")
    container:RegisterEvent("BAG_UPDATE_DELAYED")
    container:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    container:RegisterEvent("QUEST_ACCEPTED")
    container:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
    container:RegisterEvent("CALENDAR_UPDATE_GUILD_EVENTS")
    container:RegisterEvent("PLAYER_ENTERING_WORLD")
    container:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
    if GW.Retail then
        container:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
        container:RegisterEvent("WEEKLY_REWARDS_UPDATE")
    end

    if not GW.Retail and not GW.Wrath then
        container:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE")
        GW.Libs.GW2Lib:RegisterCombatEvent(container, "SPELL_CAST_SUCCESS", CLEUHandling)
        GW.Libs.GW2Lib:RegisterCombatEvent(container, "SPELL_CREATE", CLEUHandling)
    end

    container.lastMinimapRare = {time = 0, id = nil}
    container.ignoreNewSpells = true
    container:SetScript("OnEvent", AlertContainerFrameOnEvent)
end

function GW.LoadOurAlertSubSystem()
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    GW.AlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("GW2_UIAlertFrameTemplate", GW2_UIAlertFrame_SetUp, 4, math.huge)
end
