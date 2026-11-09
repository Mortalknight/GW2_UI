---@class GW2
local GW = select(2, ...)
local L = GW.L

local TRAINER_CACHE_KEY = "upcomingTrainerRewards"
local PET_TRAINER_CACHE_KEY = "upcomingPetTrainerRewards"
local TRAINER_CACHE_VERSION = 6
local TRAINER_FILTERS = {"available", "unavailable", "used"}

local trainableRewards = {}
local upcomingLevelRewards = {}
local petTrainableRewards = {}
local petUpcomingRewards = {}
-- the level the pet trainer offer counts with, the one of the pet unless the hunter learns it himself
local petRewardLevel, petLevelIsOwn = 1, false
-- "name (rank)" of every trainer reward, the way the trainer names its requirements; true while not learned
local rewardPending = {}
-- pets learn at the pet trainer on these clients, wrath pets use their own talent tree
local HAS_PET_TRAINERS = GW.myclass == "HUNTER" and (GW.Classic or GW.TBC or GW.Forever)
local scanningTrainer = false
local dirty = true

-- forever has the mainline GetTrainerServiceInfo (icon and level in it), the classic clients the old one;
-- same global on both, and the classic binaries have GetTrainerServiceStepIndex too
local MAINLINE_TRAINER = GW.Forever

-- on forever the pet trainer type is the window that teaches the pet and the pet trainer counts as general,
-- the classic clients teach the pet in the craft window
local function GetMaxLevel()
    return GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion() or GetMaxPlayerLevel()
end

local function IsClassOrPetTrainer()
    if C_Trainer and C_Trainer.GetTrainerType then
        local trainerType = C_Trainer.GetTrainerType()
        return trainerType == Enum.TrainerType.General or (trainerType == Enum.TrainerType.Pet and not MAINLINE_TRAINER)
    end
    return not IsTradeskillTrainer()
end

local BEAST_TRAINING_SPELL_ID = 5149

-- needs all services listed
local function TeachesInSkillLines(skillLines)
    for index = 1, GetNumTrainerServices() do
        if skillLines[GetTrainerServiceSkillLine(index) or ""] then
            return true
        end
    end
    return false
end

-- only the class trainer teaches in the skill lines of the spell book, weapon masters and pet trainers do not
local function TeachesSpellBookLines()
    local spellBookLines = {}
    if C_SpellBook.GetNumSpellBookSkillLines then
        for skillLineIndex = 1, C_SpellBook.GetNumSpellBookSkillLines() do
            local skillLine = C_SpellBook.GetSpellBookSkillLineInfo(skillLineIndex)
            if skillLine then
                spellBookLines[skillLine.name] = true
            end
        end
    else
        for tab = 1, GetNumSpellTabs() do
            spellBookLines[GetSpellTabInfo(tab)] = true
        end
    end
    return TeachesInSkillLines(spellBookLines)
end

-- the pet trainer teaches in the beast training line, named like the spell; classic also gives him a type of his own,
-- forever uses that type for the window that teaches the pet
local function IsPetTrainerOffer(isClassTrainer)
    if not MAINLINE_TRAINER and C_Trainer and C_Trainer.GetTrainerType and C_Trainer.GetTrainerType() == Enum.TrainerType.Pet then
        return true
    end
    local beastTraining = C_Spell.GetSpellInfo(BEAST_TRAINING_SPELL_ID)
    return not isClassTrainer and beastTraining ~= nil and TeachesInSkillLines({[beastTraining.name] = true})
end

local function GetTrainerServiceRequirements(index)
    local requirements
    for i = 1, GetTrainerServiceNumAbilityReq(index) do
        local ability, hasReq = GetTrainerServiceAbilityReq(index, i)
        if ability then
            requirements = requirements or {}
            tinsert(requirements, {name = ability, met = hasReq})
        end
    end
    return requirements
end

local function GetTrainerService(index)
    if MAINLINE_TRAINER then
        return GetTrainerServiceInfo(index)
    end
    local name, subText, serviceType = GetTrainerServiceInfo(index)
    return name, serviceType, GetTrainerServiceIcon(index), GetTrainerServiceLevelReq(index), subText
end

local function GetTrainerServiceSpellID(index)
    if C_TooltipInfo and C_TooltipInfo.GetTrainerService then
        local tooltipData = C_TooltipInfo.GetTrainerService(index)
        return tooltipData and tooltipData.id
    end

    local tooltip = GW.ScanTooltip
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:SetTrainerService(index)
    local _, spellID = tooltip:GetSpell()
    tooltip:Hide()
    return spellID
