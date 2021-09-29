local _, GW = ...

local function SetStanceButtons(stanceButton)
    if not stanceButton then return end
    local numForms = GetNumShapeshiftForms()

    if numForms == 1 then -- If we have only 1 stance, show that button directly and not a container
        StanceButton1:SetParent(stanceButton)
        StanceButton1:ClearAllPoints()
        StanceButton1:SetPoint("TOPLEFT", stanceButton.gwMover)
        StanceButton1:SetFrameLevel(stanceButton:GetFrameLevel() + 5)
    else
        local growDirection = GW.GetSetting("StanceBar_GrowDirection")

        stanceButton.container:ClearAllPoints()
        if growDirection == "UP" then
            stanceButton.container:SetPoint("BOTTOM", stanceButton, "TOP", 0, 0)
        elseif growDirection == "LEFT" then
            stanceButton.container:SetPoint("RIGHT", stanceButton, "LEFT", 0, 0)
        elseif growDirection == "RIGHT" then
            stanceButton.container:SetPoint("LEFT", stanceButton, "RIGHT", 0, 0)
        elseif growDirection == "DOWN" then
            stanceButton.container:SetPoint("TOP", stanceButton, "BOTTOM", 0, 0)
        end
        for i = 1, NUM_STANCE_SLOTS do
            _G["StanceButton" .. i]:ClearAllPoints()
            _G["StanceButton" .. i]:SetParent(stanceButton.container)
            if growDirection == "UP" then
                if i == 1 then
                    _G["StanceButton" .. i]:SetPoint("BOTTOM", stanceButton.container, "BOTTOM", 0, 2)
                else
                    _G["StanceButton" .. i]:SetPoint("BOTTOM", _G["StanceButton" .. (i - 1)], "TOP", 0, 2)
                end
            elseif growDirection == "LEFT" then
                if i == 1 then
                    _G["StanceButton" .. i]:SetPoint("RIGHT", stanceButton.container, "RIGHT", -2, 0)
                else
                    _G["StanceButton" .. i]:SetPoint("RIGHT", _G["StanceButton" .. (i - 1)], "LEFT", -2, 0)
                end
            elseif growDirection == "RIGHT" then
                if i == 1 then
                    _G["StanceButton" .. i]:SetPoint("LEFT", stanceButton.container, "LEFT", 2, 0)
                else
                    _G["StanceButton" .. i]:SetPoint("LEFT", _G["StanceButton" .. (i - 1)], "RIGHT", 2, 0)
                end
            elseif growDirection == "DOWN" then
                if i == 1 then
                    _G["StanceButton" .. i]:SetPoint("TOP", stanceButton.container, "TOP", 0, -2)
                else
                    _G["StanceButton" .. i]:SetPoint("TOP", _G["StanceButton" .. (i - 1)], "BOTTOM", 0, -2)
                end
            end
        end
    end
end
GW.SetStanceButtons = SetStanceButtons

local function StanceButton_OnEvent(self, event)
    if event == "PLAYER_ENTERING_WORLD" and not InCombatLockdown() then
        self.container:SetShown(GW.GetSetting("StanceBarContainerState") == "open" and true or false)
    end
    if InCombatLockdown() then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end

    if GetNumShapeshiftForms() == 0 then
        self:Hide()
    else
        SetStanceButtons(self)
        self:Show()
    end
end

local function CreateStanceBarButton()
    local StanceButton = CreateFrame("Button", "GwStanceBarButton", UIParent, "GwStanceBarButton")

    StanceButton:RegisterEvent("PLAYER_ENTERING_WORLD")
    StanceButton:RegisterEvent("CHARACTER_POINTS_CHANGED")
    StanceButton:RegisterEvent("PLAYER_ALIVE")
    StanceButton:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    StanceButton:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
    StanceButton:SetScript("OnEvent", StanceButton_OnEvent)

    return StanceButton
end

local function CreateStanceBar()
    local StanceBarButton = CreateStanceBarButton()

    StanceBarButton:SetFrameRef("GwStanceBarContainer", StanceBarButton.container)
    StanceBarButton:SetAttribute(
        "_onclick",
        [=[
        if self:GetFrameRef("GwStanceBarContainer"):IsVisible() then
            self:GetFrameRef("GwStanceBarContainer"):Hide()
        else
            self:GetFrameRef("GwStanceBarContainer"):Show()
        end
    ]=]
    )
    StanceBarButton:HookScript("OnClick", function(self)
        GW.SetSetting("StanceBarContainerState", self.container:IsShown() and "open" or "close")
    end)

    GW.RegisterMovableFrame(StanceBarButton, GW.L["StanceBar"], "StanceBar_pos", "VerticalActionBarDummy", nil, nil, {"default", "scaleable"})
    StanceBarButton:ClearAllPoints()
    StanceBarButton:SetPoint("TOPLEFT", StanceBarButton.gwMover)

    -- Skin default stancebuttons
    for i = 1, NUM_STANCE_SLOTS do
        if _G["StanceButton" .. i] then
            _G["StanceButton" .. i]:SetSize(30, 30)
            GW.setActionButtonStyle("StanceButton" .. i, true, nil ,true)
        end
    end

    SetStanceButtons(StanceBarButton)

    StanceBarFrame:Kill()
end
GW.CreateStanceBar = CreateStanceBar
