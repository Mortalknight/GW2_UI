---@class GW2
local GW = select(2, ...)

GwObjectivesBlockTemplateMixin = {}
local FALLBACK_WHITE = GW.Colors.FallbackWhite
local DIM_RED = DIM_RED_FONT_COLOR
local WHITE_R, WHITE_G, WHITE_B, WHITE_A = FALLBACK_WHITE:GetRGBA()
local DIM_RED_R, DIM_RED_G, DIM_RED_B, DIM_RED_A = DIM_RED:GetRGBA()

function GwObjectivesBlockTemplateMixin:UpdateBlockObjectives()
    -- override per module
end

function GwObjectivesBlockTemplateMixin:UpdateBlock()
    -- override per module
end

function GwObjectivesBlockTemplateMixin:UpdateFindGroupButton(id, isScenario)
    local hasButton
    if not isScenario then
        hasButton = QuestUtil.CanCreateQuestGroup(id)
    else
        hasButton = C_LFGList.CanCreateScenarioGroup(id)
    end
    if hasButton then
		self.groupButton:SetUp(id, isScenario)
		self.groupButton:Show()
    else
        self.groupButton:Hide()
	end
end

function GwObjectivesBlockTemplateMixin:OnEnter()
    if not self.hover then
        local parent = self:GetParent()
        local r, g, b = parent.Header:GetTextColor()
        parent._oldHeaderR, parent._oldHeaderG, parent._oldHeaderB = r, g, b
        parent.Header:SetTextColor(r * 2, g * 2, b * 2)
        self = parent
    end

    self.hover:Show()

    if self.objectiveBlocks then
        for _, v in ipairs(self.objectiveBlocks) do
            if not v.StatusBar.notHide and not v.StatusBar.progress:IsShown() then
                v.StatusBar.progress:Show()
            end
        end
    else
        -- here we have a frame pool
        for frame in self.objectivesPool:EnumerateActive() do
            if not frame.StatusBar.notHide and not frame.StatusBar.progress:IsShown() then
                frame.StatusBar.progress:Show()
            end
        end
    end

    if self.gwHasSuperTrackPin then
        self.superTrackButton:Show()
    end

    if not self.isSuperTracked then
        GW.AddToAnimation(
            (self.animationName or self:GetDebugName()) .. "hover",
            0,
            1,
            GetTime(),
            0.2,
            function(step)
                self.hover:SetAlpha(math.max((step - 0.3), 0))
                self.hover:SetTexCoord(0, step, 0, 1)
            end
        )
    end
    if self.event then
        self:TryShowRewardsTooltip()
    elseif GW.Retail and IsInGroup() and self.questID then
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, 0)
        GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
        GameTooltip:SetQuestPartyProgress(self.questID)
        EventRegistry:TriggerEvent("OnQuestBlockHeader.OnEnter", self, self.questID, true)
    end
end

function GwObjectivesBlockTemplateMixin:OnLeave()
    if not self.hover then
        local parent = self:GetParent()
        if parent._oldHeaderR ~= nil then
            parent.Header:SetTextColor(parent._oldHeaderR, parent._oldHeaderG, parent._oldHeaderB)
        end
        self = parent
    end
    if not self.isSuperTracked then
        self.hover:Hide()
    end

    -- IsMouseOver, not focus: the pin sits inside the block rect, so moving onto it fires
    -- this handler and would hide the button under the cursor
    if self.gwHasSuperTrackPin and not self.isSuperTracked and not self:IsMouseOver() then
        self.superTrackButton:Hide()
    end

    if self.objectiveBlocks then
        for _, v in ipairs(self.objectiveBlocks) do
            if not v.StatusBar.notHide and v.StatusBar.progress:IsShown() then
                v.StatusBar.progress:Hide()
            end
        end
    else
        -- here we have a frame pool
        for frame in self.objectivesPool:EnumerateActive() do
            if not frame.StatusBar.notHide and frame.StatusBar.progress:IsShown() then
                frame.StatusBar.progress:Hide()
            end
        end
    end

    GW.StopAnimation((self.animationName or self:GetDebugName()) .. "hover")
    GameTooltip_Hide()
end

