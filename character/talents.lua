local _, GW = ...
local maxTalentRows = 7
local talentsPerRow = 3
--Legacy
local MAX_NUM_TALENTS = 20
-- Default 8 but none uses 8 talent rows in classic
local MAX_NUM_TALENT_TIERS = 8
local NUM_TALENT_COLUMNS = 4
local TALENT_BRANCH_ARRAY = {}


GwActiveSpellTab = 2;



TAXIROUTE_LINEFACTOR = 32/30; -- Multiplying factor for texture coordinates
TAXIROUTE_LINEFACTOR_2 = TAXIROUTE_LINEFACTOR / 2; -- Half o that

-- T        - Texture
-- C        - Canvas Frame (for anchoring)
-- sx,sy    - Coordinate of start of line
-- ex,ey    - Coordinate of end of line
-- w        - Width of line
-- relPoint - Relative point on canvas to interpret coords (Default BOTTOMLEFT)


function DrawRouteLine(T, C, sx, sy, ex, ey, w, relPoint)
   if (not relPoint) then relPoint = "BOTTOMLEFT"; end

   -- Determine dimensions and center point of line
   local dx,dy = ex - sx, ey - sy;
   local cx,cy = (sx + ex) / 2, (sy + ey) / 2;

   -- Normalize direction if necessary
   if (dx < 0) then
      dx,dy = -dx,-dy;
   end

   -- Calculate actual length of line
   local l = sqrt((dx * dx) + (dy * dy));

   -- Quick escape if it's zero length
   if (l == 0) then
      T:SetTexCoord(0,0,0,0,0,0,0,0);
      T:SetPoint("BOTTOMLEFT", C, relPoint, cx,cy);
      T:SetPoint("TOPRIGHT",   C, relPoint, cx,cy);
      return;
   end

   -- Sin and Cosine of rotation, and combination (for later)
   local s,c = -dy / l, dx / l;
   local sc = s * c;

   -- Calculate bounding box size and texture coordinates
   local Bwid, Bhgt, BLx, BLy, TLx, TLy, TRx, TRy, BRx, BRy;
   if (dy >= 0) then
      Bwid = ((l * c) - (w * s)) * TAXIROUTE_LINEFACTOR_2;
      Bhgt = ((w * c) - (l * s)) * TAXIROUTE_LINEFACTOR_2;
      BLx, BLy, BRy = (w / l) * sc, s * s, (l / w) * sc;
      BRx, TLx, TLy, TRx = 1 - BLy, BLy, 1 - BRy, 1 - BLx;
      TRy = BRx;
   else
      Bwid = ((l * c) + (w * s)) * TAXIROUTE_LINEFACTOR_2;
      Bhgt = ((w * c) + (l * s)) * TAXIROUTE_LINEFACTOR_2;
      BLx, BLy, BRx = s * s, -(l / w) * sc, 1 + (w / l) * sc;
      BRy, TLx, TLy, TRy = BLx, 1 - BRx, 1 - BLx, 1 - BLy;
      TRx = TLy;
   end

   -- Set texture coordinates and anchors
   T:ClearAllPoints();
   T:SetTexCoord(TLx, TLy, BLx, BLy, TRx, TRy, BRx, BRy);
   T:SetPoint("BOTTOMLEFT", C, relPoint, cx - Bwid, cy - Bhgt);
   T:SetPoint("TOPRIGHT",   C, relPoint, cx + Bwid, cy + Bhgt);
end




local function spellBookTab_onClick(self)

    GwspellbookTab1.background:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\spellbooktab_bg_inactive')
    GwspellbookTab2.background:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\spellbooktab_bg_inactive')
    GwspellbookTab3.background:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\spellbooktab_bg_inactive')

    self.background:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\spellbooktab_bg')

end

local function spellBookTabHero_onLoad(self)
     local localizedClass, englishClass, classIndex = UnitClass("player");

    GW.SetClassIcon(self.icon,classIndex)
end

