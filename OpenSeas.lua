local dialogResult, v123

local function v0(p1, p2, p3)
    local v17, xorKey, currentByte, decryptedByte
    local byte = string.byte
    local char = string.char
    local concat = table.concat
    local floor = math.floor
    p3 = p3 or 0
    local v7 = p3 % 256
    local count = #p2
    if count == 0 then
        return ""
    end

    local function v9(p1, p2)
        local v4, v5
        local v2 = 0
        local v3 = 1
        while p1 > 0 or p2 > 0 do
            v4 = p1 % 2
            v5 = p2 % 2
            if v4 ~= v5 then
                v2 = v2 + v3
            end
            p1 = (p1 - v4) / 2
            p2 = (p2 - v5) / 2
            v3 = v3 * 2
        end

        return v2
    end

    local v10 = bit32 and bit32.bxor or v9
    local v11 = (3271 + p3 * 211 + count * 73) % 65536
    for i = 1, count, 1 do
        v11 = (v11 * 89 + byte(p2, i) * 7 + i * 23 + p3 * (i % 11 + 1)) % 65536
    end
    local v12 = {}
    local v13 = (v7 + count * 5) % 256
    for j = 1, #p1, 1 do
        v17 = byte(p2, (j - 1) % count + 1)
        xorKey = (floor(v11 / 3) + v11 + v17 * 7 + v13 + j * 19 + v7) % 256
        currentByte = byte(p1, j)
        decryptedByte = v10((currentByte - (v13 + v17 + j + v7) % 256) % 256, xorKey)
        v12[j] = char(decryptedByte)
        v13 = v10(currentByte, decryptedByte)
        v11 = (v11 + v13 * 23 + currentByte * 3 + v17 * 5 + j * 29) % 65536
    end

    return concat(v12)
end

local v1 = _ENV or getfenv and getfenv() or _G
local v2 = setmetatable({}, {
    __index = function(p1, p2)
        if p2 == 30449 then
            return true
        end
        return v1[p2]
    end,
    __newindex = v1,
})
local v3, v4 = (function()
    local v0 = rawget
    local v1 = setmetatable
    local stringByte = string.byte
    local v3 = table and table.unpack or unpack

    local function v4(p1)
        local v1_8 = { [21218222] = p1 }

        v1_8[259887478] = function()
            return v0(v1_8, 21218222)
        end

        v1_8[213373649] = function(...)
            return v0(v1_8, 21218222)(...)
        end

        return v1(v1_8, {
            __call = function(p1, p2)
                if p2 == nil or p2 == 259887478 then
                    return v0(p1, 21218222)
                end
            end,
            __metatable = false,
        })
    end

    return v4, function(p1, p2, ...)
        local v2_9 = { n = select("#", ...), ... }
        local v3_9 = {}
        for k = 1, p2, 1 do
            if stringByte(p1, k) == 49 then
                v3_9[k] = v4(v2_9[k])
            else
                v3_9[k] = v2_9[k]
            end
        end

        return v3(v3_9, 1, p2)
    end
end)()
local v6 = game.GetService(game, "HttpService")
local v7 = {
    AutoFarmSea = false,
    AutoPickup = false,
    FarmExtensionTime = 15,
    PickupDelay = 0.12,
    MaxPickupPerTrip = 5,
    CollectBestFirst = true,
    SelectedEggs = {},
    AutoPlaceEgg = false,
    AutoHatchEgg = false,
    AutoEquipBest = false,
    AutoOfflineCash = false,
    AutoSellPets = false,
    SellBelowValue = 1000,
    FilterProtectMutations = true,
    FilterProtectRarities = true,
    ProtectedMutations = { GOLD = true, DIAMOND = true, RAINBOW = true, RADIOACTIVE = true },
    ProtectedRarities = { Legendary = true, Mythic = true, SECRET = true },
    AutoGymTrain = false,
    AutoClaimBonus = true,
    AutoBuyDumbbell = false,
    AutoEquipDumbbell = false,
    AutoBuyStaff = false,
    AutoEquipStaff = false,
    AutoRebirth = false,
    AutoUpgradeBase = false,
    AutoUpgradeCarry = false,
    AutoUpgradeSpeed = false,
    AutoClaimPlaytime = false,
    AutoClaimDaily = false,
    AutoClaimGroup = false,
    AutoClaimFreeShop = false,
    AutoClaimPass = false,
    AutoClaimQuests = false,
    AutoLuckyWheel = false,
    AutoPotions = false,
    AutoPotionLuck = true,
    AutoPotionTrain = true,
    AutoPotionCash = true,
    AutoRedeemCodes = false,
    PerformanceMode = false,
    Disable3DRender = false,
    AntiAFK = true,
    AutoSaveConfig = true,
}

local function v8()
    if not (writefile and v7.AutoSaveConfig) then
        return
    end
    pcall(function()
        v2[v0(nil, nil, 197)]("TawinHub_OpenSea.json", (v6[v0(nil, nil, 209)](v6, v7)))
    end)
end

local function v9()
    if not (readfile and isfile and isfile("TawinHub_OpenSea.json")) then
        return
    end
    pcall(function()
        local v1 = v6[v0(nil, nil, 94)](v6, (v2[v0(nil, nil, 115)]("TawinHub_OpenSea.json")))
        if v2[v0(nil, nil, 236)](v1) == v0(nil, nil, 209) then
            for v5_132, v6_132 in v2[v0(nil, nil, 97)](v1) do
                v7[v5_132] = v6_132
            end
        end
    end)
end

v9()
local v10 = {}
local v17 = {
    id = "sleepy_egg",
    name = "Sleepy Egg (ง่วงนอน)",
    rarity = "Nightfall",
    tier = 14,
}
local xorKey = {
    id = "gorilla_egg",
    name = "Gorilla Egg (กอริลลา)",
    rarity = "CYBER",
    tier = 13,
}
local runService = {
    id = "mamut_egg",
    name = "Mamut Egg (แมมมอธ)",
    rarity = "LAW",
    tier = 12,
}
local currentByte = {
    id = "ocean_egg",
    name = "Ocean Egg (มหาสมุทร)",
    rarity = "Titanium",
    tier = 11,
}
local decryptedByte = {
    id = "snake_egg",
    name = "Snake Egg (งูยักษ์)",
    rarity = "Cosmic",
    tier = 10,
}
local localPlayer = {
    id = "sphinx_egg",
    name = "Sphinx Egg (สฟิงซ์)",
    rarity = "Eternal",
    tier = 9,
}
local isPlayer = {
    id = "mouse_egg",
    name = "Mouse Egg (หนู)",
    rarity = "Eternal",
    tier = 9,
}
local getService = {
    id = "capybara_egg",
    name = "Capybara Egg (คาปิบารา)",
    rarity = "Divine",
    tier = 8,
}
local gameInstance = {
    id = "osctrich_egg",
    name = "Ostrich Egg (นกกระจอกเทศ)",
    rarity = "Secret",
    tier = 7,
}
local modifiersModule = {
    id = "snails_egg",
    name = "Snails Egg (หอยทาก)",
    rarity = "Mythic",
    tier = 6,
}
local hiddenGui = {
    id = "trex_egg",
    name = "Trex Egg (ทีเร็กซ์)",
    rarity = "Legendary",
    tier = 5,
}
local knitModule = {
    id = "tigers_egg",
    name = "Tiger Egg (เสือ)",
    rarity = "Epic",
    tier = 4,
}
local packagesFolder = {
    id = "bats_egg",
    name = "Bat Egg (ค้างคาว)",
    rarity = "Rare",
    tier = 3,
}
local staffConfigModule = {
    id = "frogs_egg",
    name = "Frog Egg (กบ)",
    rarity = "Uncommon",
    tier = 2,
}
local rebirthConfigModule = {
    id = "basic_egg",
    name = "Basic Egg (ไข่เริ่มต้น)",
    rarity = "Common",
    tier = 1,
}
v10[1] = {
    id = "dragon_egg",
    name = "Dragon Egg (มังกร)",
    rarity = "SPECIAL",
    tier = 14,
}
v10[2] = {
    id = "polarbear_egg",
    name = "Polarbear Egg (หมีขาว)",
    rarity = "SPECIAL",
    tier = 14,
}
v10[3] = {
    id = "seal_egg",
    name = "Seal Egg (แมวน้ำ)",
    rarity = "SPECIAL",
    tier = 14,
}
v10[4] = {
    id = "volt_egg",
    name = "Volt Egg (สายฟ้า)",
    rarity = "Lightning",
    tier = 14,
}
v10[5] = {
    id = "glacial_egg",
    name = "Glacial Egg (น้ำแข็ง)",
    rarity = "Frosty",
    tier = 14,
}
v10[6] = {
    id = "deer_egg",
    name = "Corals Egg (ปะการัง)",
    rarity = "Magical",
    tier = 14,
}
v10[7] = v17
v10[8] = xorKey
v10[9] = runService
v10[10] = currentByte
v10[11] = decryptedByte
v10[12] = localPlayer
v10[13] = isPlayer
v10[14] = getService
v10[15] = gameInstance
v10[16] = modifiersModule
v10[17] = hiddenGui
v10[18] = knitModule
v10[19] = packagesFolder
v10[20] = staffConfigModule
v10[21] = rebirthConfigModule
local v11 = {}
for index, value in ipairs(v10) do
    v11[value.id] = value
end
local v12 = {
    RADIOACTIVE = 500,
    RAINBOW = 400,
    DIAMOND = 300,
    GOLD = 200,
    NORMAL = 100,
}

local function v13()
    for key, value2 in pairs(v7.SelectedEggs) do
        if value2 == true then
            return true
        end
    end
    return false
end

local function getOrDefault(p1)
    local v1 = p1.GetAttribute(p1, "EggType") or p1.Name
    local v2 = p1.GetAttribute(p1, "Mutation") or "NORMAL"
    local v3 = v11[v1]
    local v4_28 = v3 and v3.tier or 1
    local v5 = v12[v2] or 100
    if v13() then
        if v7.SelectedEggs[v1] == true then
            return 100000 + v4_28 * 1000 + v5
        end
        return -1
    end

    return v4_28 * 1000 + v5
end

local playersService = game.GetService(game, "Players")
local replicatedStorage = game.GetService(game, "ReplicatedStorage")
v17 = game.GetService(game, "TweenService")
xorKey = game.GetService(game, "UserInputService")
runService = game.GetService(game, "RunService")
currentByte = game.GetService(game, "VirtualUser")
getService = game.GetService
gameInstance = game
decryptedByte = getService(gameInstance, "Lighting")
localPlayer = playersService.LocalPlayer
isPlayer = not localPlayer
if isPlayer then
    isPlayer = playersService.GetPropertyChangedSignal(playersService, "LocalPlayer")
    isPlayer.Wait(isPlayer)
    localPlayer = playersService.LocalPlayer
end
isPlayer = localPlayer.WaitForChild(localPlayer, "PlayerGui")
hiddenGui = gethui and gethui() or isPlayer
getService = hiddenGui
gameInstance = pcall
gameInstance(function()
    if not gethui then
        getService = (game.GetService(game, "CoreGui"))
    end
end)
if not getService then
    getService = isPlayer
