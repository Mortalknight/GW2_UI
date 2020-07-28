local _, GW = ...
local Self_Hide = GW.Self_Hide
local Debug = GW.Debug
local TimeCount = GW.TimeCount
local GetSetting = GW.GetSetting
local DEBUFF_COLOR = GW.DEBUFF_COLOR
local RegisterMovableFrame = GW.RegisterMovableFrame

local function setLongCD(self)
    self.cooldown:Hide()
    self.status.duration:SetFont(UNIT_NAME_FONT, 11)
    self.status.duration:SetShadowColor(0, 0, 0, 1)
    self.status.duration:SetShadowOffset(1, -1)
    self.status.stacks:SetFont(UNIT_NAME_FONT, 12, "OUTLINED")
    self.status.stacks:SetShadowColor(0, 0, 0, 1)
    self.status.stacks:SetShadowOffset(1, -1)

    self.status:ClearAllPoints()
    self.status:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -6)
    self.status:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 2)
    self.border:ClearAllPoints()
    self.border:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -4)
    self.border:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 0)
end
GW.AddForProfiling("aurabar_secure", "setLongCD", setLongCD)

local function setShortCD(self, expires, duration)
    self.cooldown:SetCooldown(expires - duration, duration)
    self.status.duration:SetFont(UNIT_NAME_FONT, 13)
    self.status.duration:SetShadowColor(0, 0, 0, 1)
    self.status.duration:SetShadowOffset(1, -1)
    self.status.stacks:SetFont(UNIT_NAME_FONT, 14, "OUTLINED")
    self.status.stacks:SetShadowColor(0, 0, 0, 1)
    self.status.stacks:SetShadowOffset(1, -1)

    self.status:ClearAllPoints()
    self.status:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4)
    self.status:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 4)
    self.border:ClearAllPoints()
    self.border:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
    self.border:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
end
GW.AddForProfiling("aurabar_secure", "setShortCD", setShortCD)

local function SetCD(self, expires, duration)
    if not self or not self.status or not self.gwInit then
        return
    end

    if self.atype == 2 then
        -- temp weapon enchant
        local remains = expires/1000
        setLongCD(self)
        self.status.duration:SetText(TimeCount(remains))
        self.status.duration:Show()
    elseif duration and duration ~= 0 then
        -- normal aura with duration
        local remains = expires - GetTime()
        if duration < 121 then
            setShortCD(self, expires, duration)
            if duration - remains < 0.1 then
                self.agZoomIn:Play()
            end
        else
            setLongCD(self)
        end
        self.status.duration:SetText(TimeCount(remains))
        self.status.duration:Show()
    else
        -- aura without duration or invalid
        setLongCD(self)
        self.status.duration:Hide()
    end
end
GW.AddForProfiling("aurabar_secure", "SetCD", SetCD)

local function UpdateCD(self, remains)
    if not self or not self.status or not self.gwInit then
        return
    end
    if not remains or remains < 0 then
        return
    end

    self.status.duration:SetText(TimeCount(remains))
end
GW.AddForProfiling("aurabar_secure", "UpdateCD", UpdateCD)

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
GW.AddForProfiling("aurabar_secure", "SetCount", SetCount)

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

    local atype = self.atype
    if atype == 1 then
        self.border.inner:SetVertexColor(0, 0, 0)
    else
        if atype == 2 then
            dtype = "Curse"
        end
        local c = DEBUFF_COLOR[dtype]
        if not c then
            c = DEBUFF_COLOR["none"]
        end
        self.border.inner:SetVertexColor(c.r, c.g, c.b)
    end

end
GW.AddForProfiling("aurabar_secure", "SetIcon", SetIcon)

local function GetFilter(self)
    return self:GetParent():GetFilter(self)
end
GW.AddForProfiling("aurabar_secure", "GetFilter", GetFilter)

