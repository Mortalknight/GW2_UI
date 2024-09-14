local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local ParseObjectiveString = GW.ParseObjectiveString
local CreateObjectiveNormal = GW.CreateObjectiveNormal
local CreateTrackerObject = GW.CreateTrackerObject
local setBlockColor = GW.setBlockColor

local IsRecrafting = true

local function GetRecipeID(block)
    return math.abs(block.id)
end

local function IsRecraftBlock(block)
    return block.isRecraft
end

local function recipe_OnClick(self, button)
    if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
        local link = C_TradeSkillUI.GetRecipeLink(GetRecipeID(self))
        if link then
            ChatEdit_InsertLink(link)
        end
    elseif button ~= "RightButton" then
        if not ProfessionsFrame then
            ProfessionsFrame_LoadUI()
            ProfessionsFrame_LoadUI()
        end
        if IsModifiedClick("RECIPEWATCHTOGGLE") then
            C_TradeSkillUI.SetRecipeTracked(GetRecipeID(self), false, IsRecraftBlock(self))
        else
            if not IsRecraftBlock(self) then
                C_TradeSkillUI.OpenRecipe(GetRecipeID(self))
                C_Timer.After(0, function() C_TradeSkillUI.OpenRecipe(GetRecipeID(self)) end)
            end
        end
    else
        MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
            rootDescription:CreateTitle(self.title)
            if not IsRecraftBlock(self) then
                rootDescription:CreateButton(PROFESSIONS_TRACKING_VIEW_RECIPE, function()
                    if not ProfessionsFrame then
                        ProfessionsFrame_LoadUI()
                        ProfessionsFrame_LoadUI()
                    end
                    C_TradeSkillUI.OpenRecipe(GetRecipeID(self))
                    C_Timer.After(0, function() C_TradeSkillUI.OpenRecipe(GetRecipeID(self)) end)
                end)
            end
            rootDescription:CreateButton(PROFESSIONS_UNTRACK_RECIPE, function() C_TradeSkillUI.SetRecipeTracked(GetRecipeID(self), false, IsRecraftBlock(self)) end)
        end)
    end
end

local function getObjectiveBlock(self)
    if _G[self:GetName() .. "Objective" .. self.numObjectives] then
        return _G[self:GetName() .. "Objective" .. self.numObjectives]
    end

    self.objectiveBlocks = self.objectiveBlocks or {}

    local newBlock = CreateObjectiveNormal(self:GetName() .. "Objective" .. self.numObjectives, self)
    newBlock:SetParent(self)

    self.objectiveBlocks[#self.objectiveBlocks] = newBlock

    if self.numObjectives == 1 then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -25)
    else
        newBlock:SetPoint("TOPRIGHT", _G[self:GetName() .. "Objective" .. self.numObjectives - 1], "BOTTOMRIGHT", 0, 0)
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
    if qty < totalqty then
        objectiveBlock.ObjectiveText:SetText(GW.CommaValue(qty) .. "/" .. GW.CommaValue(totalqty) .. " " .. text)
    else
        objectiveBlock.ObjectiveText:SetText(text)
    end
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
                local quantity = ProfessionsUtil.AccumulateReagentsInPossession(reagentSlotSchematic.reagents)
                local quantityRequired = reagentSlotSchematic.quantityRequired
                if quantity < quantityRequired then
                    allCollacted = false
                end
                addObjective(block, itemName, quantity >= quantityRequired, quantity, quantityRequired)
            end
        end
    end

    if allCollacted then
        addObjective(block, GW.L["Ready to craft"], false, 0, 0)
    end

    for i = block.numObjectives + 1, 20 do
        if _G[block:GetName() .. "Objective" .. i] then
            _G[block:GetName() .. "Objective" .. i]:Hide()
        end
    end

    block:SetHeight(block.height)
end

local function CreateTrackedBlock(self, idx, isRecraft, savedHeight, shownIndex)
    local recipeID = C_TradeSkillUI.GetRecipesTracked(isRecraft)[idx]
    local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft)

    if idx == 1 then
        savedHeight = 20
    end

    self.header:Show()
    local block = getBlock(shownIndex)
    if block == nil then
        return 0, 0
    end
    block.id = recipeID
    block.isRecraft = isRecraft
    block.title = recipeSchematic.name
    updateRecipeObjectives(block, recipeSchematic)
    block.Header:SetText(recipeSchematic.name)

    block:Show()

    block:SetScript("OnClick", recipe_OnClick)

    savedHeight = savedHeight + block.height

    shownIndex = shownIndex + 1

    return savedHeight, shownIndex
end

