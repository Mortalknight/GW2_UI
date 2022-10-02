local _, GW = ...
local GetSetting = GW.GetSetting

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
    if not frame.template then
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

local function handleGossipText()
    for i = 1, NUMGOSSIPBUTTONS do
        local button = _G["GossipTitleButton"..i]
        local icon = _G["GossipTitleButton"..i.."GossipIcon"]
        local text = button:GetFontString()

        if text and text:GetText() then
            local textString = gsub(text:GetText(), "|c[Ff][Ff]%x%x%x%x%x%x(.+)|r", "%1")

            button:SetText(textString)
            text:SetTextColor(1, 1, 1)

            if button.type == "Available" or button.type == "Active" then
                if button.type == "Active" then
                    icon:SetDesaturation(1)
                    text:SetTextColor(.6, .6, .6)
                else
                    icon:SetDesaturation(0)
                    text:SetTextColor(1, .8, .1)
                end

                local numEntries = GetNumQuestLogEntries()
                for k = 1, numEntries, 1 do
                    local questLogTitleText, _, _, _, _, isComplete, _, questId = GetQuestLogTitle(k)
                    if strmatch(questLogTitleText, textString) then
                        if (isComplete == 1 or IsQuestComplete(questId)) then
                            icon:SetDesaturation(0)
                            button:GetFontString():SetTextColor(1, .8, .1)
                            break
                        end
                    end
                end
            end
        end
    end
end

local function LoadGossipSkin()
    if not GW.GetSetting("GOSSIP_SKIN_ENABLED") then return end

    ItemTextFrame:StripTextures(true)
    ItemTextFrame:CreateBackdrop()

    ItemTextFrame.tex = ItemTextFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    ItemTextFrame.tex:SetPoint("TOP", ItemTextFrame, "TOP", 0, 20)
    ItemTextFrame.tex:SetSize(ItemTextFrame:GetSize())
    ItemTextFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    ItemTextScrollFrame:StripTextures()

    GossipFrameNpcNameText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    GossipFrame:StripTextures()
    GossipFrame:CreateBackdrop()
    GossipFrame.tex = GossipFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    GossipFrame.tex:SetPoint("TOP", GossipFrame, "TOP", 0, 20)
    GossipFrame.tex:SetSize(GossipFrame:GetSize())
    GossipFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    GossipFrameCloseButton:SkinButton(true)
    GossipFrameCloseButton:SetSize(20, 20)

    for i = 1, _G.NUMGOSSIPBUTTONS do
        _G["GossipTitleButton"..i.."GossipIcon"]:SetSize(16, 16)
        _G["GossipTitleButton"..i.."GossipIcon"]:SetPoint("TOPLEFT", 3, 1)
    end

    GossipGreetingScrollFrameScrollBar:SkinScrollBar()
    ItemTextScrollFrameScrollBar:SkinScrollBar()
    ItemTextScrollFrame:SkinScrollFrame()

    GossipFrameGreetingGoodbyeButton:StripTextures()
    GossipFrameGreetingGoodbyeButton:SkinButton(false, true)

    GW.HandleNextPrevButton(ItemTextPrevPageButton)
    GW.HandleNextPrevButton(ItemTextNextPageButton)

    ItemTextPageText:SetTextColor(1, 1, 1)
    hooksecurefunc(ItemTextPageText, "SetTextColor", function(pageText, headerType, r, g, b)
        if r ~= 1 or g ~= 1 or b ~= 1 then
            pageText:SetTextColor(headerType, 1, 1, 1)
        end
    end)

    local StripAllTextures = {"GossipFrameGreetingPanel", "GossipGreetingScrollFrame"}
    for _, object in pairs(StripAllTextures) do
        _G[object]:StripTextures()
    end

    GossipGreetingScrollFrame:SkinScrollFrame()

    hooksecurefunc("GossipFrameUpdate", handleGossipText)
    GossipGreetingText:SetTextColor(1, 1, 1)
    handleGossipText()

    ItemTextCloseButton:SkinButton(true)
    ItemTextCloseButton:SetSize(20, 20)

    local NPCFriendshipStatusBar = NPCFriendshipStatusBar
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
        hooksecurefunc("QuestInfo_Display", function()
            QuestInfoTitleHeader:SetTextColor(1, 0.8, 0.1)
            QuestInfoDescriptionHeader:SetTextColor(1, 0.8, 0.1)
            QuestInfoObjectivesHeader:SetTextColor(1, 0.8, 0.1)
            QuestInfoRewardsFrame.Header:SetTextColor(1, 0.8, 0.1)

            QuestInfoDescriptionText:SetTextColor(1, 1, 1)
            QuestInfoObjectivesText:SetTextColor(1, 1, 1)
            QuestInfoGroupSize:SetTextColor(1, 1, 1)
            QuestInfoRewardText:SetTextColor(1, 1, 1)
            QuestInfoQuestType:SetTextColor(1, 1, 1)

            local numObjectives = GetNumQuestLeaderBoards()
            for i = 1, numObjectives do
                local text = _G["QuestInfoObjective"..i]
                if not text then break end

                text:SetTextColor(1, 1, 1)
            end

            QuestInfoRewardsFrame.ItemChooseText:SetTextColor(1, 1, 1)
            QuestInfoRewardsFrame.ItemReceiveText:SetTextColor(1, 1, 1)
            QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(1, 1, 1)
            QuestInfoRewardsFrameHonorReceiveText:SetTextColor(1, 1, 1)
            QuestInfoRewardsFrameReceiveText:SetTextColor(1, 1, 1)

            QuestInfoRewardsFrame.spellHeaderPool.textR, QuestInfoRewardsFrame.spellHeaderPool.textG, QuestInfoRewardsFrame.spellHeaderPool.textB = 1, 1, 1

            for spellHeader, _ in QuestInfoFrame.rewardsFrame.spellHeaderPool:EnumerateActive() do
                spellHeader:SetVertexColor(1, 1, 1)
            end
            for spellIcon, _ in QuestInfoFrame.rewardsFrame.spellRewardPool:EnumerateActive() do
                if not spellIcon.template then
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
                local item = _G["QuestInfoRewardsFrameQuestInfoItem"..i]
                local name = _G["QuestInfoRewardsFrameQuestInfoItem"..i.."Name"]
                local link = item.type and (QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

                questQualityColors(item, name, link)
            end

        end)
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
        button:StripTextures()
        button:SkinButton(false, true)
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
    local w, h = QuestNPCModelTextFrame:GetSize()
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
        local self = self:GetParent()

        self:StopMovingOrSizing()
    end)
end
GW.LoadGossipSkin = LoadGossipSkin