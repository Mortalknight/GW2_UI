local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame

local function SkinGearManagerDialogPopup_OnShow()
    local GearManagerDialogPopup = _G.GearManagerDialogPopup

    GearManagerDialogPopup.BG:Hide()
    local r = {GearManagerDialogPopup.BorderBox:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            c:Hide()
        end
    end
    GearManagerDialogPopup.BorderBox.NameText:SetFont(DAMAGE_TEXT_FONT, 12)
    GearManagerDialogPopup.BorderBox.ChooseIconText:SetFont(DAMAGE_TEXT_FONT, 12)
    GearManagerDialogPopup:SetSize(GearManagerDialogPopup:GetSize(), GearManagerDialogPopup:GetSize() + 5)
    GearManagerDialogPopup:SetBackdrop(constBackdropFrame)
    --Change EditBox
    _G["GearManagerDialogPopupEditBoxLeft"]:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar-bg")
    _G["GearManagerDialogPopupEditBoxRight"]:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar-bg")
    _G["GearManagerDialogPopupEditBoxMiddle"]:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar-bg")

    local GearManagerDialogPopupCancel = _G.GearManagerDialogPopupCancel

    GearManagerDialogPopupCancel:SkinButton(false, true)
    GearManagerDialogPopupCancel:ClearAllPoints()
    GearManagerDialogPopupCancel:SetPoint("BOTTOMRIGHT" ,-11, 20)

    _G.GearManagerDialogPopupOkay:SkinButton(false, true)
    _G.GearManagerDialogPopupScrollFrame:SkinScrollFrame()
    _G.GearManagerDialogPopupScrollFrameScrollBar:SkinScrollBar()
end

local function SkinGearManagerDialogPopupButtons_OnUpdate()
    local texture, index, button
    local popup = _G.GearManagerDialogPopup
    local buttons = popup.buttons
    local offset = FauxScrollFrame_GetOffset(_G.GearManagerDialogPopupScrollFrame) or 0

    for i = 1, NUM_GEARSET_ICONS_SHOWN do
        local button = buttons[i]
        index = (offset * NUM_GEARSET_ICONS_PER_ROW) + i
        if index <= 90 then
            local ii = 1
            local r = {button:GetRegions()}
            for _,c in pairs(r) do
                if c:GetObjectType() == "Texture" then
                    if ii == 1 then
                        c:Hide()
                    end
                    ii = ii + 1
                end
            end
            texture = GetEquipmentSetIconInfo(index)
            if(type(texture) == "number") then
                button.icon:SetTexture(texture)
                button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            else
                button.icon:SetTexture("INTERFACE/ICONS/" .. texture)
                button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            end
            button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/UI-Quickslot-Depress")
            button:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/UI-Quickslot-Depress")
        end
    end
end

local function SkinGearManagerDialogPopup()
    hooksecurefunc("GearManagerDialogPopup_Update", SkinGearManagerDialogPopupButtons_OnUpdate)
    SkinGearManagerDialogPopup_OnShow()
end
GW.SkinGearManagerDialogPopup = SkinGearManagerDialogPopup