-----------------------------------------------------------------------------------------------------------------------
-- Usage
-- 1.  Get a reference to the library
--     local LibGearScore = LibStub:GetLibrary("LibGearScore.1000",true)
-- 2.  Call the LibGearScore:GetScore(unit_or_guid) method passing a unitid or unitguid to get a player's
--     gearscore data. Player has to have been inspected sometime during the play
--     session. History of gearscores is not retained past the session by this library.
--     If you need data retention it would have to be implemented downstream by your addon.
--  2a.local guid, gearScore = LibGearScore:GetScore("player")
--     'gearScore' table members:
--     {
--       TimeStamp = TimeStamp, -- YYYYMMDDhhmmss (eg. 20221025134532) for easy string sortable comparisons
--       PlayerName = PlayerName,
--       PlayerRealm = PlayerRealm, -- Normalized Realm Name
--       GearScore = GearScore, -- Number
--       AvgItemLevel = AvgItemLevel, -- Number
--       FLOPScore = FLOPScore, -- Number (bonus or minus itemlevels for Flame Leviathan vehicles)
--       HeraldFails = hashTable, -- {slot = itemlevel}
--       RawTime = RawTime, -- nilable: unixtime (can feed to date(fmt,RawTime) to get back human readable datetime)
--       Color = color, -- nilable: ColorMixin
--       FLOPColor = color, -- ColorMixin
--       HeraldColor = color, -- ColorMixin
--       Description = description -- nilable: String
--     }
--     PlayerName / PlayerRealm == _G.UKNOWNOBJECT or GearScore = 0 indicates failure to calculate
-- 3.  LibGearScore:GetItemScore(item) method passing itemid, itemstring or itemlink to get the ItemScore
--     of a single item.
--  3a.local itemID, itemScore = LibGearScore:GetItemScore(item)
--     'itemScore' table members:
--     {
--       ItemScore=ItemScore, -- Number
--       ItemLevel=ItemLevel, -- Number
--       Red=Red, -- 0-1
--       Green=Green, -- 0-1
--       Blue=Blue, -- 0-1
--       Description=Description, -- String
--     }
--     Description == _G.UNKNOWNOBJECT indicates invalid item, Description == _G.PENDING_INVITE indicates uncached item
-- 4.  Callbacks: "LibGearScore_Update", "LibGearScore_ItemScore", "LibGearScore_ItemPending"
--  4a.LibGearScore.RegisterCallback(addon, "LibGearScore_Update")
--     function addon:LibGearScore_Update(guid, gearScore) -- see (2a) for `gearScore` members
--       -- do something with gearScore for player guid
--     end
--     LibGearScore.RegisterCallback(addon, "LibGearScore_ItemScore")
--     function addon:LibGearScore_ItemScore(itemid, itemScore) -- see (3a) for `itemScore` members
--       -- do something with itemScore for itemid
--     end
--     LibGearScore.RegisterCallback(addon, "LibGearScore_ItemPending")
--     function addon:LibGearScore_ItemPending(itemid)
--       -- can for example monitor for the LibGearScore_ItemScore callback to have final item data
--     end
--
-- Notes
--     LibGearScore-1.0 does NOT initiate Inspects, it only passively monitors inspect results.
-----------------------------------------------------------------------------------------------------------------------

local MAJOR, MINOR = "LibGearScore.1000", 6
assert(LibStub, format("%s requires LibStub.", MAJOR))
local lib, oldMinor = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

local GUIDIsPlayer = _G.C_PlayerInfo.GUIDIsPlayer
local GetPlayerInfoByGUID = _G.GetPlayerInfoByGUID
local GetNormalizedRealmName = _G.GetNormalizedRealmName
local GetItemInfoInstant = _G.GetItemInfoInstant
local CanInspect = _G.CanInspect
local CheckInteractDistance = _G.CheckInteractDistance
local UnitIsVisible = _G.UnitIsVisible
local GetServerTime = _G.GetServerTime
local UnitGUID = _G.UnitGUID
local UnitLevel = _G.UnitLevel
local UnitIsPlayer = _G.UnitIsPlayer
local Item = _G.Item
local After = _G.C_Timer.After
local CreateColor = _G.CreateColor
local floor = _G.math.floor
local max = _G.math.max
local min = _G.math.min
local modf = _G.math.modf

local ScanTip = _G["LibGearScoreScanTooltip.1000"] or CreateFrame("GameTooltip", "LibGearScoreScanTooltip.1000", UIParent, "GameTooltipTemplate")
lib.callbacks = lib.callbacks or LibStub:GetLibrary("CallbackHandler-1.0"):New(lib)

local BRACKET_SIZE = 1000

if WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
  BRACKET_SIZE = 1000
elseif WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
  BRACKET_SIZE = 400
elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
  BRACKET_SIZE = 200
