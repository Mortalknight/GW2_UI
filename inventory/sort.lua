local _, GW = ...
local _G, _M = getfenv(0), {}
setfenv(1, setmetatable(_M, {__index=_G}))
local GetSetting = GW.GetSetting

CreateFrame("GameTooltip", "SortBagsTooltip", nil, "GameTooltipTemplate")

BAG_CONTAINERS = {0, 1, 2, 3, 4}
BANK_BAG_CONTAINERS = {-1, 5, 6, 7, 8, 9, 10, 11}

function _G.GW_SortBags()
    CONTAINERS = {unpack(BAG_CONTAINERS)}
    for i = #CONTAINERS, 1, -1 do
        if C_Container.GetBagSlotFlag(CONTAINERS[i], LE_BAG_FILTER_FLAG_IGNORE_CLEANUP) then
            tremove(CONTAINERS, i)
        end
    end
    Start()
end

function _G.GW_SortBankBags()
    CONTAINERS = {unpack(BANK_BAG_CONTAINERS)}
    for i = #CONTAINERS, 1, -1 do
        if C_Container.GetBagSlotFlag(CONTAINERS[i], LE_BAG_FILTER_FLAG_IGNORE_CLEANUP) then
            tremove(CONTAINERS, i)
        end
    end
    Start()
end

local function set(...)
    local t = {}
    local n = select("#", ...)
    for i = 1, n do
        t[select(i, ...)] = true
    end
    return t
end

local function union(...)
    local t = {}
    local n = select("#", ...)
    for i = 1, n do
        for k in pairs(select(i, ...)) do
            t[k] = true
        end
    end
    return t
end

local MOUNTS = set(
    -- rams
    5864, 5872, 5873, 18785, 18786, 18787, 18244, 19030, 13328, 13329,
    -- horses
    2411, 2414, 5655, 5656, 18778, 18776, 18777, 18241, 12353, 12354,
    -- sabers
    8629, 8631, 8632, 18766, 18767, 18902, 18242, 13086, 19902, 12302, 12303, 8628, 12326,
    -- mechanostriders
    8563, 8595, 13321, 13322, 18772, 18773, 18774, 18243, 13326, 13327,
    -- kodos
    15277, 15290, 18793, 18794, 18795, 18247, 15292, 15293,
    -- wolves
    1132, 5665, 5668, 18796, 18797, 18798, 18245, 12330, 12351,
    -- raptors
    8588, 8591, 8592, 18788, 18789, 18790, 18246, 19872, 8586, 13317,
    -- undead horses
    13331, 13332, 13333, 13334, 18791, 18248, 13335,
    -- qiraji battle tanks
    21218, 21321, 21323, 21324, 21176
)

local SPECIAL = set(5462, 17696, 17117, 13347, 13289, 11511)

local KEYS = set(9240, 17191, 13544, 12324, 16309, 12384, 20402)

local TOOLS = set(7005, 12709, 19727, 5956, 2901, 6219, 10498, 6218, 6339, 11130, 11145, 16207, 9149, 15846, 6256, 6365, 6367)

local ENCHANTING_MATERIALS = set(
    -- dust
    10940, 11083, 11137, 11176, 16204,
    -- essence
    10938, 10939, 10998, 11082, 11134, 11135, 11174, 11175, 16202, 16203,
    -- shard
    10978, 11084, 11138, 11139, 11177, 11178, 14343, 14344,
    -- crystal
    20725
)

local HERBS = set(765, 785, 2447, 2449, 2450, 2452, 2453, 3355, 3356, 3357, 3358, 3369, 3818, 3819, 3820, 3821, 4625, 8153, 8831, 8836, 8838, 8839, 8845, 8846, 13463, 13464, 13465, 13466, 13467, 13468)

local SEEDS = set(17034, 17035, 17036, 17037, 17038)