local function updateRecipeLayout(self)
    local numRecipes = #C_TradeSkillUI.GetRecipesTracked(true)
    local numRecipesRecraft = #C_TradeSkillUI.GetRecipesTracked(false)
    local savedHeight = 1
    local shownIndex = 1

    self.header:Hide()

    if self.collapsed and (numRecipes + numRecipesRecraft) > 0 then
        self.header:Show()
        numRecipes = 0
        numRecipesRecraft = 0
        savedHeight = 20
    end

    for i = 1, numRecipes do
        savedHeight, shownIndex = CreateTrackedBlock(self, i, true, savedHeight, shownIndex)
    end
    for i = 1, numRecipesRecraft do
        savedHeight, shownIndex = CreateTrackedBlock(self, i, false, savedHeight, shownIndex)
    end

    self:SetHeight(savedHeight)

    for i = shownIndex, 25 do
        if _G["GwRecipeBlock" .. i] then
            _G["GwRecipeBlock" .. i]:Hide()
            _G["GwRecipeBlock" .. i].id = nil
            _G["GwRecipeBlock" .. i].isRecraft = nil
        end
    end

    GW.QuestTrackerLayoutChanged()
end
GW.UpdateRecipeTrackingLayout = updateRecipeLayout

local function StartUpdate(self)
    if self.continuableContainer then
        self.continuableContainer:Cancel()
    end

    self.continuableContainer = ContinuableContainer:Create()
    local function LoadItems(recipes)
        for _, recipeID in ipairs(recipes) do
            local reagents = ProfessionsUtil.CreateRecipeReagentsForAllBasicReagents(recipeID)
            for _, reagent in ipairs(reagents) do
                if reagent.itemID then
                    self.continuableContainer:AddContinuable(Item:CreateFromItemID(reagent.itemID))
                end
            end
        end
    end

    -- Load regular and recraft recipe items.
    LoadItems(C_TradeSkillUI.GetRecipesTracked(IsRecrafting))
    LoadItems(C_TradeSkillUI.GetRecipesTracked(not IsRecrafting))

    -- We can continue to layout each of the blocks if every item is loaded, otherwise
    -- we need to wait until the items load, then notify the objective tracker to try again.
    local allLoaded = true
    local function OnItemsLoaded()
        if allLoaded then
            updateRecipeLayout(self)
        else
            StartUpdate(self)
        end
    end
    -- The assignment of allLoaded is only meaningful if false. If and when the callback
    -- is invoked later, it will force an update. If the value was true, the callback would have
    -- already been invoked prior to returning.
    allLoaded = self.continuableContainer:ContinueOnLoad(OnItemsLoaded)
end

local function UntrackRecipeIfUnlearned()
    for _, recipeID in ipairs(C_TradeSkillUI.GetRecipesTracked(not IsRecrafting)) do
        if not C_TradeSkillUI.IsRecipeProfessionLearned(recipeID) then
            local track = false
            C_TradeSkillUI.SetRecipeTracked(recipeID, track, not IsRecrafting)
        end
    end
end

local function OnEvent(self, event, ...)
    if event == "TRACKED_RECIPE_UPDATE" then
        StartUpdate(self)
    elseif event == "CURRENCY_DISPLAY_UPDATE" then
        StartUpdate(self)
    elseif event == "UPDATE_PENDING_MAIL" then
        StartUpdate(self)
    elseif event == "SKILL_LINES_CHANGED" then
        UntrackRecipeIfUnlearned()
    elseif event == "BAG_UPDATE_DELAYED" then
        StartUpdate(self)
    end
end

local function CollapseHeader(self, forceCollapse, forceOpen)
    if (not self.collapsed or forceCollapse) and not forceOpen then
        self.collapsed = true
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    else
        self.collapsed = false
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
    updateRecipeLayout(GwQuesttrackerContainerRecipe)
end
GW.CollapseRecipeHeader = CollapseHeader

local function LoadRecipeTracking(self)
    self:RegisterEvent("TRACKED_RECIPE_UPDATE")
    self:RegisterEvent("SKILL_LINES_CHANGED")
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self:RegisterEvent("UPDATE_PENDING_MAIL")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:SetScript("OnEvent", OnEvent)

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0.5, 1, 0.75, 1)
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText(PROFESSIONS_TRACKER_HEADER_PROFESSION)

    self.collapsed = false
    self.header:SetScript("OnMouseDown",
        function(self)
            CollapseHeader(self:GetParent(), false, false)
        end
    )
    self.header.title:SetTextColor(
        TRACKER_TYPE_COLOR.RECIPE.r,
        TRACKER_TYPE_COLOR.RECIPE.g,
        TRACKER_TYPE_COLOR.RECIPE.b
    )

    updateRecipeLayout(self)
end
GW.LoadRecipeTracking = LoadRecipeTracking