end

local function GetTrainerCache(key)
    local cache = GW.GetStorage(key)
    if cache and cache.version == TRAINER_CACHE_VERSION then
        return cache.rewards, cache.playerLevels
    end
end

-- classic style clients hand out most spells at the trainer, so we remember his whole offer on the first visit
local function CacheTrainerRewards()
    if scanningTrainer or not IsClassOrPetTrainer() then
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

    local rewards, petRewards = {}, {}
    local stepIndex = MAINLINE_TRAINER and GetTrainerServiceStepIndex()
    for index = 1, GetNumTrainerServices() do
        if index ~= stepIndex then
            local name, serviceType, texture, reqLevel, subText = GetTrainerService(index)
            if name and serviceType ~= "header" then
                -- the pet trainers offer goes to its own list, it must not replace the class trainers one
                local isPetSpell = IsTrainerServiceLearnSpell and select(2, IsTrainerServiceLearnSpell(index))
                tinsert(isPetSpell and petRewards or rewards, {
                    spellID = GetTrainerServiceSpellID(index),
                    name = name,
                    subText = subText,
                    icon = texture,
                    level = reqLevel or 0,
                    cost = GetTrainerServiceCost(index),
                    known = serviceType == "used",
                    requirements = GetTrainerServiceRequirements(index)
                })
            end
        end
    end

    -- forever reports weapon masters and pet trainers as general ones too, their offer must not replace the class list
    local isClassTrainer = TeachesSpellBookLines()
    local isPetTrainer = false
    if #petRewards == 0 and HAS_PET_TRAINERS then
        isPetTrainer = IsPetTrainerOffer(isClassTrainer)
    end

    for filter in pairs(restore) do
        SetTrainerServiceTypeFilter(filter, false)
    end

    scanningTrainer = false

    if isPetTrainer then
        rewards, petRewards = petRewards, rewards
    end
    -- unflagged pet spells on classic are learned by the hunter himself, so their levels are his
    local playerLevels = isPetTrainer and not MAINLINE_TRAINER or nil

    -- a trainer with only a few class spells, like the portal trainer of mages, must not replace the full list
    local classCache = GetTrainerCache(TRAINER_CACHE_KEY)
    if #rewards > 0 and isClassTrainer and (not classCache or #rewards * 2 >= #classCache) then
        GW.SetStorage(TRAINER_CACHE_KEY, {version = TRAINER_CACHE_VERSION, rewards = rewards})
    end
    if #petRewards > 0 then
        GW.SetStorage(PET_TRAINER_CACHE_KEY, {version = TRAINER_CACHE_VERSION, rewards = petRewards, playerLevels = playerLevels})
    end
end

-- pet trainer spells only teach the pet, so their state is the one of the last visit
local function IsRewardKnown(reward, isPet)
    if reward.spellID and not isPet then
        return C_SpellBook.IsSpellInSpellBook(reward.spellID, Enum.SpellBookSpellBank.Player, false) or C_SpellBook.IsSpellKnown(reward.spellID, Enum.SpellBookSpellBank.Player)
    end

    return reward.known
end

-- the client does not count every lower rank as known after a new one, a known higher rank covers them
local highestKnownLevel = {}

local function IsRewardLearned(reward, isPet)
    local highest = highestKnownLevel[(isPet and "pet:" or "") .. reward.name]
    return highest and reward.level < highest or IsRewardKnown(reward, isPet)
end

local function UpdateHighestKnownLevels(rewards, isPet)
    for _, reward in ipairs(rewards) do
        local key = (isPet and "pet:" or "") .. reward.name
        if IsRewardKnown(reward, isPet) and reward.level > (highestKnownLevel[key] or 0) then
            highestKnownLevel[key] = reward.level
        end
    end
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
    tinsert(upcomingLevelRewards, {spellID = spellID, level = level})
end

