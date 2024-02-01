local _, GW = ...
local Debug = GW.Debug
local DebuffColors = GW.Libs.Dispel:GetDebuffTypeColor()
local BleedList = GW.Libs.Dispel:GetBleedList()
local BadDispels = GW.Libs.Dispel:GetBadList()
local RegisterMovableFrame = GW.RegisterMovableFrame

local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
    UPR = 1,
    DOWNR = 1,
    DOWN = -1,
    UP = -1,
}

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
    UPR = 1,
    DOWNR = -1,
    DOWN = -1,
    UP = 1,
}

local DIRECTION_TO_POINT = {
    DOWNR = "TOPLEFT",
    DOWN = "TOPRIGHT",
    UPR = "BOTTOMLEFT",
    UP = "BOTTOMRIGHT",
}

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
GW.AddForProfiling("aurabar_secure", "aura_OnEnter", AuraOnEnter)

local function AuraOnShow(self)
    if self.enchantIndex then
        self.header.enchants[self.enchantIndex] = self
        self.header.elapsedEnchants = 1
    end
end

local function AuraOnHide(self)
    if self.enchantIndex then
        self.header.enchants[self.enchantIndex] = nil
    else
        self.instant = true
    end
end

local function UpdateAura_OnUpdate(self, xpr, elapsed)
    if self.nextUpdate > 0 then
        self.nextUpdate = self.nextUpdate - elapsed
        return
    end

    local now = GetTime()
    local text, nextUpdate = GW.GetTimeInfo(self.endTime - now)
    self.nextUpdate = nextUpdate

    if self.auraType and self.auraType == 2 then -- temp weapon enchant
        setLongCD(self, self.stackCount)

        self.status.duration:SetText(text)
        self.status.duration:Show()
    elseif self.duration and self.duration ~= 0 then -- normal aura with duration
        local remains = xpr - now
        if self.duration < 121 then
            setShortCD(self, xpr, self.duration, self.stackCount)
            if self.duration - remains < 0.1 then
                if GW.settings.PLAYER_AURA_ANIMATION and (self.oldAuraName ~= self.auraName) then
                    self.agZoomIn:Play()
                end
            end
        else
            setLongCD(self, self.stackCount)
        end
        self.status.duration:SetText(text)
        self.status.duration:Show()
    else -- aura without duration or invalid
        setLongCD(self, self.stackCount)
        self.status.duration:Hide()
    end
end

local function AuraButton_OnUpdate(self, elapsed)
    local xpr = self.endTime
    if xpr then
        UpdateAura_OnUpdate(self, xpr, elapsed)
    end

    if self.elapsed and self.elapsed > 0.1 then
        if GameTooltip:IsOwned(self) then
            SetTooltip(self)
        end

        if xpr then
            GW.UpdateTime(self, xpr)
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

    self.auraName = nil
    self.oldAuraName = nil
    self.endTime = nil
    self.status.duration:SetText("")
    setLongCD(self, 0) -- to reset border and timer
end

local function UpdateTime(self, expires)
    if (expires - GetTime()) < 0.1 then
        ClearAuraTime(self)
    end
end
GW.UpdateTime = UpdateTime

local function SetCD(self, expires, duration, stackCount, auraType, name)
    local oldEnd = self.endTime
    self.endTime = expires
    self.auraType = auraType
    self.stackCount = stackCount
    self.duration = duration
    self.oldAuraName = self.auraName
    self.auraName = name

    if oldEnd ~= self.endTime then
        self.nextUpdate = 0
    end

    UpdateTime(self, expires)
    self.elapsed = 0
end

local function SetCount(self, count)
    if not self or not self.status or not self.gwInit then
        return
    end

    self.status.stacks:SetText(count > 1 and count or "")
end

local function SetIcon(self, icon, dtype, auraType, spellId)
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

        if dtype and BadDispels[spellId] and GW.Libs.Dispel:IsDispellableByMe(dtype) then
            dtype = "BadDispel"
        end
        if not dtype and BleedList[spellId] and GW.Libs.Dispel:IsDispellableByMe("Bleed") then
            dtype = "Bleed"
        end

        local c = DebuffColors[dtype]
        if not c then
            c = DebuffColors.none
        end
        self.border.inner:SetVertexColor(c.r, c.g, c.b)
    end
end

