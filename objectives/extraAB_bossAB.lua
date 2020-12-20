local _, GW = ...
local L = GW.L
local RegisterMovableFrame = GW.RegisterMovableFrame
local GetSetting = GW.GetSetting

local ExtraActionBarHolder, ZoneAbilityHolder
local ExtraButtons = {}

local function ExtraButtons_ZoneScale()
    local scale = GetSetting("ZoneAbilityFramePos_scale")
    _G.ZoneAbilityFrame.Style:SetScale(scale)
    _G.ZoneAbilityFrame.SpellButtonContainer:SetScale(scale)

    local width, height = _G.ZoneAbilityFrame.SpellButtonContainer:GetSize()
    ZoneAbilityHolder:SetSize(width * scale, height * scale)
    ZoneAbilityHolder.gwMover:SetSize(width * scale, height * scale)
end

local function ExtraButtons_UpdateScale()
    ExtraButtons_ZoneScale()

    local scale = GetSetting("ExtraActionBarFramePos_scale")
    _G.ExtraActionBarFrame:SetScale(scale)

    local width, height = _G.ExtraActionBarFrame.button:GetSize()
    ExtraActionBarHolder:SetSize(width * scale, height * scale)
    ExtraActionBarHolder.gwMover:SetSize(width * scale, height * scale)

    QuickKeybindFrame.phantomExtraActionButton.normalTexture:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/spelliconempty")
    QuickKeybindFrame.phantomExtraActionButton.normalTexture:ClearAllPoints()
    QuickKeybindFrame.phantomExtraActionButton.normalTexture:SetAllPoints(ExtraActionBarHolder.gwMover)
    QuickKeybindFrame.phantomExtraActionButton.QuickKeybindHighlightTexture:ClearAllPoints()
    QuickKeybindFrame.phantomExtraActionButton.QuickKeybindHighlightTexture:SetAllPoints(ExtraActionBarHolder.gwMover)
    QuickKeybindFrame.phantomExtraActionButton:ClearAllPoints()
    QuickKeybindFrame.phantomExtraActionButton:SetAllPoints(ExtraActionBarHolder.gwMover)
end

local function UpdateExtraBindings()
    for _, button in pairs(ExtraButtons) do
        button.HotKey:SetText(_G.GetBindingKey(button:GetName()))
        GW.updateHotkey(button)
    end
end

local function ExtraAB_BossAB_Setup()
    KeyBindingFrame_LoadUI()

    local ExtraActionBarFrame = _G.ExtraActionBarFrame
    local ZoneAbilityFrame = _G.ZoneAbilityFrame
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("UPDATE_BINDINGS")
    eventFrame:SetScript("OnEvent", UpdateExtraBindings)

    ExtraActionBarHolder = CreateFrame("Frame", nil, UIParent)
    ExtraActionBarHolder:SetPoint("BOTTOM", UIParent, "BOTTOM", -150, 300)

    ZoneAbilityHolder = CreateFrame("Frame", nil, UIParent)
    ZoneAbilityHolder:SetPoint("BOTTOM", UIParent, "BOTTOM", 150, 300)
    
    ZoneAbilityFrame.SpellButtonContainer.holder = ZoneAbilityHolder

    -- try to shutdown the container movement and taints
    _G.UIPARENT_MANAGED_FRAME_POSITIONS.ExtraAbilityContainer = nil
    _G.ExtraAbilityContainer.SetSize = GW.NoOp
    
    RegisterMovableFrame(ExtraActionBarHolder, L["Boss Button"], "ExtraActionBarFramePos", "VerticalActionBarDummy", nil, nil, {"scaleable"})
    RegisterMovableFrame(ZoneAbilityHolder, L["Zone Ability"], "ZoneAbilityFramePos", "VerticalActionBarDummy", nil, nil, {"scaleable"})

    ZoneAbilityFrame:SetParent(ZoneAbilityHolder)
    ZoneAbilityFrame:ClearAllPoints()
    ZoneAbilityFrame:SetAllPoints(ZoneAbilityHolder.gwMover)
    ZoneAbilityFrame.ignoreInLayout = true

    ExtraActionBarFrame:SetParent(ExtraActionBarHolder)
    ExtraActionBarFrame:ClearAllPoints()
    ExtraActionBarFrame:SetAllPoints(ExtraActionBarHolder.gwMover)
    ExtraActionBarFrame.ignoreInLayout = true
    
    hooksecurefunc(ZoneAbilityFrame.SpellButtonContainer, "SetSize", ExtraButtons_ZoneScale)
    hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(frame)

        for spellButton in frame.SpellButtonContainer:EnumerateActive() do
            if spellButton and not spellButton.IsSkinned then
                spellButton.NormalTexture:SetAlpha(0)
                spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
                spellButton.Icon:SetDrawLayer("ARTWORK")
                spellButton.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

                spellButton.holder = ZoneAbilityHolder

                spellButton.IsSkinned = true
            end
        end
    end)
    
    for i = 1, ExtraActionBarFrame:GetNumChildren() do
        local button = _G["ExtraActionButton" .. i]
        if button then
            button.pushed = true
            button.checked = true

            button.icon:SetDrawLayer("ARTWORK")
            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

            button.holder = ExtraActionBarHolder

            local tex = button:CreateTexture(nil, "OVERLAY")
            tex:SetColorTexture(0.9, 0.8, 0.1, 0.3)
            button:SetCheckedTexture(tex)          

            button.HotKey:SetText(GetBindingKey("ExtraActionButton" .. i))
            tinsert(ExtraButtons, button)
        end
    end
    
    ExtraButtons_UpdateScale()
    
    -- Spawn the mover before its available.
    local size = 52 * GetSetting("ZoneAbilityFramePos_scale")
    ZoneAbilityHolder:SetSize(size, size)
    ZoneAbilityHolder.gwMover:SetSize(size, size)
end
GW.ExtraAB_BossAB_Setup = ExtraAB_BossAB_Setup