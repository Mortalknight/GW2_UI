local _, GW = ...
local L = GW.L
local RegisterMovableFrame = GW.RegisterMovableFrame
local GetSetting = GW.GetSetting

local function ExtraButtons_ZoneScale()
    local scale = GetSetting("ZoneAbilityFramePos_scale")
    _G.ZoneAbilityFrame.Style:SetScale(scale)
    _G.ZoneAbilityFrame.SpellButtonContainer:SetScale(scale)

    local width, height = _G.ZoneAbilityFrame.SpellButtonContainer:GetSize()
    ZoneAbilityFrame.gwMover:SetSize(width * scale, height * scale)
    ZoneAbilityFrame.SpellButtonContainer:ClearAllPoints()
    ZoneAbilityFrame.SpellButtonContainer:SetAllPoints(ZoneAbilityFrame.gwMover)
end

local function ExtraButtons_UpdateScale()
    ExtraButtons_ZoneScale()

    local scale = GetSetting("ExtraActionBarFramePos_scale")
    _G.ExtraActionBarFrame:SetScale(scale)
    QuickKeybindFrame.phantomExtraActionButton:SetScale(scale)

    local width, height = _G.ExtraActionBarFrame.button:GetSize()
    ExtraActionBarFrame.gwMover:SetSize(width, height)
    QuickKeybindFrame.phantomExtraActionButton.normalTexture:SetTexture("Interface/AddOns/GW2_UI/textures/spelliconempty")
    QuickKeybindFrame.phantomExtraActionButton.normalTexture:ClearAllPoints()
    QuickKeybindFrame.phantomExtraActionButton.normalTexture:SetAllPoints(ExtraActionBarFrame.gwMover)
    QuickKeybindFrame.phantomExtraActionButton.QuickKeybindHighlightTexture:ClearAllPoints()
    QuickKeybindFrame.phantomExtraActionButton.QuickKeybindHighlightTexture:SetAllPoints(ExtraActionBarFrame.gwMover)
    QuickKeybindFrame.phantomExtraActionButton:ClearAllPoints()
    QuickKeybindFrame.phantomExtraActionButton:SetAllPoints(ExtraActionBarFrame.gwMover)
end

local function ExtraAB_BossAB_Setup()
    KeyBindingFrame_LoadUI()

    RegisterMovableFrame(ExtraActionBarFrame, L["EXTRA_AB_NAME"], "ExtraActionBarFramePos", "VerticalActionBarDummy", nil, nil, nil, true)
    RegisterMovableFrame(ZoneAbilityFrame, L["ZONE_ANILITY_AB_NAME"], "ZoneAbilityFramePos", "VerticalActionBarDummy", nil, nil, nil, true)

    ZoneAbilityFrame.SpellButtonContainer.holder = ZoneAbilityFrame.gwMover

    _G.UIPARENT_MANAGED_FRAME_POSITIONS.ExtraAbilityContainer = nil
    _G.ExtraAbilityContainer.SetSize = GW.NoOp
    _G.ExtraActionBarFrame.SetSize = GW.NoOp
    
    ExtraButtons_UpdateScale()
    
    ZoneAbilityFrame:SetParent(ZoneAbilityFrame.gwMover)
    ZoneAbilityFrame:ClearAllPoints()
    ZoneAbilityFrame:SetAllPoints(ZoneAbilityFrame.gwMover)
    ZoneAbilityFrame.ignoreInLayout = true

    ExtraActionBarFrame:SetParent(ExtraActionBarFrame.gwMover)
    ExtraActionBarFrame:ClearAllPoints()
    ExtraActionBarFrame:SetAllPoints(ExtraActionBarFrame.gwMover)
    ExtraActionBarFrame.ignoreInLayout = true

    -- Spawn the mover before its available.
    local size = 52 * GetSetting("ZoneAbilityFramePos_scale")
    ZoneAbilityFrame.gwMover:SetSize(size, size)

    hooksecurefunc(ZoneAbilityFrame.SpellButtonContainer, "SetSize", ExtraButtons_ZoneScale)
    hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(self)
        for spellButton in self.SpellButtonContainer:EnumerateActive() do
            if spellButton then
                spellButton.holder = ZoneAbilityFrame.gwMover
                spellButton.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                spellButton.NormalTexture:SetAlpha(0)
                spellButton:ClearAllPoints()
                spellButton:SetAllPoints(ExtraActionBarFrame.gwMover)
                spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            end
        end
    end)
    hooksecurefunc(ExtraActionBarFrame, "SetPoint", function()
        ExtraActionBarFrame:SetParent(ExtraActionBarFrame.gwMover)
        ExtraActionBarFrame:ClearAllPoints()
        ExtraActionBarFrame:SetAllPoints(ExtraActionBarFrame.gwMover)
    end)
    for i = 1, ExtraActionBarFrame:GetNumChildren() do
        local button = _G["ExtraActionButton" .. i]
        if button then
            button.pushed = true
            button.checked = true    
            button.holder = ExtraActionBarFrame.gwMover
            button:ClearAllPoints()
            button:SetAllPoints(ExtraActionBarFrame.gwMover)
            button.icon:SetDrawLayer("ARTWORK")
            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        end
    end
end
GW.ExtraAB_BossAB_Setup = ExtraAB_BossAB_Setup