end
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_LEVEL_CURRENT]
local MAX_SCORE = BRACKET_SIZE*6-1
local BASELINE, ARMOR_MAX, WEAPON_MAX = 200, 239, 245
local FLOPBASE, FLOPMAX, SCALING_FACTOR = 3000, 4225, 6

local AllSlots = {
  _G.INVSLOT_HEAD,
  _G.INVSLOT_NECK,
  _G.INVSLOT_SHOULDER,
  _G.INVSLOT_CHEST,
  _G.INVSLOT_WAIST,
  _G.INVSLOT_LEGS,
  _G.INVSLOT_FEET,
  _G.INVSLOT_WRIST,
  _G.INVSLOT_HAND,
  _G.INVSLOT_FINGER1,
  _G.INVSLOT_FINGER2,
  _G.INVSLOT_TRINKET1,
  _G.INVSLOT_TRINKET2,
  _G.INVSLOT_BACK,
  _G.INVSLOT_MAINHAND,
  _G.INVSLOT_OFFHAND,
  _G.INVSLOT_RANGED,
}

local SlotMap = {
  [_G.INVSLOT_HEAD] = _G.HEADSLOT,
  [_G.INVSLOT_NECK] = _G.NECKSLOT,
  [_G.INVSLOT_SHOULDER] = _G.SHOULDERSLOT,
  [_G.INVSLOT_CHEST] = _G.CHESTSLOT,
  [_G.INVSLOT_WAIST] = _G.WAISTSLOT,
  [_G.INVSLOT_LEGS] = _G.LEGSSLOT,
  [_G.INVSLOT_FEET] = _G.FEETSLOT,
  [_G.INVSLOT_WRIST] = _G.WRISTSLOT,
  [_G.INVSLOT_HAND] = _G.HANDSSLOT,
  [_G.INVSLOT_FINGER1] = _G.FINGER0SLOT.."1",
  [_G.INVSLOT_FINGER2] = _G.FINGER1SLOT.."2",
  [_G.INVSLOT_TRINKET1] = _G.TRINKET0SLOT.."1",
  [_G.INVSLOT_TRINKET2] = _G.TRINKET1SLOT.."2",
  [_G.INVSLOT_BACK] = _G.BACKSLOT,
  [_G.INVSLOT_MAINHAND] = _G.MAINHANDSLOT,
  [_G.INVSLOT_OFFHAND] = _G.SECONDARYHANDSLOT,
  [_G.INVSLOT_RANGED] = _G.RANGEDSLOT,
}

local GS_ItemSlots = {
  [_G.INVSLOT_HEAD] = true,
  [_G.INVSLOT_NECK] = true,
  [_G.INVSLOT_SHOULDER] = true,
  [_G.INVSLOT_CHEST] = true,
  [_G.INVSLOT_WAIST] = true,
  [_G.INVSLOT_LEGS] = true,
  [_G.INVSLOT_FEET] = true,
  [_G.INVSLOT_WRIST] = true,
  [_G.INVSLOT_HAND] = true,
  [_G.INVSLOT_FINGER1] = true,
  [_G.INVSLOT_FINGER2] = true,
  [_G.INVSLOT_TRINKET1] = true,
  [_G.INVSLOT_TRINKET2] = true,
  [_G.INVSLOT_BACK] = true,
  [_G.INVSLOT_MAINHAND] = true,
  [_G.INVSLOT_OFFHAND] = false,
  [_G.INVSLOT_RANGED] = true,
}

local Flop_ItemSlots = { -- 15
  [_G.INVSLOT_HEAD] = true,
  [_G.INVSLOT_NECK] = true,
  [_G.INVSLOT_SHOULDER] = true,
  [_G.INVSLOT_CHEST] = true,
  [_G.INVSLOT_WAIST] = true,
  [_G.INVSLOT_LEGS] = true,
  [_G.INVSLOT_FEET] = true,
  [_G.INVSLOT_WRIST] = true,
  [_G.INVSLOT_HAND] = true,
  [_G.INVSLOT_FINGER1] = true,
  [_G.INVSLOT_FINGER2] = true,
  [_G.INVSLOT_TRINKET1] = true,
  [_G.INVSLOT_TRINKET2] = true,
  [_G.INVSLOT_BACK] = true,
  [_G.INVSLOT_MAINHAND] = true,
}

