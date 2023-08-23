local _, GW = ...
-- Default 8 but none uses 8 talent rows in classic
local MAX_NUM_TALENTS = 20
local NUM_TALENT_COLUMNS = 4
local MAX_NUM_TALENT_TIERS = 9
local TALENT_BRANCH_ARRAY = {}

local function talentBunnton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()

    GameTooltip:SetTalent(self.talentFrameId, self.talentid)
    self.UpdateTooltip = talentBunnton_OnEnter
end

local function hookTalentButton(talentButton, container, row, index)
    local w = container:GetWidth()
    local h = container:GetHeight()
    local x = (w / NUM_TALENT_COLUMNS) * (index - 1)
    local y = (h / MAX_NUM_TALENT_TIERS) * (row - 1)

    talentButton:RegisterForClicks("AnyUp")
    talentButton:SetPoint('TOPLEFT', container, 'TOPLEFT', x + (talentButton:GetWidth() / 4), -(y + (talentButton:GetHeight() / 4)))

    talentButton:SetScript("OnEnter", talentBunnton_OnEnter)
    talentButton:SetScript("OnLeave", GameTooltip_Hide)
    talentButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            if IsModifiedClick("CHATLINK") then
                local link = GetTalentLink(self.talentFrameId, self.talentid)
                if link then
                    ChatEdit_InsertLink(link)
                end
            else
                LearnTalent(self.talentFrameId, self.talentid)
            end
        end
    end)
    talentButton:SetScript("OnEvent", function(self)
        if GameTooltip:IsOwned(self) then
            GameTooltip:SetTalent(self.talentFrameId, self.talentid)
        end
    end)
    talentButton:RegisterEvent("CHARACTER_POINTS_CHANGED")
    --talentButton:RegisterEvent("")
    --talentButton:RegisterEvent("")

    local mask = UIParent:CreateMaskTexture()

    mask:SetPoint("CENTER", talentButton, 'CENTER', 0, 0)
    mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(talentButton:GetSize())
    talentButton.mask = mask
    talentButton.points:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINE")
    talentButton.points:SetTextColor(1, 1, 1, 1)
end

local function getArrow(frame, teir, column, i)
    local n = "GwLegacyTalentLine" .. "-" .. frame .. "-" .. teir .. "-" .. column .. "-" .. i
    if _G[n] == nil then
        return CreateFrame('Frame', n, _G["GwLegacyTalentTree" .. frame].treeContainer, 'GwLegacyTalentLine')
    end
    return _G[n]
end

local function colorTalentArrow(self, active)
    local color = {r = 1, b = 0.6, g = 1}
    if active == nil then
        color = {r = 0.3, b = 0.3, g = 0.3}
    end
    self.up:SetVertexColor(color.r,color.g,color.b)
    self.down:SetVertexColor(color.r,color.g,color.b)
    self.left:SetVertexColor(color.r,color.g,color.b)
    self.right:SetVertexColor(color.r,color.g,color.b)
end

local function drawLegacyLine(path, frame, teir, column, requirementsMet)
    local w = _G["GwLegacyTalentTree" .. frame].treeContainer:GetWidth()
    local h = _G["GwLegacyTalentTree" .. frame].treeContainer:GetHeight()
    local cTeir = teir
    local cCol = column

    for i = 1, #path do
        local x = (w / NUM_TALENT_COLUMNS) * (cCol - 1)
        local y = (h / MAX_NUM_TALENT_TIERS) * (cTeir - 1)
        local arrow = getArrow(frame, teir, column, i)

        arrow:ClearAllPoints()
        arrow:SetPoint("TOPLEFT", _G["GwLegacyTalentTree" .. frame].treeContainer, "TOPLEFT", x + (arrow:GetWidth() / 4) , -(y + (arrow:GetHeight() / 4)))

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

