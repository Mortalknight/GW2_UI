local _, GW = ...
local maxTalentRows = 7;
local talentsPerRow = 3;
--Legacy
local MAX_NUM_TALENTS = 20;
-- Default 8 but none uses 8 talent rows in classic
local MAX_NUM_TALENT_TIERS = 8;
local NUM_TALENT_COLUMNS = 4;
local TALENT_BRANCH_ARRAY ={}

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


local function  spellBookMenu_onLoad(self)
    self:RegisterEvent("SPELLS_CHANGED");
    self:RegisterEvent("LEARNED_SPELL_IN_TAB");
    self:RegisterEvent("SKILL_LINES_CHANGED");
    self:RegisterEvent("PLAYER_GUILD_UPDATE");
    --self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
    --self:RegisterEvent("USE_GLYPH");
    --self:RegisterEvent("CANCEL_GLYPH_CAST");
    --self:RegisterEvent("ACTIVATE_GLYPH");
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

 --  self:SetAttribute('macrotext1', '/click PlayerTalentFrameTalentsTalentRow'..row..'Talent'..index)
    self:RegisterForClicks("AnyUp");
 --   self:SetAttribute("type", "macro");
    self:SetPoint('TOPLEFT',container,'TOPLEFT', x + (self:GetWidth()/4) , -(  y + (self:GetHeight()/4)));


    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("CENTER",self,'CENTER',0,0)

    mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(self:GetSize())
    self.mask = mask;

    self.points:SetFont(DAMAGE_TEXT_FONT,12,"OUTLINE")
    self.points:SetTextColor(1,1,1,1)

end

local function petSpecFrame_onShow(self)
    self:SetScript('OnUpdate',function(self,elapsed)
            if MouseIsOver(self) then
                if not self.info.spellPreview:IsShown() and not self.active then
                    self.info.spellPreview:Show()
                    self.info.specDesc:Hide()
                end
                local r,g,b,a = self.background:GetVertexColor()
                self.background:SetVertexColor(r + (1 * elapsed),r + (1 * elapsed),r + (1 * elapsed),r + (1 * elapsed))
                return
            end

            self.info.spellPreview:Hide()
            self.info.specDesc:Show()

            self.background:SetVertexColor(0.7,0.7,0.7,0.7)
        end)
end

local function setLineRotation(self,from,to)


    local y1 = 0
    local y2 = 0

    if from==1 then
        y1 = -18
    elseif from==2 then
        y1 = -60
    elseif from==3 then
        y1 = -103
    end
    if to==1 then
        y2 = -18
    elseif to==2 then
        y2 = -60
    elseif to==3 then
        y2 = -103
    end



  DrawRouteLine(self.line,self,10,y1,56,y2,4,'TOPLEFT')
end

local function getArrow(frame,teir,column,i)
    local n ="GwLegacyTalentLine".."-"..frame.."-"..teir.."-"..column.."-"..i
    if _G[n] ==nil then
        return CreateFrame('Frame',n,_G["GwLegacyTalentTree"..frame].treeContainer,'GwLegacyTalentLine')
    end
    return _G[n]
end

local function colorTalentArrow(self,active)
    local color =  {r=1, b=0.6, g=1}
    if active ==nil then
        color =  {r=0.3, b=0.3, g=0.3}
    end
    self.up:SetVertexColor(color.r,color.g,color.b)
    self.down:SetVertexColor(color.r,color.g,color.b)
    self.left:SetVertexColor(color.r,color.g,color.b)
    self.right:SetVertexColor(color.r,color.g,color.b)
