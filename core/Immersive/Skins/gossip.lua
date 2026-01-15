local _, GW = ...

local lerp = GW.lerp
local gossipOptionPointer = {}


--[[

TODO Greetings text above the model frame

[646979]="Interface/GossipFrame/ActiveLegendaryQuestIcon", 646979
[132048]="Interface/GossipFrame/ActiveQuestIcon", 132048
[646980]="Interface/GossipFrame/AvailableLegendaryQuestIcon", 646980
[132049]="Interface/GossipFrame/AvailableQuestIcon", 132049
[132050]="Interface/GossipFrame/BankerGossipIcon", 132050
[132051]="Interface/GossipFrame/BattleMasterGossipIcon",132051
[132052]="Interface/GossipFrame/BinderGossipIcon", 132054
[3532316]="Interface/GossipFrame/CampaignActiveQuestIcon", 3532316
[3532317]="Interface/GossipFrame/CampaignAvailableQuestIcon", 3532317
[3595324]="Interface/GossipFrame/CampaignGossipIcons",
[3532318]="Interface/GossipFrame/CampaignIncompleteQuestIcon",3532318
[1019848]="Interface/GossipFrame/ChatBubbleGossipIcon",132053
[368577]="Interface/GossipFrame/DailyActiveQuestIcon",368577
[368364]="Interface/GossipFrame/DailyQuestIcon", 368364
[132053]="Interface/GossipFrame/GossipGossipIcon",132053
[132054]="Interface/GossipFrame/HealerGossipIcon", 132054
[365195]="Interface/GossipFrame/IncompleteQuestIcon", 365195
[132055]="Interface/GossipFrame/PetitionGossipIcon", 132055
[132056]="Interface/GossipFrame/TabardGossipIcon", 132056
[132057]="Interface/GossipFrame/TaxiGossipIcon", 132057
[132058]="Interface/GossipFrame/TrainerGossipIcon", 132058
[132059]="Interface/GossipFrame/UnlearnGossipIcon", 132059
[132060]="Interface/GossipFrame/VendorGossipIcon", 132060
[1130518]="Interface/GossipFrame/WorkOrderGossipIcon", 1130518
[528409]="Interface/GossipFrame/auctioneerGossipIcon", 528409
[1673939]="Interface/GossipFrame/transmogrifyGossipIcon", 1673939

["Interface/GossipFrame/CampaignGossipIcons"]={
        ["CampaignActiveDailyQuestIcon"]={16, 16, 0.0078125, 0.195312, 0.015625, 0.390625, false, false, "1x"},
        ["CampaignActiveQuestIcon"]={16, 16, 0.0078125, 0.195312, 0.421875, 0.796875, false, false, "1x"},
        ["CampaignAvailableDailyQuestIcon"]={16, 16, 0.210938, 0.398438, 0.015625, 0.390625, false, false, "1x"},
        ["CampaignAvailableQuestIcon"]={16, 16, 0.210938, 0.398438, 0.421875, 0.796875, false, false, "1x"},
        ["CampaignIncompleteQuestIcon"]={16, 16, 0.414062, 0.601562, 0.015625, 0.390625, false, false, "1x"},

]]

local CUSTOM_ICONS = {
    [646979] = 646979,
    [132048] = 132048,
    [646980] = 646980,
    [132049] = 132049,
    [132050] = 132050,
    [132051] = 132051,
    [132052] = 132054,
    [3532316] = 3532316,
    [3532317] = 3532317,
    [3532318] = 3532318,
    [1019848] = 132053,
    [368577] = 368577,
    [368364] = 368364,
    [132053] = 132053,
    [132054] = 132054,
    [365195] = 365195,
    [132055] = 132055,
    [132056] = 132056,
    [132057] = 132057,
    [132058] = 132058,
    [132059] = 132059,
    [132060] = 132060,
    [1130518] = 1130518,
    [528409] = 528409,
    [1673939] = 1673939,
}

local CUSTOM_ATLAS = {
    ["CampaignActiveDailyQuestIcon"] = true,
    ["CampaignActiveQuestIcon"] = true,
    ["CampaignAvailableDailyQuestIcon"] = true,
    ["CampaignAvailableQuestIcon"] = true,
    ["CampaignIncompleteQuestIcon"] = true,
    ["Recurringavailablequesticon"] = true,
}

local DEBUG_ENABLED = false
local MODEL_POSITION_OVERRIDERS = {
    {
        --Baby dragons
        oldX = 2.3854219913483,
        oldY = 1.1516649723053,
        oldZ = 1.0744315385818,
        x = 0,
        y = 0.2,
        z = 2.0,
    },
    { --wrathion Dragonflight model
        oldX = 2.4409618377686,
        oldY = 1.041432261467,
        oldZ = 1.2235957384109,
        x = 0,
        y = 0.2,
        z = 2.0,
    },
    { --snake-men-dragons
        oldX = 1.1580023765564,
        oldY = 0.81407845020294,
        oldZ = 1.2595001459122,
        x = 1.9,
        y = 0.3,
        z = 1.7,
    },
    { oldX = 0.66019856929779, oldY = -0.18824565410614, oldZ = 0.97438132762909, x = 0,   y = 0,     z = 1.1, },
    { oldX = 1.0195727348328,  oldY = -0.52885949611664, oldZ = 1.2723264694214, x = 0,    y = 0,     z = 1.5, },
    { oldX = 0.75523900985718, oldY = -0.39174777269363, oldZ = 0.94246399402618, x = 0,   y = 0,     z = 1.1, },
    { oldX = 0.48536586761475, oldY = -0.25882887840271, oldZ = 1.3045704364777, x = 0,    y = 0.2,   z = 1.5, },
    { oldX = 0.24291133880615, oldY = -0.20592048764229, oldZ = 0.94999349117279, x = 0,   y = 0,     z = 1.15, },
    { oldX = 0.47681593894958, oldY = -0.32944831252098, oldZ = 1.1506718397141, x = 0,    y = -0.4,  z = 1.3, },
    { oldX = 0.29181063175201, oldY = -0.2284619808197, oldZ = 0.84874707460403, x = 0.7,  y = -0.1,  z = 1.1, },
    { oldX = 0.47816109657288, oldY = -0.30829229950905, oldZ = 1.0849158763885, x = 0,    y = -0.2,  z = 1.0849158763885, },
    { oldX = 0.33127820491791, oldY = -0.20283228158951, oldZ = 0.98665994405746, x = 01,  y = 0,     z = 1.2, },
    { oldX = 0.32186508178711, oldY = -0.21955521404743, oldZ = 0.9369757771492, x = 0.9,  y = -0.2,  z = 1.1, },
    { oldX = 0.31549227237701, oldY = -0.18083333969116, oldZ = 0.89432013034821, x = 1,   y = 0,     z = 1.2, },
    { oldX = 0.24291133880615, oldY = -0.20592048764229, oldZ = 0.94999349117279, x = 0.7, y = 0,     z = 1.2, },
    { oldX = 7.9042167663574,  oldY = 2.5631413459778,  oldZ = 3.815083026886,   x = 0,    y = 3,     z = 5, },
    { oldX = 1.0998735427856,  oldY = 0.35394787788391, oldZ = 3.2438087463379,  x = 3,    y = -0.3,  z = 4.2438087463379, },
    { oldX = 0.38284432888031, oldY = -0.41617172956467, oldZ = 0.52872723340988, x = 0,   y = -0.25, z = 0.62872723340988, },
    { oldX = 0.35409247875214, oldY = -0.32758858799934, oldZ = 0.53851765394211, x = 0.6, y = 0,     z = 0.7, },
    { oldX = 0.43959748744965, oldY = -0.24298840761185, oldZ = 0.57567697763443, x = 0,   y = 0,     z = 0.64, },
    { oldX = 0.60450959205627, oldY = 0.27705547213554, oldZ = 1.0151824951172,  x = 2,    y = -0.6,  z = 1.2, },
    { oldX = 1.037400841713,   oldY = 0.6772723197937,  oldZ = 0.62776660919189, x = -2.2, y = 0,     z = 0.9, },
    { oldX = 0.78230690956116, oldY = 0.35086506605148, oldZ = 0.56640255451202, x = 0,    y = 0,     z = 0.9, },
    { oldX = 1.070325255394,   oldY = 0.44662028551102, oldZ = 0.4964391887188,  x = 0.40, y = 0.40,  z = 0.5964391887188, },
    { oldX = 2.9506461620331,  oldY = 0,                oldZ = 1.2835310697556,  x = -11,  y = -0.3,  z = 1.3835310697556, },
    { oldX = 0.75775837898254, oldY = 0.39659583568573, oldZ = 0.54236280918121, x = -4.5, y = -0.2,  z = 0.6736280918121, },
    { oldX = 2.3754806518555,  oldY = 1.0457524061203,  oldZ = 2.8190972805023,  x = 8,    y = -0,    z = 4.4, },
    { oldX = 8.8620824813843,  oldY = 5.2495307922363,  oldZ = 1.1385167837143,  x = 2,    y = 2,     z = 3.8, },
    { oldX = 0.39927804470062, oldY = 0.31848821043968, oldZ = 0.90161156654358, x = -5,   y = -0.5,  z = 0.9016, },
    {oldX = 0.32435846328735, oldY =-0.23640835285187, oldZ = 0.81982237100601, x = 0.4, y = 0, z = 0.9,},
    {oldX = 0.77819514274597, oldY =0.58722692728043, oldZ = 0.47829860448837, x = 0, y = -0.2, z = 0.7,},
    {oldX = 0.48978042602539, oldY =-0.27370131015778, oldZ = 1.2520405054092, x = 0.5, y = 0, z = 1.35,},
    {oldX = 0.33340585231781, oldY =-0.21574158966541, oldZ = 0.95541352033615, x = 0.9, y = 0, z = 1.05,},
}

local function splitIter(inputstr, pat)
    local st, g = 1, string.gmatch(inputstr, "()(" .. pat .. ")")
    local function getter(segs, seps, sep, cap1, ...)
        st = sep and seps + #sep
        return string.sub(inputstr, segs, seps or -1), cap1 or sep, ...
    end
    return function()
        if st then
            return getter(st, g())
        end
    end
end

local function splitQuest(inputstr)
    local t = {}
    local i = 1
    local length = string.len(inputstr)
    if length < 150 then
        t[i] = inputstr
        return t
    end
    local sep = "[\\.|!|?|>]%s+"
    inputstr = inputstr:gsub("\n", " ")
    inputstr = inputstr:gsub(" %s+", " ")
    inputstr = inputstr:gsub("%.%.%.", "…")

    for str in splitIter(inputstr, sep) do
        if str ~= nil and str ~= "" then
            t[i] = str
            i = i + 1
        end
    end
    return t
end

local ReplacedGossipColor = {
    ["000000"] = "ffffff",
    ["414141"] = "7b8489",
}

local function Gossip_SetTextColor(text, r, g, b)
    if r ~= 1 or g ~= 1 or b ~= 1 then
        text:SetTextColor(1, 1, 1)
    end
end

local function Gossip_ReplaceColor(color)
    return "|cFF" .. (ReplacedGossipColor[color] or color)
end

local function ReplaceGossipFormat(button, textFormat, text, skip)
    if skip or not text or text == "" then return end

    local newFormat, count = gsub(textFormat, "|c[fF][fF](%x%x%x%x%x%x)", Gossip_ReplaceColor)
    if count > 0 then
        button:SetFormattedText(newFormat, text, true)
    end
end

local function ReplaceGossipText(button, text)
    if not text and text == "" then return end
    local startText = text

    local iconText, iconCount = gsub(text, ":32:32:0:0", ":32:32:0:0:64:64:5:59:5:59")
    if iconCount > 0 then
        text = iconText
    end

    local colorStr, colorCount = gsub(text, "|c[fF][fF](%x%x%x%x%x%x)", Gossip_ReplaceColor)
    if colorCount > 0 then text = colorStr end

    if startText ~= text then
        button:SetFormattedText("%s", text, true)
    end
end

local function Resize(self)
    self:SetHeight(math.max(32, self:GetTextHeight() + 2, self.Icon:GetHeight()))
end

local function skinGossipOption(self)
    self.skinned = true

    if self.Icon then
        self.Icon:ClearAllPoints()
        self.Icon:SetPoint("LEFT", self, "LEFT", 0, 0)
        self.Icon:SetSize(32, 32)
        self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/gossip/optionhover.png")

        local hl = self:GetHighlightTexture()
        hl:ClearAllPoints()
        hl:SetSize(512, 64)
        hl:SetBlendMode("BLEND")
        hl:SetDrawLayer("BACKGROUND", -7)
        hl:SetPoint("LEFT", 16, 0)
        hl:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/optionhover.png")
        hl:SetVertexColor(1, 1, 1, 1)
        hl:Hide()
        self:HookScript("OnEnter", function()
            hl:Show()
            hl:SetAlpha(0.2)
            GW.AddToAnimation("GOSSIP_OPTIONHOVER", 0, 1, GetTime(), 0.2,
                function(p)
                    p = math.max(0.2, p)
                    hl:SetAlpha(p)
                end
            )
        end)
        self:HookScript("OnLeave", function()
            hl:Hide()
        end)
    end

    local buttonText = self.GetFontString and self:GetFontString() or select(3, self:GetRegions())
    if buttonText and buttonText:IsObjectType("FontString") then
        buttonText:ClearAllPoints()
        buttonText:SetPoint("LEFT", self, "LEFT", 40, 0)
        buttonText:SetTextColor(1, 1, 1)
        hooksecurefunc(buttonText, "SetTextColor", Gossip_SetTextColor)

        ReplaceGossipText(self, self:GetText())
        hooksecurefunc(self, "SetText", ReplaceGossipText)
        hooksecurefunc(self, "SetFormattedText", ReplaceGossipFormat)
        hooksecurefunc(self, "Resize", Resize)
    end
end

local function updateGossipOption(self, elementData)
    if not self.skinned then
        skinGossipOption(self)
    end

    if elementData then
        if elementData.buttonType == GOSSIP_BUTTON_TYPE_DIVIDER or elementData.buttonType == GOSSIP_BUTTON_TYPE_TITLE then
            self:SetHeight(0)
        else
            if elementData.index then
                gossipOptionPointer[elementData.index] = self
                self:GetFontString():SetText("[" .. elementData.index .. "] " .. (elementData.info.name or elementData.info.title))
            end
        end
    end

    if self.Icon then
        self.Icon:SetSize(32, 32)
        local atlas = self.Icon:GetAtlas()
        if atlas then
            if CUSTOM_ATLAS[atlas] then
                self.Icon:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/" .. atlas .. ".png")
            else
                GW.Debug("Missing Gossip atlas: ", atlas)
                self.Icon:SetAtlas(atlas, true)
            end
        else
            local t = self.Icon:GetTexture()
            if CUSTOM_ICONS[t] then
                self.Icon:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/" .. CUSTOM_ICONS[t] .. ".png")
            else
                GW.Debug("Missing Gossip Icon ID: ", t)
            end
        end
    end
end
local function comparePosition(p1, p2)
    p1 = string.format("%.5f", p1)
    p2 = string.format("%.5f", p2)
    if p1 == p2 then
        return true
    end
    return false
end

local function createModelPositionOverriderString(x, y, z, overriderX, overriderY, overriderZ)
    return "{oldX = " ..
    x .. ", oldY =" .. y .. ", oldZ = " .. z .. ", x = " .. overriderX ..
    ", y = " .. overriderY .. ", z = " .. overriderZ .. ",},"
end

-- unit for testing
local function updateModelFrame(self, unit, isDebugUpdate) -- needs to be tested on gnomes
    if unit == nil then
        unit = "npc"
    end
    if UnitExists(unit) then
        self.modelFrame:SetPosition(0, 0, 0)
        self.modelFrame:SetUnit(unit)
        self.modelFrame:SetPortraitZoom(1)
        self.modelFrame:SetRotation(0)
        self.modelFrame:SetCamDistanceScale(1)
        self.modelFrame:SetPortraitZoom(1) -- 1 = Header; 0.75 = Torso
        self.modelFrame:SetPaused(true)
        self.backLayer:Show()
        self.modelFrame:Show()
        self.maskLayer:Show()

        -- get frame true size
        local trueSize = self.modelFrame:GetHeight()
        --frame base height; models will be scaled as if the frame was this size
        local size = 200
        local sizeDif = (size / trueSize) / 2

        -- get the camera target for the portrait view
        local fx, fy = self.modelFrame:GetCameraTarget()
        -- get the height ( z ) here for the face
        local x, y, z = self.modelFrame:GetCameraPosition()
        local newX = 0
        local newY = 0
        local newZ = z

        if DEBUG_ENABLED then
            if not isDebugUpdate then
                GwGossipModelDebug.x:SetText(newX)
                GwGossipModelDebug.y:SetText(newY)
                GwGossipModelDebug.z:SetText(newZ)
            end

            newX = GwGossipModelDebug.x:GetText()
            newY = GwGossipModelDebug.y:GetText()
            newZ = GwGossipModelDebug.z:GetText()

            if newX == nil or newX == "" then
                newX = 0
            end
            if newY == nil or newY == "" then
                newY = 0
            end
            if newZ == nil or newZ == "" then
                newZ = 0
            end

            if isDebugUpdate then
                GwGossipModelDebug.editbox:SetText(createModelPositionOverriderString(x, y, z, newX, newY, newZ))
            end
        else
            for _, v in pairs(MODEL_POSITION_OVERRIDERS) do
                if comparePosition(x, v.oldX) and comparePosition(y, v.oldY) and comparePosition(z, v.oldZ) then
                    newX = v.x
                    newY = v.y
                    newZ = v.z
                    break
                end
            end
        end

        --Let blizzard zoom us out to the frontal view
        self.modelFrame:SetPortraitZoom(0)
        -- rotate the model to the left (very heroic)
        self.modelFrame:SetFacing(-0.30)
        -- make the camera custom so we can change its position and target
        self.modelFrame:MakeCurrentCameraCustom()
        -- we push the model down half step so we dont distort the FOV
        self.modelFrame:SetPosition(newX, newY, -(newZ * (sizeDif / 2)))
        -- we move set the camere target to the face and move the camere up a half step so we dont distort the FOV
        self.modelFrame:SetCameraTarget(fx, fy, newZ + (newZ * (sizeDif / 2)))

        if not isDebugUpdate then
            GW.AddToAnimation("GOSSIP_MODEL", 0, 1, GetTime(), 0.8,
                function(p)
                    p = math.min(1, math.max(0, (p - 0.5) / 0.5))
                    self.modelFrame:SetAlpha(p)
                end
            )
        end
    else
        self.backLayer:Hide()
        self.modelFrame:Hide()
        self.maskLayer:Hide()
    end
end

local greetingsText
local currentGreetingTextIndex = 0

local function setGreetingsTextPaging(dir, forceIndex)
    local newIndex = currentGreetingTextIndex + dir
    if forceIndex then
        newIndex = forceIndex
    end
    if greetingsText and #greetingsText > 0 and #greetingsText >= newIndex and newIndex > 0 then
        currentGreetingTextIndex = newIndex
        GossipFrame.customGossipText:SetText(greetingsText[currentGreetingTextIndex])

        GossipPaginControler.forward:Show()
        GossipPaginControler.back:Show()
        if #greetingsText == newIndex then
            GossipPaginControler.forward:Hide()
        end
        if newIndex == 1 then
            GossipPaginControler.back:Hide()
        end
    end
end
local function setGreetingsText(text)
    greetingsText = splitQuest(text)
    if greetingsText and #greetingsText > 0 then
        currentGreetingTextIndex = 1
    end
    setGreetingsTextPaging(0, 1)
end

local function createCoordDebugInput(self, labelText, index)
    local f = CreateFrame("EditBox", nil, self)
    f:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -(22 * index))
    f:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 0 - (22 * index))
    f:SetSize(20, 20)
    f:SetAutoFocus(false)
    f:SetMultiLine(false)
    f:SetMaxLetters(50)
    f:SetFontObject(ChatFontNormal)
    f:SetText("")

    f.bg = f:CreateTexture(nil, "ARTWORK", nil, 1)
    f.bg:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png") -- add custom overlay texture here
    f.bg:SetAllPoints()

    f.label = f:CreateFontString(nil, "ARTWORK")
    f.label:SetPoint("RIGHT", f, "LEFT", 0, 0)
    f.label:SetJustifyH("LEFT")
    f.label:SetJustifyV("MIDDLE")
    f.label:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER, "OUTLINE")
    f.label:SetText(labelText)

    f:SetScript("OnTextChanged", function() updateModelFrame(GwGossipModelFrame, nil, true) end)
    return f
