---@class GW2
local GW = select(2, ...)
local L = GW.L

local TRAINER_CACHE_KEY = "upcomingTrainerRewards"
local PET_TRAINER_CACHE_KEY = "upcomingPetTrainerRewards"
local TRAINER_CACHE_VERSION = 4
local TRAINER_FILTERS = {"available", "unavailable", "used"}
local LEVEL_ICON = " |TInterface/AddOns/GW2_UI/textures/icons/levelreward-icon.png:20:20:0:0|t"

local trainableRewards = {}
local upcomingLevelRewards = {}
local petTrainableRewards = {}
local petUpcomingRewards = {}
-- "name (rank)" of every listed reward, the way the trainer names its requirements
local pendingRewardNames = {}
-- pets learn at the pet trainer on these clients, wrath pets use their own talent tree
local HAS_PET_TRAINERS = GW.myclass == "HUNTER" and (GW.Classic or GW.TBC or GW.Forever)
local scanningTrainer = false
local dirty = true

-- the trainer API: forever has the mainline one (step index, icon and level in the service info),
-- the classic clients still have the old globals
local MAINLINE_TRAINER = GetTrainerServiceStepIndex ~= nil

local function IsClassOrPetTrainer()
    if C_Trainer and C_Trainer.GetTrainerType then
        local trainerType = C_Trainer.GetTrainerType()
        return trainerType == Enum.TrainerType.General or trainerType == Enum.TrainerType.Pet
    end
    return not IsTradeskillTrainer()
end

-- forever has no per service flag and reports its pet trainers as general ones: the player knows the learned
-- services of a class trainer, a pet trainer teaches through spells of its own that nobody knows afterwards;
-- nil without learned services
local function IsPetTrainerOffer(rewards)
    if C_Trainer and C_Trainer.GetTrainerType and C_Trainer.GetTrainerType() == Enum.TrainerType.Pet then
        return true
    end
    local hasLearned = false
    for _, reward in ipairs(rewards) do
        if reward.known and reward.spellID then
            if GW.IsPlayerSpell(reward.spellID) then
                return false
            end
            hasLearned = true
        end
    end
    if hasLearned then
        return true
    end
end

local function GetTrainerServiceRequirements(index)
    local requirements
    for i = 1, GetTrainerServiceNumAbilityReq(index) do
        local ability = GetTrainerServiceAbilityReq(index, i)
        if ability then
            requirements = requirements or {}
            tinsert(requirements, ability)
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

    for filter in pairs(restore) do
        SetTrainerServiceTypeFilter(filter, false)
    end

    scanningTrainer = false

    if not IsTrainerServiceLearnSpell then
        local isPetTrainer = IsPetTrainerOffer(rewards)
        if isPetTrainer == nil then
            return
        elseif isPetTrainer then
            rewards, petRewards = petRewards, rewards
        end
    end

    if #rewards > 0 then
        GW.SetStorage(TRAINER_CACHE_KEY, {version = TRAINER_CACHE_VERSION, rewards = rewards})
    end
    if #petRewards > 0 then
        GW.SetStorage(PET_TRAINER_CACHE_KEY, {version = TRAINER_CACHE_VERSION, rewards = petRewards})
    end
end

local function GetTrainerCache(key)
    local cache = GW.GetStorage(key)

    return cache and cache.version == TRAINER_CACHE_VERSION and cache.rewards or nil
end

-- pet trainer spells only teach the pet, so their state is the one of the last visit
local function IsRewardKnown(reward, isPet)
    if reward.spellID and not isPet then
        return GW.IsSpellKnown(reward.spellID) or GW.IsPlayerSpell(reward.spellID)
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

