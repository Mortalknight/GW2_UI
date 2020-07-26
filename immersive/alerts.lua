local _, GW = ...
local GetSetting = GW.GetSetting

GW2_UIAlertSystem = {}
local toastQueue = {} --Prevent from showing all "new" spells after spec change

local lastShown
local i = 0
local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -10

local constBackdropAlertFrame = {
    bgFile = "Interface/AddOns/GW2_UI/textures/toast-bg",
    edgeFile = "",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
local constBackdropLevelUpAlertFrame = {
    bgFile = "Interface/AddOns/GW2_UI/textures/toast-levelup",
    edgeFile = "",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local function forceAlpha(self, alpha, forced)
    if alpha ~= 1 and forced ~= true then
        self:SetAlpha(1, true)
    end
end

local function AddFlare(frame, flarFrame)
    if not flarFrame then return end

    if not frame.flareIcon then
        frame.flareIcon = flarFrame
    end

    if not flarFrame.flare then
        flarFrame.flare = flarFrame:CreateTexture(nil, "BACKGROUND")
        flarFrame.flare:SetTexture("Interface/AddOns/GW2_UI/textures/level-up-flare")
        flarFrame.flare:SetPoint("CENTER")
        flarFrame.flare:SetSize(120, 120)
        flarFrame.flare:Show()
    end
    if not flarFrame.flare2 then
        flarFrame.flare2 = flarFrame:CreateTexture(nil, "BACKGROUND")
        flarFrame.flare2:SetTexture("Interface/AddOns/GW2_UI/textures/level-up-flare")
        flarFrame.flare2:SetPoint("CENTER")
        flarFrame.flare2:SetSize(120, 120)
        flarFrame.flare2:Show()
    end

    if not flarFrame.animationGroup1 then
        flarFrame.animationGroup1 = flarFrame.flare:CreateAnimationGroup()
        local a1 = flarFrame.animationGroup1:CreateAnimation("Rotation")
        a1:SetDegrees(2000)
        a1:SetDuration(60)
        a1:SetSmoothing("OUT")
    end

    if not flarFrame.animationGroup2 then
        flarFrame.animationGroup2 = flarFrame.flare2:CreateAnimationGroup()
        local a2 = flarFrame.animationGroup2:CreateAnimation("Rotation")
        a2:SetDegrees(-2000)
        a2:SetDuration(60)
        a2:SetSmoothing("OUT")
    end
end

local function skinAchievementAlert(frame)
    frame:SetAlpha(1)

    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    if not frame.backdrop then
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame.Background, "TOPLEFT", -10, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame.Background, "BOTTOMRIGHT", 5, 0)
    end

    -- Background
    frame.Background:SetTexture()
    frame.OldAchievement:Kill()
    frame.glow:Kill()
    frame.shine:Kill()
    frame.GuildBanner:Kill()
    frame.GuildBorder:Kill()
    -- Text
    frame.Unlocked:SetTextColor(1, 1, 1)

    -- Icon
    frame.Icon.Texture:SetSize(45, 45)
    frame.Icon.Texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.Icon.Overlay:Kill()

    frame.Icon.Texture:ClearAllPoints()
    frame.Icon.Texture:SetPoint("LEFT", frame, 7, 0)

    if not frame.Icon.Texture.b then
        frame.Icon.Texture.b = CreateFrame("Frame", nil, frame)
        frame.Icon.Texture.b:SetAllPoints(frame.Icon.Texture)
        frame.Icon.Texture:SetParent(frame.Icon.Texture.b)
        frame.Icon.iconBorder = frame.Icon.Texture.b:CreateTexture(nil, "ARTWORK")
        frame.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.Icon.iconBorder:SetAllPoints(frame.Icon.Texture.b)
    end

    --flare
    AddFlare(frame, frame.Icon.Texture.b)
end

local function skinCriteriaAlert(frame)
    frame:SetAlpha(1)

    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    if not frame.backdrop then
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -35, 15)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 27, -10)
    end

    frame.Unlocked:SetTextColor(1, 1, 1)
    frame.Name:SetTextColor(1, 1, 0)
    frame.Name:SetFont(UNIT_NAME_FONT, 12)
    frame.Unlocked:SetFont(UNIT_NAME_FONT, 14)
    frame.Background:Kill()
    frame.glow:Kill()
    frame.shine:Kill()
    frame.Icon.Bling:Kill()
    frame.Icon.Overlay:Kill()

    -- Icon border
    if not frame.Icon.Texture.b then
        frame.Icon.Texture.b = CreateFrame("Frame", nil, frame)
        frame.Icon.Texture.b:SetAllPoints(frame.Icon.Texture)
        frame.Icon.Texture:SetParent(frame.Icon.Texture.b)
        frame.Icon.iconBorder = frame.Icon.Texture.b:CreateTexture(nil, "ARTWORK")
        frame.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.Icon.iconBorder:SetAllPoints(frame.Icon.Texture.b)
    end
    frame.Icon.Texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.Icon.Texture:SetSize(45, 45)
    --flare
    AddFlare(frame, frame.Icon.Texture.b)
end

local function skinWorldQuestCompleteAlert(frame)
    if not frame.isSkinned then
        frame:SetAlpha(1)
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -10, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

        frame.shine:Kill()
        -- Background
        if frame.GetNumRegions then
            for i = 1, frame:GetNumRegions() do
                local region = select(i, frame:GetRegions())
                if region:IsObjectType("Texture") then
                    if region:GetTexture() == "Interface\\LFGFrame\\UI-LFG-DUNGEONTOAST" then
                        region:Kill()
                    end
                end
            end
        end

        frame.ToastText:SetFont(UNIT_NAME_FONT, 14)

        --Icon
        frame.QuestTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        frame.QuestTexture:SetDrawLayer("ARTWORK")
        frame.QuestTexture.b = CreateFrame("Frame", nil, frame)
        frame.QuestTexture.b:SetAllPoints(frame.QuestTexture)
        frame.QuestTexture:SetParent(frame.QuestTexture.b)
        frame.QuestTexture.iconBorder = frame.QuestTexture.b:CreateTexture(nil, "ARTWORK")
        frame.QuestTexture.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.QuestTexture.iconBorder:SetAllPoints(frame.QuestTexture.b)

        --flare
        AddFlare(frame, frame.QuestTexture.b)

        frame.isSkinned = true
    end
