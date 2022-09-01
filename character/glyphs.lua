local _, GW = ...

CHACHED_CLASSGLYPHS = {}

local function glyphItem_onEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetItemByID(self.itemID)
end

local function GlyphFrameGlyph_UpdateSlot_Hook(self)
    -- make sure we are not using blizzard frames
    local id = self:GetID()
    local frame = _G["GwGlyphesContainerGlyph" .. id]

	local enabled, _, glyphSpell, iconFilename = GetGlyphSocketInfo(id, GetActiveTalentGroup())

	if ( not enabled ) then
		--Locked glyph slot
        frame.GwUnlocked:Hide()
        frame.GwEquiped:Hide()
        frame.GwGlyph:Hide()
	elseif ( not glyphSpell ) then
	    -- No equiped glyph in slot
        frame.GwUnlocked:Show()
        frame.GwEquiped:Hide()
        frame.GwGlyph:Hide()
	else
	    -- equiped slot
        frame.GwUnlocked:Show()
        frame.GwEquiped:Show()
        frame.GwGlyph:Show()

        frame.GwGlyph:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\glyphs\\" .. (iconFilename and iconFilename or "237636")) -- as fallback: sometimes we do not have an id
	end
end

local function loadGlyphSlot(self)
    local _, glyphType = GetGlyphSocketInfo(self:GetID(), GetActiveTalentGroup())

    if glyphType == GLYPHTYPE_MINOR then
        GlyphFrameGlyph_SetGlyphType(self, GLYPHTYPE_MINOR)
        self.GwBackground:SetSize(100,100)
        self.GwUnlocked:SetSize(100,100)
        self.GwEquiped:SetSize(100,100)
        self.GwGlyph:SetSize(71,71)
        self.selectable:SetSize(120,120)
    else
        GlyphFrameGlyph_SetGlyphType(self, GLYPHTYPE_MAJOR);
    end
end

local function overrideBlizzardStyle(self)
    self.setting:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\glyphbgmajor")
    self.setting:SetTexCoord(0, 1, 0, 1)
    self.background:Hide()
    self.shine:Hide()
    self.ring:Hide()
    self.setting:Hide()
    self.glyph:Hide()
end

-- Chache all glyph data from players inventory
-- Should only be run when window is open and player inventory changes or when the player opens the window outside of combat
local function getClassGlyphsInBag()
    local classGlyphs = GW.GlyphData[GW.myclass].glyphs

    local index = 0
    local found
    wipe(CHACHED_CLASSGLYPHS)
    for itemID, _glyphType in pairs(classGlyphs) do
        found = false
        CHACHED_CLASSGLYPHS[index] = {itemID = itemID, inBag = false, glyphType = _glyphType}
        for i = 0, NUM_BAG_SLOTS do
            for z = 1, GetContainerNumSlots(i) do
                if GetContainerItemID(i, z) == itemID then
                    CHACHED_CLASSGLYPHS[index].inBag = true
                    found = true
                    break
                end
            end
            if found then break end
        end

        index = index + 1
    end
    table.sort(CHACHED_CLASSGLYPHS, function(a, b)
        if a.inBag and not b.inBag then
            return true
        elseif not a.inBag and b.inBag then
            return false
        end
        return a.glyphType > b.glyphType
    end)
end

local function setGlyphButtonState(self, active)
    if active then
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
    self.subHeader:SetText(glyphData.glyphType == 1 and MAJOR_GLYPH  or MINOR_GLYPH)

    --hook tooltip
    self:SetScript("OnEnter", glyphItem_onEnter)
    self:SetScript("OnLeave", GameTooltip_Hide)

    -- if glyph is in players bag set it as a usable item
    -- glyphData.inBag
    setGlyphButtonState(self, glyphData.inBag)
    if glyphData.inBag then
        self:SetAttribute("macrotext", "/use item:" .. glyphData.itemID)
    else
        self:SetAttribute("macrotext", nil)
    end
end

