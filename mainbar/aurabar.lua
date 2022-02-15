local _, GW = ...
local Debug = GW.Debug
local TimeCount = GW.TimeCount
local GetSetting = GW.GetSetting
local DEBUFF_COLOR = GW.DEBUFF_COLOR
local RegisterMovableFrame = GW.RegisterMovableFrame

local function setLongCD(self, stackCount)
    self.cooldown:Hide()
    self.status.duration:SetFont(UNIT_NAME_FONT, 11)
    self.status.duration:SetShadowColor(0, 0, 0, 1)
    self.status.duration:SetShadowOffset(1, -1)
    self.status.stacks:SetShadowColor(0, 0, 0, 1)
    self.status.stacks:SetShadowOffset(1, -1)

    if stackCount and stackCount > 99 then
        self.status.stacks:SetFont(UNIT_NAME_FONT, 10, "OUTLINED")
    else
        self.status.stacks:SetFont(UNIT_NAME_FONT, 12, "OUTLINED")
    end

    self.status:ClearAllPoints()
    self.status:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -6)
    self.status:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 2)
    self.border:ClearAllPoints()
    self.border:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -4)
    self.border:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 0)
end

local function setShortCD(self, expires, duration, stackCount)
    self.cooldown:SetCooldown(expires - duration, duration)
    self.status.duration:SetFont(UNIT_NAME_FONT, 13)
    self.status.duration:SetShadowColor(0, 0, 0, 1)
    self.status.duration:SetShadowOffset(1, -1)
    self.status.stacks:SetShadowColor(0, 0, 0, 1)
    self.status.stacks:SetShadowOffset(1, -1)

    if stackCount and stackCount > 99 then
        self.status.stacks:SetFont(UNIT_NAME_FONT, 10, "OUTLINED")
    else
        self.status.stacks:SetFont(UNIT_NAME_FONT, 14, "OUTLINED")
    end

    self.status:ClearAllPoints()
    self.status:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4)
    self.status:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 4)
    self.border:ClearAllPoints()
    self.border:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
    self.border:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
end

local function SetTooltip(self)
    GameTooltip:ClearLines()

    if self:GetAttribute("index") then
        GameTooltip:SetUnitAura(SecureButton_GetUnit(self.header), self:GetID(), self:GetFilter())
    elseif self:GetAttribute("target-slot") then
        GameTooltip:SetInventoryItem("player", self:GetID())
    end
end

local function AuraOnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -5, -5)

    self.elapsed = 1
end
GW.AddForProfiling("aurabar_secure", "aura_OnEnter", aura_OnEnter)

local function AuraOnShow(self)
    if self.enchantIndex then
        self.header.enchants[self.enchantIndex] = self
    end
end

local function AuraOnHide(self)
    if self.enchantIndex then
        self.header.enchants[self.enchantIndex] = nil
    else
        self.instant = true
    end
end

local function AuraButton_OnUpdate(self, elapsed)
    local xpr = self.endTime
    if xpr then
        if self.auraType and self.auraType == 2 then -- temp weapon enchant
            setLongCD(self, self.stackCount)

            self.status.duration:SetText(TimeCount(xpr - GetTime()))
            self.status.duration:Show()
        elseif self.duration and self.duration ~= 0 then -- normal aura with duration
            local remains = xpr - GetTime()
            if self.duration < 121 then
                setShortCD(self, xpr, self.duration, self.stackCount)
                if self.duration - remains < 0.1 then
                    self.agZoomIn:Play()
                end
            else
                setLongCD(self, self.stackCount)
            end
            self.status.duration:SetText(TimeCount(remains))
            self.status.duration:Show()
        else -- aura without duration or invalid
            setLongCD(self, self.stackCount)
            self.status.duration:Hide()
        end
    end

    if self.elapsed and self.elapsed > 0.1 then
        if GameTooltip:IsOwned(self) then
            SetTooltip(self)
        end

        self.elapsed = 0
    else
        self.elapsed = (self.elapsed or 0) + elapsed
    end
end

local function ClearAuraTime(self)
    self.auraType = nil
    self.stackCount = nil
    self.duration = nil

    self.endTime = nil
    self.status.duration:SetText("")
    setLongCD(self, 0) -- to reset border and timer
