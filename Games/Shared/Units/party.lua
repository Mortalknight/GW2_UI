---@class GW2
local GW = select(2, ...)
local RegisterMovableFrame = GW.RegisterMovableFrame
local SetClassIcon = GW.SetClassIcon
local RoundDec = GW.RoundDec
local IsIn = GW.IsIn
local nameRoleIcon = GW.nameRoleIcon

local GW_PORTRAIT_BACKGROUND = {
    [1] = {l = 0, r = 0.828, t = 0, b = 0.166015625},
    [2] = {l = 0, r = 0.828, t = 0.166015625, b = 0.166015625 * 2},
    [3] = {l = 0, r = 0.828, t = 0.166015625 * 2, b = 0.166015625 * 3},
    [4] = {l = 0, r = 0.828, t = 0.166015625 * 3, b = 0.166015625 * 4},
    [5] = {l = 0, r = 0.828, t = 0.166015625 * 4, b = 0.166015625 * 5}
}

local partyFrames = {}
local healtTextColorCurve
local previewMode = false
local SUMMON_ICON_PREFIX = GW.Retail and "RaidFrame-Icon-" or "Raid-Icon-"
local PARTY_HORIZONTAL_AURA_SIZE = 16
local PARTY_HORIZONTAL_AURAS_PER_ROW = 4
local PARTY_HORIZONTAL_PET_AURA_SIZE = 12
local PARTY_HORIZONTAL_PET_AURAS_PER_ROW = 6
local PARTY_VERTICAL_AURA_SIZE = 20
local PARTY_VERTICAL_AURA_X_OFFSET = 5
local PARTY_VERTICAL_PET_AURA_X_OFFSET = 2
local PARTY_VERTICAL_PET_X_OFFSET = 15
local PARTY_VERTICAL_PET_Y_OFFSET = -17
local PARTY_HORIZONTAL_AURA_GAP = 4
local PARTY_HORIZONTAL_PET_GAP = 10
local PARTY_HORIZONTAL_PET_AURA_GAP = 6

if GW.Retail then
    healtTextColorCurve = C_CurveUtil.CreateColorCurve()
    healtTextColorCurve:SetType(Enum.LuaCurveType.Linear)
    healtTextColorCurve:AddPoint(0, CreateColor(1, 1, 1, 1))
end

local function GetPartyUnit(i)
    return (i == 1 and GW.settings.PARTY_PLAYER_FRAME) and "player" or "party" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0))
end

local function GetPartyPetUnit(i)
    return (i == 1 and GW.settings.PARTY_PLAYER_FRAME) and "pet" or "partypet" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0))
end

local function GetVisiblePartyFrameCount()
    return GW.settings.PARTY_PLAYER_FRAME and 5 or 4
end

local function ForceUpdateAuras(frame)
    if frame and frame.auras and frame.auras.ForceUpdate then
        frame.auras:ForceUpdate()
    end
end

local function ApplyAuraContainerLayout(frame, point, relativeTo, relativePoint, xOffset, yOffset, width, height)
    if not frame or not frame.auras then return end

    frame.auras:ClearAllPoints()
    frame.auras:SetPoint(point, relativeTo, relativePoint, xOffset or 0, yOffset or 0)

    if width and height then
        frame.auras:SetSize(width, height)
    elseif width then
        frame.auras:SetWidth(width)
    elseif height then
        frame.auras:SetHeight(height)
    end
    frame.auras.maxWidth = width
end

local function SyncAuraContainerHeight(frame)
    if not frame or not frame.auras then return 0 end

    local auraHeight = frame.auras.gwContentHeight or 0
    frame.auras:SetHeight(math.max(auraHeight, frame.auras.smallSize or 1))

    return auraHeight
end

local function UpdateAuraDisplaySettings(frame)
    if not frame or not frame.auras then return end

    local orientation = GW.settings.PARTY_FRAME_ORIENTATION or "VERTICAL"
    if orientation == "HORIZONTAL" then
        if frame.isPet then
            frame.auras.smallSize = PARTY_HORIZONTAL_PET_AURA_SIZE
            frame.auras.bigSize = PARTY_HORIZONTAL_PET_AURA_SIZE
            frame.auras.gwButtonsPerRow = PARTY_HORIZONTAL_PET_AURAS_PER_ROW
            frame.auras.gwGrowUp = true
        else
            frame.auras.smallSize = PARTY_HORIZONTAL_AURA_SIZE
            frame.auras.bigSize = PARTY_HORIZONTAL_AURA_SIZE
            frame.auras.gwButtonsPerRow = PARTY_HORIZONTAL_AURAS_PER_ROW
            frame.auras.gwGrowUp = false
        end
    else
        local auraSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE or PARTY_VERTICAL_AURA_SIZE
        if frame.isPet then
            frame.auras.smallSize = auraSize - 6
            frame.auras.bigSize = auraSize - 6
        else
            frame.auras.smallSize = auraSize
            frame.auras.bigSize = auraSize
        end
        frame.auras.gwButtonsPerRow = nil
        frame.auras.gwGrowUp = nil
    end
end

