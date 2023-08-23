local _, GW = ...
local AddToAnimation = GW.AddToAnimation
local CommaValue = GW.CommaValue
local CountTable  = GW.CountTable
local MoveTowards = GW.MoveTowards
local getSpriteByIndex = GW.getSpriteByIndex
local playerGUID
local unitToGuid = {}
local guidToUnit = {}

local fontStringList = {}
local namePlatesOffsets = {}
local namePlateClassicGrid = {}
local namePlatesCriticalOffsets = {}

local eventHandler = CreateFrame("Frame")

local settings = {}

local elementIcons = {
    width = 512,
    height = 256,
    colums = 4,
    rows = 2
}

local colorTable ={
    gw = {
        spell = {r = 1, g = 1, b = 1, a = 1},
        melee = {r = 1, g = 1, b = 1, a = 1},
        pet = {r = 1, g = 0.2, b= 0.2, a = 1},
        heal = {r = 25 / 255, g = 255 / 255, b = 25 / 255, a = 1},
    },
    blizzard = {
        spell = {r = 1, g = 1, b = 0, a = 1},
        melee = {r = 1, g = 1, b = 1, a = 1},
        pet = {r = 1, g = 1, b = 1, a = 1},
        heal = {r = 25 / 255, g = 255 / 255, b = 25 / 255, a = 1},
    }
}

local NUM_OBJECTS_HARDLIMIT = 20

--Animation settings
local NORMAL_ANIMATION_DURATION = 0.7
local CRITICAL_ANIMATION_DURATION = 1.2

local STACKING_NORMAL_ANIMATION_DURATION = 1
local STACKING_CRITICAL_ANIMATION_DURATION = 1
local STACKING_NORMAL_ANIMATION_OFFSET_Y = 10
local STACKING_NORMAL_ANIMATION_OFFSET_X = -20
local STACKING_MOVESPEED = 1

local CRITICAL_SCALE_MODIFIER = 1.5
local PET_SCALE_MODIFIER = 0.7

local CLASSIC_NUM_HITS = 0
local CLASSIC_AVARAGE_HIT = 0

local NORMAL_ANIMATION_OFFSET_Y = 20

local stackingContainer
local ClassicDummyFrame

local formats = {Default = "Default", Stacking = "Stacking", Classic = "Classic"}

local NORMAL_ANIMATION
local CRITICAL_ANIMATION

