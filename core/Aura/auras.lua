local _, GW = ...
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local DebuffColors = GW.Libs.Dispel:GetDebuffTypeColor()
local BadDispels = GW.Libs.Dispel:GetBadList()

if GW.Retail then return end

local function UpdateTooltip(self)
    if GameTooltip:IsForbidden() then return end

    if self.index then
        GameTooltip:SetUnitAura(self:GetParent().__owner.unit, self.index, self.isHarmful and "HARMFUL" or "HELPFUL")
    end
end

local function auraFrame_OnEnter(self)
    if GameTooltip:IsForbidden() or not self:IsVisible() then return end
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    self:UpdateTooltip()
end


local function auraFrame_OnUpdate(self, elapsed)
    if not self.hideDuration then
        if self.nextUpdate > 0 then
            self.nextUpdate = self.nextUpdate - elapsed
        elseif self:IsShown() and self.expirationTime ~= nil then
            local text, nextUpdate = GW.GetTimeInfo(self.expirationTime - GetTime())
            self.nextUpdate = nextUpdate
            self.duration:SetText(text)
        end
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


local function CreateAuraFrame(name, parent)
    local f = CreateFrame("Button", name, parent, "GwAuraFrame")

    f.typeAura = "smallbuff"
    f.Cooldown:SetDrawEdge(0)
    f.Cooldown:SetDrawSwipe(1)
    f.Cooldown:SetReverse(false)
    f.Cooldown:SetHideCountdownNumbers(true)
    f.nextUpdate = 0

    f.status.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "OUTLINE", -1)
    f.status.duration:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -2)
    f.status.duration:SetShadowOffset(1, -1)

    f.duration = f.status.duration
    f.stacks = f.status.stacks
    f.icon = f.status.icon

    f.UpdateTooltip = UpdateTooltip
    f.OnUpdatefunction = auraFrame_OnUpdate
    f:SetScript("OnEnter", auraFrame_OnEnter)
    f:SetScript("OnLeave", GameTooltip_Hide)

    return f
end

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
    if a.sourceUnit and b.sourceUnit and a.sourceUnit == b.sourceUnit then
        return tonumber(a.timeRemaining) < tonumber(b.timeRemaining)
    end

    return (b.sourceUnit ~= "player" and a.sourceUnit == "player")
end


local function sortAurasRevert(a, b)
    if a.sourceUnit and b.sourceUnit and a.sourceUnit == b.sourceUnit then
        return tonumber(a.timeRemaining) > tonumber(b.timeRemaining)
    end

    return (a.sourceUnit ~= "player" and b.sourceUnit == "player")
end



local function sortAuraList(auraList, revert)
    if revert then
        table.sort(auraList, sortAurasRevert)
    else
        table.sort(auraList, sortAuras)
    end

    return auraList
end


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


local function auraAnimateIn(self)
    local endWidth = self:GetWidth()

    GW.AddToAnimation(
        self:GetDebugName(),
        endWidth * 2,
        endWidth,
        GetTime(),
        0.2,
        function(step)
            self:SetSize(step, step)
        end
    )
end


local function SetPosition(element, from, to, unit, isInvert, auraPositon)
    local anchorTo = unit == "pet" and "TOPRIGHT" or isInvert and "TOPRIGHT" or "TOPLEFT"
    local growthx = isInvert and -1 or (unit == "pet" and -1) or 1
    local growthy = (auraPositon == 'DOWN' and -1) or 1
    local marginY = 20
    local marginX = 3
    local smallSize = 20
    local maxWidth = element.maxWidth
    local usedWidth = 0
    local usedWidth2 = 0
    local maxHeightInRow = smallSize
    local usedHeight = 0
    local lineSize = smallSize
    local firstDebuff = false
    local handledBuff = false

    for i = from, to do
        local button = element[i]
        if(not button) then break end

        if button.isHarmful and not firstDebuff then
            firstDebuff = true
            -- new line for debuffs
            usedWidth = 0
            usedHeight = handledBuff and (usedHeight + lineSize + marginY) or 0
            lineSize = smallSize
        else
            handledBuff = true
        end

        usedWidth = usedWidth + button.neededSize + marginX
        if maxWidth < usedWidth then
            usedWidth = 0
            maxHeightInRow = button.neededSize
            usedHeight = usedHeight + lineSize + marginY
            lineSize = smallSize
        elseif button.neededSize > maxHeightInRow then
            maxHeightInRow = button.neededSize
        end
        if usedWidth > 0 then
            usedWidth2 = usedWidth - button.neededSize - marginX
        else
            usedWidth2 = usedWidth
        end
        local px = usedWidth2 + (button.neededSize / 2)
        local py = usedHeight + (maxHeightInRow / 2)

        button:ClearAllPoints()
        button:SetPoint("CENTER", element, anchorTo, px * growthx, py * growthy)

        if usedWidth == 0 then
            usedWidth = usedWidth + button.neededSize + marginX
        end
    end
