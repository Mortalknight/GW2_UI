local questState = 'TAKE'   
local questStateSet = false

    questViewBorder, questViewBorderTexture = createWindow('CENTER',1024,512,0,0,"Interface\\AddOns\\GW2_UI\\textures\\questviewborder",0)    
    questViewBg, questViewTexture = createWindow('CENTER',950,475,0,0,"Interface\\AddOns\\GW2_UI\\textures\\questviewbg",1)
    questViewBottomBG, questViewBottomTexture = createWindow('CENTER',950,475,0,0,"Interface\\AddOns\\GW2_UI\\textures\\questviewbottom",3)
    questViewBottomBG:SetParent(questViewBg);
    questViewBg:SetParent(questViewBorder);

    questViewBg:EnableMouse(1);

    local playerModelQuestView = CreateFrame("PlayerModel",playerModelQuestView,questViewBg)
    playerModelQuestView:SetFrameStrata("BACKGROUND")
    playerModelQuestView:SetWidth(950) 
    playerModelQuestView:SetHeight(474) 
    playerModelQuestView:SetPoint('BOTTOMLEFT',questViewBg,'BOTTOMLEFT',0,1)
    playerModelQuestView:Show()
    playerModelQuestView:SetUnit("player")
    playerModelQuestView:SetRotation(0.7)
    playerModelQuestView:SetPosition(-1,-0.85,-0.2)
    playerModelQuestView:SetFrameLevel(2)
   playerModelQuestView:SetFrameStrata("DIALOG")

    local targetModelQuestView = CreateFrame("PlayerModel",targetModelQuestView,questViewBg)
    targetModelQuestView:SetFrameStrata("BACKGROUND")
    targetModelQuestView:SetWidth(950) 
    targetModelQuestView:SetHeight(474) 
    targetModelQuestView:SetPoint('BOTTOMRIGHT',questViewBg,'BOTTOMRIGHT',0,1)
    targetModelQuestView:Show()
    targetModelQuestView:SetRotation(-0.7)
    targetModelQuestView:SetPosition(-1,0.85,-0.2)
    targetModelQuestView:SetFrameLevel(2)
 targetModelQuestView:SetFrameStrata("DIALOG")



    local questTextViewFrame = CreateFrame("Button",questTextViewFrame,questViewBg)
    questTextViewFrame:SetParent(questViewBg)
    questTextViewFrame:SetWidth(950)
    questTextViewFrame:SetHeight(100);
    questTextViewFrame:SetPoint('BOTTOM',questViewBg,'BOTTOM',0,0)
    questTextViewFrame:SetFrameLevel(4)
    questTextViewFrame:SetFrameStrata("DIALOG")


    
  

    questAcceptButton, questAcceptButtonTexture = createButton('BOTTOM',150,30,0,0,"Interface\\AddOns\\GW2_UI\\textures\\questviewbutton",4)
    questAcceptButton:SetParent(questViewBorder)
    questAcceptButton:SetWidth(128)
    questAcceptButton:SetHeight(32);
    questAcceptButton:SetPoint('BOTTOMLEFT',questViewBg,'BOTTOMLEFT',0,-32)
    questAcceptButton:SetFrameLevel(5)
    questAcceptButton:SetFrameStrata("DIALOG")

    local questAcceptButtonString = unitBGf:CreateFontString('questAcceptButtonString', "OVERLAY", "GameFontNormal")
    questAcceptButtonString:SetParent(questAcceptButton)
    questAcceptButtonString:SetTextColor(30/255,30/255,30/255)
    questAcceptButtonString:SetFont(STANDARD_TEXT_FONT,14)
    questAcceptButtonString:SetPoint("CENTER")
    questAcceptButtonString:SetText("Skip")
    questAcceptButtonString:SetWidth(128)
    questAcceptButton:SetHeight(32);
    questAcceptButtonString:SetShadowColor(118/255,118/255,118/255);
    questAcceptButtonString:SetPoint('CENTER',questAcceptButton,'CENTER',0,0)

    local questTextView = unitBGf:CreateFontString('questTextView', "OVERLAY", "GameFontNormal")
    questTextView:SetParent(questTextViewFrame)
    questTextView:SetTextColor(1,1,1)
    questTextView:SetFont(STANDARD_TEXT_FONT,14)
    questTextView:SetPoint("CENTER")
    questTextView:SetText("")
    questTextView:SetWidth(950)
    questTextView:SetHeight(100);
    questTextView:SetPoint('BOTTOM',questViewBg,'BOTTOM',0,0)

    local questTitelView = unitBGf:CreateFontString('questTitelView', "OVERLAY", "GameFontNormal")
    questTitelView:SetParent(questTextViewFrame)
    questTitelView:SetTextColor(255/255,197/255,39/255)
    questTitelView:SetFont(DAMAGE_TEXT_FONT,24)
    questTitelView:SetPoint("CENTER")
    questTitelView:SetText("")
    questTitelView:SetWidth(950)
    questTitelView:SetHeight(100);
    questTitelView:SetPoint('TOP',questViewBg,'TOP',0,0)
    


