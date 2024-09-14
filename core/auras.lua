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
        return tonumber(a.timeremaning) < tonumber(b.timeremaning)
    end

    return (b.caster ~= "player" and a.caster == "player")
end
GW.AddForProfiling("auras", "sortAuras", sortAuras)

local function sortAurasRevert(a, b)
    if a.caster and b.caster and a.caster == b.caster then
        return tonumber(a.timeremaning) > tonumber(b.timeremaning)
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

local function getBuffs(unit, filter, revert)
    local buffList = {}
    local auraData
    local time = GetTime()
    if filter == nil then
        filter = ""
    end
    for i = 1, 40 do
        auraData = C_UnitAuras.GetBuffDataByIndex(unit, i, filter)
        if auraData then
            buffList[i] = {}
            local bli = buffList[i]
            bli.id = i

            bli.name = auraData.name
            bli.icon = auraData.icon
            bli.count = auraData.applications
            bli.dispelType = auraData.dispelName
            bli.duration = auraData.duration
            bli.expires = auraData.expirationTime
            bli.caster = auraData.sourceUnit
            bli.isStealable = auraData.isStealable
            bli.shouldConsolidate = auraData.nameplateShowPersonal
            bli.spellID = auraData.spellId

            bli.timeremaning = bli.duration <= 0 and 500001 or bli.expires - time
        end
    end

    return sortAuraList(buffList, revert)
end
GW.AddForProfiling("auras", "getBuffs", getBuffs)

local function getDebuffs(unit, filter, revert)
    local debuffList = {}
    local showImportant = filter == "IMPORTANT"
    local counter = 0
    local filterToUse = nil
    local time = GetTime()
    local auraData
    if not showImportant then
        filterToUse = filter
    end
    for i = 1, 40 do
        auraData = C_UnitAuras.GetDebuffDataByIndex(unit, i, filterToUse)
        if auraData and ((showImportant and (auraData.sourceUnit == "player" or GW.ImportendRaidDebuff[auraData.spellId])) or not showImportant) then
            counter = counter + 1
            debuffList[counter] = {}
            local dbi = debuffList[counter]
            dbi.id = i

            dbi.name = auraData.name
            dbi.icon = auraData.icon
            dbi.count = auraData.applications
            dbi.dispelType = auraData.dispelName
            dbi.duration = auraData.duration
            dbi.expires = auraData.expirationTime
            dbi.caster = auraData.sourceUnit
            dbi.isStealable = auraData.isStealable
            dbi.shouldConsolidate = auraData.nameplateShowPersonal
            dbi.spellID  = auraData.spellId

            dbi.timeremaning = dbi.duration <= 0 and 500001 or dbi.expires - time
        end
    end

    return sortAuraList(debuffList, revert)
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

local function setBuffData(self, buffs, i)
    if not self or not buffs then
        return false
    end
    local b = buffs[i]
    if b == nil or b.name == nil then
        return false
    end

    local stacks = ""

    if b.caster == "player" and (b.duration > 0 and b.duration < 120) then
        setAuraType(self, "bigBuff")
        self.cooldown:SetCooldown(b.expires - b.duration, b.duration)
    else
        setAuraType(self, "smallbuff")
    end

    if b.count ~= nil and b.count > 1 then
        stacks = b.count
    end

    if b.expires < 1 or b.timeremaning > 500000 then
        self.expires = nil
    else
        self.expires = b.expires
    end

    if self.auraType == "debuff" then
        if b.dispelType and BadDispels[b.spellID] and GW.Libs.Dispel:IsDispellableByMe(b.dispelType) then
            b.dispelType = "BadDispel"
        end
        if not b.dispelType and BleedList[b.spellID] and GW.Libs.Dispel:IsDispellableByMe("Bleed") then
            b.dispelType = "Bleed"
        end

        if b.dispelType then
            self.background:SetVertexColor(DebuffColors[b.dispelType].r, DebuffColors[b.dispelType].g, DebuffColors[b.dispelType].b)
        else
            self.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
        end
    else
        if b.isStealable then
            self.background:SetVertexColor(DebuffColors.Stealable.r, DebuffColors.Stealable.g, DebuffColors.Stealable.b)
        else
            self.background:SetVertexColor(0, 0, 0)
        end
    end

    self.auraid = b.id
    self.stacks:SetText(stacks)
    self.icon:SetTexture(b.icon)

    return true
end
GW.AddForProfiling("auras", "setBuffData", setBuffData)

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