local function updateGlyphListFrame(self)
    if InCombatLockdown() then return end
    local offset = HybridScrollFrame_GetOffset(self)
    local classGlyphsCount = #CHACHED_CLASSGLYPHS
    local zebra
    local slot

    for i = 1, #self.buttons do
        slot = self.buttons[i]
        local idx = i + offset

        if idx > classGlyphsCount then
            slot:Hide()
        else
            setGlyphButton(slot, CHACHED_CLASSGLYPHS[idx])

            zebra = idx % 2
            slot.zebra:SetVertexColor(zebra, zebra, zebra, 0.05)
        end
    end

    local HEIGHT = 44  * classGlyphsCount

    HybridScrollFrame_Update(self, HEIGHT, 600)
end

local function loadGlyphList(self)
    HybridScrollFrame_CreateButtons(self, "GwGlyphItem", 0, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")

    for i = 1, #self.buttons do
        local slot = self.buttons[i]

        slot.title:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE")
        slot.title:SetTextColor(0.7, 0.7, 0.5, 1)
        slot.subHeader:SetFont(DAMAGE_TEXT_FONT, 13, "OUTLINE")
        slot.subHeader:SetTextColor(0.5, 0.5, 0.5, 1)

        slot:SetAttribute("type1", "macro")
        slot:SetAttribute("type2", "macro")

        slot.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
        slot:SetNormalTexture(nil)
        slot:SetText("")
    end
end

local function UpdateGlyphList()
    if InCombatLockdown() then
        GwGlyphesFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    getClassGlyphsInBag()
    updateGlyphListFrame(GwGlyphsList.GlyphScroll)
end

local function GlyphFrameOnUpdateTimer()
    for i = 1, 6 do
        local enabled = GetGlyphSocketInfo(i, GetActiveTalentGroup());

        if enabled and GlyphMatchesSocket(i) then
            _G["GwGlyphesContainerGlyph" .. i].selectable:Show()
            GW.FrameFlash(_G["GwGlyphesContainerGlyph" .. i].selectable, 1, 0.4, 1, true)
            GW.FrameFlash(_G["GwGlyphesContainerGlyph" .. i].GwUnlocked, 1, 0.4, 1, true)
            GW.FrameFlash(_G["GwGlyphesContainerGlyph" .. i].GwEquiped, 1, 0.4, 1, true) 
        else
            _G["GwGlyphesContainerGlyph" .. i].selectable:Hide()
            GW.StopFlash(_G["GwGlyphesContainerGlyph" .. i].selectable)
            GW.StopFlash(_G["GwGlyphesContainerGlyph" .. i].GwUnlocked)
            GW.StopFlash(_G["GwGlyphesContainerGlyph" .. i].GwEquiped)
        end
    end
end

local function GlyphFrameOnEvent(self, event, ...)
    if event == "ACTIVE_TALENT_GROUP_CHANGED" then
        for i = 1, 6 do
            loadGlyphSlot(_G["GwGlyphesContainerGlyph" .. i])
        end
        UpdateGlyphList()
       print(event)
    elseif event == "USE_GLYPH" then
        if InCombatLockdown() then return end
        GwCharacterWindow:SetAttribute('windowPanelOpen', "glyphes")
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent(event)
        UpdateGlyphList()
    elseif event == "BAG_UPDATE" then
        local bagId = ...
        if bagId >= 0 and self:IsVisible() then
            UpdateGlyphList()
        end
    elseif event == "PLAYER_LEVEL_UP" then
        if self:IsVisible() then
            UpdateGlyphList()
        end
    elseif event == "GLYPH_ADDED" or event == "GLYPH_REMOVED" or event == "GLYPH_UPDATED" then
        if self:IsVisible() then
            local index = ...
            local glyph = _G["GwGlyphesContainerGlyph" .. index]
            local glyphBlizz = _G["GlyphFrameGlyph" .. index]
            local glyphType = glyph.glyphType

		    if glyphBlizz then
			    -- update the glyph blizz one to trigger hooks, on default it is only trigger if the frame is visible
			    GlyphFrameGlyph_UpdateSlot(glyphBlizz)
            end

            if event == "GLYPH_ADDED" or event == "GLYPH_UPDATED" then
				if glyphType == GLYPHTYPE_MINOR then
					PlaySound(SOUNDKIT.GLYPH_MINOR_CREATE);
				elseif ( glyphType == GLYPHTYPE_MAJOR ) then
					PlaySound(SOUNDKIT.GLYPH_MAJOR_CREATE);
				end
			elseif event == "GLYPH_REMOVED" then
				if glyphType == GLYPHTYPE_MINOR then
					PlaySound(SOUNDKIT.GLYPH_MINOR_DESTROY)
				elseif glyphType == GLYPHTYPE_MAJOR then
					PlaySound(SOUNDKIT.GLYPH_MAJOR_DESTROY)
				end
			end

            UpdateGlyphList()

            --Refresh tooltip!
            if GameTooltip:IsOwned(glyph) then
                GlyphFrameGlyph_OnEnter(glyph)
            end
        end
    end
end

local function GlyphFrameGlyph_OnEnter(self) -- copy from blizzard with littel tweaks
	self.hasCursor = true

	local glyphSpellID = self.spell
	local glyphName = GetSpellInfo(glyphSpellID)

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetGlyph(self:GetID(), GetActiveTalentGroup())

	EventRegistry:TriggerEvent("GlyphFrameGlyph.MouseOver", self, glyphName, glyphSpellID)
	GameTooltip:Show();
end

local function LoadGlyphes()
    TalentFrame_LoadUI()
    GlyphFrame_LoadUI()

    local glyphesFrame = CreateFrame("Frame", "GwGlyphesFrame", GwCharacterWindow, "GwGlyphesFrame")

    GwGlyphsList.GlyphScroll.update = updateGlyphListFrame
    GwGlyphsList.GlyphScroll.scrollBar.doNotHide = true

    hooksecurefunc("GlyphFrameGlyph_UpdateSlot", overrideBlizzardStyle)
    hooksecurefunc("GlyphFrameGlyph_UpdateSlot", GlyphFrameGlyph_UpdateSlot_Hook)

    for i = 1, 6 do
        loadGlyphSlot(_G["GwGlyphesContainerGlyph" .. i])
        _G["GwGlyphesContainerGlyph" .. i]:SetScript("OnClick", function()
            PlaceGlyphInSocket(_G["GwGlyphesContainerGlyph" .. i]:GetID())
        end)
        _G["GwGlyphesContainerGlyph" .. i]:SetScript("OnEnter", GlyphFrameGlyph_OnEnter)
    end

    loadGlyphList(GwGlyphsList.GlyphScroll)

    getClassGlyphsInBag() -- should only update on inventory item added

    updateGlyphListFrame(GwGlyphsList.GlyphScroll)

    -- remove default GlyphHandling
    UIParent:UnregisterEvent("USE_GLYPH")

    -- add event handling
    glyphesFrame:RegisterEvent("USE_GLYPH")
    glyphesFrame:RegisterEvent("PLAYER_LEVEL_UP")
    glyphesFrame:RegisterEvent("GLYPH_ADDED")
    glyphesFrame:RegisterEvent("GLYPH_REMOVED")
    glyphesFrame:RegisterEvent("GLYPH_UPDATED")
    glyphesFrame:RegisterEvent("BAG_UPDATE")
    glyphesFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    glyphesFrame:SetScript("OnEvent", GlyphFrameOnEvent)

    GwGlyphsList:SetScript("OnShow", function()
        GwGlyphsList.OnUpdateTimer = C_Timer.NewTicker(0.2, GlyphFrameOnUpdateTimer)
        UpdateGlyphList()
    end)
    GwGlyphsList:SetScript("OnHide", function()
        GwGlyphsList.OnUpdateTimer:Cancel()
        GwGlyphsList.OnUpdateTimer= nil
        UpdateGlyphList()
    end)

    return glyphesFrame
end
GW.LoadGlyphes = LoadGlyphes
