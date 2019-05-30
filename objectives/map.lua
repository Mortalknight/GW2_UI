GW_MAP_FRAMES_HIDE ={}
GW_MAP_FRAMES_HIDE[1] =MiniMapMailFrame 
GW_MAP_FRAMES_HIDE[2] =MinimapCluster
GW_MAP_FRAMES_HIDE[3] =GameTimeFrame

local Minimap_Addon_Buttons = {
    
    [1] = "MiniMapTrackingFrame",
	[2] = "MiniMapMeetingStoneFrame",
	[3] = "MiniMapMailFrame",
	[4] = "MiniMapBattlefieldFrame",
	[5] = "MiniMapWorldMapButton",
	[6] = "MiniMapPing",
	[7] = "MinimapBackdrop",
	[8] = "MinimapZoomIn",
	[9] = "MinimapZoomOut",
	[10] = "BookOfTracksFrame",
	[11] = "GatherNote",
	[12] = "FishingExtravaganzaMini",
	[13] = "MiniNotePOI",
	[14] = "RecipeRadarMinimapIcon",
	[15] = "FWGMinimapPOI",
	[16] = "CartographerNotesPOI",
	[17] = "MBB_MinimapButtonFrame",
	[18] = "EnhancedFrameMinimapButton",
	[19] = "GFW_TrackMenuFrame",
	[20] = "GFW_TrackMenuButton",
	[21] = "TDial_TrackingIcon",
	[22] = "TDial_TrackButton",
	[23] = "MiniMapTracking",
	[24] = "GatherMatePin",
	[25] = "HandyNotesPin",
	[26] = "TimeManagerClockButton",
	[27] = "GameTimeFrame",
	[28] = "DA_Minimap",
	[29] = "ElvConfigToggle",
	[30] = "MiniMapInstanceDifficulty",
	[31] = "MinimapZoneTextButton",
	[32] = "GuildInstanceDifficulty",
	[33] = "MiniMapVoiceChatFrame",
	[34] = "MiniMapRecordingButton",
	[35] = "QueueStatusMinimapButton",
	[36] = "GatherArchNote",
	[37] = "ZGVMarker",
	[38] = "QuestPointerPOI",
	[39] = "poiMinimap",
	[40] = "MiniMapLFGFrame", 
	[41] = "PremadeFilter_MinimapButton", 
	[42] = "GwMapTime"
    
}



GW_MAP_FRAMES_HOVER = {}

local animationIndex = 0
local animationIndexY = 0
local anim_thro = 0
local framesToAdd = {}


function gwSetMinimapHover()
	if gwGetSetting('MINIMAP_HOVER') == 'NONE' then
		GW_MAP_FRAMES_HOVER[1] = 'mapGradient'
		GW_MAP_FRAMES_HOVER[2] = 'MinimapZoneText'
	elseif gwGetSetting('MINIMAP_HOVER') == 'CLOCK' then
		GW_MAP_FRAMES_HOVER[1] = 'mapGradient'
		GW_MAP_FRAMES_HOVER[2] = 'MinimapZoneText'
	elseif gwGetSetting('MINIMAP_HOVER') == 'ZONE' then

	end