function GwObjectivesBlockTemplateMixin:OnLoad()
    self:ApplyLayoutStyle()

    self.turnin:SetScript("OnShow", self.turnin.WiggleAnimation)
    self.turnin:SetScript("OnHide", function(btn) GW.StopAnimation(btn:GetDebugName()) end)
    self.turnin:SetScript("OnClick",function(btn)
        if GW.Retail then
            ShowQuestComplete(self.questID)
        else
            ShowQuestComplete(self.questLogIndex)
        end
        RemoveAutoQuestPopUp(self.questID)
        btn:Hide()
    end)
    self.popupQuestAccept:SetScript("OnShow", self.popupQuestAccept.WiggleAnimation)
    self.popupQuestAccept:SetScript("OnHide", function(btn) GW.StopAnimation(btn:GetDebugName()) end)
    self.popupQuestAccept:SetScript("OnClick", function(btn)
         if GW.Retail then
            ShowQuestOffer(self.questID)
        else
            ShowQuestOffer(self.questLogIndex)
        end
            RemoveAutoQuestPopUp(self.questID)
            btn:Hide()
        end)
    self.groupButton:SetScript("OnClick", self.groupButton.OnClick)
    self.groupButton:SetScript("OnEnter", self.groupButton.OnEnter)
    self.groupButton:SetScript("OnLeave", self.groupButton.OnLeave)

    self.turnin:SetScale(GwQuestTracker:GetScale() * 0.9)
    self.popupQuestAccept:SetScale(GwQuestTracker:GetScale() * 0.9)
    self.groupButton:SetScale(GwQuestTracker:GetScale() * 0.9)

    -- hooks for scaling
    hooksecurefunc(GwQuestTracker, "SetScale", function(_, scale)
        self.turnin:SetScale(scale * 0.9)
        self.popupQuestAccept:SetScale(scale * 0.9)
        self.groupButton:SetScale(scale * 0.9)
    end)
end

function GwObjectivesBlockTemplateMixin:ApplyLayoutStyle()
    local compact = GW.IsObjectivesTrackerCompactMode()
    local headerHeight = compact and 20 or 30

    self.Header:GwSetFontTemplate(DAMAGE_TEXT_FONT, compact and GW.Enum.TextSizeType.Small or GW.Enum.TextSizeType.Normal)
    self.SubHeader:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    self.Header:SetHeight(headerHeight)
    self.SubHeader:SetHeight(headerHeight)
    self.Difficulty:SetHeight(headerHeight)
    self.SubHeader:ClearAllPoints()
    self.SubHeader:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, compact and -17 or -25)
end

local SUPER_TRACK_TITLE_INSET = 32

local function SetTitleRightInset(block, inset)
    block.Header:ClearAllPoints()
    block.Header:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0)
    block.Header:SetPoint("TOPRIGHT", block, "TOPRIGHT", -inset, 0)
end

GwObjectivesSuperTrackButtonMixin = {}

function GwObjectivesSuperTrackButtonMixin:OnClick()
    local questID = self:GetParent().questID
    if not questID then
        return
    end

    if C_SuperTrack.GetSuperTrackedQuestID() == questID then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        C_SuperTrack.ClearAllSuperTracked()
    else
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        C_SuperTrack.SetSuperTrackedQuestID(questID)
    end
end

function GwObjectivesSuperTrackButtonMixin:OnEnter()
    local questID = self:GetParent().questID
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(C_SuperTrack.GetSuperTrackedQuestID() == questID and STOP_SUPER_TRACK_QUEST or SUPER_TRACK_QUEST,
        GW.Colors.TextColors.LightHeader:GetRGB())
    GameTooltip:Show()
end

function GwObjectivesSuperTrackButtonMixin:OnLeave()
    GameTooltip_Hide()
end

function GwObjectivesBlockTemplateMixin:UpdateSuperTrackButton(isSuperTracked, iconType)
    local button = self.superTrackButton
    if not button then
        return
    end
    if not self.questID then
        self.gwHasSuperTrackPin = nil
        button:Hide()
        SetTitleRightInset(self, 0)
        return
    end

    local icon = GW.GetObjectivesTypeIcon(iconType) or GW.GetObjectivesTypeIcon(GW.Enum.ObjectivesNotificationType.Quest)
    if not icon then
        button:Hide()
        return
    end

    button.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/" .. icon.tex .. ".png")
    button.icon:SetTexCoord(icon.l, icon.r, icon.t, icon.b)
    button.icon:SetDesaturated(true)
    button.icon:SetVertexColor(self.color.r, self.color.g, self.color.b, isSuperTracked and 1 or 0.7)

    -- only the tracked quest keeps its pin, the others appear on hover (OnEnter/OnLeave)
    self.gwHasSuperTrackPin = true
    button:SetShown(isSuperTracked)

    -- the inset stays regardless: reserved space keeps titles from reflowing on hover
    SetTitleRightInset(self, SUPER_TRACK_TITLE_INSET)