local CLASSES = {
    -- arrow
    {
        containers = {2101, 5439, 7278, 11362, 3573, 3605, 7371, 8217, 2662, 19319, 18714, 29143, 29144, 34105, 34100, 44448},
		items = set(2512, 2514, 2515, 3029, 3030, 3031, 3464, 9399, 10579, 11285, 12654, 18042, 19316, 24412, 24417, 28053, 28056, 30319, 30611, 31737, 31949, 32760, 33803, 34581, 41165, 52021),
    },
        -- bullet
    {
        containers = {2102, 5441, 7279, 11363, 3574, 3604, 7372, 8218, 2663, 19320, 29118, 34106, 34099, 44447},
		items = set(2516, 2519, 3033, 3465, 4960, 5568, 8067, 8068, 8069, 10512, 10513, 11284, 11630, 13377, 15997, 19317, 23772, 23773, 28060, 28061, 30612, 31735, 32761, 32882, 32883, 34582, 41164, 52020),
    },
        -- soul
    {
        containers = {22243, 22244, 21340, 21341, 21342},
        items = set(6265),
    },
    -- ench
    {
        containers = {22246, 22248, 22249},
        items = union(
            ENCHANTING_MATERIALS,
            -- rods
            set(6218, 6339, 11130, 11145, 16207)
        ),
    },
    -- herb
    {
        containers = {22250, 22251, 22252},
        items = union(HERBS, SEEDS)
    },
}

do
    local f = CreateFrame"Frame"
    local lastUpdate = 0
    local function updateHandler()
        if GetTime() - lastUpdate > 1 then
            for _, container in pairs(BAG_CONTAINERS) do
                for position = 1, C_Container.GetContainerNumSlots(container) do
                    SetScanTooltip(container, position)
                end
            end
            for _, container in pairs(BANK_BAG_CONTAINERS) do
                for position = 1, C_Container.GetContainerNumSlots(container) do
                    SetScanTooltip(container, position)
                end
            end
            f:SetScript("OnUpdate", nil)
        end
    end
    f:SetScript("OnEvent", function()
        lastUpdate = GetTime()
        f:SetScript("OnUpdate", updateHandler)
    end)
    f:RegisterEvent"BAG_UPDATE"
    f:RegisterEvent"BANKFRAME_OPENED"
end

local model, itemStacks, itemClasses, itemSortKeys

do
    local f = CreateFrame"Frame"

    local process = coroutine.create(function() end);

    local suspended

    function Start()
        process = coroutine.create(function()
            while not Initialize() do
                coroutine.yield()
            end
            while true do
                suspended = false
                if InCombatLockdown() then
                    return
                end
                local complete = Sort()
                if complete then
                    return
                end
                Stack()
                if not suspended then
                    coroutine.yield()
                end
            end
        end)
        f:Show()
    end

    f:SetScript("OnUpdate", function(_, arg1)
        if coroutine.status(process) == "suspended" then
            suspended = true
            coroutine.resume(process)
        end
        if coroutine.status(process) == "dead" then
            f:Hide()
        end
    end)
end

function LT(a, b)
    local i = 1
    while true do
        if a[i] and b[i] and a[i] ~= b[i] then
            return a[i] < b[i]
        elseif not a[i] and b[i] then
            return true
        elseif not b[i] then
            return false
        end
        i = i + 1
    end
end


function Move(src, dst)
    local srcContainerInfo = C_Container.GetContainerItemInfo(src.container, src.position)
 	local dstContainerInfo = C_Container.GetContainerItemInfo(dst.container, dst.position)

     if srcContainerInfo and not srcContainerInfo.isLocked and (not dstContainerInfo or not dstContainerInfo.isLocked) then
        ClearCursor()
        C_Container.PickupContainerItem(src.container, src.position)
        C_Container.PickupContainerItem(dst.container, dst.position)

        if src.item == dst.item then
            local count = min(src.count, itemStacks[dst.item] - dst.count)
            src.count = src.count - count
            dst.count = dst.count + count
            if src.count == 0 then
                src.item = nil
            end
        else
            src.item, dst.item = dst.item, src.item
            src.count, dst.count = dst.count, src.count
        end

        coroutine.yield()
        return true
    end
end

