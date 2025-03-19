local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

GwWorldQuestTrackerContainerMixin =  {}
function GwWorldQuestTrackerContainerMixin:UpdateLayout()
    if not WorldQuestTrackerAddon then return end
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

            local block = self:GetBlock(counter, "EVENT", false)
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
            wqtFrame.SuperTracked:SetTexture("Interface/AddOns/GW2_UI/textures/bag/stancebar-border")
            wqtFrame.SuperTracked:SetSize(20, 20)

            objectiveDetailBlock:Show()
            objectiveDetailBlock.ObjectiveText:SetText("")
            objectiveDetailBlock.StatusBar:Hide()
            block:SetHeight(objectiveDetailBlock:GetHeight() + 35)
            height = height + block:GetHeight()
            block:Show()
        end
    end

    for i = (self.collapsed and foundEvent and 1 or counter + 1), 25 do
        local block = _G[self:GetName() .. "Block" .. i]
        if block and block:IsShown() then
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
    if not GW.settings.SKIN_WQT_ENABLED then return end

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0, 0.5, 0.5, 0.75)
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText("World Quest Tracker")
    self.header.title:SetTextColor(TRACKER_TYPE_COLOR.EVENT.r, TRACKER_TYPE_COLOR.EVENT.g, TRACKER_TYPE_COLOR.EVENT.b)

    self.collapsed = false
    self.header:SetScript("OnMouseDown", function() self:CollapseHeader() end) -- this way, otherwiese we have a wrong self at the function

    if WorldQuestTrackerAddon then
        self:UpdateLayout()
        hooksecurefunc(WorldQuestTrackerAddon, "RefreshTrackerAnchor", function() self:UpdateLayout() end)
    end
end
