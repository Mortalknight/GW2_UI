local _, GW = ...
local GetSetting = GW.GetSetting

GW2_UIAlertSystem = {}
local toastQueue = {} --Prevent from showing all "new" spells after spec change
local hasMail = false
local showRepair = true
local numInvites = 0
local LFG_Timer = 0
local guildInviteCache = {}
local slots = {
    [1] = {1, INVTYPE_HEAD, 1000},
    [2] = {3, INVTYPE_SHOULDER, 1000},
    [3] = {5, INVTYPE_ROBE, 1000},
    [4] = {6, INVTYPE_WAIST, 1000},
    [5] = {9, INVTYPE_WRIST, 1000},
    [6] = {10, INVTYPE_HAND, 1000},
    [7] = {7, INVTYPE_LEGS, 1000},
    [8] = {8, INVTYPE_FEET, 1000},
    [9] = {16, INVTYPE_WEAPONMAINHAND, 1000},
    [10] = {17, INVTYPE_WEAPONOFFHAND, 1000},
    [11] = {18, INVTYPE_RANGED, 1000}
}

local ignoreDragonRidingSpells = {
    [372608] = true,
    [372610] = true,
    [374990] = true,
    [361584] = true,
}

local PARAGON_QUEST_ID = { --[questID] = {factionID}
    --Legion
    [48976] = {2170}, -- Argussian Reach
    [46777] = {2045}, -- Armies of Legionfall
    [48977] = {2165}, -- Army of the Light
    [46745] = {1900}, -- Court of Farondis
    [46747] = {1883}, -- Dreamweavers
    [46743] = {1828}, -- Highmountain Tribes
    [46748] = {1859}, -- The Nightfallen
    [46749] = {1894}, -- The Wardens
    [46746] = {1948}, -- Valarjar

    --Battle for Azeroth
    --Neutral
    [54453] = {2164}, --Champions of Azeroth
    [58096] = {2415}, --Rajani
    [55348] = {2391}, --Rustbolt Resistance
    [54451] = {2163}, --Tortollan Seekers
    [58097] = {2417}, --Uldum Accord

    --Horde
    [54460] = {2156}, --Talanji's Expedition
    [54455] = {2157}, --The Honorbound
    [53982] = {2373}, --The Unshackled
    [54461] = {2158}, --Voldunai
    [54462] = {2103}, --Zandalari Empire

    --Alliance
    [54456] = {2161}, --Order of Embers
    [54458] = {2160}, --Proudmoore Admiralty
    [54457] = {2162}, --Storm's Wake
    [54454] = {2159}, --The 7th Legion
    [55976] = {2400}, --Waveblade Ankoan

    --Shadowlands
    [61100] = {2413}, --Court of Harvesters
    [61097] = {2407}, --The Ascended
    [61095] = {2410}, --The Undying Army
    [61098] = {2465}, --The Wild Hunt
    [64012] = {2470}, --The Death Advance
    [64266] = {2472}, --The Archivist's Codex
    [64267] = {2432}, --Ve'nari
    [64867] = {2478}, --The Enlightened
}

local VignetteExclusionMapIDs = {
    [579] = true, -- Lunarfall: Alliance garrison
    [585] = true, -- Frostwall: Horde garrison
    [646] = true, -- Scenario: The Broken Shore
    [1911] = true, -- Thorgast
    [1912] = true, -- Thorgast
}

local VignetteBlackListIDs = {
    [4024] = true, -- Soul Cage (The Maw and Torghast)
    [4578] = true, -- Gateway to Hero's Rest (Bastion)
    [4583] = true, -- Gateway to Hero's Rest (Bastion)
    [4553] = true, -- Recoverable Corpse (The Maw)
    [4581] = true, -- Grappling Growth (Maldraxxus)
    [4582] = true, -- Ripe Purian (Bastion)
    [4602] = true, -- Aimless Soul (The Maw)
    [4617] = true, -- Imprisoned Soul (The Maw)
    [5020] = true, -- Consol (Zereth Mortis)
    [5485] = true, -- Tuskarr Tacklebox
}

