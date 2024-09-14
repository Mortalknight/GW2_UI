local _, GW = ...
local L = GW.L

local function setFont(fontObject, font, size, style, shadowX, shadowY, shadowA, r, g, b, shadowR, shadowG, shadowB)
    if not fontObject then return end
    local newStyle

    local _, oldSize, oldStyle = fontObject:GetFont()

    if not size then
        size = oldSize
    end

    if style == "NONE" or not style then style = "" end

    local shadow = strsub(style, 0, 6) == "SHADOW" -- only used for shadow color(offset)
    if shadow then style = strsub(style, 7) end

    if not style or style == "" then
        newStyle = oldStyle == "OUTLINE" and "THINOUTLINE" or oldStyle or "" -- keep outlines thin
    end

    fontObject:SetFont(font, size, newStyle or style)
    fontObject:SetShadowColor(shadowR or 0, shadowG or 0, shadowB or 0,
        shadowA or (shadow and (style == "" and 1 or 0.6)) or 0)
    fontObject:SetShadowOffset(shadowX or (shadow and 1) or 0, shadowY or (shadow and -1) or 0)

    if r and g and b then
        fontObject:SetTextColor(r, g, b)
    end
end

local function getNormalFontFamily()
    local locale = GW.mylocal
    -- get our saved font
    local activeFont = GW.settings.FONT_NORMAL
    -- if we use a custom font, fetch it from shared media
    if GW.settings.CUSTOM_FONT_NORMAL ~= "NONE" then
        activeFont = GW.Libs.LSM:Fetch("font", GW.settings.CUSTOM_FONT_NORMAL)
    elseif GW.settings.FONT_STYLE_TEMPLATE ~= "BLIZZARD" then
        if locale == "koKR" then
            activeFont = "Interface/AddOns/GW2_UI/fonts/korean.ttf"
        elseif locale == "zhCN" or locale == "zhTW" then
            activeFont = "Interface/AddOns/GW2_UI/fonts/chinese-font.ttf"
        elseif locale == "ruRU" then
            activeFont = "Interface/AddOns/GW2_UI/fonts/menomonia_old.ttf"
        end
    elseif GW.settings.FONT_STYLE_TEMPLATE == "BLIZZARD" then
        activeFont = ""
    end
    return activeFont
end
local function getHeaderFontFamily()
    local locale = GW.mylocal
    -- get our saved font
    local activeFont = GW.settings.FONT_HEADERS
    -- if we use a custom font, fetch it from shared media
    if GW.settings.CUSTOM_FONT_HEADER ~= "NONE" then
        activeFont = GW.Libs.LSM:Fetch("font", GW.settings.CUSTOM_FONT_HEADER)
    elseif GW.settings.FONT_STYLE_TEMPLATE ~= "BLIZZARD" then
        if locale == "koKR" then
            activeFont = "Interface/AddOns/GW2_UI/fonts/korean.ttf"
        elseif locale == "zhCN" or locale == "zhTW" then
            activeFont = "Interface/AddOns/GW2_UI/fonts/chinese-font.ttf"
        elseif locale == "ruRU" then
            activeFont = "Interface/AddOns/GW2_UI/fonts/headlines_old.ttf"
        end
    elseif GW.settings.FONT_STYLE_TEMPLATE == "BLIZZARD" then
        activeFont = ""
    end
    return activeFont
end

