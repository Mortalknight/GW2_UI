---@class GW2
local GW = select(2, ...)

-- our own references to the Blizzard rows, so nothing is written into their frames
local playerRows, statusRows = {}, {}

local function GetMember(row)
    local index = row.button.guildIndex
    if not index then return end
    local _, _, _, level, className, zone, _, _, online = GetGuildRosterInfo(index)
    return GW.UnlocalizedClassName(className), online, level, zone
end

local function SetClassColor(text, classFile)
    local color = GW.GWGetClassColor(classFile, true)
    text:SetTextColor(color.r, color.g, color.b)
end

-- Blizzard colors all rows in GuildStatus_Update, we only recolor online members
local function UpdatePlayerRows()
    local myZone = GW.Location.GetZoneText()
    for _, row in ipairs(playerRows) do
        local classFile, online, level, zone = GetMember(row)
        if classFile then
            GW.SetClassIcon(row.icon, classFile)
            if online then
                SetClassColor(row.name, classFile)
                local levelColor = GetQuestDifficultyColor(level)
                row.level:SetTextColor(levelColor.r, levelColor.g, levelColor.b)
                local zoneColor = zone == myZone and GW.Colors.SkinColors.Positive or GW.Colors.FallbackWhite
                row.zone:SetTextColor(zoneColor:GetRGB())
            end
        end
    end
end

local function UpdateStatusRows()
    for _, row in ipairs(statusRows) do
        local classFile, online = GetMember(row)
        if classFile and online then
            SetClassColor(row.name, classFile)
            row.online:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
        end
    end
end

local function UpdateGuildRows()
    if FriendsFrame.playerStatusFrame then
        UpdatePlayerRows()
    else
        UpdateStatusRows()
    end
end

local function UseListHover(button)
    button:GetHighlightTexture():SetTexture("")
    GW.AddListItemChildHoverTexture(button)
end

local function SkinRows()
    for i = 1, GUILDMEMBERS_TO_DISPLAY do
        local prefix = "GuildFrameButton" .. i
        local button = _G[prefix]
        -- the class icon takes the place of the class name column
        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("LEFT", 48, 0)
        icon:SetSize(15, 15)
        icon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons.png")
        icon:GwCreateBackdrop(nil, true, nil, nil, nil, nil, nil, icon)
        _G[prefix .. "Class"]:Hide()

        local row = { button = button, icon = icon, name = _G[prefix .. "Name"], level = _G[prefix .. "Level"], zone = _G[prefix .. "Zone"] }
        row.level:ClearAllPoints()
        row.level:SetPoint("TOPLEFT", 10, -1)
        row.name:ClearAllPoints()
        row.name:SetPoint("LEFT", 85, 0)
        row.name:SetSize(100, 14)
        UseListHover(button)
        playerRows[i] = row

        prefix = "GuildFrameGuildStatusButton" .. i
        local statusRow = { button = _G[prefix], name = _G[prefix .. "Name"], online = _G[prefix .. "Online"] }
        statusRow.name:ClearAllPoints()
        statusRow.name:SetPoint("LEFT", 10, 0)
        UseListHover(statusRow.button)
        statusRows[i] = statusRow
    end
end

local function SkinColumnHeaders()
    -- the player view shows level, class icon, name and zone from left to right
    local previous
    for _, column in ipairs({ { 3 }, { 4, 50 }, { 1, 105 }, { 2, 127 } }) do
        local header = _G["GuildFrameColumnHeader" .. column[1]]
        header:ClearAllPoints()
        if previous then
            header:SetPoint("LEFT", previous, "RIGHT", -2, 0)
        else
            header:SetPoint("TOPLEFT", 8, -57)
        end
        if column[2] then
            header:SetWidth(column[2])
        end
        previous = header
    end

    for _, prefix in ipairs({ "GuildFrameColumnHeader", "GuildFrameGuildStatusColumnHeader" }) do
        for i = 1, 4 do
            local header = _G[prefix .. i]
            header:GwStripTextures()
            for _, region in ipairs({ header:GetRegions() }) do
                if region:GetObjectType() == "FontString" then
                    region:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
                end
            end
            GW.HandleScrollFrameHeaderButton(header)
        end
    end
end

function GW.SkinGuildList()
    if not (GW.TBC or GW.Wrath) then return end

    -- more rows would need new Blizzard buttons, which taints the guild frame
    SkinRows()
    SkinColumnHeaders()
    hooksecurefunc("GuildStatus_Update", UpdateGuildRows)

    GuildFrame:GwStripTextures()
    GuildFrameLFGFrame:GwStripTextures()
    GuildListScrollFrame:GwStripTextures()
    GuildListScrollFrame:GwSkinScrollFrame()
    GuildListScrollFrame:SetPoint("TOPLEFT", GuildFrame, "TOPLEFT", 10, -60)
    GuildListScrollFrameScrollBar:GwSkinScrollBar()

    GuildFrameLFGButton:GwSkinCheckButton(false, 15)
    GW.HandleNextPrevButton(GuildFrameGuildListToggleButton, "right")
    for _, button in ipairs({ GuildFrameAddMemberButton, GuildFrameGuildInformationButton, GuildFrameControlButton }) do
        button:GwSkinButton(false, true)
    end
    GuildMOTDEditButton:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)

    for _, text in ipairs({ GuildFrameTotals, GuildFrameOnlineTotals, GuildFrameNotesLabel, GuildFrameNotesText }) do
        text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    end
    GuildFrameNotesText:SetWidth(450)
    GuildFrameNotesLabel:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
end