-- No use for player (not secure)
local function UpdateBuffLayout(self, event, anchorPos)
    local minIndex = self.displayBuffs and 1 or 40
    local maxIndex = self.displayDebuffs and 80 or 40
    local marginX = 3
    local marginY = 20
    local maxHeightInRow = 0
    local usedWidth = 0
    local usedHeight = 0
    local usedWidth2 = 2
    local smallSize = 20
    local bigSize = 28
    local maxSize = self.auras:GetWidth()
    local isBuff = false
    local auraList = getBuffs(self.unit, nil, self.frameInvert)
    local dbList = getDebuffs(self.unit, self.debuffFilter, self.frameInvert)
    local lineSize = smallSize
    local saveAuras = {}
    local debuffScale = GetDebuffScaleBasedOnPrio()

    saveAuras.buff = {}
    saveAuras.debuff = {}

    for frameIndex = minIndex, maxIndex do
        local index = frameIndex
        local list = auraList
        local newAura = true

        if frameIndex > 40 then
            index = frameIndex - 40
        end

        local frame = _G["Gw" .. self.unit .. "buffFrame" .. index]

        if frameIndex > 40 then
            frame = _G["Gw" .. self.unit .. "debuffFrame" .. index]
            list = dbList
        end
        if frameIndex == 41 and isBuff then
            usedWidth = 0
            usedHeight = usedHeight + lineSize + marginY
            lineSize = smallSize
            isBuff = false
        end

        if setBuffData(frame, list, index) then
            if frameIndex <= 40 then
                isBuff = true
            end
            if not frame:IsShown() then
                frame:Show()
            end
            frame.nextUpdate = 0
            frame.duration:SetText("")
            frame:SetScript("OnUpdate", frame.OnUpdatefunction)

            local isBig = frame.typeAura == "bigBuff"

            local size = smallSize
            if isBig then
                size = bigSize
                lineSize = bigSize

                for _, v in pairs(self.saveAuras[frame.auraType]) do
                    if v == list[index].name then
                        newAura = false
                    end
                end
                self.animating = false
                saveAuras[frame.auraType][#saveAuras[frame.auraType] + 1] = list[index].name
            elseif UnitIsFriend(self.unit, "player") and not isBuff then
                -- debuffs
                if GW.ImportendRaidDebuff[list[index].spellID] and list[index].dispelType and GW.Libs.Dispel:IsDispellableByMe(list[index].dispelType) then
                    size = size * debuffScale
                elseif GW.ImportendRaidDebuff[list[index].spellID] then
                    size = size * tonumber(GW.settings.RAIDDEBUFFS_Scale)
                elseif list[index].dispelType and GW.Libs.Dispel:IsDispellableByMe(list[index].dispelType) then
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
                frame:SetPoint("CENTER", self.auras, "TOPRIGHT", -px, self.auraPositionUnder and -py or py)
            else
                frame:SetPoint("CENTER", self.auras, self.frameInvert and "TOPRIGHT" or "TOPLEFT", self.frameInvert and -px or px, self.auraPositionTop and py or -py)
            end

            frame:SetSize(size, size)
            if newAura and isBig and event == "UNIT_AURA" then
                auraAnimateIn(frame)
            end

            if usedWidth == 0 then
                usedWidth = usedWidth + size + marginX
            end
        elseif frame then
            frame:Hide()
            frame:SetScript("OnUpdate", nil)
            frame.endTime = nil
        end
    end

    self.saveAuras = saveAuras
end
GW.UpdateBuffLayout = UpdateBuffLayout

local function auraFrame_OnEnter(self)
    if self:IsShown() and self.auraid ~= nil and self.unit ~= nil then
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        GameTooltip:ClearLines()
        if self.auraType == "buff" then
            GameTooltip:SetUnitBuff(self.unit, self.auraid)
        else
            GameTooltip:SetUnitDebuff(self.unit, self.auraid, self.debuffFilter)
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

    f:SetScript("OnUpdate", auraFrame_OnUpdate)
    f:SetScript("OnEnter", auraFrame_OnEnter)
    f:SetScript("OnLeave", GameTooltip_Hide)

    return f
end
GW.CreateAuraFrame = CreateAuraFrame

local function LoadAuras(self)
    for i = 1, 40 do
        local frame = CreateAuraFrame("Gw" .. self.unit .. "buffFrame" .. i, self.auras)
        frame.unit = self.unit
        frame.auraType = "buff"
        frame = CreateAuraFrame("Gw" .. self.unit .. "debuffFrame" .. i, self.auras)
        frame.unit = self.unit
        frame.auraType = "debuff"
    end
    self.saveAuras = {}
    self.saveAuras.buff = {}
    self.saveAuras.debuff = {}
end
GW.LoadAuras = LoadAuras
