
local defaults_CHAT_FRAME_TEXTURES = CHAT_FRAME_TEXTURES
local defaults_CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA =CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA
local defaults_CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA =CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA
local defaults_CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA =CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA
local defaults_CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA =CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA
local defaults_CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA =CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA
local defaults_CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA =CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA
local defaults_CHAT_FRAME_FADE_OUT_TIME = CHAT_FRAME_FADE_OUT_TIME
local defaults_DEFAULT_CHATFRAME_ALPHA = DEFAULT_CHATFRAME_ALPHA
local defaults_DEFAULT_CHATFRAME_COLOR = DEFAULT_CHATFRAME_COLOR
local defaults_DEFAULT_TAB_SELECTED_COLOR_TABLE_ = DEFAULT_TAB_SELECTED_COLOR_TABLE_
local defaults_FCF_SetWindowColor = FCF_SetWindowColor
local defaults_FCFTab_UpdateColors = FCFTab_UpdateColors
local defaults_FCF_FadeInChatFrame
local defaults_FCF_FadeOutChatFrame

function setDefaults()

    CHAT_FRAME_TEXTURES = defaults_CHAT_FRAME_TEXTURES
    CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA =defaults_CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA
    CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA =defaults_CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA
    CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA =defaults_CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA
    CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA =defaults_CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA
    CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA =defaults_CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA
    CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA =defaults_CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA
    CHAT_FRAME_FADE_OUT_TIME =defaults_CHAT_FRAME_FADE_OUT_TIME
    DEFAULT_CHATFRAME_ALPHA =defaults_DEFAULT_CHATFRAME_ALPHA
    DEFAULT_CHATFRAME_COLOR =defaults_DEFAULT_CHATFRAME_COLOR
    DEFAULT_TAB_SELECTED_COLOR_TABLE_ =defaults_DEFAULT_TAB_SELECTED_COLOR_TABLE_
    FCF_SetWindowColor =defaults_FCF_SetWindowColor
    FCFTab_UpdateColors =defaults_FCFTab_UpdateColors
    
end

function setCustoms()
    CHAT_FRAME_TEXTURES = {
    "Background",
    "TopLeftTexture",
    "BottomLeftTexture",
    "TopRightTexture",
    "BottomRightTexture",
    "LeftTexture",
    "RightTexture",
    "BottomTexture",
    "TopTexture",
    --"ResizeButton",
     
    "ButtonFrame",
    "EditBox",
    "ResizeButton",
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
CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1;
CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0;
CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1;
CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 0;
CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1;
CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0;

CHAT_FRAME_FADE_OUT_TIME = 1
 
DEFAULT_CHATFRAME_ALPHA = 1;

DEFAULT_CHATFRAME_COLOR = {r = 1, g = 1, b = 1};
DEFAULT_TAB_SELECTED_COLOR_TABLE_= { r = 1, g = 1, b = 1, };


end
    

local editboxHasFocus = false


function FCF_SetWindowColor(frame, r, g, b, doNotSave)
  --  chatFrameBg()
end
function FCFTab_UpdateColors(self, selected)
    if ( selected ) then
        self.leftSelectedTexture:Show();
        self.middleSelectedTexture:Show();
        self.rightSelectedTexture:Show();
    else
        self.leftSelectedTexture:Hide();
        self.middleSelectedTexture:Hide();
        self.rightSelectedTexture:Hide();
    end
     
    local colorTable = self.selectedColorTable or DEFAULT_TAB_SELECTED_COLOR_TABLE;
     
    if ( self.selectedColorTable ) then
        self:GetFontString():SetTextColor(colorTable.r, colorTable.g, colorTable.b);
    else
        self:GetFontString():SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
    end
     
    self.leftSelectedTexture:SetVertexColor(1,1,1);
    self.middleSelectedTexture:SetVertexColor(1,1,1);
    self.rightSelectedTexture:SetVertexColor(1,1,1);
     
    self.leftHighlightTexture:SetVertexColor(1,1,1);
    self.middleHighlightTexture:SetVertexColor(1,1,1);
    self.rightHighlightTexture:SetVertexColor(1,1,1);
    self.glow:SetVertexColor(1,1,1);
     
    if ( self.conversationIcon ) then
        self.conversationIcon:SetVertexColor(colorTable.r, colorTable.g, colorTable.b);
    end
     
    local minimizedFrame = _G["ChatFrame"..self:GetID().."Minimized"];
    if ( minimizedFrame ) then
        minimizedFrame.selectedColorTable = self.selectedColorTable;
        FCFMin_UpdateColors(minimizedFrame);
    end
end
function FCF_FadeInChatFrame(chatFrame)
    local frameName = chatFrame:GetName();
    if frameName=='table' then 
        return
    end
    chatFrame.hasBeenFaded = true;
    for index, value in pairs(CHAT_FRAME_TEXTURES) do
        local object = _G[frameName..value];
        if ( object:IsShown() ) then
            UIFrameFadeIn(object, CHAT_FRAME_FADE_TIME, object:GetAlpha(), 1);
        end
    end
    if ( chatFrame == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) ) then
        for _, frame in pairs(FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)) do
            if ( frame ~= chatFrame ) then
                FCF_FadeInChatFrame(frame);
            end
        end
        if ( GENERAL_CHAT_DOCK.overflowButton:IsShown() ) then
            UIFrameFadeIn(GENERAL_CHAT_DOCK.overflowButton, CHAT_FRAME_FADE_TIME, GENERAL_CHAT_DOCK.overflowButton:GetAlpha(), 1);
        end
    end
     
    local chatTab = _G[frameName.."Tab"];
    UIFrameFadeIn(chatTab, CHAT_FRAME_FADE_TIME, chatTab:GetAlpha(), 1);
     
    --Fade in the button frame
    if ( not chatFrame.isDocked ) then
        UIFrameFadeIn(chatFrame.buttonFrame, CHAT_FRAME_FADE_TIME, chatFrame.buttonFrame:GetAlpha(), 1);
    end
    UIFrameFadeIn(FriendsMicroButton, CHAT_FRAME_FADE_TIME, chatFrame.buttonFrame:GetAlpha(), 1);
    UIFrameFadeIn(ChatFrameMenuButton, CHAT_FRAME_FADE_TIME, chatFrame.buttonFrame:GetAlpha(), 1);
    UIFrameFadeIn(GeneralDockManager, CHAT_FRAME_FADE_TIME, chatFrame.buttonFrame:GetAlpha(), 1);
