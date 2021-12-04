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

local function SetCD(self, expires, duration, stackCount)
    if not self or not self.status or not self.gwInit then
        return
    end

    if self.atype == 2 then
        -- temp weapon enchant
        local remains = expires / 1000
        setLongCD(self, stackCount)
        self.status.duration:SetText(TimeCount(remains))
        self.status.duration:Show()
    elseif duration and duration ~= 0 then
        -- normal aura with duration
        local remains = expires - GetTime()
        if duration < 121 then
            setShortCD(self, expires, duration, stackCount)
            if duration - remains < 0.1 then
                self.agZoomIn:Play()
            end
        else
            setLongCD(self, stackCount)
        end
        self.status.duration:SetText(TimeCount(remains))
        self.status.duration:Show()
    else
        -- aura without duration or invalid
        setLongCD(self, stackCount)
        self.status.duration:Hide()
    end
end

local function SetCount(self, count)
    if not self or not self.status or not self.gwInit then
        return
    end
    if count and count > 1 then
        self.status.stacks:SetText(count)
        self.status.stacks:Show()
    else
        self.status.stacks:Hide()
    end
end

local function SetIcon(self, icon, dtype)
    if not self or not self.status or not self.gwInit then
        return
    end
    if icon then
        self.status.icon:SetTexture(icon)
        self.status.icon:Show()
    else
        self.status.icon:Hide()
    end

    if self.atype == 1 then
        self.border.inner:SetVertexColor(0, 0, 0)
    else
        if self.atype == 2 then
            dtype = "Curse"
        end
        local c = DEBUFF_COLOR[dtype]
        if not c then
            c = DEBUFF_COLOR["none"]
        end
        self.border.inner:SetVertexColor(c.r, c.g, c.b)
    end

end

local function UpdateAura(button, index)
    local name, icon , count, dtype, duration, expires = UnitAura(button:GetParent():GetUnit(), index, button:GetFilter())

    if name then
        button.atype = button:GetParent():GetAType()
        button:SetIcon(icon, dtype)
        button:SetCD(expires, duration, count)
        button:SetCount(count)
        if duration and GameTooltip:IsOwned(button) then
            GameTooltip:SetUnitAura(button:GetParent():GetUnit(), index, button:GetFilter());
        end
    end
end

local function UpdateTempEnchant(button, index)
    local mh, mh_exp, mh_num, _, oh, oh_exp, oh_num = GetWeaponEnchantInfo()

    local icon = GetInventoryItemTexture("player", index)

    button.atype = 2
    button.slotId = index
    button:SetIcon(icon)
    if index == INVSLOT_MAINHAND and mh then
        button:SetCount(mh_num)
        button:SetCD(mh_exp, -1)
    elseif index == INVSLOT_OFFHAND and oh then
        button:SetCount(oh_num)
        button:SetCD(oh_exp, -1)
    end

    if GameTooltip:IsOwned(button) then
        TempEnchantButton_OnEnter(button)
    end
end

local function aura_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -5, -5)
    GameTooltip:ClearLines()

    if self:GetAttribute("index") then
        GameTooltip:SetUnitAura(SecureButton_GetUnit(self:GetParent()), self:GetID(), self:GetFilter())
    elseif self:GetAttribute("target-slot") then
        GameTooltip:SetInventoryItem("player", self:GetID())
    end
end
GW.AddForProfiling("aurabar_secure", "aura_OnEnter", aura_OnEnter)

local function GetFilter(self)
    return self:GetParent():GetFilter(self)
end
GW.AddForProfiling("aurabar_secure", "GetFilter", GetFilter)

function GwAuraTmpl_OnLoad(self)
    if self.gwInit then
        return
    end

    self.cooldown:SetDrawBling(false)
    self.cooldown:SetDrawEdge(false)
    self.cooldown:SetDrawSwipe(true)
    self.cooldown:SetReverse(false)
    self.cooldown:SetHideCountdownNumbers(true)

    self.atype = 1
    self.SetCD = SetCD
    self.SetCount = SetCount
    self.SetIcon = SetIcon
    self.GetFilter = GetFilter

    self:SetScript("OnAttributeChanged", function(_, attribute, value)
        if attribute == "index" then
            UpdateAura(self, value)
        elseif attribute == "target-slot" then
            UpdateTempEnchant(self, value)
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
    self:SetScript("OnEnter", aura_OnEnter)
    self:SetScript("OnLeave", GameTooltip_Hide)

    self.gwInit = true
end

local function newHeader(filter, settingname)
    local size = tonumber(GW.RoundDec(GetSetting(settingname .. "_ICON_SIZE")))

    local h = CreateFrame("Frame", nil, UIParent, "SecureAuraHeaderTemplate")
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

    RegisterStateDriver(h, "visibility", "[petbattle] hide; show")
    RegisterAttributeDriver(h, "unit", "[vehicleui] vehicle; player")

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

