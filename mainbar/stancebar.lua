local _, GW = ...
local NeedAdjustMaxStanceButtons = false
local NeedStanceButtonStyling = false
local NUM_STANCE_SLOTS = NUM_STANCE_SLOTS or 10
local WispSplode = [[Interface\Icons\Spell_Nature_WispSplode]]

local function UpdateCooldown()
    local numForms = GetNumShapeshiftForms()
    for i = 1, NUM_STANCE_SLOTS do
        if i <= numForms then
            local cooldown = _G["GwStanceBarButton" .. i .. "Cooldown"]
            local start, duration, active = GetShapeshiftFormCooldown(i)
            if (active and active ~= 0) and start > 0 and duration > 0 then
                cooldown:SetCooldown(start, duration)
                cooldown:SetDrawBling(cooldown:GetEffectiveAlpha() > 0.5)
            else
                cooldown:Clear()
            end
        end
    end
end

local function PositionsAndSize(self)
    if not self then return end
    local numForms = GetNumShapeshiftForms()

    if numForms == 1 then -- If we have only 1 stance, show that button directly and not a container
        GwStanceBarButton1:SetParent(self)
        GwStanceBarButton1:ClearAllPoints()
        GwStanceBarButton1:SetPoint("TOPLEFT", self.gwMover)
        GwStanceBarButton1:SetFrameLevel(self:GetFrameLevel() + 5)
    else
        local growDirection = GW.settings.StanceBar_GrowDirection
        local button, lastbutton

        self.container:ClearAllPoints()
        if growDirection == "UP" then
            self.container:SetPoint("BOTTOM", self, "TOP", 0, 0)
        elseif growDirection == "LEFT" then
            self.container:SetPoint("RIGHT", self, "LEFT", 0, 0)
        elseif growDirection == "RIGHT" then
            self.container:SetPoint("LEFT", self, "RIGHT", 0, 0)
        elseif growDirection == "DOWN" then
            self.container:SetPoint("TOP", self, "BOTTOM", 0, 0)
        end
        for i = 1, NUM_STANCE_SLOTS do
            button = _G["GwStanceBarButton" .. i]
            lastbutton = _G["GwStanceBarButton" .. i - 1]

            button:ClearAllPoints()
            button:SetParent(self.container)
            if growDirection == "UP" then
                if i == 1 then
                    button:SetPoint("BOTTOM", self.container, "BOTTOM", 0, 2)
                else
                    button:SetPoint("BOTTOM", lastbutton, "TOP", 0, 2)
                end
            elseif growDirection == "LEFT" then
                if i == 1 then
                    button:SetPoint("RIGHT", self.container, "RIGHT", -2, 0)
                else
                    button:SetPoint("RIGHT", lastbutton, "LEFT", -2, 0)
                end
            elseif growDirection == "RIGHT" then
                if i == 1 then
                    button:SetPoint("LEFT", self.container, "LEFT", 2, 0)
                else
                    button:SetPoint("LEFT", lastbutton, "RIGHT", 2, 0)
                end
            elseif growDirection == "DOWN" then
                if i == 1 then
                    button:SetPoint("TOP", self.container, "TOP", 0, -2)
                else
                    button:SetPoint("TOP", lastbutton, "BOTTOM", 0, -2)
                end
            end
        end
    end
end
GW.SetStanceButtons = PositionsAndSize

local function StyleStanceBarButtons()
    local numForms = GetNumShapeshiftForms()
    local stance = GetShapeshiftForm()

    for i = 1, NUM_STANCE_SLOTS do
        local button = _G["GwStanceBarButton" .. i]

        if i > numForms then
            break
        else
            local texture, isActive, isCastable, spellID = GetShapeshiftFormInfo(i)

            button.icon:SetTexture((not isActive and spellID and GetSpellTexture(spellID)) or WispSplode)
            button.icon:GwSetInside()
            button:SetSize(30, 30)
            button.cooldown:SetAlpha(texture and 1 or 0)
            if isActive then
                button:SetChecked(numForms == 1)
            elseif numForms == 1 or stance == 0 then
                button:SetChecked(false)
            else
                button:SetChecked(false)
            end

            if isCastable then
                button.icon:SetVertexColor(1.0, 1.0, 1.0)
            else
                button.icon:SetVertexColor(0.3, 0.3, 0.3)
            end

            GW.setActionButtonStyle(button:GetName(), true ,true)
        end
    end
