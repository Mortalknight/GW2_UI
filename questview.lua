local questState = 'TAKE'   
local questStateSet = false
local QUESTSTRING = {}
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
    
    QuestInfoXPFrame.ReceiveText:SetFont('UNIT_NAME_FONT',12)
    QuestInfoXPFrame.ReceiveText:SetTextColor(1,1,1)
    QuestInfoXPFrame.ReceiveText:SetShadowColor(0,0,0,1)
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
    GwQuestviewFrame:RegisterEvent('QUEST_ACCEPTED')
    GwQuestviewFrame:RegisterEvent('QUEST_PROGRESS')
   
    GwQuestviewFrame:SetScript("OnEvent",function(self,event,addon)
            
            if event == 'QUEST_PROGRESS' then
                if IsQuestCompletable() then
                    CompleteQuest();
                end
            end
            
            if event == 'QUEST_DETAIL' then
                
            GwQuestviewFrame:Show()
            GwQuestviewFrameContainerPlayerModel:SetUnit("player")
                
            GwQuestviewFrameContainerDialogQuestTitle:SetText(GetTitleText())

            GwQuestviewFrameContainerGiverModel:SetUnit('npc')           
                
            QUESTSTRING = splitString(GetQuestText(),'.','!','?')
            QUESTSTRINGINT = 1
            GwQuestviewFrameContainerDialogString:SetText(QUESTSTRING[QUESTSTRINGINT])
            setQuestGiverAnimation()
            questState = 'TAKE'
            questStateSet = false
            GwQuestviewFrameContainerAcceptButton:SetText(GwLocalization['QUEST_VIEW_SKIP'])
            PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\dialog_open.ogg",'SFX') 
            hideBlizzardQuestFrame()

        end
        if event == 'QUEST_COMPLETE' then
            
            GwQuestviewFrame:Show()
            GwQuestviewFrameContainerPlayerModel:SetUnit("player")

            GwQuestviewFrameContainerDialogQuestTitle:SetText(GetTitleText())
 
            
            GwQuestviewFrameContainerGiverModel:SetUnit('npc')
                

            QUESTSTRING = splitString(GetRewardText(),'.','!','?')
            QUESTSTRINGINT = 1
            GwQuestviewFrameContainerDialogString:SetText(QUESTSTRING[QUESTSTRINGINT])
            setQuestGiverAnimation()
            questState = 'COMPLETE'
            questStateSet =false
            PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\dialog_open.ogg",'SFX') 
            hideBlizzardQuestFrame()


        end

        if event == 'QUEST_FINISHED' then
            GwQuestviewFrame:Hide()
            PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\dialog_close.ogg",'SFX')          
        end

    end)
    GwQuestviewFrameContainerDialog:RegisterForClicks("LeftButtonUp", "RightButtonUp");
    
GwQuestviewFrameContainerDialog:SetScript("OnClick", function(self,event,addon)
            nextGossip()
end)
    GwQuestviewFrameContainerAcceptButton:SetScript("OnClick", function(self,event,addon)
         
        Stringcount = 0   
    for k,v in pairs(QUESTSTRING) do
         Stringcount = Stringcount + 1
    end

        if QUESTSTRINGINT<=Stringcount then
            QUESTSTRINGINT=Stringcount
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
                        end
                    end
                    AcceptQuest()
                else
                if ( GetNumQuestChoices() == 1 ) then
                    QuestInfoFrame.itemChoice = 1;
                end
                if ( QuestInfoFrame.itemChoice == 0 and GetNumQuestChoices() > 0 ) then
                    QuestChooseRewardError();
                else
                    GetQuestReward(QuestInfoFrame.itemChoice);
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
            setQuestGiverAnimation()
            GwQuestviewFrameContainerAcceptButton:SetText(GwLocalization['QUEST_VIEW_SKIP'])
        PlaySoundKitID(906)
        else
            questTextCompleted()
        end
end

function setQuestGiverAnimation()
      a = 60
    if QUESTSTRING[QUESTSTRINGINT] == nil then
        return
        end
    s = string.sub(QUESTSTRING[QUESTSTRINGINT],-1)
    if s =='.' then
        a = 60
    end
    if s =='!' then
        a = 74
    end
    if s =='?' then
        a = 65
    end
    GwQuestviewFrameContainerGiverModel:SetAnimation(a)
    
end

function questTextCompleted()
    if questStateSet then
        return
    end
    if questState=='COMPLETE' then
        showRewards()
        GwQuestviewFrameContainerAcceptButton:SetText(GwLocalization['QUEST_VIEW_COMPLETE'])
    else
        showRewards()
        GwQuestviewFrameContainerDialogString:SetText(GetObjectiveText())
        GwQuestviewFrameContainerAcceptButton:SetText(GwLocalization['QUEST_VIEW_ACCPET'])
    end
    questStateSet = true
end

function showRewards()
        UIFrameFadeIn(QuestInfoRewardsFrame, 0.1,0,1)
        QuestInfoRewardsFrame:SetParent(GwQuestviewFrame)
        QuestInfoRewardsFrame:SetWidth(285);
        QuestInfoRewardsFrame:SetHeight(285);
            
        QuestInfoRewardsFrame:ClearAllPoints();
        QuestInfoRewardsFrame:SetPoint('CENTER',GwQuestviewFrame,'CENTER',0,-20);
        QuestInfoRewardsFrame:SetFrameLevel(5)
        gw_style_questview_rewards()
end


