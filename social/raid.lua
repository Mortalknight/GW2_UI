local _, GW = ...
local GetSetting = GW.GetSetting

local function RaidGroupButton_OnDragStart(raidButton)
    if InCombatLockdown() then return end
    if ( not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") ) then
        return;
    end
    local cursorX, cursorY = GetCursorPosition();
    local uiScale = UIParent:GetScale();
    raidButton:StartMoving();
    MOVING_RAID_MEMBER = raidButton;
end

local function RaidGroupButton_OnDragStop(raidButton)
    if InCombatLockdown() then return end
    if ( not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") ) then
        return;
    end

    raidButton:StopMovingOrSizing();
    raidButton:ClearAllPoints();
    raidButton:SetPoint("TOPLEFT", raidButton.slot, "TOPLEFT", 0, 0);

    MOVING_RAID_MEMBER = nil;
    if ( TARGET_RAID_SLOT and TARGET_RAID_SLOT:GetParent():GetID() ~= raidButton.subgroup ) then
        if (TARGET_RAID_SLOT.button) then
            local button = _G[TARGET_RAID_SLOT.button];
            SwapRaidSubgroup(raidButton:GetID(), button:GetID());
        else
            local slot = TARGET_RAID_SLOT:GetParent():GetName().."Slot"..TARGET_RAID_SLOT:GetParent().nextIndex;
            raidButton:ClearAllPoints();
            raidButton:SetPoint("TOPLEFT", slot, "TOPLEFT", 0, 0);
            TARGET_RAID_SLOT:UnlockHighlight();
            SetRaidSubgroup(raidButton:GetID(), TARGET_RAID_SLOT:GetParent():GetID());
        end
    else
        if ( TARGET_RAID_SLOT ) then
            TARGET_RAID_SLOT:UnlockHighlight();
        end
    end
end

local function RaidFrame_OnEvent(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        RaidFrame_Update()
    end

    if ( event == "PLAYER_ENTERING_WORLD" ) then
        RequestRaidInfo();
    elseif ( event == "PLAYER_LOGIN" ) then
        if ( IsInRaid() ) then
            RaidFrame_LoadUI();
            if not InCombatLockdown() then RaidFrame_Update() end
        end
    elseif ( event == "GROUP_ROSTER_UPDATE" ) then
        RaidFrame_LoadUI();
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
        else
            RaidFrame_Update()
        end
        RaidPullout_RenewFrames();
    elseif ( event == "READY_CHECK" or
        event == "READY_CHECK_CONFIRM" ) then
        if ( RaidFrame:IsShown() and RaidGroupFrame_Update and not InCombatLockdown() ) then
            RaidGroupFrame_Update();
        end
    elseif ( event == "READY_CHECK_FINISHED" ) then
        if ( RaidFrame:IsShown() and RaidGroupFrame_ReadyCheckFinished ) then
            RaidGroupFrame_ReadyCheckFinished();
        end
    elseif ( event == "UPDATE_INSTANCE_INFO" ) then
        if ( not RaidFrame.hasRaidInfo ) then
            -- Set flag
            RaidFrame.hasRaidInfo = 1;
            return;
        end
        if ( GetNumSavedInstances() + GetNumSavedWorldBosses() > 0 ) then
            RaidFrameRaidInfoButton:Enable();
        else
            RaidFrameRaidInfoButton:Disable();
        end
        RaidInfoFrame_Update(true);
    elseif (event == "PARTY_LEADER_CHANGED" or event == "PARTY_LFG_RESTRICTED" ) then
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
        else
            RaidFrame_Update()
        end
    end
end

local function RaidGroupFrame_OnEvent(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        RaidGroupFrame_Update()
    end

    RaidFrame_OnEvent(self, event, ...);
    if ( event == "UNIT_LEVEL" ) then
        local arg1 = ...;
        local id, found = gsub(arg1, "raid([0-9]+)", "%1");
        if ( found == 1 ) then
            RaidGroupFrame_UpdateLevel(id);
        end
    elseif ( event == "UNIT_HEALTH" ) then
        local arg1 = "...";
        local id, found = gsub(arg1, "raid([0-9]+)", "%1");
        if ( found == 1 ) then
            RaidGroupFrame_UpdateHealth(id);
        end
    elseif ( event == "UNIT_PET" or event == "UNIT_NAME_UPDATE" ) then
        RaidClassButton_Update();
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        RaidPullout_RenewFrames();
    elseif ( event == "VARIABLES_LOADED" ) then
        RaidFrame.showRange = GetCVarBool("showRaidRange");
    elseif ( event == "RAID_ROSTER_UPDATE" and not InCombatLockdown() ) then
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
        else
            RaidGroupFrame_Update()
        end
    end
end

local function LoadRaidList(tabContainer)
    RaidFrame_LoadUI()
    RaidFrame_Update()
    RequestRaidInfo()

    RaidFrame:SetScript("OnEvent", RaidGroupFrame_OnEvent);

    local raidFrame = CreateFrame("Frame", "GwRaidWindow", tabContainer, "GWRaidFrameSocial")

    RaidFrame:SetParent(raidFrame)
    RaidFrame:ClearAllPoints()
    RaidFrame:SetPoint("TOPLEFT", raidFrame, "TOPLEFT", 0, 0)
    RaidFrame:SetPoint("BOTTOMRIGHT", raidFrame, "BOTTOMRIGHT", 0, 0)
    --RaidFrame.SetParent = GW.NoOp
    --RaidFrame.ClearAllPoints = GW.NoOp
    --RaidFrame.SetAllPoints = GW.NoOp
    --RaidFrame.SetPoint = GW.NoOp

    RaidFrame:SetScript("OnShow", function(self)
        ButtonFrameTemplate_ShowAttic(self:GetParent())

        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
        else
            RaidFrame_Update()
        end
        RequestRaidInfo()
    end)

    RaidFrameRaidDescription:ClearAllPoints()
    RaidFrameRaidDescription:SetPoint("TOPLEFT", RaidFrameNotInRaid, "TOPLEFT", 0, -73)
    RaidFrameRaidDescription:SetPoint("BOTTOMRIGHT", RaidFrameNotInRaid, "BOTTOMRIGHT", 0, 0)
    RaidFrameRaidDescription:SetJustifyH("CENTER")
    RaidFrameRaidDescription:SetJustifyV("TOP")

    RaidFrameAllAssistCheckButton:ClearAllPoints()
    RaidFrameAllAssistCheckButton:SetPoint("TOPLEFT", 10, -23)
    RaidFrameAllAssistCheckButton.text:ClearAllPoints()
    RaidFrameAllAssistCheckButton.text:SetPoint("LEFT", RaidFrameAllAssistCheckButton, "RIGHT", 5, -2)
    RaidFrameAllAssistCheckButton.text:SetText(ALL .. " |TInterface/AddOns/GW2_UI/textures/party/icon-assist:25:25:0:-3|t")
    --ALL_ASSIST_LABEL
    RaidFrame.RoleCount:ClearAllPoints()
    RaidFrame.RoleCount:SetPoint("TOP", -80, -25)

    RaidFrame.RoleCount.TankIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-tank")
    RaidFrame.RoleCount.HealerIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-healer")
    RaidFrame.RoleCount.DamagerIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-dps")
    RaidFrame.RoleCount.DamagerIcon:SetSize(20, 20)

    RaidFrameAllAssistCheckButton:GwSkinCheckButton()
    RaidFrameAllAssistCheckButton:SetSize(18, 18)

    RaidFrameConvertToRaidButton:GwSkinButton(false, true)
    RaidFrameRaidInfoButton:GwSkinButton(false, true)
    if GetSetting("USE_CHARACTER_WINDOW") then
        RaidFrameRaidInfoButton:SetScript("OnClick", function()
            if InCombatLockdown() then return end
            if GWCharacterCurrenyRaidInfoFrame.RaidScroll:IsVisible() then
                GwCharacterWindow:SetAttribute("windowpanelopen", "nil")
                return
            end
            GwCharacterWindow:SetAttribute("windowpanelopen", "currency")
            GWCurrencyMenu.items.raidinfo:Click()
        end)
    end

    ClaimRaidFrame = GW.NoOp

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
        _G["RaidGroupButton" .. i .. "Class"]:SetFont(UNIT_NAME_FONT, 10)

        _G["RaidGroupButton" .. i .. "Name"]:SetSize(60, 19)
        _G["RaidGroupButton" .. i .. "Level"]:SetSize(37, 19)
        _G["RaidGroupButton" .. i .. "Class"]:SetSize(80, 19)

        _G["RaidGroupButton" .. i]:SetScript("OnDragStart", RaidGroupButton_OnDragStart)
        _G["RaidGroupButton" .. i]:SetScript("OnDragStop", RaidGroupButton_OnDragStop)
    end

    hooksecurefunc("RaidGroupFrame_Update", function()
        for i = 1, _G.MAX_RAID_GROUPS * 5 do
            local _, rank, _, _, _, _, _, _, _, role = GetRaidRosterInfo(i)

            if rank == 2 then
                _G["RaidGroupButton" .. i .. "RankTexture"]:SetTexture("Interface/AddOns/GW2_UI/textures/party/icon-groupleader")
            elseif rank == 1 then
                _G["RaidGroupButton" .. i .. "RankTexture"]:SetTexture("Interface/AddOns/GW2_UI/textures/party/icon-assist")
            else
                _G["RaidGroupButton" .. i .. "RankTexture"]:SetTexture("")
            end

            if role == "MAINTANK" then
                _G["RaidGroupButton" .. i .. "RoleTexture"]:SetTexture("Interface/AddOns/GW2_UI/textures/party/icon-maintank")
            elseif role == "MAINASSIST" then
                _G["RaidGroupButton" .. i .. "RoleTexture"]:SetTexture("Interface/AddOns/GW2_UI/textures/party/icon-mainassist")
            else
                _G["RaidGroupButton" .. i .. "RoleTexture"]:SetTexture("")
            end
        end

    end)
end
GW.LoadRaidList = LoadRaidList