local function UpdatePartyFrameSubLayout(frame)
    if not frame or not frame.healthContainer or not frame.auras or not frame.PetFrame then return 0 end

    local orientation = GW.settings.PARTY_FRAME_ORIENTATION or "VERTICAL"
    local showPets = GW.settings.PARTY_SHOW_PETS

    if orientation == "HORIZONTAL" then
        UpdateAuraDisplaySettings(frame.PetFrame)
        frame.PetFrame:ClearAllPoints()
        frame.PetFrame:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, PARTY_HORIZONTAL_PET_GAP)

        ApplyAuraContainerLayout(
            frame.PetFrame,
            "BOTTOMLEFT",
            frame.PetFrame.name,
            "TOPLEFT",
            0,
            PARTY_HORIZONTAL_PET_AURA_GAP,
            frame.PetFrame.powerbar:GetWidth(),
            frame.PetFrame.auras.smallSize or 1
        )
        ForceUpdateAuras(frame.PetFrame)
        local petAuraHeight = SyncAuraContainerHeight(frame.PetFrame)

        UpdateAuraDisplaySettings(frame)
        ApplyAuraContainerLayout(
            frame,
            "TOPLEFT",
            frame.powerbar,
            "BOTTOMLEFT",
            0,
            -PARTY_HORIZONTAL_AURA_GAP,
            frame.powerbar:GetWidth(),
            frame.auras.smallSize or GW.settings.PARTY_SHOW_AURA_ICON_SIZE or PARTY_VERTICAL_AURA_SIZE
        )
        ForceUpdateAuras(frame)
        local auraHeight = SyncAuraContainerHeight(frame)

        local extraHeight = auraHeight > 0 and (auraHeight + PARTY_HORIZONTAL_AURA_GAP) or 0
        if showPets then
            extraHeight = extraHeight + PARTY_HORIZONTAL_PET_GAP + frame.PetFrame:GetHeight()
            if petAuraHeight > 0 then
                extraHeight = extraHeight + PARTY_HORIZONTAL_PET_AURA_GAP + petAuraHeight
            end
        end

        return extraHeight
    end

    UpdateAuraDisplaySettings(frame)
    ApplyAuraContainerLayout(frame, "BOTTOMLEFT", frame.powerbar, "BOTTOMRIGHT", PARTY_VERTICAL_AURA_X_OFFSET, 0, PARTY_VERTICAL_AURA_SIZE, PARTY_VERTICAL_AURA_SIZE)
    ForceUpdateAuras(frame)

    frame.PetFrame:ClearAllPoints()
    frame.PetFrame:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", PARTY_VERTICAL_PET_X_OFFSET, PARTY_VERTICAL_PET_Y_OFFSET)
    UpdateAuraDisplaySettings(frame.PetFrame)

    ApplyAuraContainerLayout(frame.PetFrame, "BOTTOMLEFT", frame.PetFrame.powerbar, "BOTTOMRIGHT", PARTY_VERTICAL_PET_AURA_X_OFFSET, 0, PARTY_VERTICAL_AURA_SIZE, PARTY_VERTICAL_AURA_SIZE)
    ForceUpdateAuras(frame.PetFrame)

    return 0
end

local function UpdatePartyLayout()
    local anchorFrame = partyFrames[1]
    if not anchorFrame then return end

    local orientation = GW.settings.PARTY_FRAME_ORIENTATION or "VERTICAL"
    local spacing = tonumber(GW.settings.PARTY_FRAME_SPACING) or 0
    local visibleCount = GetVisiblePartyFrameCount()
    local partyWidth = anchorFrame:GetWidth()
    local partyHeight = anchorFrame:GetHeight()
    local petWidth = GW.settings.PARTY_SHOW_PETS and (anchorFrame.PetFrame:GetWidth() + 15) or 0
    local petHeight = GW.settings.PARTY_SHOW_PETS and (anchorFrame.PetFrame:GetHeight() + 17) or 0
    local blockWidth = math.max(partyWidth, petWidth)
    local horizontalExtraHeight = 0

    for i, frame in ipairs(partyFrames) do
        frame:ClearAllPoints()

        if i == 1 then
            frame:SetPoint("TOPLEFT", frame.gwMover)
        elseif orientation == "HORIZONTAL" then
            frame:SetPoint("TOPLEFT", partyFrames[i - 1], "TOPLEFT", blockWidth + spacing, 0)
        else
            local currentBlockHeight = frame:GetHeight() + (GW.settings.PARTY_SHOW_PETS and (frame.PetFrame:GetHeight() + 17) or 0)
            frame:SetPoint("TOPLEFT", partyFrames[i - 1], "TOPLEFT", 0, -(currentBlockHeight + spacing))
        end

        horizontalExtraHeight = math.max(horizontalExtraHeight, UpdatePartyFrameSubLayout(frame))
    end

    if anchorFrame.gwMover then
        local moverWidth = orientation == "HORIZONTAL" and (blockWidth * visibleCount) + (spacing * (visibleCount - 1)) or blockWidth
        local blockHeight = partyHeight + (orientation == "HORIZONTAL" and horizontalExtraHeight or petHeight)
        local moverHeight = orientation == "HORIZONTAL" and blockHeight or (blockHeight * visibleCount) + (spacing * (visibleCount - 1))

        anchorFrame.gwMover:SetSize(moverWidth, moverHeight)
    end
end
GW.UpdatePartyLayout = UpdatePartyLayout

local function FilterAura(element, unit, data)
    if data.isHelpfulAura then
        return data and data.name
    else
        if GW.Retail then
            if not GW.settings.PARTY_SHOW_DEBUFFS then
                return false
            end
            if GW.settings.PARTY_ONLY_DISPELL_DEBUFFS then
                return data.isAuraRaidPlayerDispellable
            else
                return data and data.name
            end
        else
            if data and data.name then
                local shouldDisplay = false

                if GW.settings.PARTY_SHOW_DEBUFFS then
                    if GW.settings.PARTY_ONLY_DISPELL_DEBUFFS then
                        if data.dispelName and GW.Libs.Dispel:IsDispellableByMe(data.dispelName) then
                            shouldDisplay = data.name and not (data.spellId == 6788 and data.sourceUnit and GW.UnitNotUnit(data.sourceUnit, "player")) -- Don't show "Weakened Soul" from other players
                        end
                    else
                        shouldDisplay = data.name and not (data.spellId == 6788 and data.sourceUnit and GW.UnitNotUnit(data.sourceUnit, "player")) -- Don't show "Weakened Soul" from other players
                    end
                end

                if GW.settings.PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF and not shouldDisplay then
                    shouldDisplay = GW.ImportantRaidDebuff[data.spellId] or false
                end

                return shouldDisplay
            end
        end
    end