local function UpdateAura(self, index)
    local auraData = C_UnitAuras.GetAuraDataByIndex(self.header:GetUnit(), index, self:GetFilter())
    if not auraData then
        self.oldAuraName = nil
        self.auraName = nil
        return
    end

    local auraType = self.header:GetAType()
    self:SetIcon(auraData.icon, auraData.dispelName, auraType, auraData.spellId)
    self:SetCount(auraData.applications)

    if auraData.duration > 0 and auraData.expirationTime then
        self:SetCD(auraData.expirationTime, auraData.duration, auraData.applications, auraType, auraData.name)
    else
        ClearAuraTime(self)
    end
end

local function UpdateTempEnchant(self, index, expires)
    if expires then
        self:SetIcon(GetInventoryItemTexture("player", index), nil, 2)
        self:SetCount(0)

        self:SetCD(((expires / 1000) or 0) + GetTime(), -1, nil, 2, nil)
    else
        ClearAuraTime(self)
    end
end

local function HeaderOnUpdate(self, elapsed)
    local header = self.frame

    if header.elapsedSpells and header.elapsedSpells > 0.1 then
        local button, value = next(header.spells)
        while button do
            UpdateAura(button, value)

            header.spells[button] = nil
            button, value = next(header.spells)
        end

        header.elapsedSpells = 0
    else
        header.elapsedSpells = (header.elapsedSpells or 0) + elapsed
    end

    if header.elapsedEnchants and header.elapsedEnchants > 0.5 then
        local index, enchant = next(header.enchants)
        if index then
            local _, main, _, _, _, offhand, _, _, _, ranged = GetWeaponEnchantInfo()

            while enchant do
                UpdateTempEnchant(enchant, enchant:GetID(), (index == 1 and main) or (index == 2 and offhand) or (index == 3 and ranged))

                header.enchants[index] = nil
                index, enchant = next(header.enchants)
            end
        end

        header.elapsedEnchants = 0
    else
        header.elapsedEnchants = (header.elapsedEnchants or 0) + elapsed
    end
end

local function GetFilter(self)
    return self.header:GetFilter(self)
end
GW.AddForProfiling("aurabar_secure", "GetFilter", GetFilter)

local function AuraOnAttributeChanged(self, attribute, value)
    if attribute == "index" then
        if self.instant then
            UpdateAura(self, value)
            self.instant = nil
        elseif self.header.spells[self] ~= value then
            self.header.spells[self] = value
        end
    elseif attribute == "target-slot" and self.enchantIndex and self.header.enchants[self.enchantIndex] ~= self then
        self.header.enchants[self.enchantIndex] = self
        self.header.elapsedEnchants = 0
    end
end

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

    self:SetScript("OnAttributeChanged", AuraOnAttributeChanged)

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
    a2:SetScaleFrom(2.5, 2.5)
    a2:SetScaleTo(1.0, 1.0)

    -- add mouseover handlers
    self:SetScript("OnUpdate", AuraButton_OnUpdate)
    self:SetScript("OnEnter", AuraOnEnter)
    self:SetScript("OnShow", AuraOnShow)
    self:SetScript("OnHide", AuraOnHide)
    self:SetScript("OnLeave", GameTooltip_Hide)

    self:RegisterForClicks("AnyUp", "AnyDown")

    self.gwInit = true
end

