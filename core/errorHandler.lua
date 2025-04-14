local Name, GW = ...
local Debug = GW.Debug

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

    tinsert(UISpecialFrames, "Gw2ErrorLog")

    frame.bg = frame:CreateTexture(nil, "ARTWORK")
    frame.bg:SetAllPoints()
    frame.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/welcome-bg")

    frame.header = frame:CreateFontString(nil, "OVERLAY")
    frame.header:SetFont(DAMAGE_TEXT_FONT, 28, "OUTLINE")
    frame.header:SetTextColor(1, 0.95, 0.8, 1)
    frame.header:SetPoint("TOP", frame, "TOP", 0, -20)
    frame.header:SetText("GW2 Error Log")

    frame.result = frame:CreateFontString(nil, "OVERLAY")
    frame.result:SetFont(UNIT_NAME_FONT, 14, "")
    frame.result:SetTextColor(0.9, 0.85, 0.7, 1)
    frame.result:SetPoint("TOP", frame.subheader, "BOTTOM", 0, -40)

    frame.scrollArea = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -170)
    frame.scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 40)
    frame.scrollArea:SetScript("OnSizeChanged", function(scroll)
        frame.editBox:SetWidth(scroll:GetWidth())
        frame.editBox:SetHeight(scroll:GetHeight())
    end)
    frame.scrollArea:HookScript("OnVerticalScroll", function(scroll, offset)
        frame.editBox:SetHitRectInsets(0, 0, offset, (frame.editBox:GetHeight() - offset - scroll:GetHeight()))
    end)
    frame.scrollArea.bg = frame.scrollArea:CreateTexture(nil, "ARTWORK")
    frame.scrollArea.bg:SetAllPoints()
    frame.scrollArea.bg:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatframebackground")

    frame.editBox = CreateFrame("EditBox", nil, frame)
    frame.editBox:SetMultiLine(true)
    frame.editBox:EnableMouse(true)
    frame.editBox:SetAutoFocus(false)
    frame.editBox:SetFontObject(ChatFontNormal)
    frame.editBox:SetAllPoints()
    frame.editBox:SetScript("OnEscapePressed", function() frame:Hide() end)

    frame.scrollArea:SetScrollChild(frame.editBox)

    frame.editBox:SetScript("OnTextChanged", function(_, userInput)
        if userInput then return end
        local _, max = frame.scrollArea.ScrollBar:GetMinMaxValues()
        for _ = 1, max do
            ScrollFrameTemplate_OnMouseWheel(frame.scrollArea, -1)
        end
    end)

    return frame
end

function Gw2ErrorHandlerMixin:Toggle()
    if not self.Skinned then
        self.scrollArea.ScrollBar:GwSkinScrollBar()
        self.close = CreateFrame("Button", nil, self, "GwStandardButton")
        self.close:SetPoint("BOTTOMRIGHT")
        self.close:SetFrameLevel(self.close:GetFrameLevel() + 1)
        self.close:EnableMouse(true)
        self.close:SetSize(128, 28)
        self.close:SetText(CLOSE)
        self.close:SetScript("OnClick", function() self:Hide() end)
        self.Skinned = true
    end

    if self:IsShown() then
        self.editBox:SetText("")
        self:Hide()
    else
        local txt = ("Version: %s Date: %s Locale: %s Build %s %s"):format(GW.VERSION_STRING or "?", date("%m/%d/%y %H:%M:%S") or "?", GW.mylocal or "?", GW.wowpatch, GW.wowbuild)
        txt = txt .. "\n" .. GW.Join("\n", self.log)
        self.editBox:SetText(txt)
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
    local filePattern = Name .. "[\\/]" .. "core[\\/]" .. "errorHandler%.lua[^\n]*"
    if stack:match(filePattern .. "HandleError") then
        self.errors = math.huge
        GW.Notice("|cffff0000[ERROR]|r " .. msg .. "\n\nThis is an error in the error-handling system itself. Please create a new ticket on Curse, Discord or GitHub, copy & paste the error message in there and add any additional info you might have. Thank you! =)")
    elseif self.errors < self.LOG_MAX_ERRORS then
        self.errorRate = max(0, self.errorRate - self.LOG_MAX_ERROR_RATE * (GetTime() - self.errorPrev)) + 1
        self.errorPrev = GetTime()

        for match in stack:gmatch("%[?" .. Name .. "[\\/]+([^:%]]+)") do
            if match and not GW.StartsWith(match, "Libs") and not GW.StartsWith(match, "libs") then
                self.errors = self.errors + 1
                Debug("ERROR", msg .. "\n" .. stack)
                tinsert(self.log, ("[%s] |cffff0000[ERROR]|r: %s"):format(date("%H:%M:%S"), (msg .. "\n" .. stack) or "-"))
                while #self.log > self.maxEntries do
                    tremove(self.log, 1)
                end

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
    errorFrame.errorPrev = 0
    errorFrame.errorRate = 0

    if BugGrabber then
        BugGrabber.RegisterCallback(errorFrame, "BugGrabber_BugGrabbed", function (_, err)
            errorFrame:OnError(err.message, err.stack, err.locals ~= "InCombatSkipped" and err.locals or "")
        end)
    else
        local origHandler = geterrorhandler()
        seterrorhandler(function (msg, lvl)
            local r = origHandler and origHandler(msg, lvl) or nil
            lvl = lvl or 1

            if errorFrame:ShouldHandleError() then
                local stack = debugstack(2 + lvl)
                local locals = not (InCombatLockdown() or UnitAffectingCombat("player")) and debuglocals(2 + lvl) or ""

                errorFrame:OnError(msg, stack, locals)
            end

            return r
        end)

    end
end
GW.CreateErrorHandler = CreateErrorHandler
