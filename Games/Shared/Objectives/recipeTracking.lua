---@class GW2
local GW = select(2, ...)


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
    self.height = GW.GetObjectivesBlockBaseHeight()
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
                    self:AddObjective(itemName, {isReceip = true, finished = false, qty = quantity, totalqty = quantityRequired})
                end
            end
        end
    end

    if allCollacted then
        self:AddObjective(GW.L["Ready to craft"], {isReceip = true, finished = false})
    end

    self:SetHeight(self.height)
end

GwObjectivesRecipeContainerMixin = {}

function GwObjectivesRecipeContainerMixin:CreateTrackedBlock(idx, isRecraft, shownIndex)
    local recipeID = C_TradeSkillUI.GetRecipesTracked(isRecraft)[idx]
    local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft)

    self.header:Show()
    local block = self:GetBlock(shownIndex, GW.Enum.ObjectivesNotificationType.Recipe, false)
    if block == nil then
        return shownIndex
    end
    block.id = recipeID
    block.isRecraft = isRecraft
    block.title = recipeSchematic.name
    block:UpdateBlock(recipeSchematic)
    block.Header:SetText(recipeSchematic.name)

    block:Show()

    return shownIndex + 1
end

function GwObjectivesRecipeContainerMixin:ProcessUpdate()
    local numRecipes = #C_TradeSkillUI.GetRecipesTracked(true)
    local numRecipesRecraft = #C_TradeSkillUI.GetRecipesTracked(false)
    local shownIndex = 1

    self.header:Hide()

    if self.collapsed and (numRecipes + numRecipesRecraft) > 0 then
        self.header:Show()
        numRecipes = 0
        numRecipesRecraft = 0
    end

    for i = 1, numRecipes do
        shownIndex = self:CreateTrackedBlock(i, true, shownIndex)
    end
    for i = 1, numRecipesRecraft do
        shownIndex = self:CreateTrackedBlock(i, false, shownIndex)
    end

    for i = shownIndex, #self.blocks do
        local block = self.blocks[i]
        block.id = nil
        block.isRecraft = nil
        block:Hide()
    end

    self:LayoutBlocks(shownIndex - 1)

    GwQuestTracker:LayoutChanged()
end

function GwObjectivesRecipeContainerMixin:UpdateLayout()
    -- the reagents load through our own item listener: blizzards ContinuableContainer uses the shared
    -- ItemEventListener, and what we put there counts as tainted for blizzards own requests
    self.loadGeneration = (self.loadGeneration or 0) + 1
    local generation = self.loadGeneration
    local missing = 0

    local function OnItemLoaded()
        missing = missing - 1
        if missing == 0 and generation == self.loadGeneration then
            self:UpdateLayout()
        end
    end

    local function LoadItems(recipes)
        for _, recipeID in ipairs(recipes) do
            for _, reagent in ipairs(ProfessionsUtil.CreateRecipeReagentsForAllBasicReagents(recipeID)) do
                if reagent.itemID then
                    local item = Item:CreateFromItemID(reagent.itemID)
                    if not item:IsItemDataCached() then
                        missing = missing + 1
                        GW.ContinueOnItemLoad(item, OnItemLoaded)
                    end
                end
            end
        end
    end

    -- Load regular and recraft recipe items.
    LoadItems(C_TradeSkillUI.GetRecipesTracked(IsRecrafting))
    LoadItems(C_TradeSkillUI.GetRecipesTracked(not IsRecrafting))

    -- with every item loaded the blocks are laid out now, otherwise once the last one arrived
    if missing == 0 then
        self:ProcessUpdate()
    end
end

local function UntrackRecipeIfUnlearned()
    for _, recipeID in ipairs(C_TradeSkillUI.GetRecipesTracked(not IsRecrafting)) do
        if not C_TradeSkillUI.IsRecipeProfessionLearned(recipeID) then
            local track = false
            C_TradeSkillUI.SetRecipeTracked(recipeID, track, not IsRecrafting)
        end
    end
end

-- bags, currencies and mail only change reagent counts, without a tracked recipe there is nothing to count
local function HasTrackedRecipes()
    return #C_TradeSkillUI.GetRecipesTracked(IsRecrafting) > 0 or #C_TradeSkillUI.GetRecipesTracked(not IsRecrafting) > 0
end

function GwObjectivesRecipeContainerMixin:OnEvent(event, ...)
    if event == "TRACKED_RECIPE_UPDATE" then
        self:UpdateLayout()
    elseif event == "SKILL_LINES_CHANGED" then
        UntrackRecipeIfUnlearned()
    elseif (event == "CURRENCY_DISPLAY_UPDATE" or event == "UPDATE_PENDING_MAIL" or event == "BAG_UPDATE_DELAYED") and HasTrackedRecipes() then
        self:UpdateLayout()
    end
end

function GwObjectivesRecipeContainerMixin:BlockOnClick(button)
    if IsModifiedClick("CHATLINK") and ChatFrameUtil.GetActiveWindow() then
        local link = C_TradeSkillUI.GetRecipeLink(GetRecipeID(self))
        if link then
            ChatFrameUtil.InsertLink(link)
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
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header, "SHADOW")
    self.header.title:SetText(PROFESSIONS_TRACKER_HEADER_PROFESSION)

    if C_AddOns.IsAddOnLoaded("Auctionator") then
        self.header.SearchButton = CreateFrame("Frame", nil, self.header)
        self.header.SearchButton.text = self.header.SearchButton:CreateFontString(nil, "ARTWORK")
        self.header.SearchButton.text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
        self.header.SearchButton.text:SetTextColor(GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Recipe]:GetRGB())
        self.header.SearchButton.text:SetText(SEARCH)
        self.header.SearchButton.text:SetPoint("RIGHT", self.header, "RIGHT", -5, 0)
        self.header.SearchButton.SearchButton = self.header.SearchButton
        Mixin(self.header.SearchButton, AuctionatorCraftingInfoObjectiveTrackerFrameMixin)
        self.header.SearchButton:OnLoad()
        self.header.SearchButton:SetScript("OnEvent", self.header.SearchButton.OnEvent)
        self.header.SearchButton.text:SetScript("OnMouseUp", function() self.header.SearchButton:SearchButtonClicked() end)
    end

    self.collapsed = false
    self.header:SetScript("OnMouseDown", function() self:ToggleCollapsed() end) -- this way, otherwiese we have a wrong self at the function
    self.header.title:SetTextColor(GW.Colors.ObjectivesTypeColors[GW.Enum.ObjectivesNotificationType.Recipe]:GetRGB())

    self.blockMixInTemplate = GwObjectivesRecipeBlockMixin

    self:UpdateLayout()
end