end
knitModule = require
packagesFolder = replicatedStorage.WaitForChild(replicatedStorage, "Packages")
gameInstance = knitModule(packagesFolder.WaitForChild(packagesFolder, "Knit"))
modifiersModule = require(replicatedStorage.WaitForChild(replicatedStorage, "Modifiers"))
hiddenGui = require
knitModule = replicatedStorage.WaitForChild(replicatedStorage, "Configs")
hiddenGui = hiddenGui(knitModule.WaitForChild(knitModule, "BrainrotsConfig"))
knitModule = require
packagesFolder = replicatedStorage.WaitForChild(replicatedStorage, "Configs")
knitModule = knitModule(packagesFolder.WaitForChild(packagesFolder, "TrainToolConfig"))
packagesFolder = require
staffConfigModule = replicatedStorage.WaitForChild(replicatedStorage, "Configs")
packagesFolder = packagesFolder(staffConfigModule.WaitForChild(staffConfigModule, "StaffConfig"))
staffConfigModule = require
rebirthConfigModule = replicatedStorage.WaitForChild(replicatedStorage, "Configs")
staffConfigModule = staffConfigModule(rebirthConfigModule.WaitForChild(rebirthConfigModule, "RebirthConfig"))
rebirthConfigModule = require
local upgradeConfigModule = replicatedStorage.WaitForChild(replicatedStorage, "Configs")
rebirthConfigModule = rebirthConfigModule(upgradeConfigModule.WaitForChild(upgradeConfigModule, "UpgradeConfig"))
upgradeConfigModule = require
local seasonPassConfigModule = replicatedStorage.WaitForChild(replicatedStorage, "Configs")
upgradeConfigModule = upgradeConfigModule(seasonPassConfigModule.WaitForChild(seasonPassConfigModule, "SeasonPassConfig"))
seasonPassConfigModule = require
local gameSharedFolder = (replicatedStorage.WaitForChild(replicatedStorage, "GameShared"))
seasonPassConfigModule = seasonPassConfigModule(gameSharedFolder.WaitForChild(gameSharedFolder, "BrainrotUtils"))
local plotUtilsModule = require
gameSharedFolder = replicatedStorage.WaitForChild(replicatedStorage, "GameShared")
plotUtilsModule = plotUtilsModule(gameSharedFolder.WaitForChild(gameSharedFolder, "PlotUtils"))
gameSharedFolder = require
local pickupUtilsModule = replicatedStorage.WaitForChild(replicatedStorage, "GameShared")
gameSharedFolder = gameSharedFolder(pickupUtilsModule.WaitForChild(pickupUtilsModule, "PickupUtils"))
pickupUtilsModule = gameInstance.GetService("WaveService")
local animalService = gameInstance.GetService("AnimalService")
local eggService = gameInstance.GetService("EggService")
local inventoryService = gameInstance.GetService("InventoryService")
local trainingService = gameInstance.GetService("TrainingService")
local pickaxeService = gameInstance.GetService("PickaxeService")
local rebirthService = gameInstance.GetService("RebirthService")
local upgradesService = gameInstance.GetService("UpgradesService")
local plotService = gameInstance.GetService("PlotService")
local playtimeRewardService = gameInstance.GetService("PlaytimeRewardService")
local dailyRewardService = gameInstance.GetService("DailyRewardService")
local rewardService = gameInstance.GetService("RewardService")
local freeShopService = gameInstance.GetService("FreeShopService")
local seasonPassService = gameInstance.GetService("SeasonPassService")
local questService = gameInstance.GetService("QuestService")
local spinWheelService = gameInstance.GetService("SpinWheelService")
local potionService = gameInstance.GetService("PotionService")
local codesService = gameInstance.GetService("CodesService")
local waveController = gameInstance.GetController("WaveController")
local pickupController = gameInstance.GetController("PickupController")
local replicaController = gameInstance.GetController("ReplicaController")
local trainingController = gameInstance.GetController("TrainingController")
local systemStatusText = "ระบบพร้อมทำงาน (กด 🌊 เพื่อเปิดเมนู)"

local function getDialogResult()
    local v0_32, v1 = v2[v0(nil, nil, 83)](function()
        local v0_134 = v4(nil, 1, replicaController[v0(nil, nil, 154)](replicaController))
        return v0_134(259887478) and v0_134(259887478)[nil]
    end)
    return v0_32 and v1 or {}
end

local function getDialogValue()
    local v3
    local v0_34, v1 = v4(nil, 2, v2[v0(nil, nil, 51)](function()
        return plotUtilsModule[nil](localPlayer)
    end))
    if v0_34 and v1(259887478) then
        return v1(259887478)
    end
    local v2_34 = v4(nil, 1, nil)
    v2[v0(nil, nil, 138)](function()
        v2_34[21218222] = plotService[v0(nil, nil, 213)](plotService)
    end)
    if v2_34(259887478) and v2[v0(nil, nil, 148)][v0(nil, nil, 233)](v2[v0(nil, nil, 80)], v0(nil, nil, 119)) then
        v3 = v2[v0(nil, nil, 4)][nil]
        return v3[nil](v3, v2[v0(nil, nil, 96)](v2_34(259887478)))
    end

    return nil
end

local function getDialogState()
    local v1
    local v0_36 = v4(nil, 1, getDialogValue())
    if v0_36(259887478) then
        v1 = v4(nil, 1, v0_36(259887478)[v0(nil, nil, 105)](v0_36(259887478), v0(nil, nil, 71), true))
        if v1(259887478) then
            return v1(259887478)
        end
    end

    return nil
end

local function getDialogCallback(p1)
    if not p1 or v2[v0(nil, nil, 102)](p1) ~= v0(nil, nil, 3) then
        return nil
    elseif p1 >= 1000000000 then
        return v2[v0(nil, nil, 241)][nil](v0(nil, nil, 207), p1 / 1000000000)
    elseif p1 >= 1000000 then
        return v2[v0(nil, nil, 93)][nil](v0(nil, nil, 43), p1 / 1000000)
    elseif p1 >= 1000 then
        return v2[v0(nil, nil, 234)][nil](v0(nil, nil, 31), p1 / 1000)
    end
    return v2[v0(nil, nil, 55)](v2[v0(nil, nil, 62)][nil](p1))
end

local dialogCallback = getDialogCallback
local antiAfkService = v7.AntiAFK
if antiAfkService then
    antiAfkService = localPlayer.Idled
    antiAfkService.Connect(antiAfkService, function()
        currentByte[v0(nil, nil, 195)](currentByte)
        currentByte[v0(nil, nil, 207)](currentByte, v2[v0(nil, nil, 41)][nil](0, 0))
    end)
end

antiAfkService = function()
    if v7[nil] then
        decryptedByte[nil] = false
        decryptedByte[nil] = nil
        decryptedByte[nil] = 1
        v2[v0(nil, nil, 154)](function()
            v2[v0(nil, nil, 80)]()[nil][nil] = 1
        end)
        for v3, v4 in v2[v0(nil, nil, 94)](v2[v0(nil, nil, 71)][v0(nil, nil, 17)](v2[v0(nil, nil, 82)])) do
            if v4[v0(nil, nil, 178)](v4, v0(nil, nil, 18)) or v4[v0(nil, nil, 65)](v4, v0(nil, nil, 186)) or v4[v0(nil, nil, 95)](v4, v0(nil, nil, 78)) or v4[v0(nil, nil, 27)](v4, v0(nil, nil, 174)) then
                v4[nil] = false
            end
        end
    end
    if v7[nil] then
        v2[v0(nil, nil, 116)](function()
            runService[v0(nil, nil, 214)](runService, false)
        end)
    else
        v2[v0(nil, nil, 165)](function()
            runService[v0(nil, nil, 152)](runService, true)
        end)
    end
end

