local _, GW = ...

local function UpdateGreetingFrame()
	local i = 1
	local title = _G['QuestTitleButton'..i]
	while (title and title:IsVisible()) do
		GreetingText:SetTextColor(1, 1, 1)
		CurrentQuestsText:SetTextColor(1, 0.80, 0.10)
		AvailableQuestsText:SetTextColor(1, 0.80, 0.10)

		local text = title:GetFontString()
		local textString = gsub(title:GetText(), '|c[Ff][Ff]%x%x%x%x%x%x(.+)|r', '%1')
		title:SetText(textString)

		local icon = _G['QuestTitleButton'..i..'QuestIcon']
		if title.isActive == 1 then
			icon:SetTexture(132048)
			icon:SetDesaturation(1)
			text:SetTextColor(.6, .6, .6)
		else
			icon:SetTexture(132049)
			icon:SetDesaturation(0)
			text:SetTextColor(1, .8, .1)
		end

		local numEntries = GetNumQuestLogEntries()
		for y = 1, numEntries do
			local titleText, _, _, _, _, isComplete, _, questId = GetQuestLogTitle(y)
			if not titleText then
				break
			elseif strmatch(titleText, textString) and (isComplete == 1 or IsQuestComplete(questId)) then
				icon:SetDesaturation(0)
				text:SetTextColor(1, .8, .1)
				break
			end
		end

		i = i + 1
		title = _G['QuestTitleButton'..i]
	end
end

local function handleItemButton(item)
    if not item then return end

    if item then
        item:GwCreateBackdrop("Transparent", true, -1, -1)
        item:SetSize(143, 40)
        item:SetFrameLevel(item:GetFrameLevel() + 2)
    end

    if item.Icon then
        item.Icon:SetSize(35, 35)
        item.Icon:SetDrawLayer("ARTWORK")
        item.Icon:SetPoint("TOPLEFT", 2 , -2)
        GW.HandleIcon(item.Icon)
    end

    if item.IconBorder then
        GW.HandleIconBorder(item.IconBorder)
    end

    if item.Count then
        item.Count:SetDrawLayer("OVERLAY")
        item.Count:ClearAllPoints()
        item.Count:SetPoint("BOTTOMRIGHT", item.Icon, "BOTTOMRIGHT", 0, 0)
    end

    if item.NameFrame then
        item.NameFrame:SetAlpha(0)
        item.NameFrame:Hide()
    end

    if item.IconOverlay then
        item.IconOverlay:SetAlpha(0)
    end

    if item.Name then
        item.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    end

    if item.CircleBackground then
        item.CircleBackground:SetAlpha(0)
        item.CircleBackgroundGlow:SetAlpha(0)
    end

    for i = 1, item:GetNumRegions() do
        local Region = select(i, item:GetRegions())
        if Region and Region:IsObjectType("Texture") and Region:GetTexture() == [[Interface\Spellbook\Spellbook-Parts]] then
            Region:SetTexture("")
        end
    end
end

local function questQualityColors(frame, text, link)
    if not frame.backdrop then
        handleItemButton(frame)
    end

    local quality = link and select(3, C_Item.GetItemInfo(link))
    if quality and quality > 1 then
        local r, g, b = C_Item.GetItemQualityColor(quality)

        text:SetTextColor(r, g, b)
        frame.backdrop:SetBackdropBorderColor(r, g, b)
    else
        text:SetTextColor(1, 1, 1)
        frame.backdrop:SetBackdropBorderColor(1, 1, 1)
    end
end