end

local function SetCD(self, expires, duration, stackCount, auraType)
    local oldEnd = self.endTime
    self.endTime = expires
    self.auraType = auraType
    self.stackCount = stackCount
    self.duration = duration

    if oldEnd ~= self.endTime then
        self.nextUpdate = 0
    end

    self.elapsed = 0
end

local function SetCount(self, count)
    if not self or not self.status or not self.gwInit then
        return
    end

    self.status.stacks:SetText(count > 1 and count)
end

local function SetIcon(self, icon, dtype, auraType)
    if not self or not self.status or not self.gwInit then
        return
    end

    self.status.icon:SetTexture(icon)

    if auraType == 1 then
        self.border.inner:SetVertexColor(0, 0, 0)
    else
        if auraType == 2 then
            dtype = "Curse"
        end
        local c = DEBUFF_COLOR[dtype]
        if not c then
            c = DEBUFF_COLOR["none"]
        end
        self.border.inner:SetVertexColor(c.r, c.g, c.b)
    end
end

local function UpdateAura(self, index)
    local name, icon, count, dtype, duration, expires = UnitAura(self.header:GetUnit(), index, self:GetFilter())
    if not name then return end

    local auraType = self.header:GetAType()
    self:SetIcon(icon, dtype, auraType)
    self:SetCount(count)

    if duration > 0 and expires then
        self:SetCD(expires, duration, count, auraType)
    else
        ClearAuraTime(self)
    end
end

local function UpdateTempEnchant(self, index, expires)
    if expires then
        self:SetIcon(GetInventoryItemTexture("player", index), nil, 2)
        self:SetCount(0)

        self:SetCD(((expires / 1000) or 0) + GetTime(), -1, nil, 2)
    else
        ClearAuraTime(self)
    end
end

local function HeaderOnUpdate(self, elapsed)
    local header = self.frame

    if header.elapsed and header.elapsed > 0.1 then
        local button, value = next(header.spells)
        while button do
            UpdateAura(button, value)

            header.spells[button] = nil
            button, value = next(header.spells)
        end

        local _, main, _, _, _, offhand = GetWeaponEnchantInfo()
        header.enchantOffhand = offhand
        header.enchantMain = main

        local index, enchant = next(header.enchants)
        while enchant do
            if index == 1 then
                UpdateTempEnchant(enchant, enchant:GetID(), main)
            else
                UpdateTempEnchant(enchant, enchant:GetID(), offhand)
            end
            header.enchants[index] = nil
            index, enchant = next(header.enchants)
        end

        header.elapsed = 0
    else
        header.elapsed = (header.elapsed or 0) + elapsed
    end
end

local function HeaderOnEvent(self)
    local header = self.frame
    if header then
        header.enchants[1] = header.enchantMain and header.enchant1
        header.enchants[2] = header.enchantOffhand and header.enchant2
    end
end

local function GetFilter(self)
    return self.header:GetFilter(self)
end
GW.AddForProfiling("aurabar_secure", "GetFilter", GetFilter)

function GwAuraTmpl_OnLoad(self)
    if self.gwInit then
        return
    end

    self.header = self:GetParent()
    self.name = self:GetName()

    self.enchantIndex = tonumber(strmatch(self.name, "TempEnchant(%d)$"))
    if self.enchantIndex then
        self.header["enchant" .. self.enchantIndex] = self
    else
        self.instant = true
    end

    self.cooldown:SetDrawBling(false)
    self.cooldown:SetDrawEdge(false)
    self.cooldown:SetDrawSwipe(true)
    self.cooldown:SetReverse(false)
    self.cooldown:SetHideCountdownNumbers(true)

    self.SetCD = SetCD
    self.SetCount = SetCount
    self.SetIcon = SetIcon
    self.GetFilter = GetFilter

    self:SetScript("OnAttributeChanged", function(_, attribute, value)
        if attribute == "index" then
            if self.instant then
                UpdateAura(self, value)
                self.instant = nil
            else
                self.header.spells[self] = value
            end
        end
    end)

    setLongCD(self) -- force font info to get set first time

    -- create an animation group to "zoom in" a new aura
    local duration = 0.25
    local ag = self:CreateAnimationGroup()
    self.agZoomIn = ag
    local a1 = ag:CreateAnimation("alpha")
    local a2 = ag:CreateAnimation("scale")

    a1:SetOrder(1)
    a1:SetDuration(duration)
    a2:SetOrder(1)
    a2:SetDuration(duration)

    a1:SetFromAlpha(0.85)
    a1:SetToAlpha(1.0)
    a2:SetFromScale(2.5, 2.5)
    a2:SetToScale(1.0, 1.0)

    -- add mouseover handlers
    self:SetScript("OnUpdate", AuraButton_OnUpdate)
    self:SetScript("OnEnter", AuraOnEnter)
    self:SetScript("OnShow", AuraOnShow)
    self:SetScript("OnHide", AuraOnHide)
    self:SetScript("OnLeave", GameTooltip_Hide)

    self.gwInit = true
