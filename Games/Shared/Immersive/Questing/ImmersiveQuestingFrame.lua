---@class GW2
local GW = select(2, ...)
local mapBGs = GW.immersiveQuesting.mapBackgrounds
local instanceBGs = GW.immersiveQuesting.instanceBackgrounds
local object_types = GW.immersiveQuesting.objectTypes

GwImmersiveQuestFrameMixin = {}

function GwImmersiveQuestFrameMixin:UiScaleChanged()
    local sf = GW.settings.immersiveQuesting.scale
    self:SetScale(UIParent:GetScale() * sf)
    self.container.playerModel:SetupModel()
    self.container.giverModel:SetupModel()
    if self:IsShown() then
        -- reload internal stuff
        self:showQuestFrame()
    end
    self.defer_ui_change = false
end

local function updateMap(self)
    self.mapId = C_Map.GetBestMapForUnit("player")
    if not self.mapId and self.update_map_attempt < 6 then
        self.update_map_attempt = self.update_map_attempt + 1
        C_Timer.After(0.5, function() updateMap(self) end)
    else
        self.update_map_attempt = 0
        self.update_map_mutex = false
    end
end

function GwImmersiveQuestFrameMixin:UpdateMapId()
    if self.update_map_mutex then
        return
    end
    self.update_map_mutex = true
    updateMap(self)
end

local pat_sep = "[\\.|!|?|\n]%s+"
local pat_uwu = "^<[^>]*>"
local function splitQuest(inputstr)
    local t = {}
    local i = 1

    -- cleanup and normalize the quest text
    inputstr = inputstr:gsub("%|n", "\n") -- normalize escape sequence to LF
    inputstr = inputstr:gsub("[\r\n]+", "\n") -- normalize to LF and collapse multi-line gaps
    inputstr = inputstr:gsub("^%s+", "") -- left trim whitespace
    inputstr = inputstr:gsub("%s+$", "") -- right trim whitespace
    inputstr = inputstr:gsub(" %s+", " ") -- collapse multi-space gaps to a single space
    inputstr = inputstr:gsub("%.%.%.", "…") -- normalize elipsis
    inputstr = inputstr:gsub("%-%-", "—") -- normalize emdash
    inputstr = inputstr:gsub("(%S)—(%S)", "%1 — %2") -- as above
    inputstr = inputstr:gsub(" Co%.", " Co;,;") -- change abbrev period into a pattern we fix back later
    inputstr = inputstr:gsub(" Mk%.", " Mk;,;")

    -- split a string by separators, clean up, and add uwu caps if needed
    local sepString = function(text, uwuflag)
        local sep_s, _ = text:find(pat_sep)
        local uwucap = uwuflag and "<" or ""
        local uwuend = uwuflag and ">" or ""
        if sep_s then
            t[i] = uwucap .. text:sub(1, sep_s):gsub("%s+$", ""):gsub(";,;", ".") .. uwuend
            i = i + 1
            text = text:sub(sep_s + 1):gsub("^%s+", "")
        else
            t[i] = uwucap .. text:gsub("%s+$", ""):gsub(";,;", ".") .. uwuend
            i = i + 1
            text = ""
        end
        return text
    end

    -- check for uwus and recursively split those
    while inputstr ~= "" do
        local uwu_s, uwu_e = inputstr:find(pat_uwu)
        if uwu_s then
            local uwustr = inputstr:sub(uwu_s + 1, uwu_e - 1)
            while uwustr ~= "" do
                uwustr = sepString(uwustr, true)
            end
            inputstr = inputstr:sub(uwu_e + 1):gsub("^%s+", "")
        else
            inputstr = sepString(inputstr)
        end
    end

    return t
end