task.spawn(function()
    local v1, v2_42, v3, v4, v5, v11, v12, v13, v14_42
    while true do
        v3 = nil
        v2[v0(nil, nil, 30)][nil](nil)
        if v7[nil] then
            v1 = localPlayer[nil]
            if v1 then
                v3 = nil
                v3 = v0
                v1 = v1[v0(nil, nil, 66)](v1, v3(nil, nil, 113))
            end
            if v1 then
                v3 = nil
                systemStatusText = v0(nil, nil, 162)
                v3 = v2[v0(nil, nil, 228)][nil](665, 68, 325)
                v1[nil] = v3
                v2_42 = v2
                v3 = v0(nil, nil, 101)
                v2_42 = v2_42[v3][nil]
                v3 = nil
                v2_42(nil)
                v3 = nil
                systemStatusText = v0(nil, nil, 38)
                v2_42 = v2
                v3 = v0(nil, nil, 155)
                v2_42 = v2_42[v3]

                v3 = function()
                    waveController[v0(nil, nil, 232)](waveController, v7[nil])
                end

                v2_42(v3)
                v2_42 = v2
                v3 = v0(nil, nil, 225)
                v2_42 = v2_42[v3][nil]
                v3 = nil
                v2_42(nil)
                v2_42 = v2
                v3 = v0(nil, nil, 47)
                v2_42 = v2_42[v3]
                v3 = v0(nil, nil, 219)
                v2_42 = v2_42[v3]
                v3 = v2[v0(nil, nil, 179)]
                v2_42 = v2_42(v3, v0(nil, nil, 172))
                v3 = 5
                v2[v0(nil, nil, 250)](function()
                    v3 = modifiersModule[nil](localPlayer, v0(nil, nil, 212)) or 5
                end)
                v4 = 0
                if v2_42 then
                    v5 = {}
                    for v9, v10 in v2[v0(nil, nil, 25)](v2_42[v0(nil, nil, 5)](v2_42)) do
                        v14_42 = nil
                        v14_42 = nil
                        if v10[v0(nil, nil, 238)](v10, v0(nil, nil, 123)) then
                            v11 = getOrDefault(v10)
                            if v11 > 0 then
                                v14_42 = nil
                                v12 = v2[v0(nil, nil, 105)][nil]
                                v14_42 = {}
                                v14_42[v0(nil, nil, 121)] = v10
                                v14_42[v0(nil, nil, 224)] = v11
                                v12(v5, v14_42)
                            end
                        end
                    end
                    v2[v0(nil, nil, 131)][nil](v5, function(p1, p2)
                        return p1[nil] > p2[nil]
                    end)
                    for v9, v10 in v2[v0(nil, nil, 192)](v5) do
                        if not v7[nil] then
                            break
                        else
                            if v4 >= v3 then
                                break
                            else
                                local v11_in = v10[nil]
                                v12 = v11_in and v11_in[nil]
                                if v12 then
                                    v14_42 = nil
                                    v14_42 = v0
                                    v12 = v11_in[v0(nil, nil, 66)](v11_in, v14_42(nil, nil, 91))
                                end
                                if v12 then
                                    v14_42 = nil
                                    v12 = v11_in[v0(nil, nil, 61)]
                                    v14_42 = v0
                                    v12 = v12(v11_in, v14_42(nil, nil, 185)) or v11_in[nil]
                                    v14_42 = v0(nil, nil, 64)
                                    v13 = v11_in[v14_42]
                                    v14_42 = v11_in
                                    v13 = v13(v14_42, v0(nil, nil, 103))
                                    if not v13 then
                                        v14_42 = nil
                                        v13 = v0(nil, nil, 211)
                                    end
                                    v14_42 = v2[v0(nil, nil, 120)][nil](v0(nil, nil, 183), v2[v0(nil, nil, 94)](v12), v2[v0(nil, nil, 75)](v13))
                                    systemStatusText = v14_42
                                    v14_42 = v1
                                    v14_42[nil] = v11_in[v0(nil, nil, 206)](v11_in) * v2[v0(nil, nil, 165)][nil](0, 3, 0)
                                    v14_42 = v2[v0(nil, nil, 223)][nil]
                                    v14_42(v7[nil])
                                    v14_42 = false
                                    v2[v0(nil, nil, 252)](function()
                                        v14_42 = pickupController[v0(nil, nil, 41)](pickupController, v11_in)
                                    end)
                                    if v14_42 then
                                        v4 = v4 + 1
                                    end
                                end
                            end
                        end
                    end
                end
                systemStatusText = (v0(nil, nil, 218))
                v2[v0(nil, nil, 122)][nil](nil)
                v1[nil] = (v2[v0(nil, nil, 86)][nil](675, 68, 325))
                v2[v0(nil, nil, 42)][nil](1)
                v2[v0(nil, nil, 224)](function()
                    plotService[v0(nil, nil, 77)](plotService)
                end)
                v2[v0(nil, nil, 135)][nil](nil)
            end
        end
    end
end)
task.spawn(function()
    local v0_43, v1, v2_43
    while true do
        v2[v0(nil, nil, 188)][nil](nil)
        if v7[nil] and not v7[nil] then
            v0_43 = localPlayer[nil]
            v1 = v0_43 and v0_43[v0(nil, nil, 188)](v0_43, v0(nil, nil, 184))
            v2_43 = v2[v0(nil, nil, 170)][v0(nil, nil, 124)](v2[v0(nil, nil, 131)], v0(nil, nil, 37))
            if v1 and v2_43 then
                for v6, v7_43 in v2[v0(nil, nil, 225)](v2_43[v0(nil, nil, 66)](v2_43)) do
                    if v7_43[v0(nil, nil, 196)](v7_43, v0(nil, nil, 194)) then
                        if (v7_43[v0(nil, nil, 91)](v7_43)[nil] - v1[nil])[nil] < 65 then
                            v2[v0(nil, nil, 126)](function()
                                pickupController[v0(nil, nil, 104)](pickupController, v7_43)
                            end)
                        end
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    local v0_44, v1, v2_44, v4, v5, v7_44, v8, v9, v10
    while true do
        v2[v0(nil, nil, 74)][nil](nil)
        if v7[nil] or v7[nil] then
            v0_44 = getDialogState()
            if v0_44 then
                v1 = {}
                v2_44 = localPlayer[nil]
                if v2_44 then
                    for v6, v7_44 in v2[v0(nil, nil, 2)](v2_44[v0(nil, nil, 117)](v2_44)) do
                        v9 = v0(nil, nil, 212)
                        v8 = v7_44[v9]
                        v9 = v7_44
                        v8 = v8(v9, v0(nil, nil, 241))
                        if v8 then
                            v9 = v0(nil, nil, 179)
                            v8 = v7_44[v9]
                            v9 = v7_44
                            v8 = v8(v9, v0(nil, nil, 61))
                        end
                        if v8 then
                            v9 = v0(nil, nil, 82)
                            v8 = v7_44[v9]
                            v9 = v7_44
                            v8 = v8(v9, v0(nil, nil, 84))
                        end
                        if v8 then
                            v8 = v2
                            v9 = v0(nil, nil, 146)
                            v8 = v8[v9][nil]
                            v9 = v1
                            v8(v9, v7_44)
                        end
                    end
                end
                v4 = localPlayer[nil]
                for v6, v7_44 in v2[v0(nil, nil, 12)](v4[nil](v4)) do
                    v9 = v0(nil, nil, 45)
                    v8 = v7_44[v9]
                    v9 = v7_44
                    v8 = v8(v9, v0(nil, nil, 205))
                    if v8 then
                        v9 = v0(nil, nil, 12)
                        v8 = v7_44[v9]
                        v9 = v7_44
                        v8 = v8(v9, v0(nil, nil, 124))
                    end
                    if v8 then
                        v9 = v0(nil, nil, 38)
                        v8 = v7_44[v9]
                        v9 = v7_44
                        v8 = v8(v9, v0(nil, nil, 141))
                    end
                    if v8 then
                        v8 = v2
                        v9 = v0(nil, nil, 5)
                        v8 = v8[v9][nil]
                        v9 = v1
                        v8(v9, v7_44)
                    end
                end
                for v6, v7_44 in v2[v0(nil, nil, 1)](v1) do
                    v5 = v6
                    v9 = v0(nil, nil, 98)
                    local v8_in = v7_44[v9]
                    v9 = v7_44
                    v8_in = v8_in(v9, v0(nil, nil, 128))
                    v9 = v5
                    v9 = (v5 - 1) % 4 * 4 - 6
                    local v11_in
                    v10 = v2[v0(nil, nil, 50)][nil]((v5 - 1) / 4) * 4 - 6
                    v11_in = v0_44[nil] * v2[v0(nil, nil, 163)][nil](v9, nil, v10)
                    systemStatusText = (v2[v0(nil, nil, 226)][nil](v0(nil, nil, 114), v7_44[nil]))
                    v2[v0(nil, nil, 221)](function()
                        eggService[v0(nil, nil, 179)](eggService, v8_in, v11_in)
                    end)
                    v2[v0(nil, nil, 72)][nil](nil)
                end
            end
        end
        if v7[nil] or v7[nil] then
            v0_44 = getDialogValue()
            if v0_44 then
                v1 = v2[v0(nil, nil, 19)][v0(nil, nil, 172)](v2[v0(nil, nil, 33)])
                for v5, v6 in v2[v0(nil, nil, 80)](v0_44[v0(nil, nil, 67)](v0_44)) do
                    v9 = nil
                    v9 = v0
                    v7_44 = v6[v0(nil, nil, 117)](v6, v9(nil, nil, 54))
                    if v7_44 then
                        v9 = nil
                        v9 = v0
                        v7_44 = v6[v0(nil, nil, 20)](v6, v9(nil, nil, 105))
                    end
                    if v7_44 then
                        v9 = nil
                        v9 = v0
                        v7_44 = v6[v0(nil, nil, 8)](v6, v9(nil, nil, 111))
                    end
                    if v7_44 then
                        v9 = nil
                        v9 = v0
                        v7_44 = v6[v0(nil, nil, 44)](v6, v9(nil, nil, 145))
                        v9 = v0(nil, nil, 120)
                        v8 = v6[v9]
                        v9 = v6
                        v8 = v8(v9, v0(nil, nil, 196))
                        v9 = v6[v0(nil, nil, 113)](v6, v0(nil, nil, 51))
                        if not v6[v0(nil, nil, 191)](v6, v0(nil, nil, 79)) and v7_44 + v8 - v1 <= 0 then
                            systemStatusText = (v2[v0(nil, nil, 133)][nil](v0(nil, nil, 10), v6[nil]))
                            v2[v0(nil, nil, 100)](function()
                                eggService[v0(nil, nil, 99)](eggService, v9)
                            end)
                            v2[v0(nil, nil, 30)][nil](nil)
                        end
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while true do
        v2[v0(nil, nil, 139)][nil](nil)
        if v7[nil] or v7[nil] then
            v2[v0(nil, nil, 181)](function()
                animalService[v0(nil, nil, 14)](animalService)
            end)
        end
    end
end)
task.spawn(function()
    local v1, v2_46, v5, v8, v9, v10, v11, v12, v13
    while true do
        v2_46 = nil
        v2[v0(nil, nil, 220)][nil](4)
        if v7[nil] then
            v1 = getDialogResult()[nil] or {}
            v2_46 = {}
            for v6, v7_46 in v2[v0(nil, nil, 141)](v1) do
                v5 = v6
                v8 = v7_46[nil]
                v9 = v7_46[nil] or v0(nil, nil, 26)
                v10 = hiddenGui[nil][v8] or {}
                v11 = v10[nil] or v0(nil, nil, 10)
                v12 = v10[nil] or 1
                v13 = false
                if v7[nil] and v9 ~= v0(nil, nil, 254) then
                    v13 = true
                end
                if v7[nil] and v7[nil][v11] then
                    v13 = true
                end
                if not v13 and v12 < v7[nil] then
                    v2[v0(nil, nil, 71)][nil](v2_46, v5)
                end
            end
            if #v2_46 > 0 then
                systemStatusText = v2[v0(nil, nil, 208)][nil](v0(nil, nil, 97), #v2_46)
                v2[v0(nil, nil, 89)](function()
                    inventoryService[v0(nil, nil, 176)](inventoryService, v2_46)
                end)
            end
        end
    end
end)
task.spawn(function()
    while true do
        v2[v0(nil, nil, 146)][nil](nil)
        if v7[nil] then
            v2[v0(nil, nil, 191)](function()
                if not trainingController[v0(nil, nil, 224)](trainingController) then
                    systemStatusText = v0(nil, nil, 196)
                    trainingService[v0(nil, nil, 250)](trainingService)
                end
            end)
        end
    end
end)
pcall(function()
    local v0_48 = trainingService[nil]
    v0_48[nil](v0_48, function(p1)
        if v7[nil] then
            systemStatusText = v0(nil, nil, 77)
            v2[v0(nil, nil, 87)](function()
                trainingService[v0(nil, nil, 135)](trainingService, p1)
            end)
        end
    end)
end)
task.spawn(function()
    local v0_49, v1, v2_49, v3, v4, v5, v6, v7_49, v13, getOrDefault, playersService
    while true do
        v4 = 40
        v2[v0(nil, nil, 40)][nil](3)
        if v7[nil] or v7[nil] then
            v0_49 = getDialogResult()
            v1 = v0_49[nil] and v0_49[nil][nil] or 0
            v2_49 = v0_49[nil] or {}
            v3 = v0_49[nil]
            if not v3 then
                v4 = nil
                v5 = nil
                v3 = v0(nil, nil, 12)
            end
            v4 = nil
            v5 = v0(nil, nil, 23)
            v6 = 0
            v7_49 = {}
            for v11, v12 in v2[v0(nil, nil, 11)](knitModule[nil]) do
                v2[v0(nil, nil, 20)][nil](v7_49, v12)
            end
            v2[v0(nil, nil, 216)][nil](v7_49, function(p1, p2)
                return (p1[nil] or 0) > (p2[nil] or 0)
            end)
            for v11, v12 in v2[v0(nil, nil, 243)](v7_49) do
                v13 = v12[nil]
                getOrDefault = v12[nil] or 0
                playersService = v12[nil] or 0
                if v2_49[v13] and playersService > v6 then
                    v6 = playersService
                    v5 = v13
                end
                if v7[nil] and not v2_49[v13] and getOrDefault > 0 and v1 >= getOrDefault then
                    if not v4 then
                        v4 = v12
                    end
                end
            end
            if v7[nil] and v4 then
                systemStatusText = v2[v0(nil, nil, 212)][nil](v0(nil, nil, 245), v4[nil], dialogCallback(v4[nil]))
                v2[v0(nil, nil, 156)](function()
                    trainingService[v0(nil, nil, 228)](trainingService, v4[nil])
                end)
                v2[v0(nil, nil, 195)][nil](nil)
            end
            if v7[nil] and v5 and v5 ~= v3 then
                systemStatusText = v2[v0(nil, nil, 235)][nil](v0(nil, nil, 69), v5)
                v2[v0(nil, nil, 182)](function()
                    trainingService[v0(nil, nil, 90)](trainingService, v5)
                end)
            end
        end
    end
end)
task.spawn(function()
    local v0_50, v1, v2_50, v3, v4, v5, v6, v7_50, v13, getOrDefault, playersService, replicatedStorage
    while true do
        v4 = 223
        v2[v0(nil, nil, 223)][nil](3)
        if v7[nil] or v7[nil] then
            v0_50 = getDialogResult()
            v1 = v0_50[nil] and v0_50[nil][nil] or 0
            v2_50 = v0_50[nil] or {}
            v3 = v0_50[nil]
            if not v3 then
                v4 = nil
                v5 = nil
                v3 = v0(nil, nil, 239)
            end
            v4 = nil
            v5 = v0(nil, nil, 105)
            v6 = 0
            v7_50 = {}
            for v11, v12 in v2[v0(nil, nil, 94)](packagesFolder) do
                v13 = v2[v0(nil, nil, 18)][nil]
                playersService = {}
                playersService[v0(nil, nil, 138)] = v11
                playersService[v0(nil, nil, 169)] = v12
                v13(v7_50, playersService)
            end
            v2[v0(nil, nil, 195)][nil](v7_50, function(p1, p2)
                return (p1[nil][nil] or 0) > (p2[nil][nil] or 0)
            end)
            for v11, v12 in v2[v0(nil, nil, 90)](v7_50) do
                v13 = v12[nil]
                getOrDefault = v12[nil]
                playersService = getOrDefault[nil] or 0
                replicatedStorage = getOrDefault[nil] or 0
                if v2_50[v13] and replicatedStorage > v6 then
                    v6 = replicatedStorage
                    v5 = v13
                end
                if v7[nil] and not v2_50[v13] and playersService > 0 and v1 >= playersService then
                    if not v4 then
                        v4 = v12
                    end
                end
            end
            if v7[nil] and v4 then
                systemStatusText = v2[v0(nil, nil, 19)][nil](v0(nil, nil, 224), v4[nil][nil], dialogCallback(v4[nil][nil]))
                v2[v0(nil, nil, 107)](function()
                    pickaxeService[v0(nil, nil, 130)](pickaxeService, v4[nil])
                end)
                v2[v0(nil, nil, 29)][nil](nil)
            end
            if v7[nil] and v5 and v5 ~= v3 then
                systemStatusText = v2[v0(nil, nil, 22)][nil](v0(nil, nil, 238), v5)
                v2[v0(nil, nil, 3)](function()
                    pickaxeService[v0(nil, nil, 115)](pickaxeService, v5)
                end)
            end
        end
    end
end)
task.spawn(function()
    local v0_51, v1, v2_51, v3
    while true do
        v2[v0(nil, nil, 90)][nil](nil)
        v0_51 = getDialogResult()
        v1 = v0_51[nil] and v0_51[nil][nil] or 0
        v2_51 = v0_51[nil] or 0
        if v7[nil] then
            v3 = staffConfigModule[nil][v2_51 + 1]
            if v3 and v3[nil] and v3[nil][nil] and v1 >= v3[nil][nil] then
                systemStatusText = (v2[v0(nil, nil, 240)][nil](v0(nil, nil, 90), v2_51 + 1))
                v2[v0(nil, nil, 136)](function()
                    rebirthService[v0(nil, nil, 9)](rebirthService)
                end)
                v2[v0(nil, nil, 21)][nil](nil)
            end
        end
        if v7[nil] then
            v2[v0(nil, nil, 137)](function()
                upgradesService[v0(nil, nil, 150)](upgradesService, v0(nil, nil, 125))
            end)
        end
        if v7[nil] then
            v2[v0(nil, nil, 214)](function()
                upgradesService[v0(nil, nil, 66)](upgradesService, v0(nil, nil, 243))
            end)
        end
        if v7[nil] then
            v2[v0(nil, nil, 119)](function()
                upgradesService[v0(nil, nil, 241)](upgradesService, v0(nil, nil, 144))
            end)
        end
    end
end)
task.spawn(function()
    while true do
        v2[v0(nil, nil, 145)][nil](5)
        if v7[nil] then
            if (1 > 0 and 1 <= 12) or (1 < 0 and 1 >= 12) then
                local v0_52_in = 1
                repeat
                    v2[v0(nil, nil, 84)](function()
                        playtimeRewardService[v0(nil, nil, 49)](playtimeRewardService, v0_52_in)
                    end)
                    v2[v0(nil, nil, 192)][nil](nil)
                    v0_52_in = v0_52_in + 1
                until not (v0_52_in <= 12)
            end
            ::block5::
            if v7[nil] then
                v2[v0(nil, nil, 10)](function()
                    dailyRewardService[v0(nil, nil, 189)](dailyRewardService)
                end)
                v2[v0(nil, nil, 17)](function()
                    dailyRewardService[v0(nil, nil, 173)](dailyRewardService, 1)
                end)
            end
            if v7[nil] then
                v2[v0(nil, nil, 125)](function()
                    animalService[v0(nil, nil, 176)](animalService)
                end)
            end
            if v7[nil] then
                v2[v0(nil, nil, 61)](function()
                    rewardService[v0(nil, nil, 218)](rewardService)
                end)
            end
            if v7[nil] then
                v2[v0(nil, nil, 211)](function()
                    freeShopService[v0(nil, nil, 191)](freeShopService)
                end)
            end
            continue
        end
        goto block5
    end
end)
task.spawn(function()
    local v1
    while true do
        v2[v0(nil, nil, 13)][nil](6)
        if v7[nil] then
            if (1 > 0 and 1 <= 10) or (1 < 0 and 1 >= 10) then
                local v0_53_in = 1
                repeat
                    v2[v0(nil, nil, 33)](function()
                        seasonPassService[v0(nil, nil, 186)](seasonPassService, v0_53_in)
                    end)
                    v2[v0(nil, nil, 42)][nil](nil)
                    v0_53_in = v0_53_in + 1
                until not (v0_53_in <= 10)
            end
            ::block5::
            if v7[nil] then
                v1 = (getDialogResult())[nil] or {}
                for v5, v6 in v2[v0(nil, nil, 177)](v1) do
                    if v2[v0(nil, nil, 62)](v6) == v0(nil, nil, 91) then
                        for v10, v11 in v2[v0(nil, nil, 150)](v6) do
                            if v11[nil] and not v11[nil] and v11[nil] then
                                systemStatusText = v2[v0(nil, nil, 191)][nil](v0(nil, nil, 220), v2[v0(nil, nil, 124)](v11[nil]))
                                v2[v0(nil, nil, 92)](function()
                                    questService[v0(nil, nil, 121)](questService, v11[nil])
                                end)
                                v2[v0(nil, nil, 130)][nil](nil)
                            end
                        end
                    end
                end
            end
            continue
        end
        goto block5
    end
end)
task.spawn(function()
    while true do
        v2[v0(nil, nil, 106)][nil](8)
        if v7[nil] then
            v2[v0(nil, nil, 226)](function()
                spinWheelService[v0(nil, nil, 77)](spinWheelService)
            end)
        end
    end
end)
task.spawn(function()
    local v0_55, v1, v2_55, v3, v4
    while true do
        v2[v0(nil, nil, 71)][nil](10)
        if v7[nil] then
            v0_55 = getDialogResult()
            v1 = v0_55[nil] or {}
            v2_55 = v0_55[nil] or {}
            v3 = v7[nil]
            if v3 then
                v4 = v0(nil, nil, 171)
                v3 = (v1[v4] or 0) > 0
            end
            if v3 then
                v3 = not v2_55[v0(nil, nil, 54)]
            end
            if v3 then
                v2[v0(nil, nil, 20)](function()
                    potionService[v0(nil, nil, 216)](potionService, v0(nil, nil, 173))
                end)
            end
            v3 = v7[nil]
            if v3 then
                v4 = v0(nil, nil, 211)
                v3 = (v1[v4] or 0) > 0
            end
            if v3 then
                v3 = not v2_55[v0(nil, nil, 103)]
            end
            if v3 then
                v2[v0(nil, nil, 171)](function()
                    potionService[v0(nil, nil, 182)](potionService, v0(nil, nil, 114))
                end)
            end
            v3 = v7[nil]
            if v3 then
                v4 = v0(nil, nil, 146)
                v3 = (v1[v4] or 0) > 0
            end
            if v3 then
                v3 = not v2_55[v0(nil, nil, 183)]
            end
            if v3 then
                v2[v0(nil, nil, 166)](function()
                    potionService[v0(nil, nil, 149)](potionService, v0(nil, nil, 200))
                end)
            end
        end
    end
end)


getDialogCallback = function()
    local v0_57 = {
        v0(nil, nil, 41),
        v0(nil, nil, 60),
        v0(nil, nil, 158),
        v0(nil, nil, 168),
        v0(nil, nil, 69),
        v0(nil, nil, 71),
        v0(nil, nil, 24),
        v0(nil, nil, 242),
        v0(nil, nil, 142),
        v0(nil, nil, 3),
        v0(nil, nil, 68),
        v0(nil, nil, 129),
        v0(nil, nil, 233),
    }
    for v4, v5 in v2[v0(nil, nil, 236)](v0_57) do
        systemStatusText = v2[v0(nil, nil, 164)][nil](v0(nil, nil, 199), v5)
        v2[v0(nil, nil, 212)](function()
            codesService[v0(nil, nil, 253)](codesService, v5)
        end)
        v2[v0(nil, nil, 121)][nil](nil)
    end
    systemStatusText = v0(nil, nil, 254)
end

task.spawn(function()
    v2[v0(nil, nil, 154)][nil](2)
    if v7[nil] then
        getDialogCallback()
    end
end)
local accentColor = Color3.fromRGB(0, 195, 255)
local frameBackgroundColor = Color3.fromRGB(13, 16, 23)
local textColor = Color3.fromRGB(20, 24, 34)
local panelBackgroundColor = Color3.fromRGB(16, 20, 28)
pcall(function()
    local v0_59 = v4(nil, 1, getService[v0(nil, nil, 61)](getService, v0(nil, nil, 91)))
    if v0_59(259887478) then
        v0_59(259887478)[v0(nil, nil, 55)](v0_59(259887478))
    end
end)
pcall(function()
    local v0_60 = v4(nil, 1, isPlayer[v0(nil, nil, 95)](isPlayer, v0(nil, nil, 55)))
    if v0_60(259887478) then
        v0_60(259887478)[v0(nil, nil, 178)](v0_60(259887478))
    end
end)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TawinHubOpenSeaGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local isMenuOpen = false
pcall(function()
    screenGui[nil] = getService
    isMenuOpen = true
end)
if not isMenuOpen or not screenGui.Parent then
    screenGui.Parent = isPlayer
end
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 690, 0, 470)
frame.Position = UDim2.new(0.5, -345, 0.5, -235)
frame.BackgroundColor3 = frameBackgroundColor
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = screenGui
local uICorner = Instance.new("UICorner", frame)
uICorner.CornerRadius = (UDim.new(0, 12))

