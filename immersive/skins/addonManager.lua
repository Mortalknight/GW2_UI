local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder
local SkinButton = GW.skins.SkinButton
local SkinDropDownMenu = GW.skins.SkinDropDownMenu
local SkinCheckButton = GW.skins.SkinCheckButton
local SkinScrollBar = GW.skins.SkinScrollBar
local SkinScrollFrame = GW.skins.SkinScrollFrame

local function SkinAddonList()
    local AddonList = _G.AddonList

    _G.AddonListTopBorder:Hide()
    _G.AddonListLeftBorder:Hide()
    _G.AddonListRightBorder:Hide()
    _G.AddonListBottomBorder:Hide()
    _G.AddonListTopLeftCorner:Hide()
    _G.AddonListTopRightCorner:Hide()
    _G.AddonListBotRightCorner:Hide()
    _G.AddonListBotLeftCorner:Hide()
    _G.AddonListBtnCornerLeft:Hide()
    _G.AddonListBtnCornerRight:Hide()
    _G.AddonListButtonBottomBorder:Hide()
    _G.AddonListBg:Hide()
    AddonList.TitleBg:Hide()
    AddonList.TopTileStreaks:Hide()
    AddonList:SetBackdrop(nil)
    _G.AddonListInsetInsetTopBorder:Hide()
    _G.AddonListInsetInsetBottomBorder:Hide()
    _G.AddonListInsetInsetLeftBorder:Hide()
    _G.AddonListInsetInsetRightBorder:Hide()
    _G.AddonListInsetInsetTopLeftCorner:Hide()
    _G.AddonListInsetInsetTopRightCorner:Hide()
    _G.AddonListInsetInsetBotRightCorner:Hide()
    _G.AddonListInsetInsetBotLeftCorner:Hide()
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
        _G["AddonListEntry" .. i .. "Enabled"]:SetHitRectInsets(0, 0, 0, 0)
        _G["AddonListEntry" .. i .. "Enabled"]:SetSize(15, 15)
        SkinButton(_G["AddonListEntry"  ..  i].LoadAddonButton, false, true)
    end

    SkinScrollFrame(_G.AddonListScrollFrame)
    SkinScrollBar(_G.AddonListScrollFrameScrollBar)

    hooksecurefunc("TriStateCheckbox_SetState", function(checked, checkButton)
        local checkedTexture = _G[checkButton:GetName().."CheckedTexture"]
        -- 1 is a gray check
        if checked == 1 then
            checkedTexture:SetVertexColor(1, .93, .73)
        end
    end)
end
GW.SkinAddonList = SkinAddonList