end

function GwObjectivesBlockTemplateMixin:SetBlockColorByKey(type)
    self.color = GW.Colors.ObjectivesTypeColors[type]
end

function GwObjectivesBlockTemplateMixin:GetObjectiveBlock(index, firstObjectivesYValue, rowYOffset)
    local objective = self.objectiveBlocks and self.objectiveBlocks[index]
    if objective then
        objective:ClearAllPoints()
        if index == 1 then
            objective:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, (firstObjectivesYValue or GW.GetObjectivesFirstObjectiveOffset()))
        else
            objective:SetPoint("TOPRIGHT", self.objectiveBlocks[index - 1], "BOTTOMRIGHT", 0, rowYOffset or 0)
        end
        -- fonts and the row internal anchors only depend on the compact mode setting,
        -- re-applying them on every content update is the expensive part of row reuse
        if objective.gwLayoutGeneration ~= GW.ObjectivesTrackerState.layoutGeneration then
            objective.gwLayoutGeneration = GW.ObjectivesTrackerState.layoutGeneration
            objective:ApplyLayoutStyle()
        end
        objective:SetScript("OnUpdate", nil)
        objective:SetScript("OnEnter", nil)
        objective:SetScript("OnLeave", nil)
        objective.isMythicKeystone = false
        objective.ObjectiveText:SetText("")

        return objective
    end

    local newObjective = CreateFrame("Frame", nil, self, "GwQuesttrackerObjectiveTemplate")
    newObjective:SetParent(self)
    tinsert(self.objectiveBlocks, newObjective)

    if index == 1 then
        newObjective:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, (firstObjectivesYValue or GW.GetObjectivesFirstObjectiveOffset()))
    else
        newObjective:SetPoint("TOPRIGHT", self.objectiveBlocks[index - 1], "BOTTOMRIGHT", 0, 0)
    end

    newObjective.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)
    newObjective.ObjectiveText:SetText("")

    newObjective.notChangeSize = true
    newObjective.hasObjectToHide = false
    newObjective.objectToHide = nil
    newObjective.resetParent = false
    newObjective.isMythicKeystone = false

    newObjective:ApplyLayoutStyle()
    newObjective.gwLayoutGeneration = GW.ObjectivesTrackerState.layoutGeneration

    return newObjective
end

local function GetObjectiveTextHeight(objectiveText)
    local textHeight = objectiveText:GetStringHeight() or 0
    local lineHeight = objectiveText:GetLineHeight() or 0
    local lineCount = objectiveText:GetNumLines() or 1

    if lineHeight > 0 and lineCount > 0 then
        textHeight = math.max(textHeight, lineHeight * lineCount)
    end

    return textHeight
end

-- Books what a row contributes to the block height. A row offset is negative: it pushes
-- the row further down, so it enlarges the block by its own magnitude. Deriving that here
-- instead of hard coding the number at every caller keeps block.height and the real
-- geometry in sync - an unaccounted offset makes the block too short and its last row
-- bleeds into the tracker section below.
function GwObjectivesBlockTemplateMixin:AccountObjectiveRow(row, rowYOffset)
    self.height = self.height + row:GetHeight()
    if self.numObjectives > 1 and rowYOffset then
        self.height = self.height - rowYOffset
    end
end

