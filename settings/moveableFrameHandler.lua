local _, GW = ...
local L = GW.L

local moveable_window_placeholders_visible = true
local settings_window_open_before_change = false

local allTags, allTagsSet = {}, {}
local selectedTag = ALL
local grid

local function AddTagsCSV(tags)
    tags = tags or ""
    for _, v in pairs({strsplit(",", tags)}) do
        v = strtrim(v)
        if v ~= "" and not allTagsSet[v] then
            allTagsSet[v] = true
            tinsert(allTags, v)
            -- markiere Dropdown zum Neuaufbau
            if GwSmallSettingsContainer and GwSmallSettingsContainer.moverSettingsFrame then
                local dd = GwSmallSettingsContainer.moverSettingsFrame.defaultButtons.tagDropdown
                if dd then dd.needsRebuild = true end
            end
        end
    end
end

local function filterHudMovers(filter)
    selectedTag = filter
    for _, mf in ipairs(GW.MOVABLE_FRAMES) do
        local show = mf.enable
        if show and filter and mf.tagsSet then
            show = mf.tagsSet[filter] == true
        end
        mf:SetShown(show)
    end
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

    GW.GridToggle(_, _, true)

    -- enable main bar layout manager and trigger the changes
    GW.MoveHudScaleableFrame.layoutManager:GetScript("OnEvent")(GW.MoveHudScaleableFrame.layoutManager)
    GW.MoveHudScaleableFrame.layoutManager:SetAttribute("InMoveHudMode", false)

    GW.InMoveHudMode = false
end
GW.lockHudObjects = lockHudObjects
GW.AddForProfiling("settings", "lockHudObjects", lockHudObjects)

local function toggleHudPlaceholders()
    local show = not moveable_window_placeholders_visible

    for _, mf in ipairs(GW.MOVABLE_FRAMES) do
        if mf.backdrop then
            if show then mf.backdrop:Show() else mf.backdrop:Hide() end
        end
    end
    local btn = GW.MoveHudScaleableFrame.moverSettingsFrame.defaultButtons.hidePlaceholder
    btn:SetText(show and L["Hide placeholders"] or L["Show placeholders"])

    moveable_window_placeholders_visible = show
end
GW.toggleHudPlaceholders = toggleHudPlaceholders

local function moveHudObjects(self)
    GW.InMoveHudMode = true

    if GwSettingsWindow:IsShown() or settings_window_open_before_change then
        settings_window_open_before_change = true
    end
    GwSettingsWindow:Hide()
    for _, mf in ipairs(GW.MOVABLE_FRAMES) do
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

