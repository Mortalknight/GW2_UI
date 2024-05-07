local _, GW = ...
local L = GW.L

local moveable_window_placeholders_visible = true
local settings_window_open_before_change = false

local AllTags = {}
local grid

local function filterHudMovers(filter)
    if filter then
        for _, mf in pairs(GW.MOVABLE_FRAMES) do
            if string.find(mf.tags, filter, 1, true) and mf.enable then
                mf:Show()
            else
                mf:Hide()
            end
        end
    end
end

local function loadTagDropDown(tagwin)
    local USED_DROPDOWN_HEIGHT

    local offset = HybridScrollFrame_GetOffset(tagwin)

    for i = 1, #tagwin.buttons do
        local slot = tagwin.buttons[i]

        local idx = i + offset
        if idx > #AllTags then
            -- empty row (blank starter row, final row, and any empty entries)
            slot:Hide()
            slot.name = nil
        else
            slot.name = AllTags[idx]

            slot.checkbutton:Hide()
            slot.string:ClearAllPoints()
            slot.string:SetPoint("LEFT", 5, 0)
            slot.soundButton:Hide()

            slot.string:SetText(slot.name)

            slot:Show()
        end
    end

    USED_DROPDOWN_HEIGHT = 20 * #AllTags
    HybridScrollFrame_Update(tagwin, USED_DROPDOWN_HEIGHT, 120)
end