local function hookTalentButton(self,container, row, index)

    local w = container:GetWidth()
    local h = container:GetHeight()
    local x = (w / NUM_TALENT_COLUMNS) * (index - 1)
    local y = (h / MAX_NUM_TALENT_TIERS) * (row - 1)

    self:RegisterForClicks("AnyUp")
    self:SetPoint('TOPLEFT', container, 'TOPLEFT', x + (self:GetWidth() / 4), -(y + (self:GetHeight() / 4)))

    local mask = UIParent:CreateMaskTexture()

    mask:SetPoint("CENTER", self, 'CENTER', 0,0 )
    mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(self:GetSize())
    self.mask = mask
    self.points:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINE")
    self.points:SetTextColor(1, 1, 1, 1)
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
                arrow.left:Down()
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
        path = {}
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
            path[#path + 1] = {x = 1, y = 0}
        end
        if not blocked then
            return drawLegacyLine(path, frame, tier, column, requirementsMet)
        end
    end
    path = {}
    path[#path + 1] = {x = 1, y = 0}
    path[#path + 1] = {x = 0, y = 1}

    return drawLegacyLine(path, frame, tier, column, requirementsMet)
end

local function TalentFrame_SetPrereqs(frame, buttonTier, buttonColumn, forceDesaturated, tierUnlocked, ...)
	local tier, column, isLearnable
    local requirementsMet

	if tierUnlocked and not forceDesaturated then
		requirementsMet = 1
	else
		requirementsMet = nil
	end
	for i = 1, select('#', ...), 3 do
		tier = select(i, ...);
		column = select(i + 1, ...)
		isLearnable = select(i + 2, ...)
		if not isLearnable or forceDesaturated then
			requirementsMet = nil
		end
		getLinePath(buttonTier, buttonColumn, tier, column, frame, requirementsMet)
	end
	return requirementsMet
end

local function updateTalentTrees()
    if InCombatLockdown() then return end

    for f = 1, GW.api.GetNumSpecializations() do
        local forceDesaturated, tierUnlocked;
        local talentPoints = UnitCharacterPoints("player");
        local name, iconTexture, pointsSpent = GetTalentTabInfo(f)
        local TalentFrame = _G["GwLegacyTalentTree" .. f]

        TalentFrame.pointsSpent = pointsSpent

        if pointsSpent<1 then
            TalentFrame.background:SetDesaturated(true);
        else
            TalentFrame.background:SetDesaturated(false);
        end
        TalentFrame.talentPoints = talentPoints ;
        TalentFrame.talentFrameId = f;


        TalentFrame.info.title:SetText(name)
        TalentFrame.info.points:SetText(pointsSpent)

        GwTalentFrame.bottomBar.unspentPoints:SetText(talentPoints)

        local numTalents = GetNumTalents(f)
        for i = 1, MAX_NUM_TALENTS do
            if i <= numTalents then
                local name, texture, tier, column, rank, maxRank, isExceptional, available, spellid = GetTalentInfo(f, i)

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

local function loadTalents()
    local classDisplayName, class, classID = UnitClass('player')
    local txR, txT, txH, txMH

    txR = 588 / 1024
    txT = 0
    txH = 140
    txMH = 512
    local specs = GW.api.GetNumSpecializations()
    if specs > 3 then
        txMH = 1024
    end

    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("TOPLEFT", GwCharacterWindow, 'TOPLEFT', 0, 0)
    mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\windowbg-mask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(853, 853)


    for i = 1, GW.api.GetNumSpecializations() do
        TALENT_BRANCH_ARRAY[i] = {}
        local container = CreateFrame('Button', 'GwLegacyTalentTree' .. i, GwTalentFrame, 'GwLegacyTalentTree')

        container:SetPoint('TOPLEFT',GwTalentFrame,'TOPLEFT', (284 * (i-1)) + 5,-92);
        container.spec = i;

        local id, name, description, icon, background, role, primaryStat = GW.api.GetSpecializationInfo(i)
        container.background:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\art\\legacy\\' .. classID)
        container.background:SetTexCoord(0.27734375 * (i - 1), 0.27734375 * i, 0, 0.611328125)
        container.background:AddMaskTexture(mask)

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

local function spellbookButton_onEvent(self)
    if not GwTalentFrame:IsShown() then return end

    local start, duration, enable = GetSpellCooldown(self.spellbookIndex, self.booktype)

    if start ~= nil and duration ~= nil then
        self.cooldown:SetCooldown(start, duration)
    end

    local autocastable, autostate = GetSpellAutocast(self.spellbookIndex, self.booktype)

    self.autocast:Hide()
    if autostate then
         _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].autocast:Show();
    end

    _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].isPassive = ispassive;
    _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].isFuture = (skillType=='FUTURESPELL');
    _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].isFlyout = (skillType=='FLYOUT');
    _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].spellbookIndex = spellbookIndex
    _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].booktype = booktype
    _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex]:EnableMouse(true)

    _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].spellId =spellID
    _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].icon:SetTexture(icon)

     _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex]:SetAlpha(1)


    if booktype=='pet' then
        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex]:SetAttribute("type", "spell");
        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex]:SetAttribute("*spell", spellID)



         _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex]:SetAttribute("type2", "macro")
         _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex]:SetAttribute("*macrotext2", "/petautocasttoggle "..name)
    else
        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex]:SetAttribute("type", "spell");
        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex]:SetAttribute("spell", spellID);
    end



    _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].arrow:Hide()

    _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex]:SetScript('OnEvent',spellbookButton_onEvent)


    if skillType=='FUTURESPELL' then

         _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].icon:SetDesaturated(true);
         _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].icon:SetAlpha(0.5)
    elseif skillType=='FLYOUT' then

        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].arrow:Show()
        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex]:SetAttribute("type", "flyout");
        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex]:SetAttribute("flyout", spellID);
        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex]:SetAttribute("flyoutDirection", 'RIGHT');

        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].icon:SetDesaturated(false);
        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].icon:SetAlpha(1)
    else
        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].icon:SetDesaturated(false);
        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].icon:SetAlpha(1)
    end


    if ispassive then
        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight' )
        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].icon:AddMaskTexture(_G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].mask)
        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_outline');
    else

        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight' )
        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].icon:RemoveMaskTexture(_G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].mask)
        _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\background_border');
    end

