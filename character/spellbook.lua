local _, GW = ...
local MAX_SPELLS = MAX_SPELLS;
local MAX_SKILLLINE_TABS = MAX_SKILLLINE_TABS;
local SPELLS_PER_PAGE = 21;
local MAX_SPELL_PAGES = ceil(MAX_SPELLS / SPELLS_PER_PAGE);
local ACTIVE_PAGE = 1;

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

local SpellbookHeaderIndex = 1;
local function getSpellBookHeader(tab)

    if _G['GwSpellbookContainerTab'..tab..'GwSpellbookActionBackground'..SpellbookHeaderIndex]~=nil then

        local f = _G['GwSpellbookContainerTab'..tab..'GwSpellbookActionBackground'..SpellbookHeaderIndex]
        SpellbookHeaderIndex = SpellbookHeaderIndex + 1
        return f
    end

     local f =CreateFrame("Frame",'GwSpellbookContainerTab'..tab..'GwSpellbookActionBackground'..SpellbookHeaderIndex,_G['GwSpellbookContainerTab'..tab].scrollchild,"GwSpellbookActionBackground" )
     _G['GwSpellbookContainerTab'..tab].headers[#_G['GwSpellbookContainerTab'..tab].headers + 1] = f
     local prev = _G['GwSpellbookContainerTab'..tab..'GwSpellbookActionBackground'..(SpellbookHeaderIndex - 1)]
     if prev~=nil then
         if (SpellbookHeaderIndex % 2) == 0 then
             local prev2 = _G['GwSpellbookContainerTab'..tab..'GwSpellbookActionBackground'..(SpellbookHeaderIndex - 2)]
             if prev2~=nil then
                 f:SetPoint("TOPLEFT",prev2,"BOTTOMLEFT", 0,-15)
             else
                 f:SetPoint("TOPLEFT", prev,"TOPRIGHT", 0,0)
            end
            f.column = 1;
          else
              prev = _G['GwSpellbookContainerTab'..tab..'GwSpellbookActionBackground'..(SpellbookHeaderIndex - 2)]
              f:SetPoint("TOPLEFT", prev,"BOTTOMLEFT", 0,-15)
          end
     else
         f.column = 2
          f:SetPoint("TOPLEFT", f:GetParent(),"TOPLEFT", 0,0)
     end
     SpellbookHeaderIndex = SpellbookHeaderIndex + 1
     return f;
end


local spellButtonIndex = 1;
local function setButtonStyle(ispassive,isFuture,spellID,skillType,icon,spellbookIndex,booktype,tab,name,rank,level)

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

     if rank~=nil then
         _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].rank:SetText(rank)
     else
         _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].rank:SetText("")
     end
     if level~=nil then
         _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].lock:Show()
     else
         _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex].lock:Hide()
     end


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
    return _G['GwSpellbookTab'..tab..'Actionbutton'..spellButtonIndex]

end

