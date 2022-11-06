local _, GW = ...
local L = GW.L

local upcomingLevelRewards = {}

local function IsUpcomingSpellAvalible()
    --if not loaded then GW.UpdateUpcomingSpells() end
    --return #upcomingLevelRewards > 0
    return false
end
GW.IsUpcomingSpellAvalible = IsUpcomingSpellAvalible

local function UpdateUpcomingSpells()
    local totalUpcomingRewards = {}
    local upcomingLevelRewardsIdx = 1
    wipe(upcomingLevelRewards)

    local spells = {GetSpecializationSpells(GW.myspec)}
    for _, v in pairs(spells) do
        if v then
            local tIndex = #totalUpcomingRewards + 1
            totalUpcomingRewards[tIndex] = {}
            totalUpcomingRewards[tIndex].type = "SPELL"
            totalUpcomingRewards[tIndex].id = v
            totalUpcomingRewards[tIndex].level = GetSpellLevelLearned(v)
        end
    end

    for i = 1, 80 do
        local skillType, spellId = GetSpellBookItemInfo(i, "spell")

        if skillType == "FUTURESPELL" and spellId then
            local shouldAdd = true
            for _, v in pairs(totalUpcomingRewards) do
                if v.type == "SPELL" and v.id == spellId then
                    shouldAdd = false
                end
            end
            if shouldAdd then
                local tIndex = #totalUpcomingRewards + 1

                totalUpcomingRewards[tIndex] = {}
                totalUpcomingRewards[tIndex].type = "SPELL"
                totalUpcomingRewards[tIndex].id = spellId
                totalUpcomingRewards[tIndex].level = GetSpellLevelLearned(spellId)
            end
        end
    end

    for k, _ in pairs(totalUpcomingRewards) do
        if totalUpcomingRewards[k] and totalUpcomingRewards[k].level > GW.mylevel then
            upcomingLevelRewards[upcomingLevelRewardsIdx] = totalUpcomingRewards[k]
            upcomingLevelRewardsIdx = upcomingLevelRewardsIdx + 1
        end
    end

    table.sort(
        upcomingLevelRewards,
        function(a, b)
            return a.level < b.level
        end
    )
end
GW.UpdateUpcomingSpells = UpdateUpcomingSpells
GW.AddForProfiling("upcomingSpells", "UpdateUpcomingSpells", UpdateUpcomingSpells)

local function UpcomingSpellOnEnter(self)
    if self.type == "SPELL" then
        GameTooltip:SetOwner(self:GetParent(), "ANCHOR_CURSOR", 0, 0)
        GameTooltip:ClearLines()
        GameTooltip:SetSpellByID(self.id)
        GameTooltip:Show()
    end
end

local function LoadUpcomingRewarsIntoScrollFrame(self)
    local offset = HybridScrollFrame_GetOffset(self)

    for i = 1, #self.buttons do
        local slot = self.buttons[i]

        local idx = i + offset
        if idx > #upcomingLevelRewards then
            -- empty row (blank starter row, final row, and any empty entries)
            slot.item:Hide()
            slot.item.type = nil
            slot.item.id = nil
            slot.item.level = nil
        else
            slot.item.type = upcomingLevelRewards[idx].type
            slot.item.id = upcomingLevelRewards[idx].id
            slot.item.level = upcomingLevelRewards[idx].level

            slot.item.levelString:SetText(slot.item.level .. " |TInterface/AddOns/GW2_UI/textures/icons/levelreward-icon:24:24:0:0|t")

            if slot.item.mask then
                slot.item.icon:RemoveMaskTexture(slot.item.mask)
            end

            if slot.item.type == "SPELL" then
                local name, _, icon = GetSpellInfo(slot.item.id)
                slot.item.icon:SetTexture(icon)
                slot.item.name:SetText(name)
                if IsPassiveSpell(slot.item.id) then
                    if not slot.item.mask then
                        slot.item.mask = UIParent:CreateMaskTexture()
                        slot.item.mask:SetPoint("CENTER", slot.item.icon, "CENTER", 0, 0)
                        slot.item.mask:SetTexture(
                            "Interface/AddOns/GW2_UI/textures/talents/passive_border",
                            "CLAMPTOBLACKADDITIVE",
                            "CLAMPTOBLACKADDITIVE"
                        )
                        slot.item.mask:SetSize(40, 40)
                    end
                    slot.item.icon:AddMaskTexture(slot.item.mask)
                end
            end

            slot.item:Show()
        end
    end

    local USED_HEIGHT = 50 * #upcomingLevelRewards
    HybridScrollFrame_Update(self, USED_HEIGHT, 235)