local constBackdropAlertFrame = {
    bgFile = "Interface/AddOns/GW2_UI/textures/hud/toast-bg",
    edgeFile = "",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.BackdropTemplates.AlertFrame = constBackdropAlertFrame

local constBackdropLevelUpAlertFrame = {
    bgFile = "Interface/AddOns/GW2_UI/textures/hud/toast-levelup",
    edgeFile = "",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.BackdropTemplates.LevelUpAlertFrame = constBackdropLevelUpAlertFrame

local function forceAlpha(self, alpha, forced)
    if alpha ~= 1 and forced ~= true then
        self:SetAlpha(1, true)
    end
end
GW.ForceAlpha = forceAlpha

local function AddFlare(frame, flarFrame)
    if not flarFrame then return end

    if not frame.flareIcon then
        frame.flareIcon = flarFrame
    end

    if not flarFrame.flare then
        flarFrame.flare = flarFrame:CreateTexture(nil, "BACKGROUND")
        flarFrame.flare:SetTexture("Interface/AddOns/GW2_UI/textures/hud/level-up-flare")
        flarFrame.flare:SetPoint("CENTER")
        flarFrame.flare:SetSize(120, 120)
        flarFrame.flare:Show()
    end
    if not flarFrame.flare2 then
        flarFrame.flare2 = flarFrame:CreateTexture(nil, "BACKGROUND")
        flarFrame.flare2:SetTexture("Interface/AddOns/GW2_UI/textures/hud/level-up-flare")
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
GW.AddFlareAnimationToObject = AddFlare

local function skinAchievementAlert(frame)
    frame:SetAlpha(1)

    if not frame.hooked then
        hooksecurefunc(frame, "SetAlpha", forceAlpha)
        frame.hooked = true
    end

    if not frame.backdrop then
        frame:GwCreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame.Background, "TOPLEFT", -10, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame.Background, "BOTTOMRIGHT", 5, 0)
    end

    -- Background
    frame.Background:SetTexture()
    if frame.OldAchievement then frame.OldAchievement:GwKill() end
    frame.glow:GwKill()
    frame.shine:GwKill()
    frame.GuildBanner:GwKill()
    frame.GuildBorder:GwKill()
    -- Text
    frame.Unlocked:SetTextColor(1, 1, 1)

    -- Icon
    frame.Icon.Texture:SetSize(45, 45)
    frame.Icon.Texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.Icon.Overlay:GwKill()

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
        frame:GwCreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -35, 15)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 27, -10)
    end

    frame.Unlocked:SetTextColor(1, 1, 1)
    frame.Name:SetTextColor(1, 1, 0)
    frame.Name:SetFont(UNIT_NAME_FONT, 12)
    frame.Unlocked:SetFont(UNIT_NAME_FONT, 14)
    frame.Background:GwKill()
    frame.glow:GwKill()
    frame.shine:GwKill()
    frame.Icon.Bling:GwKill()
    frame.Icon.Overlay:GwKill()

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
        frame:GwCreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -10, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

        frame.shine:GwKill()
        frame.ToastBackground:GwKill()
        -- Background
        if frame.GetNumRegions then
            for i = 1, frame:GetNumRegions() do
                local region = select(i, frame:GetRegions())
                if region:IsObjectType("Texture") then
                    if region:GetTexture() == "Interface\\LFGFrame\\UI-LFG-DUNGEONTOAST" then
                        region:GwKill()
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
        frame:GwCreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -35, 15)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 27, -10)
    end

    if frame.shine then frame.shine:GwKill() end
    if frame.glowFrame then
        frame.glowFrame:GwKill()
        if frame.glowFrame.glow then
            frame.glowFrame.glow:GwKill()
        end
    end

    if frame.raidArt then frame.raidArt:GwKill() end
    if frame.dungeonArt then frame.dungeonArt:GwKill() end
    if frame.dungeonArt1 then frame.dungeonArt1:GwKill() end
    if frame.dungeonArt2 then frame.dungeonArt2:GwKill() end
    if frame.dungeonArt3 then frame.dungeonArt3:GwKill() end
    if frame.dungeonArt4 then frame.dungeonArt4:GwKill() end
    if frame.heroicIcon then frame.heroicIcon:GwKill() end

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
        frame:GwCreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -25, 5)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 20, 0)
    end

    -- Background
    local region = select(2, frame:GetRegions())
    if region:IsObjectType("Texture") then
        if region:GetTexture() == "Interface\\GuildFrame\\GuildChallenges" then
            region:GwKill()
        end
    end
    frame.glow:GwKill()
    frame.shine:GwKill()
    frame.EmblemBorder:GwKill()

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

    frame.Background:GwKill()
    frame.IconBorder:GwKill()
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
        frame:GwCreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame.Icon.b, "TOPLEFT", -25, 15)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame.Icon.b, "BOTTOMRIGHT", 227, -15)
    end

    --flare
    AddFlare(frame, frame.Icon.b)
end

