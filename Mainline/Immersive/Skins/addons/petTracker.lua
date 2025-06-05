local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local maxEntries = 30

GwPetTrackerContainerMixin = {}
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

function GwPetTrackerContainerMixin:UpdateLayout()
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
                            elseif petObjectives then
                                self.objectivesPool:Release(petObjectives)
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

    GwQuestTracker:LayoutChanged()
end

function GwPetTrackerContainerMixin:InitModule()
    if not GW.settings.SKIN_PETTRACKER_ENABLED or not PetTracker then return end

    local petTrackerLocals = LibStub("AceLocale-3.0"):GetLocale("PetTracker")

    self.header = CreateFrame("Button", nil, self, "GwQuestTrackerHeader")
    self.header.icon:SetTexCoord(0, 0.5, 0.5, 0.75)
    self.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    self.header.title:SetShadowOffset(1, -1)
    self.header.title:SetText("Pet Tracker")
    self.header.title:SetTextColor(TRACKER_TYPE_COLOR.EVENT.r, TRACKER_TYPE_COLOR.EVENT.g, TRACKER_TYPE_COLOR.EVENT.b)

    self.blockPool = CreateFramePool("Frame", self, "GwObjectivesBlockTemplate")

    self.mainBlock = self.blockPool:Acquire()
    self.mainBlock:SetParent(self)
    self.mainBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -20)
    self.mainBlock.color = TRACKER_TYPE_COLOR.EVENT
    self.mainBlock.Header:SetTextColor(self.mainBlock.color.r, self.mainBlock.color.g, self.mainBlock.color.b)
    self.mainBlock.hover:SetVertexColor(self.mainBlock.color.r, self.mainBlock.color.g, self.mainBlock.color.b)
    self.mainBlock:Hide()
    self.mainBlock.Header:SetHeight(0.00001)
    self.mainBlock.Header:Hide()
    self.mainBlock.animationName = "PetTrackerOnEnterOnLeave"

    self.objectivesPool = CreateFramePool("Frame", self.mainBlock, "GwQuesttrackerObjectiveTemplate")

    self.collapsed = false
    self.header:SetScript("OnMouseDown",
        function(_, button)
            if button == "RightButton" then
                if not self.collapsed then
                    MenuUtil.CreateContextMenu(self.header, function(ownerRegion, drop)
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
                self:CollapseHeader(false, false)
            end
        end
    )

    self:SetScript("OnEvent", self.UpdateLayout)
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    EventRegistry:RegisterCallback("PetTracker.COLLECTION_CHANGED", function() self:UpdateLayout() end)
    EventRegistry:RegisterCallback("PetTracker.OPTIONS_CHANGED", function() self:UpdateLayout() end)

    self:UpdateLayout()
end