end

local function UpdateKeybinds()
    for i = 1, NUM_STANCE_SLOTS do
		local button = _G['GwStanceBarButton'..i]
		if not button then break end

		button.HotKey:SetText(GetBindingKey('SHAPESHIFTBUTTON'..i))
        GW.updateHotkey(button)
        GW.FixHotKeyPosition(button, true)
	end
end

local function AdjustMaxStanceButtons(self)
    for _, button in ipairs(self.buttons) do
        button:Hide()
    end

    local numButtons = GetNumShapeshiftForms()
    for i = 1, NUM_STANCE_SLOTS do
        if not self.buttons[i] then
            self.buttons[i] = CreateFrame("CheckButton", format(self:GetName() .. "Button%d", i), self, "StanceButtonTemplate")
            self.buttons[i]:SetID(i)
            self.buttons[i].parentName = self:GetName()
        end

        local blizz = _G[format("StanceButton%d", i)]
        if blizz and blizz.commandName then
            self.buttons[i].commandName = blizz.commandName
        end
        GW.updateHotkey(self.buttons[i])

        if i <= numButtons then
            self.buttons[i]:Show()
            self.LastButton = i
        else
            self.buttons[i]:Hide()
        end
    end

    PositionsAndSize(self)
    StyleStanceBarButtons()
    UpdateKeybinds()

    if numButtons == 0 then
        self:Hide()
    else
        self:Show()
    end
end

local function StanceButton_OnEvent(self, event)
    local inCombat = InCombatLockdown()

    if (event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_SHAPESHIFT_FORMS") or NeedAdjustMaxStanceButtons then
        if inCombat then
            NeedAdjustMaxStanceButtons = true
        else
            self.container:SetShown(GW.settings.StanceBarContainerState == "open" and true or false)
            AdjustMaxStanceButtons(self)
            NeedAdjustMaxStanceButtons = false
        end
    elseif event == "UPDATE_SHAPESHIFT_FORM" or event == "UPDATE_SHAPESHIFT_USABLE" or event == "ACTIONBAR_PAGE_CHANGED" or NeedStanceButtonStyling then
        if inCombat then
            NeedStanceButtonStyling = true
        else
            StyleStanceBarButtons()
            NeedStanceButtonStyling = false
        end
    elseif event == "UPDATE_SHAPESHIFT_COOLDOWN" then
        UpdateCooldown()
    elseif event == "UPDATE_BINDINGS" then
        UpdateKeybinds()
    end

    if inCombat then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end

local function CreateStanceBarButtonHolder()
    local StanceButtonHolder = CreateFrame("Button", "GwStanceBar", UIParent, "GwStanceBarButton")

    StanceButtonHolder.buttons = {}

    StanceButtonHolder:RegisterEvent("PLAYER_ENTERING_WORLD")
    StanceButtonHolder:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    StanceButtonHolder:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
    StanceButtonHolder:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
    StanceButtonHolder:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
    StanceButtonHolder:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
    StanceButtonHolder:RegisterEvent("UPDATE_BINDINGS")
    StanceButtonHolder:SetScript("OnEvent", StanceButton_OnEvent)

    GW.MixinHideDuringPetAndOverride(StanceButtonHolder)
    return StanceButtonHolder
end

local function CreateStanceBar()
    local StanceButtonHolder = CreateStanceBarButtonHolder()

    StanceBar:GwKillEditMode()

    StanceButtonHolder:SetFrameRef("GwStanceBarContainer", StanceButtonHolder.container)
    StanceButtonHolder:SetAttribute(
        "_onclick",
        [=[
            local GwStanceBarContainer = self:GetFrameRef("GwStanceBarContainer")
            if GwStanceBarContainer:IsVisible() then
                GwStanceBarContainer:Hide()
            else
                GwStanceBarContainer:Show()
            end
        ]=])
    StanceButtonHolder:HookScript("OnClick", function(self)
        GW.settings.StanceBarContainerState =  self.container:IsShown() and "open" or "close"
    end)

    GW.RegisterMovableFrame(StanceButtonHolder, GW.L["StanceBar"], "StanceBar_pos", ALL .. ",Power,Blizzard", nil, {"default", "scaleable"})
    StanceButtonHolder:ClearAllPoints()
    StanceButtonHolder:SetPoint("TOPLEFT", StanceButtonHolder.gwMover)
end
GW.CreateStanceBar = CreateStanceBar