end


 function stackMinimapIcons(self,event) 
 
	for _, frame in pairs(framesToAdd) do 
        frame:SetParent(Minimap)
    end
    
    local foundFrames = false;
    framesToAdd = {}
	
    local children = {Minimap:GetChildren()};
    for _, child in ipairs(children) do
        if child:HasScript("OnClick") and child:IsShown() and child:GetName() then
            local ignore = false
            local childName = child:GetName()
            for _, v in pairs(Minimap_Addon_Buttons) do 
				local namecompare = string.sub(childName,1,string.len(v))
				if v==namecompare then
					ignore = true
					break;
				end
			end
            if not ignore then
                foundFrames = true
                framesToAdd[#framesToAdd + 1] = child;
            end
        end
    end
    
    if not foundFrames then return end
    
        
    CreateFrame('Button','GwAddonToggle',UIParent,'GwAddonToggle')
	GwAddonToggle:SetPoint('TOPRIGHT',Minimap,'TOPLEFT',-5.5,-127)
	_G['GwAddonToggleTexture']:SetTexCoord(0,0.5,0,0.25)
    
    GwAddonToggle.container:SetWidth(#framesToAdd * 35)
	GwAddonToggle:SetFrameStrata('HIGH')
    local frameIndex = 0
    for _, frame in pairs(framesToAdd) do 
        frame:SetParent(GwAddonToggle.container)
        frame:ClearAllPoints()
        frame:SetPoint('RIGHT',GwAddonToggle.container,'RIGHT',frameIndex*-36,0);
        frameIndex = frameIndex + 1;
        frame:SetScript('OnDragStart',nil)
    end
        
    
end



function gw_set_minimap()
    
    local GwMinimapShadow = CreateFrame('Frame','GwMinimapShadow',Minimap,'GwMinimapShadow')
	
	gwSetMinimapHover()

    Minimap:ClearAllPoints()
    Minimap:SetPoint('BOTTOMRIGHT',UIParent,-5,21)

    Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')
 
    local child = _G[v]

    Minimap:SetParent(UIParent)
	
	Minimap:SetFrameStrata('LOW')
    
    mapGradient = CreateFrame('Frame','GwMapGradient',GwMinimapShadow,'GwMapGradient')
    mapGradient:SetParent(GwMinimapShadow)
    mapGradient:SetPoint('TOPLEFT',Minimap,'TOPLEFT',0,0)
    mapGradient:SetPoint('TOPRIGHT',Minimap,'TOPRIGHT',0,0)
    
    --GwMapTime = CreateFrame('Button','GwMapTime',Minimap,'GwMapTime')
    
    MinimapNorthTag:ClearAllPoints()
    MinimapNorthTag:SetPoint('TOP',Minimap,0,0)

    MinimapCluster:Hide()
    MinimapBorder:Hide()
    MiniMapWorldMapButton:Hide()

    MiniMapMailFrame:ClearAllPoints()
    MinimapZoneText:ClearAllPoints()

    MinimapZoneText:SetParent(mapGradient)
    MinimapZoneText:SetDrawLayer('OVERLAY',2)

    --GameTimeFrame:SetPoint('TOPLEFT',Minimap,-42,0)
    MiniMapMailFrame:SetPoint('TOPLEFT',Minimap,45,15)

    MinimapZoneText:SetTextColor(1,1,1)
    
    hooksecurefunc(MinimapZoneText,'SetText',function() 
        MinimapZoneText:SetTextColor(1,1,1)
    end)
    
    --GameTimeFrame:HookScript('OnShow', function(self) self:Hide() end)
    
    GwCalendarButton = CreateFrame('Button','GwCalendarButton',UIParent,'GwCalendarButton')
    
    
    GwCalendarButton:HookScript('OnEvent',function()
     GameTooltip:SetOwner(self, "ANCHOR_LEFT",0,-30)
    end)
   
    
    GwCalendarButton:SetPoint('TOPRIGHT',Minimap,'TOPLEFT',-7,0)
    
    
    local GwMailButton = CreateFrame('Button','GwMailButton',UIParent,'GwMailButton')
    GwMailButton:SetPoint('TOPRIGHT',Minimap,'TOPLEFT',-12,-47)
    
    GwDateText:SetFont(UNIT_NAME_FONT,14)
    GwDateText:SetTextColor(0,0,0)
    GwDateText:SetText(date('%d'))
    
    hooksecurefunc(Minimap,'SetScale',function()

    end)
    
    stackMinimapIcons()
    Minimap:SetScale(1.2)
    
    MinimapZoneText:ClearAllPoints()
    MinimapZoneText:SetPoint('TOP',Minimap,0,-5)
    

    hideMiniMapIcons()


    Minimap:SetScript('OnEnter', function(self)
        
        hoverMiniMap()
        Minimap:SetScript('OnUpdate',function() checkCursorOverMap() end)
    end)
    

    MinimapZoomIn:Hide()
    MinimapZoomOut:Hide()
    Minimap:EnableMouseWheel(true)

    Minimap:SetScript("OnMouseWheel", function(self, delta)
       if delta > 0 and self:GetZoom() < 5 then
          self:SetZoom(self:GetZoom() + 1)
       elseif delta < 0 and self:GetZoom() > 0 then
          self:SetZoom(self:GetZoom() - 1)
       end
    end)
    

    Minimap:RegisterEvent("PLAYER_ENTERING_WORLD");
    

    Minimap:SetSize(gwGetSetting('MINIMAP_SCALE'),gwGetSetting('MINIMAP_SCALE'))


    hoverMiniMapOut()
   


end
    function hideMiniMapIcons()
        for k,v in pairs(GW_MAP_FRAMES_HIDE) do
           if v then
                v:Hide()
                v:SetScript('OnShow', function(self) self:Hide() end)
            end
        end
        
        Minimap:SetScript('OnUpdate', function()
            
                if TimeManagerClockButton then
                    TimeManagerClockButton:Hide()
                    TimeManagerClockButton:SetScript('OnShow', function(self) self:Hide() end)
                    Minimap:SetScript('OnUpdate',nil)
                end
                
        end)
        
    end

    function checkCursorOverMap()
        if Minimap:IsMouseOver(100, -100, -100, 100) then
            
        else
                hoverMiniMapOut()
              Minimap:SetScript('OnUpdate',nil)
        end
    end


    function hoverMiniMap()
			for k,v in pairs(GW_MAP_FRAMES_HOVER) do
					local child = _G[v]
				UIFrameFadeIn(child, 0.2, child:GetAlpha(),1)

			end
			MinimapNorthTag:Hide()
    end
    function hoverMiniMapOut()
			for k,v in pairs(GW_MAP_FRAMES_HOVER) do
					local child = _G[v]
				UIFrameFadeOut(child, 0.2, child:GetAlpha(),0)
			end
			MinimapNorthTag:Show()
    end
	
function GetMinimapShape()
		return 'SQUARE'
	end
--[[
function GwMapTimeClick(self,button)
	if button == "LeftButton" then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON   );
		
		if IsShiftKeyDown() then
			TimeManager_ToggleLocalTime()
			GwMapTimeOnEnter(self)
		else
			TimeManager_ToggleTimeFormat()
		end
	end
	if button == "RightButton" then
		PlaySound(SOUNDKIT.IG_MAINMENU_QUIT    );
		Stopwatch_Toggle()
	end
end


function GwMapTimeOnEnter(self)
	local string;
	
	if GetCVarBool("timeMgrUseLocalTime") then
		string = TIMEMANAGER_TOOLTIP_LOCALTIME:gsub(":","")
	else
		string = TIMEMANAGER_TOOLTIP_REALMTIME:gsub(":","")
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_TOP",0,5)
    GameTooltip:AddLine(GwLocalization['MAP_CLOCK_TITLE'])
    GameTooltip:AddLine(GwLocalization['MAP_CLOCK_LOCAL_REALM'],1,1,1,TRUE)
    GameTooltip:AddLine(GwLocalization['MAP_CLOCK_STOPWATCH'],1,1,1,TRUE)
    GameTooltip:AddLine(GwLocalization['MAP_CLOCK_MILITARY'],1,1,1,TRUE)
	GameTooltip:AddDoubleLine(GwLocalization['MAP_CLOCK_DISPLAY'],string,nil,nil,nil,1,1,0)
    GameTooltip:SetMinimumWidth(100)								
	GameTooltip:Show()
end
]]