local function SetupTagDropdown(tagwin)
    HybridScrollFrame_CreateButtons(tagwin, "GwDropDownItemTmpl", 0, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
    for i = 1, #tagwin.buttons do
        local slot = tagwin.buttons[i]
        slot:SetWidth(tagwin:GetWidth())
        slot.string:SetFont(UNIT_NAME_FONT, 10)
        slot.hover:SetAlpha(0.5)
        if not slot.ScriptsHooked then
            slot:HookScript("OnClick", function(self)
                tagwin.displayButton.string:SetText(self.name)
                if tagwin.scrollContainer:IsShown() then
                    tagwin.scrollContainer:Hide()
                else
                    tagwin.scrollContainer:Show()
                end

                filterHudMovers(self.name)
            end)
            slot:HookScript("OnEnter", function()
                slot.hover:Show()
            end)
            slot.checkbutton:HookScript("OnEnter", function()
                slot.hover:Show()
            end)
            slot:HookScript("OnLeave", function()
                slot.hover:Hide()
            end)

            slot.ScriptsHooked = true
        end
    end

    loadTagDropDown(tagwin)
end

local function lockHudObjects(_, _, inCombatLockdown)
    GW.MoveHudScaleableFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
    GW.MoveHudScaleableFrame:Hide()
    if settings_window_open_before_change and not inCombatLockdown then
        settings_window_open_before_change = false
        GwSettingsWindow:Show()
    end

    if not moveable_window_placeholders_visible then
        GW.toggleHudPlaceholders()
    end
    for _, mf in ipairs(GW.MOVABLE_FRAMES) do
        mf:EnableMouse(false)
        mf:SetMovable(false)
        mf:Hide()
    end
    if GW.MoveHudScaleableFrame.moverSettingsFrame.defaultButtons.showGrid.grid then
        GW.MoveHudScaleableFrame.moverSettingsFrame.defaultButtons.showGrid.grid:Hide()
        GW.MoveHudScaleableFrame.moverSettingsFrame.defaultButtons.gridAlign:Hide()
        GW.MoveHudScaleableFrame.moverSettingsFrame.defaultButtons.showGrid.forceHide = false
        GW.MoveHudScaleableFrame.moverSettingsFrame.defaultButtons.showGrid:SetText(L["Show grid"])
    end

    -- enable main bar layout manager and trigger the changes
    GW.MoveHudScaleableFrame.layoutManager:GetScript("OnEvent")(GW.MoveHudScaleableFrame.layoutManager)
    GW.MoveHudScaleableFrame.layoutManager:SetAttribute("InMoveHudMode", false)

    GW.InMoveHudMode = false
end
GW.lockHudObjects = lockHudObjects
GW.AddForProfiling("settings", "lockHudObjects", lockHudObjects)

local function toggleHudPlaceholders()
    for _, mf in pairs(GW.MOVABLE_FRAMES) do
        if mf.backdrop then
            if moveable_window_placeholders_visible then
                mf.backdrop:Hide()
                GW.MoveHudScaleableFrame.moverSettingsFrame.defaultButtons.hidePlaceholder:SetText(L["Show placeholders"])
            else
                mf.backdrop:Show()
                GW.MoveHudScaleableFrame.moverSettingsFrame.defaultButtons.hidePlaceholder:SetText(L["Hide placeholders"])
            end
        end
    end
    moveable_window_placeholders_visible = not moveable_window_placeholders_visible
end
GW.toggleHudPlaceholders = toggleHudPlaceholders

local function moveHudObjects(self)
    GW.InMoveHudMode = true

    if GwSettingsWindow:IsShown() or settings_window_open_before_change then
        settings_window_open_before_change = true
    end
    GwSettingsWindow:Hide()
    for _, mf in pairs(GW.MOVABLE_FRAMES) do
        mf:EnableMouse(true)
        mf:SetMovable(true)
        mf:SetShown(mf.enable)
    end
    GW.MoveHudScaleableFrame.moverSettingsFrame.options:Hide()
    GW.MoveHudScaleableFrame.moverSettingsFrame.desc:Show()
    GW.MoveHudScaleableFrame:Show()

    -- disable main bar layout manager
    GW.MoveHudScaleableFrame.layoutManager:SetAttribute("InMoveHudMode", true)

    -- register event to close move hud in combat
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
end
GW.moveHudObjects = moveHudObjects

local function HandleMoveHudEvents(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        GW.Notice(L["You can not move elements during combat!"])
        self:UnregisterEvent(event)
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        lockHudObjects(self, nil, true)
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent(event)
        moveHudObjects(self)
    end
end

local function Grid_GetRegion()
    if grid then
        if grid.regionCount and grid.regionCount > 0 then
            local line = select(grid.regionCount, grid:GetRegions())
            grid.regionCount = grid.regionCount - 1
            line:SetAlpha(1)
            return line
        else
            return grid:CreateTexture()
        end
    end
end

local function create_grid(mhgb)
    if not grid then
        grid = CreateFrame("Frame", "GW2_Grid", UIParent)
        grid:SetFrameStrata("BACKGROUND")
    else
        grid.regionCount = 0
        for _, region in next, { grid:GetRegions() } do
            if region and region.IsObjectType and region:IsObjectType("Texture") then
                grid.regionCount = grid.regionCount + 1
                region:SetAlpha(0)
            end
        end
    end

    local width, height = UIParent:GetSize()
    local size, half = GW.mult * 0.5, height * 0.5

    local gSize = mhgb.gridSize
    local gHalf = gSize * 0.5

    local ratio = width / height
    local hHeight = height * ratio
    local wStep = width / gSize
    local hStep = hHeight / gSize

    grid.boxSize = gSize
    grid:SetPoint("CENTER", UIParent)
    grid:SetSize(width, height)
    grid:Hide()

    for i = 0, gSize do
        local tx = Grid_GetRegion()
        if i == gHalf then
            tx:SetColorTexture(1, 0, 0)
            tx:SetDrawLayer("BACKGROUND", 1)
        else
            tx:SetColorTexture(0, 0, 0)
            tx:SetDrawLayer("BACKGROUND", 0)
        end
        local iwStep = i * wStep
        tx:ClearAllPoints()
        tx:SetPoint("TOPLEFT", grid, "TOPLEFT", iwStep - size, 0)
        tx:SetPoint("BOTTOMRIGHT", grid, "BOTTOMLEFT", iwStep + size, 0)
    end

    do
        local tx = Grid_GetRegion()
        tx:SetColorTexture(1, 0, 0)
        tx:SetDrawLayer("BACKGROUND", 1)
        tx:ClearAllPoints()
        tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -half + size)
        tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(half + size))
    end

    local hSteps = floor((height * 0.5) / hStep)
    for i = 1, hSteps do
        local ihStep = i * hStep

        local tx = Grid_GetRegion()
        tx:SetColorTexture(0, 0, 0)
        tx:SetDrawLayer("BACKGROUND", 0)
        tx:ClearAllPoints()
        tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(half+ihStep) + size)
        tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(half+ihStep + size))

        tx = Grid_GetRegion()
        tx:SetColorTexture(0, 0, 0)
        tx:SetDrawLayer("BACKGROUND", 0)
        tx:ClearAllPoints()
        tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(half-ihStep) + size)
        tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(half-ihStep + size))
    end
end

local function Grid_Show_Hide(self)
    local self = self:GetParent()
    if self.showGrid.forceHide then
        if grid then
            grid:Hide()
        end
        self.gridAlign:Hide()
        self.showGrid.forceHide = false
        self.showGrid:SetText(L["Show grid"])
    else
        if not grid then
            create_grid(self.showGrid)
        elseif grid.boxSize ~= self.showGrid.gridSize then
            grid:Hide()
            create_grid(self.showGrid)
        end
        self.gridAlign:Show()
        grid:Show()
        self.showGrid.forceHide = true
        self.showGrid:SetText(L["Hide grid"])
    end
