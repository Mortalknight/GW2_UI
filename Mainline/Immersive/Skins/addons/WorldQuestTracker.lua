local _, GW = ...

GwWorldQuestTrackerContainerMixin =  {}
function GwWorldQuestTrackerContainerMixin:UpdateLayout()
    local objectiveDetailBlock
    local counter = 0
    local height = 0.001
    local foundEvent = false
    local wqtFrame

    for i = 1, 25 do
        wqtFrame = _G["WorldQuestTracker_Tracker" .. i]

        if wqtFrame and wqtFrame:IsShown() then
            counter = counter + 1
            foundEvent = true

            if counter == 1 then
                height = 20
            end

            local block = self:GetBlock(counter, GW.Enum.ObjectivesNotificationType.Event, false)
            block.Header:SetText(wqtFrame.Title:GetText())
            wqtFrame.Title:Hide()
            objectiveDetailBlock = block:GetObjectiveBlock(1)
            objectiveDetailBlock:SetHeight(wqtFrame:GetHeight())

            wqtFrame:SetParent(objectiveDetailBlock)
            wqtFrame:ClearAllPoints()
            wqtFrame:SetAllPoints()
            wqtFrame.Zone:SetPoint ("TOPLEFT", wqtFrame, "TOPLEFT", 10, -7)
            wqtFrame.Circle:Hide()
            wqtFrame.Shadow:Hide()
            wqtFrame.SuperTracked:SetTexture("Interface/AddOns/GW2_UI/textures/bag/stancebar-border.png")
            wqtFrame.SuperTracked:SetSize(20, 20)

            objectiveDetailBlock:Show()
            objectiveDetailBlock.ObjectiveText:SetText("")
            objectiveDetailBlock.StatusBar:Hide()
            block:SetHeight(objectiveDetailBlock:GetHeight() + 35)
            height = height + block:GetHeight()
            block:Show()
        end
    end

    for i = (self.collapsed and foundEvent and 1 or counter + 1), #self.blocks do
        local block = self.blocks[i]
        if block:IsShown() then
            block:Hide()
        end
    end

    if WorldQuestTrackerQuestsHeader then
        WorldQuestTrackerQuestsHeader:Hide()
        WorldQuestTrackerQuestsHeaderMinimizeButton:Hide()
    end

    if self.collapsed and foundEvent then
        height = 20
    end

    self.header:SetShown(counter > 0 or foundEvent)
    self:SetHeight(height)
    GwQuestTracker:LayoutChanged()
end

function GwWorldQuestTrackerContainerMixin:InitModule()
    if not GW.settings.SKIN_WQT_ENABLED or not WorldQuestTrackerAddon then return end

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0, 0.5, 0.5, 0.75)
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText("World Quest Tracker")
    self.header.title:SetTextColor(GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Event]:GetRGB())

    self.collapsed = false
    self.header:SetScript("OnMouseDown", function() self:CollapseHeader() end) -- this way, otherwiese we have a wrong self at the function

    self:UpdateLayout()
    hooksecurefunc(WorldQuestTrackerAddon, "RefreshTrackerAnchor", function() self:UpdateLayout() end)
end
