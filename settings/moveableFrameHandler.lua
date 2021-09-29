local _, GW = ...
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local GetDefault = GW.GetDefault
local L = GW.L

local settings_window_open_before_change = false
local function lockHudObjects(_, inCombat)
    GW.MoveHudScaleableFrame:UnregisterAllEvents()
    if InCombatLockdown() then
        DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["You can not move elements during combat!"]):gsub("*", GW.Gw2Color))
        return
    end

    GW.MoveHudScaleableFrame:Hide()
    if settings_window_open_before_change and inCombat ~= true then
        settings_window_open_before_change = false
        GwSettingsWindow:Show()
    end

    for _, mf in ipairs(GW.MOVABLE_FRAMES) do
        mf:EnableMouse(false)
        mf:SetMovable(false)
        mf:Hide()
    end
    if GW.MoveHudScaleableFrame.showGrid.grid then
        GW.MoveHudScaleableFrame.showGrid.grid:Hide()
        GW.MoveHudScaleableFrame.gridAlign:Hide()
        GW.MoveHudScaleableFrame.showGrid.forceHide = false
        GW.MoveHudScaleableFrame.showGrid:SetText(L["Show grid"])
    end
end
GW.lockHudObjects = lockHudObjects
GW.AddForProfiling("settings", "lockHudObjects", lockHudObjects)

local function moveHudObjects(self)
    if GwSettingsWindow:IsShown() then
        settings_window_open_before_change = true
    end
    GwSettingsWindow:Hide()
    for _, mf in pairs(GW.MOVABLE_FRAMES) do
        mf:EnableMouse(true)
        mf:SetMovable(true)
        mf:Show()
    end
    GW.MoveHudScaleableFrame.scaleSlider:Hide()
    GW.MoveHudScaleableFrame.heightSlider:Hide()
    GW.MoveHudScaleableFrame.default:Hide()
    GW.MoveHudScaleableFrame.movers:Hide()
    GW.MoveHudScaleableFrame.desc:Show()
    GW.MoveHudScaleableFrame:Show()

    -- register event to close move hud in combat
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_DISABLED" then
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["You can not move elements during combat!"]):gsub("*", GW.Gw2Color))
            self:UnregisterEvent(event)
            lockHudObjects(self, true)
        end
    end)
end
GW.moveHudObjects = moveHudObjects

local function Grid_GetRegion(mhgb)
    if mhgb.grid then
        if mhgb.grid.regionCount and mhgb.grid.regionCount > 0 then
            local line = select(mhgb.grid.regionCount, mhgb.grid:GetRegions())
            mhgb.grid.regionCount = mhgb.grid.regionCount - 1
            line:SetAlpha(1)
            return line
        else
            return mhgb.grid:CreateTexture()
        end
    end
end