end

local function AuraSetPoint(element, from, to)
    local x, y = 0, 0
    local orientation = GW.settings.PARTY_FRAME_ORIENTATION
    local rowWidth = element.maxWidth
    local growUp = element.gwGrowUp
    element.gwContentHeight = 0
    for i = from, to do
        local button = element[i]
        if not button then break end

        local buttonsPerRow = element.gwButtonsPerRow or 11
        if orientation == "HORIZONTAL" and rowWidth > 0 then
            buttonsPerRow = element.gwButtonsPerRow or math.max(1, math.floor(rowWidth / math.max(button.neededSize, 1)))
        end

        if x >= buttonsPerRow then
            y = y + 1
            x = 0
        end
        button:ClearAllPoints()
        if orientation == "HORIZONTAL" then
            if growUp then
                button:SetPoint("BOTTOMLEFT", ((button.neededSize - 1) * x), ((button.neededSize + 2) * y))
            else
                button:SetPoint("TOPLEFT", ((button.neededSize - 1) * x), -((button.neededSize + 2) * y))
            end
        else
            button:SetPoint("BOTTOMRIGHT", ((button.neededSize - 1) * x), (button.neededSize + 2) * y)
        end
        x = x + 1

        element.gwContentHeight = ((y + 1) * (button.neededSize + 2))
    end
end

GwPartyFrameMixin = {}
function GwPartyFrameMixin:SetPortraitBackground(idx)
    local bg = GW_PORTRAIT_BACKGROUND[idx]
    if bg then
        self.portraitBackground:SetTexCoord(bg.l, bg.r, bg.t, bg.b)
    end
end

function GwPartyFrameMixin:UpdateAwayData()
    if not self.classicon then return end

    local playerInstanceId = select(4, UnitPosition("player"))
    local instanceId = select(4, UnitPosition(self.unit))
    local readyCheckStatus = GetReadyCheckStatus(self.unit)
    local phaseReason
    local portraitIndex = 1

    if GW.Retail then
        phaseReason = UnitPhaseReason(self.unit)
    else
        phaseReason = not UnitInPhase(self.unit)
    end

    if not readyCheckStatus and not UnitHasIncomingResurrection(self.unit) and not (GW.Retail and C_IncomingSummon.HasIncomingSummon(self.unit)) then
        self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons.png")
        SetClassIcon(self.classicon, select(3, UnitClass(self.unit)))
    end

    if playerInstanceId ~= instanceId then
        portraitIndex = 2
    end

    if phaseReason then
        portraitIndex = 4
    end

    if UnitHasIncomingResurrection(self.unit) then
        self.classicon:SetTexCoord(unpack(GW.TexCoords))
        if GW.Retail then
            self.classicon:SetAtlas("RaidFrame-Icon-Rez")
        else
            self.classicon:SetTexture("Interface/RaidFrame/Raid-Icon-Rez")
        end
    end

    local status = (GW.Retail or GW.TBC or GW.Wrath) and C_IncomingSummon.IncomingSummonStatus(self.unit) or 0
    if status ~= 0 then --Enum.SummonStatus.None
        self.classicon:SetTexCoord(unpack(GW.TexCoords))
        if status == Enum.SummonStatus.Pending then
            self.classicon:SetAtlas(SUMMON_ICON_PREFIX .. "SummonPending")
        elseif status == Enum.SummonStatus.Accepted then
            self.classicon:SetAtlas(SUMMON_ICON_PREFIX .. "SummonAccepted")
        elseif status == Enum.SummonStatus.Declined then
            self.classicon:SetAtlas(SUMMON_ICON_PREFIX .. "SummonDeclined")
        end
    end

    if not UnitIsConnected(self.unit) then
        portraitIndex = 3
    end

    if readyCheckStatus then
        self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/readycheck.png")
        if readyCheckStatus == "waiting" then
            self.classicon:SetTexCoord(0, 1, 0, 0.25)
        elseif readyCheckStatus == "notready" then
            self.classicon:SetTexCoord(0, 1, 0.25, 0.50)
        elseif readyCheckStatus == "ready" then
            self.classicon:SetTexCoord(0, 1, 0.50, 0.75)
        end
    end

    if UnitThreatSituation(self.unit) and UnitThreatSituation(self.unit) > 2 then
        portraitIndex = 5
    end

    self:SetPortraitBackground(portraitIndex)
end

function GwPartyFrameMixin:UpdatePortrait()
    if self.portrait then
        local playerInstanceId = select(4, UnitPosition("player"))
        local instanceId = select(4, UnitPosition(self.unit))
        local phaseReason

        if GW.Retail then
            phaseReason = UnitPhaseReason(self.unit)
        else
            phaseReason = not UnitInPhase(self.unit)
        end

        if playerInstanceId == instanceId and not phaseReason then
            SetPortraitTexture(self.portrait, self.unit)
        else
            self.portrait:SetTexture(nil)
        end
    end
end

function GwPartyFrameMixin:SetUnitName()
    local role = UnitGroupRolesAssigned(self.unit)
    local nameString = UnitName(self.unit) or UNKNOWNOBJECT

    if nameRoleIcon[role] then
        nameString = nameRoleIcon[role] .. nameString
    end

    if UnitIsGroupLeader(self.unit) then
        nameString = "|TInterface/AddOns/GW2_UI/textures/party/icon-groupleader.png:18:18:0:-3|t" .. nameString
    end

    self.name:SetText(nameString)
