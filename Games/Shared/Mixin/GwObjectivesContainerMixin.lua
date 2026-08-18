---@class GW2
local GW = select(2, ...)

GwObjectivesContainerMixin = {}

function GwObjectivesContainerMixin:UpdateLayout()
    -- override per module
end

-- Positions the shown blocks under the header and takes the container height from
-- their actual rects, so there is one source of truth instead of a parallel height
-- count. Call it AFTER the unused blocks are hidden.
-- The anchors are refreshed every pass on purpose: a block hidden in between keeps
-- its rect (anchors ignore visibility) and would leave a hole, and the header offset
-- baked in when the block was created goes stale when compact mode changes it.
function GwObjectivesContainerMixin:LayoutBlocks(numShown)
    local headerOffset = (self.header and self.header:IsShown()) and GW.GetObjectivesHeaderHeight() or 0
    local height = headerOffset
    local shown = 0
    local previous

    local blockGap = GW.GetObjectivesBlockGap()

    for i = 1, (numShown or #self.blocks) do
        local block = self.blocks[i]
        if block and block:IsShown() then
            block:ClearAllPoints()
            if previous then
                block:SetPoint("TOPRIGHT", previous, "BOTTOMRIGHT", 0, -blockGap)
            else
                block:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -headerOffset)
            end
            -- one gap per block: the anchors consume all but the last, which becomes the
            -- container's own bottom margin
            height = height + block:GetHeight() + blockGap
            -- the item button is placed from this offset: it is a SecureActionButton,
            -- so it must not be moved in combat and cannot be anchored to the block
            block.fromContainerTopHeight = height
            shown = shown + 1
            previous = block
        end
    end

    self:SetHeight(math.max(height, GW.OBJECTIVES_EMPTY_HEIGHT))

    return height, shown
end

function GwObjectivesContainerMixin:BlockOnClick()
    -- override per module
end

function GwObjectivesContainerMixin:SetCollapsed(collapsed, source)
    local wasCollapsed = self.collapsed == true
    collapsed = collapsed == true

    if source == "autoCollapse" then
        self.autoCollapseActive = collapsed

        if collapsed then
            if self.autoCollapseManualOverride then
                return
            end

            if not wasCollapsed then
                self.collapsedByAutoCollapse = true
            end
        else
            self.autoCollapseManualOverride = nil

            if not self.collapsedByAutoCollapse then
                return
            end

            self.collapsedByAutoCollapse = nil
        end
    else
        if self.autoCollapseActive and wasCollapsed and not collapsed then
            self.autoCollapseManualOverride = true
        elseif collapsed then
            self.autoCollapseManualOverride = nil
        end

        self.collapsedByAutoCollapse = nil
    end

    if wasCollapsed == collapsed then
        return
    end

    self.collapsed = collapsed
    if collapsed then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    else
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
    self:UpdateLayout()
end

function GwObjectivesContainerMixin:ToggleCollapsed()
    self:SetCollapsed(not self.collapsed)
end

function GwObjectivesContainerMixin:GetBlock(idx, colorKey, addItemButton)
    local block = self.blocks and self.blocks[idx]
    if block then
        -- style and colors only change with the compact mode setting or when the block
        -- gets reused for another module color — a content update re-hides the rows only
        if block.gwLayoutGeneration ~= GW.ObjectivesTrackerState.layoutGeneration then
            block.gwLayoutGeneration = GW.ObjectivesTrackerState.layoutGeneration
            block:ApplyLayoutStyle()
        end
        if block.gwColorKey ~= colorKey then
            block.gwColorKey = colorKey
            block:SetBlockColorByKey(colorKey)
            block.Header:SetTextColor(block.color.r, block.color.g, block.color.b)
            block.hover:SetVertexColor(block.color.r, block.color.g, block.color.b)
            for _, obj in ipairs(block.objectiveBlocks) do
                obj.StatusBar:SetStatusBarColor(block.color.r, block.color.g, block.color.b)
            end
        end
        for _, obj in ipairs(block.objectiveBlocks) do
            obj:Hide()
        end
        return block
    end

    local count = #self.blocks + 1

    local newBlock = CreateFrame("Button", nil, self, "GwObjectivesBlockTemplate")
    newBlock:SetParent(self)
    tinsert(self.blocks, newBlock)

    newBlock.objectiveBlocks = {}

    if count == 1 then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -GW.GetObjectivesHeaderHeight())
    else
        newBlock:SetPoint("TOPRIGHT", self.blocks[count - 1], "BOTTOMRIGHT", 0, 0)
    end

    newBlock.index = idx
    newBlock.gwColorKey = colorKey
    newBlock:SetBlockColorByKey(colorKey)
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)

    newBlock:SetScript("OnMouseDown", self.BlockOnClick)

    if self.blockMixInTemplate then
        Mixin(newBlock, self.blockMixInTemplate)
    end

    newBlock:ApplyLayoutStyle()
    newBlock.gwLayoutGeneration = GW.ObjectivesTrackerState.layoutGeneration

    -- quest item button here
    if addItemButton then
        newBlock.actionButton = CreateFrame("Button", nil, GwQuestTracker, "GwQuestItemTemplate")
        newBlock.actionButton.NormalTexture:SetTexture(nil)
        newBlock.actionButton.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        newBlock.actionButton.Icon = newBlock.actionButton.icon
        Mixin(newBlock.actionButton, GwObjectivesItemButtonMixin)
        newBlock.actionButton:SetAttribute("type1", "item")
        newBlock.actionButton:SetAttribute("type2", "stop")
        if GW.Classic then
            newBlock.actionButton:FakeHide()
        end
        if GW.Retail or GW.TBC or GW.Wrath then
            newBlock.actionButton:RegisterForClicks("AnyUp", "AnyDown")
        else
            newBlock.actionButton:RegisterForClicks("AnyDown")
        end
        newBlock.actionButton:SetScript("OnLeave", GameTooltip_Hide)
        newBlock.actionButton:SetScript("OnEnter", newBlock.actionButton.OnEnter)
        newBlock.actionButton:SetScript("OnShow", newBlock.actionButton.OnShow)
        newBlock.actionButton:SetScript("OnHide", newBlock.actionButton.OnHide)
        newBlock.actionButton:SetScript("OnEvent", newBlock.actionButton.OnEvent)
    end

    return newBlock
end
