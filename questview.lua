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


function gw_create_questview()
    
CreateFrame('Frame','GwQuestviewFrame',UIParent,'GwQuestviewFrame')
    
    
    
    GwQuestviewFrame:SetScript('OnShow',function()
        
    end)
    
    GwQuestviewFrame:RegisterEvent('QUEST_DETAIL')
    GwQuestviewFrame:RegisterEvent('QUEST_FINISHED')
    GwQuestviewFrame:RegisterEvent('QUEST_COMPLETE')
   
    GwQuestviewFrame:SetScript("OnEvent",function(self,event,addon)
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
            GwQuestviewFrameContainerAcceptButton:SetText("Skip")
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
            print()
        if QUESTSTRINGINT<=Stringcount then
            QUESTSTRINGINT=Stringcount
            nextGossip()
                
        else
            if questState =='TAKE' then
                  
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
    QuestFrame:SetPoint('LEFT',UIParent,'LEFT',-800,0)
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
            GwQuestviewFrameContainerAcceptButton:SetText("Skip")
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
        GwQuestviewFrameContainerAcceptButton:SetText("Complete")
    else
        showRewards()
        GwQuestviewFrameContainerDialogString:SetText(GetObjectiveText())
        GwQuestviewFrameContainerAcceptButton:SetText("Accept")
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
end


