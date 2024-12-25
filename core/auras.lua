local _, GW = ...
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local DebuffColors = GW.Libs.Dispel:GetDebuffTypeColor()
local BleedList = GW.Libs.Dispel:GetBleedList()
local BadDispels = GW.Libs.Dispel:GetBadList()

local function GetDebuffScaleBasedOnPrio()
    local scale = 1

    if GW.settings.RAIDDEBUFFS_DISPELLDEBUFF_SCALE_PRIO == "DISPELL" then
        return tonumber(GW.settings.DISPELL_DEBUFFS_Scale)
    elseif GW.settings.RAIDDEBUFFS_DISPELLDEBUFF_SCALE_PRIO == "IMPORTANT" then
        return tonumber(GW.settings.RAIDDEBUFFS_Scale)
    end

    return scale
end
GW.GetDebuffScaleBasedOnPrio = GetDebuffScaleBasedOnPrio

local function sortAuras(a, b)
    if a.caster and b.caster and a.caster == b.caster then
        return tonumber(a.timeRemaining) < tonumber(b.timeRemaining)
    end

    return (b.caster ~= "player" and a.caster == "player")
end
GW.AddForProfiling("auras", "sortAuras", sortAuras)

local function sortAurasRevert(a, b)
    if a.caster and b.caster and a.caster == b.caster then
        return tonumber(a.timeRemaining) > tonumber(b.timeRemaining)
    end

    return (a.caster ~= "player" and b.caster == "player")
end
GW.AddForProfiling("auras", "sortAuras", sortAuras)


local function sortAuraList(auraList, revert)
    if revert then
        table.sort(auraList, sortAurasRevert)
    else
        table.sort(auraList, sortAuras)
    end

    return auraList
end
GW.AddForProfiling("auras", "sortAuraList", sortAuraList)

local function getBuffs(self)
    local buffList = {}
    if not self.displayBuffs then return buffList end

    AuraUtil.ForEachAura(self.unit, "HELPFUL", 40, function(auraData)
        if auraData then
            tinsert(buffList, {
                name = auraData.name,
                icon = auraData.icon,
                count = auraData.applications,
                dispelType = auraData.dispelName,
                duration = auraData.duration,
                expires = auraData.expirationTime,
                caster = auraData.sourceUnit,
                isStealable = auraData.isStealable,
                shouldConsolidate = auraData.nameplateShowPersonal,
                spellID = auraData.spellId,
                timeRemaining = auraData.duration <= 0 and 500000 or auraData.expirationTime - GetTime(),
                auraInstanceID = auraData.auraInstanceID
            })
        end
    end, true)

    return sortAuraList(buffList, self.frameInvert)
end
GW.AddForProfiling("auras", "getBuffs", getBuffs)

local function getDebuffs(self)
    local debuffList = {}
    local showImportant = self.debuffFilter == "IMPORTANT"
    local filterToUse = self.debuffFilter == "PLAYER" and "PLAYER" or "HARMFUL"
    if not self.displayDebuffs then return debuffList end

    AuraUtil.ForEachAura(self.unit, filterToUse, 40, function(auraData)
        if auraData and ((showImportant and (auraData.sourceUnit == "player" or GW.ImportendRaidDebuff[auraData.spellId])) or not showImportant) then
            tinsert(debuffList, {
                name = auraData.name,
                icon = auraData.icon,
                count = auraData.applications,
                dispelType = auraData.dispelName,
                duration = auraData.duration,
                expires = auraData.expirationTime,
                caster = auraData.sourceUnit,
                isStealable = auraData.isStealable,
                shouldConsolidate = auraData.nameplateShowPersonal,
                spellID = auraData.spellId,
                timeRemaining = auraData.duration <= 0 and 500000 or auraData.expirationTime - GetTime(),
                auraInstanceID = auraData.auraInstanceID
            })
        end
    end, true)

    return sortAuraList(debuffList, self.frameInvert)
end
GW.AddForProfiling("auras", "getDebuffs", getDebuffs)

local function setAuraType(self, typeAura)
    if self.typeAura == typeAura then
        return
    end

    if typeAura == "smallbuff" then
        self.icon:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
        self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
        self.duration:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -1)
        self.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "OUTLINE", -1)
    elseif typeAura == "bigBuff" then
        self.icon:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -3)
        self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 3)
        self.duration:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        self.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, "OUTLINE")
    end

    self.typeAura = typeAura
end
GW.AddForProfiling("auras", "setAuraType", setAuraType)

local function auraAnimateIn(self)
    local endWidth = self:GetWidth()

    GW.AddToAnimation(
        self:GetName(),
        endWidth * 2,
        endWidth,
        GetTime(),
        0.2,
        function(step)
            self:SetSize(step, step)
        end
    )
end
GW.AddForProfiling("auras", "auraAnimateIn", auraAnimateIn)

