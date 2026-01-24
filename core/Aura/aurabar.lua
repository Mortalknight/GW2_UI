local _, GW = ...
local Debug = GW.Debug
local DebuffColors = GW.Libs.Dispel:GetDebuffTypeColor()
local BadDispels = GW.Libs.Dispel:GetBadList()
local RegisterMovableFrame = GW.RegisterMovableFrame

local debuffColorCurve

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

local AttributeCustomsVisibility = [[
    local header = self:GetFrameRef("AuraHeader")
    local hide, shown = newstate == 0, header:IsShown()
    if hide and shown then header:Hide() elseif not hide and not shown then header:Show() end
]]

local AttributeInitialConfig = [[
    local header = self:GetParent()

    self:SetWidth(header:GetAttribute("config-width"))
    self:SetHeight(header:GetAttribute("config-height"))
]]

local function setLongCD(self, stackCount)
    self.cooldown:Hide()
    self.status.duration:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -1)
    self.status.duration:SetShadowColor(0, 0, 0, 1)
    self.status.duration:SetShadowOffset(1, -1)
    self.status.stacks:SetShadowColor(0, 0, 0, 1)
    self.status.stacks:SetShadowOffset(1, -1)

    if stackCount and stackCount > 99 then
        self.status.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "OUTLINE", -2)
    else
        self.status.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "OUTLINE")
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
    self.status.duration:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, nil, -1)
    self.status.duration:SetShadowColor(0, 0, 0, 1)
    self.status.duration:SetShadowOffset(1, -1)
    self.status.stacks:SetShadowColor(0, 0, 0, 1)
    self.status.stacks:SetShadowOffset(1, -1)

    if stackCount and stackCount > 99 then
        self.status.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "OUTLINE", -2)
    else
        self.status.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, "OUTLINE")
    end

    self.status:ClearAllPoints()
    self.status:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4)
    self.status:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 4)
    self.border:ClearAllPoints()
    self.border:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
    self.border:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
end

local function setRetailCooldown(self, auraData, durationObject)
    if durationObject then
        self.cooldown:SetCooldownFromDurationObject(durationObject)
        self.cooldown:SetAlphaFromBoolean(C_UnitAuras.DoesAuraHaveExpirationTime("player", auraData.auraInstanceID), 1, 0)
    else
        self.cooldown:SetCooldown(auraData.expirationTime - auraData.duration, auraData.duration)
    end
end

local function SetTooltip(self)
    GameTooltip:ClearLines()

    if self:GetAttribute("index") then
        GameTooltip:SetUnitAura(self.header:GetAttribute("unit"), self:GetID(), self:GetFilter())
    elseif self:GetAttribute("target-slot") then
        GameTooltip:SetInventoryItem("player", self:GetID())
    end
end

local function AuraOnEnter(self)
    if(GameTooltip:IsForbidden() or not self:IsVisible()) then return end
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -5, -5)

    if GW.Retail then
        if self:GetAttribute("target-slot") then
            GameTooltip:SetInventoryItem("player", self:GetID())
        else
            --GameTooltip:SetUnitAuraByAuraInstanceID("player", self.auraInstanceID)
            GameTooltip:SetUnitAura("player", self:GetID(), self:GetFilter())
        end
    else
        self.elapsed = 1
    end
end

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
                if GW.settings[self.header.setting].NewAuraAnimation and (self.oldAuraName ~= self.auraName) then
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
    self.auraInstanceID = nil
    self.status.duration:SetText("")

    if not GW.Retail then
        setLongCD(self, 0) -- to reset border and timer
    end
end

local function UpdateTime(self, expires)
    if (expires - GetTime()) < 0.1 then
        ClearAuraTime(self)
    end
end
GW.UpdateTime = UpdateTime

local function SetCD(self, auraData, auraType, durationObject)
    local oldEnd = self.endTime
    self.endTime = auraData.expirationTime
    self.auraType = auraType
    self.stackCount = auraData.applications
    self.oldAuraName = self.auraName
    self.auraName = auraData.name
    self.auraInstanceID = auraData.auraInstanceID
    self.duration = auraData.duration

    if not GW.Retail and oldEnd ~= self.endTime then
        self.nextUpdate = 0
    end

    if GW.Retail then
        setRetailCooldown(self, auraData, durationObject)
    else
        UpdateTime(self, self.endTime)
        self.elapsed = 0
    end
