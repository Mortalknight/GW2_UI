local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local GWGetClassColor = GW.GWGetClassColor
local RegisterMovableFrame = GW.RegisterMovableFrame
local SetClassIcon = GW.SetClassIcon
local IsIn = GW.IsIn


local function hideBlizzardRaidFrame()
    if InCombatLockdown() then
        return
    end

    if CompactRaidFrameManager then
        CompactRaidFrameManager:UnregisterAllEvents()
        CompactRaidFrameManager:Hide()
    end
    if CompactRaidFrameContainer then
        CompactRaidFrameContainer:UnregisterAllEvents()
    end
    if CompactRaidFrameManager_GetSetting then
        local compact_raid = CompactRaidFrameManager_GetSetting("IsShown")
        if compact_raid and compact_raid ~= "0" then
            CompactRaidFrameManager_SetSetting("IsShown", "0")
        end
    end
end
GW.AddForProfiling("raidframes", "hideBlizzardRaidFrame", hideBlizzardRaidFrame)

local function togglePartyFrames(b)
    if InCombatLockdown() then
        return
    end

    if IsInRaid() then
        b = false
    end

    if b then
        if GetSetting("RAID_STYLE_PARTY") or GetSetting("RAID_STYLE_PARTY_AND_FRAMES") then
            for i = 1, 5 do
                _G["GwCompactPartyFrame" .. i]:Show()
                RegisterStateDriver(_G["GwCompactPartyFrame" .. i], "visibility", ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format(_G["GwCompactPartyFrame" .. i].unit))
            end
        end
        GW.TogglePartyRaid(true)
    else
        GW.TogglePartyRaid(false)
        for i = 1, 5 do
            UnregisterStateDriver(_G["GwCompactPartyFrame" .. i], "visibility")
            _G["GwCompactPartyFrame" .. i]:Hide()
        end
    end
end
GW.AddForProfiling("raidframes", "togglePartyFrames", togglePartyFrames)

local function GridOnEvent(self, event, unit)
    if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        -- Enable or disable mouse handling on aura frames
        local name = self:GetName()
        for j = 1, 2 do
            local i, aura = 1, j == 1 and "Buff" or "DeBuff"
            local frame = nil
            repeat
                frame = _G["Gw" .. name .. aura .. "ItemFrame" .. i]
                if frame then
                    if frame.tooltipSetting == "NEVER" then
                        frame:EnableMouse(false)
                    elseif frame.tooltipSetting == "ALWAYS" then
                        frame:EnableMouse(true)
                    elseif frame.tooltipSetting == "IN_COMBAT" and event == "PLAYER_REGEN_ENABLED" then
                        frame:EnableMouse(false)
                    elseif frame.tooltipSetting == "IN_COMBAT" and event == "PLAYER_REGEN_DISABLED" then
                        frame:EnableMouse(true)
                    elseif frame.tooltipSetting == "OUT_COMBAT" and event == "PLAYER_REGEN_ENABLED" then
                        frame:EnableMouse(true)
                    elseif frame.tooltipSetting == "OUT_COMBAT" and event == "PLAYER_REGEN_DISABLED" then
                        frame:EnableMouse(false)
                    end
                end
                i = i + 1
            until not frame
        end
    end

    if not UnitExists(self.unit) then
        return
    elseif not self.nameNotLoaded then
        GW.GridSetUnitName(self)
    end

    if event == "load" then
        GW.GridSetAbsorbAmount(self)
        GW.GridSetPredictionAmount(self)
        GW.GridSetHealth(self)
        GW.GridUpdateAwayData(self)
        GW.GridUpdateAuras(self)
        GW.GridUpdatePower(self)
    elseif event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" then
        GW.GridSetHealth(self)
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
        GW.GridUpdatePower(self)
    elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
        GW.GridSetAbsorbAmount(self)
    elseif event == "UNIT_HEAL_PREDICTION" then
        GW.GridSetPredictionAmount(self)
    elseif event == "UNIT_PHASE" or event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" or event == "UNIT_THREAT_SITUATION_UPDATE" then
        GW.GridUpdateAwayData(self)
    elseif event == "PLAYER_TARGET_CHANGED" then
        GW.GridHighlightTargetFrame(self)
    elseif event == "UNIT_NAME_UPDATE" then
        GW.GridSetUnitName(self)
    elseif event == "UNIT_AURA" then
        GW.GridUpdateAuras(self)
    elseif event == "PLAYER_ENTERING_WORLD" then
        RequestRaidInfo()
    elseif event == "UPDATE_INSTANCE_INFO" then
        GW.GridUpdateAuras(self)
        GW.GridUpdateAwayData(self)
    elseif (event == "INCOMING_RESURRECT_CHANGED" or event == "INCOMING_SUMMON_CHANGED") and unit == self.unit then
        GW.GridUpdateAwayData(self)
    elseif event == "RAID_TARGET_UPDATE" and GetSetting("RAID_UNIT_MARKERS") then
        GW.GridUpdateRaidMarkers(self)
    elseif event == "READY_CHECK" or (event == "READY_CHECK_CONFIRM" and unit == self.unit) then
        GW.GridUpdateAwayData(self)
    elseif event == "READY_CHECK_FINISHED" then
        C_Timer.After(1.5, function()
            if UnitInRaid(self.unit) then
                local _, englishClass, classIndex = UnitClass(self.unit)
                if GetSetting("RAID_CLASS_COLOR") then
                    local color = GWGetClassColor(englishClass, true)
                    self.healthbar:SetStatusBarColor(color.r, color.g, color.b, color.a)
                    self.classicon:SetShown(false)
                else
                    self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons")
                    self.healthbar:SetStatusBarColor(0.207, 0.392, 0.168)
                    self.classicon:SetShown(true)
                    SetClassIcon(self.classicon, classIndex)
                end
            end
        end)
    end
