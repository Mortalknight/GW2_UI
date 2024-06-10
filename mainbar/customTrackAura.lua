local _, GW = ...

local trackedIds = {}
local searchIDs = {}

local function findBuffs(unit, ...)
    local auraData
    table.wipe(searchIDs)
    for i = 1, select("#", ...) do
        searchIDs["ID" .. select(i, ...)] = true
    end
    local results = nil
    for i = 1, 40 do
        auraData = C_UnitAuras.GetAuraDataByIndex(unit, i)
        if not auraData then
            break
        elseif searchIDs["ID" .. auraData.spellId] then
            if results == nil then
                results = {}
            end
            results[#results + 1] = {name = auraData.name, icon = auraData.icon, count = auraData.applications, duration = auraData.duration, expires = auraData.expirationTime}
        end
    end

    for i = 1, 40 do
        auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
        if not auraData then
            break
        elseif searchIDs["ID" .. auraData.spellId] then
            if results == nil then
                results = {}
            end
            results[#results + 1] = {name = auraData.name, icon = auraData.icon, count = auraData.applications, duration = auraData.duration, expires = auraData.expirationTime}
        end
    end

    if results ~= nil then
        table.sort(results,
            function(a, b)
                if a.expires and b.expires then
                    return tonumber(a.expires) < tonumber(b.expires)
                end
                return a
            end
        )
    end

    return results
end

local function Position(self, button, index)
    local growDirection = GW.settings.AuraTracker_GrowDirection
    local sortDirection = GW.settings.AuraTracker_SortDirection

    local prevButton = index > 1 and _G[self:GetName() .. "Icon" .. (index - 1)] or nil

    button:ClearAllPoints()
    if growDirection == "HORIZONTAL" and sortDirection == "ASC" then
        button:SetPoint("LEFT", prevButton, "RIGHT", 2, 0)
    elseif growDirection == "HORIZONTAL" and sortDirection == "DSC" then
        button:SetPoint("RIGHT", prevButton, "LEFT", -2, 0)
    elseif growDirection == "VERTICAL" and sortDirection == "ASC" then
        button:SetPoint("TOP", prevButton, "BOTTOM", 0, -2)
    elseif growDirection == "VERTICAL" and sortDirection == "DSC" then
        button:SetPoint("BOTTOM", prevButton, "TOP", 0, 2)
    end
end

local function GetIconButton(self, index)
    if _G[self:GetName() .. "Icon" .. index] then
        local frame = _G[self:GetName() .. "Icon" .. index]
        if index == 1 then
            frame:SetPoint("CENTER", self, "CENTER")
        else
            Position(self, frame, index)
        end

        return frame
    else
        local frame = CreateFrame("Button", self:GetName() .. "Icon" .. index, self, "GwCustomAuraTrackerTemplate")
        if index == 1 then
            frame:SetPoint("CENTER", self, "CENTER")
        else
            Position(self, frame, index)
        end

        frame:SetSize(50, 50)
        frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

        frame.cooldown:SetReverse(false)
        frame.cooldown:SetHideCountdownNumbers(false)
        frame.cooldown:SetDrawEdge(false)
        frame.cooldown:SetPoint("TOPLEFT", frame, "TOPLEFT")
        frame.cooldown:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")

        frame.counter:SetFont(UNIT_NAME_FONT, 14, "OUTLINE")
        frame.counter:SetShadowColor(0, 0, 0, 1)
        frame.counter:SetShadowOffset(1, -1)

        tinsert(self.icons, frame)

        GW.RegisterCooldown(frame.cooldown)

        return frame
    end
end

local function OnEvent(self)
    local foundAuras = findBuffs("player", GW.splitString(trackedIds, ","))

    for _, v in pairs(self.icons) do
        v:Hide()
    end

    if foundAuras == nil then
        self:Hide()
        return
    else
        self:Show()
    end

    for i = 1, #foundAuras do
        local iconSlot = GetIconButton(self, i)

        iconSlot.cooldown:SetCooldown(foundAuras[i].expires - foundAuras[i].duration, foundAuras[i].duration)
        iconSlot.counter:SetText(foundAuras[i].count > 1 and foundAuras[i].count or "")

        iconSlot.icon:SetTexture(foundAuras[i].icon)
        iconSlot:Show()
        GW.FrameFlash(self, 0.5, 0.5, 1, true)
    end
end

local function UpdateTrackedAuras()
    trackedIds = tostring(GW.settings.CUSTOM_AURA_TRACKER):trim():gsub("%s*,%s*", ",")

    if trackedIds then
        GWCustomAuraTracker:RegisterUnitEvent("UNIT_AURA", "player")
        GWCustomAuraTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
        GWCustomAuraTracker:SetScript("OnEvent", OnEvent)
        OnEvent(GWCustomAuraTracker)
    else
        GWCustomAuraTracker:UnregisterAllEvents()
        GWCustomAuraTracker:SetScript("OnEvent", nil)
    end
end
GW.UpdateTrackedAuras = UpdateTrackedAuras

local function LoadCustomAuraTracker()
    local eventFrame = CreateFrame("Frame", "GWCustomAuraTracker", UIParent)
    eventFrame:SetSize(50, 50)
    eventFrame:Hide()
    eventFrame.icons = {}

    GW.RegisterMovableFrame(eventFrame, "Aura Tracker", "AuraTrackerPos", ALL, nil, {"default", "scaleable"})
    eventFrame:SetPoint("TOPLEFT", eventFrame.gwMover)

    GW.UpdateTrackedAuras()
end
GW.LoadCustomAuraTracker = LoadCustomAuraTracker