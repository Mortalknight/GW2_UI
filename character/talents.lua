local _, GW = ...
-- Default 8 but none uses 8 talent rows in classic
local MAX_NUM_TALENT_TIERS = 11
local TALENT_BRANCH_ARRAY = {}

local activeSpec = nil
local openSpec = 1 -- Can be 1 or 2
local isPetTalents = false

StaticPopupDialogs["GW_CONFIRM_LEARN_PREVIEW_TALENTS"] = {
	text = CONFIRM_LEARN_PREVIEW_TALENTS,
	button1 = YES,
	button2 = NO,
	OnAccept = function ()
		LearnPreviewTalents(isPetTalents)
	end,
	OnCancel = function (self)
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
    preferredIndex = 4
}

local function PlayerTalentFrameRole_UpdateRole(self, role)
	if not role or role == "NONE" then
		role = "DAMAGER"
	end

	self:GetNormalTexture():SetTexCoord(GetTexCoordsForRole(role))
end

local function PlayerTalentFrameRoleDropDown_OnSelect(self)
	if activeSpec then
		SetTalentGroupRole(activeSpec, self.value)
	end
end

local function PlayerTalentFrameRoleDropDown_Initialize()
    local currentRole = "NONE"
    if activeSpec then
        currentRole = GetTalentGroupRole(activeSpec)
    end

    local info = UIDropDownMenu_CreateInfo()

    info.text = INLINE_TANK_ICON .. " " .. TANK
    info.func = PlayerTalentFrameRoleDropDown_OnSelect
    info.classicChecks = true
    info.value = "TANK"
    info.checked = info.value == currentRole
    UIDropDownMenu_AddButton(info)

    info.text = INLINE_HEALER_ICON .. " " .. HEALER
    info.func = PlayerTalentFrameRoleDropDown_OnSelect
    info.classicChecks = true
    info.value = "HEALER"
    info.checked = info.value == currentRole
    UIDropDownMenu_AddButton(info)

    info.text = INLINE_DAMAGER_ICON .. " " .. DAMAGER
    info.func = PlayerTalentFrameRoleDropDown_OnSelect
    info.classicChecks = true
    info.value = "DAMAGER"
    info.checked = info.value == currentRole or currentRole == "NONE"
    UIDropDownMenu_AddButton(info)
end

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
    local talentPoints = GetUnspentTalentPoints(false, isPetTalents, openSpec)
	local unspentPoints = talentPoints - GetGroupPreviewTalentPointsSpent(isPetTalents ,openSpec);

    return unspentPoints
end

local function talentBunnton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()

    GameTooltip:SetTalent(self.talentFrameId, self.talentid, false, isPetTalents, openSpec, GetCVarBool("previewTalents"))
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
        if button == "LeftButton" and openSpec == activeSpec then
            if IsModifiedClick("CHATLINK") then
                local link = GetTalentLink(self.talentFrameId, self.talentid, false, isPetTalents, openSpec, GetCVarBool("previewTalents"))
                if link then
                    ChatEdit_InsertLink(link)
                end
            else
                if GetCVarBool("previewTalents") then
                    AddPreviewTalentPoints(self.talentFrameId, self.talentid, 1, isPetTalents, openSpec)
                else
                    LearnTalent(self.talentFrameId, self.talentid, isPetTalents, openSpec)
                end
            end
        elseif button == "RightButton" and openSpec == activeSpec  then
			if GetCVarBool("previewTalents") then
				AddPreviewTalentPoints(self.talentFrameId, self.talentid, -1, isPetTalents, openSpec)
			end
        end
    end)
    talentButton:SetScript("OnEvent", function(self)
        if GameTooltip:IsOwned(self) then
            GameTooltip:SetTalent(self.talentFrameId, self.talentid)
        end
    end)
    talentButton:RegisterEvent("CHARACTER_POINTS_CHANGED")

    local mask = UIParent:CreateMaskTexture()

    mask:SetPoint("CENTER", talentButton, 'CENTER', 0, 0)
    mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(talentButton:GetSize())
    talentButton.mask = mask
    talentButton.points:SetFont(DAMAGE_TEXT_FONT, 10, "OUTLINE")
    talentButton.points:SetTextColor(1, 1, 1, 1)
