---@class GW2
local GW = select(2, ...)
local SetClassIcon = GW.SetClassIcon
local GWGetClassColor = GW.GWGetClassColor
local IsIn = GW.IsIn
local nameRoleIcon = GW.nameRoleIcon

local countArenaFrames = 0
local MAX_ARENA_ENEMIES = MAX_ARENA_ENEMIES or 5

local arenaFrames = {}
local arenaPrepFrames = {}

local FractionIcon = {
    Alliance = "|TInterface/AddOns/GW2_UI/textures/battleground/alliance.png:16:16:0:0|t ",
    Horde    = "|TInterface/AddOns/GW2_UI/textures/battleground/horde.png:16:16:0:0|t ",
    NONE     = ""
}

local TEST_OPPONENTS = {
    {name = "Lightbringer", spec = "Holy", role = "HEALER", class = "PALADIN", classIndex = 2, health = 0.63, power = 0.55, powerToken = "MANA", cast = "Flash of Light", castTime = 1.5, auras = {{spellID = 118, dispelType = GW.Enum.DispelType.Magic}}},
    {name = "Shadowstep", spec = "Subtlety", role = "DAMAGER", class = "ROGUE", classIndex = 4, health = 0.88, power = 0.7, powerToken = "ENERGY", auras = {{spellID = 1022}}},
    {name = "Frostfire", spec = "Frost", role = "DAMAGER", class = "MAGE", classIndex = 8, health = 0.4, power = 0.9, powerToken = "MANA", cast = "Polymorph", castTime = 1.7, notInterruptible = true},
}

GwArenaFrameMixin = CreateFromMixins(GwObjectivesUnitFrameMixin)

function GwArenaFrameMixin:UpdateName()
    local inArena = C_PvP.GetZonePVPInfo()
    local inBG = UnitInBattleground("player")
    local name = GW.GetUnitDisplayName(self.gwUnit) or UNKNOWNOBJECT
    local nameString = UNKNOWNOBJECT

    if inArena == "arena" then
        local specID = GetArenaOpponentSpec(self.id)
        -- 12.1.5 hands out the opponent spec as a secret, blizzards display helper still resolves the name
        if GW.IsSecretValue(specID) then
            nameString = format("%s - %s", name, UnitFrameUtil.GetArenaOpponentSpecDisplayInfo(self.id).specName)
        elseif specID and specID > 0 then
            local _, specName, _, _, role = GetSpecializationInfoByID(specID, UnitSex(self.gwUnit))
            if role and nameRoleIcon[role] and specName and name then
                nameString = nameRoleIcon[role] .. name .. " - " .. specName
            else
                nameString = name
            end
        else
            nameString = name
        end
    elseif inBG then
        local role = UnitGroupRolesAssigned(self.gwUnit)
        local englishFaction = UnitFactionGroup(self.gwUnit)
        if GW.NotSecretValue(role) and role and nameRoleIcon[role] and englishFaction and FractionIcon[englishFaction] and name then
            nameString = FractionIcon[englishFaction] .. nameRoleIcon[role] .. name
        else
            nameString = name
        end
    else
        nameString = name
    end

    self.name:SetText(nameString)
    self.class = select(2, UnitClass(self.gwUnit))
    self.classIndex = select(3, UnitClass(self.gwUnit))
    if self.class then
        SetClassIcon(self.icon, self.classIndex)
        local color = GWGetClassColor(self.class, true)
        self.health:SetStatusBarColor(color.r, color.g, color.b, color.a)
    end

    if GW.isModern then return end
    self.guid = UnitGUID(self.gwUnit)
    if self.guid == UnitGUID("target") then
        self.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    else
        self.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    end
end