end

local function updateAura(element, unit, data, position)
    if not data.name then return end

    local button = element[position]
    if not button then
        button = CreateAuraFrame(element:GetDebugName() .. 'Button' .. position, element)

        table.insert(element, button)
        element.createdButtons = element.createdButtons + 1
    end

    button.smallSize = element.smallSize
    button.bigSize = element.bigSize
    local size = button.smallSize

    -- for tooltips
    button.auraInstanceID = data.auraInstanceID
    button.hideDuration = element.hideDuration
    button.isHarmful = data.isHarmful
    button.index = nil -- reset

    --loop to get the index
    for i = 1, 40 do
        local auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, data.isHelpful and "HELPFUL" or "HARMFUL")
        if auraData then
            if auraData.auraInstanceID == data.auraInstanceID then
                button.index = i
                break
            end
        else
            break
        end
    end

    if data.sourceUnit == "player" and (data.duration > 0 and data.duration < 120) then
        setAuraType(button, "bigBuff")
        size = button.bigSize
        button.Cooldown:SetCooldown(data.expirationTime - data.duration, data.duration)
        button.Cooldown:Show()
    else
        setAuraType(button, "smallbuff")
        button.Cooldown:Hide()
        data.newBuffAnimation = false
    end

    if data.expirationTime < 1 or data.timeRemaining > 500000 then
        button.expirationTime = nil
    else
        button.expirationTime = data.expirationTime
    end

    if data.isHarmfulAura then
        if data.dispelName and BadDispels[data.spellId] and GW.Libs.Dispel:IsDispellableByMe(data.dispelName) then
            data.dispelName = "BadDispel"
        end

        if data.dispelName then
            button.background:SetVertexColor(DebuffColors[data.dispelName].r, DebuffColors[data.dispelName].g, DebuffColors[data.dispelName].b)
        else
            button.background:SetVertexColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
        end
    else
        if data.isStealable then
            button.background:SetVertexColor(DebuffColors.Stealable.r, DebuffColors.Stealable.g, DebuffColors.Stealable.b)
        else
            button.background:SetVertexColor(0, 0, 0)
        end
    end
    button.background:Show()

    if button.typeAura == "bigBuff" then

    elseif UnitIsFriend(unit, "player") and data.isHarmfulAura and button.typeAura == "smallbuff" then
        -- debuffs
        if GW.ImportantRaidDebuff[data.spellId] and data.dispelName and GW.Libs.Dispel:IsDispellableByMe(data.dispelName) then
            size = size * GetDebuffScaleBasedOnPrio()
        elseif GW.ImportantRaidDebuff[data.spellId] then
            size = size * tonumber(GW.settings.RAIDDEBUFFS_Scale)
        elseif data.dispelName and GW.Libs.Dispel:IsDispellableByMe(data.dispelName) then
            size = size * tonumber(GW.settings.DISPELL_DEBUFFS_Scale)
        end
    end

    button.icon:SetTexture(data.icon)
    button.stacks:SetText(data.applications > 1 and data.applications or "")
    button.nextUpdate = 0
    button.duration:SetText("")

    button:SetSize(size, size)
    if data.newBuffAnimation == true then
        auraAnimateIn(button)
        data.newBuffAnimation = false
    end
    button:EnableMouse(true)
    button:Show()
    button:SetScript("OnUpdate", button.OnUpdatefunction)

    button.neededSize = size
end

local function CheckFilter(data, filters)
    if not filters or filters.noFilter then return true end

    local player, cancel = data.isAuraPlayer, data.isAuraCancelable
    local other, perma = not player, not cancel

    return (filters.isAuraPlayer and player)
        or (filters.isAuraCancelable and cancel and other)
        or (filters.isAuraCancelablePlayer and cancel and player)
        or (filters.notAuraCancelable and perma and other)
        or (filters.notAuraCancelablePlayer and perma and player)
        or (filters.isAuraRaid and data.isAuraRaid and other)
        or (filters.isAuraRaidPlayer and data.isAuraRaid and player)
        or (filters.isAuraRaidPlayerDispellable and data.dispelName and GW.Libs.Dispel:IsDispellableByMe(data.dispelName))