local Herald_ItemSlots = {
  [_G.INVSLOT_HEAD] = ARMOR_MAX,
  [_G.INVSLOT_NECK] = ARMOR_MAX,
  [_G.INVSLOT_SHOULDER] = ARMOR_MAX,
  [_G.INVSLOT_CHEST] = ARMOR_MAX,
  [_G.INVSLOT_WAIST] = ARMOR_MAX,
  [_G.INVSLOT_LEGS] = ARMOR_MAX,
  [_G.INVSLOT_FEET] = ARMOR_MAX,
  [_G.INVSLOT_WRIST] = ARMOR_MAX,
  [_G.INVSLOT_HAND] = ARMOR_MAX,
  [_G.INVSLOT_FINGER1] = ARMOR_MAX,
  [_G.INVSLOT_FINGER2] = ARMOR_MAX,
  [_G.INVSLOT_TRINKET1] = ARMOR_MAX,
  [_G.INVSLOT_TRINKET2] = ARMOR_MAX,
  [_G.INVSLOT_BACK] = ARMOR_MAX,
  [_G.INVSLOT_MAINHAND] = WEAPON_MAX,
  [_G.INVSLOT_OFFHAND] = WEAPON_MAX,
  [_G.INVSLOT_RANGED] = WEAPON_MAX, -- check if INVTYPE_RELIC needs special handling
}

local GS_ItemTypes = {
  ["INVTYPE_RELIC"] = { ["SlotMOD"] = 0.3164, ["ItemSlot"] = 18, ["Enchantable"] = false},
  ["INVTYPE_TRINKET"] = { ["SlotMOD"] = 0.5625, ["ItemSlot"] = 33, ["Enchantable"] = false },
  ["INVTYPE_2HWEAPON"] = { ["SlotMOD"] = 2.000, ["ItemSlot"] = 16, ["Enchantable"] = true },
  ["INVTYPE_WEAPONMAINHAND"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 16, ["Enchantable"] = true },
  ["INVTYPE_WEAPONOFFHAND"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 17, ["Enchantable"] = true },
  ["INVTYPE_RANGED"] = { ["SlotMOD"] = 0.3164, ["ItemSlot"] = 18, ["Enchantable"] = true },
  ["INVTYPE_THROWN"] = { ["SlotMOD"] = 0.3164, ["ItemSlot"] = 18, ["Enchantable"] = false },
  ["INVTYPE_RANGEDRIGHT"] = { ["SlotMOD"] = 0.3164, ["ItemSlot"] = 18, ["Enchantable"] = false },
  ["INVTYPE_SHIELD"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 17, ["Enchantable"] = true },
  ["INVTYPE_WEAPON"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 36, ["Enchantable"] = true },
  ["INVTYPE_HOLDABLE"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 17, ["Enchantable"] = false },
  ["INVTYPE_HEAD"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 1, ["Enchantable"] = true },
  ["INVTYPE_NECK"] = { ["SlotMOD"] = 0.5625, ["ItemSlot"] = 2, ["Enchantable"] = false },
  ["INVTYPE_SHOULDER"] = { ["SlotMOD"] = 0.7500, ["ItemSlot"] = 3, ["Enchantable"] = true },
  ["INVTYPE_CHEST"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 5, ["Enchantable"] = true },
  ["INVTYPE_ROBE"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 5, ["Enchantable"] = true },
  ["INVTYPE_WAIST"] = { ["SlotMOD"] = 0.7500, ["ItemSlot"] = 6, ["Enchantable"] = false },
  ["INVTYPE_LEGS"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 7, ["Enchantable"] = true },
  ["INVTYPE_FEET"] = { ["SlotMOD"] = 0.75, ["ItemSlot"] = 8, ["Enchantable"] = true },
  ["INVTYPE_WRIST"] = { ["SlotMOD"] = 0.5625, ["ItemSlot"] = 9, ["Enchantable"] = true },
  ["INVTYPE_HAND"] = { ["SlotMOD"] = 0.7500, ["ItemSlot"] = 10, ["Enchantable"] = true },
  ["INVTYPE_FINGER"] = { ["SlotMOD"] = 0.5625, ["ItemSlot"] = 31, ["Enchantable"] = false },
  ["INVTYPE_CLOAK"] = { ["SlotMOD"] = 0.5625, ["ItemSlot"] = 15, ["Enchantable"] = true },
  ["INVTYPE_BODY"] = { ["SlotMOD"] = 0, ["ItemSlot"] = 4, ["Enchantable"] = false },
}

local GS_Rarity = {
  [0] = {Red = 0.55, Green = 0.55, Blue = 0.55 },
  [1] = {Red = 1.00, Green = 1.00, Blue = 1.00 },
  [2] = {Red = 0.12, Green = 1.00, Blue = 0.00 },
  [3] = {Red = 0.00, Green = 0.50, Blue = 1.00 },
  [4] = {Red = 0.69, Green = 0.28, Blue = 0.97 },
  [5] = {Red = 0.94, Green = 0.09, Blue = 0.00 },
  [6] = {Red = 1.00, Green = 0.00, Blue = 0.00 },
  [7] = {Red = 0.90, Green = 0.80, Blue = 0.50 },
}