end

local function skinDungeonCompletionAlert(frame)
    frame:SetAlpha(1)

    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    if not frame.backdrop then
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -35, 15)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 27, -10)
    end

    frame.shine:Kill()
    frame.glowFrame:Kill()
    frame.glowFrame.glow:Kill()

    frame.raidArt:Kill()
    frame.dungeonArt1:Kill()
    frame.dungeonArt2:Kill()
    frame.dungeonArt3:Kill()
    frame.dungeonArt4:Kill()
    frame.heroicIcon:Kill()

    -- Icon
    frame.dungeonTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.dungeonTexture:SetDrawLayer("OVERLAY")
    frame.dungeonTexture:ClearAllPoints()
    frame.dungeonTexture:SetPoint("LEFT", frame, 7, 0)

    if not frame.dungeonTexture.b then
        frame.dungeonTexture.b = CreateFrame("Frame", nil, frame)
        frame.dungeonTexture.b:SetAllPoints(frame.dungeonTexture)
        frame.dungeonTexture:SetParent(frame.dungeonTexture.b)
        frame.dungeonTexture.iconBorder = frame.dungeonTexture.b:CreateTexture(nil, "ARTWORK")
        frame.dungeonTexture.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.dungeonTexture.iconBorder:SetAllPoints(frame.dungeonTexture.b)
    end
    
    --flare
    AddFlare(frame, frame.dungeonTexture.b)
end

local function skinGuildChallengeAlert(frame)
    frame:SetAlpha(1)

    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    if not frame.backdrop then
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -25, 5)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 20, 0)
    end

    -- Background
    local region = select(2, frame:GetRegions())
    if region:IsObjectType('Texture') then
        if region:GetTexture() == "Interface\\GuildFrame\\GuildChallenges" then
            region:Kill()
        end
    end
    frame.glow:Kill()
    frame.shine:Kill()
    frame.EmblemBorder:Kill()

    -- Icon
    frame.EmblemIcon:ClearAllPoints()
    frame.EmblemIcon:SetPoint("LEFT", frame.backdrop, 25, 0)
    frame.EmblemBackground:ClearAllPoints()
    frame.EmblemBackground:SetPoint("LEFT", frame.backdrop, 25, 0)

    -- Icon border
    local EmblemIcon = frame.EmblemIcon
    if not EmblemIcon.b then
        EmblemIcon.b = CreateFrame("Frame", nil, frame)
        EmblemIcon.b:SetPoint("TOPLEFT", EmblemIcon, "TOPLEFT", -3, 3)
        EmblemIcon.b:SetPoint("BOTTOMRIGHT", EmblemIcon, "BOTTOMRIGHT", 3, -2)
        EmblemIcon:SetParent(EmblemIcon.b)
        EmblemIcon.iconBorder = EmblemIcon.b:CreateTexture(nil, "ARTWORK")
        EmblemIcon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        EmblemIcon.iconBorder:SetAllPoints(EmblemIcon.b)
    end
    SetLargeGuildTabardTextures("player", EmblemIcon)
    
    --flare
    AddFlare(frame, EmblemIcon.b)
end

local function skinHonorAwardedAlert(frame)
    frame:SetAlpha(1)

    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    frame.Background:Kill()
    frame.IconBorder:Kill()
    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    -- Icon border
    if not frame.Icon.b then
        frame.Icon.b = CreateFrame("Frame", nil, frame)
        frame.Icon.b:SetAllPoints(frame.Icon)
        frame.Icon:SetParent(frame.Icon.b)
        frame.Icon.iconBorder = frame.Icon.b:CreateTexture(nil, "ARTWORK")
        frame.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.Icon.iconBorder:SetAllPoints(frame.Icon.b)
    end

    if not frame.backdrop then
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame.Icon.b, "TOPLEFT", -25, 15)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame.Icon.b, "BOTTOMRIGHT", 227, -15)
    end

    --flare
    AddFlare(frame, frame.Icon.b)
end

local function skinLegendaryItemAlert(frame, itemLink)
    if not frame.isSkinned then
        frame.Background:Kill()
        frame.Background2:Kill()
        frame.Background3:Kill()
        frame.Ring1:Kill()
        frame.Particles1:Kill()
        frame.Particles2:Kill()
        frame.Particles3:Kill()
        frame.Starglow:Kill()
        frame.glow:Kill()
        frame.shine:Kill()

        --Icon
        frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        frame.Icon:SetDrawLayer("ARTWORK")
        frame.Icon.b = CreateFrame("Frame", nil, frame)
        frame.Icon.b:SetAllPoints(frame.Icon)
        frame.Icon:SetParent(frame.Icon.b)
        frame.Icon.iconBorder = frame.Icon.b:CreateTexture(nil, "ARTWORK")
        frame.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.Icon.iconBorder:SetAllPoints(frame.Icon.b)
        --Create Backdrop
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", 25, -15)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, 20)

        --flare
        AddFlare(frame, frame.Icon.b)

        frame.isSkinned = true
    end

    local _, _, itemRarity = GetItemInfo(itemLink)
    local color = ITEM_QUALITY_COLORS[itemRarity]
    if color then
        frame.Icon.b:SetBackdropBorderColor(color.r, color.g, color.b)
    else
        frame.Icon.b:SetBackdropBorderColor(0, 0, 0)
    end
end

