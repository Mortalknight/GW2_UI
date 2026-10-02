---@class GW2
local GW = select(2, ...)
local addonName = ...

-- Thanks at Shrugal for the ErrorHandler

Gw2ErrorHandlerMixin = {}

local function CreateErrorLogWindow()
    local frame = CreateFrame("Frame", "Gw2ErrorLog", UIParent)

    Mixin(frame, Gw2ErrorHandlerMixin)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetResizable(true)
    frame:SetUserPlaced(true)
    frame:SetSize(700, 600)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:Hide()

    tinsert(UISpecialFrames, "Gw2ErrorLog")

    frame.info = frame:CreateFontString(nil, "OVERLAY")
    frame.info:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -45)
    frame.info:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -45)
    frame.info:SetJustifyH("LEFT")

    frame.scrollArea = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -70)
    frame.scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 15)
    frame.scrollArea:SetScript("OnSizeChanged", function(scroll)
        frame.editBox:SetWidth(scroll:GetWidth())
        frame.editBox:SetHeight(scroll:GetHeight())
    end)
    frame.scrollArea:HookScript("OnVerticalScroll", function(scroll, offset)
        frame.editBox:SetHitRectInsets(0, 0, offset, (frame.editBox:GetHeight() - offset - scroll:GetHeight()))
    end)
    frame.scrollArea.bg = frame.scrollArea:CreateTexture(nil, "ARTWORK")
    frame.scrollArea.bg:SetAllPoints()
    frame.scrollArea.bg:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatframebackground.png")

    frame.editBox = CreateFrame("EditBox", nil, frame)
    frame.editBox:SetMultiLine(true)
    frame.editBox:EnableMouse(true)
    frame.editBox:SetAutoFocus(false)
    frame.editBox:SetFontObject(ChatFontNormal)
    frame.editBox:SetAllPoints()
    frame.editBox:SetScript("OnEscapePressed", function() frame:Hide() end)

    frame.scrollArea:SetScrollChild(frame.editBox)

    return frame
end