local function create_grid(mhgb)
    if not mhgb.grid then
        mhgb.grid = CreateFrame("Frame", nil, UIParent)
        mhgb.grid:SetFrameStrata("BACKGROUND")
    else
        mhgb.grid.regionCount = 0
        local numRegions = mhgb.grid:GetNumRegions()
        for i = 1, numRegions do
            local region = select(i, mhgb.grid:GetRegions())
            if region and region.IsObjectType and region:IsObjectType("Texture") then
                mhgb.grid.regionCount = mhgb.grid.regionCount + 1
                region:SetAlpha(0)
            end
        end
    end

    local size = (1 / 0.64) - ((1 - (768 / GW.screenHeight)) / 0.64)
    local width, height = UIParent:GetSize()
    local ratio = width / height
    local hStepheight = height * ratio
    local wStep = width / mhgb.gridSize
    local hStep = hStepheight / mhgb.gridSize

    mhgb.grid.boxSize = mhgb.gridSize
    mhgb.grid:SetPoint("CENTER", UIParent)
    mhgb.grid:SetSize(width, height)
    mhgb.grid:Hide()

    for i = 0, mhgb.gridSize do
        local tx = Grid_GetRegion(mhgb)
        if i == mhgb.gridSize / 2 then
            tx:SetColorTexture(1, 0, 0)
            tx:SetDrawLayer("BACKGROUND", 1)
        else
            tx:SetColorTexture(0, 0, 0)
            tx:SetDrawLayer("BACKGROUND", 0)
        end
        tx:ClearAllPoints()
        tx:SetPoint("TOPLEFT", mhgb.grid, "TOPLEFT", i * wStep - (size / 2), 0)
        tx:SetPoint("BOTTOMRIGHT", mhgb.grid, "BOTTOMLEFT", i * wStep + (size / 2), 0)
    end

    do
        local tx = Grid_GetRegion(mhgb)
        tx:SetColorTexture(1, 0, 0)
        tx:SetDrawLayer("BACKGROUND", 1)
        tx:ClearAllPoints()
        tx:SetPoint("TOPLEFT", mhgb.grid, "TOPLEFT", 0, -(height / 2) + (size / 2))
        tx:SetPoint("BOTTOMRIGHT", mhgb.grid, "TOPRIGHT", 0, -(height / 2 + size / 2))
    end

    for i = 1, floor((height / 2) / hStep) do
        local tx = Grid_GetRegion(mhgb)
        tx:SetColorTexture(0, 0, 0)
        tx:SetDrawLayer("BACKGROUND", 0)
        tx:ClearAllPoints()
        tx:SetPoint("TOPLEFT", mhgb.grid, "TOPLEFT", 0, -(height / 2 + i * hStep) + (size / 2))
        tx:SetPoint("BOTTOMRIGHT", mhgb.grid, "TOPRIGHT", 0, -(height / 2 + i * hStep + size / 2))

        tx = Grid_GetRegion(mhgb)
        tx:SetColorTexture(0, 0, 0)
        tx:SetDrawLayer("BACKGROUND", 0)
        tx:ClearAllPoints()
        tx:SetPoint("TOPLEFT", mhgb.grid, "TOPLEFT", 0, -(height / 2 - i * hStep) + (size / 2))
        tx:SetPoint("BOTTOMRIGHT", mhgb.grid, "TOPRIGHT", 0, -(height / 2 - i * hStep + size / 2))
    end
end

local function Grid_Show_Hide(self)
    local self = self:GetParent()
    if self.showGrid.forceHide then
        if self.showGrid.grid then
            self.showGrid.grid:Hide()
        end
        self.gridAlign:Hide()
        self.showGrid.forceHide = false
        self.showGrid:SetText(L["Show grid"])
    else
        if not self.showGrid.grid then
            create_grid(self.showGrid)
        elseif self.showGrid.grid.boxSize ~= self.showGrid.gridSize then
            self.showGrid.grid:Hide()
            create_grid(self.showGrid)
        end
        self.gridAlign:Show()
        self.showGrid.grid:Show()
        self.showGrid.forceHide = true
        self.showGrid:SetText(L["Hide grid"])
    end
end

local function CheckIfMoved(self, settingsName, new_point)
    -- check if we need to know if the frame is on its default position
    if self.gw_isMoved ~= nil then
        local defaultPoint = GetDefault(settingsName)
        local growDirection = GetSetting(settingsName .. "_GrowDirection")
        local frame = self.gw_frame
        if defaultPoint.point == new_point.point and defaultPoint.relativePoint == new_point.relativePoint and defaultPoint.xOfs == new_point.xOfs and defaultPoint.yOfs == new_point.yOfs and (growDirection and growDirection == "UP") then
            frame.isMoved = false
            frame:SetAttribute("isMoved", false)
        else
            frame.isMoved = true
            frame:SetAttribute("isMoved", true)
        end
    end
end