local function Acquire(frame, pool)
    local tx = pool[#pool]
    if tx then
        pool[#pool] = nil
        tx:Show()
        return tx
    end
    tx = frame:CreateTexture(nil, "BACKGROUND")
    return tx
end

local function CreateGrid()
    if not grid then
        grid = CreateFrame("Frame", "GW2_UIIGrid", UIParent)
        grid:SetFrameStrata("BACKGROUND")
        grid.vPool, grid.hPool, grid.activeV, grid.activeH = {}, {}, {}, {}
    end

    local width, height = UIParent:GetSize()
    local size = math.max(GW.mult * 0.5, 0.5)  -- Min 0.5 pixel
    local gSize = GW.settings.gridSpacing
    local step = math.max(2, math.min(width, height) / gSize)
    local halfW, halfH = width * 0.5, height * 0.5

    grid.boxSize = gSize
    grid:SetPoint("CENTER", UIParent)
    grid:SetSize(width, height)
    grid:Show()

    for _, t in ipairs(grid.activeV) do t:Hide(); grid.vPool[#grid.vPool + 1] = t end
    for _, t in ipairs(grid.activeH) do t:Hide(); grid.hPool[#grid.hPool + 1] = t end
    wipe(grid.activeV)
    wipe(grid.activeH)

    -- Vertical lines
    local cols = math.floor(width / step / 2)
    for i = -cols, cols do
        local x = i * step
        local tx = Acquire(grid, grid.vPool)
        local isCenter = (i == 0)
        tx:SetColorTexture(isCenter and 1 or 0, 0, 0, 1)
        tx:SetDrawLayer("BACKGROUND", isCenter and 1 or 0)
        tx:ClearAllPoints()
        tx:SetPoint("TOP", grid, "CENTER", x, halfH)
        tx:SetPoint("BOTTOM", grid, "CENTER", x, -halfH)
        tx:SetWidth(size)
        grid.activeV[#grid.activeV+1] = tx
    end

    -- horizontal lines
    local rows = math.floor(height / step / 2)
    for i = -rows, rows do
        local y = i * step
        local tx = Acquire(grid, grid.hPool)
        local isCenter = (i == 0)
        tx:SetColorTexture(isCenter and 1 or 0, 0, 0, 1)
        tx:SetDrawLayer("BACKGROUND", isCenter and 1 or 0)
        tx:ClearAllPoints()
        tx:SetPoint("LEFT", grid, "CENTER", -halfW, y)
        tx:SetPoint("RIGHT", grid, "CENTER", halfW, y)
        tx:SetHeight(size)
        grid.activeH[#grid.activeH+1] = tx
    end
end

local function ShowGrid()
    if not grid then
        CreateGrid()
    elseif grid.boxSize ~= GW.settings.gridSpacing then
        grid:Hide()
        CreateGrid()
    else
        grid:Show()
    end
end

local function HideGrid()
    if grid then
        grid:Hide()
    end
end

local function GridToggle(_, _, forceClose)
    if InCombatLockdown() then return end
    local show = not (grid and grid:IsShown())

    if show and not forceClose then
        ShowGrid()
        GwSmallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider:Show()
        GwSmallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid:SetText(L["Hide grid"])
    else
        HideGrid()
        GwSmallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider:Hide()
        GwSmallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid:SetText(L["Show grid"])
    end
end
GW.GridToggle = GridToggle

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

    --if "PlayerBuffFrame" or "PlayerDebuffFrame", set also the grow direction, h,v spacing, auras per row and max wraps to default
    if mf.setting == "PlayerBuffFrame" or mf.setting == "PlayerDebuffFrame" then
        -- reset also the settings frame values
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".Seperate", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".SortDir", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".SortMethod", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".IconSize", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".IconHeight", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".KeepSizeRatio", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".GrowDirection", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".HorizontalSpacing", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".VerticalSpacing", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".MaxWraps", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".WrapAfter", nil, nil, true)
        GW.updateSettingsFrameSettingsValue(mf.setting .. ".NewAuraAnimation", nil, nil, true)
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
    GW.UpdateMatchingLayout(mf, new_point)

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

local function CheckForDefaultPosition(frame, point, relativePoint, xOfs, yOfs, newPoint)
    if frame.defaultPoint.point == point and frame.defaultPoint.relativePoint == relativePoint and frame.defaultPoint.xOfs == xOfs and frame.defaultPoint.yOfs == yOfs then
        newPoint.hasMoved = false
    else
        newPoint.hasMoved = true
    end

    frame.parent.isMoved = newPoint.hasMoved
    frame.parent:SetAttribute("isMoved", newPoint.hasMoved)

    GW.settings[frame.setting] = newPoint
end

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
        CheckForDefaultPosition(self, point, relativePoint, xOfs, yOfs, new_point)

        self:ClearAllPoints()
        self:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
        self.savedPoint = GW.CopyTable(new_point)

        self:SetMovable(true)
        self:SetUserPlaced(true)

        --also update the selected layout
        GW.UpdateMatchingLayout(self, new_point)
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

    for _, moverframe in ipairs(GW.MOVABLE_FRAMES) do
        if moverframe:IsShown() and moverframe ~= self then
            UIFrameFadeOut(moverframe, 0.5, moverframe:GetAlpha(), 0.5)
        end
    end
end

local function moverframe_OnLeave(self)
    if self.IsMoving then
        return
    end

    for _, moverframe in ipairs(GW.MOVABLE_FRAMES) do
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

    local fs = mf:CreateFontString(nil, "OVERLAY")
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
    mf.tags = tags or ""
    mf.tagsSet = {}
    for _, v in pairs({strsplit(",", mf.tags)}) do
        v = strtrim(v)
        if v ~= "" then
            mf.tagsSet[v] = true
        end
    end
    AddTagsCSV(mf.tags)

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
        moveframe.savedPoint = GW.CopyTable(moveframe.defaultPoint)
    else
        moveframe:SetPoint(moveframe.savedPoint.point, UIParent, moveframe.savedPoint.relativePoint, moveframe.savedPoint.xOfs, moveframe.savedPoint.yOfs)
    end

    if moveframe.savedPoint.hasMoved ~= nil then
        frame.isMoved = moveframe.savedPoint.hasMoved
        frame:SetAttribute("isMoved", moveframe.savedPoint.hasMoved)
    end

    -- check if frame moved or back at default position
    CheckForDefaultPosition(moveframe, moveframe.savedPoint.point, moveframe.savedPoint.relativePoint, moveframe.savedPoint.xOfs, moveframe.savedPoint.yOfs, moveframe.savedPoint)
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
    for _, moveableFrame in ipairs(GW.MOVABLE_FRAMES) do
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
    smallSettingsContainer:Hide()

    tinsert(UISpecialFrames, "GwSmallSettingsContainer")

    --set correct separator rotation
    local angle = math.rad(90)
    local cos, sin = math.cos(angle), math.sin(angle)
    smallSettingsContainer.seperator:SetTexCoord((sin - cos), -(cos + sin), -cos, -sin, sin, -cos, 0, 0)

    smallSettingsContainer.headerString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    smallSettingsContainer.headerString:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
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

    smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid:SetScript("OnClick", GridToggle)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.showGrid:SetText(L["Show grid"])

    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider.slider:SetMinMaxValues(20, 300)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider.slider:SetValue(GW.RoundDec(GW.settings.gridSpacing, 0))
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider.slider:SetObeyStepOnDrag(true)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider.slider:SetValueStep(2)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider.inputFrame.input:SetText(GW.RoundDec(GW.settings.gridSpacing, 0))

    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider.slider:SetScript("OnValueChanged", function(self)
        local roundValue = GW.RoundDec(self:GetValue(), 0)
        GW.settings.gridSpacing = tonumber(roundValue)
        self:GetParent().inputFrame.input:SetText(roundValue)
        ShowGrid()
    end)
    smallSettingsContainer.moverSettingsFrame.defaultButtons.gridSlider.inputFrame.input:SetScript("OnEnterPressed", function(self)
        local roundValue = GW.RoundDec(self:GetNumber(), 0) or 20

        self:ClearFocus()
        if tonumber(roundValue) > 300 then self:SetText(300) end
        if tonumber(roundValue) < 20 then self:SetText(20) end
        roundValue = GW.RoundDec(self:GetNumber(), 0) or 20

        roundValue = floor((roundValue - 20) / 2 + 0.5) * 2 + 20
        self:GetParent():GetParent().slider:SetValue(roundValue)
        self:SetText(roundValue)

        GW.settings.gridSpacing = tonumber(roundValue)
        ShowGrid()
    end)

    --load tag dropdown
    local tagScrollFrame = smallSettingsContainer.moverSettingsFrame.defaultButtons.tagDropdown
    tagScrollFrame.title:SetFont(DAMAGE_TEXT_FONT, 12)
    tagScrollFrame.title:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    tagScrollFrame.title:SetText(L["Filter"])
    tagScrollFrame:GwHandleDropDownBox(nil, nil, nil, 125)

    tagScrollFrame:SetupMenu(function(dropdown, rootDescription)
        table.sort(allTags, function(a, b)
            if a == ALL then return true end
            if b == ALL then return false end
            return tostring(a) < tostring(b)
        end)

        local buttonSize = 20
        local maxButtons = 7
        rootDescription:SetScrollMode(buttonSize * maxButtons)

        for _, v in pairs(allTags) do
            local function IsSelected(tag) return selectedTag == tag end

            local function SetSelected(tagEnum) filterHudMovers(tagEnum) end

            local radio = rootDescription:CreateRadio(v, IsSelected, SetSelected, v)
            radio:AddInitializer(function(button, description, menu)
                GW.BlizzardDropdownRadioButtonInitializer(button, description, menu, IsSelected, v)
            end)
        end
    end)

    tagScrollFrame.needsRebuild = true
    smallSettingsContainer:HookScript("OnShow", function()
        if tagScrollFrame.needsRebuild then
            tagScrollFrame:GenerateMenu()
            tagScrollFrame.needsRebuild = false
        end
    end)

    --Layout
    GW.LoadLayoutsFrame(smallSettingsContainer, layoutManager)

    smallSettingsContainer:Hide()
    mf:Hide()
end
GW.LoadMovers = LoadMovers