local uIStroke = Instance.new("UIStroke", frame)
uIStroke.Thickness = 1.8
uIStroke.Color = accentColor
uIStroke.Transparency = 0.15
uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local frame2 = Instance.new("Frame")
frame2.Name = "FloatToggle"
frame2.Size = UDim2.new(0, 52, 0, 52)
frame2.Position = UDim2.new(0.03, 0, 0.25, 0)
frame2.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
frame2.BorderSizePixel = 0
frame2.ZIndex = 50
frame2.Parent = screenGui
local uiStroke = Instance.new("UICorner", frame2)
uiStroke.CornerRadius = UDim.new(1, 0)
uiStroke = Instance.new("UIStroke", frame2)
uiStroke.Thickness = 2
uiStroke.Color = accentColor
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local textButton2 = (Instance.new("TextLabel"))
textButton2.Size = (UDim2.new(1, 0, 1, 0))
textButton2.BackgroundTransparency = 1
textButton2.Text = "🌊"
textButton2.Font = Enum.Font.GothamBold
textButton2.TextSize = 22
textButton2.ZIndex = 51
textButton2.Parent = frame2
textButton2 = Instance.new("TextButton")
local isActivated = textButton2
isActivated.Size = (UDim2.new(1, 0, 1, 0))

textButton2.BackgroundTransparency = 1
textButton2.Text = ""
textButton2.ZIndex = 52
isActivated = textButton2
isActivated.Parent = frame2
isActivated = false
local selectedValue
local currentPosition
local inputHandler = textButton2.InputBegan
inputHandler.Connect(inputHandler, function(p1)
    local v4_62
    local v1 = p1[nil]
    local v2_62 = v2[v0(nil, nil, 237)][nil][nil]
    v1 = v1 == v2_62
    if not v1 then
        v1 = p1[nil]
        v2_62 = v2[v0(nil, nil, 158)][nil][nil]
        v1 = v1 == v2_62
    end
    if v1 then
        isActivated = false
        selectedValue = p1[nil]
        currentPosition = frame2[nil]
        v1, v2_62 = v4(nil, 2)
        v4_62 = xorKey[nil]
        v1[21218222] = v4_62[nil](v4_62, function(p1)
            local v1
            if (p1[nil] == v2[v0(nil, nil, 19)][nil][nil] or p1[nil] == v2[v0(nil, nil, 92)][nil][nil]) and selectedValue then
                v1 = v4(nil, 1, p1[nil] - selectedValue)
                if v1(259887478)[nil] > 6 then
                    isActivated = true
                    frame2[nil] = v2[v0(nil, nil, 28)][nil](currentPosition[nil][nil], currentPosition[nil][nil] + v1(259887478)[nil], currentPosition[nil][nil], currentPosition[nil][nil] + v1(259887478)[nil])
                end
            end
        end)
        v4_62 = xorKey[nil]
        v2_62[21218222] = v4_62[nil](v4_62, function(p1)
            if p1[nil] == v2[v0(nil, nil, 226)][nil][nil] or p1[nil] == v2[v0(nil, nil, 133)][nil][nil] then
                if v1(259887478) then
                    v1(259887478)[v0(nil, nil, 68)](v1(259887478))
                end
                if v2_62(259887478) then
                    v2_62(259887478)[v0(nil, nil, 26)](v2_62(259887478))
                end
                selectedValue = nil
                v2[v0(nil, nil, 230)][nil](nil, function()
                    isActivated = false
                end)
            end
        end)
    end
end)

