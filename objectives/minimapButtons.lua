local _, GW = ...

local buttons = {}
local ignoreButton = {
	"GameTimeFrame",
	"HelpOpenWebTicketButton",
	"MiniMapVoiceChatFrame",
	"TimeManagerClockButton",
	"BattlefieldMinimap",
	"ButtonCollectFrame",
	"GameTimeFrame",
	"QueueStatusMinimapButton",
	"GarrisonLandingPageMinimapButton",
	"MiniMapMailFrame",
	"MiniMapTracking",
	"MinimapZoomIn",
	"MinimapZoomOut",
	"RecipeRadarMinimapButtonFrame",
	"InstanceDifficultyFrame",
    "GwMapFPS",
    "GwMapCoords",
    "GwMapTime",
    "GwMiniMapTrackingFrame"
}
local genericIgnore = {
	"Archy",
	"GatherMatePin",
	"GatherNote",
	"GuildInstance",
	"HandyNotesPin",
	"MiniMap",
	"Spy_MapNoteList_mini",
	"ZGVMarker",
	"poiMinimap",
	"GuildMap3Mini",
	"LibRockConfig-1.0_MinimapButton",
	"NauticusMiniIcon",
	"WestPointer",
	"Cork",
	"DugisArrowMinimapPoint",
	"QuestieFrame",
    "ElvConfigToggle"
}
local partialIgnore = {
    "Node",
    "Note",
    "Pin",
    "POI"
}
local RemoveTextureID = {
    [136430] = true,
    [136467] = true,
    [136468] = true,
    [130924] = true,
    [136477] = true,
}
local RemoveTextureFile = {
    ["interface/minimap/minimap-trackingborder"] = true,
    ["interface/minimap/ui-minimap-border"] = true,
    ["interface/minimap/ui-minimap-background"] = true,
}
local buttonFunctions = {
    "SetParent",
    "ClearAllPoints",
    "SetPoint",
    "SetSize",
    "SetScale",
    "SetFrameStrata",
    "SetFrameLevel"
}

local function SkinMinimapButton(button)
    if button.isSkinnedGW2_UI then return end

    local name = button.GetName and button:GetName()

    if tContains(ignoreButton, name) then return end

	for i = 1, #genericIgnore do
		if strsub(name, 1, strlen(genericIgnore[i])) == genericIgnore[i] then return end
	end

	for i = 1, #partialIgnore do
		if strfind(name, "LibDBIcon") == nil and strfind(name, partialIgnore[i]) ~= nil then return end
	end

    for i = 1, button:GetNumRegions() do
        local region = select(i, button:GetRegions())
        if region.IsObjectType and region:IsObjectType("Texture") then
            local texture = region.GetTextureFileID and region:GetTextureFileID()

            if RemoveTextureID[texture] then
                region:SetTexture()
            else
                texture = strlower(tostring(region:GetTexture()))
                if RemoveTextureFile[texture] or (strfind(texture, [[interface\characterframe]]) or (strfind(texture, [[interface\minimap]]) and not strfind(texture, [[interface\minimap\tracking\]])) or strfind(texture, "border") or strfind(texture, "background") or strfind(texture, "alphamask") or strfind(texture, "highlight")) then
                    region:SetTexture()
                    region:SetAlpha(0)
                else
                    region:ClearAllPoints()
                    region:SetDrawLayer("ARTWORK")
                    region:SetPoint("TOPLEFT", region:GetParent(), "TOPLEFT", 2, -2)
                    region:SetPoint("BOTTOMRIGHT", region:GetParent(), "BOTTOMRIGHT", -2, 2)

                    region.SetPoint = GW.NoOp
                end
            end
        end
    end

    button:SetFrameLevel(Minimap:GetFrameLevel() + 10)
	button:SetFrameStrata(Minimap:GetFrameStrata())
	button:SetSize(25, 25)
    button:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder)
    button:HookScript("OnEnter", function(self)
        if self.icon then self.icon:SetBlendMode("ADD") end
        if self.texture then self.texture:SetBlendMode("ADD") end
    end)
    button:HookScript("OnLeave", function(self)
        if self.icon then self.icon:SetBlendMode("BLEND") end
        if self.texture then self.texture:SetBlendMode("BLEND") end
    end)

	button.isSkinnedGW2_UI = true
    tinsert(buttons, button)
end

local function LockButton(self)
	for _, func in pairs(buttonFunctions) do
		self[func] = GW.NoOp
	end
end

local function UnlockButton(self)
	for _, func in pairs(buttonFunctions) do
		self[func] = nil
	end
end

local function UpdateButtons(self)
    local frameIndex, prevFrame = 0, self.container

    for _, button in pairs(buttons) do
        if button:IsShown() then
			UnlockButton(button)

			button:SetParent(self.container)
            button:ClearAllPoints()
            button:SetPoint("RIGHT", prevFrame, "RIGHT", frameIndex == 0 and -5 or -27, 0)
            frameIndex = frameIndex + 1
            prevFrame = button

			button:SetScale(1)
			button:SetFrameStrata("MEDIUM")
			button:SetFrameLevel(self.container:GetFrameLevel() + 1)

			if button:HasScript("OnDragStart") then button:SetScript("OnDragStart", nil) end
			if button:HasScript("OnDragStop") then button:SetScript("OnDragStop", nil) end

			LockButton(button)
		end
    end

    self.container:SetWidth(frameIndex * 25 + (frameIndex - 1) * 2 + 10)
    if frameIndex == 0 then
        self:Hide()
    end
end

local function GrabIcons(self)
    if InCombatLockdown() then return end

    local children = {Minimap:GetChildren()}
    for _, frame in ipairs(children) do
        if frame then
            local name = frame:GetName()
            local width = frame:GetWidth()
            if name and width > 15 and width < 40 and (frame:IsObjectType("Button") or frame:IsObjectType("Frame")) then
                SkinMinimapButton(frame)
            end
        end
    end

    UpdateButtons(self)
end
GW.AddForProfiling("map", "GrabIcons", GrabIcons)

local function stack_OnClick(self)
    GrabIcons(self)
    if self.container:IsShown() then
        UIFrameFadeOut(self.container, 0.2, 1, 0)
        C_Timer.After(0.2, function() self.container:Hide() end)
    else
        UIFrameFadeIn(self.container, 0.2, 0, 1)
    end

end
GW.AddForProfiling("map", "stack_OnClick", stack_OnClick)

local function CreateMinimapButtonsSack()
    local minimapButton = CreateFrame("Button", "GwAddonToggle", UIParent, "GwAddonToggle")
    minimapButton:SetScript("OnClick", stack_OnClick)
    minimapButton:SetScript("OnEvent", GrabIcons)
    minimapButton:RegisterEvent("PLAYER_ENTERING_WORLD")
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton.container:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
    minimapButton.gw_Showing = true
    GrabIcons(minimapButton)

    C_Timer.NewTicker(6, function() GrabIcons(minimapButton) end)
end
GW.CreateMinimapButtonsSack = CreateMinimapButtonsSack