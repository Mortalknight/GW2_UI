local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
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

GwArenaFrameMixin = CreateFromMixins(GwObjectivesUnitFrameMixin)

function GwArenaFrameMixin:UpdateName()
    local inArena = C_PvP.GetZonePVPInfo()
    local inBG = UnitInBattleground("player")
    local name = UnitName(self.unit) or UNKNOWNOBJECT
    local nameString = UNKNOWNOBJECT

    if inArena == "arena" then
        local specID = GetArenaOpponentSpec(self.id)
        if specID and specID > 0 then
            local _, specName, _, _, role = GetSpecializationInfoByID(specID, UnitSex(self.unit))
            if role and nameRoleIcon[role] and specName and name then
                nameString = nameRoleIcon[role] .. name .. " - " .. specName
            else
                nameString = name
            end
        else
            nameString = name
        end
    elseif inBG then
        local role = UnitGroupRolesAssigned(self.unit)
        local englishFaction = UnitFactionGroup(self.unit)
        if role and nameRoleIcon[role] and englishFaction and FractionIcon[englishFaction] and name then
            nameString = FractionIcon[englishFaction] .. nameRoleIcon[role] .. name
        else
            nameString = name
        end
    else
        nameString = name
    end

    self.name:SetText(nameString)
    self.class = select(2, UnitClass(self.unit))
    self.classIndex = select(3, UnitClass(self.unit))
    if self.class then
        SetClassIcon(self.icon, self.classIndex)
        local color = GWGetClassColor(self.class, true)
        self.health:SetStatusBarColor(color.r, color.g, color.b, color.a)
    end

    if GW.Retail then return end
    self.guid = UnitGUID(self.unit)
    if self.guid == UnitGUID("target") then
        self.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    else
        self.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    end
end

function GwArenaFrameMixin:OnEvent(event, unitId)
    if event == "UNIT_POWER_FREQUENT" and self.unit ~= unitId then return end
    local _, instanceType = IsInInstance()
    if instanceType ~= "arena" and instanceType ~= "pvp" then
        return
    end

    if IsIn(event, "UNIT_MAXHEALTH", "UNIT_HEALTH") then
        self:UpdateHealth()
    elseif IsIn(event, "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT") then
        self:UpdatePower()
    elseif event == "PLAYER_TARGET_CHANGED" then
        self:UpdateName()
    elseif IsIn(event, "PLAYER_ENTERING_WORLD", "PLAYER_ENTERING_BATTLEGROUND", "UNIT_NAME_UPDATE", "ARENA_OPPONENT_UPDATE") then
        self:UpdateHealth()
        self:UpdatePower()
        self:UpdateName()
    end
end

function GwArenaFrameMixin:OnShow()
    -- Verstecke alle ArenaPrepFrames
    for _, frame in pairs(arenaPrepFrames) do
        if frame:IsShown() then
            frame:Hide()
        end
    end

    self.container:UpdateArenaFrameHeight()
    self:UpdateHealth()
    self:UpdatePower()
    self:UpdateName()
    countArenaFrames = countArenaFrames + 1
end

function GwArenaFrameMixin:OnHide()
    countArenaFrames = countArenaFrames - 1
    self.container:UpdateArenaFrameHeight()
    local _, instanceType = IsInInstance()
    if countArenaFrames < 1 and instanceType ~= "arena" and instanceType ~= "pvp" then
        GwObjectivesNotification:RemoveNotificationOfType(GW.TRACKER_TYPE.ARENA)
        countArenaFrames = 0
    end
end

GwArenaPrepFrameMixin = {}

function GwArenaPrepFrameMixin:OnShow()
    self.container:UpdateArenaFrameHeight()
end


GwObjectivesArenaContainerMixin = {}

function GwObjectivesArenaContainerMixin:SetCompass()
    local compassData = {}
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

    compassData.TITLE = compassTitle
    compassData.DESC = compassDesc
    compassData.TYPE = GW.TRACKER_TYPE.ARENA
    compassData.ID = "arena_unknown"
    compassData.QUESTID = "unknown"
    compassData.COMPASS = false
    compassData.MAPID = nil
    compassData.X = nil
    compassData.Y = nil
    compassData.COLOR = TRACKER_TYPE_COLOR.ARENA

    GwObjectivesNotification:AddNotification(compassData, true)
end

function GwObjectivesArenaContainerMixin:UpdateArenaFrameHeight()
    local lastIndex = 0

    for index, frame in pairs(arenaFrames) do
        if frame:IsShown() then
            lastIndex = index
        end
    end

    if lastIndex == 0 then
        for index, frame in pairs(arenaPrepFrames) do
            if frame:IsShown() then
                lastIndex = index
            end
        end
    end
    self.oldHeight = GW.RoundInt(self:GetHeight())
    self:SetHeight(lastIndex > 0 and (48 * lastIndex) or 1)
end

function GwObjectivesArenaContainerMixin:SetUpFramePosition()
    local yOffset = GW.settings.SHOW_QUESTTRACKER_COMPASS and 70 or 0

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
    local arenaFrame = CreateFrame("Button", "GwArenaFrame" .. i, GwQuestTracker, GW.Retail and "GwQuestTrackerArenaFramePingableTemplate" or "GwQuestTrackerArenaFrameTemplate")
    local unit = "arena" .. i
    Mixin(arenaFrame, GwArenaFrameMixin)

    arenaFrame.unit = unit
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

    arenaFrame.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    arenaFrame.name:SetShadowOffset(1, -1)
    arenaFrame.marker:Hide()
    arenaFrame.icon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\classicons.png")

    arenaFrame.power.value:Hide()

    arenaFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    arenaFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    arenaFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    arenaFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
    arenaFrame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    arenaFrame:RegisterUnitEvent("UNIT_HEALTH", unit)
    arenaFrame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    arenaFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
    arenaFrame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)

    arenaFrame:SetScript("OnShow", arenaFrame.OnShow)
    arenaFrame:SetScript("OnHide", arenaFrame.OnHide)
    arenaFrame:SetScript("OnEvent", arenaFrame.OnEvent)

    return arenaFrame
end

function GwObjectivesArenaContainerMixin:RegisterPrepFrame()
    local arenaPrepFrame = CreateFrame("Button", nil, GwQuestTracker, "GwQuestTrackerArenaPrepFramePingableTemplate")

    arenaPrepFrame:EnableMouse(true)
    arenaPrepFrame:RegisterForClicks("AnyDown")
    arenaPrepFrame.container = self

    arenaPrepFrame.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    arenaPrepFrame.name:SetShadowOffset(1, -1)

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
                if specID > 0 then
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
        if GW.Retail then
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

    if GW.Retail then
        self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
        local numOpps = GetNumArenaOpponentSpecs()
        if numOpps and numOpps > 0 then
            self:OnEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
        end
    end

    C_Timer.After(0.01, function() self:UpdateArenaFrameHeight() end)
end
