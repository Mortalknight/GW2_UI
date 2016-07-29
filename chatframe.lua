
local   CHAT_FRAME_TEXTURES = {

    "TopLeftTexture",
    "BottomLeftTexture",
    "TopRightTexture",
    "BottomRightTexture",
    "LeftTexture",
    "RightTexture",
    "BottomTexture",
    "TopTexture",
    --"ResizeButton",
     
    
    "EditBox",
    "ResizeButton",
    "ButtonFrameDownButton",
    "ButtonFrameUpButton",
    "ButtonFrameBottomButton",
    "ButtonFrameBackground",
    "ButtonFrameTopLeftTexture",
    "ButtonFrameBottomLeftTexture",
    "ButtonFrameTopRightTexture",
    "ButtonFrameBottomRightTexture",
    "ButtonFrameLeftTexture",
    "ButtonFrameRightTexture",
    "ButtonFrameBottomTexture",
    "ButtonFrameTopTexture",
    "EditBoxMid",
    "EditBoxLeft",
    "EditBoxRight",
    
    "TabSelectedRight",
    "TabSelectedLeft",
    "TabSelectedMiddle",
    
    "TabRight",
    "TabLeft",
    "TabMiddle",
}

function gw_set_chatframe_bg()
    
    gw_styleOveralChat()

end


local gw_fade_frames = {}


function gw_styleOveralChat()

    
    FriendsMicroButton:SetDisabledTexture('Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down'); 
    FriendsMicroButton:SetNormalTexture('Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down'); 
    FriendsMicroButton:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down'); 
    FriendsMicroButton:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down'); 
    FriendsMicroButton:SetWidth(25) 
    FriendsMicroButton:SetHeight(25) 
    
    CreateFrame('FRAME','GwChatContainer',UIParent,'GwChatContainer')
    GwChatContainer:SetPoint('TOPLEFT',ChatFrame1,'TOPLEFT',-35,5)
    GwChatContainer:SetPoint('BOTTOMRIGHT',ChatFrame1EditBoxFocusRight,'BOTTOMRIGHT',0,0)
    
    for i=1,10 do
       gw_styleChatWindow(i) 
    end
    
    
    hooksecurefunc('FCFTab_UpdateColors', function(self,selected)
            
            self:GetFontString():SetTextColor(1, 1, 1);
            self.leftSelectedTexture:SetVertexColor(1,1,1);
            self.middleSelectedTexture:SetVertexColor(1,1,1);
            self.rightSelectedTexture:SetVertexColor(1,1,1);
     
            self.leftHighlightTexture:SetVertexColor(1,1,1);
            self.middleHighlightTexture:SetVertexColor(1,1,1);
            self.rightHighlightTexture:SetVertexColor(1,1,1);
            self.glow:SetVertexColor(1,1,1);
        
    end)
    
    hooksecurefunc('FCF_FadeOutChatFrame',gw_handleChatFrameFadeOut )
    hooksecurefunc('FCF_FadeInChatFrame',gw_handleChatFrameFadeIn)
    hooksecurefunc('FCFTab_UpdateColors',gw_setChatBackgroundColor)
    
    gw_fade_frames = {
    FriendsMicroButton,
    GwChatContainer,
    GeneralDockManager,
    }
    
    FCF_FadeOutChatFrame(_G['ChatFrame1'])
    
    
    
end

function gw_ChatFader(frame,to,from)

 
     UIFrameFadeIn(frame, 2,from, to);
end

function gw_setChatBackgroundColor()
    for i=1,10 do
        if _G['ChatFrame'..i..'Background'] then
            _G['ChatFrame'..i..'Background']:SetVertexColor(0,0,0,0)
            _G['ChatFrame'..i..'Background']:SetAlpha(0)
            _G['ChatFrame'..i..'Background']:Hide()
            if _G['ChatFrame'..i..'ButtonFrameBackground'] then
                _G['ChatFrame'..i..'ButtonFrameBackground']:SetVertexColor(0,0,0,0)
                _G['ChatFrame'..i..'ButtonFrameBackground']:Hide()
                _G['ChatFrame'..i..'RightTexture']:SetVertexColor(0,0,0,1)
                
                
                
            end
        end
    end
end

function gw_handleChatFrameFadeOut(chatFrame)
    if not gwGetSetting('CHATFRAME_FADE') then return end
    gw_setChatBackgroundColor()
    if chatFrame.editboxHasFocus then
        gw_handleChatFrameFadeIn(chatFrame)
        return
    end

    local frameName = chatFrame:GetName()
    for k,v in pairs(CHAT_FRAME_TEXTURES) do
        local object = _G[chatFrame:GetName()..v];
        if ( object:IsShown() ) then
            UIFrameFadeOut(object,2,object:GetAlpha(),0)
        end
    end
    for k,v in pairs(gw_fade_frames) do 
        UIFrameFadeOut(v,2,v:GetAlpha(),0)
    end
    local chatTab = _G[frameName.."Tab"];
    UIFrameFadeOut(chatTab,2, chatTab:GetAlpha(),0)
   
    UIFrameFadeOut(chatFrame.buttonFrame,2,chatFrame.buttonFrame:GetAlpha(),0)
    _G[frameName..'ButtonFrame']:Hide()
    ChatFrameMenuButton:Hide()

