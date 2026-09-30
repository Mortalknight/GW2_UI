---@class GW2
local GW = select(2, ...)

-- Holding the raid marker key opens a ring of the eight markers at the cursor.
-- The buttons are secure macro buttons running /tm, so the ring can not change in combat.

local MARKER_COUNT = 8
local RING_RADIUS = 60
local HOVER_GROW = 10
-- these clients read useOnKeyDown from an attribute, older ones use the click registration
local USES_KEY_DOWN_ATTRIBUTE = GW.isModern or GW.TBC or GW.Wrath

local ring
local keyHeld = false

-- the skull sits in the middle, the other seven go clockwise around it from the top
local function GetMarkerOffset(index)
    if index == MARKER_COUNT then
        return 0, 0
    end
    local angle = (index - 1) * 2 * math.pi / (MARKER_COUNT - 1)
    return math.sin(angle) * RING_RADIUS, math.cos(angle) * RING_RADIUS
end

-- alone or in a party anyone may mark, in a raid only the leader and assistants
local function CanPlaceMarkers()
    if not IsInRaid() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
        return true
    end
    UIErrorsFrame:AddMessage(CALENDAR_ERROR_PERMISSIONS, GW.Colors.SkinColors.Negative:GetRGB())
    return false
end

local function ShowRing()
    if InCombatLockdown() or not UnitExists("target") or UnitIsDead("target") then return end
    local x, y = GetCursorPosition()
    local scale = ring:GetEffectiveScale()
    ring:ClearAllPoints()
    ring:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
    ring:Show()
end

local function HideRing()
    if not InCombatLockdown() then
        ring:Hide()
    end
end

-- called by the key binding in Bindings.xml
function GW_RaidMark_HotkeyPressed(keystate)
    if not ring then return end
    keyHeld = keystate == "down" and CanPlaceMarkers()
    if keyHeld then
        ShowRing()
    else
        HideRing()
    end
end

local function SetKeyDown(keyDown)
    if USES_KEY_DOWN_ATTRIBUTE and InCombatLockdown() then
        GW.CombatQueue:Queue("Update Raid Marker CVAR", SetKeyDown, { keyDown })
        return
    end
    for _, button in ipairs(ring.buttons) do
        if USES_KEY_DOWN_ATTRIBUTE then
            button:SetAttribute("useOnKeyDown", keyDown)
        else
            button:RegisterForClicks(keyDown and "AnyDown" or "AnyUp")
        end
    end
end

local function OnRingEvent(_, event, cvar, value)
    if event == "PLAYER_TARGET_CHANGED" then
        if keyHeld then
            ShowRing()
        end
    elseif cvar == "ActionButtonUseKeyDown" then
        SetKeyDown(value == "1")
    end
end

local function GrowIcon(button)
    button.icon:ClearAllPoints()
    button.icon:SetPoint("TOPLEFT", -HOVER_GROW, HOVER_GROW)
    button.icon:SetPoint("BOTTOMRIGHT", HOVER_GROW, -HOVER_GROW)
end

local function ShrinkIcon(button)
    button.icon:SetAllPoints()
end

local function OnMarkerClicked()
    PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
    HideRing()
end

local function CreateMarkerButton(index, keyDown)
    local button = CreateFrame("Button", "RaidMarkIconButton" .. index, ring, "SecureActionButtonTemplate")
    button:SetSize(40, 40)
    button:SetID(index)
    button:SetPoint("CENTER", GetMarkerOffset(index))
    button:SetAttribute("type", "macro")
    button:SetAttribute("macrotext", "/tm " .. index)

    if USES_KEY_DOWN_ATTRIBUTE then
        button:SetAttribute("useOnKeyDown", keyDown)
        button:RegisterForClicks("AnyDown", "AnyUp")
        button:SetScript("OnMouseUp", OnMarkerClicked)
    else
        button:RegisterForClicks(keyDown and "AnyDown" or "AnyUp")
        button:SetScript("OnMouseDown", OnMarkerClicked)
    end

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcons")
    button.icon:SetAllPoints()
    SetRaidTargetIconTexture(button.icon, index)
    button:SetScript("OnEnter", GrowIcon)
    button:SetScript("OnLeave", ShrinkIcon)
    return button
end

local function LoadRaidMarkerCircle()
    BINDING_NAME_RAID_MARKER = RAID_TARGET_ICON

    ring = CreateFrame("Frame", nil, UIParent)
    ring:SetSize(100, 100)
    ring:SetFrameStrata("DIALOG")
    ring:EnableMouse(true)
    ring:Hide()

    ring.buttons = {}
    local keyDown = GetCVarBool("ActionButtonUseKeyDown")
    for index = 1, MARKER_COUNT do
        ring.buttons[index] = CreateMarkerButton(index, keyDown)
    end

    ring:RegisterEvent("PLAYER_TARGET_CHANGED")
    ring:RegisterEvent("CVAR_UPDATE")
    ring:SetScript("OnEvent", OnRingEvent)
end
GW.LoadRaidMarkerCircle = LoadRaidMarkerCircle
