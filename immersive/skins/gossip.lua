local _, GW = ...
local GetSetting = GW.GetSetting


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
    self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover")

    local hl = self:GetHighlightTexture()
    hl:SetVertexColor(0.8, 0.8, 0.8, 0.8)
  --  self:SetInside(background)
    self:HookScript("OnEnter",function()
      GW.TriggerButtonHoverAnimation(self,hl)
    end)
  end

  local buttonText = select(3, self:GetRegions())
  if selfText and buttonText:IsObjectType("FontString") then
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
  end
end

local function updateModelFrame(self)
    print("Model frame update")
    if ( UnitExists("npc") ) then
        self.modelFrame:SetUnit("npc")
        self.modelFrame:SetAnimation(804)
        self.modelFrame:SetRotation(0)
        self.modelFrame:SetCamDistanceScale(1)
        self.modelFrame:SetPortraitZoom(1) -- 1 = Header; 0.75 = Torso
        --self.modelFrame:SetFacing(5)
        self.modelFrame:SetPaused(false)

        self.backLayer:Show()
        self.modelFrame:Show()
        self.maskLayer:Show()
    --    self:SetCamera({4.8, 0.1707, -0.04, )
            --	self:MakeCurrentCameraCustom();

        --  local cameraID = C_TransmogCollection.GetAppearanceCameraID(322,1);
    --    print(cameraID)
        --	self:RefreshCamera();
            --Model_ApplyUICamera(self, 1712)
    --    self:FreezeAnimation(804,0,1)
    --  self:SetCamera(0)
        --Model_ApplyUICamera(self,7)
    else
        self.backLayer:Hide()
        self.modelFrame:Hide()
        self.maskLayer:Hide()
    end


end

local function LoadGossipSkin()
    if not GetSetting("GOSSIP_SKIN_ENABLED") then return end

    local GossipFrame = GossipFrame

    ItemTextScrollFrameScrollBar:SkinScrollBar()
    ItemTextScrollFrame:SkinScrollFrame()
    GW.HandleTrimScrollBar(GossipFrame.GreetingPanel.ScrollBar)
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

    --custom greetings text string
    local greetings = GossipFrame:CreateFontString(nil, "ARTWORK")
    greetings:SetPoint("TOPLEFT", GossipFrame, "TOPLEFT", 45, -45)
    greetings:SetPoint("BOTTOMRIGHT", GossipFrame, "TOPLEFT", 592, -165)
    greetings:SetJustifyH("LEFT")
    greetings:SetJustifyV("MIDDLE")
    greetings:SetFont(UNIT_NAME_FONT, 14, "OUTLINE")
    greetings:SetText("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
    GossipFrame.customGossipText = greetings

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
    portraitFrame.modelFrame:SetPoint("TOPLEFT", portraitFrame.backLayer)
	portraitFrame.modelFrame:SetPoint("BOTTOMRIGHT", portraitFrame.backLayer)

    portraitFrame.maskLayer = portraitFrame:CreateTexture(nil, "ARTWORK", nil, 1)
    --portraitFrame.maskLayer:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/staggaer-animation") -- add custom overlay texture here
	portraitFrame.maskLayer:SetPoint("TOPLEFT", portraitFrame.backLayer)
	portraitFrame.maskLayer:SetPoint("BOTTOMRIGHT", portraitFrame.backLayer)

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
    GossipFrame.GreetingPanel.ScrollBox:SetPoint("BOTTOMRIGHT",GossipFrame.ListBackground,"BOTTOMRIGHT")
    GW.HandleNextPrevButton(ItemTextPrevPageButton)
    GW.HandleNextPrevButton(ItemTextNextPageButton)


    local GreetingPanelFirstLoad = true
    hooksecurefunc(GossipFrame.GreetingPanel.ScrollBox, "Update", function(frame)
        for _, button in next, { frame.ScrollTarget:GetChildren() } do
          updateGossipOption(button)
        end
        if GreetingPanelFirstLoad then
          GreetingPanelFirstLoad = false
          -- replace the element default size calculator
          GossipFrame.GreetingPanel.ScrollBox.view:SetPadding(10,10,10,10,0);
          GossipFrame.GreetingPanel.ScrollBox.view:SetElementExtentCalculator(function(dataIndex, elementData)
        		if elementData.greetingTextFrame then
        			   GossipFrame.customGossipText:SetText(elementData.text);
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
