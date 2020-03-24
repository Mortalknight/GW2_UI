local _, GW = ...
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder
local SkinButton = GW.skins.SkinButton
local SkinDropDownMenu = GW.skins.SkinDropDownMenu
local SkinCheckButton = GW.skins.SkinCheckButton
local SkinTab = GW.skins.SkinTab
local SkinSliderFrame = GW.skins.SkinSliderFrame

local OptionsFrames = {_G.VideoOptionsFrameCategoryFrame, _G.VideoOptionsFramePanelContainer, _G.Display_, _G.Graphics_, _G.RaidGraphics_,_G.AudioOptionsSoundPanelHardware, _G.AudioOptionsSoundPanelVolume, _G.AudioOptionsSoundPanelPlayback, _G.AudioOptionsVoicePanelTalking, _G.AudioOptionsVoicePanelListening, _G.AudioOptionsVoicePanelBinding}
local OptionsButtons = {_G.GraphicsButton, _G.RaidButton}

local InterfaceOptions = {
    _G.VideoOptionsFrame,
    _G.Display_,
    _G.Graphics_,
    _G.RaidGraphics_,
    _G.Advanced_,
    _G.NetworkOptionsPanel,
    _G.InterfaceOptionsLanguagesPanel,
    _G.AudioOptionsSoundPanel,
    _G.AudioOptionsSoundPanelHardware,
    _G.AudioOptionsSoundPanelVolume,
    _G.AudioOptionsSoundPanelPlayback,
    _G.AudioOptionsVoicePanel,
    _G.AudioOptionsVoicePanelTalking,
    _G.AudioOptionsVoicePanelListening,
    _G.AudioOptionsVoicePanelBinding,
    _G.AudioOptionsVoicePanelMicTest,
    _G.AudioOptionsVoicePanelChatMode1,
    _G.AudioOptionsVoicePanelChatMode2,
}

local function SkinSystemSettings()
    local VideoOptionsFrame = _G.VideoOptionsFrame

    VideoOptionsFrame.Header.CenterBG:Hide()
    VideoOptionsFrame.Header.RightBG:Hide()
    VideoOptionsFrame.Header.LeftBG:Hide()
    VideoOptionsFrame.Header.Text:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    VideoOptionsFrame.Border:Hide()
    local tex = VideoOptionsFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", VideoOptionsFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = VideoOptionsFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    VideoOptionsFrame.tex = tex

    for _, Frame in pairs(OptionsFrames) do
		Frame:SetBackdrop(constBackdropFrameBorder)
    end

    for _, Tab in pairs(OptionsButtons) do
		SkinTab(Tab)
	end
    
    for _, Panel in pairs(InterfaceOptions) do
		if Panel then
			for i = 1, Panel:GetNumChildren() do
				local Child = select(i, Panel:GetChildren())
				if Child:IsObjectType("CheckButton") then
                    SkinCheckButton(Child)
                    Child:SetSize(15, 15)
				elseif Child:IsObjectType("Button") then
					SkinButton(Child, false, true)
				elseif Child:IsObjectType('Slider') then
					SkinSliderFrame(Child)
				elseif Child:IsObjectType("Tab") then
                    SkinTab(Child)
				elseif Child:IsObjectType("Frame") and Child.Left and Child.Middle and Child.Right then
					SkinDropDownMenu(Child)
				end
			end
		end
	end
end
GW.SkinSystemSettings = SkinSystemSettings