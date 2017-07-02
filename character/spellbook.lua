local MAX_SPELLS = MAX_SPELLS;
local MAX_SKILLLINE_TABS = MAX_SKILLLINE_TABS;
local SPELLS_PER_PAGE = 21;
local MAX_SPELL_PAGES = ceil(MAX_SPELLS / SPELLS_PER_PAGE);
local ACTIVE_PAGE = 1;

function gwSpellBookSpell_onDrag(self)
    local slot, slotType = SpellBook_GetSpellBookSlot(self);
    if (not slot or slot > MAX_SPELLS or not _G[self:GetName().."IconTexture"]:IsShown() or (slotType == "FUTURESPELL")) then
        return;
	   end
    self:SetChecked(false);
    PickupSpellBookItem(slot, SpellBookFrame.bookType);
end


local function updateSpellbook(tab)
    
    local currentSpec = GetSpecialization() 
    local spells = {GetSpecializationSpells(currentSpec)}
    for k,v in pairs(spells) do
  
  
    end
    
    local from = (MAX_SPELL_PAGES*(ACTIVE_PAGE - 1))
    local to  = MAX_SPELL_PAGES * ACTIVE_PAGE
    
    for i=from,to do
    
        local skillType, spellId =GetSpellBookItemInfo(i,'spell')

        if  spellId~=nil  then
            local name, rank, icon, castingTime, minRange, maxRange, spellID =  GetSpellInfo(spellId) 

            _G['GwSpellbookButton'..i].icon:SetTexture(icon)
            _G['GwSpellbookButton'..i].title:SetText(name)
            _G['GwSpellbookButton'..i].sub:SetText(rank)
            
            local height =  _G['GwSpellbookButton'..i].title:GetStringHeight() 
            _G['GwSpellbookButton'..i].title:SetHeight(height)
        end
      
        
    end
    
end



function gw_register_spellbook_window()
    
    CreateFrame('Frame','GwSpellbook',GwCharacterWindow,'GwSpellbook')
    CreateFrame('Frame','GwSpellbookMenu',GwSpellbook,'GwCharacterMenu')
    
    
     hooksecurefunc('ToggleSpellBook',gwToggleSpellbook)
       
    local x = 0
    local y = 0
    for i=1,21 do
       local f = CreateFrame('Frame', 'GwSpellbookButton'..i,GwSpellbook, 'GwSpellbookButton' ) 
        f:SetPoint('TOPLEFT',GwSpellbook,'TOPLEFT',10 + (x*200), -10 + (y * -70) )
        
        x=x+1
        if x>2 then
            y =y+1
            x = 0
        end
        
    end
    
    GwSpellbook:SetScript('OnShow',updateSpellbook)
  --  updateSpellbook()    
    
end

function gwToggleSpellbook(bookType)
   gwCharacterPanelToggle(nil) 
    GwSpellbook:Show()
end