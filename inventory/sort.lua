local _, GW = ...
local _G, _M = getfenv(0), {}
setfenv(1, setmetatable(_M, {__index=_G}))
local GetSetting = GW.GetSetting

CreateFrame('GameTooltip', 'SortBagsTooltip', nil, 'GameTooltipTemplate')

BAG_CONTAINERS = {0, 1, 2, 3, 4}
BANK_BAG_CONTAINERS = {-1, 5, 6, 7, 8, 9, 10, 11}

function _G.GW_SortBags()
    CONTAINERS = {unpack(BAG_CONTAINERS)}
    for i = #CONTAINERS, 1, -1 do
        if GetBagSlotFlag(i - 1, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP) then
            tremove(CONTAINERS, i)
        end
    end
    Start()
end

function _G.GW_SortBankBags()
    CONTAINERS = {unpack(BANK_BAG_CONTAINERS)}
    for i = #CONTAINERS, 1, -1 do
        if GetBankBagSlotFlag(i - 1, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP) then
            tremove(CONTAINERS, i)
        end
    end
    Start()
end

local function set(...)
    local t = {}
    local n = select('#', ...)
    for i = 1, n do
        t[select(i, ...)] = true
    end
    return t
end

local function union(...)
    local t = {}
    local n = select('#', ...)
    for i = 1, n do
        for k in pairs(select(i, ...)) do
            t[k] = true
        end
    end
    return t
end

local SPECIAL = set(5462, 17696, 17117, 13347, 13289, 11511)

local KEYS = set(9240, 17191, 13544, 12324, 16309, 12384, 20402)

local RODS = set(6218, 6339, 11130, 11145, 16207, 22461, 22462, 22463)

local TOOLS = union(
    RODS,
    set(5060, 7005, 12709, 19727, 5956, 2901, 6219, 10498, 9149, 15846, 6256, 6365, 6367)
);

local ENCHANTING_MATERIALS = set(
    -- dust
    10940, 11083, 11137, 11176, 16204, 22445,
    -- essence
    10938, 10939, 10998, 11082, 11134, 11135, 11174, 11175, 16202, 16203, 22447, 22446,
    -- shard
    10978, 11084, 11138, 11139, 11177, 11178, 14343, 14344, 22448, 22449,
    -- crystal
    20725, 22450
)

local HERBS = set(765, 785, 2447, 2449, 2450, 2452, 2453, 3355, 3356, 3357, 3358, 3369, 3818, 3819, 3820, 3821, 4625, 8153, 8831, 8836, 8838, 8839, 8845, 8846, 11040, 13463, 13464, 13465, 13466, 13467, 13468, 22710, 22785, 22786, 22787, 22788, 22789, 22790, 22791, 22792, 22793, 22794, 22795, 23501)

local SEEDS = set(17034, 17035, 17036, 17037, 17038, 18297, 22147)

local LEATHER = set(5116, 6470, 6471, 7286, 7287, 7392, 11512, 12607, 12731, 2934, 783, 2318, 4231, 5082, 5784, 2319, 4232, 4233, 4234, 4235, 4236, 4461, 8167, 4304, 8169, 8172, 8368, 8154, 8165, 8170, 8171, 15407, 15412, 15415, 15417, 15419, 15420, 17056, 15422, 15423, 21887, 23793, 25707)

local CLASSES = {
    -- arrow
    {
        containers = {2101, 5439, 7278, 11362, 3573, 3605, 7371, 8217, 2662, 19319, 18714, 29143, 29144, 34105},
        items = set(2512, 2515, 3030, 3464, 9399, 11285, 12654, 18042, 19316, 28053, 28056, 34581, 33803, 31737, 32760, 30611, 31949, 24412),
    },
    -- bullet
    {
        containers = {2102, 5441, 7279, 11363, 3574, 3604, 7372, 8218, 2663, 19320, 29118, 34106},
        items = set(2516, 2519, 3033, 3465, 4960, 5568, 8067, 8068, 8069, 10512, 10513, 11284, 11630, 13377, 15997, 19317, 28060, 30612, 32883, 32882, 28061, 32761, 34582, 31735, 23773),
    },
    -- soul
    {
        containers = {22243, 22244, 21340, 21341, 21342, 21872, 21313, 21193, 21194, 21195, 21872},
        items = set(6265),
    },
    -- ench
    {
        containers = {22246, 22248, 22249, 22249, 21858},
        items = union(
            ENCHANTING_MATERIALS,
            RODS
        ),
    },
    -- herb
    {
        containers = {22250, 22251, 22252, 38225},
        items = union(
            HERBS,
            SEEDS,
            set(2263, 5168, 11020, 11022, 11024, 10286, 11018, 11514, 11951, 11952, 16205, 16208, 17760, 19727, 21886, 22094, 22575, 23788, 24246, 24401, 24245, 31300)
        ),
    },
    -- mining
    {
        containers = {29540, 30746},
        items = {},
    },
    -- leather
    {
        containers = {34482, 34490},
        items = union(
            LEATHER,
            set(4096, 12753, 18240, 18662, 7005, 2304, 2320, 2324, 2604, 4289, 6260, 2313, 2605, 2321, 3182, 4340, 4341, 7070, 7067, 4265, 4291, 5637, 7071, 7428, 3824, 4337, 5785, 6261, 2325, 8150, 8151, 8173, 8343, 8153, 8146, 8168, 7081, 7075, 7077, 4342, 10290, 14341, 15409, 15564, 15846)
        ),
    },
    -- gems
    {
        containers = {24270, 30747},
        items = {},
    },
    -- engineering
    {
        containers = {23774, 23775, 30745},
        items = {},
    },
}

