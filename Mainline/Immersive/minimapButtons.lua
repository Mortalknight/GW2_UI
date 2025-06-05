local _, GW = ...

local ignoreButtonLookup = {
    GameTimeFrame = true,
    HelpOpenWebTicketButton = true,
    MiniMapVoiceChatFrame = true,
    TimeManagerClockButton = true,
    BattlefieldMinimap = true,
    ButtonCollectFrame = true,
    QueueStatusMinimapButton = true,
    GarrisonLandingPageMinimapButton = true,
    MiniMapMailFrame = true,
    MiniMapTracking = true,
    MinimapZoomIn = true,
    MinimapZoomOut = true,
    RecipeRadarMinimapButtonFrame = true,
    InstanceDifficultyFrame = true,
    GwMapFPS = true,
    GwMapCoords = true,
    GwMapTime = true,
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
    "POI",
    "TTMinimapButton"
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

local buttons = {}

local function SkinMinimapButton(button)
    if button.isSkinned then return end

    local name = button.GetName and button:GetName()
    if not name then
        return
    end

    if ignoreButtonLookup[name] then
        return
    end

    for i = 1, #genericIgnore do
        local prefix = genericIgnore[i]
        if name:sub(1, #prefix) == prefix then
            return
        end
    end

    if not name:find("LibDBIcon") then
        for i = 1, #partialIgnore do
            if name:find(partialIgnore[i]) then
                return
            end
        end
    end

    for i = 1, button:GetNumRegions() do
        local region = select(i, button:GetRegions())
        if region and region.IsObjectType and region:IsObjectType("Texture") then
            local texture = region.GetTextureFileID and region:GetTextureFileID()

            if texture and RemoveTextureID[texture] then
                region:SetTexture(nil)
            else
                texture = region:GetTexture() or ""
                texture = tostring(texture):lower()
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
    button:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    button:HookScript("OnEnter", function(self)
        if self.icon then self.icon:SetBlendMode("ADD") end
        if self.texture then self.texture:SetBlendMode("ADD") end
    end)
    button:HookScript("OnLeave", function(self)
        if self.icon then self.icon:SetBlendMode("BLEND") end
        if self.texture then self.texture:SetBlendMode("BLEND") end
    end)

    button.isSkinned = true
    tinsert(buttons, button)
end

local function LockButton(self)
    for _, funcName in ipairs(buttonFunctions) do
        self[funcName] = GW.NoOp
    end
end

local function UnlockButton(self)
    for _, funcName in ipairs(buttonFunctions) do
        self[funcName] = nil
    end
end

local function UpdateButtons(self)
    local frameIndex = 0
    local prevFrame = self.container

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

    self.gw_Showing = (frameIndex > 0)
end

local function GrabIcons(self)
    if InCombatLockdown() or C_PetBattles.IsInBattle() then return end

    for _, frame in ipairs({Minimap:GetChildren()}) do
        if frame then
            local width = frame:GetWidth() or 0
            if width > 15 and width < 40 and (frame:IsObjectType("Button") or frame:IsObjectType("Frame")) then
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
    minimapButton.container:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    minimapButton.gw_Showing = false
    GrabIcons(minimapButton)

    C_Timer.NewTicker(6, function() GrabIcons(minimapButton) end)
end
GW.CreateMinimapButtonsSack = CreateMinimapButtonsSack