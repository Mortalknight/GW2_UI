local _, GW = ...
local TOTEM_BAR_BUTTON_SIZE = 48
local TOTEM_BAR_BUTTON_MARGIN = 3

local function UpdateButton(button, totem)
    if not (button and totem) then return end

    local haveTotem, _, startTime, duration, icon = GetTotemInfo(totem.slot)
    button:SetShown(haveTotem and duration > 0)

    if haveTotem then
        button.iconTexture:SetTexture(icon)
        button.cooldown:SetCooldown(startTime, duration)

        if totem:GetParent() ~= button.holder then
            totem:ClearAllPoints()
            totem:SetParent(button.holder)
            totem:SetAllPoints(button.holder)
        end
    end
end

local function OnEvent(self)
    local priority = STANDARD_TOTEM_PRIORITIES

    for _, button in ipairs(self) do
        if button:IsShown() then
            button:SetShown(false)
        end
    end

    for totem in TotemFrame.totemPool:EnumerateActive() do
        UpdateButton(self[priority[totem.layoutIndex]], totem)
    end
end

local function PositionAndSize(self)
    local growDirection = GW.settings.TotemBar_GrowDirection
    local sortDirection = GW.settings.TotemBar_SortDirection

    for i = 1, MAX_TOTEMS do
        local button = self[i]
        local prevButton = self[i - 1]

        button:SetSize(TOTEM_BAR_BUTTON_SIZE, TOTEM_BAR_BUTTON_SIZE)
        button:ClearAllPoints()
        if growDirection == "HORIZONTAL" and sortDirection == "ASC" then
            if i == 1 then
                button:SetPoint("LEFT", self, "LEFT", TOTEM_BAR_BUTTON_MARGIN, 0)
            else
                button:SetPoint("LEFT", prevButton, "RIGHT", TOTEM_BAR_BUTTON_MARGIN, 0)
            end
        elseif growDirection == "HORIZONTAL" and sortDirection == "DSC" then
            if i == 1 then
                button:SetPoint("RIGHT", self, "RIGHT", -TOTEM_BAR_BUTTON_MARGIN, 0)
            else
                button:SetPoint("RIGHT", prevButton, "LEFT", -TOTEM_BAR_BUTTON_MARGIN, 0)
            end
        elseif growDirection == "VERTICAL" and sortDirection == "ASC" then
            if i == 1 then
                button:SetPoint("TOP", self, "TOP", 0, -TOTEM_BAR_BUTTON_MARGIN)
            else
                button:SetPoint("TOP", prevButton, "BOTTOM", 0, -TOTEM_BAR_BUTTON_MARGIN)
            end
        elseif growDirection == "VERTICAL" and sortDirection == "DSC" then
            if i == 1 then
                button:SetPoint("BOTTOM", self, "BOTTOM", 0, TOTEM_BAR_BUTTON_MARGIN)
            else
                button:SetPoint("BOTTOM", prevButton, "TOP", 0, TOTEM_BAR_BUTTON_MARGIN)
            end
        end
    end

    local size1, size2 = TOTEM_BAR_BUTTON_SIZE * MAX_TOTEMS + MAX_TOTEMS * TOTEM_BAR_BUTTON_MARGIN + TOTEM_BAR_BUTTON_MARGIN, TOTEM_BAR_BUTTON_SIZE + TOTEM_BAR_BUTTON_MARGIN * 2
    if growDirection == "HORIZONTAL" then
        self:SetWidth(size1) -- Button Size * MAX_TOTEMS + MAX_TOTEMS * Spacing + Spacing
        self:SetHeight(size2) -- Button Size + Spacing * 2
    else
        self:SetHeight(size1) -- Button Size * MAX_TOTEMS + MAX_TOTEMS * Spacing + Spacing
        self:SetWidth(size2) -- Button Size + Spacing * 2
    end
    if self.gwMover then
        self.gwMover:SetSize(self:GetSize())
    end

    OnEvent(self)
end
GW.UpdateTotembar = PositionAndSize

local function CreateTotemBar()
    local totemBar = CreateFrame("Frame", "GW_TotemBar", UIParent)

    for i = 1, MAX_TOTEMS do
        local button = CreateFrame("Button", totemBar:GetName() .. "Totem" .. i, totemBar)

        button:SetID(i)
        button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed")
        button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")

        local backDrop = CreateFrame("Frame", nil, button, "GwActionButtonBackdropTmpl")
        local backDropSize = 1

        backDrop:SetPoint("TOPLEFT", button, "TOPLEFT", -backDropSize, backDropSize)
        backDrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", backDropSize, -backDropSize)
        button:Hide()

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

        GW.RegisterCooldown(button.cooldown)

        totemBar[i] = button
    end

    PositionAndSize(totemBar)

    totemBar:RegisterEvent("PLAYER_TOTEM_UPDATE")
    totemBar:RegisterEvent("PLAYER_ENTERING_WORLD")
    totemBar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    totemBar:SetScript("OnEvent", OnEvent)

    GW.RegisterMovableFrame(totemBar, GW.L["Class Totems"], "TotemBar_pos", ALL .. ",Blizzard,Widgets", nil, {"default", "scaleable"})
    totemBar:ClearAllPoints()
    totemBar:SetPoint("TOPLEFT", totemBar.gwMover)
end
GW.CreateTotemBar = CreateTotemBar