local GS_Formula = {
  ["A"] = {
    [4] = { ["A"] = 91.4500, ["B"] = 0.6500 },
    [3] = { ["A"] = 81.3750, ["B"] = 0.8125 },
    [2] = { ["A"] = 73.0000, ["B"] = 1.0000 }
  },
  ["B"] = {
    [4] = { ["A"] = 26.0000, ["B"] = 1.2000 },
    [3] = { ["A"] = 0.7500, ["B"] = 1.8000 },
    [2] = { ["A"] = 8.0000, ["B"] = 2.0000 },
    [1] = { ["A"] = 0.0000, ["B"] = 2.2500 }
  }
}

local GS_Quality = {
  [BRACKET_SIZE*6] = {
    ["Red"] = { ["A"] = 0.94, ["B"] = BRACKET_SIZE*5, ["C"] = 0.00006, ["D"] = 1 },
    ["Blue"] = { ["A"] = 0.47, ["B"] = BRACKET_SIZE*5, ["C"] = 0.00047, ["D"] = -1 },
    ["Green"] = { ["A"] = 0, ["B"] = 0, ["C"] = 0, ["D"] = 0 },
    ["Description"] = _G.ITEM_QUALITY5_DESC
  },
  [BRACKET_SIZE*5] = {
    ["Red"] = { ["A"] = 0.69, ["B"] = BRACKET_SIZE*4, ["C"] = 0.00025, ["D"] = 1 },
    ["Blue"] = { ["A"] = 0.28, ["B"] = BRACKET_SIZE*4, ["C"] = 0.00019, ["D"] = 1 },
    ["Green"] = { ["A"] = 0.97, ["B"] = BRACKET_SIZE*4, ["C"] = 0.00096, ["D"] = -1 },
    ["Description"] = _G.ITEM_QUALITY4_DESC
  },
  [BRACKET_SIZE*4] = {
    ["Red"] = { ["A"] = 0.0, ["B"] = BRACKET_SIZE*3, ["C"] = 0.00069, ["D"] = 1 },
    ["Blue"] = { ["A"] = 0.5, ["B"] = BRACKET_SIZE*3, ["C"] = 0.00022, ["D"] = -1 },
    ["Green"] = { ["A"] = 1, ["B"] = BRACKET_SIZE*3, ["C"] = 0.00003, ["D"] = -1 },
    ["Description"] = _G.ITEM_QUALITY3_DESC
  },
  [BRACKET_SIZE*3] = {
    ["Red"] = { ["A"] = 0.12, ["B"] = BRACKET_SIZE*2, ["C"] = 0.00012, ["D"] = -1 },
    ["Blue"] = { ["A"] = 1, ["B"] = BRACKET_SIZE*2, ["C"] = 0.00050, ["D"] = -1 },
    ["Green"] = { ["A"] = 0, ["B"] = BRACKET_SIZE*2, ["C"] = 0.001, ["D"] = 1 },
    ["Description"] = _G.ITEM_QUALITY2_DESC
  },
  [BRACKET_SIZE*2] = {
    ["Red"] = { ["A"] = 1, ["B"] = BRACKET_SIZE, ["C"] = 0.00088, ["D"] = -1 },
    ["Blue"] = { ["A"] = 1, ["B"] = 000, ["C"] = 0.00000, ["D"] = 0 },
    ["Green"] = { ["A"] = 1, ["B"] = BRACKET_SIZE, ["C"] = 0.001, ["D"] = -1 },
    ["Description"] = _G.ITEM_QUALITY1_DESC
  },
  [BRACKET_SIZE] = {
    ["Red"] = { ["A"] = 0.55, ["B"] = 0, ["C"] = 0.00045, ["D"] = 1 },
    ["Blue"] = { ["A"] = 0.55, ["B"] = 0, ["C"] = 0.00045, ["D"] = 1 },
    ["Green"] = { ["A"] = 0.55, ["B"] = 0, ["C"] = 0.00045, ["D"] = 1 },
    ["Description"] = _G.ITEM_QUALITY0_DESC
  },
}
local tCount = function(t)
  local count = 0
  for k,v in pairs(t) do
    count = count + 1
  end
  return count
end

local colorPoor = ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_POOR].color
local gradientColors = {
  ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_UNCOMMON].color,
  ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_RARE].color,
  ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_EPIC].color,
  ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_LEGENDARY].color,
}
local colorPass, colorFail = CreateColor(0,1,0,1), CreateColor(1,0,0,1)
local function ColorGradient(percent, colors)
  if not tonumber(percent) then return end
  if tonumber(percent) > 1 then percent = 1 end
  if tonumber(percent) < 0 then percent = 0 end

  if not colors then
    colors = gradientColors
  end
  local numColors = #colors

  if percent >= 1 then
    return colors[numColors]
  elseif percent <= 0 then
    return colors[1]
  end

  local segment, relative_percent = modf(percent*(numColors-1))
  local rMin,gMin,bMin = colors[segment+1]:GetRGB()
  local rMax,gMax,bMax = colors[segment+2]:GetRGB()

  if ( not rMax or not gMax or not bMax ) then
    return colors[1]
  else
    local r = rMin + (rMax - rMin)*relative_percent
    local g = gMin + (gMax - gMin)*relative_percent
    local b = bMin + (bMax - bMin)*relative_percent

    return CreateColor(r,g,b,1)
  end
