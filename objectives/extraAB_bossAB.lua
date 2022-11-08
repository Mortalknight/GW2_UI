local _, GW = ...
local L = GW.L
local RegisterMovableFrame = GW.RegisterMovableFrame
local GetSetting = GW.GetSetting

local ExtraActionBarHolder, ZoneAbilityHolder, eventFrame
local NeedsReparentExtraButtons = false
local ExtraButtons = {}

local function ExtraButtons_ZoneScale()
    local scale = GetSetting("ZoneAbilityFramePos_scale")
    ZoneAbilityFrame.Style:SetScale(scale)
    ZoneAbilityFrame.SpellButtonContainer:SetScale(scale)

    local width, height = ZoneAbilityFrame.SpellButtonContainer:GetSize()
    ZoneAbilityHolder:SetSize(width * scale, height * scale)
    ZoneAbilityHolder.gwMover:SetSize(width * scale, height * scale)
end

local function ExtraButtons_UpdateScale()
    ExtraButtons_ZoneScale()

    local scale = GetSetting("ExtraActionBarFramePos_scale")
    ExtraActionBarFrame:SetScale(scale)

    local width, height = _G.ExtraActionBarFrame.button:GetSize()
    ExtraActionBarHolder:SetSize(width * scale, height * scale)
    ExtraActionBarHolder.gwMover:SetSize(width * scale, height * scale)

    ExtraActionButton1.QuickKeybindHighlightTexture:ClearAllPoints()
    ExtraActionButton1.QuickKeybindHighlightTexture:SetAllPoints(ExtraActionBarHolder.gwMover)
end

local function UpdateExtraBindings()
    for _, button in pairs(ExtraButtons) do
        button.HotKey:SetText(GetBindingKey(button.commandName))
        GW.updateHotkey(button)
        GW.FixHotKeyPosition(button)
    end
end

local function Reparent()
    if InCombatLockdown() then
        NeedsReparentExtraButtons = true
        eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    ZoneAbilityFrame:SetParent(ZoneAbilityHolder)
    ExtraActionBarFrame:SetParent(ExtraActionBarHolder)
end

local function OnEvent(self, event)
    if event == "UPDATE_BINDINGS" then
        UpdateExtraBindings()
    elseif event == "PLAYER_REGEN_ENABLED" then
        Reparent()
        NeedsReparentExtraButtons = false
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end



local function ExtraAB_BossAB_Setup()
    eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("UPDATE_BINDINGS")
    eventFrame:SetScript("OnEvent", OnEvent)

    ExtraActionBarHolder = CreateFrame("Frame", nil, UIParent)
    ExtraActionBarHolder:SetPoint("BOTTOM", UIParent, "BOTTOM", -150, 300)

    ZoneAbilityHolder = CreateFrame("Frame", nil, UIParent)
    ZoneAbilityHolder:SetPoint("BOTTOM", UIParent, "BOTTOM", 150, 300)

    ZoneAbilityFrame.SpellButtonContainer.holder = ZoneAbilityHolder

    -- try to shutdown the container movement and taints
    ExtraAbilityContainer.SetSize = GW.NoOp

    Reparent()

    RegisterMovableFrame(ExtraActionBarHolder, L["Boss Button"], "ExtraActionBarFramePos", "VerticalActionBarDummy", nil, {"default", "scaleable"})
    RegisterMovableFrame(ZoneAbilityHolder, L["Zone Ability"], "ZoneAbilityFramePos", "VerticalActionBarDummy", nil, {"default", "scaleable"})

    ZoneAbilityFrame:ClearAllPoints()
    ZoneAbilityFrame:SetAllPoints(ZoneAbilityHolder.gwMover)
    ZoneAbilityFrame.ignoreInLayout = true

    ExtraActionBarFrame:ClearAllPoints()
    ExtraActionBarFrame:SetAllPoints(ExtraActionBarHolder.gwMover)
    ExtraActionBarFrame.ignoreInLayout = true

    hooksecurefunc(ZoneAbilityFrame.SpellButtonContainer, "SetSize", ExtraButtons_ZoneScale)
    hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(frame)
        for spellButton in frame.SpellButtonContainer:EnumerateActive() do
            if spellButton and not spellButton.IsSkinned then
                spellButton.NormalTexture:SetAlpha(0)
                spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
                spellButton.Icon:SetDrawLayer("ARTWORK", -1)
                spellButton.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                spellButton.Icon:SetInside()

                if spellButton.Cooldown then
                    spellButton.Cooldown.CooldownOverride = "actionbar"
                    GW.RegisterCooldown(spellButton.Cooldown)
                    spellButton.Cooldown:SetInside(spellButton)
                end

                spellButton.holder = ZoneAbilityHolder

                spellButton.IsSkinned = true
            end
        end
    end)

    hooksecurefunc(ExtraAbilityContainer, "AddFrame", function(frame)
        local button = frame.button
        if button and not button.IsSkinned then
            local name = button.GetName and button:GetName()
            local cooldown = name and _G[name .. "Cooldown"]
            if cooldown then
                cooldown:SetInside()
                cooldown:SetDrawEdge(false)
                cooldown:SetSwipeColor(0, 0, 0, 1)
                GW.RegisterCooldown(cooldown)
            end

            ActionButton_UpdateCooldown(button)

            button.icon:SetDrawLayer("ARTWORK", -1)
            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

            button.holder = ExtraActionBarHolder

            local tex = button:CreateTexture(nil, "OVERLAY")
            tex:SetColorTexture(0.9, 0.8, 0.1, 0.3)
            button:SetCheckedTexture(tex)

            button.HotKey:SetText(GetBindingKey(button.commandName))
            tinsert(ExtraButtons, button)

            button.IsSkinned = true
        end
    end)

    hooksecurefunc(ZoneAbilityFrame, "SetParent", function(_, parent)
        if parent ~= ZoneAbilityHolder and not NeedsReparentExtraButtons then
            Reparent()
        end
    end)
    hooksecurefunc(ExtraActionBarFrame, "SetParent", function(_, parent)
        if parent ~= ExtraActionBarHolder and not NeedsReparentExtraButtons then
            Reparent()
        end
    end)

    ExtraButtons_UpdateScale()

    -- Spawn the mover before its available.
    local size = 52 * GetSetting("ZoneAbilityFramePos_scale")
    ZoneAbilityHolder:SetSize(size, size)
    ZoneAbilityHolder.gwMover:SetSize(size, size)
end
GW.ExtraAB_BossAB_Setup = ExtraAB_BossAB_Setup