---@class GW2
local GW = select(2, ...)

local GCD_SPELL_ID = 61304
local RING_SIZE = 44
local RING_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/gcd-ring.png"

local ring

local function FollowCursor(self)
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    self:ClearAllPoints()
    self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
end

-- the duration object keeps it working with secret cooldowns, the classic clients use start and duration
local function UpdateCooldown()
    if C_Spell.GetSpellCooldownDuration then
        local durationObject = C_Spell.GetSpellCooldownDuration(GCD_SPELL_ID)
        if durationObject then
            ring.cooldown:SetCooldownFromDurationObject(durationObject)
        end
    else
        local info = C_Spell.GetSpellCooldown(GCD_SPELL_ID)
        if info then
            ring.cooldown:SetCooldown(info.startTime, info.duration)
        end
    end
end

local function CreateRing()
    ring = CreateFrame("Frame", nil, UIParent)
    ring:SetSize(RING_SIZE, RING_SIZE)
    ring:SetFrameStrata("TOOLTIP")
    ring:EnableMouse(false)

    ring.cooldown = CreateFrame("Cooldown", nil, ring, "CooldownFrameTemplate")
    ring.cooldown:SetAllPoints()
    ring.cooldown:SetSwipeTexture(RING_TEXTURE, GW.Colors.SkinColors.QuestGold:GetRGBA())
    ring.cooldown:SetUseCircularEdge(true)
    ring.cooldown:SetDrawEdge(false)
    ring.cooldown:SetDrawBling(false)
    ring.cooldown:SetHideCountdownNumbers(true)

    ring:SetScript("OnUpdate", FollowCursor)
    ring:SetScript("OnEvent", UpdateCooldown)
end

function GW.UpdateCursorGcdRing()
    local enabled = GW.settings.general.cursorGcdRing
    if not ring then
        if not enabled then return end
        CreateRing()
    end

    ring:SetShown(enabled)
    if enabled then
        ring:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        UpdateCooldown()
    else
        ring:UnregisterAllEvents()
    end
end