local function UpdateAuraHeader(header, settingName)
    if not header then return end

    local size = tonumber(GW.RoundDec(GW.settings[settingName .. "_ICON_SIZE"]))
    local aura_tmpl = format("GwAuraSecureTmpl%d", size)
    local grow_dir = GW.settings[settingName .. "_GrowDirection"]
    local maxWraps = GW.settings[settingName .. "_MaxWraps"]
    local horizontalSpacing = tonumber(GW.settings[settingName .. "_HorizontalSpacing"])
    local verticalSpacing = tonumber(GW.settings[settingName .. "_VerticalSpacing"])
    local wrapAfter = header.name == "GW2UIPlayerBuffs" and tonumber(GW.settings.PLAYER_AURA_WRAP_NUM) or tonumber(GW.settings.PLAYER_AURA_WRAP_NUM_DEBUFF)
    if not wrapAfter or wrapAfter < 1 or wrapAfter > 20 then
        wrapAfter = 7
    end

    Debug("settings", settingName, grow_dir, wrapAfter, size)

    header:SetAttribute("sortMethod", GW.settings[settingName .. "_SortMethod"])
    header:SetAttribute("sortDirection", GW.settings[settingName .. "_SortDir"])
    header:SetAttribute("template", aura_tmpl)
    header:SetAttribute("separateOwn", tonumber(GW.RoundDec(GW.settings[settingName .. "_Seperate"])))
    header:SetAttribute("wrapAfter", wrapAfter)
    header:SetAttribute("maxWraps", maxWraps)
    header:SetAttribute("minWidth", ((wrapAfter == 1 and 0 or horizontalSpacing) + size) * wrapAfter)
    header:SetAttribute("minHeight", (size + 1))
    header:SetAttribute("point", DIRECTION_TO_POINT[grow_dir])
    header:SetAttribute("xOffset", DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[grow_dir] * (horizontalSpacing + size))
    header:SetAttribute("yOffset", 0)
    header:SetAttribute("wrapXOffset", 0)
    header:SetAttribute("wrapYOffset", DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[grow_dir] * (verticalSpacing + size))
    header:SetAttribute("growDir", grow_dir)

    if header.filter == "HELPFUL" then
        header:SetAttribute("includeWeapons", 1)
        header:SetAttribute("weaponTemplate", aura_tmpl)
    end

    local index = 1
    local child = select(index, header:GetChildren())
    while child do
        child:SetSize(size, size)

        index = index + 1
        child = select(index, header:GetChildren())
    end

    -- set anchoring
    if header.filter == "HELPFUL" then
        header:ClearAllPoints()
        header:SetPoint(DIRECTION_TO_POINT[grow_dir], header.gwMover, DIRECTION_TO_POINT[grow_dir], 0, 0)
    else
        local anchor_hd
        header:ClearAllPoints()
        if not header.isMoved then
            anchor_hd = grow_dir == "UPR" and "TOPLEFT" or grow_dir == "DOWNR" and "BOTTOMLEFT" or grow_dir == "UP" and "TOPRIGHT" or grow_dir == "DOWN" and "BOTTOMRIGHT"
            header:SetPoint(anchor_hd, GW2UIPlayerBuffs, anchor_hd, 0, DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[grow_dir] * (verticalSpacing + size))
        else
            header:SetPoint(DIRECTION_TO_POINT[grow_dir], header.gwMover, DIRECTION_TO_POINT[grow_dir], 0, 0)
        end
    end
end
GW.UpdateAuraHeader = UpdateAuraHeader

local function newHeader(filter, settingname)
    local name = filter == "HELPFUL" and "GW2UIPlayerBuffs" or "GW2UIPlayerDebuffs"

    local h = CreateFrame("Frame", name, UIParent, "SecureAuraHeaderTemplate")
    h:SetClampedToScreen(true)
    h:UnregisterEvent("UNIT_AURA") -- only need player and vehicle, so we can reduce the calls
    h:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
    h.GetFilter = function(self) return self.filter end
    h.GetAType = function(self) return self.filter == "HELPFUL" and 1 or 0 end
    h.GetUnit = function(self) return self:GetAttribute("unit") end

    -- setup parameters for the header template
    h:SetAttribute("unit", "player")
    h:SetAttribute("filter", filter)
    h.enchants = {}
    h.spells = {}
    h.filter = filter

    h.visibility = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
    h.visibility:SetScript("OnUpdate", HeaderOnUpdate)
    h.visibility.frame = h
    h.name = name

    RegisterAttributeDriver(h, "unit", "[vehicleui] vehicle; player")
    SecureHandlerSetFrameRef(h.visibility, "AuraHeader", h)
    RegisterStateDriver(h.visibility, "customVisibility", "[petbattle] 0; 1")
    h.visibility:SetAttribute("_onstate-customVisibility", [[
        local header = self:GetFrameRef("AuraHeader")
        local hide, shown = newstate == 0, header:IsShown()
        if hide and shown then header:Hide() elseif not hide and not shown then header:Show() end
    ]])

    if filter == "HELPFUL" then
        h:SetAttribute("consolidateDuration", -1)
        h:SetAttribute("consolidateTo", 0)

        RegisterMovableFrame(h, SHOW_BUFFS, "PlayerBuffFrame", ALL .. ",Blizzard,Aura", {316, 100}, {"default", "scaleable"}, true)
    else
        RegisterMovableFrame(h, SHOW_DEBUFFS, "PlayerDebuffFrame", ALL .. ",Blizzard,Aura", {316, 60}, {"default", "scaleable"}, true)
    end

    UpdateAuraHeader(h, settingname)

    return h
