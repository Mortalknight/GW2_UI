local _, GW = ...

--[[
 TODO
Drag and drop (any secure way of handling drag and drop?)
Summon button (any secure way of handling summon buttons spell attribute?)
]]

-- Number of mount tabs. if changed setUpPaging needs to include the added tabs aswell as the GwMountsFrame template
local NUM_MOUNT_TABS = 4
local NUM_MOUNTS_PER_TAB = 12

local firstLoad = false

local function setUpPaging(self)
    self.left:SetFrameRef('tab', self.attrDummy)
    self.left:SetAttribute("_onclick", [=[
        self:GetFrameRef('tab'):SetAttribute('page', 'left')
    ]=])

    self.right:SetFrameRef('tab', self.attrDummy)
    self.right:SetAttribute("_onclick", [=[
        self:GetFrameRef('tab'):SetAttribute('page', 'right')
    ]=])

    self.attrDummy:SetFrameRef('container1', self.container1)
    self.attrDummy:SetFrameRef('container2', self.container2)
    self.attrDummy:SetFrameRef('container3', self.container3)
    self.attrDummy:SetFrameRef('container4', self.container4)
    self.attrDummy:SetFrameRef('left', self.left)
    self.attrDummy:SetFrameRef('right', self.right)
    self.attrDummy:SetAttribute('_onattributechanged', ([=[
        if name ~= 'page' then return end

        local p1 = self:GetFrameRef('container1')
        local p2 = self:GetFrameRef('container2')
        local p3 = self:GetFrameRef('container3')
        local p4 = self:GetFrameRef('container4')
        local left = self:GetFrameRef('left')
        local right = self:GetFrameRef('right')
        local numPages = %s
        local currentPage = 1

        if value == "left" then
            if p4:IsVisible() then
                p4:Hide()
                p3:Show()
                currentPage = 3
            elseif p3:IsVisible() then
                p3:Hide()
                p2:Show()
                currentPage = 2
            elseif p2:IsVisible() then
                p2:Hide()
                p1:Show()
                currentPage = 1
            end
        end
        if value == "right" then
            if p1:IsVisible()  then
                p1:Hide()
                p2:Show()
                currentPage = 2
            elseif p2:IsVisible() then
                p2:Hide()
                p3:Show()
                currentPage = 3
            elseif p3:IsVisible() then
                p3:Hide()
                p4:Show()
                currentPage = 4
            end
        end

        if currentPage >= numPages then
            right:Hide()
        else
            right:Show()
        end
        if currentPage == 1 then
            left:Hide()
        else
            left:Show()
        end
    ]=]):format(self.tabs))
    self.attrDummy:SetAttribute('page', 'left')
end

local function onClick_menuButton(self)
  self.baseFrame.model:SetCreature(self.creatureID)
  self.baseFrame.title:SetText(self.creatureName)
  self.baseFrame.summon:SetAttribute("type1", "spell")
  self.baseFrame.summon:SetAttribute("type2", "spell")
  self.baseFrame.summon:SetAttribute("spell",self.spellID)

  if ( self.active and self.creatureID ) then
			self.baseFrame.summon:SetText(self.petType == "MOUNT" and BINDING_NAME_DISMOUNT or PET_DISMISS);
		else
			self.baseFrame.summon:SetText(self.petType == "MOUNT" and MOUNT or SUMMON);
      print(self.petType == "MOUNT" and MOUNT or SUMMON)
		end
end


-- reusable for both mount and companions
local function updatePetList(self, petType) -- MOUNT / CRITTER

  --NYI Combat lockdown should not update the list, use event PLAYER_REGEN_ENABLED

  local btnIndex = 0
  local tabIndex = 1

  self.tabs = 1

  for i=1,GetNumCompanions(petType) do


    local creatureID, creatureName, spellID, icon, active = GetCompanionInfo(petType, i);

    local btn =_G[GwMountsList:GetName().."container"..tabIndex..'Actionbutton' .. btnIndex]

    btn.icon:SetTexture(icon)
    btn.title:SetText(creatureName)
    btn.creatureName = creatureName
    btn.creatureID = creatureID
    btn.mountID = i
    btn.spellID = spellID
    btn.active = active

  -- For menu items, if we want them to be clickable action buttons
  --  btn:SetAttribute("ispickable", true)
  --  btn:SetAttribute("type1", "spell")
  --  btn:SetAttribute("type2", "spell")
  --  btn:SetAttribute("spell", spellID)
    btn:Show()


    -- populate the info panel with the first mount
    if not firstLoad and i==1 then
      firstLoad = true
      onClick_menuButton(btn)
    end

    -- Handle pagnition
    btnIndex = btnIndex + 1
    if btnIndex >= NUM_MOUNTS_PER_TAB then
      btnIndex = 0
      tabIndex = tabIndex + 1
      self.tabs = tabIndex
    end
  end

  setUpPaging(self)

end

-- TEST FUNCTION will be rewritten to work for both mounts and "critters"
local function LoadMounts()
    local mountsFrame = CreateFrame("Frame", "GwMountsFrame", GwCharacterWindow, "GwMountsFrame")
    CreateFrame('Frame', 'GwMountsList', GwMountsFrame, 'GwMountsList')

    --Create summon button and set frame level above the model frame
    local summonButton = CreateFrame("Button","GwMountSummonButton".."MOUNT",GwMountsFrame, "GwMountSummonButton" )
    summonButton:SetFrameLevel(mountsFrame.model:GetFrameLevel()+1)
    summonButton:RegisterForClicks("AnyUp")
    mountsFrame.summon = summonButton

    GwMountsFrame.title:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    GwMountsFrame.title:SetTextColor(0.87, 0.74, 0.29, 1)

    GwMountsList.pages:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    GwMountsList.pages:SetTextColor(0.7, 0.7, 0.5, 1)

    --loop tabs and create mount buttons
    for tab=1,NUM_MOUNT_TABS do

      local YPadding = 0
      for i=0,NUM_MOUNTS_PER_TAB do

        local btn = CreateFrame('Button', GwMountsList:GetName().."container"..tab..'Actionbutton' .. i, _G[GwMountsList:GetName().."container"..tab], 'GwMountsListItem')

        btn.baseFrame = GwMountsFrame
        btn.petType = "MOUNT"
        btn:SetPoint('TOPLEFT', GwMountsList, 'TOPLEFT', 0,YPadding)
        btn:RegisterForClicks("AnyUp")
        btn:RegisterForDrag("LeftButton")
        btn:HookScript("OnClick",onClick_menuButton)
        btn:Hide()

        local zebra = tab % 2
        btn.title:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE")
        btn.title:SetTextColor(0.7, 0.7, 0.5, 1)
        btn.bg:SetVertexColor(1, 1, 1, zebra)
        btn.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
        btn:SetNormalTexture(nil)
        btn:SetText("")

        YPadding = -44 * (i+1)
      end
      YPadding = 0
    end

    updatePetList(GwMountsList,"MOUNT")

    return mountsFrame
end
GW.LoadMounts = LoadMounts

--[[
Required events

COMPANION_LEARNED
COMPANION_UNLEARNED
COMPANION_UPDATE

Only needed if we want to display global cooldown in mount list
SPELL_UPDATE_COOLDOWN

]]
