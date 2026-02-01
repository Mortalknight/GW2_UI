local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local ChatEdit_GetActiveWindow = ChatFrameUtil and ChatFrameUtil.GetActiveWindow or ChatEdit_GetActiveWindow

local IsRecrafting = true

local function GetRecipeID(block)
    return math.abs(block.id)
end

local function IsRecraftBlock(block)
    return block.isRecraft
end

GwObjectivesRecipeBlockMixin = {}

function GwObjectivesRecipeBlockMixin:UpdateBlock(recipeSchematic)
    local allCollacted = true
    local idx = 1
    self.height = 35
    self.numObjectives = 0

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
                if not (quantity >= quantityRequired) and itemName then
                    self:AddObjective(itemName, idx, {isReceip = true, finished = false, qty = quantity, totalqty = quantityRequired})
                    idx = idx + 1
                end
            end
        end
    end

    if allCollacted then
        self:AddObjective(GW.L["Ready to craft"], idx, {isReceip = true, finished = false})
    end

    self:SetHeight(self.height)
end

GwObjectivesRecipeContainerMixin = {}

function GwObjectivesRecipeContainerMixin:CreateTrackedBlock(idx, isRecraft, savedHeight, shownIndex)
    local recipeID = C_TradeSkillUI.GetRecipesTracked(isRecraft)[idx]
    local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft)

    if idx == 1 then
        savedHeight = 20
    end

    self.header:Show()
    local block = self:GetBlock(shownIndex, "RECIPE", false)
    if block == nil then
        return 0, 0
    end
    block.id = recipeID
    block.isRecraft = isRecraft
    block.title = recipeSchematic.name
    block:UpdateBlock(recipeSchematic)
    block.Header:SetText(recipeSchematic.name)

    block:Show()

    savedHeight = savedHeight + block.height

    shownIndex = shownIndex + 1

    return savedHeight, shownIndex
end

function GwObjectivesRecipeContainerMixin:ProcessUpdate()
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
        savedHeight, shownIndex = self:CreateTrackedBlock(i, true, savedHeight, shownIndex)
    end
    for i = 1, numRecipesRecraft do
        savedHeight, shownIndex = self:CreateTrackedBlock(i, false, savedHeight, shownIndex)
    end

    self:SetHeight(savedHeight)

    for i = shownIndex, #self.blocks do
        local block = self.blocks[i]
        block.id = nil
        block.isRecraft = nil
        block:Hide()
    end

    GwQuestTracker:LayoutChanged()
end

function GwObjectivesRecipeContainerMixin:UpdateLayout()
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
            self:ProcessUpdate()
        else
            self:UpdateLayout()
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

function GwObjectivesRecipeContainerMixin:OnEvent(event, ...)
    if event == "TRACKED_RECIPE_UPDATE" then
        self:UpdateLayout()
    elseif event == "CURRENCY_DISPLAY_UPDATE" then
        self:UpdateLayout()
    elseif event == "UPDATE_PENDING_MAIL" then
        self:UpdateLayout()
    elseif event == "SKILL_LINES_CHANGED" then
        UntrackRecipeIfUnlearned()
    elseif event == "BAG_UPDATE_DELAYED" then
        self:UpdateLayout()
    end
end

function GwObjectivesRecipeContainerMixin:BlockOnClick(button)
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
            rootDescription:SetMinimumWidth(1)
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

function GwObjectivesRecipeContainerMixin:InitModule()
    self:RegisterEvent("TRACKED_RECIPE_UPDATE")
    self:RegisterEvent("SKILL_LINES_CHANGED")
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self:RegisterEvent("UPDATE_PENDING_MAIL")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:SetScript("OnEvent", self.OnEvent)

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0.5, 1, 0.75, 1)
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText(PROFESSIONS_TRACKER_HEADER_PROFESSION)

    if C_AddOns.IsAddOnLoaded("Auctionator") then
        self.header.SearchButton = CreateFrame("Frame", nil, self.header)
        self.header.SearchButton.text = self.header.SearchButton:CreateFontString(nil, "ARTWORK")
        self.header.SearchButton.text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        self.header.SearchButton.text:SetShadowOffset(1, -1)
        self.header.SearchButton.text:SetTextColor(TRACKER_TYPE_COLOR.RECIPE.r, TRACKER_TYPE_COLOR.RECIPE.g, TRACKER_TYPE_COLOR.RECIPE.b)
        self.header.SearchButton.text:SetText(SEARCH)
        self.header.SearchButton.text:SetPoint("RIGHT", self.header, "RIGHT", -5, 0)
        self.header.SearchButton.SearchButton = self.header.SearchButton
        Mixin(self.header.SearchButton, AuctionatorCraftingInfoObjectiveTrackerFrameMixin)
        self.header.SearchButton:OnLoad()
        self.header.SearchButton:SetScript("OnEvent", self.header.SearchButton.OnEvent)
        self.header.SearchButton.text:SetScript("OnMouseUp", function() self.header.SearchButton:SearchButtonClicked() end)
    end

    self.collapsed = false
    self.header:SetScript("OnMouseDown", function() self:CollapseHeader() end) -- this way, otherwiese we have a wrong self at the function
    self.header.title:SetTextColor(TRACKER_TYPE_COLOR.RECIPE.r, TRACKER_TYPE_COLOR.RECIPE.g, TRACKER_TYPE_COLOR.RECIPE.b)

    self.blockMixInTemplate = GwObjectivesRecipeBlockMixin

    self:UpdateLayout()
end