end

local function UpdateMatchingLayout(self, new_point)
    local selectedLayoutName = GwSmallSettingsContainer.layoutView.savedLayoutDropDown.button.selectedName
    local layout = selectedLayoutName and GW.GetLayoutByName(selectedLayoutName) or nil
    local frameFound = false
    if layout then
        for i = 0, #layout.frames do
            if layout.frames[i] and layout.frames[i].settingName == self.setting then
                layout.frames[i].point = nil
                layout.frames[i].point = GW.copyTable(nil, new_point)

                frameFound = true
                break
            end
        end

        -- could be a new moveable frame which is not at the layout settings, so we need to add it here
        if not frameFound then
            local newIdx = #layout.frames + 1
            layout.frames[newIdx] = {}
            layout.frames[newIdx].settingName = self.setting
            layout.frames[newIdx].point = GW.copyTable(nil, new_point)
        end
    end
end

local function smallSettings_resetToDefault(self, _,  moverFrame)
    local mf = moverFrame and moverFrame or self:GetParent():GetParent().child

    mf:ClearAllPoints()
    mf:SetPoint(
        mf.defaultPoint.point,
        UIParent,
        mf.defaultPoint.relativePoint,
        mf.defaultPoint.xOfs,
        mf.defaultPoint.yOfs
    )

    local new_point = GW.settings[mf.setting]
    new_point.point = mf.defaultPoint.point
    new_point.relativePoint = mf.defaultPoint.relativePoint
    new_point.xOfs = mf.defaultPoint.xOfs
    new_point.yOfs = mf.defaultPoint.yOfs
    new_point.hasMoved = false
    GW.settings[mf.setting] = new_point

    mf.parent.isMoved = false
    mf.parent:SetAttribute("isMoved", new_point.hasMoved)

    --if 'PlayerBuffFrame' or 'PlayerDebuffFrame', set also the grow direction, h,v spacing, auras per row and max wraps to default
    if mf.setting == "PlayerBuffFrame" or mf.setting == "PlayerDebuffFrame" then
        -- reset also the settings frame values
        GW.updateSettingsFrameSettingsValue(mf.setting .. "_GrowDirection", "UP", true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. "_HorizontalSpacing", 1, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. "_VerticalSpacing", 34, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. "_MaxWraps", 3, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. "_MaxWraps", 3, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. "_ICON_SIZE", 32, true)
        if mf.setting == "PlayerBuffFrame" then
            GW.updateSettingsFrameSettingsValue("PLAYER_AURA_WRAP_NUM", 7, true)
        elseif mf.setting == "PlayerDebuffFrame" then
            GW.updateSettingsFrameSettingsValue("PLAYER_AURA_WRAP_NUM_DEBUFF", 7, true)
        end
        GW.UpdateAuraHeader(mf.parent, mf.setting)
    elseif mf.setting == "MicromenuPos" then
        -- Hide/Show BG here
        mf.parent.cf.bg:Show()
    end

    -- Set Scale back to default
    if mf.optionScaleable then
        local scale
        if mf.mainHudFrame then
            scale = GW.settings.HUD_SCALE
        else
            scale = GW.globalDefault.profile[mf.setting .. "_scale"]
        end
        mf:SetScale(scale)
        mf.parent:SetScale(scale)
        GW.settings[mf.setting .. "_scale"] = scale
        if self then
            self:GetParent():GetParent().options.scaleSlider.slider:SetValue(scale)
        end
    end

    -- Set height back to default
    if mf.optionHeight then
        local height = GW.globalDefault.profile[mf.setting .. "_height"]
        mf:SetHeight(height)
        mf.parent:SetHeight(height)
        GW.settings[mf.setting .. "_height"] = height
        if self then
            self:GetParent():GetParent().options.heightSlider.slider:SetValue(height)
        end
    end

    if mf.postdrag then
        mf.postdrag(mf.parent)
    end

    GW.UpdateHudScale()

    --also update the selected layout
    UpdateMatchingLayout(mf, new_point)

    -- run layout manager
    GwSmallSettingsContainer.layoutManager:SetAttribute("inMoveHudMode", false)
    GwSmallSettingsContainer.layoutManager:GetScript("OnEvent")(GwSmallSettingsContainer.layoutManager)
    GwSmallSettingsContainer.layoutManager:SetAttribute("inMoveHudMode", true)
end
GW.ResetMoverFrameToDefaultValues = smallSettings_resetToDefault
GW.AddForProfiling("index", "smallSettings_resetToDefault", smallSettings_resetToDefault)

local function lockFrame_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    GameTooltip:SetText(SYSTEM_DEFAULT, 1, 1, 1)
    GameTooltip:Show()