-- future spells the spell book already knows about
local function ForEachFutureSpell(func)
    if C_SpellBook.GetNumSpellBookSkillLines then
        for skillLineIndex = 1, C_SpellBook.GetNumSpellBookSkillLines() do
            local skillLine = C_SpellBook.GetSpellBookSkillLineInfo(skillLineIndex)
            if skillLine and not skillLine.isGuild then
                for slotIndex = skillLine.itemIndexOffset + 1, skillLine.itemIndexOffset + skillLine.numSpellBookItems do
                    local itemInfo = C_SpellBook.GetSpellBookItemInfo(slotIndex, Enum.SpellBookSpellBank.Player)
                    if itemInfo and not itemInfo.isOffSpec and itemInfo.itemType == Enum.SpellBookItemType.FutureSpell then
                        func(itemInfo.spellID, itemInfo.name, itemInfo.subName)
                    end
                end
            end
        end
        return
    end

    for tab = 1, GetNumSpellTabs() do
        local _, _, offset, numSlots, isGuild, offSpecID = GetSpellTabInfo(tab)
        if not isGuild and (offSpecID or 0) == 0 then
            for slot = offset + 1, offset + numSlots do
                local slotType, spellID = GetSpellBookItemInfo(slot, BOOKTYPE_SPELL)
                if slotType == "FUTURESPELL" then
                    local name, subName = GetSpellBookItemName(slot, BOOKTYPE_SPELL)
                    func(spellID, name, subName)
                end
            end
        end
    end
end

local function SortByLevel(a, b)
    return a.level < b.level
end

local function GetRewardKey(reward)
    return reward.subText and reward.subText ~= "" and format("%s (%s)", reward.name, reward.subText) or reward.name
end

-- requirements outside the trainer offer (talents) keep the state of the last visit
local function IsRequirementMet(requirement)
    local pending = rewardPending[requirement.name]
    if pending == nil then
        return requirement.met
    end
    return not pending
end

local function IsRewardTrainable(reward, level)
    if reward.level > level then
        return false
    end
    for _, requirement in ipairs(reward.requirements or {}) do
        if not IsRequirementMet(requirement) then
            return false
        end
    end
    return true
end

local function UpdateUpcomingSpells()
    wipe(trainableRewards)
    wipe(upcomingLevelRewards)

    local seen, seenNames = {}, {}
    local classRewards = GetTrainerCache(TRAINER_CACHE_KEY) or {}
    local petRewards, petPlayerLevels
    if HAS_PET_TRAINERS then
        petRewards, petPlayerLevels = GetTrainerCache(PET_TRAINER_CACHE_KEY)
    end
    petRewards = petRewards or {}

    wipe(highestKnownLevel)
    UpdateHighestKnownLevels(classRewards)
    UpdateHighestKnownLevels(petRewards, true)

    wipe(rewardPending)
    for _, reward in ipairs(classRewards) do
        rewardPending[GetRewardKey(reward)] = not IsRewardLearned(reward)
    end
    for _, reward in ipairs(petRewards) do
        rewardPending[GetRewardKey(reward)] = not IsRewardLearned(reward, true)
    end

    ForEachFutureSpell(function(spellID, name, subName)
        AddUpcomingSpell(seen, spellID)
        seenNames[name .. (subName or "")] = true
    end)

    -- forever only, the classic clients know their level spells only through the trainer
    if C_SpellBook.GetCurrentLevelSpells then
        for level = GW.mylevel + 1, GetMaxLevel() do
            for _, spellID in ipairs(C_SpellBook.GetCurrentLevelSpells(level) or {}) do
                AddUpcomingSpell(seen, spellID, level)
            end
        end
    end

    for _, reward in ipairs(classRewards) do
        local key = reward.name .. (reward.subText or "")
        if not seenNames[key] and not (reward.spellID and seen[reward.spellID]) and not IsRewardLearned(reward) then
            seenNames[key] = true
            if reward.spellID then
                seen[reward.spellID] = true
            end

            tinsert(IsRewardTrainable(reward, GW.mylevel) and trainableRewards or upcomingLevelRewards, reward)
        end
    end

    table.sort(trainableRewards, SortByLevel)
    table.sort(upcomingLevelRewards, SortByLevel)

    -- the pet trainer levels are the ones of the pet
    wipe(petTrainableRewards)
    wipe(petUpcomingRewards)
    petLevelIsOwn = not petPlayerLevels and UnitExists("pet")
    petRewardLevel = petLevelIsOwn and UnitLevel("pet") or GW.mylevel
    for _, reward in ipairs(petRewards) do
        if not IsRewardLearned(reward, true) then
            tinsert(IsRewardTrainable(reward, petRewardLevel) and petTrainableRewards or petUpcomingRewards, reward)
        end
    end
    table.sort(petTrainableRewards, SortByLevel)
    table.sort(petUpcomingRewards, SortByLevel)

    dirty = false
end

local function EnsureUpcomingSpells()
    if dirty then
        UpdateUpcomingSpells()
    end
end