function GwObjectivesBlockTemplateMixin:AddObjective(text, options)
    if not text then return end
    self.numObjectives = self.numObjectives + 1
    local objectiveBlock = self:GetObjectiveBlock(self.numObjectives, options.firstObjectivesYValue, options.rowYOffset)
    local precentageComplete = 0
    local objectiveText = objectiveBlock.ObjectiveText
    local statusBar = objectiveBlock.StatusBar

    -- widget partition ticks are re-applied by their caller (see the scenario
    -- status bar widgets) — clear stale ones from objective block reuse
    if statusBar.gwPartitions then
        for _, tick in ipairs(statusBar.gwPartitions) do
            tick:Hide()
        end
    end

    objectiveBlock:Show()
    local formattedText = text
    if options.isReceip then
        if options.qty and options.qty < options.totalqty then
            formattedText = GW.GetLocalizedNumber(options.qty) .. "/" .. GW.GetLocalizedNumber(options.totalqty) .. " " .. text
        end
    elseif options.isAchievement then
        formattedText = GW.FormatObjectiveNumbers(text)
    end
    objectiveText:SetText(formattedText)
    local textHeight = GetObjectiveTextHeight(objectiveText)
    objectiveText:SetHeight(textHeight + GW.GetObjectivesTextPadding())

    if objectiveBlock.hasObjectToHide then
        if objectiveBlock.resetParent then objectiveBlock.objectToHide.SetParent = nil end
        objectiveBlock.objectToHide:SetParent(GW.HiddenFrame)
        if objectiveBlock.resetParent then objectiveBlock.objectToHide.SetParent = GW.NoOp end
    end

    objectiveBlock.isMythicKeystone = options.isMythicKeystone

    if options.isAchievement then
        if options.eligible then
            if options.finished then
                if options.useCompletedLine then
                    objectiveText:SetTextColor(0.72, 0.72, 0.72, 0.7)
                else
                    objectiveText:SetTextColor(0.8, 0.8, 0.8, 0.7)
                end
            else
                objectiveText:SetTextColor(WHITE_R, WHITE_G, WHITE_B, WHITE_A)
            end
        else
            objectiveText:SetTextColor(DIM_RED_R, DIM_RED_G, DIM_RED_B, DIM_RED_A)
        end
    else
        if options.finished then
            if options.useCompletedLine then
                objectiveText:SetTextColor(0.72, 0.72, 0.72, 0.7)
            else
                objectiveText:SetTextColor(0.8, 0.8, 0.8, 0.7)
            end
        else
            objectiveText:SetTextColor(WHITE_R, WHITE_G, WHITE_B, WHITE_A)
        end
    end

    objectiveBlock:SetCompletedLineState(options.finished and options.useCompletedLine)

    if options.objectiveType == "progressbar" then
        local progressValue = options.qty or (self.questID and GetQuestProgressBarPercent(self.questID)) or 0
        statusBar:SetMinMaxValues(0, 100)
        statusBar:SetValue(progressValue)
        statusBar:SetShown(options.isMythicKeystone or options.overrideShowStatusbarSetting or GW.settings.QUESTTRACKER_STATUSBARS_ENABLED)
        objectiveBlock.progress = progressValue / 100
        statusBar.precentage = true
        precentageComplete = objectiveBlock.progress
    elseif GW.ParseObjectiveString(objectiveBlock, text, options.qty, options.totalqty, (options.overrideShowStatusbarSetting or options.isMythicKeystone)) then
        precentageComplete = objectiveBlock.progress
    else
        statusBar:Hide()
    end

    -- The row holds what ApplyLayoutStyle anchors into it: the text offset, the text rect,
    -- an optional status bar stacked below it - plus exactly ONE spacing to the next row.
    -- Counting that spacing twice for bar rows was why rows without a bar ended up with no
    -- gap at all while bar rows had one.
    local h = GW.GetObjectivesRowTextOffset() + textHeight + GW.GetObjectivesTextPadding()
    local ownWhitespace = GW.GetObjectivesTextPadding()
    if statusBar:IsShown() then
        -- the bar sits inside the space the text padding would leave empty
        h = h + GW.GetObjectivesStatusBarGap() + statusBar:GetHeight()
        ownWhitespace = 0
    end
    -- The gap to the next row is what is left of the target once the whitespace this row
    -- already carries below its content and the next row's text offset are subtracted.
    -- Block separation is NOT part of it, that is added once per block in LayoutBlocks.
    h = h + math.max(GW.GetObjectivesRowGap() - ownWhitespace - GW.GetObjectivesRowTextOffset(), 0)
    objectiveBlock:SetHeight(h)

    -- a bar without a label sits centered in the row: the text rect it hangs under is
    -- sized so that the bar center lands on the row center
    if statusBar:IsShown() and strtrim(text) == "" then
        local textRect = (h - statusBar:GetHeight()) / 2 - GW.GetObjectivesStatusBarGap() - GW.GetObjectivesRowTextOffset()
        objectiveText:SetHeight(math.max(textRect, 1))
    end

    if options.timerShown then
        objectiveBlock:AddTimer(options.duration, options.startTime)
    else
        objectiveBlock.TimerBar:Hide()
        objectiveBlock.TimerBar:SetScript("OnUpdate", nil)
    end

    self:AccountObjectiveRow(objectiveBlock, options.rowYOffset)

    return precentageComplete
