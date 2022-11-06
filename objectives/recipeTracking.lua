local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local ParseObjectiveString = GW.ParseObjectiveString
local FormatObjectiveNumbers = GW.FormatObjectiveNumbers
local CreateObjectiveNormal = GW.CreateObjectiveNormal
local CreateTrackerObject = GW.CreateTrackerObject
local setBlockColor = GW.setBlockColor

local collectedItemIDs = {}

local function CreateRecipeDropdown(block)
    return {
        {text = block.title, isTitle = true, notCheckable = true},
        {text = PROFESSIONS_TRACKING_VIEW_RECIPE, isTitle = false, notCheckable = true, func = function() C_TradeSkillUI.OpenRecipe(block.id) end},
        {text = PROFESSIONS_UNTRACK_RECIPE, hasArrow = false, notCheckable = true, func = function() C_TradeSkillUI.SetRecipeTracked(block.id, false) end},
    }
end

local function recipe_OnClick(self, button)
    if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
        local link = C_TradeSkillUI.GetRecipeLink(self.id)
        if link then
            ChatEdit_InsertLink(link)
        end
    elseif button ~= "RightButton" then
        if not ProfessionsFrame then
            ProfessionsFrame_LoadUI()
        end
        if IsModifiedClick("RECIPEWATCHTOGGLE") then
            C_TradeSkillUI.SetRecipeTracked(self.id, false)
        else
            C_TradeSkillUI.OpenRecipe(self.id)
        end
    else
        GW.SetEasyMenuAnchor(GW.EasyMenu, self)
        EasyMenu(self.gwDropdown, GW.EasyMenu, nil, nil, nil, "MENU")
    end
end

local function getObjectiveBlock(self)
    if _G[self:GetName() .. "GwRecipeObjective" .. self.numObjectives] then
        return _G[self:GetName() .. "GwRecipeObjective" .. self.numObjectives]
    end

    self.objectiveBlocks = self.objectiveBlocks or {}

    local newBlock = CreateObjectiveNormal(self:GetName() .. "GwRecipeObjective" .. self.numObjectives, self)
    newBlock:SetParent(self)

    self.objectiveBlocks[#self.objectiveBlocks] = newBlock

    if self.numObjectives == 1 then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -25)
    else
        newBlock:SetPoint("TOPRIGHT", _G[self:GetName() .. "GwRecipeObjective" .. self.numObjectives - 1], "BOTTOMRIGHT", 0, 0)
    end

    newBlock.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)

    return newBlock
end

local function getBlock(blockIndex)
    if _G["GwRecipeBlock" .. blockIndex] then
    return  _G["GwRecipeBlock" .. blockIndex]
    end

    local newBlock = CreateTrackerObject("GwRecipeBlock" .. blockIndex, GwQuesttrackerContainerRecipe)
    newBlock:SetParent(GwQuesttrackerContainerRecipe)

    if blockIndex == 1 then
        newBlock:SetPoint("TOPRIGHT", GwQuesttrackerContainerRecipe, "TOPRIGHT", 0, -20)
    else
        newBlock:SetPoint("TOPRIGHT", _G["GwRecipeBlock" .. (blockIndex - 1)], "BOTTOMRIGHT", 0, 0)
    end
    newBlock.height = 0
    setBlockColor(newBlock, "RECIPE")
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    return newBlock
end

local function addObjective(block, text, finished, qty, totalqty)
    if finished or not text then
        return
    end

    block.numObjectives = block.numObjectives + 1
    local objectiveBlock = getObjectiveBlock(block)

    objectiveBlock:Show()
    objectiveBlock.ObjectiveText:SetText(FormatObjectiveNumbers(text))
    objectiveBlock.ObjectiveText:SetHeight(objectiveBlock.ObjectiveText:GetStringHeight() + 15)
    objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)

    if ParseObjectiveString(objectiveBlock, text, nil, nil, qty, totalqty) then
        --added progressbar in ParseObjectiveString
    else
        objectiveBlock.StatusBar:Hide()
    end
    local h = objectiveBlock.ObjectiveText:GetStringHeight() + 10
    objectiveBlock:SetHeight(h)
    if objectiveBlock.StatusBar:IsShown() then
        if block.numObjectives >= 1 then
            h = h + objectiveBlock.StatusBar:GetHeight() + 10
        else
            h = h + objectiveBlock.StatusBar:GetHeight() + 5
        end
        objectiveBlock:SetHeight(h)
    end
    block.height = block.height + objectiveBlock:GetHeight()
end