local classicGridData = {
    {x =1, y=0},
    {x =0, y=-1},
    {x =0, y=1},
    {x =-1, y=0},
    {x =-1, y=-1},
    {x =1, y=-1},
    {x =1, y=1},
    {x =-1, y=1},
    {x =0, y=2},
    {x =2, y=0},
    {x =-2, y=0},
    {x =0, y=-2},
    {x =-2, y=-1},
    {x =1, y=-2},
    {x =2, y=1},
    {x =2, y=-1},
    {x =-1, y=-2},
    {x =-1, y=2},
    {x =-2, y=1},
    {x =1, y=2},
    {x =2, y=2},
    {x =2, y=-2},
    {x =-2, y=-2},
    {x =-2, y=2},
    {x =0, y=-3},
    {x =-3, y=0},
    {x =0, y=3},
    {x =3, y=0},
    {x =-1, y=3},
    {x =3, y=1},
    {x =3, y=-1},
    {x =-1, y=-3},
    {x =1, y=3},
    {x =-3, y=-1},
    {x =-3, y=1},
    {x =1, y=-3},
    {x =2, y=-3},
    {x =-2, y=-3},
    {x =-3, y=2},
    {x =3, y=2},
    {x =-2, y=3},
    {x =-3, y=-2},
    {x =3, y=-2},
    {x =2, y=3},
    {x =0, y=-4},
    {x =4, y=0},
    {x =-4, y=0},
    {x =0, y=4},
    {x =-1, y=-4},
    {x =4, y=-1},
    {x =-4, y=1},
    {x =-4, y=-1},
    {x =4, y=1},
    {x =-1, y=4},
    {x =1, y=-4},
    {x =1, y=4},
    {x =-3, y=-3},
    {x =3, y=3},
    {x =3, y=-3},
    {x =-3, y=3},
    {x =4, y=-2},
    {x =-4, y=-2},
    {x =2, y=-4},
    {x =2, y=4},
    {x =4, y=2},
    {x =-4, y=2},
    {x =-2, y=-4},
    {x =-2, y=4},
    {x =5, y=0},
    {x =-5, y=0},
    {x =3, y=-4},
    {x =-4, y=3},
    {x =-3, y=4},
    {x =0, y=-5},
    {x =-4, y=-3},
    {x =0, y=5},
    {x =4, y=-3},
    {x =3, y=4},
    {x =4, y=3},
    {x =-3, y=-4},
    {x =-1, y=5},
    {x =5, y=1},
    {x =1, y=5},
    {x =-1, y=-5},
    {x =-5, y=1},
    {x =-5, y=-1},
    {x =1, y=-5},
    {x =5, y=-1},
    {x =2, y=5},
    {x =-5, y=-2},
    {x =-2, y=-5},
    {x =5, y=2},
    {x =5, y=-2},
    {x =-2, y=5},
    {x =-5, y=2},
    {x =2, y=-5},
    {x =4, y=4},
    {x =-4, y=4},
    {x =-4, y=-4},
    {x =4, y=-4},
    {x =-3, y=5},
    {x =-5, y=3},
    {x =-5, y=-3},
    {x =5, y=3},
    {x =3, y=5},
    {x =-3, y=-5},
    {x =5, y=-3},
    {x =3, y=-5},
    {x =6, y=0},
    {x =0, y=6},
    {x =0, y=-6},
    {x =-6, y=0},
    {x =1, y=-6},
    {x =-1, y=6},
    {x =-1, y=-6},
    {x =1, y=6},
    {x =6, y=-1},
    {x =-6, y=1},
    {x =-6, y=-1},
    {x =6, y=1},
    {x =6, y=2},
    {x =-6, y=2},
    {x =-2, y=6},
    {x =-6, y=-2},
    {x =-2, y=-6},
    {x =2, y=-6},
    {x =2, y=6},
    {x =6, y=-2},
    {x =-5, y=-4},
    {x =-4, y=5},
    {x =5, y=4},
    {x =4, y=-5},
    {x =-4, y=-5},
    {x =5, y=-4},
    {x =-5, y=4},
    {x =4, y=5},
    {x =6, y=-3},
    {x =6, y=3},
    {x =3, y=6},
    {x =3, y=-6},
    {x =-6, y=3},
    {x =-3, y=-6},
    {x =-3, y=6},
    {x =-6, y=-3},
    {x =0, y=-7},
    {x =7, y=0},
    {x =-7, y=0},
    {x =0, y=7},
    {x =5, y=5},
    {x =5, y=-5},
    {x =-5, y=-5},
    {x =7, y=1},
    {x =-1, y=-7},
    {x =1, y=7},
    {x =1, y=-7},
    {x =-1, y=7},
    {x =-7, y=-1},
    {x =-7, y=1},
    {x =7, y=-1},
    {x =-5, y=5},
    {x =4, y=6},
    {x =6, y=4},
    {x =4, y=-6},
    {x =6, y=-4},
    {x =-6, y=-4},
    {x =-6, y=4},
    {x =-4, y=6},
    {x =-4, y=-6},
    {x =2, y=7},
    {x =-7, y=-2},
    {x =2, y=-7},
    {x =-2, y=7},
    {x =-7, y=2},
    {x =7, y=-2},
    {x =7, y=2},
    {x =-2, y=-7},
    {x =3, y=7},
    {x =-7, y=-3},
    {x =-7, y=3},
    {x =3, y=-7},
    {x =-3, y=-7},
    {x =7, y=-3},
    {x =-3, y=7},
    {x =7, y=3},
    {x =6, y=-5},
    {x =6, y=5},
    {x =5, y=6},
    {x =-5, y=-6},
    {x =-6, y=5},
    {x =-5, y=6},
    {x =5, y=-6},
    {x =-6, y=-5},
    {x =0, y=-8},
    {x =8, y=0},
    {x =0, y=8},
    {x =-8, y=0},
    {x =-4, y=7},
    {x =1, y=8},
    {x =7, y=-4},
    {x =-1, y=8},
    {x =7, y=4},
    {x =-4, y=-7},
    {x =1, y=-8},
    {x =4, y=-7},
    {x =8, y=1},
    {x =4, y=7},
    {x =-8, y=-1},
    {x =-8, y=1},
    {x =-7, y=-4},
    {x =-1, y=-8},
    {x =-7, y=4},
    {x =8, y=-1},
    {x =8, y=2},
    {x =2, y=-8},
    {x =-8, y=2},
    {x =-2, y=8},
    {x =-2, y=-8},
    {x =8, y=-2},
    {x =-8, y=-2},
    {x =2, y=8},
    {x =6, y=-6},
    {x =6, y=6},
    {x =-6, y=6},
    {x =-6, y=-6},
    {x =3, y=8},
    {x =8, y=3},
    {x =-8, y=3},
    {x =3, y=-8},
    {x =8, y=-3},
    {x =-3, y=8},
    {x =-8, y=-3},
    {x =-3, y=-8},
    {x =-5, y=-7},
    {x =7, y=-5},
    {x =-7, y=-5},
    {x =7, y=5},
    {x =5, y=7},
    {x =-5, y=7},
    {x =-7, y=5},
    {x =5, y=-7},
    {x =4, y=8},
    {x =4, y=-8},
    {x =8, y=-4},
    {x =-4, y=8},
    {x =-4, y=-8},
    {x =8, y=4},
    {x =-8, y=-4},
    {x =-8, y=4},
    {x =0, y=-9},
    {x =-9, y=0},
    {x =9, y=0},
    {x =0, y=9},
    {x =9, y=1},
    {x =-9, y=1},
    {x =-1, y=9},
    {x =1, y=-9},
    {x =1, y=9},
    {x =-1, y=-9},
    {x =9, y=-1},
    {x =-9, y=-1},
    {x =-7, y=6},
    {x =-2, y=-9},
    {x =6, y=-7},
    {x =9, y=-2},
    {x =-6, y=-7},
    {x =-2, y=9},
    {x =-9, y=2},
    {x =-7, y=-6},
    {x =2, y=9},
    {x =7, y=6},
    {x =2, y=-9},
    {x =6, y=7},
    {x =-9, y=-2},
    {x =-6, y=7},
    {x =9, y=2},
    {x =7, y=-6},
    {x =8, y=-5},
    {x =-5, y=-8},
    {x =8, y=5},
    {x =5, y=8},
    {x =-5, y=8},
    {x =-8, y=-5},
    {x =5, y=-8},
    {x =-8, y=5},
    {x =-3, y=-9},
    {x =9, y=3},
    {x =3, y=9},
    {x =-9, y=-3},
    {x =3, y=-9},
    {x =-3, y=9},
    {x =-9, y=3},
    {x =9, y=-3},
    {x =9, y=-4},
    {x =-9, y=4},
    {x =4, y=9},
    {x =-9, y=-4},
    {x =-4, y=9},
    {x =9, y=4},
    {x =4, y=-9},
    {x =-4, y=-9},
    {x =7, y=-7},
    {x =-7, y=7},
    {x =7, y=7},
    {x =-7, y=-7},
    {x =6, y=-8},
    {x =0, y=10},
    {x =-8, y=-6},
    {x =6, y=8},
    {x =8, y=6},
    {x =-8, y=6},
    {x =0, y=-10},
    {x =-6, y=-8},
    {x =-10, y=0},
    {x =8, y=-6},
    {x =-6, y=8},
    {x =10, y=0},
    {x =1, y=10},
    {x =-10, y=1},
    {x =1, y=-10},
    {x =-10, y=-1},
    {x =10, y=1},
    {x =-1, y=10},
    {x =10, y=-1},
    {x =-1, y=-10},
    {x =10, y=-2},
    {x =2, y=10},
    {x =-10, y=-2},
    {x =-2, y=-10},
    {x =2, y=-10},
    {x =-2, y=10},
    {x =10, y=2},
    {x =-10, y=2},
    {x =-9, y=5},
    {x =9, y=5},
    {x =9, y=-5},
    {x =-9, y=-5},
    {x =5, y=-9},
    {x =5, y=9},
    {x =-5, y=-9},
    {x =-5, y=9},
    {x =10, y=3},
    {x =10, y=-3},
    {x =-10, y=3},
    {x =-10, y=-3},
    {x =-3, y=10},
    {x =3, y=-10},
    {x =-3, y=-10},
    {x =3, y=10},
    {x =8, y=-7},
    {x =8, y=7},
    {x =7, y=8},
    {x =7, y=-8},
    {x =-7, y=-8},
    {x =-7, y=8},
    {x =-8, y=7},
    {x =-8, y=-7},
    {x =-10, y=-4},
    {x =-4, y=-10},
    {x =-4, y=10},
    {x =4, y=-10},
    {x =10, y=4},
    {x =4, y=10},
    {x =-10, y=4},
    {x =10, y=-4},
    {x =9, y=6},
    {x =6, y=9},
    {x =9, y=-6},
    {x =6, y=-9},
    {x =-9, y=-6},
    {x =-6, y=-9},
    {x =-9, y=6},
    {x =-6, y=9},
    {x =-5, y=10},
    {x =-5, y=-10},
    {x =10, y=5},
    {x =10, y=-5},
    {x =-10, y=5},
    {x =5, y=10},
    {x =5, y=-10},
    {x =-10, y=-5},
    {x =8, y=8},
    {x =-8, y=8},
    {x =8, y=-8},
    {x =-8, y=-8},
    {x =7, y=9},
    {x =-7, y=9},
    {x =-9, y=-7},
    {x =-9, y=7},
    {x =9, y=-7},
    {x =7, y=-9},
    {x =-7, y=-9},
    {x =9, y=7},
    {x =10, y=-6},
    {x =-10, y=6},
    {x =6, y=-10},
    {x =10, y=6},
    {x =6, y=10},
    {x =-10, y=-6},
    {x =-6, y=-10},
    {x =-6, y=10},
    {x =9, y=-8},
    {x =-9, y=-8},
    {x =8, y=-9},
    {x =-8, y=-9},
    {x =8, y=9},
    {x =9, y=8},
    {x =-9, y=8},
    {x =-8, y=9},
    {x =7, y=-10},
    {x =-7, y=-10},
    {x =10, y=-7},
    {x =-7, y=10},
    {x =-10, y=7},
    {x =-10, y=-7},
    {x =7, y=10},
    {x =10, y=7},
    {x =-9, y=9},
    {x =9, y=-9},
    {x =9, y=9},
    {x =-9, y=-9},
    {x =-10, y=8},
    {x =-8, y=-10},
    {x =-8, y=10},
    {x =-10, y=-8},
    {x =8, y=-10},
    {x =10, y=8},
    {x =10, y=-8},
    {x =8, y=10},
    {x =10, y=-9},
    {x =-10, y=-9},
    {x =9, y=10},
    {x =9, y=-10},
    {x =-9, y=10},
    {x =-9, y=-10},
    {x =10, y=9},
    {x =-10, y=9},
    {x =-10, y=-10},
    {x =-10, y=10},
    {x =10, y=-10},
    {x =10, y=10},
}