function GwArenaFrameMixin:OnEvent(event, unitId)
    if event == "UNIT_POWER_FREQUENT" and self.gwUnit ~= unitId then return end
    local _, instanceType = IsInInstance()
    if self.gwTest or (instanceType ~= "arena" and instanceType ~= "pvp") then
        return
    end

    if self:IsCastbarEvent(event) then
        self:UpdateCastbar(GW.settings.objectives.arenaFrames.castbar)
    elseif IsIn(event, "UNIT_MAXHEALTH", "UNIT_HEALTH") then
        self:UpdateHealth()
    elseif IsIn(event, "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT") then
        self:UpdatePower()
    elseif event == "PLAYER_TARGET_CHANGED" then
        self:UpdateName()
    elseif IsIn(event, "PLAYER_ENTERING_WORLD", "PLAYER_ENTERING_BATTLEGROUND", "UNIT_NAME_UPDATE", "ARENA_OPPONENT_UPDATE") then
        self:UpdateHealth()
        self:UpdatePower()
        self:UpdateName()
        self:UpdateCastbar(GW.settings.objectives.arenaFrames.castbar)
    end
end

function GwArenaFrameMixin:ApplySettings()
    self:ApplyAuraSettings(GW.settings.objectives.arenaFrames.auras)
    if self:IsShown() and not self.gwTest then
        self:UpdateCastbar(GW.settings.objectives.arenaFrames.castbar)
    end
end

function GwArenaFrameMixin:StartTest(data)
    UnregisterUnitWatch(self)
    self.gwTest = true
    self.name:SetText(nameRoleIcon[data.role] .. data.name .. " - " .. data.spec)
    SetClassIcon(self.icon, data.classIndex)
    local color = GWGetClassColor(data.class, true)
    self.health:SetMinMaxValues(0, 1)
    self.health:SetValue(data.health)
    self.health.value:SetText(GW.RoundInt(data.health * 100) .. "%")
    self.health:SetStatusBarColor(color.r, color.g, color.b, color.a)
    self.power:SetMinMaxValues(0, 1)
    self.power:SetValue(data.power)
    self.power:SetStatusBarColor(GW.Colors.PowerBarCustomColors[data.powerToken]:GetRGB())
    if data.cast and GW.settings.objectives.arenaFrames.castbar then
        self:ShowTestCastbar(data.cast, data.castTime, data.notInterruptible)
    else
        self:HideCastbar()
    end
    self:SetTestAuras(data.auras, GW.settings.objectives.arenaFrames.auras)
    self:Show()
end

function GwArenaFrameMixin:StopTest()
    self.gwTest = nil
    self:SetTestAuras(nil)
    self:HideCastbar()
    self:Hide()
    RegisterUnitWatch(self)
end

function GwArenaFrameMixin:OnShow()
    -- Verstecke alle ArenaPrepFrames
    for _, frame in pairs(arenaPrepFrames) do
        if frame:IsShown() then
            frame:Hide()
        end
    end

    self.container:UpdateArenaFrameHeight()
    countArenaFrames = countArenaFrames + 1
    if self.gwTest then return end
    self:UpdateHealth()
    self:UpdatePower()
    self:UpdateName()
    self:UpdateCastbar(GW.settings.objectives.arenaFrames.castbar)
end

function GwArenaFrameMixin:OnHide()
    self:HideCastbar()
    countArenaFrames = countArenaFrames - 1
    self.container:UpdateArenaFrameHeight()
    local _, instanceType = IsInInstance()
    if countArenaFrames < 1 and instanceType ~= "arena" and instanceType ~= "pvp" then
        GwObjectivesNotification:SetNotification("arena", nil)
        countArenaFrames = 0
    end
end

GwArenaPrepFrameMixin = {}

function GwArenaPrepFrameMixin:OnShow()
    self.container:UpdateArenaFrameHeight()
end


local function UpdateArenaFramesSettings()
    for _, frame in ipairs(arenaFrames) do
        frame:ApplySettings()
    end
    if arenaFrames[1] and arenaFrames[1].gwTest then
        for i, data in ipairs(TEST_OPPONENTS) do
            arenaFrames[i]:StartTest(data)
        end
    end
end
GW.UpdateArenaFramesSettings = UpdateArenaFramesSettings

-- secure frames: only out of combat, and the test ends when a fight starts
local testWatcher = CreateFrame("Frame")
testWatcher:SetScript("OnEvent", function()
    GW.ToggleArenaFramesTest(false)
end)