local function skinLegendaryItemAlert(frame, itemLink)
    if not frame.isSkinned then
        frame.Background:GwKill()
        frame.Background2:GwKill()
        frame.Background3:GwKill()
        frame.Ring1:GwKill()
        frame.Particles1:GwKill()
        frame.Particles2:GwKill()
        frame.Particles3:GwKill()
        frame.Starglow:GwKill()
        frame.glow:GwKill()
        frame.shine:GwKill()

        --Icon
        frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        frame.Icon:SetDrawLayer("ARTWORK")
        frame.Icon.b = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        frame.Icon.b:SetAllPoints(frame.Icon)
        frame.Icon:SetParent(frame.Icon.b)
        frame.Icon.iconBorder = frame.Icon.b:CreateTexture(nil, "ARTWORK")
        frame.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        frame.Icon.iconBorder:SetAllPoints(frame.Icon.b)
        --Create Backdrop
        frame:GwCreateBackdrop(constBackdropAlertFrame)
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
    frame.Background:GwKill()

    local lootItem = frame.lootItem or frame
    lootItem.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    lootItem.Icon:SetDrawLayer("BORDER")
    lootItem.IconBorder:GwKill()
    lootItem.SpecRing:SetTexture("")

    frame.glow:GwKill()
    frame.shine:GwKill()
    frame.BGAtlas:GwKill()
    frame.PvPBackground:GwKill()

    -- Icon border
    if not lootItem.Icon.b then
        lootItem.Icon.b = CreateFrame("Frame", nil, frame)
        lootItem.Icon.b:SetAllPoints(lootItem.Icon)
        lootItem.Icon:SetParent(lootItem.Icon.b)
    end

    if not frame.backdrop then
        frame:GwCreateBackdrop(constBackdropAlertFrame)
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

    frame.Background:GwKill()
    frame.BorderGlow:GwKill()
    frame.Sheen:GwKill()

    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.Icon:SetDrawLayer("BORDER", 5)

    -- Icon border
    if not frame.Icon.b then
        frame.Icon.b = CreateFrame("Frame", nil, frame)
        frame.Icon.b:SetAllPoints(frame.Icon)
        frame.Icon:SetParent(frame.Icon.b)
    end

    if not frame.backdrop then
        frame:GwCreateBackdrop(constBackdropAlertFrame)
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

    frame.Background:GwKill()
    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.IconBorder:GwKill()

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
        frame:GwCreateBackdrop(constBackdropAlertFrame)
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
        frame:GwCreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, 5)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 10, 10)
    end

    -- Background
    frame.Background:GwKill()
    frame.glow:GwKill()
    frame.shine:GwKill()

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
        frame:GwCreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, 5)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 10, 10)
    end

    -- Background
    frame.StandardBackground:GwKill()
    frame.glow:GwKill()
    frame.shine:GwKill()

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
        frame:GwCreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, 0)
    end

    frame.glow:GwKill()
    frame.shine:GwKill()
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
        frame:GwCreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, 5)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 10)
    end

    frame.glow:GwKill()
    frame.shine:GwKill()
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

    frame.Background:GwKill()
    frame.IconBorder:GwKill()

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
        frame:GwCreateBackdrop(constBackdropAlertFrame)
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

        frame:GwCreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

        --Background contains the item border too, so have to remove it
        if frame.GetRegions then
            local region, icon = frame:GetRegions()
            if region and region:IsObjectType("Texture") then
                if region:GetAtlas() == "legioninvasion-Toast-Frame" then
                    region:GwKill()
                end
            end
            -- Icon border
            if icon and icon:IsObjectType('Texture') then
                if icon:GetTexture() == 236293 then
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
        frame:GwCreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -15, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    end

    -- Background
    for i = 1, frame:GetNumRegions() do
        local region = select(i, frame:GetRegions())
        if region:IsObjectType('Texture') then
            if region:GetAtlas() == "Toast-IconBG" or region:GetAtlas() == "Toast-Frame" then
                region:GwKill()
            end
        end
    end

    frame.shine:GwKill()
    frame.glowFrame:GwKill()
    frame.glowFrame.glow:GwKill()

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
        frame.glow:GwKill()
        frame.shine:GwKill()
        frame.FollowerBG:SetAlpha(0)
        frame.DieIcon:SetAlpha(0)
        --Background
        if frame.GetNumRegions then
            for i = 1, frame:GetNumRegions() do
                local region = select(i, frame:GetRegions())
                if region:IsObjectType('Texture') then
                    if region:GetAtlas() == "Garr_MissionToast" then
                        region:GwKill()
                    end
                end
            end
        end
        --Create Backdrop
        frame:GwCreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 10)

        frame.PortraitFrame.PortraitRing:Hide()
        frame.PortraitFrame.PortraitRingQuality:SetTexture()
        frame.PortraitFrame.LevelBorder:SetAlpha(0)

        local level = frame.PortraitFrame.Level
        level:ClearAllPoints()
        level:SetPoint("BOTTOM", frame.PortraitFrame, 0, 12)

        local squareBG = CreateFrame("Frame", nil, frame.PortraitFrame, "BackdropTemplate")
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
        frame.glow:GwKill()
        frame.shine:GwKill()

        frame.FollowerBG:SetAlpha(0)
        frame.DieIcon:SetAlpha(0)
        --Background
        frame.Background:GwKill()
        --Create Backdrop
        frame:GwCreateBackdrop(constBackdropAlertFrame)
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
        frame.glow:GwKill()
        frame.shine:GwKill()
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
        frame:GwCreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

        --flare
        AddFlare(frame, frame.Icon.b)

        frame.isSkinned = true
    end
end

local function skinGarrisonBuildingAlert(frame)
    if not frame.isSkinned then
        frame.glow:GwKill()
        frame.shine:GwKill()
        frame:GetRegions():Hide()
        --Create Backdrop
        frame:GwCreateBackdrop(constBackdropAlertFrame)
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
        frame.glow:GwKill()
        frame.shine:GwKill()
        frame.IconBG:GwKill()
        frame.Background:GwKill()
        if frame.EncounterIcon.EliteOveraly then frame.EncounterIcon.EliteOveraly:GwKill() end

        --Create Backdrop
        frame:GwCreateBackdrop(constBackdropAlertFrame)
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
        frame.glow:GwKill()
        frame.shine:GwKill()
        frame.Background:GwKill()

        --Create Backdrop
        frame:GwCreateBackdrop(constBackdropAlertFrame)
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
        frame.glow:GwKill()
        frame.shine:GwKill()
        frame.Background:GwKill()
        frame.Blank:GwKill()
        frame.IconBG:GwKill()

        --Create Backdrop
        frame:GwCreateBackdrop(constBackdropAlertFrame)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

        --Icon
        frame.MissionType:ClearAllPoints()
        frame.MissionType:SetPoint("LEFT", frame.backdrop, 30, 0)
        frame.MissionType:SetSize(45, 45)
        frame.MissionType:SetDrawLayer("ARTWORK")
        frame.MissionType:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        frame.MissionType.b = CreateFrame("Frame", nil, frame, "BackdropTemplate")
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
    local frame = BonusRollMoneyWonFrame
    frame:SetAlpha(1)
    hooksecurefunc(frame, "SetAlpha", forceAlpha)

    frame.Background:GwKill()
    frame.IconBorder:GwKill()

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
    frame:GwCreateBackdrop(constBackdropAlertFrame)
    frame.backdrop:SetPoint("TOPLEFT", frame.Icon.b, "TOPLEFT", -25, 15)
    frame.backdrop:SetPoint("BOTTOMRIGHT", frame.Icon.b, "BOTTOMRIGHT", 227, -15)

    --flare
    AddFlare(frame, frame.Icon.b)
end

