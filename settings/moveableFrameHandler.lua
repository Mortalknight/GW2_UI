local _, GW = ...
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local GetDefault = GW.GetDefault
local L = GW.L

local MOVABLE_FRAMES = {}
GW.MOVABLE_FRAMES = MOVABLE_FRAMES

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

local function lockableOnClick(self, btn)
    local mf = self:GetParent()
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

    -- check if we need to know if the frame is on its default position
    CheckIfMoved(self, settingsName, new_point)

    --if 'PlayerBuffFrame' or 'PlayerDebuffFrame', set also the grow direction to default
    if settingsName == "PlayerBuffFrame" or settingsName == "PlayerDebuffFrame" then
        SetSetting(settingsName .. "_GrowDirection", "UP")
    end
end
GW.AddForProfiling("index", "lockableOnClick", lockableOnClick)

local function smallSettings_resetToDefault(self, btn)
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
    end

    -- check if we need to know if the frame is on its default position
    CheckIfMoved(self, settingsName, new_point)

    --Set Scale back to default
    local scale = GetDefault(settingsName .. "_scale")
    mf:SetScale(scale)
    mf.gw_frame:SetScale(scale)
    SetSetting(settingsName .. "_scale", scale)
    self:GetParent().scaleSlider.slider:SetValue(scale)
end
GW.AddForProfiling("index", "lockableOnClick", lockableOnClick)

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
    local lockAble = self.gw_Lockable
    self:StopMovingOrSizing()
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()

    local new_point = GetSetting(settingsName)
    new_point.point = point
    new_point.relativePoint = relativePoint
    new_point.xOfs = math.floor(xOfs)
    new_point.yOfs = math.floor(yOfs)
    SetSetting(settingsName, new_point)
    if lockAble ~= nil then
        SetSetting(lockAble, false)
    end
    -- check if we need to know if the frame is on its default position
    CheckIfMoved(self, settingsName, new_point)

    --check if we need to change the text string
    if settingsName == "AlertPos" then
        local _, y = self:GetCenter()
        local screenHeight = UIParent:GetTop()
        if y > (screenHeight / 2) then
            if self.frameName and self.frameName.SetText then
                self.frameName:SetText(L["ALERTFRAMES"] .. " (" .. COMBAT_TEXT_SCROLL_DOWN .. ")")
            end
        else
            if self.frameName and self.frameName.SetText then
                self.frameName:SetText(L["ALERTFRAMES"] .. " (" .. COMBAT_TEXT_SCROLL_UP .. ")")
            end
        end
    end

    self.IsMoving = false
end
GW.AddForProfiling("index", "mover_OnDragStop", mover_OnDragStop)

local function mover_scaleable(self, button)
    if button =="RightButton" then
        if GW.MoveHudScaleableFrame.child == self then
            GW.MoveHudScaleableFrame.child = nil
            GW.MoveHudScaleableFrame.headerString:SetText(L["SMALL_SETTINGS_HEADER"])
            GW.MoveHudScaleableFrame.scaleSlider:Hide()
            GW.MoveHudScaleableFrame.default:Hide()
            GW.MoveHudScaleableFrame.desc:SetText(L["SMALL_SETTINGS_DEFAULT_DESC"])
            GW.MoveHudScaleableFrame.desc:Show()
            GW.StopFlash(GW.MoveHudScaleableFrame.activeFlasher)
        else
            local scale = GetSetting(self.gw_Settings .."_scale")
            GW.MoveHudScaleableFrame.child = self
            GW.MoveHudScaleableFrame.headerString:SetText(self.frameName:GetText())
            GW.MoveHudScaleableFrame.scaleSlider.slider:SetValue(scale)
            GW.MoveHudScaleableFrame.scaleSlider.input:SetNumber(scale)
            GW.MoveHudScaleableFrame.desc:Hide()
            GW.MoveHudScaleableFrame.scaleSlider:Show()
            GW.MoveHudScaleableFrame.default:Show()
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
    SetSetting(moverFrame.gw_Settings .."_scale", roundValue)

    self:GetParent():GetParent().child.gw_frame.isMoved = true
    self:GetParent():GetParent().child.gw_frame:SetAttribute("isMoved", true)
end

local function moverframe_OnEnter(self)
    if self.IsMoving then
        return
    end

    for _, moverframe in pairs(MOVABLE_FRAMES) do
        if moverframe:IsShown() and moverframe ~= self then
            UIFrameFadeOut(moverframe, 0.5, moverframe:GetAlpha(), 0.5)
        end
    end
end

local function moverframe_OnLeave(self)
    if self.IsMoving then
        return
    end

    for _, moverframe in pairs(MOVABLE_FRAMES) do
        if moverframe:IsShown() and moverframe ~= self then
            UIFrameFadeIn(moverframe, 0.5, moverframe:GetAlpha(), 1)
        end
    end
end

