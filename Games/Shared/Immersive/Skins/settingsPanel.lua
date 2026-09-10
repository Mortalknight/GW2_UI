---@class GW2
local GW = select(2, ...)


local ARROW_RIGHT = "Interface/AddOns/GW2_UI/textures/uistuff/arrow_right.png"
local ARROW_DOWN = "Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png"
local MENU_BG = "Interface/AddOns/GW2_UI/textures/character/menu-bg.png"
local MENU_HOVER = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"
local MENU_TEXT_COLOR = {1, 0.9450, 0.8196}
local MENU_MAIN_FONT_SIZE = 14
local MENU_SUB_FONT_SIZE = 12
local DROPDOWN_TEXT_COLOR = {178 / 255, 178 / 255, 178 / 255}

local function HideTextureRegions(frame)
    for _, region in pairs({frame:GetRegions()}) do
        if region:IsObjectType("Texture") then
            region:SetAlpha(0)
        end
    end
end

---------- header ----------
local function SkinTab(tab)
    if not tab or tab.gwSkinned then return end
    tab.gwSkinned = true

    GW.HandleTabs(tab, "top")
    local function HideArt(self)
        self.Left:SetAlpha(0)
        self.Middle:SetAlpha(0)
        self.Right:SetAlpha(0)
    end
    HideArt(tab)
    hooksecurefunc(tab, "UpdateAtlas", HideArt)

    local function ApplyText(self)
        self.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        self.Text:SetTextColor(1, 1, 1)
        self.Text:ClearAllPoints()
        self.Text:SetPoint("CENTER")
        self.background:SetBlendMode(self:IsSelected() and "MOD" or "BLEND")
    end
    ApplyText(tab)
    tab:HookScript("OnEnter", ApplyText)
    tab:HookScript("OnLeave", ApplyText)
    hooksecurefunc(tab, "OnSelected", ApplyText)
    tab:SetHeight(25)
end

---------- category list ----------
local function SkinCategoryRow(row)
    if row.gwSkinned then return end
    row.gwSkinned = true

    if not row.Label then
        return -- spacer row
    end
    if row.Background then
        -- category header = main menu row
        row.Background:SetAlpha(0)
        row.gwBg = row:CreateTexture(nil, "BACKGROUND")
        row.gwBg:SetTexture(MENU_BG)
        row.gwBg:SetAllPoints()
        row.Label:SetFont(UNIT_NAME_FONT, MENU_MAIN_FONT_SIZE, "")
        row.Label:SetTextColor(unpack(MENU_TEXT_COLOR))
        row.Label:ClearAllPoints()
        row.Label:SetPoint("LEFT", 22, 0)
        return
    end

    -- category = sub menu row
    row.Texture:SetAlpha(0)
    row.gwSubBg = row:CreateTexture(nil, "BACKGROUND", nil, 1)
    row.gwSubBg:SetAllPoints()
    row.gwSubBg:SetColorTexture(0, 0, 0, 0.35)
    row.gwRail = row:CreateTexture(nil, "BACKGROUND", nil, 2)
    row.gwRail:SetPoint("TOPLEFT", 30, 0)
    row.gwRail:SetPoint("BOTTOMLEFT", 30, 0)
    row.gwRail:SetWidth(1)
    row.gwRail:SetColorTexture(1, 1, 1, 0.18)
    row.gwHover = row:CreateTexture(nil, "BACKGROUND", nil, 3)
    row.gwHover:SetTexture(MENU_HOVER)
    row.gwHover:SetAllPoints()
    row.gwActive = row:CreateTexture(nil, "BACKGROUND", nil, 3)
    row.gwActive:SetTexture(MENU_HOVER)
    row.gwActive:SetAllPoints()
    row.gwActiveBar = row:CreateTexture(nil, "OVERLAY")
    row.gwActiveBar:SetPoint("TOPLEFT", 0, 0)
    row.gwActiveBar:SetPoint("BOTTOMLEFT", 0, 0)
    row.gwActiveBar:SetWidth(3)
    row.gwActiveBar:SetColorTexture(GW.Colors.Accent:GetRGB())

    local function ApplyState(self, selected)
        self.gwActive:SetShown(selected)
        self.gwActiveBar:SetShown(selected)
        self.gwHover:SetShown(not selected and self.over)
        self.Label:SetFont(UNIT_NAME_FONT, MENU_SUB_FONT_SIZE, "")
        if selected then
            self.Label:SetTextColor(1, 1, 1)
        else
            self.Label:SetTextColor(unpack(MENU_TEXT_COLOR))
        end
    end
    hooksecurefunc(row, "UpdateStateInternal", ApplyState)
    ApplyState(row, false)

    local toggle = row.Toggle
    if toggle then
        toggle:GetNormalTexture():SetAlpha(0)
        toggle:GetPushedTexture():SetAlpha(0)
        toggle:GetHighlightTexture():SetAlpha(0)
        toggle.gwArrow = toggle:CreateTexture(nil, "OVERLAY")
        toggle.gwArrow:SetTexture(ARROW_RIGHT)
        toggle.gwArrow:SetSize(14, 14)
        toggle.gwArrow:SetPoint("CENTER")
        local function UpdateArrow(self, atlas)
            local open = type(atlas) == "string" and strfind(atlas, "open", 1, true)
            self.gwArrow:SetRotation(open and -1.5707 or 0)
        end
        UpdateArrow(toggle, toggle:GetNormalTexture():GetAtlas())
        hooksecurefunc(toggle, "SetNormalTexture", UpdateArrow)
    end
