local _, GW = ...

local function handleGossipText()
    local buttons = GossipFrame.buttons
    if buttons and next(buttons) then
        for _, button in ipairs(buttons) do
            local str = button:GetFontString()
            if str then
                str:SetTextColor(1, 1, 1)

                local text = str:GetText()
                if text then
                    local stripped = GW.StripString(text)
                    str:SetText(stripped)
                end
            end
        end
    end
end

local function LoadGossipSkin()
    if not GW.GetSetting("GOSSIP_SKIN_ENABLED") then return end

    local GossipFrame = GossipFrame
    ItemTextFrame:StripTextures(true)
    ItemTextFrame:CreateBackdrop()

    local tex = ItemTextFrame:CreateTexture("bg", "BACKGROUND", 0)
    local w, h = ItemTextFrame:GetSize()
    tex:SetPoint("TOP", ItemTextFrame, "TOP", 0, 20)
    tex:SetSize(w + 50, h + 70)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    ItemTextFrame.tex = tex

    ItemTextScrollFrame:StripTextures()

    GossipFrameNpcNameText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    GossipFrame:StripTextures()
    GossipFrame:CreateBackdrop()
    tex = GossipFrame:CreateTexture("bg", "BACKGROUND", 0)
    w, h = GossipFrame:GetSize()
    tex:SetPoint("TOP", GossipFrame, "TOP", 0, 20)
    tex:SetSize(w + 50, h + 70)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    GossipFrame.tex = tex

    GossipFrame.CloseButton:SkinButton(true)
    GossipFrame.CloseButton:SetSize(20, 20)
    GossipFrame.Background:Hide()

    ItemTextFrameCloseButton:SkinButton(true)
    ItemTextFrameCloseButton:SetSize(20, 20)

    GossipGreetingScrollFrameScrollBar:SkinScrollBar()
    ItemTextScrollFrameScrollBar:SkinScrollBar()
    ItemTextScrollFrame:SkinScrollFrame()

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

    local GossipGreetingScrollFrame = GossipGreetingScrollFrame
    GossipGreetingScrollFrame:SkinScrollFrame()

    hooksecurefunc("GossipFrameUpdate", handleGossipText)
    GossipGreetingText:SetTextColor(1, 1, 1)
    handleGossipText()

    GossipFrameGreetingGoodbyeButton:StripTextures()
    GossipFrameGreetingGoodbyeButton:SkinButton(false, true)

    for i = 1, 4 do
        local notch = _G["NPCFriendshipStatusBarNotch" .. i]
        if notch then
            notch:SetColorTexture(0, 0, 0)
            notch:SetSize(1, 16)
        end
    end

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
    local QuestFrame = QuestFrame
    QuestFrameNpcNameText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    QuestFrame:StripTextures()
    QuestFrame:CreateBackdrop()
    QuestFrame.tex = QuestFrame:CreateTexture("bg", "BACKGROUND", 0)
    w, h = QuestFrame:GetSize()
    QuestFrame.tex:SetPoint("TOP", QuestFrame, "TOP", 0, 20)
    QuestFrame.tex:SetSize(w + 50, h + 70)
    QuestFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    QuestFrame.CloseButton:SkinButton(true)
    QuestFrame.CloseButton:SetSize(20, 20)

    QuestFrameDetailPanel:StripTextures()
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

    hooksecurefunc("QuestInfo_Display", GW.QuestInfo_Display)
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
    hooksecurefunc(QuestInfoSealFrame.Text, "SetText", function(text)
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

    for i = 1, 6 do
        local button = _G["QuestProgressItem" .. i]
        local icon = _G["QuestProgressItem" .. i .. "IconTexture"]
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        button:StripTextures()
        button:SetFrameLevel(button:GetFrameLevel() +1)
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

    QuestLogPopupDetailFrame:StripTextures()
    QuestLogPopupDetailFrame:CreateBackdrop()
    tex = QuestLogPopupDetailFrame:CreateTexture("bg", "BACKGROUND", 0)
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