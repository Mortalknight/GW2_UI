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
        text:SetTextColor(0.6, 0.6, 0.6)
    else
        icon:SetDesaturation(0)
        text:SetTextColor(1, 0.8, 0.1)
    end
end

local function GreetingPanel_OnShow(self)
    GreetingText:SetTextColor(1, 1, 1)

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

local function LoadQuestFrameSkin()
    if not GW.settings.skins.questLog.enabled then return end

    QuestFrame:GwStripTextures()
    GW.HandlePortraitFrameArt(QuestFrame)
    QuestFramePortrait:Hide()

    GW.CreateFrameHeaderWithBody(QuestFrame, QuestFrameNpcNameText or QuestFrame.TitleContainer.TitleText, nil, nil, nil, nil, true)

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
end
GW.LoadQuestFrameSkin = LoadQuestFrameSkin
