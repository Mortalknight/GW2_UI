---@class GW2
local GW = select(2, ...)

-- the shaman totem selection (MultiCastActionBarFrame) of the classic clients and Forever: Blizzard keeps
-- its logic and lays the buttons out in a row, the bar moves into a frame of ours with a mover and gets our look
local PUSHED_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed.png"
local HIGHLIGHT_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png"
local ARROW_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/arrowup_up.png"

local holder
local anchoring = false
local skinned = {}
local elementBorders = {}

local function GetElementColor(slot)
    local colors = GW.Colors.TotemColors
    return (slot == EARTH_TOTEM_SLOT and colors.Earth) or (slot == FIRE_TOTEM_SLOT and colors.Fire)
        or (slot == WATER_TOTEM_SLOT and colors.Water) or (slot == AIR_TOTEM_SLOT and colors.Air) or nil
end

local function SetBorderColor(button, color)
    local border = elementBorders[button]
    if not border then
        return
    end
    border:SetShown(color ~= nil)
    if color then
        border:SetBackdropBorderColor(color:GetRGB())
    end
end

local function SkinButton(button, icon, noBackdrop)
    if skinned[button] then
        return
    end
    if icon then
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end
    local normal = button:GetNormalTexture()
    if normal then
        normal:SetAlpha(0)
    end
    if button.overlayTex then
        button.overlayTex:SetAlpha(0)
    end
    -- blizzards template insets the cooldown into the icon, like our action bars it covers the whole button
    if button.cooldown then
        button.cooldown:ClearAllPoints()
        button.cooldown:SetAllPoints(button)
    end
    button:SetPushedTexture(PUSHED_TEXTURE)
    button:SetHighlightTexture(HIGHLIGHT_TEXTURE)
    if button.SetCheckedTexture then
        button:SetCheckedTexture(HIGHLIGHT_TEXTURE)
    end
    -- the action buttons come with atlas textures, their coords would cut a piece out of ours
    for _, texture in ipairs({button:GetPushedTexture(), button:GetHighlightTexture(), button.GetCheckedTexture and button:GetCheckedTexture()}) do
        texture:SetTexCoord(0, 1, 0, 1)
    end

    skinned[button] = true
    if not noBackdrop then
        local backdrop = CreateFrame("Frame", nil, button, "GwActionButtonBackdropTmpl")
        backdrop:SetPoint("TOPLEFT", -1, 1)
        backdrop:SetPoint("BOTTOMRIGHT", 1, -1)
        backdrop:SetFrameLevel(math.max(button:GetFrameLevel() - 1, 0))

        -- the borders of the backdrop are black art that does not take a color, the element gets a border of its own
        local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
        border:SetBackdrop(GW.BackdropTemplates.ColorableBorderOnly)
        border:SetAllPoints(backdrop)
        border:SetFrameLevel(button:GetFrameLevel() + 5)
        border:Hide()
        elementBorders[button] = border
    end
end

-- the open and close buttons of the flyout show an arrow of ours instead of blizzards colored one
-- the hover is the same arrow, added on top
local function SkinArrowButton(button, rotate)
    button.normalTexture:SetAlpha(0)
    local arrow = button:CreateTexture(nil, "OVERLAY")
    arrow:SetTexture(ARROW_TEXTURE)
    button:SetHighlightTexture(ARROW_TEXTURE, "ADD")
    for _, texture in ipairs({arrow, button:GetHighlightTexture()}) do
        texture:SetTexCoord(0, 1, 0, 1)
        texture:ClearAllPoints()
        texture:SetSize(16, 16)
        texture:SetPoint("CENTER")
        if rotate then
            texture:SetRotation(math.pi)
        end
    end
end

-- blizzard moves the bar on its own: edit mode layouts, the slide in and out on wrath
local function AnchorToHolder()
    if InCombatLockdown() then
        GW.CombatQueue:Queue("GwTotemSelectionAnchor", AnchorToHolder)
        return
    end
    local bar = MultiCastActionBarFrame
    anchoring = true
    bar:ClearAllPoints();
    (bar.SetPointBase or bar.SetPoint)(bar, "BOTTOMLEFT", holder, "BOTTOMLEFT", 0, 0)
    anchoring = false
end

local function OnSlotUpdate(button, slot)
    SetBorderColor(button, GetElementColor(slot))
end

-- the flyout buttons are created when the flyout opens the first time; blizzard sets their icon coords on every open,
-- the empty slot entry keeps its own
local function OnToggleFlyout(flyout, flyoutType, parent)
    local color = flyoutType == "slot" and GetElementColor(parent:GetID()) or nil
    for i, button in ipairs(flyout.buttons or {}) do
        SkinButton(button, nil)
        if not (flyoutType == "slot" and i == 1) then
            button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        end
        SetBorderColor(button, color)
    end
end

function GW.LoadTotemSelectionBar()
    local bar = MultiCastActionBarFrame
    if not bar or GW.myclass ~= "SHAMAN" then
        return
    end
    -- the bar holds secure buttons, after a reload in combat it moves once the fight is over
    if InCombatLockdown() then
        GW.CombatQueue:Queue("GwTotemSelectionLoad", GW.LoadTotemSelectionBar)
        return
    end

    holder = CreateFrame("Frame", "GwTotemSelectionBar", UIParent)
    holder:SetSize(bar:GetSize())
    GW.RegisterMovableFrame(holder, HUD_EDIT_MODE_TOTEM_ACTION_BAR_LABEL or GW.L["Totem Bar"], "totemSelection", BINDING_HEADER_ACTIONBAR, nil, {GW.MoverOption.Scale})
    holder:ClearAllPoints()
    holder:SetPoint("TOPLEFT", holder.gwMover)
    -- on wrath the bar went with the main menu bar, that hides in vehicles
    RegisterStateDriver(holder, "visibility", "[overridebar][vehicleui][petbattle] hide; show")

    bar:SetParent(holder)
    if bar.Selection then
        bar:GwKillEditMode()
    end
    hooksecurefunc(bar, "SetPoint", function()
        if not anchoring then
            AnchorToHolder()
        end
    end)
    AnchorToHolder()

    for i = 1, NUM_MULTI_CAST_BUTTONS_PER_PAGE do
        -- the empty slot art keeps blizzards coords
        local slotButton = _G["MultiCastSlotButton" .. i]
        SkinButton(slotButton)
        OnSlotUpdate(slotButton, slotButton:GetID())
    end
    -- the action buttons lie on the slot buttons, those bring the border
    for i = 1, NUM_MULTI_CAST_PAGES * NUM_MULTI_CAST_BUTTONS_PER_PAGE do
        local button = _G["MultiCastActionButton" .. i]
        SkinButton(button, button.icon, true)
    end
    for _, button in ipairs({MultiCastSummonSpellButton, MultiCastRecallSpellButton}) do
        local name = button:GetName()
        SkinButton(button, _G[name .. "Icon"])
        _G[name .. "Highlight"]:SetAlpha(0)
    end

    MultiCastFlyoutFrame.top:SetAlpha(0)
    MultiCastFlyoutFrame.middle:SetAlpha(0)
    SkinArrowButton(MultiCastFlyoutFrameOpenButton)
    SkinArrowButton(MultiCastFlyoutFrameCloseButton, true)

    hooksecurefunc("MultiCastSlotButton_Update", OnSlotUpdate)
    hooksecurefunc("MultiCastFlyoutFrame_ToggleFlyout", OnToggleFlyout)
end
