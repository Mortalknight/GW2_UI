---@class GW2
local GW = select(2, ...)

local GIZMO_ICON = "Interface/Icons/inv_gizmo_03"

-- the machine art and its slots stay, the window gets our header and the items our icon border
local function ApplyScrappingMachineSkin()
    if not GW.settings.skins.scrappingMachine.enabled then return end
    local frame = ScrappingMachineFrame

    GW.HandlePortraitFrame(frame)
    GW.HandlePortraitFrameArt(frame)
    if frame.TitleContainer then
        frame.TitleContainer:Hide()
    end
    GW.CreateFrameHeaderWithBody(frame, frame:GetTitleText(), nil, nil, nil, nil, true)
    GW.SetHeaderPortrait(frame.gwHeader, "player")
    frame.gwHeader.windowIcon:SetTexture(GIZMO_ICON)
    frame.gwHeader.windowIcon:SetSize(48, 48)
    frame.gwHeader.windowIcon:ClearAllPoints()
    frame.gwHeader.windowIcon:SetPoint("CENTER", frame.gwHeader, "BOTTOMLEFT", 30, 19)

    for button in frame.ItemSlots.scrapButtons:EnumerateActive() do
        GW.HandleIcon(button.Icon, true, GW.BackdropTemplates.ColorableBorderOnly, true)
        GW.HandleIconBorder(button.IconBorder, button.Icon.backdrop)
    end

    frame.ScrapButton:GwSkinButton(false, true)
end

local function LoadScrappingMachineSkin()
    GW.RegisterLoadHook(ApplyScrappingMachineSkin, "Blizzard_ScrappingMachineUI", ScrappingMachineFrame)
end
GW.LoadScrappingMachineSkin = LoadScrappingMachineSkin