local function skinBonusRollLoot()
    local frame = BonusRollLootWonFrame
    frame:SetAlpha(1)
    hooksecurefunc(frame, "SetAlpha", forceAlpha)

    frame.Background:GwKill()
    frame.glow:GwKill()
    frame.shine:GwKill()

    local lootItem = frame.lootItem or frame
    lootItem.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    lootItem.IconBorder:GwKill()

    -- Icon border
    lootItem.Icon.b = CreateFrame("Frame", nil, frame)
    lootItem.Icon.b:SetPoint("TOPLEFT", lootItem.Icon, "TOPLEFT", -2, 2)
    lootItem.Icon.b:SetPoint("BOTTOMRIGHT", lootItem.Icon, "BOTTOMRIGHT", 2, -2)
    lootItem.Icon:SetParent(lootItem.Icon.b)
    lootItem.Icon.iconBorder = lootItem.Icon.b:CreateTexture(nil, "ARTWORK")
    lootItem.Icon.iconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    lootItem.Icon.iconBorder:SetAllPoints(lootItem.Icon.b)

    --Create Backdrop
    frame:GwCreateBackdrop(constBackdropAlertFrame)
    frame.backdrop:SetPoint("TOPLEFT", lootItem.Icon.b, "TOPLEFT", -25, 15)
    frame.backdrop:SetPoint("BOTTOMRIGHT", lootItem.Icon.b, "BOTTOMRIGHT", 227, -15)

    --flare
    AddFlare(frame, lootItem.Icon.b)
end

local function GW2_UIAlertFrame_OnClick(self, ...)
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

local function GW2_UIAlertFrame_SetUp(frame, name, delay, toptext, onClick, icon, levelup, spellID, targetName)
    -- An alert flagged as alreadyEarned has more space for the text to display since there's no shield+points icon.
    AchievementAlertFrame_SetUp(frame, 5208, true)
    frame:HookScript("OnClick", GW2_UIAlertFrame_OnClick)
    frame.Name:SetFormattedText(name)
    frame.Name:SetFont(UNIT_NAME_FONT, 12)
    frame.Unlocked:SetFormattedText(toptext or "")
    frame.Unlocked:SetFont(UNIT_NAME_FONT, 14)
    frame.onClick = onClick
    frame.delay = delay
    frame.spellID = spellID
    frame.levelup = levelup
    frame:RegisterForClicks("AnyUp", "AnyDown")

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
        frame:GwCreateBackdrop()
        frame.backdrop:SetPoint("TOPLEFT", frame.Background, "TOPLEFT", -10, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame.Background, "BOTTOMRIGHT", 5, 0)
    end
    frame.backdrop:SetBackdrop(levelup and constBackdropLevelUpAlertFrame or constBackdropAlertFrame)

    if delay == -1 then
        frame:SetScript("OnLeave", nil)
    else
        frame:SetScript("OnLeave", AlertFrame_ResumeOutAnimation)
    end

    -- target by name
    if not InCombatLockdown() and targetName then
        frame:SetAttribute("type", "macro")
        frame:SetAttribute("macrotext", "/target " .. targetName)
    end

    -- Background
    frame.Background:SetTexture()
    if frame.OldAchievement then frame.OldAchievement:GwKill() end
    frame.glow:GwKill()
    frame.shine:GwKill()
    frame.GuildBanner:GwKill()
    frame.GuildBorder:GwKill()

    -- Text
    frame.Unlocked:SetTextColor(1, 1, 1)

    -- Icon
    frame.Icon.Texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.Icon.Overlay:GwKill()

    frame.Icon.Texture:ClearAllPoints()
    frame.Icon.Texture:SetPoint("LEFT", frame, 7, 0)

    if icon and C_Texture.GetAtlasInfo(icon) then
        frame.Icon.Texture:SetAtlas(icon)
    else
        frame.Icon.Texture:SetTexture(icon)
    end

    frame.Icon.Texture.b = CreateFrame("Frame", nil, frame)
    frame.Icon.Texture.b:SetAllPoints(frame.Icon.Texture)
    frame.Icon.Texture:SetParent(frame.Icon.Texture.b)

    --flare
    if not frame.flareIcon then
        AddFlare(frame, frame.Icon.Texture.b)
    end
end

local function GetGuildInvites()
    local numGuildInvites = 0
    local date = C_DateAndTime.GetCurrentCalendarTime()
    for index = 1, C_Calendar.GetNumGuildEvents() do
        local info = C_Calendar.GetGuildEventInfo(index)
        local monthOffset = info.month - date.month
        local numDayEvents = C_Calendar.GetNumDayEvents(monthOffset, info.monthDay)

        for i = 1, numDayEvents do
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
    if not CalendarFrame then LoadAddOn("Blizzard_Calendar") end
    ShowUIPanel(CalendarFrame)
end

local function alertEvents()
    if CalendarFrame and CalendarFrame:IsShown() then return false end
    local showAlert = false
    local num = C_Calendar.GetNumPendingInvites()
    if num ~= numInvites then
        if num > 0 then
            GW2_UIAlertSystem.AlertSystem:AddAlert(GW.L["You have %s pending calendar invite(s)."]:format(num), nil, CALENDAR_STATUS_INVITED, toggleCalendar, "Interface/AddOns/GW2_UI/textures/icons/clock", false)
            showAlert = true
        end
        numInvites = num
    end

    return showAlert
end

local function alertGuildEvents()
    if CalendarFrame and CalendarFrame:IsShown() then return false end
    local showAlert = false
    local num = GetGuildInvites()
    if num > 0 then
        -- /run GW2_UIAlertSystem.AlertSystem:AddAlert("tt", nil, CALENDAR_STATUS_INVITED, function() if not CalendarFrame then LoadAddOn("Blizzard_Calendar") end ShowUIPanel(CalendarFrame) end , "Interface/AddOns/GW2_UI/textures/icons/clock", false)
        GW2_UIAlertSystem.AlertSystem:AddAlert(GW.L["You have %s pending guild event(s)."]:format(num), nil, CALENDAR_STATUS_INVITED, toggleCalendar, "Interface/AddOns/GW2_UI/textures/icons/clock", false)
        showAlert = true
    end

    return showAlert
end

local settings = {}