local function skinLootWonAlert(frame)
    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    frame:SetAlpha(1)
    frame.Background:Kill()

    local lootItem = frame.lootItem or frame
    lootItem.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    lootItem.Icon:SetDrawLayer("BORDER")
    lootItem.IconBorder:Kill()
    lootItem.SpecRing:SetTexture("")

    frame.glow:Kill()
    frame.shine:Kill()
    frame.BGAtlas:Kill()
    frame.PvPBackground:Kill()

    -- Icon border
    if not lootItem.Icon.b then
        lootItem.Icon.b = CreateFrame("Frame", nil, frame)
        lootItem.Icon.b:SetAllPoints(lootItem.Icon)
        lootItem.Icon:SetParent(lootItem.Icon.b)
    end

    if not frame.backdrop then
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", lootItem.Icon.b, "TOPLEFT", -25, 15)
        frame.backdrop:SetPoint("BOTTOMRIGHT", lootItem.Icon.b, "BOTTOMRIGHT", 227, -15)
    end
    
    --flare
    AddFlare(frame, lootItem.Icon.b)
end

local function skinLootUpgradeAlert(frame)
    frame:SetAlpha(1)

    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    frame.Background:Kill()
    frame.BorderGlow:Kill()
    frame.Sheen:Kill()

    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.Icon:SetDrawLayer("BORDER", 5)

    -- Icon border
    if not frame.Icon.b then
        frame.Icon.b = CreateFrame("Frame", nil, frame)
        frame.Icon.b:SetAllPoints(frame.Icon)
        frame.Icon:SetParent(frame.Icon.b)
    end

    if not frame.backdrop then
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame.Icon.b, "TOPLEFT", -25, 15)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame.Icon.b, "BOTTOMRIGHT", 227, -15)
    end
    
    --flare
    AddFlare(frame, frame.Icon.b)
end

local function skinMoneyWonAlert(frame)
    frame:SetAlpha(1)

    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    frame.Background:Kill()
    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.IconBorder:Kill()

    -- Icon border
    if not frame.Icon.b then
        frame.Icon.b = CreateFrame("Frame", nil, frame)
        frame.Icon.b:SetAllPoints(frame.Icon)
        frame.Icon:SetParent(frame.Icon.b)
        frame.Icon.iconBorder = frame.Icon.b:CreateTexture(nil, "ARTWORK")
        frame.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.Icon.iconBorder:SetAllPoints(frame.Icon.b)
    end

    if not frame.backdrop then
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame.Icon.b, "TOPLEFT", -25, 15)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame.Icon.b, "BOTTOMRIGHT", 227, -15)
    end
    
    --flare
    AddFlare(frame, frame.Icon.b)
end

local function skinEntitlementDeliveredAlert(frame)
    frame:SetAlpha(1)

    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    if not frame.backdrop then
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, 5)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 10, 10)
    end

    -- Background
    frame.Background:Kill()
    frame.glow:Kill()
    frame.shine:Kill()

    -- Icon
    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.Icon:ClearAllPoints()
    frame.Icon:SetPoint("LEFT", frame.backdrop, 25, 0)

    -- Icon border
    if not frame.Icon.b then
        frame.Icon.b = CreateFrame("Frame", nil, frame)
        frame.Icon.b:SetPoint("TOPLEFT", frame.Icon, "TOPLEFT", -2, 2)
        frame.Icon.b:SetPoint("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, -2)
        frame.Icon:SetParent(frame.Icon.b)
        frame.Icon.iconBorder = frame.Icon.b:CreateTexture(nil, "ARTWORK")
        frame.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.Icon.iconBorder:SetAllPoints(frame.Icon.b)
    end
    
    --flare
    AddFlare(frame, frame.Icon.b)
end

local function skinRafRewardDeliveredAlert(frame)
    frame:SetAlpha(1)

    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    if not frame.backdrop then
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, 5)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 10, 10)
    end

    -- Background
    frame.StandardBackground:Kill()
    frame.glow:Kill()
    frame.shine:Kill()

    -- Icon
    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.Icon:ClearAllPoints()
    frame.Icon:SetPoint("LEFT", frame.backdrop, 25, 0)

    -- Icon border
    if not frame.Icon.b then
        frame.Icon.b = CreateFrame("Frame", nil, frame)
        frame.Icon.b:SetPoint("TOPLEFT", frame.Icon, "TOPLEFT", -2, 2)
        frame.Icon.b:SetPoint("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, -2)
        frame.Icon:SetParent(frame.Icon.b)
        frame.Icon.iconBorder = frame.Icon.b:CreateTexture(nil, "ARTWORK")
        frame.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.Icon.iconBorder:SetAllPoints(frame.Icon.b)
    end
    
    --flare
    AddFlare(frame, frame.Icon.b)
end

local function skinDigsiteCompleteAlert(frame)
    frame:SetAlpha(1)

    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    if not frame.backdrop then
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, 0)
    end

    frame.glow:Kill()
    frame.shine:Kill()
    frame:GetRegions():Hide()
    frame.DigsiteTypeTexture.b = CreateFrame("Frame", nil, frame)
    frame.DigsiteTypeTexture.b:SetPoint("TOPLEFT", frame.DigsiteTypeTexture, "TOPLEFT", -2, 2)
    frame.DigsiteTypeTexture.b:SetPoint("BOTTOMRIGHT", frame.DigsiteTypeTexture, "BOTTOMRIGHT", 2, -2)
    frame.DigsiteTypeTexture:SetParent(frame.DigsiteTypeTexture.b)
    frame.DigsiteTypeTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.DigsiteTypeTexture:SetDrawLayer("ARTWORK", 7)
    frame.DigsiteTypeTexture:ClearAllPoints()
    frame.DigsiteTypeTexture:SetPoint("LEFT", frame.backdrop, 25,-18)
end

