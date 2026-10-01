---@class GW2
local GW = select(2, ...)

-- The report is read by us when helping users, so labels stay English and
-- values use tokens/ids instead of localized names.

local function AnyAddOnEnabled(matches)
    for i = 1, C_AddOns.GetNumAddOns() do
        local name = C_AddOns.GetAddOnInfo(i)
        if matches(name) and C_AddOns.GetAddOnEnableState(name, GW.myname) == 2 then
            return true
        end
    end
    return false
end

local function AreOtherAddOnsEnabled()
    return AnyAddOnEnabled(function(name) return name ~= "GW2_UI" end)
end

local function CheckForPasteAddon()
    return AnyAddOnEnabled(function(name) return name == "Paste" or name == "CopyPaste" end)
end
GW.CheckForPasteAddon = CheckForPasteAddon

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

-- every getter returns the text and optionally whether it points at a problem
local SECTIONS = {
    {
        title = "AddOn Info",
        rows = {
            { "GW2 UI version", function() return GW.GetVersionString() end },
            { "Other AddOns enabled", function() local on = AreOtherAddOnsEnabled() return YesNo(on), on end },
            { "Paste AddOn enabled", function() local on = CheckForPasteAddon() return YesNo(on), on end },
            { "Recommended scale", function() return format("%.2f", GW.getBestPixelScale()) end },
            { "UI scale", function() return format("%.2f", GW.scale), GW.scale ~= GW.getBestPixelScale() end },
        },
    },
    {
        title = "WoW Info",
        rows = {
            { "WoW version", function() return format("%s (build %s)", GW.wowpatch, GW.wowbuild) end },
            { "Client language", function() return GW.mylocal end },
            { "Display mode", GetDisplayMode },
            { "Resolution", function() return GW.resolution end },
            { "Mac client", function() return YesNo(IsMacClient()) end },
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
}

local PADDING = 20
local ROW_HEIGHT = 18

local function CreateText(frame, template)
    local text = frame:CreateFontString(nil, "ARTWORK", template)
    text:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    return text
end

local function CreateButton(frame, text, onClick)
    local button = CreateFrame("Button", nil, frame, "GwStandardButton")
    button:SetSize(120, 25)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

local function CreateStatusFrame()
    local frame = CreateFrame("Frame", "GWStatusFrame", UIParent)
    frame:SetWidth(320)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:GwCreateBackdrop({
        bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/welcome-bg.png",
        edgeFile = "",
        tile = false,
        edgeSize = 32,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:Hide()
    tinsert(UISpecialFrames, "GWStatusFrame")

    -- the logo area drags the window
    local logoArea = CreateFrame("Frame", nil, frame, "TitleDragAreaTemplate")
    logoArea:SetPoint("TOPLEFT")
    logoArea:SetPoint("TOPRIGHT")
    logoArea:SetHeight(140)
    GW.CreateBrandLogo(logoArea, 128):SetPoint("CENTER")

    frame.rows = {}
    local y = -140
    for _, section in ipairs(SECTIONS) do
        local title = frame:CreateFontString(nil, "ARTWORK")
        title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        title:SetPoint("TOPLEFT", PADDING, y)
        title:SetText(section.title)

        local separator = frame:CreateTexture(nil, "ARTWORK")
        separator:SetTexture("Interface/AddOns/GW2_UI/textures/hud/levelreward-sep.png")
        separator:SetTexCoord(0.5, 1, 0, 1)
        separator:SetHeight(2)
        separator:SetPoint("TOPLEFT", PADDING - 4, y - 20)
        separator:SetPoint("TOPRIGHT", -PADDING + 4, y - 20)
        y = y - 28

        for _, row in ipairs(section.rows) do
            local label = CreateText(frame, "SystemFont_Outline")
            label:SetPoint("TOPLEFT", PADDING, y)
            label:SetText(row[1])

            local value = CreateText(frame, "SystemFont_Outline")
            value:SetPoint("TOPRIGHT", -PADDING, y)
            value:SetJustifyH("RIGHT")
            frame.rows[#frame.rows + 1] = { value = value, get = row[2] }
            y = y - ROW_HEIGHT
        end
        y = y - 14
    end

    local reload = CreateButton(frame, RELOADUI, function() C_UI.Reload() end)
    reload:SetPoint("TOPLEFT", PADDING, y)
    local close = CreateButton(frame, CLOSE, function()
        HideUIPanel(frame)
        GwSettingsWindow:Show()
    end)
    close:SetPoint("TOPRIGHT", -PADDING, y)

    frame:SetHeight(-y + 25 + PADDING)
    return frame
end

local function RefreshValues(frame)
    local colors = GW.Colors.SkinColors
    for _, row in ipairs(frame.rows) do
        local text, isProblem = row.get()
        row.value:SetText(tostring(text))
        if isProblem == nil then
            row.value:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
        else
            row.value:SetTextColor((isProblem and colors.Negative or colors.Positive):GetRGB())
        end
    end
end

local function ShowStatusReport()
    GW.StatusFrame = GW.StatusFrame or CreateStatusFrame()

    local frame = GW.StatusFrame
    if frame:IsShown() then
        frame:Hide()
    else
        RefreshValues(frame)
        frame:Raise()
        frame:Show()
    end
end
GW.ShowStatusReport = ShowStatusReport
