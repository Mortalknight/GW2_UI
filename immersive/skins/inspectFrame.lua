local _, GW = ...

local InscpectSlots = {
    ["InspectHeadSlot"] = {0, 0.25, 0, 0.25},
    ["InspectNeckSlot"] = {0.25, 0.5, 0, 0.25},
    ["InspectShoulderSlot"] = {0.5, 0.75, 0.5, 0.75},
    ["InspectBackSlot"] = {0.75, 1, 0, 0.25},
    ["InspectChestSlot"] = {0.75, 1, 0.5, 0.75},
    ["InspectShirtSlot"] = {0.75, 1, 0.5, 0.75},
    ["InspectTabardSlot"] = {0.25, 0.5, 0.75, 1},
    ["InspectWristSlot"] = {0.75, 1, 0.25, 0.5},
    ["InspectHandsSlot"] = {0, 0.25, 0.75, 1},
    ["InspectWaistSlot"] = {0.25, 0.5, 0.5, 0.75},
    ["InspectLegsSlot"] = {0, 0.25, 0.5, 0.75},
    ["InspectFeetSlot"] = {0.5, 0.75, 0.25, 0.5},
    ["InspectFinger0Slot"] = {0.5, 0.75, 0, 0.25},
    ["InspectFinger1Slot"] = {0.5, 0.75, 0, 0.25},
    ["InspectTrinket0Slot"] = {0.5, 0.75, 0.75, 1},
    ["InspectTrinket1Slot"] = {0.5, 0.75, 0.75, 1},
    ["InspectMainHandSlot"] = {0.25, 0.5, 0.25, 0.5},
    ["InspectSecondaryHandSlot"] = {0, 0.25, 0.25, 0.5},
}

local function SkinInspectFrameOnLoad()
    InspectFrame:StripTextures()
    InspectFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    InspectFrameCloseButton:SkinButton(true)
    InspectFrameCloseButton:SetSize(20, 20)
    InspectPaperDollFrame.ViewButton:SkinButton(false, true)
    local tex = InspectFrame:CreateTexture("bg", "BACKGROUND", 0)
    tex:SetPoint("TOP", InspectFrame, "TOP", 0, 20)
    local w, h = InspectFrame:GetSize()
    tex:SetSize(w + 50, h + 70)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    InspectFrame.tex = tex

    -- PVE Talents
    for i = 1, 7 do
        for j = 1, 3 do
            local button = _G["TalentsTalentRow" .. i .. "Talent" .. j]

            button:StripTextures()
            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        end
    end

    -- PVP Talents
    for i = 1, 3 do
        local icon = InspectPVPFrame["TalentSlot" .. i].Texture
        InspectPVPFrame["TalentSlot" .. i]:StripTextures()
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        InspectPVPFrame["TalentSlot" .. i].Border:Hide()
    end

    for i = 1, 4 do
        _G["InspectFrameTab" .. i]:SkinButton(false, true)
        _G["InspectFrameTab" .. i]:SetSize(80, 24)
        if i > 1 then
            _G["InspectFrameTab" .. i]:ClearAllPoints()
            _G["InspectFrameTab" .. i]:SetPoint("RIGHT",  _G["InspectFrameTab" .. i - 1], "RIGHT", 75, 0)
        end
    end

    hooksecurefunc("PanelTemplates_SelectTab", function(tab)
        local name = tab:GetName()
        local text = tab.Text or _G[name .. "Text"]
        text:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), (tab.deselectedTextY or 2))
    end)

    InspectModelFrame:StripTextures()
    InspectModelFrameBorderTopLeft:Kill()
    InspectModelFrameBorderTopRight:Kill()
    InspectModelFrameBorderTop:Kill()
    InspectModelFrameBorderLeft:Kill()
    InspectModelFrameBorderRight:Kill()
    InspectModelFrameBorderBottomLeft:Kill()
    InspectModelFrameBorderBottomRight:Kill()
    InspectModelFrameBorderBottom:Kill()
    InspectModelFrameBorderBottom2:Kill()

    InspectModelFrame.BackgroundOverlay:SetColorTexture(0, 0, 0)

    -- Give inspect frame model backdrop it's color back
    for _, corner in pairs({"TopLeft","TopRight","BotLeft","BotRight"}) do
        local bg = _G["InspectModelFrameBackground" .. corner]
        if bg then
            bg:SetDesaturated(false)
            hooksecurefunc(bg, "SetDesaturated", function(bckgnd, value)
                if value and bckgnd.ignoreDesaturated then
                    bckgnd:SetDesaturated(false)
                end
            end)
        end
    end

    for _, Slot in pairs({InspectPaperDollItemsFrame:GetChildren()}) do
        if Slot:IsObjectType("Button") or Slot:IsObjectType("ItemButton") then
            Slot.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            Slot:StripTextures()
        end
    end

    hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
        local textureName = GetInventoryItemTexture(InspectFrame.unit, button:GetID())
        if not textureName then
            button.icon:SetTexture("Interface/AddOns/GW2_UI/textures/character/slot-bg")
            button.icon:SetTexCoord(unpack(InscpectSlots[button:GetName()]))
        end
    end)

    InspectPVPFrame.BG:Kill()
    InspectGuildFrameBG:Kill()
    InspectTalentFrame:StripTextures()
end

local function SkinInspectFrame()
    hooksecurefunc("InspectFrame_LoadUI", SkinInspectFrameOnLoad)
end
GW.SkinInspectFrame = SkinInspectFrame
