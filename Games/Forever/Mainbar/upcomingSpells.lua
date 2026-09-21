---@class GW2
local GW = select(2, ...)
local L = GW.L

local TRAINER_CACHE_KEY = "upcomingTrainerRewards"
local TRAINER_CACHE_VERSION = 3
local TRAINER_FILTERS = {"available", "unavailable", "used"}
local LEVEL_ICON = " |TInterface/AddOns/GW2_UI/textures/icons/levelreward-icon.png:24:24:0:0|t"

local trainableRewards = {}
local upcomingLevelRewards = {}
local scanningTrainer = false
local dirty = true

-- classic style clients hand out most spells at the trainer, so we remember his whole offer on the first visit
local function CacheTrainerRewards()
    if scanningTrainer or C_Trainer.GetTrainerType() ~= Enum.TrainerType.General then
        return
    end

    scanningTrainer = true

    local restore = {}
    for _, filter in ipairs(TRAINER_FILTERS) do
        if not GetTrainerServiceTypeFilter(filter) then
            restore[filter] = true
            SetTrainerServiceTypeFilter(filter, true)
        end
    end

    local rewards = {}
    local stepIndex = GetTrainerServiceStepIndex()
    for index = 1, GetNumTrainerServices() do
        if index ~= stepIndex then
            local name, serviceType, texture, reqLevel, subText = GetTrainerServiceInfo(index)
            if name and serviceType ~= "header" then
                local tooltipData = C_TooltipInfo.GetTrainerService(index)
                tinsert(rewards, {
                    spellID = tooltipData and tooltipData.id,
                    name = name,
                    subText = subText,
                    icon = texture,
                    level = reqLevel or 0,
                    cost = GetTrainerServiceCost(index),
                    known = serviceType == "used"
                })
            end
        end
    end

    for filter in pairs(restore) do
        SetTrainerServiceTypeFilter(filter, false)
    end

    scanningTrainer = false

    GW.SetStorage(TRAINER_CACHE_KEY, {version = TRAINER_CACHE_VERSION, rewards = rewards})
end

local function GetTrainerCache()
    local cache = GW.GetStorage(TRAINER_CACHE_KEY)

    return cache and cache.version == TRAINER_CACHE_VERSION and cache.rewards or nil
end

local function IsRewardKnown(reward)
    if reward.spellID then
        return IsSpellKnown(reward.spellID) or IsPlayerSpell(reward.spellID)
    end

    return reward.known
end

local function AddUpcomingSpell(seen, spellID, level)
    if not spellID or seen[spellID] then
        return
    end

    level = level or C_Spell.GetSpellLevelLearned(spellID)
    if not level or level <= GW.mylevel then
        return
    end

    seen[spellID] = true
    tinsert(upcomingLevelRewards, {id = spellID, level = level})
end

local function SortByLevel(a, b)
    return a.level < b.level
end

local function UpdateUpcomingSpells()
    wipe(trainableRewards)
    wipe(upcomingLevelRewards)

    local seen, seenNames = {}, {}

    for skillLineIndex = 1, C_SpellBook.GetNumSpellBookSkillLines() do
        local skillLine = C_SpellBook.GetSpellBookSkillLineInfo(skillLineIndex)
        if skillLine and not skillLine.isGuild then
            for slotIndex = skillLine.itemIndexOffset + 1, skillLine.itemIndexOffset + skillLine.numSpellBookItems do
                local itemInfo = C_SpellBook.GetSpellBookItemInfo(slotIndex, Enum.SpellBookSpellBank.Player)
                if itemInfo and not itemInfo.isOffSpec and itemInfo.itemType == Enum.SpellBookItemType.FutureSpell then
                    AddUpcomingSpell(seen, itemInfo.spellID)
                    seenNames[itemInfo.name .. (itemInfo.subName or "")] = true
                end
            end
        end
    end

    local maxLevel = GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion() or GetMaxPlayerLevel()
    for level = GW.mylevel + 1, maxLevel do
        for _, spellID in ipairs(C_SpellBook.GetCurrentLevelSpells(level) or {}) do
            AddUpcomingSpell(seen, spellID, level)
        end
    end

    for _, reward in ipairs(GetTrainerCache() or {}) do
        local key = reward.name .. (reward.subText or "")
        if not seenNames[key] and not (reward.spellID and seen[reward.spellID]) and not IsRewardKnown(reward) then
            seenNames[key] = true
            if reward.spellID then
                seen[reward.spellID] = true
            end

            local entry = {id = reward.spellID, name = reward.name, subText = reward.subText, icon = reward.icon, level = reward.level, cost = reward.cost}
            tinsert(reward.level > GW.mylevel and upcomingLevelRewards or trainableRewards, entry)
        end
    end

    table.sort(trainableRewards, SortByLevel)
    table.sort(upcomingLevelRewards, SortByLevel)

    dirty = false