end
function FCF_FadeOutChatFrame(chatFrame)
    
    if editboxHasFocus then
        return
    end
    if GW2UI_SETTINGS['CHATFRAME_FADE']==false then
        return
    end
    
    local frameName = chatFrame:GetName();
    chatFrame.hasBeenFaded = nil;
    for index, value in pairs(CHAT_FRAME_TEXTURES) do
        -- Fade out chat frame
        local object = _G[frameName..value];
        if ( object:IsShown() ) then
            UIFrameFadeOut(object, CHAT_FRAME_FADE_OUT_TIME, max(object:GetAlpha(), chatFrame.oldAlpha), 0);
        end
    end
    if ( chatFrame == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) ) then
        for _, frame in pairs(FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)) do
            if ( frame ~= chatFrame ) then
                FCF_FadeOutChatFrame(frame);
            end
        end
        if ( GENERAL_CHAT_DOCK.overflowButton:IsShown() ) then
            UIFrameFadeOut(GENERAL_CHAT_DOCK.overflowButton, CHAT_FRAME_FADE_OUT_TIME, GENERAL_CHAT_DOCK.overflowButton:GetAlpha(), 0);
        end
    end
     
    local chatTab = _G[frameName.."Tab"];
    UIFrameFadeOut(chatTab, CHAT_FRAME_FADE_OUT_TIME, chatTab:GetAlpha(), chatTab.noMouseAlpha);
     
    --Fade out the ButtonFrame
    if ( not chatFrame.isDocked ) then
        UIFrameFadeOut(chatFrame.buttonFrame, CHAT_FRAME_FADE_OUT_TIME, chatFrame.buttonFrame:GetAlpha(), 0);
    end

    UIFrameFadeOut(FriendsMicroButton,CHAT_FRAME_FADE_OUT_TIME, chatFrame.buttonFrame:GetAlpha(), 0);
    UIFrameFadeOut(ChatFrameMenuButton,CHAT_FRAME_FADE_OUT_TIME, chatFrame.buttonFrame:GetAlpha(), 0);
    UIFrameFadeOut(GeneralDockManager,CHAT_FRAME_FADE_OUT_TIME, chatFrame.buttonFrame:GetAlpha(), 0);
end