local usedColorTable
local function UpdateSettings()
    settings.useBlizzardColor = GW.GetSetting("GW_COMBAT_TEXT_BLIZZARD_COLOR")
    settings.useCommaFormat = GW.GetSetting("GW_COMBAT_TEXT_COMMA_FORMAT")
    settings.usedFormat = GW.GetSetting("GW_COMBAT_TEXT_STYLE")
    settings.classicFormatAnchorPoint = GW.GetSetting("GW_COMBAT_TEXT_STYLE_CLASSIC_ANCHOR")
    settings.showHealNumbers = GW.GetSetting("GW_COMBAT_TEXT_SHOW_HEALING_NUMBERS")

    usedColorTable = settings.useBlizzardColor and colorTable.blizzard or colorTable.gw
end
GW.UpdateDameTextSettings = UpdateSettings

local function getSchoolIndex(school)
    if school == 1 then         -- 	Physical
        return 0
    elseif school == 2 then     -- 	Holy
        return 1
    elseif school == 4 then     -- 	Fire
        return 6
    elseif school == 8 then     -- 	Nature
        return 2
    elseif school == 16 then    -- 	Frost
        return 5
    elseif school == 32 then    -- 	Shadow
        return 3
    elseif school == 64 then    -- 	Arcane
        return 4
    else
        return false
    end
