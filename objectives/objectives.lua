local _, GW = ...
local RoundDec = GW.RoundDec
local IsIn = GW.IsIn
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local AFP = GW.AddProfiling

-- needed frames
local fTracker
local fTraScr
local fNotify
local fBoss
local fArenaBG
local fScen
local fAchv
local fCampaign
local fQuest
local fBonus
local fRecipe
local fMonthlyActivity
local fCollection


local function ParseSimpleObjective(text)
    local itemName, numItems, numNeeded = string.match(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)")

    if itemName == nil then
        numItems, numNeeded, _ = string.match(text, "(%d+)/(%d+) (%S+)")
    end
    local ndString = ""

    if numItems ~= nil then
        ndString = numItems
    end

    if numNeeded ~= nil then
        ndString = ndString .. "/" .. numNeeded
    end

    return string.gsub(text, ndString, "")
end
GW.ParseSimpleObjective = ParseSimpleObjective


local function ParseCriteria(quantity, totalQuantity, criteriaString, isMythicKeystone, mythicKeystoneCurrentValue, isWeightedProgress)
    if quantity ~= nil and totalQuantity ~= nil and criteriaString ~= nil then
        if isMythicKeystone then
            if isWeightedProgress then
                return string.format("%.2f", (mythicKeystoneCurrentValue / totalQuantity * 100)) .."% " ..  string.format("(%s/%s) %s", mythicKeystoneCurrentValue, totalQuantity, criteriaString)
            else
                return string.format("%d/%d %s", quantity, totalQuantity, criteriaString)
            end
        elseif totalQuantity == 0 then
            return string.format("%d %s", quantity, criteriaString)
        else
            return string.format("%d/%d %s", quantity, totalQuantity, criteriaString)
        end
    end

    return criteriaString
end
GW.ParseCriteria = ParseCriteria

local function FormatObjectiveNumbers(text)
    local itemName, numItems, numNeeded = string.match(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)")

    if itemName == nil then
        numItems, numNeeded, itemName = string.match(text, "(%d+)/(%d+) ((.*))")
    end
    numItems = tonumber(numItems)
    numNeeded = tonumber(numNeeded)

    if numItems ~= nil and numNeeded ~= nil then
        return GW.GetLocalizedNumber(numItems) .. " / " .. GW.GetLocalizedNumber(numNeeded) .. " " .. itemName
    end
    return text
end
GW.FormatObjectiveNumbers = FormatObjectiveNumbers


local questExraButtonHelperFrame = CreateFrame("Frame")
questExraButtonHelperFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    GW.updateExtraQuestItemPositions(self.height)
end)

local function updateExtraQuestItemPositions(height)
    if GwBonusItemButton == nil or GwScenarioItemButton == nil then
        return
    end

    if InCombatLockdown() then
        questExraButtonHelperFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        questExraButtonHelperFrame.height = height
        return
    end

    height = height or 0

    if fNotify:IsShown() then
        height = height + fNotify.desc:GetHeight() + 50
    end

    height = height + fBoss:GetHeight() + fArenaBG:GetHeight()

    GwScenarioItemButton:SetPoint("TOPLEFT", fTracker, "TOPRIGHT", -330, -height)

    height = height + fScen:GetHeight() + fQuest:GetHeight() + fAchv:GetHeight() + fCampaign:GetHeight()

    -- get correct height for WQ block
    for i = 1, 20 do
        if _G["GwBonusObjectiveBlock" .. i] ~= nil and _G["GwBonusObjectiveBlock" .. i].questID then
            if _G["GwBonusObjectiveBlock" .. i].hasItem then
                break
            end
            height = height + _G["GwBonusObjectiveBlock" .. i]:GetHeight()
        end
    end

    GwBonusItemButton:SetPoint("TOPLEFT", fTracker, "TOPRIGHT", -330, -height + -25)
end
GW.updateExtraQuestItemPositions = updateExtraQuestItemPositions