end

local function FilterAura(element, unit, data)
    if data.isHelpfulAura then
        if element.buffFilter == "advanced" then
            return CheckFilter(data, element.buffAdvancedFilters)
        elseif element.buffFilter == "all" then
            return true
        end
    elseif data.isHarmfulAura then
        if element.debuffFilter == "advanced" then
            return CheckFilter(data, element.debuffAdvancedFilters)
        elseif element.debuffFilter == "player" then
            return data.isAuraPlayer
        elseif element.debuffFilter == "important" then
            return GW.ImportantRaidDebuff[data.spellId]
        elseif element.debuffFilter == "all" then
            return true
        end
	end
end

local function processData(unit, data, filter, newBuffAnimation)
    if not data or not data.name then return end

    data.timeRemaining = data.duration <= 0 and 500000 or data.expirationTime - GetTime()
    data.newBuffAnimation = newBuffAnimation

    data.isHarmfulAura = filter:match("HARMFUL")
    data.isHelpfulAura = not data.isHarmfulAura

    data.isAuraCancelable = not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, "HELPFUL|CANCELABLE") or not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, "HARMFUL|CANCELABLE")
    data.isAuraPlayer = not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, "HELPFUL|PLAYER") or not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, "HARMFUL|PLAYER")
    data.isAuraRaid = not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, "HELPFUL|RAID") or not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, "HARMFUL|RAID")

    return data
end