local function LoadFonts()
    local addonFont = getNormalFontFamily()
    local addonFontHeader = getHeaderFontFamily()
    if addonFont == nil or addonFont == "" then
        return
    end
    if addonFontHeader==nil or addonFontHeader==""then
        addonFontHeader = addonFont
    end
    local normal = addonFont
    local bold = addonFontHeader
    local narrow = addonFont
    local narrowBold = addonFont
    --local light = L["FONT_LIGHT"]
    local damage = addonFont

    -- game engine fonts
    UNIT_NAME_FONT = normal
    DAMAGE_TEXT_FONT = addonFontHeader
    STANDARD_TEXT_FONT = normal

    -- default values
    UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 14
    CHAT_FONT_HEIGHTS = { 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }

    setFont(ChatFontNormal, narrow, nil, nil, 0.75, -0.75, 1)
    setFont(NumberFontNormal, narrow, 14, "", 1.25, -1.25, 1)
    setFont(SystemFont_Tiny, normal)
    setFont(SystemFont_Small, narrow)
    setFont(SystemFont_Small2, narrow)
    setFont(SystemFont_Outline_Small, narrow)
    setFont(SystemFont_Outline, normal)
    setFont(SystemFont_Shadow_Small, normal)
    setFont(SystemFont_InverseShadow_Small, normal)
    setFont(SystemFont_Med1, normal)
    setFont(SystemFont_Shadow_Med1, normal)
    setFont(SystemFont_Shadow_Med1_Outline, normal)
    setFont(SystemFont_Med2, normal)
    setFont(SystemFont_Shadow_Med2, normal)
    setFont(SystemFont_Med3, normal)
    setFont(SystemFont_Shadow_Med3, normal)
    setFont(SystemFont_Large, normal)
    setFont(SystemFont_Shadow_Large, bold)
    setFont(SystemFont_Shadow_Large_Outline, bold)
    setFont(SystemFont_Huge1, normal)
    setFont(SystemFont_OutlineThick_Huge2, bold)
    setFont(SystemFont_Shadow_Outline_Huge2, narrow)
    setFont(SystemFont_Shadow_Huge3, normal)
    setFont(SystemFont_OutlineThick_Huge4, bold)
    setFont(SystemFont_OutlineThick_WTF, normal)
    setFont(SystemFont_Huge2, normal) -- Widget Top Center Text
    setFont(SystemFont_Shadow_Huge2, normal, 24, "SHADOW")
    setFont(SpellFont_Small, normal)
    setFont(InvoiceFont_Med, normal)
    setFont(InvoiceFont_Small, normal)
    setFont(AchievementFont_Small, normal)
    setFont(ReputationDetailFont, normal)
    setFont(FriendsFont_Normal, normal)
    setFont(FriendsFont_Small, normal)
    setFont(FriendsFont_Large, damage)
    setFont(FriendsFont_UserText, narrow)
    setFont(GameFont_Gigantic, normal)
    setFont(ChatBubbleFont, normal)
    setFont(Fancy12Font, normal)
    setFont(Fancy14Font, normal)
    setFont(Fancy22Font, normal)
    setFont(Fancy24Font, normal)
    setFont(GameTooltipHeader, normal, 16, "", -1, -1, 1, 1, 1, 1, 0, 0, 0)
    setFont(Tooltip_Med, normal, 14, "", -1, -1, 1, 1, 1, 1, 0, 0, 0)
    setFont(Tooltip_Small, normal, 12, "", -1, -1, 1, 1, 1, 1, 0, 0, 0)
    setFont(NumberFont_Shadow_Small, narrow)
    setFont(NumberFont_OutlineThick_Mono_Small, narrow)
    setFont(NumberFont_Shadow_Med, narrow)
    setFont(NumberFont_Normal_Med, narrow)
    setFont(NumberFont_Outline_Med, narrow)
    setFont(NumberFont_Outline_Large, narrow)
    setFont(NumberFont_Outline_Huge, narrowBold)
    setFont(ErrorFont, narrow, 12, "", 0.75, -0.75, 0.5)
    setFont(ZoneTextFont, narrow, 32, "", 1.25, -1.25, 0.75)
    setFont(SubZoneTextFont, narrow, 24, "", 1.25, -1.25, 0.75)
    setFont(PVPInfoTextFont, narrow, 16, "", 1.25, -1.25, 0.75)
    setFont(RaidWarningFrameSlot1, narrow, nil, "", 0.75, -0.75, 0.75)
    setFont(RaidWarningFrameSlot2, narrow, nil, "", 0.75, -0.75, 0.75)
    setFont(RaidBossEmoteFrameSlot1, narrow, nil, "", 0.75, -0.75, 0.75)
    setFont(RaidBossEmoteFrameSlot2, narrow, nil, "", 0.75, -0.75, 0.75)
    setFont(MailFont_Large, normal)
    setFont(BossEmoteNormalHuge, normal)
    setFont(CoreAbilityFont, normal)
    setFont(DestinyFontHuge, normal)
    setFont(DestinyFontMed, normal)
    setFont(FriendsFont_11, normal, 11, "SHADOW")
    setFont(Game10Font_o1, normal)
    setFont(Game120Font, normal)
    setFont(Game12Font, normal)
    setFont(Game13FontShadow, normal)
    setFont(Game15Font_o1, normal)
    setFont(Game16Font, normal)
    setFont(Game18Font, normal)
    setFont(Game24Font, normal)
    setFont(Game30Font, normal)
    setFont(Game40Font, normal)
    setFont(Game42Font, normal)
    setFont(Game46Font, normal)
    setFont(Game48Font, normal)
    setFont(Game48FontShadow, normal)
    setFont(Game60Font, normal)
    setFont(Game72Font, normal)
    setFont(GameFontHighlight, normal)
    setFont(GameFontHighlightMedium, normal)
    setFont(GameFontHighlightSmall2, normal)
    setFont(GameFontNormalHuge2, normal)
    setFont(GameFontNormalLarge, normal)
    setFont(GameFontNormalLarge2, normal)
    setFont(GameFontNormalMed1, normal)
    setFont(GameFontNormalMed2, normal)
    setFont(GameFontNormalMed3, normal)
    setFont(GameFontNormalSmall, normal)
    setFont(GameFontNormalSmall2, normal)
    setFont(Number11Font, narrow)
    setFont(Number11Font, narrow)
    setFont(Number12Font, narrow)
    setFont(Number12Font_o1, narrow)
    setFont(Number13Font, narrow)
    setFont(Number13FontGray, narrow, 13, "SHADOW")
    setFont(Number13FontWhite, narrow, 13, "SHADOW")
    setFont(Number13FontYellow, narrow, 13, "SHADOW")
    setFont(Number14FontGray, narrow, 14, "SHADOW")
    setFont(Number14FontWhite, narrow, 14, "SHADOW")
    setFont(Number15Font, narrowBold, 15)
    setFont(Number18Font, narrowBold, 18)
    setFont(Number18FontWhite, narrowBold, 18, "SHADOW")
    setFont(NumberFont_OutlineThick_Mono_Small, narrow)
    setFont(NumberFont_Shadow_Small, normal)
    setFont(NumberFontNormalSmall, normal)
    setFont(PriceFont, normal)
    setFont(PVPArenaTextString, normal, 22, "OUTLINE")
    setFont(PVPInfoTextString, normal, 22, "OUTLINE")
    setFont(QuestFont, normal)
    setFont(QuestFont_Large, normal, 14)
    setFont(QuestFont_Larger, normal, 16)
    setFont(QuestFont_39, normal, 39)
    setFont(QuestFont_Huge, normal)
    setFont(QuestFont_Super_Huge, normal)
    setFont(QuestFont_Enormous, normal)
    setFont(QuestFont_Shadow_Small, normal, nil, "SHADOW", nil, nil, 1, nil, nil, nil, 0.49, 0.35, 0.05)
    setFont(QuestFont_Shadow_Huge, normal, nil, "SHADOW", nil, nil, 1, nil, nil, nil, 0.49, 0.35, 0.05)
    setFont(QuestFont_Shadow_Super_Huge, normal, nil, "SHADOW", nil, nil, 1, nil, nil, nil, 0.49, 0.35, 0.05)
    setFont(QuestFont_Shadow_Enormous, normal, nil, "SHADOW", nil, nil, 1, nil, nil, nil, 0.49, 0.35, 0.05)
    setFont(SubSpellFont, normal)
    setFont(SubZoneTextString, normal)
    setFont(SystemFont_Huge1_Outline, normal)
    setFont(SystemFont_Outline, normal)
    setFont(SystemFont_Shadow_Huge4, normal)
    setFont(SystemFont_Shadow_Large2, normal)
    setFont(ZoneTextString, normal)

    do
        -- fix the blurr on the frames
        setFont(SystemFont_Shadow_Huge1, normal)

        local warnTimings = RaidWarningFrame and RaidWarningFrame.timings
        if warnTimings then
            warnTimings.RAID_NOTICE_MIN_HEIGHT = 20
            warnTimings.RAID_NOTICE_MAX_HEIGHT = 24
        end

        local bossTimings = RaidBossEmoteFrame and RaidBossEmoteFrame.timings
        if bossTimings then
            bossTimings.RAID_NOTICE_MIN_HEIGHT = 20
            bossTimings.RAID_NOTICE_MAX_HEIGHT = 24
        end
    end

    RaidWarningFrame:SetSize(640, 48)
    RaidBossEmoteFrame:SetSize(640, 56)
end
GW.LoadFonts = LoadFonts