function GwImmersiveQuestFrameMixin:questTextCompleted()
    if not self.container.summary:IsShown() and not self.container.summary:IsEmpty() then
        UIFrameFadeIn(self.container.summary, 0.1, 0, 1)
    end
    if self.questState == "COMPLETE" then
        self.container.acceptButton:SetText(COMPLETE_QUEST)
        self.container.acceptButton:Show()
    elseif self.questState == "PROGRESS" then
        if self.quest_can_turnin then
            self.container.acceptButton:SetText(CONTINUE)
            self.container.acceptButton:Show()
        else
            local s = string.sub(self.questString[self.questStringInt], -1)
            if s == "?" then
                self.container.playerModel:SetAction("no")
            end
            self.container.acceptButton:Hide()
        end
    else
        self.container.acceptButton:SetText(ACCEPT)
        self.container.acceptButton:Show()
    end
end

local MAX_TEXT_WIDTH = 750
function GwImmersiveQuestFrameMixin:setBalancedText(text)
    local t = self.container.dialog.text
    t:SetWidth(MAX_TEXT_WIDTH)
    t:SetText(text)
    local needed = t:GetStringWidth()
    if needed > (2 * MAX_TEXT_WIDTH) then
        local balanced = math.floor(needed / 3) + 50
        if balanced < MAX_TEXT_WIDTH then
            t:SetWidth(balanced)
        end
    elseif needed > MAX_TEXT_WIDTH then
        local balanced = math.floor(needed / 2) + 50
        if balanced < MAX_TEXT_WIDTH then
            t:SetWidth(balanced)
        end
    end
end

function GwImmersiveQuestFrameMixin:nextGossip()
    self.questStringInt = self.questStringInt + 1
    local qStringInt = self.questStringInt
    local count = #self.questString

    if qStringInt <= count then
        self:setBalancedText(self.questString[qStringInt])
        self.container.giverModel:setQuestGiverAnimation(count, self.questString, qStringInt)
        if qStringInt ~= 1 then
            PlaySound(906)
        end
        if qStringInt == count then
            self:questTextCompleted()
        else
            self.container.acceptButton:SetText(GW.L["Skip to End"])
            self.container.acceptButton:Show()
        end
    else
        self.questStringInt = count
        self:questTextCompleted()
    end
end

function GwImmersiveQuestFrameMixin:prevGossip()
    if self.questStringInt == 1 then
        return
    end
    self.questStringInt = max(self.questStringInt - 1, 1)
    local qStringInt = self.questStringInt
    local count = #self.questString

    if qStringInt <= count then
        self:setBalancedText(self.questString[qStringInt])
        self.container.giverModel:setQuestGiverAnimation(count, self.questString, qStringInt)
        if qStringInt ~= 1 then
            PlaySound(906)
        end
        self.container.acceptButton:SetText(GW.L["Skip to End"])
        self.container.acceptButton:Show()
        if self.questState ~= "PROGRESS" then
            self.container.summary:Hide()
        end
    else
        self:questTextCompleted()
    end
end

function GwImmersiveQuestFrameMixin:HideBlizzQuestFrame()
    -- cannot actually hide it as we are stealing its elements/events and need it
    -- to remain technically shown for the duration
    QuestFrame:SetAlpha(0.0)
end

function GwImmersiveQuestFrameMixin:UnhideBlizzQuestFrame()
    QuestFrame:SetAlpha(1.0)
end

local default_map = "Misc/default"
local function getMapBackground(self)
    local map_id = self.mapID or C_Map.GetBestMapForUnit("player") or 0
    if map_id == 0 then
        GW.Debug("map - no id:", map_id)
        return default_map
    end
    local map_bg
    repeat
        local map = C_Map.GetMapInfo(map_id)
        if map then
            GW.Debug("map - id:", map.mapID, "| name:", map.name, "| type:", map.mapType, "| parent:", map.parentMapID)
            if map.mapType == Enum.UIMapType.Dungeon or map.mapType == Enum.UIMapType.Orphan then
                local _, _, _, _, _, _, _, instanceID, _ = GetInstanceInfo()
                GW.Debug("map - instance id:", instanceID)
                map_bg = instanceBGs[instanceID]
            end
            if not map_bg then
                map_bg = mapBGs[map.mapID] or mapBGs[map.parentMapID]
            end
            map_id = map.parentMapID
        end
    until not map or map_bg or map.parentMapID == 0
    return map_bg or default_map