end
function gw_handleChatFrameFadeIn(chatFrame)
    
     if not gwGetSetting('CHATFRAME_FADE') then return end
    
    gw_setChatBackgroundColor()
    local frameName = chatFrame:GetName()
    for k,v in pairs(CHAT_FRAME_TEXTURES) do
        local object = _G[chatFrame:GetName()..v];
        if ( object:IsShown() ) then
            gw_ChatFader(object,object:GetAlpha(),1)
        end
    end    
            
    for k,v in pairs(gw_fade_frames) do 
        gw_ChatFader(v,v:GetAlpha(),1)
    end
    local chatTab = _G[frameName.."Tab"];
    gw_ChatFader(chatTab, chatTab:GetAlpha(),1)
    gw_ChatFader(chatFrame.buttonFrame,chatFrame.buttonFrame:GetAlpha(),1)
      _G[frameName..'ButtonFrame']:Show()
    ChatFrameMenuButton:Show()

end

function gw_styleChatWindow(i)
    local useId = i
    
    if not _G['ChatFrame'..useId..'Background'] then return end
    
    if not _G['ChatFrame'..useId].gwhasBeenHooked then
        
        
         if  _G['ChatFrame'..useId] == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) then
            _G['ChatFrame'..useId..'EditBox']:Show()
           
        end
        
        _G['ChatFrame'..useId..'EditBox'].editboxHasFocus= false
        _G['ChatFrame'..useId..'EditBox']:HookScript('OnEditFocusGained',function()
                
                _G['ChatFrame'..useId].editboxHasFocus= true
                _G['ChatFrame'..useId]:SetScript('OnUpdate',function()  gw_handleChatFrameFadeIn(_G['ChatFrame'..useId]) end)
                
                FCF_FadeInChatFrame(_G['ChatFrame'..useId])
                _G['ChatFrame'..useId..'EditBox']:SetText('')
        end)
  
        _G['ChatFrame'..useId..'EditBox']:HookScript('OnEditFocusLost',function()
                _G['ChatFrame'..useId]:SetScript('OnUpdate',nil)
                   _G['ChatFrame'..useId].editboxHasFocus= false
                FCF_FadeOutChatFrame(_G['ChatFrame'..useId])
         
        
        end)
        
        _G['ChatFrame'..useId..'EditBox']:HookScript('OnHide',function(self)
            if  _G['ChatFrame'..useId] == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) then
                self:Show()
            end
            
        end)
          
        hooksecurefunc( _G['ChatFrame'..useId..'EditBoxHeader'],'SetTextColor', function() 
                
            if not string.find(_G['ChatFrame'..useId..'EditBoxHeader']:GetText(),'%[') then
             local newText =  string.gsub(_G['ChatFrame'..useId..'EditBoxHeader']:GetText(),': ','')
             _G['ChatFrame'..useId..'EditBoxHeader']:SetText('['..newText..'] ')
            end
        end)
        
        
        
        
        _G['ChatFrame'..useId].gwhasBeenHooked = true
    end
    
    
    _G['ChatFrame'..useId..'ButtonFrameUpButton']:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\arrowup_down')
    _G['ChatFrame'..useId..'ButtonFrameUpButton']:SetNormalTexture('Interface\\AddOns\\GW2_UI\\textures\\arrowup_up')
    _G['ChatFrame'..useId..'ButtonFrameUpButton']:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\arrowup_down')
    _G['ChatFrame'..useId..'ButtonFrameUpButton']:SetHeight(24)
    _G['ChatFrame'..useId..'ButtonFrameUpButton']:SetWidth(24)
            
    _G['ChatFrame'..useId..'ButtonFrameDownButton']:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down')
    _G['ChatFrame'..useId..'ButtonFrameDownButton']:SetNormalTexture('Interface\\AddOns\\GW2_UI\\textures\\arrowdown_up')
    _G['ChatFrame'..useId..'ButtonFrameDownButton']:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down')
    _G['ChatFrame'..useId..'ButtonFrameDownButton']:SetHeight(24)
    _G['ChatFrame'..useId..'ButtonFrameDownButton']:SetWidth(24)
            
    _G['ChatFrame'..useId..'ButtonFrameBottomButton']:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down')
    _G['ChatFrame'..useId..'ButtonFrameBottomButton']:SetNormalTexture('Interface\\AddOns\\GW2_UI\\textures\\arrowdown_up')
    _G['ChatFrame'..useId..'ButtonFrameBottomButton']:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down')
    _G['ChatFrame'..useId..'ButtonFrameBottomButton']:SetHeight(24)
    _G['ChatFrame'..useId..'ButtonFrameBottomButton']:SetWidth(24)
    
    ChatFrameMenuButton:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\bubble_down')
    ChatFrameMenuButton:SetNormalTexture('Interface\\AddOns\\GW2_UI\\textures\\bubble_up')
    ChatFrameMenuButton:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\bubble_down')
    
    ChatFrameMenuButton:SetHeight(20)
    ChatFrameMenuButton:SetWidth(20)

    _G['ChatFrame'..useId..'TabSelectedRight']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\chattabactiveright')
    _G['ChatFrame'..useId..'TabSelectedLeft']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\chattabactiveleft')            
    _G['ChatFrame'..useId..'TabSelectedMiddle']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\chattabactive')  
    
    
    _G['ChatFrame'..useId..'TabMiddle']:SetHeight(40)
    _G['ChatFrame'..useId..'TabLeft']:SetHeight(40)       
    _G['ChatFrame'..useId..'TabRight']:SetHeight(40)
    
    _G['ChatFrame'..useId..'TabLeft']:SetPoint('BOTTOM',GeneralDockManager,'BOTTOM',0,-4)
    _G['ChatFrame'..useId..'TabMiddle']:SetPoint('BOTTOM',GeneralDockManager,'BOTTOM',0,-4)
            
    _G['ChatFrame'..useId..'TabSelectedRight']:SetBlendMode("BLEND")
    _G['ChatFrame'..useId..'TabSelectedLeft']:SetBlendMode("BLEND")
    _G['ChatFrame'..useId..'TabSelectedMiddle']:SetBlendMode("BLEND")
            
    _G['ChatFrame'..useId..'TabSelectedRight']:SetVertexColor(1,1,1,1)
    _G['ChatFrame'..useId..'TabSelectedLeft']:SetVertexColor(1,1,1,1)
    _G['ChatFrame'..useId..'TabSelectedMiddle']:SetVertexColor(1,1,1,1)
    
    _G['ChatFrame'..useId..'TabText']:SetFont(DAMAGE_TEXT_FONT,14)
    _G['ChatFrame'..useId..'TabText']:SetTextColor(1,1,1)
    
    _G['ChatFrame'..useId..'TabHighlightMiddle']:SetTexture(nil)
    _G['ChatFrame'..useId..'TabHighlightRight']:SetTexture(nil)
    _G['ChatFrame'..useId..'TabHighlightLeft']:SetTexture(nil)
                
    _G['ChatFrame'..useId..'TabMiddle']:SetTexture(nil)
    _G['ChatFrame'..useId..'TabLeft']:SetTexture(nil)
    _G['ChatFrame'..useId..'TabRight']:SetTexture(nil)
    
    
    _G['ChatFrame'..useId..'ButtonFrameTopTexture']:SetTexture(nil)    
    _G['ChatFrame'..useId..'ButtonFrameRightTexture']:SetTexture(nil)    
    _G['ChatFrame'..useId..'ButtonFrameLeftTexture']:SetTexture(nil)    
    _G['ChatFrame'..useId..'ButtonFrameBottomTexture']:SetTexture(nil)    
    _G['ChatFrame'..useId..'TopTexture']:SetTexture(nil)
    _G['ChatFrame'..useId..'BottomTexture']:SetTexture(nil)
    _G['ChatFrame'..useId..'RightTexture']:SetTexture(nil)
    _G['ChatFrame'..useId..'LeftTexture']:SetTexture(nil)
    
    _G['ChatFrame'..useId..'EditBox']:ClearAllPoints()
    _G['ChatFrame'..useId..'EditBox']:SetPoint('TOPLEFT', _G['ChatFrame'..useId..'ButtonFrame'],'BOTTOMLEFT',0,0)
    _G['ChatFrame'..useId..'EditBox']:SetPoint('TOPRIGHT', _G['ChatFrame'..useId..'Background'],'BOTTOMRIGHT',0,0)
  
    _G['ChatFrame'..useId..'EditBoxRight']:SetTexture(nil)   
    _G['ChatFrame'..useId..'EditBoxLeft']:SetTexture(nil)   
    _G['ChatFrame'..useId..'EditBoxMid']:SetTexture(nil)   
    
 
    
    _G['ChatFrame'..useId..'EditBoxFocusRight']:SetTexture(nil)
    _G['ChatFrame'..useId..'EditBoxFocusLeft']:SetTexture(nil)
    _G['ChatFrame'..useId..'EditBoxFocusMid']:SetTexture(nil)
    

    
    
end

function gw_chatBackgroundOnResize(self)
    local w,h = self:GetSize();
    
    w = math.min(1,w/512)
    h = math.min(1,h/512) 
    
    self.texture:SetTexCoord(0,w,1-h,1);
    
end

