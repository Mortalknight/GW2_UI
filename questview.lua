local questState = 'NONE'   
local questStateSet = false
local QUESTSTRING = {}
local QUESTREQ = {["stuff"] = {}, ["currency"] = {}, ["money"] = 0, ["text"] = {}}
local QUESTSTRINGINT = 0
QUESTVIEW_TEXT_ANIMATION = 0
QUEST_VIEW_ANIMATION_THROT = 0


--[[
GwQuestviewFrame
GwQuestviewFrameContainerPlayerModel
GwQuestviewFrameContainerGiverModel
GwQuestviewFrameContainerDialogString
GwQuestviewFrameContainerDialogQuestTitle
GwQuestviewFrameContainerAcceptButton

]]--

function gw_style_questview_rewards()
    QuestInfoRewardsFrame.Header:SetFont('UNIT_NAME_FONT',14)
    QuestInfoRewardsFrame.Header:SetTextColor(1,1,1)
    QuestInfoRewardsFrame.Header:SetShadowColor(0,0,0,1)  
    
    QuestInfoRewardsFrame.ItemChooseText:SetFont('UNIT_NAME_FONT',12)
    QuestInfoRewardsFrame.ItemChooseText:SetTextColor(1,1,1)
    QuestInfoRewardsFrame.ItemChooseText:SetShadowColor(0,0,0,1)   
    
    QuestInfoRewardsFrame.ItemReceiveText:SetFont('UNIT_NAME_FONT',12)
    QuestInfoRewardsFrame.ItemReceiveText:SetTextColor(1,1,1)
    QuestInfoRewardsFrame.ItemReceiveText:SetShadowColor(0,0,0,1)

    QuestInfoRewardsFrame.PlayerTitleText:SetFont('UNIT_NAME_FONT',12)
    QuestInfoRewardsFrame.PlayerTitleText:SetTextColor(1,1,1)
    QuestInfoRewardsFrame.PlayerTitleText:SetShadowColor(0,0,0,1)
    
    QuestInfoXPFrame.ReceiveText:SetFont('UNIT_NAME_FONT',12)
    QuestInfoXPFrame.ReceiveText:SetTextColor(1,1,1)
    QuestInfoXPFrame.ReceiveText:SetShadowColor(0,0,0,1)

    GwQuestviewFrameContainerDialogRequired:SetFont('UNIT_NAME_FONT',14)
    GwQuestviewFrameContainerDialogRequired:SetTextColor(1,1,1)
    GwQuestviewFrameContainerDialogRequired:SetShadowColor(0,0,0,1)
    GwQuestviewFrameContainerDialogRequired:SetText(GwLocalization['QUEST_REQUIRED_ITEMS'])
end

function gw_create_questview()
    
