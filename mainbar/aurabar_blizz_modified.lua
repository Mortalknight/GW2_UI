local _, GW = ...

-- This is a straight copy of the SecureAuraHeader code used by Blizz in
-- "SecureGroupHeaders.lua". We only make a one small modifications to enable
-- this same code to support our "legacy" and "new" aura styles. Specifically,
-- we allow buffs to be "consolidated" by their remaining duration regardless of the
-- value of the "shouldConsolidate" flag. This same change has been proposed to
-- Blizz directly so hopefully we can eventually do this with secure auras.

-- We also add one loading func to our addon namespace to simplify creating a header
-- in this style.

local strsplit = strsplit;
local select = select;
local tonumber = tonumber;
local type = type;
local floor = math.floor;
local min = math.min;
local max = math.max;
local pairs = pairs;
local ipairs = ipairs;
local wipe = table.wipe;
local tinsert = table.insert;
local GetFrameHandle = GetFrameHandle;

--working tables
local tokenTable = {};
local sortingTable = {};
local groupingTable = {};

-- forward decl
local auraHeader_Update;

local function setAttributesWithoutResponse(self, ...)
    local oldIgnore = self:GetAttribute("_ignore");
    self:SetAttribute("_ignore", "attributeChanges");
    for i = 1, select('#', ...), 2 do
        self:SetAttribute(select(i, ...));
    end
    self:SetAttribute("_ignore", oldIgnore);
end

local function auraHeader_OnLoad(self)
    self:RegisterEvent("UNIT_AURA");
end

local function auraHeader_OnUpdate(self)
    local hasMainHandEnchant, _, _, _, hasOffHandEnchant = GetWeaponEnchantInfo();
    if ( hasMainHandEnchant ~= self:GetAttribute("_mainEnchanted") ) then
        self:SetAttribute("_mainEnchanted", hasMainHandEnchant);
    end
    if ( hasOffHandEnchant ~= self:GetAttribute("_secondaryEnchanted") ) then
        self:SetAttribute("_secondaryEnchanted", hasOffHandEnchant);
    end
end

local function auraHeader_OnEvent(self, event, ...)
    if ( self:IsVisible() ) then
        local unit = SecureButton_GetUnit(self);
        if ( event == "UNIT_AURA" and ... == unit ) then
            auraHeader_Update(self);
        end
    end
end

local function auraHeader_OnAttributeChanged(self, name, value)
    if ( name == "_ignore" or self:GetAttribute("_ignore") ) then
        return;
    end
    if ( self:IsVisible() ) then
        auraHeader_Update(self);
    end
end

local buttons = {};

local function extractTemplateInfo(template, defaultWidget)
    local widgetType;

    if ( template ) then
        template, widgetType = strsplit(",", (tostring(template):trim():gsub("%s*,%s*", ",")) );
        if ( template ~= "" ) then
            if ( not widgetType or widgetType == "" ) then
                widgetType = defaultWidget;
            end
            return template, widgetType;
        end
    end
    return nil;
end

local function constructChild(kind, name, parent, template)
    local new = CreateFrame(kind, name, parent, template);
    return new;
end

local enchantableSlots = {
    [1] = "MainHandSlot", 
    [2] = "SecondaryHandSlot"
}