local function skinNewRecipeLearnedAlert(frame)
    frame:SetAlpha(1)

    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    if not frame.backdrop then
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, 5)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 10)
    end

    frame.glow:Kill()
    frame.shine:Kill()
    frame:GetRegions():Hide()

    frame.Icon:SetMask("")
    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.Icon:SetDrawLayer("BORDER", 5)
    frame.Icon:ClearAllPoints()
    frame.Icon:SetPoint("LEFT", frame.backdrop, 30, 0)
    frame.Icon:SetSize(45, 45)

    -- Icon border
    if not frame.Icon.b then
        frame.Icon.b = CreateFrame("Frame", nil, frame)
        frame.Icon.b:SetPoint("TOPLEFT", frame.Icon, "TOPLEFT", -2, 2)
        frame.Icon.b:SetPoint("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, -2)
        frame.Icon:SetParent(frame.Icon.b)
        frame.Icon.iconBorder = frame.Icon.b:CreateTexture(nil, "ARTWORK")
        frame.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.Icon.iconBorder:SetAllPoints(frame.Icon.b)
    end

    frame.Name:SetFont(UNIT_NAME_FONT, 12)
    frame.Title:SetFont(UNIT_NAME_FONT, 14)
    
    --flare
    AddFlare(frame, frame.Icon.b)
end

local function skinNewPetAlert(frame)
    frame:SetAlpha(1)

    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    frame.Background:Kill()
    frame.IconBorder:Kill()

    frame.Icon:SetMask("")
    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.Icon:SetDrawLayer("BORDER", 5)

    -- Icon border
    if not frame.Icon.b then
        frame.Icon.b = CreateFrame("Frame", nil, frame)
        frame.Icon.b:SetPoint("TOPLEFT", frame.Icon, "TOPLEFT", -2, 2)
        frame.Icon.b:SetPoint("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, -2)
        frame.Icon:SetParent(frame.Icon.b)
        frame.Icon.iconBorder = frame.Icon.b:CreateTexture(nil, "ARTWORK")
        frame.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.Icon.iconBorder:SetAllPoints(frame.Icon.b)
    end

    if not frame.backdrop then
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame.Icon.b, "TOPLEFT", -25, 15)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame.Icon.b, "BOTTOMRIGHT", 227, -15)
    end

    frame.Name:SetFont(UNIT_NAME_FONT, 12)
    frame.Label:SetFont(UNIT_NAME_FONT, 14)
    
    --flare
    AddFlare(frame, frame.Icon.b)
end

local function skinInvasionAlert(frame)
    if not frame.isSkinned then
        frame:SetAlpha(1)
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        
        --Background contains the item border too, so have to remove it
        if frame.GetRegions then
            local region, icon = frame:GetRegions()
            if region and region:IsObjectType("Texture") then
                if region:GetAtlas() == "legioninvasion-Toast-Frame" then
                    region:Kill()
                end
            end
            -- Icon border
            if icon and icon:IsObjectType('Texture') then
                if icon:GetTexture() == "Interface\\Icons\\Ability_Warlock_DemonicPower" then
                    icon.b = CreateFrame("Frame", nil, frame)
                    icon.b:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
                    icon.b:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
                    icon:SetParent(icon.b)
                    icon.iconBorder = icon.b:CreateTexture(nil, "ARTWORK")
                    icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
                    icon.iconBorder:SetAllPoints(icon.b)
                    icon:SetDrawLayer("OVERLAY")
                    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    
                    --flare
                    AddFlare(frame, icon.b)
                end
            end
        end
        frame.isSkinned = true
    end
end

local function skinScenarioAlert(frame)
    frame:SetAlpha(1)

    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    if not frame.backdrop then
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    end

    -- Background
    for i = 1, frame:GetNumRegions() do
        local region = select(i, frame:GetRegions())
        if region:IsObjectType('Texture') then
            if region:GetAtlas() == "Toast-IconBG" or region:GetAtlas() == "Toast-Frame" then
                region:Kill()
            end
        end
    end

    frame.shine:Kill()
    frame.glowFrame:Kill()
    frame.glowFrame.glow:Kill()

    -- Icon
    frame.dungeonTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.dungeonTexture:ClearAllPoints()
    frame.dungeonTexture:SetPoint("LEFT", frame.backdrop, 30, 0)
    frame.dungeonTexture:SetDrawLayer("OVERLAY")

    -- Icon border
    if not frame.dungeonTexture.b then        
        frame.dungeonTexture.b = CreateFrame("Frame", nil, frame)
        frame.dungeonTexture.b:SetPoint("TOPLEFT", frame.dungeonTexture, "TOPLEFT", -2, 2)
        frame.dungeonTexture.b:SetPoint("BOTTOMRIGHT", frame.dungeonTexture, "BOTTOMRIGHT", 2, -2)
        frame.dungeonTexture:SetParent(frame.dungeonTexture.b)
        frame.dungeonTexture.iconBorder = frame.dungeonTexture.b:CreateTexture(nil, "ARTWORK")
        frame.dungeonTexture.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.dungeonTexture.iconBorder:SetAllPoints(frame.dungeonTexture.b)
    end
    
    --flare
    AddFlare(frame, frame.dungeonTexture.b)
end

