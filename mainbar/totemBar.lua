local _, GW = ...

local TOTEM_BAR_BUTTON_SIZE = 48
local TOTEM_BAR_BUTTON_MARGIN = 3

local function gw_totem_bar_OnEvent(self)
    for i = 1, MAX_TOTEMS do
        local button = _G["TotemFrameTotem" .. i]
        local _, _, startTime, duration, icon = GetTotemInfo(button.slot)

        if button:IsShown() then
            self[i]:Show()
            self[i].iconTexture:SetTexture(icon)
            CooldownFrame_Set(self[i].cooldown, startTime, duration, true)

            button:ClearAllPoints()
            button:SetParent(self[i].holder)
            button:SetAllPoints(self[i].holder)
        else
            self[i]:Hide()
        end
    end
end

local function PositionAndSize(self)
    local growDirection = GW.GetSetting("TotemBar_GrowDirection")
    local sortDirection = GW.GetSetting("TotemBar_SortDirection")

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

    if growDirection == "HORIZONTAL" then
        self:SetWidth(TOTEM_BAR_BUTTON_SIZE * MAX_TOTEMS + MAX_TOTEMS * TOTEM_BAR_BUTTON_MARGIN + TOTEM_BAR_BUTTON_MARGIN) -- Button Size * MAX_TOTEMS + MAX_TOTEMS * Spacing + Spacing
        self:SetHeight(TOTEM_BAR_BUTTON_SIZE + TOTEM_BAR_BUTTON_MARGIN * 2) -- Button Size + Spacing * 2
    else
        self:SetHeight(TOTEM_BAR_BUTTON_SIZE * MAX_TOTEMS + MAX_TOTEMS * TOTEM_BAR_BUTTON_MARGIN + TOTEM_BAR_BUTTON_MARGIN) -- Button Size * MAX_TOTEMS + MAX_TOTEMS * Spacing + Spacing
        self:SetWidth(TOTEM_BAR_BUTTON_SIZE + TOTEM_BAR_BUTTON_MARGIN * 2) -- Button Size + Spacing * 2
    end

    gw_totem_bar_OnEvent(self)
end

local function Create_Totem_Bar()
    local gw_totem_bar = CreateFrame("Frame", "GW_TotemBar", UIParent)

    for i = 1, MAX_TOTEMS do
        local button = CreateFrame("Button", gw_totem_bar:GetName() .. "Totem" .. i, gw_totem_bar)

        button:SetID(i)
        button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed")
        button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")

        local backDrop = CreateFrame("Frame", nil, button, "GwActionButtonBackdropTmpl")
        local backDropSize = 1
        if button:GetWidth() > 40 then
            backDropSize = 2
        end
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

        gw_totem_bar[i] = button
    end

    PositionAndSize(gw_totem_bar)

    gw_totem_bar:RegisterEvent("PLAYER_TOTEM_UPDATE")
    gw_totem_bar:RegisterEvent("PLAYER_ENTERING_WORLD")
    gw_totem_bar:SetScript("OnEvent", gw_totem_bar_OnEvent)

    GW.RegisterMovableFrame(gw_totem_bar, GW.L["Class Totems"], "TotemBar_pos", "VerticalActionBarDummy", nil, nil, {"default", "scaleable"})
    gw_totem_bar:ClearAllPoints()
    gw_totem_bar:SetPoint("TOPLEFT", gw_totem_bar.gwMover)
end
GW.Create_Totem_Bar = Create_Totem_Bar