end
GW.AddForProfiling("index", "lockFrame_OnEnter", lockFrame_OnEnter)

local function mover_OnDragStart(self)
    self.IsMoving = true
    self:StartMoving()
end
GW.AddForProfiling("index", "mover_OnDragStart", mover_OnDragStart)

local function mover_OnDragStop(self)
    local settingsName = self.setting
    self:StopMovingOrSizing()
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()

    -- for layouts: if newPoint is old point, do not update the setting
    if self.savedPoint.point ~= point or self.savedPoint.relativePoint ~= relativePoint or self.savedPoint.xOfs ~= xOfs or self.savedPoint.yOfs ~= yOfs then
        local new_point = GW.settings[settingsName]
        new_point.point = point
        new_point.relativePoint = relativePoint
        new_point.xOfs = xOfs and GW.RoundInt(xOfs) or 0
        new_point.yOfs = yOfs and GW.RoundInt(yOfs) or 0

        -- check if frame moved or back at default position
        if self.defaultPoint.point == point and self.defaultPoint.relativePoint == relativePoint and self.defaultPoint.xOfs == xOfs and self.defaultPoint.yOfs == yOfs then
            new_point.hasMoved = false
        else
            new_point.hasMoved = true
        end
        self:ClearAllPoints()
        self:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
        GW.settings[settingsName] = new_point
        self.savedPoint = GW.copyTable(nil, new_point)

        self.parent.isMoved = new_point.hasMoved
        self.parent:SetAttribute("isMoved", new_point.hasMoved)

        self:SetMovable(true)
        self:SetUserPlaced(true)

        --also update the selected layout
        UpdateMatchingLayout(self, new_point)
    end

    if self.postdrag then
        self.postdrag(self.parent)
    end
    self.IsMoving = false
end
GW.AddForProfiling("index", "mover_OnDragStop", mover_OnDragStop)

local function showExtraOptions(self)
    GW.MoveHudScaleableFrame.moverSettingsFrame.child = self
    GW.MoveHudScaleableFrame.moverSettingsFrame.childMover = self
    GW.MoveHudScaleableFrame.headerString:SetText(self.textString .. " & Layouts")
    GW.MoveHudScaleableFrame.moverSettingsFrame.desc:Hide()
    GW.MoveHudScaleableFrame.moverSettingsFrame.options:Show()
    -- options
    GW.MoveHudScaleableFrame.moverSettingsFrame.options.scaleSlider:SetShown(self.optionScaleable)
    GW.MoveHudScaleableFrame.moverSettingsFrame.options.heightSlider:SetShown(self.optionHeight)
    if self.optionScaleable then
        local scale = GW.settings[self.setting .. "_scale"]
        GW.MoveHudScaleableFrame.moverSettingsFrame.options.scaleSlider.slider:SetValue(scale)
        GW.MoveHudScaleableFrame.moverSettingsFrame.options.scaleSlider.input:SetText(scale)
    end
    if self.optionHeight then
        local height = GW.settings[self.setting .. "_height"]
        GW.MoveHudScaleableFrame.moverSettingsFrame.options.heightSlider.slider:SetValue(height)
        GW.MoveHudScaleableFrame.moverSettingsFrame.options.heightSlider.input:SetText(height)
    end

    if GW.MoveHudScaleableFrame.moverSettingsFrame.activeFlasher then
        GW.StopFlash(GW.MoveHudScaleableFrame.moverSettingsFrame.activeFlasher)
        UIFrameFadeOut(GW.MoveHudScaleableFrame.moverSettingsFrame.activeFlasher, 0.5, GW.MoveHudScaleableFrame.moverSettingsFrame.activeFlasher:GetAlpha(), 0.5)
    end
    GW.MoveHudScaleableFrame.moverSettingsFrame.activeFlasher = self
    GW.FrameFlash(self, 1.5, 0.5, 1, true)
end

local function hideExtraOptions()
    GW.MoveHudScaleableFrame.moverSettingsFrame.child = nil
    GW.MoveHudScaleableFrame.moverSettingsFrame.childMover = nil
    GW.MoveHudScaleableFrame.headerString:SetText(L["Extra Frame Options"] .. " & Layouts")
    GW.MoveHudScaleableFrame.moverSettingsFrame.options:Hide()
    GW.MoveHudScaleableFrame.moverSettingsFrame.desc:SetText(L["Left click on a moverframe to show extra frame options"])
    GW.MoveHudScaleableFrame.moverSettingsFrame.desc:Show()
    GW.StopFlash(GW.MoveHudScaleableFrame.moverSettingsFrame.activeFlasher)
end