end

local function updateSpellbookTab()


    if InCombatLockdown() then return end



    for spellBookTabs=1,3 do

        local name, texture, offset, numSpells = GetSpellTabInfo(spellBookTabs)

        local flyOuts = {}

        spellButtonIndex = 1;
        local BOOKTYPE = 'spell'
        if spellBookTabs==3 then
            BOOKTYPE='pet'
            numSpells, petToken = HasPetSpells();
            offset = 0
           if numSpells==nil then
                numSpells = 0
            end
        end

        local boxIndex = 1;
        local y = 1
        local fPassive = false
        local indexToPassive =nil
        for i=1,numSpells do


            local spellIndex = i + offset
            local name, rank, icon, castingTime, minRange, maxRange, spellID =  GetSpellInfo(spellIndex,BOOKTYPE)
                local skillType, spellId = GetSpellBookItemInfo(spellIndex,BOOKTYPE)
                print(skillType)

                local ispassive = IsPassiveSpell(spellID)

                if not ispassive then

                local icon = GetSpellBookItemTexture(spellIndex, BOOKTYPE);
                local name, Subtext = GetSpellBookItemName(spellIndex, BOOKTYPE)

                setButtonStyle(ispassive,isFuture,spellId,skillType,icon,spellIndex,BOOKTYPE,spellBookTabs,name)

                    spellButtonIndex = spellButtonIndex + 1
                    boxIndex = boxIndex + 1;
                    y = y + 1

                    if y==6 then
                        y=1
                    end

                else
                    if indexToPassive==nil then
                        indexToPassive = i;
                    end
                end


        end



        maxSkip = 10
        if y==1 then maxSkip=5 end
        for skip=y,maxSkip do
            _G['GwSpellbookTab'..spellBookTabs..'Actionbutton'..boxIndex]:SetAlpha(0)
            _G['GwSpellbookTab'..spellBookTabs..'Actionbutton'..boxIndex]:EnableMouse(false)
            _G['GwSpellbookTab'..spellBookTabs..'Actionbutton'..boxIndex]:SetScript('OnEvent',nil)
            boxIndex = boxIndex + 1;
            spellButtonIndex = spellButtonIndex +1
        end
        _G['GwSpellbookContainerTab'..spellBookTabs].passiveLabel:ClearAllPoints()
         _G['GwSpellbookContainerTab'..spellBookTabs].passiveLabel:SetPoint('BOTTOMLEFT',_G['GwSpellbookTab'..spellBookTabs..'Actionbutton'..boxIndex],'TOPLEFT',-4,15);



        if indexToPassive~=nil then

            for i=indexToPassive,numSpells do

                local spellIndex = i + offset
                local name, rank, _, castingTime, minRange, maxRange, spellID =  GetSpellInfo(spellIndex,BOOKTYPE)

                local skillType, spellId = GetSpellBookItemInfo(spellIndex,BOOKTYPE)

                local ispassive = IsPassiveSpell(spellID)

                local icon = GetSpellBookItemTexture(spellIndex, BOOKTYPE);
                local name, Subtext = GetSpellBookItemName(spellIndex, BOOKTYPE)
                if ispassive then
                    y = y + 1

                    if y==6 then
                        y=0
                    end

                setButtonStyle(ispassive,isFuture,spellId,skillType,icon,spellIndex,BOOKTYPE,spellBookTabs,name)

                    spellButtonIndex = spellButtonIndex + 1
                    boxIndex = boxIndex + 1;
                    indexToPassive = spellIndex + 1
                end
            end
        end




        for i=boxIndex,100 do
            _G['GwSpellbookTab'..spellBookTabs..'Actionbutton'..i]:SetAlpha(0)
            _G['GwSpellbookTab'..spellBookTabs..'Actionbutton'..i]:EnableMouse(false)
            _G['GwSpellbookTab'..spellBookTabs..'Actionbutton'..boxIndex]:SetScript('OnEvent',nil)
        end

    end