end

local function getArrow(frame, teir, column, i)
    local n = "GwLegacyTalentLine" .. "-" .. frame .. "-" .. teir .. "-" .. column .. "-" .. i
    if _G[n] == nil then
        return CreateFrame('Frame', n, _G["GwLegacyTalentTree" .. frame].treeContainer, 'GwLegacyTalentLine')
    end
    _G[n]:Show()
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
        local arrow = getArrow(frame, cTeir, cCol, i)

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
            for i = tier , buttonTier - 1 do
                path[#path + 1] = {x = 0, y = 1}
            end
        else
            path[#path + 1] = {x = 0, y= 1}
        end
        if not blocked then
            return drawLegacyLine(path, frame, tier, column, requirementsMet)
        end
    end

    blocked = false
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

local function TalentFrame_SetPrereqs(frame, buttonTier, buttonColumn, forceDesaturated, tierUnlocked, preview, ...)
    local requirementsMet = tierUnlocked and not forceDesaturated

    for i = 1, select('#', ...), 4 do
        local tier, column, isLearnable, isPreviewLearnable = select(i, ...)
        if ( forceDesaturated or
			 (preview and not isPreviewLearnable) or
			 (not preview and not isLearnable) ) then
            requirementsMet = nil
        end
        getLinePath(buttonTier, buttonColumn, tier, column, frame, requirementsMet)
    end
    return requirementsMet
end

local function CleanUpTalentTrees()
    wipe(TALENT_BRANCH_ARRAY)
    for i = 1, 3 do
        TALENT_BRANCH_ARRAY[i] = {}
        for y = 1, 15 do
            TALENT_BRANCH_ARRAY[i][y] = {}
            for j = 1, NUM_TALENT_COLUMNS do
                TALENT_BRANCH_ARRAY[i][y][j] = {id = nil, up = 0, left = 0, right = 0, down = 0, leftArrow = 0, rightArrow = 0, topArrow = 0}
                local button = _G['GwLegacyTalentTree' .. i .. 'Teir' .. y .. 'index' .. j]
                button.talentid = nil
                button:Hide()

                for l = 1, 10 do
                    local line = _G["GwLegacyTalentLine" .. "-" .. i .. "-" .. y .. "-" .. j .. "-" .. l]
                    if line then
                        line:Hide()
                    end
                end
            end
        end
    end
end

local function UpdatePreviewControls()
    local preview = GetCVarBool("previewTalents")
    local talentPoints = GetUnspentTalentPoints(false, isPetTalents, openSpec)

    if (isPetTalents or openSpec) and talentPoints > 0 and preview then
        GwTalentFrame.bottomBar.prevLearn:Show()
        GwTalentFrame.bottomBar.prevCancel:Show()
		-- enable accept/cancel buttons if preview talent points were spent
		if GetGroupPreviewTalentPointsSpent(isPetTalents, openSpec) > 0 then
			GwTalentFrame.bottomBar.prevLearn:Enable();
			GwTalentFrame.bottomBar.prevCancel:Enable();
		else
			GwTalentFrame.bottomBar.prevLearn:Disable();
			GwTalentFrame.bottomBar.prevCancel:Disable();
		end
	else
		GwTalentFrame.bottomBar.prevLearn:Hide()
        GwTalentFrame.bottomBar.prevCancel:Hide()
	end
end

local function updateTalentTrees()
    if InCombatLockdown() then return end

    local activeTalentGroup = GetActiveTalentGroup()
    local hasDualSpec = GetNumTalentGroups(false, false) > 1
    local hasPetTalents = GetNumTalentGroups(false, true) > 0
    local role = GetTalentGroupRole(activeTalentGroup)

    -- preview
    UpdatePreviewControls()

    UpdateActiveSpec(activeTalentGroup)

	if role then
		PlayerTalentFrameRole_UpdateRole(GwTalentFrame.bottomBar.roleButton, role)
	end

    if isPetTalents then
        GwTalentFrame.bottomBar.spec1Button:Hide()
        GwTalentFrame.bottomBar.spec2Button:Hide()

        GwTalentFrame.bottomBar.dualSpecActiveTalentGroupe:Hide()
        GwTalentFrame.bottomBar.activateSpecGroup:Hide()
    elseif hasDualSpec then
        GwTalentFrame.bottomBar.spec1Button:Show()
        GwTalentFrame.bottomBar.spec2Button:Show()
        GwTalentFrame.bottomBar.spec1Button:SetEnabled(openSpec == 2 or isPetTalents)
        GwTalentFrame.bottomBar.spec2Button:SetEnabled(openSpec == 1 or isPetTalents)

        GwTalentFrame.bottomBar.dualSpecActiveTalentGroupe:SetShown(openSpec == activeTalentGroup)
        GwTalentFrame.bottomBar.activateSpecGroup:SetShown(openSpec ~= activeTalentGroup)
    else
        GwTalentFrame.bottomBar.spec1Button:Hide()
        GwTalentFrame.bottomBar.spec2Button:Hide()

        GwTalentFrame.bottomBar.dualSpecActiveTalentGroupe:Hide()
        GwTalentFrame.bottomBar.activateSpecGroup:Hide()
    end

    if hasPetTalents then
        GwTalentFrame.bottomBar.petTalentsButton:SetText(isPetTalents and PLAYER or PETS)
    end
    GwTalentFrame.bottomBar.petTalentsButton:SetShown(hasPetTalents)

    GwTalentFrame.bottomBar.unspentPoints:SetFormattedText(UNSPENT_TALENT_POINTS, UpdateTalentPoints())

    for f = 1, GW.api.GetNumSpecializations(isPetTalents) do
        local forceDesaturated
        local talentPoints = UpdateTalentPoints()
        local name, _, pointsSpent, _, previewPointsSpent = GetTalentTabInfo(f, false, isPetTalents, openSpec)
        local TalentFrame = _G["GwLegacyTalentTree" .. f]
        local preview = GetCVarBool("previewTalents")

        TalentFrame.pointsSpent = pointsSpent + previewPointsSpent

        if pointsSpent < 1 then
            TalentFrame.background:SetDesaturated(true)
        else
            TalentFrame.background:SetDesaturated(false)
        end
        TalentFrame.talentPoints = talentPoints
        TalentFrame.talentFrameId = f


        TalentFrame.info.title:SetText(name)
        TalentFrame.info.points:SetText(TalentFrame.pointsSpent)

        local numTalents = GetNumTalents(f, false, isPetTalents)
        for i = 1, MAX_NUM_TALENTS do
            local name, texture, tier, column, rank, maxRank, isExceptional, available, previewRank, meetsPreviewPrereq = GetTalentInfo(f, i, false, isPetTalents, openSpec)
            local button = _G['GwLegacyTalentTree' .. f .. 'Teir' .. tier .. 'index' .. column]

            if name and i <= numTalents then
                TALENT_BRANCH_ARRAY[f][tier][column].id = i
                button.icon:SetTexture(texture)
                button.points:SetText((preview and previewRank or rank) .. " / " .. maxRank)
                button.talentid = i
                button.talentFrameId = f
                button:Show()
                button.active = true

                -- If player has no talent points or this is the inactive talent group then show only talents with points in them
                if (TalentFrame.talentPoints <= 0 or not openSpec == activeTalentGroup) and (preview and previewRank or rank) == 0 then
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
                local Prereqs = TalentFrame_SetPrereqs(f, tier, column, forceDesaturated, tierUnlocked, preview, GetTalentPrereqs(f, i, false, isPetTalents, openSpec))

                button.talentID = i
                button.available = preview and meetsPreviewPrereq or available
                button.known = (preview and previewRank or rank) == maxRank

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
                if Prereqs and ((preview and meetsPreviewPrereq) or (not preview and available)) then
                    button.icon:SetDesaturated(openSpec ~= activeTalentGroup)
                    button.icon:SetVertexColor(1, 1, 1, 1)
                    button:SetAlpha(1)
                    if rank < maxRank then
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
                if button and button.talentid == nil then
                    button:Hide()
                end
            end
        end
    end
    -- Clean up unsuded slots
    for i = 1, GW.api.GetNumSpecializations(isPetTalents) do
        for y = 1, 15 do
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

    for i = 1, GW.api.GetNumSpecializations(isPetTalents) do
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

        for y = 1, 15 do
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
    TalentFrame_LoadUI()

    CreateFrame('Frame','GwTalentFrame', GwCharacterWindow, 'GwLegacyTalentFrame')

    GwTalentFrame.bottomBar.activateSpecGroup:SetWidth(GwTalentFrame.bottomBar.activateSpecGroup:GetTextWidth() + 40)

    loadTalentsFrames()

    GwTalentFrame.bottomBar.prevCancel:SetScript("OnClick", function()
        ResetGroupPreviewTalentPoints(isPetTalents, openSpec)
        updateTalentTrees()
    end)
    GwTalentFrame.bottomBar.prevLearn:SetScript("OnClick", function()
        StaticPopup_Show("GW_CONFIRM_LEARN_PREVIEW_TALENTS")
        updateTalentTrees()
    end)

    GwTalentFrame.bottomBar.spec1Button:SetScript("OnClick", function()
        openSpec = 1
        isPetTalents = false
        updateTalentTrees()
    end)
    GwTalentFrame.bottomBar.spec2Button:SetScript("OnClick", function()
        openSpec = 2
        isPetTalents = false
        updateTalentTrees()
    end)
    GwTalentFrame.bottomBar.petTalentsButton:SetScript("OnClick", function()
        openSpec = 1
        isPetTalents = not isPetTalents
        CleanUpTalentTrees()
        updateTalentTrees()
    end)
    GwTalentFrame.bottomBar.activateSpecGroup:SetScript("OnClick", function()
        if openSpec then
            SetActiveTalentGroup(openSpec)
            updateTalentTrees()
        end
    end)

    GwTalentFrame.bottomBar.dualSpecActiveTalentGroupe:SetTextColor(63 / 255, 205 / 255, 75 / 255)

    GwTalentFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
    GwTalentFrame:RegisterEvent("PET_TALENT_UPDATE")
    GwTalentFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    GwTalentFrame:RegisterEvent("TALENT_GROUP_ROLE_CHANGED")
    GwTalentFrame:RegisterEvent("PREVIEW_TALENT_POINTS_CHANGED")
    GwTalentFrame:RegisterEvent("PREVIEW_PET_TALENT_POINTS_CHANGED")
    GwTalentFrame:SetScript('OnEvent', function(_, event, ...)
        GwTalentFrame.bottomBar.unspentPoints:SetFormattedText(UNSPENT_TALENT_POINTS, UnitCharacterPoints("player"))
        if not GwTalentFrame:IsShown() then return end
        updateTalentTrees()
        if event == "TALENT_GROUP_ROLE_CHANGED" then
            local talentGroupIndex, role = ...
            if activeSpec == talentGroupIndex then
                PlayerTalentFrameRole_UpdateRole(GwTalentFrame.bottomBar.roleButton, role)
            end

        end
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

    -- role icon
    UIDropDownMenu_Initialize(GwTalentFrame.bottomBar.roleButton.DropDown, PlayerTalentFrameRoleDropDown_Initialize, "MENU")

    return GwTalentFrame
end
GW.LoadTalents = LoadTalents