end

function GwObjectivesBlockTemplateMixin:IsQuestAutoTurnInOrAutoAccept(blockQuestID, checkType, isComplete, isAutoComplete)
    for i = 1, GetNumAutoQuestPopUps() do
        local questID, popUpType = GetAutoQuestPopUp(i)
        if blockQuestID and questID and popUpType and popUpType == checkType and blockQuestID == questID then
            return true
        end
    end

    --fallback for cata
    if GW.Mists and checkType == "COMPLETE" and isComplete and isAutoComplete then
        return true
    end

    return false
end

function GwObjectivesBlockTemplateMixin:UpdateObjectiveActionButton()
    if not self.actionButton then return end
    local btn = self.actionButton

    self.hasItem = false

    if GW.Retail or GW.Mists or GW.TBC or GW.Wrath then
        if self.questLogIndex then
            local link, item, charges, showWhenComplete = GetQuestLogSpecialItemInfo(self.questLogIndex)
            local isComplete = GW.Retail and (self.questID and QuestCache:Get(self.questID):IsComplete()) or self.isComplete
            if item and (not isComplete or showWhenComplete) then
                self.hasItem = true
                btn.questLogIndex = self.questLogIndex
                btn.charges = charges
                btn.rangeTimer = -1
                SetItemButtonTexture(btn, item)
                SetItemButtonCount(btn, charges)
                btn:UpdateCooldown()
                btn:SetAttribute("type", "item")
                btn:SetAttribute("item", link)
                btn:SetScript("OnUpdate", btn.OnUpdate)
                btn:Show()
                return
            end
        end
        btn:Hide()
        btn:SetScript("OnUpdate", nil)
    elseif GW.Classic then
        if self.sourceItemId and not self.isComplete and btn:SetItem(self) then
            btn:SetScript("OnUpdate", btn.OnUpdate)
            btn:Show()
            self.hasItem = true
        else
            btn:FakeHide()
            btn.itemID, btn.questID, btn.itemName = nil, nil, nil
            btn:Hide()
            btn:SetScript("OnUpdate", nil)
        end
    end
end

function GwObjectivesBlockTemplateMixin:UpdateScenarioSpell(spellInfo)
    local btn = self.actionButton
    self.hasItem = false

    if not (GW.Classic or GW.TBC or GW.Wrath)  then
        if spellInfo and spellInfo[1] then
            local data = spellInfo[1]
            btn:SetSpell(data)
            btn:SetAttribute("type", "spell")
            btn:SetAttribute("spell", data.spellID)
            btn:Show()
            self.hasItem = true
            return
        end
        btn:Hide()
        btn:SetScript("OnUpdate", nil)
    end
end

function GwObjectivesBlockTemplateMixin:UpdateObjectiveActionButtonPosition()
    if not self.actionButton or not self.hasItem then
        return
    end

    -- The button is a SecureActionButton and cannot be moved in combat, so it is
    -- anchored to a frame that already carries the layout above it instead of to a
    -- position summed up from every container. For a block in the scrolled part that
    -- frame is the scroll child: it hangs below the fixed containers and moves with
    -- the scroll bar, so scrolling needs no reposition at all. Only the offset within
    -- the own column is left to add.
    local container = self:GetParent()
    local scrollChild = GwQuestTracker.ScrollFrame.Child
    local isScrolled = container:GetParent() == scrollChild
    local column = isScrolled and GW.QuestTrackerScrollableContainer or GW.QuestTrackerFixedContainer
    local height = self.fromContainerTopHeight or 0

    for _, other in ipairs(column) do
        if other == container then
            break
        end
        height = height + other:GetHeight()
    end

    self.actionButton:SetPoint("TOPLEFT", isScrolled and scrollChild or GwQuestTracker, "TOPRIGHT", -330, -height)
end