end
local function getSchoolIconMap(self, school)

    local iconID = getSchoolIndex(school)

    if iconID then
        self:SetTexCoord(getSpriteByIndex(elementIcons, iconID))
        return true
    else
        return false
    end
end

local function calcAvarageHit(amount)
    if CLASSIC_NUM_HITS>100 then
        return
    end
    CLASSIC_NUM_HITS = CLASSIC_NUM_HITS + 1
    CLASSIC_AVARAGE_HIT = CLASSIC_AVARAGE_HIT + amount
end
local function getAvrageHitModifier(amount,critical)
  if amount == nil then return 0 end

	local a = CLASSIC_AVARAGE_HIT / CLASSIC_NUM_HITS;

	local n = math.min(1.5, math.max(0.7, (amount / a)))
	if critical then
		return n / 2
	end
	return n
end
local function classicPositionGrid(namePlate)
    if namePlateClassicGrid[namePlate] == nil then
        namePlateClassicGrid[namePlate] = {}
    end

    for i = 1, 100 do
        if namePlateClassicGrid[namePlate][i] == nil then
            namePlateClassicGrid[namePlate][i] = true
            return i, classicGridData[i].x, classicGridData[i].y
        end
    end

    return nil, 1, 0
end

--STACKING
local function stackingContainerOnUpdate()
    -- for each damage text instance
    local NUM_ACTIVE_DAMAGETEXT_FRAMES = CountTable(stackingContainer.activeFrames)
    if NUM_ACTIVE_DAMAGETEXT_FRAMES <= 0 then return end

    local index = 0
    local newOffsetValue = -((NUM_ACTIVE_DAMAGETEXT_FRAMES * (20 / 2)))
    local currentOffsetValue = stackingContainer.offsetValue or 0

    stackingContainer.offsetValue = MoveTowards(currentOffsetValue, newOffsetValue, STACKING_MOVESPEED)
    for _, f in pairs(stackingContainer.activeFrames) do
        local offsetY = 20 * index
        offsetY = offsetY + stackingContainer.offsetValue
        local frameOffset = (f.offsetY or 0)
        local frameOffsetX = (f.offsetX or 0)
        offsetY = offsetY + frameOffset
        f:ClearAllPoints()
        if f.oldOffsetY == nil then
            f.oldOffsetY = offsetY
        end
        f.oldOffsetY =  MoveTowards(f.oldOffsetY, offsetY, NUM_ACTIVE_DAMAGETEXT_FRAMES)
        f:SetPoint("CENTER", stackingContainer, "CENTER", frameOffsetX, f.oldOffsetY)
        index = index + 1
    end
end

local function animateTextCriticalForStackingFormat(frame)
    local aName = frame:GetName()
    frame.oldOffsetY = nil

    AddToAnimation(
        aName,
        0,
        1,
        GetTime(),
        STACKING_CRITICAL_ANIMATION_DURATION,
        function(p)
            local offsetY = -(STACKING_NORMAL_ANIMATION_OFFSET_Y * p)
            frame.offsetY = offsetY
            frame.offsetX =  0
            if p < 0.25 then
                local scaleFade = p - 0.25
                frame.offsetX = GW.lerp(STACKING_NORMAL_ANIMATION_OFFSET_X, 0, scaleFade / 0.25)
                frame:SetScale(GW.lerp(1 * frame.textScaleModifier * CRITICAL_SCALE_MODIFIER, frame.textScaleModifier, scaleFade / 0.25))
            else
                frame:SetScale(frame.textScaleModifier)
            end

            if p > 0.7 then
                frame:SetAlpha(math.min(1, math.max(0, GW.lerp(1, 0, (p - 0.7) / 0.3))))
            else
                frame:SetAlpha(1)
            end
        end,
        nil,
        function()
            table.remove(stackingContainer.activeFrames,1)
            frame:SetScale(1)
            frame:Hide()
        end
    )
