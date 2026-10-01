---@class GW2
local GW = select(2, ...)

-- the gw header takes over the npc name and portrait, so the panels can move up into that space
local PANEL_TOP_OFFSET = 18

local questPanels = {"QuestFrameDetailPanel", "QuestFrameProgressPanel", "QuestFrameRewardPanel", "QuestFrameGreetingPanel"}
local questScrollFrames = {"QuestDetailScrollFrame", "QuestProgressScrollFrame", "QuestRewardScrollFrame", "QuestGreetingScrollFrame"}
local questButtons = {
    "QuestFrameAcceptButton",
    "QuestFrameDeclineButton",
    "QuestFrameCompleteButton",
    "QuestFrameCompleteQuestButton",
    "QuestFrameGoodbyeButton",
    "QuestFrameGreetingGoodbyeButton",
    "QuestFramePushQuestButton",
    "QuestFrameCancelButton",
    "QuestFrameExitButton"
}

local function SkinGreetingButton(button)
    if not button.gwSkinned then
        button.gwSkinned = true
        GW.AddListItemChildHoverTexture(button)
    end

    local name = button:GetName()
    local icon = button.Icon or (name and _G[name .. "QuestIcon"])
    icon:ClearAllPoints()
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 4, 2)
    icon:SetSize(16, 16)

    local text = button:GetFontString()
    button:SetText(gsub(button:GetText(), "|c[Ff][Ff]%x%x%x%x%x%x(.+)|r", "%1"))

    if text.SetFixedColor then
        text:SetFixedColor(true)
    end

    -- a quest the npc is still waiting on is greyed out, everything turn in ready or new stays gold
    if button.isActive == 1 and not select(2, GetActiveTitle(button:GetID())) then
        icon:SetDesaturation(1)
        text:SetTextColor(GW.Colors.SkinColors.Disabled:GetRGB())
    else
        icon:SetDesaturation(0)
        text:SetTextColor(GW.Colors.SkinColors.QuestGold:GetRGB())
    end
end

local function GreetingPanel_OnShow(self)
    GreetingText:SetTextColor(GW.Colors.FallbackWhite:GetRGB())

    if self.titleButtonPool then
        for button in self.titleButtonPool:EnumerateActive() do
            SkinGreetingButton(button)
        end
    else
        for i = 1, MAX_NUM_QUESTS do
            local button = _G["QuestTitleButton" .. i]
            if button:IsShown() then
                SkinGreetingButton(button)
            end
        end
    end
end

local function QuestFrame_OnShow()
    GW.SetHeaderPortrait(QuestFrame.gwHeader, UnitExists("questnpc") and "questnpc" or "npc")
end

-- the seal of a few quests is written in dark ink for the parchment, on our background it gets lighter colors
local SEAL_TEXT_COLORS = {
    ["480404"] = "c20606",
    ["042c54"] = "1c86ee",
}

-- the parts of the modern quest frame: text colors, rewards, progress items, the npc model and the quest log popup
local function SkinModernQuestParts()
    if not GW.QuestInfo_Display_hooked then
        hooksecurefunc("QuestInfo_Display", GW.QuestInfo_Display)
        GW.QuestInfo_Display_hooked = true
    end
    hooksecurefunc("QuestFrame_SetTextColor", function(fontString)
        fontString:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    end)
    hooksecurefunc("QuestFrameProgressItems_Update", function()
        QuestProgressRequiredItemsText:SetTextColor(GW.Colors.SkinColors.QuestGold:GetRGB())
        QuestProgressRequiredMoneyText:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    end)
    hooksecurefunc("QuestInfo_ShowRequiredMoney", function()
        local requiredMoney = GetQuestLogRequiredMoney()
        if requiredMoney > 0 then
            local color = requiredMoney > GetMoney() and GW.Colors.SkinColors.ObjectiveOpen or GW.Colors.SkinColors.QuestGold
            QuestInfoRequiredMoneyText:SetTextColor(color:GetRGB())
        end
    end)
    hooksecurefunc(QuestInfoSealFrame.Text, "SetText", function(self, text)
        if text and text ~= "" then
            local colorStr, rawText = strmatch(text, "|c[fF][fF](%x%x%x%x%x%x)(.-)|r")
            if colorStr and rawText then
                self:SetFormattedText("|cff%s%s|r", SEAL_TEXT_COLORS[colorStr] or "99ccff", rawText)
            end
        end
    end)

    for i = 1, 6 do
        local button = _G["QuestProgressItem" .. i]
        _G["QuestProgressItem" .. i .. "IconTexture"]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        button:GwStripTextures()
        button:SetFrameLevel(button:GetFrameLevel() + 1)
    end
    QuestDetailScrollChildFrame:GwStripTextures(true)
    QuestRewardScrollChildFrame:GwStripTextures(true)

    -- the npc model next to the frame
    QuestModelScene:SetHeight(253)
    QuestModelScene:GwStripTextures()
    QuestModelScene:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    QuestModelScene.ModelTextFrame:GwStripTextures()
    QuestModelScene.ModelTextFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, nil, 10)
    QuestNPCModelNameText:ClearAllPoints()
    QuestNPCModelNameText:SetPoint("TOP", QuestModelScene, 0, -10)
    QuestNPCModelNameText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header, "OUTLINE")
    QuestNPCModelNameText:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    QuestNPCModelText:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    QuestNPCModelText:SetJustifyH("CENTER")
    QuestNPCModelTextScrollFrame:ClearAllPoints()
    QuestNPCModelTextScrollFrame:SetPoint("TOPLEFT", QuestModelScene.ModelTextFrame, 2, -2)
    QuestNPCModelTextScrollFrame:SetPoint("BOTTOMRIGHT", QuestModelScene.ModelTextFrame, -10, 6)
    QuestNPCModelTextScrollChildFrame:GwSetInside(QuestNPCModelTextScrollFrame)
    GW.SkinSlimScrollFrame(QuestNPCModelTextScrollFrame)
    hooksecurefunc("QuestFrame_ShowQuestPortrait", function(frame, _, _, _, _, _, x, y)
        QuestModelScene:ClearAllPoints()
        QuestModelScene:SetPoint("TOPLEFT", frame, "TOPRIGHT", (x or 0) + (frame == QuestMapFrame:GetParent() and 0 or 6), y or 0)
    end)

    -- the quest details opened from the quest log
    local popup = QuestLogPopupDetailFrame
    popup:GwStripTextures(nil, true)
    popup:GwCreateBackdrop()
    local width, height = popup:GetSize()
    popup.tex = popup:CreateTexture(nil, "BACKGROUND", nil, 0)
    popup.tex:SetPoint("TOP", popup, "TOP", 0, 20)
    popup.tex:SetSize(width + 50, height + 70)
    popup.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
    QuestLogPopupDetailFrameAbandonButton:GwSkinButton(false, true)
    QuestLogPopupDetailFrameAbandonButton:GwSkinNegativeButton()
    QuestLogPopupDetailFrameShareButton:GwSkinButton(false, true)
    QuestLogPopupDetailFrameTrackButton:GwSkinButton(false, true)
    QuestLogPopupDetailFrameCloseButton:GwSkinButton(true)
    QuestLogPopupDetailFrameCloseButton:SetSize(20, 20)
    QuestLogPopupDetailFrameScrollFrame:GwStripTextures()
    GW.HandleTrimScrollBar(QuestLogPopupDetailFrameScrollFrame.ScrollBar)
    GW.HandleScrollControls(QuestLogPopupDetailFrameScrollFrame)
    QuestLogPopupDetailFrameScrollFrame:GwSkinScrollFrame()