local function LoadQuestLogFrameSkin()
    if not GW.settings.QUESTLOG_SKIN_ENABLED then return end

    local QuestStrip = {
		EmptyQuestLogFrame,
		QuestDetailScrollChildFrame,
		QuestDetailScrollFrame,
		QuestFrame,
		QuestFrameDetailPanel,
		QuestFrameGreetingPanel,
		QuestFrameProgressPanel,
		QuestFrameRewardPanel,
		QuestGreetingScrollFrame,
		QuestInfoItemHighlight,
		QuestLogDetailScrollFrame,
		QuestLogFrame,
		QuestLogListScrollFrame,
		QuestLogQuestCount,
		QuestProgressScrollFrame,
		QuestRewardScrollChildFrame,
		QuestRewardScrollFrame
	}
	for _, object in pairs(QuestStrip) do
		object:GwStripTextures(true)
	end

    local QuestButtons = {
		QuestFrameAcceptButton,
		QuestFrameCancelButton,
		QuestFrameCompleteButton,
		QuestFrameCompleteQuestButton,
		QuestFrameDeclineButton,
		QuestFrameGoodbyeButton,
		QuestFrameGreetingGoodbyeButton,
		QuestFramePushQuestButton,
		QuestLogFrameAbandonButton,
		QuestLogFrameTrackButton,
		QuestLogFrameCancelButton
	}
	for _, button in pairs(QuestButtons) do
		button:GwStripTextures()
		button:GwSkinButton(false, true)
	end

    local ScrollBars = {
		QuestDetailScrollFrameScrollBar,
		QuestGreetingScrollFrameScrollBar,
		QuestLogDetailScrollFrameScrollBar,
		QuestLogListScrollFrameScrollBar,
		QuestRewardScrollFrameScrollBar
	}
	for _, object in pairs(ScrollBars) do
		object:GwSkinScrollBar()
	end

    ScrollBars = {
		QuestDetailScrollFrame,
		QuestGreetingScrollFrame,
		QuestLogDetailScrollFrame,
		QuestLogListScrollFrame,
		QuestRewardScrollFrame
	}
	for _, object in pairs(ScrollBars) do
		object:GwSkinScrollFrame()
	end

    for frame, numItems in pairs({ QuestLogItem = MAX_NUM_ITEMS, QuestProgressItem = MAX_REQUIRED_ITEMS }) do
		for i = 1, numItems do
			handleItemButton(_G[frame..i])
		end
	end

    hooksecurefunc('QuestInfo_GetRewardButton', function(rewardsFrame, index)
		local button = rewardsFrame.RewardButtons[index]
		if not button and button.backdrop then return end

		handleItemButton(button)
	end)

	hooksecurefunc('QuestInfoItem_OnClick', function(frame)
		if frame.type == 'choice' then
			frame.backdrop:SetBackdropBorderColor(1, 0.80, 0.10)
			_G[frame:GetName()..'Name']:SetTextColor(1, 0.80, 0.10)

			for i = 1, #QuestInfoRewardsFrame.RewardButtons do
				local item = _G['QuestInfoRewardsFrameQuestInfoItem'..i]

				if item ~= frame then
					local name = _G['QuestInfoRewardsFrameQuestInfoItem'..i..'Name']
					local link = item.type and (QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

					questQualityColors(item, name, link)
				end
			end
		end
	end)

    hooksecurefunc('QuestInfo_ShowRewards', function()
		for i = 1, #QuestInfoRewardsFrame.RewardButtons do
			local item = _G['QuestInfoRewardsFrameQuestInfoItem'..i]
			local name = _G['QuestInfoRewardsFrameQuestInfoItem'..i..'Name']
			local link = item.type and (QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

    hooksecurefunc('QuestInfo_ShowRewards', function()
		for i = 1, #QuestInfoRewardsFrame.RewardButtons do
			local item = _G['QuestInfoRewardsFrameQuestInfoItem'..i]
			local name = _G['QuestInfoRewardsFrameQuestInfoItem'..i..'Name']
			local link = item.type and (QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

    hooksecurefunc('QuestFrameProgressItems_Update', function()
		QuestProgressTitleText:SetTextColor(1, .8, .1)
		QuestProgressText:SetTextColor(1, 1, 1)
		QuestProgressRequiredItemsText:SetTextColor(1, .8, 0.1)

		local moneyToGet = GetQuestMoneyToGet()
		if moneyToGet > 0 then
			if moneyToGet > GetMoney() then
				QuestProgressRequiredMoneyText:SetTextColor(.6, .6, .6)
			else
				QuestProgressRequiredMoneyText:SetTextColor(1, .8, .1)
			end
		end

        if not GW.settings.QUESTVIEW_ENABLED then
            for i = 1, MAX_REQUIRED_ITEMS do
                local item = _G['QuestProgressItem'..i]
                local name = _G['QuestProgressItem'..i..'Name']
                local link = item.type and GetQuestItemLink(item.type, item:GetID())

                questQualityColors(item, name, link)
            end
        end

	end)

    hooksecurefunc('QuestLog_Update', function()
		if not QuestLogFrame:IsShown() then return end
		local numEntries = GetNumQuestLogEntries()
		local scrollOffset = HybridScrollFrame_GetOffset(QuestLogListScrollFrame)
		local buttons = QuestLogListScrollFrame.buttons

		for i = 1, 22 do
			local questIndex = i + scrollOffset
			if questIndex <= numEntries then
				local _, _, _, isHeader, isCollapsed = GetQuestLogTitle(questIndex)
				if isHeader then
					if isCollapsed then
						buttons[i]:SetNormalTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrow_right.png")
					else
						buttons[i]:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
					end
				end
			end
		end
	end)

    hooksecurefunc('QuestLog_UpdateQuestDetails', function()
		local requiredMoney = GetQuestLogRequiredMoney()
		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end
	end)

	hooksecurefunc('QuestLogUpdateQuestCount', function()
		QuestLogCount:ClearAllPoints()
		QuestLogCount:SetPoint('BOTTOMLEFT', QuestLogListScrollFrame.tex, 'TOPLEFT', 0, 5)
	end)

    local textR, textG, textB = 1, 1, 1
	local titleR, titleG, titleB = 1, 0.80, 0.10
    hooksecurefunc('QuestFrameItems_Update', function()
		-- Headers
		QuestLogDescriptionTitle:SetTextColor(titleR, titleG, titleB)
		QuestLogRewardTitleText:SetTextColor(titleR, titleG, titleB)
		QuestLogQuestTitle:SetTextColor(titleR, titleG, titleB)

		-- Other text
		QuestLogItemChooseText:SetTextColor(textR, textG, textB)
		QuestLogItemReceiveText:SetTextColor(textR, textG, textB)
		QuestLogObjectivesText:SetTextColor(textR, textG, textB)
		QuestLogQuestDescription:SetTextColor(textR, textG, textB)
		QuestLogSpellLearnText:SetTextColor(textR, textG, textB)
		QuestInfoQuestType:SetTextColor(textR, textG, textB)

		local requiredMoney = GetQuestLogRequiredMoney()
		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		QuestLogItem1:SetPoint('TOPLEFT', QuestLogItemChooseText, 'BOTTOMLEFT', 1, -3)

		local numVisibleObjectives = 0
		local numObjectives = GetNumQuestLeaderBoards()
		for i = 1, numObjectives do
			local _, objType, finished = GetQuestLogLeaderBoard(i)
			if objType ~= 'spell' then
				numVisibleObjectives = numVisibleObjectives + 1
				local objective = _G['QuestLogObjective'..numVisibleObjectives]

				if objective then
					if finished then
						objective:SetTextColor(1, .8, .1)
					else
						objective:SetTextColor(.63, .09, .09)
					end
				end
			end
		end

		for i = 1, MAX_NUM_ITEMS do
			local item = _G['QuestLogItem'..i]
			local name = _G['QuestLogItem'..i..'Name']
			local link = item.type and (GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

    hooksecurefunc('QuestInfo_Display', function()
		-- Headers
		QuestInfoTitleHeader:SetTextColor(titleR, titleG, titleB)
		QuestInfoDescriptionHeader:SetTextColor(titleR, titleG, titleB)
		QuestInfoObjectivesHeader:SetTextColor(titleR, titleG, titleB)
		QuestInfoRewardsFrame.Header:SetTextColor(titleR, titleG, titleB)

		-- Other text
		QuestInfoDescriptionText:SetTextColor(textR, textG, textB)
		QuestInfoObjectivesText:SetTextColor(textR, textG, textB)
		QuestInfoGroupSize:SetTextColor(textR, textG, textB)
		QuestInfoRewardText:SetTextColor(textR, textG, textB)
		QuestInfoQuestType:SetTextColor(textR, textG, textB)

		local numObjectives = GetNumQuestLeaderBoards()
		for i = 1, numObjectives do
			local text = _G['QuestInfoObjective'..i]
			if not text then break end

			text:SetTextColor(textR, textG, textB)
		end

		-- Reward frame text
		QuestInfoRewardsFrame.ItemChooseText:SetTextColor(textR, textG, textB)
		QuestInfoRewardsFrame.ItemReceiveText:SetTextColor(textR, textG, textB)
		QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(textR, textG, textB)
		QuestInfoRewardsFrameHonorReceiveText:SetTextColor(textR, textG, textB)
		QuestInfoRewardsFrameReceiveText:SetTextColor(textR, textG, textB)

		QuestInfoRewardsFrame.spellHeaderPool.textR, QuestInfoRewardsFrame.spellHeaderPool.textG, QuestInfoRewardsFrame.spellHeaderPool.textB = textR, textG, textB

		for spellHeader, _ in QuestInfoFrame.rewardsFrame.spellHeaderPool:EnumerateActive() do
			spellHeader:SetVertexColor(1, 1, 1)
		end
		for spellIcon, _ in QuestInfoFrame.rewardsFrame.spellRewardPool:EnumerateActive() do
			if not spellIcon.backdrop then
				handleItemButton(spellIcon)
			end
		end

		local requiredMoney = GetQuestLogRequiredMoney()
		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		for i = 1, #QuestInfoRewardsFrame.RewardButtons do
			local item = _G['QuestInfoRewardsFrameQuestInfoItem'..i]
			local name = _G['QuestInfoRewardsFrameQuestInfoItem'..i..'Name']
			local link = item.type and (QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

    for i = 1, MAX_NUM_QUESTS do
		_G['QuestTitleButton'..i..'QuestIcon']:SetPoint('TOPLEFT', 4, 2)
		_G['QuestTitleButton'..i..'QuestIcon']:SetSize(16, 16)
	end

    QuestFrameGreetingPanel:HookScript('OnUpdate', UpdateGreetingFrame)
	hooksecurefunc('QuestFrameGreetingPanel_OnShow', UpdateGreetingFrame)

    QuestFramePushQuestButton:ClearAllPoints()
	QuestFramePushQuestButton:SetPoint('LEFT', QuestLogFrameAbandonButton, 'RIGHT', 1, 0)
	QuestFramePushQuestButton:SetPoint('RIGHT', QuestLogFrameTrackButton, 'LEFT', -1, 0)

	GW.CreateFrameHeaderWithBody(QuestLogFrame, QuestLogTitleText:GetText(), "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon.png", {QuestLogListScrollFrame, QuestLogDetailScrollFrame}, 2, nil, true)
	QuestLogFrameCancelButton:SetPoint('BOTTOMRIGHT', QuestLogFrame, 'BOTTOMRIGHT', -25, 12)

	QuestLogTitleText:Hide()

	QuestLogFrameCloseButton:SetPoint("TOPRIGHT", QuestLogFrame, "TOPRIGHT", -5, -3)
    QuestLogFrameCloseButton:GwSkinButton(true)
    QuestLogFrameCloseButton:SetSize(20, 20)

    QuestLogDetailFrameCloseButton:GwSkinButton(true)
    QuestLogDetailFrameCloseButton:SetSize(20, 20)

	QuestLogDetailFrame:GwStripTextures()
	QuestLogDetailFrame.tex = QuestLogDetailFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
   	QuestLogDetailFrame.tex:SetPoint("TOPLEFT", QuestLogDetailFrame.NineSlice, "TOPLEFT", -10, 20)
    QuestLogDetailFrame.tex:SetPoint("BOTTOMRIGHT", QuestLogDetailFrame.NineSlice, "BOTTOMRIGHT", 20, -20)
    QuestLogDetailFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")

	QuestGreetingFrameHorizontalBreak:GwKill()

	QuestLogListScrollFrame:SetWidth(303)
	QuestLogDetailScrollFrame:SetWidth(303)
	QuestLogFrameAbandonButton:SetWidth(129)

	QuestLogHighlightFrame:SetWidth(303)
	QuestLogHighlightFrame.SetWidth = GW.NoOp

	QuestLogSkillHighlight:SetAlpha(0.35)

    QuestLogCount:GwStripTextures()
    QuestLogCount:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
	QuestLogQuestCount:GwSetFontTemplate(STANDARD_TEXT_FONT, GW.TextSizeType.SMALL)
	QuestLogQuestCount:SetTextColor(1, 1, 1)
	QuestLogCount.backdrop:SetFrameLevel(QuestLogFrame:GetFrameLevel() + 1)
	QuestLogFrameShowMapButtonText:SetTextColor(1, 1, 1)

    --- mover
    QuestLogFrame:EnableMouse(true)
    QuestLogFrame:SetMovable(true)
    QuestLogFrame:RegisterForDrag("LeftButton")
    QuestLogFrame:SetClampedToScreen(true)
    QuestLogFrame:SetScript("OnDragStart", function(self)
		self:StartMoving()
    end)
    QuestLogFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    QuestFrameNpcNameText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    QuestFrame:GwStripTextures()
    QuestFrame:GwCreateBackdrop()
    QuestFrame.tex = QuestFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
   	QuestFrame.tex:SetPoint("TOPLEFT", QuestFrame.NineSlice, "TOPLEFT", -10, 20)
    QuestFrame.tex:SetPoint("BOTTOMRIGHT", QuestFrame.NineSlice, "BOTTOMRIGHT", 20, -20)
    QuestFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")

    QuestFrameCloseButton:GwSkinButton(true)
    QuestFrameCloseButton:SetSize(20, 20)

    QuestFrameDetailPanel:GwStripTextures(nil, true)
    QuestDetailScrollFrame:GwStripTextures()
    QuestProgressScrollFrame:GwStripTextures()
    QuestGreetingScrollFrame:GwStripTextures()

    QuestFrameGreetingPanel:GwStripTextures(true)
    QuestFrameGreetingGoodbyeButton:GwSkinButton(false, true)
    QuestGreetingFrameHorizontalBreak:GwKill()

    QuestDetailScrollChildFrame:GwStripTextures(true)
    QuestRewardScrollChildFrame:GwStripTextures(true)
    QuestFrameProgressPanel:GwStripTextures(true)
    QuestFrameRewardPanel:GwStripTextures(true)

    QuestProgressScrollFrameScrollBar:GwSkinScrollBar()
    QuestProgressScrollFrame:GwSkinScrollFrame()

	QuestFrameAcceptButton:GwSkinButton(false, true)
	QuestFrameDeclineButton:GwSkinButton(false, true)
	QuestFrameCompleteButton:GwSkinButton(false, true)
	QuestFrameGoodbyeButton:GwSkinButton(false, true)
	QuestFrameCompleteQuestButton:GwSkinButton(false, true)

	QuestNPCModelTextFrame:GwStripTextures()
	QuestNPCModelTextFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
	QuestNPCModelTextFrame:SetPoint('BOTTOM', QuestModelScene, 0, -66)

	QuestNPCModelText:SetTextColor(1, 1, 1)

	QuestModelScene:SetHeight(253)
	QuestModelScene:GwStripTextures()
	QuestModelScene:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)

	QuestNPCModelNameText:ClearAllPoints()
	QuestNPCModelNameText:SetPoint("TOP", QuestModelScene, 0, -10)
	QuestNPCModelNameText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER, "OUTLINE")
	QuestNPCModelNameText:SetTextColor(1, 1, 1)

	QuestNPCModelText:SetJustifyH("CENTER")
	QuestNPCModelTextScrollFrame:ClearAllPoints()
	QuestNPCModelTextScrollFrame:SetPoint("TOPLEFT", QuestNPCModelTextFrame, 2, -2)
	QuestNPCModelTextScrollFrame:SetPoint("BOTTOMRIGHT", QuestNPCModelTextFrame, -10, 6)
	QuestNPCModelTextScrollChildFrame:GwSetInside(QuestNPCModelTextScrollFrame)

	QuestNPCModelTextScrollFrame.ScrollBar:GwSkinScrollBar()
	QuestNPCModelTextScrollFrame:GwSkinScrollFrame()
end
GW.LoadQuestLogFrameSkin = LoadQuestLogFrameSkin