local function UpdateBuffLayout(self, event, unit, updateInfo)
    if self.unit ~= unit then return end

    local isFullUpdate = not updateInfo or updateInfo.isFullUpdate

    local auras = self.auras

    local buffsChanged = false
    local numBuffs = self.displayBuffs or 32
    local buffFilter = "HELPFUL"

    local debuffsChanged = false
    local numDebuffs = self.displayDebuffs or 40
    local debuffFilter = self.debuffFilter or "HARMFUL"

    local numTotal = auras.numTotal or numBuffs + numDebuffs

    if isFullUpdate then
        auras.allBuffs = table.wipe(auras.allBuffs or {})
        auras.activeBuffs = table.wipe(auras.activeBuffs or {})
        buffsChanged = true

        local slots = {C_UnitAuras.GetAuraSlots(unit, buffFilter)}
        for i = 2, #slots do -- #1 return is continuationToken, we don't care about it
            local data = processData(unit, C_UnitAuras.GetAuraDataBySlot(unit, slots[i]), buffFilter, false)
            if data then
                auras.allBuffs[data.auraInstanceID] = data

                if ((auras.FilterAura or FilterAura)(auras, unit, data)) then
                    auras.activeBuffs[data.auraInstanceID] = true
                end
            end
        end

        auras.allDebuffs = table.wipe(auras.allDebuffs or {})
        auras.activeDebuffs = table.wipe(auras.activeDebuffs or {})
        debuffsChanged = true

        slots = {C_UnitAuras.GetAuraSlots(unit, debuffFilter)}
        for i = 2, #slots do
            local data = processData(unit, C_UnitAuras.GetAuraDataBySlot(unit, slots[i]), debuffFilter, false)
            if data then
                auras.allDebuffs[data.auraInstanceID] = data

                if ((auras.FilterAura or FilterAura)(auras, unit, data)) then
                    auras.activeDebuffs[data.auraInstanceID] = true
                end
            end
        end
    else
        auras.allBuffs = auras.allBuffs or {}
        auras.activeBuffs = auras.activeBuffs or {}
        auras.allDebuffs = auras.allDebuffs or {}
        auras.activeDebuffs = auras.activeDebuffs or {}

        if updateInfo.addedAuras then
            for _, data in next, updateInfo.addedAuras do
                if(data.isHelpful and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, buffFilter)) then
                    data = processData(unit, data, buffFilter, true)
                    if data then
                        auras.allBuffs[data.auraInstanceID] = data

                        if ((auras.FilterAura or FilterAura)(auras, unit, data)) then
                            auras.activeBuffs[data.auraInstanceID] = true
                            buffsChanged = true
                        end
                    end
                elseif(data.isHarmful and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, debuffFilter)) then
                    data = processData(unit, data, debuffFilter, false)
                    if data then
                        auras.allDebuffs[data.auraInstanceID] = data

                        if ((auras.FilterAura or FilterAura)(auras, unit, data)) then
                            auras.activeDebuffs[data.auraInstanceID] = true
                            debuffsChanged = true
                        end
                    end
                end
            end
        end

        if updateInfo.updatedAuraInstanceIDs then
            for _, auraInstanceID in next, updateInfo.updatedAuraInstanceIDs do
                if(auras.allBuffs[auraInstanceID]) then
                    auras.allBuffs[auraInstanceID] = processData(unit, C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID), buffFilter, false)

                    -- only update if it's actually active
                    if(auras.activeBuffs[auraInstanceID]) then
                        auras.activeBuffs[auraInstanceID] = true
                        buffsChanged = true
                    end
                elseif(auras.allDebuffs[auraInstanceID]) then
                    auras.allDebuffs[auraInstanceID] = processData(unit, C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID), debuffFilter, false)

                    if(auras.activeDebuffs[auraInstanceID]) then
                        auras.activeDebuffs[auraInstanceID] = true
                        debuffsChanged = true
                    end
                end
            end
        end

        if updateInfo.removedAuraInstanceIDs then
            for _, auraInstanceID in next, updateInfo.removedAuraInstanceIDs do
                if(auras.allBuffs[auraInstanceID]) then
                    auras.allBuffs[auraInstanceID] = nil

                    if(auras.activeBuffs[auraInstanceID]) then
                        auras.activeBuffs[auraInstanceID] = nil
                        buffsChanged = true
                    end
                elseif(auras.allDebuffs[auraInstanceID]) then
                    auras.allDebuffs[auraInstanceID] = nil

                    if(auras.activeDebuffs[auraInstanceID]) then
                        auras.activeDebuffs[auraInstanceID] = nil
                        debuffsChanged = true
                    end
                end
            end
        end
    end

    if buffsChanged or debuffsChanged then
        local numVisible

        if buffsChanged then
            -- instead of removing auras one by one, just wipe the tables entirely
            -- and repopulate them, multiple table.remove calls are insanely slow
            auras.sortedBuffs = table.wipe(auras.sortedBuffs or {})

            for auraInstanceID in next, auras.activeBuffs do
                table.insert(auras.sortedBuffs, auras.allBuffs[auraInstanceID])
            end

            auras.sortedBuffs = sortAuraList(auras.sortedBuffs, self.frameInvert)

            numVisible = math.min(numBuffs, numTotal, #auras.sortedBuffs)

            for i = 1, numVisible do
                updateAura(auras, unit, auras.sortedBuffs[i], i)
            end
        else
            numVisible = math.min(numBuffs, numTotal, #auras.sortedBuffs)
        end

        -- do it before adding the gap because numDebuffs could end up being 0
        if debuffsChanged then
            auras.sortedDebuffs = table.wipe(auras.sortedDebuffs or {})

            for auraInstanceID in next, auras.activeDebuffs do
                table.insert(auras.sortedDebuffs, auras.allDebuffs[auraInstanceID])
            end

            auras.sortedDebuffs = sortAuraList(auras.sortedDebuffs, self.frameInvert)
        end

        numDebuffs = math.min(numDebuffs, numTotal - numVisible, #auras.sortedDebuffs)

        -- any changes to buffs will affect debuffs, so just redraw them even if nothing changed
        for i = 1, numDebuffs do
            updateAura(auras, unit, auras.sortedDebuffs[i], numVisible + i)
        end

        numVisible = numVisible + numDebuffs
        local visibleChanged = false

        if numVisible ~= auras.visibleButtons then
            auras.visibleButtons = numVisible
            visibleChanged = true
        end

        for i = numVisible + 1, #auras do
            auras[i]:Hide()
            auras[i]:SetScript("OnUpdate", nil)
        end

        if event == "ForceUpdate" or visibleChanged or auras.createdButtons > auras.anchoredButtons then
            local auraPositon = "TOP"
            if unit == "pet" then
                if self.auraPositionUnder == true then
                    auraPositon = "DOWN"
                end
            else
                if not self.auraPositionTop then
                    auraPositon = "DOWN"
                end
            end
            (auras.SetPosition or SetPosition) (auras, 1, numVisible, unit, self.frameInvert, auraPositon)
        end
    end
end
GW.UpdateBuffLayout = UpdateBuffLayout

local function ForceUpdate(element)
    local parent = element:GetParent()
    UpdateBuffLayout(parent, "ForceUpdate", parent.unit)
end

-- No use for player (not secure)
local function LoadAuras(self)
    self.auras.visibleButtons = 0
    self.auras.createdButtons = 0
    self.auras.anchoredButtons = 0
    self.auras.ForceUpdate = ForceUpdate
    self.auras.__owner = self

    self.auras.maxWidth = self.auras:GetWidth()
end
GW.LoadAuras = LoadAuras