local function mover_options(self)
    if GW.MoveHudScaleableFrame.moverSettingsFrame.child == self then
        hideExtraOptions()
    else
        showExtraOptions(self)
    end
end

local function sliderValueChange(self)
    local roundValue = GW.RoundDec(self:GetValue(), 2)
    local moverFrame = self:GetParent():GetParent():GetParent().child
    moverFrame:SetScale(roundValue)
    moverFrame.parent:SetScale(roundValue)
    self:GetParent().input:SetText(roundValue)
    GW.settings[moverFrame.setting .."_scale"] = roundValue

    moverFrame.parent.isMoved = true
    moverFrame.parent:SetAttribute("isMoved", true)
end

local function sliderEditBoxValueChanged(self)
    local roundValue = GW.RoundDec(self:GetNumber(), 2) or 0.5
    local moverFrame = self:GetParent():GetParent():GetParent().child

    self:ClearFocus()
    if tonumber(roundValue) > 1.5 then self:SetText(1.5) end
    if tonumber(roundValue) < 0.5 then self:SetText(0.5) end
    roundValue = GW.RoundDec(self:GetNumber(), 2) or 0.5

    self:GetParent().slider:SetValue(roundValue)
    self:SetText(roundValue)
    GW.settings[moverFrame.setting .. "_scale"] = roundValue

    moverFrame.parent.isMoved = true
    moverFrame.parent:SetAttribute("isMoved", true)
end

local function heightSliderValueChange(self)
    local roundValue = GW.RoundDec(self:GetValue())
    local moverFrame = self:GetParent():GetParent():GetParent().child
    moverFrame:SetHeight(roundValue)
    moverFrame.parent:SetHeight(roundValue)
    self:GetParent().input:SetText(roundValue)
    GW.settings[moverFrame.setting .."_height"] = roundValue
end

local function heightEditBoxValueChanged(self)
    local roundValue = GW.RoundDec(self:GetNumber()) or 1
    local moverFrame = self:GetParent():GetParent():GetParent().child

    self:ClearFocus()
    if tonumber(roundValue) > 1500 then self:SetText(1500) end
    if tonumber(roundValue) < 1 then self:SetText(1) end

    GW.settings[moverFrame.setting .."_height"] = roundValue

    moverFrame.parent:SetHeight(roundValue)
    moverFrame:SetHeight(roundValue)
end

local function moverframe_OnEnter(self)
    if self.IsMoving then
        return
    end

    for _, moverframe in pairs(GW.MOVABLE_FRAMES) do
        if moverframe:IsShown() and moverframe ~= self then
            UIFrameFadeOut(moverframe, 0.5, moverframe:GetAlpha(), 0.5)
        end
    end
end

local function moverframe_OnLeave(self)
    if self.IsMoving then
        return
    end

    for _, moverframe in pairs(GW.MOVABLE_FRAMES) do
        if moverframe:IsShown() and moverframe ~= self then
            UIFrameFadeIn(moverframe, 0.5, moverframe:GetAlpha(), 1)
        end
    end
end