local function handleInput()
    local v0_64, v1, v2_64, v3, v4
    frame[nil] = not frame[nil]
    if frame[nil] then
        frame[nil] = v2[v0(nil, nil, 99)][nil](0, 660, 0, 440)
        v0_64 = v17[v0(nil, nil, 177)]
        v1 = v17
        v2_64 = frame
        v3 = v2[v0(nil, nil, 74)][nil](nil, v2[v0(nil, nil, 95)][nil][nil], v2[v0(nil, nil, 193)][nil][nil])
        v4 = {}
        v4[v0(nil, nil, 144)] = v2[v0(nil, nil, 13)][nil](0, 690, 0, 470)
        v0_64 = v0_64(v1, v2_64, v3, v4)
        v0_64[nil](v0_64)
    end
end

inputHandler = textButton2.Activated
inputHandler.Connect(inputHandler, function()
    if not isActivated then
        handleInput()
    end
end)
inputHandler = xorKey.InputBegan
inputHandler.Connect(inputHandler, function(p1, p2)
    if not p2 and (p1[nil] == v2[v0(nil, nil, 132)][nil][nil] or p1[nil] == v2[v0(nil, nil, 78)][nil][nil] or p1[nil] == v2[v0(nil, nil, 124)][nil][nil]) then
        handleInput()
    end
end)
inputHandler = Instance.new("Frame", frame)
inputHandler.Name = "Topbar"
inputHandler.Size = (UDim2.new(1, 0, 0, 54))
inputHandler.BackgroundColor3 = (Color3.fromRGB(20, 24, 34))
inputHandler.BorderSizePixel = 0
local uiCorner = Instance.new("UICorner", inputHandler)
uiCorner.CornerRadius = (UDim.new(0, 12))
uiCorner = Instance.new("TextLabel", inputHandler)
uiCorner.Size = UDim2.new(0, 260, 0, 22)
uiCorner.Position = UDim2.new(0, 16, 0, 8)
uiCorner.BackgroundTransparency = 1
uiCorner.Text = "👑 เนตรนารี ฮัฟฟู๊วว"
uiCorner.TextColor3 = accentColor
uiCorner.Font = Enum.Font.GothamBold
uiCorner.TextSize = 18
uiCorner.TextXAlignment = Enum.TextXAlignment.Left

local textLabel = Instance.new("TextLabel", inputHandler)
textLabel.Size = (UDim2.new(0, 320, 0, 16))
textLabel.Position = (UDim2.new(0, 16, 0, 30))
textLabel.BackgroundTransparency = 1
textLabel.Text = "Open Sea For Animals — V1.1"
textLabel.TextColor3 = (Color3.fromRGB(150, 160, 180))
textLabel.Font = Enum.Font.GothamMedium
textLabel.TextSize = 12
textLabel.TextXAlignment = Enum.TextXAlignment.Left

local textButton = Instance.new("TextButton", inputHandler)
local buttonHandler = textButton
buttonHandler.Size = (UDim2.new(0, 32, 0, 32))
buttonHandler = textButton
buttonHandler.Position = (UDim2.new(1, -42, 0, 11))
buttonHandler = textButton
buttonHandler.BackgroundColor3 = (Color3.fromRGB(35, 40, 55))

textButton.Text = "✕"
buttonHandler = textButton
buttonHandler.TextColor3 = (Color3.fromRGB(230, 230, 240))

textButton.Font = Enum.Font.GothamBold
textButton.TextSize = 14
textButton.BorderSizePixel = 0
buttonHandler = Instance.new("UICorner", textButton)
buttonHandler.CornerRadius = (UDim.new(0, 8))
buttonHandler = textButton.Activated
buttonHandler.Connect(buttonHandler, function()
    frame[nil] = false
end)
buttonHandler = false
local selectedOption
local framePosition
local scrollingFrame = inputHandler.InputBegan
scrollingFrame.Connect(scrollingFrame, function(p1)
    local v4_68
    local v1 = p1[nil]
    local v2_68 = v2[v0(nil, nil, 98)][nil][nil]
    v1 = v1 == v2_68
    if not v1 then
        v1 = p1[nil]
        v2_68 = v2[v0(nil, nil, 252)][nil][nil]
        v1 = v1 == v2_68
    end
    if v1 then
        buttonHandler = true
        selectedOption = p1[nil]
        framePosition = frame[nil]
        v1, v2_68 = v4(nil, 2)
        v4_68 = xorKey[nil]
        v1[21218222] = v4_68[nil](v4_68, function(p1)
            local v1
            if (p1[nil] == v2[v0(nil, nil, 163)][nil][nil] or p1[nil] == v2[v0(nil, nil, 99)][nil][nil]) and buttonHandler and selectedOption then
                v1 = v4(nil, 1, p1[nil] - selectedOption)
                frame[nil] = v2[v0(nil, nil, 157)][nil](framePosition[nil][nil], framePosition[nil][nil] + v1(259887478)[nil], framePosition[nil][nil], framePosition[nil][nil] + v1(259887478)[nil])
            end
        end)
        v4_68 = xorKey[nil]
        v2_68[21218222] = v4_68[nil](v4_68, function(p1)
            if p1[nil] == v2[v0(nil, nil, 228)][nil][nil] or p1[nil] == v2[v0(nil, nil, 155)][nil][nil] then
                if v1(259887478) then
                    v1(259887478)[v0(nil, nil, 147)](v1(259887478))
                end
                if v2_68(259887478) then
                    v2_68(259887478)[v0(nil, nil, 116)](v2_68(259887478))
                end
                buttonHandler = false
                selectedOption = nil
            end
        end)
    end
end)
local frame3 = Instance.new("Frame", frame)
frame3.Size = (UDim2.new(1, 0, 1, -54))
frame3.Position = (UDim2.new(0, 0, 0, 54))
frame3.BackgroundTransparency = 1
scrollingFrame = Instance.new("ScrollingFrame", frame3)
scrollingFrame.Size = UDim2.new(0, 165, 1, -10)
scrollingFrame.Position = UDim2.new(0, 10, 0, 5)
scrollingFrame.BackgroundColor3 = panelBackgroundColor
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 2
scrollingFrame.ScrollBarImageColor3 = accentColor
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
local uiListLayout = Instance.new("UICorner", scrollingFrame)
uiListLayout.CornerRadius = UDim.new(0, 10)
uiListLayout = Instance.new("UIListLayout", scrollingFrame)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = (UDim.new(0, 5))

local uIPadding = Instance.new("UIPadding", scrollingFrame)
uIPadding.PaddingTop = (UDim.new(0, 8))
uIPadding.PaddingBottom = (UDim.new(0, 8))
uIPadding.PaddingLeft = (UDim.new(0, 6))
uIPadding.PaddingRight = (UDim.new(0, 6))

local frame4 = Instance.new("Frame", frame3)
frame4.Size = (UDim2.new(1, -190, 1, -10))
frame4.Position = (UDim2.new(0, 180, 0, 5))
frame4.BackgroundColor3 = panelBackgroundColor
frame4.BorderSizePixel = 0
local itemList = Instance.new("UICorner", frame4)
itemList.CornerRadius = (UDim.new(0, 10))
itemList = {}
local configList = {}

