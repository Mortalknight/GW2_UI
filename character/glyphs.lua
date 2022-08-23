local _, GW = ...
local Length = GW.Length;

local CHACHED_CLASSGLYPHS = {}

--[[
  TODO
  Disable default glyph frame when right clicking a glyph from inventory

  scroll frame needs to be disabled during InCombatLockdown

  glyph list should't update during combat but queue for when combat ends

  getClassGlyphsInBag is expensive and should only update when inventory AND the window is open. else queue up the list update for when the player opens the window








]]

local function glyphItem_onEnter(self)
  GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, 0)
  GameTooltip:ClearLines()
  GameTooltip:SetItemByID(self.itemID)
end

local function GlyphFrameGlyph_UpdateSlot_Hook(self)

  -- make sure we are not using blizzard frames
  if self.GwUnlocked==nil then return end
  local id = self:GetID();

	local enabled, glyphType, glyphSpell, iconFilename = GetGlyphSocketInfo(id, GetActiveTalentGroup());

	if ( not enabled ) then
		--Locked glyph slot
    self.GwUnlocked:Hide()
    self.GwEquiped:Hide()
    self.GwGlyph:Hide()
	elseif ( not glyphSpell ) then
	   -- No equiped glyph in slot
     self.GwUnlocked:Show()
     self.GwEquiped:Hide()
     self.GwGlyph:Hide()
	else
	   -- equiped slot
     self.GwUnlocked:Show()
     self.GwEquiped:Show()
     self.GwGlyph:Show()
	end
end

local function loadGlyphSlot(self)
  	local id = self:GetID();
  local enabled, glyphType, glyphSpell, iconFilename = GetGlyphSocketInfo(id, GetActiveTalentGroup());


  if ( glyphType == GLYPHTYPE_MINOR ) then
    GlyphFrameGlyph_SetGlyphType(self, GLYPHTYPE_MINOR);
    self.GwBackground:SetSize(100,100)
    self.GwUnlocked:SetSize(100,100)
    self.GwEquiped:SetSize(100,100)
    self.GwGlyph:SetSize(71,71)
  else
    GlyphFrameGlyph_SetGlyphType(self, GLYPHTYPE_MAJOR);
  end

end

local function overrideDefaultGlyphIcons(self, t)

  if t==nil then
    self:GetParent().GwGlyph:SetTexture(nil)
    return
  end
  self:GetParent().GwGlyph:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\glyphs\\"..t)
end

local function overrideBlizzardStyle(self)
  self.setting:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\glyphbgmajor");
  self.setting:SetTexCoord(0,1,0,1);
  self.background:Hide()
  self.shine:Hide()
  self.ring:Hide()
  self.setting:Hide()
  self.glyph:Hide()

end

-- Chache all glyph data from players inventory
-- Should only be run when window is open and player inventory changes or when the player opens the window outside of combat
local function getClassGlyphsInBag()
  local classGlyphs = GW.GlyphData[GW.myclass].glyphs;

  local index = 0
  for itemID,_glyphType in pairs(classGlyphs) do
    CHACHED_CLASSGLYPHS[index] ={itemID = itemID, inBag = 0, glyphType = _glyphType }
    for i = 0, NUM_BAG_SLOTS do
      for z = 1, GetContainerNumSlots(i) do
          if GetContainerItemID(i, z) == itemID then
            CHACHED_CLASSGLYPHS[index].inBag = 1
          end
      end
    end
  index = index + 1;
  end
  table.sort(CHACHED_CLASSGLYPHS,function(a,b)

      if a.inBag > b.inBag then
        return true
      end
      return a.glyphType > b.glyphType
  end)

end

local function setGlyphButtonState(self, active)

    if active==1 then
      self.title:SetTextColor(0.7, 0.7, 0.5, 1)
      self.subHeader:SetTextColor(0.5, 0.5, 0.5, 1)
      self.icon:SetDesaturated(false);
      return
    end
    self.title:SetTextColor(0.5, 0.5, 0.5, 1)
    self.subHeader:SetTextColor(0.3, 0.3, 0.3, 1)
    self.icon:SetDesaturated(true);
end
local function setGlyphButton(self, glyphData)

  local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(glyphData.itemID)

  self.itemID = glyphData.itemID

  self.icon:SetTexture(itemTexture)
  self.title:SetText(itemName)
  self.subHeader:SetText(glyphData.glyphType == 1 and MAJOR_GLYPH  or MINOR_GLYPH )

  --hook tooltip
    self:SetScript("OnEnter", glyphItem_onEnter)
    self:SetScript("OnLeave", GameTooltip_Hide)

  -- if glyph is in players bag set it as a usable item
 -- glyphData.inBag
  setGlyphButtonState(self,glyphData.inBag)
  if glyphData.inBag then
    self:SetAttribute("type1", "macro")
    self:SetAttribute("type2", "macro")
    self:SetAttribute("macrotext", "/use item:"..glyphData.itemID)
  else
  end
end

local function updateGlyphListFrame(self)
    local classGlyphsData = GW.GlyphData[GW.myclass];



    local offset = HybridScrollFrame_GetOffset(self)
    local classGlyphsCount = #CHACHED_CLASSGLYPHS
    local zebra
    local slot



    for i = 1, #self.buttons do
      slot = self.buttons[i]
      local idx = i + offset

      if idx > classGlyphsCount then
        slot:Hide();
      else


        setGlyphButton(slot,CHACHED_CLASSGLYPHS[idx])

        zebra = idx % 2
        if slot.active then
            slot.zebra:SetVertexColor(1, 1, 0.5, 0.15)
        else
            slot.zebra:SetVertexColor(zebra, zebra, zebra, 0.05)
        end
      end
    end

    local HEIGHT = 44  * classGlyphsCount

    HybridScrollFrame_Update(self,HEIGHT , 600)

end

local function loadGlyphList(self)

    HybridScrollFrame_CreateButtons(self, "GwGlyphItem", 0, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")

    for i = 1, #self.buttons do
      local slot = self.buttons[i]

      slot.title:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE")
      slot.title:SetTextColor(0.7, 0.7, 0.5, 1)
      slot.subHeader:SetFont(DAMAGE_TEXT_FONT, 13, "OUTLINE")
      slot.subHeader:SetTextColor(0.5, 0.5, 0.5, 1)


      slot.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
      slot:SetNormalTexture(nil)
      slot:SetText("")
    end

end


local function LoadGlyphes()
    TalentFrame_LoadUI()
    GlyphFrame_LoadUI()
    local glyphesFrame = CreateFrame("Frame", "GwGlyphesFrame", GwCharacterWindow, "GwGlyphesFrame")

    GwGlyphsList.GlyphScroll.update = updateGlyphListFrame
    GwGlyphsList.GlyphScroll.scrollBar.doNotHide = true

    hooksecurefunc("GlyphFrameGlyph_UpdateSlot", overrideBlizzardStyle)
    hooksecurefunc("GlyphFrameGlyph_UpdateSlot", GlyphFrameGlyph_UpdateSlot_Hook)

    for i = 1,6 do
      loadGlyphSlot(_G["GwGlyphesContainerGlyph"..i])
      hooksecurefunc(_G["GwGlyphesContainerGlyph"..i].glyph,"SetTexture",overrideDefaultGlyphIcons)

    end

    loadGlyphList(GwGlyphsList.GlyphScroll)

    getClassGlyphsInBag() -- should only update on inventory item added

    updateGlyphListFrame(GwGlyphsList.GlyphScroll)






    return glyphesFrame
end
GW.LoadGlyphes = LoadGlyphes
