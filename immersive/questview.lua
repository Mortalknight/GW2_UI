local _, GW = ...
local L = GW.L

local HandleReward = GW.HandleReward
local Debug = GW.Debug
local AFP = GW.AddProfiling

local model_tweaks = GW.QUESTVIEW_MODEL_TWEAKS
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
    ["No"] = 186
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

local QuestModelMixin = {}
AFP("QuestModelMixin", QuestModelMixin)

function QuestModelMixin:setPMUnit(unit, side, is_dead, crace, cgender)
    local uX, uY, uZ, uF = -1.25, -0.65, -0.2, 0.7 -- fac 0.7
    if side > 0 then
        uY = -uY
        uF = -uF
    end

    -- Reset camera each time because it can bug out when the frame is hidden
    self:ClearModel()
    self:SetUnit("none")

    -- SetUnit does magical camera work to get things in frame so set facing & position first
    self:SetFacing(uF)
    self:SetPosition(uX, uY, uZ)
    self:SetUnit(unit)
    if crace then
        self:SetCustomRace(crace, cgender)
    end

    -- Check the auto camera alignment, adjust if needed; larger units tend to be placed
    -- too high and too inward and smaller units vice-versa; this is hacky normalization
    -- but is much more light-weight than analyzing model paths/categories
    local cpos = {self:GetCameraPosition()}
    local ctar = {self:GetCameraTarget()}
    local fileid = self:GetModelFileID()

    if not fileid or not cpos or not ctar or not cpos[1] or not cpos[3] or not ctar[1] or not ctar[3] then
        return
    end

    local zdiff = (cpos[3] / ctar[3]) ^ 4 / (cpos[1] - ctar[1])
    local ydiff = (cpos[1] - ctar[1])
    local dirty = 0

    if zdiff > 0.6 then
        local adj = 0.04 * zdiff ^ 2
        if adj > 1 then
            adj = 1
        end
        uZ = uZ - adj
        dirty = 1
    elseif zdiff < 0.4 then
        local adj = 0.02 / zdiff ^ 1.5
        if adj > 1 then
            adj = 1
        end
        uZ = uZ + adj
        dirty = 1
    end
    if ydiff < 1.4 then
        local adj = 0.15 * ydiff / 1.4
        if adj > 1 then
            adj = 1
        end
        if side > 0 then
            uY = uY - adj
        else
            uY = uY + adj
        end
        dirty = 1
    elseif ydiff > 2 then
        local adj = 0.15 * ydiff / 2
        if adj > 1 then
            adj = 1
        end
        if side > 0 then
            uY = uY + adj
        else
            uY = uY - adj
        end
        dirty = 1
    end
    if is_dead then
        uZ = uZ + 0.3
        dirty = 1
    end

    local twk = model_tweaks[fileid]
    if twk then
        if twk.x then
            uX = twk.x
            dirty = 1
        end
        if twk.y then
            uY = twk.y
            dirty = 1
        end
        if twk.z then
            uZ = twk.z
            dirty = 1
        end
        if twk.f then
            uF = twk.f
            if side > 0 then
                uF = -uF
            end
            dirty = 1
        end
    end

    if dirty then
        self:SetPosition(uX, uY, uZ)
        self:SetFacing(uF)
        Debug("set pos:", unit, "id:", fileid, "x:", uX, "y:", uY, "z:", uZ, "f:", uF, "is_dead:", is_dead)
        self:SetUnit(unit)
        if crace then
            self:SetCustomRace(crace, cgender)
        end
    end
    if is_dead then
        self:SetAnimation(emotes.Dead)
    end
end

local QuestViewMixin = {}
AFP("QuestViewMixin", QuestViewMixin)

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