local function smallSettings_resetToDefault(self)
    local mf = self:GetParent().child
    --local f = mf.gw_frame
    local settingsName = mf.gw_Settings

    local dummyPoint = GetDefault(settingsName)
    mf:ClearAllPoints()
    mf:SetPoint(
        dummyPoint["point"],
        UIParent,
        dummyPoint["relativePoint"],
        dummyPoint["xOfs"],
        dummyPoint["yOfs"]
    )

    local point, _, relativePoint, xOfs, yOfs = mf:GetPoint()

    local new_point = GetSetting(settingsName)
    new_point["point"] = point
    new_point["relativePoint"] = relativePoint
    new_point["xOfs"] = GW.RoundInt(xOfs)
    new_point["yOfs"] = GW.RoundInt(yOfs)
    SetSetting(settingsName, new_point)

    --if 'PlayerBuffFrame' or 'PlayerDebuffFrame', set also the grow direction to default
    if settingsName == "PlayerBuffFrame" or settingsName == "PlayerDebuffFrame" then
        SetSetting(settingsName .. "_GrowDirection", "UP")
    elseif settingsName == "MicromenuPos" then
        -- Hide/Show BG here
        mf.gw_frame.cf.bg:Show()
    end

    -- check if we need to know if the frame is on its default position
    CheckIfMoved(mf, settingsName, new_point)

    if mf.gw_positionAfter then
        mf.gw_frame:ClearAllPoints()
        mf.gw_frame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
    end

    -- Set Scale back to default
    if mf.optionScaleable then
        local scale
        if mf.gw_mhf then
            scale = GetSetting("HUD_SCALE")
        else
            scale = GetDefault(settingsName .. "_scale")
        end
        mf:SetScale(scale)
        mf.gw_frame:SetScale(scale)
        SetSetting(settingsName .. "_scale", scale)
        self:GetParent().scaleSlider.slider:SetValue(scale)
    end

    -- Set height back to default
    if mf.optionHeight then
        local height = GetDefault(settingsName .. "_height")
        mf:SetHeight(height)
        mf.gw_frame:SetHeight(height)
        SetSetting(settingsName .. "_height", height)
        self:GetParent().heightSlider.slider:SetValue(height)
    end

    if mf.gw_postdrag then
        mf.gw_postdrag(mf.gw_frame)
    end

    GW.UpdateHudScale()
end
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
    local settingsName = self.gw_Settings
    self:StopMovingOrSizing()
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()

    local new_point = GetSetting(settingsName)
    new_point.point = point
    new_point.relativePoint = relativePoint
    new_point.xOfs = xOfs and math.floor(xOfs) or 0
    new_point.yOfs = yOfs and math.floor(yOfs) or 0
    self:ClearAllPoints()
    self:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
    SetSetting(settingsName, new_point)
    -- check if we need to know if the frame is on its default position
    CheckIfMoved(self, settingsName, new_point)

    if self.gw_positionAfter then
        self.gw_frame:ClearAllPoints()
        self.gw_frame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
    end
    if self.gw_postdrag then
        self.gw_postdrag(self.gw_frame)
    end

    self:SetMovable(true)
    self:SetUserPlaced(true)
    self.IsMoving = false
end
GW.AddForProfiling("index", "mover_OnDragStop", mover_OnDragStop)