function GW.GetUpcomingSpellCounts()
    EnsureUpcomingSpells()

    return #trainableRewards, #upcomingLevelRewards
end

local function GetRewardDisplay(reward)
    local icon, name = reward.icon, reward.name

    if reward.spellID then
        local spellInfo = C_Spell.GetSpellInfo(reward.spellID)
        if spellInfo then
            icon, name = spellInfo.iconID, spellInfo.name
        end
    end

    local subText = reward.subText ~= "" and reward.subText or nil
    return icon, name, subText
end

local function GetRequirementText(requirements)
    local texts = {}
    for _, requirement in ipairs(requirements or {}) do
        if not IsRequirementMet(requirement) then
            tinsert(texts, RED_FONT_COLOR:WrapTextInColorCode(requirement.name))
        end
    end
    return #texts > 0 and REQUIRES_LABEL .. " " .. table.concat(texts, ", ") or nil
end

-- levels this far after the own one only show their icons
local COMPACT_FROM = 3
-- the right half of the summary counts this many levels ahead
local SUMMARY_LEVELS = 5
local STRIP_ICONS = 12

-- "Rank 3/8": the highest rank of the trainer offer, the starting ranks are not in it
local function GetRankText(entry)
    local _, _, subText = GetRewardDisplay(entry.reward)
    local _, _, lastSubText = GetRewardDisplay(entry.ranks[#entry.ranks].reward)
    local lastRank = lastSubText and lastSubText:match("%d+")
    if subText and lastRank then
        return format("%s/%s", subText, lastRank)
    end
    return subText or ""
end

local function Reward_OnEnter(self)
    local entry = self.elementData
    local reward = entry.reward
    local white, grey = GW.Colors.FallbackWhite, GW.Colors.SkinColors.Disabled
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, 0)
    GameTooltip:ClearLines()

    if reward.spellID then
        GameTooltip:SetSpellByID(reward.spellID)
    else
        GameTooltip:AddLine(entry.name, white.r, white.g, white.b)
        GameTooltip:AddLine(format(UNIT_LEVEL_TEMPLATE, reward.level), grey.r, grey.g, grey.b)
    end

    local requirementText = GetRequirementText(reward.requirements)
    if requirementText then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(requirementText, white.r, white.g, white.b, true)
    end

    local addedSpace
    for _, rank in ipairs(entry.ranks) do
        if rank.reward.level > reward.level and rank.reward.subText and rank.reward.subText ~= "" then
            if not addedSpace then
                GameTooltip:AddLine(" ")
                addedSpace = true
            end
            GameTooltip:AddDoubleLine(rank.reward.subText,
                format(UNIT_LEVEL_TEMPLATE, rank.reward.level), white.r, white.g, white.b, grey.r, grey.g, grey.b)
        end
    end

    GameTooltip:Show()
end

-- the rows show their tooltip only over the icon, the hover of the row stays
local function Row_OnUpdate(self)
    local overIcon = self.icon:IsMouseOver() or nil
    if overIcon ~= self.gwOverIcon then
        self.gwOverIcon = overIcon
        if overIcon then
            Reward_OnEnter(self)
        else
            GameTooltip_Hide()
        end
    end
end

local function Row_OnEnter(self)
    self:SetScript("OnUpdate", Row_OnUpdate)
end

local function Row_OnLeave(self)
    self:SetScript("OnUpdate", nil)
    if self.gwOverIcon then
        self.gwOverIcon = nil
        GameTooltip_Hide()
    end
end

local function SortRanks(a, b)
    if a.reward.level ~= b.reward.level then
        return a.reward.level < b.reward.level
    end
    return a.now and not b.now
end

local function SortEntries(a, b)
    if a.level ~= b.level then
        return a.level < b.level
    end
    if a.name ~= b.name then
        return a.name < b.name
    end
    return a.reward.level < b.reward.level
end

local function MatchesSearch(reward, search)
    if search == "" then
        return true
    end
    local _, name, subText = GetRewardDisplay(reward)
    local text = subText and format("%s %s", name, subText) or name
    return text and text:lower():find(search, 1, true) ~= nil
end

-- the ranks of a spell share one list for the rank text and the tooltip
local function BuildEntries(trainable, upcoming, search)
    local ranksByName, entries = {}, {}
    local function Add(reward, now)
        local _, name = GetRewardDisplay(reward)
        name = name or ""
        ranksByName[name] = ranksByName[name] or {}
        local entry = {name = name, reward = reward, now = now, level = reward.level, cost = reward.cost or 0, ranks = ranksByName[name]}
        tinsert(entry.ranks, entry)
        if MatchesSearch(reward, search) then
            tinsert(entries, entry)
        end
    end
    for _, reward in ipairs(trainable) do Add(reward, true) end
    for _, reward in ipairs(upcoming) do Add(reward, false) end

    for _, ranks in pairs(ranksByName) do
        table.sort(ranks, SortRanks)
    end
    table.sort(entries, SortEntries)
    return entries
end

local function InitNode(frame, data)
    if not frame.gwSkinned then
        frame.Name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
        frame.info:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small)
        frame.info:SetTextColor(GW.Colors.SkinColors.Disabled:GetRGB())
        frame.Name:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        frame.line:SetColorTexture(GW.Colors.Accent:GetRGB())
        frame.gwSkinned = true
    end

    if data.kind == "here" then
        frame.node:SetTexture("Interface/COMMON/Indicator-Green")
        frame.Name:SetText(format(UNIT_LEVEL_TEMPLATE, data.level))
        frame.info:SetText(data.max > 0 and format("%d%%", data.current / data.max * 100) or "")
    else
        frame.node:SetTexture(data.kind == "now" and "Interface/COMMON/Indicator-Yellow" or "Interface/COMMON/Indicator-Gray")
        frame.Name:SetText(data.kind == "now" and L["Trainable Now:"] or format(UNIT_LEVEL_TEMPLATE, data.level))
        -- the summary above already counts what is trainable now
        frame.info:SetText(data.kind == "now" and "" or format("%d %s", #data.entries, SPELLS))
    end

    if data.kind == "here" and data.max > 0 then
        if not frame.xp then
            frame.xp = CreateFrame("StatusBar", nil, frame)
            frame.xp:SetPoint("LEFT", frame, "LEFT", 130, 0)
            frame.xp:SetPoint("RIGHT", frame, "RIGHT", -50, 0)
            frame.xp:SetHeight(6)
            frame.xp:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
            frame.xp.bg = frame.xp:CreateTexture(nil, "BACKGROUND")
            frame.xp.bg:SetAllPoints()
            frame.xp.bg:SetColorTexture(GW.Colors.SkinColors.StatusBarTrack:GetRGBA())
        end
        frame.xp:SetStatusBarColor((data.isPet and GW.Colors.StatusBarColors.PetXp or GW.Colors.StatusBarColors.Xp):GetRGB())
        frame.xp:SetMinMaxValues(0, data.max)
        frame.xp:SetValue(data.current)
        frame.xp:Show()
    elseif frame.xp then
        frame.xp:Hide()
    end
end

local function InitReward(button, entry)
    if not button.gwSkinned then
        button.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
        button.ranks:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small)
        button.ranks:SetTextColor(GW.Colors.SkinColors.Disabled:GetRGB())
        button.costString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small)
        button.requirementString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small, nil, -1)
        button.requirementString:SetTextColor(GW.Colors.SkinColors.Disabled:GetRGB())
        button.line:SetColorTexture(GW.Colors.Accent:GetRGB())
        button.hover:SetVertexColor(GW.Colors.SkinColors.ListHover:GetRGBA())
        button:SetScript("OnEnter", Row_OnEnter)
        button:SetScript("OnLeave", Row_OnLeave)
        button.gwSkinned = true
    end

    button.elementData = entry
    -- the row under the mouse can get a new entry, its tooltip follows
    if button.gwOverIcon then
        Reward_OnEnter(button)
    end

    local reward = entry.reward
    local icon, name = GetRewardDisplay(reward)
    local requirementText = GetRequirementText(reward.requirements)
    local offset = requirementText and 8 or 0
    button.icon:SetTexture(icon)
    button.name:SetText(name)
    button.name:SetPoint("LEFT", 80, offset)
    button.ranks:SetText(GetRankText(entry))
    button.costString:SetText(entry.cost > 0 and GW.FormatMoneyForChat(entry.cost, true) or "")
    button.costString:SetPoint("RIGHT", -6, offset)
    button.requirementString:SetText(requirementText or "")

    if button.mask then
        button.icon:RemoveMaskTexture(button.mask)
    end

    if reward.spellID and C_Spell.IsSpellPassive(reward.spellID) then
        if not button.mask then
            button.mask = UIParent:CreateMaskTexture()
            button.mask:SetPoint("CENTER", button.icon, "CENTER", 0, 0)
            button.mask:SetTexture(
                "Interface/AddOns/GW2_UI/textures/talents/passive_border.png",
                "CLAMPTOBLACKADDITIVE",
                "CLAMPTOBLACKADDITIVE"
            )
            button.mask:SetSize(32, 32)
        end
        button.icon:AddMaskTexture(button.mask)
    end