questViewBorder:Hide()

QUESTSTRING = {}
QUESTSTRINGINT = 0

questViewBg:SetScript("OnEvent",function(self,event,addon)
    if event == 'QUEST_DETAIL' then
        
            
        playerModelQuestView:SetUnit("player")
        questTitelView:SetText(GetTitleText())
        questViewBorder:Show()
        UIFrameFadeIn(questViewBorder, 0.2,0,1)
        UIFrameFadeIn(questViewBg, 1,0,1)
  
        targetModelQuestView:SetUnit('npc')
        QUESTSTRING = splitString(GetQuestText(),'.','!','?')
        QUESTSTRINGINT = 1
        questTextView:SetText(QUESTSTRING[QUESTSTRINGINT])
        setQuestGiverAnimation()
        questState = 'TAKE'
        questStateSet = false
        questAcceptButtonString:SetText("Skip")
        PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\dialog_open.ogg",'SFX') 
        hideBlizzardQuestFrame()
            
    end
    if event == 'QUEST_COMPLETE' then
        
        playerModelQuestView:SetUnit("player")
        questTitelView:SetText(GetTitleText())
        questViewBorder:Show()
        UIFrameFadeIn(questViewBorder, 1,0,1)
        targetModelQuestView:SetUnit('npc')
        QUESTSTRING = splitString(GetRewardText(),'.','!','?')
        QUESTSTRINGINT = 1
        questTextView:SetText(QUESTSTRING[QUESTSTRINGINT])
        setQuestGiverAnimation()
        questState = 'COMPLETE'
        questStateSet =false
        PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\dialog_open.ogg",'SFX') 
        hideBlizzardQuestFrame()
       
            
    end
        
    if event == 'QUEST_FINISHED' then
        questViewBorder:Hide()
        PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\dialog_close.ogg",'SFX')          
    end
        
end)

function hideBlizzardQuestFrame()
    QuestFrame:ClearAllPoints()
    QuestFrame:SetPoint('LEFT',UIParent,'LEFT',-800,0)
end

questTextViewFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp");
questTextViewFrame:SetScript("OnClick", function(self,event,addon)
nextGossip()
end)

questAcceptButton:SetScript("OnClick", function(self,event,addon)
        count = 0   
    for k,v in pairs(QUESTSTRING) do
         count = count + 1
    end
        if QUESTSTRINGINT<=count then
            QUESTSTRINGINT=count
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

questAcceptButton:SetScript("OnEnter", function(self,event,addon)

     questAcceptButtonTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\questviewbutton_hover");
end)
questAcceptButton:SetScript("OnLeave", function(self,event,addon)
      questAcceptButtonTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\questviewbutton");
end)



function nextGossip()
        QUESTSTRINGINT=QUESTSTRINGINT+1 
        count = 0
for k,v in pairs(QUESTSTRING) do
     count = count + 1
end
        if QUESTSTRINGINT<=count then
            questTextView:SetText(QUESTSTRING[QUESTSTRINGINT])
            setQuestGiverAnimation()
            questAcceptButtonString:SetText("Skip")
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
    targetModelQuestView:SetAnimation(a)
    
end

function questTextCompleted()
    if questStateSet then
        return
    end
    if questState=='COMPLETE' then
        showRewards()
        questAcceptButtonString:SetText("Complete")
    else
        showRewards()
        questTextView:SetText(GetObjectiveText())
        questAcceptButtonString:SetText("Accept")
    end
    questStateSet = true
end

function showRewards()
        UIFrameFadeIn(QuestInfoRewardsFrame, 0.1,0,1)
        QuestInfoRewardsFrame:SetParent(questViewBg)
        QuestInfoRewardsFrame:SetWidth(285);
        QuestInfoRewardsFrame:SetHeight(285);
            
        QuestInfoRewardsFrame:ClearAllPoints();
        QuestInfoRewardsFrame:SetPoint('CENTER',questViewBg,'CENTER',0,-20);
        QuestInfoRewardsFrame:SetFrameLevel(5)
end

questViewBg:RegisterEvent('QUEST_DETAIL')
questViewBg:RegisterEvent('QUEST_FINISHED')
questViewBg:RegisterEvent('QUEST_COMPLETE')