end

local function heirloomLevel(unitLevel)
  if unitLevel < 60 then
    return unitLevel
  elseif unitLevel < 70 then
    return 3*(unitLevel-60)+85
  elseif unitLevel <= 80 then
    return 4*(unitLevel-70)+147
  else
    return 1
  end
end

local function ResolveGUID(unitorguid)
  if (unitorguid) then
    if (GUIDIsPlayer(unitorguid)) then
      return unitorguid
    elseif (UnitIsPlayer(unitorguid)) then
      return UnitGUID(unitorguid)
    end
  end
  return nil
end

local function GetScoreColor(ItemScore)
  local ItemScore = tonumber(ItemScore)
  if (not ItemScore) then
    return 0, 0, 0, _G.ITEM_QUALITY0_DESC
  end

  if (ItemScore > MAX_SCORE) then
    ItemScore = MAX_SCORE
  end
  local Red = 0.1
  local Blue = 0.1
  local Green = 0.1
  for i = 0,6 do
    if ((ItemScore > i * BRACKET_SIZE) and (ItemScore <= ((i + 1) * BRACKET_SIZE))) then
      local Red = GS_Quality[( i + 1 ) * BRACKET_SIZE].Red["A"] + (((ItemScore - GS_Quality[( i + 1 ) * BRACKET_SIZE].Red["B"])*GS_Quality[( i + 1 ) * BRACKET_SIZE].Red["C"])*GS_Quality[( i + 1 ) * BRACKET_SIZE].Red["D"])
      local Blue = GS_Quality[( i + 1 ) * BRACKET_SIZE].Green["A"] + (((ItemScore - GS_Quality[( i + 1 ) * BRACKET_SIZE].Green["B"])*GS_Quality[( i + 1 ) * BRACKET_SIZE].Green["C"])*GS_Quality[( i + 1 ) * BRACKET_SIZE].Green["D"])
      local Green = GS_Quality[( i + 1 ) * BRACKET_SIZE].Blue["A"] + (((ItemScore - GS_Quality[( i + 1 ) * BRACKET_SIZE].Blue["B"])*GS_Quality[( i + 1 ) * BRACKET_SIZE].Blue["C"])*GS_Quality[( i + 1 ) * BRACKET_SIZE].Blue["D"])
      return Red, Green, Blue, GS_Quality[( i + 1 ) * BRACKET_SIZE].Description
    end
  end
  return 0.1, 0.1, 0.1, _G.ITEM_QUALITY0_DESC
end

local function ItemScoreCalc(ItemRarity, ItemLevel, ItemEquipLoc)
  local Table
  local QualityScale = 1
  local GearScore = 0
  local unitLevel = lib.inspecting and lib.inspecting.level or UnitLevel("player")
  local Scale = 1.8618
  if (ItemRarity == 5) then
    QualityScale = 1.3
    ItemRarity = 4
  elseif (ItemRarity == 1) then
    QualityScale = 0.005
    ItemRarity = 2
  elseif (ItemRarity == 0) then
    QualityScale = 0.005
    ItemRarity = 2
  elseif (ItemRarity == 7) then
    ItemRarity = 3
    ItemLevel = heirloomLevel(unitLevel)
  end
  if (ItemLevel > 120) then
    Table = GS_Formula["A"]
  else
    Table = GS_Formula["B"]
  end
  if ((ItemRarity >= 2) and (ItemRarity <= 4)) then
    local Red, Green, Blue, Description = GetScoreColor((floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B) * 1 * Scale)) * 11.25)
    GearScore = floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B) * GS_ItemTypes[ItemEquipLoc].SlotMOD * Scale * QualityScale)
    if (GearScore < 0) then
      GearScore = 0
      Red, Green, Blue, Description = GetScoreColor(1)
    end
    return GearScore, ItemLevel, Red, Green, Blue, Description
  end
end