end

local function animateTextNormalForStackingFormat(frame)
    local aName = frame:GetName()
    frame.oldOffsetY = nil

    AddToAnimation(
        aName,
        0,
        1,
        GetTime(),
        STACKING_NORMAL_ANIMATION_DURATION,
        function(p)
            frame.offsetX =  0
            frame:SetScale(1 * frame.textScaleModifier)
            frame.offsetY = -(STACKING_NORMAL_ANIMATION_OFFSET_Y * p)

            if p < 0.25 then
                frame.offsetX = GW.lerp(STACKING_NORMAL_ANIMATION_OFFSET_X, 0, (p - 0.25) / 0.25)
            end
            if p > 0.7 then
                frame:SetAlpha(math.min(1, math.max(0, GW.lerp(1, 0, (p - 0.7) / 0.3))))
            else
                frame:SetAlpha(1)
            end
        end,
        nil,
        function()
            table.remove(stackingContainer.activeFrames, 1)
            frame:SetScale(1)
            frame:Hide()
        end
    )
end

-- DEFAULT
local function animateTextCriticalForDefaultFormat(frame, offsetIndex)
    local aName = frame:GetName()

    AddToAnimation(
        aName,
        0,
        1,
        GetTime(),
        CRITICAL_ANIMATION_DURATION,
        function(p)
            if p < 0.25 then
                local scaleFade = p - 0.25

                frame:SetScale(GW.lerp(1 * frame.textScaleModifier * CRITICAL_SCALE_MODIFIER, frame.textScaleModifier, scaleFade / 0.25))
            else
                frame:SetScale(frame.textScaleModifier)
            end

            if offsetIndex == 0 then
                frame:SetPoint("TOP", frame.anchorFrame, "BOTTOM", 0, 0)
            elseif offsetIndex == 1 then
                frame:SetPoint("TOP", frame.anchorFrame, "BOTTOMLEFT", 0, 0)
            elseif offsetIndex== 2 then
                frame:SetPoint("TOP", frame.anchorFrame, "BOTTOMRIGHT", 0, 0)
            end

            if p > 0.7 then
                frame:SetAlpha(math.min(1, math.max(0, GW.lerp(1, 0, (p - 0.7) / 0.3))))
            else
                frame:SetAlpha(1)
            end
        end,
        nil,
        function()
            frame:SetScale(1)
            frame:Hide()
        end
    )
end

local function animateTextNormalForDefaultFormat(frame, offsetIndex)
    local aName = frame:GetName()

    AddToAnimation(
        aName,
        0,
        1,
        GetTime(),
        NORMAL_ANIMATION_DURATION,
        function(p)
            local offsetY = NORMAL_ANIMATION_OFFSET_Y * p

            frame:SetScale(1 * frame.textScaleModifier )
            if offsetIndex == 0 then
                frame:SetPoint("BOTTOM", frame.anchorFrame, "TOP", 0, offsetY)
            elseif offsetIndex== 1 then
                frame:SetPoint("BOTTOM", frame.anchorFrame, "TOPLEFT", 0, offsetY)
            elseif offsetIndex== 2 then
                frame:SetPoint("BOTTOM", frame.anchorFrame, "TOPRIGHT", 0, offsetY)
            end

            if p > 0.7 then
                frame:SetAlpha(math.min(1, math.max(0, GW.lerp(1, 0, (p - 0.7) / 0.3))))
            else
                frame:SetAlpha(1)
            end
        end,
        nil,
        function()
            frame:SetScale(1)
            frame:Hide()
        end
    )
end

--CLASSIC
local function animateTextCriticalForClassicFormat(frame, gridIndex, x, y)
    local aName = frame:GetName()

    AddToAnimation(
        aName,
        0,
        1,
        GetTime(),
        CRITICAL_ANIMATION_DURATION  * (frame.dynamicScale + CRITICAL_SCALE_MODIFIER),
        function(p)
            if frame.anchorFrame == nil or not frame.anchorFrame:IsShown() then
                frame.anchorFrame = ClassicDummyFrame
                classicPositionGrid(frame.anchorFrame)
            end
            if p < 0.05 and not frame.periodic then
                frame:SetScale(math.max(0.1, GW.lerp(1.5 * frame.dynamicScale * frame.textScaleModifier * CRITICAL_SCALE_MODIFIER, frame.dynamicScale, (p - 0.05) / 0.05)))
            else
                frame:SetScale(math.max(0.1, frame.dynamicScale * frame.textScaleModifier * CRITICAL_SCALE_MODIFIER))
            end

            frame:SetPoint("CENTER", frame.anchorFrame, "CENTER", 50 * x, 50 * y)

            if p > 0.7 then
                frame:SetAlpha(math.min(1, math.max(0, GW.lerp(1, 0, (p - 0.7) / 0.3))))
            else
                frame:SetAlpha(1)
            end
        end,
        nil,
        function()
        if namePlateClassicGrid[frame.anchorFrame] and gridIndex ~= nil then
            namePlateClassicGrid[frame.anchorFrame][gridIndex] = nil
        end
            frame:SetScale(1)
            frame:Hide()
        end
    )