local function setAuraData(self, parent, aura, isBuff, debuffScale, anchorPos, event, saveAuras, maxSize, usedWidth, maxHeightInRow, usedHeight, marginX, marginY, lineSize, smallSize, bigSize)
    local stacks = ""
    local usedWidth2 = 2
    local newAura = true
    local isBig = self.typeAura == "bigBuff"
    local size = smallSize

    if aura.caster == "player" and (aura.duration > 0 and aura.duration < 120) then
        setAuraType(self, "bigBuff")
        self.cooldown:SetCooldown(aura.expires - aura.duration, aura.duration)
    else
        setAuraType(self, "smallbuff")
    end

    if aura.count ~= nil and aura.count > 1 then
        stacks = aura.count
    end

    if aura.expires < 1 or aura.timeRemaining > 500000 then
        self.expires = nil
    else
        self.expires = aura.expires
    end

    if self.auraType == "debuff" then
        if aura.dispelType and BadDispels[aura.spellID] and GW.Libs.Dispel:IsDispellableByMe(aura.dispelType) then
            aura.dispelType = "BadDispel"
        end
        if not aura.dispelType and BleedList[aura.spellID] and GW.Libs.Dispel:IsDispellableByMe("Bleed") then
            aura.dispelType = "Bleed"
        end

        if aura.dispelType then
            self.background:SetVertexColor(DebuffColors[aura.dispelType].r, DebuffColors[aura.dispelType].g, DebuffColors[aura.dispelType].b)
        else
            self.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
        end
    else
        if aura.isStealable then
            self.background:SetVertexColor(DebuffColors.Stealable.r, DebuffColors.Stealable.g, DebuffColors.Stealable.b)
        else
            self.background:SetVertexColor(0, 0, 0)
        end
    end

    self.auraInstanceID = aura.auraInstanceID
    self.stacks:SetText(stacks)
    self.icon:SetTexture(aura.icon)

    self.nextUpdate = 0
    self.duration:SetText("")

    if isBig then
        size = bigSize
        lineSize = bigSize

        for _, savedAuraName in pairs(parent.saveAuras[self.auraType]) do
            if savedAuraName == aura.name then
                newAura = false
            end
        end
        self.animating = false
        if isBuff then
            saveAuras.buff[#saveAuras.buff + 1] = aura.name
        else
            saveAuras.debuff[#saveAuras.debuff + 1] = aura.name
        end
    elseif UnitIsFriend(self.unit, "player") and not isBuff then
        -- debuffs
        if GW.ImportendRaidDebuff[aura.spellID] and aura.dispelType and GW.Libs.Dispel:IsDispellableByMe(aura.dispelType) then
            size = size * debuffScale
        elseif GW.ImportendRaidDebuff[aura.spellID] then
            size = size * tonumber(GW.settings.RAIDDEBUFFS_Scale)
        elseif aura.dispelType and GW.Libs.Dispel:IsDispellableByMe(aura.dispelType) then
            size = size * tonumber(GW.settings.DISPELL_DEBUFFS_Scale)
        end
    end

    usedWidth = usedWidth + size + marginX
    if maxSize < usedWidth then
        usedWidth = 0
        maxHeightInRow = size
        usedHeight = usedHeight + lineSize + marginY
        lineSize = smallSize
    elseif size > maxHeightInRow then
        maxHeightInRow = size
    end
    if usedWidth > 0 then
        usedWidth2 = usedWidth - size - marginX
    else
        usedWidth2 = usedWidth
    end
    local px = usedWidth2  + (size / 2)
    local py = usedHeight + (maxHeightInRow / 2)

    if anchorPos == "pet" then
        self:SetPoint("CENTER", parent.auras, "TOPRIGHT", -px, parent.auraPositionUnder and -py or py)
    else
        self:SetPoint("CENTER", parent.auras, parent.frameInvert and "TOPRIGHT" or "TOPLEFT", parent.frameInvert and -px or px, parent.auraPositionTop and py or -py)
    end

    self:SetSize(size, size)
    if newAura and isBig and event == "UNIT_AURA" then
        auraAnimateIn(self)
    end

    if usedWidth == 0 then
        usedWidth = usedWidth + size + marginX
    end

    return saveAuras, usedWidth, maxHeightInRow, usedHeight, marginX, marginY, lineSize, smallSize, bigSize
end
GW.AddForProfiling("auras", "setAuraData", setAuraData)

-- No use for player (not secure)
local function UpdateBuffLayout(self, event, anchorPos)
    local maxHeightInRow = 0
    local usedWidth = 0
    local usedHeight = 0
    local smallSize = 20
    local bigSize = 28
    local marginX = 3
    local marginY = 20
    local lineSize = smallSize
    local buffList = getBuffs(self)
    local debuffList = getDebuffs(self)
    local debuffScale = GetDebuffScaleBasedOnPrio()
    local maxSize = self.auras:GetWidth()
    local saveAuras = {}
    saveAuras.buff = {}
    saveAuras.debuff = {}

    for i, auraFrame in pairs(self.buffFrames) do
        if buffList[i] then
            saveAuras, usedWidth, maxHeightInRow, usedHeight, marginX, marginY, lineSize, smallSize, bigSize = setAuraData(auraFrame, self, buffList[i], true, debuffScale, anchorPos, event, saveAuras, maxSize, usedWidth, maxHeightInRow, usedHeight, marginX, marginY, lineSize, smallSize, bigSize)
            auraFrame:SetScript("OnUpdate", auraFrame.OnUpdatefunction)
            auraFrame:Show()
        else
            auraFrame:Hide()
            auraFrame:SetScript("OnUpdate", nil)
            auraFrame.endTime = nil
        end
    end

    -- new line for debuffs
    usedWidth = 0
    usedHeight = usedHeight + lineSize + marginY
    lineSize = smallSize

    for i, auraFrame in pairs(self.debuffFrames) do
        if debuffList[i] then
            saveAuras, usedWidth, maxHeightInRow, usedHeight, marginX, marginY, lineSize, smallSize, bigSize = setAuraData(auraFrame, self, debuffList[i], true, debuffScale, anchorPos, event, saveAuras, maxSize, usedWidth, maxHeightInRow, usedHeight, marginX, marginY, lineSize, smallSize, bigSize)
            auraFrame:SetScript("OnUpdate", auraFrame.OnUpdatefunction)
            auraFrame:Show()
        else
            auraFrame:Hide()
            auraFrame:SetScript("OnUpdate", nil)
            auraFrame.endTime = nil
        end
    end

    self.saveAuras = saveAuras
end
GW.UpdateBuffLayout = UpdateBuffLayout

local function auraFrame_OnEnter(self)
    if self:IsShown() and self.auraInstanceID ~= nil and self.unit ~= nil then
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        GameTooltip:ClearLines()
        if self.auraType == "buff" then
            GameTooltip:SetUnitBuffByAuraInstanceID(self.unit, self.auraInstanceID)
        else
            GameTooltip:SetUnitDebuffByAuraInstanceID(self.unit, self.auraInstanceID, self.debuffFilter)
        end
        GameTooltip:Show()
    end
end
GW.AddForProfiling("auras", "auraFrame_OnEnter", auraFrame_OnEnter)

local function auraFrame_OnUpdate(self, elapsed)
    if self.nextUpdate > 0 then
        self.nextUpdate = self.nextUpdate - elapsed
    elseif self:IsShown() and self.expires ~= nil then
        local text, nextUpdate = GW.GetTimeInfo(self.expires - GetTime())
        self.nextUpdate = nextUpdate
        self.duration:SetText(text)
    end

    if self.elapsed and self.elapsed > 0.1 then
        if GameTooltip:IsOwned(self) then
            auraFrame_OnEnter(self)
        end

        self.elapsed = 0
    else
        self.elapsed = (self.elapsed or 0) + elapsed
    end
end
GW.AddForProfiling("auras", "auraFrame_OnUpdate", auraFrame_OnUpdate)

local function CreateAuraFrame(name, parent)
    local f = CreateFrame("Button", name, parent, "GwAuraFrame")

    f.typeAura = "smallbuff"
    f.cooldown:SetDrawEdge(0)
    f.cooldown:SetDrawSwipe(1)
    f.cooldown:SetReverse(false)
    f.cooldown:SetHideCountdownNumbers(true)
    f.nextUpdate = 0

    f.status.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "OUTLINE", -1)
    f.status.duration:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -2)
    f.status.duration:SetShadowOffset(1, -1)

    f.duration = f.status.duration
    f.stacks = f.status.stacks
    f.icon = f.status.icon

    f.OnUpdatefunction = auraFrame_OnUpdate
    f:SetScript("OnEnter", auraFrame_OnEnter)
    f:SetScript("OnLeave", GameTooltip_Hide)

    return f
end
GW.CreateAuraFrame = CreateAuraFrame

local function LoadAuras(self)
    self.buffFrames = {}
    self.debuffFrames = {}
    self.saveAuras = {}
    self.saveAuras.buff = {}
    self.saveAuras.debuff = {}

    for i = 1, 40 do
        local frame = CreateAuraFrame("Gw" .. self.unit .. "buffFrame" .. i, self.auras)
        frame.unit = self.unit
        frame.auraType = "buff"

        self.buffFrames[i] = frame

        frame = CreateAuraFrame("Gw" .. self.unit .. "debuffFrame" .. i, self.auras)
        frame.unit = self.unit
        frame.auraType = "debuff"

        self.debuffFrames[i] = frame
    end
end
GW.LoadAuras = LoadAuras
