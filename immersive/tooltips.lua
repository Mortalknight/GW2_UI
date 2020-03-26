local _, GW = ...

local GetSetting = GW.GetSetting
local RegisterMovableFrame = GW.RegisterMovableFrame

local UNSTYLED = {
    "GameTooltip",
    "ShoppingTooltip1",
    "ShoppingTooltip2",
    "ShoppingTooltip3",
    "ItemRefShoppingTooltip1",
    "ItemRefShoppingTooltip2",
    "ItemRefShoppingTooltip3",
    "WorldMapTooltip",
    "WorldMapCompareTooltip1",
    "WorldMapCompareTooltip2",
    "WorldMapCompareTooltip3",
    "AtlasLootTooltip",
    "QuestHelperTooltip",
    "QuestGuru_QuestWatchTooltip",
    "TRP2_MainTooltip",
    "TRP2_ObjetTooltip",
    "TRP2_StaticPopupPersoTooltip",
    "TRP2_PersoTooltip",
    "TRP2_MountTooltip",
    "AltoTooltip",
    "AltoScanningTooltip",
    "ArkScanTooltipTemplate",
    "NxTooltipItem",
    "NxTooltipD",
    "DBMInfoFrame",
    "DBMRangeCheck",
    "DatatextTooltip",
    "VengeanceTooltip",
    "FishingBuddyTooltip",
    "FishLibTooltip",
    "HealBot_ScanTooltip",
    "hbGameTooltip",
    "PlateBuffsTooltip",
    "LibGroupInSpecTScanTip",
    "RecountTempTooltip",
    "VuhDoScanTooltip",
    "XPerl_BottomTip",
    "EventTraceTooltip",
    "FrameStackTooltip",
    "PetBattlePrimaryUnitTooltip",
    "PetBattlePrimaryAbilityTooltip",
    "LibDBIconTooltip"
}

local function movePlacement(self)
    local settings = GetSetting("GameTooltipPos")
    self:ClearAllPoints()
    self:SetPoint(settings.point, UIParent, settings.relativePoint, settings.xOfs, settings.yOfs)
end
GW.AddForProfiling("tooltips", "movePlacement", movePlacement)

