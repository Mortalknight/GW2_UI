---@class GW2
local GW = select(2, ...)

-- blizzard places the nodes freely at posX / 10 and -posY / 10 and the trees 400 pixel apart,
-- nodes that would overlap on screen share a row or column
local TREE_SPACING = 4000
local OVERLAP = 300
local MAX_TIERS = 11
local NUM_COLUMNS = 4

local layout

local function GetConfigID(group)
    return C_SpecializationInfo.GetCombatConfigIDForSpecGroup(group or C_SpecializationInfo.GetActiveSpecGroup())
end

local function GetTreeID(configID)
    local info = configID and C_Traits.GetConfigInfo(configID)
    return info and info.treeIDs and info.treeIDs[1]
end

-- start of the slot every value belongs to, and the smallest distance between two slots
local function GetSlots(values)
    table.sort(values)
    local slotOf, starts, last = {}, {}, nil
    for _, value in ipairs(values) do
        if not last or value - last > OVERLAP then
            starts[#starts + 1] = value
        end
        slotOf[value] = starts[#starts]
        last = value
    end

    local step
    for i = 2, #starts do
        local delta = starts[i] - starts[i - 1]
        if not step or delta < step then
            step = delta
        end
    end
    return slotOf, starts[1] or 0, step or 1
end

local function BuildLayout(configID)
    local treeID = GetTreeID(configID)
    if not treeID then return end
    if layout and layout.treeID == treeID then return layout end

    local displayInfos = C_Traits.GetGroupDisplayInfoByTreeID(treeID)
    table.sort(displayInfos, function(a, b) return a.orderIndex < b.orderIndex end)

    local trees, treeByGroup = {}, {}
    for i, displayInfo in ipairs(displayInfos) do
        trees[i] = {groupID = displayInfo.groupID, name = displayInfo.displayName, icon = displayInfo.icon, nodes = {}, index = i}
        treeByGroup[displayInfo.groupID] = trees[i]
    end

    local nodes, xs, ys = {}, {}, {}
    for _, nodeID in ipairs(C_Traits.GetTreeNodes(treeID)) do
        local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
        if nodeInfo and nodeInfo.isVisible and #nodeInfo.entryIDs > 0 then
            for _, groupID in ipairs(nodeInfo.groupIDs) do
                local tree = treeByGroup[groupID]
                if tree then
                    nodes[#nodes + 1] = {info = nodeInfo, tree = tree}
                    xs[#xs + 1] = nodeInfo.posX
                    ys[#ys + 1] = nodeInfo.posY
                    break
                end
            end
        end
    end

    local slotX, _, stepX = GetSlots(xs)
    local slotY, minY, stepY = GetSlots(ys)

    -- the first column of all trees, shifted back by the tree spacing
    local originX = math.huge
    for _, node in ipairs(nodes) do
        originX = math.min(originX, slotX[node.info.posX] - (node.tree.index - 1) * TREE_SPACING)
    end

    local numTiers, position, treeOf, prereqs = GW.TalentData.NumTiers, {}, {}, {}
    for _, node in ipairs(nodes) do
        local nodeInfo = node.info
        local treeX = originX + (node.tree.index - 1) * TREE_SPACING
        local tier = math.floor((slotY[nodeInfo.posY] - minY) / stepY + 0.5) + 1
        local column = math.floor((slotX[nodeInfo.posX] - treeX) / stepX + 0.5) + 1
        if tier >= 1 and tier <= MAX_TIERS and column >= 1 and column <= NUM_COLUMNS then
            position[nodeInfo.ID] = {tier = tier, column = column}
            treeOf[nodeInfo.ID] = node.tree
            numTiers = math.max(numTiers, tier)
            tinsert(node.tree.nodes, nodeInfo.ID)
        end
    end

    -- our arrows only run downwards inside one tree
    for _, node in ipairs(nodes) do
        local source = position[node.info.ID]
        for _, edge in ipairs(node.info.visibleEdges) do
            local target = position[edge.targetNode]
            if source and target and treeOf[edge.targetNode] == node.tree and target.tier > source.tier then
                prereqs[edge.targetNode] = prereqs[edge.targetNode] or {}
                tinsert(prereqs[edge.targetNode], node.info.ID)
            end
        end
    end

    for _, tree in ipairs(trees) do
        table.sort(tree.nodes, function(a, b)
            local pa, pb = position[a], position[b]
            if pa.tier ~= pb.tier then return pa.tier < pb.tier end
            return pa.column < pb.column
        end)
    end

    -- the rows are built with the first layout
    GW.TalentData.NumTiers = numTiers
    layout = {treeID = treeID, trees = trees, position = position, prereqs = prereqs}
    return layout
end

local function GetNode(tree, index, group)
    local configID = GetConfigID(group)
    local data = configID and BuildLayout(configID)
    local nodeID = data and data.trees[tree] and data.trees[tree].nodes[index]
    if nodeID then
        return configID, nodeID, C_Traits.GetNodeInfo(configID, nodeID)
    end
end

local function GetDefinition(configID, nodeInfo)
    local entryID = nodeInfo.activeEntry and nodeInfo.activeEntry.entryID or nodeInfo.entryIDs[1]
    local entryInfo = entryID and C_Traits.GetEntryInfo(configID, entryID)
    return entryInfo and entryInfo.definitionID and C_Traits.GetDefinitionInfo(entryInfo.definitionID) or {}
end

-- the requirement lines like blizzard: only the highest gate, none of a type that is already met
local function AddRequirementLines(configID, nodeInfo, treeName)
    local conditions, metTypes, bestGate = {}, {}, nil
    for _, conditionID in ipairs(nodeInfo.conditionIDs) do
        local condInfo = C_Traits.GetConditionInfo(configID, conditionID, false, treeName)
        if condInfo then
            conditions[#conditions + 1] = condInfo
            if condInfo.isSufficient and condInfo.isMet then
                metTypes[condInfo.type] = true
            end
            if condInfo.isGate and (not bestGate or (condInfo.spentAmountRequired or 0) > (bestGate.spentAmountRequired or 0)) then
                bestGate = condInfo
            end
        end
    end

    local spacer = true
    local function AddLine(text, isError)
        if spacer then
            GameTooltip_AddBlankLineToTooltip(GameTooltip)
            spacer = false
        end
        if isError then
            GameTooltip_AddErrorLine(GameTooltip, text)
        else
            GameTooltip_AddHighlightLine(GameTooltip, text)
        end
    end

    for _, condInfo in ipairs(conditions) do
        if condInfo.tooltipText and (condInfo.isMet or not metTypes[condInfo.type]) and (not condInfo.isGate or condInfo == bestGate) then
            AddLine(condInfo.tooltipText)
        end
    end
    if not nodeInfo.meetsEdgeRequirements then
        AddLine(GENERIC_TRAIT_FRAME_EDGE_REQUIREMENTS_BUTTON_TOOLTIP, true)
    end
end

local function GetCurrency(group, excludeStaged)
    local configID = GetConfigID(group)
    local treeID = GetTreeID(configID)
    local currencyInfo = treeID and C_Traits.GetTreeCurrencyInfo(configID, treeID, excludeStaged)[1]
    return currencyInfo and currencyInfo.quantity or 0
end

GW.TalentData = {
    NumTiers = 7,
    HasPreviewOption = false,
    Events = {
        "TRAIT_CONFIG_UPDATED",
        "TRAIT_NODE_CHANGED",
        "TRAIT_TREE_CURRENCY_INFO_UPDATED",
        "ACTIVE_TALENT_GROUP_CHANGED",
        "PLAYER_TALENT_UPDATE",
        "CHARACTER_POINTS_CHANGED",
        "SPELLS_CHANGED",
    },

    -- forever stages every rank until it is applied
    UsesPreview = function() return true end,
    GetNumSpecGroups = function(isPet) return isPet and 0 or GetNumSpecGroups() end,
    GetActiveSpecGroup = function() return C_SpecializationInfo.GetActiveSpecGroup() end,
    GetUnspentPoints = function(_, group) return GetCurrency(group, true) end,
    GetPreviewPoints = function(_, group) return GetCurrency(group, true) - GetCurrency(group, false) end,

    ResetPreview = function(_, group)
        local configID = GetConfigID(group)
        if configID then
            C_Traits.RollbackConfig(configID)
        end
    end,

    CommitPreview = function(_, group)
        local configID = GetConfigID(group)
        if configID then
            C_Traits.CommitConfig(configID)
        end
    end,

    GetNumTrees = function(isPet)
        local configID = not isPet and GetConfigID()
        local data = configID and BuildLayout(configID)
        return data and #data.trees or 0
    end,

    GetNumTalents = function(tree)
        local info = layout and layout.trees[tree]
        return info and #info.nodes or 0
    end,

    GetTreeInfo = function(tree, _, group)
        local configID = GetConfigID(group)
        local info = configID and layout and layout.trees[tree]
        if not info then return "", nil, 0, 0 end

        local spent = 0
        local currencyInfo = C_Traits.GetGroupCurrencyInfo(configID, {info.groupID})[1]
        if currencyInfo and currencyInfo.currencyInfos[1] then
            spent = currencyInfo.currencyInfos[1].spent
        end
        return info.name, info.icon, spent, spent
    end,

    GetTalent = function(tree, index, _, group)
        local configID, nodeID, nodeInfo = GetNode(tree, index, group)
        if not nodeInfo then return end

        local position = layout.position[nodeID]
        local definitionInfo = GetDefinition(configID, nodeInfo)
        local spellID = definitionInfo.spellID
        local prereqs = {}
        for _, sourceID in ipairs(layout.prereqs[nodeID] or {}) do
            local source = layout.position[sourceID]
            prereqs[#prereqs + 1] = {tier = source.tier, column = source.column, met = nodeInfo.meetsEdgeRequirements}
        end

        return {
            tier = position.tier,
            column = position.column,
            rank = nodeInfo.currentRank,
            maxRank = nodeInfo.maxRanks,
            icon = definitionInfo.overrideIcon or (spellID and C_Spell.GetSpellTexture(spellID)),
            spellID = spellID,
            isExceptional = spellID and not C_Spell.IsSpellPassive(spellID),
            available = nodeInfo.isAvailable and nodeInfo.meetsEdgeRequirements,
            prereqs = prereqs,
        }
    end,

    Learn = function(tree, index, _, group)
        local configID, nodeID, nodeInfo = GetNode(tree, index, group)
        if nodeInfo and nodeInfo.canPurchaseRank then
            C_Traits.PurchaseRank(configID, nodeID)
        end
    end,

    Unlearn = function(tree, index, _, group)
        local configID, nodeID, nodeInfo = GetNode(tree, index, group)
        if nodeInfo and nodeInfo.canRefundRank then
            C_Traits.RefundRank(configID, nodeID)
        end
    end,

    GetLink = function(tree, index, _, group)
        local configID, _, nodeInfo = GetNode(tree, index, group)
        local spellID = nodeInfo and GetDefinition(configID, nodeInfo).spellID
        return spellID and C_Spell.GetSpellLink(spellID)
    end,

    SetTooltip = function(tree, index, _, group)
        local configID, _, nodeInfo = GetNode(tree, index, group)
        if not nodeInfo then return end

        local current, nextEntry = nodeInfo.activeEntry, nodeInfo.nextEntry
        local entry = nodeInfo.ranksPurchased > 0 and current or nextEntry or current
        if not entry then return end

        local definitionInfo = GetDefinition(configID, nodeInfo)
        GameTooltip_SetTitle(GameTooltip, definitionInfo.overrideName or (definitionInfo.spellID and C_Spell.GetSpellName(definitionInfo.spellID)) or "")
        GameTooltip_AddHighlightLine(GameTooltip, TOOLTIP_TALENT_RANK:format(nodeInfo.currentRank, nodeInfo.maxRanks))
        GameTooltip:AppendInfo("GetTraitEntry", entry.entryID, entry.rank)
        if nextEntry and nodeInfo.ranksPurchased > 0 then
            GameTooltip_AddBlankLineToTooltip(GameTooltip)
            GameTooltip_AddHighlightLine(GameTooltip, TALENT_BUTTON_TOOLTIP_NEXT_RANK)
            GameTooltip:AppendInfo("GetTraitEntry", nextEntry.entryID, nextEntry.rank)
        end

        AddRequirementLines(configID, nodeInfo, layout.trees[tree].name)

        if nodeInfo.canPurchaseRank and GetCurrency(group, false) > 0 then
            GameTooltip_AddBlankLineToTooltip(GameTooltip)
            GameTooltip_AddInstructionLine(GameTooltip, TALENT_BUTTON_TOOLTIP_PURCHASE_INSTRUCTIONS)
        elseif nodeInfo.canRefundRank then
            GameTooltip_AddBlankLineToTooltip(GameTooltip)
            GameTooltip_AddDisabledLine(GameTooltip, TALENT_BUTTON_TOOLTIP_REFUND_INSTRUCTIONS)
        end
        return true
    end,
}