local function QuestTrackerLayoutChanged()
    updateExtraQuestItemPositions()
    -- adjust scrolframe height
    local height = fCollection:GetHeight() + fMonthlyActivity:GetHeight() + fRecipe:GetHeight() + fBonus:GetHeight() + fQuest:GetHeight() + fCampaign:GetHeight() + fAchv:GetHeight() + 60 + (GwQuesttrackerContainerWQT and GwQuesttrackerContainerWQT:GetHeight() or 0) + (GwQuesttrackerContainerPetTracker and GwQuesttrackerContainerPetTracker:GetHeight() or 0) + (GwQuesttrackerContainerTodoloo and GwQuesttrackerContainerTodoloo:GetHeight() or 0)
    local scroll = 0
    local trackerHeight = GW.settings.QuestTracker_pos_height - fBoss:GetHeight() - fArenaBG:GetHeight() - fScen:GetHeight() - fNotify:GetHeight()
    if height > tonumber(trackerHeight) then
        scroll = math.abs(trackerHeight - height)
    end
    fTraScr.maxScroll = scroll

    fTraScr:SetSize(fTracker:GetWidth(), height)
end
GW.QuestTrackerLayoutChanged = QuestTrackerLayoutChanged

local function tracker_OnEvent(self, event, ...)
    local numWatchedQuests = C_QuestLog.GetNumQuestWatches()

    if event == "QUEST_LOG_UPDATE" then
        self:UpdateQuestLogLayout()
    elseif event == "QUEST_ACCEPTED" then
        local questID = ...
        if not C_QuestLog.IsQuestBounty(questID) then
            if C_QuestLog.IsQuestTask(questID) then
                if not C_QuestLog.IsWorldQuest(questID) then
                    self:UpdateQuestLogLayoutSingle(questID)
                end
            else
                if GetCVarBool("autoQuestWatch") and C_QuestLog.GetNumQuestWatches() < Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
                    C_QuestLog.AddQuestWatch(questID)
                    self:UpdateQuestLogLayoutSingle(questID)
                end
            end
        end
    elseif event == "QUEST_WATCH_LIST_CHANGED" then
        local questID, added = ...
        if added then
            if not C_QuestLog.IsQuestBounty(questID) or C_QuestLog.IsComplete(questID) then
                self:UpdateQuestLogLayoutSingle(questID, added)
            end
        else
            self:UpdateQuestLogLayout()
        end
    elseif event == "QUEST_AUTOCOMPLETE" then
        local questID = ...
        self:UpdateQuestLogLayoutSingle(questID)
    elseif event == "PLAYER_MONEY" and self.watchMoneyReasons > numWatchedQuests then
        self:UpdateQuestLogLayout()
    elseif event == "LOAD" then
        self:UpdateQuestLogLayout()
        C_Timer.After(0.5, function() GW.updateBonusObjective(fBonus) end)
        self.init = true
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:RegisterEvent("QUEST_DATA_LOAD_RESULT")
    elseif event == "QUEST_DATA_LOAD_RESULT" then
        local questID, success = ...
        local idx = C_QuestLog.GetLogIndexForQuestID(questID)
        if success and questID and idx and idx > 0 then
            C_Timer.After(1, function()self:UpdateQuestLogLayoutSingle(questID) end)
        end
    end

    if self.watchMoneyReasons > numWatchedQuests then self.watchMoneyReasons = self.watchMoneyReasons - numWatchedQuests end
    self:CheckForAutoQuests()
    QuestTrackerLayoutChanged()
end
AFP("tracker_OnEvent", tracker_OnEvent)

local function tracker_OnUpdate()
    local prevState = fNotify.shouldDisplay

    if GW.Libs.GW2Lib:GetPlayerLocationMapID() or GW.Libs.GW2Lib:GetPlayerInstanceMapID() then
        GW.SetObjectiveNotification()
    end

    if prevState ~= fNotify.shouldDisplay then
        GW.NotificationStateChanged(fNotify.shouldDisplay)
    end
end
GW.forceCompassHeaderUpdate = tracker_OnUpdate