local constBackdropArgs = {
    bgFile = "Interface\\AddOns\\GW2_UI\\textures\\UI-Tooltip-Background",
    edgeFile = "Interface\\AddOns\\GW2_UI\\textures\\UI-Tooltip-Border",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
local function styleTooltip(self)
    if not self:IsShown() then
        return
    end
    self:SetBackdrop(constBackdropArgs)
    if _G[self:GetName() .. "StatusBarTexture"] then
        _G[self:GetName() .. "StatusBarTexture"]:SetTexture("Interface\\Addons\\GW2_UI\\Textures\\castinbar-white")
    end
    if DBMInfoFrame then 
        DBMInfoFrame:SetBackdrop(constBackdropArgs)
    end
end
GW.AddForProfiling("tooltips", "styleTooltip", styleTooltip)

local function tooltip_SetBackdropStyle(self, args)
    if args and args == GAME_TOOLTIP_BACKDROP_STYLE_EMBEDDED then
        return
    end
    if not self:IsShown() then
        return
    end
    self:SetBackdrop(constBackdropArgs)
end
GW.AddForProfiling("tooltips", "tooltip_SetBackdropStyle", tooltip_SetBackdropStyle)

local function anchorTooltip(self, p)
    self:SetOwner(p, GetSetting("CURSOR_ANCHOR_TYPE"), GetSetting("ANCHOR_CURSOR_OFFSET_X"), GetSetting("ANCHOR_CURSOR_OFFSET_Y"))
end
GW.AddForProfiling("tooltips", "anchorTooltip", anchorTooltip)

local function SkinItemRefTooltip()
    local SkinItemRefTooltip_Update = function()
        if ItemRefTooltip:IsShown() then
            ItemRefCloseButton:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\window-close-button-normal")
            ItemRefCloseButton:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\window-close-button-hover")
            ItemRefCloseButton:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\window-close-button-hover")
            ItemRefCloseButton:SetSize(20, 20)
            ItemRefCloseButton:ClearAllPoints()
            ItemRefCloseButton:SetPoint("TOPRIGHT", -3, -3)
            ItemRefTooltip:SetBackdrop(constBackdropArgs)
        end
    end

    hooksecurefunc("SetItemRef", SkinItemRefTooltip_Update)
end

local function SkinBattlePetTooltip()
    local skin_battle_pet_tt = function(self)
        self.BorderTopLeft:Hide()
        self.BorderTopRight:Hide()
        self.BorderBottomRight:Hide()
        self.BorderBottomLeft:Hide()
        self.BorderTop:Hide()
        self.BorderRight:Hide()
        self.BorderBottom:Hide()
        self.BorderLeft:Hide()
        self.Background:Hide()
        self:SetBackdrop(constBackdropArgs)
    end

    hooksecurefunc("SharedPetBattleAbilityTooltip_SetAbility", function(self) skin_battle_pet_tt(self) end)

    local fbptt = function()
        if FloatingBattlePetTooltip:IsShown() then
            FloatingBattlePetTooltip.CloseButton:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\window-close-button-normal")
            FloatingBattlePetTooltip.CloseButton:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\window-close-button-hover")
            FloatingBattlePetTooltip.CloseButton:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\window-close-button-hover")
            FloatingBattlePetTooltip.CloseButton:SetSize(20, 20)
            FloatingBattlePetTooltip.CloseButton:ClearAllPoints()
            FloatingBattlePetTooltip.CloseButton:SetPoint("TOPRIGHT", -3, -3)

            skin_battle_pet_tt(FloatingBattlePetTooltip)
        end
    end
    hooksecurefunc("FloatingBattlePet_Show", fbptt)

    local bptt = function()
        skin_battle_pet_tt(BattlePetTooltip)
    end
    hooksecurefunc("BattlePetToolTip_Show", bptt)
end

local function SkinQueueStatusFrame()
    local QueueStatusFrame = _G.QueueStatusFrame

    QueueStatusFrame:SetBackdrop(nil)
    QueueStatusFrame.BorderTopLeft:Hide()
    QueueStatusFrame.BorderTopRight:Hide()
    QueueStatusFrame.BorderBottomRight:Hide()
    QueueStatusFrame.BorderBottomLeft:Hide()
    QueueStatusFrame.BorderTop:Hide()
    QueueStatusFrame.BorderRight:Hide()
    QueueStatusFrame.BorderBottom:Hide()
    QueueStatusFrame.BorderLeft:Hide()
    QueueStatusFrame.Background:Hide()
    QueueStatusFrame:SetBackdrop(constBackdropArgs)
end

local function LoadTooltips()
    if GetSetting("TOOLTIP_MOUSE") then
        hooksecurefunc("GameTooltip_SetDefaultAnchor", anchorTooltip)
    else
        GameTooltip:HookScript("OnTooltipSetUnit", movePlacement)
        GameTooltip:HookScript("OnTooltipSetQuest", movePlacement)
        --GameTooltip:HookScript("OnTooltipSetItem", movePlacement)
        GameTooltip:HookScript("OnTooltipSetSpell", movePlacement)
        GameTooltip:HookScript("OnTooltipSetDefaultAnchor", movePlacement)
        RegisterMovableFrame(GameTooltip, "Tooltip", "GameTooltipPos", "VerticalActionBarDummy")
        hooksecurefunc(GameTooltip.gwMover, "StopMovingOrSizing", function (frame)
            local anchor = "BOTTOMRIGHT"
            local x = frame:GetRight() - GetScreenWidth()
            local y = frame:GetBottom()

            frame:ClearAllPoints()
            frame:SetPoint(anchor, x, y)

            if not InCombatLockdown() then
                GameTooltip:ClearAllPoints()
                GameTooltip:SetPoint(frame:GetPoint())
            end
        end)
    end
    SkinItemRefTooltip()
    SkinQueueStatusFrame()
    SkinBattlePetTooltip()
    hooksecurefunc("GameTooltip_SetBackdropStyle", tooltip_SetBackdropStyle)
    for _, toStyle in ipairs(UNSTYLED) do
        local f = _G[toStyle]
        if f then
            f:HookScript("OnUpdate", styleTooltip)
        end
    end
end
GW.LoadTooltips = LoadTooltips