do
    local patterns = {}
    for i = 1, 10 do
        local text = gsub(format(ITEM_SPELL_CHARGES, i), "(-?%d+)(.-)|4([^;]-);", function(numberString, gap, numberForms)
            local singular, dual, plural
            _, _, singular, dual, plural = strfind(numberForms, "(.+):(.+):(.+)");
            if not singular then
                _, _, singular, plural = strfind(numberForms, "(.+):(.+)")
            end
            local i = abs(tonumber(numberString))
            local numberForm
            if i == 1 then
                numberForm = singular
            elseif i == 2 then
                numberForm = dual or plural
            else
                numberForm = plural
            end
            return numberString .. gap .. numberForm
        end)
        patterns[text] = i
    end

    function itemCharges(text)
        return patterns[text]
    end
end

function TooltipInfo(container, position)
    SetScanTooltip(container, position)

    local charges, usable, soulbound, quest, conjured
    for i = 1, SortBagsTooltip:NumLines() do
        local text = getglobal("SortBagsTooltipTextLeft" .. i):GetText()

        local extractedCharges = itemCharges(text)
        if extractedCharges then
            charges = extractedCharges
        elseif strfind(text, "^" .. ITEM_SPELL_TRIGGER_ONUSE) then
            usable = true
        elseif text == ITEM_SOULBOUND then
            soulbound = true
        elseif text == ITEM_BIND_QUEST then -- TODO retail can maybe use GetItemInfo bind info instead
            quest = true
        elseif text == ITEM_CONJURED then
            conjured = true
        end
    end

    return charges or 1, usable, soulbound, quest, conjured
end

function SetScanTooltip(container, position)
    SortBagsTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    SortBagsTooltip:ClearLines()

    if container == BANK_CONTAINER then
        SortBagsTooltip:SetInventoryItem("player", BankButtonIDToInvSlotID(position))
    else
        SortBagsTooltip:SetBagItem(container, position)
    end
end

function Sort()
    local complete, moved
    repeat
        complete, moved = true, false
        for _, dst in ipairs(model) do
            if dst.targetItem and (dst.item ~= dst.targetItem or dst.count < dst.targetCount) then
                complete = false

                local sources, rank = {}, {}

                for _, src in ipairs(model) do
                    if src.item == dst.targetItem
                        and src ~= dst
                        and not (dst.item and src.class and not itemClasses[dst.item][src.class])
                        and not (src.targetItem and src.item == src.targetItem and src.count <= src.targetCount)
                    then
                        rank[src] = abs(src.count - dst.targetCount + (dst.item == dst.targetItem and dst.count or 0))
                        tinsert(sources, src)
                    end
                end

                sort(sources, function(a, b) return rank[a] < rank[b] end)

                for _, src in ipairs(sources) do
                    if Move(src, dst) then
                        moved = true
                        break
                    end
                end
            end
        end
    until complete or not moved
    return complete
end

function Stack()
    for _, src in ipairs(model) do
        if src.item and src.count < itemStacks[src.item] and src.item ~= src.targetItem then
            for _, dst in ipairs(model) do
                if dst ~= src and dst.item and dst.item == src.item and dst.count < itemStacks[dst.item] and dst.item ~= dst.targetItem then
                    if Move(src, dst) then
                        return
                    end
                end
            end
        end
    end
end

do
    local counts

    local function insert(t, v)
        if GetSetting("SORT_BAGS_RIGHT_TO_LEFT") then
            tinsert(t, v)
        else
            tinsert(t, 1, v)
        end
    end

    local function assign(slot, item)
        if counts[item] > 0 then
            local count
            if GetSetting("SORT_BAGS_RIGHT_TO_LEFT") and mod(counts[item], itemStacks[item]) ~= 0 then
                count = mod(counts[item], itemStacks[item])
            else
                count = min(counts[item], itemStacks[item])
            end
            slot.targetItem = item
            slot.targetCount = count
            counts[item] = counts[item] - count
            return true
        end
    end

    function Initialize()
        model, counts, itemStacks, itemClasses, itemSortKeys = {}, {}, {}, {}, {}

        for _, container in ipairs(CONTAINERS) do
            local class = ContainerClass(container)
            for position = 1, C_Container.GetContainerNumSlots(container) do
                local slot = {container=container, position=position, class=class}
                local item = Item(container, position)
                if item then
                    local containerInfo = C_Container.GetContainerItemInfo(container, position)
 					if containerInfo and containerInfo.isLocked then
                        return false
                    end
                    slot.item = item
                    slot.count = containerInfo.stackCount
 					counts[item] = (counts[item] or 0) + containerInfo.stackCount
                end
                insert(model, slot)
            end
        end

        local items = {}
        for item in pairs(counts) do
            tinsert(items, item)
        end
        sort(items, function(a, b) return LT(itemSortKeys[a], itemSortKeys[b]) end)

        for _, slot in ipairs(model) do
            if slot.class then
                for _, item in ipairs(items) do
                    if itemClasses[item][slot.class] and assign(slot, item) then
                        break
                    end
                end
            end
        end
        for _, slot in ipairs(model) do
            if not slot.class then
                for _, item in ipairs(items) do
                    if assign(slot, item) then
                        break
                    end
                end
            end
        end
        return true
    end
