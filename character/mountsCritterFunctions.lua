local _, GW = ...

local function SetUpMoutCritterPaging(self)
    self.attrDummy:SetAttribute("maxNumberOfContainers", self.maxNumberOfContainers)
    self.attrDummy:SetAttribute("neededContainers", self.neededContainers)

    self.left:SetFrameRef('tab', self.attrDummy)
    self.left:SetAttribute("_onclick", [=[
        self:GetFrameRef('tab'):SetAttribute('page', 'left')
    ]=])

    self.right:SetFrameRef('tab', self.attrDummy)
    self.right:SetAttribute("_onclick", [=[
        self:GetFrameRef('tab'):SetAttribute('page', 'right')
    ]=])

    self.attrDummy:SetFrameRef('left', self.left)
    self.attrDummy:SetFrameRef('right', self.right)
    self.attrDummy:SetAttribute('_onattributechanged', ([=[
        if name ~= 'page' then return end

        local maxNumberOfContainers = self:GetAttribute("maxNumberOfContainers")
        local container
        local showNext = false
        local hadSomethingToShow = false

        local left = self:GetFrameRef("left")
        local right = self:GetFrameRef("right")

        local currentPage = 1
        local neededContainers = self:GetAttribute("neededContainers")

        if value == "left" then -- container -1
            for i = maxNumberOfContainers, 1, -1 do
                container = self:GetFrameRef("container" .. i)

                if container:IsVisible() then
                    container:Hide()
                    showNext = true
                else
                    if showNext then
                        container:Show()
                        showNext = false
                        hadSomethingToShow = true
                        currentPage = i
                    else
                        container:Hide()
                    end
                end

                if i == 1 and not hadSomethingToShow then
                    self:GetFrameRef("container" .. i):Show()
                    currentPage = i
                end
            end

        end
        if value == "right" then -- container +1
            for i = 1, maxNumberOfContainers do
                container = self:GetFrameRef("container" .. i)

                if container:IsVisible() then
                    container:Hide()
                    showNext = true
                else
                    if showNext then
                        container:Show()
                        showNext = false
                        currentPage = i
                    else
                        container:Hide()
                    end
                end
            end
        end

        if currentPage >= neededContainers then
            right:Hide()
        else
            right:Show()
        end
        if currentPage == 1 then
            left:Hide()
        else
            left:Show()
        end
    ]=]))
    self.attrDummy:SetAttribute('page', 'left')
end
GW.SetUpMoutCritterPaging = SetUpMoutCritterPaging

local function CreateMountsPetsContainersWithButtons(listFrame, baseFrame, maxNumberOfContainers, numMountsCritterPerTab, listItemTemplate, startTab)
    -- create dynamic container min 10 to have enough start space
    for i = 1, maxNumberOfContainers do
        local container = CreateFrame("Frame", listFrame:GetName() .. "Container" .. i, listFrame, "GWMountCritterListContainerTemplate")
        container:SetParent(listFrame)
        container:SetScript("OnShow", function()
            listFrame.pages:SetText(i)
        end)
        listFrame["container" .. i] = container
        listFrame.attrDummy:SetFrameRef("container" .. i, listFrame["container" .. i])

        if i == 1 then
            container:Show()
        end
    end

    --loop tabs and create mount buttons
    for tab = (startTab or 1), maxNumberOfContainers do
        local YPadding = 0
        for i = 0, numMountsCritterPerTab do

            local btn = CreateFrame('Button', listFrame:GetName() .. "Container"..tab..'Actionbutton' .. i, _G[listFrame:GetName() .. "Container"..tab], listItemTemplate)

            btn.baseFrame = baseFrame
            btn.baseList = listFrame
            btn.petType = "MOUNT"
            btn:SetPoint('TOPLEFT', listFrame, 'TOPLEFT', 0,YPadding)
            btn:RegisterForClicks("AnyUp")
            btn:RegisterForDrag("LeftButton")
            btn:HookScript("OnClick", GW.MountCrintterItemOnClick)
            btn:Hide()

            btn.title:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE")
            btn.title:SetTextColor(0.7, 0.7, 0.5, 1)
            btn.bg:SetVertexColor(1, 1, 1, 1)
            btn.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
            btn:SetNormalTexture(nil)
            btn:SetText("")

            YPadding = -44 * (i + 1)
        end
        YPadding = 0
    end
end
GW.CreateMountsPetsContainersWithButtons = CreateMountsPetsContainersWithButtons

local function MountCrintterItemOnClick(self)
    self.baseFrame.model:SetCreature(self.creatureID)
    self.baseFrame.title:SetText(self.creatureName)
    self.baseFrame.selectedButton = self

    if self.active and self.creatureID then
		self.baseFrame.summon:SetText(self.petType == "MOUNT" and BINDING_NAME_DISMOUNT or PET_DISMISS)
    else
        self.baseFrame.summon:SetText(self.petType == "MOUNT" and MOUNT or SUMMON)
    end
end
GW.MountCrintterItemOnClick = MountCrintterItemOnClick

local function UserMountCritter(self)
    local selectedButton = self:GetParent().selectedButton

    if selectedButton.active and selectedButton.creatureID then
        DismissCompanion(selectedButton.petType )
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

		self:SetText(selectedButton.petType  == "MOUNT" and MOUNT or SUMMON)
    else
        CallCompanion(selectedButton.petType, selectedButton.mountID)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)

        self:SetText(selectedButton.petType == "MOUNT" and BINDING_NAME_DISMOUNT or PET_DISMISS)
    end
end
GW.UserMountCritter = UserMountCritter

local function UpdateMountsCritterList(self, petType, numMountsCritterPerTab, firstLoad) -- MOUNT / CRITTER
    if InCombatLockdown() then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    local btnIndex = 0
    local tabIndex = 1
    local zebra

    for i = 1, GetNumCompanions(petType) do
        local creatureID, creatureName, spellID, icon, active = GetCompanionInfo(petType, i)

        local btn =_G[self:GetName() .. "Container" .. tabIndex .. 'Actionbutton' .. btnIndex]

        btn.icon:SetTexture(icon)
        btn.title:SetText(creatureName)
        btn.creatureName = creatureName
        btn.creatureID = creatureID
        btn.mountID = i
        btn.spellID = spellID
        btn.active = active

        zebra = btnIndex % 2
        if btn.active then
            btn.zebra:SetVertexColor(1, 1, 0.5, 0.15)
        else
            btn.zebra:SetVertexColor(zebra, zebra, zebra, 0.05)
        end

        btn:Show()

        -- populate the info panel with the first mount
        if firstLoad and i == 1 then
            MountCrintterItemOnClick (btn)
        end

        -- Handle pagnition
        btnIndex = btnIndex + 1
        if btnIndex >= numMountsCritterPerTab then
            btnIndex = 0
            tabIndex = tabIndex + 1
        end
    end
end
GW.UpdateMountsCritterList = UpdateMountsCritterList