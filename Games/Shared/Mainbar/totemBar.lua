---@class GW2
local GW = select(2, ...)

-- the edge the first button sits at and the step towards the next one, per grow and sort setting
local LAYOUTS = {
    HORIZONTAL = { ASC = { "LEFT", 1, 0 }, DSC = { "RIGHT", -1, 0 } },
    VERTICAL = { ASC = { "TOP", 0, -1 }, DSC = { "BOTTOM", 0, 1 } },
}

GwTotemBarMixin = {}

function GwTotemBarMixin:UpdateVisibility()
    RegisterStateDriver(self, "visibility", GW.settings.totemBar.enabled and "show" or "hide")
end

local hookedTotems = {}

local function TotemOnEnter(totem)
    totem:GetParent():GetParent():LockHighlight()
end

local function TotemOnLeave(totem)
    totem:GetParent():GetParent():UnlockHighlight()
end

-- Blizzard's totem button moves into ours: it stays invisible but keeps its
-- tooltip and the right click that dismisses the totem. Era has no such button.
local function ShowTotem(button, slot, totem)
    local _, _, startTime, duration, icon = GetTotemInfo(slot)

    button.iconTexture:SetTexture(icon)
    if GetTotemDuration then
        local durationObject = GetTotemDuration(slot)
        if durationObject then
            button.cooldown:SetCooldownFromDurationObject(durationObject)
        end
    elseif duration > 0 then
        button.cooldown:SetCooldown(startTime, duration)
    end

    if not totem then
        button:SetShown(duration > 0)
        return
    end

    if not hookedTotems[totem] then
        hookedTotems[totem] = true
        totem:HookScript("OnEnter", TotemOnEnter)
        totem:HookScript("OnLeave", TotemOnLeave)
    end
    if totem:GetParent() ~= button.holder then
        totem:SetParent(button.holder)
    end
    -- Blizzard's pool clears the anchors on every update, also when the button comes back to the same place
    totem:ClearAllPoints()
    totem:SetAllPoints(button.holder)

    -- totems without a running timer are not worth a button; Blizzard's button
    -- knows that even when the duration is secret
    button:SetShown(totem:IsShown())
    if totem:IsMouseOver() then
        button:LockHighlight()
    end
end

function GwTotemBarMixin:Update()
    for _, button in ipairs(self.buttons) do
        button.cooldown:Clear()
        button:UnlockHighlight()
        button:Hide()
    end

    -- most clients pool their totem buttons, Wrath still has fixed ones, Era has none
    if not TotemFrame then
        for slot, button in ipairs(self.buttons) do
            ShowTotem(button, slot)
        end
    elseif TotemFrame.totemPool then
        for totem in TotemFrame.totemPool:EnumerateActive() do
            local button = self.buttons[totem.layoutIndex]
            if button then
                ShowTotem(button, totem.slot, totem)
            end
        end
    else
        for i, button in ipairs(self.buttons) do
            local totem = _G["TotemFrameTotem" .. i]
            if totem and totem.slot and totem.slot > 0 then
                ShowTotem(button, totem.slot, totem)
            end
        end
    end
end

function GwTotemBarMixin:PositionAndSizeUpdate()
    local settings = GW.settings.totemBar
    local size, spacing = settings.buttonSize, settings.spacing
    local point, stepX, stepY = unpack(LAYOUTS[settings.growDirection][settings.sortDirection])

    for i, button in ipairs(self.buttons) do
        local offset = spacing + (i - 1) * (size + spacing)
        button:SetSize(size, size)
        button:ClearAllPoints()
        button:SetPoint(point, self, point, stepX * offset, stepY * offset)
    end

    local length = #self.buttons * (size + spacing) + spacing
    local thickness = size + spacing * 2
    if settings.growDirection == "HORIZONTAL" then
        self:SetSize(length, thickness)
    else
        self:SetSize(thickness, length)
    end
    if self.gwMover then
        self.gwMover:SetSize(self:GetSize())
    end

    self:Update()
end

local function CreateTotemButton(bar, index)
    local button = CreateFrame("Button", nil, bar)
    button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png")
    button:EnableMouse(false)
    button:Hide()

    local backdrop = CreateFrame("Frame", nil, button, "GwActionButtonBackdropTmpl")
    backdrop:SetPoint("TOPLEFT", -1, 1)
    backdrop:SetPoint("BOTTOMRIGHT", 1, -1)

    -- invisible home for Blizzard's totem button
    button.holder = CreateFrame("Frame", nil, button)
    button.holder:SetAllPoints()
    button.holder:SetAlpha(0)

    button.iconTexture = button:CreateTexture(nil, "ARTWORK")
    button.iconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button.iconTexture:SetPoint("TOPLEFT", GW.border, -GW.border)
    button.iconTexture:SetPoint("BOTTOMRIGHT", -GW.border, GW.border)

    button.cooldown = CreateFrame("Cooldown", "GwTotemBarTotem" .. index .. "Cooldown", button, "CooldownFrameTemplate")
    button.cooldown:SetAllPoints(button.iconTexture)
    button.cooldown:SetReverse(true)
    button.cooldown:SetDrawEdge(false)
    button.cooldown:SetHideCountdownNumbers(false)
    -- modern cooldowns bring their own numbers
    if not GW.isModern then
        GW.RegisterCooldown(button.cooldown)
    end

    return button
end

function GW.CreateTotemBar()
    local bar = Mixin(CreateFrame("Frame", "GwTotemBar", UIParent), GwTotemBarMixin)
    bar.buttons = {}
    for i = 1, MAX_TOTEMS do
        bar.buttons[i] = CreateTotemButton(bar, i)
    end
    bar:PositionAndSizeUpdate()

    if TotemFrame then
        hooksecurefunc(TotemFrame, "Update", function() bar:Update() end)
    else
        bar:RegisterEvent("PLAYER_TOTEM_UPDATE")
        bar:RegisterEvent("PLAYER_ENTERING_WORLD")
        bar:SetScript("OnEvent", bar.Update)
    end

    GW.RegisterMovableFrame(bar, GW.L["Class Totems"], "totemBar", "Blizzard,Widgets", nil, { GW.MoverOption.Scale })
    bar:UpdateVisibility()
    bar:ClearAllPoints()
    bar:SetPoint("TOPLEFT", bar.gwMover)
end