lib.ItemStale = {}
lib.ItemScoreData = setmetatable({},{__index = function(cache, item)
  local itemID, _, _, ItemEquipLoc = GetItemInfoInstant(item)
  if not itemID then return {ItemScore=0, ItemLevel=0, ItemQuality = LE_ITEM_QUALITY_POOR, Red=0.1, Green=0.1, Blue=0.1, Description=_G.UNKNOWNOBJECT} end
  if not GS_ItemTypes[ItemEquipLoc] then return {ItemScore=0, ItemLevel=0, ItemQuality = LE_ITEM_QUALITY_POOR, Red=0.1, Green=0.1, Blue=0.1, Description=_G.UNKNOWNOBJECT} end
  local itemAsync = Item:CreateFromItemID(itemID)
  if itemAsync:IsItemDataCached() then
    local ItemLink = itemAsync:GetItemLink()
    local ItemRarity = itemAsync:GetItemQuality()
    local ItemLevelCurrent = itemAsync:GetCurrentItemLevel()
    local ItemScore, ItemLevel, Red, Green, Blue, Description = ItemScoreCalc(ItemRarity, ItemLevelCurrent, ItemEquipLoc)
    local scoreData = {ItemScore=ItemScore,ItemLevel=ItemLevel,ItemQuality=ItemRarity,Red=Red,Green=Green,Blue=Blue,Description=Description}
    if ItemRarity == LE_ITEM_QUALITY_HEIRLOOM then
      lib.ItemStale[itemID] = {item,ItemLink}
    end
    rawset(cache, item, scoreData)
    rawset(cache, ItemLink, scoreData)
    rawset(cache, itemID, scoreData)
    lib.callbacks:Fire("LibGearScore_ItemScore", itemID, scoreData)
    return cache[item]
  else
    itemAsync:ContinueOnItemLoad(function()
      local ItemLink = itemAsync:GetItemLink()
      local ItemRarity = itemAsync:GetItemQuality()
      local ItemLevelCurrent = itemAsync:GetCurrentItemLevel()
      local ItemScore, ItemLevel, Red, Green, Blue, Description = ItemScoreCalc(ItemRarity, ItemLevelCurrent, ItemEquipLoc)
      local scoreData = {ItemScore=ItemScore,ItemLevel=ItemLevel,ItemQuality=ItemRarity,Red=Red,Green=Green,Blue=Blue,Description=Description}
      if ItemRarity == LE_ITEM_QUALITY_HEIRLOOM then
        lib.ItemStale[itemID] = {item,ItemLink}
      end
      rawset(cache, item, scoreData)
      rawset(cache, ItemLink, scoreData)
      rawset(cache, itemID, scoreData)
      lib.callbacks:Fire("LibGearScore_ItemPending", itemID)
    end)
    return {ItemScore=0, ItemLevel=0, ItemQuality = LE_ITEM_QUALITY_POOR, Red=0.1, Green=0.1, Blue=0.1, Description=_G.PENDING_INVITE}
  end
end})

local function GetUnitSlotLink(unit, slot)
  ScanTip:SetOwner(UIParent, "ANCHOR_NONE")
  ScanTip:SetInventoryItem(unit, slot)
  return GetInventoryItemLink(unit, slot) or select(2, ScanTip:GetItem())
end