local function configureAuras(self, auraTable, consolidateTable, weaponPosition)
    local point = self:GetAttribute("point") or "TOPRIGHT";
    local xOffset = tonumber(self:GetAttribute("xOffset")) or 0;
    local yOffset = tonumber(self:GetAttribute("yOffset")) or 0;
    local wrapXOffset = tonumber(self:GetAttribute("wrapXOffset")) or 0;
    local wrapYOffset = tonumber(self:GetAttribute("wrapYOffset")) or 0;
    local wrapAfter = tonumber(self:GetAttribute("wrapAfter"));
    if ( wrapAfter == 0 ) then wrapAfter = nil; end
    local maxWraps = self:GetAttribute("maxWraps");
    if ( maxWraps == 0 ) then maxWraps = nil; end
    local minWidth = tonumber(self:GetAttribute("minWidth")) or 0;
    local minHeight = tonumber(self:GetAttribute("minHeight")) or 0;

    if ( consolidateTable and #consolidateTable == 0 ) then
        consolidateTable = nil;
    end
    local name = self:GetName();

    wipe(buttons);
    local buffTemplate, buffWidget = extractTemplateInfo(self:GetAttribute("template"), "Button");
    if ( buffTemplate ) then
        for i=1, #auraTable do
            local button = self.buttons[i]
            if ( button ) then
                button:ClearAllPoints();
            else
                button = constructChild(buffWidget, name and name.."AuraButton"..i, self, buffTemplate);
                self.buttons[i] = button
            end
            local buffInfo = auraTable[i];
            button:SetID(buffInfo.index);
            button.index = buffInfo.index;
            button.filter = buffInfo.filter;
            buttons[i] = button;
        end
    end

    local consolidateProxy = self:GetAttribute("consolidateProxy");
    if ( consolidateTable ) then
        if ( type(consolidateProxy) == 'string' ) then
            local template, widgetType = extractTemplateInfo(consolidateProxy, "Button");
            if ( template ) then
                consolidateProxy = constructChild(widgetType, name and name.."ProxyButton", self, template);
                setAttributesWithoutResponse(self, "consolidateProxy", consolidateProxy, "frameref-proxy", GetFrameHandle(consolidateProxy));
            else
                consolidateProxy = nil;
            end
        end
        if ( consolidateProxy ) then
            if ( consolidateTable.position ) then
                tinsert(buttons, consolidateTable.position, consolidateProxy);
            else
                tinsert(buttons, consolidateProxy);
            end
            consolidateProxy:ClearAllPoints();
        end
    else
        if ( consolidateProxy and type(consolidateProxy.Hide) == 'function' ) then
            consolidateProxy:Hide();
        end
    end
    if ( weaponPosition ) then
        local hasMainHandEnchant, _, _, _, hasOffHandEnchant, _, _, _, hasRangedEnchant = GetWeaponEnchantInfo();

        for weapon=2,1,-1 do
            --local weaponAttr = "tempEnchant"..weapon
            local tempEnchant = self.tempenchants[weapon]
            if ( (select(weapon, hasMainHandEnchant, hasOffHandEnchant, hasRangedEnchant)) ) then
                if ( not tempEnchant ) then
                    local template, widgetType = extractTemplateInfo(self:GetAttribute("weaponTemplate"), "Button");
                    if ( template ) then
                        tempEnchant = constructChild(widgetType, name and name.."TempEnchant"..weapon, self, template);
                        --setAttributesWithoutResponse(self, weaponAttr, tempEnchant);
                        self.tempenchants[weapon] = tempEnchant
                    end
                end
                if ( tempEnchant ) then
                    tempEnchant:ClearAllPoints();
                    local slot = GetInventorySlotInfo(enchantableSlots[weapon]);
                    tempEnchant.targetSlot = slot;
                    tempEnchant:SetID(slot);
                    if ( weaponPosition == 0 ) then
                        tinsert(buttons, tempEnchant);
                    else
                        tinsert(buttons, weaponPosition, tempEnchant);
                    end
                end
            else
                if ( tempEnchant and type(tempEnchant.Hide) == 'function' ) then
                    tempEnchant:Hide();
                end
            end
        end
    end

    local display = #buttons
    if ( wrapAfter and maxWraps ) then
        display = min(display, wrapAfter * maxWraps);
    end

    local left, right, top, bottom = math.huge, -math.huge, -math.huge, math.huge;
    for index=1,display do
        local button = buttons[index];
        local wrapAfter = wrapAfter or index
        local tick, cycle = floor((index - 1) % wrapAfter), floor((index - 1) / wrapAfter);
        button:SetPoint(point, self, cycle * wrapXOffset + tick * xOffset, cycle * wrapYOffset + tick * yOffset);
        button:Show();
        left = min(left, button:GetLeft() or math.huge);
        right = max(right, button:GetRight() or -math.huge);
        top = max(top, button:GetTop() or -math.huge);
        bottom = min(bottom, button:GetBottom() or math.huge);
    end
    local deadIndex = #(auraTable) + 1;
    local button = self.buttons[deadIndex]
    while ( button ) do
        button:Hide();
        deadIndex = deadIndex + 1;
        button = self.buttons[deadIndex]
    end
    
    if ( display >= 1 ) then
        self:SetWidth(max(right - left, minWidth));
        self:SetHeight(max(top - bottom, minHeight));
    else
        self:SetWidth(minWidth);
        self:SetHeight(minHeight);
    end
    if ( consolidateTable ) then
        local header = self:GetAttribute("consolidateHeader");
        if ( type(header) == 'string' ) then
            local template, widgetType = extractTemplateInfo(header, "Frame");
            if ( template ) then
                header = constructChild(widgetType, name and name.."ProxyHeader", consolidateProxy, template);
                setAttributesWithoutResponse(self, "consolidateHeader", header);
                consolidateProxy:SetAttribute("header", header);
                consolidateProxy:SetAttribute("frameref-header", GetFrameHandle(header))
            end
        end
        if ( header ) then
            configureAuras(header, consolidateTable);
        end
    end
end

local tremove = table.remove;

local function stripRAID(filter)
    return filter and tostring(filter):upper():gsub("RAID", ""):gsub("|+", "|"):match("^|?(.+[^|])|?$");
end

local freshTable;
local releaseTable;
do
    local tableReserve = {};
    freshTable = function ()
        local t = next(tableReserve) or {};
        tableReserve[t] = nil;
        return t;
    end
    releaseTable = function (t)
        tableReserve[t] = wipe(t);
    end
end

local sorters = {};

local function sortFactory(key, separateOwn, reverse)
    if ( separateOwn ~= 0 ) then
        if ( reverse ) then
            return function (a, b)
                if ( groupingTable[a.filter] == groupingTable[b.filter] ) then
                    local ownA, ownB = a.caster == "player", b.caster == "player";
                    if ( ownA ~= ownB ) then
                        return ownA == (separateOwn > 0)
                    end
                    if key == "consolidateIdx" and a[key] == b[key] then
                        return a.expires > b.expires;
                    else
                        return a[key] > b[key];
                    end
                else
                    return groupingTable[a.filter] < groupingTable[b.filter];
                end
            end;
        else
            return function (a, b)
                if ( groupingTable[a.filter] == groupingTable[b.filter] ) then
                    local ownA, ownB = a.caster == "player", b.caster == "player";
                    if ( ownA ~= ownB ) then
                        return ownA == (separateOwn > 0)
                    end
                    if key == "consolidateIdx" and a[key] == b[key] then
                        return a.expires < b.expires;
                    else
                        return a[key] < b[key];
                    end
                else
                    return groupingTable[a.filter] < groupingTable[b.filter];
                end
            end;
        end
    else
        if ( reverse ) then
            return function (a, b)
                if ( groupingTable[a.filter] == groupingTable[b.filter] ) then
                    if key == "consolidateIdx" and a[key] == b[key] then
                        return a.expires > b.expires;
                    else
                        return a[key] > b[key];
                    end
                else
                    return groupingTable[a.filter] < groupingTable[b.filter];
                end
            end;
        else
            return function (a, b)
                if ( groupingTable[a.filter] == groupingTable[b.filter] ) then
                    if key == "consolidateIdx" and a[key] == b[key] then
                        return a.expires < b.expires;
                    else
                        return a[key] < b[key];
                    end
                else
                    return groupingTable[a.filter] < groupingTable[b.filter];
                end
            end;
        end
    end
end

for i, key in ipairs{"consolidateIdx", "index", "name", "expires"} do
    local label = key:upper();
    sorters[label] = {};
    for bool in pairs{[true] = true, [false] = false} do
        sorters[label][bool] = {}
        for sep=-1,1 do
            sorters[label][bool][sep] = sortFactory(key, sep, bool);
        end
    end
end
sorters.TIME = sorters.EXPIRES;

auraHeader_Update = function(self)
    local filter = self:GetAttribute("filter");
    local groupBy = self:GetAttribute("groupBy");
    local unit = SecureButton_GetUnit(self) or "player";
    local includeWeapons = tonumber(self:GetAttribute("includeWeapons"));
    if ( includeWeapons == 0 ) then
        includeWeapons = nil
    end
    local consolidateTo = tonumber(self:GetAttribute("consolidateTo"));
    local consolidateDuration, consolidateThreshold, consolidateFraction, consolidateGroup;
    if ( consolidateTo ) then
        consolidateDuration = tonumber(self:GetAttribute("consolidateDuration")) or 30;
        consolidateThreshold = tonumber(self:GetAttribute("consolidateThreshold")) or 10;
        consolidateFraction = tonumber(self:GetAttribute("consolidateFraction")) or 0.1;
        consolidateGroup = self:GetAttribute("consolidateGroup") or false;
    end
    local sortDirection = self:GetAttribute("sortDirection");
    local separateOwn = tonumber(self:GetAttribute("separateOwn")) or 0;
    if ( separateOwn > 0 ) then
        separateOwn = 1;
    elseif (separateOwn < 0 ) then
        separateOwn = -1;
    end
    local sortMethod = (sorters[tostring(self:GetAttribute("sortMethod")):upper()] or sorters["INDEX"])[sortDirection == "-"][separateOwn];

    local time = GetTime();

    local consolidateTable;
    if ( consolidateTo and consolidateTo ~= 0 ) then
        consolidateTable = wipe(tokenTable);
    end

    wipe(sortingTable);
    wipe(groupingTable);

    if ( groupBy ) then
        local i = 1;
        for subFilter in groupBy:gmatch("[^,]+") do
            if ( filter ) then
                subFilter = stripRAID(filter.."|"..subFilter);
            else
                subFilter = stripRAID(subFilter);
            end
            groupingTable[subFilter], groupingTable[i] = i, subFilter;
            i = i + 1;
        end
    else
        filter = stripRAID(filter);
        groupingTable[filter], groupingTable[1] = 1, filter;
    end
    if ( consolidateTable and consolidateTo < 0 ) then
        consolidateTo = #groupingTable + consolidateTo + 1;
    end
    if ( includeWeapons and includeWeapons < 0 ) then
        includeWeapons = #groupingTable + includeWeapons + 1;
    end
    local weaponPosition;
    for filterIndex, fullFilter in ipairs(groupingTable) do
        if ( consolidateTable and not consolidateTable.position and filterIndex >= consolidateTo ) then
            consolidateTable.position = #sortingTable + 1;
        end
        if ( includeWeapons and not weaponPosition and filterIndex >= includeWeapons ) then
            weaponPosition = #sortingTable + 1;
        end

        local i = 1;
        AuraUtil.ForEachAura(unit, fullFilter, nil, function(...)
            local aura, _, duration = freshTable();
            aura.name, _, _, _, duration, aura.expires, aura.caster, _, aura.shouldConsolidate, _ = ...;
            aura.filter = fullFilter;
            aura.index = i;
            aura.consolidateIdx = 0;
            local targetList = sortingTable;
            if ( consolidateTable ) then
                if ( not aura.expires or duration > consolidateDuration or (aura.expires - time >= max(consolidateThreshold, duration * consolidateFraction)) or (duration == 0)) then
                    if consolidateGroup then
                        aura.consolidateIdx = 1;
                    else
                        targetList = consolidateTable;
                    end
                end
            end
            tinsert(targetList, aura);
            i = i + 1;
            return false;
        end);
    end
    if ( includeWeapons and not weaponPosition ) then
        weaponPosition = 0;
    end
    table.sort(sortingTable, sortMethod);
    if ( consolidateTable ) then
        table.sort(consolidateTable, sortMethod);
    end

    configureAuras(self, sortingTable, consolidateTable, weaponPosition);
    while ( sortingTable[1] ) do
        releaseTable(tremove(sortingTable));
    end
    while ( consolidateTable and consolidateTable[1] ) do
        releaseTable(tremove(consolidateTable));
    end
end

local function CreateModifiedAuraHeader()
    local wrap_num = GW.GetSetting("PLAYER_AURA_WRAP_NUM")
    local grow_dir = GW.GetSetting("PlayerBuffFrame_GrowDirection")
    local w = CreateFrame("Frame", nil, UIParent, "SecureFrameTemplate")
    w:Hide()
    w:SetSize(wrap_num * 33, 33)

    local h = CreateFrame("Frame", nil, w)
    h:Hide()
    h:ClearAllPoints()
    if grow_dir == "UP" or grow_dir == "UPR" then
        h:SetPoint("BOTTOM", w, "BOTTOM", 0, 0)
    else
        h:SetPoint("TOP", w, "TOP", 0, 0)
    end

    h.buttons = {}
    h.tempenchants = {}

    h:SetScript("OnEvent", auraHeader_OnEvent)
    h:SetScript("OnShow", auraHeader_Update)
    h:SetScript("OnUpdate", auraHeader_OnUpdate)
    h:SetScript("OnAttributeChanged", auraHeader_OnAttributeChanged)

    auraHeader_OnLoad(h)

    w.inner = h

    return w
end
GW.CreateModifiedAuraHeader = CreateModifiedAuraHeader