local function mover_options(self, button)
    if button == "RightButton" then
        if GW.MoveHudScaleableFrame.child == self then
            GW.MoveHudScaleableFrame.child = nil
            GW.MoveHudScaleableFrame.childMover = nil
            GW.MoveHudScaleableFrame.headerString:SetText(L["Extra Frame Options"])
            GW.MoveHudScaleableFrame.scaleSlider:Hide()
            GW.MoveHudScaleableFrame.heightSlider:Hide()
            GW.MoveHudScaleableFrame.default:Hide()
            GW.MoveHudScaleableFrame.movers:Hide()
            GW.MoveHudScaleableFrame.desc:SetText(L["Right click on a moverframe to show extra frame options"])
            GW.MoveHudScaleableFrame.desc:Show()
            GW.StopFlash(GW.MoveHudScaleableFrame.activeFlasher)
        else
            GW.MoveHudScaleableFrame.child = self
            GW.MoveHudScaleableFrame.childMover = self
            GW.MoveHudScaleableFrame.headerString:SetText(self.frameName:GetText())
            GW.MoveHudScaleableFrame.desc:Hide()
            GW.MoveHudScaleableFrame.default:Show()
            GW.MoveHudScaleableFrame.movers:Show()
            -- options 
            GW.MoveHudScaleableFrame.scaleSlider:SetShown(self.optionScaleable)
            GW.MoveHudScaleableFrame.heightSlider:SetShown(self.optionHeight)
            if self.optionScaleable then
                local scale = GetSetting(self.gw_Settings .. "_scale")
                GW.MoveHudScaleableFrame.scaleSlider.slider:SetValue(scale)
                GW.MoveHudScaleableFrame.scaleSlider.input:SetNumber(scale)
            end
            if self.optionHeight then
                local height = GetSetting(self.gw_Settings .. "_height")
                GW.MoveHudScaleableFrame.heightSlider.slider:SetValue(height)
                GW.MoveHudScaleableFrame.heightSlider.input:SetNumber(height)
            end

            if GW.MoveHudScaleableFrame.activeFlasher then
                GW.StopFlash(GW.MoveHudScaleableFrame.activeFlasher)
                UIFrameFadeOut(GW.MoveHudScaleableFrame.activeFlasher, 0.5, GW.MoveHudScaleableFrame.activeFlasher:GetAlpha(), 0.5)
            end
            GW.MoveHudScaleableFrame.activeFlasher = self
            GW.FrameFlash(self, 1.5, 0.5, 1, true)
        end
    end
end

local function sliderValueChange(self)
    local roundValue = GW.RoundDec(self:GetValue(), 2)
    local moverFrame = self:GetParent():GetParent().child
    moverFrame:SetScale(roundValue)
    moverFrame.gw_frame:SetScale(roundValue)
    self:GetParent().input:SetText(roundValue)
    SetSetting(moverFrame.gw_Settings .."_scale", roundValue)

    self:GetParent():GetParent().child.gw_frame.isMoved = true
    self:GetParent():GetParent().child.gw_frame:SetAttribute("isMoved", true)
end

local function sliderEditBoxValueChanged(self)
    local roundValue = GW.RoundDec(self:GetNumber(), 2) or 0.5
    local moverFrame = self:GetParent():GetParent().child

    self:ClearFocus()
    if tonumber(roundValue) > 1.5 then self:SetText(1.5) end
    if tonumber(roundValue) < 0.5 then self:SetText(0.5) end
    roundValue = GW.RoundDec(self:GetNumber(), 2) or 0.5

    self:GetParent().slider:SetValue(roundValue)
    self:SetText(roundValue)
    SetSetting(moverFrame.gw_Settings .. "_scale", roundValue)

    self:GetParent():GetParent().child.gw_frame.isMoved = true
    self:GetParent():GetParent().child.gw_frame:SetAttribute("isMoved", true)
end

local function heightSliderValueChange(self)
    local roundValue = GW.RoundDec(self:GetValue())
    local moverFrame = self:GetParent():GetParent().child
    moverFrame:SetHeight(roundValue)
    moverFrame.gw_frame:SetHeight(roundValue)
    self:GetParent().input:SetText(roundValue)
    SetSetting(moverFrame.gw_Settings .."_height", roundValue)
end

local function heightEditBoxValueChanged(self)
    local roundValue = GW.RoundDec(self:GetNumber()) or 1
    local moverFrame = self:GetParent():GetParent().child

    self:ClearFocus()
    if tonumber(roundValue) > 1500 then self:SetText(1500) end
    if tonumber(roundValue) < 1 then self:SetText(1) end

    SetSetting(moverFrame.gw_Settings .."_height", roundValue)

    moverFrame.gw_frame:SetHeight(roundValue)
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

