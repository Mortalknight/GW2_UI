---@class GW2
local GW = select(2, ...)
local NeedAdjustMaxStanceButtons = false
local NeedStanceButtonStyling = false
local NUM_STANCE_SLOTS = NUM_STANCE_SLOTS or 10
local WispSplode = [[Interface\Icons\Spell_Nature_WispSplode]]

local function IsStanceBarMouseOver(bar)
    if not bar then return false end
    if bar:IsMouseOver() or bar.container:IsMouseOver() then return true end

    for _, button in ipairs(bar.buttons or {}) do
        if button:IsShown() and button:IsMouseOver() then
            return true
        end
    end

    return false
end

local function StanceBarOnEnter(self)
    local bar = self.gwStanceBar
    bar:UpdateAlpha(true)
end

local function StanceBarOnLeave(self)
    local bar = self.gwStanceBar
    C_Timer.After(0.05, function()
        bar:UpdateAlpha(IsStanceBarMouseOver(bar))
    end)
end

local function HookMouseFade(frame, bar)
    if not frame or frame.gwStanceBarMouseFadeHooked then return end

    frame.gwStanceBar = bar
    frame.gwStanceBarMouseFadeHooked = true
    frame:EnableMouse(true)
    frame:HookScript("OnEnter", StanceBarOnEnter)
    frame:HookScript("OnLeave", StanceBarOnLeave)
end

GwStanceBarMixin = {}

function GwStanceBarMixin:UpdateVisibility()
    local visibility = string.gsub(GW.settings.StanceBar.visibility, "[\n\r]", "")
    RegisterStateDriver(self, "visibility", (not GW.settings.StanceBar.enabled or GetNumShapeshiftForms() == 0) and "hide" or visibility)
end

function GwStanceBarMixin:UpdateAlpha(isMouseOver)
    if isMouseOver == nil then
        isMouseOver = IsStanceBarMouseOver(self)
    end

    local alpha = GW.settings.StanceBar.alpha
    if GW.settings.StanceBar.mouseOver and not isMouseOver then
        alpha = 0
    end

    self:SetAlpha(alpha)
end

function GwStanceBarMixin:UpdateCooldown()
    local numForms = GetNumShapeshiftForms()
    for i = 1, NUM_STANCE_SLOTS do
        if i <= numForms then
            local button = self.buttons[i]
            local cooldown = button and button.cooldown
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

function GwStanceBarMixin:PositionsAndSize()
    local numForms = GetNumShapeshiftForms()
    local buttonSize = GW.settings.StanceBar.buttonSize
    local spacing = GW.settings.StanceBar.spacing

    self:SetSize(buttonSize, buttonSize)

    if numForms == 1 then -- If we have only 1 stance, show that button directly and not a container
        local button = self.buttons[1]
        button:SetParent(self)
        button:SetSize(buttonSize, buttonSize)
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", self, "TOPLEFT")
        button:SetFrameLevel(self:GetFrameLevel() + 5)
    else
        local growDirection = GW.settings.StanceBar.growDirection
        local button, lastbutton
        local containerLongSide = (buttonSize * numForms) + (spacing * (numForms + 1))
        local containerShortSide = buttonSize + (spacing * 2)

        if growDirection == "LEFT" or growDirection == "RIGHT" then
            self.container:SetSize(containerLongSide, containerShortSide)
        else
            self.container:SetSize(containerShortSide, containerLongSide)
        end

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
            button = self.buttons[i]
            lastbutton = self.buttons[i - 1]

            button:ClearAllPoints()
            button:SetSize(buttonSize, buttonSize)
            button:SetParent(self.container)
            if growDirection == "UP" then
                if i == 1 then
                    button:SetPoint("BOTTOM", self.container, "BOTTOM", 0, spacing)
                else
                    button:SetPoint("BOTTOM", lastbutton, "TOP", 0, spacing)
                end
            elseif growDirection == "LEFT" then
                if i == 1 then
                    button:SetPoint("RIGHT", self.container, "RIGHT", -spacing, 0)
                else
                    button:SetPoint("RIGHT", lastbutton, "LEFT", -spacing, 0)
                end
            elseif growDirection == "RIGHT" then
                if i == 1 then
                    button:SetPoint("LEFT", self.container, "LEFT", spacing, 0)
                else
                    button:SetPoint("LEFT", lastbutton, "RIGHT", spacing, 0)
                end
            elseif growDirection == "DOWN" then
                if i == 1 then
                    button:SetPoint("TOP", self.container, "TOP", 0, -spacing)
                else
                    button:SetPoint("TOP", lastbutton, "BOTTOM", 0, -spacing)
                end
            end
        end
    end

    self.gwMover:SetSize(self:GetSize())
    self:UpdateAlpha()