local function header_OnEvent(self, event, ...)
    local unit = select(1, ...)
    local valid = false
    if event == "PLAYER_ENTERING_WORLD" then
        valid = true
    elseif event == "UNIT_AURA" and unit == "player" then
        valid = true
    elseif event == "UNIT_INVENTORY_CHANGED" and unit == "player" then
        valid = true
    end
    if not valid then return end
    
    -- set info for each aura button (on aura change events)
    if event == "UNIT_AURA" or event == "PLAYER_ENTERING_WORLD" then
        local atype = self:GetAType()
        for i = 1, 40 do
            local btn = self:GetAura(i)
            if not btn or not btn:IsShown() then
                -- only look at buttons that have info
                break
            end

            local name, icon , count, dtype, duration, expires, _ = UnitAura("player", btn:GetID(), btn:GetFilter())
            if name then
                btn.atype = atype
                btn:SetIcon(icon, dtype)
                btn:SetCD(expires, duration)
                btn:SetCount(count)
            end
        end
    end

    -- set info for weapon enchants (on any event)
    local weigot, mh, mh_exp, mh_num, oh, oh_exp, oh_num, rh, rh_exp, rh_num
    for i = 1, 3 do
        local btn = self:GetTempEnchant(i)
        if btn then
            TemporaryEnchantFrame:Hide()
            -- only look at buttons that have info
            if not weigot then
                mh, mh_exp, mh_num, _, oh, oh_exp, oh_num, _, rh, rh_exp, rh_num, _= GetWeaponEnchantInfo()
                weigot = true
            end
            local slot = INVSLOT_MAINHAND - 1 + i
            local icon = GetInventoryItemTexture("player", slot)

            btn.atype = 2
            btn.slotId = slot
            btn:SetIcon(icon)
            if slot == INVSLOT_MAINHAND and mh then
                btn:SetCount(mh_num)
                btn:SetCD(mh_exp, -1)
            elseif slot == INVSLOT_OFFHAND and oh then
                btn:SetCount(oh_num)
                btn:SetCD(oh_exp, -1)
            elseif slot == INVSLOT_RANGED and rh then
                btn:SetCount(rh_num)
                btn:SetCD(rh_exp, -1)
            end
        end
    end
end
GW.AddForProfiling("aurabar_secure", "header_OnEvent", header_OnEvent)

local function header_OnUpdate(self, elapsed)
    if self.timer > 0 then
        self.timer = self.timer - elapsed
        return
    end
    self.timer = 0.2

    -- update the cooldown text for each aura
    for i = 1, 40 do
        local btn = self:GetAura(i)
        if not btn or not btn:IsShown() then
            -- only look at auras being used
            break
        end

        local name, _ , _, _, duration, expires, _ = UnitAura("player", btn:GetID(), btn:GetFilter())
        if name and duration then
            btn:UpdateCD(expires - GetTime())
        end
    end

    -- update the cooldown text for each weapon enchant
    local weigot, mh, mh_exp, oh, oh_exp, rh, rh_exp
    for i = 1, 3 do
        local btn = self:GetTempEnchant(i)
        if btn and btn:IsShown() then
            -- only look at auras being used
            if not weigot then
                mh, mh_exp, _, _, oh, oh_exp, _, _, rh, rh_exp, _ = GetWeaponEnchantInfo()
                weigot = true
            end
    
            local slot = INVSLOT_MAINHAND - 1 + i
            local remain = 0
            if slot == INVSLOT_MAINHAND and mh and mh_exp > 0 then
                remain = mh_exp / 1000
            elseif slot == INVSLOT_OFFHAND and oh and oh_exp > 0 then
                remain = oh_exp / 1000
            elseif slot == INVSLOT_RANGED and rh and rh_exp > 0 then
                remain = rh_exp / 1000
            end
            btn:UpdateCD(remain)
        end
    end

end
GW.AddForProfiling("aurabar_secure", "header_OnUpdate", header_OnUpdate)

local function aura_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    GameTooltip:ClearLines()
    local atype = self.atype
    if atype == 0 then
        GameTooltip:SetUnitDebuff("player", self:GetID(), self:GetFilter())
    elseif atype == 1 then
        GameTooltip:SetUnitBuff("player", self:GetID())
    elseif atype == 2 then
        GameTooltip:SetInventoryItem("player", self.slotId, false, true)
    end
    GameTooltip:Show()
end
GW.AddForProfiling("aurabar_secure", "aura_OnEnter", aura_OnEnter)

local function cancelAura(self)
    local slot = tonumber(self.targetSlot)
    if slot then
        if slot == 16 or slot == 17 then
            -- currently doesn't work as this is set protected
            --CancelItemTempEnchantment(slot - 15)
        end
    else
        local index = self:GetID()
        if index then
            CancelUnitBuff("player", index, self.filter)
        end
    end
end

local function auraFrame_OnClick(self, button, down)
    if not InCombatLockdown() and button == "RightButton" and self.atype ~= 0 then
        cancelAura(self)
    end
end
GW.AddForProfiling("aurabar_secure", "auraFrame_OnClick", auraFrame_OnClick)

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
    self.UpdateCD = UpdateCD
    self.SetCount = SetCount
    self.SetIcon = SetIcon
    self.GetFilter = GetFilter

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
    self:HookScript("OnEnter", aura_OnEnter)
    self:HookScript("OnLeave", GameTooltip_Hide)

    if not self:GetAttribute("type2") then
        -- not a secure handler; add our own right-click buff removal
        self:SetScript("OnClick", auraFrame_OnClick)
    end

    self.gwInit = true
