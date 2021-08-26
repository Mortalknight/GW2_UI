local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local IsIn = GW.IsIn
local GWGetClassColor = GW.GWGetClassColor
local RegisterMovableFrame = GW.RegisterMovableFrame
local SetClassIcon = GW.SetClassIcon

local function unhookPlayerFrame()
    if InCombatLockdown() or IsInRaid() then
        return
    end

    if IsInGroup() and (GetSetting("RAID_STYLE_PARTY") or GetSetting("RAID_STYLE_PARTY_AND_FRAMES")) then
        GwCompactPartyFrame1:Show()
        RegisterStateDriver(GwCompactPartyFrame1, "visibility", ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format(GwCompactPartyFrame1.unit))
    else
        UnregisterStateDriver(GwCompactPartyFrame1, "visibility")
        GwCompactPartyFrame1:Hide()
    end
end
GW.AddForProfiling("raidframes", "unhookPlayerFrame", unhookPlayerFrame)

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
        GW.GridSetUnitName(self, "PARTY")
    end

    if event == "load" then
        GW.GridSetAbsorbAmount(self)
        GW.GridSetPredictionAmount(self, "PARTY")
        GW.GridSetHealth(self, "PARTY")
        GW.GridUpdateAwayData(self, "PARTY")
        GW.GridUpdateAuras(self, "PARTY")
        GW.GridUpdatePower(self)
    elseif event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" then
        GW.GridSetHealth(self, "PARTY")
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
        GW.GridUpdatePower(self)
    elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
        GW.GridSetAbsorbAmount(self)
    elseif event == "UNIT_HEAL_PREDICTION" then
        GW.GridSetPredictionAmount(self, "PARTY")
    elseif event == "UNIT_PHASE" or event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" or event == "UNIT_THREAT_SITUATION_UPDATE" then
        GW.GridUpdateAwayData(self, "PARTY")
    elseif event == "PLAYER_TARGET_CHANGED" then
        GW.GridHighlightTargetFrame(self)
    elseif event == "UNIT_NAME_UPDATE" then
        GW.GridSetUnitName(self, "PARTY")
    elseif event == "UNIT_AURA" then
        GW.GridUpdateAuras(self, "PARTY")
    elseif event == "PLAYER_ENTERING_WORLD" then
        RequestRaidInfo()
    elseif event == "UPDATE_INSTANCE_INFO" then
        GW.GridUpdateAuras(self, "PARTY")
        GW.GridUpdateAwayData(self, "PARTY")
    elseif (event == "INCOMING_RESURRECT_CHANGED" or event == "INCOMING_SUMMON_CHANGED") and unit == self.unit then
        GW.GridUpdateAwayData(self, "PARTY")
    elseif event == "RAID_TARGET_UPDATE" and GetSetting("RAID_UNIT_MARKERS_PARTY") then
        GW.GridUpdateRaidMarkers(self, "PARTY")
    elseif event == "READY_CHECK" or (event == "READY_CHECK_CONFIRM" and unit == self.unit) then
        GW.GridUpdateAwayData(self, "PARTY")
    elseif event == "READY_CHECK_FINISHED" then
        C_Timer.After(1.5, function()
            if UnitInRaid(self.unit) then
                local _, englishClass, classIndex = UnitClass(self.unit)
                if GetSetting("RAID_CLASS_COLOR_PARTY") then
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
        GW.GridUpdateAwayData(self, "PARTY")
    end
end

local function LoadPartyGrid()
    if not GetSetting("RAID_STYLE_PARTY") and not GetSetting("RAID_STYLE_PARTY_AND_FRAMES") then
        return
    end

    if not _G.GwManageGroupButton then
        GW.manageButton()
    end

    CreateFrame("Frame", "GwRaidFramePartyContainer", UIParent, "GwRaidFrameContainer")

    GwRaidFramePartyContainer:ClearAllPoints()
    GwRaidFramePartyContainer:SetPoint(
        GetSetting("raid_party_pos")["point"],
        UIParent,
        GetSetting("raid_party_pos")["relativePoint"],
        GetSetting("raid_party_pos")["xOfs"],
        GetSetting("raid_party_pos")["yOfs"]
    )

    RegisterMovableFrame(GwRaidFramePartyContainer, L["Group Frames"], "raid_party_pos", "VerticalActionBarDummy", nil, true, {"default", "default"})


    hooksecurefunc(GwRaidFramePartyContainer.gwMover, "StopMovingOrSizing", function (frame)
        local anchor = GetSetting("RAID_ANCHOR_PARTY")

        if anchor == "GROWTH" then
            local g1, g2 = strsplit("+", GetSetting("RAID_GROW_PARTY"))
            anchor = (IsIn("DOWN", g1, g2) and "TOP" or "BOTTOM") .. (IsIn("RIGHT", g1, g2) and "LEFT" or "RIGHT")
        end

        if anchor ~= "POSITION" then
            local x = anchor:sub(-5) == "RIGHT" and frame:GetRight() - GetScreenWidth() or anchor:sub(-4) == "LEFT" and frame:GetLeft() or frame:GetLeft() + (frame:GetWidth() - GetScreenWidth()) / 2
            local y = anchor:sub(1, 3) == "TOP" and frame:GetTop() - GetScreenHeight() or anchor:sub(1, 6) == "BOTTOM" and frame:GetBottom() or frame:GetBottom() + (frame:GetHeight() - GetScreenHeight()) / 2

            frame:ClearAllPoints()
            frame:SetPoint(anchor, x, y)
        end

        if not InCombatLockdown() then
            GwRaidFramePartyContainer:ClearAllPoints()
            GwRaidFramePartyContainer:SetPoint(frame:GetPoint())
        end
    end)

    for i = 1, 5 do
        GW.CreateGridFrame(i, true, GwRaidFramePartyContainer, GridOnEvent, GridOnUpdate, "PARTY")
    end

    GW.GridUpdateRaidFramesPosition("PARTY") -- profile
    GW.GridUpdateRaidFramesLayout("PARTY") -- profile

    GwRaidFramePartyContainer:RegisterEvent("RAID_ROSTER_UPDATE")
    GwRaidFramePartyContainer:RegisterEvent("GROUP_ROSTER_UPDATE")
    GwRaidFramePartyContainer:RegisterEvent("PLAYER_ENTERING_WORLD")

    GwRaidFramePartyContainer:SetScript("OnEvent", function(self, event)
        print(event)
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
        end
        if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end

        unhookPlayerFrame()

        GW.GridUpdateRaidFramesLayout("PARTY") -- profile

        for i = 1, 5 do
            GW.GridUpdateFrameData(_G["GwCompactPartyFrame" .. i], i)
        end
    end)
end
GW.LoadPartyGrid = LoadPartyGrid