end

function GwImmersiveQuestFrameMixin:showQuestFrame()
    local map_bg = getMapBackground(self)
    self.container.mapBG:SetTexture("Interface/AddOns/GW2_UI/textures/questview/backgrounds/" .. map_bg .. ".jpg")

    self.container.floaty.title:SetText(GetTitleText())

    local npc_name = GetUnitName("questnpc")
    local is_self = UnitIsUnit("questnpc", "player")
    local is_dead = UnitIsDead("questnpc")

    local PC_kit = self.recent_player_choice and PlayerChoiceFrame and PlayerChoiceFrame.uiTextureKit
    GW.Debug("quest giver - name:", npc_name, "| self:", is_self, "| dead:", is_dead, "| PC_kit:", PC_kit)

    self:Show()

    local pm = self.container.playerModel
    local gm = self.container.giverModel
    if GW.Retail and is_self and PC_kit then
        -- a recent player choice popup was made, use the relevant kit/board
        gm:SetBoardUnit(PC_kit, self.mapId)
    elseif is_self then
        -- typical for auto-accepted quests, story pushes, etc.; have the player read a scroll
        pm:SetAction("read")
    elseif is_dead then
        -- quest giver is a dead NPC; have the player kneel
        pm:SetAction("kneel")
    else
        -- attempt to set the questnpc unit, check for success
        local did_set_unit = gm:SetQuestUnit()
        GW.Debug("attempted set unit:", did_set_unit)
        if not did_set_unit then
            -- could not set the model automatically, try to figure out some common cases
            -- (TODO: some of these use English localized names, which only works for English clients)
            if GW.NotSecretValue(npc_name) then
                if npc_name == "Warchief's Command Board" then
                    gm:SetBoardUnit("horde")
                elseif npc_name == "Hero's Call Board" then
                    gm:SetBoardUnit("alliance")
                elseif object_types[npc_name] then
                    gm:SetModelUnit(object_types[npc_name])
                else
                    -- if we can't figure out a better option, have the player read a scroll
                    pm:SetAction("read")
                end
            else
                pm:SetAction("read")
            end
        end
    end
end

function GwImmersiveQuestFrameMixin:clearDialog()
    if (self.questString) then
        wipe(self.questString)
        wipe(self.questReqText)
    else
        self.questString = {}
        self.questReqText = {}
    end
    self.questStringInt = 0
end

function GwImmersiveQuestFrameMixin:clearQuestReq()
    self.questState = "NONE"
    self.was_showing = false
    self.quest_id = nil
    self.quest_idx = nil
    self.quest_can_turnin = false
    self.update_map_attempt = 0
    self.update_map_mutex = false
    self:clearDialog()
    self.container.summary:ClearInfo()
    self.container.summary:Hide()
    self.container.acceptButton:SetText(CONTINUE)
    self.container.acceptButton:Hide()
    self.container.cancelButton:SetText(CANCEL)
    self.container.cancelButton:Hide()
end

function GwImmersiveQuestFrameMixin:OnShow()
    if _G.GwImmersiveQuestDebugFrame then
        _G.GwImmersiveQuestDebugFrame:Show()
    end
    self:EnableKeyboard(true)
    self:SetScript("OnKeyDown", self.OnKeyDown)
    if self.was_showing then
        -- this was just a temporary hide from the load/cinematic handler, don't setup
        return
    end
    self.container.FadeIn:Play()
end

function GwImmersiveQuestFrameMixin:OnHide()
    if _G.GwImmersiveQuestDebugFrame then
        _G.GwImmersiveQuestDebugFrame:Hide()
    end
    self:EnableKeyboard(false)
    self:SetScript("OnKeyDown", nil)
    if self.was_showing then
        -- this is just a temporary hide from the load/cinematic handler, don't clean up
        return
    end
    self.container.summary:ReleaseRewards()
    self:UnhideBlizzQuestFrame()
