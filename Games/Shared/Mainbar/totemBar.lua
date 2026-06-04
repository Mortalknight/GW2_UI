---@class GW2
local GW = select(2, ...)

local classic = { 2, 1, 3, 4 }

GwTotemBarMixin = {}

function GwTotemBarMixin:UpdateVisibility()
    if not self then return end
    RegisterStateDriver(self, "visibility", GW.settings.TotemBar.enabled and "show" or "hide")
end

local function UpdateButton(button, totem)
    if not (button and totem) then return end

    local slot = (GW.Classic or GW.TBC or GW.Wrath or GW.Mists) and totem or totem.slot
    local _, _, startTime, duration, icon = GetTotemInfo(slot)

    if startTime then
        button.iconTexture:SetTexture(icon)
        if GW.IsSecretValue(duration) then
            button.cooldown:SetCooldownFromDurationObject(GetTotemDuration(slot))
        elseif duration and duration > 0 then
            button.cooldown:SetCooldown(startTime, duration)
        else
            button.cooldown:Clear()
        end

        if GW.Mists or GW.Retail then
            if totem:GetParent() ~= button.holder then
                totem:SetParent(button.holder)
            end

            totem:SetAllPoints(button.holder)
        end
    else
        button.cooldown:Clear()
    end

    button:SetShown(button.cooldown:IsShown())
end

function GwTotemBarMixin:Update()
    local priority = STANDARD_TOTEM_PRIORITIES

    if GW.Retail or GW.Mists then
        for _, button in ipairs(self) do
            if button:IsShown() then
                button:SetShown(false)
            end
        end

        for totem in TotemFrame.totemPool:EnumerateActive() do
            UpdateButton(self[priority[totem.layoutIndex]], totem)
        end
    else
        for i = 1, MAX_TOTEMS do
            UpdateButton(self[priority[i]], _G["TotemFrameTotem"..i] or classic[i])
        end
    end
end

function GwTotemBarMixin:PositionAndSizeUpdate()
    local growDirection = GW.settings.TotemBar.growDirection
    local sortDirection = GW.settings.TotemBar.sortDirection
    local buttonSize = GW.settings.TotemBar.buttonSize
    local spacing = GW.settings.TotemBar.spacing

    for i = 1, MAX_TOTEMS do
        local button = self[i]
        local prevButton = self[i - 1]

        button:SetSize(buttonSize, buttonSize)
        button:ClearAllPoints()
        if growDirection == "HORIZONTAL" and sortDirection == "ASC" then
            if i == 1 then
                button:SetPoint("LEFT", self, "LEFT", spacing, 0)
            else
                button:SetPoint("LEFT", prevButton, "RIGHT", spacing, 0)
            end
        elseif growDirection == "HORIZONTAL" and sortDirection == "DSC" then
            if i == 1 then
                button:SetPoint("RIGHT", self, "RIGHT", -spacing, 0)
            else
                button:SetPoint("RIGHT", prevButton, "LEFT", -spacing, 0)
            end
        elseif growDirection == "VERTICAL" and sortDirection == "ASC" then
            if i == 1 then
                button:SetPoint("TOP", self, "TOP", 0, -spacing)
            else
                button:SetPoint("TOP", prevButton, "BOTTOM", 0, -spacing)
            end
        elseif growDirection == "VERTICAL" and sortDirection == "DSC" then
            if i == 1 then
                button:SetPoint("BOTTOM", self, "BOTTOM", 0, spacing)
            else
                button:SetPoint("BOTTOM", prevButton, "TOP", 0, spacing)
            end
        end
    end

    local size1, size2 = buttonSize * MAX_TOTEMS + (MAX_TOTEMS + 1) * spacing, buttonSize + spacing * 2
    if growDirection == "HORIZONTAL" then
        self:SetWidth(size1)
        self:SetHeight(size2)
    else
        self:SetHeight(size1)
        self:SetWidth(size2)
    end
    if self.gwMover then
        self.gwMover:SetSize(self:GetSize())
    end

    self:Update()
end

function GW.CreateTotemBar()
    local totemBar = CreateFrame("Frame", "GwTotemBar", UIParent)
    Mixin(totemBar, GwTotemBarMixin)

    for i = 1, MAX_TOTEMS do
        local button = CreateFrame("Button", totemBar:GetName() .. "Totem" .. i, totemBar)

        button:SetID(i)
        button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed.png")
        button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png")
        button:Hide()

        local backDrop = CreateFrame("Frame", nil, button, "GwActionButtonBackdropTmpl")
        local backDropSize = 1

        backDrop:SetPoint("TOPLEFT", button, "TOPLEFT", -backDropSize, backDropSize)
        backDrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", backDropSize, -backDropSize)

        button.holder = CreateFrame("Frame", nil, button)
        button.holder:SetAlpha(0)
        button.holder:SetAllPoints()

        button.iconTexture = button:CreateTexture(nil, "ARTWORK")
        button.iconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        button.iconTexture:SetPoint("TOPLEFT", button, "TOPLEFT", GW.border, -GW.border)
        button.iconTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -GW.border, GW.border)

        button.cooldown = CreateFrame("Cooldown", button:GetName() .. "Cooldown", button, "CooldownFrameTemplate")
        button.cooldown:SetReverse(true)
        button.cooldown:SetHideCountdownNumbers(false)
        button.cooldown:SetDrawEdge(false)
        button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", GW.border, -GW.border)
        button.cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -GW.border, GW.border)

        if not GW.Retail then
            GW.RegisterCooldown(button.cooldown)
        end

        totemBar[i] = button
    end

    totemBar:PositionAndSizeUpdate()

    totemBar:RegisterEvent("PLAYER_TOTEM_UPDATE")
    totemBar:RegisterEvent("PLAYER_ENTERING_WORLD")
    if GW.Retail then
        totemBar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    else
        totemBar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    end
    totemBar:SetScript("OnEvent", totemBar.Update)

    GW.RegisterMovableFrame(totemBar, GW.L["Class Totems"], "TotemBar_pos", "Blizzard,Widgets", nil, {"default", "scaleable"})
    totemBar:UpdateVisibility()
    totemBar:ClearAllPoints()
    totemBar:SetPoint("TOPLEFT", totemBar.gwMover)
end