end

local function animateTextNormalForClassicFormat(frame, gridIndex, x, y)
    local aName = frame:GetName()

    AddToAnimation(
        aName,
        0,
        1,
        GetTime(),
        NORMAL_ANIMATION_DURATION,
        function(p)
            if frame.anchorFrame==nil or not frame.anchorFrame:IsShown() then
                frame.anchorFrame = ClassicDummyFrame
                classicPositionGrid(frame.anchorFrame)
            end
            frame:SetPoint("CENTER", frame.anchorFrame, "CENTER", 50 * x, 50 * y)
            if p < 0.10 and not frame.periodic then
                frame:SetScale(math.max(0.1, GW.lerp(1.2 * frame.dynamicScale * frame.textScaleModifier, frame.dynamicScale, (p - 0.10) / 0.10)))
            else
                frame:SetScale(math.max(0.1, frame.dynamicScale * frame.textScaleModifier))
            end
            if p > 0.9 then
                frame:SetAlpha(math.min(1, math.max(0, GW.lerp(1, 0, (p - 0.9) / 0.1))))
            else
                frame:SetAlpha(1)
            end
        end,
        nil,
        function()
            if namePlateClassicGrid[frame.anchorFrame] and gridIndex ~= nil then
                namePlateClassicGrid[frame.anchorFrame][gridIndex] = nil
            end
            frame:SetScale(1)
            frame:Hide()
        end
    )
end

local createdFramesIndex = 0
local function createNewFontElement(self)
    if createdFramesIndex >= NUM_OBJECTS_HARDLIMIT then
--      return nil
    end

    local f = CreateFrame("FRAME", "GwDamageTextElement" .. createdFramesIndex, self, "GwDamageText")
    f.string:SetJustifyV("MIDDLE")
    f.string:SetJustifyH("Left")

    f.id = createdFramesIndex
    table.insert(fontStringList, f)
    createdFramesIndex = createdFramesIndex + 1
    return f
end

local function getFontElement(self)
    for _, f in pairs(fontStringList) do
        if not f:IsShown() then
            return f
        end
    end

    local newFrame = createNewFontElement(self)
    if newFrame ~= nil then
        return newFrame
    end
    for _, f in pairs(fontStringList) do
        return f
    end
end

local function setElementData(self, critical, source, missType, blocked, absorbed, periodic, school)
    if missType then
        self.critTexture:Hide()
        self.string:SetFont(DAMAGE_TEXT_FONT, 18, "OUTLINED")
        self.crit = false
    elseif blocked or absorbed then
        self.critTexture:Hide()
        self.string:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINED")
        self.crit = false
    elseif critical then
        self.critTexture:Show()
        self.string:SetFont(DAMAGE_TEXT_FONT, 34, "OUTLINED")
        self.crit = true
    else
        self.critTexture:Hide()
        self.string:SetFont(DAMAGE_TEXT_FONT, 24, "OUTLINED")
        self.crit = false
    end

    if periodic and getSchoolIconMap(self.bleedTexture, school) then
        self.bleedTexture:Show()
        self.peroidicBackground:Show()
    else
        self.bleedTexture:Hide()
        self.peroidicBackground:Hide()
    end

    self.pet = source == "pet"
    self.textScaleModifier = self.pet and PET_SCALE_MODIFIER or 1
    self.periodic = periodic

    local colorSource = (source == "pet" or source == "melee") and source or source == "heal" and "heal" or "spell"

    self.string:SetTextColor(usedColorTable[colorSource].r, usedColorTable[colorSource].g, usedColorTable[colorSource].b, usedColorTable[colorSource].a)

    self:Show()

    self:ClearAllPoints()
end

local function formatDamageValue(amount)
    return settings.useCommaFormat and CommaValue(amount) or amount
end