local function CreateMoverFrame(parent, displayName, settingsName, size, frameOptions, mhf, postdrag, tags)
    local mf = CreateFrame("Button", "Gw_" .. settingsName, UIParent, "SecureHandlerStateTemplate")
    mf:SetClampedToScreen(true)
    mf:SetMovable(true)
    mf:EnableMouseWheel(true)
    mf:RegisterForDrag("LeftButton", "RightButton")
    mf:SetFrameLevel(parent:GetFrameLevel() + 1)
    mf:SetFrameStrata("DIALOG")
    mf:GwCreateBackdrop("Transparent White")
    mf:SetScale(parent:GetScale())

    if size then
        mf:SetSize(unpack(size))
    else
        mf:SetSize(parent:GetSize())
    end
    mf:Hide()

    local fs = mf:CreateFontString(nil, 'OVERLAY')
    fs:SetFont(UNIT_NAME_FONT, 12, "")
    fs:SetPoint("CENTER")
    fs:SetText(displayName)
    fs:SetJustifyH("CENTER")
    fs:SetTextColor(1, 1, 1)
    mf:SetFontString(fs)

    mf.text = fs
    mf.parent = parent
    mf.postdrag = postdrag
    mf.textString = displayName
    mf.setting = settingsName
    mf.mainHudFrame = mhf
    mf.frameOptions = frameOptions
    mf.savedPoint = GW.settings[settingsName]
    mf.defaultPoint = GW.globalDefault.profile[settingsName]
    mf.tags = tags

    for _, v in pairs({strsplit(",", tags)}) do
        if not tContains(AllTags, v) then
            tinsert(AllTags, v)
            SetupTagDropdown(GwSmallSettingsContainer.moverSettingsFrame.defaultButtons.tagDropdown.container.contentScroll)
        end
    end

    -- set all options default as false
    mf.optionScaleable = false
    mf.optionHeight = false

    for _, v in pairs(frameOptions) do
        if v == "scaleable" then
            local scale = GW.settings[settingsName .. "_scale"]
            mf.parent:SetScale(scale)
            mf:SetScale(scale)
            GW.scaleableFrames[#GW.scaleableFrames + 1] = mf

            mf.optionScaleable = true
        elseif v == "height" then
            local height = GW.settings[settingsName .. "_height"]
            mf.parent:SetHeight(height)
            mf:SetHeight(height)

            mf.optionHeight = true
        end
    end

    parent.gwMover = mf

    mf:SetScript("OnDragStart", mover_OnDragStart)
    mf:SetScript("OnDragStop", mover_OnDragStop)
    mf:SetScript("OnEnter", moverframe_OnEnter)
    mf:SetScript("OnLeave", moverframe_OnLeave)
    mf:SetScript("OnClick", mover_options)

    if mhf then
        GW.scaleableMainHudFrames[#GW.scaleableMainHudFrames + 1] = mf
    end

    if postdrag then
        mf:RegisterEvent("PLAYER_ENTERING_WORLD")
        mf:SetScript("OnEvent", function(self)
            postdrag(self.parent)
            self:UnregisterAllEvents()
        end)
    end

    mf.enable = true

    GW.MOVABLE_FRAMES[#GW.MOVABLE_FRAMES + 1] = mf

    return mf
end

local function RegisterMovableFrame(frame, displayName, settingsName, tags, size, frameOptions, mhf, postdrag)
    local moveframe = CreateMoverFrame(frame, displayName, settingsName, size, frameOptions, mhf, postdrag, tags)

    moveframe:ClearAllPoints()
    if not moveframe.savedPoint.point or not moveframe.savedPoint.relativePoint or not moveframe.savedPoint.xOfs or not moveframe.savedPoint.yOfs then
        -- use default position
        moveframe:SetPoint(moveframe.defaultPoint.point, UIParent, moveframe.defaultPoint.relativePoint, moveframe.defaultPoint.xOfs, moveframe.defaultPoint.yOfs)
        moveframe.savedPoint = GW.copyTable(nil, moveframe.defaultPoint)
    else
        moveframe:SetPoint(moveframe.savedPoint.point, UIParent, moveframe.savedPoint.relativePoint, moveframe.savedPoint.xOfs, moveframe.savedPoint.yOfs)
    end

    if moveframe.savedPoint.hasMoved == nil then -- can be removed after some time
        if moveframe.defaultPoint.point == moveframe.savedPoint.point and moveframe.defaultPoint.relativePoint == moveframe.savedPoint.relativePoint and moveframe.defaultPoint.xOfs == moveframe.savedPoint.xOfs and moveframe.defaultPoint.yOfs == moveframe.savedPoint.yOfs then
            frame.isMoved = false
            frame:SetAttribute("isMoved", false)
        else
            frame.isMoved = true
            frame:SetAttribute("isMoved", true)
        end
    elseif moveframe.savedPoint.hasMoved ~= nil then
        frame.isMoved = moveframe.savedPoint.hasMoved
        frame:SetAttribute("isMoved", moveframe.savedPoint.hasMoved)
    end

    --temp to migrate to new isMoved system
    if moveframe.savedPoint.hasMoved == nil then
        moveframe.savedPoint.hasMoved = frame.isMoved
        GW.settings[settingsName] = moveframe.savedPoint
    end
end
GW.RegisterMovableFrame = RegisterMovableFrame

local function MoveFrameByPixel(nudgeX, nudgeY)
    local mover = GwSmallSettingsContainer.moverSettingsFrame.childMover

    local point, _, anchorPoint, x, y = mover:GetPoint()
    x = x + nudgeX
    y = y + nudgeY
    mover:ClearAllPoints()
    mover:SetPoint(point, UIParent, anchorPoint, x, y)

    mover_OnDragStop(mover)
end

local function ToggleMover(frame, toggle)
    for _, moveableFrame in pairs(GW.MOVABLE_FRAMES) do
        if moveableFrame == frame then
            moveableFrame.enable = toggle
            break
        end
    end
end
GW.ToggleMover = ToggleMover

local function LoadMovers(layoutManager)
    -- Create mover settings frame
    local fnMf_OnDragStart = function(self)
        self:StartMoving()
    end
    local fnMf_OnDragStop = function(self)
        self:StopMovingOrSizing()
    end
    local mf = CreateFrame("Frame", "GwSmallSettingsMoverFrame", UIParent, "GwSmallSettingsMoverFrame")
    mf:RegisterForDrag("LeftButton")
    mf:SetScript("OnDragStart", fnMf_OnDragStart)
    mf:SetScript("OnDragStop", fnMf_OnDragStop)

    local smallSettingsContainer = CreateFrame("Frame", "GwSmallSettingsContainer", UIParent, "GwSmallSettingsContainer")
    smallSettingsContainer.moverSettingsFrame = CreateFrame("Frame", "GwSmallSettingsWindow", smallSettingsContainer, "GwSmallSettings")
    GW.MoveHudScaleableFrame = smallSettingsContainer
    smallSettingsContainer.layoutManager = layoutManager

    tinsert(UISpecialFrames, "GwSmallSettingsContainer")

    --set correct separator rotation
    local angle = math.rad(90)
    local cos, sin = math.cos(angle), math.sin(angle)
    smallSettingsContainer.seperator:SetTexCoord((sin - cos), -(cos + sin), -cos, -sin, sin, -cos, 0, 0)

    smallSettingsContainer.headerString:SetFont(UNIT_NAME_FONT, 14, "")
    smallSettingsContainer.headerString:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    smallSettingsContainer.headerString:SetText(L["Extra Frame Options"] .. " & Layouts")

    smallSettingsContainer.moverSettingsFrame.options.scaleSlider.slider:SetMinMaxValues(0.5, 1.5)
    smallSettingsContainer.moverSettingsFrame.options.scaleSlider.slider:SetValue(1)
    smallSettingsContainer.moverSettingsFrame.options.scaleSlider.slider:SetScript("OnValueChanged", sliderValueChange)
    smallSettingsContainer.moverSettingsFrame.options.scaleSlider.input:SetText(1)
    smallSettingsContainer.moverSettingsFrame.options.scaleSlider.input:SetFont(UNIT_NAME_FONT, 8, "")
    smallSettingsContainer.moverSettingsFrame.options.scaleSlider.input:SetScript("OnEnterPressed", sliderEditBoxValueChanged)

    smallSettingsContainer.moverSettingsFrame.options.heightSlider.slider:SetMinMaxValues(1, 1500)
    smallSettingsContainer.moverSettingsFrame.options.heightSlider.slider:SetValue(1)
    smallSettingsContainer.moverSettingsFrame.options.heightSlider.slider:SetScript("OnValueChanged", heightSliderValueChange)
    smallSettingsContainer.moverSettingsFrame.options.heightSlider.input:SetText(1)
    smallSettingsContainer.moverSettingsFrame.options.heightSlider.input:SetFont(UNIT_NAME_FONT, 7, "")
    smallSettingsContainer.moverSettingsFrame.options.heightSlider.input:SetScript("OnEnterPressed", heightEditBoxValueChanged)

    smallSettingsContainer.moverSettingsFrame.desc:SetText(L["Left click on a moverframe to show extra frame options"])
    smallSettingsContainer.moverSettingsFrame.desc:SetFont(UNIT_NAME_FONT, 12, "")
    smallSettingsContainer.moverSettingsFrame.desc:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    smallSettingsContainer.moverSettingsFrame.options.scaleSlider.title:SetFont(UNIT_NAME_FONT, 12, "")
    smallSettingsContainer.moverSettingsFrame.options.scaleSlider.title:SetText(L["Scale"])
    smallSettingsContainer.moverSettingsFrame.options.heightSlider.title:SetFont(UNIT_NAME_FONT, 12, "")
    smallSettingsContainer.moverSettingsFrame.options.heightSlider.title:SetText(COMPACT_UNIT_FRAME_PROFILE_FRAMEHEIGHT)

    smallSettingsContainer.moverSettingsFrame.options.movers.title:SetText(NPE_MOVE )
    smallSettingsContainer.moverSettingsFrame.options.movers.title:SetFont(UNIT_NAME_FONT, 12, "")
    GW.HandleNextPrevButton(smallSettingsContainer.moverSettingsFrame.options.movers.left, "left")
    GW.HandleNextPrevButton(smallSettingsContainer.moverSettingsFrame.options.movers.right, "right")
    GW.HandleNextPrevButton(smallSettingsContainer.moverSettingsFrame.options.movers.up, "up")
    GW.HandleNextPrevButton(smallSettingsContainer.moverSettingsFrame.options.movers.down, "down")
    smallSettingsContainer.moverSettingsFrame.options.movers.left:SetScript("OnClick", function() MoveFrameByPixel(-1, 0) end)
    smallSettingsContainer.moverSettingsFrame.options.movers.right:SetScript("OnClick", function() MoveFrameByPixel(1, 0) end)
    smallSettingsContainer.moverSettingsFrame.options.movers.up:SetScript("OnClick", function() MoveFrameByPixel(0, 1) end)
    smallSettingsContainer.moverSettingsFrame.options.movers.down:SetScript("OnClick", function() MoveFrameByPixel(0, -1) end)

    smallSettingsContainer:SetScript("OnShow", function()
        mf:Show()
    end)
    smallSettingsContainer:SetScript("OnHide", function()
        lockHudObjects()
        mf:Hide()
    end)
    smallSettingsContainer:SetScript("OnEvent", HandleMoveHudEvents)

    smallSettingsContainer.moverSettingsFrame.options.default:SetScript("OnClick", smallSettings_resetToDefault)

    -- lock, placeholder and grid button
    smallSettingsContainer.moverSettingsFrame.defaultButtons.lockHud:SetScript("OnClick", lockHudObjects)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.lockHud:SetText(L["Lock HUD"])

    smallSettingsContainer.moverSettingsFrame.defaultButtons.hidePlaceholder:SetScript("OnClick", toggleHudPlaceholders)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.hidePlaceholder:SetText(L["Hide placeholders"])

    smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid:SetScript("OnClick", Grid_Show_Hide)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid:SetText(L["Show grid"])
    smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid.gridSize = 64
    smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid.forceHide = false

    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridAlign.input:SetScript("OnEscapePressed", function(eb)
        eb:SetText(smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid.gridSize)
        EditBox_ClearFocus(eb)
    end)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridAlign.input:SetScript("OnEnterPressed", function(eb)
        local text = eb:GetText()
        if tonumber(text) then
            if tonumber(text) <= 256 and tonumber(text) >= 4 then
                smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid.gridSize = tonumber(text)
            else
                eb:SetText(smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid.gridSize)
            end
        else
            eb:SetText(smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid.gridSize)
        end
        smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid.forceHide = false
        Grid_Show_Hide(smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid)
        EditBox_ClearFocus(eb)
    end)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridAlign.input:SetScript("OnEditFocusLost", function(eb)
        eb:SetText(smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid.gridSize)
    end)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridAlign.input:SetScript("OnEditFocusGained", smallSettingsContainer.moverSettingsFrame.defaultButtons.gridAlign.HighlightText)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridAlign.input:SetScript("OnShow", function(eb)
        EditBox_ClearFocus(eb)
        eb:SetText(smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid.gridSize)
    end)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridAlign.text:SetText(L["Grid Size:"])
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridAlign:Hide()

    --load tag dropdown
    smallSettingsContainer.moverSettingsFrame.defaultButtons.tagDropdown.title:SetFont(DAMAGE_TEXT_FONT, 12)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.tagDropdown.title:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.tagDropdown.title:SetText(L["Filter"])
    local tagScrollFrame = smallSettingsContainer.moverSettingsFrame.defaultButtons.tagDropdown.container.contentScroll
    tagScrollFrame.scrollBar.thumbTexture:SetSize(12, 30)
    tagScrollFrame.scrollBar:ClearAllPoints()
    tagScrollFrame.scrollBar:SetPoint("TOPRIGHT", -3, -12)
    tagScrollFrame.scrollBar:SetPoint("BOTTOMRIGHT", -3, 12)
    tagScrollFrame.scrollBar.scrollUp:SetPoint("TOPRIGHT", 0, 12)
    tagScrollFrame.scrollBar.scrollDown:SetPoint("BOTTOMRIGHT", 0, -12)
    tagScrollFrame.scrollBar:SetFrameLevel(tagScrollFrame:GetFrameLevel() + 5)
    tagScrollFrame.scrollContainer = smallSettingsContainer.moverSettingsFrame.defaultButtons.tagDropdown.container
    tagScrollFrame.displayButton = smallSettingsContainer.moverSettingsFrame.defaultButtons.tagDropdown.button
    tagScrollFrame:GetParent():SetParent(smallSettingsContainer.moverSettingsFrame.defaultButtons)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.tagDropdown.button.string:SetText(ALL)

    tagScrollFrame.update = loadTagDropDown
    tagScrollFrame.scrollBar.doNotHide = false
    SetupTagDropdown(tagScrollFrame)

    smallSettingsContainer.moverSettingsFrame.defaultButtons.tagDropdown.button:SetScript("OnClick", function(self)
        local dd = self:GetParent()
        if dd.container:IsShown() then
            dd.container:Hide()
        else
            dd.container:Show()
        end
    end)

    --Layout
    GW.LoadLayoutsFrame(smallSettingsContainer, layoutManager)

    smallSettingsContainer:Hide()
    mf:Hide()
end
GW.LoadMovers = LoadMovers