function chatFrameBg()

    GeneralDockManager.texture = GeneralDockManager:CreateTexture()
    GeneralDockManager.texture:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\chatdockbg')
    GeneralDockManager.texture:SetPoint('LEFT',GeneralDockManager,'LEFT',-32,0)
    GeneralDockManager.texture:SetWidth(GeneralDockManager:GetWidth()+32)

     FriendsMicroButton:SetDisabledTexture('Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Up'); 
        FriendsMicroButton:SetNormalTexture('Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Up'); 
        FriendsMicroButton:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down'); 
        FriendsMicroButton:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\LFDMicroButton-Down'); 
        FriendsMicroButton:SetWidth(25) 
        FriendsMicroButton:SetHeight(25) 
    
        ChatFrameMenuButton:SetPushedTexture('Interface\\AddOns\\GW2_UI\\textures\\bubble_down')
        ChatFrameMenuButton:SetNormalTexture('Interface\\AddOns\\GW2_UI\\textures\\bubble_up')
        ChatFrameMenuButton:SetHighlightTexture('Interface\\AddOns\\GW2_UI\\textures\\bubble_down')
    
        ChatFrameMenuButton:SetHeight(20)
        ChatFrameMenuButton:SetWidth(20)

    for i = 1,10 do
        
        local useId = i
        
        if _G['ChatFrame'..useId..'Background'] then
            
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
            
            _G['ChatFrame'..useId..'TabText']:SetFont(UNIT_NAME_FONT,12)
            _G['ChatFrame'..useId..'TabText']:SetTextColor(1,1,1)

          _G['ChatFrame'..useId..'Background']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\chatframebackground')
          _G['ChatFrame'..useId..'ButtonFrameBackground']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\chatframebackground')
            
            _G['ChatFrame'..useId..'TabSelectedRight']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\chattabactiveright')
            _G['ChatFrame'..useId..'TabSelectedLeft']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\chattabactiveleft')            
            _G['ChatFrame'..useId..'TabSelectedMiddle']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\chattabactive')
            
            _G['ChatFrame'..useId..'TabSelectedRight']:SetBlendMode("BLEND")
            _G['ChatFrame'..useId..'TabSelectedLeft']:SetBlendMode("BLEND")
            _G['ChatFrame'..useId..'TabSelectedMiddle']:SetBlendMode("BLEND")
            
            _G['ChatFrame'..useId..'TabSelectedRight']:SetVertexColor(1,1,1,1)
            _G['ChatFrame'..useId..'TabSelectedLeft']:SetVertexColor(1,1,1,1)
            _G['ChatFrame'..useId..'TabSelectedMiddle']:SetVertexColor(1,1,1,1)
           
          
            
            _G['ChatFrame'..useId..'EditBox']:HookScript('OnEditFocusGained',function()
                    
                    editboxHasFocus= true
                   FCF_FadeInChatFrame(_G['ChatFrame'..useId])
            end)
            _G['ChatFrame'..useId..'EditBox']:HookScript('OnEditFocusLost',function()
                    editboxHasFocus= false
            end)
            
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
            
          _G['ChatFrame'..useId..'EditBoxRight']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\chateditboxright')
          _G['ChatFrame'..useId..'EditBoxLeft']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\chateditboxleft')
          _G['ChatFrame'..useId..'EditBoxMid']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\chateditboxmid')
            
        _G['ChatFrame'..useId..'EditBoxFocusRight']:SetTexture(nil)
          _G['ChatFrame'..useId..'EditBoxFocusLeft']:SetTexture(nil)
          _G['ChatFrame'..useId..'EditBoxFocusMid']:SetTexture(nil)
        _G['ChatFrame'..useId..'EditBox']:Show()
        if _G['ChatFrame'..useId..'EditBox'] then
            
                _G['ChatFrame'..useId..'EditBox']:SetScript('OnHide',function(self) self:Show() 
                    end)
        end
           
        end
        
    end
    
end

local chatFrameOnload = CreateFrame('frame',nil,UIParent)

chatFrameOnload:SetScript('OnUpdate',function()
    if GW2UI_SETTINGS['SETTINGS_LOADED'] == false then
        return
    end
        
    if GW2UI_SETTINGS['DISABLE_CHATFRAME']==false then
        setCustoms()
        chatFrameBg()
        FCF_FadeOutChatFrame(ChatFrame1)
    else
        setDefaults()
    end
    
  
    chatFrameOnload:SetScript('OnUpdate',nil)
end)
