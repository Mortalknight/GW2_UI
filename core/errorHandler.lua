local Name, GW = ...
local Debug = GW.Debug

-- Thanks at Shrugal for the ErrorHandler

local ErrorHandler = CreateFrame("Frame")
GW.ErrorHandler = ErrorHandler
-- Max # of logged addon error messages
ErrorHandler.LOG_MAX_ERRORS = 10
-- Max # of handled errors per second
ErrorHandler.LOG_MAX_ERROR_RATE = 10
ErrorHandler.LOG_MAX_ENTRIES = 500

ErrorHandler.errors = 0
ErrorHandler.errorPrev = 0
ErrorHandler.errorRate = 0
ErrorHandler.log = {}

local function CreateErrorLogWindow()
    if GW2_ERRORLOG then return GW2_ERRORLOG end

    local frame = CreateFrame("Frame", "GW2_ERRORLOG", UIParent)

    frame:SetSize(700, 600)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:Hide()
    frame:SetFrameStrata("DIALOG")

    tinsert(UISpecialFrames, "GW2_ERRORLOG")

    frame.bg = frame:CreateTexture(nil, "ARTWORK")
    frame.bg:SetAllPoints()
    frame.bg:SetTexture("Interface/AddOns/GW2_UI/textures/welcome-bg")

    frame.header = frame:CreateFontString(nil, "OVERLAY")
    frame.header:SetFont(DAMAGE_TEXT_FONT, 30, "OUTLINE")
    frame.header:SetTextColor(1, 0.95, 0.8, 1)
    frame.header:SetPoint("TOP", 0, -20)
    frame.header:SetText("GW2 Error Log")

    frame.result = frame:CreateFontString(nil, "OVERLAY")
    frame.result:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE")
    frame.result:SetTextColor(0.9, 0.85, 0.7, 1)
    frame.result:SetPoint("TOP", frame.subheader, "BOTTOM", 0, -40)

    frame.scrollArea = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -170)
    frame.scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 40)
    frame.scrollArea.ScrollBar:SkinScrollBar()
    frame.scrollArea:SetScript("OnSizeChanged", function(scroll)
        frame.editBox:SetWidth(scroll:GetWidth())
        frame.editBox:SetHeight(scroll:GetHeight())
    end)
    frame.scrollArea:HookScript("OnVerticalScroll", function(scroll, offset)
        frame.editBox:SetHitRectInsets(0, 0, offset, (frame.editBox:GetHeight() - offset - scroll:GetHeight()))
    end)
    frame.scrollArea.bg = frame.scrollArea:CreateTexture(nil, "ARTWORK")
    frame.scrollArea.bg:SetAllPoints()
    frame.scrollArea.bg:SetTexture("Interface/AddOns/GW2_UI/textures/chatframebackground")

    frame.editBox = CreateFrame("EditBox", nil, frame)
    frame.editBox:SetMultiLine(true)
    frame.editBox:EnableMouse(true)
    frame.editBox:SetAutoFocus(false)
    frame.editBox:SetFontObject(ChatFontNormal)
    frame.editBox:SetWidth(frame.scrollArea:GetWidth())
    frame.editBox:SetHeight(500)

    frame.editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame.scrollArea:SetScrollChild(frame.editBox)
    frame.editBox:SetScript("OnTextChanged", function(_, userInput)
        if userInput then return end
        local _, max = frame.scrollArea.ScrollBar:GetMinMaxValues()
        for _ = 1, max do
            ScrollFrameTemplate_OnMouseWheel(frame.scrollArea, -1)
        end
    end)

    frame.close = CreateFrame("Button", nil, frame, "GwStandardButton")
    frame.close:SetPoint("BOTTOMRIGHT")
    frame.close:SetFrameLevel(frame.close:GetFrameLevel() + 1)
    frame.close:EnableMouse(true)
    frame.close:SetSize(128, 28)
    frame.close:SetText(CLOSE)
    frame.close:SetScript("OnClick", function() frame:Hide() end)

    return frame
end
GW.CreateErrorLogWindow = CreateErrorLogWindow

local function StartsWith(str, str2)
    return type(str) == "string" and str:sub(1, str2:len()) == str2
end

-- Check if we should handle errors
local function ShouldHandleError()
    return ErrorHandler.errors <= ErrorHandler.LOG_MAX_ERRORS
        and ErrorHandler.errorRate - ErrorHandler.LOG_MAX_ERROR_RATE * (GetTime() - ErrorHandler.errorPrev) < ErrorHandler.LOG_MAX_ERROR_RATE
end

local function cleanFilePaths(msg)
    return strtrim(tostring(msg or ""), "\n"):gsub("@?Interface\\AddOns\\", "")
end

-- Check for GW2 errors and log them
local function HandleError(msg, stack)
    if ShouldHandleError() then
        msg = "\"" .. cleanFilePaths(msg) .. "\""
        stack = cleanFilePaths(stack)

        -- Just print the error message if HandleError or LogExport caused it
        local file = Name .. "\\core\\errorHandler.lua[^\n]*"
        if stack:match(file .. "HandleError") then
            ErrorHandler.errors = math.huge
            DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r |cffff0000[ERROR]|r " .. msg .. "\n\nThis is an error in the error-handling system itself. Please create a new ticket on Curse, Discord or GitHub, copy & paste the error message in there and add any additional info you might have. Thank you! =)"):gsub("*", GW.Gw2Color))
        -- Log error message and stack as well as printing the error message
        elseif ErrorHandler.errors < ErrorHandler.LOG_MAX_ERRORS then
            ErrorHandler.errorRate = max(0, ErrorHandler.errorRate - ErrorHandler.LOG_MAX_ERROR_RATE * (GetTime() - ErrorHandler.errorPrev)) + 1
            ErrorHandler.errorPrev = GetTime()

            for match in stack:gmatch(Name .. "\\([^\n]+)") do
                if match and (not StartsWith(match, "Libs") or StartsWith(match, "libs")) then
                    ErrorHandler.errors = ErrorHandler.errors + 1

                    Debug("ERROR", msg .. "\n" .. stack)
                    tinsert(ErrorHandler.log, ("[%s] |cffff0000[ERROR]|r: %s"):format(date("%H:%M:%S"), (msg .. "\n" .. stack) or "-"))
                    while #ErrorHandler.log > ErrorHandler.LOG_MAX_ENTRIES do
                        tremove(ErrorHandler.log, 1)
                    end

                    if ErrorHandler.errors == 1 then
                        DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r |cffff0000[ERROR]|r " .. msg .. "\n\nPlease type in |cffbbbbbb/gw2 error|r, create a new ticket on Curse or GitHub, copy & paste the log in there and add any additional info you might have. Thank you! =)"):gsub("*", GW.Gw2Color))
                    end

                    break
                end
            end
        end
    end
end

-- Register our error handler
local function RegisterErrorHandler()
    if BugGrabber and BugGrabber.RegisterCallback then
        BugGrabber.RegisterCallback(ErrorHandler, "BugGrabber_BugGrabbed", function (_, err)
            HandleError(err.message, err.stack)
        end)
    else
        local origHandler = geterrorhandler()
        seterrorhandler(function (msg, lvl)
            local r = origHandler and origHandler(msg, lvl) or nil
            lvl = lvl or 1

            if ShouldHandleError() then
                local stack = debugstack(2 + lvl)

                HandleError(msg, stack)
            end

            return r
        end)
    end
end
GW.RegisterErrorHandler = RegisterErrorHandler
