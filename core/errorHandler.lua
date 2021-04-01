local Name, GW = ...
local Debug = GW.Debug

-- Thanks at Shrugal for the ErrorHandler

local ErrorHandler = CreateFrame("Frame")
-- Max # of logged addon error messages
ErrorHandler.LOG_MAX_ERRORS = 10
-- Max # of handled errors per second
ErrorHandler.LOG_MAX_ERROR_RATE = 10

ErrorHandler.errors = 0
ErrorHandler.errorPrev = 0
ErrorHandler.errorRate = 0

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

                    if ErrorHandler.errors == 1 then
                        DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r |cffff0000[ERROR]|r " .. msg .. "\n\nPlease create a new ticket on Curse, Discord or GitHub, copy & paste the log in there and add any additional info you might have. Thank you! =)")):gsub("*", GW.Gw2Color)
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
            HandleError(err.message, err.stack, err.locals ~= "InCombatSkipped" and err.locals or "")
        end)
    else
        local origHandler = geterrorhandler()
        seterrorhandler(function (msg, lvl)
            local r = origHandler and origHandler(msg, lvl) or nil
            lvl = lvl or 1

            if ShouldHandleError() then
                local stack = debugstack(2 + lvl)
                local locals = not (InCombatLockdown() or UnitAffectingCombat("player")) and debuglocals(2 + lvl) or ""

                HandleError(msg, stack, locals)
            end

            return r
        end)
    end
end
GW.RegisterErrorHandler = RegisterErrorHandler