local function CacheScore(guid, unit, level)
  local _, enClass, _, _, _, PlayerName, PlayerRealm = GetPlayerInfoByGUID(guid)
  if not PlayerName or PlayerName == _G.UNKNOWNOBJECT then return end
  if PlayerRealm == "" then PlayerRealm = GetNormalizedRealmName() end
  local GearScore = 0
  local FLOPScore
  local HeraldFails = {}
  local ItemCount = 0
  local LevelTotal = 0
  local TitanGrip = 1
  local ItemScore = 0
  local ItemLevel = 0
  local ItemQuality = 0
  local AvgItemLevel = 0
  local Description
  local mainHandLink = GetUnitSlotLink(unit, _G.INVSLOT_MAINHAND)
  local offHandLink = GetUnitSlotLink(unit, _G.INVSLOT_OFFHAND)
  if mainHandLink and offHandLink then
    local itemID, _, _, ItemEquipLoc = GetItemInfoInstant(mainHandLink)
    if ItemEquipLoc == "INVTYPE_2HWEAPON" then
      TitanGrip = 0.5
    end
  end
  if offHandLink then
    local itemID, _, _, ItemEquipLoc = GetItemInfoInstant(offHandLink)
    if ItemEquipLoc == "INVTYPE_2HWEAPON" then
      TitanGrip = 0.5
    end
    local _, scoreData = lib:GetItemScore(offHandLink)
    ItemScore, ItemLevel, Description = scoreData.ItemScore, scoreData.ItemLevel, scoreData.Description
    if Description == _G.UNKNOWNOBJECT then return end
    if Description == _G.PENDING_INVITE then
      After(0.1, function()
        CacheScore(guid, unit, level)
        return
      end)
    end
    if enClass == "HUNTER" then
      ItemScore = ItemScore * 0.3164
    end
    GearScore = GearScore + ItemScore * TitanGrip
    ItemCount = ItemCount + 1
    LevelTotal = LevelTotal + ItemLevel
  end
  for _, slot in ipairs(AllSlots) do
    local slotLink = GetUnitSlotLink(unit, slot)
    if slotLink then
      local _, scoreData = lib:GetItemScore(slotLink)
      ItemScore, ItemLevel, ItemQuality, Description = scoreData.ItemScore, scoreData.ItemLevel, scoreData.ItemQuality, scoreData.Description
      if Description == _G.UNKNOWNOBJECT then return end
      if Description == _G.PENDING_INVITE then
        After(0.1, function()
          CacheScore(guid, unit, level)
          return
        end)
      end
      if GS_ItemSlots[slot] then
        if enClass == "HUNTER" then
          if slot == _G.INVSLOT_MAINHAND then
            ItemScore = ItemScore * 0.3164
          elseif slot == _G.INVSLOT_RANGED then
            ItemScore = ItemScore * 5.3224
          end
        end
        if slot == _G.INVSLOT_MAINHAND then
          ItemScore = ItemScore * TitanGrip
        end
        GearScore = GearScore + ItemScore
        ItemCount = ItemCount + 1
        LevelTotal = LevelTotal + ItemLevel
      end
      if Flop_ItemSlots[slot] then
        if ItemQuality == LE_ITEM_QUALITY_HEIRLOOM then ItemQuality = LE_ITEM_QUALITY_RARE end
        if ItemQuality >= LE_ITEM_QUALITY_EPIC then
          FLOPScore = (FLOPScore or 0) + (ItemLevel - BASELINE)
        else
          local qualityTax = (LE_ITEM_QUALITY_EPIC - ItemQuality) * 13
          FLOPScore = (FLOPScore or 0) + (ItemLevel - BASELINE) - qualityTax
        end
      end
      if Herald_ItemSlots[slot] then
        if ItemLevel > Herald_ItemSlots[slot] then
          HeraldFails[slot] = ItemLevel
        else
          if HeraldFails[slot] then
            HeraldFails[slot] = nil
          end
        end
      end
    else
      if Flop_ItemSlots[slot] then
        FLOPScore = (FLOPScore or 0) - BASELINE
      end
    end
  end
  if GearScore > 0 and ItemCount > 0 then
    GearScore = floor(GearScore)
    AvgItemLevel = floor(LevelTotal/ItemCount)
    local RawTime = GetServerTime()
    local TimeStamp = date("%Y%m%d%H%M%S",RawTime) -- 20221017133545 (YYYYMMDDHHMMSS)
    local r,g,b, description = GetScoreColor(GearScore)
    local color = CreateColor(r,g,b,1)
    local flopColor
    if FLOPScore then
      if FLOPScore < 0 then
        flopColor = colorPoor
      else
        flopColor = ColorGradient(FLOPScore/(FLOPMAX-FLOPBASE))
      end
    end
    local heraldColor
    if tCount(HeraldFails) > 0 then
      heraldColor = colorFail
    else
      heraldColor = colorPass
    end
    local scoreData = {TimeStamp = TimeStamp, PlayerName = PlayerName, PlayerRealm = PlayerRealm, GearScore = GearScore, AvgItemLevel = AvgItemLevel, FLOPScore = FLOPScore, HeraldFails = HeraldFails, RawTime = RawTime, Color = color, FLOPColor = flopColor, HeraldColor = heraldColor, Description = description}
    lib.PlayerScoreData[guid] = scoreData
    lib.callbacks:Fire("LibGearScore_Update", guid, scoreData)
  end
end

lib.PlayerScoreData = setmetatable({},{__index = function(cache, guid)
  return {PlayerName = _G.UNKNOWNOBJECT, PlayerRealm = _G.UNKNOWNOBJECT, GearScore = 0, AvgItemLevel = 0}
end})

--------------
--- Events ---
--------------
lib.eventFrame = lib.eventFrame or CreateFrame("Frame")
lib.eventFrame:UnregisterAllEvents()
lib.eventFrame:SetScript("OnEvent",nil)
lib.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
lib.eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
lib.eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
lib.eventFrame:RegisterEvent("INSPECT_READY")
lib.OnEvent = function(_,event,...)
  return lib[event] and lib[event](lib,event,...)
end
lib.eventFrame:SetScript("OnEvent",lib.OnEvent)
function lib:PLAYER_EQUIPMENT_CHANGED(event,...)
  local guid, unit, level = UnitGUID("player"), "player", UnitLevel("player")
  CacheScore(guid,unit,level)
end
function lib:UNIT_INVENTORY_CHANGED(event,...)
  local unit = ...
  if unit and UnitIsPlayer(unit) then
    local guid, level = UnitGUID(unit), UnitLevel(unit)
    if lib.inspecting and lib.inspecting.guid == guid then
      CacheScore(guid, unit, level)
    end
  end