local function displayDamageText(self, guid, amount, critical, source, missType, blocked, absorbed, periodic,school)
    local f = getFontElement(self)
    f.string:SetText(missType and getglobal(missType) or blocked and format(TEXT_MODE_A_STRING_RESULT_BLOCK, formatDamageValue(blocked)) or absorbed and format(TEXT_MODE_A_STRING_RESULT_ABSORB, formatDamageValue(absorbed)) or formatDamageValue(amount))

    if settings.usedFormat == formats.Default or settings.usedFormat == formats.Classic then
        local nameplate
        if settings.classicFormatAnchorPoint == "Center" and settings.usedFormat == formats.Classic then
            nameplate = ClassicDummyFrame
        else
            local unit = guidToUnit[guid]

            if unit then
                nameplate = C_NamePlate.GetNamePlateForUnit(unit)
                f.unit = unit
            end

            if not nameplate then
                if settings.usedFormat == formats.Default then
                    return
                else
                    nameplate = ClassicDummyFrame -- use as fallback if namplates out off range
                end
            end
        end
        if amount and amount > 0 then
            calcAvarageHit(amount)
        end

        f.anchorFrame = nameplate
        f.dynamicScale = getAvrageHitModifier(amount,critical)

        setElementData(f, critical, source, missType, blocked, absorbed, periodic, school)

        if namePlatesOffsets[nameplate] == nil then
            namePlatesOffsets[nameplate] = 0
        else
            namePlatesOffsets[nameplate] = namePlatesOffsets[nameplate] + 1
            if namePlatesOffsets[nameplate] > 2 then
                namePlatesOffsets[nameplate] = 0
            end
        end

        if critical then
            if namePlatesCriticalOffsets[nameplate] == nil then
                namePlatesCriticalOffsets[nameplate] = 0
            else
                namePlatesCriticalOffsets[nameplate] = namePlatesCriticalOffsets[nameplate] + 1
                if namePlatesCriticalOffsets[nameplate] > 2 then
                    namePlatesCriticalOffsets[nameplate] = 0
                end
            end

            if settings.usedFormat == formats.Default then
                CRITICAL_ANIMATION(f, namePlatesCriticalOffsets[nameplate])
            else
                CRITICAL_ANIMATION(f, classicPositionGrid(nameplate))
            end
            return
        end
        if settings.usedFormat == formats.Default then
            NORMAL_ANIMATION(f, namePlatesOffsets[nameplate])
        else
            NORMAL_ANIMATION(f, classicPositionGrid(nameplate))
        end
    elseif settings.usedFormat == formats.Stacking then
        f.anchorFrame = stackingContainer
        -- Add damage text to array of active Elements
        table.insert(stackingContainer.activeFrames, f)

        setElementData(f, critical, source, missType, blocked, absorbed, periodic, school)

        -- add to animation here
        if critical then
            CRITICAL_ANIMATION(f)
        else
            NORMAL_ANIMATION(f)
        end
    end
end

local function handleCombatLogEvent(self, _, event, _, sourceGUID, _, sourceFlags, _, destGUID, _, _, _, ...)
    local targetUnit = guidToUnit[destGUID]
    -- if targetNameplate doesnt exists, ignore
    if settings.usedFormat == formats.Default and not targetUnit then return end
    local _
    if playerGUID == sourceGUID then
        local periodic = false
        local element = nil
        if (string.find(event, "_DAMAGE")) then
            local spellName, amount, blocked, absorbed, critical
            if (string.find(event, "SWING")) then
                spellName, amount, _, _, _, blocked, absorbed, critical = "melee", ...
            elseif (string.find(event, "ENVIRONMENTAL")) then
                spellName, amount, _, _, _, blocked, absorbed, critical = ...
            elseif (string.find(event, "PERIODIC")) then
                _, spellName, element, amount, _, _, _, blocked, absorbed, critical = ...
                periodic = true
            else
                _, spellName, _, amount, _, _, _, blocked, absorbed, critical = ...
            end
            displayDamageText(self, destGUID, amount, critical, spellName, nil, blocked, absorbed, periodic, element)
        elseif (string.find(event, "_MISSED")) then
            local missType
            if (string.find(event, "RANGE") or string.find(event, "SPELL")) then
                missType = select(4,...)
            elseif (string.find(event, "SWING")) then
                missType = ...
            else
                _, _, _, missType = ...
            end
            displayDamageText(self, destGUID, nil, nil, nil, missType)
        elseif ((settings.usedFormat == formats.Stacking or (settings.usedFormat == formats.Classic and settings.classicFormatAnchorPoint == "Center"))) and settings.showHealNumbers and string.find(event, "_HEAL") then
            local amount, overhealing, absorbed, critical = select(4, ...)
            if amount - overhealing > 0 then
                displayDamageText(self, destGUID, (amount - overhealing), critical, "heal", nil, nil, (absorbed > 0 and absorbed or nil))
            end
        end
    elseif (bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0 or bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) > 0) and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 then -- caster is player pet
        if (string.find(event, "_DAMAGE")) then
            local amount, _, _, _, _, blocked, absorbed, critical
            if (string.find(event, "SWING")) then
                _, amount, _, _, _, blocked, absorbed, critical = "pet", ...
            elseif (string.find(event, "ENVIRONMENTAL")) then
                _, amount, _, _, _, blocked, absorbed, critical = ...
            else
                _, _, _, amount, _, _, _, blocked, absorbed, critical = ...
            end
            displayDamageText(self, destGUID, amount, critical, "pet", nil, blocked, absorbed)
        elseif (string.find(event, "_MISSED")) then
            local missType
            if (string.find(event, "RANGE") or string.find(event, "SPELL")) then
                missType = select(4,...)
            elseif (string.find(event, "SWING")) then
                missType = ...
            end
            displayDamageText(self, destGUID, nil, nil, "pet", missType)
        end
    end
end

local function onNamePlateAdded(_, _, unitID)
    local guid = UnitGUID(unitID)
    if guid then
        unitToGuid[unitID] = guid
        guidToUnit[guid] = unitID
    end
