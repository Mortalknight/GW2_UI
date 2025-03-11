local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local maxEntries = 30

local function AddSpecie(block, specie, quality, level)
    local source = specie:GetSourceIcon()
    if source then
        local name, icon = specie:GetInfo()
        local text = name .. (level > 0 and format(" (%s)", level) or "")
        local r,g,b = PetTracker.Tracker:GetColor(quality):GetRGB()
        block.ObjectiveText:SetText("|T" .. icon ..":0:0:0:0:64:64:4:60:4:60|t |T" .. source ..":0:0:0:0:64:64:4:60:4:60|t " .. GW.RGBToHex(r, g, b) .. text .. "|r")
        block.StatusBar:Hide()
        block:SetHeight(20)
        block.notChangeSize = true
        block:Show()
        block:SetScript("OnMouseDown",function() specie:Display() end)
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

local function setUpProgressbar(block, progress)
    local progessbarObjective = block:GetParent().objectivesPool:Acquire()
    local petsOwned = 0
    local h

    progessbarObjective:SetPoint("TOPRIGHT", block, "TOPRIGHT", 0, -5)

    progessbarObjective.notChangeSize = true
    progessbarObjective.ObjectiveText:SetText("")
    progessbarObjective.ObjectiveText:SetHeight(10)
    progessbarObjective.StatusBar.precentage = false
    progessbarObjective.StatusBar:Show()
    progessbarObjective.StatusBar.notHide = true
    progessbarObjective.StatusBar:SetMinMaxValues(0, progress.total)
    progessbarObjective.StatusBar:SetStatusBarColor(block.color.r, block.color.g, block.color.b)
    for i = PetTracker.MaxQuality, 1, -1 do
        petsOwned = petsOwned + progress[i].total
    end

    progessbarObjective.progress = petsOwned / progress.total
    progessbarObjective.StatusBar:SetValue(petsOwned)
    progessbarObjective.StatusBar.progress:Show()

    if progress.total > 0 then
        progessbarObjective:Show()
        h = 10 + progessbarObjective.StatusBar:GetHeight() + 10
    else
        progessbarObjective:Hide()
        h = 0
    end
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

    return h, progessbarObjective
end

local function petTrackerUpdate()
    local self = GwQuesttrackerContainerPetTracker
    local progress = PetTracker.Maps:GetCurrentProgress()
    local prevBlock = nil

    -- hide always all objectives
    self.objectivesPool:ReleaseAll()

    if PetTracker.sets.zoneTracker and progress.total > 0 then
        if self.collapsed then
            self:SetHeight(20) -- for header

            self.mainBlock:Hide()
        else
            local height, counter = 1, 1
            local statusBarHeight = 0
            local maxQuality = PetTracker.Tracker:MaxQuality()

            statusBarHeight, prevBlock = setUpProgressbar(self.mainBlock, progress) -- setup the progessbar
            height = height + statusBarHeight

            counter = counter + 1
            for quality = 0, maxQuality do
                for level = 0, PetTracker.MaxLevel do
                    for _, specie in ipairs(progress[quality][level] or {}) do
                        if counter <= maxEntries then
                            local petObjectives = self.objectivesPool:Acquire()
                            if AddSpecie(petObjectives, specie, quality, level) then
                                petObjectives:SetPoint("TOPRIGHT", prevBlock, "BOTTOMRIGHT", 0, (counter == 2 and 10 or 0))
                                height = height + petObjectives:GetHeight()
                                counter = counter + 1
                                prevBlock = petObjectives
                            else
                                petObjectives:Release()
                            end
                        else
                            break
                        end
                    end
                end
            end

            self.mainBlock:SetHeight(height)
            height = height + 20 -- for header

            self:SetHeight(height)

            self.mainBlock:Show()
        end

        self.header:Show()
        self:SetShown(true)
    else
        self:SetHeight(0.0001)
        self:Hide()

        self.mainBlock:Hide()
    end

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

    petTrackerObjectives.blockPool = CreateFramePool("Frame", petTrackerObjectives, "GwObjectivesBlockTemplate")

    petTrackerObjectives.mainBlock = petTrackerObjectives.blockPool:Acquire()
    petTrackerObjectives.mainBlock:SetParent(petTrackerObjectives)
    petTrackerObjectives.mainBlock:SetPoint("TOPRIGHT", petTrackerObjectives, "TOPRIGHT", 0, -20)
    petTrackerObjectives.mainBlock.color = TRACKER_TYPE_COLOR.EVENT
    petTrackerObjectives.mainBlock.Header:SetTextColor(petTrackerObjectives.mainBlock.color.r, petTrackerObjectives.mainBlock.color.g, petTrackerObjectives.mainBlock.color.b)
    petTrackerObjectives.mainBlock.hover:SetVertexColor(petTrackerObjectives.mainBlock.color.r, petTrackerObjectives.mainBlock.color.g, petTrackerObjectives.mainBlock.color.b)
    petTrackerObjectives.mainBlock:Hide()
    petTrackerObjectives.mainBlock.Header:SetHeight(0.00001)
    petTrackerObjectives.mainBlock.Header:Hide()
    petTrackerObjectives.mainBlock.animationName = "PetTrackerOnEnterOnLeave"

    petTrackerObjectives.objectivesPool = CreateFramePool("Frame", petTrackerObjectives.mainBlock, "GwQuesttrackerObjectiveTemplate")

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

    petTrackerObjectives:SetScript("OnEvent", petTrackerUpdate)
    petTrackerObjectives:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	EventRegistry:RegisterCallback("PetTracker.COLLECTION_CHANGED", petTrackerUpdate)
	EventRegistry:RegisterCallback("PetTracker.OPTIONS_CHANGED", petTrackerUpdate)

    petTrackerUpdate()
end
GW.LoadPetTrackerAddonSkin = LoadPetTrackerAddonSkin