end

local function SetCount(self, auraData)
    if not self or not self.status or not self.gwInit then
        return
    end

    if GW.Retail then
        self.status.stacks:SetText(C_UnitAuras.GetAuraApplicationDisplayCount("player", auraData.auraInstanceID, 2, 999))
    else
        self.status.stacks:SetText(auraData.applications > 1 and auraData.applications or "")
    end
end

local function SetIcon(self, icon, dtype, auraType, spellId)
    if not self or not self.status or not self.gwInit then
        return
    end

    self.status.icon:SetTexture(icon)

    if auraType == 1 then
        self.border.inner:SetVertexColor(0, 0, 0)
    else
        if GW.Retail then
            local color
            if GW.IsSecretValue(auraType) then
                color = C_UnitAuras.GetAuraDispelTypeColor("player", self.auraInstanceID, debuffColorCurve)
            else
                color = GW.DebuffColors[auraType]
            end
            self.border.inner:SetVertexColor(color:GetRGB())
        else
            if auraType == 2 then
                dtype = "Curse"
            end

            if dtype and BadDispels[spellId] and GW.Libs.Dispel:IsDispellableByMe(dtype) then
                dtype = "BadDispel"
            end

            local c = DebuffColors[dtype]
            if not c then
                c = DebuffColors.none
            end
            self.border.inner:SetVertexColor(c.r, c.g, c.b)
        end
    end
end

local function UpdateAura(self, index)
    local auraData = C_UnitAuras.GetAuraDataByIndex(self.header:GetUnit(), index, self:GetFilter())
    if not auraData then
        self.oldAuraName = nil
        self.auraName = nil
        self.auraInstanceID = nil
        return
    end

    local auraType = self.header:GetAType()
    self.auraInstanceID = auraData.auraInstanceID
    self:SetIcon(auraData.icon, auraData.dispelName, auraType, auraData.spellId)
    self:SetCount(auraData)

    if GW.Retail then
        local durationObject = C_UnitAuras.GetAuraDuration("player", auraData.auraInstanceID)
        if durationObject then
			self:SetCD(auraData, auraType, durationObject)
		else
			ClearAuraTime(self)
		end
    else
        if auraData.duration > 0 and auraData.expirationTime then
            self:SetCD(auraData, auraType)
        else
            ClearAuraTime(self)
        end
    end
end

local function UpdateTempEnchant(self, index, expires)
    if expires then
        self:SetIcon(GetInventoryItemTexture("player", index), nil, 2)
        self.status.stacks:SetText("")
        local auraData = {
            expirationTime = (expires / 1000) + GetTime(),
            duration = (expires / 1000),
            applications = 0,
            name = GetInventoryItemLink("player", index),
        }
        self:SetCD(auraData, 2)
    else
        ClearAuraTime(self)
    end
end

local function HeaderOnEvent(self, event)
    if event == "WEAPON_ENCHANT_CHANGED" then
        local header = self.frame
        for enchantIndex, button in next, header.enchantButtons do
            if header.enchants[enchantIndex] ~= button then
                header.enchants[enchantIndex] = button
                header.elapsedEnchants = 0 -- reset the timer
            end
        end
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