local function getLinePath(buttonTier, buttonColumn, tier, column, frame, requirementsMet)
    --[[
        Get path to required talent
        Blocking spells are not implemented as there are none in classic
    ]]
    local path = {}
    local blocked = false

    -- Check to see if are in the same column
    if buttonColumn == column then
        if (buttonTier - tier) > 1 then
            for i=tier , buttonTier - 1 do
                path[#path + 1] = {x = 0, y = 1}
            end
        else
            path[#path + 1] = {x = 0, y= 1}
        end
        if not blocked then
            return drawLegacyLine(path, frame, tier, column, requirementsMet)
        end
    end

    blocked= false
    if buttonTier == tier then
        local left = min(buttonColumn, column)
        local right = max(buttonColumn, column)

        -- See if the distance is greater than one space
        if (right - left) > 1 then
            for i = buttonColumn + 1, column - 1 do
                if TALENT_BRANCH_ARRAY[frame][i][column].id ~= nil then
                    blocked = true
                else
                    path[#path + 1] = {x = 1, y = 0}
                end
            end
        else
            if buttonColumn < column then
                path[#path + 1] = {x = -1, y = 0}
            else
                path[#path + 1] = {x = 1, y = 0}
            end
        end
        if not blocked then
            return drawLegacyLine(path, frame, tier, column, requirementsMet)
        end
    end
    path[#path + 1] = {x = 1, y = 0}
    path[#path + 1] = {x = 0, y = 1}

    return drawLegacyLine(path, frame, tier, column, requirementsMet)
end

local function TalentFrame_SetPrereqs(frame, buttonTier, buttonColumn, forceDesaturated, tierUnlocked, ...)

    local requirementsMet = tierUnlocked and not forceDesaturated

    for i = 1, select('#', ...), 4 do
        local tier, column, isLearnable = select(i, ...)
        if ( forceDesaturated or not isLearnable ) then
            requirementsMet = nil
        end
        getLinePath(buttonTier, buttonColumn, tier, column, frame, requirementsMet)
    end
    return requirementsMet
end

local function updateTalentTrees()
    if InCombatLockdown() then return end

    for f = 1, GW.api.GetNumSpecializations() do
        local forceDesaturated
        local talentPoints = UnitCharacterPoints("player")
        local name, _, pointsSpent = GetTalentTabInfo(f)
        local TalentFrame = _G["GwLegacyTalentTree" .. f]

        TalentFrame.pointsSpent = pointsSpent

        if pointsSpent < 1 then
            TalentFrame.background:SetDesaturated(true)
        else
            TalentFrame.background:SetDesaturated(false)
        end
        TalentFrame.talentPoints = talentPoints
        TalentFrame.talentFrameId = f


        TalentFrame.info.title:SetText(name)
        TalentFrame.info.points:SetText(pointsSpent)

        GwTalentFrame.bottomBar.unspentPoints:SetText(talentPoints)

        local numTalents = GetNumTalents(f)
        for i = 1, MAX_NUM_TALENTS do
            if i <= numTalents then
                local name, texture, tier, column, rank, maxRank, isExceptional, available = GetTalentInfo(f, i)

                TALENT_BRANCH_ARRAY[f][tier][column].id = i
                local button = _G['GwLegacyTalentTree' .. f .. 'Teir' .. tier .. 'index' .. column]
                button.icon:SetTexture(texture)
                button.points:SetText(rank .. " / " .. maxRank)
                button.talentid = i
                button.talentFrameId = f
                button:Show()
                button.active = true

                -- If player has no talent points then show only talents with points in them
                if TalentFrame.talentPoints <= 0 and rank == 0 then
                    forceDesaturated = 1
                else
                    forceDesaturated = nil
                end
                -- If the player has spent at least 5 talent points in the previous tier
                local tierUnlocked = nil
                if (tier - 1) * 5 <= TalentFrame.pointsSpent then
                    tierUnlocked = 1
                end

                local ispassive = not isExceptional
                local Prereqs = TalentFrame_SetPrereqs(f, tier, column, forceDesaturated, tierUnlocked, GetTalentPrereqs(f, i))

                button.talentID = talentID
                button.available = available
                button.known = rank==maxRank

                if ispassive then
                    button.legendaryHighlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight')
                    button.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight')
                    button.icon:AddMaskTexture(button.mask)
                    button.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_outline')
                else
                    button.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight')
                    button.legendaryHighlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight')
                    button.icon:RemoveMaskTexture(button.mask)
                    button.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\background_border')
                end
                    button:EnableMouse(true)
                if  available and Prereqs then
                    button.icon:SetDesaturated(false)
                    button.icon:SetVertexColor(1, 1, 1, 1)
                    button:SetAlpha(1)
                    if rank<maxRank then
                        button.highlight:Hide()
                        button.points:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                    else
                        button.highlight:Show()
                        button.points:SetText("")
                    end
                else
                    button.icon:SetDesaturated(true)
                    button.icon:SetVertexColor(1, 1, 1, 0.4)
                    button.highlight:Hide()
                    button.points:SetText("")
                end
            else
                if button ~= nil then
                    button:Hide()
                end
            end
        end
    end
    -- Clean up unsuded slots
    for i = 1, GW.api.GetNumSpecializations() do
        for y = 1, MAX_NUM_TALENT_TIERS do
            for j = 1, NUM_TALENT_COLUMNS do
                local button = _G['GwLegacyTalentTree' .. i .. 'Teir' .. y .. 'index' .. j]
                if button.talentid == nil then
                    button:Hide()
                end
            end
        end
    end
end

local function loadTalentsFrames()
    local _, _, classID = UnitClass('player')
    local mask = UIParent:CreateMaskTexture()

    mask:SetPoint("TOPLEFT", GwCharacterWindow, 'TOPLEFT', 0, 0)
    mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\windowbg-mask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(853, 853)


    for i = 1, GW.api.GetNumSpecializations() do
        TALENT_BRANCH_ARRAY[i] = {}
        local container = CreateFrame('Button', 'GwLegacyTalentTree' .. i, GwTalentFrame, 'GwLegacyTalentTree')

        container:SetPoint('TOPLEFT', GwTalentFrame, 'TOPLEFT', (284 * (i - 1)) + 5, -92)
        container.spec = i

        container.background:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\art\\legacy\\' .. classID)
        container.background:SetTexCoord(0.27734375 * (i - 1), 0.27734375 * i, 0, 0.611328125)
        container.background:AddMaskTexture(mask)
        container:HookScript('OnShow',function()
            if InCombatLockdown() then return end
            updateTalentTrees()
        end)

        for y = 1, MAX_NUM_TALENT_TIERS do
            TALENT_BRANCH_ARRAY[i][y] = {}
            for j = 1, NUM_TALENT_COLUMNS do
                TALENT_BRANCH_ARRAY[i][y][j] = {id = nil, up = 0, left = 0, right = 0, down = 0, leftArrow = 0, rightArrow = 0, topArrow = 0}
                local talentButton = CreateFrame('Button', 'GwLegacyTalentTree' .. i .. 'Teir' .. y .. 'index' .. j, container.treeContainer, 'GwTalentButton')
                hookTalentButton(talentButton, container.treeContainer, y, j)
            end
        end
    end
    updateTalentTrees()
end

local function LoadTalents()
    CreateFrame('Frame','GwTalentFrame', GwCharacterWindow,'GwLegacyTalentFrame')

    loadTalentsFrames()
    GwTalentFrame:SetScript('OnEvent', function(_, event)
        if event == "CHARACTER_POINTS_CHANGED" then
            GwTalentFrame.bottomBar.unspentPoints:SetText(UnitCharacterPoints("player"))
        end
        if not GwTalentFrame:IsShown() then return end
        updateTalentTrees()
    end)
    GwTalentFrame:SetScript('OnShow', function()
        if InCombatLockdown() then return end
        updateTalentTrees()
    end)
    hooksecurefunc('ToggleTalentFrame',function()
        if InCombatLockdown() then return end
        GwCharacterWindow:SetAttribute("keytoggle", true)
        GwCharacterWindow:SetAttribute("windowpanelopen", "talents")
    end)
    GwTalentFrame:Hide()

    return GwTalentFrame
end
GW.LoadTalents = LoadTalents