local function bonus_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetText(RoundDec(self.progress * 100, 0) .. "%")
    GameTooltip:Show()
end
AFP("bonus_OnEnter", bonus_OnEnter)

local function AdjustItemButtonPositions()
    for i = 1, 25 do
        if _G["GwCampaignBlock" .. i] then
            if i <= fCampaign.numQuests then
                GW.CombatQueue_Queue("update_tracker_campaign_itembutton_position" .. _G["GwCampaignBlock" .. i].index,  _G["GwCampaignBlock" .. i].UpdateQuestItemPositions, {_G["GwCampaignBlock" .. i].actionButton, _G["GwCampaignBlock" .. i].savedHeight})
            else
                GW.CombatQueue_Queue("update_tracker_campaign_itembutton_remove" .. i, _G["GwCampaignBlock" .. i].UpdateQuestItem, {_G["GwCampaignBlock" .. i]})
            end
        end
        if _G["GwQuestBlock" .. i] then
            if i <= fQuest.numQuests then
                GW.CombatQueue_Queue("update_tracker_quest_itembutton_position" .. _G["GwQuestBlock" .. i].index, _G["GwQuestBlock" .. i].UpdateQuestItemPositions, {_G["GwQuestBlock" .. i].actionButton, _G["GwQuestBlock" .. i].savedHeight, "QUEST"})
            else
                GW.CombatQueue_Queue("update_tracker_quest_itembutton_remove" .. i, _G["GwQuestBlock" .. i].UpdateQuestItem, {_G["GwQuestBlock" .. i]})
            end
        end

        if i <= 20 then
            if _G["GwBonusObjectiveBlock" .. i] then
                if fBonus.numEvents <= i then
                    GW.CombatQueue_Queue("update_tracker_bonus_itembutton_position" .. i, _G["GwBonusObjectiveBlock" .. i].UpdateQuestItemPositions, {_G["GwBonusObjectiveBlock" .. i].actionButton, _G["GwBonusObjectiveBlock" .. i].savedHeight, "EVENT"})
                else
                    GW.CombatQueue_Queue("update_tracker_bonus_itembutton_remove" .. i, _G["GwBonusObjectiveBlock" .. i].UpdateQuestItem, {_G["GwBonusObjectiveBlock" .. i]})
                end
            end
        end
    end

    if GwScenarioBlock.hasItem then
        GW.CombatQueue_Queue("update_tracker_scenario_itembutton_position", GwScenarioBlock.UpdateQuestItemPositions, {GwScenarioBlock.actionButton, GwScenarioBlock.height, "SCENARIO"})
    end
end

local function CollapseHeader(self, forceCollapse, forceOpen)
    if (not self.collapsed or forceCollapse) and not forceOpen then
        self.collapsed = true
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    else
        self.collapsed = false
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
    fQuest:UpdateQuestLogLayout()
    QuestTrackerLayoutChanged()
end
GW.CollapseQuestHeader = CollapseHeader