local function createDialog(p1, p2, p3, p4)
    local v4_70 = v4(nil, 1, v2[v0(nil, nil, 85)][nil](v0(nil, nil, 56), frame4))
    local v5 = v4_70(259887478)
    v5[nil] = p1 .. v0(nil, nil, 172)
    v4_70(259887478)[nil] = false
    v5 = v4_70(259887478)
    v5[nil] = v2[v0(nil, nil, 166)][nil](1, -12, 1, -12)
    v5 = v4_70(259887478)
    v5[nil] = v2[v0(nil, nil, 67)][nil](0, 6, 0, 6)
    v4_70(259887478)[nil] = 1
    v4_70(259887478)[nil] = 0
    v4_70(259887478)[nil] = 4
    v4_70(259887478)[nil] = accentColor
    v5 = v4_70(259887478)
    v5[nil] = v2[v0(nil, nil, 58)][nil][nil]
    v5 = v4_70(259887478)
    v5[nil] = v2[v0(nil, nil, 232)][nil](0, 0, 0, 0)
    v5 = v4(nil, 1, v2[v0(nil, nil, 69)][nil](v0(nil, nil, 71), v4_70(259887478)))
    local v6 = v5(259887478)
    v6[nil] = v2[v0(nil, nil, 67)][nil][nil]
    v6 = v5(259887478)
    v6[nil] = (v2[v0(nil, nil, 82)][nil](0, 6))
    v6 = v4(nil, 1, v2[v0(nil, nil, 89)][nil](v0(nil, nil, 185), v4_70(259887478)))
    local v7 = v6(259887478)
    v7[nil] = v2[v0(nil, nil, 93)][nil](0, 6)
    v7 = v6(259887478)
    v7[nil] = v2[v0(nil, nil, 254)][nil](0, 12)
    v7 = v6(259887478)
    v7[nil] = v2[v0(nil, nil, 61)][nil](0, 6)
    v7 = v6(259887478)
    v7[nil] = v2[v0(nil, nil, 48)][nil](0, 6)
    v7 = v4(nil, 1, v2[v0(nil, nil, 211)][nil](v0(nil, nil, 124), scrollingFrame))
    local v8 = v7(259887478)
    v8[nil] = (v2[v0(nil, nil, 210)][nil](1, 0, 0, 36))
    v7(259887478)[nil] = textColor
    v7(259887478)[nil] = nil
    v7(259887478)[nil] = 0
    v7(259887478)[nil] = p4 or 1
    v8 = v2[v0(nil, nil, 233)][nil](v0(nil, nil, 68), v7(259887478))
    v8[nil] = (v2[v0(nil, nil, 175)][nil](0, 8))
    v8 = v4(nil, 1, v2[v0(nil, nil, 169)][nil](v0(nil, nil, 222), v7(259887478)))
    local v9 = v8(259887478)
    v9[nil] = v2[v0(nil, nil, 225)][nil](0, 24, 1, 0)
    v9 = v8(259887478)
    v9[nil] = v2[v0(nil, nil, 113)][nil](0, 8, 0, 0)
    v8(259887478)[nil] = 1
    v8(259887478)[nil] = p2
    v8(259887478)[nil] = 14
    v9 = v8(259887478)
    v9[nil] = v2[v0(nil, nil, 130)][nil][nil]
    v9 = v4(nil, 1, v2[v0(nil, nil, 123)][nil](v0(nil, nil, 86), v7(259887478)))
    local v10 = v9(259887478)
    v10[nil] = (v2[v0(nil, nil, 29)][nil](1, -38, 1, 0))
    v10 = v9(259887478)
    v10[nil] = (v2[v0(nil, nil, 54)][nil](0, 34, 0, 0))
    v9(259887478)[nil] = 1
    v9(259887478)[nil] = p3
    v10 = v9(259887478)
    v10[nil] = (v2[v0(nil, nil, 73)][nil](180, 185, 200))
    v10 = v9(259887478)
    v10[nil] = v2[v0(nil, nil, 246)][nil][nil]
    v9(259887478)[nil] = 11
    v10 = v9(259887478)
    v10[nil] = v2[v0(nil, nil, 134)][nil][nil]

    v10 = function()
        for v3, v4 in v2[v0(nil, nil, 221)](itemList) do
            v4[nil] = false
        end
        for v3, v4 in v2[v0(nil, nil, 26)](configList) do
            v4[nil] = textColor
            v4[v0(nil, nil, 169)](v4, v0(nil, nil, 91), true)[nil] = v2[v0(nil, nil, 132)][nil](180, 185, 200)
        end
        v4_70(259887478)[nil] = true
        v7(259887478)[nil] = v2[v0(nil, nil, 150)][nil](0, 95, 145)
        v9(259887478)[nil] = v2[v0(nil, nil, 191)][nil](255, 255, 255)
    end

    local v11 = v7(259887478)[nil]
    v11[nil](v11, v10)
    itemList[p1] = v4_70(259887478)
    configList[p1] = v7(259887478)

    return v4_70(259887478), v10
end

local function addDialogSection(p1, p2)
    local v2_72 = v4(nil, 1, v2[v0(nil, nil, 111)][nil](v0(nil, nil, 3), p1))
    v2_72(259887478)[nil] = v2[v0(nil, nil, 41)][nil](1, 0, 0, 28)
    v2_72(259887478)[nil] = 1
    local v3 = v4(nil, 1, v2[v0(nil, nil, 234)][nil](v0(nil, nil, 253), v2_72(259887478)))
    v3(259887478)[nil] = v2[v0(nil, nil, 241)][nil](1, 0, 1, 0)
    v3(259887478)[nil] = 1
    v3(259887478)[nil] = v0(nil, nil, 171) .. p2 .. v0(nil, nil, 91)
    v3(259887478)[nil] = accentColor
    v3(259887478)[nil] = v2[v0(nil, nil, 147)][nil][nil]
    v3(259887478)[nil] = 12
    v3(259887478)[nil] = v2[v0(nil, nil, 246)][nil][nil]

    return v2_72(259887478)
end

local function addToggleOption(p1, p2, p3, p4)
    local v4_74 = v4(nil, 1, v2[v0(nil, nil, 103)][nil](v0(nil, nil, 47), p1))
    local v5 = v4_74(259887478)
    v5[nil] = (v2[v0(nil, nil, 94)][nil](1, 0, 0, 42))
    v4_74(259887478)[nil] = textColor
    v4_74(259887478)[nil] = 0
    v5 = v2[v0(nil, nil, 17)][nil](v0(nil, nil, 155), v4_74(259887478))
    v5[nil] = (v2[v0(nil, nil, 149)][nil](0, 8))
    v5 = v4(nil, 1, v2[v0(nil, nil, 231)][nil](v0(nil, nil, 177), v4_74(259887478)))
    local v6 = v5(259887478)
    v6[nil] = (v2[v0(nil, nil, 73)][nil](1, -70, 1, 0))
    v6 = v5(259887478)
    v6[nil] = (v2[v0(nil, nil, 66)][nil](0, 12, 0, 0))
    v5(259887478)[nil] = 1
    v5(259887478)[nil] = p2
    v6 = v5(259887478)
    v6[nil] = (v2[v0(nil, nil, 254)][nil](225, 230, 240))
    v6 = v5(259887478)
    v6[nil] = v2[v0(nil, nil, 197)][nil][nil]
    v5(259887478)[nil] = 11
    v6 = v5(259887478)
    v6[nil] = v2[v0(nil, nil, 177)][nil][nil]
    v6 = v4(nil, 1, v2[v0(nil, nil, 180)][nil](v0(nil, nil, 25), v4_74(259887478)))
    local v7 = v6(259887478)
    v7[nil] = v2[v0(nil, nil, 178)][nil](0, 44, 0, 22)
    v7 = v6(259887478)
    v7[nil] = v2[v0(nil, nil, 20)][nil](1, -54, nil, -11)
    v7 = v6(259887478)
    v7[nil] = p3 and v2[v0(nil, nil, 103)][nil](0, 200, 115) or v2[v0(nil, nil, 128)][nil](45, 52, 68)
    v6(259887478)[nil] = 0
    v7 = v2[v0(nil, nil, 127)][nil](v0(nil, nil, 76), v6(259887478))
    v7[nil] = v2[v0(nil, nil, 63)][nil](1, 0)
    v7 = v4(nil, 1, v2[v0(nil, nil, 157)][nil](v0(nil, nil, 209), v6(259887478)))
    local v8_74 = v7(259887478)
    v8_74[nil] = (v2[v0(nil, nil, 204)][nil](0, 16, 0, 16))
    v8_74 = v7(259887478)
    v8_74[nil] = p3 and v2[v0(nil, nil, 51)][nil](1, -19, nil, -8) or v2[v0(nil, nil, 185)][nil](0, 3, nil, -8)
    v8_74 = v7(259887478)
    v8_74[nil] = (v2[v0(nil, nil, 95)][nil](255, 255, 255))
    v7(259887478)[nil] = 0
    v8_74 = v2[v0(nil, nil, 111)][nil](v0(nil, nil, 187), v7(259887478))
    v8_74[nil] = (v2[v0(nil, nil, 102)][nil](1, 0))
    v8_74 = v4(nil, 1, v2[v0(nil, nil, 127)][nil](v0(nil, nil, 1), v4_74(259887478)))
    local v9 = v8_74(259887478)
    v9[nil] = (v2[v0(nil, nil, 95)][nil](1, 0, 1, 0))
    v8_74(259887478)[nil] = 1
    v8_74(259887478)[nil] = nil
    v9 = v4(nil, 1, p3)

    local function v10(p1)
        local v3, v4_191, v5, v6_191, v7_191
        local v1 = v4(nil, 1, v9(259887478) and v2[v0(nil, nil, 204)][nil](0, 200, 115) or v2[v0(nil, nil, 247)][nil](45, 52, 68))
        local v2_191 = v4(nil, 1, v9(259887478) and v2[v0(nil, nil, 250)][nil](1, -19, nil, -8) or v2[v0(nil, nil, 67)][nil](0, 3, nil, -8))
        if p1 then
            v3 = v17[v0(nil, nil, 225)]
            v4_191 = v17
            v5 = v6(259887478)
            v6_191 = v2[v0(nil, nil, 106)][nil](nil, v2[v0(nil, nil, 100)][nil][nil], v2[v0(nil, nil, 177)][nil][nil])
            v7_191 = {}
            v7_191[v0(nil, nil, 96)] = v1(259887478)
            v3 = v3(v4_191, v5, v6_191, v7_191)
            v3[nil](v3)
            v3 = v17[v0(nil, nil, 117)]
            v4_191 = v17
            v5 = v7(259887478)
            v6_191 = v2[v0(nil, nil, 253)][nil](nil, v2[v0(nil, nil, 40)][nil][nil], v2[v0(nil, nil, 67)][nil][nil])
            v7_191 = {}
            v7_191[v0(nil, nil, 122)] = v2_191(259887478)
            v3 = v3(v4_191, v5, v6_191, v7_191)
            v3[nil](v3)
        else
            v6(259887478)[nil] = v1(259887478)
            v7(259887478)[nil] = v2_191(259887478)
        end
    end

    local v11 = v8_74(259887478)[nil]
    v11[nil](v11, function()
        v9[21218222] = not v9(259887478)
        v10(true)
        p4(v9(259887478))
        v8()
    end)

    return v4_74(259887478), function(p1)
        v9[21218222] = p1
        v10(false)
    end
end

