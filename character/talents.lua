local _, GW = ...
local CharacterMenuButton_OnLoad = GW.CharacterMenuButton_OnLoad

local function SetupMenuTreeButtonText(self, text)
    self:SetText(text)
end

local function UpdateMenu(menu)
    local classInfo = C_CreatureInfo.GetClassInfo(GW.myClassID)
	local specName = select(2, GetSpecializationInfoByID(PlayerUtil.GetCurrentSpecID()))

    SetupMenuTreeButtonText(menu.tree1, classInfo and classInfo.className or UNKNOWN)
    SetupMenuTreeButtonText(menu.tree2, specName)
end

local function SetupTreeContainer(fmTalents, index)
    local container = CreateFrame("Frame", "TreeContainer" .. index, fmTalents, "GwTalentskContainerTab")

    container.test:SetText("Tree " .. index)

    return container
end

local function fmTalentsOnEvent(self, event, ...)
    UpdateMenu(self)
end

local function LoadTalents(tabContainer)

    local talentContainer = CreateFrame("Frame", "GwTalentFrame", tabContainer, "SecureHandlerStateTemplate, GwTalentsWindow")
    local fmTalents = CreateFrame("Frame", "GwTalentsMenu", talentContainer, "GwTalentsMenu")
    GwCharacterWindow:SetFrameRef("GwTalentsMenu", fmTalents)

    fmTalents.tabContainers = {}
    fmTalents:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    fmTalents:SetScript("OnEvent", fmTalentsOnEvent)

    fmTalents.tabContainers[1] = SetupTreeContainer(fmTalents, 1)
    fmTalents.tabContainers[2] = SetupTreeContainer(fmTalents, 2)

    fmTalents.tabContainers[1]:Show()

    fmTalents.tree1:RegisterForClicks("AnyUp")
    fmTalents.tree1:SetFrameRef("GwTalentsMenu", fmTalents)
    fmTalents.tree1:SetAttribute(
        "_onclick",
        [=[
            self:GetFrameRef('GwTalentsMenu'):SetAttribute('tabopen',1)
        ]=]
    )
    fmTalents.tree2:RegisterForClicks("AnyUp")
    fmTalents.tree2:SetFrameRef("GwTalentsMenu", fmTalents)
    fmTalents.tree2:SetAttribute(
        "_onclick",
        [=[
            self:GetFrameRef('GwTalentsMenu'):SetAttribute('tabopen',2)
        ]=]
    )

    fmTalents:SetFrameRef("GwTalentsTree1Container", fmTalents.tabContainers[1])
    fmTalents:SetFrameRef("GwTalentsTree2Container", fmTalents.tabContainers[2])

    fmTalents:SetAttribute(
        "_onattributechanged",
        [=[
            if name ~= 'tabopen' then return end

            self:GetFrameRef('GwTalentsTree1Container'):Hide()
            self:GetFrameRef('GwTalentsTree2Container'):Hide()
        
            if value == 1 then
                self:GetFrameRef('GwTalentsTree1Container'):Show()
                return
            elseif value == 2 then
                self:GetFrameRef('GwTalentsTree2Container'):Show()
                return
            end
        ]=]
    )
    fmTalents:SetAttribute("tabOpen", 1)

    talentContainer:HookScript(
        "OnShow",
        function()
            if InCombatLockdown() then
                return
            end
            --update here
        end
    )

    UpdateMenu(fmTalents)

    CharacterMenuButton_OnLoad(fmTalents.tree1, true)
    CharacterMenuButton_OnLoad(fmTalents.tree2, false)

    return talentContainer
end
GW.LoadTalents = LoadTalents