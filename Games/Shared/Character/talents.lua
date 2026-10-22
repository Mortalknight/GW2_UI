---@class GW2
local GW = select(2, ...)
local Data = GW.TalentData
local NUM_COLUMNS = 4

local activeSpec = nil
local openSpec = 1 -- Can be 1 or 2
local isPetTalents = false

local function GetTalentSpec()
    return openSpec, isPetTalents
end
GW.GetTalentSpec = GetTalentSpec

local function UpdateActiveSpec(activeTalentGroup)
    -- set the active spec
    activeSpec = 1
    for i = 1, 2 do
        if i == activeTalentGroup then
            activeSpec = i
            break
        end
    end
end

local function UpdateTalentPoints()
    return Data.GetUnspentPoints(isPetTalents, openSpec) - Data.GetPreviewPoints(isPetTalents, openSpec)
end

local function talentBunnton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()

    if self.talentid and Data.SetTooltip(self.talentFrameId, self.talentid, isPetTalents, openSpec) then
        GW.AddOffGcdTooltipLine(self)
        GameTooltip:Show()
    end

    self.UpdateTooltip = talentBunnton_OnEnter
end

local function hookTalentButton(talentButton, container, row, index)
    local w = container:GetWidth()
    local h = container:GetHeight()
    local x = (w / NUM_COLUMNS) * (index - 1)
    local y = (h / Data.NumTiers) * (row - 1)

    talentButton:RegisterForClicks("AnyUp")
    talentButton:SetAttribute("useOnKeyDown", false)
    talentButton:SetPoint("TOPLEFT", container, "TOPLEFT", x + (talentButton:GetWidth() / 4), -(y + (talentButton:GetHeight() / 4)))

    talentButton:SetScript("OnEnter", talentBunnton_OnEnter)
    talentButton:SetScript("OnLeave", GameTooltip_Hide)
    talentButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" and openSpec == activeSpec then
            if IsModifiedClick("CHATLINK") then
                local link = Data.GetLink(self.talentFrameId, self.talentid, isPetTalents, openSpec)
                if link then
                    ChatFrameUtil.InsertLink(link)
                end
            else
                Data.Learn(self.talentFrameId, self.talentid, isPetTalents, openSpec)
            end
        elseif button == "RightButton" and openSpec == activeSpec then
            Data.Unlearn(self.talentFrameId, self.talentid, isPetTalents, openSpec)
        end
    end)

    local mask = UIParent:CreateMaskTexture()

    mask:SetPoint("CENTER", talentButton, "CENTER", 0, 0)
    mask:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_border.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(talentButton:GetSize())
    talentButton.mask = mask
    talentButton.points:SetFont(DAMAGE_TEXT_FONT, 10, "OUTLINE")
    talentButton.points:SetTextColor(1, 1, 1, 1)
end

local function getArrow(container, teir, column, i)
    local arrows = container.treeContainer.arrows
    local key = teir .. "-" .. column .. "-" .. i
    local arrow = arrows[key]
    if not arrow then
        arrow = CreateFrame("Frame", nil, container.treeContainer, "GwLegacyTalentLine")
        arrows[key] = arrow
    else
        arrow:Show()
    end
    return arrow
end

local function colorTalentArrow(self, active)
    local color = {r = 1, b = 0.6, g = 1}
    if not active then
        color = {r = 0.3, b = 0.3, g = 0.3}
    end
    self.up:SetVertexColor(color.r,color.g,color.b)
    self.down:SetVertexColor(color.r,color.g,color.b)
    self.left:SetVertexColor(color.r,color.g,color.b)
    self.right:SetVertexColor(color.r,color.g,color.b)
end

local function drawLegacyLine(path, container, teir, column, requirementsMet)
    local treeContainer = container.treeContainer
    local w = treeContainer:GetWidth()
    local h = treeContainer:GetHeight()
    local cTeir = teir
    local cCol = column

    for i = 1, #path do
        local x = (w / NUM_COLUMNS) * (cCol - 1)
        local y = (h / Data.NumTiers) * (cTeir - 1)
        local arrow = getArrow(container, cTeir, cCol, i)

        arrow:ClearAllPoints()
        arrow:SetPoint("TOPLEFT", treeContainer, "TOPLEFT", x + (arrow:GetWidth() / 4) , -(y + (arrow:GetHeight() / 4)))

        if path[i].y ~= 0 then
            if path[i].y > 0 then
                arrow.down:Show()
            else
                arrow.up:Show()
            end
        elseif path[i].x ~= 0 then
            if path[i].x > 0 then
                arrow.right:Show()
            else
                arrow.left:Show()
            end
        end
        colorTalentArrow(arrow, requirementsMet)
        cTeir = cTeir + path[i].y
        cCol = cCol + path[i].x
    end