local function UpdateIcon(self, updateSize)
    local db = GW.settings[self.header.setting]
    local width, height = db.IconSize, (db.KeepSizeRatio and db.IconSize) or db.IconHeight
    if updateSize then
        self:SetWidth(width)
        self:SetHeight(height)
    end
    if db.keepSizeRatio then
        self.status.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    else
        local left, right, top, bottom = GW.CropRatio(width, height)
        self.status.icon:SetTexCoord(left, right, top, bottom)
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
        self.header.enchantButtons[self.enchantIndex] = self
    else
        self.instant = true
    end

    self.cooldown:SetDrawBling(false)
    self.cooldown:SetDrawEdge(false)
    self.cooldown:SetDrawSwipe(true)
    self.cooldown:SetReverse(false)
    self.cooldown:SetHideCountdownNumbers(not GW.Retail)

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
    if not GW.Retail then
        self:SetScript("OnUpdate", AuraButton_OnUpdate)
    end
    self:SetScript("OnEnter", AuraOnEnter)
    self:SetScript("OnShow", AuraOnShow)
    self:SetScript("OnHide", AuraOnHide)
    self:SetScript("OnLeave", GameTooltip_Hide)

        -- for retail get cooldown font string and curve debuff color
    if GW.Retail then
        local r = {self.cooldown:GetRegions()}
        for _, c in pairs(r) do
            if c:GetObjectType() == "FontString" then
                self.cooldown.durationString = c
                self.cooldown.durationString:SetPoint("TOP", self.status, "BOTTOM", 0, -4)
                self.cooldown.durationString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, nil, -1)
                self.cooldown.durationString:SetShadowColor(0, 0, 0, 1)
                self.cooldown.durationString:SetShadowOffset(1, -1)
                break
            end
        end

        self.UpdateTooltip = AuraOnEnter

        self.status.stacks:SetShadowColor(0, 0, 0, 1)
        self.status.stacks:SetShadowOffset(1, -1)
        self.status.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, "OUTLINE")

        self.status:ClearAllPoints()
        self.status:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4)
        self.status:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 4)

        self.border:ClearAllPoints()
        self.border:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
        self.border:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
    end

    UpdateIcon(self)

    self.gwInit = true
end

local function UpdateAuraHeader(header)
    if not header then return end

    local db = GW.settings[header.setting]
    local width = db.IconSize
    local height = db.KeepSizeRatio and width or db.IconHeight
    local grow_dir = db.GrowDirection
    local maxWraps = db.MaxWraps
    local horizontalSpacing = db.HorizontalSpacing
    local verticalSpacing = db.VerticalSpacing
    local wrapAfter = db.WrapAfter
    if not wrapAfter or wrapAfter < 1 or wrapAfter > 20 then
        wrapAfter = 7
    end

    Debug("settings", header.setting, grow_dir, wrapAfter, width, height)

    header:SetAttribute("config-width", width)
    header:SetAttribute("config-height", height)
    header:SetAttribute("template", "GwAuraTmpl")
    header:SetAttribute("weaponTemplate", header.filter == "HELPFUL" and "GwAuraTmpl" or nil)
    header:SetAttribute("sortMethod", db.SortMethod)
    header:SetAttribute("sortDirection", db.SortDir)
    header:SetAttribute("separateOwn", db.Seperate)
    header:SetAttribute("wrapAfter", wrapAfter)
    header:SetAttribute("maxWraps", maxWraps)
    header:SetAttribute("minWidth", ((wrapAfter == 1 and 0 or horizontalSpacing) + width) * wrapAfter)
    header:SetAttribute("minHeight", (height + 1))
    header:SetAttribute("point", DIRECTION_TO_POINT[grow_dir])
    header:SetAttribute("xOffset", DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[grow_dir] * (horizontalSpacing + width))
    header:SetAttribute("yOffset", 0)
    header:SetAttribute("wrapXOffset", 0)
    header:SetAttribute("wrapYOffset", DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[grow_dir] * (verticalSpacing + height))
    header:SetAttribute("growDir", grow_dir)
    header:SetAttribute("initialConfigFunction", AttributeInitialConfig)

    for index, child in next, {header:GetChildren()} do
        UpdateIcon(child, true)

        --icons arent being hidden when you reduce the amount of maximum buttons
        if index > (maxWraps * wrapAfter) and child:IsShown() then
            child:Hide()
        end
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
            header:SetPoint(anchor_hd, GW2UIPlayerBuffs, anchor_hd, 0, DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[grow_dir] * (verticalSpacing + height))
        else
            header:SetPoint(DIRECTION_TO_POINT[grow_dir], header.gwMover, DIRECTION_TO_POINT[grow_dir], 0, 0)
        end
    end
end
GW.UpdateAuraHeader = UpdateAuraHeader