end
local function loadPortraitDebugMode()
    if GwGossipModelDebug then
        return
    end
    --debug stuff
    local debugModelPositionData = CreateFrame("Frame", "GwGossipModelDebug", GwGossipModelFrame)
    debugModelPositionData:SetSize(300, 300)
    debugModelPositionData:SetPoint("TOPLEFT", GwGossipModelFrame, "BOTTOMRIGHT", 0, 0)
    debugModelPositionData.bg = debugModelPositionData:CreateTexture(nil, "ARTWORK", nil, 1)
    debugModelPositionData.bg:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png") -- add custom overlay texture here
    debugModelPositionData.bg:SetAllPoints()
    debugModelPositionData.bg:SetSize(300, 300)

    debugModelPositionData.editbox = CreateFrame("EditBox", nil, debugModelPositionData)
    debugModelPositionData.editbox:SetPoint("TOPLEFT", debugModelPositionData, "TOPLEFT", 5, -5)
    debugModelPositionData.editbox:SetPoint("BOTTOMRIGHT", debugModelPositionData, "BOTTOMRIGHT", -5, 5)
    debugModelPositionData.editbox:SetAutoFocus(false)
    debugModelPositionData.editbox:SetMultiLine(true)
    debugModelPositionData.editbox:SetMaxLetters(2000)
    debugModelPositionData.editbox:SetFontObject(ChatFontNormal)
    debugModelPositionData.editbox:SetText("")

    debugModelPositionData.x = createCoordDebugInput(debugModelPositionData, "X:", 1)
    debugModelPositionData.y = createCoordDebugInput(debugModelPositionData, "Y:", 2)
    debugModelPositionData.z = createCoordDebugInput(debugModelPositionData, "Z:", 3)