end

local function getSecureAura(self, idx)
    return self:GetAttribute("child" .. idx)
end
GW.AddForProfiling("aurabar_secure", "getSecureAura", getSecureAura)

local function getSecureTempEnchant(self, idx)
    return self:GetAttribute("tempEnchant" .. idx)
end
GW.AddForProfiling("aurabar_secure", "getSecureTempEnchant", getSecureTempEnchant)

local function getSecureFilter(self, btn)
    return btn:GetAttribute("filter")
end
GW.AddForProfiling("aurabar_secure", "getSecureFilter", getSecureFilter)

local function getSecureAType(self)
    return self:GetAttribute("filter") == "HELPFUL" and 1 or 0
end
GW.AddForProfiling("aurabar_secure", "getSecureAType", getSecureAType)

local function getLegacyAura(self, idx)
    return self.buttons[idx]
end
GW.AddForProfiling("aurabar_secure", "getLegacyAura", getLegacyAura)

local function getLegacyFilter(self, btn)
    return btn.filter
end
GW.AddForProfiling("aurabar_secure", "getLegacyFilter", getLegacyFilter)

local function getLegacyTempEnchant(self, idx)
    return self.tempenchants[idx]
end
GW.AddForProfiling("aurabar_secure", "getLegacyTempEnchant", getLegacyTempEnchant)

local function newHeader(filter, secure, settingname)
    local h, w, aura_tmpl
    local size = tonumber(GW.RoundDec(GetSetting(settingname .. "_ICON_SIZE")))
    if secure then
        -- "secure" style auras
        h = CreateFrame("Frame", nil, UIParent, "SecureAuraHeaderTemplate,SecureHandlerStateTemplate")
        aura_tmpl = format("GwAuraSecureTmpl%d", size)
        h.GetAura = getSecureAura
        h.GetTempEnchant = getSecureTempEnchant
        h.GetFilter = getSecureFilter
        h.GetAType = getSecureAType
    else
        -- "legacy" style auras
        w = GW.CreateModifiedAuraHeader(settingname)
        h = w.inner
        aura_tmpl = format("GwAuraTmpl%d", size)
        h.GetAura = getLegacyAura
        h.GetTempEnchant = getLegacyTempEnchant
        h.GetFilter = getLegacyFilter
        h.GetAType = getSecureAType
    end
    -- TODO: implement "GW2" style auras

    local grow_dir = GetSetting(settingname .. "_GrowDirection")
    local aura_style = GetSetting("PLAYER_AURA_STYLE")
    local wrap_num = tonumber(GetSetting("PLAYER_AURA_WRAP_NUM"))
    if not wrap_num or wrap_num < 1 or wrap_num > 20 then
        wrap_num = 7
    end
    Debug("settings", settingname, grow_dir, aura_style, wrap_num, size)

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
    if not secure then
        -- this is custom to our modified header thing; if Blizz adopts our
        -- recommendations this will not work exactly as-is for secure stuff
        -- (which is OK because "GW2" style will work as-is, this is just
        -- legacy, and if the Blizz change is made we will eventually deprecate
        -- the legacy style and have only GW2 & Secure options; though at that
        -- point the GW2 style would *also* be secure)
        h:SetAttribute("consolidateGroup", true)
        h:SetAttribute("consolidateTo", "-1")
        h:SetAttribute("consolidateDuration", "120")
        h:SetAttribute("consolidateThreshold", "120")
        h:SetAttribute("consolidateFraction", "0")
        h:SetAttribute("sortMethod", "CONSOLIDATEIDX")
        h:SetAttribute("sortDirection", "-")
    else
        h:SetAttribute("sortMethod", "INDEX")
        h:SetAttribute("sortDirection", "+")
    end
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
        h:SetAttribute("includeWeapons", "1")
        h:SetAttribute("weaponTemplate", aura_tmpl)
    end

    -- setup event handling
    h.timer = 0.2
    h:UnregisterAllEvents()
    h:HookScript("OnEvent", header_OnEvent)
    h:HookScript("OnUpdate", header_OnUpdate)
    h:RegisterUnitEvent("UNIT_AURA", "player")
    h:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
    h:RegisterEvent("PLAYER_ENTERING_WORLD")

    if w then
        return w
    else
        return h
    end
end
GW.AddForProfiling("aurabar_secure", "newHeader", newHeader)

