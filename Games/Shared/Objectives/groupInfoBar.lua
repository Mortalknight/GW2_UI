---@class GW2
local GW = select(2, ...)
local L = GW.L

-- group info bar between the timer and the scenario block, during a mythic+ key or a raid boss: the visible
-- icons line up right to left; auras are secret, so lust and sated run through aura tracker containers
local BREZ_SPELL_ID = 20484
local LUST_SPELL_IDS = {
    [2825] = true, [32182] = true, [80353] = true, [264667] = true, [390386] = true, [466904] = true,
    [146555] = true, [178207] = true, [230935] = true, [256740] = true, [309658] = true, [381301] = true, [444257] = true,
}
local SATED_SPELL_IDS = {
    [57723] = true, [57724] = true, [80354] = true, [95809] = true, [160455] = true, [264689] = true, [390435] = true,
}
local ICON_SIZE = 13
local BAR_HEIGHT = 20
-- the chest times of the timer only fill the left side, the bar moves up into that row
local BAR_OVERLAP = 12
local MASK = "Interface/CHARACTERFRAME/TempPortraitAlphaMask"

local function SetFont(fontString)
    fontString:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "SHADOW", -2)
end

local function AddRoundMask(parent, texture)
    local mask = parent:CreateMaskTexture()
    mask:SetAllPoints(texture)
    mask:SetTexture(MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    texture:AddMaskTexture(mask)
end

-- round icon with a thin dark ring like the affix icons
local function CreateRoundIcon(parent, texture)
    local icon = parent:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon:SetTexture(texture)
    AddRoundMask(parent, icon)

    local ring = parent:CreateTexture(nil, "BORDER")
    ring:SetColorTexture(0, 0, 0, 0.9)
    ring:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
    ring:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
    AddRoundMask(parent, ring)
    return icon
end

local function UpdateBattleRes(brez)
    if brez.test then
        brez.count:SetText(1)
        if not brez.testStart then
            brez.testStart = GetTime()
            brez.cooldown:SetCooldown(brez.testStart, 600)
        end
        return
    end

    local info = C_Spell.GetSpellCharges(BREZ_SPELL_ID)
    if not info then
        brez.count:SetText("")
        brez.cooldown:Clear()
        return
    end
    -- the charges are secret while cooldowns are restricted, text and swipe take them as they are
    brez.count:SetText(info.currentCharges)
    local duration = C_Spell.GetSpellChargeDuration(BREZ_SPELL_ID)
    if duration then
        brez.cooldown:SetCooldownFromDurationObject(duration)
    else
        brez.cooldown:Clear()
    end
end

local function BattleRes_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText(L["Battle Res"], 1, 1, 1)
    GameTooltip:AddLine(L["Charges the whole group shares for battle resurrections. The ring fills until the next charge."], nil, nil, nil, true)
    local info = not self.test and C_Spell.GetSpellCharges(BREZ_SPELL_ID)
    if self.test or info then
        GameTooltip:AddDoubleLine(L["Charges"], self.test and 1 or info.currentCharges, nil, nil, nil, 1, 1, 1)
    end
    GameTooltip:Show()
end

local function Lust_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText(C_Spell.GetSpellName(self.spellID), 1, 1, 1)
    GameTooltip:AddLine(L["Grey with a time: the group is sated until then. Colored: bloodlust is ready or active."], nil, nil, nil, true)
    GameTooltip:Show()
end

local function BattleRes_OnShow(self)
    self:RegisterEvent("SPELL_UPDATE_CHARGES")
    UpdateBattleRes(self)
end

local function BattleRes_OnHide(self)
    self:UnregisterEvent("SPELL_UPDATE_CHARGES")
end

-- the engine shows the button while the aura is up, the icon covers the base icon below
local function CreateLustTracker(parent, filter, spellIDs, desaturated, text)
    local container = GW.CreateAuraTrackerContainer({
        parent = parent,
        unit = "player",
        filter = filter,
        spellIDs = spellIDs,
        width = ICON_SIZE,
        height = ICON_SIZE,
        createWidgets = function(button)
            local icon = CreateRoundIcon(button, parent.iconTexture)
            icon:SetPoint("CENTER")
            icon:SetDesaturated(desaturated)
            if not text then return {} end
            local fontString = button:CreateFontString(nil, "OVERLAY")
            SetFont(fontString)
            fontString:SetTextColor(RED_FONT_COLOR:GetRGB())
            fontString:SetJustifyH("RIGHT")
            fontString:SetPoint("RIGHT", parent, "RIGHT", -10, 0)
            return {durationText = fontString}
        end,
    })
    container:ClearAllPoints()
    container:SetPoint("CENTER", parent.icon, "CENTER")
    return container
end

-- same layout as the death counter: 30 wide, text right aligned, icon on the right edge
local function CreateGroup(parent, texture)
    local group = CreateFrame("Frame", nil, parent)
    group:SetSize(30, ICON_SIZE)
    group.iconTexture = texture
    group.icon = CreateRoundIcon(group, texture)
    group.icon:SetPoint("CENTER", group, "RIGHT", 0, 0)
    group:EnableMouse(true)
    group:SetHitRectInsets(0, -ICON_SIZE / 2, 0, 0)
    return group
end

local function CreateBattleRes(bar)
    local brez = CreateGroup(bar, C_Spell.GetSpellTexture(BREZ_SPELL_ID))
    brez.cooldown = CreateFrame("Cooldown", nil, brez, "CooldownFrameTemplate")
    brez.cooldown:SetAllPoints(brez.icon)
    brez.cooldown:SetSwipeTexture(MASK, 1, 1, 1, 1)
    brez.cooldown:SetSwipeColor(0, 0, 0, 0.5)
    brez.cooldown:SetReverse(true)
    brez.cooldown:SetDrawEdge(false)
    brez.cooldown:SetHideCountdownNumbers(true)
    brez.count = brez:CreateFontString(nil, "OVERLAY")
    SetFont(brez.count)
    brez.count:SetJustifyH("RIGHT")
    brez.count:SetPoint("RIGHT", brez, "RIGHT", -10, 0)
    brez:SetScript("OnEvent", UpdateBattleRes)
    brez:SetScript("OnEnter", BattleRes_OnEnter)
    brez:SetScript("OnLeave", GameTooltip_Hide)
    brez:SetScript("OnShow", BattleRes_OnShow)
    brez:SetScript("OnHide", BattleRes_OnHide)
    return brez
end

local function CreateLust(bar)
    local lustSpellID = GW.myfaction == "Alliance" and 32182 or 2825
    local lust = CreateGroup(bar, C_Spell.GetSpellTexture(lustSpellID))
    lust.spellID = lustSpellID
    lust:SetScript("OnEnter", Lust_OnEnter)
    lust:SetScript("OnLeave", GameTooltip_Hide)
    CreateLustTracker(lust, "HARMFUL", SATED_SPELL_IDS, true, true):SetFrameLevel(lust:GetFrameLevel() + 1)
    CreateLustTracker(lust, "HELPFUL", LUST_SPELL_IDS, false, false):SetFrameLevel(lust:GetFrameLevel() + 2)
    return lust
end

local function Deaths_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText(CHALLENGE_MODE_DEATH_COUNT_TITLE:format(self.count), 1, 1, 1)
    GameTooltip:AddLine(CHALLENGE_MODE_DEATH_COUNT_DESCRIPTION:format(SecondsToClock(self.timeLost)))
    GameTooltip:Show()
end

local function CreateDeaths(bar)
    local deaths = CreateFrame("Frame", nil, bar)
    deaths:SetSize(30, ICON_SIZE)
    deaths.icon = deaths:CreateTexture(nil, "ARTWORK")
    deaths.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-dead.png")
    deaths.icon:SetSize(15, 15)
    deaths.icon:SetPoint("CENTER", deaths, "RIGHT", 0, 0)
    deaths.counter = deaths:CreateFontString(nil, "OVERLAY")
    SetFont(deaths.counter)
    deaths.counter:SetJustifyH("RIGHT")
    deaths.counter:SetPoint("RIGHT", deaths, "RIGHT", -10, 0)
    deaths:EnableMouse(true)
    deaths:SetHitRectInsets(0, -ICON_SIZE / 2, 0, 0)
    deaths:SetScript("OnEnter", Deaths_OnEnter)
    deaths:SetScript("OnLeave", GameTooltip_Hide)
    deaths:Hide()
    return deaths
end

GwGroupInfoBarMixin = {}

-- mythic+ only, shown from the first death on
function GwGroupInfoBarMixin:SetDeaths(count, timeLost)
    local deaths = self.deaths
    deaths.count, deaths.timeLost = count, timeLost
    deaths.counter:SetText(count)
    deaths:SetShown(count and count > 0 and timeLost and timeLost > 0)
    self:UpdateState()
end

-- the shown icons right to left, hidden ones leave no gap
function GwGroupInfoBarMixin:Layout()
    local previous
    for _, item in ipairs(self.items) do
        if item:IsShown() then
            item:ClearAllPoints()
            if previous then
                item:SetPoint("RIGHT", previous, "LEFT", -6, 0)
            else
                item:SetPoint("RIGHT", self, "RIGHT", -18, 0)
            end
            previous = item
        end
    end
end

function GwGroupInfoBarMixin:UpdateState()
    local active = (self.test or self.inRaidEncounter or self.container.timerBlock.gwChallengeMode) and true or false
    for _, item in ipairs(self.groupItems) do
        item:SetShown(active)
    end
    if active ~= self:IsShown() then
        self:SetShown(active)
        self:SetHeight(active and BAR_HEIGHT or 0.1)
        self:ClearAllPoints()
        self:SetPoint("TOPRIGHT", self.container.timerBlock, "BOTTOMRIGHT", 0, active and BAR_OVERLAP or 0)
        self.container:QueueUpdateLayout()
    end
    self:Layout()
end

-- the height the bar adds to the scenario container
function GwGroupInfoBarMixin:GetLayoutHeight()
    return self:IsShown() and BAR_HEIGHT - BAR_OVERLAP or 0
end

function GwGroupInfoBarMixin:SetTest(test)
    if self.test == test then return end
    self.test = test
    if self.brez then
        self.brez.test = test
        self.brez.testStart = nil
        self.brez.cooldown:Clear()
        if self.brez:IsShown() then
            UpdateBattleRes(self.brez)
        end
    end
    self:UpdateState()
end

function GwGroupInfoBarMixin:OnEvent(event)
    if event == "ENCOUNTER_START" then
        self.inRaidEncounter = select(2, GetInstanceInfo()) == "raid"
    elseif event == "ENCOUNTER_END" then
        self.inRaidEncounter = false
    else
        self.inRaidEncounter = IsEncounterInProgress and IsEncounterInProgress() and select(2, GetInstanceInfo()) == "raid"
    end
    self:UpdateState()
end

function GW.CreateGroupInfoBar(container)
    local bar = Mixin(CreateFrame("Frame", nil, container), GwGroupInfoBarMixin)
    bar.container = container
    bar:SetSize(container.timerBlock:GetWidth(), 0.1)
    bar:SetPoint("TOPRIGHT", container.timerBlock, "BOTTOMRIGHT", 0, 0)
    bar:Hide()

    bar.deaths = CreateDeaths(bar)
    bar.items = {bar.deaths}
    bar.groupItems = {}

    if GW.CreateAuraTrackerContainer and C_Spell.GetSpellChargeDuration then
        bar.brez = CreateBattleRes(bar)
        bar.lust = CreateLust(bar)
        tinsert(bar.items, bar.brez)
        tinsert(bar.items, bar.lust)
        tinsert(bar.groupItems, bar.brez)
        tinsert(bar.groupItems, bar.lust)
    end

    bar:SetScript("OnEvent", bar.OnEvent)
    bar:RegisterEvent("ENCOUNTER_START")
    bar:RegisterEvent("ENCOUNTER_END")
    bar:RegisterEvent("PLAYER_ENTERING_WORLD")
    return bar
end
