local _, GW = ...

local  raidInit = false

local StripAllTextures = {
    "RaidGroup1",
    "RaidGroup2",
    "RaidGroup3",
    "RaidGroup4",
    "RaidGroup5",
    "RaidGroup6",
    "RaidGroup7",
    "RaidGroup8",
}

local function LoadRaidFrame()
    if raidInit then return end
    if InCombatLockdown() then
        GW.CombatQueue_Queue(nil,  LoadRaidFrame)
        return
    end
    raidInit = true
    for _, object in pairs(StripAllTextures) do
        local obj = _G[object]
        if obj then
            obj:SetSize(230, 120)
            obj:GwStripTextures()
            _G[object .. "Label"]:SetNormalFontObject("GameFontNormal")
            _G[object .. "Label"]:SetHighlightFontObject("GameFontHighlight")
            for j = 1, 5 do
                local slot = _G[object .. "Slot" .. j]
                if slot then
                    slot:GwStripTextures()
                    slot:SetSize(220, 22)
                    slot:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
                end
            end
        end
    end

    for i = 1, _G.MAX_RAID_GROUPS * 5 do
        _G["RaidGroupButton" .. i]:SetSize(220, 22)
        _G["RaidGroupButton" .. i]:GwSkinButton(false, true, true)
        _G["RaidGroupButton" .. i]:GwStripTextures()
        _G["RaidGroupButton" .. i]:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
        _G["RaidGroupButton" .. i .. "Name"]:SetFont(UNIT_NAME_FONT, 10)
        _G["RaidGroupButton" .. i .. "Level"]:SetFont(UNIT_NAME_FONT, 10)

        if _G["RaidGroupButton" .. i .. "Class"].SetFont then
            _G["RaidGroupButton" .. i .. "Class"]:SetFont(UNIT_NAME_FONT, 10)
        else
            _G["RaidGroupButton" .. i .. "Class"].text:SetFont(UNIT_NAME_FONT, 10)
        end

        _G["RaidGroupButton" .. i .. "Name"]:SetSize(60, 19)
        _G["RaidGroupButton" .. i .. "Level"]:SetSize(37, 19)
        _G["RaidGroupButton" .. i .. "Class"]:SetSize(80, 19)
    end

    hooksecurefunc("RaidGroupFrame_Update", function()
        for i = 1, MAX_RAID_GROUPS * 5 do
            local _, rank, _, _, _, _, _, _, _, role = GetRaidRosterInfo(i)

            if rank == 2 then
                _G["RaidGroupButton" .. i .. "RankTexture"]:SetTexture("Interface/AddOns/GW2_UI/textures/party/icon-groupleader.png")
            elseif rank == 1 then
                _G["RaidGroupButton" .. i .. "RankTexture"]:SetTexture("Interface/AddOns/GW2_UI/textures/party/icon-assist.png")
            else
                _G["RaidGroupButton" .. i .. "RankTexture"]:SetTexture("")
            end

            if role == "MAINTANK" then
                _G["RaidGroupButton" .. i .. "RoleTexture"]:SetTexture("Interface/AddOns/GW2_UI/textures/party/icon-maintank.png")
            elseif role == "MAINASSIST" then
                _G["RaidGroupButton" .. i .. "RoleTexture"]:SetTexture("Interface/AddOns/GW2_UI/textures/party/icon-mainassist.png")
            else
                _G["RaidGroupButton" .. i .. "RoleTexture"]:SetTexture("")
            end
        end
    end)
end

function GW.SkinRaidList()
    if RaidFrameNotInRaid.ScrollingDescription then
        RaidFrameNotInRaid.ScrollingDescription:ClearAllPoints()
        RaidFrameNotInRaid.ScrollingDescription:SetPoint("TOPLEFT", RaidFrameNotInRaid, "TOPLEFT", 0, -73)
        RaidFrameNotInRaid.ScrollingDescription:SetPoint("BOTTOMRIGHT", RaidFrameNotInRaid, "BOTTOMRIGHT", 0, 0)
        RaidFrameNotInRaid.ScrollingDescription.ScrollBox.FontStringContainer.FontString:SetJustifyH("CENTER")
        RaidFrameNotInRaid.ScrollingDescription.ScrollBox.FontStringContainer.FontString:SetJustifyV("TOP")
        RaidFrameNotInRaid.ScrollingDescription.ScrollBox.FontStringContainer.FontString:SetTextColor(1, 1, 1)
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

    RaidFrameAllAssistCheckButton:GwSkinCheckButton()
    RaidFrameAllAssistCheckButton:SetSize(18, 18)

    if RaidFrameReadyCheckButton then
        RaidFrameReadyCheckButton:GwSkinButton(false, true)
    end

    RaidFrameConvertToRaidButton:GwSkinButton(false, true)
    RaidFrameRaidInfoButton:GwSkinButton(false, true)
    RaidFrameRaidInfoButton:SetPoint("TOPRIGHT", -7, -33)
    if GW.settings.USE_CHARACTER_WINDOW and (GW.Retail or GW.Mists) then
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

    hooksecurefunc("RaidFrame_LoadUI", LoadRaidFrame)
end