local function UpdateSettings()
    settings.showLevelUp = GetSetting("ALERTFRAME_NOTIFICATION_LEVEL_UP")
    settings.levelUpSound = GetSetting("ALERTFRAME_NOTIFICATION_LEVEL_UP_SOUND")
    settings.showNewSpell = GetSetting("ALERTFRAME_NOTIFICATION_NEW_SPELL")
    settings.newSpellSound = GetSetting("ALERTFRAME_NOTIFICATION_NEW_SPELL_SOUND")
    settings.showNewMail = GetSetting("ALERTFRAME_NOTIFICATION_NEW_MAIL")
    settings.newMailSound = GetSetting("ALERTFRAME_NOTIFICATION_NEW_MAIL_SOUND")
    settings.showRepair = GetSetting("ALERTFRAME_NOTIFICATION_REPAIR")
    settings.repairSound = GetSetting("ALERTFRAME_NOTIFICATION_REPAIR_SOUND")
    settings.showParagon = GetSetting("ALERTFRAME_NOTIFICATION_PARAGON")
    settings.paragonSound = GetSetting("ALERTFRAME_NOTIFICATION_PARAGON_SOUND")
    settings.showRare = GetSetting("ALERTFRAME_NOTIFICATION_RARE")
    settings.rareSound = GetSetting("ALERTFRAME_NOTIFICATION_RARE_SOUND")
    settings.showCalenderInvite = GetSetting("ALERTFRAME_NOTIFICATION_CALENDAR_INVITE")
    settings.calenderInviteSound = GetSetting("ALERTFRAME_NOTIFICATION_CALENDAR_INVITE_SOUND")
    settings.showCallToArms = GetSetting("ALERTFRAME_NOTIFICATION_CALL_TO_ARMS")
    settings.callToArmsSound = GetSetting("ALERTFRAME_NOTIFICATION_CALL_TO_ARMS_SOUND")
    settings.showMageTable = GetSetting("ALERTFRAME_NOTIFICATION_MAGE_TABLE")
    settings.mageTableSound = GetSetting("ALERTFRAME_NOTIFICATION_MAGE_TABLE_SOUND")
    settings.showRitualOfSummoning = GetSetting("ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING")
    settings.ritualOfSummoningSound = GetSetting("ALERTFRAME_NOTIFICATION_RITUAL_OF_SUMMONING_SOUND")
    settings.showSpoulwell = GetSetting("ALERTFRAME_NOTIFICATION_SPOULWELL")
    settings.spoulwellSound = GetSetting("ALERTFRAME_NOTIFICATION_SPOULWELL_SOUND")
    settings.showMagePortal = GetSetting("ALERTFRAME_NOTIFICATION_MAGE_PORTAL")
    settings.magePortalSound = GetSetting("ALERTFRAME_NOTIFICATION_MAGE_PORTAL_SOUND")
end
GW.UpdateAlertSettings = UpdateSettings

