local _, GW = ...
local GetSetting = GW.GetSetting

local function LoadHelperFrameSkin()
    if not GetSetting("HELPFRAME_SKIN_ENABLED") then return end

    HelpFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    HelpFrameTitleText:ClearAllPoints()
    HelpFrameTitleText:SetPoint("TOP", HelpFrame, "TOP", 0, 5)

    HelpFrame:GwStripTextures(true)
    HelpFrame:GwCreateBackdrop()
    local tex = HelpFrame:CreateTexture(nil, "BACKGROUND")
    tex:SetPoint("TOP", HelpFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = HelpFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    HelpFrame.tex = tex

    HelpFrame.CloseButton:GwSkinButton(true)
    HelpFrame.CloseButton:SetSize(25, 25)
    HelpFrame.CloseButton:ClearAllPoints()
    HelpFrame.CloseButton:SetPoint("TOPRIGHT", _G.HelpFrame, "TOPRIGHT", 0, 5)

    local browser = _G.HelpBrowser
    browser.BrowserInset:GwStripTextures()
    browser:GwCreateBackdrop()
    browser.backdrop:ClearAllPoints()
    browser.backdrop:SetPoint("TOPLEFT", browser, "TOPLEFT", -1, 1)
    browser.backdrop:SetPoint("BOTTOMRIGHT", browser, "BOTTOMRIGHT", 1, -2)

end
GW.LoadHelperFrameSkin = LoadHelperFrameSkin