function QuestViewMixin:showRequired()
    local qReq = self.questReq
    if (not (qReq["money"] > 0 or #qReq["currency"] > 0 or #qReq["stuff"] > 0)) then
        return
    end
    UIFrameFadeIn(self.container.dialog.required, 0.1, 0, 1)

    if qReq["money"] > 0 then
        local f = self.container.dialog.reqMoney
        MoneyFrame_Update(f, qReq["money"])
        UIFrameFadeIn(f, 0.1, 0, 1)
        self.container.dialog.reqItem1:ClearAllPoints()
        self.container.dialog.reqItem1:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, -5)
    else
        self.container.dialog.reqItem1:ClearAllPoints()
        self.container.dialog.reqItem1:SetPoint("TOPLEFT", self.container.dialog.required, "BOTTOMLEFT", 5, -10)
    end

    for i = 1, #qReq["stuff"], 1 do
        local f = self.container.dialog["reqItem" .. i]
        f.type = "required"
        f.objectType = "item"
        f:SetID(i)
        local name = qReq["stuff"][i][1]
        local texture = qReq["stuff"][i][2]
        local numItems = qReq["stuff"][i][3]
        SetItemButtonCount(f, numItems)
        SetItemButtonTexture(f, texture)
        _G["GwReqQuestItem" .. i .. "Name"]:SetText(name)
        UIFrameFadeIn(f, 0.1, 0, 1)
    end

    local btnOffset = #qReq["stuff"]
    for i = 1, #qReq["currency"], 1 do
        local btnIdx = i + btnOffset
        if btnIdx > 6 then
            break
        end
        local f = self.container.dialog["reqItem" .. btnIdx]
        f.type = "required"
        f.objectType = "currency"
        f:SetID(i)
        if qReq["currency"][i] then
            SetItemButtonCount(f, qReq["currency"][i].requiredAmount)
            SetItemButtonTexture(f, qReq["currency"][i].texture)
            _G["GwReqQuestItem" .. btnIdx .. "Name"]:SetText(qReq["currency"][i].name)
            UIFrameFadeIn(f, 0.1, 0, 1)
        end
    end
end

function QuestViewMixin:showRewards(showObjective)
    local questID = QuestInfoFrame.questLog and C_QuestLog.GetSelectedQuest() or GetQuestID()

    local xp = GetRewardXP()
    local money = GetRewardMoney()
    local title = GetRewardTitle()
    local currency = C_QuestInfoSystem.GetQuestRewardCurrencies(questID) or {};
    local _, _, skillPoints = GetRewardSkillPoints()
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

    if (xp > 0 or money > 0 or title or #currency > 0 or skillPoints or items > 0 or #spells > 0 or choices > 0 or honor > 0) then
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
    Debug("quest text completed", self.questState)
    if self.questState == "COMPLETE" then
        self:showRewards(false)
        self.container.acceptButton:SetText(COMPLETE_QUEST)
        self.container.acceptButton:Show()
    elseif self.questState == "PROGRESS" then
        if IsQuestCompletable() then
            Debug("in progress completable state")
            self.container.acceptButton:SetText(CONTINUE)
            self.questState = "NEEDCOMPLETE"
        else
            local s = string.sub(self.questString[self.questStringInt], -1)
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
        self:clearRequired()
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
            local qReq = self.questReq
            local itemReq = #qReq["currency"] + #qReq["stuff"]
            for i = 1, itemReq, 1 do
                local frame = _G["QuestProgressItem" .. i]
                if frame then
                    frame:Hide()
                end
            end
            self.container.dialog.required:Hide()
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

    self.title:SetText(GetTitleText())
    self:Show()

    self.container.playerModel:setPMUnit("player", 0)

    local npc_name = GetUnitName("npc")
    local npc_type = UnitCreatureType("npc")

    if UnitIsUnit("npc", "player") then
        --local board = "World/Expansion06/Doodads/Artifact/7AF_Paladin_MissionBoard01.m2" -- TODO need new files, this one does not exist anymore
        self.questNPCType = 1
        self.container.giverModel:ClearModel()
        self.container.giverModel:SetUnit("none")
        --GwQuestviewFrameContainerGiverModel:SetModel(board)
        --GwQuestviewFrameContainerGiverModel:SetFacing(-0.5)
        --GwQuestviewFrameContainerGiverModel:SetPosition(-15, 1.9, -0.8)
    elseif npc_name and npc_type then
        if UnitIsDead("npc") then
            self.questNPCType = 2
            self.container.giverModel:setPMUnit("npc", 1, true)
        else
            self.questNPCType = 3
            self.container.giverModel:setPMUnit("npc", 1)
        end
    end
    PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\dialog_open.ogg", "SFX")
end

function QuestViewMixin:clearRequired()
    if (self.questReq) then
        wipe(self.questReq.stuff)
        wipe(self.questReq.currency)
        wipe(self.questReq.text)
        self.questReq.money = 0
    else
        self.questReq = {
            ["stuff"] = {},
            ["currency"] = {},
            ["text"] = {},
            ["money"] = 0
        }
    end
    self.container.dialog.reqMoney:Hide()
    for i = 1, 6, 1 do
        local f = self.container.dialog["reqItem" .. i]
        f:Hide()
    end
    self.container.dialog.required:Hide()
    self.container.dialog.objectiveHeader:Hide()
    self.container.dialog.objectiveText:Hide()
end

function QuestViewMixin:clearDialog()
    if (self.questString) then
        wipe(self.questString)
    else
        self.questString = {}
    end
    self.questStringInt = 0
end

function QuestViewMixin:clearQuestReq()
    self.questState = "NONE"
    self.questStateSet = false
    self.questNPCType = 0
    self:clearDialog()
    self:clearRequired()
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
    if key == "SPACE" then
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
    self.questReq["money"] = GetQuestMoneyToGet()
    for i = GetNumQuestItems(), 1, -1 do
        if (IsQuestItemHidden(i) == 0) then
            tinsert(self.questReq["stuff"], 1, {GetQuestItemInfo("required", i)})
        end
    end
    for i = GetNumQuestCurrencies(), 1, -1 do
        tinsert(self.questReq["currency"], 1, C_QuestOffer.GetQuestRequiredCurrencyInfo(i))
    end
    if (self.questReq["money"] > 0 or #self.questReq["currency"] > 0 or #self.questReq["stuff"] > 0) then
        self.questReq["text"] = splitQuest(GetProgressText())
    end
    self:showQuestFrame()
    self.questString = splitQuest(GetProgressText())
    self.questState = "PROGRESS"
    self:nextGossip()
    self:showRequired()
    Debug("quest progress", self.questState)
end

function QuestViewMixin:evQuestDetail(questStartItemID)
    if (questStartItemID ~= nil and questStartItemID ~= 0) or (QuestGetAutoAccept() and QuestIsFromAreaTrigger()) then
        if GW.settings.QUESTTRACKER_ENABLED and not GW.IsIncompatibleAddonLoadedOrOverride("Objectives", true) then
            AcknowledgeAutoAcceptQuest()
        end
        return
    end
    if (self.questState ~= "COMPLETING") then
        self:HideQuestFrame()
        self:clearQuestReq()
        self.questState = "TAKE"
    else
        self.questStringInt = 0
        self.questStateSet = false
    end
    self:showQuestFrame()
    self.questString = splitQuest(GetQuestText())
    if self.questState ~= "COMPLETING" then
        --Debug("adding end row")
        tinsert(self.questString, "")
    end
    self:nextGossip()
end

function QuestViewMixin:evQuestComplete()
    if (self.questState ~= "COMPLETING") then
        self:HideQuestFrame()
        self:clearQuestReq()
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
    local qText = self.questReq.text
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
    self:Hide()
    if (self.questState ~= "PROGRESS") then
        PlaySoundFile("Interface/AddOns/GW2_UI/sounds/dialog_close.ogg", "SFX")
    end
end

function QuestViewMixin:OnEvent(event, ...)
    Debug("OnEvent", event)
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

local function LoadQuestview()
    local f = CreateFrame("Frame", "GwQuestviewFrame", UIParent, "GwQuestviewFrameTemplate")
    Mixin(f, QuestViewMixin)
    Mixin(f.container.giverModel, QuestGiverMixin)
    Mixin(f.container.giverModel, QuestModelMixin)
    Mixin(f.container.playerModel, QuestModelMixin)
    f:clearQuestReq()

    f.title:SetTextColor(255 / 255, 197 / 255, 39 / 255)
    f.title:SetFont(DAMAGE_TEXT_FONT, 24)
    f.container.dialog.text:SetFont(STANDARD_TEXT_FONT, 14)
    f.container.dialog.text:SetTextColor(1, 1, 1)
    f.container.dialog.required:SetFont("UNIT_NAME_FONT", 14)
    f.container.dialog.required:SetTextColor(1, 1, 1)
    f.container.dialog.required:SetShadowColor(0, 0, 0, 1)
    f.container.dialog.required:SetText(L["Required Items:"])
    f.container.dialog.objectiveHeader:SetTextColor(1, 1, 1)
    f.container.dialog.objectiveHeader:SetShadowColor(0, 0, 0, 1)
    f.container.dialog.objectiveHeader:SetText(QUEST_OBJECTIVES)
    f.container.dialog.objectiveText:SetTextColor(1, 1, 1)

    f:SetScript("OnShow", f.OnShow)
    f:SetScript("OnHide", f.OnHide)
    f:SetScript("OnEvent", f.OnEvent)

    f:RegisterEvent("QUEST_DETAIL")
    f:RegisterEvent("QUEST_FINISHED")
    f:RegisterEvent("QUEST_COMPLETE")
    f:RegisterEvent("QUEST_PROGRESS")

    f.container.dialog:SetScript("OnMouseUp", dialog_OnMouseUp)
    f.container.declineButton:SetScript("OnClick", decline_OnClick)
    f.container.acceptButton:SetScript("OnClick", accept_OnClick)

    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    -- handle styling the rewards in a consistent way across options
    if not GW.QuestInfo_Display_hooked then
        hooksecurefunc("QuestInfo_Display", GW.QuestInfo_Display)
        GW.QuestInfo_Display_hooked = true
    end

    -- style required items
    for i = 1, 6 do
        local button = f.container.dialog["reqItem" .. i]
        if button then
            HandleReward(button, false)
            if button.IconBorder then
                button.IconBorder:Show()
            end
        end
    end
end
GW.LoadQuestview = LoadQuestview