end

---------- controls ----------
local function SkinCheckbox(checkbox)
    if checkbox.gwSkinned then return end
    checkbox.gwSkinned = true

    checkbox:GwSkinCheckButton(false, 20)
    for _, texture in ipairs({checkbox:GetNormalTexture(), checkbox:GetPushedTexture(), checkbox:GetCheckedTexture(), checkbox:GetDisabledCheckedTexture()}) do
        if texture then
            texture:ClearAllPoints()
            texture:SetPoint("CENTER")
            texture:SetSize(20, 20)
        end
    end
end

local function SkinArrowButton(button, direction)
    if not button or button.gwSkinned then return end
    button.gwSkinned = true

    HideTextureRegions(button)
    GW.HandleNextPrevButton(button, direction, true)
end

local function SkinStepSlider(stepper)
    if stepper.gwSkinned then return end
    stepper.gwSkinned = true

    local slider = stepper.Slider
    slider:GwSkinSliderFrame()
    slider:ClearAllPoints()
    slider:SetPoint("LEFT", 19, 0)
    slider:SetPoint("RIGHT", -19, 0)
    slider:SetHeight(12)
    slider:GetThumbTexture():SetSize(16, 16)
    GW.AddSliderValueFill(slider)

    SkinArrowButton(stepper.Back, "left")
    SkinArrowButton(stepper.Forward, "right")

    local function ColorLabels(self, enabled)
        for _, label in ipairs(self.Labels or {}) do
            if enabled == false then
                label:SetVertexColor(0.5, 0.5, 0.5)
            else
                label:SetVertexColor(1, 1, 1)
            end
        end
    end
    for _, label in ipairs(stepper.Labels or {}) do
        label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    end
    ColorLabels(stepper, stepper.sliderEnabled)
    hooksecurefunc(stepper, "SetEnabled", ColorLabels)
end

local function SkinDropdownControl(control)
    if control.gwSkinned then return end
    control.gwSkinned = true

    local dropdown = control.Dropdown
    if dropdown then
        dropdown:GwHandleDropDownBox(nil, nil, nil, dropdown:GetWidth())
        if dropdown.Background then dropdown.Background:SetAlpha(0) end
        if dropdown.Arrow then dropdown.Arrow:SetAlpha(0) end
        hooksecurefunc(dropdown, "OnButtonStateChanged", function(self)
            if self:IsEnabled() then
                self.Text:SetTextColor(unpack(DROPDOWN_TEXT_COLOR))
            end
        end)
    end
    SkinArrowButton(control.DecrementButton, "left")
    SkinArrowButton(control.IncrementButton, "right")
end

