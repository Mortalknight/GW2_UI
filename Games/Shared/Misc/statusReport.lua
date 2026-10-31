---@class GW2
local GW = select(2, ...)

-- The report is read by us when helping users, so labels stay English and
-- values use tokens/ids instead of localized names.

local function CountOtherAddOnsEnabled()
    local count = 0
    for i = 1, C_AddOns.GetNumAddOns() do
        local name = C_AddOns.GetAddOnInfo(i)
        if name ~= "GW2_UI" and C_AddOns.GetAddOnEnableState(name, GW.myname) == 2 then
            count = count + 1
        end
    end
    return count
end


local function YesNo(value)
    return value and "Yes" or "No"
end

local function GetDisplayMode()
    if GetCVar("gxWindow") ~= "1" then
        return "Fullscreen"
    end
    return GetCVar("gxMaximize") == "1" and "Windowed (Fullscreen)" or "Windowed"
end

local function GetSpecText()
    if not (C_SpecializationInfo and GW.myspec) then
        return UNKNOWN
    end
    local specID, specName = C_SpecializationInfo.GetSpecializationInfo(GW.myspec)
    return specID and format("%s (%d)", specName, specID) or UNKNOWN
end

-- on, off, or blocked by an incompatible addon; the gamepad interface replaces our action bars;
-- the path of the module settings, read when the page shows: the settings load after this file and change with the profile
local function ModuleState(path, incompatibleCategory, gamepadReplaces)
    return function()
        local settings = GW.settings
        for key in gmatch(path, "[^.]+") do
            settings = settings[key]
        end
        if not settings.enabled then
            return "Off"
        end
        if incompatibleCategory then
            local isLoaded, addonNames, isOverride = GW.GetIncompatibleAddonInfo(incompatibleCategory)
            if isLoaded and not isOverride then
                return format("Blocked (%s)", addonNames), true
            end
        end
        if gamepadReplaces and GW.IsGamepadInterface() then
            return "Off (Gamepad)"
        end
        return "On"
    end
end

-- every getter returns the text and optionally whether it points at a problem
local SECTIONS = {
    {
        title = "AddOn Info",
        rows = {
            { "GW2 UI Version", function() return GW.GetVersionString() end },
            { "DB Version", function() return GW.settings.settingsVersion or 0 end },
            { "Profile", function() return GW.globalSettings:GetCurrentProfile() end },
            { "Other AddOns Enabled", function()
                local count = CountOtherAddOnsEnabled()
                return count > 0 and format("Yes (%d)", count) or "No", count > 0
            end },
            { "Recommended Scale", function() return format("%.2f", GW.getBestPixelScale()) end },
            { "UI Scale", function() return format("%.2f", GW.scale), GW.scale ~= GW.getBestPixelScale() end },
        },
    },
    {
        title = "WoW Info",
        rows = {
            { "Client", GW.GetClientFlavorName },
            { "WoW Version", function() return format("%s (build %s)", GW.wowpatch, GW.wowbuild) end },
            { "Client Language", function() return GW.mylocal end },
            { "Display Mode", GetDisplayMode },
            { "Resolution", function() return GW.resolution end },
            { "Mac Client", function() return YesNo(IsMacClient()) end },
        },
    },
    {
        title = "Character Info",
        rows = {
            { "Faction", function() return GW.myfaction end },
            { "Race", function() return GW.myrace end },
            { "Class", function() return GW.myclass end },
            { "Specialization", GetSpecText },
            { "Level", function() return GW.mylevel end },
            { "Zone", function() return GW.Location.GetZoneText() or UNKNOWN end },
        },
    },
    {
        title = "Modules",
        rows = {
            { "Action Bars", ModuleState("actionbars", "Actionbars", true) },
            { "Player Frame", ModuleState("unitframes.player") },
            { "Target Frame", ModuleState("unitframes.target") },
            { "Group Frames", ModuleState("groupFrames") },
            { "Bags", ModuleState("bags", "Inventory") },
            { "Character Window", ModuleState("windows.character") },
            { "Objectives", ModuleState("objectives", "Objectives") },
            { "Chat", ModuleState("chat", "Chat") },
            { "Tooltips", ModuleState("tooltip") },
            { "Minimap", ModuleState("minimap", "Minimap") },
            { "Immersive Questing", ModuleState("immersiveQuesting", "ImmersiveQuesting") },
            { "Gamepad Interface", function() return YesNo(GW.IsGamepadInterface()) end },
        },
    },
}

-- the system info page of the overview: a card per section like the credits, two side by side
local PAD = 12
local CARD_GAP = 10
local ROW_HEIGHT = 18

local function CreateSectionCard(page, section)
    local card = CreateFrame("Frame", nil, page)
    GW.AddDetailsBackground(card)

    local title = card:CreateFontString(nil, "ARTWORK")
    title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    title:SetPoint("TOPLEFT", PAD, -PAD)
    title:SetText(section.title)

    local y = -(PAD + 26)
    for _, row in ipairs(section.rows) do
        local label = card:CreateFontString(nil, "ARTWORK")
        label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        label:SetTextColor(GW.Colors.SkinColors.SubText:GetRGB())
        label:SetPoint("TOPLEFT", PAD, y)
        label:SetText(row[1])

        local value = card:CreateFontString(nil, "ARTWORK")
        value:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        value:SetPoint("TOPRIGHT", -PAD, y)
        value:SetJustifyH("RIGHT")
        tinsert(page.rows, {value = value, get = row[2]})
        y = y - ROW_HEIGHT
    end
    card.contentHeight = -y + PAD
    return card
end

local function Layout(page)
    local width = page:GetWidth()
    if not width or width <= 0 then return end
    local half = (width - CARD_GAP) / 2

    local top = 0
    for row = 1, #page.cards, 2 do
        local left, right = page.cards[row], page.cards[row + 1]
        local height = math.max(left.contentHeight, right and right.contentHeight or 0)
        for _, card in ipairs({left, right}) do
            card:SetSize(half, height)
            card:ClearAllPoints()
        end
        left:SetPoint("TOPLEFT", 0, top)
        if right then
            right:SetPoint("TOPRIGHT", 0, top)
        end
        top = top - height - CARD_GAP
    end

    page.reload:ClearAllPoints()
    page.reload:SetPoint("TOPRIGHT", 0, top - 4)
    -- the overview grows its page block to this
    page.contentHeight = -top + 4 + page.reload:GetHeight()
end

local function RefreshValues(page)
    local colors = GW.Colors.SkinColors
    for _, row in ipairs(page.rows) do
        local text, isProblem = row.get()
        row.value:SetText(tostring(text))
        if isProblem == nil then
            row.value:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
        else
            row.value:SetTextColor((isProblem and colors.Negative or colors.Positive):GetRGB())
        end
    end
end

function GW.CreateSystemInfoPage(parent)
    local page = CreateFrame("Frame", nil, parent)
    page:Hide()

    page.rows, page.cards = {}, {}
    for _, section in ipairs(SECTIONS) do
        tinsert(page.cards, CreateSectionCard(page, section))
    end

    page.reload = CreateFrame("Button", nil, page, "GwStandardButton")
    page.reload:SetSize(130, 26)
    page.reload:SetText(RELOADUI)
    page.reload:SetScript("OnClick", function() C_UI.Reload() end)

    page:SetScript("OnSizeChanged", Layout)
    page:SetScript("OnShow", function(self)
        RefreshValues(self)
        Layout(self)
    end)
    Layout(page)
    return page
end