local function addWarpOption(p1, p2, p3, p4)
    local v4_76 = v4(nil, 1, v2[v0(nil, nil, 44)][nil](v0(nil, nil, 187), p1))
    local v5 = v4_76(259887478)
    v5[nil] = (v2[v0(nil, nil, 107)][nil](1, 0, 0, 40))
    v4_76(259887478)[nil] = textColor
    v4_76(259887478)[nil] = 0
    v5 = v2[v0(nil, nil, 111)][nil](v0(nil, nil, 28), v4_76(259887478))
    v5[nil] = (v2[v0(nil, nil, 208)][nil](0, 8))
    v5 = v4(nil, 1, v2[v0(nil, nil, 218)][nil](v0(nil, nil, 40), v4_76(259887478)))
    local v6 = v5(259887478)
    v6[nil] = v2[v0(nil, nil, 152)][nil](1, -110, 1, 0)
    v6 = v5(259887478)
    v6[nil] = v2[v0(nil, nil, 118)][nil](0, 12, 0, 0)
    v5(259887478)[nil] = 1
    v5(259887478)[nil] = p2
    v6 = v5(259887478)
    v6[nil] = v2[v0(nil, nil, 106)][nil](220, 225, 235)
    v6 = v5(259887478)
    v6[nil] = v2[v0(nil, nil, 140)][nil][nil]
    v5(259887478)[nil] = 11
    v6 = v5(259887478)
    v6[nil] = v2[v0(nil, nil, 240)][nil][nil]
    v6 = v4(nil, 1, v2[v0(nil, nil, 247)][nil](v0(nil, nil, 137), v4_76(259887478)))
    local v7 = v6(259887478)
    v7[nil] = v2[v0(nil, nil, 27)][nil](0, 95, 0, 26)
    v7 = v6(259887478)
    v7[nil] = v2[v0(nil, nil, 152)][nil](1, -103, nil, -13)
    v7 = v6(259887478)
    v7[nil] = v2[v0(nil, nil, 193)][nil](0, 125, 190)
    v6(259887478)[nil] = p3
    v7 = v6(259887478)
    v7[nil] = v2[v0(nil, nil, 169)][nil](255, 255, 255)
    v7 = v6(259887478)
    v7[nil] = v2[v0(nil, nil, 44)][nil][nil]
    v6(259887478)[nil] = 11
    v6(259887478)[nil] = 0
    v7 = v2[v0(nil, nil, 161)][nil](v0(nil, nil, 230), v6(259887478))
    v7[nil] = v2[v0(nil, nil, 180)][nil](0, 6)
    v7 = v6(259887478)[nil]
    v7[nil](v7, function()
        v6(259887478)[nil] = v0(nil, nil, 139)
        p4()
        v2[v0(nil, nil, 39)][nil](nil)
        v6(259887478)[nil] = p3
    end)

    return v4_76(259887478)
end

local function createStatusText(p1, p2)
    local v2_78 = v4(nil, 1, v2[v0(nil, nil, 247)][nil](v0(nil, nil, 93), p1))
    v2_78(259887478)[nil] = v2[v0(nil, nil, 83)][nil](1, 0, 0, 32)
    v2_78(259887478)[nil] = v2[v0(nil, nil, 159)][nil](17, 21, 29)
    v2_78(259887478)[nil] = 0
    v2[v0(nil, nil, 83)][nil](v0(nil, nil, 231), v2_78(259887478))[nil] = v2[v0(nil, nil, 92)][nil](0, 6)
    local v3 = v4(nil, 1, v2[v0(nil, nil, 236)][nil](v0(nil, nil, 211), v2_78(259887478)))
    v3(259887478)[nil] = v2[v0(nil, nil, 91)][nil](1, -16, 1, 0)
    v3(259887478)[nil] = v2[v0(nil, nil, 137)][nil](0, 8, 0, 0)
    v3(259887478)[nil] = 1
    v3(259887478)[nil] = p2
    v3(259887478)[nil] = v2[v0(nil, nil, 102)][nil](160, 200, 230)
    v3(259887478)[nil] = v2[v0(nil, nil, 244)][nil][nil]
    v3(259887478)[nil] = 11
    v3(259887478)[nil] = v2[v0(nil, nil, 80)][nil][nil]

    return v3(259887478)
end

local dashboardPanel, v105 = createDialog("Dashboard", "🏠", "หน้าหลัก (Home)", 1)
addDialogSection(dashboardPanel, "สถานะตัวละคร & บัญชี (Player Stats)")
local cashText = createStatusText(dashboardPanel, "💰 เงิน (Cash): กำลังโหลด...")
local powerText = createStatusText(dashboardPanel, "⚡ พลัง (Power): กำลังโหลด...")
local rebirthText = createStatusText(dashboardPanel, "🔄 รีเบิร์ธ (Rebirth): กำลังโหลด...")
local staffText = createStatusText(dashboardPanel, "🪄 คทาที่สวมใส่ (Staff): กำลังโหลด...")
local dumbbellText = createStatusText(dashboardPanel, "🏋️ ดัมเบลที่สวมใส่ (Dumbbell): กำลังโหลด...")
local actionText = createStatusText(dashboardPanel, "⚡ การกระทำปัจจุบัน: " .. systemStatusText)
addDialogSection(dashboardPanel, "วาร์ปด่วน (Quick Teleports)")
addWarpOption(dashboardPanel, "วาร์ปไปแปลงฟาร์มของตนเอง", "🚀 ไปที่แปลง", function()
    v2[v0(nil, nil, 195)](function()
        plotService[v0(nil, nil, 38)](plotService)
    end)
end)
addWarpOption(dashboardPanel, "วาร์ปไปหน้าหาดแหวกทะเล (SeaEdge)", "🌊 ไปหน้าหาด", function()
    local v0_80 = v4(nil, 1, localPlayer[nil])
    if v0_80(259887478) and v0_80(259887478)[v0(nil, nil, 150)](v0_80(259887478), v0(nil, nil, 89)) then
        v0_80(259887478)[nil][nil] = v2[v0(nil, nil, 103)][nil](665, 68, 325)
    end
end)
addWarpOption(dashboardPanel, "วาร์ปไปพื้นที่ยิมปั๊มพลัง (Training Area)", "💪 ไปที่ยิม", function()
    local v1, v2_81
    local v0_81 = v4(nil, 1, getDialogValue())
    if v0_81(259887478) then
        v1 = v4(nil, 1, v0_81(259887478)[v0(nil, nil, 143)](v0_81(259887478), v0(nil, nil, 106), true))
        v2_81 = v1(259887478) and localPlayer[nil]
        if v2_81 then
            v2_81 = localPlayer[nil]
            v2_81 = v2_81[nil](v2_81, v0(nil, nil, 69))
        end
        if v2_81 then
            localPlayer[nil][nil][nil] = v1(259887478)[v0(nil, nil, 52)](v1(259887478)) * v2[v0(nil, nil, 98)][nil](0, 3, 0)
        end
    end
end)
local seaFarmPanel = createDialog("SeaFarm", "🌊", "ฟาร์มทะเล (Sea Farm)", 2)
addDialogSection(seaFarmPanel, "ระบบแหวกทะเลอัตโนมัติ 24 ชม.")
addToggleOption(seaFarmPanel, "★ ออโต้ฟาร์มแหวกทะเล 24 ชม. (AutoFarmSea)", v7.AutoFarmSea, function(p1)
    v7[nil] = p1
end)
addToggleOption(seaFarmPanel, "★ วาร์ปไปเก็บไข่ที่ดีที่สุดก่อนเสมอ (CollectBestFirst)", v7.CollectBestFirst, function(p1)
    v7[nil] = p1
end)
addToggleOption(seaFarmPanel, "★ ดูดไข่/สัตว์/ไอเทมรอบตัว (AutoPickup)", v7.AutoPickup, function(p1)
    v7[nil] = p1
end)
addWarpOption(seaFarmPanel, "สั่งเริ่มแหวกทะเลทันที 1 ครั้ง", "🌊 แหวกทะเล", function()
    v2[v0(nil, nil, 86)](function()
        waveController[v0(nil, nil, 136)](waveController, v7[nil])
    end)
end)
addWarpOption(seaFarmPanel, "นำไข่ที่แบกอยู่ส่งกลับแปลงทันที", "📦 ส่งไข่", function()
    local v1
    local v0_86 = v4(nil, 1, localPlayer[nil])
    if v0_86(259887478) and v0_86(259887478)[v0(nil, nil, 50)](v0_86(259887478), v0(nil, nil, 173)) then
        v1 = v0_86(259887478)[nil]
        v1[nil] = (v2[v0(nil, nil, 27)][nil](675, 68, 325))
        v2[v0(nil, nil, 119)][nil](nil)
        v2[v0(nil, nil, 23)](function()
            plotService[v0(nil, nil, 7)](plotService)
        end)
    end
end)
local eggSelectPanel = createDialog("EggSelect", "🎯", "เลือกไข่ (Egg Select)", 3)
addDialogSection(eggSelectPanel, "ตั้งค่าการเลือกเก็บไข่ (Egg Checklist)")
local mutationCallbacks = {}
addWarpOption(eggSelectPanel, "เลือกเก็บไข่ทุกชนิดในเกม", "✅ เลือกทั้งหมด", function()
    for v3, v4 in v2[v0(nil, nil, 120)](v10) do
        v7[nil][v4[nil]] = true
        if mutationCallbacks[v4[nil]] then
            mutationCallbacks[v4[nil]](true)
        end
    end
    v8()
end)
addWarpOption(eggSelectPanel, "ยกเลิกการเลือกไข่ทั้งหมด (เก็บตามความเทพ)", "❌ ยกเลิกทั้งหมด", function()
    for v3, v4 in v2[v0(nil, nil, 53)](v10) do
        v7[nil][v4[nil]] = false
        if mutationCallbacks[v4[nil]] then
            mutationCallbacks[v4[nil]](false)
        end
    end
    v8()
end)
addDialogSection(eggSelectPanel, "รายชื่อไข่ทั้งหมดในเกม (เลือกได้หลายอัน)")
for index2, value3 in ipairs(v10) do
    dialogResult, v123 = addToggleOption(eggSelectPanel, string.format("🥚 %s [%s]", value3.name, value3.rarity), v7.SelectedEggs[value3.id] == true, function(p1)
        v7[nil][value3[nil]] = p1
    end)
    mutationCallbacks[value3.id] = v123
