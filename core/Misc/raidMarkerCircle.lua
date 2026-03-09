---@class GW2
local GW = select(2, ...)

local ButtonIsDown
local ANG_RAD = rad(360) / 7
local raidMarker

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

    if not raidMarker then return end

    if ButtonIsDown then
        raidMarker:RaidMarkShowIcons()
    else
        if GW.Retail and InCombatLockdown() then return end
        raidMarker:Hide()
    end
end

function RaidMarkerFrameMixin:OnEvent(event, cvar, keydown)
    if event == "PLAYER_TARGET_CHANGED" then
        if ButtonIsDown then
            self:RaidMarkShowIcons()
        end
    elseif event == "CVAR_UPDATE" and cvar == "ActionButtonUseKeyDown" then
        self:RaidMarkUpdateKeyDown(keydown == "1")
    end
end

function RaidMarkerFrameMixin:RaidMarkUpdateKeyDown(keydown)
    if not self or not self.buttons then return end

    local useAttribute = GW.Retail or GW.TBC
    if useAttribute and InCombatLockdown() then
        GW.CombatQueue_Queue("Update Raid Marker CVAR", self.RaidMarkUpdateKeyDown, {keydown})
        return
    end
    for _, button in next, self.buttons do
        if useAttribute then
            button:SetAttribute("useOnKeyDown", keydown)
        else
            button:RegisterForClicks(keydown and "AnyDown" or "AnyUp")
        end
    end
end

local function LoadRaidMarkerCircle()
    BINDING_NAME_RAID_MARKER = RAID_TARGET_ICON

    raidMarker = CreateFrame("Frame", nil, UIParent)
    Mixin(raidMarker, RaidMarkerFrameMixin)
    raidMarker:EnableMouse(true)
    raidMarker:SetFrameStrata("DIALOG")
    raidMarker:SetSize(100, 100)
    raidMarker:RegisterEvent("PLAYER_TARGET_CHANGED")
    raidMarker:RegisterEvent("CVAR_UPDATE")
    raidMarker:SetScript("OnEvent", raidMarker.OnEvent)
    raidMarker.buttons = {}

    local keydown = GetCVarBool("ActionButtonUseKeyDown")
    for i = 1, 8 do
        local tm = format("/tm %d", i)
        local name = "RaidMarkIconButton" .. i
        local button = CreateFrame("Button", name, raidMarker, "SecureActionButtonTemplate")
        Mixin(button, RaidMarkerButtonMixin)
        tinsert(raidMarker.buttons, button)

        button:SetScript("OnEnter", button.OnEnter)
        button:SetScript("OnLeave", button.OnLeave)
        button:SetAttribute("type", "macro")
        button:SetAttribute("macrotext", tm)
        if GW.Retail or GW.TBC then
            button:SetScript("OnMouseUp", button.Clicked)
            button:SetAttribute("useOnKeyDown", keydown)
            button:RegisterForClicks("AnyDown", "AnyUp")
        else
            button:SetScript("OnMouseDown", button.Clicked)
            button:RegisterForClicks(keydown and "AnyDown" or "AnyUp")
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
