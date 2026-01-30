local _, GW = ...
local L = GW.L

local Debug = GW.Debug
local AFP = GW.AddProfiling

local model_tweaks = GW.QUESTVIEW_MODEL_TWEAKS
local npc_tweaks = GW.QUESTVIEW_NPC_TWEAKS
local mapBGs = GW.QUESTVIEW_MAP_BGS

local function splitIter(inputstr, pat)
    local st, g = 1, string.gmatch(inputstr, "()(" .. pat .. ")")
    local function getter(segs, seps, sep, cap1, ...)
        st = sep and seps + #sep
        return string.sub(inputstr, segs, seps or -1), cap1 or sep, ...
    end
    return function()
        if st then
            return getter(st, g())
        end
    end
end
AFP("splitIter", splitIter)

local function splitQuest(inputstr)
    local sep = "[\\.|!|?|>]%s+"
    inputstr = inputstr:gsub("\n", " ")
    inputstr = inputstr:gsub(" %s+", " ")
    inputstr = inputstr:gsub("%.%.%.", "…")
    local t = {}
    local i = 1
    for str in splitIter(inputstr, sep) do
        if str ~= nil and str ~= "" then
            t[i] = str
            i = i + 1
        end
    end
    return t
end
AFP("splitQuest", splitQuest)

local QuestGiverMixin = {}
AFP("QuestGiverMixin", QuestGiverMixin)

-- emote IDs used for SetAnimation
local emotes = {
    ["Idle"] = 0,
    ["Dead"] = 6,
    ["Talk"] = 60,
    ["TalkExclamation"] = 64,
    ["TalkQuestion"] = 65,
    ["Bow"] = 66,
    ["Point"] = 84,
    ["Salute"] = 113,
    ["Drowned"] = 132,
    ["Yes"] = 185,
    ["No"] = 186,
    ["Read"] = 520
}
local mid_set = {"Idle", "Talk", "Yes", "No", "Point"}
local end_set = {"Bow", "Salute"}
function QuestGiverMixin:OnAnimFinished()
    if self.anim_next ~= 0 then
        self:SetAnimation(self.anim_next)
        self.anim_next = 0
    else
        self:SetScript("OnAnimFinished", nil)
        self.anim_playing = false
        self:SetAnimation(0)
    end
end