local function skinGarrisonFollowerAlert(frame, _, _, _, quality)
    -- /run GarrisonFollowerAlertSystem:AddAlert(204, "Ben Stone", 90, 3, false, C_Garrison.GetFollowerInfo(204))
    if not frame.isSkinned then
        frame.glow:Kill()
        frame.shine:Kill()
        frame.FollowerBG:SetAlpha(0)
        frame.DieIcon:SetAlpha(0)
        --Background
        if frame.GetNumRegions then
            for i = 1, frame:GetNumRegions() do
                local region = select(i, frame:GetRegions())
                if region:IsObjectType('Texture') then
                    if region:GetAtlas() == "Garr_MissionToast" then
                        region:Kill()
                    end
                end
            end
        end
        --Create Backdrop
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 10)

        frame.PortraitFrame.PortraitRing:Hide()
        frame.PortraitFrame.PortraitRingQuality:SetTexture()
        frame.PortraitFrame.LevelBorder:SetAlpha(0)

        local level = frame.PortraitFrame.Level
        level:ClearAllPoints()
        level:SetPoint("BOTTOM", frame.PortraitFrame, 0, 12)

        local squareBG = CreateFrame("Frame", nil, frame.PortraitFrame)
        squareBG:SetFrameLevel(frame.PortraitFrame:GetFrameLevel() - 1)
        squareBG:SetPoint("TOPLEFT", 3, -3)
        squareBG:SetPoint("BOTTOMRIGHT", -3, 11)
        frame.PortraitFrame.squareBG = squareBG

        local cover = frame.PortraitFrame.PortraitRingCover
        if cover then
            cover:SetColorTexture(0, 0, 0)
            cover:SetAllPoints(squareBG)
        end

        frame.Name:SetFont(UNIT_NAME_FONT, 12)
        frame.Title:SetFont(UNIT_NAME_FONT, 14)
        
        --flare
        AddFlare(frame, frame.PortraitFrame.squareBG)

        frame.isSkinned = true
    end

    local color = ITEM_QUALITY_COLORS[quality]
    if color then
        frame.PortraitFrame.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
    else
        frame.PortraitFrame.squareBG:SetBackdropBorderColor(0, 0, 0)
    end
end

local function skinGarrisonShipFollowerAlert(frame)
    if not frame.isSkinned then
        frame.glow:Kill()
        frame.shine:Kill()

        frame.FollowerBG:SetAlpha(0)
        frame.DieIcon:SetAlpha(0)
        --Background
        frame.Background:Kill()
        --Create Backdrop
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

        frame.Name:SetFont(UNIT_NAME_FONT, 10)
        frame.Title:SetFont(UNIT_NAME_FONT, 12)
        frame.Class:SetFont(UNIT_NAME_FONT, 10)

        frame.isSkinned = true
    end
end

