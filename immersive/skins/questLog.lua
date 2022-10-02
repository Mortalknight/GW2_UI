local _, GW = ...

local function UpdateGreetingFrame()
	local i = 1
	local title = _G['QuestTitleButton'..i]
	while (title and title:IsVisible()) do
		_G.GreetingText:SetTextColor(1, 1, 1)
		_G.CurrentQuestsText:SetTextColor(1, 0.80, 0.10)
		_G.AvailableQuestsText:SetTextColor(1, 0.80, 0.10)

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
        item:CreateBackdrop("Transparent", true)
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
        item.Name:SetFont(UNIT_NAME_FONT, 12, "")
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

    local quality = link and select(3, GetItemInfo(link))
    if quality and quality > 1 then
        local r, g, b = GetItemQualityColor(quality)

        text:SetTextColor(r, g, b)
        frame.backdrop:SetBackdropBorderColor(r, g, b)
    else
        text:SetTextColor(1, 1, 1)
        frame.backdrop:SetBackdropBorderColor(1, 1, 1)
    end
end


local function LoadQuestLogFrameSkin()
    if not GW.GetSetting("QUESTLOG_SKIN_ENABLED") then return end

    local QuestStrip = {
		_G.EmptyQuestLogFrame,
		_G.QuestDetailScrollChildFrame,
		_G.QuestDetailScrollFrame,
		_G.QuestFrame,
		_G.QuestFrameDetailPanel,
		_G.QuestFrameGreetingPanel,
		_G.QuestFrameProgressPanel,
		_G.QuestFrameRewardPanel,
		_G.QuestGreetingScrollFrame,
		_G.QuestInfoItemHighlight,
		_G.QuestLogDetailScrollFrame,
		_G.QuestLogFrame,
		_G.QuestLogListScrollFrame,
		_G.QuestLogQuestCount,
		_G.QuestProgressScrollFrame,
		_G.QuestRewardScrollChildFrame,
		_G.QuestRewardScrollFrame
	}
	for _, object in pairs(QuestStrip) do
		object:StripTextures(true)
	end

    local QuestButtons = {
		_G.QuestFrameAcceptButton,
		_G.QuestFrameCancelButton,
		_G.QuestFrameCompleteButton,
		_G.QuestFrameCompleteQuestButton,
		_G.QuestFrameDeclineButton,
		_G.QuestFrameGoodbyeButton,
		_G.QuestFrameGreetingGoodbyeButton,
		_G.QuestFramePushQuestButton,
		_G.QuestLogFrameAbandonButton,
		_G.QuestLogFrameTrackButton,
		_G.QuestLogFrameCancelButton
	}
	for _, button in pairs(QuestButtons) do
		button:StripTextures()
		button:SkinButton(false, true)
	end

    local ScrollBars = {
		_G.QuestDetailScrollFrameScrollBar,
		_G.QuestGreetingScrollFrameScrollBar,
		_G.QuestLogDetailScrollFrameScrollBar,
		_G.QuestLogListScrollFrameScrollBar,
		_G.QuestRewardScrollFrameScrollBar
	}
	for _, object in pairs(ScrollBars) do
		object:SkinScrollBar()
	end

    local ScrollBars = {
		_G.QuestDetailScrollFrame,
		_G.QuestGreetingScrollFrame,
		_G.QuestLogDetailScrollFrame,
		_G.QuestLogListScrollFrame,
		_G.QuestRewardScrollFrame
	}
	for _, object in pairs(ScrollBars) do
		object:SkinScrollFrame()
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

			for i = 1, #_G.QuestInfoRewardsFrame.RewardButtons do
				local item = _G['QuestInfoRewardsFrameQuestInfoItem'..i]

				if item ~= frame then
					local name = _G['QuestInfoRewardsFrameQuestInfoItem'..i..'Name']
					local link = item.type and (_G.QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

					questQualityColors(item, name, link)
				end
			end
		end
	end)

    hooksecurefunc('QuestInfo_ShowRewards', function()
		for i = 1, #_G.QuestInfoRewardsFrame.RewardButtons do
			local item = _G['QuestInfoRewardsFrameQuestInfoItem'..i]
			local name = _G['QuestInfoRewardsFrameQuestInfoItem'..i..'Name']
			local link = item.type and (_G.QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

    hooksecurefunc('QuestInfo_ShowRewards', function()
		for i = 1, #_G.QuestInfoRewardsFrame.RewardButtons do
			local item = _G['QuestInfoRewardsFrameQuestInfoItem'..i]
			local name = _G['QuestInfoRewardsFrameQuestInfoItem'..i..'Name']
			local link = item.type and (_G.QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

    hooksecurefunc('QuestFrameProgressItems_Update', function()
		_G.QuestProgressTitleText:SetTextColor(1, .8, .1)
		_G.QuestProgressText:SetTextColor(1, 1, 1)
		_G.QuestProgressRequiredItemsText:SetTextColor(1, .8, 0.1)

		local moneyToGet = GetQuestMoneyToGet()
		if moneyToGet > 0 then
			if moneyToGet > GetMoney() then
				_G.QuestProgressRequiredMoneyText:SetTextColor(.6, .6, .6)
			else
				_G.QuestProgressRequiredMoneyText:SetTextColor(1, .8, .1)
			end
		end

        if not GW.GetSetting("QUESTVIEW_ENABLED") then
            for i = 1, _G.MAX_REQUIRED_ITEMS do
                local item = _G['QuestProgressItem'..i]
                local name = _G['QuestProgressItem'..i..'Name']
                local link = item.type and GetQuestItemLink(item.type, item:GetID())

                questQualityColors(item, name, link)
            end
        end

	end)

    hooksecurefunc('QuestLog_Update', function()
		if not _G.QuestLogFrame:IsShown() then return end
		local numEntries = GetNumQuestLogEntries()
		local scrollOffset = HybridScrollFrame_GetOffset(_G.QuestLogListScrollFrame)
		local buttons = _G.QuestLogListScrollFrame.buttons

		for i = 1, 22 do
			local questIndex = i + scrollOffset
			if questIndex <= numEntries then
				local _, _, _, isHeader, isCollapsed = GetQuestLogTitle(questIndex)
				if isHeader then
					if isCollapsed then
						buttons[i]:SetNormalTexture("Interface/AddOns/GW2_UI/Textures/arrow_right")
					else
						buttons[i]:SetNormalTexture("Interface/AddOns/GW2_UI/Textures/arrowdown_down")
					end
				end
			end
		end
	end)

    hooksecurefunc('QuestLog_UpdateQuestDetails', function()
		local requiredMoney = GetQuestLogRequiredMoney()
		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				_G.QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				_G.QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end
	end)

	hooksecurefunc('QuestLogUpdateQuestCount', function()
		_G.QuestLogCount:ClearAllPoints()
		_G.QuestLogCount:SetPoint('BOTTOMLEFT', _G.QuestLogListScrollFrame.backdrop, 'TOPLEFT', 0, 5)
	end)

    local textR, textG, textB = 1, 1, 1
	local titleR, titleG, titleB = 1, 0.80, 0.10
    hooksecurefunc('QuestFrameItems_Update', function()
		-- Headers
		_G.QuestLogDescriptionTitle:SetTextColor(titleR, titleG, titleB)
		_G.QuestLogRewardTitleText:SetTextColor(titleR, titleG, titleB)
		_G.QuestLogQuestTitle:SetTextColor(titleR, titleG, titleB)

		-- Other text
		_G.QuestLogItemChooseText:SetTextColor(textR, textG, textB)
		_G.QuestLogItemReceiveText:SetTextColor(textR, textG, textB)
		_G.QuestLogObjectivesText:SetTextColor(textR, textG, textB)
		_G.QuestLogQuestDescription:SetTextColor(textR, textG, textB)
		_G.QuestLogSpellLearnText:SetTextColor(textR, textG, textB)
		_G.QuestInfoQuestType:SetTextColor(textR, textG, textB)

		local requiredMoney = GetQuestLogRequiredMoney()
		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				_G.QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				_G.QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		_G.QuestLogItem1:SetPoint('TOPLEFT', _G.QuestLogItemChooseText, 'BOTTOMLEFT', 1, -3)

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

		for i = 1, _G.MAX_NUM_ITEMS do
			local item = _G['QuestLogItem'..i]
			local name = _G['QuestLogItem'..i..'Name']
			local link = item.type and (GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

    hooksecurefunc('QuestInfo_Display', function()
		-- Headers
		_G.QuestInfoTitleHeader:SetTextColor(titleR, titleG, titleB)
		_G.QuestInfoDescriptionHeader:SetTextColor(titleR, titleG, titleB)
		_G.QuestInfoObjectivesHeader:SetTextColor(titleR, titleG, titleB)
		_G.QuestInfoRewardsFrame.Header:SetTextColor(titleR, titleG, titleB)

		-- Other text
		_G.QuestInfoDescriptionText:SetTextColor(textR, textG, textB)
		_G.QuestInfoObjectivesText:SetTextColor(textR, textG, textB)
		_G.QuestInfoGroupSize:SetTextColor(textR, textG, textB)
		_G.QuestInfoRewardText:SetTextColor(textR, textG, textB)
		_G.QuestInfoQuestType:SetTextColor(textR, textG, textB)

		local numObjectives = GetNumQuestLeaderBoards()
		for i = 1, numObjectives do
			local text = _G['QuestInfoObjective'..i]
			if not text then break end

			text:SetTextColor(textR, textG, textB)
		end

		-- Reward frame text
		_G.QuestInfoRewardsFrame.ItemChooseText:SetTextColor(textR, textG, textB)
		_G.QuestInfoRewardsFrame.ItemReceiveText:SetTextColor(textR, textG, textB)
		_G.QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(textR, textG, textB)
		_G.QuestInfoRewardsFrameHonorReceiveText:SetTextColor(textR, textG, textB)
		_G.QuestInfoRewardsFrameReceiveText:SetTextColor(textR, textG, textB)

		_G.QuestInfoRewardsFrame.spellHeaderPool.textR, _G.QuestInfoRewardsFrame.spellHeaderPool.textG, _G.QuestInfoRewardsFrame.spellHeaderPool.textB = textR, textG, textB

		for spellHeader, _ in _G.QuestInfoFrame.rewardsFrame.spellHeaderPool:EnumerateActive() do
			spellHeader:SetVertexColor(1, 1, 1)
		end
		for spellIcon, _ in _G.QuestInfoFrame.rewardsFrame.spellRewardPool:EnumerateActive() do
			if not spellIcon.backdrop then
				handleItemButton(spellIcon)
			end
		end

		local requiredMoney = GetQuestLogRequiredMoney()
		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				_G.QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				_G.QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		for i = 1, #_G.QuestInfoRewardsFrame.RewardButtons do
			local item = _G['QuestInfoRewardsFrameQuestInfoItem'..i]
			local name = _G['QuestInfoRewardsFrameQuestInfoItem'..i..'Name']
			local link = item.type and (_G.QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

    for i = 1, MAX_NUM_QUESTS do
		_G['QuestTitleButton'..i..'QuestIcon']:SetPoint('TOPLEFT', 4, 2)
		_G['QuestTitleButton'..i..'QuestIcon']:SetSize(16, 16)
	end

    _G.QuestFrameGreetingPanel:HookScript('OnUpdate', UpdateGreetingFrame)
	hooksecurefunc('QuestFrameGreetingPanel_OnShow', UpdateGreetingFrame)

    _G.QuestFramePushQuestButton:ClearAllPoints()
	_G.QuestFramePushQuestButton:SetPoint('LEFT', _G.QuestLogFrameAbandonButton, 'RIGHT', 1, 0)
	_G.QuestFramePushQuestButton:SetPoint('RIGHT', _G.QuestLogFrameTrackButton, 'LEFT', -1, 0)


    local w, h = QuestLogFrame:GetSize()
    QuestLogFrame:StripTextures()
    QuestLogFrame.tex = QuestLogFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    QuestLogFrame.tex:SetPoint("TOP", QuestLogFrame, "TOP", 0, 20)
    QuestLogFrame.tex:SetSize(w + 30, h + 110)
    QuestLogFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    QuestLogFrameCloseButton:SkinButton(true)
    QuestLogFrameCloseButton:SetSize(20, 20)

    QuestLogDetailFrameCloseButton:SkinButton(true)
    QuestLogDetailFrameCloseButton:SetSize(20, 20)

	QuestLogFrameCancelButton:SetPoint('BOTTOMRIGHT', _G.QuestLogFrame, 'BOTTOMRIGHT', -25, 12)

	_G.QuestGreetingFrameHorizontalBreak:Kill()

	_G.QuestLogListScrollFrame:SetWidth(303)
	_G.QuestLogDetailScrollFrame:SetWidth(303)
	_G.QuestLogFrameAbandonButton:SetWidth(129)

	_G.QuestLogHighlightFrame:SetWidth(303)
	_G.QuestLogHighlightFrame.SetWidth = GW.NoOp

	_G.QuestLogSkillHighlight:SetAlpha(0.35)

    QuestLogCount:StripTextures()
    QuestLogCount:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorde, true)
    QuestLogListScrollFrame:CreateBackdrop(GW.skins.constBackdropFrame, true, 2, 2)
    QuestLogDetailScrollFrame:CreateBackdrop(GW.skins.constBackdropFrame, true, 8, 4)

    --- mover
    QuestLogFrame.mover = CreateFrame("Frame", nil, QuestLogFrame)
    QuestLogFrame.mover:EnableMouse(true)
    QuestLogFrame:SetMovable(true)
    QuestLogFrame.mover:SetSize(QuestLogFrame:GetWidth(), 30)
    QuestLogFrame.mover:SetPoint("BOTTOMLEFT", QuestLogFrame, "TOPLEFT", 0, -20)
    QuestLogFrame.mover:SetPoint("BOTTOMRIGHT", QuestLogFrame, "TOPRIGHT", 0, 20)
    QuestLogFrame.mover:RegisterForDrag("LeftButton")
    QuestLogFrame:SetClampedToScreen(true)
    QuestLogFrame.mover:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
    end)
    QuestLogFrame.mover:SetScript("OnDragStop", function(self)
        local self = self:GetParent()

        self:StopMovingOrSizing()
    end)

    QuestFrameNpcNameText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    QuestFrame:StripTextures()
    QuestFrame:CreateBackdrop()
    QuestFrame.tex = QuestFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    QuestFrame.tex:SetPoint("TOP", QuestFrame, "TOP", 0, 20)
    QuestFrame.tex:SetSize(QuestFrame:GetSize())
    QuestFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    QuestFrameCloseButton:SkinButton(true)
    QuestFrameCloseButton:SetSize(20, 20)

    QuestFrameDetailPanel:StripTextures(nil, true)
    QuestDetailScrollFrame:StripTextures()
    QuestProgressScrollFrame:StripTextures()
    QuestGreetingScrollFrame:StripTextures()


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

    QuestProgressScrollFrameScrollBar:SkinScrollBar()
    QuestProgressScrollFrame:SkinScrollFrame()

    QuestFrameAcceptButton:SkinButton(false, true)
    QuestFrameDeclineButton:SkinButton(false, true)
    QuestFrameCompleteButton:SkinButton(false, true)
    QuestFrameGoodbyeButton:SkinButton(false, true)
    QuestFrameCompleteQuestButton:SkinButton(false, true)

    QuestNPCModelTextFrame:StripTextures()
    local w, h = QuestNPCModelTextFrame:GetSize()
    QuestNPCModelTextFrame:StripTextures()
    QuestNPCModelTextFrame.tex = QuestNPCModelTextFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    QuestNPCModelTextFrame.tex:SetPoint("TOP", QuestNPCModelTextFrame, "TOP", 0, 20)
    QuestNPCModelTextFrame.tex:SetSize(w + 30, h + 60)
    QuestNPCModelTextFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

end
GW.LoadQuestLogFrameSkin = LoadQuestLogFrameSkin