local function AlertContainerFrameOnEvent(self, event, ...)
    if event == "PLAYER_LEVEL_UP" and settings.showLevelUp then
        local level, _, _, talentPoints, numNewPvpTalentSlots = ...
        GW2_UIAlertSystem.AlertSystem:AddAlert(LEVEL_UP_YOU_REACHED .. " " .. LEVEL .. " " .. level, nil, PLAYER_LEVEL_UP, false, "Interface/AddOns/GW2_UI/textures/icons/icon-levelup", true)
        -- /run GW2_UIAlertSystem.AlertSystem:AddAlert(LEVEL_UP_YOU_REACHED .. " " .. LEVEL .. " 120", nil, PLAYER_LEVEL_UP, false, "Interface/AddOns/GW2_UI/textures/icons/icon-levelup", true)

        if talentPoints and talentPoints > 0 then
            GW2_UIAlertSystem.AlertSystem:AddAlert(LEVEL_UP_TALENT_MAIN, nil, LEVEL_UP_TALENT_SUB, false, "Interface/AddOns/GW2_UI/textures/icons/talent-icon", false)
            --/run GW2_UIAlertSystem.AlertSystem:AddAlert(LEVEL_UP_TALENT_MAIN, nil, LEVEL_UP_TALENT_SUB, false, "Interface/AddOns/GW2_UI/textures/icons/talent-icon", false)
        end
        if C_SpecializationInfo.CanPlayerUsePVPTalentUI() and numNewPvpTalentSlots and numNewPvpTalentSlots > 0 then
            GW2_UIAlertSystem.AlertSystem:AddAlert(LEVEL_UP_PVP_TALENT_MAIN, nil, BONUS_TALENTS, false, "Interface/AddOns/GW2_UI/textures/icons/talent-icon", false)
            --/run GW2_UIAlertSystem.AlertSystem:AddAlert(LEVEL_UP_PVP_TALENT_MAIN, nil, BONUS_TALENTS, false, "Interface/AddOns/GW2_UI/textures/icons/talent-icon", false)
        end

        -- if we learn a spell here we should show the new spell so we remove the event from the toastQueue list
        for _, v in pairs(toastQueue) do
            if v ~= nil and v.event == "LEARNED_SPELL_IN_TAB" then
                v.event = ""
            end
        end
        PlaySoundFile(GW.Libs.LSM:Fetch("sound", settings.levelUpSound), "Master")
    elseif event == "LEARNED_SPELL_IN_TAB" and settings.showNewSpell then
        local spellID = ...
        if ignoreDragonRidingSpells[spellID] then return end
        local name, _, icon = GetSpellInfo(spellID)
        toastQueue[#toastQueue + 1] = {name = name, spellID = spellID, icon = icon, event = event}
        C_Timer.After(1.5, function()
            for _, v in pairs(toastQueue) do
                if v ~= nil then
                    GW2_UIAlertSystem.AlertSystem:AddAlert(SPELL_BUCKET_ABILITIES_UNLOCKED, nil, v.name, false, v.icon, false, v.spellID)
                end
            end
            wipe(toastQueue)
            PlaySoundFile(GW.Libs.LSM:Fetch("sound",settings.newSpellSound), "Master")
        end)
        -- /run GW2_UIAlertSystem.AlertSystem:AddAlert(GetSpellInfo(48181), nil, LEVEL_UP_ABILITY, false, select(3, GetSpellInfo(48181)), false, 48181)
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" and settings.showNewSpell then
        C_Timer.After(0.5, function()
            for k, v in pairs(toastQueue) do
                if v ~= nil and v.event == "LEARNED_SPELL_IN_TAB" then
                    toastQueue[k] = nil
                end
            end
        end)
    elseif event == "UPDATE_PENDING_MAIL" and settings.showNewMail then
        if InCombatLockdown() then return end
        local newMail = HasNewMail()
        if hasMail ~= newMail then
            hasMail = newMail

            if hasMail then
                -- /run GW2_UIAlertSystem.AlertSystem:AddAlert(HAVE_MAIL, nil, MAIL_LABEL, false, "Interface/AddOns/GW2_UI/textures/icons/mail-window-icon", false)
                GW2_UIAlertSystem.AlertSystem:AddAlert(HAVE_MAIL, nil, MAIL_LABEL, false, "Interface/AddOns/GW2_UI/textures/icons/mail-window-icon", false)
                PlaySoundFile(GW.Libs.LSM:Fetch("sound", settings.newMailSound), "Master")
            end
        end
    elseif event == "UPDATE_INVENTORY_DURABILITY" and settings.showRepair then
        local current, max

        for i = 1, 11 do
            if GetInventoryItemLink("player", slots[i][1]) then
                current, max = GetInventoryItemDurability(slots[i][1])
                if current then
                    slots[i][3] = current / max
                end
            end
        end
        table.sort(slots, function(a, b) return a[3] < b[3] end)

        local value = floor(slots[1][3] * 100)
        if showRepair and value < 20 then
            showRepair = false
            C_Timer.After(30, function() showRepair = true end)
            -- /run GW2_UIAlertSystem.AlertSystem:AddAlert(format("%s slot needs to repair, current durability is %d.", INVTYPE_HEAD, 20), nil, MINIMAP_TRACKING_REPAIR, false, "Interface/AddOns/GW2_UI/textures/icons/repair", false)
            GW2_UIAlertSystem.AlertSystem:AddAlert(format(GW.L["%s slot needs to repair, current durability is %d."], slots[1][2], value), nil, MINIMAP_TRACKING_REPAIR, false, "Interface/AddOns/GW2_UI/textures/icons/repair", false)
            PlaySoundFile(GW.Libs.LSM:Fetch("sound", settings.repairSound), "Master")
        end
    elseif event == "QUEST_ACCEPTED" and settings.showParagon then
        local questId = ...
        if PARAGON_QUEST_ID[questId] then
            local text = GW.RGBToHex(0.22, 0.37, 0.98) .. (GetFactionInfoByID(PARAGON_QUEST_ID[questId][1]) or UNKNOWN) .. "|r"
            local name = GetQuestLogCompletionText(C_QuestLog.GetLogIndexForQuestID(questId))
            -- /run GW2_UIAlertSystem.AlertSystem:AddAlert(format("|cff00c0fa%s|r", GetFactionInfoByID(2407)), nil, format("|cff00c0fa%s|r", "TESTE"), false, "Interface\\Icons\\Achievement_Quests_Completed_08", false)
            GW2_UIAlertSystem.AlertSystem:AddAlert(name, nil, text, false, "Interface\\Icons\\Achievement_Quests_Completed_08", false)
            PlaySoundFile(GW.Libs.LSM:Fetch("sound",settings.paragonSound), "Master")
        end
    elseif event == "VIGNETTE_MINIMAP_UPDATED" and settings.showRare then
        if VignetteExclusionMapIDs[GW.Libs.GW2Lib:GetPlayerLocationMapID()] or IsInGroup() or IsInRaid() or IsPartyLFG() then return end

        local vignetteGUID, onMinimap = ...

        if onMinimap then
            local vignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
            if not vignetteInfo then return end
            if VignetteBlackListIDs[vignetteInfo.vignetteID] then return end

            if vignetteGUID ~= self.lastMinimapRare.id then
                GW.Debug("Minimap vignette with id", vignetteInfo.vignetteID, "and name", vignetteInfo.name, "appeared on the minimap.")
                vignetteInfo.nameColored = format("|cff00c0fa%s|r", vignetteInfo.name)
                GW2_UIAlertSystem.AlertSystem:AddAlert(GW.L["has appeared on the Minimap!"], nil, vignetteInfo.nameColored, false, vignetteInfo.atlasName, false, nil, vignetteInfo.name)
                self.lastMinimapRare.id = vignetteGUID

                local time = GetTime()
                if time > (self.lastMinimapRare.time + 20) then
                    PlaySoundFile(GW.Libs.LSM:Fetch("sound", settings.rareSound), "Master")
                    self.lastMinimapRare.time = time
                end
            end
        end
    elseif event == "CALENDAR_UPDATE_PENDING_INVITES" and settings.showCalenderInvite then
        if alertEvents() or alertGuildEvents() then
            PlaySoundFile(GW.Libs.LSM:Fetch("sound", settings.calenderInviteSound), "Master")
        end
    elseif event == "CALENDAR_UPDATE_GUILD_EVENTS" and settings.showCalenderInvite then
        if alertGuildEvents() then
            PlaySoundFile(GW.Libs.LSM:Fetch("sound", settings.calenderInviteSound), "Master")
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- collect open invites
        C_Timer.After(7, function() AlertContainerFrameOnEvent(self, "CALENDAR_UPDATE_PENDING_INVITES") end)
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    elseif event == "LFG_UPDATE_RANDOM_INFO" and settings.showCallToArms then
        local _, forTank, forHealer, forDamage = GetLFGRoleShortageRewards(2087, LFG_ROLE_SHORTAGE_RARE) -- 2087 Random Shadowlands Heroic
        local IsTank, IsHealer, IsDamage = C_LFGList.GetAvailableRoles()

        local ingroup = IsInGroup(LE_PARTY_CATEGORY) or IsInGroup(LE_PARTY_CATEGORY_INSTANCE)

        local tank = IsTank and forTank and "|cff00B2EE" .. TANK .. "|r" or ""
        local healer = IsHealer and forHealer and "|cff00EE00" .. HEALER .. "|r" or ""
        local damager = IsDamage and forDamage and "|cffd62c35" .. DAMAGER .. "|r" or ""

        if ((IsTank and forTank) or (IsHealer and forHealer) or (IsDamage and forDamage)) and not ingroup then
            if GetTime() - LFG_Timer > 20 then
                PlaySoundFile(GW.Libs.LSM:Fetch("sound", settings.callToArmsSound), "Master")
                -- /run GW2_UIAlertSystem.AlertSystem:AddAlert(format(LFG_CALL_TO_ARMS, "|cff00B2EE" .. TANK .. "|r"), nil, BATTLEGROUND_HOLIDAY, false, "Interface/AddOns/GW2_UI/textures/icons/garrison-up", false)
                GW2_UIAlertSystem.AlertSystem:AddAlert(format(LFG_CALL_TO_ARMS, tank .. " " .. healer .. " " .. damager), nil, BATTLEGROUND_HOLIDAY, false, "Interface/AddOns/GW2_UI/textures/icons/garrison-up", false)
                LFG_Timer = GetTime()
            end
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and (IsInRaid() or IsInGroup()) then
        local _, subEvent, _, _, srcName, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if not subEvent or not spellID or not srcName then return end

        local groupStatus = GW.IsGroupMember(srcName)
        if not groupStatus or groupStatus == 3 then
            return
        end

        if subEvent == "SPELL_CAST_SUCCESS" then
            if settings.showMageTable and spellID == 190336 then -- Refreshment Table
                local name, _, icon = GetSpellInfo(190336)
                -- /run GW2_UIAlertSystem.AlertSystem:AddAlert(format("%s created a table of Conjured Refreshments.", "Hansi"), nil, GetSpellInfo(190336), false, select(3, GetSpellInfo(190336)), false)
                GW2_UIAlertSystem.AlertSystem:AddAlert(format(GW.L["%s created a table of Conjured Refreshments."], srcName), nil, name, false, icon, false)
                PlaySoundFile(GW.Libs.LSM:Fetch("sound", settings.mageTableSound), "Master")
            end
        elseif subEvent == "SPELL_CREATE" then
            if settings.showRitualOfSummoning and spellID == 698 then -- Ritual of Summoning
                local name, _, icon = GetSpellInfo(698)
                -- /run GW2_UIAlertSystem.AlertSystem:AddAlert(format("%s is performing a Ritual of Summoning.", "Hansi"), nil, GetSpellInfo(698), false, select(3, GetSpellInfo(698)), false)
                GW2_UIAlertSystem.AlertSystem:AddAlert(format(GW.L["%s is performing a Ritual of Summoning."], srcName), nil, name, false, icon, false)
                PlaySoundFile(GW.Libs.LSM:Fetch("sound", settings.ritualOfSummoningSound), "Master")
            elseif settings.showSpoulwell and spellID == 29893 then -- Soul Well
                local name, _, icon = GetSpellInfo(29893)
                -- /run GW2_UIAlertSystem.AlertSystem:AddAlert(format("%s created a Soulwell.", "Hansi"), nil, GetSpellInfo(29893), false, select(3, GetSpellInfo(29893)), false)
                GW2_UIAlertSystem.AlertSystem:AddAlert(format(GW.L["%s created a Soulwell."], srcName), nil, name, false, icon, false)
                PlaySoundFile(GW.Libs.LSM:Fetch("sound", settings.spoulwellSound), "Master")
            elseif settings.showMagePortal and GW.MagePortals[spellID] then
                local name, _, icon = GetSpellInfo(spellID)
                -- /run GW2_UIAlertSystem.AlertSystem:AddAlert(format("%s placed a portal to %s.", "Hansi", GetSpellInfo(224871):gsub("^.+:%s+", "")), nil, GetSpellInfo(224871), false, select(3, GetSpellInfo(224871)), false)
                GW2_UIAlertSystem.AlertSystem:AddAlert(format(GW.L["%s placed a portal to %s."], srcName, name:gsub("^.+:%s+", "")), nil, name, false, icon, false)
                PlaySoundFile(GW.Libs.LSM:Fetch("sound", settings.magePortalSound), "Master")
            end
        end
    end
end

local function LoadAlertSystem()
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end

    UpdateSettings()

    if GetSetting("ALERTFRAME_SKIN_ENABLED") then
        -- Achievements
        hooksecurefunc(AchievementAlertSystem, "setUpFunction", skinAchievementAlert)
        hooksecurefunc(CriteriaAlertSystem, "setUpFunction", skinCriteriaAlert)
        hooksecurefunc(MonthlyActivityAlertSystem, "setUpFunction", skinCriteriaAlert)

        -- Encounters
        hooksecurefunc(DungeonCompletionAlertSystem, "setUpFunction", skinDungeonCompletionAlert)
        hooksecurefunc(WorldQuestCompleteAlertSystem, "setUpFunction", skinWorldQuestCompleteAlert)
        hooksecurefunc(GuildChallengeAlertSystem, "setUpFunction", skinGuildChallengeAlert)
        hooksecurefunc(InvasionAlertSystem, "setUpFunction", skinInvasionAlert)
        hooksecurefunc(ScenarioAlertSystem, "setUpFunction", skinScenarioAlert)

        -- Loot
        hooksecurefunc(LegendaryItemAlertSystem, "setUpFunction", skinLegendaryItemAlert)
        hooksecurefunc(LootAlertSystem, "setUpFunction", skinLootWonAlert)
        hooksecurefunc(LootUpgradeAlertSystem, "setUpFunction", skinLootUpgradeAlert)
        hooksecurefunc(MoneyWonAlertSystem, "setUpFunction", skinMoneyWonAlert)
        hooksecurefunc(EntitlementDeliveredAlertSystem, "setUpFunction", skinEntitlementDeliveredAlert)
        hooksecurefunc(RafRewardDeliveredAlertSystem, "setUpFunction", skinRafRewardDeliveredAlert)

        -- Professions
        hooksecurefunc(DigsiteCompleteAlertSystem, "setUpFunction", skinDigsiteCompleteAlert)
        hooksecurefunc(NewRecipeLearnedAlertSystem, "setUpFunction", skinNewRecipeLearnedAlert)

        -- Honor
        hooksecurefunc(HonorAwardedAlertSystem, "setUpFunction", skinHonorAwardedAlert)

        -- Pets/Mounts
        hooksecurefunc(NewPetAlertSystem, "setUpFunction", skinNewPetAlert)
        hooksecurefunc(NewMountAlertSystem, "setUpFunction", skinNewPetAlert)
        hooksecurefunc(NewToyAlertSystem, "setUpFunction", skinNewPetAlert)

        -- Cosmetics
        hooksecurefunc(NewCosmeticAlertFrameSystem, "setUpFunction", skinNewPetAlert)

        -- Garrisons
        hooksecurefunc(GarrisonFollowerAlertSystem, "setUpFunction", skinGarrisonFollowerAlert)
        hooksecurefunc(GarrisonShipFollowerAlertSystem, "setUpFunction", skinGarrisonShipFollowerAlert)
        hooksecurefunc(GarrisonTalentAlertSystem, "setUpFunction", skinGarrisonTalentAlert)
        hooksecurefunc(GarrisonBuildingAlertSystem, "setUpFunction", skinGarrisonBuildingAlert)
        hooksecurefunc(GarrisonMissionAlertSystem, "setUpFunction", skinGarrisonMissionAlert)
        hooksecurefunc(GarrisonShipMissionAlertSystem, "setUpFunction", skinGarrisonShipMissionAlert)
        hooksecurefunc(GarrisonRandomMissionAlertSystem, "setUpFunction", skinGarrisonRandomMissionAlert)

        --Bonus Roll Money
        skinBonusRollMoney()

        --Bonus Roll Loot
        skinBonusRollLoot()
    end

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
            if self.timer then
                self.timer:Cancel()
                self.timer = nil
            end
            self.timer = C_Timer.NewTicker(self.duration or 4, function()
                if not self:IsShown() then
                    self.flareIcon.animationGroup1:Stop()
                    self.flareIcon.animationGroup2:Stop()
                    self.timer:Cancel()
                end
            end)
        end
    end)

    if GetSetting("ALERTFRAME_ENABLED") then
        GW.AlertContainerFrame = CreateFrame("Frame", nil, UIParent)
        GW.AlertContainerFrame:SetSize(300, 5) -- 265

        local point = GetSetting("AlertPos")
        GW.AlertContainerFrame:ClearAllPoints()
        GW.AlertContainerFrame:SetPoint(point.point, UIParent, point.relativePoint, point.xOfs, point.yOfs)

        local postDragFunction = function(self)
            local _, y = self.gwMover:GetCenter()
            local screenHeight = UIParent:GetTop()
            if y > (screenHeight / 2) then
                if self.gwMover.frameName and self.gwMover.frameName.SetText then
                    self.gwMover.frameName:SetText(GW.L["Alert Frames"] .. " (" .. COMBAT_TEXT_SCROLL_DOWN .. ")")
                end
            else
                if self.gwMover.frameName and self.gwMover.frameName.SetText then
                    self.gwMover.frameName:SetText(GW.L["Alert Frames"] .. " (" .. COMBAT_TEXT_SCROLL_UP .. ")")
                end
            end
        end

        GW.RegisterMovableFrame(GW.AlertContainerFrame, GW.L["Alert Frames"], "AlertPos", ALL .. ",Blizzard,Widgets", {300, 5}, {"default"}, nil, postDragFunction)

        GW.AlertContainerFrame:RegisterEvent("PLAYER_LEVEL_UP")
        GW.AlertContainerFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")
        GW.AlertContainerFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        GW.AlertContainerFrame:RegisterEvent("UPDATE_PENDING_MAIL")
        GW.AlertContainerFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        GW.AlertContainerFrame:RegisterEvent("QUEST_ACCEPTED")
        GW.AlertContainerFrame:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
        GW.AlertContainerFrame:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
        GW.AlertContainerFrame:RegisterEvent("CALENDAR_UPDATE_GUILD_EVENTS")
        GW.AlertContainerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        GW.AlertContainerFrame:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
        GW.AlertContainerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

        GW.AlertContainerFrame.lastMinimapRare = {time = 0, id = nil}

        GW.AlertContainerFrame:SetScript("OnEvent", AlertContainerFrameOnEvent)
    end
end
GW.LoadAlertSystem = LoadAlertSystem

local function LoadOurAlertSubSystem()
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end

    -- Add customs alert system
    if not GW2_UIAlertSystem.AlertSystem then
        GW2_UIAlertSystem.AlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("GW2_UIAlertFrameTemplate", GW2_UIAlertFrame_SetUp, 4, math.huge)
    end
end
GW.LoadOurAlertSubSystem = LoadOurAlertSubSystem
