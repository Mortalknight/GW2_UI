local _, GW = ...
--local AddActionBarCallback = GW.AddActionBarCallback
local Self_Hide = GW.Self_Hide
--local LoadAuras = GW.LoadAuras
--local UpdateBuffLayout = GW.UpdateBuffLayout
--local GetSetting = GW.GetSetting
--local RegisterMovableFrame = GW.RegisterMovableFrame
local Debug = GW.Debug
local TimeCount = GW.TimeCount

local function header_OnEvent(self, event, ...)
    if event ~= "PLAYER_ENTERING_WORLD" and (event ~= "UNIT_AURA" or select(1, ...) ~= "player") then
        return
    end

    for i = 1, 40 do
        local btn = self:GetAttribute("child" .. i)
        if not btn or not btn:IsShown() then
            -- only look at buttons that have valid aura info
            break
        end

        -- the 3rd parameter should match the secure header's filter attribute, by using the same string
        local name, icon , count, _, duration, expires, _, _, cons = UnitAura("player", btn:GetID(), btn:GetAttribute("filter"))
        Debug("bbtn", i, btn:GetID(), name, count, expires, cons)
        if name then
            btn.status.icon:SetTexture(icon)
            if count and count > 0 then
                btn.status.stacks:SetText(count)
                btn.status.stacks:Show()
            else
                btn.status.stacks:Hide()
            end
            if duration and expires and duration > 0 then
                btn.status.duration:SetText(TimeCount(expires - GetTime()))
                btn.status.duration:Show()
            else
                btn.status.duration:Hide()
            end
        end
    end

    local ahs = self:GetAttribute("consolidateHeader")
    for i = 1, 40 do
        local btn = ahs:GetAttribute("child" .. i)
        if not btn or not btn:IsShown() then
            -- only look at buttons that have valid aura info
            break
        end

        -- the 3rd parameter should match the secure header's filter attribute, by using the same string
        local name, icon , count, _, duration, expires, _, _, cons = UnitAura("player", btn:GetID(), btn:GetAttribute("filter"))
        Debug("cbtn", i, btn:GetID(), name, count, expires, cons)
        if name then
            btn.status.icon:SetTexture(icon)
            if count and count > 0 then
                btn.status.stacks:SetText(count)
                btn.status.stacks:Show()
            else
                btn.status.stacks:Hide()
            end
            if duration and expires and duration > 0 then
                btn.status.duration:SetText(TimeCount(expires - GetTime()))
                btn.status.duration:Show()
            else
                btn.status.duration:Hide()
            end
        end
    end

end

function GwAuraTimerTmpl_OnLoad(self)
    self.status.icon:SetPoint("TOPLEFT", self.status, "TOPLEFT", 3, -3)
    self.status.icon:SetPoint("BOTTOMRIGHT", self.status, "BOTTOMRIGHT", -3, 3)
    self.status.duration:SetFont(UNIT_NAME_FONT, 14)
    self.status.stacks:SetFont(UNIT_NAME_FONT, 14, "OUTLINED")
    self.gwInit = true
end

function GwAuraNoTimerTmpl_OnLoad(self)
    self.status.icon:SetPoint("TOPLEFT", self.status, "TOPLEFT", 1, -1)
    self.status.icon:SetPoint("BOTTOMRIGHT", self.status, "BOTTOMRIGHT", -1, 1)
    self.status.duration:SetFont(UNIT_NAME_FONT, 11)
    self.status.stacks:SetFont(UNIT_NAME_FONT, 12, "OUTLINED")
    self.gwInit = true
end

local function LoadAurasSecureHopeful()
    BuffFrame:Hide()
    BuffFrame:SetScript("OnShow", Self_Hide)
    local ahb = CreateFrame("Frame", nil, UIParent, "SecureAuraHeaderTemplate")
    local ahs = CreateFrame("Frame", nil, UIParent, "SecureFrameTemplate")

    ahb:ClearAllPoints()
    ahb:SetPoint("CENTER", UIParent, "CENTER", 30, -50)

    ahb:SetAttribute("template", "GwAuraTimerTmpl")
    ahb:SetAttribute("unit", "player")
    ahb:SetAttribute("filter", "HELPFUL")
    ahb:SetAttribute("minWidth", "1")
    ahb:SetAttribute("minHeight", "32")
    ahb:SetAttribute("sortMethod", "TIME")
    ahb:SetAttribute("sortDirection", "-")
    ahb:SetAttribute("separateOwn", "1")
    --ahb:SetAttribute("includeWeapons", "1")
    ahb:SetAttribute("point", "LEFT")
    ahb:SetAttribute("xOffset", "34")
    ahb:SetAttribute("yOffset", "0")
    ahb:SetAttribute("wrapAfter", "40")
    ahb:SetAttribute("wrapXOffset", "0")
    ahb:SetAttribute("wrapYOffset", "34")
    
    ahb:SetAttribute("consolidateTo", "-1")
    ahb:SetAttribute("consolidateDuration", "120")
    ahb:SetAttribute("consolidateThreshold", "120")
    ahb:SetAttribute("consolidateFraction", "0")
    ahb:SetAttribute("consolidateAll", "-1")

    ahs:ClearAllPoints()
    ahs:SetPoint("BOTTOMLEFT", ahb, "BOTTOMRIGHT", 2, 0)

    ahs:SetAttribute("template", "GwAuraNoTimerTmpl")
    ahs:SetAttribute("unit", "player")
    ahs:SetAttribute("filter", "HELPFUL")
    ahs:SetAttribute("groupBy", "INCLUDE_NAME_PLATE_ONLY")
    ahs:SetAttribute("minWidth", "28")
    ahs:SetAttribute("minHeight", "28")
    ahs:SetAttribute("point", "LEFT")
    ahs:SetAttribute("xOffset", "30")
    ahs:SetAttribute("yOffset", "0")
    ahs:SetAttribute("wrapAfter", "40")
    ahs:SetAttribute("wrapXOffset", "0")
    ahs:SetAttribute("wrapYOffset", "30")

    ahb:SetAttribute("consolidateHeader", ahs)

    ahb:HookScript("OnEvent", header_OnEvent)
    ahb:UnregisterAllEvents()
    ahb:RegisterUnitEvent("UNIT_AURA", "player")
    ahb:RegisterEvent("PLAYER_ENTERING_WORLD")

    ahb:Show()
    ahs:Show()
end
GW.LoadAurasSecureHopeful = LoadAurasSecureHopeful
