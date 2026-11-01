---@class GW2
local GW = select(2, ...)

-- the parts of the hero panel the classic clients share; their character.lua keep what differs
local HeroPanel = {}
GW.HeroPanel = HeroPanel

HeroPanel.PlayerSlots = {
    ["CharacterHeadSlot"] = {0, 0.25, 0, 0.125},
    ["CharacterNeckSlot"] = {0.25, 0.5, 0, 0.125},
    ["CharacterShoulderSlot"] = {0.5, 0.75, 0.25, 0.375},
    ["CharacterBackSlot"] = {0.75, 1, 0, 0.125},
    ["CharacterChestSlot"] = {0.75, 1, 0.25, 0.375},
    ["CharacterShirtSlot"] = {0.75, 1, 0.25, 0.375},
    ["CharacterTabardSlot"] = {0.25, 0.5, 0.375, 0.5},
    ["CharacterWristSlot"] = {0.75, 1, 0.125, 0.25},
    ["CharacterHandsSlot"] = {0, 0.25, 0.375, 0.5},
    ["CharacterWaistSlot"] = {0.25, 0.5, 0.25, 0.375},
    ["CharacterLegsSlot"] = {0, 0.25, 0.25, 0.375},
    ["CharacterFeetSlot"] = {0.5, 0.75, 0.125, 0.25},
    ["CharacterFinger0Slot"] = {0.5, 0.75, 0, 0.125},
    ["CharacterFinger1Slot"] = {0.5, 0.75, 0, 0.125},
    ["CharacterTrinket0Slot"] = {0.5, 0.75, 0.375, 0.5},
    ["CharacterTrinket1Slot"] = {0.5, 0.75, 0.375, 0.5},
    ["CharacterMainHandSlot"] = {0.25, 0.5, 0.125, 0.25},
    ["CharacterSecondaryHandSlot"] = {0, 0.25, 0.125, 0.25},
    ["CharacterRangedSlot"] = {0.25, 0.5, 0.5, 0.625},
    ["CharacterAmmoSlot"] = {0.75, 1, 0.375, 0.5},
}

HeroPanel.statsIconsSprite = {
    width = 256,
    height = 512,
    colums = 4,
    rows = 8
}

HeroPanel.petStateSprite = {
    width = 512,
    height = 128,
    colums = 4,
    rows = 1
}

HeroPanel.STATS_ICONS = {
    STRENGTH = {x = 1, y = 5},
    AGILITY = {x = 2, y = 5},
    INTELLECT = {x = 3, y = 5},
    SPIRIT= {x = 4, y = 2},
    STAMINA = {x = 1, y = 2},
    ARMOR = {x = 3, y = 1},
    CRITCHANCE = {x = 2, y = 2},
    HASTE = {x = 1, y = 3},
    MASTERY = {x = 1, y = 1},
    --Needs icon
    MANAREGEN = {x = 4, y = 2},
    VERSATILITY = {x = 2, y = 3},
    LIFESTEAL = {x = 2, y = 4},
    --Needs icon
    AVOIDANCE = {x =4 , y = 1},
    --DODGE needs icon
    DODGE = {x = 3, y = 3},
    DEFENSE = {x = 4, y = 3},
    PARRY = {x = 1, y = 1},
    MOVESPEED = {x = 3, y = 2},
    ATTACKRATING = {x = 4, y = 5},
    DAMAGE = {x = 4, y = 4},
    ATTACKPOWER = {x = 1, y = 6},
    RANGEDATTACK = {x = 2, y = 6},
    RANGEDDAMAGE = {x = 3, y = 6},
    RANGEDATTACKPOWER = {x = 4, y = 6},
    Holy = {x = 1, y = 7},
    Fire = {x = 2, y = 7},
    Nature = {x = 3, y = 7},
    Frost = {x = 4, y = 7},
    Shadow = {x = 1, y = 8},
    Arcane = {x = 2, y = 8},
}

-- player stat tiles of the current update, the stats picker lays them out
HeroPanel.statTiles = {}

function HeroPanel.StatGridPos(grid, x, y)
    grid = grid + 1
    x = x + 92
    if grid > 2 then
        grid = 1
        x = 0
        y = y + 30
    end
    return grid, x, y
end

function HeroPanel.SetupBackButton(_, fmBtn, key)
    GW.CharacterMenuButtonBack_OnLoad(fmBtn, key, true)
    GW.SetCharacterWindowOpenAttribute(fmBtn, "paperdoll", false)
end

