local _, GW = ...

local function LoadHelperFrameSkin()
    if not GW.GetSetting("HELPFRAME_SKIN_ENABLED") then return end

    _G.HelpFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    _G.HelpFrameTitleText:ClearAllPoints()
    _G.HelpFrameTitleText:SetPoint("TOP", _G.HelpFrame, "TOP", 0, 5)
    local HelpFrame = _G.HelpFrame
    HelpFrame:StripTextures(true)
    HelpFrame:CreateBackdrop()
    local tex = HelpFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", HelpFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = HelpFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    HelpFrame.tex = tex

    _G.HelpFrameCloseButton:SkinButton(true)
    _G.HelpFrameCloseButton:SetSize(25, 25)
    _G.HelpFrameCloseButton:ClearAllPoints()
    _G.HelpFrameCloseButton:SetPoint("TOPRIGHT", _G.HelpFrame, "TOPRIGHT", 0, 5)

    local browser = _G.HelpBrowser
    browser.BrowserInset:StripTextures()
    browser:CreateBackdrop()
    browser.backdrop:ClearAllPoints()
    browser.backdrop:SetPoint("TOPLEFT", browser, "TOPLEFT", -1, 1)
    browser.backdrop:SetPoint("BOTTOMRIGHT", browser, "BOTTOMRIGHT", 1, -2)

end
GW.LoadHelperFrameSkin = LoadHelperFrameSkin