end

function ContainerClass(container)
    if container ~= 0 and container ~= BANK_CONTAINER then
        local name = C_Container.GetBagName(container)
        if name then        
            for class, info in pairs(CLASSES) do
                for _, itemID in pairs(info.containers) do
                    if name == GetItemInfo(itemID) then
                        return class
                    end
                end    
            end
        end
    end
end

function Item(container, position)
    local link = C_Container.GetContainerItemLink(container, position)
    if link then
        local _, _, itemID, enchantID, suffixID, uniqueID = strfind(link, "item:(%d+):(%d*):::::(%d*):(%d*)")
        itemID = tonumber(itemID)
        local itemName, _, quality, _, _, _, _, stack, slot, _, sellPrice, classId, subClassId = GetItemInfo("item:" .. itemID)
        local charges, usable, soulbound, quest, conjured = TooltipInfo(container, position)

        local sortKey = {}

        -- hearthstone
        if itemID == 6948 then
            tinsert(sortKey, 1)

        -- mounts
        elseif MOUNTS[itemID] then
            tinsert(sortKey, 2)

        -- special items
        elseif SPECIAL[itemID] then
            tinsert(sortKey, 3)

        -- key items
        elseif KEYS[itemID] then
            tinsert(sortKey, 4)

        -- tools
        elseif TOOLS[itemID] then
            tinsert(sortKey, 5)

        -- soul shards
        elseif itemID == 6265 then
            tinsert(sortKey, 14)

        -- conjured items
        elseif conjured then
            tinsert(sortKey, 15)

        -- soulbound items
        elseif soulbound then
            tinsert(sortKey, 6)

        -- reagents
        elseif classId == 9 then
            tinsert(sortKey, 7)

        -- quest items
        elseif quest then
            tinsert(sortKey, 9)

        -- consumables
        elseif usable and classId ~= 1 and classId ~= 2 and classId ~= 8 or classId == 4 then
            tinsert(sortKey, 8)

        -- enchanting materials
        elseif ENCHANTING_MATERIALS[itemID] then
            tinsert(sortKey, 11)

        -- herbs
        elseif HERBS[itemID] then
            tinsert(sortKey, 12)

        -- higher quality
        elseif quality > 1 then
            tinsert(sortKey, 10)

        -- common quality
        elseif quality == 1 then
            tinsert(sortKey, 13)
            tinsert(sortKey, -sellPrice)

        -- junk
        elseif quality == 0 then
            tinsert(sortKey, 14)
            tinsert(sortKey, sellPrice)
        end
        
        tinsert(sortKey, classId)
        tinsert(sortKey, slot)
        tinsert(sortKey, subClassId)
        tinsert(sortKey, -quality)
        tinsert(sortKey, itemName)
        tinsert(sortKey, itemID)
        tinsert(sortKey, (GetSetting("SORT_BAGS_RIGHT_TO_LEFT") and 1 or -1) * charges)
        tinsert(sortKey, suffixID)
        tinsert(sortKey, enchantID)
        tinsert(sortKey, uniqueID)

        local key = format("%s:%s:%s:%s:%s:%s", itemID, enchantID, suffixID, uniqueID, charges, (soulbound and 1 or 0))

        itemStacks[key] = stack
        itemSortKeys[key] = sortKey

        for class, info in pairs(CLASSES) do
            if info.items[itemID] then
                itemClasses[key] = class
                break
            end
        end

        return key
    end
end
