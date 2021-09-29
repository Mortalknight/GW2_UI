local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder

local function SkinAddonList()
    local AddonList = _G.AddonList

    _G.AddonList:StripTextures(true)
    _G.AddonListBg:Hide()
    AddonList.TitleBg:Hide()
    AddonList.TopTileStreaks:Hide()
    _G.AddonListInsetInsetTopBorder:Hide()
    _G.AddonListInsetInsetBottomBorder:Hide()
    _G.AddonListInsetInsetLeftBorder:Hide()
    _G.AddonListInsetInsetRightBorder:Hide()
    _G.AddonListInsetInsetTopLeftCorner:Hide()
    _G.AddonListInsetInsetTopRightCorner:Hide()
    _G.AddonListInsetInsetBotRightCorner:Hide()
    _G.AddonListInsetInsetBotLeftCorner:Hide()
    AddonListInset:CreateBackdrop(constBackdropFrameBorder)

    AddonList.TitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    local tex = AddonList:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", AddonList, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = AddonList:GetSize()
    tex:SetSize(w + 50, h + 50)
    AddonList.tex = tex

    AddonList.CloseButton:SkinButton(true)
    AddonList.EnableAllButton:SkinButton(false, true)
    AddonList.DisableAllButton:SkinButton(false, true)
    AddonList.OkayButton:SkinButton(false, true)
    AddonList.CancelButton:SkinButton(false, true)
    _G.AddonCharacterDropDown:SkinDropDownMenu()
    _G.AddonListForceLoad:SkinCheckButton()
    _G.AddonListForceLoad:SetSize(18, 18)

    AddonList.CloseButton:SetSize(25, 25)
    AddonList.CloseButton:ClearAllPoints()
    AddonList.CloseButton:SetPoint("TOPRIGHT", 0, 0)

    for i = 1, _G.MAX_ADDONS_DISPLAYED do
        _G["AddonListEntry" .. i .. "Enabled"]:SkinCheckButton()
        _G["AddonListEntry" .. i .. "Enabled"]:SetHitRectInsets(0, 0, 0, 0)
        _G["AddonListEntry" .. i .. "Enabled"]:SetSize(15, 15)
        _G["AddonListEntry"  ..  i].LoadAddonButton:SkinButton(false, true)
    end

    _G.AddonListScrollFrame:SkinScrollFrame()
    _G.AddonListScrollFrameScrollBar:SkinScrollBar()

    hooksecurefunc("TriStateCheckbox_SetState", function(checked, checkButton)
        local checkedTexture = _G[checkButton:GetName().."CheckedTexture"]
        -- 1 is a gray check
        if checked == 1 then
            checkedTexture:SetVertexColor(1, .93, .73)
        end
    end)
end
GW.SkinAddonList = SkinAddonList