end

local function getQuestIndex(quest_id)
    if C_QuestLog.GetLogIndexForQuestID then
        return C_QuestLog.GetLogIndexForQuestID(quest_id)
    else
        return GetQuestLogIndexByID(quest_id)
    end
end

local function deferShow(self)
    if self.in_cine or self.in_load then
        -- defer actually opening this frame until after load/cinematic finishes
        self.needs_showing = true
    else
        self.needs_showing = false
        if not self:IsShown() then
            self:showQuestFrame()
        end
        self:nextGossip()
    end
end

function GwImmersiveQuestFrameMixin:evQuestProgress()
    self:HideBlizzQuestFrame()
    self:clearQuestReq()

    self.questState = "PROGRESS"
    self.quest_id = GetQuestID()
    self.quest_idx = getQuestIndex(self.quest_id)
    self.quest_can_turnin = IsQuestCompletable()
    GW.Debug("progress - questID:", self.quest_id, "| index:", self.quest_idx)
    if self.quest_idx then
        local _, objective_text = GetQuestLogQuestText(self.quest_idx)
        self.container.summary:SetObjectiveText(objective_text)
    end
    self.container.summary:UpdateInfo(self.quest_id, self.quest_idx, self.questState)
    self.questString = splitQuest(GetProgressText())
    self.container.cancelButton:SetShown(not QuestFrame.autoQuest)
    self.container.cancelButton:SetText(CANCEL)

    UIFrameFadeIn(self.container.summary, 0.1, 0, 1)
    deferShow(self)
end

function GwImmersiveQuestFrameMixin:evQuestDetail(questStartItemID)
    if not QuestFrame:IsShown() then
        return
    end
    if self.questState ~= "COMPLETING" then
        self:HideBlizzQuestFrame()
        self:clearQuestReq()
        self.questState = "OFFER"
        self.container.cancelButton:SetText(DECLINE)
    else
        self.questStringInt = 0
        self.container.cancelButton:SetText(CANCEL)
    end
    self.container.cancelButton:SetShown(not QuestFrame.autoQuest)
    self.quest_id = GetQuestID()
    self.quest_idx = getQuestIndex(self.quest_id)
    GW.Debug("detail - questID:", self.quest_id, "| index:", self.quest_idx, "| auto:", QuestFrame.autoQuest)
    self.container.summary:SetObjectiveText(GetObjectiveText())
    self.container.summary:UpdateInfo(self.quest_id, self.quest_idx, self.questState)
    self.questString = splitQuest(GetQuestText())
    if self.questState ~= "COMPLETING" and not self.container.summary:IsEmpty() then
        tinsert(self.questString, "")
    end
    deferShow(self)
end

