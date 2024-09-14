local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local function getObjectiveBlock(self, index)
    if _G[self:GetName() .. "GwWQTObjective" .. index] then
        return _G[self:GetName() .. "GwWQTObjective" .. index]
    end

    local newBlock = GW.CreateObjectiveNormal(self:GetName() .. "GwWQTObjective1", self)
    newBlock:SetParent(self)
    newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -25)
    newBlock.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)

    return newBlock
end
GW.AddForProfiling("bonusObjective", "getObjectiveBlock", getObjectiveBlock)

local function createNewWQTObjectiveBlock(blockIndex, parent)
    if _G["GwWQTBlock" .. blockIndex] then
        return _G["GwWQTBlock" .. blockIndex]
    end

    local newBlock = GW.CreateTrackerObject("GwWQTBlock" .. blockIndex, parent)
    newBlock:SetParent(parent)

    if blockIndex == 1 then
        newBlock:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -20)
    else
        newBlock:SetPoint("TOPRIGHT", _G["GwWQTBlock" .. (blockIndex - 1)], "BOTTOMRIGHT", 0, 0)
    end

    newBlock.color = TRACKER_TYPE_COLOR.EVENT
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)

    newBlock:Hide()

    return newBlock
end

local function addWQTTrackerQuest(self)
    local objectiveBlock, objectiveDetailBlock
    local counter = 0
    local height = 1
    local foundEvent = false
    local wqtFrame

    for i = 1, 25 do
        wqtFrame = _G["WorldQuestTracker_Tracker" .. i]

        if wqtFrame and wqtFrame:IsShown() then
            counter = counter + 1
            foundEvent = true

            objectiveBlock = createNewWQTObjectiveBlock(counter, self)
            objectiveBlock.Header:SetText(wqtFrame.Title:GetText())
            wqtFrame.Title:Hide()
            objectiveDetailBlock = getObjectiveBlock(objectiveBlock, 1)
            objectiveDetailBlock:SetHeight(wqtFrame:GetHeight())
            wqtFrame:SetParent(objectiveDetailBlock)
            wqtFrame:ClearAllPoints()
            wqtFrame:SetAllPoints()
            wqtFrame.Zone:SetPoint ("TOPLEFT", wqtFrame, "TOPLEFT", 10, -7)
            --wqtFrame.Icon:RemoveMaskTexture( wqtFrame.Icon:GetMaskTexture(0))
            --wqtFrame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            wqtFrame.Circle:Hide()
            wqtFrame.Shadow:Hide()
            wqtFrame.SuperTracked:SetTexture("Interface/AddOns/GW2_UI/textures/bag/stancebar-border")
            wqtFrame.SuperTracked:SetSize(20, 20)

            objectiveDetailBlock:Show()
            objectiveDetailBlock.ObjectiveText:SetText("")
            objectiveDetailBlock.StatusBar:Hide()

            objectiveBlock:SetHeight(objectiveDetailBlock:GetHeight() + 30)
            height = height + objectiveBlock:GetHeight()
            objectiveBlock:Show()
        end
    end

    for i = (self.collapsed and foundEvent and 1 or counter + 1), 25 do
        if _G["GwWQTBlock" .. i] and _G["GwWQTBlock" .. i]:IsShown() then
            _G["GwWQTBlock" .. i]:Hide()
        end
    end

    if WorldQuestTrackerQuestsHeader then
        WorldQuestTrackerQuestsHeader:Hide()
        WorldQuestTrackerQuestsHeaderMinimizeButton:Hide()
    end

    self.header:SetShown(counter > 0 or foundEvent)
    self:SetHeight(height)
    GW.QuestTrackerLayoutChanged()
end

local function CollapseHeader(self, forceCollapse, forceOpen)
    if (not self.collapsed or forceCollapse) and not forceOpen then
        self.collapsed = true
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    else
        self.collapsed = false
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
    addWQTTrackerQuest(GwQuesttrackerContainerWQT)
end
GW.CollapseWQTAddonHeader = CollapseHeader

local function LoadWQTAddonSkin()
    if not GW.settings.SKIN_WQT_ENABLED or not WorldQuestTrackerAddon then return end

    local fWQT = CreateFrame("Frame", "GwQuesttrackerContainerWQT", GwQuestTrackerScrollChild, "GwQuesttrackerContainer")
    fWQT:SetParent(GwQuestTrackerScrollChild)
    fWQT:SetPoint("TOPRIGHT", GwQuesttrackerContainerCollection, "BOTTOMRIGHT")

    fWQT.header = CreateFrame("Button", nil, fWQT, "GwQuestTrackerHeader")
    fWQT.header.icon:SetTexCoord(0, 0.5, 0.5, 0.75)
    fWQT.header.title:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    fWQT.header.title:SetShadowOffset(1, -1)
    fWQT.header.title:SetText("World Quest Tracker")
    fWQT.header.title:SetTextColor(TRACKER_TYPE_COLOR.EVENT.r, TRACKER_TYPE_COLOR.EVENT.g, TRACKER_TYPE_COLOR.EVENT.b)

    fWQT.collapsed = false
    fWQT.header:SetScript("OnMouseDown",
        function(self)
            CollapseHeader(self:GetParent(), false, false)
        end
    )

    addWQTTrackerQuest(fWQT)
    hooksecurefunc(WorldQuestTrackerAddon, "RefreshTrackerAnchor", function() addWQTTrackerQuest(fWQT) end)
end
GW.LoadWQTAddonSkin = LoadWQTAddonSkin