function Gw2ErrorHandlerMixin:Toggle()
    if not self.Skinned then
        GW.CreateFrameHeaderWithBody(self, GW.L["GW2 Error Log"], "Interface/AddOns/GW2_UI/textures/character/addon-window-icon.png")
        local header = self.gwHeader
        header:EnableMouse(true)
        header:RegisterForDrag("LeftButton")
        header:SetScript("OnDragStart", function() self:StartMoving() end)
        header:SetScript("OnDragStop", function() self:StopMovingOrSizing() end)

        self.close = CreateFrame("Button", nil, header, "UIPanelCloseButton")
        self.close:GwSkinButton(true)
        self.close:SetSize(20, 20)
        self.close:ClearAllPoints()
        self.close:SetPoint("TOPRIGHT", self, "TOPRIGHT", -10, -2)
        self.close:SetScript("OnClick", function() self:Hide() end)

        self.info:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        self.info:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        self.scrollArea.ScrollBar:GwSkinScrollBar()
        self.Skinned = true
    end

    if self:IsShown() then
        self.editBox:SetText("")
        self:Hide()
    else
        local txt = ("Version: %s Date: %s Locale: %s Build %s %s"):format(GW.GetVersionString() or "?", date("%m/%d/%y %H:%M:%S") or "?", GW.mylocal or "?", GW.wowpatch, GW.wowbuild)
        txt = txt .. "\n" .. GW.Join("\n", self.log)
        self.editBox:SetText(txt)
        self.info:SetText(format(GW.L["%d errors this session, Ctrl+C copies the marked log."], #self.log))
        self.scrollArea:SetVerticalScroll(0)
        self.editBox:HighlightText()
        self.editBox:SetFocus()
        self:Show()
    end
end

function Gw2ErrorHandlerMixin:ShouldHandleError()
    return self.errors <= self.LOG_MAX_ERRORS
        and self.errorRate - self.LOG_MAX_ERROR_RATE * (GetTime() - self.errorPrev) < self.LOG_MAX_ERROR_RATE
end

function Gw2ErrorHandlerMixin:CleanFilePaths(msg)
    return tostring(msg or ""):gsub("@?Interface\\AddOns\\", ""):gsub("@?Interface/AddOns/", "")
end

-- Check for GW2 errors and log them
function Gw2ErrorHandlerMixin:HandleError(msg, stack, locals)
    if not self:ShouldHandleError() then
        return
    end

    msg = "\"" .. self:CleanFilePaths(msg) .. "\""
    stack = self:CleanFilePaths(stack)

    -- Just print the error message if HandleError or LogExport caused it
    local filePattern = addonName .. "[\\/]" .. "[Cc]ore[\\/]" .. "errorHandler%.lua[^\n]*"
    if stack:match(filePattern .. "HandleError") then
        self.errors = math.huge
        GW.Notice("|cffff0000[ERROR]|r " .. msg .. "\n\nThis is an error in the error-handling system itself. Please create a new ticket on Curse, Discord or GitHub, copy & paste the error message in there and add any additional info you might have. Thank you! =)")
    elseif self.errors < self.LOG_MAX_ERRORS then
        self.errorRate = max(0, self.errorRate - self.LOG_MAX_ERROR_RATE * (GetTime() - self.errorPrev)) + 1
        self.errorPrev = GetTime()

        for match in stack:gmatch("%[?" .. addonName .. "[\\/]+([^:%]]+)") do
            if match and not GW.StartsWith(match, "Libs") and not GW.StartsWith(match, "libs") then
                self.errors = self.errors + 1
                GW.Debug("ERROR", msg .. "\n" .. stack)
                local entry = msg .. "\n" .. stack
                if locals and locals ~= "" then
                    local cleanLocals = self:CleanFilePaths(locals)
                    if #cleanLocals > self.LOG_MAX_LOCALS_LENGTH then
                        cleanLocals = cleanLocals:sub(1, self.LOG_MAX_LOCALS_LENGTH) .. "\n..."
                    end
                    entry = entry .. "\nLocals:\n" .. cleanLocals
                end
                tinsert(self.log, ("[%s] |cffff0000[ERROR]|r: %s"):format(date("%H:%M:%S"), entry))
                while #self.log > self.maxEntries do
                    tremove(self.log, 1)
                end
                -- the micro menu shows an icon with the count, the first error flashes it
                EventRegistry:TriggerEvent("GW2_UI.ErrorLogged", #self.log, self.errors == 1)

                if self.errors == 1 then
                    GW.Notice("|cffff0000[ERROR]|r " .. msg .. "\n\nPlease type in |cffbbbbbb/gw2 error|r, create a new ticket on Curse or GitHub, copy & paste the log in there and add any additional info you might have. Thank you! =)")
                end

                break
            end
        end
    end
end

function Gw2ErrorHandlerMixin:OnError(msg, stack, locals)
    self:HandleError(msg, stack, locals)
end

-- Register our error handler
local function CreateErrorHandler()
    local errorFrame = CreateErrorLogWindow()
    errorFrame.log = {}
    errorFrame.errors = 0
    errorFrame.maxEntries = 500
    errorFrame.LOG_MAX_ERRORS = 10
    errorFrame.LOG_MAX_ERROR_RATE = 10
    errorFrame.LOG_MAX_LOCALS_LENGTH = 800
    errorFrame.errorPrev = 0
    errorFrame.errorRate = 0

    if BugGrabber then
        EventRegistry:RegisterCallback("BugGrabber.BugGrabbed", function(_, tableID)
            local error = BugGrabber:GetErrorByID(tableID)
            if error then
                errorFrame:OnError(error.message, error.stack, error.locals ~= "InCombatSkipped" and error.locals or "")
            end
        end)
    else
        local origHandler = geterrorhandler()
        seterrorhandler(function (msg, lvl)
            local r = origHandler and origHandler(msg, lvl) or nil
            lvl = lvl or 1

            if errorFrame:ShouldHandleError() then
                local stack = debugstack(1 + lvl)
                local locals = not (InCombatLockdown() or UnitAffectingCombat("player")) and debuglocals(1 + lvl) or ""

                errorFrame:OnError(msg, stack, locals)
            end

            return r
        end)

    end
end
GW.CreateErrorHandler = CreateErrorHandler

function GW.TestErrorHandler()
    C_Timer.After(0, function()
        local testLocal = "this local shows up in the log"
        error("GW2 test error, the error handler works: " .. testLocal)
    end)
end