function GwImmersiveQuestFrameMixin:evQuestComplete()
    if (self.questState ~= "COMPLETING") then
        self:HideBlizzQuestFrame()
        self:clearQuestReq()
    else
        self.questStringInt = 0
    end
    self.container.cancelButton:SetText(CANCEL)
    self.container.cancelButton:SetShown(not QuestFrame.autoQuest)
    self.questState = "COMPLETE"
    self.quest_id = GetQuestID()
    self.quest_idx = getQuestIndex(self.quest_id)
    GW.Debug("complete - questID:", self.quest_id, "| index:", self.quest_idx, "| auto:", QuestFrame.autoQuest)
    self.container.summary:ClearInfo()
    self.container.summary:UpdateInfo(self.quest_id, self.quest_idx, self.questState)
    self.questString = splitQuest(GetRewardText())
    local qText = self.questReqText
    if (#qText > 0) then
        for i = #qText, 1, -1 do
            tinsert(self.questString, 1, qText[i])
        end
    end
    deferShow(self)
end

function GwImmersiveQuestFrameMixin:evQuestFinished()
    if self.questState ~= "COMPLETING" then
        self:clearQuestReq()
        self:Hide()
    end
    -- else, we expect a QUEST_COMPLETE event to follow shortly
end

local function acceptQuest(self)
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
    if self:IsShown() then
        self:Hide()
    end
end

local function turnInQuest(self)
    self.questState = "COMPLETING"
    self:clearDialog()
    self.container.summary:ClearInfo()
    self.container.summary:Hide()
    self.container.acceptButton:Hide()
    self.container.cancelButton:Hide()
    self.container.playerModel:SetAction("yes")
    CompleteQuest()
end

local function completeQuest(self)
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

local function advance(self, is_click, skip_to_end)
    local count = #self.questString
    local click_accept = GW.settings.immersiveQuesting.clickAccept
    if self.questStringInt < count then
        if skip_to_end then
            self.questStringInt = count - 1
        end
        self:nextGossip()
    else
        if self.questState == "PROGRESS" then
            if self.quest_can_turnin then
                turnInQuest(self)
            end
        elseif self.questState == "OFFER" then
            if not is_click or click_accept then
                acceptQuest(self)
            end
        elseif self.questState == "COMPLETE" then
            if not is_click or click_accept then
                completeQuest(self)
            end
        end
    end
end

function GwImmersiveQuestFrameMixin:OnKeyDown(key)
    local inCombat = InCombatLockdown()
    local interact1, interact2 = GetBindingKey("INTERACTTARGET")
    if key == "SPACE" or ((key == interact1 and interact1 ~= nil) or (key == interact2 and interact2 ~= nil)) then
        if not inCombat then
            self:SetPropagateKeyboardInput(false)
        end
        advance(self)
    elseif key == "BACKSPACE" then
        if not inCombat then
            self:SetPropagateKeyboardInput(false)
        end
        self:prevGossip()
    else
        if not inCombat then
            self:SetPropagateKeyboardInput(true)
        end
    end
end

local function dialog_OnMouseUp(self, button, isInside)
    if not isInside or (button ~= "LeftButton" and button ~= "RightButton") then
        return
    end
    local qview = self:GetParent():GetParent()
    if button == "RightButton" then
        qview:prevGossip()
    else
        advance(qview, true)
    end
end

local function accept_OnClick(self)
    local qview = self:GetParent():GetParent()
    advance(qview, false, true)
end

local function cancel_OnClick()
    CloseQuest()
end

local function deferredHide(self)
    if self:IsShown() then
        self.was_showing = true
        self:Hide()
    else
        self.was_showing = false
    end
end

local function deferredShow(self)
    if self.in_cine or self.in_load then
        return
    end
    if self.was_showing then
        self:Show()
        C_Timer.After(0, function() self.was_showing = false end)
    elseif self.needs_showing then
        self.needs_showing = false
        self:HideBlizzQuestFrame()
        -- usually this path happens because a cinematic finished
        -- whatever re-shows the UI is probably doing a timed fadein
        -- so we need to re-hide the quest window again just in case
        C_Timer.After(0.11, function() self:HideBlizzQuestFrame() end)
        self:showQuestFrame()
        self:nextGossip()
    end
end

function GwImmersiveQuestFrameMixin:OnEvent(event, ...)
    GW.Debug("event handling", event, ...)
    if event == "ADDON_LOADED" then
        self:evAddonLoaded(...)
    elseif event == "UI_SCALE_CHANGED" then
        if not self.defer_ui_change then
            -- pause one frame for cvars but don't queue multiple of these
            self.defer_ui_change = true
            C_Timer.After(0, function() self:UiScaleChanged() end)
        end
    elseif event == "LOADING_SCREEN_ENABLED" then
        self.in_load = true
        deferredHide(self)
    elseif event == "LOADING_SCREEN_DISABLED" then
        self.in_load = false
        self:UpdateMapId()
        deferredShow(self)
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
        self:UpdateMapId()
    elseif event == "QUEST_PROGRESS" then
        self:evQuestProgress()
    elseif event == "QUEST_DETAIL" then
        self:evQuestDetail(...)
    elseif event == "QUEST_COMPLETE" then
        self:evQuestComplete()
    elseif event == "QUEST_FINISHED" then
        self:evQuestFinished()
    elseif event == "CINEMATIC_START" then
        local is_real = select(1, ...)
        if is_real then
            self.in_cine = true
            deferredHide(self)
        end
    elseif event == "CINEMATIC_STOP" then
        self.in_cine = false
        deferredShow(self)
    elseif event == "PLAYER_CHOICE_CLOSE" then
        self.recent_player_choice = true
        C_Timer.After(2, function () self.recent_player_choice = false end)
    end
end

function GwImmersiveQuestFrameMixin:applyLockFrame()
    local lf = GW.settings.immersiveQuesting.lockFrame
    if not lf then
        self:RegisterForDrag("LeftButton")
        self:SetScript("OnDragStart", self.StartMoving)
        self:SetScript("OnDragStop", self.StopMovingOrSizing)
    else
        self:SetScript("OnDragStart", nil)
        self:SetScript("OnDragStop", nil)
        self:RegisterForDrag()
    end
end

function GwImmersiveQuestFrameMixin:applyTitleStyle()
    local style = GW.settings.immersiveQuesting.titleStyle
    if style == "THIN" then
        self.container.blackout_head:SetHeight(48)
        self.container.blackout_head:SetAlpha(1.0)
        self.container.blackout_fade:Show()
        self.container.floaty.title:SetHeight(48)
    elseif style == "TRANSPARENT" then
        self.container.blackout_head:SetHeight(80)
        self.container.blackout_head:SetAlpha(0.0)
        self.container.blackout_fade:Hide()
        self.container.floaty.title:SetHeight(80)
    else
        self.container.blackout_head:SetHeight(96)
        self.container.blackout_head:SetAlpha(1.0)
        self.container.blackout_fade:Show()
        self.container.floaty.title:SetHeight(96)
    end
end

function GW.LoadImmersiveQuesting()
    if not GW.settings.immersiveQuesting.enabled or GW.ShouldBlockIncompatibleAddon("ImmersiveQuesting") then return end

    local frame = CreateFrame("Frame", "GwImmersiveQuestFrame", nil, "GwImmersiveQuestFrameTemplate")
    frame.mapId = 0
    frame.updateAttempts = 0

    frame.border:SetTextureSliceMargins(32, 32, 32, 32)
    frame.border:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    frame.container.floaty.inset:SetTextureSliceMargins(64, 64, 64, 64)
    frame.container.floaty.inset:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)

    frame:UiScaleChanged()
    frame:applyLockFrame()
    frame:applyTitleStyle()

    frame:SetScript("OnShow", frame.OnShow)
    frame:SetScript("OnHide", frame.OnHide)
    frame:SetScript("OnEvent", frame.OnEvent)

    frame:RegisterEvent("UI_SCALE_CHANGED")
    frame:RegisterEvent("LOADING_SCREEN_DISABLED")
    frame:RegisterEvent("LOADING_SCREEN_ENABLED")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    frame:RegisterEvent("ZONE_CHANGED")
    frame:RegisterEvent("ZONE_CHANGED_INDOORS")
    frame:RegisterEvent("QUEST_DETAIL")
    frame:RegisterEvent("QUEST_FINISHED")
    frame:RegisterEvent("QUEST_COMPLETE")
    frame:RegisterEvent("QUEST_PROGRESS")
    frame:RegisterEvent("CINEMATIC_START")
    frame:RegisterEvent("CINEMATIC_STOP")
    if GW.Retail then
        frame:RegisterEvent("PLAYER_CHOICE_CLOSE")
        frame:RegisterEvent("PLAYER_CHOICE_UPDATE")
    end

    frame.container.dialog:SetScript("OnMouseUp", dialog_OnMouseUp)
    frame.container.cancelButton:SetScript("OnClick", cancel_OnClick)
    frame.container.acceptButton:SetScript("OnClick", accept_OnClick)

    frame:clearQuestReq()
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame.container.playerModel:OnLoad()

    --GW.LoadImmersiveQuestionDebugFrame()
end