end

local function newHeader(filter, settingname)
    local size = tonumber(GW.RoundDec(GetSetting(settingname .. "_ICON_SIZE")))
    local name = filter == "HELPFUL" and "GW2UIPlayerBuffs" or "GW2UIPlayerDebuffs"

    local h = CreateFrame("Frame", name, UIParent, "SecureAuraHeaderTemplate")
    local aura_tmpl = format("GwAuraSecureTmpl%d", size)
    h.GetFilter = function(_, btn) return btn:GetAttribute("filter") end
    h.GetAType = function(self) return self:GetAttribute("filter") == "HELPFUL" and 1 or 0 end
    h.GetUnit = function(self) return self:GetAttribute("unit") end

    local grow_dir = GetSetting(settingname .. "_GrowDirection")
    local wrap_num = tonumber(GetSetting("PLAYER_AURA_WRAP_NUM"))
    if not wrap_num or wrap_num < 1 or wrap_num > 20 then
        wrap_num = 7
    end
    Debug("settings", settingname, grow_dir, wrap_num, size)

    local ap
    local yoff
    local xoff
    if grow_dir == "UPR" then
        ap = "BOTTOMLEFT"
        xoff = (size + 1)
        yoff = 50
    elseif grow_dir == "DOWN" then
        ap = "TOPRIGHT"
        xoff = -(size + 1)
        yoff = -50
    elseif grow_dir == "DOWNR" then
        ap = "TOPLEFT"
        xoff = (size + 1)
        yoff = -50
    else
        ap = "BOTTOMRIGHT"
        xoff = -(size + 1)
        yoff = 50
    end

    -- setup parameters for the header template
    h:SetAttribute("template", aura_tmpl)
    h:SetAttribute("unit", "player")
    h:SetAttribute("filter", filter)
    h.enchants = {}
    h.spells = {}

    h.visibility = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
    h.visibility:SetScript("OnUpdate", HeaderOnUpdate)
    h.visibility:SetScript("OnEvent", HeaderOnEvent)
    h.visibility.frame = h
    h.enchants = {}
    h.name = name

    C_Timer.After(1, function() h.visibility:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player") end)

    RegisterAttributeDriver(h, "unit", "[vehicleui] vehicle; player")
    SecureHandlerSetFrameRef(h.visibility, "AuraHeader", h)
    RegisterStateDriver(h.visibility, "customVisibility", "[petbattle] 0; 1")
    h.visibility:SetAttribute("_onstate-customVisibility", [[
        local header = self:GetFrameRef("AuraHeader")
        local hide, shown = newstate == 0, header:IsShown()
        if hide and shown then header:Hide() elseif not hide and not shown then header:Show() end
    ]])

    h:SetAttribute("sortMethod", "INDEX")
    h:SetAttribute("sortDirection", "+")
    h:SetAttribute("minWidth", (size + 1) * wrap_num)
    h:SetAttribute("minHeight", (size + 1))
    h:SetAttribute("separateOwn", 0)
    h:SetAttribute("point", ap)
    h:SetAttribute("xOffset", xoff)
    h:SetAttribute("yOffset", "0")
    h:SetAttribute("wrapAfter", wrap_num)
    h:SetAttribute("wrapXOffset", "0")
    h:SetAttribute("wrapYOffset", yoff)
    if filter == "HELPFUL" then
        h:SetAttribute("includeWeapons", 1)
        h:SetAttribute("weaponTemplate", aura_tmpl)
        h:SetAttribute("consolidateDuration", -1)
        h:SetAttribute("consolidateTo", 0)
    end

    return h
end
GW.AddForProfiling("aurabar_secure", "newHeader", newHeader)

local function loadAuras(lm)
    local grow_dir = GetSetting("PlayerBuffFrame_GrowDirection")
    local anchor_hb = grow_dir == "UPR" and "BOTTOMLEFT" or grow_dir == "DOWNR" and "TOPLEFT" or grow_dir == "UP" and "BOTTOMRIGHT" or grow_dir == "DOWN" and "TOPRIGHT"

    -- create a new header for buffs
    local hb = newHeader("HELPFUL", "PlayerBuffFrame")
    hb:SetAttribute("growDir", grow_dir)
    hb:Show()

    RegisterMovableFrame(hb, SHOW_BUFFS, "PlayerBuffFrame", "VerticalActionBarDummy", {316, 100}, true, {"default", "scaleable"}, true)
    hb:ClearAllPoints()
    hb:SetPoint(anchor_hb, hb.gwMover, anchor_hb, 0, 0)
    lm:RegisterBuffFrame(hb)
    hooksecurefunc(hb.gwMover, "StopMovingOrSizing", function ()
        local grow_dir = GetSetting("PlayerBuffFrame_GrowDirection")
        local anchor_hb = grow_dir == "UPR" and "BOTTOMLEFT" or grow_dir == "DOWNR" and "TOPLEFT" or grow_dir == "UP" and "BOTTOMRIGHT" or grow_dir == "DOWN" and "TOPRIGHT"

        if not InCombatLockdown() then
            hb:ClearAllPoints()
            hb:SetPoint(anchor_hb, hb.gwMover, anchor_hb, 0, 0)
        end
    end)

    -- create a new header for debuffs
    local grow_dir = GetSetting("PlayerDebuffFrame_GrowDirection")
    local hd = newHeader("HARMFUL", "PlayerDebuffFrame")
    local anchor_hd
    RegisterMovableFrame(hd, SHOW_DEBUFFS, "PlayerDebuffFrame", "VerticalActionBarDummy", {316, 60}, true, {"default", "scaleable"}, true)
    hd:Show()
    hd:ClearAllPoints()
    if not hd.isMoved then
        anchor_hd = grow_dir == "UPR" and "TOPLEFT" or grow_dir == "DOWNR" and "BOTTOMLEFT" or grow_dir == "UP" and "TOPRIGHT" or grow_dir == "DOWN" and "BOTTOMRIGHT"
        if grow_dir == "DOWNR" or grow_dir == "DOWN" then
            hd:SetPoint(anchor_hd, hb, anchor_hd, 0, -50)
        else
            hd:SetPoint(anchor_hd, hb, anchor_hd, 0, 50)
        end
    else
        anchor_hd = grow_dir == "UPR" and "BOTTOMLEFT" or grow_dir == "DOWNR" and "TOPLEFT" or grow_dir == "UP" and "BOTTOMRIGHT" or grow_dir == "DOWN" and "TOPRIGHT"
        hd:SetPoint(anchor_hd, hd.gwMover, anchor_hd, 0, 0)
    end
    lm:RegisterDebuffFrame(hd)
    hooksecurefunc(hd.gwMover, "StopMovingOrSizing", function ()
        local grow_dir = GetSetting("PlayerDebuffFrame_GrowDirection")
        local anchor_hd = grow_dir == "UPR" and "BOTTOMLEFT" or grow_dir == "DOWNR" and "TOPLEFT" or grow_dir == "UP" and "BOTTOMRIGHT" or grow_dir == "DOWN" and "TOPRIGHT"

        if not InCombatLockdown() then
            hd:ClearAllPoints()
            hd:SetPoint(anchor_hd, hd.gwMover, anchor_hd, 0, 0)
        end
    end)

    -- Raise PetBattleFrame
    PetBattleFrame:SetFrameLevel(hb:GetFrameLevel() + 5)
end

local function LoadPlayerAuras(lm)
    -- hide default buffs
    TemporaryEnchantFrame:Kill()
    BuffFrame:Kill()

    loadAuras(lm)
end
GW.LoadPlayerAuras = LoadPlayerAuras

