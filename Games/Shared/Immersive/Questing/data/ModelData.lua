---@class GW2
local GW = select(2, ...)

-- model (fileID) tweaks
-- if only a single value defined (no table), that value is the sf
-- sf: percent bigger(+) or smaller(-) from default size
--     models not in these lists get a sf of -25
-- x: right(+) or left(-) offset
-- z: up(+) or down(-) offset
-- f: percent change in facing toward cam(+) or away from cam(-)
-- p: pitch
-- ia: idle animation; -1 to disable anims
-- hk: flag to use upper body/half-kit animations
GW.immersiveQuesting.modelTweaks = {
    -- NPCs using generic player models - old models (pre revamp)
    [119940] = {['sf'] = -27.5, ['x'] = 25}, -- human male (old)
    [119563] = {['sf'] = -31, ['x'] = 50}, -- human female (old)
    [119159] = {['sf'] = -46.5, ['x'] = -30}, -- gnome male (old)
    [119063] = {['sf'] = -47.4, ['x'] = -20}, -- gnome female (old)
    [118355] = {['sf'] = -36.3, ['x'] = 25}, -- dwarf male (old)
    [118135] = {['sf'] = -36.3, ['x'] = 35}, -- dwarf female (old)
    [120791] = {['sf'] = -23.1, ['x'] = 5}, -- night elf male (old)
    [120590] = {['sf'] = -26.5, ['x'] = -20}, -- night elf female (old)
    [121768] = {['sf'] = -32, ['x'] = 40}, -- undead male (old)
    [121608] = {['sf'] = -29.1, ['x'] = 30}, -- undead female (old)
    [121287] = {['sf'] = -27, ['x'] = 20}, -- orc male (old)
    [121087] = {['sf'] = -26.5, ['x'] = 30}, -- orc female (old)
    [122560] = {['sf'] = -28.6, ['x'] = -20}, -- troll male (old)
    [122414] = {['sf'] = -21.9, ['x'] = 40}, -- troll female (old)
    [122055] = {['sf'] = -20}, -- taruen male (old)
    [121961] = {['sf'] = -21.9, ['x'] = 35}, -- tauren female (old)
    [117721] = {['sf'] = -17.4, ['x'] = 45, ['f'] = -0.7}, -- draenei male (old)
    [117437] = {['sf'] = -21.9, ['x'] = 30}, -- draenei female (old)
    [117170] = {['sf'] = -25.9, ['x'] = 10}, -- blood elf male (old)
    [116921] = {['sf'] = -30.5, ['x'] = 30}, -- blood elf female (old)

    -- NPCs using generic player models
    [1011653] = {['sf'] = -28.5, ['x'] = 25}, -- human male
    [1000764] = {['sf'] = -31, ['x'] = 50}, -- human female
    [900914] = {['sf'] = -47, ['x'] = -30}, -- gnome male
    [940356] = {['sf'] = -50, ['x'] = 0}, -- gnome female
    [878772] = {['sf'] = -39, ['x'] = -40}, -- dwarf male
    [950080] = {['sf'] = -37, ['x'] = 38}, -- dwarf female
    [974343] = {['sf'] = -23, ['x'] = 5}, -- night elf male
    [921844] = {['sf'] = -27, ['x'] = -20}, -- night elf female
    [959310] = {['sf'] = -30, ['x'] = 40}, -- undead male
    [997378] = {['sf'] = -27, ['x'] = -30}, -- undead female
    [917116] = {['sf'] = -28, ['x'] = 20}, -- orc male
    [949470] = {['sf'] = -28, ['x'] = 30}, -- orc female
    [1022938] = {['sf'] = -28.5, ['x'] = -30}, -- troll male
    [1018060] = {['sf'] = -28.5, ['x'] = 40}, -- troll female
    [968705] = {['sf'] = -17, ['x'] = 20}, -- tauren male
    [986648] = {['sf'] = -23, ['x'] = 45}, -- tauren female
    [1005887] = {['sf'] = -14, ['x'] = 15, ['f'] = -0.7}, -- draenei male
    [1022598] = {['sf'] = -19, ['x'] = -40}, -- draenei female
    [1100087] = {['sf'] = -25.9, ['x'] = 10}, -- blood elf male
    [1100258] = {['sf'] = -30.5, ['x'] = 30}, -- blood elf female
    [307454] = GW.Retail and
        {['sf'] = -29, ['x'] = -30} or -- worgen male
        {['sf'] = -21.9},              -- worgen male (old)
    [307453] = GW.Retail and
        {['sf'] = -30, ['x'] = 10} or -- worgen female
        {['sf'] = -8.3, ['x'] = 10},  -- worgen female (old)
    [119376] = {['sf'] = -42.5, ['x'] = -50}, -- goblin male
    [119369] = {['sf'] = -45.1, ['x'] = -50}, -- goblin female
    [535052] = {['sf'] = -14.5, ['x'] = 40}, -- pandaren male
    [589715] = {['sf'] = -30.5, ['x'] = 55}, -- pandaren female
    [1734034] = {['sf'] = -25.9, ['x'] = 10}, -- void elf male
    [1733758] = {['sf'] = -30.5, ['x'] = 30}, -- void elf female
    [1620605] = {['sf'] = -25, ['x'] = 15, ['f'] = -0.7}, -- lightforged male
    [1593999] = {['sf'] = -23, ['x'] = 15, ['z'] = 10}, -- lightforged female
    [1630218] = {['sf'] = -17, ['x'] = 20}, -- highmountain male
    [1630402] = {['sf'] = -23, ['x'] = 45}, -- highmountain female
    [1814471] = {['sf'] = -23, ['x'] = 0}, -- nightborne male
    [1810676] = {['sf'] = -26, ['x'] = -10}, -- nightborne female
    [2622502] = {['sf'] = -47, ['x'] = -30}, -- mechagnome male
    [2564806] = {['sf'] = -50, ['x'] = 0}, -- mechagnome female
    [1721003] = {['sf'] = -19, ['x'] = -25}, -- kul tiran male
    [1886724] = {['sf'] = -28, ['x'] = -25}, -- kul tiran female
    [1890765] = {['sf'] = -39, ['x'] = -40}, -- dark iron male
    [1890763] = {['sf'] = -37, ['x'] = 38}, -- dark iron female
    [1630447] = {['sf'] = -21, ['x'] = 10}, -- zandalari male
    [1662187] = {['sf'] = -25.5, ['x'] = 50}, -- zandalari female
    [1968587] = {['sf'] = -14, ['x'] = 25, ['f'] = -0.8}, -- mag'har male
    -- mag'har female uses same model/stats as orc female
    [1890761] = {['sf'] = -40, ['x'] = -20}, -- vulpera male
    [1890759] = {['sf'] = -44.5, ['x'] = -20}, -- vulpera female
    [4207724] = {['sf'] = -32, ['x'] = 30}, -- dracthyr male & female
    [5548261] = {['sf'] = -34, ['x'] = -40}, -- earthen male
    [5548259] = {['sf'] = -33, ['x'] = 38}, -- earthen female
    [5422149] = {['sf'] = -20.5, ['x'] = -10}, -- haranir male
    [5422147] = {['sf'] = -21, ['x'] = -15}, -- haranir female

    -- non-creature items/objects
    [1822634] = {['sf'] = -50, ['x'] = -250, ['z'] = -40, ['ia'] = -1, ['f'] = -0.7}, -- generic quest board
    [429102] = {['sf'] = -71.4, ['x'] = -250, ['z'] = -10, ['ia'] = -1, ['f'] = -0.7}, -- hero board
    [429104] = {['sf'] = -71.4, ['x'] = -250, ['z'] = -10, ['ia'] = -1, ['f'] = -0.7}, -- command board
    [2020272] = {['sf'] = -50, ['x'] = -250, ['z'] = -10, ['ia'] = -1, ['f'] = -0.7}, -- marine table
    [1267024] = {['sf'] = -50, ['x'] = -250, ['z'] = 200, ['ia'] = -1}, -- floating scroll/khadgar's summons
    [5755585] = {['sf'] = -66.7, ['z'] = 50, ['ia'] = -1}, -- chett
    [6658771] = {['sf'] = -60, ['x'] = -200, ['ia'] = -1}, -- titan console
    [1134486] = {['sf'] = -50, ['x'] = -200, ['z'] = 200, ['ia'] = -1}, -- tidestone core
    [1134482] = {['sf'] = -65, ['x'] = -200, ['z'] = 200, ['ia'] = -1}, -- tidestone of golganneth
    [1395379] = {['sf'] = -30, ['x'] = -200, ['ia'] = -1}, -- light's heart
    [1449278] = {['sf'] = -40, ['x'] = -250, ['z'] = 50}, -- khadgar orb
    [1337278] = {['sf'] = -60, ['x'] = -200, ['z'] = 50, ['ia'] = -1}, -- tears of elune
    [5019424] = {['sf'] = -55, ['x'] = -200, ['z'] = 15, ['ia'] = -1, ['f'] = 0.9}, -- candy bucket
    [199901] = {['sf'] = -55, ['x'] = -200, ['z'] = 100, ['ia'] = -1}, -- large jack-o-lantern
    [4861458] = {['sf'] = -50, ['x'] = -250, ['z'] = 300, ['ia'] = -1}, -- floaty orb messenger aelor
    --[199428] = {['sf'] = -45, ['x'] = -200, ['z'] = 150, ['ia'] = -1}, -- wanted board

    -- big dragons
    [3084654] = {['sf'] = 26.6, ['x'] = 130, ['z'] = -30}, -- big wrathion
    [4227968] = {['sf'] = 26.6, ['x'] = 130, ['z'] = -30}, -- big selistra
    [4496906] = {['sf'] = 42.8, ['x'] = 130, ['z'] = -30}, -- big kalec
    [4498270] = {['sf'] = 42.8, ['x'] = 130, ['z'] = -30}, -- big dormu
    [4495214] = {['sf'] = 42.8, ['x'] = 130, ['z'] = -30}, -- big alexstrasza
    [1259122] = {['sf'] = 42.8, ['x'] = 130, ['z'] = -30}, -- big senegos
    [4416923] = {['sf'] = 26.6, ['x'] = 130, ['z'] = -30}, -- big ebyssian, big surigosa
    [5151105] = {['sf'] = 33.3, ['x'] = 130, ['z'] = -30}, -- big merithra
    [4492766] = {['sf'] = 81.8, ['x'] = 130, ['z'] = -30}, -- big vyranoth
    [4500511] = {['sf'] = 33.3, ['x'] = 130, ['z'] = -30}, -- big eternus
    [123497] = {['sf'] = 33.3, ['x'] = 130, ['z'] = -30}, -- big ebyssian
    [234554] = {['sf'] = 26.6, ['x'] = 130, ['z'] = -30}, -- big stellagosa
    [532126] = {['sf'] = 42.8, ['x'] = 130, ['z'] = -30}, -- big ysera

    -- other stuff
    [1980608] = -23.1, -- Ulfar
    [3762412] = -9.1, -- primus
    [1249799] = 11.1, -- malfurion
    [4218359] = -50, -- chromie
    --[1890759] = -44.4, -- selistra
    [4216711] = 0, -- therazal
    [4036647] = -37.5, --- huseng
    [4081379] = -37.5, -- tomul
    --[4207724] = -28.5, -- vaskarn
    [4498203] = -40, -- emberthal
    [123698] = {['sf'] = -52.4, ['x'] = -200}, -- tarindrella, female dryads
    [4186587] = -37.5, -- rowie
    [3947971] = -50, -- nostwin
    [3950118] = -37.5, -- honeypelt
    [4575036] = {['sf'] = -61.5, ['z'] = 50}, -- newsy
    --[1890761] = -41.2, -- veeno
    [1135341] = 17.6, -- brogg
    [4183015] = 0, -- ignax
    [1261840] = 0, -- cenarius
    [3024835] = -50, -- moonberry
    [5011146] = -37.5, -- amrymn
    [4278602] = {['sf'] = 233, ['x'] = 130}, -- buri
    [5154480] = 5.3, -- dreamkin
    [4883916] = -59.8, -- Q'onzu
    [1120702] = 0, -- aviana
    [1572377] = 25, -- locus walker
    [1817113] = -26, -- wolf genn
    [5353632] = -23.1, -- magni
    [5492980] = -33.3, -- moira
    [2168127] = -9.1, -- memory of a duke
    [3952870] = -9.1, -- thrall
    [3730980] = {['sf'] = -61.5, ['z'] = 50}, -- reese
    [5165026] = {['sf'] = -61.5, ['z'] = 50}, -- squally
    [4066013] = 11.1, -- garz
    --[5548261] = -28.5, -- baelgrim
    [5484812] = -26, -- brinthe
    [5339030] = -28.5, -- skitter
    [5767091] = -33.3, -- dagan
    [5482015] = 0, -- sum'latha
    [5221517] = 5.3, -- kish'nal
    [5333438] = {['sf'] = -61.5, ['z'] = 50}, -- spindle
    [5348707] = 23.5, -- vix'aron
    [5241992] = -4.8, -- ren'khat
    [5550057] = -50, -- cogwalker
    [5517447] = 11.1, -- miral murder-mittens
    [5763560] = -33.3, -- alyza bowblaze
    [2618947] = 66.7, -- goehi
    [5764885] = -37.5, -- monte gazlowe
    [5899823] = 0, -- sitchoaf
    [1905018] = 25, -- xithixxin
    [123799] = -13, -- ameer
    [123791] = 17.6, -- dabiri
    [3058051] = -37.5, -- tarela
    [1608483] = -50, -- maggie wiltshire
    [3657310] = -4.8, -- om'en
    [5159886] = {['sf'] = -16.7, ['ia'] = GW.immersiveQuesting.emotes.IdleHover, ['hk'] = true}, -- xal'atath
    [1738454] = -13, -- saurfang
    [126286] = {['sf'] = -44.4, ['x'] = -250}, -- waltor of pal'ea
    [4419101] = -15.3, -- watcher koranos
    [117412] = -26, -- lost/broken male, firmanvaar
    [669393] = {['sf'] = -23.1, ['x'] = -80}, -- vol'jin
    [1697869] = -33.3, -- katherine proudmoore
    [2448981] = {['sf'] = -45, ['x'] = -20}, -- mekkatorque
    [571311] = {['sf'] = -40, ['x'] = -40, ['z'] = 20}, -- huo
    [579259] = {['sf'] = -33, ['x'] = -50, ['z'] = 20}, -- dafeng
    [124495] = {['sf'] = -40, ['x'] = -250}, -- human male child
    [1806321] = {['sf'] = -50, ['x'] = -200}, -- hidden treasure chest
    [1348273] = {['sf'] = 30}, -- lightspawn
    [319484] = {['sf'] = -50, ['x'] = -250, ['f'] = -0.8}, -- danger sign
    [5680838] = {['x'] = 40}, -- faerin lothar
    [1410363] = -30, -- summoned voidwalker
    [926251] = -25, -- ghost wolf
    [1268729] = {['sf'] = -80, ['x'] = 100, ['z'] = -50}, -- fel portal
    [1239969] = {['sf'] = -5, ['x'] = 30}, -- maiev shadowsong
    [897186] = {['sf'] = -25, ['x'] = -250, ['f'] = 2.0}, -- lever
    [1245874] = {['sf'] = -17, ['x'] = 40}, -- sylvanas (legion)
    [5145420] = 0, -- momentus
    [1281267] = 0, -- danica the reclaimer
    --[1284603] = {['sf'] = 0, ['ia'] = 217, ['hk'] = true}, -- odyn
    [1284603] = -14, -- odyn
    [1109072] = {['sf'] = -35, ['x'] = -300}, -- emmigosa or probably any dragon whelpling
    [123555] = {['sf'] = 0, ['x'] = 50}, -- agapanthus
    [123382] = {['x'] = -80}, -- unng ak/furbolgs
    [1120483] = 0, -- eche'ro
    [1245128] = -30, -- keeper remulos
    [124025] = -30, -- mylune
    [3024833] = -7, -- aranelle
    [1273835] = 65, -- thaon moonclaw
    [1137939] = 80, -- elothir
    [1622490] = -52, -- jesper/human male child
    [5909233] = {['sf'] = -44, ['x'] = -250}, -- gidwin goldbraids (wrapped up)
    [5633401] = {['sf'] = -25.5, ['x'] = -15}, -- orweyna
    [234919] = -5, -- vrykul female (tigrid the charmer)
    [6730408] = 20, -- lothraxion
    [6181816] = 8, -- decimus
    [6181818] = 7, -- perodius
    [6254251] = -47, -- amani child (kuvahn)
    [6647868] = -47, -- haranir child (chua)
}

