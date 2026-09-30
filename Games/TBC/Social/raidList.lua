---@class GW2
local GW = select(2, ...)

local ICON_PATH = "Interface/AddOns/GW2_UI/textures/party/"
local RANK_ICONS = { [2] = "icon-groupleader.png", [1] = "icon-assist.png" }
local ROLE_ICONS = { MAINTANK = "icon-maintank.png", MAINASSIST = "icon-mainassist.png" }

local raidSkinned = false

local function SetIcon(texture, file)
    texture:SetTexture(file and (ICON_PATH .. file) or "")
end

local function UpdateMemberIcons()
    for i = 1, MAX_RAID_GROUPS * MEMBERS_PER_RAID_GROUP do
        local _, rank, _, _, _, _, _, _, _, role = GetRaidRosterInfo(i)
        local prefix = "RaidGroupButton" .. i
        -- secret values can not be used as table keys
        SetIcon(_G[prefix .. "RankTexture"], GW.NotSecretValue(rank) and RANK_ICONS[rank])
        SetIcon(_G[prefix .. "RoleTexture"], GW.NotSecretValue(role) and ROLE_ICONS[role])
    end
end

local function SkinGroup(group, prefix)
    group:SetSize(230, 120)
    group:GwStripTextures()
    local label = _G[prefix .. "Label"]
    label:SetNormalFontObject("GameFontNormal")
    label:SetHighlightFontObject("GameFontHighlight")

    for slotIndex = 1, MEMBERS_PER_RAID_GROUP do
        local slot = _G[prefix .. "Slot" .. slotIndex]
        if slot then
            slot:GwStripTextures()
            slot:SetSize(220, 22)
            slot:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
        end
    end
end

local function SkinMemberButton(button, prefix)
    button:SetSize(220, 22)
    button:GwSkinButton(false, true, true)
    button:GwStripTextures()
    button:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)

    -- the class column is a font string on some clients and a button with text on others
    local class = _G[prefix .. "Class"]
    local columns = { { _G[prefix .. "Name"], 60 }, { _G[prefix .. "Level"], 37 }, { class, 80 } }
    for _, column in ipairs(columns) do
        local text = column[1].SetFont and column[1] or column[1].text
        text:SetFont(UNIT_NAME_FONT, 10)
        column[1]:SetSize(column[2], 19)
    end
end

-- Blizzard_RaidUI loads on demand and its group buttons are protected
local function SkinRaidGroups()
    if raidSkinned then return end
    if InCombatLockdown() then
        GW.CombatQueue:Queue(nil, SkinRaidGroups)
        return
    end
    raidSkinned = true

    for groupIndex = 1, MAX_RAID_GROUPS do
        local prefix = "RaidGroup" .. groupIndex
        if _G[prefix] then
            SkinGroup(_G[prefix], prefix)
        end
    end
    for i = 1, MAX_RAID_GROUPS * MEMBERS_PER_RAID_GROUP do
        SkinMemberButton(_G["RaidGroupButton" .. i], "RaidGroupButton" .. i)
    end

    hooksecurefunc("RaidGroupFrame_Update", UpdateMemberIcons)
end

function GW.SkinRaidList()
    if RaidFrameNotInRaid.ScrollingDescription then
        RaidFrameNotInRaid.ScrollingDescription:ClearAllPoints()
        RaidFrameNotInRaid.ScrollingDescription:SetPoint("TOPLEFT", RaidFrameNotInRaid, "TOPLEFT", 0, -73)
        RaidFrameNotInRaid.ScrollingDescription:SetPoint("BOTTOMRIGHT", RaidFrameNotInRaid, "BOTTOMRIGHT", 0, 0)
        RaidFrameNotInRaid.ScrollingDescription.ScrollBox.FontStringContainer.FontString:SetJustifyH("CENTER")
        RaidFrameNotInRaid.ScrollingDescription.ScrollBox.FontStringContainer.FontString:SetJustifyV("TOP")
        RaidFrameNotInRaid.ScrollingDescription.ScrollBox.FontStringContainer.FontString:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    end

    RaidFrameAllAssistCheckButton:ClearAllPoints()
    RaidFrameAllAssistCheckButton:SetPoint("TOPLEFT", 10, -33)
    RaidFrameAllAssistCheckButton.text:ClearAllPoints()
    RaidFrameAllAssistCheckButton.text:SetPoint("LEFT", RaidFrameAllAssistCheckButton, "RIGHT", 5, -2)
    RaidFrameAllAssistCheckButton.text:SetText(ALL .. " |TInterface/AddOns/GW2_UI/textures/party/icon-assist.png:25:25:0:-3|t")

    if RaidFrame.RoleCount then
        RaidFrame.RoleCount:ClearAllPoints()
        RaidFrame.RoleCount:SetPoint("TOP", -80, -33)

        RaidFrame.RoleCount.TankIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-tank.png")
        RaidFrame.RoleCount.HealerIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-healer.png")
        RaidFrame.RoleCount.DamagerIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-dps.png")
        RaidFrame.RoleCount.DamagerIcon:SetSize(20, 20)
    end

    RaidFrameAllAssistCheckButton:GwSkinCheckButton(false, 18)

    if RaidFrameReadyCheckButton then
        RaidFrameReadyCheckButton:GwSkinButton(false, true)
    end

    RaidFrameConvertToRaidButton:GwSkinButton(false, true)
    RaidFrameRaidInfoButton:GwSkinButton(false, true)
    RaidFrameRaidInfoButton:SetPoint("TOPRIGHT", -7, -33)
    if GW.settings.windows.character.enabled and (GW.Retail or GW.Mists) then
        RaidFrameRaidInfoButton:SetScript("OnClick", function()
            if InCombatLockdown() then return end
            if GwCharacterCurrencyRaidInfoFrame.RaidLocks:IsVisible() then
                GwCharacterWindow:SetAttribute("windowpanelopen", "nil")
                return
            end
            GwCharacterWindow:SetAttribute("windowpanelopen", "currency")
            GWCurrencyMenu.items.raidinfo:Click()
        end)
    end

    hooksecurefunc("RaidFrame_LoadUI", SkinRaidGroups)
end