end

function GwPartyFrameMixin:UpdateHealthTextString(healthCur, healthPrec, healthMax)
    if GW.settings.PARTY_UNIT_HEALTH == "NONE" then
        self.healthString:Hide()
        return
    end

    if GW.Retail then
        local formatFunc = GW.settings.PARTY_UNIT_HEALTH_SHORT_VALUES and AbbreviateNumbers or BreakUpLargeNumbers

        if GW.settings.PARTY_UNIT_HEALTH == "PREC" then
            self.healthString:SetText(string.format("%.0f%%", UnitHealthPercent(self.unit, true, CurveConstants.ScaleTo100)))
            self.healthString:SetJustifyH("LEFT")
        elseif GW.settings.PARTY_UNIT_HEALTH == "HEALTH" then
            self.healthString:SetText(formatFunc(healthCur))
            self.healthString:SetJustifyH("LEFT")
        elseif GW.settings.PARTY_UNIT_HEALTH == "LOSTHEALTH" then
            self.healthString:SetText(formatFunc(UnitHealthMissing(self.unit)))
            self.healthString:SetJustifyH("RIGHT")
        end
        local color = UnitHealthPercent(self.unit, true, healtTextColorCurve)
        self.healthString:SetTextColor(color:GetRGB())
    else
        local formatFunc = GW.settings.PARTY_UNIT_HEALTH_SHORT_VALUES and GW.ShortValue or GW.GetLocalizedNumber
        if GW.settings.PARTY_UNIT_HEALTH == "PREC" then
            self.healthString:SetText(RoundDec(healthPrec * 100, 0) .. "%")
            self.healthString:SetJustifyH("LEFT")
        elseif GW.settings.PARTY_UNIT_HEALTH == "HEALTH" then
            self.healthString:SetText(formatFunc(healthCur))
            self.healthString:SetJustifyH("LEFT")
        elseif GW.settings.PARTY_UNIT_HEALTH == "LOSTHEALTH" then
            local lost = (healthMax - healthCur > 0) and formatFunc(healthMax - healthCur) or ""
            self.healthString:SetText(lost)
            self.healthString:SetJustifyH("RIGHT")
        end

        self.healthString:SetTextColor(healthCur == 0 and 255 or 1, healthCur == 0 and 0 or 1, healthCur == 0 and 0 or 1)
    end
    self.healthString:Show()
end

function GwPartyFrameMixin:UpdateFrame()
    self:UpdatePowerBar()
    self:UpdateHealthBar()
    self:SetUnitName()
    self:UpdateAwayData()
    self:UpdatePortrait()

    if self.level then self.level:SetText(UnitLevel(self.unit)) end
    if self.classicon then SetClassIcon(self.classicon, select(3, UnitClass(self.unit))) end
end

function GwPartyFrameMixin:OnEvent(event, unit, ...)
    local isVisible = event == "UNIT_PET" or self:IsVisible()
    if (not UnitExists(self.unit) or IsInRaid()) or not isVisible and event ~= "load" then return end

    if event == "load" then
        self:UpdateFrame()
        self.auras:ForceUpdate()
    end

    if event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" or event == "UNIT_HEALTH_FREQUENT" or event == "UNIT_HEAL_PREDICTION" or event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
        self:UpdateHealthBar()
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
        self:UpdatePowerBar()
    elseif IsIn(event, "UNIT_LEVEL", "GROUP_ROSTER_UPDATE", "UNIT_MODEL_CHANGED", "UNIT_PET") then
        self:UpdateFrame()
        self.auras:ForceUpdate()
    elseif IsIn(event,"UNIT_PHASE", "PARTY_MEMBER_DISABLE", "PARTY_MEMBER_ENABLE", "UNIT_THREAT_SITUATION_UPDATE", "INCOMING_RESURRECT_CHANGED", "INCOMING_SUMMON_CHANGED") then
        self:UpdateAwayData()
    elseif event == "UNIT_PORTRAIT_UPDATE" or event == "PORTRAITS_UPDATED" or event == "UNIT_PHASE" then
        self:UpdatePortrait()
    elseif event == "UNIT_NAME_UPDATE" then
        self:SetUnitName()
    elseif event == "UNIT_AURA" and unit == self.unit then
        GW.UpdateBuffLayout(self, event, self.unit, ...)
    elseif event == "READY_CHECK" or (event == "READY_CHECK_CONFIRM" and unit == self.unit) then
        self:UpdateAwayData()
    elseif event == "READY_CHECK_FINISHED" then
        C_Timer.After(1.5, function()
            if UnitInParty(self.unit) then
                self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons.png")
                SetClassIcon(self.classicon, select(3, UnitClass(self.unit)))
            end
        end)
    end
end