-- NPC (creatureID) tweaks; takes priority over model tweaks
local n_widow_araknai = {
    ['sf'] = -9.1, ['ia'] = GW.immersiveQuesting.emotes.IdleHang, ['hk'] = true,
    ['x'] = -50, ['z'] = 325, ['p'] = -0.33,
}
local n_berrund  = -9.1
local n_mayla = -17
local n_dundun = {
    ['sf'] = -50, ['ia'] = -1, ['ik'] = 35831, ['hk'] = true, ['z'] = 120, ['x'] = -30,
}
GW.immersiveQuesting.npcTweaks = {
    [197478] = -64.3, -- herald flaps
    [201648] = {['sf'] = 26.6, ['x'] = 130}, -- big somnikus
    [215788] = n_berrund, [215822] = n_berrund, [215836] = n_berrund,
    [144154] = -37.5, -- thurgaden
    [228860] = -54.5, -- gabby gabi
    [207471] = n_widow_araknai, [227428] = n_widow_araknai,
    [205067] = -20, -- shandris feathermoon
    [202656] = n_mayla, [93826] = n_mayla, -- mayla highmountain
    [37195] = -15.3, -- lord darius crowley
    [49425] = {['sf'] = -20, ['x'] = 40}, -- darnell
    [36648] = -15.3, -- baine bloodhoof
    [4949] = -18, -- classic thrall
    [130993] = {['sf'] = -15, ['x'] = 15}, -- fareeya
    [162943] = -17, -- hjalmar the undying
    [93011] = -20, [98229] = -20, [93127] = -20, [97303] = -20, [89362] = -20, -- kayn sunfury
    [241140] = -25, [243948] = -25, -- moratari
    [95130] = {['x'] = 400}, -- moozy, displays as nelf for some reason, so just hide that
    [251601] = n_dundun, [242704] = n_dundun,
}

-- display ID override by creature ID
GW.immersiveQuesting.displayIdOverrides = {
    [257544] = 140230, [259951] = 140230, [259941] = 140230, [259942] = 140230, -- messenger aelor
}