function QuestGiverMixin:setQuestGiverAnimation(count)
    local qView = self:GetParent():GetParent()
    local qString = qView.questString
    local qStringInt = qView.questStringInt
    if qString[qStringInt] == nil then
        return
    end

    if qView.questNPCType ~= 3 then
        -- showing board/non-NPC/dead model, don't need anims
        return
    end

    if qStringInt == 1 or qStringInt >= count then
        self:SetScript("OnAnimFinished", nil)
        self.anim_next = 0
        self.anim_playing = false
    end

    -- determine main emote to play for this line
    local a = emotes["Talk"]
    local s = string.sub(qString[qStringInt], -1)
    if qStringInt >= count then
        a = emotes[end_set[math.random(1, #end_set)]]
    elseif s == "!" then
        a = emotes["TalkExclamation"]
    elseif s == "?" then
        a = emotes["TalkQuestion"]
    end

    -- if playing something, don't interrupt to avoid spastic motions on click-thru
    if self.anim_playing then
        if a == emotes["Talk"] then
            self.anim_next = emotes[mid_set[math.random(1, #mid_set)]]
        else
            self.anim_next = a
        end
    else
        self.anim_playing = true
        if qStringInt < count then
            self.anim_next = emotes[mid_set[math.random(1, #mid_set)]]
        end
        self:SetScript("OnAnimFinished", self.OnAnimFinished)
        self:SetAnimation(a)
    end
end

local function GetCreatureIDFromGUID(guid)
    if GW.IsSecretValue(guid) then return end
    return tonumber(string.match(guid, "Creature%-.-%-.-%-.-%-.-%-(.-)%-"));
end

local MODEL_FACING = 0.5
function QuestGiverMixin:setPMUnit(unit, is_dead, npc_name, npc_type)
    -- reset previous model/unit
    self:ClearModel()
    self:RefreshCamera()

    -- set new model/unit
    local scaleFactor = 1.25 -- can we figure this out programmatically without lookups?
    self:SetUnit(unit)

    local creatureID = GetCreatureIDFromGUID(UnitGUID(unit))
    local fileID = self:GetModelFileID()
    if creatureID and npc_tweaks[creatureID] then
        scaleFactor = npc_tweaks[creatureID]
    elseif fileID and model_tweaks[fileID] then
        scaleFactor = model_tweaks[fileID]
    end

    Debug("NPC:", npc_name, "type:", npc_type, "fileID:", fileID, "creatureID:", creatureID, "is_dead:", is_dead, "sf:", scaleFactor)
    self:InitializeCamera(scaleFactor)

    local offsetX = -110
    local offsetZ = 50
    if scaleFactor < 0.8 then
        -- static tweak for some big models like dragons
        offsetX = 30
        --offsetZ = 0
    elseif scaleFactor > 2.5 then
        -- static tweak for most smaller models
        offsetZ = 100
    end
    self:SetViewTranslation(offsetX, offsetZ)

    if is_dead then
        self:SetAnimation(emotes.Dead)
    end
end

function QuestGiverMixin:setBoardUnit()
    self:ClearModel()
    self:RefreshCamera()
    self:SetModel(1822634)
    self:InitializeCamera(2.0)
    self:SetViewTranslation(-400, 10)
end

function QuestGiverMixin:SetupModel()
    self:SetFacing(-MODEL_FACING)
    self:SetFacingLeft(true)
end

local QuestPlayerMixin = {}
AFP("QuestPlayerMixin", QuestPlayerMixin)

local player_scales = GW.QUESTVIEW_PLAYER_SCALES
function QuestPlayerMixin:SetupModel()
    local _, _, raceID = UnitRace("player")
    local heightScale = player_scales[raceID]
    if not heightScale then
        heightScale = player_scales[0] -- default
    end
    local foot_offset = floor((heightScale - 1.0) * -100)
    local offsetX = -35

    if raceID == 52 or raceID == 70 then
        -- adjust for dracthyr weirdness; proper fix would check visage form
        -- and reset these params based on current form
        foot_offset = foot_offset - 10
        offsetX = -90
    elseif raceID == 10 then
        -- tweak for blood elf
        foot_offset = foot_offset - 15
    elseif raceID == 22 then
        -- tweak for worgen
        -- TODO: would be really nice if we could figure out if we're in worgen
        -- or human form on model refresh and adjust from that
        foot_offset = foot_offset - 15
        offsetX = -55
    elseif raceID == 1 then
        -- tweaks for humans
        foot_offset = foot_offset - 15
        offsetX = -55
    end

    Debug("player frame scale:", heightScale, "foot_offset:", foot_offset)

    self:SetFacing(MODEL_FACING)
    self:SetUnit("player", true, true)
    self:SetCamDistanceScale(heightScale)
    self:SetViewTranslation(offsetX, foot_offset)
end

function QuestPlayerMixin:setPMUnit()
    self:RefreshUnit()
    if not self:GetSheathed() then
        self:SetSheathed(true, false)
    end
end

GwQuestViewFrameMixin = {}
local QuestViewMixin = GwQuestViewFrameMixin

function QuestViewMixin:HideQuestFrame()
    -- cannot actually hide it as we are stealing its elements/events and need it
    -- to remain technially shown for the duration
    if self.blizzFramePoints then
        wipe(self.blizzFramePoints)
    else
        self.blizzFramePoints = {}
    end
    for i = 1, QuestFrame:GetNumPoints() do
        tinsert(self.blizzFramePoints, {QuestFrame:GetPoint(i)})
    end
    QuestFrame:ClearAllPoints()
    QuestFrame:SetClampedToScreen(false)
    QuestFrame:SetPoint("RIGHT", UIParent, "LEFT", -800, 0)
end

function QuestViewMixin:UnhideQuestFrame()
    QuestFrame:ClearAllPoints()
    QuestFrame:SetClampedToScreen(true)
    for _, pt in ipairs(self.blizzFramePoints) do
        QuestFrame:SetPoint(pt[1], pt[2], pt[3], pt[4], pt[5])
    end
end

function QuestViewMixin:showRewards(showObjective)
    local questID = QuestInfoFrame.questLog and C_QuestLog.GetSelectedQuest() or GetQuestID()

    local xp = GetRewardXP()
    local money = GetRewardMoney()
    local title = GetRewardTitle()
    local currency = GW.Retail and C_QuestInfoSystem.GetQuestRewardCurrencies(questID) or {}
    local _, _, skillPoints = GW.Retail and GetRewardSkillPoints() or nil, nil, nil
    local items = GetNumQuestRewards()
    local spells = C_QuestInfoSystem.GetQuestRewardSpells(questID) or {}
    local choices = GetNumQuestChoices()
    local honor = GetRewardHonor()

    local qinfoHeight = 300
    local qinfoTop = -20

    if showObjective then
        self.container.dialog.objectiveText:SetText(GetObjectiveText())
        UIFrameFadeIn(self.container.dialog.objectiveHeader, 0.1, 0, 1)
        UIFrameFadeIn(self.container.dialog.objectiveText, 0.1, 0, 1)
    end

    if (GW.Retail and xp > 0) or money > 0 or title or #currency > 0 or skillPoints or items > 0 or #spells > 0 or choices > 0 or honor > 0 then
        local f = _G.QuestInfoRewardsFrame
        UIFrameFadeIn(f, 0.1, 0, 1)
        f:SetParent(self)
        f:SetHeight(qinfoHeight)
        f:ClearAllPoints()
        f:SetFrameLevel(5)
        if showObjective then
            f:SetPoint("TOPLEFT", self.container.dialog.objectiveText, "BOTTOMLEFT", 0, -15)
        else
            f:SetPoint("CENTER", self, "CENTER", -5, qinfoTop)
        end
    end
end

function QuestViewMixin:questTextCompleted()
    if self.questStateSet then
        return
    end
    if self.questState == "COMPLETE" then
        self:showRewards(false)
        self.container.acceptButton:SetText(COMPLETE_QUEST)
        self.container.acceptButton:Show()
    elseif self.questState == "PROGRESS" then
        if IsQuestCompletable() then
            self.container.acceptButton:SetText(CONTINUE)
            self.questState = "NEEDCOMPLETE"
        else
            local s = self.questString[self.questStringInt] and string.sub(self.questString[self.questStringInt], -1) or ""
            if s == "?" then
                self.container.playerModel:SetAnimation(emotes.No)
            end
            self.container.acceptButton:Hide()
            self.container.declineButton:SetText(CANCEL)
            self.container.declineButton:Show()
        end
    else
        self:showRewards(true)
        self.container.acceptButton:SetText(ACCEPT)
        self.container.acceptButton:Show()
    end
    self.questStateSet = true
end

function QuestViewMixin:nextGossip()
    if self.questState and self.questState == "NEEDCOMPLETE" then
        self.questState = "COMPLETING"
        -- there will be a QUEST_COMPLETE event shortly
        self:clearDialog()
        self.container.dialog.reqItems:ClearInfo()
        self.container.dialog.reqItems:Hide()
        self.container.dialog.objectiveHeader:Hide()
        self.container.dialog.objectiveText:Hide()
        self.container.acceptButton:Hide()
        self.container.declineButton:Hide()
        self.container.playerModel:SetAnimation(emotes.Yes)
        CompleteQuest()
        return
    end
    if self.questStateSet then
        return
    end
    self.questStringInt = self.questStringInt + 1
    local qStringInt = self.questStringInt
    local count = #self.questString

    if (self.container.dialog.reqItems:HasRequiredItems()) then
        self.container.dialog.reqItems:Show()
    else
        self.container.dialog.reqItems:Hide()
    end
    if qStringInt <= count then
        self.container.dialog.text:SetText(self.questString[qStringInt])
        self.container.giverModel:setQuestGiverAnimation(count)
        if qStringInt ~= 1 then
            PlaySound(906)
        end
        if qStringInt == count then
            self:questTextCompleted()
        else
            self.container.acceptButton:SetText(L["Skip"])
            self.container.acceptButton:Show()
        end
    else
        self.questStringInt = count
        self:questTextCompleted()
    end
end

function QuestViewMixin:lastGossip()
    if self.questStringInt == 1 then
        return
    end
    self.questStringInt = max(self.questStringInt - 1, 1)
    local qStringInt = self.questStringInt
    local count = #self.questString

    if qStringInt <= count then
        self.container.dialog.text:SetText(self.questString[qStringInt])
        self.container.giverModel:setQuestGiverAnimation(count)
        if qStringInt ~= 1 then
            PlaySound(906)
        end
        self.container.acceptButton:SetText(L["Skip"])
        self.container.acceptButton:Show()
        QuestInfoRewardsFrame:Hide()
        self.questStateSet = false
        if self.questState ~= "PROGRESS" then
            self.container.dialog.reqItems:Hide()
        end
        self.container.dialog.objectiveHeader:Hide()
        self.container.dialog.objectiveText:Hide()
    else
        self:questTextCompleted()
    end
end

function QuestViewMixin:showQuestFrame()
    local mapId = GW.Libs.GW2Lib:GetPlayerLocationMapID() or C_Map.GetBestMapForUnit("player") or 0 -- as fallback if location service is to slow
    local mapTex
    repeat
        local mapInfo = C_Map.GetMapInfo(mapId)
        if mapInfo then
            Debug("current map", mapInfo.mapID, mapInfo.name, mapInfo.mapType, mapInfo.parentMapID)
            mapTex = mapBGs[mapInfo.mapID] or mapBGs[mapInfo.parentMapID]
            mapId = mapInfo.parentMapID
        end
    until not mapInfo or mapTex or mapInfo.parentMapID == 0
    if not mapTex then
        mapTex = "default"
    end
    self.mapBG:SetTexture("Interface/AddOns/GW2_UI/textures/questview/backgrounds/" .. mapTex)

    self.container.floaty.title:SetText(GetTitleText())
    self:Show()

    self.container.playerModel:setPMUnit()

    local npc_name = GetUnitName("questnpc")
    local npc_type = UnitCreatureType("questnpc")
    self.questNPCType = 0
    local gm = self.container.giverModel
    if UnitIsUnit("questnpc", "player") then
        -- quest giver is the player; typically for auto-accepted quests, story pushes, etc.
        self.questNPCType = 1
        gm:setBoardUnit()
    elseif npc_name and npc_type then
        -- quest giver has a creature type; some kind of entity with a normal model
        if UnitIsDead("questnpc") then
            self.questNPCType = 2
            gm:setPMUnit("questnpc", true, npc_name, npc_type)
        else
            self.questNPCType = 3
            gm:setPMUnit("questnpc", false, npc_name, npc_type)
        end
    elseif npc_name then
        -- quest giver has a name but no type; probably an item or letter; give player a reading anim
        self.questNPCType = 4
        gm:ClearModel()
        gm:RefreshCamera()
        self.container.playerModel:SetAnimation(emotes.Read)
        self.container.playerModel:ApplySpellVisualKit(29521, false)
    end
    PlaySoundFile("Interface/AddOns/GW2_UI/Sounds/dialog_open.ogg", "SFX")
end

function QuestViewMixin:clearDialog()
    if (self.questString) then
        wipe(self.questString)
        wipe(self.questReqText)
    else
        self.questString = {}
        self.questReqText = {}
    end
    self.questStringInt = 0
end

function QuestViewMixin:clearQuestReq()
    self.questState = "NONE"
    self.questStateSet = false
    self.questNPCType = 0
    self:clearDialog()
    self.container.dialog.objectiveHeader:Hide()
    self.container.dialog.objectiveText:Hide()
end

function QuestViewMixin:acceptQuest()
    if self.questState == "TAKE" then
        if (QuestFlagsPVP()) then
            QuestFrame.dialog = StaticPopup_Show("CONFIRM_ACCEPT_PVP_QUEST")
        else
            if (QuestFrame.autoQuest) then
                AcknowledgeAutoAcceptQuest()
            else
                AcceptQuest()
                CloseQuest()
            end
        end
        if self:IsShown() then self:Hide() end
    elseif self.questState == "PROGRESS" then
        CloseQuest()
    else
        if (GetNumQuestChoices() == 0) then
            GetQuestReward(0)
            CloseQuest()
        elseif (GetNumQuestChoices() == 1) then
            GetQuestReward(1)
            CloseQuest()
        else
            if (QuestInfoFrame.itemChoice == 0) then
                QuestChooseRewardError()
            else
                GetQuestReward(QuestInfoFrame.itemChoice)
                CloseQuest()
            end
        end
    end
end

function QuestViewMixin:OnKeyDown(key)
    local inCombat = InCombatLockdown()
    local interact1,interact2 = GetBindingKey("INTERACTTARGET")
    if key == "SPACE" or ((key == interact1 and interact1 ~= nil) or (key == interact2 and interact2 ~= nil)) then
        if not inCombat then
            self:SetPropagateKeyboardInput(false)
        end
        local Stringcount = #self.questString

        if self.questStringInt < Stringcount then
            self:nextGossip()
        else
            if self.questState == "NEEDCOMPLETE" then
                self:nextGossip()
            else
                self:acceptQuest()
            end
        end
    else
        if not inCombat then
            self:SetPropagateKeyboardInput(true)
        end
    end
end

function QuestViewMixin:OnShow()
    UIFrameFadeIn(self, 0.2, 0, 1)
    self.container.declineButton:SetText(IGNORE)
    self.container.declineButton:SetShown(not QuestFrame.autoQuest)
    self:EnableKeyboard(true)
    self:SetScript("OnKeyDown", self.OnKeyDown)
end

function QuestViewMixin:OnHide()
    self:EnableKeyboard(false)
    self:SetScript("OnKeyDown", nil)
    self:UnhideQuestFrame()
end

function QuestViewMixin:evQuestProgress()
    self:HideQuestFrame()
    self:clearQuestReq()

    self.container.dialog.reqItems:UpdateInfo()
    if (self.container.dialog.reqItems:HasRequiredItems()) then
        self.questReqText = splitQuest(GetProgressText())
        self.container.dialog.reqItems:UpdateFrame()
    end
    self:showQuestFrame()
    self.questString = splitQuest(GetProgressText())
    self.questState = "PROGRESS"
    self:nextGossip()
end

function QuestViewMixin:evQuestDetail(questStartItemID)
    if (questStartItemID ~= nil and questStartItemID ~= 0) or (GW.Retail and QuestGetAutoAccept() and QuestIsFromAreaTrigger()) then
        if GW.settings.QUESTTRACKER_ENABLED and not GW.ShouldBlockIncompatibleAddon("Objectives") then
            AcknowledgeAutoAcceptQuest()
        end
        return
    end
    if (self.questState ~= "COMPLETING") then
        self:HideQuestFrame()
        self:clearQuestReq()
        self.container.dialog.reqItems:ClearInfo()
        self.container.dialog.reqItems:Hide()
        self.questState = "TAKE"
    else
        self.questStringInt = 0
        self.questStateSet = false
    end
    self:showQuestFrame()
    self.questString = splitQuest(GetQuestText())
    if self.questState ~= "COMPLETING" then
        tinsert(self.questString, "")
    end
    self:nextGossip()
end

function QuestViewMixin:evQuestComplete()
    if (self.questState ~= "COMPLETING") then
        self:HideQuestFrame()
        self:clearQuestReq()
        self.container.dialog.reqItems:ClearInfo()
        self.container.dialog.reqItems:Hide()
    else
        self.container.declineButton:SetText(IGNORE)
        self.container.declineButton:SetShown(not QuestFrame.autoQuest)
        self.questStringInt = 0
        self.questStateSet = false
    end
    if not self:IsShown() then
        self:showQuestFrame()
    end
    self.questString = splitQuest(GetRewardText())
    local qText = self.questReqText
    if (#qText > 0) then
        for i = #qText, 1, -1 do
            tinsert(self.questString, 1, qText[i])
        end
    end
    self.questState = "COMPLETE"
    self:nextGossip()
end

function QuestViewMixin:evQuestFinished()
    QuestInfoRewardsFrame:Hide()
    self:clearQuestReq()
    self.container.dialog.reqItems:ClearInfo()
    self.container.dialog.reqItems:Hide()
    self:Hide()
    if (self.questState ~= "PROGRESS") then
        PlaySoundFile("Interface/AddOns/GW2_UI/Sounds/dialog_close.ogg", "SFX")
    end
end

function QuestViewMixin:OnEvent(event, ...)
    if event == "QUEST_PROGRESS" then
        self:evQuestProgress()
    elseif event == "QUEST_DETAIL" then
        self:evQuestDetail(...)
    elseif event == "QUEST_COMPLETE" then
        self:evQuestComplete()
    elseif event == "QUEST_FINISHED" then
        self:evQuestFinished()
    end
end

local function dialog_OnMouseUp(self, button, isInside)
    if not isInside or not (button == "LeftButton" or button == "RightButton") then
        return
    end
    local qview = self:GetParent():GetParent()
    if button == "RightButton" then
        qview:lastGossip()
    else
        qview:nextGossip()
    end
end
AFP("dialog_OnMouseUp", dialog_OnMouseUp)

local function decline_OnClick()
    CloseQuest()
end
AFP("decline_OnClick", decline_OnClick)

local function accept_OnClick(self)
    local qview = self:GetParent():GetParent()
    local Stringcount = #qview.questString

    if qview.questStringInt < Stringcount then
        qview.questStringInt = Stringcount - 1
        qview:nextGossip()
    else
        if qview.questState == "NEEDCOMPLETE" then
            qview:nextGossip()
        else
            qview:acceptQuest()
        end
    end
end
AFP("accept_OnClick", accept_OnClick)

function QuestViewMixin:OnLoad()
    Mixin(self.container.playerModel, QuestPlayerMixin)
    Mixin(self.container.giverModel, QuestGiverMixin)

    self.container.playerModel:SetupModel()
    self.container.giverModel:SetupModel()

    self.container.floaty.title:SetTextColor(255 / 255, 197 / 255, 39 / 255)
    self.container.floaty.title:SetFont(DAMAGE_TEXT_FONT, 24)
    self.container.dialog.text:SetFont(STANDARD_TEXT_FONT, 14)
    self.container.dialog.text:SetTextColor(1, 1, 1)
    self.container.dialog.objectiveHeader:SetTextColor(1, 1, 1)
    self.container.dialog.objectiveHeader:SetShadowColor(0, 0, 0, 1)
    self.container.dialog.objectiveHeader:SetText(QUEST_OBJECTIVES)
    self.container.dialog.objectiveText:SetTextColor(1, 1, 1)

    self:SetScript("OnShow", self.OnShow)
    self:SetScript("OnHide", self.OnHide)
    self:SetScript("OnEvent", self.OnEvent)

    self:RegisterEvent("QUEST_DETAIL")
    self:RegisterEvent("QUEST_FINISHED")
    self:RegisterEvent("QUEST_COMPLETE")
    self:RegisterEvent("QUEST_PROGRESS")

    self.container.dialog:SetScript("OnMouseUp", dialog_OnMouseUp)
    self.container.declineButton:SetScript("OnClick", decline_OnClick)
    self.container.acceptButton:SetScript("OnClick", accept_OnClick)

    self:clearQuestReq()
    self:SetMovable(true)
    self:SetClampedToScreen(true)
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", self.StartMoving)
    self:SetScript("OnDragStop", self.StopMovingOrSizing)

    -- handle styling the rewards in a consistent way across options
    if not GW.QuestInfo_Display_hooked then
        hooksecurefunc("QuestInfo_Display", GW.QuestInfo_Display)
        GW.QuestInfo_Display_hooked = true
    end
end

local function LoadQuestview()
    CreateFrame("Frame", "GwQuestviewFrame", UIParent, "GwQuestviewFrameTemplate")
end
GW.LoadQuestview = LoadQuestview