local function ApplyLabel(label, enabled)
    label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    if enabled == false then
        label:SetTextColor(0.5, 0.5, 0.5)
    else
        label:SetTextColor(1, 1, 1)
    end
end

local function SkinLabel(frame, key)
    local label = frame[key]
    if not label or frame.gwLabelSkinned then return end
    frame.gwLabelSkinned = true

    ApplyLabel(label)
    if frame.Init then
        hooksecurefunc(frame, "Init", function(self) ApplyLabel(self[key]) end)
    end
    if frame.DisplayEnabled then
        hooksecurefunc(frame, "DisplayEnabled", function(self, enabled) ApplyLabel(self[key], enabled) end)
    end
end

local function SkinControl(frame)
    SkinLabel(frame, "Text")
    if frame.Checkbox then
        SkinCheckbox(frame.Checkbox)
    end
    if frame.SliderWithSteppers then
        SkinStepSlider(frame.SliderWithSteppers)
    end
    if frame.Control and frame.Control.Dropdown then
        SkinDropdownControl(frame.Control)
    end
    for _, control in ipairs(frame.Controls or {}) do
        SkinControl(control)
    end
end

local function SkinRowButton(row)
    local button = row.Button
    if button.gwSkinned then return end
    button.gwSkinned = true

    local atlas = button.Left and button.Left:GetAtlas()
    if not (atlas and strfind(atlas, "Options_ListExpand", 1, true)) then
        button:GwSkinButton(false, true)
        return
    end

    HideTextureRegions(button)
    button:SetHighlightTexture(MENU_HOVER)
    button.Text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    button.Text:GwLockTextColor(1, 1, 1)
    button.Text:ClearAllPoints()
    button.Text:SetPoint("LEFT", 12, 0)

    button.gwArrow = button:CreateTexture(nil, "OVERLAY")
    button.gwArrow:SetTexture(ARROW_DOWN)
    button.gwArrow:SetSize(16, 16)
    button.gwArrow:SetPoint("RIGHT", -10, 0)
    local function UpdateArrow(expanded)
        button.gwArrow:SetRotation(expanded and 0 or 1.5708)
    end
    if row.OnExpandedChanged then
        hooksecurefunc(row, "OnExpandedChanged", function(_, expanded) UpdateArrow(expanded) end)
    end
    hooksecurefunc(row, "Init", function(_, initializer) UpdateArrow(initializer.data and initializer.data.expanded) end)
    local ok, initializer = pcall(row.GetElementData, row)
    UpdateArrow(ok and initializer and initializer.data and initializer.data.expanded)
end

---------- settings list ----------
local function SkinBindingButton(button)
    if button.gwSkinned then return end
    button.gwSkinned = true

    HideTextureRegions(button)
    button:SetFrameLevel(button:GetFrameLevel() + 2)
    button:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
    button.backdrop:SetBackdropBorderColor(0, 0, 0)
    button:SetHighlightTexture(MENU_HOVER)
    button:GetHighlightTexture():SetAlpha(0.6)
    local text = button:GetFontString()
    if text then
        text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        text:SetTextColor(1, 1, 1)
    end
    if button.SetSelected then
        hooksecurefunc(button, "SetSelected", function(self, selected)
            if selected then
                self.backdrop:SetBackdropBorderColor(1, 0.82, 0)
            else
                self.backdrop:SetBackdropBorderColor(0, 0, 0)
            end
        end)
    end
end

local function SkinBindingFrame(frame)
    SkinLabel(frame, "Label")
    for _, key in ipairs({"Button1", "Button2", "CustomButton", "PushToTalkKeybindButton", "ToggleTest"}) do
        if frame[key] then
            SkinBindingButton(frame[key])
        end
    end
end