end

local function scrollFrameSetup(self)
    HybridScrollFrame_CreateButtons(self, "GwUpcomingRewardRow", 12, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
    for i = 1, #self.buttons do
        local slot = self.buttons[i]
        slot:SetWidth(self:GetWidth() - 12)
        slot.item.name:SetFont(DAMAGE_TEXT_FONT, 14)
        slot.item.levelString:SetFont(DAMAGE_TEXT_FONT, 14)

        if not slot.item.ScriptsHooked then
            slot.item:HookScript("OnEnter", UpcomingSpellOnEnter)
            slot.item:HookScript("OnLeave", GameTooltip_Hide)
            slot.item.ScriptsHooked = true
        end
    end

    LoadUpcomingRewarsIntoScrollFrame(self)
end

local function UpcomingSpellsFrameOnShow(self)
    PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_OPEN)
    self.animationValue = -400
    local name = self:GetName()
    local start = GetTime()
    GW.AddToAnimation(
        name,
        self.animationValue,
        0,
        start,
        0.2,
        function()
            local prog = GW.animations[name].progress
            local a = math.min(1, math.max(0, GW.lerp(0, 1, (GetTime() - start) / 0.2)))
            self:SetAlpha(a)
            self:SetPoint("CENTER", 0, prog)
        end
    )
end
GW.AddForProfiling("hud", "levelingRewards_OnShow", levelingRewards_OnShow)

local function LoadUpcomingSpells()
    local upcomingSpellsFrame = CreateFrame("Frame", "GwLevelingRewards", UIParent, "GwLevelingRewards")

    upcomingSpellsFrame.header:SetFont(DAMAGE_TEXT_FONT, 24)
    upcomingSpellsFrame.header:SetText(L["Upcoming Level Rewards"])

    upcomingSpellsFrame.rewardHeader:SetFont(DAMAGE_TEXT_FONT, 11)
    upcomingSpellsFrame.rewardHeader:SetTextColor(0.6, 0.6, 0.6)
    upcomingSpellsFrame.rewardHeader:SetText(REWARD)

    upcomingSpellsFrame.levelHeader:SetFont(DAMAGE_TEXT_FONT, 11)
    upcomingSpellsFrame.levelHeader:SetTextColor(0.6, 0.6, 0.6)
    upcomingSpellsFrame.levelHeader:SetText(LEVEL)

    upcomingSpellsFrame.CloseButton:SetScript("OnClick", GW.Parent_Hide)
    upcomingSpellsFrame.CloseButton:SetText(CLOSE)

    upcomingSpellsFrame:SetScript("OnShow", UpcomingSpellsFrameOnShow)

    tinsert(UISpecialFrames, "GwLevelingRewards")

    upcomingSpellsFrame.scrollFrame.update = LoadUpcomingRewarsIntoScrollFrame
    upcomingSpellsFrame.scrollFrame.scrollBar.doNotHide = false
    scrollFrameSetup(upcomingSpellsFrame.scrollFrame)

    upcomingSpellsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    upcomingSpellsFrame:RegisterEvent("PLAYER_LEVEL_CHANGED")
    upcomingSpellsFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

    upcomingSpellsFrame:SetScript(
        "OnEvent",
        function(self)
            UpdateUpcomingSpells()
            scrollFrameSetup(self.scrollFrame)
        end
    )
end
GW.LoadUpcomingSpells = LoadUpcomingSpells