end
local eggsSection = createDialog("Eggs", "🥚", "ฟักไข่ & สัตว์ (Pets)", 4)
addDialogSection(eggsSection, "วางและฟักไข่ (Place & Hatch)")
addToggleOption(eggsSection, "★ วางไข่ลงแปลงอัตโนมัติ (AutoPlaceEgg)", v7.AutoPlaceEgg, function(p1)
    v7[nil] = p1
end)
addToggleOption(eggsSection, "★ ฟักไข่อัตโนมัติเมื่อพร้อม (AutoHatchEgg)", v7.AutoHatchEgg, function(p1)
    v7[nil] = p1
end)
addToggleOption(eggsSection, "★ สวมใส่สัตว์ทำเงินสูงสุด (AutoEquipBest)", v7.AutoEquipBest, function(p1)
    v7[nil] = p1
end)
addToggleOption(eggsSection, "★ เก็บเงินออฟไลน์อัตโนมัติ (AutoOfflineCash)", v7.AutoOfflineCash, function(p1)
    v7[nil] = p1
end)
addDialogSection(eggsSection, "ระบบขายสัตว์เลี้ยง (Auto Sell)")
addToggleOption(eggsSection, "★ ขายสัตว์เลี้ยงอัตโนมัติ (AutoSellPets)", v7.AutoSellPets, function(p1)
    v7[nil] = p1
end)
addWarpOption(eggsSection, "ขายสัตว์ทั้งหมดที่ไม่ได้รับการปกป้อง", "💰 ขายทันที", function()
    local v5, v8, v9, v11, v12
    local v1 = getDialogResult()[nil] or {}
    local v2_95 = {}
    for v6, v7_95 in v2[v0(nil, nil, 26)](v1) do
        v5 = v6
        v8 = v7_95[nil]
        v9 = v7_95[nil] or v0(nil, nil, 120)
        v11 = (hiddenGui[nil][v8] or {})[nil] or v0(nil, nil, 223)
        v12 = false
        if v7[nil] and v9 ~= v0(nil, nil, 179) then
            v12 = true
        end
        if v7[nil] and v7[nil][v11] then
            v12 = true
        end
        if not v12 then
            v2[v0(nil, nil, 51)][nil](v2_95, v5)
        end
    end
    if #v2_95 > 0 then
        v2[v0(nil, nil, 59)](function()
            inventoryService[v0(nil, nil, 69)](inventoryService, v2_95)
        end)
    end
end)
local filtersSection = createDialog("Filters", "🔍", "ระบบกรอง (Filters)", 5)
addDialogSection(filtersSection, "ระบบล็อคป้องกันไม่ให้ขาย (Protection)")
addToggleOption(filtersSection, "★ ป้องกันสัตว์มี Mutation ทุกชนิด (ทอง/เพชร/รุ้ง/ฯลฯ)", v7.FilterProtectMutations, function(p1)
    v7[nil] = p1
end)
addToggleOption(filtersSection, "★ ป้องกันสัตว์ระดับสูง (Legendary, Mythic, SECRET)", v7.FilterProtectRarities, function(p1)
    v7[nil] = p1
end)
addDialogSection(filtersSection, "เลือกป้องกันตาม Mutation เฉพาะตัว")
addToggleOption(filtersSection, "🛡️ ป้องกัน Mutation: GOLD (สีทอง)", v7.ProtectedMutations.GOLD or false, function(p1)
    v7[nil][v0(nil, nil, 94)] = p1
end)
addToggleOption(filtersSection, "🛡️ ป้องกัน Mutation: DIAMOND (เพชร)", v7.ProtectedMutations.DIAMOND or false, function(p1)
    v7[nil][v0(nil, nil, 143)] = p1
end)
addToggleOption(filtersSection, "🛡️ ป้องกัน Mutation: RAINBOW (สีรุ้ง)", v7.ProtectedMutations.RAINBOW or false, function(p1)
    v7[nil][v0(nil, nil, 33)] = p1
end)
addToggleOption(filtersSection, "🛡️ ป้องกัน Mutation: RADIOACTIVE (กัมมันตรังสี)", v7.ProtectedMutations.RADIOACTIVE or false, function(p1)
    v7[nil][v0(nil, nil, 138)] = p1
end)
local gymSection = v4("1", 1, createDialog("Gym", "💪", "ยิม & อุปกรณ์ (Gym)", 6))
addDialogSection(gymSection(259887478), "ปั๊มพลังในยิม (Gym Training)")
addToggleOption(gymSection(259887478), "★ วาร์ปปั๊ม Power อัตโนมัติ (AutoGymTrain)", v7.AutoGymTrain, function(p1)
    v7[nil] = p1
end)
addToggleOption(gymSection(259887478), "★ เก็บโบนัสคูณ x2 ทันที (AutoClaimBonus)", v7.AutoClaimBonus, function(p1)
    v7[nil] = p1
end)
addDialogSection(gymSection(259887478), "ดัมเบล & คทา (Dumbbell & Staff)")
addToggleOption(gymSection(259887478), "★ ซื้อดัมเบลที่ดีที่สุดอัตโนมัติ (AutoBuyDumbbell)", v7.AutoBuyDumbbell, function(p1)
    v7[nil] = p1
end)
addToggleOption(gymSection(259887478), "★ สวมใส่ดัมเบลที่ดีที่สุดอัตโนมัติ (AutoEquipDumbbell)", v7.AutoEquipDumbbell, function(p1)
    v7[nil] = p1
end)
addToggleOption(gymSection(259887478), "★ ซื้อคทาที่ดีที่สุดอัตโนมัติ (AutoBuyStaff)", v7.AutoBuyStaff, function(p1)
    v7[nil] = p1
end)
addToggleOption(gymSection(259887478), "★ สวมใส่คทาที่ดีที่สุดอัตโนมัติ (AutoEquipStaff)", v7.AutoEquipStaff, function(p1)
    v7[nil] = p1
end)
local baseSection = createDialog("Base", "🏰", "รีเบิร์ธ & ฐาน (Base)", 7)
addDialogSection(baseSection, "รีเบิร์ธ & ขยายขนาดแปลง")
addToggleOption(baseSection, "★ รีเบิร์ธอัตโนมัติเมื่อเงินครบ (AutoRebirth)", v7.AutoRebirth, function(p1)
    v7[nil] = p1
end)
addToggleOption(baseSection, "★ ขยายขนาดแปลงฟาร์มสัตว์ (AutoUpgradeBase)", v7.AutoUpgradeBase, function(p1)
    v7[nil] = p1
end)
addToggleOption(baseSection, "★ อัปเกรดความจุแบกไข่ (AutoUpgradeCarry)", v7.AutoUpgradeCarry, function(p1)
    v7[nil] = p1
end)
addToggleOption(baseSection, "★ อัปเกรดความเร็วตัวละคร (AutoUpgradeSpeed)", v7.AutoUpgradeSpeed, function(p1)
    v7[nil] = p1
end)
local rewardsSection = v4("1", 1, createDialog("Rewards", "🎁", "ของรางวัล (Rewards)", 8))
addDialogSection(rewardsSection(259887478), "เคลมของขวัญ & วงล้อฟรี")
addToggleOption(rewardsSection(259887478), "★ รับของขวัญออนไลน์ Playtime 1-12 (AutoClaimPlaytime)", v7.AutoClaimPlaytime, function(p1)
    v7[nil] = p1
end)
addToggleOption(rewardsSection(259887478), "★ รับรางวัลประจำวัน & กล่องฟรี (AutoClaimDaily)", v7.AutoClaimDaily, function(p1)
    v7[nil] = p1
end)
addToggleOption(rewardsSection(259887478), "★ หมุนวงล้อเสี่ยงโชคฟรี (AutoLuckyWheel)", v7.AutoLuckyWheel, function(p1)
    v7[nil] = p1
end)
addToggleOption(rewardsSection(259887478), "★ รับของขวัญกลุ่ม Roblox Group (AutoClaimGroup)", v7.AutoClaimGroup, function(p1)
    v7[nil] = p1
end)
addToggleOption(rewardsSection(259887478), "★ รับของฟรีจากร้านค้า Free Shop (AutoClaimFreeShop)", v7.AutoClaimFreeShop, function(p1)
    v7[nil] = p1
end)
addDialogSection(rewardsSection(259887478), "ซีซั่นพาส & เควสต์ & โพชั่น")
addToggleOption(rewardsSection(259887478), "★ เคลมรางวัล Season Pass ทุกขั้น (AutoClaimPass)", v7.AutoClaimPass, function(p1)
    v7[nil] = p1
end)
addToggleOption(rewardsSection(259887478), "★ เคลมเควสต์รายชั่วโมง/ซีซั่น (AutoClaimQuests)", v7.AutoClaimQuests, function(p1)
    v7[nil] = p1
end)
addToggleOption(rewardsSection(259887478), "★ กดใช้โพชั่น Luck/Train/Cash ต่อเนื่อง (AutoPotions)", v7.AutoPotions, function(p1)
    v7[nil] = p1
end)
addWarpOption(rewardsSection(259887478), "แลกรับโค้ดแจกของฟรีทั้งหมดทันที", "🎟️ แลกโค้ดทั้งหมด", function()
    getDialogCallback()
end)
local settingsSection = createDialog("Settings", "⚙️", "ตั้งค่า (Settings)", 9)
addDialogSection(settingsSection, "เพิ่มประสิทธิภาพ & เปิดหลายจอ (Performance)")
addToggleOption(settingsSection, "★ โหมดลื่นพิเศษ / ลดเงาและหมอก (PerformanceMode)", v7.PerformanceMode, function(p1)
    v7[nil] = p1
    antiAfkService()
end)
addToggleOption(settingsSection, "★ ปิดจอภาพ 3D ลดโหลด GPU 90% (Disable3DRender)", v7.Disable3DRender, function(p1)
    v7[nil] = p1
    antiAfkService()
end)
addToggleOption(settingsSection, "★ ป้องกันการเด้งหลุด 20 นาที (AntiAFK)", v7.AntiAFK, function(p1)
    v7[nil] = p1
end)
addToggleOption(settingsSection, "★ เซฟการตั้งค่าอัตโนมัติ (AutoSaveConfig)", v7.AutoSaveConfig, function(p1)
    v7[nil] = p1
end)
addDialogSection(settingsSection, "ระบบบันทึกไฟล์ (Config Files)")
addWarpOption(settingsSection, "บันทึกการตั้งค่าลงไฟล์ทันที", "💾 บันทึก", function()
    v8()
end)
addWarpOption(settingsSection, "โหลดการตั้งค่าจากไฟล์", "📂 โหลดซ้ำ", function()
    v9()
end)
v105()
task.spawn(function()
    while true do
        v2[v0(nil, nil, 131)][nil](1)
        v2[v0(nil, nil, 232)](function()
            local v0_201 = getDialogResult()
            local v1 = v0_201[nil] and v0_201[nil][nil] or 0
            local v2_201 = v0_201[nil] or 0
            local v3 = v0_201[nil] or 0
            local v4 = v0_201[nil] or v0(nil, nil, 129)
            local v5 = v0_201[nil] or v0(nil, nil, 83)
            cashText[nil] = v2[v0(nil, nil, 202)][nil](v0(nil, nil, 21), dialogCallback(v1))
            powerText[nil] = v2[v0(nil, nil, 111)][nil](v0(nil, nil, 224), dialogCallback(v2_201))
            rebirthText[nil] = v2[v0(nil, nil, 22)][nil](v0(nil, nil, 136), v3)
            staffText[nil] = v2[v0(nil, nil, 214)][nil](v0(nil, nil, 75), v2[v0(nil, nil, 211)](v4))
            dumbbellText[nil] = v2[v0(nil, nil, 137)][nil](v0(nil, nil, 77), v2[v0(nil, nil, 29)](v5))
            actionText[nil] = v0(nil, nil, 171) .. systemStatusText
        end)
    end
end)
pcall(function()
    local v1 = (v2[v0(nil, nil, 84)][v0(nil, nil, 148)](v2[v0(nil, nil, 19)], v0(nil, nil, 78)))
    local v0_128 = v1[nil]
    local v2_128 = v0(nil, nil, 96)
    local v3 = {}
    v3[v0(nil, nil, 79)] = v0(nil, nil, 218)
    v3[v0(nil, nil, 228)] = v0(nil, nil, 20)
    v3[v0(nil, nil, 177)] = 6
    v0_128(v1, v2_128, v3)
end)
print("[เนตรนารี ฮัฟฟู๊วว 🌊] Open Sea For Animals V1.1 Loaded Successfully! (Minimized on Startup)")