local function SkinSettingsRow(row)
    if row.gwSkinned then return end
    row.gwSkinned = true

    if row.Title then
        row.Title:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
        row.Title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end

    if row.NineSlice then
        row.NineSlice:SetAlpha(0)
        row:GwCreateBackdrop("Transparent")
        row.backdrop:ClearAllPoints()
        row.backdrop:SetAllPoints(row.NineSlice)
    end

    SkinControl(row)

    if row.Button then
        SkinRowButton(row)
    end

    SkinBindingFrame(row)

    if row.bindingsPool and row.EvaluateVisibility then
        local function SkinPool(self)
            for frame in self.bindingsPool:EnumerateActive() do
                SkinBindingFrame(frame)
            end
        end
        hooksecurefunc(row, "EvaluateVisibility", SkinPool)
        SkinPool(row)
    end

    if row.BaseQualityControls then
        for _, region in pairs({row:GetRegions()}) do
            if region:IsObjectType("FontString") then
                region:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
                region:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
            end
        end
        SkinTab(row.BaseTab)
        SkinTab(row.RaidTab)
        SkinControl(row.BaseQualityControls)
        SkinControl(row.RaidQualityControls)
    end
end

---------- frame ----------
local function LoadSettingsPanelSkin()
    if not GW.settings.BLIZZARD_OPTIONS_SKIN_ENABLED then return end

    local panel = SettingsPanel
    panel:GwStripTextures()
    if panel.Bg then
        panel.Bg:Hide()
    end
    local title
    if panel.NineSlice then
        panel.NineSlice:GwStripTextures()
        title = panel.NineSlice.Text
    end

    GW.CreateFrameHeaderWithBody(panel, title, "Interface/AddOns/GW2_UI/textures/character/settings-window-icon.png", {panel.CategoryList, panel.Container}, nil, false, true)
    local header = panel.gwHeader
    header.BGLEFT:ClearAllPoints()
    header.BGLEFT:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
    header.BGLEFT:SetPoint("TOPRIGHT", header, "TOPRIGHT", 0, 0)
    header.BGRIGHT:ClearAllPoints()
    header.BGRIGHT:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
    header.BGRIGHT:SetPoint("TOPLEFT", header, "TOPLEFT", 0, 0)
    panel:GwCreateBackdrop()
    panel:SetClampedToScreen(true)
    panel:SetClampRectInsets(0, 0, header:GetHeight() - 20, 0)

    panel.ClosePanelButton:GwSkinButton(true)
    panel.ClosePanelButton:SetSize(25, 25)
    panel.ClosePanelButton:ClearAllPoints()
    panel.ClosePanelButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -5, 0)
    panel.ApplyButton:GwSkinButton(false, true)
    panel.CloseButton:GwSkinButton(false, true)
    GW.SkinTextBox(panel.SearchBox.Middle, panel.SearchBox.Left, panel.SearchBox.Right)

    SkinTab(panel.GameTab)
    SkinTab(panel.AddOnsTab)
    panel.GameTab:ClearAllPoints()
    panel.GameTab:SetPoint("BOTTOMLEFT", panel.CategoryList, "TOPLEFT", 0, 0)
    panel.AddOnsTab:ClearAllPoints()
    panel.AddOnsTab:SetPoint("LEFT", panel.GameTab, "RIGHT", 2, 0)

    local function SkinExistingRows(scrollBox, skin)
        if scrollBox:GetView() then
            scrollBox:ForEachFrame(skin)
        end
    end

    local categoryList = panel.CategoryList
    GW.HandleTrimScrollBar(categoryList.ScrollBar)
    categoryList.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnAcquiredFrame, function(_, frame)
        SkinCategoryRow(frame)
    end, panel)
    SkinExistingRows(categoryList.ScrollBox, SkinCategoryRow)

    local list = panel.Container.SettingsList
    list.Header.Title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader)
    list.Header.Title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    list.Header.DefaultsButton:GwSkinButton(false, true)
    GW.HandleTrimScrollBar(list.ScrollBar)
    list.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnAcquiredFrame, function(_, frame)
        SkinSettingsRow(frame)
    end, panel)
    SkinExistingRows(list.ScrollBox, SkinSettingsRow)

    panel:HookScript("OnShow", function()
        SkinExistingRows(categoryList.ScrollBox, SkinCategoryRow)
        SkinExistingRows(list.ScrollBox, SkinSettingsRow)
    end)
end
GW.LoadSettingsPanelSkin = LoadSettingsPanelSkin