do
    local f = CreateFrame'Frame'
    f:SetScript('OnEvent', function()
        f:SetScript('OnUpdate', function()
            for _, container in pairs(BAG_CONTAINERS) do
                for position = 1, GetContainerNumSlots(container) do
                    SetScanTooltip(container, position)
                end
            end
            f:SetScript('OnUpdate', nil)
        end)
    end)
    f:RegisterEvent'PLAYER_LOGIN'
end

do
    local f = CreateFrame'Frame'
    f:SetScript('OnEvent', function()
        for _, container in pairs(BANK_BAG_CONTAINERS) do
            for position = 1, GetContainerNumSlots(container) do
                SetScanTooltip(container, position)
            end
        end
    end)
    f:RegisterEvent'BANKFRAME_OPENED'
end

local model, itemStacks, itemClasses, itemSortKeys

do
    local f = CreateFrame'Frame'

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

    f:SetScript('OnUpdate', function(_, arg1)
        if coroutine.status(process) == 'suspended' then
            suspended = true
            coroutine.resume(process)
        end
        if coroutine.status(process) == 'dead' then
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
    local texture, _, srcLocked = GetContainerItemInfo(src.container, src.position)
    local _, _, dstLocked = GetContainerItemInfo(dst.container, dst.position)
    
    if texture and not srcLocked and not dstLocked then
        ClearCursor()
           PickupContainerItem(src.container, src.position)
        PickupContainerItem(dst.container, dst.position)

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
        local text = gsub(format(ITEM_SPELL_CHARGES, i), '(-?%d+)(.-)|4([^;]-);', function(numberString, gap, numberForms)
            local singular, dual, plural
            _, _, singular, dual, plural = strfind(numberForms, '(.+):(.+):(.+)');
            if not singular then
                _, _, singular, plural = strfind(numberForms, '(.+):(.+)')
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

    local charges, usable, soulbound, quest, conjured, mount
    for i = 1, SortBagsTooltip:NumLines() do
        local text = getglobal('SortBagsTooltipTextLeft' .. i):GetText()

        local extractedCharges = itemCharges(text)
        if extractedCharges then
            charges = extractedCharges
        elseif strfind(text, '^' .. ITEM_SPELL_TRIGGER_ONUSE) then
            usable = true
        elseif text == ITEM_SOULBOUND then
            soulbound = true
        elseif text == ITEM_BIND_QUEST then -- TODO retail can maybe use GetItemInfo bind info instead
            quest = true
        elseif text == ITEM_CONJURED then
            conjured = true
        elseif text == MOUNT then
            mount = true
        end
    end

    return charges or 1, usable, soulbound, quest, conjured, mount
end

function SetScanTooltip(container, position)
    SortBagsTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
    SortBagsTooltip:ClearLines()

    if container == BANK_CONTAINER then
        SortBagsTooltip:SetInventoryItem('player', BankButtonIDToInvSlotID(position))
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
                        and not (dst.item and src.class and src.class ~= itemClasses[dst.item])
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
            for position = 1, GetContainerNumSlots(container) do
                local slot = {container=container, position=position, class=class}
                local item = Item(container, position)
                if item then
                    local _, count, locked = GetContainerItemInfo(container, position)
                    if locked then
                        return false
                    end
                    slot.item = item
                    slot.count = count
                    counts[item] = (counts[item] or 0) + count
                end
                insert(model, slot)
            end
        end

        local free = {}
        for item, count in pairs(counts) do
            local stacks = ceil(count / itemStacks[item])
            free[item] = stacks
            if itemClasses[item] then
                free[itemClasses[item]] = (free[itemClasses[item]] or 0) + stacks
            end
        end
        for _, slot in ipairs(model) do
            if slot.class and free[slot.class] then
                free[slot.class] = free[slot.class] - 1
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
                    if itemClasses[item] == slot.class and assign(slot, item) then
                        break
                    end
                end
            else
                for _, item in ipairs(items) do
                    if (not itemClasses[item] or free[itemClasses[item]] > 0) and assign(slot, item) then
                        if itemClasses[item] then
                            free[itemClasses[item]] = free[itemClasses[item]] - 1
                        end
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
        local name = GetBagName(container)
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
    local link = GetContainerItemLink(container, position)
    if link then
        local _, _, itemID, enchantID, suffixID, uniqueID = strfind(link, 'item:(%d+):(%d*):::::(%-?%d*):(%-?%d*)')
        itemID = tonumber(itemID)
        local itemName, _, quality, _, _, _, _, stack, slot, _, sellPrice, classId, subClassId = GetItemInfo('item:' .. itemID)
        local charges, usable, soulbound, quest, conjured, mount = TooltipInfo(container, position)
        local sortKey = {}

        -- hearthstone
        if itemID == 6948 or itemID == 184871 then
            tinsert(sortKey, 1)

        -- mounts
        elseif mount then
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

        local key = format('%s:%s:%s:%s:%s:%s', itemID, enchantID, suffixID, uniqueID, charges, (soulbound and 1 or 0))

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
