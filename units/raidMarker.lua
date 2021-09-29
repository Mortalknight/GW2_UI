local _, GW = ...

local ButtonIsDown
local RaidMarkFrame = CreateFrame("Frame")
local ANG_RAD = rad(360) / 7

local function RaidMarkCanMark()
    if not RaidMarkFrame then return false end

    if GetNumGroupMembers() > 0 then
        if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
            return true
        elseif IsInGroup() and not IsInRaid() then
            return true
        else
            UIErrorsFrame:AddMessage(CALENDAR_ERROR_PERMISSIONS, 1.0, 0.1, 0.1, 1.0)
            return false
        end
    else
        return true
    end
end

local function RaidMarkShowIcons()
    if not UnitExists("target") or UnitIsDead("target")then
        return
    end
    local x, y = GetCursorPosition()
    RaidMarkFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    RaidMarkFrame:Show()
end

function GW_RaidMark_HotkeyPressed(keystate)
    ButtonIsDown = (keystate == "down") and RaidMarkCanMark()
    if ButtonIsDown and RaidMarkFrame then
        RaidMarkShowIcons()
    elseif RaidMarkFrame then
        RaidMarkFrame:Hide()
    end
end

local function RaidMark_OnEvent()
    if ButtonIsDown then
        RaidMarkShowIcons()
    end
end

local function RaidMarkButton_OnEnter(self)
    self.Texture:ClearAllPoints()
    self.Texture:SetPoint("TOPLEFT", -10, 10)
    self.Texture:SetPoint("BOTTOMRIGHT", 10, -10)
end

local function RaidMarkButton_OnLeave(self)
    self.Texture:SetAllPoints()
end

local function RaidMarkButton_OnClick(self, button)
    PlaySound(1115)
    SetRaidTarget("target", (button ~= "RightButton") and self:GetID() or 0)
    RaidMarkFrame:Hide()
end

local function LoadRaidMarker()
    _G["BINDING_NAME_GW2UI_RAID_MARKER"] = RAID_TARGET_ICON

    RaidMarkFrame:EnableMouse(true)
    RaidMarkFrame:SetFrameStrata("DIALOG")
    RaidMarkFrame:SetSize(100, 100)
    RaidMarkFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    RaidMarkFrame:SetScript("OnEvent", RaidMark_OnEvent)

    for i = 1, 8 do
        local button = CreateFrame("Button", "RaidMarkIconButton" .. i, RaidMarkFrame)
        button:SetSize(40, 40)
        button:SetID(i)
        button.Texture = button:CreateTexture(button:GetName() .. "NormalTexture", "ARTWORK")
        button.Texture:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcon_" .. i)
        button.Texture:SetAllPoints()
        button:RegisterForClicks("LeftbuttonUp","RightbuttonUp")
        button:SetScript("OnClick", RaidMarkButton_OnClick)
        button:SetScript("OnEnter", RaidMarkButton_OnEnter)
        button:SetScript("OnLeave", RaidMarkButton_OnLeave)
        if i == 8 then
            button:SetPoint("CENTER")
        else
            local angle = ANG_RAD * (i - 1)
            button:SetPoint("CENTER", math.sin(angle) * 60, math.cos(angle) * 60)
        end
    end
end
GW.LoadRaidMarker = LoadRaidMarker