end

local function getLinePath(buttonTier, buttonColumn, tier, column, container, requirementsMet)
    --[[
        Get path to required talent
        Blocking talents are not implemented as there are none in classic
    ]]
    local path = {}

    -- Check to see if are in the same column
    if buttonColumn == column then
        if (buttonTier - tier) > 1 then
            for _ = tier, buttonTier - 1 do
                path[#path + 1] = {x = 0, y = 1}
            end
        else
            path[#path + 1] = {x = 0, y = 1}
        end
        return drawLegacyLine(path, container, tier, column, requirementsMet)
    end

    if buttonTier == tier then
        local left = min(buttonColumn, column)
        local right = max(buttonColumn, column)

        -- See if the distance is greater than one space
        if (right - left) > 1 then
            for _ = buttonColumn + 1, column - 1 do
                path[#path + 1] = {x = 1, y = 0}
            end
        else
            if buttonColumn < column then
                path[#path + 1] = {x = -1, y = 0}
            else
                path[#path + 1] = {x = 1, y = 0}
            end
        end
        return drawLegacyLine(path, container, tier, column, requirementsMet)
    end

    path[#path + 1] = {x = 1, y = 0}
    path[#path + 1] = {x = 0, y = 1}

    return drawLegacyLine(path, container, tier, column, requirementsMet)
end

local function TalentFrame_SetPrereqs(container, talent, forceDesaturated)
    local requirementsMet = talent.available and not forceDesaturated

    for _, prereq in ipairs(talent.prereqs) do
        if not prereq.met then
            requirementsMet = false
        end
        getLinePath(talent.tier, talent.column, prereq.tier, prereq.column, container, requirementsMet)
    end
    return requirementsMet
end

-- the flat button list is filled tier by tier, so a grid slot maps to (tier - 1) * columns + column
local function GetTreeButton(container, tier, column)
    return container.buttons[(tier - 1) * NUM_COLUMNS + column]
end

local function CleanUpTalentTrees(self)
    if not self.container then return end
    for i = 1, #self.container do
        for _, button in ipairs(self.container[i].buttons) do
            button.talentid = nil
            button:Hide()
        end

        for _, arrow in pairs(self.container[i].treeContainer.arrows) do
            arrow:Hide()
        end
    end
end

local function UpdatePreviewControls(self, isPreview)
    local talentPoints = Data.GetUnspentPoints(isPetTalents, openSpec)

    if (isPetTalents or openSpec) and talentPoints > 0 and isPreview then
        self.bottomBar.prevLearn:Show()
        self.bottomBar.prevCancel:Show()
        -- enable accept/cancel buttons if preview talent points were spent
        if Data.GetPreviewPoints(isPetTalents, openSpec) > 0 then
            self.bottomBar.prevLearn:Enable();
            self.bottomBar.prevCancel:Enable();
        else
            self.bottomBar.prevLearn:Disable();
            self.bottomBar.prevCancel:Disable();
        end
    else
        self.bottomBar.prevLearn:Hide()
        self.bottomBar.prevCancel:Hide()
    end
end

local function updateTalentTrees(self)
    if InCombatLockdown() then return end
    if not self.container or not self.container[1] then return end

    local activeTalentGroup = Data.GetActiveSpecGroup(isPetTalents)
    local hasDualSpec = Data.GetNumSpecGroups(false) > 1
    local hasPetTalents = Data.GetNumSpecGroups(true) > 0
    local preview = Data.UsesPreview()
    local isActiveTalentGroup = openSpec == activeTalentGroup

    -- preview
    UpdatePreviewControls(self, preview)

    UpdateActiveSpec(activeTalentGroup)

    if isPetTalents then
        self.bottomBar.spec1Button:Hide()
        self.bottomBar.spec2Button:Hide()

        self.bottomBar.dualSpecActiveTalentGroupe:Hide()
        self.bottomBar.activateSpecGroup:Hide()
    elseif hasDualSpec then
        self.bottomBar.spec1Button:Show()
        self.bottomBar.spec2Button:Show()
        self.bottomBar.spec1Button:SetEnabled(openSpec == 2 or isPetTalents)
        self.bottomBar.spec2Button:SetEnabled(openSpec == 1 or isPetTalents)

        self.bottomBar.dualSpecActiveTalentGroupe:SetShown(isActiveTalentGroup)
        self.bottomBar.activateSpecGroup:SetShown(not isActiveTalentGroup)
    else
        self.bottomBar.spec1Button:Hide()
        self.bottomBar.spec2Button:Hide()

        self.bottomBar.dualSpecActiveTalentGroupe:Hide()
        self.bottomBar.activateSpecGroup:Hide()
    end

    if hasPetTalents then
        self.bottomBar.petTalentsButton:SetText(isPetTalents and PLAYER or PETS)
    end
    self.bottomBar.petTalentsButton:SetShown(hasPetTalents)

    self.bottomBar.unspentPoints:SetFormattedText(UNSPENT_TALENT_POINTS, UpdateTalentPoints())

    for f = 1, Data.GetNumTrees(isPetTalents) do
        local container = self.container[f]
        if not container then break end
        local talentPoints = UpdateTalentPoints()
        local name, icon, pointsSpent, treePoints = Data.GetTreeInfo(f, isPetTalents, openSpec)

        container.background:SetDesaturated(pointsSpent < 1)
        container.talentPoints = talentPoints
        container.talentFrameId = f

        container.info.icon:SetTexture(icon)
        container.info.title:SetText(name)
        container.info.points:SetText(pointsSpent)

        for i = 1, Data.GetNumTalents(f, isPetTalents) do
            local talent = Data.GetTalent(f, i, isPetTalents, openSpec, treePoints)
            -- talents are indexed in list order, the buttons live in grid order
            local button = talent and GetTreeButton(container, talent.tier, talent.column)
            if button then
                local displayRank = talent.rank

                button.icon:SetTexture(talent.icon)
                GW.UpdateOffGcdIndicator(button, talent.spellID)
                button.points:SetText(displayRank .. " / " .. talent.maxRank)
                button.textBG:Show()
                button.talentid = i
                button.talentFrameId = f
                button.active = true
                button:Show()
                button:EnableMouse(true)

                -- If player has no talent points or this is the inactive talent group then show only talents with points in them
                local forceDesaturated = (container.talentPoints <= 0 or not isActiveTalentGroup) and displayRank == 0
                local requirementsMet = TalentFrame_SetPrereqs(container, talent, forceDesaturated)

                button.talentID = i
                button.known = displayRank == talent.maxRank

                if not talent.isExceptional then
                    button.legendaryHighlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_highlight.png")
                    button.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_highlight.png")
                    button.icon:AddMaskTexture(button.mask)
                    button.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_outline.png")
                else
                    button.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/active_highlight.png")
                    button.legendaryHighlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/active_highlight.png")
                    button.icon:RemoveMaskTexture(button.mask)
                    button.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/background_border.png")
                end

                if requirementsMet then
                    button.icon:SetDesaturated(not isActiveTalentGroup)
                    button.icon:SetVertexColor(1, 1, 1, 1)
                    button:SetAlpha(1)
                    if displayRank < talent.maxRank then
                        button.highlight:Hide()
                        button.points:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                    else
                        button.highlight:Show()
                        button.points:SetTextColor(0.87, 0.74, 0.29, 1)
                    end
                else
                    button.icon:SetDesaturated(true)
                    button.icon:SetVertexColor(1, 1, 1, 0.65)
                    button.highlight:Hide()
                    button.points:SetText("")
                    button.textBG:Hide()
                end
            end
        end
    end
    -- Clean up unused slots
    for i = 1, #self.container do
        for y = 1, #self.container[i].buttons do
            local button = self.container[i].buttons[y]
            if button.talentid == nil then
                button:Hide()
            end
        end
    end
end

local talentFramesLoaded = false
local function loadTalentsFrames(self)
    -- on era the window loads before the server sent the talent data, the trees follow with the talent events;
    -- the buttons are secure, so not in combat
    if talentFramesLoaded or InCombatLockdown() or Data.GetNumTrees(isPetTalents) == 0 then
        return
    end
    talentFramesLoaded = true

    local mask = UIParent:CreateMaskTexture()

    mask:SetPoint("TOPLEFT", GwCharacterWindow, "TOPLEFT", 0, 0)
    mask:SetTexture("Interface/AddOns/GW2_UI/textures/character/windowbg-mask.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(853, 853)

    self.container = {}

    for i = 1, Data.GetNumTrees(isPetTalents) do
        local container = CreateFrame("Button", "GwLegacyTalentTree" .. i, self, "GwLegacyTalentTree")
        self.container[i] = container
        container.buttons = {}
        container.treeContainer.arrows = {}

        container:SetPoint("TOPLEFT", self, "TOPLEFT", (284 * (i - 1)) + 5, -92)

        container.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/art/legacy/" .. GW.myClassID .. ".png")
        container.background:SetTexCoord(0.27734375 * (i - 1), 0.27734375 * i, 0, 0.611328125)
        container.background:AddMaskTexture(mask)
        container:HookScript("OnShow",function()
            if InCombatLockdown() then return end
            updateTalentTrees(self)
        end)

        for y = 1, Data.NumTiers do
            for j = 1, NUM_COLUMNS do
                local talentButton = CreateFrame("Button", "GwLegacyTalentTree" .. i .. "Teir" .. y .. "index" .. j, container.treeContainer, "GwTalentButton")
                hookTalentButton(talentButton, container.treeContainer, y, j)
                container.buttons[#container.buttons + 1] = talentButton
            end
        end
    end

    updateTalentTrees(self)
end

local function LoadTalents(tabContainer)
    local talentFrame = CreateFrame("Frame", "GwTalentFrame", tabContainer, "GwLegacyTalentFrame")

    talentFrame.bottomBar.prevCancel:SetScript("OnClick", function()
        Data.ResetPreview(isPetTalents, openSpec)
        updateTalentTrees(talentFrame)
    end)
    talentFrame.bottomBar.prevLearn:SetScript("OnClick", function()
        -- forever applies like blizzard without asking, it has no confirm text
        if CONFIRM_LEARN_PREVIEW_TALENTS then
            GW.ShowPopup({text = CONFIRM_LEARN_PREVIEW_TALENTS,
                button1 = YES,
                button2 = NO,
                OnAccept = function() Data.CommitPreview(isPetTalents, openSpec) end,
                hideOnEscape = true}
            )
        else
            Data.CommitPreview(isPetTalents, openSpec)
        end
        updateTalentTrees(talentFrame)
    end)

    talentFrame.bottomBar.spec1Button:SetScript("OnClick", function()
        openSpec = 1
        isPetTalents = false
        updateTalentTrees(talentFrame)
    end)
    talentFrame.bottomBar.spec2Button:SetScript("OnClick", function()
        openSpec = 2
        isPetTalents = false
        updateTalentTrees(talentFrame)
    end)
    talentFrame.bottomBar.petTalentsButton:SetScript("OnClick", function()
        openSpec = 1
        isPetTalents = not isPetTalents
        CleanUpTalentTrees(talentFrame)
        updateTalentTrees(talentFrame)
    end)
    talentFrame.bottomBar.activateSpecGroup:SetScript("OnClick", function()
        if openSpec then
            C_SpecializationInfo.SetActiveSpecGroup(openSpec)
            updateTalentTrees(talentFrame)
        end
    end)

    talentFrame.bottomBar.dualSpecActiveTalentGroupe:SetTextColor(63 / 255, 205 / 255, 75 / 255)
    talentFrame.bottomBar.unspentPoints:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    talentFrame.bottomBar.unspentPoints:SetTextColor(0.87, 0.74, 0.29, 1)

    talentFrame.bottomBar.dualSpecActiveTalentGroupe:SetFont(DAMAGE_TEXT_FONT, 18, "OUTLINE")

    talentFrame.bottomBar.talentPreview:SetShown(Data.HasPreviewOption)
    talentFrame.bottomBar.talentPreview.checkbutton:SetChecked(GetCVarBool("previewTalentsOption"))

    for _, event in ipairs(Data.Events) do
        talentFrame:RegisterEvent(event)
    end

    talentFrame.bottomBar.talentPreview.checkbutton:SetScript("OnClick", function(self)
        local talentPreview = GetCVarBool("previewTalentsOption") and "0" or "1"
        C_CVar.SetCVar("previewTalentsOption", talentPreview)
        self:SetChecked(GetCVarBool("previewTalentsOption"))
        updateTalentTrees(talentFrame)
    end)

    talentFrame:SetScript("OnEvent", function()
        loadTalentsFrames(talentFrame)
        talentFrame.bottomBar.unspentPoints:SetFormattedText(UNSPENT_TALENT_POINTS, UpdateTalentPoints())
        if not talentFrame:IsShown() then return end
        updateTalentTrees(talentFrame)
    end)
    talentFrame:SetScript("OnShow", function()
        if InCombatLockdown() then return end
        loadTalentsFrames(talentFrame)
        updateTalentTrees(talentFrame)
    end)
    if ToggleTalentFrame then
        hooksecurefunc("ToggleTalentFrame", function()
            if InCombatLockdown() then return end
            GwCharacterWindow:SetAttribute("keytoggle", true)
            GwCharacterWindow:SetAttribute("windowpanelopen", "talents")
        end)
    end

    loadTalentsFrames(talentFrame)
end
GW.LoadTalents = LoadTalents