local function UpdatePartyFrames()
    for _, frame in ipairs(partyFrames) do
        -- statusbar texture
        local textureKey =  GW.settings.partyFrameHealthBarTexture
        if textureKey == GW.DEFAULT_UNITFRAME_STATUSBAR_TEXTURE then
            frame.antiHeal:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/antiheal.png")
            frame.health:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/statusbar.png")
            frame.absorbbg:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/absorb.png")
            frame.healPrediction:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")

            frame.PetFrame.antiHeal:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/antiheal.png")
            frame.PetFrame.health:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/statusbar.png")
            frame.PetFrame.absorbbg:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/absorb.png")
            frame.PetFrame.healPrediction:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
        else
            local texture = GW.Libs.LSM:Fetch("statusbar", textureKey)
            frame.antiHeal:SetStatusBarTexture(texture)
            frame.health:SetStatusBarTexture(texture)
            frame.absorbbg:SetStatusBarTexture(texture)
            frame.healPrediction:SetStatusBarTexture(texture)

            frame.PetFrame.antiHeal:SetStatusBarTexture(texture)
            frame.PetFrame.health:SetStatusBarTexture(texture)
            frame.PetFrame.absorbbg:SetStatusBarTexture(texture)
            frame.PetFrame.healPrediction:SetStatusBarTexture(texture)
        end

        frame.displayBuffs = GW.settings.PARTY_SHOW_BUFFS and 32 or 0
        frame.displayDebuffs = (GW.settings.PARTY_SHOW_DEBUFFS or GW.settings.PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF) and 40 or 0
        frame.showAbsorbBar = GW.settings.PARTY_SHOW_ABSORB_BAR
        frame.health:SetStatusBarColor(GW.Colors.UnitFrameReactionColors.Friendly:GetRGB())
        frame.auras.smallSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE
        frame.auras.bigSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE
        frame:OnEvent("load")
        frame.PetFrame.auras.smallSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE - 6
        frame.PetFrame.auras.bigSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE - 6
        frame.PetFrame.displayDebuffs = (GW.settings.PARTY_SHOW_DEBUFFS or GW.settings.PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF) and 40 or 0
        frame.PetFrame.displayBuffs = GW.settings.PARTY_SHOW_BUFFS and 32 or 0
        frame.PetFrame.health:SetStatusBarColor(GW.Colors.UnitFrameReactionColors.Friendly:GetRGB())
        frame.showAbsorbBar = GW.settings.PARTY_SHOW_ABSORB_BAR
        frame.PetFrame:OnEvent("load")
    end

    UpdatePartyLayout()
end
GW.UpdatePartyFrames = UpdatePartyFrames

local function UpdatePetVisibility(alwaysHide)
    for i, frame in ipairs(partyFrames) do
        local petFrame = frame.PetFrame
        if not GW.settings.PARTY_SHOW_PETS or alwaysHide then
            RegisterStateDriver(petFrame, "visibility", "hide")
        else
            local petUnit = GetPartyPetUnit(i)
            local vis = ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format(petUnit)
            RegisterStateDriver(petFrame, "visibility", vis)
        end

        if i == 5 then
            if not GW.settings.PARTY_PLAYER_FRAME then
                petFrame:SetScript("OnEvent", nil)
                RegisterStateDriver(petFrame, "visibility", "hide")
            else
                petFrame:SetScript("OnEvent", frame.OnEvent)
            end
        end
    end

    UpdatePartyLayout()
end
GW.UpdatePartyPetVisibility = UpdatePetVisibility

local function UpdatePlayerInPartySetting(alwaysHide)
    for i, frame in ipairs(partyFrames) do
        local petFrame = frame.PetFrame

        local unit = GetPartyUnit(i)
        frame.unit = unit
        frame.guid = UnitGUID(unit)
        frame:SetAttribute("unit", unit)
        frame:OnEvent("load")

        local petUnit = GetPartyPetUnit(i)
        petFrame.unit = petUnit
        petFrame.guid = UnitGUID(petUnit)
        petFrame:SetAttribute("unit", petUnit)
        petFrame:OnEvent("load")

        if alwaysHide then
            RegisterStateDriver(frame, "visibility", "hide")
        else
            local vis = (unit == "player") and ("[@raid1,exists][@party1,noexists] hide;show") or
                        (("[@raid1,exists][@%s,noexists] hide;show"):format(unit))
            RegisterStateDriver(frame, "visibility", vis)
        end

        if i == 5 then
            if not GW.settings.PARTY_PLAYER_FRAME then
                frame:SetScript("OnEvent", nil)
                RegisterStateDriver(frame, "visibility", "hide")
            else
                frame:SetScript("OnEvent", frame.OnEvent)
            end
        end
    end

    UpdatePartyLayout()
    UpdatePetVisibility(alwaysHide)
end
GW.UpdatePlayerInPartySetting = UpdatePlayerInPartySetting

