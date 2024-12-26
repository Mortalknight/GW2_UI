local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local maxEntries = 25

local function getObjectiveBlock(self, index)
    if _G[self:GetName() .. "Objective" .. index] then
        return _G[self:GetName() .. "Objective" .. index]
    end
    local newBlock = GW.CreateObjectiveNormal(self:GetName() .. "Objective" .. index, self)
    newBlock:SetParent(self)
    newBlock.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)

    if index == 1 then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -25)
    else
        newBlock:SetPoint("TOPRIGHT", _G[self:GetName() .. "Objective" .. (index - 1)], "BOTTOMRIGHT", 0, 0)
    end

    return newBlock
end

local function createNewMainBlock(parent)
    if _G["GwPetTrackerBlock"] then
        return _G["GwPetTrackerBlock"]
    end

    local newBlock = GW.CreateTrackerObject("GwPetTrackerBlock", parent)
    newBlock:SetParent(parent)
    newBlock:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -20)
    newBlock.color = TRACKER_TYPE_COLOR.EVENT
    newBlock.Header:SetTextColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock.hover:SetVertexColor(newBlock.color.r, newBlock.color.g, newBlock.color.b)
    newBlock:Hide()

    return newBlock
end

local function AddSpecie(self, block, specie, quality, level)
    local source = specie:GetSourceIcon()
    if source then
        local name, icon = specie:GetInfo()
        local text = name .. (level > 0 and format(" (%s)", level) or "")
        local r,g,b = self:GetColor(quality):GetRGB()
        block.ObjectiveText:SetText("|T" .. icon ..":0:0:0:0:64:64:4:60:4:60|t |T" .. source ..":0:0:0:0:64:64:4:60:4:60|t " .. GW.RGBToHex(r, g, b) .. text .. "|r")
        block.StatusBar:Hide()
        block:SetHeight(20)
        block:Show()
        block:SetScript("OnMouseDown", function() specie:Display() end)
        block:SetScript("OnEnter", function()
            if not block:GetParent().hover:IsShown() then
                block:GetParent():GetScript("OnEnter")(block:GetParent())
            end
        end)
        block:SetScript("OnLeave", function()
            if not block:GetParent():IsMouseOver() then
                block:GetParent():GetScript("OnLeave")(block:GetParent())
            end
        end)

        return true
    end
    return false
end

local function setUpProgressbar(block, progress, counter)
    local progessbarObjective = getObjectiveBlock(block, counter)
    local petsOwned = 0

    progessbarObjective.notChangeSize = true
    progessbarObjective.ObjectiveText:SetText("")
    progessbarObjective.ObjectiveText:SetHeight(progessbarObjective.ObjectiveText:GetStringHeight() + 10)
    progessbarObjective.StatusBar.precentage = false
    progessbarObjective.StatusBar:Show()
    progessbarObjective.StatusBar.notHide = true
    progessbarObjective.StatusBar:SetMinMaxValues(0, progress.total)
    for i = PetTracker.MaxQuality, 1, -1 do
        petsOwned = petsOwned + progress[i].total
    end

    progessbarObjective.progress = petsOwned / progress.total
    progessbarObjective.StatusBar:SetValue(petsOwned)
    progessbarObjective.StatusBar.progress:Show()
    progessbarObjective:Show()

    local h = progessbarObjective.ObjectiveText:GetStringHeight() + progessbarObjective.StatusBar:GetHeight() + 10
    progessbarObjective:SetHeight(h)

    progessbarObjective:SetScript("OnEnter", function()
        if not progessbarObjective:GetParent().hover:IsShown() then
            progessbarObjective:GetParent():GetScript("OnEnter")(progessbarObjective:GetParent())
        end
    end)
    progessbarObjective:SetScript("OnLeave", function()
        if not progessbarObjective:GetParent():IsMouseOver() then
            progessbarObjective:GetParent():GetScript("OnLeave")(progessbarObjective:GetParent())
        end
    end)

    return h
end

