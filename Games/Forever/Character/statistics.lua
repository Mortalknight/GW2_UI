---@class GW2
local GW = select(2, ...)

local ARROW = "Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png"

local function SetArrow(texture, collapsed)
    texture:SetTexture(ARROW)
    texture:SetRotation(collapsed and math.pi / 2 or 0)
end

local function UpdateHeaderArrow(header)
    SetArrow(header.StateIcon, header.treeNode and header.treeNode:IsCollapsed())
end

local function UpdateToggleArrow(button)
    local header = button:GetHeader()
    local collapsed = header and header.treeNode and header.treeNode:IsCollapsed()
    SetArrow(button:GetNormalTexture(), collapsed)
    SetArrow(button:GetPushedTexture(), collapsed)
end

local function SkinChild(child)
    if child.StateIcon then
        child:GwStripTextures()
        child:GwCreateBackdrop()
        child.backdrop:GwSetInside(child)
        child.StateIcon:SetSize(20, 20)
        UpdateHeaderArrow(child)
        hooksecurefunc(child, "RefreshStateIcon", UpdateHeaderArrow)
        child.Name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        child.Name:GwLockTextColor(1, 1, 1)
    end

    if child.ToggleCollapseButton then
        child.ToggleCollapseButton:SetSize(16, 16)
        UpdateToggleArrow(child.ToggleCollapseButton)
        hooksecurefunc(child.ToggleCollapseButton, "RefreshIcon", UpdateToggleArrow)
    end

    if child.Content then
        child.Content.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        child.Content.Value:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        child.Content.Name:GwLockTextColor(1, 1, 1)
        child.Content.Value:GwLockTextColor(1, 1, 1)
        child.Content.Value:SetWidth(120)
        if child.Content.BackgroundHighlight then
            child.Content.BackgroundHighlight:GwKill()
        end
        GW.AddListItemChildHoverTexture(child)
    end

    if child.ToggleCollapseButton then
        child.Content.Name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    end
end

local function UpdateStatisticsSkins(scrollBox)
    for _, child in next, {scrollBox.ScrollTarget:GetChildren()} do
        if not child.gwSkinned then
            SkinChild(child)
            child.gwSkinned = true
        end
    end
    GW.HandleItemListScrollBoxHover(scrollBox)
end

local function KeepInContainer(frame, container, ...)
    local points = {...}
    hooksecurefunc(frame, "SetParent", function(self, parent)
        if parent ~= container then
            self:SetParent(container)
        end
    end)
    hooksecurefunc(frame, "SetPoint", function(self, _, relativeTo)
        if relativeTo ~= container then
            self:ClearAllPoints()
            self:SetPoint(unpack(points))
        end
    end)
end

local function LoadStatistics(tabContainer)
    local window = CreateFrame("Frame", "GwCharacterStatisticsFrame", tabContainer, "GwStatisticsWindowTemplate")
    local content = window.Content

    StatisticsFrame:SetParent(content)
    StatisticsFrame:ClearAllPoints()
    StatisticsFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -15)
    StatisticsFrame:SetSize(580, 560)
    StatisticsFrame.ScrollBox:ClearAllPoints()
    StatisticsFrame.ScrollBox:SetPoint("TOPLEFT", StatisticsFrame, 4, 0)
    StatisticsFrame.ScrollBox:SetPoint("BOTTOMRIGHT", StatisticsFrame, -22, 0)
    StatisticsFrame:Show()

    -- the Blizzard character frame keeps toggling its sub frames, ours only follows the container
    StatisticsFrame.Hide = StatisticsFrame.Show
    hooksecurefunc(StatisticsFrame, "SetShown", function(self) self:Show() end)
    KeepInContainer(StatisticsFrame, content, "TOPLEFT", content, "TOPLEFT", 0, -15)
    KeepInContainer(StatisticsFrame.ScrollBox, StatisticsFrame, "TOPLEFT", StatisticsFrame, "TOPLEFT", 4, 0)

    -- the scroll box carries two decorative scroll line frames besides its scroll target
    for _, child in ipairs({StatisticsFrame.ScrollBox:GetChildren()}) do
        if child ~= StatisticsFrame.ScrollBox.ScrollTarget then
            child:Hide()
        end
    end
    GW.HandleTrimScrollBar(StatisticsFrame.ScrollBar)
    StatisticsFrame.ScrollBar:SetHideIfUnscrollable(true)
    GW.HandleScrollControls(StatisticsFrame)
    hooksecurefunc(StatisticsFrame.ScrollBox, "Update", UpdateStatisticsSkins)
end
GW.LoadStatistics = LoadStatistics