local function CreatePartyFrame(i, isPlayer)
    local registerUnit = isPlayer and "player" or "party" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0))
    local frame = CreateFrame("Button", "GwPartyFrame" .. i, UIParent, GW.Retail and "GwPartyFrameRetailTemplate" or "GwPartyFrameTemplate")

    if i == 1 then
        RegisterMovableFrame(frame, PARTY, "party_pos", ALL .. ",Unitframe,Group", nil, {"default"})
    end

    local hg = frame.healthContainer
    if GW.Retail then
        frame.absorbOverlay = hg.health.overDamageAbsorbIndicator
        frame.antiHeal      = hg.healAbsorb
        frame.health        = hg.health
        frame.absorbbg      = hg.damageAbsorb
        frame.healPrediction= hg.healPrediction
        frame.healthString  = hg.health.healthString

        frame.hpValues = CreateUnitHealPredictionCalculator()
        frame.hpValues:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth)
        frame.hpValues:SetHealAbsorbClampMode(Enum.UnitHealAbsorbClampMode.CurrentHealth)
        frame.hpValues:SetIncomingHealClampMode(Enum.UnitIncomingHealClampMode.MissingHealth)
        frame.hpValues:SetHealAbsorbMode(Enum.UnitHealAbsorbMode.ReducedByIncomingHeals)
        frame.hpValues:SetIncomingHealOverflowPercent(1)

        frame.healPrediction:ClearAllPoints()
        frame.healPrediction:SetPoint("TOP")
        frame.healPrediction:SetPoint("BOTTOM")
        frame.healPrediction:SetPoint("LEFT", frame.health:GetStatusBarTexture(), "RIGHT")

        frame.absorbbg:ClearAllPoints()
        frame.absorbbg:SetPoint("TOP")
        frame.absorbbg:SetPoint("BOTTOM")
        frame.absorbbg:SetPoint("LEFT", frame.healPrediction:GetStatusBarTexture(), "RIGHT")

        frame.antiHeal:ClearAllPoints()
        frame.antiHeal:SetPoint("TOP")
        frame.antiHeal:SetPoint("BOTTOM")
        frame.antiHeal:SetPoint("RIGHT", frame.health:GetStatusBarTexture())
        frame.antiHeal:SetReverseFill(true)

        frame.absorbOverlay:ClearAllPoints()
        frame.absorbOverlay:SetPoint("TOP")
        frame.absorbOverlay:SetPoint("BOTTOM")
        frame.absorbOverlay:SetPoint("LEFT", frame.health, "RIGHT", -8, 0)
        frame.absorbOverlay:SetWidth(16)
    else
        frame.absorbOverlay = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay
        frame.antiHeal = hg.healPrediction.absorbbg.health.antiHeal
        frame.health = hg.healPrediction.absorbbg.health
        frame.absorbbg = hg.healPrediction.absorbbg
        frame.healPrediction = hg.healPrediction
        frame.healthString = hg.healPrediction.absorbbg.health.antiHeal.absorbOverlay.healthString

        for _, bar in ipairs({ frame.absorbOverlay, frame.antiHeal, frame.health, frame.absorbbg, frame.healPrediction, frame.powerbar }) do
            GW.AddStatusbarAnimation(bar, true)
        end
        GW.AddStatusbarAnimation(frame.healPrediction, false)

        frame.absorbOverlay:SetStatusBarColor(1, 1, 1, 0.66)
    end

    local textureKey =  GW.settings.partyFrameHealthBarTexture
    if textureKey == GW.DEFAULT_UNITFRAME_STATUSBAR_TEXTURE then
        frame.antiHeal:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/antiheal.png")
        frame.health:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/statusbar.png")
        frame.absorbbg:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/absorb.png")
        frame.healPrediction:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")

        frame.absorbbg:SetStatusBarColor(1, 1, 1, 0.66)
    else
        local texture = GW.Libs.LSM:Fetch("statusbar", textureKey)
        frame.antiHeal:SetStatusBarTexture(texture)
        frame.health:SetStatusBarTexture(texture)
        frame.absorbbg:SetStatusBarTexture(texture)
        frame.healPrediction:SetStatusBarTexture(texture)

        frame.absorbbg:SetStatusBarColor(248/255, 232/255, 159/255, 0.66)
    end
    frame.healPrediction:SetStatusBarColor(0.58431, 0.9372, 0.2980, 0.60)

    frame.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    frame.name:SetShadowOffset(-1, -1)
    frame.name:SetShadowColor(0, 0, 0, 1)
    frame.level:SetFont(UNIT_NAME_FONT, 12, "OUTLINE")
    frame.healthString:SetFontObject(GameFontNormalSmall)

    --Create party pet frame
    local petUnit = (registerUnit == "player") and "pet" or "partypet" .. (i - (GW.settings.PARTY_PLAYER_FRAME and 1 or 0))
    local petFrame = CreateFrame("Button", "GwPartyPetFrame" .. i, UIParent, GW.Retail and "GwPartyPetFrameRetailTemplate" or "GwPartyPetFrameTemplate")
    petFrame.unit = petUnit
    petFrame:SetAttribute("unit", petUnit)
    petFrame.isPet = true

    local phg = petFrame.healthContainer
    if GW.Retail then
        petFrame.absorbOverlay = phg.health.overDamageAbsorbIndicator
        petFrame.antiHeal      = phg.healAbsorb
        petFrame.health        = phg.health
        petFrame.absorbbg      = phg.damageAbsorb
        petFrame.healPrediction= phg.healPrediction
        petFrame.healthString  = phg.health.healthString

        petFrame.hpValues = CreateUnitHealPredictionCalculator()
        petFrame.hpValues:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth)
        petFrame.hpValues:SetHealAbsorbClampMode(Enum.UnitHealAbsorbClampMode.CurrentHealth)
        petFrame.hpValues:SetIncomingHealClampMode(Enum.UnitIncomingHealClampMode.MissingHealth)
        petFrame.hpValues:SetHealAbsorbMode(Enum.UnitHealAbsorbMode.ReducedByIncomingHeals)
        petFrame.hpValues:SetIncomingHealOverflowPercent(1)

        petFrame.healPrediction:ClearAllPoints()
        petFrame.healPrediction:SetPoint("TOP")
        petFrame.healPrediction:SetPoint("BOTTOM")
        petFrame.healPrediction:SetPoint("LEFT", petFrame.health:GetStatusBarTexture(), "RIGHT")

        petFrame.absorbbg:ClearAllPoints()
        petFrame.absorbbg:SetPoint("TOP")
        petFrame.absorbbg:SetPoint("BOTTOM")
        petFrame.absorbbg:SetPoint("LEFT", petFrame.healPrediction:GetStatusBarTexture(), "RIGHT")

        petFrame.antiHeal:ClearAllPoints()
        petFrame.antiHeal:SetPoint("TOP")
        petFrame.antiHeal:SetPoint("BOTTOM")
        petFrame.antiHeal:SetPoint("RIGHT", petFrame.health:GetStatusBarTexture())
        petFrame.antiHeal:SetReverseFill(true)

        petFrame.absorbOverlay:ClearAllPoints()
        petFrame.absorbOverlay:SetPoint("TOP")
        petFrame.absorbOverlay:SetPoint("BOTTOM")
        petFrame.absorbOverlay:SetPoint("LEFT", petFrame.health, "RIGHT", -8, 0)
        petFrame.absorbOverlay:SetWidth(16)
    else
        petFrame.absorbOverlay = phg.healPrediction.absorbbg.health.antiHeal.absorbOverlay
        petFrame.antiHeal = phg.healPrediction.absorbbg.health.antiHeal
        petFrame.health = phg.healPrediction.absorbbg.health
        petFrame.absorbbg = phg.healPrediction.absorbbg
        petFrame.healPrediction = phg.healPrediction
        petFrame.healthString = phg.healPrediction.absorbbg.health.antiHeal.absorbOverlay.healthString

        for _, bar in ipairs({ frame.absorbOverlay, frame.antiHeal, frame.health, frame.absorbbg, frame.healPrediction, frame.powerbar }) do
            GW.AddStatusbarAnimation(bar, true)
        end
        GW.AddStatusbarAnimation(frame.healPrediction, false)

        for _, bar in ipairs({ petFrame.absorbOverlay, petFrame.antiHeal, petFrame.health, petFrame.absorbbg, petFrame.healPrediction, petFrame.powerbar }) do
            GW.AddStatusbarAnimation(bar, true)
        end
        GW.AddStatusbarAnimation(petFrame.healPrediction, false)

        petFrame.absorbOverlay:SetStatusBarColor(1, 1, 1, 0.66)
    end

    if textureKey == GW.DEFAULT_UNITFRAME_STATUSBAR_TEXTURE then
        petFrame.antiHeal:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/antiheal.png")
        petFrame.health:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/statusbar.png")
        petFrame.absorbbg:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/absorb.png")
        petFrame.healPrediction:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")

        petFrame.absorbbg:SetStatusBarColor(1, 1, 1, 0.66)
    else
        local texture = GW.Libs.LSM:Fetch("statusbar", textureKey)
        petFrame.antiHeal:SetStatusBarTexture(texture)
        petFrame.health:SetStatusBarTexture(texture)
        petFrame.absorbbg:SetStatusBarTexture(texture)
        petFrame.healPrediction:SetStatusBarTexture(texture)

        petFrame.absorbbg:SetStatusBarColor(248/255, 232/255, 159/255, 0.66)
    end
    petFrame.healPrediction:SetStatusBarColor(0.58431, 0.9372, 0.2980, 0.60)

    petFrame.healthString:SetFontObject(GameFontNormalSmall)

    petFrame:SetAttribute("*type1", "target")
    petFrame:SetAttribute("*type2", "togglemenu")
    petFrame:EnableMouse(true)
    petFrame:RegisterForClicks("AnyDown")

    -- Standard Auras und Buffs für Pet-Frame
    petFrame.auras.FilterAura = FilterAura
    petFrame.auras.SetPosition = AuraSetPoint
    petFrame.auras.smallSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE - 6
    petFrame.auras.bigSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE - 6
    petFrame.displayBuffs = GW.settings.PARTY_SHOW_BUFFS and 32 or 0
    petFrame.displayDebuffs = (GW.settings.PARTY_SHOW_DEBUFFS or GW.settings.PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF) and 40 or 0
    petFrame.auras.hideDuration = true
    GW.LoadAuras(petFrame)

    petFrame:ClearAllPoints()
    petFrame:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, -17)
    petFrame:SetScript("OnLeave", GameTooltip_Hide)
    petFrame:SetScript("OnEnter", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(petUnit)
        GameTooltip:Show()
    end)
    GW.AddToClique(petFrame)
    petFrame.health:SetStatusBarColor(GW.Colors.UnitFrameReactionColors.Friendly:GetRGB())
    petFrame:SetScript("OnEvent", petFrame.OnEvent)
    -- Registriere Events für Pet-Frame
    for _, ev in ipairs({ "GROUP_ROSTER_UPDATE", "PARTY_MEMBER_DISABLE", "PARTY_MEMBER_ENABLE", "PORTRAITS_UPDATED", "PLAYER_TARGET_CHANGED" }) do
        petFrame:RegisterEvent(ev)
    end
    petFrame:RegisterUnitEvent("UNIT_PET", registerUnit)
    for _, ev in ipairs({ "UNIT_AURA", "UNIT_LEVEL", "UNIT_PHASE", "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER", "UNIT_NAME_UPDATE", "UNIT_HEAL_PREDICTION" }) do
        petFrame:RegisterUnitEvent(ev, petUnit)
    end
    petFrame:OnEvent("load")

    if GW.Retail or GW.Mists then
        petFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", petUnit)
        petFrame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", petUnit)
    elseif GW.Classic then
        petFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", petUnit)
    end

    -- Speichere den Pet-Frame im Party-Frame
    frame.PetFrame = petFrame

    frame.unit = registerUnit
    frame.guid = UnitGUID(registerUnit)
    frame.ready = -1
    frame:SetAttribute("unit", registerUnit)
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")

    frame.auras.FilterAura = FilterAura
    frame.auras.SetPosition = AuraSetPoint
    frame.auras.smallSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE
    frame.auras.bigSize = GW.settings.PARTY_SHOW_AURA_ICON_SIZE
    frame.auras.hideDuration = true
    frame.displayBuffs = GW.settings.PARTY_SHOW_BUFFS and 32 or 0
    frame.displayDebuffs = (GW.settings.PARTY_SHOW_DEBUFFS or GW.settings.PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF) and 40 or 0
    frame.auras.debuffFilter = GW.settings.PARTY_ONLY_DISPELL_DEBUFFS and "RAID|HARMFUL" or "HARMFUL" --TESTING
    GW.LoadAuras(frame)

    RegisterStateDriver(frame, "visibility", ("[@raid6,exists][@%s,noexists] hide;show"):format(registerUnit))
    frame:EnableMouse(true)
    frame:RegisterForClicks("AnyUp")
    frame:SetScript("OnLeave", GameTooltip_Hide)
    frame:SetScript("OnEnter", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(registerUnit)
        GameTooltip:Show()
    end)
    GW.AddToClique(frame)
    frame.health:SetStatusBarColor(GW.Colors.UnitFrameReactionColors.Friendly:GetRGB())
    for _, ev in ipairs({ "GROUP_ROSTER_UPDATE", "PARTY_MEMBER_DISABLE", "PARTY_MEMBER_ENABLE", "READY_CHECK", "READY_CHECK_CONFIRM", "READY_CHECK_FINISHED", "PLAYER_TARGET_CHANGED", "INCOMING_RESURRECT_CHANGED", "PORTRAITS_UPDATED" }) do
        frame:RegisterEvent(ev)
    end
    for _, ev in ipairs({ "UNIT_AURA", "UNIT_LEVEL", "UNIT_PHASE", "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_POWER_FREQUENT", "UNIT_MAXPOWER", "UNIT_NAME_UPDATE", "UNIT_MODEL_CHANGED", "UNIT_HEAL_PREDICTION", "UNIT_THREAT_SITUATION_UPDATE", "UNIT_PORTRAIT_UPDATE" }) do
        frame:RegisterUnitEvent(ev, registerUnit)
    end
    frame:SetScript("OnEvent", frame.OnEvent)

    if GW.Retail then
        frame:RegisterEvent("INCOMING_SUMMON_CHANGED")
    end

    if GW.Retail or GW.Mists then
        frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", registerUnit)
        frame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", registerUnit)
    elseif GW.Classic then
        frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", registerUnit)
    end

    -- create private auras for retail
    if GW.Retail then
        frame.privateAuraFrames = {}
        for k = 1, 6 do
            local privateAura = CreateFrame("Frame", nil, frame.auras, "GwPrivateAuraTmpl")
            privateAura:SetPoint("BOTTOMRIGHT", frame.auras, (28 * (k - 1)), 28 * 2)
            privateAura.auraIndex = k
            privateAura:SetSize(24, 24)
            local auraAnchor = {
                isContainer = false,
                unitToken = registerUnit,
                auraIndex = privateAura.auraIndex,
                parent = privateAura,
                showCountdownFrame = true,
                showCountdownNumbers = true,
                iconInfo = {
                    iconWidth = 24,
                    iconHeight = 24,
                    iconAnchor = {
                        point = "CENTER",
                        relativeTo = privateAura.status,
                        relativePoint = "CENTER",
                        offsetX = 0,
                        offsetY = 0,
                    },
                },
            }
            privateAura.anchorIndex = C_UnitAuras.AddPrivateAuraAnchor(auraAnchor)
            frame.privateAuraFrames[k] = privateAura
        end
    end

    frame:OnEvent("load")

    tinsert(partyFrames, frame)