local function LoadQuestTracker()
    -- disable the default tracker
    ObjectiveTrackerFrame:SetMovable(1)
    ObjectiveTrackerFrame:SetUserPlaced(true)
    ObjectiveTrackerFrame:Hide()
    ObjectiveTrackerFrame:SetScript(
        "OnShow",
        function()
            ObjectiveTrackerFrame:Hide()
        end
    )

    --ObjectiveTrackerFrame:UnregisterAllEvents()
    ObjectiveTrackerFrame:SetScript("OnUpdate", nil)
    ObjectiveTrackerFrame:SetScript("OnSizeChanged", nil)
    --ObjectiveTrackerFrame:SetScript("OnEvent", nil)

    -- create our tracker
    fTracker = CreateFrame("Frame", "GwQuestTracker", UIParent, "GwQuestTracker")

    fTraScr = CreateFrame("ScrollFrame", "GwQuestTrackerScroll", fTracker, "GwQuestTrackerScroll")
    fTraScr:SetHeight(GW.settings.QuestTracker_pos_height)
    fTraScr:SetScript(
        "OnMouseWheel",
        function(self, delta)
            delta = -delta * 15
            local s = math.max(0, self:GetVerticalScroll() + delta)
            if self.maxScroll ~= nil then
                s = math.min(self.maxScroll, s)
            end
            self:SetVerticalScroll(s)
        end
    )
    fTraScr.maxScroll = 0

    local fScroll = CreateFrame("Frame", "GwQuestTrackerScrollChild", fTraScr, fTracker)

    fNotify = CreateFrame("Frame", "GwObjectivesNotification", fTracker, "GwObjectivesNotification")
    fNotify.animatingState = false
    fNotify.animating = false
    fNotify.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    fNotify.title:SetShadowOffset(1, -1)
    fNotify.desc:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    fNotify.desc:SetShadowOffset(1, -1)
    fNotify.bonusbar.bar:SetOrientation("VERTICAL")
    fNotify.bonusbar.bar:SetMinMaxValues(0, 1)
    fNotify.bonusbar.bar:SetValue(0.5)
    fNotify.bonusbar:SetScript("OnEnter", bonus_OnEnter)
    fNotify.bonusbar:SetScript("OnLeave", GameTooltip_Hide)
    fNotify.compass:SetScript("OnShow", fNotify.compass.NewQuestAnimation)
    fNotify.compass:SetScript("OnMouseDown", function() C_SuperTrack.SetSuperTrackedQuestID(0) end) -- to rest the SuperTracked quest

    fBoss = CreateFrame("Frame", "GwQuesttrackerContainerBossFrames", fTracker, "GwQuesttrackerContainer")
    fArenaBG = CreateFrame("Frame", "GwQuesttrackerContainerArenaBGFrames", fTracker, "GwQuesttrackerContainer")
    fScen = CreateFrame("Frame", "GwQuesttrackerContainerScenario", fTracker, "GwQuesttrackerContainer")
    fAchv = CreateFrame("Frame", "GwQuesttrackerContainerAchievement", fTracker, "GwQuesttrackerContainer")
    fCampaign = CreateFrame("Frame", "GwQuesttrackerContainerCampaign", fScroll, "GwQuesttrackerContainer")
    fQuest = CreateFrame("Frame", "GwQuesttrackerContainerQuests", fScroll, "GwQuesttrackerContainer")
    fBonus = CreateFrame("Frame", "GwQuesttrackerContainerBonusObjectives", fScroll, "GwQuesttrackerContainer")
    fRecipe = CreateFrame("Frame", "GwQuesttrackerContainerRecipe", fScroll, "GwQuesttrackerContainer")
    fMonthlyActivity = CreateFrame("Frame", "GwQuesttrackerContainerMonthlyActivity", fScroll, "GwQuesttrackerContainer")
    fCollection = CreateFrame("Frame", "GwQuesttrackerContainerCollection", fScroll, "GwQuesttrackerContainer")

    fNotify:SetParent(fTracker)
    fBoss:SetParent(fTracker)
    fArenaBG:SetParent(fTracker)
    fScen:SetParent(fTracker)
    fAchv:SetParent(fScroll)
    fCampaign:SetParent(fScroll)
    fQuest:SetParent(fScroll)
    fBonus:SetParent(fScroll)
    fRecipe:SetParent(fScroll)
    fMonthlyActivity:SetParent(fScroll)
    fCollection:SetParent(fScroll)

    fNotify:SetPoint("TOPRIGHT", fTracker, "TOPRIGHT")
    fBoss:SetPoint("TOPRIGHT", fNotify, "BOTTOMRIGHT")
    fArenaBG:SetPoint("TOPRIGHT", fBoss, "BOTTOMRIGHT")
    fScen:SetPoint("TOPRIGHT", fArenaBG, "BOTTOMRIGHT")

    fTraScr:SetPoint("TOPRIGHT", fScen, "BOTTOMRIGHT")
    fTraScr:SetPoint("BOTTOMRIGHT", fTracker, "BOTTOMRIGHT")

    fScroll:SetPoint("TOPRIGHT", fTraScr, "TOPRIGHT")
    fAchv:SetPoint("TOPRIGHT", fScroll, "TOPRIGHT")
    fCampaign:SetPoint("TOPRIGHT", fAchv, "BOTTOMRIGHT")
    fQuest:SetPoint("TOPRIGHT", fCampaign, "BOTTOMRIGHT")
    fBonus:SetPoint("TOPRIGHT", fQuest, "BOTTOMRIGHT")
    fRecipe:SetPoint("TOPRIGHT", fBonus, "BOTTOMRIGHT")
    fMonthlyActivity:SetPoint("TOPRIGHT", fRecipe, "BOTTOMRIGHT")
    fCollection:SetPoint("TOPRIGHT", fMonthlyActivity, "BOTTOMRIGHT")

    fScroll:SetSize(fTracker:GetWidth(), 2)
    fTraScr:SetScrollChild(fScroll)

    --Mixin
    Mixin(fQuest, GwQuestTrackerContainerMixin)
    Mixin(fAchv, GwAchievementTrackerContainerMixin)

    fQuest:SetScript("OnEvent", tracker_OnEvent)
    fQuest:RegisterEvent("QUEST_LOG_UPDATE")
    fQuest:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
    fQuest:RegisterEvent("QUEST_AUTOCOMPLETE")
    fQuest:RegisterEvent("QUEST_ACCEPTED")
    fQuest:RegisterEvent("PLAYER_MONEY")
    fQuest:RegisterEvent("PLAYER_ENTERING_WORLD")
    fQuest.watchMoneyReasons = 0

    fCampaign.header = CreateFrame("Button", nil, fCampaign, "GwQuestTrackerHeader")
    fCampaign.header.icon:SetTexCoord(0.5, 1, 0, 0.25)
    fCampaign.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    fCampaign.header.title:SetShadowOffset(1, -1)
    fCampaign.header.title:SetText(TRACKER_HEADER_CAMPAIGN_QUESTS)

    fCampaign.collapsed = false
    fCampaign.header:SetScript("OnMouseDown",
        function(self)
            CollapseHeader(self:GetParent(), false, false)
        end
    )
    fCampaign.header.title:SetTextColor(TRACKER_TYPE_COLOR.CAMPAIGN.r, TRACKER_TYPE_COLOR.CAMPAIGN.g, TRACKER_TYPE_COLOR.CAMPAIGN.b)

    fQuest.header = CreateFrame("Button", nil, fQuest, "GwQuestTrackerHeader")
    fQuest.header.icon:SetTexCoord(0, 0.5, 0.25, 0.5)
    fQuest.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    fQuest.header.title:SetShadowOffset(1, -1)
    fQuest.header.title:SetText(TRACKER_HEADER_QUESTS)

    fQuest.collapsed = false
    fQuest.header:SetScript("OnMouseDown",
        function(self)
            CollapseHeader(self:GetParent(), false, false)
        end
    )
    fQuest.header.title:SetTextColor(TRACKER_TYPE_COLOR.QUEST.r, TRACKER_TYPE_COLOR.QUEST.g, TRACKER_TYPE_COLOR.QUEST.b)

    fQuest.init = false

    GW.LoadBossFrame()
    if not C_AddOns.IsAddOnLoaded("sArena") then
        GW.LoadArenaFrame(fArenaBG)
    end
    GW.LoadScenarioFrame(fScen)
    GW.LoadAchievementFrame(fAchv)
    GW.LoadBonusFrame(fBonus)
    GW.LoadRecipeTracking(fRecipe)
    GW.LoadMonthlyActivitiesTracking(fMonthlyActivity)
    GW.LoadCollectionTracking(fCollection)
    GW.LoadWQTAddonSkin()
    GW.LoadPetTrackerAddonSkin()
    GW.LoadTodolooAddonSkin()

    GW.ToggleCollapseObjectivesInChallangeMode()

    fNotify.shouldDisplay = false
    -- only update the tracker on Events or if player moves
    local compassUpdateFrame = CreateFrame("Frame")
    compassUpdateFrame:RegisterEvent("PLAYER_STARTED_MOVING")
    compassUpdateFrame:RegisterEvent("PLAYER_STOPPED_MOVING")
    compassUpdateFrame:RegisterEvent("PLAYER_CONTROL_LOST")
    compassUpdateFrame:RegisterEvent("PLAYER_CONTROL_GAINED")
    compassUpdateFrame:RegisterEvent("QUEST_LOG_UPDATE")
    compassUpdateFrame:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
    compassUpdateFrame:RegisterEvent("PLAYER_MONEY")
    compassUpdateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    compassUpdateFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    compassUpdateFrame:RegisterEvent("QUEST_DATA_LOAD_RESULT")
    compassUpdateFrame:RegisterEvent("SUPER_TRACKING_CHANGED")
    compassUpdateFrame:RegisterEvent("SCENARIO_UPDATE")
    compassUpdateFrame:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
    compassUpdateFrame:SetScript("OnEvent", function(self, event, ...)
        -- Events for start updating
        if IsIn(event, "PLAYER_STARTED_MOVING", "PLAYER_CONTROL_LOST") then
            if self.Ticker then
                self.Ticker:Cancel()
                self.Ticker = nil
            end
            self.Ticker = C_Timer.NewTicker(1, function() tracker_OnUpdate() end)
        elseif IsIn(event, "PLAYER_STOPPED_MOVING", "PLAYER_CONTROL_GAINED") then -- Events for stop updating
            if self.Ticker then
                self.Ticker:Cancel()
                self.Ticker = nil
            end
        elseif event == "QUEST_DATA_LOAD_RESULT" then
            local questID, success = ...
            if success and fNotify.compass.dataIndex and questID == fNotify.compass.dataIndex then
                tracker_OnUpdate()
            end
        else
            C_Timer.After(0.25, function() tracker_OnUpdate() end)
        end
    end)

    -- some hooks to set the itembuttons correct
    local UpdateItemButtonPositionAndAdjustScrollFrame = function()
        GW.Debug("Update Quest Buttons")
        QuestTrackerLayoutChanged()
        AdjustItemButtonPositions()
    end

    fBoss.oldHeight = 1
    fArenaBG.oldHeight = 1
    fScen.oldHeight = 1
    fAchv.oldHeight = 1
    fQuest.oldHeight = 1
    fCampaign.oldHeight = 1

    hooksecurefunc(fBoss, "SetHeight", function(_, height)
        if fBoss.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)
    hooksecurefunc(fArenaBG, "SetHeight", function(_, height)
        if fArenaBG.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)
    hooksecurefunc(fAchv, "SetHeight", function(_, height)
        if fAchv.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)
    hooksecurefunc(fScen, "SetHeight", function(_, height)
        if fScen.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)

    hooksecurefunc(fQuest, "SetHeight", function(_, height)
        if fQuest.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)
    hooksecurefunc(fCampaign, "SetHeight", function(_, height)
        if fCampaign.oldHeight ~= GW.RoundInt(height) then
            C_Timer.After(0.25, function()
                UpdateItemButtonPositionAndAdjustScrollFrame()
            end)
        end
    end)

    fNotify:HookScript("OnShow", function() C_Timer.After(0.25, function() UpdateItemButtonPositionAndAdjustScrollFrame() end) end)
    fNotify:HookScript("OnHide", function() C_Timer.After(0.25, function() UpdateItemButtonPositionAndAdjustScrollFrame() end) end)

    GW.RegisterMovableFrame(fTracker, OBJECTIVES_TRACKER_LABEL, "QuestTracker_pos", ALL, nil, {"scaleable", "height"})
    fTracker:ClearAllPoints()
    fTracker:SetPoint("TOPLEFT", fTracker.gwMover)
    fTracker:SetHeight(GW.settings.QuestTracker_pos_height)

    tracker_OnEvent(fQuest, "LOAD")
end
GW.LoadQuestTracker = LoadQuestTracker
