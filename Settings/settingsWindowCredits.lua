---@class GW2
local GW = select(2, ...)

local L = GW.L

-- the credits page of the overview: the creator and the lead developer on their own cards, every other role on a
-- card with the names as chips, a thank you to the community at the bottom
local TEXTURES = "Interface/AddOns/GW2_UI/textures/uistuff/"
local PAD = 12
local CARD_GAP = 10
local HERO_HEIGHT = 78
local CHIP_HEIGHT = 22
local CHIP_PAD = 8
local CHIP_GAP = 6

local CREATOR = "Aethelwulf"
local LEAD = "Glow"
-- the languages come from the git history and the curseforge localization page
local SECTIONS = {
    {key = "developer", title = L["Developers"], gold = true, names = {"Nezroy", "Shoodox", "Shrugal"}},
    {key = "contribution", title = L["Contributors"], names = {"Hatdragon", "Zoelie"}},
    {key = "localization", title = L["Translators"], names = {
        {"aSlightDrizzle", "esES"}, "AxelVader", {"Calcifer", "itIT"}, {"Crisll", "esES"}, "Dololo",
        {"Glow", "deDE"}, {"Kitto", "frFR"}, "Murak", {"Pyrefox", "esES ptBR"}, "RickCiotti", "Throli", {"Zelrog", "ruRU"},
    }},
    {key = "testing", title = L["QA Testers"], names = {"Belazor", "Crohnleuchter", "KYZ", "Ultrachocobo", "Zoelie"}},
}

-- every name once, the grid preview borrows them as test names
do
    local seen = {}
    local function Add(name)
        if not seen[name] then
            seen[name] = true
            tinsert(GW.CreditsList, name)
        end
    end
    Add(CREATOR)
    Add(LEAD)
    for _, section in ipairs(SECTIONS) do
        for _, entry in ipairs(section.names) do
            Add(type(entry) == "table" and entry[1] or entry)
        end
    end
end

local function CreateCard(parent)
    local card = CreateFrame("Frame", nil, parent)
    GW.AddDetailsBackground(card)
    return card
end

local function CreateHeroCard(parent, iconKey, role, name, text)
    local card = CreateCard(parent)
    card:SetHeight(HERO_HEIGHT)

    local icon = card:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(TEXTURES .. "credits_" .. iconKey .. ".png")
    icon:SetSize(36, 36)
    icon:SetPoint("LEFT", PAD, 0)

    local roleText = card:CreateFontString(nil, "ARTWORK")
    roleText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    roleText:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    roleText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, 10)
    roleText:SetText(role)

    local nameText = card:CreateFontString(nil, "ARTWORK")
    nameText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    nameText:SetTextColor(GW.Colors.SkinColors.QuestGold:GetRGB())
    nameText:SetPoint("TOPLEFT", roleText, "BOTTOMLEFT", 0, -2)
    nameText:SetText(name)

    local descText = card:CreateFontString(nil, "ARTWORK")
    descText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    descText:SetTextColor(GW.Colors.SkinColors.SubText:GetRGB())
    descText:SetJustifyH("LEFT")
    descText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
    descText:SetPoint("RIGHT", card, "RIGHT", -PAD, 0)
    descText:SetText(text)
    return card
end

local function CreateChip(card, entry, gold)
    local name, lang = entry, nil
    if type(entry) == "table" then
        name, lang = entry[1], entry[2]
    end
    local chip = CreateFrame("Frame", nil, card)
    chip:SetHeight(CHIP_HEIGHT)
    chip.bg = chip:CreateTexture(nil, "BACKGROUND", nil, 1)
    chip.bg:SetAllPoints()
    chip.bg:SetColorTexture(GW.Colors.SkinColors.Chip:GetRGBA())

    chip.text = chip:CreateFontString(nil, "ARTWORK")
    chip.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    chip.text:SetTextColor((gold and GW.Colors.SkinColors.QuestGold or GW.Colors.FallbackWhite):GetRGB())
    chip.text:SetPoint("LEFT", CHIP_PAD, 0)
    chip.text:SetText(lang and (name .. "  " .. GW.Colors.SkinColors.SubText:WrapTextInColorCode(lang)) or name)
    return chip