end
GW.GridOnEvent = GridOnEvent

local function GridOnUpdate(self, elapsed)
    if self.onUpdateDelay ~= nil and self.onUpdateDelay > 0 then
        self.onUpdateDelay = self.onUpdateDelay - elapsed
        return
    end
    self.onUpdateDelay = 0.2
    if UnitExists(self.unit) then
        GW.GridUpdateAwayData(self)
    end
end

local function LoadRaidFrames()
    if not _G.GwManageGroupButton then
        GW.manageButton()
    end

    hideBlizzardRaidFrame()

    if CompactRaidFrameManager_UpdateShown then
        hooksecurefunc("CompactRaidFrameManager_UpdateShown", hideBlizzardRaidFrame)
    end
    if CompactRaidFrameManager then
        CompactRaidFrameManager:HookScript("OnShow", hideBlizzardRaidFrame)
    end

    CreateFrame("Frame", "GwRaidFrameContainer", UIParent, "GwRaidFrameContainer")

    GwRaidFrameContainer:ClearAllPoints()
    GwRaidFrameContainer:SetPoint(
        GetSetting("raid_pos")["point"],
        UIParent,
        GetSetting("raid_pos")["relativePoint"],
        GetSetting("raid_pos")["xOfs"],
        GetSetting("raid_pos")["yOfs"]
    )

    RegisterMovableFrame(GwRaidFrameContainer, RAID_FRAMES_LABEL, "raid_pos", "VerticalActionBarDummy", nil, true, {"default", "default"})

    hooksecurefunc(GwRaidFrameContainer.gwMover, "StopMovingOrSizing", function (frame)
        local anchor = GetSetting("RAID_ANCHOR")

        if anchor == "GROWTH" then
            local g1, g2 = strsplit("+", GetSetting("RAID_GROW"))
            anchor = (IsIn("DOWN", g1, g2) and "TOP" or "BOTTOM") .. (IsIn("RIGHT", g1, g2) and "LEFT" or "RIGHT")
        end

        if anchor ~= "POSITION" then
            local x = anchor:sub(-5) == "RIGHT" and frame:GetRight() - GetScreenWidth() or anchor:sub(-4) == "LEFT" and frame:GetLeft() or frame:GetLeft() + (frame:GetWidth() - GetScreenWidth()) / 2
            local y = anchor:sub(1, 3) == "TOP" and frame:GetTop() - GetScreenHeight() or anchor:sub(1, 6) == "BOTTOM" and frame:GetBottom() or frame:GetBottom() + (frame:GetHeight() - GetScreenHeight()) / 2

            frame:ClearAllPoints()
            frame:SetPoint(anchor, x, y)
        end

        if not InCombatLockdown() then
            GwRaidFrameContainer:ClearAllPoints()
            GwRaidFrameContainer:SetPoint(frame:GetPoint())
        end
    end)

    for i = 1, MAX_RAID_MEMBERS do
        GW.CreateGridFrame(i, false, GridOnEvent, GridOnUpdate)
    end

    GW.GridUpdateRaidFramesPosition() -- profile
    GW.GridUpdateRaidFramesLayout() -- profile

    GwSettingsRaidPanel.buttonRaidPreview:SetScript("OnClick", function()
        if GwSettingsRaidPanel.selectProfile.type == "RAID" then
            GW.GridToggleFramesPreviewRaid(_, _, false, false)
        else
            GW.GridToggleFramesPreviewParty(_, _, false, false)
        end
    end)
    GwSettingsRaidPanel.buttonRaidPreview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:AddLine(L["Click to toggle raid frame preview and cycle through different group sizes."], 1, 1, 1)
        GameTooltip:Show()
    end)
    GwSettingsRaidPanel.buttonRaidPreview:SetScript("OnLeave", GameTooltip_Hide)
    GwSettingsWindowMoveHud:HookScript("OnClick", function ()
        GW.GridToggleFramesPreviewRaid(_, _, true, true)
        GW.GridToggleFramesPreviewParty(_, _, true, true)
    end)
    GwSmallSettingsWindow.lockHud:HookScript("OnClick", function()
        GW.GridToggleFramesPreviewRaid(_, _, true, true)
        GW.GridToggleFramesPreviewParty(_, _, true, true)
    end)

    GwRaidFrameContainer:RegisterEvent("RAID_ROSTER_UPDATE")
    GwRaidFrameContainer:RegisterEvent("GROUP_ROSTER_UPDATE")
    GwRaidFrameContainer:RegisterEvent("PLAYER_ENTERING_WORLD")

    GwRaidFrameContainer:SetScript("OnEvent", function(self)
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
            --return
        end

        if not IsInRaid() and IsInGroup() then
            togglePartyFrames(true)
        elseif IsInRaid() then
            togglePartyFrames(false)
        end

        GW.GridUpdateRaidFramesLayout() -- profile

        for i = 1, MAX_RAID_MEMBERS do
            GW.GridUpdateFrameData(_G["GwCompactRaidFrame" .. i], i)
        end
    end)
end
GW.LoadRaidFrames = LoadRaidFrames