local function newHeader(filter)
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
    h.enchantButtons = {}
    h.enchants = {}
    h.spells = {}
    h.filter = filter
    h.setting = filter == "HELPFUL" and "PlayerBuffs" or "PlayerDebuffs"

    h.visibility = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
    h.visibility:SetScript("OnUpdate", HeaderOnUpdate)
    h.visibility:SetScript("OnEvent", HeaderOnEvent)
    h.visibility.frame = h
    h.name = name

    if GW.Retail or GW.TBC then
        h.visibility:RegisterEvent("WEAPON_ENCHANT_CHANGED")
    end

    RegisterAttributeDriver(h, "unit", "[vehicleui] vehicle; player")
    SecureHandlerSetFrameRef(h.visibility, "AuraHeader", h)
    RegisterStateDriver(h.visibility, "customVisibility", "[petbattle] 0; 1")
    h.visibility:SetAttribute("_onstate-customVisibility", AttributeCustomsVisibility)

    if filter == "HELPFUL" then
        h:SetAttribute("consolidateDuration", -1)
        h:SetAttribute("consolidateTo", 0)
        h:SetAttribute("includeWeapons", 1)

        RegisterMovableFrame(h, SHOW_BUFFS, "PlayerBuffFrame", ALL .. ",Blizzard,Aura", {316, 100}, {"default", "scaleable"}, true)
    else
        RegisterMovableFrame(h, SHOW_DEBUFFS, "PlayerDebuffFrame", ALL .. ",Blizzard,Aura", {316, 60}, {"default", "scaleable"}, true)
    end

    UpdateAuraHeader(h)

    return h
end
GW.AddForProfiling("aurabar_secure", "newHeader", newHeader)

local function loadAuras(lm)
    -- create a new header for buffs
    local hb = newHeader("HELPFUL")
    hb:Show()

    lm:RegisterBuffFrame(hb)
    hooksecurefunc(hb.gwMover, "StopMovingOrSizing", function ()
        local grow_dir = GW.settings[hb.setting].GrowDirection
        local anchor_hb = grow_dir == "UPR" and "BOTTOMLEFT" or grow_dir == "DOWNR" and "TOPLEFT" or grow_dir == "UP" and "BOTTOMRIGHT" or grow_dir == "DOWN" and "TOPRIGHT"

        if not InCombatLockdown() then
            hb:ClearAllPoints()
            hb:SetPoint(anchor_hb, hb.gwMover, anchor_hb, 0, 0)
        end
    end)

    -- create a new header for debuffs
    local hd = newHeader("HARMFUL")
    hd:Show()
    lm:RegisterDebuffFrame(hd)
    hooksecurefunc(hd.gwMover, "StopMovingOrSizing", function ()
        local grow_dir = GW.settings[hd.setting].GrowDirection
        local anchor_hd = grow_dir == "UPR" and "BOTTOMLEFT" or grow_dir == "DOWNR" and "TOPLEFT" or grow_dir == "UP" and "BOTTOMRIGHT" or grow_dir == "DOWN" and "TOPRIGHT"

        if not InCombatLockdown() then
            hd:ClearAllPoints()
            hd:SetPoint(anchor_hd, hd.gwMover, anchor_hd, 0, 0)
        end
    end)

    if GW.Retail then
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
end

local function LoadPlayerAuras(lm)
    -- hide default buffs
    BuffFrame:GwKill()
    if DebuffFrame then
        DebuffFrame:GwKill()
    end
    if TemporaryEnchantFrame then
        TemporaryEnchantFrame:GwKill()
    end
    if ConsolidatedBuffs then
        ConsolidatedBuffs:GwKill()
    end

    if GW.Retail then
        debuffColorCurve = C_CurveUtil.CreateColorCurve()
        debuffColorCurve:SetType(Enum.LuaCurveType.Step)
        for _, dispelIndex in next, GW.DispelType do
            if GW.DebuffColors[dispelIndex] then
                debuffColorCurve:AddPoint(dispelIndex, GW.DebuffColors[dispelIndex])
            end
        end
    end

    loadAuras(lm)
end
GW.LoadPlayerAuras = LoadPlayerAuras