end

local function onNamePlateRemoved(_, _, unitID)
    local guid = unitToGuid[unitID]

    unitToGuid[unitID] = nil
    guidToUnit[guid] = nil

    if settings.usedFormat == formats.Classic then
      return
    end

    for _, f in pairs(fontStringList) do
        if f.unit and f.unit == unitID then
            f:Hide()
        end
    end
end

local function RescanAllNameplates()
    for _, frame in pairs(C_NamePlate.GetNamePlates(false)) do
        local guid = UnitGUID(frame.namePlateUnitToken)
        if guid then
            unitToGuid[frame.namePlateUnitToken] = guid
            guidToUnit[guid] = frame.namePlateUnitToken
        end
    end
end

local function onCombatLogEvent(self)
    handleCombatLogEvent(self, CombatLogGetCurrentEventInfo())
end

local function ToggleFormat(activate)
    if activate then
        eventHandler:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

        eventHandler:SetScript("OnEvent", function(_, event, ...)
            if event == "NAME_PLATE_UNIT_ADDED" then
                onNamePlateAdded(eventHandler, event, ...)
            elseif event == "NAME_PLATE_UNIT_REMOVED" then
                onNamePlateRemoved(eventHandler, event, ...)
            elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
                onCombatLogEvent(eventHandler)
            end
        end)

        if settings.usedFormat == formats.Default or settings.usedFormat == formats.Classic then
            -- hide the other format things
            if stackingContainer then
                -- TODO remove from Move Hud mode
                stackingContainer:SetScript("OnUpdate", nil)
                stackingContainer:Hide()
                wipe(stackingContainer.activeFrames)
            end

            NUM_OBJECTS_HARDLIMIT = 20

            if settings.usedFormat == formats.Classic then
                if not ClassicDummyFrame then
                    ClassicDummyFrame = CreateFrame("Frame", nil, UIParent)
                    ClassicDummyFrame:ClearAllPoints()
                    ClassicDummyFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                    ClassicDummyFrame:SetSize(100, 50)
                    ClassicDummyFrame:EnableMouse(false)
                end

                CRITICAL_ANIMATION = animateTextCriticalForClassicFormat
                NORMAL_ANIMATION = animateTextNormalForClassicFormat

                if settings.classicFormatAnchorPoint == "Nameplates" then
                    eventHandler:RegisterEvent("NAME_PLATE_UNIT_ADDED")
                    eventHandler:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

                    RescanAllNameplates()
                else
                    eventHandler:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
                    eventHandler:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")

                    wipe(unitToGuid)
                    wipe(guidToUnit)
                end

                ClassicDummyFrame:Show()
            else
                if ClassicDummyFrame then
                    ClassicDummyFrame:Hide()
                end

                CRITICAL_ANIMATION = animateTextCriticalForDefaultFormat
                NORMAL_ANIMATION = animateTextNormalForDefaultFormat

                eventHandler:RegisterEvent("NAME_PLATE_UNIT_ADDED")
                eventHandler:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

                RescanAllNameplates()

                wipe(namePlateClassicGrid)
            end
        elseif settings.usedFormat == formats.Stacking then
            if not stackingContainer then
                stackingContainer = CreateFrame("Frame", nil, UIParent)
                stackingContainer:SetSize(200, 400)
                stackingContainer:EnableMouse(false)
                stackingContainer:ClearAllPoints()
                GW.RegisterMovableFrame(stackingContainer, GW.L["FCT Container"], "FCT_STACKING_CONTAINER", "VerticalActionBarDummy", nil, nil, {"default", "scaleable"})
                stackingContainer:ClearAllPoints()
                stackingContainer:SetPoint("TOPLEFT", stackingContainer.gwMover)
                stackingContainer.activeFrames = {}
            end

            if ClassicDummyFrame then
                ClassicDummyFrame:Hide()
            end

            CRITICAL_ANIMATION = animateTextCriticalForStackingFormat
            NORMAL_ANIMATION = animateTextNormalForStackingFormat

            NUM_OBJECTS_HARDLIMIT = 50

            eventHandler:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
            eventHandler:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")

            wipe(unitToGuid)
            wipe(guidToUnit)
            wipe(namePlateClassicGrid)
            wipe(stackingContainer.activeFrames)

            stackingContainer:SetScript("OnUpdate", stackingContainerOnUpdate)
            stackingContainer:Show()
        end
    else
        eventHandler:UnregisterAllEvents()
        eventHandler:SetScript("OnEvent", nil)

        wipe(unitToGuid)
        wipe(guidToUnit)

        if stackingContainer then
            -- TODO remove from Move Hud mode
            stackingContainer:SetScript("OnUpdate", nil)
            stackingContainer:Hide()
        end
        if ClassicDummyFrame then
            ClassicDummyFrame:Hide()
        end
    end
end
GW.FloatingCombatTextToggleFormat = ToggleFormat

local function LoadDamageText(activate)
    UpdateSettings()
    ToggleFormat(activate)
    playerGUID = UnitGUID("player")
end
GW.LoadDamageText = LoadDamageText