end

local function TogglePartyPreview()
    if previewMode then
        for i, frame in ipairs(partyFrames) do
            local unit = GetPartyUnit(i)
            local petUnit = GetPartyPetUnit(i)
            frame.unit = unit
            frame.guid = UnitGUID(unit)
            frame:SetAttribute("unit", unit)
            local vis = (i == 1 and GW.settings.PARTY_PLAYER_FRAME) and
                ("[@raid6,exists][@%s,noexists] hide;show"):format("party1") or
                ("[@raid6,exists][@%s,noexists] hide;show"):format(unit)
            RegisterStateDriver(frame, "visibility", vis)
            frame:OnEvent("load")
            frame.PetFrame.unit = petUnit
            frame.PetFrame.guid = UnitGUID(petUnit)
            frame.PetFrame:SetAttribute("unit", petUnit)
            if GW.settings.PARTY_SHOW_PETS then
                RegisterStateDriver(frame.PetFrame, "visibility", ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format(petUnit))
            else
                RegisterStateDriver(frame.PetFrame, "visibility", "hide")
            end
            frame.PetFrame:OnEvent("load")

            if i == 5 and not GW.settings.PARTY_PLAYER_FRAME then
                RegisterStateDriver(frame, "visibility", "hide")
                RegisterStateDriver(frame.PetFrame, "visibility", "hide")
            end
        end
        previewMode = false
    else
        for i, frame in ipairs(partyFrames) do
            frame.unit = "player"
            frame.guid = GW.myguid
            frame:SetAttribute("unit", "player")
            RegisterStateDriver(frame, "visibility", "show")
            frame:OnEvent("load")
            if GW.settings.PARTY_SHOW_PETS then
                frame.PetFrame.unit = "player"
                frame.PetFrame.guid = GW.myguid
                frame.PetFrame:SetAttribute("unit", "player")
                RegisterStateDriver(frame.PetFrame, "visibility", "show")
                frame.PetFrame:OnEvent("load")
            end
            if i == 5 and not GW.settings.PARTY_PLAYER_FRAME then
                RegisterStateDriver(frame, "visibility", "hide")
                RegisterStateDriver(frame.PetFrame, "visibility", "hide")
            end
        end
        previewMode = true
    end
end
GW.TogglePartyPreview = TogglePartyPreview

local function LoadPartyFrames()
    GW.CreateRaidControlFrame()

    for i = 1, MAX_PARTY_MEMBERS + 1 do
        CreatePartyFrame(i, GW.settings.PARTY_PLAYER_FRAME and (i == 1))
    end

    UpdatePlayerInPartySetting(GW.settings.RAID_FRAMES and GW.settings.RAID_STYLE_PARTY)
end
GW.LoadPartyFrames = LoadPartyFrames