end

local function CreateSectionCard(parent, section)
    local card = CreateCard(parent)

    local icon = card:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(TEXTURES .. "credits_" .. section.key .. ".png")
    icon:SetSize(16, 16)
    icon:SetPoint("TOPLEFT", PAD, -PAD)

    local title = card:CreateFontString(nil, "ARTWORK")
    title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    title:SetText(section.title)

    card.chips = {}
    for _, entry in ipairs(section.names) do
        tinsert(card.chips, CreateChip(card, entry, section.gold))
    end
    return card
end

-- the chips flow into rows as wide as the card, returns the height the card needs
local function FlowChips(card, width)
    local x, y = PAD, -(PAD + 26)
    for _, chip in ipairs(card.chips) do
        local chipWidth = chip.text:GetStringWidth() + CHIP_PAD * 2
        if x > PAD and x + chipWidth > width - PAD then
            x, y = PAD, y - CHIP_HEIGHT - CHIP_GAP
        end
        chip:SetWidth(chipWidth)
        chip:ClearAllPoints()
        chip:SetPoint("TOPLEFT", x, y)
        x = x + chipWidth + CHIP_GAP
    end
    return -y + CHIP_HEIGHT + PAD
end

local function Layout(page)
    local width = page:GetWidth()
    if not width or width <= 0 then return end
    local half = (width - CARD_GAP) / 2

    page.creator:SetPoint("TOPLEFT", 0, 0)
    page.creator:SetWidth(half)
    page.lead:SetPoint("TOPRIGHT", 0, 0)
    page.lead:SetWidth(half)

    local top = -(HERO_HEIGHT + CARD_GAP)
    for row = 1, #page.cards, 2 do
        local left, right = page.cards[row], page.cards[row + 1]
        local height = FlowChips(left, half)
        if right then
            height = math.max(height, FlowChips(right, half))
        end
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

    page.thanks:ClearAllPoints()
    page.thanks:SetPoint("TOPLEFT", 0, top - 4)
    page.thanks:SetPoint("TOPRIGHT", 0, top - 4)
    -- the overview grows its page block to this
    page.contentHeight = -top + 4 + page.thanks:GetHeight()
end

function GW.CreateCreditsPage(parent, onDiscordClick)
    local page = CreateFrame("Frame", nil, parent)
    page:Hide()

    page.creator = CreateHeroCard(page, "owner", L["Founder"], CREATOR, L["Created GW2 UI in 2015, inspired by the interface of Guild Wars 2."])
    page.lead = CreateHeroCard(page, "developer", L["Lead developer"], LEAD, L["Part of GW2 UI since 2016, lead developer since 2020."])

    page.cards = {}
    for _, section in ipairs(SECTIONS) do
        tinsert(page.cards, CreateSectionCard(page, section))
    end

    local thanks = CreateFrame("Frame", nil, page)
    thanks:SetHeight(32)
    page.thanks = thanks

    local discord = CreateFrame("Button", nil, thanks, "GwStandardButton")
    discord:SetSize(130, 26)
    discord:SetPoint("RIGHT", 0, 0)
    discord:SetText(L["Join Discord"])
    discord:SetScript("OnClick", onDiscordClick)

    local text = thanks:CreateFontString(nil, "ARTWORK")
    text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    text:SetTextColor(GW.Colors.SkinColors.SubText:GetRGB())
    text:SetJustifyH("LEFT")
    text:SetPoint("LEFT", 4, 0)
    text:SetPoint("RIGHT", discord, "LEFT", -12, 0)
    text:SetText(L["Thank you to everyone who uses GW2 UI, reports bugs and shares ideas."])

    page:SetScript("OnSizeChanged", Layout)
    page:SetScript("OnShow", Layout)
    return page
end