end
GW.UpdateUpcomingSpells = UpdateUpcomingSpells

local function EnsureUpcomingSpells()
    if dirty then
        UpdateUpcomingSpells()
    end
end

local function IsUpcomingSpellAvalible()
    EnsureUpcomingSpells()

    return #upcomingLevelRewards > 0 or #trainableRewards > 0
end
GW.IsUpcomingSpellAvalible = IsUpcomingSpellAvalible

local function GetRewardDisplay(elementData)
    local icon, name = elementData.icon, elementData.name

    if elementData.id then
        local spellInfo = C_Spell.GetSpellInfo(elementData.id)
        if spellInfo then
            icon, name = spellInfo.iconID, spellInfo.name
        end
    end

    if elementData.subText and elementData.subText ~= "" then
        name = name .. " " .. elementData.subText
    end

    return icon, name
end

local function Reward_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, 0)
    GameTooltip:ClearLines()

    if self.elementData.id then
        GameTooltip:SetSpellByID(self.elementData.id)
    else
        GameTooltip:AddLine(self.name:GetText(), 1, 1, 1)
        GameTooltip:AddLine(format(UNIT_LEVEL_TEMPLATE, self.elementData.level), 0.6, 0.6, 0.6)
    end

    GameTooltip:Show()
end

local function InitHeader(frame, elementData)
    if not frame.gwSkinned then
        frame.Name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        frame.gwSkinned = true
    end

    frame.Name:SetText(elementData.title)
end

local function InitReward(button, elementData)
    if not button.gwSkinned then
        button.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
        button.levelString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
        button.costString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small)
        button.costString:SetTextColor(0.6, 0.6, 0.6)
        button:SetScript("OnEnter", Reward_OnEnter)
        button:SetScript("OnLeave", GameTooltip_Hide)
        button.gwSkinned = true
    end

    button.elementData = elementData

    local icon, name = GetRewardDisplay(elementData)
    button.icon:SetTexture(icon)
    button.name:SetText(name)
    button.levelString:SetText(elementData.level > 0 and (elementData.level .. LEVEL_ICON) or "")
    button.costString:SetText(elementData.cost and elementData.cost > 0 and GW.FormatMoneyForChat(elementData.cost) or "")

    if button.mask then
        button.icon:RemoveMaskTexture(button.mask)
    end

    if elementData.id and C_Spell.IsSpellPassive(elementData.id) then
        if not button.mask then
            button.mask = UIParent:CreateMaskTexture()
            button.mask:SetPoint("CENTER", button.icon, "CENTER", 0, 0)
            button.mask:SetTexture(
                "Interface/AddOns/GW2_UI/textures/talents/passive_border.png",
                "CLAMPTOBLACKADDITIVE",
                "CLAMPTOBLACKADDITIVE"
            )
            button.mask:SetSize(40, 40)
        end
        button.icon:AddMaskTexture(button.mask)
    end
end