function GW.ToggleArenaFramesTest(enable)
    if #arenaFrames == 0 or InCombatLockdown() then return end
    local active = arenaFrames[1].gwTest == true
    if enable == nil then
        enable = not active
    elseif enable == active then
        return enable
    end

    if enable then
        for i, data in ipairs(TEST_OPPONENTS) do
            arenaFrames[i]:StartTest(data)
        end
        GwObjectivesNotification:SetNotification("arena", {title = ARENA})
        testWatcher:RegisterEvent("PLAYER_REGEN_DISABLED")
    else
        for i = 1, #TEST_OPPONENTS do
            arenaFrames[i]:StopTest()
        end
        testWatcher:UnregisterEvent("PLAYER_REGEN_DISABLED")
    end
    return enable
end

GwObjectivesArenaContainerMixin = {}

function GwObjectivesArenaContainerMixin:SetCompass()
    local compassTitle, compassDesc = "", ""

    if C_PvP.IsInBrawl() then
        local brawlInfo = C_PvP.GetActiveBrawlInfo()
        if brawlInfo then
            compassTitle = brawlInfo.name
            compassDesc = brawlInfo.shortDescription
        end
    else
        for i = 1, GetMaxBattlefieldID() do
            local status, mapName, _, _, _, _, _, _, _, shortDescription = GetBattlefieldStatus(i)
            if status and status == "active" then
                compassTitle = mapName
                compassDesc = shortDescription or ""
                break
            end
        end
    end

    GwObjectivesNotification:SetNotification("arena", {title = compassTitle, desc = compassDesc})
end

function GwObjectivesArenaContainerMixin:UpdateArenaFrameHeight()
    -- no arena frames yet: the preparation frames hold the slots
    local height, shownSlots = GW.GetFixedSlotContainerHeight(arenaFrames)
    if shownSlots == 0 then
        height = GW.GetFixedSlotContainerHeight(arenaPrepFrames)
    end

    self:SetHeight(height)
end

function GwObjectivesArenaContainerMixin:SetUpFramePosition()
    local yOffset = GW.settings.objectives.compass and 70 or 0

    for idx, frame in pairs(arenaFrames) do
        local p = yOffset + ((48 * idx) - 48)
        frame:SetPoint("TOPRIGHT", GwQuestTracker, "TOPRIGHT", 0, -p)
    end

    for idx, frame in pairs(arenaPrepFrames) do
        local p = yOffset + ((48 * idx) - 48)
        frame:SetPoint("TOPRIGHT", GwQuestTracker, "TOPRIGHT", 0, -p)
    end
end

function GwObjectivesArenaContainerMixin:RegisterFrame(i)
    local arenaFrame = CreateFrame("Button", "GwArenaFrame" .. i, GwQuestTracker, GW.isModern and "GwQuestTrackerArenaFramePingableTemplate" or "GwQuestTrackerArenaFrameTemplate")
    GW.SetFrameRoleset(arenaFrame, "arenaFrames")
    local unit = "arena" .. i
    Mixin(arenaFrame, GwArenaFrameMixin)

    arenaFrame.gwUnit = unit
    arenaFrame.id = i
    arenaFrame.guid = UnitGUID(unit)
    arenaFrame.container = self

    arenaFrame:SetAttribute("unit", unit)
    arenaFrame:SetAttribute("*type1", "target")
    arenaFrame:SetAttribute("*type2", "togglemenu")

    GW.AddToClique(arenaFrame)

    RegisterUnitWatch(arenaFrame)
    arenaFrame:EnableMouse(true)
    arenaFrame:RegisterForClicks("AnyDown")

    arenaFrame.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "SHADOW")
    arenaFrame.marker:Hide()
    arenaFrame.icon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons.png")

    arenaFrame.power.value:Hide()

    -- crowd control on the opponent first, then the important buffs (defensives, trinket effects)
    arenaFrame:InitCastbarAndAuras({ "ARENA_OPPONENT_UPDATE", "PLAYER_ENTERING_WORLD" }, {
        { key = "cc", filter = "HARMFUL|CROWD_CONTROL", maxFrameCount = 2, isDebuff = true },
        { key = "buffs", filter = "HELPFUL|IMPORTANT", maxFrameCount = 2, showStealable = true },
    })
    arenaFrame:ApplySettings()

    arenaFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    arenaFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    arenaFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    arenaFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
    arenaFrame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    arenaFrame:RegisterUnitEvent("UNIT_HEALTH", unit)
    arenaFrame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    arenaFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
    arenaFrame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)
    arenaFrame:RegisterCastbarEvents()

    arenaFrame:SetScript("OnShow", arenaFrame.OnShow)
    arenaFrame:SetScript("OnHide", arenaFrame.OnHide)
    arenaFrame:SetScript("OnEvent", arenaFrame.OnEvent)

    return arenaFrame