local function updateRecipeObjectives(block, recipeSchematic)
    local allCollacted = true
    block.height = 35
    block.numObjectives = 0

    for _, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
        if reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic then
            local reagent = reagentSlotSchematic.reagents[1]
            if reagent.itemID then
                local item = Item:CreateFromItemID(reagent.itemID)
                local itemName = item:GetItemName()
                local quantity = Professions.AccumulateReagentsInPossession(reagentSlotSchematic.reagents)
                local quantityRequired = reagentSlotSchematic.quantityRequired
                if quantity < quantityRequired then
                    allCollacted = false
                end
                addObjective(block, itemName, quantity >= quantityRequired, quantity, quantityRequired)
            end
        end
    end

    if allCollacted then
        addObjective(block, "Ready to craft", false, 0, 0)
    end

    for i = block.numObjectives + 1, 20 do
        if _G[block:GetName() .. "GwRecipeObjective" .. i] then
            _G[block:GetName() .. "GwRecipeObjective" .. i]:Hide()
        end
    end

    block:SetHeight(block.height)
end

local function updateRecipeLayout(self)
    local numRecipes = #C_TradeSkillUI.GetRecipesTracked()
    local savedHeight = 1
    local shownIndex = 1
    local isRecraft = false

    self.header:Hide()

    if self.collapsed then
        self.header:Show()
        numRecipes = 0
        savedHeight = 20
    end

    for i = 1, numRecipes do
        local recipeID = C_TradeSkillUI.GetRecipesTracked()[i]
        local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft)

        self.header:Show()
        local block = getBlock(shownIndex)
        if block == nil then
            return
        end
        block.id = recipeID
        block.title = recipeSchematic.name
        updateRecipeObjectives(block, recipeSchematic)
        block.Header:SetText(recipeSchematic.name)

        block:Show()

        block.gwDropdown = CreateRecipeDropdown(block)

        block:SetScript("OnClick", recipe_OnClick)

        savedHeight = savedHeight + block.height

        shownIndex = shownIndex + 1
    end

    self:SetHeight(savedHeight)

    for i = shownIndex, 25 do
        if _G["GwRecipeBlock" .. i] then
            _G["GwRecipeBlock" .. i]:Hide()
            _G["GwRecipeBlock" .. i].id = nil
        end
    end
end

local function GetAllBasicReagentItemIDs()
    wipe(collectedItemIDs)
    for _, recipeID in ipairs(C_TradeSkillUI.GetRecipesTracked()) do
        for _, itemID in ipairs(Professions.CreateRecipeItemIDsForAllBasicReagents(recipeID)) do
            table.insert(collectedItemIDs, itemID)
        end
    end
end

local function OnEvent(self, event, ...)
    if event == "TRACKED_RECIPE_UPDATE" then
        GetAllBasicReagentItemIDs()
        updateRecipeLayout(self)
    elseif event == "ITEM_COUNT_CHANGED" then
        local itemID = ...
        if tContains(collectedItemIDs, itemID) then
            updateRecipeLayout(self)
        end
    elseif event == "SKILL_LINES_CHANGED" then
        for _, recipeID in ipairs(C_TradeSkillUI.GetRecipesTracked()) do
            if not C_TradeSkillUI.IsRecipeProfessionLearned(recipeID) then
                C_TradeSkillUI.SetRecipeTracked(recipeID, false)
            end
        end
    end
end

local function LoadRecipeTracking(self)
    self:RegisterEvent("TRACKED_RECIPE_UPDATE")
    self:RegisterEvent("ITEM_COUNT_CHANGED")
    self:RegisterEvent("SKILL_LINES_CHANGED")
    self:SetScript("OnEvent", OnEvent)

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0, 0.5, 0, 0.25) -- CHANGE
    self.header.title:SetFont(UNIT_NAME_FONT, 14)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText(PROFESSIONS_TRACKER_HEADER_PROFESSION)

    self.collapsed = false
    self.header:SetScript(
        "OnMouseDown",
        function(self)
            local p = self:GetParent()
            if p.collapsed == false then
                p.collapsed = true
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
            else
                p.collapsed = false
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            end
            updateRecipeLayout(p)
        end
    )
    self.header.title:SetTextColor(
        TRACKER_TYPE_COLOR.RECIPE.r,
        TRACKER_TYPE_COLOR.RECIPE.g,
        TRACKER_TYPE_COLOR.RECIPE.b
    )

    GetAllBasicReagentItemIDs()

    updateRecipeLayout(self)
end
GW.LoadRecipeTracking = LoadRecipeTracking