local function findHigherRank(t,spellID)
    local si = spellID
    for k,v in pairs(GW.SpellsByLevel) do
        for _,spell in pairs(v) do
            if spell.requiredIds~=nil then
                for _,rid in pairs(spell.requiredIds) do
                    if rid == si  then
                        if not IsSpellKnown(spell.id) then
                            t[#t + 1] = {id=spell.id,level=k}
                            t = findHigherRank(t,spell.id)
                            return t
                        end
                    end
                end
            end
        end
    end
    return t
end

local knowSpells = {}
local function updateSpellbookTab()


    if InCombatLockdown() then return end


    for spellBookTabs=1,5 do
        local name, texture, offset, numSpells,offSpecID,shouldHide,specID = GetSpellTabInfo(spellBookTabs)


        local flyOuts = {}
        SpellbookHeaderIndex = 1
        spellButtonIndex = 1;
        local BOOKTYPE = 'spell'
        if spellBookTabs==5 then
            BOOKTYPE='pet'
            numSpells, petToken = HasPetSpells();
            offset = 0
            name = PET
            texture = "Interface\\AddOns\\GW2_UI\\textures\\talents\\tabicon_pet"
           if numSpells==nil then
                numSpells = 0
            end
        end
        _G['GwspellbookTab'..spellBookTabs].icon:SetTexture(texture)
        _G['GwspellbookTab'..spellBookTabs].title:SetText(name)
        _G['GwSpellbookContainerTab'..spellBookTabs].title:SetText(name)

        local boxIndex = 1;
        local y = 1
        local fPassive = false
        local indexToPassive =nil
        local lastSkillid = 0
        local lastButton
        local header
        local headerPositionY = 0
        local needNewHeader = true

        local column1 = 0;
        local column2 = 0;

        for i=1,numSpells do

            local hasHigherRank = false
            local spellIndex = i + offset
            local name, rank, icon, castingTime, minRange, maxRange, spellID =  GetSpellInfo(spellIndex,BOOKTYPE)
                local skillType, spellId = GetSpellBookItemInfo(spellIndex,BOOKTYPE)


                local ispassive = IsPassiveSpell(spellID)

                --

                local icon = GetSpellBookItemTexture(spellIndex, BOOKTYPE);
                local name, Subtext = GetSpellBookItemName(spellIndex, BOOKTYPE)



                needNewHeader = true
                for k,v in pairs(GW.SpellsByLevel) do
                    for _,spell in pairs(v) do
                        local contains
                        if spell.requiredIds~=nil then
                            if spell.id==spellID then

                                contains = GW.tableContains(spell.requiredIds,lastSkillid)
                            end
                            if contains then
                                needNewHeader = false

                            end
                        end

                    end
                end
                local rank
                if not needNewHeader then
                    rank = header.buttons + 1
                end

                local mainButton = setButtonStyle(ispassive,isFuture,spellID,skillType,icon,spellIndex,BOOKTYPE,spellBookTabs,name,rank)
                spellButtonIndex = spellButtonIndex + 1
                boxIndex = boxIndex + 1;
                knowSpells[#knowSpells +1] = spellID

                local unlearnd = {}

                unlearnd = findHigherRank(unlearnd,spellID)


                if needNewHeader then
                    header = getSpellBookHeader(spellBookTabs)
                    header.title:SetText(name)
                    header.buttons = 1;
                    header.height = 60
                end


                mainButton:ClearAllPoints()
                if needNewHeader then
                    mainButton:SetPoint("TOPLEFT",header,"TOPLEFT",15,-35)
                    header.firstButton = mainButton
                else

                    if header.buttons==6 then
                        mainButton:SetPoint("TOPLEFT",header.firstButton,"BOTTOMLEFT",0,-5)
                        header.height =header.height + 45
                    else
                        mainButton:SetPoint("LEFT",lastButton,"RIGHT",5,0)
                    end
                    header.buttons =header.buttons +1;
                end

                local lastBox = mainButton
                for _,unknownSpellID in pairs(unlearnd) do

                    local unKnownChildButton = setButtonStyle(ispassive,isFuture,unknownSpellID.id,'FUTURESPELL',icon,spellIndex,BOOKTYPE,spellBookTabs,name,header.buttons+1,unlearnd,unknownSpellID.level)
                    knowSpells[#knowSpells +1] = unknownSpellID.id
                    unKnownChildButton:ClearAllPoints()
                    if header.buttons==6 then
                        unKnownChildButton:SetPoint("TOPLEFT",header.firstButton,"BOTTOMLEFT",0,-5)
                        header.height =header.height + 45
                    else
                        unKnownChildButton:SetPoint("LEFT",lastBox,"RIGHT",5,0)
                    end
                    spellButtonIndex = spellButtonIndex + 1
                    boxIndex = boxIndex + 1;
                    lastBox = unKnownChildButton
                    header.buttons =header.buttons +1;
                end




                header:SetHeight(header.height )




                lastSkillid = spellID
                lastButton = mainButton





        end

        for _, h in pairs(_G['GwSpellbookContainerTab'..spellBookTabs].headers) do
            if h.column==1 then
                column1 = column1 + h.height
            else
                column2 = column2 + h.height
            end
        end

        if column1>column2 then
            _G['GwSpellbookContainerTab'..spellBookTabs].slider:SetMinMaxValues(0,math.max(0,column1 -_G['GwSpellbookContainerTab'..spellBookTabs]:GetHeight()))
        else
            _G['GwSpellbookContainerTab'..spellBookTabs].slider:SetMinMaxValues(0,math.max(0,column2 -_G['GwSpellbookContainerTab'..spellBookTabs]:GetHeight()))
        end


        for i=boxIndex,100 do
            _G['GwSpellbookTab'..spellBookTabs..'Actionbutton'..i]:SetAlpha(0)
            _G['GwSpellbookTab'..spellBookTabs..'Actionbutton'..i]:EnableMouse(false)
            _G['GwSpellbookTab'..spellBookTabs..'Actionbutton'..boxIndex]:SetScript('OnEvent',nil)
        end
    end

end

local function spellBookTab_onClick(self)

    GwspellbookTab1.background:Hide()
    GwspellbookTab2.background:Hide()
    GwspellbookTab3.background:Hide()
    GwspellbookTab4.background:Hide()
    GwspellbookTab5.background:Hide()

    self.background:Show()

end

function gw_register_spellbook_window()
    local classDisplayName, class, classID = UnitClass('player');
    CreateFrame('Frame','GwSpellbook',GwCharacterWindow,'GwSpellbook')
    CreateFrame('Frame','GwSpellbookMenu',GwSpellbook,'GwSpellbookMenu')


    spellBookMenu_onLoad(GwSpellbookMenu)
    GwSpellbookMenu:SetScript('OnEvent',function()

            if not GwSpellbook:IsShown() then return end
            updateSpellbookTab()
    end)

    local mask = UIParent:CreateMaskTexture()
    mask:SetPoint("TOPLEFT",GwCharacterWindow,'TOPLEFT',0,0)
    mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\windowbg-mask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(853, 853)


    for tab = 1,5 do
        local menuItem = CreateFrame('Button','GwspellbookTab'..tab,GwSpellbookMenu,'GwspellbookTab')
        menuItem:SetPoint("TOPLEFT",GwSpellbookMenu,"TOPLEFT", 0, -menuItem:GetHeight() * (tab-1) )
        local container = CreateFrame('ScrollFrame','GwSpellbookContainerTab'..tab,GwSpellbook,'GwSpellbookContainerTab')
        container.title:SetFont(DAMAGE_TEXT_FONT,16,"OUTLINE")
        container.title:SetTextColor(0.9,0.9,0.7,1)
        local zebra = tab % 2
        menuItem.title:SetFont(DAMAGE_TEXT_FONT,14,"OUTLINE")
        menuItem.title:SetTextColor(0.7,0.7,0.5,1)
        menuItem.bg:SetVertexColor(1,1,1,zebra)

        menuItem.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
        menuItem:SetNormalTexture(nil)
        menuItem:SetText("")

        container.headers = {}
        local line = 0;
        local x = 0;
        local y = 0;
        for i=1,100 do
            local f = CreateFrame('Button','GwSpellbookTab'..tab..'Actionbutton'..i,container.scrollchild,'GwSpellbookActionbutton')
            local mask = UIParent:CreateMaskTexture()
            mask:SetPoint("CENTER",f,'CENTER',0,0)

            mask:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            mask:SetSize(40, 40)

            f.mask = mask
            f.rank:SetFont(DAMAGE_TEXT_FONT,12,"OUTLINE")
            f.rank:SetTextColor(0.9,0.9,0.8,1)
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
    GwSpellbookContainerTab2:Hide()
    GwSpellbookContainerTab3:Show()
    GwSpellbookContainerTab4:Hide()
    GwSpellbookContainerTab5:Hide()

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
            GwspellbookTab4:SetFrameRef('GwSpellbookMenu',GwSpellbookMenu)
            GwspellbookTab4:SetAttribute("_onclick", [=[
             self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',4)
             ]=]);
             GwspellbookTab5:SetFrameRef('GwSpellbookMenu',GwSpellbookMenu)
             GwspellbookTab5:SetAttribute("_onclick", [=[
              self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',5)
              ]=]);



                 GwspellbookTab5:SetAttribute("_onstate-petstate", [=[

                 if newstate == "nopet" then
                    self:Hide()
                     if self:GetFrameRef('GwSpellbookMenu'):GetAttribute('tabopen') then
                         self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',2)
                     end
                 elseif newstate == "hasPet" then
                     self:Show()
                 end
             ]=]);
                 RegisterStateDriver(GwspellbookTab5, "petstate", "[target=pet,noexists] nopet;" ..
                  " [target=pet,help] hasPet;");


                     GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab1',GwSpellbookContainerTab1)
                     GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab2',GwSpellbookContainerTab2)
                     GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab3',GwSpellbookContainerTab3)
                     GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab4',GwSpellbookContainerTab4)
                     GwSpellbookMenu:SetFrameRef('GwSpellbookContainerTab5',GwSpellbookContainerTab5)

                     GwSpellbookMenu:SetAttribute('_onattributechanged', [=[

                         if name~='tabopen' then return end

                         self:GetFrameRef('GwSpellbookContainerTab1'):Hide()
                         self:GetFrameRef('GwSpellbookContainerTab2'):Hide()
                         self:GetFrameRef('GwSpellbookContainerTab3'):Hide()
                         self:GetFrameRef('GwSpellbookContainerTab4'):Hide()
                         self:GetFrameRef('GwSpellbookContainerTab5'):Hide()

                         if value==1 then
                             self:GetFrameRef('GwSpellbookContainerTab1'):Show()
                             return
                         end   if value==2 then
                             self:GetFrameRef('GwSpellbookContainerTab2'):Show()

                             return
                         end
                          if value==3 then
                             self:GetFrameRef('GwSpellbookContainerTab3'):Show()
                             return
                         end
                         if value==4 then
                            self:GetFrameRef('GwSpellbookContainerTab4'):Show()
                            return
                        end
                        if value==5 then
                           self:GetFrameRef('GwSpellbookContainerTab5'):Show()
                           return
                       end


                     ]=]);
                     GwSpellbookMenu:SetAttribute('tabOpen',2)


                    GwspellbookTab1:HookScript('OnClick', spellBookTab_onClick)
                    GwspellbookTab2:HookScript('OnClick', spellBookTab_onClick)
                    GwspellbookTab3:HookScript('OnClick', spellBookTab_onClick)
                    GwspellbookTab4:HookScript('OnClick', spellBookTab_onClick)
                    GwspellbookTab5:HookScript('OnClick', spellBookTab_onClick)
                    GwspellbookTab5:HookScript('OnHide', function() spellBookTab_onClick(GwspellbookTab2) end)

                    GwSpellbook:HookScript('OnShow', function()
                        GwCharacterWindow.windowIcon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\spellbook-window-icon')
                        GwCharacterWindow.WindowHeader:SetText(SPELLBOOK)
                        if InCombatLockdown() then return end
                            updateSpellbookTab()

                    end)

                        hooksecurefunc('ToggleSpellBook',function()
                            if InCombatLockdown() then return end
                            GwCharacterWindow:SetAttribute('windowPanelOpen',3)
                        end)




     --hooksecurefunc('ToggleSpellBook',gwToggleSpellbook)

     -- Remove blizzard default panel
     SpellBookFrame:SetScript("OnShow", function()
           HideUIPanel(SpellBookFrame)
     end)
     SpellBookFrame:UnregisterAllEvents()

    return GwSpellbook
end

function gwToggleSpellbook(bookType)
   gwCharacterPanelToggle(nil)
    GwSpellbook:Show()
end