end

function GwObjectivesArenaContainerMixin:RegisterPrepFrame()
    local arenaPrepFrame = CreateFrame("Button", nil, GwQuestTracker, "GwQuestTrackerArenaPrepFramePingableTemplate")
    GW.SetFrameRoleset(arenaPrepFrame, "arenaFrames")

    arenaPrepFrame:EnableMouse(true)
    arenaPrepFrame:RegisterForClicks("AnyDown")
    arenaPrepFrame.container = self

    arenaPrepFrame.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "SHADOW")

    arenaPrepFrame:SetScript("OnShow", arenaPrepFrame.OnShow)

    return arenaPrepFrame
end

function GwObjectivesArenaContainerMixin:OnEvent(event)
    -- handle compass header
    if IsIn(event, "PLAYER_ENTERING_WORLD", "PLAYER_ENTERING_BATTLEGROUND", "PVP_BRAWL_INFO_UPDATED", "UPDATE_BATTLEFIELD_STATUS") then
        C_Timer.After(0.8, function()
            local _, instanceType = IsInInstance()
            if instanceType == "arena" or instanceType == "pvp" then
                self:SetCompass()
                self:UpdateArenaFrameHeight()
            end
        end)
    elseif event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" then
        local numOpps = GetNumArenaOpponentSpecs()

        if ArenaPrepFrames then
            ArenaPrepFrames:GwKill()
        end

        for i = 1, MAX_ARENA_ENEMIES do
            local prepFrame = arenaPrepFrames[i]
            if i <= numOpps then
                local specID, gender = GetArenaOpponentSpec(i)
                if GW.IsSecretValue(specID) then
                    UnitFrameUtil.UpdateArenaOpponentSpecDisplayName(prepFrame.name, i)
                    prepFrame.health:SetStatusBarColor(0.5, 0.5, 0.5)
                    prepFrame.power:SetStatusBarColor(0.5, 0.5, 0.5)
                    SetClassIcon(prepFrame.icon)
                    prepFrame:Show()
                elseif specID > 0 then
                    local nameString = UNKNOWN
                    local className, classFile
                    local _, specName, _, _, role, class = GetSpecializationInfoByID(specID, gender)
                    for y = 1, GetNumClasses() do
                        className, classFile = GetClassInfo(y)
                        if class == classFile then
                            break
                        end
                    end
                    if nameRoleIcon[role] then
                        nameString = nameRoleIcon[role] .. className .. " - " .. specName
                    else
                        nameString = className .. " - " .. specName
                    end
                    prepFrame.name:SetText(nameString)
                    prepFrame.health:SetStatusBarColor(0.5, 0.5, 0.5)
                    prepFrame.power:SetStatusBarColor(0.5, 0.5, 0.5)
                    SetClassIcon(prepFrame.icon, class)
                    prepFrame:Show()
                else
                    prepFrame:Hide()
                end
            else
                prepFrame:Hide()
            end
        end

        self:UpdateArenaFrameHeight()
    end
end

function GwObjectivesArenaContainerMixin:InitModule()
    if C_AddOns.IsAddOnLoaded("sArena") then
        return
    end

    for i = 1, MAX_ARENA_ENEMIES do
        arenaFrames[i] = self:RegisterFrame(i)
        if GW.isModern then
            arenaPrepFrames[i] = self:RegisterPrepFrame()
        end
    end
    self:SetUpFramePosition()

    --event for arena prep frames
    self:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")

    -- Log event for compass Header
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PVP_BRAWL_INFO_UPDATED")
    self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
    self:SetScript("OnEvent", self.OnEvent)

    if GW.isModern then
        self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
        local numOpps = GetNumArenaOpponentSpecs()
        if numOpps and numOpps > 0 then
            self:OnEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
        end
    end

    C_Timer.After(0.01, function() self:UpdateArenaFrameHeight() end)
end