end

local function LoadGossipSkin()
    if not GW.settings.GOSSIP_SKIN_ENABLED then return end

    local GossipFrame = GossipFrame

    if GW.Retail then
        GW.HandleTrimScrollBar(ItemTextScrollFrame.ScrollBar)
        GW.HandleScrollControls(ItemTextScrollFrame)
    else
        ItemTextScrollFrameScrollBar:GwSkinScrollBar()
        ItemTextScrollFrame:GwSkinScrollFrame()
    end
    GW.HandleTrimScrollBar(GossipFrame.GreetingPanel.ScrollBar)
    GW.HandleScrollControls(GossipFrame.GreetingPanel)
    GossipFrame.GreetingPanel.GoodbyeButton:Hide()
    GossipFrame.GreetingPanel.GoodbyeButton:GwStripTextures()
    GossipFrame.GreetingPanel.GoodbyeButton:GwSkinButton(false, true)

    local statusbar = NPCFriendshipStatusBar or GossipFrame.FriendshipStatusBar
    for i = 1, 4 do
        local notch = statusbar["Notch" .. i]
        if notch then
            notch:SetColorTexture(0, 0, 0)
            notch:SetSize(1, 16)
        end
    end

    ItemTextPageText:SetTextColor("P", 1, 1, 1)
    hooksecurefunc(ItemTextPageText, "SetTextColor", function(pageText, headerType, r, g, b)
        if r ~= 1 or g ~= 1 or b ~= 1 then
            pageText:SetTextColor(headerType, 1, 1, 1)
        end
    end)

    ItemTextFrame:GwStripTextures(true)
    ItemTextFrame:GwCreateBackdrop()
    QuestFont:SetTextColor(1, 1, 1)
    if GossipFrameInset then
        GossipFrameInset:Hide()
    end
    GossipFramePortrait:Hide()

    if GossipFrame.Background then
        GossipFrame.Background:Hide()
    end

    local tex = ItemTextFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
    local w, h = ItemTextFrame:GetSize()
    tex:SetPoint("TOP", ItemTextFrame, "TOP", 0, 20)
    tex:SetSize(w + 50, h + 70)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
    ItemTextFrame.tex = tex

    ItemTextScrollFrame:GwStripTextures()

    GossipFrame:GwStripTextures()
    if GossipFrame.GreetingPanel then
        GossipFrame.GreetingPanel:GwStripTextures()
    end
    GossipFrame:GwCreateBackdrop()
    tex = GossipFrame:CreateTexture(nil, "BACKGROUND", nil, 0)

    tex:SetPoint("TOPLEFT", GossipFrame, "TOPLEFT", 0, 0)
    tex:SetSize(1024, 512)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/background.png")
    GossipFrame.tex = tex

    local bgMask = UIParent:CreateMaskTexture()
    bgMask:SetPoint("TOPLEFT", tex, "TOPLEFT", 0, 0)
    bgMask:SetPoint("BOTTOMRIGHT", tex, "BOTTOMLEFT", 0, 0)
    bgMask:SetTexture(
        "Interface/AddOns/GW2_UI/textures/masktest.png",
        "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE"
    )
    GossipFrame.tex:AddMaskTexture(bgMask)
    GossipFrame.bgMask = bgMask

    -- list background
    tex = GossipFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
    tex:SetPoint("TOPLEFT", GossipFrame, "TOPLEFT", 70, -175)
    tex:SetSize(566, 512)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/listbg.png")
    GossipFrame.ListBackground = tex
    --create portrait
    local portraitFrame = CreateFrame("BUTTON", "GwGossipModelFrame", GossipFrame)
    portraitFrame:Show()
    portraitFrame:SetPoint("TOPLEFT", GossipFrame, "TOPLEFT", 548, 24)
    portraitFrame:SetSize(200, 200)

    portraitFrame:SetScript("OnClick", function()
        if IsModifiedClick("CHATLINK") then
            if DEBUG_ENABLED then
                GwGossipModelDebug:Hide()
                DEBUG_ENABLED = false
                updateModelFrame(GwGossipModelFrame)
            else
                loadPortraitDebugMode()
                GwGossipModelDebug:Show()
                DEBUG_ENABLED = true
                updateModelFrame(GwGossipModelFrame)
            end
        end
    end)

    portraitFrame.backLayer = portraitFrame:CreateTexture(nil, "BACKGROUND", nil, -1)
    portraitFrame.backLayer:SetPoint("TOPLEFT", portraitFrame)
    portraitFrame.backLayer:SetPoint("BOTTOMRIGHT", portraitFrame)

    portraitFrame.modelFrame = CreateFrame("PlayerModel", nil, portraitFrame, "GW2ModelLevelTemplate")
    portraitFrame.modelFrame:SetModelDrawLayer("ARTWORK")
    portraitFrame.modelFrame:SetPoint("BOTTOM", portraitFrame.backLayer, "BOTTOM", 20, 0)
    portraitFrame.modelFrame:SetSize(500, 500)

    portraitFrame.maskLayer = portraitFrame:CreateTexture(nil, "ARTWORK", nil, 1)
    portraitFrame.maskLayer:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/modelmask.png") -- add custom overlay texture here
    portraitFrame.maskLayer:SetPoint("TOPLEFT", GossipFrame.tex)
    portraitFrame.maskLayer:SetSize(1024, 256)
    portraitFrame.maskLayer:AddMaskTexture(GossipFrame.bgMask)

    --custom greetings text string
    local greetings = portraitFrame:CreateFontString(nil, "ARTWORK")
    greetings:SetPoint("TOPLEFT", portraitFrame.maskLayer, "TOPLEFT", 45, -45)
    greetings:SetPoint("BOTTOMRIGHT", portraitFrame.maskLayer, "TOPLEFT", 545, -165)
    greetings:SetJustifyH("LEFT")
    greetings:SetJustifyV("MIDDLE")
    greetings:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, "OUTLINE")
    greetings:SetText("")
    GossipFrame.customGossipText = greetings

    -- npc name label
    portraitFrame.npcNameLabel = portraitFrame:CreateTexture(nil, "ARTWORK", nil, 2)
    portraitFrame.npcNameLabel:SetTexture("Interface/AddOns/GW2_UI/textures/gossip/npcname.png")
    portraitFrame.npcNameLabel:SetSize(200, 32)
    portraitFrame.npcNameLabel:SetPoint("TOPLEFT", portraitFrame, "TOPLEFT", -3, -170)

    portraitFrame.npcNameText = portraitFrame:CreateFontString(nil, "ARTWORK")
    portraitFrame.npcNameText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL, "OUTLINE")
    portraitFrame.npcNameText:SetTextColor(1, 1, 1)
    portraitFrame.npcNameText:ClearAllPoints()
    portraitFrame.npcNameText:SetPoint("TOPLEFT", portraitFrame.npcNameLabel, "TOPLEFT", 5, 0)
    portraitFrame.npcNameText:SetPoint("BOTTOMRIGHT", portraitFrame.npcNameLabel, "BOTTOMRIGHT", -10, 0)
    portraitFrame.npcNameText:SetJustifyH("LEFT")

    hooksecurefunc(GossipFrame, "Update", function()
        updateModelFrame(portraitFrame)
    end)
    local titleText = GW.Classic and GossipFrameTitleText or (GW.Mists  or GW.TBC) and GossipFrame.TitleText or GossipFrame.TitleContainer.TitleText
    hooksecurefunc(titleText, "SetText", function(_, txt)
        portraitFrame.npcNameText:SetText(txt)
    end)
    if titleText.SetTitleFormatted then
        hooksecurefunc(titleText, "SetTitleFormatted", function(_, fmt, ...)
            portraitFrame.npcNameText:SetFormattedText(fmt, ...)
        end)
    end
    titleText:Hide()

    GossipFrame.CloseButton:GwSkinButton(true)
    GossipFrame.CloseButton:SetSize(20, 20)
    GossipFrame.CloseButton:ClearAllPoints()
    GossipFrame.CloseButton:SetPoint("BOTTOMLEFT", portraitFrame.npcNameLabel, "BOTTOMRIGHT", -10, 0)
    GossipFrame.CloseButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/gossip/closebutton.png")
    GossipFrame.CloseButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/gossip/closebutton.png")
    GossipFrame.CloseButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/gossip/closebutton.png")
    if ItemTextFrameCloseButton then
        ItemTextFrameCloseButton:GwSkinButton(true)
        ItemTextFrameCloseButton:SetSize(20, 20)
    end

    if ItemTextCloseButton then
        ItemTextCloseButton:GwSkinButton(true)
        ItemTextCloseButton:SetSize(20, 20)
    end

    GossipFrame.GreetingPanel.ScrollBox:ClearAllPoints()
    GossipFrame.GreetingPanel.ScrollBox:SetPoint("TOPLEFT", GossipFrame.ListBackground, "TOPLEFT")
    GossipFrame.GreetingPanel.ScrollBox:SetPoint("BOTTOMRIGHT", GossipFrame.ListBackground, "BOTTOMRIGHT", 0, 126)
    GW.HandleNextPrevButton(ItemTextPrevPageButton)
    GW.HandleNextPrevButton(ItemTextNextPageButton)

    local GossipPaginControler = CreateFrame("Button", "GossipPaginControler", GossipFrame)
    local GossipPagingBack = CreateFrame("Button", "GossipPagingBack", GossipPaginControler, "GwHeroPanelMenuButtonBackTemplate")
    local GossipPagingForward = CreateFrame("Button", "GossipPagingForward", GossipPaginControler, "GwHeroPanelMenuButtonBackTemplate")

    GossipPaginControler:RegisterForClicks("LeftButtonDown", "RightButtonDown")

    GossipPaginControler.back = GossipPagingBack
    GossipPaginControler.forward = GossipPagingForward

    GossipPagingBack:ClearAllPoints()
    GossipPagingForward:ClearAllPoints()
    GossipPaginControler:SetSize(64, 32)
    GossipPagingForward:SetSize(32, 32)
    GossipPagingBack:SetSize(32, 32)
    GossipPagingForward:ClearNormalTexture()
    GossipPagingBack:ClearNormalTexture()
    GossipPagingForward.backarrow:SetRotation(math.pi)
    GossipPaginControler:SetPoint("TOPLEFT", greetings, "TOPLEFT", 0, 0)
    GossipPaginControler:SetPoint("BOTTOMRIGHT", greetings, "BOTTOMRIGHT", 0, 0)

    GossipPagingForward:SetPoint("RIGHT", portraitFrame.npcNameLabel, "LEFT", -5, 0)
    GossipPagingBack:SetPoint("RIGHT", GossipPagingForward, "LEFT", 0, 0)

    GossipPaginControler:SetScript("OnClick", function(_, button)
        local dir = button == "LeftButton" and 1 or -1
        setGreetingsTextPaging(dir)
    end)
    GossipPagingForward:SetScript("OnClick", function()
        setGreetingsTextPaging(1)
    end)
    GossipPagingBack:SetScript("OnClick", function()
        setGreetingsTextPaging(-1)
    end)

    GossipFrame:SetPropagateKeyboardInput(true)
    GossipFrame:HookScript("OnKeyDown", function(_, key)
        --Brut force the key to number.
        --Downside if butto name contains a number it will be used. example JoyStick1
        local numKey = tonumber(key)
        local foundUsableKey = false
        if numKey and gossipOptionPointer[numKey] then
            gossipOptionPointer[numKey]:Click()
            foundUsableKey = true
        end
        if not InCombatLockdown() then
            GossipFrame:SetPropagateKeyboardInput(not foundUsableKey)
        end
    end)

    GossipFrame:HookScript("OnShow", function()
        GossipFrame.CloseButton:Hide()

        GW.AddToAnimation("GOSSIP_FRAME_FADE", 0, 1, GetTime(), 0.4,
            function(p)
                GossipFrame:SetAlpha(math.max(0.5, p))
                portraitFrame.npcNameLabel:SetWidth(200 * p)
                portraitFrame.npcNameLabel:SetTexCoord(0, p, 0, 1)

                GossipFrame.bgMask:SetPoint("BOTTOMRIGHT", GossipFrame.tex, "BOTTOMLEFT",
                    lerp(0, (GossipFrame.tex:GetWidth()), p), 0)
            end, nil, function()
                GossipFrame.CloseButton:Show()
            end
        )
    end)

    local GreetingPanelFirstLoad = true
    hooksecurefunc(GossipFrame.GreetingPanel.ScrollBox, "Update", function(frame)
        --Reset pointers for buttons
        gossipOptionPointer = {}
        -- we need to check each button for button type so we dont count titles and spacers
        local hasButton = false
        GossipFrame.GreetingPanel.ScrollBox:ForEachFrame(function(self, elementData)
            if elementData.buttonType ~= GOSSIP_BUTTON_TYPE_DIVIDER and elementData.buttonType ~= GOSSIP_BUTTON_TYPE_TITLE then
                hasButton = true
            end
            updateGossipOption(self, elementData)
        end)
        if hasButton then
            GossipFrame.ListBackground:Show()
            GossipFrame.GreetingPanel:Show()
        else
            GossipFrame.ListBackground:Hide()
            GossipFrame.GreetingPanel:Hide()
        end

        if GreetingPanelFirstLoad then
            GreetingPanelFirstLoad = false
            -- replace the element default size calculator
            GossipFrame.GreetingPanel.ScrollBar:SetHideIfUnscrollable(true)
            GossipFrame.GreetingPanel.ScrollBox.view:SetPadding(10, 10, 10, 10, 0)
            GossipFrame.GreetingPanel.ScrollBox.view:SetElementExtentCalculator(function(_, elementData)
                if elementData.greetingTextFrame then
                    setGreetingsText(elementData.text)
                    return 0.1
                elseif elementData.buttonType == GOSSIP_BUTTON_TYPE_DIVIDER then
                    return 0.1
                elseif elementData.titleOptionButton then
                    elementData.titleOptionButton:Setup(elementData.info)
                    return math.max(32, elementData.titleOptionButton:GetHeight())
                else
                    return 32
                end
            end)
        end
    end)

    local NPCFriendshipStatusBar = NPCFriendshipStatusBar or GossipFrame.FriendshipStatusBar
    NPCFriendshipStatusBar:SetFrameLevel(portraitFrame:GetFrameLevel() + 2)
    NPCFriendshipStatusBar:ClearAllPoints()
    NPCFriendshipStatusBar:SetPoint("BOTTOMLEFT", portraitFrame.npcNameLabel, "TOPLEFT", 5, 3)
    NPCFriendshipStatusBar:SetPoint("BOTTOMRIGHT", portraitFrame.npcNameLabel, "TOPRIGHT", 5, 3)
    NPCFriendshipStatusBar:SetHeight(16)
    NPCFriendshipStatusBar:GwStripTextures()
    NPCFriendshipStatusBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    NPCFriendshipStatusBar.bg = NPCFriendshipStatusBar:CreateTexture(nil, "BACKGROUND")
    NPCFriendshipStatusBar.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg.png")
    NPCFriendshipStatusBar.bg:SetPoint("TOPLEFT", NPCFriendshipStatusBar, "TOPLEFT", -3, 3)
    NPCFriendshipStatusBar.bg:SetPoint("BOTTOMRIGHT", NPCFriendshipStatusBar, "BOTTOMRIGHT", 3, -3)

    NPCFriendshipStatusBar.icon:ClearAllPoints()
    NPCFriendshipStatusBar.icon:SetPoint("RIGHT", NPCFriendshipStatusBar, "LEFT", 0, -3)
    NPCFriendshipStatusBar.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    --QuestFrame
    if GW.Retail then
        local QuestFrame = QuestFrame
        QuestFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, "OUTLINE", 2)
        QuestFrame:GwStripTextures()
        QuestFrame:GwCreateBackdrop()
        QuestFrame.tex = QuestFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
        w, h = QuestFrame:GetSize()
        QuestFrame.tex:SetPoint("TOP", QuestFrame, "TOP", 0, 20)
        QuestFrame.tex:SetSize(w + 50, h + 70)
        QuestFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")

        QuestFrame.CloseButton:GwSkinButton(true)
        QuestFrame.CloseButton:SetSize(20, 20)

        QuestFrameDetailPanel:GwStripTextures(nil, true)
        QuestDetailScrollFrame:GwStripTextures()
        QuestProgressScrollFrame:GwStripTextures()
        QuestGreetingScrollFrame:GwStripTextures()

        QuestFrameGreetingPanel:HookScript("OnShow", function(frame)
            for button in frame.titleButtonPool:EnumerateActive() do
                button.Icon:SetDrawLayer("ARTWORK")

                local text = button:GetFontString():GetText()
                if text and strfind(text, "|cff000000") then
                    button:GetFontString():SetText(gsub(text, "|cff000000", "|cffffe519"))
                end
            end
        end)

        local sealFrameTextColor = {
            ["480404"] = "c20606",
            ["042c54"] = "1c86ee",
        }

        if not GW.QuestInfo_Display_hooked then
            hooksecurefunc("QuestInfo_Display", GW.QuestInfo_Display)
            GW.QuestInfo_Display_hooked = true
        end
        hooksecurefunc("QuestFrame_SetTitleTextColor", function(self)
            self:SetTextColor(1, 0.8, 0.1)
        end)
        hooksecurefunc("QuestFrame_SetTextColor", function(self)
            self:SetTextColor(1, 1, 1)
        end)
        hooksecurefunc("QuestFrameProgressItems_Update", function()
            QuestProgressRequiredItemsText:SetTextColor(1, 0.8, 0.1)
            QuestProgressRequiredMoneyText:SetTextColor(1, 1, 1)
        end)
        hooksecurefunc("QuestInfo_ShowRequiredMoney", function()
            local requiredMoney = GetQuestLogRequiredMoney()
            if requiredMoney > 0 then
                if requiredMoney > GetMoney() then
                    QuestInfoRequiredMoneyText:SetTextColor(0.63, 0.09, 0.09)
                else
                    QuestInfoRequiredMoneyText:SetTextColor(1, 0.8, 0.1)
                end
            end
        end)
        hooksecurefunc(QuestInfoSealFrame.Text, "SetText", function(self, text)
            if text and text ~= "" then
                local colorStr, rawText = strmatch(text, "|c[fF][fF](%x%x%x%x%x%x)(.-)|r")
                if colorStr and rawText then
                    colorStr = sealFrameTextColor[colorStr] or "99ccff"
                    self:SetFormattedText("|cff%s%s|r", colorStr, rawText)
                end
            end
        end)
        hooksecurefunc("QuestFrameProgressItems_Update", function()
            QuestProgressRequiredItemsText:SetTextColor(1, 0.8, 0.1)
            QuestProgressRequiredMoneyText:SetTextColor(1, 1, 1)
        end)

        for i = 1, 6 do
            local button = _G["QuestProgressItem" .. i]
            local icon = _G["QuestProgressItem" .. i .. "IconTexture"]
            icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            button:GwStripTextures()
            button:SetFrameLevel(button:GetFrameLevel() + 1)
        end

        QuestFrameDetailPanel.SealMaterialBG:SetAlpha(0)
        QuestFrameRewardPanel.SealMaterialBG:SetAlpha(0)
        QuestFrameProgressPanel.SealMaterialBG:SetAlpha(0)
        QuestFrameGreetingPanel.SealMaterialBG:SetAlpha(0)

        QuestFrameGreetingPanel:GwStripTextures(true)
        QuestFrameGreetingGoodbyeButton:GwSkinButton(false, true)
        QuestGreetingFrameHorizontalBreak:GwKill()

        QuestDetailScrollChildFrame:GwStripTextures(true)
        QuestRewardScrollChildFrame:GwStripTextures(true)
        QuestFrameProgressPanel:GwStripTextures(true)
        QuestFrameRewardPanel:GwStripTextures(true)

        GW.HandleTrimScrollBar(QuestProgressScrollFrame.ScrollBar, true)
        GW.HandleTrimScrollBar(QuestRewardScrollFrame.ScrollBar, true)
        GW.HandleTrimScrollBar(QuestDetailScrollFrame.ScrollBar, true)
        GW.HandleTrimScrollBar(QuestGreetingScrollFrame.ScrollBar, true)

        GW.HandleScrollControls(QuestProgressScrollFrame)
        GW.HandleScrollControls(QuestRewardScrollFrame)
        GW.HandleScrollControls(QuestDetailScrollFrame)
        GW.HandleScrollControls(QuestGreetingScrollFrame)

        QuestFrameAcceptButton:GwSkinButton(false, true)
        QuestFrameDeclineButton:GwSkinButton(false, true)
        QuestFrameCompleteButton:GwSkinButton(false, true)
        QuestFrameGoodbyeButton:GwSkinButton(false, true)
        QuestFrameCompleteQuestButton:GwSkinButton(false, true)

        QuestModelScene.ModelTextFrame:GwStripTextures()
        QuestNPCModelText:SetTextColor(1, 1, 1)

        QuestModelScene:SetHeight(253)
        QuestModelScene:GwStripTextures()
        QuestModelScene:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
        QuestModelScene.ModelTextFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, nil, 10)

        QuestNPCModelNameText:ClearAllPoints()
        QuestNPCModelNameText:SetPoint("TOP", QuestModelScene, 0, -10)
        QuestNPCModelNameText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER, "OUTLINE")
        QuestNPCModelNameText:SetTextColor(1, 1, 1)

        QuestNPCModelText:SetJustifyH("CENTER")
        QuestNPCModelTextScrollFrame:ClearAllPoints()
        QuestNPCModelTextScrollFrame:SetPoint("TOPLEFT", QuestModelScene.ModelTextFrame, 2, -2)
        QuestNPCModelTextScrollFrame:SetPoint("BOTTOMRIGHT", QuestModelScene.ModelTextFrame, -10, 6)
        QuestNPCModelTextScrollChildFrame:GwSetInside(QuestNPCModelTextScrollFrame)

        GW.HandleTrimScrollBar(QuestNPCModelTextScrollFrame.ScrollBar)
        GW.HandleScrollControls(QuestNPCModelTextScrollFrame)
        hooksecurefunc("QuestFrame_ShowQuestPortrait", function(frame, _, _, _, _, _, x, y)
            local mapFrame = QuestMapFrame:GetParent()

            QuestModelScene:ClearAllPoints()
            QuestModelScene:SetPoint("TOPLEFT", frame, "TOPRIGHT", (x or 0) + (frame == mapFrame and 0 or 6), y or 0)
        end)

        QuestLogPopupDetailFrame:GwStripTextures(nil, true)
        QuestLogPopupDetailFrame:GwCreateBackdrop()
        tex = QuestLogPopupDetailFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
        w, h = QuestLogPopupDetailFrame:GetSize()
        tex:SetPoint("TOP", QuestLogPopupDetailFrame, "TOP", 0, 20)
        tex:SetSize(w + 50, h + 70)
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
        QuestLogPopupDetailFrame.tex = tex

        QuestLogPopupDetailFrameAbandonButton:GwSkinButton(false, true)
        QuestLogPopupDetailFrameShareButton:GwSkinButton(false, true)
        QuestLogPopupDetailFrameTrackButton:GwSkinButton(false, true)
        QuestLogPopupDetailFrameCloseButton:GwSkinButton(true)
        QuestLogPopupDetailFrameCloseButton:SetSize(20, 20)

        QuestLogPopupDetailFrameScrollFrame:GwStripTextures()
        GW.HandleTrimScrollBar(QuestLogPopupDetailFrameScrollFrame.ScrollBar, true)
        GW.HandleScrollControls(QuestLogPopupDetailFrameScrollFrame)
        QuestLogPopupDetailFrameScrollFrame:GwSkinScrollFrame()
    end

    -- mover
    GossipFrame.mover = CreateFrame("Frame", nil, GossipFrame)
    GossipFrame.mover:EnableMouse(true)
    GossipFrame:SetMovable(true)
    GossipFrame.mover:SetSize(w, 30)
    GossipFrame.mover:SetPoint("BOTTOMLEFT", GossipFrame, "TOPLEFT", 0, -20)
    GossipFrame.mover:SetPoint("BOTTOMRIGHT", GossipFrame, "TOPRIGHT", 0, 20)
    GossipFrame.mover:RegisterForDrag("LeftButton")
    GossipFrame:SetClampedToScreen(true)
    GossipFrame.mover:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
    end)
    GossipFrame.mover:SetScript("OnDragStop", function(self)
        self:GetParent():StopMovingOrSizing()
    end)
end
GW.LoadGossipSkin = LoadGossipSkin