end

local function LoadQuestFrameSkin()
    if not GW.settings.skins.questLog.enabled then return end

    -- the quest texts are written for the parchment, ours is dark
    QuestFont:SetTextColor(GW.Colors.FallbackWhite:GetRGB())

    QuestFrame:GwStripTextures()
    GW.HandlePortraitFrameArt(QuestFrame)
    QuestFramePortrait:Hide()

    -- no open animation here: it fades the frame in on every show and would undo the alpha 0
    -- with which the immersive questing keeps the blizzard frame technically shown but invisible
    GW.CreateFrameHeaderWithBody(QuestFrame, QuestFrameNpcNameText or QuestFrame.TitleContainer.TitleText)

    QuestFrame.gwHeader.windowIcon:SetSize(48, 48)
    QuestFrame.gwHeader.windowIcon:ClearAllPoints()
    QuestFrame.gwHeader.windowIcon:SetPoint("CENTER", QuestFrame.gwHeader, "BOTTOMLEFT", 30, 19)

    local closeButton = QuestFrameCloseButton or QuestFrame.CloseButton
    closeButton:GwSkinButton(true, false)
    closeButton:SetSize(25, 25)
    closeButton:ClearAllPoints()
    closeButton:SetPoint("TOPRIGHT", QuestFrame, "TOPRIGHT", -6, 4)

    for _, name in ipairs(questPanels) do
        local panel = _G[name]
        panel:GwStripTextures(true)
        panel:ClearAllPoints()
        panel:SetPoint("TOPLEFT", QuestFrame, "TOPLEFT", 0, PANEL_TOP_OFFSET)

        if panel.SealMaterialBG then
            panel.SealMaterialBG:SetAlpha(0)
        end
    end

    for _, name in ipairs(questScrollFrames) do
        local scrollFrame = _G[name]
        scrollFrame:GwStripTextures()
        scrollFrame:GwSkinScrollFrame()
        GW.AddDetailsBackground(scrollFrame)

        -- the modern clients build an unnamed ScrollBar object, the classic ones a named UIPanelScrollBar
        local scrollBar = scrollFrame.ScrollBar or _G[name .. "ScrollBar"]
        if scrollBar.SetHideIfUnscrollable then
            GW.HandleTrimScrollBar(scrollBar)
            GW.HandleScrollControls(scrollFrame)
            scrollBar:SetHideIfUnscrollable(true)
            scrollBar:Update()
        else
            scrollBar:GwSkinScrollBar()
            scrollFrame.scrollBarHideable = 1
        end
    end

    for _, name in ipairs(questButtons) do
        local button = _G[name]
        if button then
            button:GwSkinButton(false, true)
        end
    end

    if QuestGreetingFrameHorizontalBreak then
        QuestGreetingFrameHorizontalBreak:GwKill()
    end

    if QuestFrame_SetTitleTextColor then
        hooksecurefunc("QuestFrame_SetTitleTextColor", function(fontString)
            fontString:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        end)
    end

    QuestFrameGreetingPanel:HookScript("OnShow", GreetingPanel_OnShow)
    QuestFrame:HookScript("OnShow", QuestFrame_OnShow)

    if GW.isModern then
        SkinModernQuestParts()
    end
end
GW.LoadQuestFrameSkin = LoadQuestFrameSkin