local function UpdateUpcomingSpells()
    wipe(trainableRewards)
    wipe(upcomingLevelRewards)

    local seen, seenNames = {}, {}

    ForEachFutureSpell(function(spellID, name, subName)
        AddUpcomingSpell(seen, spellID)
        seenNames[name .. (subName or "")] = true
    end)

    -- forever only, the classic clients know their level spells only through the trainer
    if C_SpellBook.GetCurrentLevelSpells then
        local maxLevel = GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion() or GetMaxPlayerLevel()
        for level = GW.mylevel + 1, maxLevel do
            for _, spellID in ipairs(C_SpellBook.GetCurrentLevelSpells(level) or {}) do
                AddUpcomingSpell(seen, spellID, level)
            end
        end
    end

    for _, reward in ipairs(GetTrainerCache(TRAINER_CACHE_KEY) or {}) do
        local key = reward.name .. (reward.subText or "")
        if not seenNames[key] and not (reward.spellID and seen[reward.spellID]) and not IsRewardKnown(reward) then
            seenNames[key] = true
            if reward.spellID then
                seen[reward.spellID] = true
            end

            tinsert(reward.level > GW.mylevel and upcomingLevelRewards or trainableRewards, reward)
        end
    end

    table.sort(trainableRewards, SortByLevel)
    table.sort(upcomingLevelRewards, SortByLevel)

    -- the pet trainer levels are the ones of the pet
    wipe(petTrainableRewards)
    wipe(petUpcomingRewards)
    if HAS_PET_TRAINERS then
        local petLevel = UnitExists("pet") and UnitLevel("pet") or GW.mylevel
        for _, reward in ipairs(GetTrainerCache(PET_TRAINER_CACHE_KEY) or {}) do
            if not IsRewardKnown(reward, true) then
                tinsert(reward.level > petLevel and petUpcomingRewards or petTrainableRewards, reward)
            end
        end
        table.sort(petTrainableRewards, SortByLevel)
        table.sort(petUpcomingRewards, SortByLevel)
    end

    wipe(pendingRewardNames)
    for _, rewards in ipairs({trainableRewards, upcomingLevelRewards, petTrainableRewards, petUpcomingRewards}) do
        for _, reward in ipairs(rewards) do
            if reward.name then
                pendingRewardNames[reward.subText and reward.subText ~= "" and format("%s (%s)", reward.name, reward.subText) or reward.name] = true
            end
        end
    end

    dirty = false
end

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

    if elementData.spellID then
        local spellInfo = C_Spell.GetSpellInfo(elementData.spellID)
        if spellInfo then
            icon, name = spellInfo.iconID, spellInfo.name
        end
    end

    local subText = elementData.subText ~= "" and elementData.subText or nil
    return icon, name, subText
end

-- requirements still waiting in the list are red, like at the trainer; the rest keeps the text color
local function GetRequirementText(requirements)
    if not requirements then
        return nil
    end
    local texts = {}
    for _, requirement in ipairs(requirements) do
        tinsert(texts, pendingRewardNames[requirement] and RED_FONT_COLOR:WrapTextInColorCode(requirement) or requirement)
    end
    return REQUIRES_LABEL .. " " .. table.concat(texts, ", ")
end

local function Reward_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, 0)
    GameTooltip:ClearLines()

    if self.elementData.spellID then
        GameTooltip:SetSpellByID(self.elementData.spellID)
    else
        GameTooltip:AddLine(self.name:GetText(), 1, 1, 1)
        GameTooltip:AddLine(format(UNIT_LEVEL_TEMPLATE, self.elementData.level), 0.6, 0.6, 0.6)
    end

    local requirementText = GetRequirementText(self.elementData.requirements)
    if requirementText then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(requirementText, 1, 1, 1, true)
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
        button.requirementString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small, nil, -1)
        button.requirementString:SetTextColor(0.6, 0.6, 0.6)
        button:SetScript("OnEnter", Reward_OnEnter)
        button:SetScript("OnLeave", GameTooltip_Hide)
        button.gwSkinned = true
    end

    button.elementData = elementData

    -- the rank grey behind the name, like at the trainer
    local icon, name, subText = GetRewardDisplay(elementData)
    button.icon:SetTexture(icon)
    button.name:SetText(subText and format("%s |cff999999(%s)|r", name, subText) or name)
    button.levelString:SetText(elementData.level > 0 and (elementData.level .. LEVEL_ICON) or "")
    button.costString:SetText(elementData.cost and elementData.cost > 0 and GW.FormatMoneyForChat(elementData.cost, true) or "")
    button.requirementString:SetText(GetRequirementText(elementData.requirements) or "")

    if button.mask then
        button.icon:RemoveMaskTexture(button.mask)
    end

    if elementData.spellID and C_Spell.IsSpellPassive(elementData.spellID) then
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

local function MatchesSearch(reward, search)
    if search == "" then
        return true
    end
    local _, name, subText = GetRewardDisplay(reward)
    local text = subText and format("%s %s", name, subText) or name
    return text and text:lower():find(search, 1, true) ~= nil
end

-- a section header only stays when something below it matches the search
local function InsertSection(dataProvider, title, rewards, search)
    local header
    for _, reward in ipairs(rewards) do
        if MatchesSearch(reward, search) then
            if not header then
                header = {isHeader = true, title = title}
                dataProvider:Insert(header)
            end
            dataProvider:Insert(reward)
        end
    end