local function skinGarrisonTalentAlert(frame)
    if not frame.isSkinned then
        frame:GetRegions():Hide()
        frame.glow:Kill()
        frame.shine:Kill()
        --Icon
        frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        frame.Icon.b = CreateFrame("Frame", nil, frame)
        frame.Icon.b:SetPoint("TOPLEFT", frame.Icon, "TOPLEFT", -2, 2)
        frame.Icon.b:SetPoint("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, -2)
        frame.Icon:SetParent(frame.Icon.b)
        frame.Icon.iconBorder = frame.Icon.b:CreateTexture(nil, "ARTWORK")
        frame.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.Icon.iconBorder:SetAllPoints(frame.Icon.b)
        --Create Backdrop
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

        --flare
        AddFlare(frame, frame.Icon.b)

        frame.isSkinned = true
    end
end

local function skinGarrisonBuildingAlert(frame)
    if not frame.isSkinned then
        frame.glow:Kill()
        frame.shine:Kill()
        frame:GetRegions():Hide()
        --Create Backdrop
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        --Icon
        frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        frame.Icon.b = CreateFrame("Frame", nil, frame)
        frame.Icon.b:SetPoint("TOPLEFT", frame.Icon, "TOPLEFT", -2, 2)
        frame.Icon.b:SetPoint("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, -2)
        frame.Icon:SetParent(frame.Icon.b)
        frame.Icon.iconBorder = frame.Icon.b:CreateTexture(nil, "ARTWORK")
        frame.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.Icon.iconBorder:SetAllPoints(frame.Icon.b)
        
        frame.Name:SetFont(UNIT_NAME_FONT, 12)
        frame.Title:SetFont(UNIT_NAME_FONT, 14)

        --flare
        AddFlare(frame, frame.Icon.b)

        frame.isSkinned = true
    end
end

local function skinGarrisonMissionAlert(frame)
    -- /run GarrisonMissionAlertSystem:AddAlert(C_Garrison.GetBasicMissionInfo(391))
    if not frame.isSkinned then
        frame.glow:Kill()
        frame.shine:Kill()
        frame.IconBG:Kill()
        frame.Background:Kill()

        --Create Backdrop
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

        --Icon
        frame.MissionType:ClearAllPoints()
        frame.MissionType:SetPoint("LEFT", frame.backdrop, 30, 0)
        frame.MissionType:SetSize(45, 45)
        frame.MissionType:SetDrawLayer("ARTWORK")
        frame.MissionType:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        frame.MissionType.b = CreateFrame("Frame", nil, frame)
        frame.MissionType.b:SetPoint("TOPLEFT", frame.MissionType, "TOPLEFT", -2, 2)
        frame.MissionType.b:SetPoint("BOTTOMRIGHT", frame.MissionType, "BOTTOMRIGHT", 2, -2)
        frame.MissionType:SetParent(frame.MissionType.b)
        frame.MissionType.iconBorder = frame.MissionType.b:CreateTexture(nil, "ARTWORK")
        frame.MissionType.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.MissionType.iconBorder:SetAllPoints(frame.MissionType.b)

        frame.Name:SetFont(UNIT_NAME_FONT, 12)
        frame.Title:SetFont(UNIT_NAME_FONT, 14)
        
        --flare
        AddFlare(frame, frame.MissionType.b)

        frame.isSkinned = true
    end
end

local function skinGarrisonShipMissionAlert(frame)
    -- /run GarrisonShipMissionAlertSystem:AddAlert(C_Garrison.GetBasicMissionInfo(517))
    if not frame.isSkinned then
        frame.glow:Kill()
        frame.shine:Kill()
        frame.Background:Kill()

        --Create Backdrop
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

        --Icon
        frame.MissionType:ClearAllPoints()
        frame.MissionType:SetPoint("LEFT", frame.backdrop, 30, 0)
        frame.MissionType:SetSize(45, 45)
        frame.MissionType:SetDrawLayer("ARTWORK")
        frame.MissionType:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        frame.MissionType.b = CreateFrame("Frame", nil, frame)
        frame.MissionType.b:SetPoint("TOPLEFT", frame.MissionType, "TOPLEFT", -2, 2)
        frame.MissionType.b:SetPoint("BOTTOMRIGHT", frame.MissionType, "BOTTOMRIGHT", 2, -2)
        frame.MissionType:SetParent(frame.MissionType.b)
        frame.MissionType.iconBorder = frame.MissionType.b:CreateTexture(nil, "ARTWORK")
        frame.MissionType.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.MissionType.iconBorder:SetAllPoints(frame.MissionType.b)

        --flare
        AddFlare(frame, frame.MissionType.b)

        frame.isSkinned = true
    end
end

local function skinGarrisonRandomMissionAlert(frame, _, _, _, _, _, quality)
    -- /run GarrisonRandomMissionAlertSystem:AddAlert(C_Garrison.GetBasicMissionInfo(391))
    if not frame.isSkinned then
        frame.glow:Kill()
        frame.shine:Kill()
        frame.Background:Kill()
        frame.Blank:Kill()
        frame.IconBG:Kill()

        --Create Backdrop
        frame:CreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

        --Icon
        frame.MissionType:ClearAllPoints()
        frame.MissionType:SetPoint("LEFT", frame.backdrop, 30, 0)
        frame.MissionType:SetSize(45, 45)
        frame.MissionType:SetDrawLayer("ARTWORK")
        frame.MissionType:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        frame.MissionType.b = CreateFrame("Frame", nil, frame)
        frame.MissionType.b:SetPoint("TOPLEFT", frame.MissionType, "TOPLEFT", -2, 2)
        frame.MissionType.b:SetPoint("BOTTOMRIGHT", frame.MissionType, "BOTTOMRIGHT", 2, -2)
        frame.MissionType:SetParent(frame.MissionType.b)
        frame.MissionType.iconBorder = frame.MissionType.b:CreateTexture(nil, "ARTWORK")
        frame.MissionType.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.MissionType.iconBorder:SetAllPoints(frame.MissionType.b)

        --flare
        AddFlare(frame, frame.MissionType.b)

        frame.isSkinned = true
    end

    if frame.PortraitFrame and frame.PortraitFrame.squareBG then
        local color = quality and ITEM_QUALITY_COLORS[quality]
        if color then
            frame.PortraitFrame.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
        else
            frame.PortraitFrame.squareBG:SetBackdropBorderColor(0, 0, 0)
        end
    end
end

local function skinBonusRollMoney()
    local frame = _G.BonusRollMoneyWonFrame
    frame:SetAlpha(1)
    hooksecurefunc(frame, "SetAlpha", forceAlpha)

    frame.Background:Kill()
    frame.IconBorder:Kill()

    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    -- Icon border
    frame.Icon.b = CreateFrame("Frame", nil, frame)
    frame.Icon.b:SetPoint("TOPLEFT", frame.Icon, "TOPLEFT", -2, 2)
    frame.Icon.b:SetPoint("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, -2)
    frame.Icon:SetParent(frame.Icon.b)
    frame.Icon.iconBorder = frame.Icon.b:CreateTexture(nil, "ARTWORK")
    frame.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    frame.Icon.iconBorder:SetAllPoints(frame.Icon.b)

    --Create Backdrop
    frame:CreateBackdrop(constBackdropAlertFrame)
    frame.backdrop:SetPoint("TOPLEFT", frame.Icon.b, "TOPLEFT", -25, 15)
    frame.backdrop:SetPoint("BOTTOMRIGHT", frame.Icon.b, "BOTTOMRIGHT", 227, -15)

    --flare
    AddFlare(frame, frame.Icon.b)
end

local function skinBonusRollLoot()
    local frame = _G.BonusRollLootWonFrame
    frame:SetAlpha(1)
    hooksecurefunc(frame, "SetAlpha", forceAlpha)

    frame.Background:Kill()
    frame.glow:Kill()
    frame.shine:Kill()

    local lootItem = frame.lootItem or frame
    lootItem.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    lootItem.IconBorder:Kill()
    
    -- Icon border
    lootItem.Icon.b = CreateFrame("Frame", nil, frame)
    lootItem.Icon.b:SetPoint("TOPLEFT", lootItem.Icon, "TOPLEFT", -2, 2)
    lootItem.Icon.b:SetPoint("BOTTOMRIGHT", lootItem.Icon, "BOTTOMRIGHT", 2, -2)
    lootItem.Icon:SetParent(lootItem.Icon.b)
    lootItem.Icon.iconBorder = lootItem.Icon.b:CreateTexture(nil, "ARTWORK")
    lootItem.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    lootItem.Icon.iconBorder:SetAllPoints(lootItem.Icon.b)

    --Create Backdrop
    frame:CreateBackdrop(constBackdropAlertFrame)
    frame.backdrop:SetPoint("TOPLEFT", lootItem.Icon.b, "TOPLEFT", -25, 15)
    frame.backdrop:SetPoint("BOTTOMRIGHT", lootItem.Icon.b, "BOTTOMRIGHT", 227, -15)

    --flare

    AddFlare(frame, lootItem.Icon.b)
end

function GW2_UIAlertFrame_OnClick(self, ...)
    if (self.delay == -1) then
        self:SetScript("OnLeave", AlertFrame_ResumeOutAnimation)
        self.delay = 0
    end
    if (self.onClick) then
        if (AlertFrame_OnClick(self, ...)) then  return  end -- Handle right-clicking to hide the frame.
        self.onClick(self, ...)
    elseif (self.onClick == false) then
        AlertFrame_OnClick(self, ...)
    end
end

local function GW2_UIAlertFrame_SetUp(frame, name, delay, toptext, onClick, icon, levelup, spellID)
    -- An alert flagged as alreadyEarned has more space for the text to display since there's no shield+points icon.
    local ret = AchievementAlertFrame_SetUp(frame, 5208, true)
    frame.Name:SetText(name)
    frame.Name:SetFont(UNIT_NAME_FONT, 12)
    frame.Unlocked:SetText(toptext or "")
    frame.Unlocked:SetFont(UNIT_NAME_FONT, 14)
    frame.onClick = onClick
    frame.delay = delay
    frame.spellID = spellID
    frame.levelup = levelup

    frame.Icon:SetScript("OnEnter", function(self)
        if self:GetParent().spellID then
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
            GameTooltip:ClearLines()
            GameTooltip:SetSpellByID(self:GetParent().spellID)
            GameTooltip:Show()
        end
    end)
    frame.Icon:SetScript("OnLeave", GameTooltip_Hide)

    frame:SetAlpha(1)

    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    if not frame.backdrop then
        frame:CreateBackdrop()
        frame.backdrop:SetPoint("TOPLEFT", frame.Background, "TOPLEFT", -10, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame.Background, "BOTTOMRIGHT", 5, 0)
    end
    frame.backdrop:SetBackdrop(levelup and constBackdropLevelUpAlertFrame or constBackdropAlertFrame)

    if delay == -1 then
        frame:SetScript("OnLeave", nil)
    else
        frame:SetScript("OnLeave", AlertFrame_ResumeOutAnimation)
    end

    -- Background
    frame.Background:SetTexture()
    frame.OldAchievement:Kill()
    frame.glow:Kill()
    frame.shine:Kill()
    frame.GuildBanner:Kill()
    frame.GuildBorder:Kill()

    -- Text
    frame.Unlocked:SetTextColor(1, 1, 1)

    -- Icon
    frame.Icon.Texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.Icon.Overlay:Kill()

    frame.Icon.Texture:ClearAllPoints()
    frame.Icon.Texture:SetPoint("LEFT", frame, 7, 0)

    frame.Icon.Texture:SetTexture(icon)
    frame.Icon.Texture.b = CreateFrame("Frame", nil, frame)
    frame.Icon.Texture.b:SetAllPoints(frame.Icon.Texture)
    frame.Icon.Texture:SetParent(frame.Icon.Texture.b)

    --flare
    if not frame.flareIcon then
        AddFlare(frame, frame.Icon.Texture.b)
    end
end

local function AlertContainerFrameOnEvent(self, event, ...)
    if event == "PLAYER_LEVEL_UP" then
        local level, _, _, talentPoints, numNewPvpTalentSlots = ...
        GW2_UIAlertSystem.AlertSystem:AddAlert(LEVEL_UP_YOU_REACHED .. " " .. LEVEL .. " " .. ..., nil, PLAYER_LEVEL_UP, false, "Interface/AddOns/GW2_UI/textures/icon-levelup", true)
        -- /run GW2_UIAlertSystem.AlertSystem:AddAlert(LEVEL_UP_YOU_REACHED .. " " .. LEVEL .. " 120", nil, PLAYER_LEVEL_UP, false, "Interface/AddOns/GW2_UI/textures/icon-levelup", true)

        if talentPoints and talentPoints > 0 then
            GW2_UIAlertSystem.AlertSystem:AddAlert(LEVEL_UP_TALENT_MAIN, nil, LEVEL_UP_TALENT_SUB, false, "Interface/AddOns/GW2_UI/textures/talent-icon", false)
            --/run GW2_UIAlertSystem.AlertSystem:AddAlert(LEVEL_UP_TALENT_MAIN, nil, LEVEL_UP_TALENT_SUB, false, "Interface/AddOns/GW2_UI/textures/talent-icon", false)
        end
        if numNewPvpTalentSlots and numNewPvpTalentSlots > 0 then
            GW2_UIAlertSystem.AlertSystem:AddAlert(LEVEL_UP_PVP_TALENT_MAIN, nil, BONUS_TALENTS, false, "Interface/AddOns/GW2_UI/textures/talent-icon", false)
            --/run GW2_UIAlertSystem.AlertSystem:AddAlert(LEVEL_UP_PVP_TALENT_MAIN, nil, BONUS_TALENTS, false, "Interface/AddOns/GW2_UI/textures/talent-icon", false)
        end

        -- if we learn a spell here we should show the new spell so we remove the event drom the toastQueue list
        for k, v in pairs(toastQueue) do
            if v ~= nil and v.event == "LEARNED_SPELL_IN_TAB" then
                v.event = ""
            end
        end
    elseif event == "LEARNED_SPELL_IN_TAB" then
        local spellID = ...
        local name, _, icon = GetSpellInfo(spellID)
        toastQueue[#toastQueue + 1] = {name = name, spellID = spellID, icon = icon, event = event}

        C_Timer.After(1, function()
            for k, v in pairs(toastQueue) do
                if v ~= nil then
                    GW2_UIAlertSystem.AlertSystem:AddAlert(SPELL_BUCKET_ABILITIES_UNLOCKED, nil, v.name, false, v.icon, false, v.spellID)
                end
            end
            wipe(toastQueue)
        end)
        -- /run GW2_UIAlertSystem.AlertSystem:AddAlert(GetSpellInfo(48181), nil, LEVEL_UP_ABILITY, false, select(3, GetSpellInfo(48181)), false, 48181)
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        for k, v in pairs(toastQueue) do
            if v ~= nil and v.event == "LEARNED_SPELL_IN_TAB" then
                toastQueue[k] = nil
            end
        end
    end
end

local function loadAlterSystemFrameSkins()
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end

    -- Add customs alert system
    if not GW2_UIAlertSystem.AlertSystem then
        GW2_UIAlertSystem.AlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("GW2_UIAlertFrameTemplate", GW2_UIAlertFrame_SetUp, 4, math.huge)
    end
    
    -- Achievements
    hooksecurefunc(_G.AchievementAlertSystem, "setUpFunction", skinAchievementAlert)
    hooksecurefunc(_G.CriteriaAlertSystem, "setUpFunction", skinCriteriaAlert)
    
    -- Encounters
    hooksecurefunc(_G.DungeonCompletionAlertSystem, "setUpFunction", skinDungeonCompletionAlert)
    hooksecurefunc(_G.WorldQuestCompleteAlertSystem, "setUpFunction", skinWorldQuestCompleteAlert) --TODO: position
    hooksecurefunc(_G.GuildChallengeAlertSystem, "setUpFunction", skinGuildChallengeAlert)
    hooksecurefunc(_G.InvasionAlertSystem, "setUpFunction", skinInvasionAlert)
    hooksecurefunc(_G.ScenarioAlertSystem, "setUpFunction", skinScenarioAlert) --TODO: position

    -- Loot
    hooksecurefunc(_G.LegendaryItemAlertSystem, "setUpFunction", skinLegendaryItemAlert)
    hooksecurefunc(_G.LootAlertSystem, "setUpFunction", skinLootWonAlert)
    hooksecurefunc(_G.LootUpgradeAlertSystem, "setUpFunction", skinLootUpgradeAlert)
    hooksecurefunc(_G.MoneyWonAlertSystem, "setUpFunction", skinMoneyWonAlert)
    hooksecurefunc(_G.EntitlementDeliveredAlertSystem, "setUpFunction", skinEntitlementDeliveredAlert)
    hooksecurefunc(_G.RafRewardDeliveredAlertSystem, "setUpFunction", skinRafRewardDeliveredAlert)
    
    -- Professions
    hooksecurefunc(_G.DigsiteCompleteAlertSystem, "setUpFunction", skinDigsiteCompleteAlert)
    hooksecurefunc(_G.NewRecipeLearnedAlertSystem, "setUpFunction", skinNewRecipeLearnedAlert)

    -- Honor
    hooksecurefunc(_G.HonorAwardedAlertSystem, "setUpFunction", skinHonorAwardedAlert)
    
    -- Pets/Mounts
    hooksecurefunc(_G.NewPetAlertSystem, "setUpFunction", skinNewPetAlert)
    hooksecurefunc(_G.NewMountAlertSystem, "setUpFunction", skinNewPetAlert)
    hooksecurefunc(_G.NewToyAlertSystem, "setUpFunction", skinNewPetAlert)
    
    -- Garrisons
    hooksecurefunc(_G.GarrisonFollowerAlertSystem, "setUpFunction", skinGarrisonFollowerAlert)
    hooksecurefunc(_G.GarrisonShipFollowerAlertSystem, "setUpFunction", skinGarrisonShipFollowerAlert)
    hooksecurefunc(_G.GarrisonTalentAlertSystem, "setUpFunction", skinGarrisonTalentAlert) --TODO: position
    hooksecurefunc(_G.GarrisonBuildingAlertSystem, "setUpFunction", skinGarrisonBuildingAlert)
    hooksecurefunc(_G.GarrisonMissionAlertSystem, "setUpFunction", skinGarrisonMissionAlert)
    hooksecurefunc(_G.GarrisonShipMissionAlertSystem, "setUpFunction", skinGarrisonShipMissionAlert)
    hooksecurefunc(_G.GarrisonRandomMissionAlertSystem, "setUpFunction", skinGarrisonRandomMissionAlert)
    
    --Bonus Roll Money
    skinBonusRollMoney() --TODO: position

    --Bonus Roll Loot
    skinBonusRollLoot() --TODO: position

    local AlertContainerFrame = CreateFrame("Frame", nil, UIParent)
    AlertContainerFrame:SetSize(300, 5) -- 265

    local point = GetSetting("AlertPos")
    AlertContainerFrame:ClearAllPoints()
    AlertContainerFrame:SetPoint(point.point, UIParent, point.relativePoint, point.xOfs, point.yOfs)

    local _, y = AlertContainerFrame:GetCenter()
    local screenHeight = UIParent:GetTop()
    if y > (screenHeight / 2) then
        GW.RegisterMovableFrame(AlertContainerFrame, GW.L["ALERTFRAMES"] .. " (" .. COMBAT_TEXT_SCROLL_DOWN .. ")", "AlertPos", "VerticalActionBarDummy", {300, 5})
    else
        GW.RegisterMovableFrame(AlertContainerFrame, GW.L["ALERTFRAMES"] .. " (" .. COMBAT_TEXT_SCROLL_UP .. ")", "AlertPos", "VerticalActionBarDummy", {300, 5})
    end

    AlertContainerFrame:RegisterEvent("PLAYER_LEVEL_UP")
    AlertContainerFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")
    AlertContainerFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    
    AlertContainerFrame:SetScript("OnEvent", AlertContainerFrameOnEvent)

    -- add flare animation
    hooksecurefunc("AlertFrame_PlayIntroAnimation", function(self)
        -- show flare
        if self.flareIcon then
            self.flareIcon.animationGroup1:Play()
            self.flareIcon.animationGroup2:Play()
        end
    end)
    hooksecurefunc("AlertFrame_PlayOutAnimation", function(self)
        if self.flareIcon then
            self.timer = C_Timer.NewTicker(self.duration or 4, function()
                if not self:IsShown() then
                    self.flareIcon.animationGroup1:Stop()
                    self.flareIcon.animationGroup2:Stop()
                    self.timer:Cancel()
                end
            end)
        end
    end)

    return AlertContainerFrame
end
GW.loadAlterSystemFrameSkins = loadAlterSystemFrameSkins