local function StatOnEnter(self)
    if self.stat == "DURABILITY" then
        GW.DurabilityTooltip(self)
        return
    end
    if not self.tooltip then
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.tooltip, 1, 1, 1)
    if self.tooltip2 then
        GameTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
    end
    GameTooltip:Show()
end

local function GetStatListFrame(self, i, isPet)
    local frameName = isPet and ("GwPaperDollPetStat" .. i) or ("GwPaperDollStat" .. i)
    local frame = _G[frameName]
    if frame then
        return frame
    end
    frame = CreateFrame("Frame", frameName, self, "GwPaperDollStat")

    frame:SetScript("OnEnter", StatOnEnter)
    frame:SetScript("OnLeave", GameTooltip_Hide)
    frame.Value:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    frame.Label:SetFont(UNIT_NAME_FONT, 1, "")
    frame.Label:SetTextColor(0, 0, 0, 0)
    frame.Value:SetText("")
    frame.icon:SetTexture("Interface/AddOns/GW2_UI/textures/character/statsicon-classic.png")

    return frame
end

local function SetStatIcon(self, stat)
    local newTexture = "Interface/AddOns/GW2_UI/textures/character/statsicon-classic.png"

    if stat == "DURABILITY" then
        newTexture = "Interface/AddOns/GW2_UI/textures/globe/repair.png"
    elseif HeroPanel.STATS_ICONS[stat] then
        self.icon:SetTexCoord(GW.getSprite(HeroPanel.statsIconsSprite, HeroPanel.STATS_ICONS[stat].x, HeroPanel.STATS_ICONS[stat].y))
    end

    if newTexture ~= self.icon:GetTexture() then
        self.icon:SetTexture(newTexture)
        if stat == "DURABILITY" then
            self.icon:SetTexCoord(0, 1, 0, 0.5)
        end
    end
    self.icon:SetDesaturated(stat == "DURABILITY")
end

function HeroPanel.SetStatFrame(stat, index, statText, tooltip, tooltip2, grid, x, y)
    local statFrame = GetStatListFrame(GwDressingRoom.stats, index, false)
    statFrame.tooltip = tooltip
    statFrame.tooltip2 = tooltip2
    statFrame.stat = stat
    statFrame.Value:SetText(statText)
    SetStatIcon(statFrame, stat)

    statFrame.icon:ClearAllPoints()
    if stat == "DURABILITY" then
        statFrame.icon:SetSize(25, 25)
        statFrame.icon:SetPoint("LEFT", 5, 0)
        GW.WatchDurability(statFrame)
    else
        statFrame.icon:SetSize(35, 35)
        statFrame.icon:SetPoint("LEFT")
    end
    GW.StatsPicker.RegisterTile(GwDressingRoom.stats, statFrame)
    statFrame.gwStatVisible = GW.StatsPicker.IsVisible(stat, true)
    tinsert(HeroPanel.statTiles, statFrame)
    return grid, x, y, index + 1
end

function HeroPanel.SetPetStatFrame(stat, index, statText, tooltip, tooltip2, grid, x, y)
    local statFrame = GetStatListFrame(GwDressingRoomPet.stats, index, true)
    statFrame.tooltip = tooltip
    statFrame.tooltip2 = tooltip2
    statFrame.stat = stat
    statFrame.Value:SetText(statText)
    SetStatIcon(statFrame, stat)

    statFrame:SetPoint("TOPLEFT", 5 + x, -35 + -y)
    grid, x, y = HeroPanel.StatGridPos(grid, x, y)
    return grid, x, y, index + 1
end

function GW.SetItemButtonBorderQuality(button, quality)
    -- grey items get a border too; blizzard's bag colors would make common items grey as well, ours are white
    local color = quality and GW.GetQualityColor(quality)
    if color then
        button.IconBorder:Show()
        button.IconBorder:SetVertexColor(color.r, color.g, color.b)
    else
        button.IconBorder:Hide()
    end
end