end
local function drawLegacyLine(path,frame,teir,column,requirementsMet)


    local w = _G["GwLegacyTalentTree"..frame].treeContainer:GetWidth()
    local h = _G["GwLegacyTalentTree"..frame].treeContainer:GetHeight()

    local cTeir = teir
    local cCol = column
    for i=1,#path do

        local x = (w / NUM_TALENT_COLUMNS) * (cCol - 1)
        local y = (h / MAX_NUM_TALENT_TIERS) * (cTeir - 1)

        local arrow = getArrow(frame,teir,column,i)
        arrow:ClearAllPoints()
        arrow:SetPoint("TOPLEFT",_G["GwLegacyTalentTree"..frame].treeContainer,"TOPLEFT",   x + (arrow:GetWidth()/4) , -(  y + (arrow:GetHeight()/4)));

        if path[i].y~=0 then
            if path[i].y>0 then
                arrow.down:Show()
            else
                arrow.up:Show()
            end
        elseif path[i].x~=0 then
            if path[i].x>0 then
                arrow.right:Show()
            else
                arrow.left:Down()
            end
        end
        colorTalentArrow(arrow,requirementsMet)
        cTeir = cTeir + path[i].y
        cCol = cCol + path[i].x

    end
end

local function getLinePath(buttonTier, buttonColumn, tier, column,frame, requirementsMet)

    --[[

        Get path to required talent
        Blocking spells are not implemented as there are none in classic

    ]]

    local path = {}
    local blocked = false

    -- Check to see if are in the same column
    if buttonColumn==column then
        if ( (buttonTier - tier) > 1 ) then
            for i=tier , buttonTier - 1 do

                path[#path + 1] = {x=0,y=1}

            end

        else
            path[#path + 1] = {x=0,y=1}
        end
        if not blocked then
            return drawLegacyLine(path,frame,tier,column,requirementsMet)
        end
        path = {}

    end

    blocked= false
    if ( buttonTier == tier ) then
        local left = min(buttonColumn, column);
        local right = max(buttonColumn, column);

        -- See if the distance is greater than one space
        if ( (right - left) > 1 ) then
            for i=buttonColumn + 1, column - 1 do
                if TALENT_BRANCH_ARRAY[frame][i][column].id~=nil then
                    blocked = true
                else
                    path[#path + 1] = {x=1,y=0}
                end
            end
        else

            path[#path + 1] = {x=1,y=0}
        end
        if not blocked then
            return drawLegacyLine(path,frame,tier,column,requirementsMet)
        end

    end
    path = {}

        path[#path + 1] = {x=1,y=0}
        path[#path + 1] = {x=0,y=1}



    return drawLegacyLine(path,frame,tier,column,requirementsMet)

end

local function TalentFrame_SetPrereqs(frame,buttonTier, buttonColumn, forceDesaturated, tierUnlocked, ...)
	local tier, column, isLearnable;
	local requirementsMet;
	if ( tierUnlocked and not forceDesaturated ) then
		requirementsMet = 1;
	else
		requirementsMet = nil;
	end
	for i = 1, select('#', ...), 3 do
		tier = select(i, ...);
		column = select(i+1, ...);
		isLearnable = select(i+2, ...);
		if ( not isLearnable or forceDesaturated ) then
			requirementsMet = nil;
		end
		getLinePath(buttonTier, buttonColumn, tier, column,frame, requirementsMet);

	end
	return requirementsMet;
end

local function updateTalentTrees()
    if InCombatLockdown() then return end

    for f = 1, GW.api.GetNumSpecializations() do

        local forceDesaturated, tierUnlocked;
        local talentPoints = UnitCharacterPoints("player");

        local name, iconTexture, pointsSpent = GetTalentTabInfo(f);

        local TalentFrame = _G["GwLegacyTalentTree"..f]
        TalentFrame.pointsSpent = pointsSpent
        TalentFrame.talentPoints = talentPoints ;
        TalentFrame.talentFrameId = f;

        TalentFrame.info.title:SetText(name)
        TalentFrame.info.points:SetText(pointsSpent)

        GwTalentFrame.bottomBar.unspentPoints:SetText(talentPoints)


        local numTalents = GetNumTalents(f);
        for i=1, MAX_NUM_TALENTS do
            if ( i <= numTalents ) then
                local name, texture, tier, column, rank, maxRank, isExceptional, available, spellid = GetTalentInfo(f, i);

                TALENT_BRANCH_ARRAY[f][tier][column].id = i;
                local button = _G['GwLegacyTalentTree'..f..'Teir'..tier..'index'..column]
                button.icon:SetTexture(texture);
                button.points:SetText(rank.." / "..maxRank)
                button.talentid = i
                button.talentFrameId = f
                button:Show()
                button.active = true

                -- If player has no talent points then show only talents with points in them
    			if ( (TalentFrame.talentPoints <= 0 and rank == 0)  ) then
    				forceDesaturated = 1;
    			else
    				forceDesaturated = nil;
    			end
                -- If the player has spent at least 5 talent points in the previous tier
                local tierUnlocked = nil
                if ( ( (tier - 1) * 5 <= TalentFrame.pointsSpent ) ) then
                    tierUnlocked = 1;
                end


                local ispassive = not isExceptional
                local Prereqs = TalentFrame_SetPrereqs(f,tier, column, forceDesaturated, tierUnlocked, GetTalentPrereqs(f, i))


                button.talentID = talentID;
                button.available = available;
                button.known = rank==maxRank;


                if ispassive then
                    button.legendaryHighlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight' )
                    button.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight' )
                    button.icon:AddMaskTexture(button.mask)
                    button.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_outline');
                else
                    button.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight' )
                    button.legendaryHighlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight' )
                    button.icon:RemoveMaskTexture(button.mask)
                    button.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\background_border');
                end
                    button:EnableMouse(true)
                if  available and Prereqs then
                    button.icon:SetDesaturated(false);
                    button.icon:SetVertexColor(1,1,1,1);
                    button:SetAlpha(1)
                    if rank<maxRank then
                        button.highlight:Hide()
                        button.points:SetTextColor(GREEN_FONT_COLOR.r,GREEN_FONT_COLOR.g,GREEN_FONT_COLOR.b)

                    else
                        button.highlight:Show()
                        button.points:SetText("")
                    end

                else
                    button.icon:SetDesaturated(true);
                    button.icon:SetVertexColor(1,1,1,0.4);
                    button.highlight:Hide()
                    button.points:SetText("")
                end


            else
                if(button~=nil) then
                    button:Hide()
                end
            end
        end
    end
    -- Clean up unsuded slots
    for i = 1, GW.api.GetNumSpecializations() do
        for y=1, MAX_NUM_TALENT_TIERS do

            for j=1, NUM_TALENT_COLUMNS do

                local button = _G['GwLegacyTalentTree'..i..'Teir'..y..'index'..j]
                if button.talentid ==nil then
                    button:Hide()
                end

            end
        end
    end
end

local function updateActiveSpec()

    if InCombatLockdown() then return end

    local current = GW.api.GetSpecialization();


    for i = 1, GW.api.GetNumSpecializations() do

        local container = _G['GwSpecFrame'..i];

        container.specIndex = i;
        if i==current then
            container.active = true;
            container.info:Hide();
            container.background:SetDesaturated(false);

        else
            container.active = false
            container.info:Show();

            container.background:SetDesaturated(true);
        end
        local last = 0;
        local lastIndex =2;
        local lastRowAnySelected = true
        for row = 1, maxTalentRows do

            local anySelected = false;
            local allAvalible = false;

            local sel = nil
            for index = 1,talentsPerRow do
                local button =  _G['GwSpecFrameSpec'..i..'Teir'..row..'index'..index];
                   local talentID, name, texture, selected, available, spellid, tier, column, _, _, known = GetTalentInfo(row, index, 1, false, "player")


                    if not availible then allAvalible  =false; end
                    if not selected then anySelected  =true; end

                    button.spellId = spellid;
                    button.icon:SetTexture(texture);


                    button.talentID = talentID;
                    button.available = available;
                    button.known = known;

                local ispassive = IsPassiveSpell(spellid)
                 button:EnableMouse(true)
                if i~=current then
                   button:EnableMouse(false)
                end

                if ispassive then

                    button.legendaryHighlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight' )
                    button.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight' )
                    button.icon:AddMaskTexture(button.mask)
                    button.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_outline');


                else
                    button.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight' )
                    button.legendaryHighlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight' )
                    button.icon:RemoveMaskTexture(button.mask)
                    button.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\background_border');
                end

                if i==current and (selected or available) and not known then

                    button.highlight:Show();
                    button.legendaryHighlight:Hide();

                    _G['GwTalentLine'..i..'-'..last..'-'..row]:Show()
                    setLineRotation( _G['GwTalentLine'..i..'-'..last..'-'..row], lastIndex,index)
                    lastIndex = index

                    if selected then
                        sel = true
                    end

                else
                    button.legendaryHighlight:Hide();
                    if known then
                        button.legendaryHighlight:Show();
                    end
                    button.highlight:Hide();
                end





                if i==current and (selected or available or known) then
                    button.icon:SetDesaturated(false);
                    button.icon:SetVertexColor(1,1,1,1);
                    button:SetAlpha(1)
                elseif i~=current then
                     button.icon:SetDesaturated(true);
                     button.icon:SetVertexColor(1,1,1,0.1);
                    button:SetAlpha(0.5)
                else
                    button.icon:SetDesaturated(true);
                    button.icon:SetVertexColor(1,1,1,0.4);
                end




            end

            if  i==current and allAvalible==true and anySelected==false then
                for index = 1,talentsPerRow do
                    local button =  _G['GwSpecFrameSpec'..i..'Teir'..row..'index'..index];
                    button.icon:SetDesaturated(false);
                    button.icon:SetVertexColor(1,1,1,1);
                    button:SetAlpha(1)
                    button.highlight:Hide();
                end
            end

            if not sel then
                _G['GwTalentLine'..i..'-'..last..'-'..row]:Hide()
                lastRowAnySelected = false
            else
               lastRowAnySelected = true
            end

             last = row;
        end


    end

end

local function loadTalents()

    local classDisplayName, class, classID = UnitClass('player');

    local txR, txT, txH, txMH;
    txR = 588/1024
    txT = 0
    txH = 140
    txMH = 512
    local specs = GW.api.GetNumSpecializations()
    if specs > 3 then
        txMH = 1024
    end

    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("TOPLEFT",GwCharacterWindow,'TOPLEFT',0,0)


    mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\windowbg-mask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(853, 853)
    GwTalentFrame.bottomBar.background:AddMaskTexture(mask)

    for i = 1, GW.api.GetNumSpecializations() do
        TALENT_BRANCH_ARRAY[i]={}
        local container = CreateFrame('Button','GwLegacyTalentTree'..i,GwTalentFrame,'GwLegacyTalentTree')

        container:SetPoint('TOPLEFT',GwTalentFrame,'TOPLEFT', 284 * (i-1),0);
        container.spec = i;
        local id, name, description, icon, background, role, primaryStat = GW.api.GetSpecializationInfo(i)
        container.background:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\art\\legacy\\'..classID)
        container.background:SetTexCoord(0.27734375*(i - 1), 0.27734375 * i,0, 0.611328125)

        container.background:AddMaskTexture(mask)
    --    container.icon:SetTexture(icon);

    --    container.info.specTitle:SetText(name)
    --    container.info.specDesc:SetText(description)

    --    txT = (i - 1) * txH
    --    container.background:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\art\\'..classID)
    --    container.background:SetTexCoord(0, txR, txT / txMH, (txT + txH) / txMH)


    for y=1, MAX_NUM_TALENT_TIERS do
        TALENT_BRANCH_ARRAY[i][y] = {};
        for j=1, NUM_TALENT_COLUMNS do
            TALENT_BRANCH_ARRAY[i][y][j] = {id=nil, up=0, left=0, right=0, down=0, leftArrow=0, rightArrow=0, topArrow=0};
            local talentButton = CreateFrame('Button','GwLegacyTalentTree'..i..'Teir'..y..'index'..j,container.treeContainer,'GwTalentButton')
            hookTalentButton(talentButton,container.treeContainer,y,j);
        end
    end

    --[[
        local last = 0;

        for row = 1, maxTalentRows do
            local fistOnRow
            local line = CreateFrame('Frame','GwTalentLine'..i..'-'..last..'-'..row,container,'GwTalentLine');

            line:SetPoint('TOPLEFT',container,'TOPLEFT',110 + ((65*row) - (88)), -10)

            last = row;

            for index = 1,talentsPerRow do

                local talentButton = CreateFrame('Button','GwSpecFrameSpec'..i..'Teir'..row..'index'..index,container,'GwTalentButton')

                talentButton:RegisterForDrag("LeftButton");

                hookTalentButton(talentButton,container,row,index);

                if fistOnRow==nil then
                    fistOnRow =talentButton
                end
            end

        end
        ]]

    end
    updateTalentTrees()
end


local function updatePetTalents()
    local current = GetSpecialization(nil, true,GetSpecialization());

    for i = 1, GetNumSpecializations(false,true) do

        local container = _G['GwPetSpecFrame'..i];

        container.specIndex = i;
        if i==current then
            container.active = true;
            container.info.specDesc:Hide();
            container.info.spellPreview:Show();
            container.background:SetDesaturated(false);

        else
            container.active = false
            container.info.specDesc:Show();
            container.info.spellPreview:Hide();

            container.background:SetDesaturated(true);
        end
    end
end


local function getPetSpecSpells(self,specID)

    local specSpells = {GetSpecializationSpells(specID, nil, true, true)};
    local index = 0;
    local xPadding = 0
    local yPadding = 0
    for k=1,#specSpells,2 do
        local button = CreateFrame('Button','GwPetSpecFrameSpec'..specID..'index'..index,self.info.spellPreview,'GwTalentButton')

        button:SetScript('OnClick',nil)
        button.mask = UIParent:CreateMaskTexture()
        button.mask:SetPoint("CENTER",button,'CENTER',0,0)

        button.mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        button.mask:SetSize(34, 34)


        button:SetPoint('TOPLEFT',self.info,'TOPLEFT', xPadding, -50 + yPadding  );
        if xPadding> 230 then
            xPadding = 0
            yPadding = yPadding - 40
        else
            xPadding = xPadding + 40
        end

        local name, rank, texture, castingTime, minRange, maxRange, spellID =  GetSpellInfo(specSpells[k])
        local skillType, spellId = GetSpellBookItemInfo(specSpells[k])
        local ispassive = IsPassiveSpell(specSpells[k])



                    button.spellId = specSpells[k];
                    button.icon:SetTexture(texture);


                    button.active = true;
                    button.talentID = nil;
                    button.available = available;
                    button.known = known;



                   button:EnableMouse(true)

                if ispassive then

                    button.legendaryHighlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight' )
                    button.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_highlight' )
                    button.icon:AddMaskTexture(button.mask)
                    button.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_outline');


                else
                    button.highlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight' )
                    button.legendaryHighlight:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\active_highlight' )
                    button.icon:RemoveMaskTexture(button.mask)
                    button.outline:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\background_border');
                end
                button.legendaryHighlight:Hide();
                button.highlight:Hide();

        index = index + 1;
    end
end

local function loadPetTalents()
  --[[ nyi
    local classDisplayName, class, classID = UnitClass('player');

    local txR, txT, txH, txMH;
    txR = 588/1024
    txT = 0
    txH = 140
    txMH = 512
    local specs = GetNumSpecializations()
    if specs > 3 then
        txMH = 1024
    end

    for i = 1, GetNumSpecializations(false,true) do



        local container = CreateFrame('Button','GwPetSpecFrame'..i,GwPetSpecContainerFrame,'GwSpecFrame')
        container:ClearAllPoints();

        container:SetScript('OnClick',function()
            SetSpecialization(i,true)
        end)
        container:SetScript('OnShow',function()
           petSpecFrame_onShow(container)
        end)

        container:SetScript('OnEvent',function()

          if GetPetTalentTree()==nil then
                container:Hide()
                    return
                else
                container:Show()
            end

            updatePetTalents()
        end)

        container:RegisterEvent("PET_SPECIALIZATION_CHANGED");
        container:RegisterEvent("SPELLS_CHANGED");
        container:RegisterEvent("LEARNED_SPELL_IN_TAB");

        container:SetPoint('TOPLEFT',GwSpecContainerFrame,'TOPLEFT', 10, (-140 * i) +98 );


        container.spec = i;
        local id, name, description, icon, background, role, primaryStat = GetSpecializationInfo(i,false,true)
        container.icon:SetTexture(icon);

        container.info.specTitle:SetText(name)
        container.info.specDesc:SetText(description)

        txT = (i - 1) * txH
        container.background:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\art\\'..classID)
        container.background:SetTexCoord(0, txR, txT / txMH, (txT + txH) / txMH)

        getPetSpecSpells(container,i)

    end
    updatePetTalents()
    ]]
end





local function spellbookButton_onEvent(self)


    if not GwTalentFrame:IsShown() then return end

    local start, duration, enable = GetSpellCooldown(self.spellbookIndex, self.booktype)

    if start~=nil and duration~=nil then
        self.cooldown:SetCooldown(start,duration)
    end

    local autocastable, autostate = GetSpellAutocast(self.spellbookIndex, self.booktype)

    self.autocast:Hide();
    if autostate then
       self.autocast:Show();
    end

end


local spellButtonIndex = 1;
local function setButtonStyle(ispassive,isFuture,spellID,skillType,icon,spellbookIndex,booktype,tab,name)

    local autocastable, autostate = GetSpellAutocast(spellbookIndex, booktype)


    _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].autocast:Hide();
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

    loadTalents();
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

             GwCharacterWindow:SetAttribute('windowPanelOpen',2)
         end)


     --[[
     CreateFrame('Frame','GwSpecContainerFrame',GwTalentFrame)
        GwSpecContainerFrame:SetPoint('TOPLEFT',GwTalentFrame,'TOPLEFT')
        GwSpecContainerFrame:SetPoint('BOTTOMRIGHT',GwTalentFrame,'BOTTOMRIGHT')

    CreateFrame('Frame','GwPetSpecContainerFrame',GwTalentFrame)
        GwPetSpecContainerFrame:SetPoint('TOPLEFT',GwTalentFrame,'TOPLEFT')
        GwPetSpecContainerFrame:SetPoint('BOTTOMRIGHT',GwTalentFrame,'BOTTOMRIGHT')

     CreateFrame('Frame','GwSpellbookMenu',GwTalentFrame,'GwSpellbookMenu')

    spellBookMenu_onLoad(GwSpellbookMenu)
    GwSpellbookMenu:SetScript('OnEvent',function()

            if not GwTalentFrame:IsShown() then return end
            updateSpellbookTab()
        end)
    GwTalentFrame:SetScript('OnEvent',function()

            if not GwTalentFrame:IsShown() then return end
            updateActiveSpec()
        end
    )



    for tab = 1,3 do
        local container = CreateFrame('Frame','GwSpellbookContainerTab'..tab,GwSpellbookMenu,'GwSpellbookContainerTab')
        local line = 0;
        local x = 0;
        local y = 0;
        for i=1,100 do
            local f = CreateFrame('Button','GwSpellbookTab'..tab..'Actionbutton'..i,container,'GwSpellbookActionbutton')
            local mask = UIParent:CreateMaskTexture()
            mask:SetPoint("CENTER",f,'CENTER',0,0)

            mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            mask:SetSize(40, 40)

            f.mask = mask

            f:SetPoint('TOPLEFT',container,'TOPLEFT',(50*x),(-70)+(-50*y))
            f:RegisterForClicks("AnyUp");
            f:RegisterForDrag("LeftButton");
            f:RegisterEvent("SPELL_UPDATE_COOLDOWN");
            f:RegisterEvent("PET_BAR_UPDATE");
			f:HookScript('OnEnter', gw_spell_buttonOnEnter)
            f:HookScript('OnLeave', gw_spell_buttonOnLeave)




            line = line + 1
            x = x + 1;
            if line==5 then
               x = 0
                y = y + 1
                line = 0
            end
        end
    end

    GwSpellbookContainerTab1:Hide()
    GwSpellbookContainerTab2:Show()
    GwSpellbookContainerTab3:Hide()

    loadTalents();
    loadPetTalents();
    updateSpellbookTab()


       GwspellbookTab1:SetFrameRef('GwSpellbookMenu',GwSpellbookMenu)
       GwspellbookTab1:SetAttribute("_onclick", [=[

        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',1)
        ]=]);
       GwspellbookTab2:SetFrameRef('GwSpellbookMenu',GwSpellbookMenu)
       GwspellbookTab2:SetAttribute("_onclick", [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',2)
        ]=]);
       GwspellbookTab3:SetFrameRef('GwSpellbookMenu',GwSpellbookMenu)
       GwspellbookTab3:SetAttribute("_onclick", [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',3)
        ]=]);



    GwspellbookTab3:SetAttribute("_onstate-petstate", [=[
    if newstate == "nopet" then
       self:Hide()
        if self:GetFrameRef('GwSpellbookMenu'):GetAttribute('tabopen') then
            self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',2)
        end
    elseif newstate == "hasPet" then
        self:Show()
    end
]=]);
    RegisterStateDriver(GwspellbookTab3, "petstate", "[target=pet,noexists] nopet;" ..
     " [target=pet,help] hasPet;");


        GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab1',GwSpellbookContainerTab1)
        GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab2',GwSpellbookContainerTab2)
        GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab3',GwSpellbookContainerTab3)
        GwSpellbookMenu:SetFrameRef('GwSpecContainerFrame',GwSpecContainerFrame)
        GwSpellbookMenu:SetFrameRef('GwPetSpecContainerFrame',GwPetSpecContainerFrame)
        GwSpellbookMenu:SetAttribute('_onattributechanged', [=[

            if name~='tabopen' then return end

            self:GetFrameRef('GwSpellbookContainerTab1'):Hide()
            self:GetFrameRef('GwSpellbookContainerTab2'):Hide()
            self:GetFrameRef('GwSpellbookContainerTab3'):Hide()

            if value==1 then
                self:GetFrameRef('GwSpellbookContainerTab1'):Show()
                self:GetFrameRef('GwSpecContainerFrame'):Show()
                self:GetFrameRef('GwPetSpecContainerFrame'):Hide()
                return
            end   if value==2 then
                self:GetFrameRef('GwSpellbookContainerTab2'):Show()
                self:GetFrameRef('GwSpecContainerFrame'):Show()
                self:GetFrameRef('GwPetSpecContainerFrame'):Hide()
                return
            end   if value==3 then
                self:GetFrameRef('GwSpellbookContainerTab3'):Show()
                self:GetFrameRef('GwSpecContainerFrame'):Hide()
                self:GetFrameRef('GwPetSpecContainerFrame'):Show()
                return
            end


        ]=]);
        GwSpellbookMenu:SetAttribute('tabOpen',2)


       GwspellbookTab1:HookScript('OnClick', spellBookTab_onClick)
       GwspellbookTab2:HookScript('OnClick', spellBookTab_onClick)
       GwspellbookTab3:HookScript('OnClick', spellBookTab_onClick)
       GwspellbookTab3:HookScript('OnHide', function() spellBookTab_onClick(GwspellbookTab2) end)

        spellBookTabHero_onLoad(GwspellbookTab2)


    GwTalentFrame:HookScript('OnShow', function()
        GwCharacterWindow.windowIcon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\spellbook-window-icon')
            GwCharacterWindow.WindowHeader:SetText(GwLocalization['TALENTS_HEADER'])
               if InCombatLockdown() then return end
            updateSpellbookTab()
            updateActiveSpec()
    end)

        hooksecurefunc('ToggleTalentFrame',function()
            if InCombatLockdown() then return end

            GwCharacterWindow:SetAttribute('windowPanelOpen',2)
        end)

        ]]
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
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(GwLocalization['REQUIRED_LEVEL_SPELL']..GetSpellLevelLearned(self.spellId), 1, 1, 1)
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