end
GW.AddForProfiling("aurabar_secure", "newHeader", newHeader)

local function loadAuras(lm)
    -- create a new header for buffs
    local hb = newHeader("HELPFUL", "PlayerBuffFrame")
    hb:Show()

    lm:RegisterBuffFrame(hb)
    hooksecurefunc(hb.gwMover, "StopMovingOrSizing", function ()
        local grow_dir = GW.settings.PlayerBuffFrame_GrowDirection
        local anchor_hb = grow_dir == "UPR" and "BOTTOMLEFT" or grow_dir == "DOWNR" and "TOPLEFT" or grow_dir == "UP" and "BOTTOMRIGHT" or grow_dir == "DOWN" and "TOPRIGHT"

        if not InCombatLockdown() then
            hb:ClearAllPoints()
            hb:SetPoint(anchor_hb, hb.gwMover, anchor_hb, 0, 0)
        end
    end)

    -- create a new header for debuffs
    local hd = newHeader("HARMFUL", "PlayerDebuffFrame")
    hd:Show()
    lm:RegisterDebuffFrame(hd)
    hooksecurefunc(hd.gwMover, "StopMovingOrSizing", function ()
        local grow_dir = GW.settings.PlayerDebuffFrame_GrowDirection
        local anchor_hd = grow_dir == "UPR" and "BOTTOMLEFT" or grow_dir == "DOWNR" and "TOPLEFT" or grow_dir == "UP" and "BOTTOMRIGHT" or grow_dir == "DOWN" and "TOPRIGHT"

        if not InCombatLockdown() then
            hd:ClearAllPoints()
            hd:SetPoint(anchor_hd, hd.gwMover, anchor_hd, 0, 0)
        end
    end)

    -- Raise PetBattleFrame
    PetBattleFrame:SetFrameLevel(hb:GetFrameLevel() + 5)

    -- creating a mover for private auras (2 atm) -- TODO: Maybe in a future update there is a skinning way
    local privateAurasheader = CreateFrame("Frame", nil, UIParent)
    privateAurasheader:SetSize(80, 40)
    RegisterMovableFrame(privateAurasheader, GW.L["Private Auras"], "PlayerPrivateAuras", ALL .. ",Blizzard,Aura", nil, {"default", "scaleable"}, true)
    privateAurasheader:ClearAllPoints()
    privateAurasheader:SetPoint("TOPLEFT", privateAurasheader.gwMover)

    for i = 1, 2 do
        local aura = privateAurasheader["privateAuraAnchor" .. i]
        aura = CreateFrame("Frame", nil, privateAurasheader, "GwPrivateAuraTmpl")
        aura.auraIndex = i
        if i == 1 then
            aura:SetPoint("TOPRIGHT")
        else
            aura:SetPoint("TOPLEFT")
        end
        local auraAnchor = {
            unitToken = "player",
            auraIndex = aura.auraIndex,
            -- The parent frame of an aura anchor must have a valid rect with a non-zero
            -- size. Each private aura will anchor to all points on its parent,
            -- providing a tooltip when mouseovered.
            parent = aura,
            -- An optional cooldown spiral can be configured to represent duration.
            showCountdownFrame = false,
            showCountdownNumbers = true,
            -- An optional icon can be created and shown for the aura. Omitting this
            -- will display no icon.
            iconInfo = {
                iconWidth = aura.status:GetWidth(),
                iconHeight = aura.status:GetHeight(),
                iconAnchor = {
                    point = "CENTER",
                    relativeTo = aura.status,
                    relativePoint = "CENTER",
                    offsetX = 0,
                    offsetY = 0,
                },
            },
            -- An optional icon duration fontstring can also be configured.
            durationAnchor = {
                point = "TOP",
                relativeTo = aura.status,
                relativePoint = "BOTTOM",
                offsetX = 0,
                offsetY = -4,
            },
        }
        -- Anchors can be removed (and the aura hidden) via the RemovePrivateAuraAnchor
        -- API, passing it the anchor index returned from the Add function.
        aura.anchorIndex = C_UnitAuras.AddPrivateAuraAnchor(auraAnchor)
    end
end

local function LoadPlayerAuras(lm)
    -- hide default buffs
    BuffFrame:GwKill()
    DebuffFrame:GwKill()

    loadAuras(lm)
end
GW.LoadPlayerAuras = LoadPlayerAuras

