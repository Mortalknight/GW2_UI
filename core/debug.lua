---@class GW2
local GW = select(2, ...)

local D = DLAPI

local function Debug(...)
    local msg = ""
    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        msg = msg .. tostring(arg) .. " "
    end
    D.DebugLog("GW2_UI", "%s", msg)
end

local function Trace()
    D.DebugLog("GW2Trace", "%s", "------------------------- Trace -------------------------")
    for i,v in ipairs({("\n"):split(debugstack(2))}) do
        if v ~= "" then
            D.DebugLog("GW2_UI", "%d: %s", i, v)
        end
    end
    D.DebugLog("GW2Trace", "%s", "---------------------------------------------------------")
end

local function EmptyFunc()
end

if D then
    GW.Debug = Debug
    GW.Trace = Trace
    GW.inDebug = true
    C_CVar.SetCVar("fstack_preferParentKeys", "0")
    Debug("debug log initialized")
else
    GW.Debug = EmptyFunc
    GW.Trace = EmptyFunc
    GW.inDebug = false
end

-- Optional integration for the NumyFunctionProfiler addon. Measured layers: the GW
-- table, the oUF api, the oUF tag methods, the shared oUF frame methods, the grid
-- element callbacks and every own Gw*Mixin.
local profilerFrame = CreateFrame("Frame")
profilerFrame:RegisterEvent("ADDON_LOADED")
profilerFrame:SetScript("OnEvent", function(self, _, addonName)
    if addonName ~= "GW2_UI" then return end
    self:UnregisterEvent("ADDON_LOADED")

    if NumyFunctionProfiler then
        NumyFunctionProfiler:WrapModules(GW.addonName, "GW", GW)
        NumyFunctionProfiler:WrapModules(GW.addonName, "oUF", GW.oUF)
        NumyFunctionProfiler:WrapModules(GW.addonName, "oUF-Tags", GW.oUF.Tags.Methods)

        local GRID_ELEMENT_SLOTS = {
            Health = { "PostUpdate", "PostUpdateColor" },
            Power = { "PostUpdate", "PostUpdateColor" },
            Auras = { "PreUpdate", "FilterAura", "PostProcessAuraData", "PostCreateButton", "PostUpdateButton", "PostUpdateInfoRemovedAuraID" },
            ThreatIndicator = { "Override" },
        }
        local function WrapGridCallbacks()
            for _, object in next, GW.oUF.objects do
                for elementKey, slots in pairs(GRID_ELEMENT_SLOTS) do
                    local element = object[elementKey]
                    if element then
                        for _, slot in ipairs(slots) do
                            if type(element[slot]) == "function" then
                                NumyFunctionProfiler:WrapInPlace(GW.addonName, "Grid-" .. elementKey, element, slot)
                            end
                        end
                    end
                end
            end
        end

        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:SetScript("OnEvent", function(frameSelf, event)
            if event == "PLAYER_ENTERING_WORLD" then
                frameSelf:UnregisterEvent("PLAYER_ENTERING_WORLD")
                frameSelf:RegisterEvent("GROUP_ROSTER_UPDATE")
            end
            if frameSelf.gwWrapQueued then return end
            frameSelf.gwWrapQueued = true
            C_Timer.After(1, function()
                frameSelf.gwWrapQueued = nil
                local anyObject = GW.oUF.objects[1]
                if anyObject and not frameSelf.gwFrameMethodsWrapped then
                    frameSelf.gwFrameMethodsWrapped = true
                    NumyFunctionProfiler:WrapModules(GW.addonName, "oUF-Frame", getmetatable(anyObject).__index)
                end
                WrapGridCallbacks()
            end)
        end)

        for name, value in pairs(_G) do
            if type(name) == "string" and type(value) == "table" and name:match("^Gw%w*Mixin$") then
                NumyFunctionProfiler:WrapModules(GW.addonName, name, value)
            end
        end
    end
end)
