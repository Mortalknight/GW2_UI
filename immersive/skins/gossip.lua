local _, GW = ...
local GetSetting = GW.GetSetting
local CharacterMenuButton_OnLoad = GW.CharacterMenuButton_OnLoad
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation


--[[

TODO Greetings text above the model frame

[646979]="Interface/GossipFrame/ActiveLegendaryQuestIcon", 646979
[132048]="Interface/GossipFrame/ActiveQuestIcon", 132048
[646980]="Interface/GossipFrame/AvailableLegendaryQuestIcon", 646980
[132049]="Interface/GossipFrame/AvailableQuestIcon", 132049
[132050]="Interface/GossipFrame/BankerGossipIcon", 132050
[132051]="Interface/GossipFrame/BattleMasterGossipIcon",132051
[132052]="Interface/GossipFrame/BinderGossipIcon", 132054
[3532316]="Interface/GossipFrame/CampaignActiveQuestIcon", 3532316
[3532317]="Interface/GossipFrame/CampaignAvailableQuestIcon", 3532317
[3595324]="Interface/GossipFrame/CampaignGossipIcons",
[3532318]="Interface/GossipFrame/CampaignIncompleteQuestIcon",3532318
[1019848]="Interface/GossipFrame/ChatBubbleGossipIcon",132053
[368577]="Interface/GossipFrame/DailyActiveQuestIcon",368577
[368364]="Interface/GossipFrame/DailyQuestIcon", 368364
[132053]="Interface/GossipFrame/GossipGossipIcon",132053
[132054]="Interface/GossipFrame/HealerGossipIcon", 132054
[365195]="Interface/GossipFrame/IncompleteQuestIcon", 365195
[132055]="Interface/GossipFrame/PetitionGossipIcon", 132055
[132056]="Interface/GossipFrame/TabardGossipIcon", 132056
[132057]="Interface/GossipFrame/TaxiGossipIcon", 132057
[132058]="Interface/GossipFrame/TrainerGossipIcon", 132058
[132059]="Interface/GossipFrame/UnlearnGossipIcon", 132059
[132060]="Interface/GossipFrame/VendorGossipIcon", 132060
[1130518]="Interface/GossipFrame/WorkOrderGossipIcon", 1130518
[528409]="Interface/GossipFrame/auctioneerGossipIcon", 528409
[1673939]="Interface/GossipFrame/transmogrifyGossipIcon", 1673939

["Interface/GossipFrame/CampaignGossipIcons"]={
		["CampaignActiveDailyQuestIcon"]={16, 16, 0.0078125, 0.195312, 0.015625, 0.390625, false, false, "1x"},
		["CampaignActiveQuestIcon"]={16, 16, 0.0078125, 0.195312, 0.421875, 0.796875, false, false, "1x"},
		["CampaignAvailableDailyQuestIcon"]={16, 16, 0.210938, 0.398438, 0.015625, 0.390625, false, false, "1x"},
		["CampaignAvailableQuestIcon"]={16, 16, 0.210938, 0.398438, 0.421875, 0.796875, false, false, "1x"},
		["CampaignIncompleteQuestIcon"]={16, 16, 0.414062, 0.601562, 0.015625, 0.390625, false, false, "1x"},

]]

local CUSTOM_ICONS = {
  [646979]= 646979,
  [132048]= 132048,
  [646980]= 646980,
  [132049]= 132049,
  [132050]= 132050,
  [132051]= 132051,
  [132052]= 132054,
  [3532316]= 3532316,
  [3532317]= 3532317,
  [3532318]= 3532318,
  [1019848]= 132053,
  [368577]= 368577,
  [368364]= 368364,
  [132053]= 132053,
  [132054]= 132054,
  [365195]= 365195,
  [132055]= 132055,
  [132056]= 132056,
  [132057]= 132057,
  [132058]= 132058,
  [132059]= 132059,
  [132060]= 132060,
  [1130518]= 1130518,
  [528409]= 528409,
  [1673939]= 1673939,
}

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

local function splitQuest(inputstr)
  local t = {}
  local i = 1
  local length = string.len(inputstr)
  if length<150 then
    t[i] = inputstr
    return t
  end
  local sep = "[\\.|!|?|>]%s+"
  inputstr = inputstr:gsub("\n", " ")
  inputstr = inputstr:gsub(" %s+", " ")
  inputstr = inputstr:gsub("%.%.%.", "…")

  for str in splitIter(inputstr, sep) do
      if str ~= nil and str ~= "" then
          t[i] = str
          i = i + 1
      end
  end
  return t
end

local function ReplaceGossipFormat(button, textFormat, text)
    local newFormat, count = gsub(textFormat, "000000", "ffffff")
    if count > 0 then
        button:SetFormattedText(newFormat, text)
    end
end

local ReplacedGossipColor = {
    ["000000"] = "ffffff",
    ["414141"] = "7b8489",
}

local function ReplaceGossipText(button, text)
    if text and text ~= "" then
        local newText, count = gsub(text, ":32:32:0:0", ":32:32:0:0:64:64:5:59:5:59")
        if count > 0 then
            text = newText
            button:SetFormattedText("%s", text)
        end

        local colorStr, rawText = strmatch(text, "|c[fF][fF](%x%x%x%x%x%x)(.-)|r")
        colorStr = ReplacedGossipColor[colorStr]
        if colorStr and rawText then
            button:SetFormattedText("|cff%s%s|r", colorStr, rawText)
        end
    end
end

local function skinGossipOption(self)
  self.skinned = true

  if self.Icon then
    self.Icon:ClearAllPoints()
    self.Icon:SetPoint("LEFT",self,"LEFT",0,0)
    self.Icon:SetSize(32,32)
    self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/gossip/optionhover")

    local hl = self:GetHighlightTexture()
    hl:ClearAllPoints()
    hl:SetSize(512,64)
    hl:SetBlendMode("BLEND")
    hl:SetDrawLayer("BACKGROUND",-7)
    hl:SetPoint("LEFT",16,0)
    hl:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/optionhover")
    hl:SetVertexColor(1, 1,1, 1)
    hl:Hide()
  --  self:SetInside(background)
    self:HookScript("OnEnter",function()
      hl:Show()
      hl:SetAlpha(0.2)
      AddToAnimation("GOSSIP_OPTIONHOVER", 0, 1, GetTime(), 0.2,
      function()
        local p = animations["GOSSIP_OPTIONHOVER"].progress
        p = math.max(0.2,p)
        hl:SetAlpha(p)
      end)
    end)
    self:HookScript("OnLeave",function()
      hl:Hide()
    end)
  end

  local buttonText = select(3, self:GetRegions())
  if buttonText and buttonText:IsObjectType("FontString") then
    buttonText:ClearAllPoints()
    buttonText:SetPoint("LEFT",self,"LEFT",40,0)
    ReplaceGossipText(self, self:GetText())
    hooksecurefunc(self, "SetText", ReplaceGossipText)
    hooksecurefunc(self, "SetFormattedText", ReplaceGossipFormat)
  end



end
local function updateGossipOption(self)
  if not self.skinned then
    skinGossipOption(self)
  end
  self:SetHeight(32)
  if self.GetElementData~=nil then
    local elementData = self:GetElementData()
    if elementData.buttonType==GOSSIP_BUTTON_TYPE_DIVIDER or  elementData.buttonType==GOSSIP_BUTTON_TYPE_TITLE then
      self:SetHeight(0)
    end
  end

  if self.Icon then
    self.Icon:SetSize(32,32)
    local atlas = self.Icon:GetAtlas()
    if atlas then
      self.Icon:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/"..atlas)
    else

      local t = self.Icon:GetTexture()
      print(t)
      if CUSTOM_ICONS[t] then
        self.Icon:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/".. CUSTOM_ICONS[t])
      else
        GW.Debug("Missing Gossip Icon ID: ", t)
      end
    end

  end
end
-- unit for testing
local function updateModelFrame(self, unit) -- needs to be tested on gnomes
    if unit==nil then
      unit = "npc"
    end
    if ( UnitExists(unit) ) then
        self.modelFrame:SetUnit(unit)
        self.modelFrame:SetAnimation(804)
        self.modelFrame:SetRotation(0)
        self.modelFrame:SetCamDistanceScale(1)
        self.modelFrame:SetPortraitZoom(1) -- 1 = Header; 0.75 = Torso
        --self.modelFrame:SetFacing(5)
        self.modelFrame:SetPaused(true)
        self.backLayer:Show()
        self.modelFrame:Show()
        self.maskLayer:Show()
        self.modelFrame:SetSize(500,500) -- can be moved to the model frame when done here

        -- get frame true size
        local trueSize = self.modelFrame:GetHeight()
        --frame base height; models will be scaled as if the frame was this size
        local size = 200
        local sizeDif = (size / trueSize) / 2

        -- get the camera target for the portrait view
        local fx,fy,fz = self.modelFrame:GetCameraTarget()
        -- get the height ( z ) here for the face
        local _,_, z = self.modelFrame:GetCameraPosition()
        --Let blizzard zoom us out to the frontal view
        self.modelFrame:SetPortraitZoom(0)
        -- rotate the model to the left (very heroic)
        self.modelFrame:SetFacing(-0.30)
        -- make the camera custom so we can change its position and target
        self.modelFrame:MakeCurrentCameraCustom()
        -- we push the model down half step so we dont distort the FOV
        self.modelFrame:SetPosition(0,0,-( z * (sizeDif/2)))
        -- we move set the camere target to the face and move the camere up a half step so we dont distort the FOV
        self.modelFrame:SetCameraTarget(fx,fy,z + ( z * (sizeDif/2)))

        AddToAnimation("GOSSIP_MODEL", 0, 1, GetTime(), 0.8,
        function()
          local p = animations["GOSSIP_MODEL"].progress
          p = math.min(1,math.max(0,(p - 0.5) / 0.5))
          self.modelFrame:SetAlpha(p)

        end)

    else
        self.backLayer:Hide()
        self.modelFrame:Hide()
        self.maskLayer:Hide()
    end
end

local greetingsText
local currentGreetingTextIndex = 0

local function setGreetingsTextPaging(dir,forceIndex)
  local newIndex = currentGreetingTextIndex + dir
  if forceIndex~=nil then
    newIndex = forceIndex
  end
  if greetingsText and #greetingsText>0 and #greetingsText>=newIndex and newIndex>0 then
    currentGreetingTextIndex = newIndex
    GossipFrame.customGossipText:SetText(greetingsText[currentGreetingTextIndex]);

    GossipPaginControler.forward:Show()
    GossipPaginControler.back:Show()
    if #greetingsText==newIndex then
      GossipPaginControler.forward:Hide()
    end
    if newIndex==1 then
      GossipPaginControler.back:Hide()
    end

  end
end
local function setGreetingsText(text)
  greetingsText = splitQuest(text)
  local firstString = ""
  if greetingsText and #greetingsText>0 then
    currentGreetingTextIndex = 1
    firstString = greetingsText[currentGreetingTextIndex]
  end
  setGreetingsTextPaging(0,1)
--  GossipFrame.customGossipText:SetText(firstString);
end



local function LoadGossipSkin()
    if not GetSetting("GOSSIP_SKIN_ENABLED") then return end

    local GossipFrame = GossipFrame

    ItemTextScrollFrameScrollBar:SkinScrollBar()
    ItemTextScrollFrame:SkinScrollFrame()
    GW.HandleTrimScrollBar(GossipFrame.GreetingPanel.ScrollBar)
    GossipFrame.GreetingPanel.GoodbyeButton:Hide()
    GossipFrame.GreetingPanel.GoodbyeButton:StripTextures()
    GossipFrame.GreetingPanel.GoodbyeButton:SkinButton(false, true)

    for i = 1, 4 do
        local notch =  GossipFrame.FriendshipStatusBar["Notch" .. i]
        if notch then
            notch:SetColorTexture(0, 0, 0)
            notch:SetSize(1, 16)
        end
    end

    ItemTextPageText:SetTextColor("P", 1, 1, 1)
    hooksecurefunc(ItemTextPageText, "SetTextColor", function(pageText, headerType, r, g, b)
        if r ~= 1 or g ~= 1 or b ~= 1 then
            pageText:SetTextColor(headerType, 1, 1, 1)
        end
    end)

    ItemTextFrame:StripTextures(true)
    ItemTextFrame:CreateBackdrop()
    QuestFont:SetTextColor(1, 1, 1)
    GossipFrameInset:Hide()
    GossipFramePortrait:Hide()

    if GossipFrame.Background then
        GossipFrame.Background:Hide()
    end

    local tex = ItemTextFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    local w, h = ItemTextFrame:GetSize()
    tex:SetPoint("TOP", ItemTextFrame, "TOP", 0, 20)
    tex:SetSize(w + 50, h + 70)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    ItemTextFrame.tex = tex

    ItemTextScrollFrame:StripTextures()


    GossipFrame:StripTextures()
    GossipFrame:CreateBackdrop()
    tex = GossipFrame:CreateTexture("bg", "BACKGROUND", nil, 0)

    tex:SetPoint("TOPLEFT", GossipFrame, "TOPLEFT", 0, 0)
    tex:SetSize(1024, 512)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/background")
    GossipFrame.tex = tex

    -- list background
    tex = GossipFrame:CreateTexture("listbackground", "BACKGROUND", nil, 1)
    tex:SetPoint("TOPLEFT", GossipFrame, "TOPLEFT", 70, -175)
    tex:SetSize(566, 512)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/listbg")
    GossipFrame.ListBackground = tex
    --create portrait
    local portraitFrame = CreateFrame("Frame", "GwGossipModelFrame", GossipFrame)
    portraitFrame:Show()
    portraitFrame:SetPoint("TOPLEFT", GossipFrame, "TOPLEFT", 548, 24)
    portraitFrame:SetSize(200, 200)

    portraitFrame.backLayer = portraitFrame:CreateTexture(nil, "BACKGROUND", nil, -1)
    --portraitFrame.backLayer:SetTexture("") -- add custom background texture here
    portraitFrame.backLayer:SetPoint("TOPLEFT", portraitFrame)
	portraitFrame.backLayer:SetPoint("BOTTOMRIGHT", portraitFrame)

    portraitFrame.modelFrame = CreateFrame("PlayerModel", nil, portraitFrame, "GW2ModelLevelTemplate")
    portraitFrame.modelFrame:SetModelDrawLayer("ARTWORK")
    portraitFrame.modelFrame:SetPoint("BOTTOM", portraitFrame.backLayer,"BOTTOM",20,0)
---	portraitFrame.modelFrame:SetPoint("BOTTOMRIGHT", portraitFrame.backLayer)

    portraitFrame.maskLayer = portraitFrame:CreateTexture(nil, "ARTWORK", nil, 1)
    portraitFrame.maskLayer:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/modelmask") -- add custom overlay texture here
	  portraitFrame.maskLayer:SetPoint("TOPLEFT", GossipFrame.tex)
    portraitFrame.maskLayer:SetSize(1024,256)

    --custom greetings text string
    local greetings = portraitFrame:CreateFontString(nil, "ARTWORK")
    greetings:SetPoint("TOPLEFT", portraitFrame.maskLayer, "TOPLEFT", 45, -45)
    greetings:SetPoint("BOTTOMRIGHT", portraitFrame.maskLayer, "TOPLEFT", 545, -165)
    greetings:SetJustifyH("LEFT")
    greetings:SetJustifyV("MIDDLE")
    greetings:SetFont(UNIT_NAME_FONT, 14, "OUTLINE")
    greetings:SetText("")
    GossipFrame.customGossipText = greetings

    -- npc name label
    portraitFrame.npcNameLabel = portraitFrame:CreateTexture(nil, "ARTWORK", nil, 2)
    portraitFrame.npcNameLabel:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/npcname")
    portraitFrame.npcNameLabel:SetSize(200, 32)
	portraitFrame.npcNameLabel:SetPoint("TOPLEFT", portraitFrame, "TOPLEFT", -3, -170)

    hooksecurefunc(GossipFrame, "Update",function() updateModelFrame(portraitFrame) end)

    GossipFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE")
    GossipFrameTitleText:ClearAllPoints()
    GossipFrameTitleText:SetPoint("TOPLEFT",portraitFrame.npcNameLabel,"TOPLEFT",5,0)
    GossipFrameTitleText:SetPoint("BOTTOMRIGHT",portraitFrame.npcNameLabel,"BOTTOMRIGHT",-10,0)
    GossipFrameTitleText:SetJustifyH("LEFT")
    GossipFrame.CloseButton:SkinButton(true)
    GossipFrame.CloseButton:SetSize(20, 20)
    GossipFrame.CloseButton:ClearAllPoints()
    GossipFrame.CloseButton:SetPoint("BOTTOMLEFT",portraitFrame.npcNameLabel,"BOTTOMRIGHT",-10,0)
    GossipFrame.CloseButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/gossip/closebutton")
    GossipFrame.CloseButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/gossip/closebutton")
    GossipFrame.CloseButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/gossip/closebutton")
    ItemTextFrameCloseButton:SkinButton(true)
    ItemTextFrameCloseButton:SetSize(20, 20)

    GossipFrame.GreetingPanel.ScrollBox:ClearAllPoints()
    GossipFrame.GreetingPanel.ScrollBox:SetPoint("TOPLEFT",GossipFrame.ListBackground,"TOPLEFT")
    GossipFrame.GreetingPanel.ScrollBox:SetPoint("BOTTOMRIGHT",GossipFrame.ListBackground,"BOTTOMRIGHT",0,126)
    GW.HandleNextPrevButton(ItemTextPrevPageButton)
    GW.HandleNextPrevButton(ItemTextNextPageButton)

    local GossipPaginControler = CreateFrame("Button","GossipPaginControler",GossipFrame)
    local GossipPagingBack = CreateFrame("Button","GossipPagingBack",GossipPaginControler,"GwCharacterMenuButtonBack")
    local GossipPagingForward = CreateFrame("Button","GossipPagingForward",GossipPaginControler,"GwCharacterMenuButtonBack")

    GossipPaginControler:RegisterForClicks("LeftButtonDown","RightButtonDown")

    GossipPaginControler.back = GossipPagingBack
    GossipPaginControler.forward = GossipPagingForward

    GossipPagingBack:ClearAllPoints()
    GossipPagingForward:ClearAllPoints()
    GossipPaginControler:SetSize(64,32)
    GossipPagingForward:SetSize(32,32)
    GossipPagingBack:SetSize(32,32)
    GossipPagingForward:ClearNormalTexture()
    GossipPagingBack:ClearNormalTexture()
    GossipPagingForward.backarrow:SetRotation(math.pi)
    GossipPaginControler:SetPoint("TOPLEFT",greetings,"TOPLEFT",0,0)
    GossipPaginControler:SetPoint("BOTTOMRIGHT",greetings,"BOTTOMRIGHT",0,0)

    GossipPagingForward:SetPoint("RIGHT",portraitFrame.npcNameLabel,"LEFT",-5,0)
    GossipPagingBack:SetPoint("RIGHT",GossipPagingForward,"LEFT",0,0)

    GossipPaginControler:SetScript("OnClick",function(self,button)
      local dir = button=="LeftButton" and 1 or -1
      setGreetingsTextPaging(dir)
     end)
    GossipPagingForward:SetScript("OnClick",function()
      setGreetingsTextPaging(1)
    end)
    GossipPagingBack:SetScript("OnClick",function()
      setGreetingsTextPaging(-1)
    end)

    GossipFrame:HookScript("OnShow",function()


      GossipFrame.CloseButton:Hide()

      AddToAnimation("GOSSIP_FRAME_FADE", 0, 1, GetTime(), 0.4,
      function()
        local p = animations["GOSSIP_FRAME_FADE"].progress
        GossipFrame:SetAlpha(p)
        portraitFrame.npcNameLabel:SetWidth(200*p)
        portraitFrame.npcNameLabel:SetTexCoord(0, p, 0, 1)
      end,nil,function()
          GossipFrame.CloseButton:Show()
      end)
    end)


    local GreetingPanelFirstLoad = true
    hooksecurefunc(GossipFrame.GreetingPanel.ScrollBox, "Update", function(frame)
        for _, button in next, { frame.ScrollTarget:GetChildren() } do
          updateGossipOption(button)
        end
        -- we need to check each button for button type so we dont count titles and spacers
        local numButtons = 0
        GossipFrame.GreetingPanel.ScrollBox:ForEachFrame(function(self)
          local elementData = self:GetElementData()
          if  elementData.buttonType~=GOSSIP_BUTTON_TYPE_DIVIDER and  elementData.buttonType~=GOSSIP_BUTTON_TYPE_TITLE then
            numButtons = numButtons + 1
          end
        end)
        if numButtons>0 then
          GossipFrame.ListBackground:Show()
        else
          GossipFrame.ListBackground:Hide()
        end

        if GreetingPanelFirstLoad then
          GreetingPanelFirstLoad = false
          -- replace the element default size calculator
          GossipFrame.GreetingPanel.ScrollBox.view:SetPadding(10,10,10,10,0);
          GossipFrame.GreetingPanel.ScrollBox.view:SetElementExtentCalculator(function(dataIndex, elementData)
        		if elementData.greetingTextFrame then
        			  setGreetingsText(elementData.text)
        			return 0
        		elseif elementData.buttonType==GOSSIP_BUTTON_TYPE_DIVIDER then
              return 0
            else
        			return 32;
        		end
        	end);
        end
    end)

    local NPCFriendshipStatusBar = GossipFrame.FriendshipStatusBar
    NPCFriendshipStatusBar:StripTextures()
    NPCFriendshipStatusBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
    NPCFriendshipStatusBar.bg = NPCFriendshipStatusBar:CreateTexture(nil, "BACKGROUND")
    NPCFriendshipStatusBar.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg")
    NPCFriendshipStatusBar.bg:SetPoint("TOPLEFT", NPCFriendshipStatusBar, "TOPLEFT", -3, 3)
    NPCFriendshipStatusBar.bg:SetPoint("BOTTOMRIGHT", NPCFriendshipStatusBar, "BOTTOMRIGHT", 3, -3)

    NPCFriendshipStatusBar.icon:ClearAllPoints()
    NPCFriendshipStatusBar.icon:SetPoint("RIGHT", NPCFriendshipStatusBar, "LEFT", 0, -3)
    NPCFriendshipStatusBar.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    --QuestFrame
    local QuestFrame = QuestFrame
    QuestFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    QuestFrame:StripTextures()
    QuestFrame:CreateBackdrop()
    QuestFrame.tex = QuestFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    w, h = QuestFrame:GetSize()
    QuestFrame.tex:SetPoint("TOP", QuestFrame, "TOP", 0, 20)
    QuestFrame.tex:SetSize(w + 50, h + 70)
    QuestFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    QuestFrame.CloseButton:SkinButton(true)
    QuestFrame.CloseButton:SetSize(20, 20)

    QuestFrameDetailPanel:StripTextures(nil, true)
    QuestDetailScrollFrame:StripTextures()
    QuestProgressScrollFrame:StripTextures()
    QuestGreetingScrollFrame:StripTextures()

    QuestFrameGreetingPanel:HookScript("OnShow", function(frame)
        for button in frame.titleButtonPool:EnumerateActive() do
            button.Icon:SetDrawLayer("ARTWORK")

            local text = button:GetFontString():GetText()
            if text and strfind(text, "|cff000000") then
                button:GetFontString():SetText(gsub(text, "|cff000000", "|cffffe519"))
            end
        end
    end)

    local sealFrameTextColor = {
        ["480404"] = "c20606",
        ["042c54"] = "1c86ee",
    }

    if not GW.QuestInfo_Display_hooked then
        hooksecurefunc("QuestInfo_Display", GW.QuestInfo_Display)
        GW.QuestInfo_Display_hooked = true
    end
    hooksecurefunc("QuestFrame_SetTitleTextColor", function(self)
        self:SetTextColor(1, 0.8, 0.1)
    end)
    hooksecurefunc("QuestFrame_SetTextColor", function(self)
        self:SetTextColor(1, 1, 1)
    end)
    hooksecurefunc("QuestFrameProgressItems_Update", function()
        QuestProgressRequiredItemsText:SetTextColor(1, 0.8, 0.1)
        QuestProgressRequiredMoneyText:SetTextColor(1, 1, 1)
    end)
    hooksecurefunc("QuestInfo_ShowRequiredMoney", function()
        local requiredMoney = GetQuestLogRequiredMoney()
        if requiredMoney > 0 then
            if requiredMoney > GetMoney() then
                QuestInfoRequiredMoneyText:SetTextColor(0.63, 0.09, 0.09)
            else
                QuestInfoRequiredMoneyText:SetTextColor(1, 0.8, 0.1)
            end
        end
    end)
    hooksecurefunc(QuestInfoSealFrame.Text, "SetText", function(self, text)
        if text and text ~= "" then
            local colorStr, rawText = strmatch(text, "|c[fF][fF](%x%x%x%x%x%x)(.-)|r")
            if colorStr and rawText then
                colorStr = sealFrameTextColor[colorStr] or "99ccff"
                self:SetFormattedText("|cff%s%s|r", colorStr, rawText)
            end
        end
    end)
    hooksecurefunc("QuestFrameProgressItems_Update", function()
        QuestProgressRequiredItemsText:SetTextColor(1, 0.8, 0.1)
        QuestProgressRequiredMoneyText:SetTextColor(1, 1, 1)
    end)

    -- questview handles required item styling when it is enabled
    if not GetSetting("QUESTVIEW_ENABLED") then
        for i = 1, 6 do
            local button = _G["QuestProgressItem" .. i]
            local icon = _G["QuestProgressItem" .. i .. "IconTexture"]
            icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            button:StripTextures()
            button:SetFrameLevel(button:GetFrameLevel() +1)
        end
    end

    QuestFrameDetailPanel.SealMaterialBG:SetAlpha(0)
    QuestFrameRewardPanel.SealMaterialBG:SetAlpha(0)
    QuestFrameProgressPanel.SealMaterialBG:SetAlpha(0)
    QuestFrameGreetingPanel.SealMaterialBG:SetAlpha(0)

    QuestFrameGreetingPanel:StripTextures(true)
    QuestFrameGreetingGoodbyeButton:SkinButton(false, true)
    QuestGreetingFrameHorizontalBreak:Kill()

    QuestDetailScrollChildFrame:StripTextures(true)
    QuestRewardScrollChildFrame:StripTextures(true)
    QuestFrameProgressPanel:StripTextures(true)
    QuestFrameRewardPanel:StripTextures(true)

    QuestRewardScrollFrame.ScrollBar:SkinScrollBar()
    QuestRewardScrollFrame:SkinScrollFrame()
    QuestProgressScrollFrameScrollBar:SkinScrollBar()
    QuestProgressScrollFrame:SkinScrollFrame()
    QuestDetailScrollFrame.ScrollBar:SkinScrollBar()
    QuestDetailScrollFrame:SkinScrollFrame()

    QuestFrameAcceptButton:SkinButton(false, true)
    QuestFrameDeclineButton:SkinButton(false, true)
    QuestFrameCompleteButton:SkinButton(false, true)
    QuestFrameGoodbyeButton:SkinButton(false, true)
    QuestFrameCompleteQuestButton:SkinButton(false, true)

    QuestNPCModelTextFrame:StripTextures()
    w, h = QuestNPCModelTextFrame:GetSize()
    QuestNPCModelTextFrame:StripTextures()
    QuestNPCModelTextFrame.tex = QuestNPCModelTextFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    QuestNPCModelTextFrame.tex:SetPoint("TOP", QuestNPCModelTextFrame, "TOP", 0, 20)
    QuestNPCModelTextFrame.tex:SetSize(w + 30, h + 60)
    QuestNPCModelTextFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    -- mover
    GossipFrame.mover = CreateFrame("Frame", nil, GossipFrame)
    GossipFrame.mover:EnableMouse(true)
    GossipFrame:SetMovable(true)
    GossipFrame.mover:SetSize(w, 30)
    GossipFrame.mover:SetPoint("BOTTOMLEFT", GossipFrame, "TOPLEFT", 0, -20)
    GossipFrame.mover:SetPoint("BOTTOMRIGHT", GossipFrame, "TOPRIGHT", 0, 20)
    GossipFrame.mover:RegisterForDrag("LeftButton")
    GossipFrame:SetClampedToScreen(true)
    GossipFrame.mover:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
    end)
    GossipFrame.mover:SetScript("OnDragStop", function(self)
        self:GetParent():StopMovingOrSizing()
    end)

    QuestLogPopupDetailFrame:StripTextures(nil, true)
    QuestLogPopupDetailFrame:CreateBackdrop()
    tex = QuestLogPopupDetailFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    w, h = QuestLogPopupDetailFrame:GetSize()
    tex:SetPoint("TOP", QuestLogPopupDetailFrame, "TOP", 0, 20)
    tex:SetSize(w + 50, h + 70)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    QuestLogPopupDetailFrame.tex = tex

    QuestLogPopupDetailFrameAbandonButton:SkinButton(false, true)
    QuestLogPopupDetailFrameShareButton:SkinButton(false, true)
    QuestLogPopupDetailFrameTrackButton:SkinButton(false, true)
    QuestLogPopupDetailFrameCloseButton:SkinButton(true)
    QuestLogPopupDetailFrameCloseButton:SetSize(20, 20)

    QuestLogPopupDetailFrameScrollFrame:StripTextures()
    QuestLogPopupDetailFrameScrollFrameScrollBar:SkinScrollBar()
    QuestLogPopupDetailFrameScrollFrame:SkinScrollFrame()
end
GW.LoadGossipSkin = LoadGossipSkin