local function RegisterMovableFrame(frame, displayName, settingsName, dummyFrame, size, lockAble, isMoved, scaleable)
    local moveframe = CreateFrame("Frame", nil, UIParent, dummyFrame)
    frame.gwMover = moveframe
    if size then
        moveframe:SetSize(unpack(size))
    else
        moveframe:SetSize(frame:GetSize())
    end
    moveframe.gw_Settings = settingsName
    moveframe.gw_Lockable = lockAble
    moveframe.gw_isMoved = isMoved
    moveframe.gw_frame = frame

    if moveframe.frameName and moveframe.frameName.SetText then
        moveframe.frameName:SetText(displayName)
    end

    -- position mover
    local framePoint = GetSetting(settingsName)
    moveframe:ClearAllPoints()
    moveframe:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs, framePoint.yOfs)

    local num = #MOVABLE_FRAMES
    MOVABLE_FRAMES[num + 1] = moveframe
    moveframe:Hide()
    moveframe:RegisterForDrag("LeftButton")
    moveframe:SetScript("OnEnter", moverframe_OnEnter)
    moveframe:SetScript("OnLeave", moverframe_OnLeave)

    if lockAble ~= nil then
        local lockFrame = CreateFrame("Button", nil, moveframe, "GwDummyLockButton")
        lockFrame:SetScript("OnEnter", lockFrame_OnEnter)
        lockFrame:SetScript("OnLeave", GameTooltip_Hide)
        lockFrame:SetScript("OnClick", lockableOnClick)
    end

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

    if scaleable then
        local scale = GetSetting(settingsName .. "_scale")
        moveframe.gw_frame:SetScale(scale)
        moveframe:SetScale(scale)
        moveframe:SetScript("OnMouseDown", mover_scaleable)
        frame:SetScale(scale)
    else
        moveframe:SetScript("OnMouseDown", function(self, button)
            if button =="RightButton" then
                if GW.MoveHudScaleableFrame.child == "nil" then
                    GW.MoveHudScaleableFrame.child = nil
                    GW.MoveHudScaleableFrame.headerString:SetText(L["SMALL_SETTINGS_HEADER"])
                    GW.MoveHudScaleableFrame.scaleSlider:Hide()
                    GW.MoveHudScaleableFrame.default:Hide()
                    GW.MoveHudScaleableFrame.desc:SetText(L["SMALL_SETTINGS_DEFAULT_DESC"])
                    GW.MoveHudScaleableFrame.desc:Show()
                    GW.StopFlash(GW.MoveHudScaleableFrame.activeFlasher)
                else
                    GW.MoveHudScaleableFrame.child = "nil"
                    GW.MoveHudScaleableFrame.headerString:SetText(displayName)
                    GW.MoveHudScaleableFrame.scaleSlider:Hide()
                    GW.MoveHudScaleableFrame.default:Hide()
                    GW.MoveHudScaleableFrame.desc:SetText(format(L["SMALL_SETTINGS_NO_SETTINGS_FOR"], displayName))
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

    moveframe:SetScript("OnDragStart", mover_OnDragStart)
    moveframe:SetScript("OnDragStop", mover_OnDragStop)
end
GW.RegisterMovableFrame = RegisterMovableFrame

local function UpdateFramePositions()
    for i, mf in pairs(MOVABLE_FRAMES) do
        local f = mf.gw_frame
        local newp = GetSetting(mf.gw_Settings)
        f:ClearAllPoints()
        f:SetPoint(newp["point"], UIParent, newp["relativePoint"], newp["xOfs"], newp["yOfs"])
    end
end
GW.UpdateFramePositions = UpdateFramePositions

local function LoadMovers()
    -- Create mover settings frame
    local fnMf_OnDragStart = function(self)
        self:StartMoving()
    end
    local fnMf_OnDragStop = function(self)
        -- check if frame is out of screen, if yes move it back
        ValidateFramePosition(self)
        self:StopMovingOrSizing()
    end
    local mf = CreateFrame("Frame", "GwSmallSettingsMoverFrame", UIParent, "GwSmallSettingsMoverFrame")
    mf:RegisterForDrag("LeftButton")
    mf:SetScript("OnDragStart", fnMf_OnDragStart)
    mf:SetScript("OnDragStop", fnMf_OnDragStop)

    local moverSettingsFrame = CreateFrame("Frame", "GwSmallSettingsWindow", UIParent, "GwScaleablePanelTmpl")
    moverSettingsFrame.scaleSlider.slider:SetMinMaxValues(0.5, 1.5)
    moverSettingsFrame.scaleSlider.slider:SetValue(1)
    moverSettingsFrame.scaleSlider.slider:SetScript("OnValueChanged", sliderValueChange)
    moverSettingsFrame.scaleSlider.input:SetNumber(1)
    moverSettingsFrame.scaleSlider.input:SetFont(UNIT_NAME_FONT, 8)
    moverSettingsFrame.scaleSlider.input:SetScript("OnEnterPressed", sliderEditBoxValueChanged)

    moverSettingsFrame.desc:SetText(L["SMALL_SETTINGS_DEFAULT_DESC"])
    moverSettingsFrame.desc:SetFont(UNIT_NAME_FONT, 12)
    moverSettingsFrame.scaleSlider.title:SetFont(UNIT_NAME_FONT, 12)
    moverSettingsFrame.scaleSlider.title:SetText(L["SMALL_SETTINGS_OPTION_SCALE"])
    moverSettingsFrame.headerString:SetFont(UNIT_NAME_FONT, 14)
    moverSettingsFrame.headerString:SetText(L["SMALL_SETTINGS_HEADER"])
    moverSettingsFrame:SetScript("OnShow", function(self)
        mf:Show()
    end)
    moverSettingsFrame:SetScript("OnHide", function(self)
        mf:Hide()
    end)

    moverSettingsFrame.default:SetScript("OnClick", smallSettings_resetToDefault)

    moverSettingsFrame:Hide()
    mf:Hide()
    GW.MoveHudScaleableFrame = moverSettingsFrame
end
GW.LoadMovers = LoadMovers