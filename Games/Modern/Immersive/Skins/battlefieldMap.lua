---@class GW2
local GW = select(2, ...)

-- the close button stays faint until the map is hovered
local CLOSE_IDLE_ALPHA = 0.25

local function ApplyBattlefieldMapFrameSkin()
    if not GW.settings.skins.battlefieldMap.enabled then return end

    local map = BattlefieldMapFrame
    local container = map.ScrollContainer
    local close = map.BorderFrame and map.BorderFrame.CloseButton

    map:GwStripTextures()
    map:GwCreateBackdrop()
    map:SetFrameStrata("LOW")
    if container then
        map.backdrop:GwSetOutside(container)
    end

    -- follow the opacity slider of Blizzard's map options
    local function UpdateBackground()
        local opacity = BattlefieldMapOptions and BattlefieldMapOptions.opacity or 1
        local r, g, b = GW.Colors.Fallback:GetRGB()
        map.backdrop:SetBackdropColor(r, g, b, 1 - opacity)
    end
    map:HookScript("OnShow", UpdateBackground)
    hooksecurefunc(map, "SetGlobalAlpha", UpdateBackground)

    if BattlefieldMapTab then
        GW.HandleTabs(BattlefieldMapTab, "top")
        if BattlefieldMapTab.Text then
            BattlefieldMapTab.Text:GwSetInside(BattlefieldMapTab)
        end
        map:ClearAllPoints()
        map:SetPoint("TOPLEFT", BattlefieldMapTab, "BOTTOMLEFT", 0, -5)
    end

    if not close then return end
    close:GwSkinButton(true)
    close:ClearAllPoints()
    close:SetPoint("TOPRIGHT", 3, 5)
    close:SetFrameLevel(close:GetFrameLevel() + 1)
    -- the map fades as a whole, the close button keeps its own alpha
    close:SetIgnoreParentAlpha(true)
    close:SetAlpha(CLOSE_IDLE_ALPHA)

    local function UpdateCloseAlpha()
        local hovered = close:IsMouseOver() or (container and container:IsMouseOver())
        close:SetAlpha(hovered and 1 or CLOSE_IDLE_ALPHA)
    end
    for _, region in ipairs({ close, container }) do
        region:HookScript("OnEnter", UpdateCloseAlpha)
        region:HookScript("OnLeave", UpdateCloseAlpha)
    end
end

local function LoadBattlefieldMapSkin()
    GW.RegisterLoadHook(ApplyBattlefieldMapFrameSkin, "Blizzard_BattlefieldMap", BattlefieldMapFrame)
end
GW.LoadBattlefieldMapSkin = LoadBattlefieldMapSkin