local function petTrackerUpdate()
    local progress = PetTracker.Maps:GetCurrentProgress()
    local foundPet = false
    local height, counter = 1, 1
    local petBlock = createNewMainBlock(GwQuesttrackerContainerPetTracker)
    petBlock.Header:SetText(PET)

    -- hide always all objectives
    for i = 1, 25 do
        if petBlock and _G["GwPetTrackerBlockObjective" .. i] then
            _G["GwPetTrackerBlockObjective" .. i]:Hide()
        end
    end

    if PetTracker.sets.zoneTracker then
        -- setup the progessbar
        height = height + setUpProgressbar(petBlock, progress, counter)
        counter = counter + 1
        for quality = 0, PetTracker.Tracker:MaxQuality() do
            for level = 0, PetTracker.MaxLevel do
                for _, specie in ipairs(progress[quality][level] or {}) do
                    if counter <= maxEntries then
                        local petObjectives = getObjectiveBlock(petBlock, counter)
                        if AddSpecie(PetTracker.Tracker, petObjectives, specie, quality, level) then
                            foundPet = true
                            height = height + 20
                            counter = counter + 1
                        end
                    else
                        break
                    end
                end
            end
        end
    end

    if foundPet then
        petBlock:Show()
        petBlock:SetHeight(height + 30)
    elseif petBlock then
        petBlock:Hide()
    end

    if GwQuesttrackerContainerPetTracker.collapsed and foundPet then
        if petBlock and petBlock:IsShown() then
            petBlock:Hide()
        end
    end

    GwQuesttrackerContainerPetTracker.header:SetShown(foundPet)
    GwQuesttrackerContainerPetTracker:SetHeight(height + 30)
    GW.QuestTrackerLayoutChanged()
end

local function CollapseHeader(self, forceCollapse, forceOpen)
    if (not self.collapsed or forceCollapse) and not forceOpen then
        self.collapsed = true
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    else
        self.collapsed = false
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
    petTrackerUpdate()
end
GW.CollapsePetTrackerAddonHeader = CollapseHeader

local function LoadPetTrackerAddonSkin()
    if not GW.settings.SKIN_PETTRACKER_ENABLED or not PetTracker then return end

    local petTrackerLocals = LibStub("AceLocale-3.0"):GetLocale("PetTracker")
    local petTrackerObjectives = CreateFrame("Frame", "GwQuesttrackerContainerPetTracker", GwQuestTrackerScrollChild, "GwQuesttrackerContainer")
    petTrackerObjectives:SetParent(GwQuestTrackerScrollChild)
    petTrackerObjectives:SetPoint("TOPRIGHT", GwQuesttrackerContainerWQT and GwQuesttrackerContainerWQT or GwQuesttrackerContainerCollection, "BOTTOMRIGHT")

    petTrackerObjectives.header = CreateFrame("Button", nil, petTrackerObjectives, "GwQuestTrackerHeader")
    petTrackerObjectives.header.icon:SetTexCoord(0, 0.5, 0.5, 0.75)
    petTrackerObjectives.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    petTrackerObjectives.header.title:SetShadowOffset(1, -1)
    petTrackerObjectives.header.title:SetText("Pet Tracker")
    petTrackerObjectives.header.title:SetTextColor(TRACKER_TYPE_COLOR.EVENT.r, TRACKER_TYPE_COLOR.EVENT.g, TRACKER_TYPE_COLOR.EVENT.b)

    petTrackerObjectives.collapsed = false
    petTrackerObjectives.header:SetScript("OnMouseDown",
        function(self, button)
            if button == "RightButton" then
                if not self.collapsed then

                    MenuUtil.CreateContextMenu(self, function(ownerRegion, drop)
                        drop:CreateTitle('|TInterface/Addons/PetTracker/art/compass:16:16|t PetTracker')
                        drop:CreateCheckbox(petTrackerLocals.ZoneTracker, PetTracker.GetOption, PetTracker.ToggleOption, 'zoneTracker')
                        drop:CreateCheckbox(petTrackerLocals.CapturedPets, PetTracker.GetOption, PetTracker.ToggleOption, 'capturedPets')

                        local get = function(v) return PetTracker.sets.targetQuality == v end
                        local set = function(v) PetTracker.SetOption('targetQuality', v) end

                        local target = drop:CreateButton(petTrackerLocals.DisplayCondition)
                        target:CreateRadio(ALWAYS, get, set, PetTracker.MaxQuality)
                        target:CreateRadio(petTrackerLocals.MissingRares, get, set, PetTracker.MaxPlayerQuality)
                        target:CreateRadio(petTrackerLocals.MissingPets, get, set, 1)
                    end)
                end
            else
                CollapseHeader(self:GetParent(), false, false)
            end
        end
    )

    hooksecurefunc(PetTracker.Tracker, "Update", petTrackerUpdate)
    petTrackerUpdate()
end
GW.LoadPetTrackerAddonSkin = LoadPetTrackerAddonSkin