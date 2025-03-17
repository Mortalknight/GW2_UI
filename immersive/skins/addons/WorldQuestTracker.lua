local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local containerMixin = CreateFromMixins(GwObjectivesContainerMixin)
function containerMixin:UpdateLayout()
    local objectiveDetailBlock
    local counter = 0
    local height = 1
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

local function LoadWQTAddonSkin()
    if not GW.settings.SKIN_WQT_ENABLED or not WorldQuestTrackerAddon then return end

    local fWQT = CreateFrame("Frame", "GwQuesttrackerContainerWQT", GwQuestTrackerScrollChild, "GwQuesttrackerContainer")
    Mixin(fWQT, containerMixin)

    tinsert(GW.QuestTrackerScrollableContainer, fWQT)

    fWQT:SetParent(GwQuestTrackerScrollChild)
    fWQT:SetPoint("TOPRIGHT", GwQuesttrackerContainerCollection, "BOTTOMRIGHT")

    fWQT.header = CreateFrame("Button", nil, fWQT, "GwQuestTrackerHeader")
    fWQT.header.icon:SetTexCoord(0, 0.5, 0.5, 0.75)
    fWQT.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    fWQT.header.title:SetShadowOffset(1, -1)
    fWQT.header.title:SetText("World Quest Tracker")
    fWQT.header.title:SetTextColor(TRACKER_TYPE_COLOR.EVENT.r, TRACKER_TYPE_COLOR.EVENT.g, TRACKER_TYPE_COLOR.EVENT.b)

    fWQT.collapsed = false
    fWQT.header:SetScript("OnMouseDown", function() fWQT:CollapseHeader() end) -- this way, otherwiese we have a wrong self at the function

    fWQT:UpdateLayout()
    hooksecurefunc(WorldQuestTrackerAddon, "RefreshTrackerAnchor", function() fWQT:UpdateLayout() end)
end
GW.LoadWQTAddonSkin = LoadWQTAddonSkin