end

function GwStanceBarMixin:StyleStanceBarButtons()
    local numForms = GetNumShapeshiftForms()
    local stance = GetShapeshiftForm()
    local buttonSize = GW.settings.StanceBar.buttonSize

    for i = 1, NUM_STANCE_SLOTS do
        local button = self.buttons[i]

        if i > numForms then
            break
        else
            local texture, isActive, isCastable, spellID = GetShapeshiftFormInfo(i)

            button.icon:SetTexture((not isActive and spellID and C_Spell.GetSpellTexture(spellID)) or WispSplode)
            button.icon:GwSetInside()
            button:SetSize(buttonSize, buttonSize)
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

function GwStanceBarMixin:UpdateKeybinds()
    for i = 1, NUM_STANCE_SLOTS do
        local button = self.buttons[i]
        if not button then break end

        button.HotKey:SetText(GetBindingKey("SHAPESHIFTBUTTON" .. i))
        GW.updateHotkey(button)
        GW.FixHotKeyPosition(button, true)
    end
end

function GwStanceBarMixin:AdjustMaxStanceButtons()
    for _, button in ipairs(self.buttons) do
        button:Hide()
    end

    local numButtons = GetNumShapeshiftForms()
    for i = 1, NUM_STANCE_SLOTS do
        if not self.buttons[i] then
            self.buttons[i] = CreateFrame("CheckButton", format(self:GetName() .. "Button%d", i), self, "StanceButtonTemplate")
            self.buttons[i]:SetID(i)
            self.buttons[i].parentName = self:GetName()
            HookMouseFade(self.buttons[i], self)
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

    self:PositionsAndSize()
    self:StyleStanceBarButtons()
    self:UpdateKeybinds()
    self:UpdateVisibility()
end

function GwStanceBarMixin:OnEvent( event)
    local inCombat = InCombatLockdown()

    if (event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_SHAPESHIFT_FORMS") or NeedAdjustMaxStanceButtons then
        if inCombat then
            NeedAdjustMaxStanceButtons = true
        else
            self.container:SetShown(GW.settings.StanceBar.containerState == "open" and true or false)
            self:AdjustMaxStanceButtons()
            NeedAdjustMaxStanceButtons = false
        end
    elseif event == "UPDATE_SHAPESHIFT_FORM" or event == "UPDATE_SHAPESHIFT_USABLE" or event == "ACTIONBAR_PAGE_CHANGED" or NeedStanceButtonStyling then
        if inCombat then
            NeedStanceButtonStyling = true
        else
            self:StyleStanceBarButtons()
            NeedStanceButtonStyling = false
        end
    elseif event == "UPDATE_SHAPESHIFT_COOLDOWN" then
        self:UpdateCooldown()
    elseif event == "UPDATE_BINDINGS" then
        self:UpdateKeybinds()
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
    Mixin(StanceButtonHolder, GwStanceBarMixin)

    StanceButtonHolder.buttons = {}
    HookMouseFade(StanceButtonHolder, StanceButtonHolder)
    HookMouseFade(StanceButtonHolder.container, StanceButtonHolder)

    StanceButtonHolder:RegisterEvent("PLAYER_ENTERING_WORLD")
    StanceButtonHolder:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    StanceButtonHolder:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
    StanceButtonHolder:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
    StanceButtonHolder:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
    StanceButtonHolder:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
    StanceButtonHolder:RegisterEvent("UPDATE_BINDINGS")
    StanceButtonHolder:SetScript("OnEvent", StanceButtonHolder.OnEvent)

    StanceButtonHolder:UpdateVisibility()
    StanceButtonHolder:UpdateAlpha()

    return StanceButtonHolder
end

function GW.CreateStanceBar ()
    local StanceButtonHolder = CreateStanceBarButtonHolder()

    if GW.Retail or GW.TBC or GW.Wrath or GW.Mists then
        StanceBar:GwKillEditMode()
    else
        StanceBarFrame:GwKill()
    end

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
        GW.settings.StanceBar.containerState =  self.container:IsShown() and "open" or "close"
    end)

    GW.RegisterMovableFrame(StanceButtonHolder, GW.L["Stance Bar"], "StanceBar_pos", "Power,Blizzard", nil, {"default", "scaleable"})
    StanceButtonHolder:ClearAllPoints()
    StanceButtonHolder:SetPoint("TOPLEFT", StanceButtonHolder.gwMover)
end
