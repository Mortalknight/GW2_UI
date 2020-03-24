local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder
local SkinButton = GW.skins.SkinButton
local SkinDropDownMenu = GW.skins.SkinDropDownMenu
local SkinCheckButton = GW.skins.SkinCheckButton

local function SkinAddonList()
    local AddonList = _G.AddonList

    AddonList.NineSlice:Hide()
    _G.AddonListBg:Hide()
    AddonList.TitleBg:Hide()
    AddonList.TopTileStreaks:Hide()
    AddonList:SetBackdrop(nil)
    _G.AddonListInset.NineSlice:Hide()
    _G.AddonListInset:SetBackdrop(constBackdropFrameBorder)

    AddonList.TitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    local tex = AddonList:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", AddonList, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = AddonList:GetSize()
    tex:SetSize(w + 50, h + 50)
    AddonList.tex = tex

    SkinButton(AddonList.CloseButton, true)
    SkinButton(AddonList.EnableAllButton, false, true)
    SkinButton(AddonList.DisableAllButton, false, true)
    SkinButton(AddonList.OkayButton, false, true)
    SkinButton(AddonList.CancelButton, false, true)
    SkinDropDownMenu(_G.AddonCharacterDropDown)
    SkinCheckButton(_G.AddonListForceLoad)
    _G.AddonListForceLoad:SetSize(18, 18)

    AddonList.CloseButton:SetSize(25, 25)
    AddonList.CloseButton:ClearAllPoints()
    AddonList.CloseButton:SetPoint("TOPRIGHT", 0, 0)

    _G.AddonListScrollFrame:SetBackdrop(nil)

    for i = 1, _G.MAX_ADDONS_DISPLAYED do
        SkinCheckButton(_G["AddonListEntry" .. i .. "Enabled"])
        _G["AddonListEntry" .. i .. "Enabled"]:SetSize(15, 15)
        SkinButton(_G["AddonListEntry"  ..  i].LoadAddonButton, false, true)
	end

    _G.AddonListScrollFrameScrollBarTop:Hide()
    _G.AddonListScrollFrameScrollBarBottom:Hide()
    _G.AddonListScrollFrameScrollBarMiddle:SetTexture("Interface/AddOns/GW2_UI/textures/scrollbg")
    _G.AddonListScrollFrameScrollBarMiddle:SetSize(3, _G.AddonListScrollFrameScrollBarMiddle:GetSize())
    _G.AddonListScrollFrameScrollBarMiddle:ClearAllPoints()
    _G.AddonListScrollFrameScrollBarMiddle:SetPoint("TOPLEFT", _G.AddonListScrollFrame, "TOPRIGHT", 12, -10)
    _G.AddonListScrollFrameScrollBarMiddle:SetPoint("BOTTOMLEFT", _G.AddonListScrollFrame,"BOTTOMRIGHT", 12, 10)

    _G.AddonListScrollFrameScrollBarThumbTexture:SetTexture("Interface/AddOns/GW2_UI/textures/scrollbarmiddle")
    _G.AddonListScrollFrameScrollBarThumbTexture:SetSize(12, _G.AddonListScrollFrameScrollBarThumbTexture:GetSize())
    _G.AddonListScrollFrameScrollBarScrollUpButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")
    _G.AddonListScrollFrameScrollBarScrollUpButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")
    _G.AddonListScrollFrameScrollBarScrollUpButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")
    _G.AddonListScrollFrameScrollBarScrollUpButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")
    _G.AddonListScrollFrameScrollBarScrollDownButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    _G.AddonListScrollFrameScrollBarScrollDownButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    _G.AddonListScrollFrameScrollBarScrollDownButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    _G.AddonListScrollFrameScrollBarScrollDownButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
end
GW.SkinAddonList = SkinAddonList