end

local function InitStrip(frame, data)
    if not frame.icons then
        frame.icons = {}
        frame.line:SetColorTexture(GW.Colors.Accent:GetRGB())
    end
    for index, entry in ipairs(data.entries) do
        local button = frame.icons[index]
        if not button then
            button = CreateFrame("Button", nil, frame)
            button:SetSize(30, 30)
            button:SetPoint("TOPLEFT", frame, "TOPLEFT", 40 + ((index - 1) % STRIP_ICONS) * 36, -5 - math.floor((index - 1) / STRIP_ICONS) * 36)
            button.icon = button:CreateTexture(nil, "ARTWORK")
            button.icon:SetAllPoints()
            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            button:SetScript("OnEnter", Reward_OnEnter)
            button:SetScript("OnLeave", GameTooltip_Hide)
            frame.icons[index] = button
        end
        button.elementData = entry
        button.icon:SetTexture((GetRewardDisplay(entry.reward)))
        button:Show()
    end
    for index = #data.entries + 1, #frame.icons do
        frame.icons[index]:Hide()
    end
end

local function SetSummary(text, title, count, cost)
    local money = ""
    if cost > 0 then
        money = GW.FormatMoneyForChat(cost, true)
        if GetMoney() < cost then
            money = GW.Colors.SkinColors.Negative:WrapTextInColorCode((money:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")))
        end
        money = "  " .. money
    end
    text:SetText(GW.Colors.SkinColors.Disabled:WrapTextInColorCode(title) .. " " .. format("%d %s", count, SPELLS) .. money)
end

local function UpdateSummary(self, trainable, upcoming, level)
    local nowCost, aheadCount = 0, #trainable
    for _, reward in ipairs(trainable) do
        nowCost = nowCost + (reward.cost or 0)
    end
    local aheadCost = nowCost
    local aheadLevel = math.min(level + SUMMARY_LEVELS, GetMaxLevel())
    for _, reward in ipairs(upcoming) do
        if reward.level <= aheadLevel then
            aheadCount = aheadCount + 1
            aheadCost = aheadCost + (reward.cost or 0)
        end
    end
    SetSummary(self.summaryNow, L["Trainable Now:"], #trainable, nowCost)
    SetSummary(self.summaryAhead, format(L["Up To Level %d"], aheadLevel) .. ":", aheadCount, aheadCost)
end

-- the path: what the trainer has now, the own level with its progress, then the later levels; far levels only
-- show icons while nothing is searched
local function RefreshRewardList(self)
    EnsureUpcomingSpells()

    local search = strtrim(self.search:GetText()):lower()
    local trainable, upcoming, level = trainableRewards, upcomingLevelRewards, GW.mylevel
    local current, max, isPetXp = UnitXP("player"), UnitXPMax("player"), false
    if self.showPet then
        trainable, upcoming, level = petTrainableRewards, petUpcomingRewards, petRewardLevel
        if petLevelIsOwn and GetPetExperience then
            current, max = GetPetExperience()
            isPetXp = true
        end
    end
    UpdateSummary(self, trainable, upcoming, level)

    local entries = BuildEntries(trainable, upcoming, search)
    local dataProvider = CreateDataProvider()
    if #entries > 0 then
        local now, levels, byLevel = {}, {}, {}
        for _, entry in ipairs(entries) do
            if entry.now then
                tinsert(now, entry)
            else
                -- reached but blocked by a requirement, it stays at the own level
                local entryLevel = math.max(entry.level, level)
                if not byLevel[entryLevel] then
                    byLevel[entryLevel] = {}
                    tinsert(levels, entryLevel)
                end
                tinsert(byLevel[entryLevel], entry)
            end
        end

        if #now > 0 then
            dataProvider:Insert({kind = "now"})
            for _, entry in ipairs(now) do
                dataProvider:Insert(entry)
            end
        end
        dataProvider:Insert({kind = "here", level = level, current = current or 0, max = max or 0, isPet = isPetXp})
        for _, entryLevel in ipairs(levels) do
            local list = byLevel[entryLevel]
            if entryLevel > level then
                dataProvider:Insert({kind = "level", level = entryLevel, entries = list})
            end
            if search == "" and entryLevel >= level + COMPACT_FROM then
                dataProvider:Insert({kind = "strip", entries = list})
            else
                for _, entry in ipairs(list) do
                    dataProvider:Insert(entry)
                end
            end
        end
    end

    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)

    local hasCache = GetTrainerCache(self.showPet and PET_TRAINER_CACHE_KEY or TRAINER_CACHE_KEY) ~= nil
    local visitHint = self.showPet and L["Visit a pet trainer once, then GW2 UI lists everything he teaches your pet."]
        or L["Visit your class trainer once, then GW2 UI lists everything he teaches you."]
    self.hint:SetText(hasCache and L["No matching rewards."] or visitHint)
    self.hint:SetShown(not hasCache or #entries == 0)
end

local function UpdateTabs(self)
    for _, tab in ipairs(self.tabs) do
        GW.SetTextTab(tab, tab.text, tab.isPet == self.showPet)
    end
end

local function CreateTab(self, text, isPet)
    local tab = CreateFrame("Button", nil, self)
    tab.isPet = isPet
    tab.text = text
    tab:SetHeight(22)
    GW.AddTextTabArt(tab)

    tab:SetScript("OnClick", function()
        self.showPet = isPet
        UpdateTabs(self)
        RefreshRewardList(self)
    end)
    tab:SetScript("OnEnter", function() UpdateTabs(self) end)
    tab:SetScript("OnLeave", function() UpdateTabs(self) end)
    return tab
end

-- the hunters get a second tab for the pet trainers offer, it shares the row with a shorter search box
local function CreatePetTabs(self)
    self.tabs = {CreateTab(self, CHARACTER, false), CreateTab(self, PET, true)}
    self.tabs[2]:SetPoint("BOTTOMRIGHT", self.ScrollBar, "TOPRIGHT", 0, 8)
    self.tabs[1]:SetPoint("RIGHT", self.tabs[2], "LEFT", -6, 0)
    self.search:SetPoint("BOTTOMRIGHT", self.tabs[1], "BOTTOMLEFT", -10, 0)
    UpdateTabs(self)
end

local function CreateSummaryText(self, point, x)
    local text = self:CreateFontString(nil, "OVERLAY")
    text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    text:SetPoint(point, self, point, x, -100)
    return text
end

-- the alert system of gw2 only runs on wrath and forever
local function ShowTrainableAlert(self, oldLevel, newLevel)
    local notifications = GW.settings.notifications
    if not (GW.AlertSystem and notifications.enabled and notifications.levelUp.enabled) then return end
    EnsureUpcomingSpells()
    local count = 0
    for _, reward in ipairs(trainableRewards) do
        if reward.level > oldLevel and reward.level <= newLevel then
            count = count + 1
        end
    end
    if count == 0 then return end
    GW.AlertSystem:AddAlert(L["Trainable Now:"] .. " " .. format("%d %s", count, SPELLS), nil, L["Upcoming Level Rewards"],
        function() self:Show() end, "Interface/AddOns/GW2_UI/textures/icons/levelreward-icon.png", false)
end

local function UpcomingSpellsFrameOnShow(self)
    RefreshRewardList(self)
    self.ScrollBox:ScrollToBegin()

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

    upcomingSpellsFrame.header:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
    upcomingSpellsFrame.header:SetText(L["Upcoming Level Rewards"])

    upcomingSpellsFrame.hint:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    upcomingSpellsFrame.hint:SetTextColor(GW.Colors.SkinColors.Disabled:GetRGB())

    local search = upcomingSpellsFrame.search
    GW.SkinEditBox(search, {search = true})
    search:SetScript("OnEnterPressed", search.ClearFocus)
    search:HookScript("OnTextChanged", function() RefreshRewardList(upcomingSpellsFrame) end)
    upcomingSpellsFrame:SetScript("OnHide", function(self)
        self.search:SetText("")
    end)

    upcomingSpellsFrame.CloseButton:SetScript("OnClick", GW.Parent_Hide)
    upcomingSpellsFrame.CloseButton:SetText(CLOSE)

    upcomingSpellsFrame:SetScript("OnShow", UpcomingSpellsFrameOnShow)

    tinsert(UISpecialFrames, "GwLevelingRewards")

    upcomingSpellsFrame.summaryNow = CreateSummaryText(upcomingSpellsFrame, "TOPLEFT", 30)
    upcomingSpellsFrame.summaryAhead = CreateSummaryText(upcomingSpellsFrame, "TOPRIGHT", -28)

    -- an even dark band behind the list, the world must not show through the art
    local listBackground = upcomingSpellsFrame:CreateTexture(nil, "BORDER")
    listBackground:SetPoint("TOPLEFT", upcomingSpellsFrame.ScrollBox, "TOPLEFT", -4, 4)
    listBackground:SetPoint("BOTTOMRIGHT", upcomingSpellsFrame.ScrollBar, "BOTTOMRIGHT", 4, -4)
    listBackground:SetColorTexture(GW.Colors.SkinColors.ListHeader:GetRGBA())

    local view = CreateScrollBoxListLinearView()
    view:SetElementFactory(function(factory, elementData)
        if elementData.kind == "strip" then
            factory("GwUpcomingRewardStrip", InitStrip)
        elseif elementData.kind then
            factory("GwUpcomingRewardHeader", InitNode)
        else
            factory("GwUpcomingRewardRow", InitReward)
        end
    end)
    view:SetElementExtentCalculator(function(_, elementData)
        if elementData.kind == "strip" then
            return 4 + math.ceil(#elementData.entries / STRIP_ICONS) * 36
        end
        if elementData.kind then
            return 30
        end
        return GetRequirementText(elementData.reward.requirements) and 48 or 40
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(upcomingSpellsFrame.ScrollBox, upcomingSpellsFrame.ScrollBar, view)
    GW.HandleTrimScrollBar(upcomingSpellsFrame.ScrollBar)
    GW.HandleScrollControls(upcomingSpellsFrame)
    upcomingSpellsFrame.ScrollBar:SetHideIfUnscrollable(true)

    upcomingSpellsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    upcomingSpellsFrame:RegisterEvent("PLAYER_LEVEL_CHANGED")
    -- wrath still names it after the old spell book tabs
    upcomingSpellsFrame:RegisterEvent(C_EventUtils.IsEventValid("LEARNED_SPELL_IN_SKILL_LINE") and "LEARNED_SPELL_IN_SKILL_LINE" or "LEARNED_SPELL_IN_TAB")
    upcomingSpellsFrame:RegisterEvent("TRAINER_UPDATE")
    upcomingSpellsFrame:RegisterEvent("TRAINER_SERVICE_INFO_NAME_UPDATE")
    upcomingSpellsFrame:RegisterEvent("PLAYER_MONEY")
    upcomingSpellsFrame:RegisterEvent("PLAYER_XP_UPDATE")
    if HAS_PET_TRAINERS then
        upcomingSpellsFrame.showPet = false
        CreatePetTabs(upcomingSpellsFrame)
        upcomingSpellsFrame:RegisterUnitEvent("UNIT_PET", "player")
        upcomingSpellsFrame:RegisterUnitEvent("UNIT_LEVEL", "pet")
        upcomingSpellsFrame:RegisterEvent("UNIT_PET_EXPERIENCE")
    end

    local function Refresh()
        dirty = true
        if upcomingSpellsFrame:IsShown() then
            RefreshRewardList(upcomingSpellsFrame)
        end
        GW.UpdateExpBar()
    end

    upcomingSpellsFrame:SetScript(
        "OnEvent",
        function(self, event, ...)
            if event == "PLAYER_LEVEL_CHANGED" then
                local oldLevel, newLevel = ...
                -- later, the own level of gw2 may not be updated yet
                if newLevel and oldLevel and newLevel > oldLevel then
                    C_Timer.After(1, function()
                        Refresh()
                        ShowTrainableAlert(self, oldLevel, newLevel)
                    end)
                    return
                end
            end
            if event == "PLAYER_MONEY" or event == "PLAYER_XP_UPDATE" or event == "UNIT_PET_EXPERIENCE" then
                if self:IsShown() then
                    RefreshRewardList(self)
                end
                return
            end
            -- names, ranks and requirements arrive one by one after the trainer opened, one scan per batch;
            -- the filter switches of our own scan fire these as well, right away or in the next frame
            if event == "TRAINER_UPDATE" or event == "TRAINER_SERVICE_INFO_NAME_UPDATE" then
                if scanningTrainer or self.gwScanQueued or GetTime() < (self.gwScanQuietUntil or 0) then return end
                self.gwScanQueued = true
                C_Timer.After(0.2, function()
                    self.gwScanQueued = false
                    CacheTrainerRewards()
                    self.gwScanQuietUntil = GetTime() + 0.1
                    Refresh()
                end)
                return
            end

            Refresh()
        end
    )
end
GW.LoadUpcomingSpells = LoadUpcomingSpells