CreateFrame('Frame','GwQuestviewFrame',UIParent,'GwQuestviewFrame')
    
    
    
    GwQuestviewFrame:SetScript('OnShow',function()
        UIFrameFadeIn(GwQuestviewFrameBackgroundBorder, 0.1,0,1)
        UIFrameFadeIn(GwQuestviewFrameBackground, 0.5,0,1)
    end)
    
    GwQuestviewFrame:RegisterEvent('QUEST_DETAIL')
    GwQuestviewFrame:RegisterEvent('QUEST_FINISHED')
    GwQuestviewFrame:RegisterEvent('QUEST_COMPLETE')
    GwQuestviewFrame:RegisterEvent('QUEST_PROGRESS')
   
    GwQuestviewFrame:SetScript("OnEvent",function(self,event,...)
            
        if event == 'QUEST_PROGRESS' then
            hideBlizzardQuestFrame()
            clearQuestReq()
            QUESTREQ["money"] = GetQuestMoneyToGet();
            for i = GetNumQuestItems(), 1, -1 do
                if (IsQuestItemHidden(i) == 0) then
                    table.insert(QUESTREQ["stuff"], 1, { GetQuestItemInfo("required", i) })
                end
            end
            for i = GetNumQuestCurrencies(), 1, -1 do
                table.insert(QUESTREQ["currency"], 1, { GetQuestCurrencyInfo("required", i) })
            end
            if (QUESTREQ["money"] > 0 or #QUESTREQ["currency"] > 0 or #QUESTREQ["stuff"] > 0) then
                QUESTREQ["text"] = splitQuest(GetProgressText())
            end
            if IsQuestCompletable() then
                -- there will be a QUEST_COMPLETE event shortly
                CompleteQuest();
                questState = 'AUTOPROGRESS'
                questStateSet = false
            else
                showQuestFrame()
                QUESTSTRING = splitQuest(GetProgressText())
                QUESTSTRINGINT = 0
                questState = 'PROGRESS'
                questStateSet = false
                nextGossip()
            end
        end
        if event == 'QUEST_DETAIL' then
            local questStartItemID = ...;
            if (questStartItemID ~= nil and questStartItemID ~= 0) or QuestIsFromAreaTrigger() then
                if gwGetSetting('QUESTTRACKER_ENABLED') then
                    AcknowledgeAutoAcceptQuest()
                end
                return
            end
            if (questState ~= 'AUTOPROGRESS') then
                hideBlizzardQuestFrame()
                clearQuestReq()
            end
            showQuestFrame()
            QUESTSTRING = splitQuest(GetQuestText())
            if not IsQuestCompletable() then
                table.insert(QUESTSTRING, GetObjectiveText())
            end
            QUESTSTRINGINT = 0
            questState = 'TAKE'
            questStateSet = false
            nextGossip()
        end
        if event == 'QUEST_COMPLETE' then
            if (questState ~= 'AUTOPROGRESS') then
                hideBlizzardQuestFrame()
                clearQuestReq()
            end
            showQuestFrame()
            QUESTSTRING = splitQuest(GetRewardText())
            if (#QUESTREQ["text"] > 0) then
                for i = #QUESTREQ["text"], 1, -1 do
                    table.insert(QUESTSTRING, 1, QUESTREQ["text"][i])
                end
            end
            QUESTSTRINGINT = 0
            questState = 'COMPLETE'
            questStateSet = false
            nextGossip()
        end

        if event == 'QUEST_FINISHED' then
            QuestInfoRewardsFrame:Hide()
            QuestProgressRequiredMoneyFrame:Hide()
            GwQuestviewFrameContainerDialogRequired:Hide()
            for i = 1, 32, 1 do
                local frame = _G["QuestProgressItem" .. i]
                if (frame) then frame:Hide() end
            end
            GwQuestviewFrame:Hide()
            if (questState ~= "PROGRESS") then
                PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\dialog_close.ogg",'SFX')
            end
            clearQuestReq()
        end

    end)
    GwQuestviewFrameContainerDialog:RegisterForClicks("LeftButtonUp", "RightButtonUp");
    
GwQuestviewFrameContainerDialog:SetScript("OnClick", function(self,event,addon)
            nextGossip()
end)
    GwQuestviewFrameContainerDeclineQuest:SetScript("OnClick", function(self,event,addon)
        if questState == "TAKE" then
            DeclineQuest()
        else
            CloseQuest()
        end
    end)
    GwQuestviewFrameContainerAcceptButton:SetScript("OnClick", function(self,event,addon)
         
        Stringcount = 0   
        for k,v in pairs(QUESTSTRING) do
            Stringcount = Stringcount + 1
        end

        if QUESTSTRINGINT<Stringcount then
            QUESTSTRINGINT=Stringcount - 1
            nextGossip()
                
        else
            if questState =='TAKE' then
                if ( QuestFlagsPVP() ) then
                    QuestFrame.dialog = StaticPopup_Show("CONFIRM_ACCEPT_PVP_QUEST");
                else
                    if ( QuestFrame.autoQuest ) then
                        AcknowledgeAutoAcceptQuest();
                    else
                        AcceptQuest();
                        CloseQuest();
                    end
                end
            elseif questState=='PROGRESS' then
                CloseQuest()
            else
                if ( GetNumQuestChoices() == 0 ) then
                    GetQuestReward();
                    CloseQuest()
                elseif ( GetNumQuestChoices() == 1 ) then
                    GetQuestReward(1);
                    CloseQuest()
                else
                    if ( QuestInfoFrame.itemChoice == 0 ) then
                        QuestChooseRewardError();
                    else
                        GetQuestReward(QuestInfoFrame.itemChoice);
                        CloseQuest()
                    end
                end
            end
        end
    end)


    
end







function hideBlizzardQuestFrame()
    QuestFrame:ClearAllPoints()
    QuestFrame:SetPoint('RIGHT',UIParent,'LEFT',-800,0)
end






function nextGossip()
    QUESTSTRINGINT=QUESTSTRINGINT+1 
    count = 0
    for k,v in pairs(QUESTSTRING) do
        count = count + 1
    end
    if QUESTSTRINGINT<=count then
        GwQuestviewFrameContainerDialogString:SetText(QUESTSTRING[QUESTSTRINGINT])
        setQuestGiverAnimation(count)
        if QUESTSTRINGINT ~= 1 then
            PlaySound(906)
        end
        if QUESTSTRINGINT==count then
            questTextCompleted()
        else
            GwQuestviewFrameContainerAcceptButton:SetText(GwLocalization['QUEST_VIEW_SKIP'])   
        end
    else
        questTextCompleted()
    end
end

local emotes = {
    ["Idle"] = 0,
    ["Talk"] = 60,
    ["TalkExclamation"] = 64,
    ["TalkQuestion"] = 65,
    ["Bow"] = 66,
    ["Point"] = 84,
    ["Salute"] = 113,
    ["Yes"] = 185,
    ["No"] = 186
}
local mid_set = {"Idle", "Talk", "Yes", "No", "Point"}
local end_set = {"Bow", "Salute"}
local anim_next = 0
local anim_playing = false
function setQuestGiverAnimation(count)
    if QUESTSTRING[QUESTSTRINGINT] == nil then
        return
        end

    if QUESTSTRINGINT == 1 then
        GwQuestviewFrameContainerGiverModel:SetScript("OnAnimFinished", nil)
        anim_next = 0
        anim_playing = false
    end
        
    -- determine main emote to play for this line
    local a = emotes["Talk"]
    local s = string.sub(QUESTSTRING[QUESTSTRINGINT],-1)
    if QUESTSTRINGINT >= count then
        a = emotes[end_set[math.random(1, #end_set)]]
    elseif s =='!' then
        a = emotes["TalkExclamation"]
    elseif s =='?' then
        a = emotes["TalkQuestion"]
    end
    
    -- if playing something, don't interrupt to avoid spastic motions on click-thru
    if anim_playing then
        if a == emotes["Talk"] then
            anim_next = emotes[mid_set[math.random(1, #mid_set)]]
        else
            anim_next = a
        end
    else
        anim_playing = true
        if QUESTSTRINGINT < count then
            anim_next = emotes[mid_set[math.random(1, #mid_set)]]
        end
        GwQuestviewFrameContainerGiverModel:SetScript("OnAnimFinished", function(self)
            if anim_next ~= 0 then
                self:SetAnimation(anim_next)
                anim_next = 0
            else
                self:SetScript("OnAnimFinished", nil)
                anim_playing = false
                self:SetAnimation(0)
            end
        end)
        GwQuestviewFrameContainerGiverModel:SetAnimation(a)
    end

end

function showQuestFrame()
    GwQuestviewFrame:Show()
    GwQuestviewFrameContainerDialogQuestTitle:SetText(GetTitleText())

    setPMUnit(GwQuestviewFrameContainerPlayerModel, "player", 0)
    
    if not GetUnitName("npc") or GetUnitName("npc") == GetUnitName("player") then
        local board = "World/Expansion06/Doodads/Artifact/7AF_Paladin_MissionBoard01.m2"
        GwQuestviewFrameContainerGiverModel:ClearModel()
        GwQuestviewFrameContainerGiverModel:SetUnit("none")
        GwQuestviewFrameContainerGiverModel:SetModel(board)
        GwQuestviewFrameContainerGiverModel:SetFacing(-0.5)
        GwQuestviewFrameContainerGiverModel:SetPosition(-15,1.9,-0.8)
    else
        setPMUnit(GwQuestviewFrameContainerGiverModel, "npc", 1)
    end
    PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\dialog_open.ogg",'SFX')
end

function setPMUnit(PM, unit, side, crace, cgender)
    local uX, uY, uZ, uF = -1.25, -0.65, -0.2, 0.7 -- fac 0.7
    if side > 0 then
        uY = -uY
        uF = -uF
    end
    
    -- Reset camera each time because it can bug out when the frame is hidden
    PM:ClearModel()
    PM:SetUnit("none")
    
    -- SetUnit does magical camera work to get things in frame so set facing & position first
    PM:SetFacing(uF)
    PM:SetPosition(uX, uY, uZ)
    PM:SetUnit(unit)
    if crace then
        PM:SetCustomRace(crace, cgender)
    end
    
    -- Check the auto camera alignment, adjust if needed; larger units tend to be placed
    -- too high and too inward and smaller units vice-versa; this is hacky normalization
    -- but is much more light-weight than analyzing model paths/categories
    local cpos = {PM:GetCameraPosition()}
    local ctar = {PM:GetCameraTarget()}
    local zdiff = (cpos[3] / ctar[3])^4 / (cpos[1] - ctar[1])
    local ydiff = (cpos[1] - ctar[1])
    local dirty = 0
    
    if zdiff > 0.6 then
        local adj = 0.04 * zdiff^2
        if adj > 1 then adj = 1 end
        uZ = uZ - adj
        dirty = 1
    elseif zdiff < 0.4 then
        local adj = 0.02 / zdiff^1.5
        if adj > 1 then adj = 1 end
        uZ = uZ + adj
        dirty = 1
    end
    if ydiff < 1.4 then
        local adj = 0.15 * ydiff / 1.4
        if adj > 1 then adj = 1 end
        if side > 0 then
            uY = uY - adj
        else
            uY = uY + adj
        end
        dirty = 1
    elseif ydiff > 2 then
        local adj = 0.15 * ydiff / 2
        if adj > 1 then adj = 1 end
        if side > 0 then
            uY = uY + adj
        else
            uY = uY - adj
        end
        dirty = 1
    end
    if dirty then
        PM:SetPosition(uX, uY, uZ)
        PM:SetUnit(unit)
        if crace then
            PM:SetCustomRace(crace, cgender)
        end
    end
        
end

function questTextCompleted()
    if questStateSet then
        return
    end
    if questState=='COMPLETE' then
        showRewards()
        GwQuestviewFrameContainerAcceptButton:SetText(GwLocalization['QUEST_VIEW_COMPLETE'])
    elseif questState=='PROGRESS' then
        showRewards()
        GwQuestviewFrameContainerAcceptButton:SetText(GwLocalization['QUEST_VIEW_SKIP'])
    else
        showRewards()
        GwQuestviewFrameContainerAcceptButton:SetText(GwLocalization['QUEST_VIEW_ACCPET'])
    end
    questStateSet = true
end

function showRewards()
    local xp = GetRewardXP();
    local money = GetRewardMoney();
    local title = GetRewardTitle();
    local currency = GetNumRewardCurrencies();
    local skillName, skillIcon, skillPoints = GetRewardSkillPoints();
    local items = GetNumQuestRewards();
    local spells = GetNumRewardSpells();
    local choices = GetNumQuestChoices();
    
    local qinfoHeight = 300
    local qinfoTop = -20

    gw_style_questview_rewards()
    
    if (QUESTREQ["money"] > 0 or #QUESTREQ["currency"] > 0 or #QUESTREQ["stuff"] > 0) then
        qinfoHeight = 150
        qinfoTop = 55
                
        UIFrameFadeIn(GwQuestviewFrameContainerDialogRequired, 0.1, 0, 1)
        
        if QUESTREQ["money"] > 0 then
            UIFrameFadeIn(QuestProgressRequiredMoneyFrame, 0.1,0,1)
            QuestProgressRequiredMoneyFrame:SetParent(GwQuestviewFrame)
            QuestProgressRequiredMoneyFrame:ClearAllPoints();
            QuestProgressRequiredMoneyFrame:SetPoint('CENTER',GwQuestviewFrame,'CENTER',0,-30);
            QuestProgressRequiredMoneyFrame:SetFrameLevel(5)
        end
        local itemReq = #QUESTREQ["currency"] + #QUESTREQ["stuff"]
        local itemHeight = 0
        local itemWidth = 0
        for i = 1, itemReq, 1 do
            local frame = _G["QuestProgressItem" .. i]
            if (frame) then
                if itemHeight == 0 then itemHeight = math.ceil(frame:GetHeight()) end
                if itemWidth == 0 then itemWidth = math.ceil(frame:GetWidth()) end
                UIFrameFadeIn(frame, 0.1, 0, 1)
                frame:SetParent(GwQuestviewFrame)
                frame:ClearAllPoints()
                frame:SetPoint('TOPLEFT',GwQuestviewFrame,'CENTER',(((i + 1) % 2) * (itemWidth + 20) - 160), -(itemHeight + 9) * (math.ceil(i/2)));
                frame:SetFrameLevel(5)
                frame:SetScript("OnEnter", function() end) -- TODO: tooltips disabled because it dies for currency types
            end
        end
    end
    
    if (xp > 0 or money > 0 or title or currency > 0 or skillPoints or items > 0 or spells > 0 or choices > 0) then
        UIFrameFadeIn(QuestInfoRewardsFrame, 0.1,0,1)
        QuestInfoRewardsFrame:SetParent(GwQuestviewFrame)
        QuestInfoRewardsFrame:SetWidth(400);
        QuestInfoRewardsFrame:SetHeight(qinfoHeight);
            
        QuestInfoRewardsFrame:ClearAllPoints();
        QuestInfoRewardsFrame:SetPoint('CENTER',GwQuestviewFrame,'CENTER',40,qinfoTop);
        QuestInfoRewardsFrame:SetFrameLevel(5)
    end
end

function clearQuestReq()
    questState = "NONE"
    questStateSet = false
    
    QuestProgressRequiredMoneyFrame:Hide()
    
    for i = 0, #QUESTSTRING do QUESTSTRING[i] = nil end
    
    QUESTREQ["money"] = 0
    
    local countStuff = #QUESTREQ["stuff"]
    for i = 0, countStuff do QUESTREQ["stuff"][i] = nil end

    local countCurrency = #QUESTREQ["currency"]
    for i = 0, countCurrency do QUESTREQ["currency"][i] = nil end

    local countText = #QUESTREQ["text"]
    for i = 0, countText do QUESTREQ["text"][i] = nil end
end