local function loadAuras(lm, secure)
    local grow_dir = GetSetting("PlayerBuffFrame_GrowDirection")
    local anchor_hb = grow_dir == "UPR" and "BOTTOMLEFT" or grow_dir == "DOWNR" and "TOPLEFT" or grow_dir == "UP" and "BOTTOMRIGHT" or grow_dir == "DOWN" and "TOPRIGHT"

    -- create a new header for buffs
    local hb = newHeader("HELPFUL", secure, "PlayerBuffFrame")
    hb:SetAttribute("growDir", grow_dir)
    GW.RegisterScaleFrame(hb)
    hb:Show()
    if hb.inner then
        hb.inner:Show()
    end
    RegisterMovableFrame(hb, SHOW_BUFFS, "PlayerBuffFrame", "VerticalActionBarDummy", {316, 100}, true, true)
    hb:ClearAllPoints()
    hb:SetPoint(anchor_hb, hb.gwMover, anchor_hb, 0, 0)
    lm:RegisterBuffFrame(hb)
    hooksecurefunc(hb.gwMover, "StopMovingOrSizing", function (frame)
        local grow_dir = GetSetting("PlayerBuffFrame_GrowDirection")
        local anchor_hb = grow_dir == "UPR" and "BOTTOMLEFT" or grow_dir == "DOWNR" and "TOPLEFT" or grow_dir == "UP" and "BOTTOMRIGHT" or grow_dir == "DOWN" and "TOPRIGHT"

        if not InCombatLockdown() then
            hb:ClearAllPoints()
            hb:SetPoint(anchor_hb, hb.gwMover, anchor_hb, 0, 0)
        end
    end)

    -- create a new header for debuffs
    local grow_dir = GetSetting("PlayerDebuffFrame_GrowDirection")
    local hd = newHeader("HARMFUL", secure, "PlayerDebuffFrame")
    local anchor_hd
    GW.RegisterScaleFrame(hd)
    lm:RegisterDebuffFrame(hd)
    RegisterMovableFrame(hd, SHOW_DEBUFFS, "PlayerDebuffFrame", "VerticalActionBarDummy", {316, 60}, true, true)
    hd:Show()
    if hd.inner then
        hd.inner:Show()
    end
    hd:ClearAllPoints()
    if not hd.isMoved then
        anchor_hd = grow_dir == "UPR" and "TOPLEFT" or grow_dir == "DOWNR" and "BOTTOMLEFT" or grow_dir == "UP" and "TOPRIGHT" or grow_dir == "DOWN" and "BOTTOMRIGHT"
        if grow_dir == "DOWNR" or grow_dir == "DOWN" then
            if hd.inner and hb.inner then
                hd.inner:ClearAllPoints()
                hd.inner:SetPoint(anchor_hd, hb.inner, anchor_hd, 0, -50)
            else
                hd:SetPoint(anchor_hd, hb, anchor_hd, 0, -50)
            end
        else
            if hd.inner and hb.inner then
                hd.inner:ClearAllPoints()
                hd.inner:SetPoint(anchor_hd, hb.inner, anchor_hd, 0, 50)
            else
                hd:SetPoint(anchor_hd, hb, anchor_hd, 0, 50)
            end
        end
    else
        anchor_hd = grow_dir == "UPR" and "BOTTOMLEFT" or grow_dir == "DOWNR" and "TOPLEFT" or grow_dir == "UP" and "BOTTOMRIGHT" or grow_dir == "DOWN" and "TOPRIGHT"
        hd:SetPoint(anchor_hd, hd.gwMover, anchor_hd, 0, 0)
    end
    hooksecurefunc(hd.gwMover, "StopMovingOrSizing", function (frame)
        local grow_dir = GetSetting("PlayerDebuffFrame_GrowDirection")
        local anchor_hd = grow_dir == "UPR" and "BOTTOMLEFT" or grow_dir == "DOWNR" and "TOPLEFT" or grow_dir == "UP" and "BOTTOMRIGHT" or grow_dir == "DOWN" and "TOPRIGHT"

        if not InCombatLockdown() then
            hd:ClearAllPoints()
            hd:SetPoint(anchor_hd, hd.gwMover, anchor_hd, 0, 0)
        end
    end)
end

local function LoadPlayerAuras(lm)
    -- hide default buffs
    BuffFrame:Kill()
    BuffFrame:SetScript("OnShow", Self_Hide)

    local aura_style = GetSetting("PLAYER_AURA_STYLE")
    local secure = aura_style == "SECURE" or false
    Debug("player aura style", aura_style, secure)

    loadAuras(lm, secure)
end
GW.LoadPlayerAuras = LoadPlayerAuras