local function RefreshRewardList(self)
    EnsureUpcomingSpells()

    local dataProvider = CreateDataProvider()

    if #trainableRewards > 0 then
        dataProvider:Insert({isHeader = true, title = L["Trainable Now"]})
        for _, reward in ipairs(trainableRewards) do
            dataProvider:Insert(reward)
        end
    end

    if #upcomingLevelRewards > 0 then
        dataProvider:Insert({isHeader = true, title = L["Next Levels"]})
        for _, reward in ipairs(upcomingLevelRewards) do
            dataProvider:Insert(reward)
        end
    end

    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
    self.hint:SetShown(GetTrainerCache() == nil)
end

local function UpcomingSpellsFrameOnShow(self)
    RefreshRewardList(self)

    PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_OPEN)
    self.animationValue = -400
    local start = GetTime()
    GW.AddToAnimation(
        self:GetDebugName(),
        self.animationValue,
        0,
        start,
        0.2,
        function(p)
            local a = math.min(1, math.max(0, GW.lerp(0, 1, (GetTime() - start) / 0.2)))
            self:SetAlpha(a)
            self:SetPoint("CENTER", 0, p)
        end
    )
end

local function LoadUpcomingSpells()
    local upcomingSpellsFrame = CreateFrame("Frame", "GwLevelingRewards", UIParent, "GwLevelingRewards")

    upcomingSpellsFrame.header:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    upcomingSpellsFrame.header:SetText(L["Upcoming Level Rewards"])

    upcomingSpellsFrame.rewardHeader:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small, nil, -1)
    upcomingSpellsFrame.rewardHeader:SetTextColor(0.6, 0.6, 0.6)
    upcomingSpellsFrame.rewardHeader:SetText(REWARD)

    upcomingSpellsFrame.levelHeader:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small, nil, -1)
    upcomingSpellsFrame.levelHeader:SetTextColor(0.6, 0.6, 0.6)
    upcomingSpellsFrame.levelHeader:SetText(LEVEL)

    upcomingSpellsFrame.hint:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    upcomingSpellsFrame.hint:SetTextColor(0.6, 0.6, 0.6)
    upcomingSpellsFrame.hint:SetText(L["Visit your class trainer once, then GW2 UI lists everything he teaches you."])

    upcomingSpellsFrame.CloseButton:SetScript("OnClick", GW.Parent_Hide)
    upcomingSpellsFrame.CloseButton:SetText(CLOSE)

    upcomingSpellsFrame:SetScript("OnShow", UpcomingSpellsFrameOnShow)

    tinsert(UISpecialFrames, "GwLevelingRewards")

    local view = CreateScrollBoxListLinearView()
    view:SetElementFactory(function(factory, elementData)
        if elementData.isHeader then
            factory("GwUpcomingRewardHeader", InitHeader)
        else
            factory("GwUpcomingRewardRow", InitReward)
        end
    end)
    view:SetElementExtentCalculator(function(_, elementData)
        return elementData.isHeader and 28 or 50
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(upcomingSpellsFrame.ScrollBox, upcomingSpellsFrame.ScrollBar, view)
    GW.HandleTrimScrollBar(upcomingSpellsFrame.ScrollBar)
    GW.HandleScrollControls(upcomingSpellsFrame)
    upcomingSpellsFrame.ScrollBar:SetHideIfUnscrollable(true)

    upcomingSpellsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    upcomingSpellsFrame:RegisterEvent("PLAYER_LEVEL_CHANGED")
    upcomingSpellsFrame:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE")
    upcomingSpellsFrame:RegisterEvent("TRAINER_UPDATE")

    upcomingSpellsFrame:SetScript(
        "OnEvent",
        function(self, event)
            if event == "TRAINER_UPDATE" then
                CacheTrainerRewards()
            end

            dirty = true

            if self:IsShown() then
                RefreshRewardList(self)
            end

            GW.UpdateExpBar()
        end
    )
end
GW.LoadUpcomingSpells = LoadUpcomingSpells
