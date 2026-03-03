local _, GW = ...

local ButtonIsDown
local ANG_RAD = rad(360) / 7
local raidMarker = CreateFrame("Frame")

local RaidMarkerButtonMixin = {}
local RaidMarkerFrameMixin = {}

function RaidMarkerFrameMixin:RaidMarkCanMark()
    if not self then return false end

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

function RaidMarkerFrameMixin:RaidMarkShowIcons()
    if not UnitExists("target") or UnitIsDead("target")then
        return
    end
    local x, y = GetCursorPosition()
    if GW.Retail and InCombatLockdown() then return end
    self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    self:Show()
end


function RaidMarkerButtonMixin:OnEnter()
    self.Texture:ClearAllPoints()
    self.Texture:SetPoint("TOPLEFT", -10, 10)
    self.Texture:SetPoint("BOTTOMRIGHT", 10, -10)
end

function RaidMarkerButtonMixin:OnLeave()
    self.Texture:SetAllPoints()
end

function RaidMarkerButtonMixin:Clicked()
    PlaySound(1115)
    local parent = self:GetParent()
    if parent then
        if GW.Retail and InCombatLockdown() then return end
        parent:Hide()
    end
end

function GW_RaidMark_HotkeyPressed(keystate)
    ButtonIsDown = (keystate == "down") and raidMarker:RaidMarkCanMark()
    if ButtonIsDown and raidMarker then
        raidMarker:RaidMarkShowIcons()
    elseif raidMarker then
        if GW.Retail and InCombatLockdown() then return end
        raidMarker:Hide()
    end
end

function RaidMarkerFrameMixin:OnEvent()
    if ButtonIsDown and self then
        self:RaidMarkShowIcons()
    end
end

local function LoadRaidMarkerCircle()
    BINDING_NAME_RAID_MARKER = RAID_TARGET_ICON

    Mixin(raidMarker, RaidMarkerFrameMixin)
    raidMarker:EnableMouse(true)
    raidMarker:SetFrameStrata("DIALOG")
    raidMarker:SetSize(100, 100)
    raidMarker:RegisterEvent("PLAYER_TARGET_CHANGED")
    raidMarker:SetScript("OnEvent", raidMarker.OnEvent)

    for i = 1, 8 do
        local tm = format("/tm %d", i)
        local name = "RaidMarkIconButton" .. i
        local button = CreateFrame("Button", name, raidMarker, "SecureActionButtonTemplate")
        Mixin(button, RaidMarkerButtonMixin)

        button:SetScript("OnEnter", button.OnEnter)
        button:SetScript("OnLeave", button.OnLeave)
        button:SetAttribute("type", "macro")
        button:SetAttribute("macrotext", tm)
        if GW.Retail or GW.TBC then
            button:SetScript("OnMouseUp", button.Clicked)
            button:RegisterForClicks("AnyDown", "AnyUp")
        else
            button:SetScript("OnMouseDown", button.Clicked)
            button:RegisterForClicks("AnyDown")
        end
        button:SetSize(40, 40)
        button:SetID(i)
        button.Texture = button:CreateTexture(name .. "NormalTexture", "ARTWORK")
        button.Texture:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcons")
        button.Texture:SetAllPoints()

        SetRaidTargetIconTexture(button.Texture, i)

        if i == 8 then
            button:SetPoint("CENTER")
        else
            local angle = ANG_RAD * (i - 1)
            button:SetPoint("CENTER", math.sin(angle) * 60, math.cos(angle) * 60)
        end
    end
end
GW.LoadRaidMarkerCircle = LoadRaidMarkerCircle