function HeroPanel.SlotButton_Update(self)
    local slot = self:GetID()
    local textureName = GetInventoryItemTexture("player", slot)
    local cooldown = _G[self:GetName() .. "Cooldown"]

    if textureName then
        if (GetInventoryItemBroken("player", slot) or GetInventoryItemEquippedUnusable("player", slot)) then
            SetItemButtonTextureVertexColor(self, 0.9, 0, 0)
        else
            SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0)
        end

        if self.repairIcon then
            local current, maximum = GetInventoryItemDurability(slot)
            if current ~= nil and (current / maximum) < 0.5 then
                self.repairIcon:Show()
                if (current / maximum) == 0 then
                    self.repairIcon:SetTexCoord(0, 1, 0.5, 1)
                else
                    self.repairIcon:SetTexCoord(0, 1, 0, 0.5)
                end
            else
                self.repairIcon:Hide()
            end
        end

        if cooldown then
            local start, duration, enable = GetInventoryItemCooldown("player", slot)
            CooldownFrame_Set(cooldown, start, duration, enable)
        end
        self.hasItem = 1
    else
        if self.repairIcon then self.repairIcon:Hide() end
    end

    if GW.settings.windows.character.itemInfo and self.itemlevel then
        local itemLink = GetInventoryItemLink("player", slot)
        if itemLink then
            local iLvl = C_Item.GetDetailedItemLevelInfo(itemLink)
            if iLvl then
                local quality = GetInventoryItemQuality("player", slot)
                if quality then
                    local r, g, b = C_Item.GetItemQualityColor(quality)
                    self.itemlevel:SetTextColor(r or 1, g or 1, b or 1, 1)
                end
                self.itemlevel:SetText(iLvl)
            else
                self.itemlevel:SetText("")
            end
        else
            self.itemlevel:SetText("")
        end
    elseif self.itemlevel then
        self.itemlevel:SetText("")
    end

    if self.IconBorder then
        local quality = GetInventoryItemQuality("player", slot)
        GW.SetItemButtonBorderQuality(self, quality)
    end
end

function HeroPanel.GrabDefaultSlot(slot, anchor, parent, size)
    slot:ClearAllPoints()
    slot:SetPoint(unpack(anchor))
    slot:SetParent(parent)
    slot:SetSize(size, size)
    slot:GwStripTextures()
    slot:SetFrameLevel(parent:GetFrameLevel() + 15)

    if slot.icon then
        slot.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        slot.icon:SetAlpha(0.9)
        slot.icon:SetAllPoints(slot)
    else
        local icon = _G[slot:GetName() .. "IconTexture"]
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        icon:SetAlpha(0.9)
        icon:SetAllPoints(slot)
        slot.icon = icon
    end
    if slot.IconBorder then
        slot.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
        slot.IconBorder:SetAllPoints(slot)
        slot.IconBorder:SetParent(slot)
    end

    local cooldown = _G[slot:GetName() .. "Cooldown"]
    if cooldown then
        GW.RegisterCooldown(cooldown)
    end

    slot:GetNormalTexture():SetTexture(nil)

    local high = slot:GetHighlightTexture()
    high:SetAllPoints(slot)
    high:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    high:SetBlendMode("ADD")
    high:SetAlpha(0.33)

    if slot ~= CharacterAmmoSlot then
        slot.repairIcon = slot:CreateTexture(nil, "OVERLAY")
        slot.repairIcon:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", 0, 0)
        slot.repairIcon:SetTexture("Interface/AddOns/GW2_UI/textures/globe/repair.png")
        slot.repairIcon:SetTexCoord(0, 1, 0.5, 1)
        slot.repairIcon:SetSize(20, 20)

        slot.itemlevel = slot:CreateFontString(nil, "OVERLAY")
        slot.itemlevel:SetSize(size, 10)
        slot.itemlevel:SetPoint("BOTTOMLEFT", 1, 2)
        slot.itemlevel:SetTextColor(1, 1, 1)
        slot.itemlevel:SetJustifyH("LEFT")
        slot.itemlevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
    end

    slot.IsGW2Hooked = true
end

-- panels: blizzard tab -> {our frame, its panel}; a tab without its frame closes the window like an unknown one
local characterPanelOpen
local function ToggleCharacter(panels, tab, onlyShow)
    if InCombatLockdown() then
        return
    end
    -- closed with escape or the close button, the next toggle of the same tab opens it again
    if not GwCharacterWindow:IsShown() then
        characterPanelOpen = nil
    end

    local panel = panels[tab]
    if panel and _G[panel[1]] and characterPanelOpen ~= tab then
        characterPanelOpen = tab
        if not onlyShow then
            GwCharacterWindow:SetAttribute("keytoggle", true)
        end
        GwCharacterWindow:SetAttribute("windowpanelopen", panel[2])
        return
    end

    if GwCharacterWindow:IsShown() then
        GwCharacterWindow:SetAttribute("windowPanelOpen", nil)
        characterPanelOpen = nil
    end
end

function HeroPanel.HookToggleCharacter(panels)
    hooksecurefunc("ToggleCharacter", function(tab, onlyShow)
        ToggleCharacter(panels, tab, onlyShow)
    end)
end
