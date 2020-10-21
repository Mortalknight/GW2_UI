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
end

local function ExtraButtons_UpdateScale()
    ExtraButtons_ZoneScale()

    local scale = GetSetting("ExtraActionBarFramePos_scale")
    _G.ExtraActionBarFrame:SetScale(scale)

    local width, height = _G.ExtraActionBarFrame.button:GetSize()
    ExtraActionBarFrame.gwMover:SetSize(width * scale, height * scale)
end

local function ExtraAB_BossAB_Setup()
    RegisterMovableFrame(ExtraActionBarFrame, L["EXTRA_AB_NAME"], "ExtraActionBarFramePos", "VerticalActionBarDummy", nil, nil, nil, true)
    RegisterMovableFrame(ZoneAbilityFrame, L["ZONE_ANILITY_AB_NAME"], "ZoneAbilityFramePos", "VerticalActionBarDummy", nil, nil, nil, true)

    ZoneAbilityFrame.SpellButtonContainer.holder = ZoneAbilityFrame.gwMover

    _G.UIPARENT_MANAGED_FRAME_POSITIONS.ExtraAbilityContainer = nil
    _G.ExtraAbilityContainer.SetSize = GW.NoOp
    _G.ExtraActionBarFrame.SetSize = GW.NoOp
    
    local point = GW.GetSetting("ZoneAbilityFramePos")
    ZoneAbilityFrame:ClearAllPoints()
    ZoneAbilityFrame:SetAllPoints(ZoneAbilityFrame.gwMover)
    ZoneAbilityFrame.ignoreInLayout = true

    local point = GW.GetSetting("ExtraActionBarFramePos")
    ExtraActionBarFrame:ClearAllPoints()
    ExtraActionBarFrame:SetAllPoints(ExtraActionBarFrame.gwMover)
    ExtraActionBarFrame.ignoreInLayout = true

    ExtraButtons_UpdateScale()

    -- Spawn the mover before its available.
    local size = 52 * GetSetting("ZoneAbilityFramePos_scale")
    ZoneAbilityFrame.gwMover:SetSize(size, size)

    hooksecurefunc(ZoneAbilityFrame.SpellButtonContainer, "SetSize", ExtraButtons_ZoneScale)
    hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(self)
        for spellButton in self.SpellButtonContainer:EnumerateActive() do
            if spellButton then
                spellButton.holder = ZoneAbilityFrame.gwMover
                spellButton:ClearAllPoints()
                spellButton:SetAllPoints(ExtraActionBarFrame.gwMover)
            end
        end
    end)

    for i = 1, ExtraActionBarFrame:GetNumChildren() do
        local button = _G["ExtraActionButton" .. i]
        if button then
            button.pushed = true
            button.checked = true    
            button.holder = ExtraActionBarFrame.gwMover
            button:ClearAllPoints()
            button:SetAllPoints(ExtraActionBarFrame.gwMover)
        end
    end
end
GW.ExtraAB_BossAB_Setup = ExtraAB_BossAB_Setup