end
function lib:INSPECT_READY(event,...)
  local guid = ...
  if self.inspecting and self.inspecting.guid == guid then
    if self.inspecting.unit and UnitIsVisible(self.inspecting.unit) then
      if CanInspect(self.inspecting.unit,false) and CheckInteractDistance(self.inspecting.unit,1) then
        CacheScore(self.inspecting.guid, self.inspecting.unit, self.inspecting.level)
      end
    end
  end
end
function lib:PLAYER_ENTERING_WORLD(event,...)
  local guid, level = UnitGUID("player"), UnitLevel("player")
  CacheScore(guid, "player", level)
end
function lib.NotifyInspect(unit)
  if unit and UnitIsPlayer(unit) then
    local guid, level = UnitGUID(unit), UnitLevel(unit)
    lib.inspecting = {guid=guid,unit=unit,level=level}
  end
end
function lib.ClearInspectPlayer()
  lib.inspecting = false
end
hooksecurefunc("NotifyInspect",lib.NotifyInspect)
hooksecurefunc("ClearInspectPlayer",lib.ClearInspectPlayer)

------------------
--- Public API ---
------------------
function lib:GetItemScore(item)
  local itemID = GetItemInfoInstant(item)
  if itemID then
    if lib.ItemStale[itemID] then -- invalidate heirlooms
      local entry1, entry2 = lib.ItemStale[itemID][1], lib.ItemStale[itemID][2]
      if rawget(lib.ItemScoreData,itemID) then
        rawset(lib.ItemScoreData,itemID,nil)
      end
      if entry1 and rawget(lib.ItemScoreData,entry1) then
        rawset(lib.ItemScoreData,entry1,nil)
      end
      if entry2 and rawget(lib.ItemScoreData,entry2) then
        rawset(lib.ItemScoreData,entry2,nil)
      end
      lib.ItemStale[itemID] = nil
    end
    return itemID, lib.ItemScoreData[item]
  end
end

function lib:GetScore(unitorguid)
  local guid = ResolveGUID(unitorguid)
  if (guid) then
    return guid, lib.PlayerScoreData[guid]
  end
end

function lib:GetScoreColor(score)
  local r,g,b, desc = GetScoreColor(score)
  local colorObj = CreateColor(r,g,b)
  return colorObj, desc
end

function lib:GetSlotName(slot)
  return SlotMap[slot] or slot
end

-- itemlevels_extra are the bonus (positive or negative) computed in GetScore for FLOPScore
-- base can be baseHP (eg 1.134.000 for siege, 630.000 for demo, 504.000 for bike)
-- or it can be baseDMG (eg 62636 for direct mortar hit)
function lib:VehicleMath(itemlevels_extra, base)
  if not itemlevels_extra then return end
  -- SCALING_FACTOR/FLOPBASE*100 = 0.2
  local percent_delta = itemlevels_extra * 0.2
  if base then
    return percent_delta, base*percent_delta/100
  else
    return percent_delta
  end
end

---------------
--- Testing ---
---------------
local function TargetScore()
  if UnitExists("target")
    and UnitIsPlayer("target")
    and UnitIsFriend("target","player") then
    local guid, scoreData = lib:GetScore("target")
    if scoreData then
      if scoreData.PlayerName == _G.UNKNOWNOBJECT then
        print(format("No Gearcheck available for '%s'. Try inspecting first.",(UnitName("target"))))
      else
        print("GearScore: "..scoreData.Color:WrapTextInColorCode(scoreData.GearScore))
        if scoreData.FLOPScore then
          print("Leviathan: "..scoreData.FLOPColor:WrapTextInColorCode(scoreData.FLOPScore))
          local percent_delta = lib:VehicleMath(scoreData.FLOPScore)
          print(format("  %s%%",scoreData.FLOPColor:WrapTextInColorCode(percent_delta)))
        end
        if tCount(scoreData.HeraldFails) > 0 then
          print("Herald: "..scoreData.HeraldColor:WrapTextInColorCode(_G.NO))
          for k,v in pairs(scoreData.HeraldFails) do
            print(format("  %s:%s",SlotMap[k],scoreData.HeraldColor:WrapTextInColorCode(v)))
          end
        else
          print("Herald: "..scoreData.HeraldColor:WrapTextInColorCode(_G.YES))
        end
      end
    else
      print(format("No Gearcheck data available for '%s'. Try inspecting first.",(UnitName("target"))))
    end
  else
    print(format("Can't get Gearcheck information for that target:%s",(UnitName("target")) or _G.TARGET_TOKEN_NOT_FOUND))
  end
end
SLASH_LibGearScore1 = "/lib_gs"
SLASH_LibGearScore2 = "/lib_gearscore"
_G.SlashCmdList["LibGearScore"] = TargetScore