end

function gw_register_talent_window()
    CreateFrame('Frame','GwTalentFrame',GwCharacterWindow,'SecureHandlerStateTemplate,GwLegacyTalentFrame')

    loadTalents()
     GwTalentFrame:SetScript('OnEvent',function()
        if not GwTalentFrame:IsShown() then return end
            updateTalentTrees()
        end
     )
     GwTalentFrame:HookScript('OnShow', function()
        GwCharacterWindow.windowIcon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\talents-window-icon')
        GwCharacterWindow.WindowHeader:SetText(TALENTS)
        if InCombatLockdown() then return end
        updateTalentTrees()
    end)

    hooksecurefunc('ToggleTalentFrame',function()
        if InCombatLockdown() then return end
        GwCharacterWindow:SetAttribute('windowPanelOpen', 2)
    end)
    GwTalentFrame:Hide()


    return GwTalentFrame;

end

function gw_spell_buttonOnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT",0,0);
    GameTooltip:ClearLines();

    if not self.isFlyout then
		GameTooltip:SetSpellBookItem(self.spellbookIndex,self.booktype)
    else
        local name, desc, numSlots, isKnown = GetFlyoutInfo(self.spellId);
        GameTooltip:AddLine(name)
        GameTooltip:AddLine(desc)
    end
	if self.isFuture then
	--	GameTooltip:AddLine(' ')
	--	GameTooltip:AddLine(GwLocalization['REQUIRED_LEVEL_SPELL']..GetSpellLevelLearned(self.spellId), 1, 1, 1)
	end
    GameTooltip:Show()
end

function gw_spell_buttonOnLeave(self)
    GameTooltip:Hide()
end
function gwSetActiveSpellbookTab(i)
    GwActiveSpellTab = i

    for i=1,3 do
        _G['GwspellbookTab'..i].background:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\spellbooktab_bg_inactive')
    end
    updateSpellbookTab()
end
