---@class GW2
local GW = select(2, ...)

GwObjectivesContainerMixin = {}

function GwObjectivesContainerMixin:UpdateLayout()
    -- override per module
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

function GwObjectivesContainerMixin:GetBlock(idx, colorKey, addItemButton)
    local block = self.blocks and self.blocks[idx]
    if block then
        block:ApplyLayoutStyle()
        -- set the correct block color for an existing block here
        block:SetBlockColorByKey(colorKey)
        block.Header:SetTextColor(block.color.r, block.color.g, block.color.b)
        block.hover:SetVertexColor(block.color.r, block.color.g, block.color.b)
        for _, obj in ipairs(block.objectiveBlocks) do
            obj.StatusBar:SetStatusBarColor(block.color.r, block.color.g, block.color.b)
            obj.TimerBar:SetStatusBarColor(block.color.r, block.color.g, block.color.b)
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
    newBlock:SetBlockColorByKey(colorKey)
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)

    newBlock:SetScript("OnMouseDown", self.BlockOnClick)

    if self.blockMixInTemplate then
        Mixin(newBlock, self.blockMixInTemplate)
    end

    newBlock:ApplyLayoutStyle()

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