local function RegisterMovableFrame(frame, displayName, settingsName, dummyFrame, size, isMoved, smallOptions, mhf, postdrag, positionFrameAfterMove)
    local moveframe = CreateFrame("Frame", settingsName .. "Mover", UIParent, dummyFrame)
    frame.gwMover = moveframe
    if size then
        moveframe:SetSize(unpack(size))
    else
        moveframe:SetSize(frame:GetSize())
    end
    moveframe:SetScale(frame:GetScale())
    moveframe.gw_Settings = settingsName
    moveframe.gw_isMoved = isMoved
    moveframe.gw_frame = frame
    moveframe.gw_mhf = mhf
    moveframe.gw_postdrag = postdrag
    moveframe.gw_positionAfter = positionFrameAfterMove

    if moveframe.frameName and moveframe.frameName.SetText then
        moveframe.frameName:SetSize(moveframe:GetSize())
        moveframe.frameName:SetText(displayName)
    end

    moveframe:SetClampedToScreen(true)

    -- position mover (as fallback use the default position)
    local framePoint = GetSetting(settingsName)
    local defaultPoint = GetDefault(settingsName)
    moveframe:ClearAllPoints()
    if not framePoint.point or not framePoint.relativePoint or not framePoint.xOfs or not framePoint.yOfs then
        -- use default position
        moveframe:SetPoint(defaultPoint.point, UIParent, defaultPoint.relativePoint, defaultPoint.xOfs, defaultPoint.yOfs)
        framePoint = defaultPoint
    else
        moveframe:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs, framePoint.yOfs)
    end

    local num = #GW.MOVABLE_FRAMES
    GW.MOVABLE_FRAMES[num + 1] = moveframe
    moveframe:Hide()
    moveframe:RegisterForDrag("LeftButton")
    moveframe:SetScript("OnEnter", moverframe_OnEnter)
    moveframe:SetScript("OnLeave", moverframe_OnLeave)

    if isMoved ~= nil then
        local defaultPoint = GetDefault(settingsName)

        if defaultPoint.point == framePoint.point and defaultPoint.relativePoint == framePoint.relativePoint and defaultPoint.xOfs == framePoint.xOfs and defaultPoint.yOfs == framePoint.yOfs then
            frame.isMoved = false
            frame:SetAttribute("isMoved", false)
        else
            frame.isMoved = true
            frame:SetAttribute("isMoved", true)
        end
    end

    if mhf then
        GW.scaleableMainHudFrames[#GW.scaleableMainHudFrames + 1] = moveframe
    end

    -- set all options default as off
    moveframe.optionScaleable = false
    moveframe.optionHeight = false

    if smallOptions then
        for _, v in pairs(smallOptions) do
            if v == "scaleable" then
                moveframe.optionScaleable = true
            elseif v == "height" then
                moveframe.optionHeight = true
            end
        end
    end

    if smallOptions and #smallOptions > 0 then
        if moveframe.optionScaleable then
            local scale = GetSetting(settingsName .. "_scale")
            moveframe.gw_frame:SetScale(scale)
            moveframe:SetScale(scale)
            GW.scaleableFrames[#GW.scaleableFrames + 1] = moveframe
        end
        if moveframe.optionHeight then
            local height = GetSetting(settingsName .. "_height")
            moveframe.gw_frame:SetHeight(height)
            moveframe:SetHeight(height)
        end
        moveframe:SetScript("OnMouseDown", mover_options)
    else
        moveframe:SetScript("OnMouseDown", function(self, button)
            if button == "RightButton" then
                if GW.MoveHudScaleableFrame.child == "nil" then
                    GW.MoveHudScaleableFrame.child = nil
                    GW.MoveHudScaleableFrame.childMover = nil
                    GW.MoveHudScaleableFrame.headerString:SetText(L["Extra Frame Options"])
                    GW.MoveHudScaleableFrame.scaleSlider:Hide()
                    GW.MoveHudScaleableFrame.heightSlider:Hide()
                    GW.MoveHudScaleableFrame.default:Hide()
                    GW.MoveHudScaleableFrame.movers:Hide()
                    GW.MoveHudScaleableFrame.desc:SetText(L["Right click on a moverframe to show extra frame options"])
                    GW.MoveHudScaleableFrame.desc:Show()
                    GW.StopFlash(GW.MoveHudScaleableFrame.activeFlasher)
                else
                    GW.MoveHudScaleableFrame.child = "nil"
                    GW.MoveHudScaleableFrame.childMover = self
                    GW.MoveHudScaleableFrame.headerString:SetText(displayName)
                    GW.MoveHudScaleableFrame.scaleSlider:Hide()
                    GW.MoveHudScaleableFrame.heightSlider:Hide()
                    GW.MoveHudScaleableFrame.default:Hide()
                    GW.MoveHudScaleableFrame.movers:Show()
                    GW.MoveHudScaleableFrame.desc:SetText(format(L["No extra frame options for '%s'"], displayName))
                    GW.MoveHudScaleableFrame.desc:Show()
                    if GW.MoveHudScaleableFrame.activeFlasher then
                        GW.StopFlash(GW.MoveHudScaleableFrame.activeFlasher)
                        UIFrameFadeOut(GW.MoveHudScaleableFrame.activeFlasher, 0.5, GW.MoveHudScaleableFrame.activeFlasher:GetAlpha(), 0.5)
                    end
                    GW.MoveHudScaleableFrame.activeFlasher = self
                    GW.FrameFlash(self, 1.5, 0.5, 1, true)
                end
            end
        end)
    end

    if postdrag then
        moveframe:RegisterEvent("PLAYER_ENTERING_WORLD")
        moveframe:SetScript("OnEvent", function(self)
            postdrag(self.gw_frame)
            self:UnregisterAllEvents()
        end)
    end

    moveframe:SetScript("OnDragStart", mover_OnDragStart)
    moveframe:SetScript("OnDragStop", mover_OnDragStop)
end
GW.RegisterMovableFrame = RegisterMovableFrame

local function MoveFrameByPixel(nudgeX, nudgeY)
    local mover = GwSmallSettingsWindow.childMover

    local point, _, anchorPoint, x, y = mover:GetPoint()
    x = x + nudgeX
    y = y + nudgeY
    mover:ClearAllPoints()
    mover:SetPoint(point, UIParent, anchorPoint, x, y)

    mover_OnDragStop(mover)
end

local function LoadMovers()
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

    local moverSettingsFrame = CreateFrame("Frame", "GwSmallSettingsWindow", UIParent, "GwSmallSettings")
    moverSettingsFrame.scaleSlider.slider:SetMinMaxValues(0.5, 1.5)
    moverSettingsFrame.scaleSlider.slider:SetValue(1)
    moverSettingsFrame.scaleSlider.slider:SetScript("OnValueChanged", sliderValueChange)
    moverSettingsFrame.scaleSlider.input:SetNumber(1)
    moverSettingsFrame.scaleSlider.input:SetFont(UNIT_NAME_FONT, 8)
    moverSettingsFrame.scaleSlider.input:SetScript("OnEnterPressed", sliderEditBoxValueChanged)

    moverSettingsFrame.heightSlider.slider:SetMinMaxValues(1, 1500)
    moverSettingsFrame.heightSlider.slider:SetValue(1)
    moverSettingsFrame.heightSlider.slider:SetScript("OnValueChanged", heightSliderValueChange)
    moverSettingsFrame.heightSlider.input:SetNumber(1)
    moverSettingsFrame.heightSlider.input:SetFont(UNIT_NAME_FONT, 7)
    moverSettingsFrame.heightSlider.input:SetScript("OnEnterPressed", heightEditBoxValueChanged)

    moverSettingsFrame.desc:SetText(L["Right click on a moverframe to show extra frame options"])
    moverSettingsFrame.desc:SetFont(UNIT_NAME_FONT, 12)
    moverSettingsFrame.scaleSlider.title:SetFont(UNIT_NAME_FONT, 12)
    moverSettingsFrame.scaleSlider.title:SetText(L["Scale"])
    moverSettingsFrame.heightSlider.title:SetFont(UNIT_NAME_FONT, 12)
    moverSettingsFrame.heightSlider.title:SetText(COMPACT_UNIT_FRAME_PROFILE_FRAMEHEIGHT)
    moverSettingsFrame.headerString:SetFont(UNIT_NAME_FONT, 14)
    moverSettingsFrame.headerString:SetText(L["Extra Frame Options"])

    moverSettingsFrame.movers.title:SetText(NPE_MOVE )
    moverSettingsFrame.movers.title:SetFont(UNIT_NAME_FONT, 12)
    GW.HandleNextPrevButton(moverSettingsFrame.movers.left, "left")
    GW.HandleNextPrevButton(moverSettingsFrame.movers.right, "right")
    GW.HandleNextPrevButton(moverSettingsFrame.movers.up, "up")
    GW.HandleNextPrevButton(moverSettingsFrame.movers.down, "down")
    moverSettingsFrame.movers.left:SetScript("OnClick", function() MoveFrameByPixel(-1, 0) end)
    moverSettingsFrame.movers.right:SetScript("OnClick", function() MoveFrameByPixel(1, 0) end)
    moverSettingsFrame.movers.up:SetScript("OnClick", function() MoveFrameByPixel(0, 1) end)
    moverSettingsFrame.movers.down:SetScript("OnClick", function() MoveFrameByPixel(0, -1) end)

    moverSettingsFrame:SetScript("OnShow", function()
        mf:Show()
    end)
    moverSettingsFrame:SetScript("OnHide", function()
        mf:Hide()
    end)

    moverSettingsFrame.default:SetScript("OnClick", smallSettings_resetToDefault)

    -- lock and grid button
    moverSettingsFrame.lockHud:SetScript("OnClick", lockHudObjects)
    moverSettingsFrame.lockHud:SetText(L["Lock HUD"])

    moverSettingsFrame.showGrid:SetScript("OnClick", Grid_Show_Hide)
    moverSettingsFrame.showGrid:SetText(L["Show grid"])
    moverSettingsFrame.showGrid.gridSize = 64
    moverSettingsFrame.showGrid.forceHide = false
    create_grid(moverSettingsFrame.showGrid)

    moverSettingsFrame.gridAlign:SetScript("OnEscapePressed", function(eb)
        eb:SetText(moverSettingsFrame.showGrid.gridSize)
        EditBox_ClearFocus(eb)
    end)
    moverSettingsFrame.gridAlign:SetScript("OnEnterPressed", function(eb)
        local text = eb:GetText()
        if tonumber(text) then
            if tonumber(text) <= 256 and tonumber(text) >= 4 then
                moverSettingsFrame.showGrid.gridSize = tonumber(text)
            else
                eb:SetText(moverSettingsFrame.showGrid.gridSize)
            end
        else
            eb:SetText(moverSettingsFrame.showGrid.gridSize)
        end
        moverSettingsFrame.showGrid.forceHide = false
        Grid_Show_Hide(moverSettingsFrame.showGrid)
        EditBox_ClearFocus(eb)
    end)
    moverSettingsFrame.gridAlign:SetScript("OnEditFocusLost", function(eb)
        eb:SetText(moverSettingsFrame.showGrid.gridSize)
    end)
    moverSettingsFrame.gridAlign:SetScript("OnEditFocusGained", moverSettingsFrame.gridAlign.HighlightText)
    moverSettingsFrame.gridAlign:SetScript("OnShow", function(eb)
        EditBox_ClearFocus(eb)
        eb:SetText(moverSettingsFrame.showGrid.gridSize)
    end)
    moverSettingsFrame.gridAlign.text:SetText(L["Grid Size:"])
    moverSettingsFrame.gridAlign:Hide()

    moverSettingsFrame:Hide()
    mf:Hide()
    GW.MoveHudScaleableFrame = moverSettingsFrame
end
GW.LoadMovers = LoadMovers