end

local function RefreshRewardList(self)
    EnsureUpcomingSpells()

    local search = strtrim(self.search:GetText()):lower()
    local dataProvider = CreateDataProvider()
    if self.showPet then
        InsertSection(dataProvider, L["Trainable Now"], petTrainableRewards, search)
        InsertSection(dataProvider, L["Next Levels"], petUpcomingRewards, search)
    else
        InsertSection(dataProvider, L["Trainable Now"], trainableRewards, search)
        InsertSection(dataProvider, L["Next Levels"], upcomingLevelRewards, search)
    end

    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)

    local hasCache = GetTrainerCache(self.showPet and PET_TRAINER_CACHE_KEY or TRAINER_CACHE_KEY) ~= nil
    local visitHint = self.showPet and L["Visit a pet trainer once, then GW2 UI lists everything he teaches your pet."]
        or L["Visit your class trainer once, then GW2 UI lists everything he teaches you."]
    self.hint:SetText(hasCache and L["No matching rewards."] or visitHint)
    self.hint:SetShown(not hasCache or dataProvider:IsEmpty())
end

local function UpdateTabs(self)
    for _, tab in ipairs(self.tabs) do
        local selected = tab.isPet == self.showPet
        local shade = selected and 1 or (tab:IsMouseOver() and 0.8 or 0.6)
        tab.Text:SetTextColor(shade, shade, shade)
        tab.line:SetShown(selected)
    end
end

-- plain text switches, the active one underlined
local function CreateTab(self, text, isPet)
    local tab = CreateFrame("Button", nil, self)
    tab.isPet = isPet
    tab.Text = tab:CreateFontString(nil, "OVERLAY")
    tab.Text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    tab.Text:SetPoint("CENTER")
    tab.Text:SetText(text)
    tab:SetSize(tab.Text:GetStringWidth() + 8, 22)

    tab.line = tab:CreateTexture(nil, "ARTWORK")
    tab.line:SetColorTexture(GW.Colors.TextColors.LightHeader:GetRGB())
    tab.line:SetHeight(2)
    tab.line:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 4, 0)
    tab.line:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -4, 0)

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
    self.tabs[2]:SetPoint("BOTTOMRIGHT", self.ScrollBar, "TOPRIGHT", 0, 6)
    self.tabs[1]:SetPoint("RIGHT", self.tabs[2], "LEFT", -6, 0)
    self.search:SetPoint("BOTTOMRIGHT", self.tabs[1], "BOTTOMLEFT", -10, 0)
    UpdateTabs(self)
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

    upcomingSpellsFrame.hint:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    upcomingSpellsFrame.hint:SetTextColor(0.6, 0.6, 0.6)

    local search = upcomingSpellsFrame.search
    search.Instructions:SetTextColor(0.5, 0.5, 0.5)
    search.Instructions:SetText(SEARCH .. "...")
    search:HookScript("OnTextChanged", function(self)
        self.clearButton:SetShown(self:GetText() ~= "")
        RefreshRewardList(upcomingSpellsFrame)
    end)
    search:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
    end)
    search:SetScript("OnEnterPressed", EditBox_ClearFocus)
    search.clearButton:SetScript("OnClick", function(self)
        self:GetParent():SetText("")
        self:GetParent():ClearFocus()
    end)
    upcomingSpellsFrame:SetScript("OnHide", function(self)
        self.search:SetText("")
    end)

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
    -- wrath still names it after the old spell book tabs
    upcomingSpellsFrame:RegisterEvent(C_EventUtils.IsEventValid("LEARNED_SPELL_IN_SKILL_LINE") and "LEARNED_SPELL_IN_SKILL_LINE" or "LEARNED_SPELL_IN_TAB")
    upcomingSpellsFrame:RegisterEvent("TRAINER_UPDATE")
    upcomingSpellsFrame:RegisterEvent("TRAINER_SERVICE_INFO_NAME_UPDATE")
    if HAS_PET_TRAINERS then
        upcomingSpellsFrame.showPet = false
        CreatePetTabs(upcomingSpellsFrame)
        upcomingSpellsFrame:RegisterUnitEvent("UNIT_PET", "player")
        upcomingSpellsFrame:RegisterUnitEvent("UNIT_LEVEL", "pet")
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
        function(self, event)
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
