--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                    MARU HUB  v6.0.0                           ║
    ║   UI     : Modern Neon Glassmorphism                          ║
    ║   Theme  : Neon Gradient + Glassmorphism + Smooth Motion      ║
    ║   Engine : Automation, Astral, Ember Infinity, Race, Potion   ║
    ╚═══════════════════════════════════════════════════════════════╝
]]

-- ─────────────────────────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────────────────────────
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local VirtualUser       = game:GetService("VirtualUser")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local GuiService        = game:GetService("GuiService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local RemoteRoot  = ReplicatedStorage:WaitForChild("Remote", 15)

-- ─────────────────────────────────────────────────────────────
-- Debug & Notify
-- ─────────────────────────────────────────────────────────────
local CurrentWindow = nil
local function notify(title, content, icon)
    if CurrentWindow and CurrentWindow.Notify then
        pcall(function() CurrentWindow:Notify(tostring(title), tostring(content)) end)
    else
        print(string.format("[Maru Hub] %s: %s", tostring(title), tostring(content)))
    end
end

local function MARU_DEBUG(msg, popup)
    msg = tostring(msg)
    print("[Maru Hub] " .. msg)
    if popup then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Maru Hub", Text = msg:sub(1, 200), Duration = 15
            })
        end)
    end
end
MARU_DEBUG("script started")

-- ─────────────────────────────────────────────────────────────
-- Optional Game Data Modules
-- ─────────────────────────────────────────────────────────────
local BackpackData, OreHelper, WeaponHelper, ArmorHelper, EnchStoneHelper = nil, nil, nil, nil, nil
local EnhantHelper, TrainCTRL = nil, nil
pcall(function() BackpackData = require(ReplicatedStorage.LocalData.BackpackData) end)
pcall(function() OreHelper = require(ReplicatedStorage.Config.Ore.Helper) end)
pcall(function() WeaponHelper = require(ReplicatedStorage.Config.Weapon.Helper) end)
pcall(function() ArmorHelper = require(ReplicatedStorage.Config.Armor.Helper) end)
pcall(function() EnchStoneHelper = require(ReplicatedStorage.Config.EnchStone.Helper) end)
pcall(function() EnhantHelper = require(ReplicatedStorage.Config.Enhant.Helper) end)
pcall(function() TrainCTRL = require(ReplicatedStorage.CTRL.TrainCTRL) end)

local EnemyCTRL, HPCTRL, CommunicationUtils, Bindable_EnemyHit = nil, nil, nil, nil
pcall(function() EnemyCTRL = require(ReplicatedStorage.CTRL.EnemyCTRL) end)
pcall(function() HPCTRL = require(ReplicatedStorage.CTRL.HPCTRL) end)
pcall(function()
    CommunicationUtils = require(ReplicatedStorage.Utils.CommunicationUtils)
    if CommunicationUtils and CommunicationUtils.TryGetBindableEvent then
        Bindable_EnemyHit = CommunicationUtils.TryGetBindableEvent("Attack", "EnemyHitBE")
    end
end)

local ProfileData = nil
pcall(function() ProfileData = require(ReplicatedStorage.ProfileData) end)
local MarketplaceService = game:GetService("MarketplaceService")

-- ─────────────────────────────────────────────────────────────
-- GamePass Bypass
-- ─────────────────────────────────────────────────────────────
local GamePassMap = {
    [1962630901] = "VIP",
    [1963566878] = "SuperLuck",
    [1965960643] = "CommonLuck",
    [1963764856] = "MoreOre",
    [1982474360] = "UltraLuck",
    [1962564854] = "SkipForge",
}
local ExtraPremiumKeys = { "AutoTrainArea_9", "AutoTrainArea_10", "AutoTrainArea_11" }

local function applyGamePassBypass()
    pcall(function()
        local pemStore = ProfileData and ProfileData.GetStoreData and ProfileData.GetStoreData("Pem")
        if pemStore and type(pemStore) == "table" then
            for _, pemKey in pairs(GamePassMap) do pemStore[pemKey] = true end
            for _, key in ipairs(ExtraPremiumKeys) do pemStore[key] = true end
        end
    end)
    if hookmetamethod and newcclosure and getnamecallmethod then
        pcall(function()
            local oldNC
            oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if self == MarketplaceService and method == "UserOwnsGamePassAsync" then
                    local args = {...}
                    local gpId = args[2] or args[1]
                    if type(gpId) == "number" and GamePassMap[gpId] then return true end
                end
                return oldNC(self, ...)
            end))
        end)
    end
    pcall(function()
        local Shop = require(ReplicatedStorage.GuiUtils.Shop)
        if Shop then
            if Shop.updateGamePass then Shop.updateGamePass() end
            if Shop.updateTrainArea then Shop.updateTrainArea() end
        end
    end)
end
pcall(applyGamePassBypass)

-- ─────────────────────────────────────────────────────────────
-- Train Area Configuration
-- ─────────────────────────────────────────────────────────────
local TRAIN_AUTO_BEST = "Auto Best (แท่นคูณสูงสุดที่ปลดล็อค)"
local TrainAreaConfig = {
    { Id = 1,  Name = "Train_1 (x1.5 Power | Rebirth 0)",  Rebirth = 0,  Mult = 1.5, PadPos = Vector3.new(-53.0, 3.0, -41.0),   DummyPos = Vector3.new(-57.88, 6.94, -41.04), FallbackPos = Vector3.new(-52.96, 7.25, -40.66) },
    { Id = 2,  Name = "Train_2 (x2 Power | Rebirth 2)",    Rebirth = 2,  Mult = 2,   PadPos = Vector3.new(-53.0, 3.0, -20.9),   DummyPos = Vector3.new(-57.88, 6.94, -20.91), FallbackPos = Vector3.new(-52.96, 7.25, -20.84) },
    { Id = 3,  Name = "Train_3 (x4 Power | Rebirth 5)",    Rebirth = 5,  Mult = 4,   PadPos = Vector3.new(-53.0, 3.0, 21.4),    DummyPos = Vector3.new(-57.88, 6.94, 21.37), FallbackPos = Vector3.new(-52.96, 7.25, 21.21) },
    { Id = 4,  Name = "Train_4 (x6 Power | Rebirth 9)",    Rebirth = 9,  Mult = 6,   PadPos = Vector3.new(-53.0, 3.0, 43.25),   DummyPos = Vector3.new(-57.88, 6.94, 43.25), FallbackPos = Vector3.new(-52.96, 7.25, 42.82) },
    { Id = 5,  Name = "Train_5 (x8 Power | Rebirth 12)",   Rebirth = 12, Mult = 8,   PadPos = Vector3.new(-80.0, 8.6, 21.29),   DummyPos = Vector3.new(-84.50, 8.61, 21.29), FallbackPos = Vector3.new(-79.64, 10.14, 21.07) },
    { Id = 6,  Name = "Train_6 (x10 Power | Rebirth 15)",  Rebirth = 15, Mult = 10,  PadPos = Vector3.new(-80.0, 9.1, -20.90),  DummyPos = Vector3.new(-83.92, 9.11, -20.90), FallbackPos = Vector3.new(-79.64, 10.14, -20.78) },
    { Id = 7,  Name = "Train_7 (x15 Power | Rebirth 18)",  Rebirth = 18, Mult = 15,  PadPos = Vector3.new(-108.0, 12.7, 32.24), DummyPos = Vector3.new(-114.22, 12.73, 32.24), FallbackPos = Vector3.new(-106.92, 11.55, 31.77) },
    { Id = 8,  Name = "Train_8 (x25 Power | Rebirth 21)",  Rebirth = 21, Mult = 25,  PadPos = Vector3.new(-106.0, 10.6, -31.00),DummyPos = Vector3.new(-110.27, 10.63, -30.99), FallbackPos = Vector3.new(-105.94, 11.53, -30.69) },
    { Id = 9,  Name = "Train_9 (x100 VIP | Rebirth 0)",   Rebirth = 0,  Mult = 100, IsPay = true, PadPos = Vector3.new(-104.29, 11.75, 0.31), DummyPos = Vector3.new(-125.79, 11.29, 0.35), FallbackPos = Vector3.new(-104.29, 11.75, 0.31) },
    { Id = 10, Name = "Train_10 (x10 VIP | Rebirth 0)",  Rebirth = 0,  Mult = 10,  IsPay = true, PadPos = Vector3.new(-79.06, 11.75, 42.68), DummyPos = Vector3.new(-80.04, 11.65, 43.36), FallbackPos = Vector3.new(-79.06, 11.75, 42.68) },
    { Id = 11, Name = "Train_11 (x20 VIP | Rebirth 0)",  Rebirth = 0,  Mult = 20,  IsPay = true, PadPos = Vector3.new(-78.89, 11.75, -41.02), DummyPos = Vector3.new(-80.04, 11.65, -40.44), FallbackPos = Vector3.new(-78.89, 11.75, -41.02) },
}

local function getTrainZonePart(zoneId)
    local part = nil
    pcall(function()
        if workspace:FindFirstChild("TOUCHED") then
            local ata = workspace.TOUCHED:FindFirstChild("AutoTrainArea")
            if ata then part = ata:FindFirstChild(tostring(zoneId)) end
        end
        if not part then
            local caf = workspace:FindFirstChild("CanAttackFolder")
            if caf then
                local ta = caf:FindFirstChild("TrainArea")
                if ta then
                    part = ta:FindFirstChild("Train_" .. tostring(zoneId))
                        or ta:FindFirstChild(tostring(zoneId))
                end
            end
        end
    end)
    return part
end

local function getBestLegitTrainZone()
    local curReb = 0
    pcall(function()
        if LocalPlayer:FindFirstChild("Eco") then
            local eco = LocalPlayer.Eco
            local rb = eco:FindFirstChild("rebirth") or eco:FindFirstChild("Rebirth")
            if rb then curReb = tonumber(rb.Value) or 0 end
        end
    end)
    if curReb == 0 then
        pcall(function()
            local pd = ProfileData and ProfileData.GetTotalData and ProfileData.GetTotalData()
            if pd and pd.Eco then
                curReb = tonumber(pd.Eco.rebirth) or tonumber(pd.Eco.Rebirth) or 0
            end
        end)
    end
    if curReb == 0 then
        pcall(function()
            curReb = tonumber(LocalPlayer:GetAttribute("Rebirth"))
                or tonumber(LocalPlayer:GetAttribute("rebirth")) or 0
        end)
    end
    local best = TrainAreaConfig[1]
    for _, z in ipairs(TrainAreaConfig) do
        if not z.IsPay and curReb >= z.Rebirth then
            if z.Mult >= best.Mult then best = z end
        end
    end
    return best
end

local function getBestTrainZone(forceVIP)
    if forceVIP or (State and State.ForceVIPTrain) then
        for _, z in ipairs(TrainAreaConfig) do
            if z.Id == 9 then return z end
        end
    end
    local canUseVIP = false
    pcall(function()
        local Shop = require(ReplicatedStorage.GuiUtils.Shop)
        if Shop and type(Shop.isOwnPass) == "function" then
            canUseVIP = Shop.isOwnPass("TrainArea") or Shop.isOwnPass(1)
        end
    end)
    if canUseVIP then
        for _, z in ipairs(TrainAreaConfig) do
            if z.Id == 9 then return z end
        end
    end
    return getBestLegitTrainZone()
end

local function getZoneByName(name)
    for _, z in ipairs(TrainAreaConfig) do
        if z.Name == name or tostring(z.Id) == tostring(name) then return z end
    end
    return nil
end

local function getTrainZoneNames()
    local list = { TRAIN_AUTO_BEST }
    for _, z in ipairs(TrainAreaConfig) do table.insert(list, z.Name) end
    return list
end

-- ─────────────────────────────────────────────────────────────
-- Dynamic Discovery
-- ─────────────────────────────────────────────────────────────
local Dynamic = {
    Stages          = {},
    TrainAreas      = {},
    Classes         = {},
    Potions         = {},
    SuperLootTiers  = { "All", "Legendary", "Eternal", "Secret" },
}

pcall(function()
    local sh = require(ReplicatedStorage.Config.Stage.Helper)
    for k in pairs(sh.GetStageEnemyConfig()) do table.insert(Dynamic.Stages, k) end
    table.sort(Dynamic.Stages, function(a, b)
        return (tonumber(a:match("%d+")) or 0) < (tonumber(b:match("%d+")) or 0)
    end)
end)
if #Dynamic.Stages == 0 then
    for i = 1, 30 do table.insert(Dynamic.Stages, "Stage_" .. i) end
end
table.insert(Dynamic.Stages, 1, "Auto Max (ด่านสูงสุดที่ผ่านได้)")

local State
local function getTargetStageId()
    local selected = State.SelectedStage or "Auto Max"
    if selected:find("Auto Max") then
        local maxPass = 0
        pcall(function()
            local pd = ProfileData and ProfileData.GetTotalData and ProfileData.GetTotalData()
            maxPass = pd and pd.Stats and tonumber(pd.Stats.StagePass) or 0
        end)
        local targetNum = math.clamp(maxPass + 1, 1, math.max(#Dynamic.Stages - 1, 30))
        return "Stage_" .. tostring(targetNum), targetNum
    else
        local clean = selected:match("Stage_%d+") or selected
        local num = tonumber(clean:match("%d+")) or 1
        return clean, num
    end
end

pcall(function()
    local ch = require(ReplicatedStorage.Config.Class.Helper)
    for k in pairs(ch.GetConfig()) do table.insert(Dynamic.Classes, k) end
    table.sort(Dynamic.Classes, function(a, b)
        return (tonumber(a:match("%d+")) or 0) < (tonumber(b:match("%d+")) or 0)
    end)
end)
if #Dynamic.Classes == 0 then
    for i = 1, 10 do table.insert(Dynamic.Classes, "Class_" .. i) end
end

pcall(function()
    local ph = require(ReplicatedStorage.Config.Potion.Helper)
    for k in pairs(ph.GetConfig()) do table.insert(Dynamic.Potions, k) end
end)
if #Dynamic.Potions == 0 then
    Dynamic.Potions = { "DamagePotion", "TrainPotion", "CoinPotion", "LuckPotion", "HPPotion" }
end

pcall(function()
    local slh = require(ReplicatedStorage.Config.SuperLoot.Helper)
    for k in pairs(slh.GetConfig()) do
        if not table.find(Dynamic.SuperLootTiers, k) then
            table.insert(Dynamic.SuperLootTiers, k)
        end
    end
end)

-- ─────────────────────────────────────────────────────────────
-- Global State
-- ─────────────────────────────────────────────────────────────
State = {
    Language            = "TH",
    Master247           = false,
    MasterDungeonTicket = true,
    MasterTrainWhenIdle = true,
    MasterAutoForgeWhenReady = true,
    MasterAutoUpgrade   = true,
    MasterStageBlitz    = true,
    MasterAutoClickSword = true,
    AlgorithmicDPSSolver = true,
    DropMagnet          = false,
    MagnetTarget        = "Safe Zone",
    MagnetInterval      = 0.15,
    UltraPrompt         = false,
    AutoSafeEvacuate    = false,
    EvacuateThreshold   = 90,
    LowHPEvacuate       = false,
    LowHPThreshold      = 25,
    AutoDungeon         = false,
    DungeonRound        = 1,
    AutoClaimTicket     = true,
    DungeonInstaKill    = true,
    AutoStage           = false,
    SelectedStage       = Dynamic.Stages[1] or "Stage_1",
    AutoClimbStages     = false,
    StageClimbTimeout   = 25,
    StageInstaKill      = true,
    AutoTrainBestZone   = false,
    GodFarmStageBlitz   = false,
    StageBlitzInterval  = 0.09,
    KillAura            = false,
    KillAuraDelay       = 0.15,
    SafeCombatFlight    = false,
    FlightHeight        = 14,
    GodMode             = false,
    SuperLootHunter     = false,
    SuperLootTargetTier = "All",
    SuperLootNotify     = true,
    AutoTrain           = false,
    TrainDelay          = 0.15,
    TrainArea           = "1",
    SelectedTrainZone   = TRAIN_AUTO_BEST,
    AutoTrainMode       = false,
    AutoClickSword      = false,
    SwordClickDelay     = 0.16,
    RemoteOnlyTrain     = false,
    ForceVIPTrain       = false,
    MasterConcurrentForge = true,
    AutoUpgrade         = false,
    UpgradeType         = "All in One",
    UpgradeDelay        = 1.5,
    AutoRebirth         = false,
    RebirthDelay        = 10,
    NativeAutoRebirth   = false,
    AutoForge           = false,
    ForgeDelay          = 1.0,
    ForgeType           = "All",
    MinOreToForge       = 4,
    OreQualityMode      = "Any",
    AutoEquipBest       = false,
    AutoSellTrashGear   = false,
    MinGearRarityToKeep = "Legendary",
    AutoSellOres        = false,
    OreRaritiesToKeep   = { "Infinite", "Ancient", "Secret", "Eternal", "Mythic", "Legendary" },
    KeepMinOreAmount    = 0,
    AutoSellEnchantStones = false,
    EnchantFilterMode   = "Sell Selected",
    EnchantRaritiesToTarget = { "Common", "Uncommon", "Rare" },
    KeepMinStoneAmount  = 0,
    AutoEquipBestPet    = false,
    PetEquipDelay       = 3.0,
    AntiTrip            = false,
    AutoReconnect       = false,
    RedeemedCodes       = {},
    AutoEnhance         = false,
    EnhanceDelay        = 1.5,
    AutoEnchant         = false,
    EnchantDelay        = 1.5,
    EnchantMaxGrade     = "Mythic",
    EnchantKeepHighGrade = true,
    EnchantSlots        = "All",
    AutoSell            = false,
    SellDelay           = 8,
    AutoRollClass       = false,
    TargetClassToLock   = Dynamic.Classes[#Dynamic.Classes] or "Class_9",
    RollClassDelay      = 1.5,
    TargetClassStar     = 0,
    ClassStarHigher     = 0,
    AutoRollSkills      = false,
    RollSkillDelay      = 2.0,
    AutoHatchEggs       = false,
    HatchEggDelay       = 2.0,
    AutoUsePotions      = false,
    PotionDelay         = 8.0,
    AutoClaimRewards    = false,
    ClaimDelay          = 60,
    WebhookEnabled      = false,
    WebhookUrl          = "",
    NotifyRareDrops     = true,
    NotifySuperLoot     = true,
    NotifyHourlyReport  = true,
    NotifyRebirth       = false,
    WalkSpeed           = 16,
    JumpPower           = 50,
    InfJump             = false,
    Noclip              = false,
    AntiAFK             = true,
    CpuSaver            = false,
    AutoSaveConfig      = true,
    Debug               = false,
}

-- ─────────────────────────────────────────────────────────────
-- Stats
-- ─────────────────────────────────────────────────────────────
local Stats = {
    StartTime       = os.time(),
    OresCollected   = 0,
    SellCycles      = 0,
    Kills           = 0,
    RebirthCount    = 0,
    SuperLootKills  = 0,
    CurrentActivity = "System Ready",
    LastStageClear  = os.time(),
    LastHourlyPost  = os.time(),
}

-- ─────────────────────────────────────────────────────────────
-- Networking Helpers
-- ─────────────────────────────────────────────────────────────
local function getRemote(folder, name)
    if not RemoteRoot then return nil end
    local f = RemoteRoot:FindFirstChild(folder .. "_Server") or RemoteRoot:FindFirstChild(folder)
    local r = f and f:FindFirstChild(name) or nil
    if r then return r end
    for _, d in ipairs(RemoteRoot:GetDescendants()) do
        if d.Name == name and (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) then
            return d
        end
    end
    return nil
end

local function call(folder, name, ...)
    local r = getRemote(folder, name)
    if not r then return nil end
    local args = { ... }
    local ok, res = pcall(function()
        if r:IsA("RemoteFunction") then
            return r:InvokeServer(unpack(args))
        else
            r:FireServer(unpack(args))
        end
    end)
    return ok and res or nil
end

local function char() return LocalPlayer.Character end
local function hrp()  local c = char(); return c and c:FindFirstChild("HumanoidRootPart") end
local function hum()  local c = char(); return c and c:FindFirstChildOfClass("Humanoid") end

local function getSafeZoneCF()
    local spawn = workspace:FindFirstChild("SpawnLocation")
    if spawn then
        if spawn:IsA("Model") then return spawn:GetPivot() end
        if spawn:IsA("BasePart") then return spawn.CFrame end
    end
    local spawnObj = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    if spawnObj then return spawnObj.CFrame end
    return CFrame.new(0, 5, 0)
end

local function tpTo(cf)
    local r = hrp()
    if r then
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
        r.CFrame = cf + Vector3.new(0, 3, 0)
    end
end

local function getPackInfo()
    local cur, maxNum = 0, 10
    pcall(function()
        local LeftInfoGUI = require(ReplicatedStorage.GuiUtils.LeftInfoGUI)
        cur = LeftInfoGUI.GetOrePack() or 0
    end)
    pcall(function()
        local UpgradeData = require(ReplicatedStorage.LocalData.UpgradeData)
        maxNum = UpgradeData.GetMaxNum("OrePack") or 10
    end)
    return cur, maxNum
end

local function getBackpackItems()
    if not BackpackData or type(BackpackData.GetData) ~= "function" then return nil end
    local ok, data = pcall(BackpackData.GetData)
    return ok and type(data) == "table" and type(data.have) == "table" and data.have or nil
end

-- ─────────────────────────────────────────────────────────────
-- DPS Solver
-- ─────────────────────────────────────────────────────────────
local function calculateEffectiveDPS(item)
    if type(item) ~= "table" or item.ID == nil then return 0 end
    local slot = item.Type or "Weapon"
    local id = item.ID or ""
    local baseTrain = 1
    local usePower = 1
    pcall(function()
        if slot == "Weapon" and WeaponHelper and WeaponHelper.GetConfig then
            local cfg = WeaponHelper.GetConfig(id)
            if cfg then
                baseTrain = tonumber(cfg.Train) or 1
                usePower = tonumber(cfg.UsePower) or 1
            end
        elseif (slot == "Armor" or slot == "Hat") and ArmorHelper and ArmorHelper.GetConfig then
            local cfg = ArmorHelper.GetConfig(id)
            if cfg then
                baseTrain = tonumber(cfg.BaseWeight or cfg.Train) or 1
                usePower = tonumber(cfg.UsePower) or 1
            end
        end
    end)
    local enhLevel = tonumber(item.EnchanceNum or item.EnhanceNum) or 0
    local enhBoost = 0
    pcall(function()
        local eh = EnhantHelper or require(ReplicatedStorage.Config.Enhant.Helper)
        if eh and eh.GetBoost then
            enhBoost = eh.GetBoost(enhLevel) or 0
        end
    end)
    local totalCritRate = 0
    local totalCritDmg = 1.0
    local damageInterval = 0.5
    pcall(function()
        local sh = EnchStoneHelper or require(ReplicatedStorage.Config.EnchStone.Helper)
        if sh and item.EnchanceList and type(item.EnchanceList) == "table" then
            for _, stoneId in ipairs(item.EnchanceList) do
                local sc = sh.GetStoneConfig(stoneId)
                if sc then
                    totalCritRate = totalCritRate + (tonumber(sc.BoomPercent) or 0)
                    totalCritDmg = totalCritDmg + (tonumber(sc.BoomValue) or 0)
                    if sc.DamageInterval and tonumber(sc.DamageInterval) < damageInterval then
                        damageInterval = tonumber(sc.DamageInterval)
                    end
                end
            end
        end
    end)
    local affixBonus = 1.0
    if item.MainAffix and type(item.MainAffix) == "table" then
        local num = tonumber(item.MainAffix.Number) or 0
        affixBonus = affixBonus + (num * 0.05)
    end
    if item.Affix and type(item.Affix) == "table" then
        for _, sub in ipairs(item.Affix) do
            if type(sub) == "table" and sub.Number then
                affixBonus = affixBonus + (tonumber(sub.Number) or 0) * 0.03
            end
        end
    end
    local dps = (baseTrain * usePower * (1 + enhBoost) * affixBonus)
        * (1 + (totalCritRate * totalCritDmg))
        * (1 / math.max(damageInterval, 0.1))
    return dps
end

local function itemGearScore(item)
    if State.AlgorithmicDPSSolver then
        return calculateEffectiveDPS(item)
    end
    if type(item) ~= "table" or item.ID == nil then return 0 end
    local designPower = 0
    local helper = item.Type == "Weapon" and WeaponHelper or ArmorHelper
    if helper and type(helper.GetDesignPower) == "function" then
        pcall(function() designPower = tonumber(helper.GetDesignPower(item.ID)) or 0 end)
    end
    local rarityValue = item.RarityLevel or item.Rarity or item.RareLevel
    local rarity = tonumber(rarityValue) or 0
    if rarity == 0 and type(rarityValue) == "string" then
        local ranks = {
            Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5,
            Mythic = 6, Eternal = 7, Secret = 8, Ancient = 9, Infinite = 10, Exclusive = 11,
        }
        rarity = ranks[rarityValue] or 0
    end
    local affix = type(item.MainAffix) == "table" and tonumber(item.MainAffix.Number) or 0
    local enhancement = tonumber(item.EnchanceNum or item.EnhanceNum) or 0
    return rarity * 1000000000 + designPower * 100000 + (affix or 0) + enhancement * 10
end

-- ═════════════════════════════════════════════════════════════
--  RACE ROLL
-- ═════════════════════════════════════════════════════════════
getgenv().maruRaceRoll = false

local function startRaceRoll()
    if getgenv().maruRaceRoll then return end
    getgenv().maruRaceRoll = true

    task.spawn(function()
        local Event
        local ok = pcall(function()
            Event = ReplicatedStorage:WaitForChild("Remote", 10)
                :WaitForChild("UpdateLog_Server", 10)
                :WaitForChild("TryClaimUPDRewardRE", 10)
        end)
        if not ok or not Event then
            getgenv().maruRaceRoll = false
            notify("Race Roll", "ไม่พบ Remote TryClaimUPDRewardRE", "alert")
            return
        end

        local targetRewards = { "4", "5", "6" }
        notify("Race Roll", "⚡ เปิดระบบเสกที่รีเผ่าแล้ว", "zap")

        while getgenv().maruRaceRoll do
            for _, rewardNumber in ipairs(targetRewards) do
                if not getgenv().maruRaceRoll then break end
                local randomPrefix = ""
                local length = math.random(5, 15)
                for i = 1, length do
                    randomPrefix = randomPrefix .. (math.random(1, 2) == 1 and " " or "\t")
                end
                pcall(function()
                    Event:FireServer(randomPrefix .. rewardNumber)
                end)
            end
            task.wait(0.1)
        end

        notify("Race Roll", "ปิดระบบเสกที่รีเผ่าแล้ว", "info")
    end)
end

local function stopRaceRoll()
    getgenv().maruRaceRoll = false
end

local function burstRaceRoll(count)
    task.spawn(function()
        local Event
        local ok = pcall(function()
            Event = ReplicatedStorage:WaitForChild("Remote", 10)
                :WaitForChild("UpdateLog_Server", 10)
                :WaitForChild("TryClaimUPDRewardRE", 10)
        end)
        if not ok or not Event then
            notify("Race Roll", "ไม่พบ Remote", "alert")
            return
        end
        count = count or 100
        notify("Race Roll", "เริ่ม Burst " .. tostring(count) .. " รอบ...", "zap")
        for i = 1, count do
            for _, r in ipairs({ "4", "5", "6" }) do
                local prefix = ""
                for j = 1, math.random(5, 15) do
                    prefix = prefix .. (math.random(1, 2) == 1 and " " or "\t")
                end
                pcall(function() Event:FireServer(prefix .. r) end)
            end
            task.wait(0.1)
        end
        notify("Race Roll", "Burst เสร็จสิ้น (" .. tostring(count * 3) .. " shots)", "check")
    end)
end

-- ═════════════════════════════════════════════════════════════
--  INFINITY POTION
-- ═════════════════════════════════════════════════════════════
local function spawnInfinityPotions()
    task.spawn(function()
        local potionS = { "DamagePotion", "LuckPotion", "TrainPotion" }
        local Event = getRemote("Potion", "TryUsePotionRE")
        if not Event then
            notify("Potion", "ไม่พบ Remote TryUsePotionRE", "alert")
            return
        end
        notify("Potion", "กำลังเสกน้ำยาไม่จำกัด...", "flask")
        for _, potion in ipairs(potionS) do
            pcall(function() Event:FireServer(potion, -1/0) end)
        end
        task.wait(1)
        for _, potion in ipairs(potionS) do
            pcall(function() Event:FireServer(potion, 1/0) end)
        end
        notify("Potion", "เสกน้ำยาไม่จำกัดสำเร็จ! (Damage/Luck/Train)", "check-circle")
    end)
end

local function spawnInfinityPotion(potionName)
    task.spawn(function()
        local Event = getRemote("Potion", "TryUsePotionRE")
        if not Event then
            notify("Potion", "ไม่พบ Remote", "alert")
            return
        end
        pcall(function() Event:FireServer(potionName, -1/0) end)
        task.wait(0.5)
        pcall(function() Event:FireServer(potionName, 1/0) end)
        notify("Potion", "เสก " .. potionName .. " ไม่จำกัดสำเร็จ", "flask")
    end)
end

local function overkillPotions(rounds)
    task.spawn(function()
        local Event = getRemote("Potion", "TryUsePotionRE")
        if not Event then
            notify("Potion", "ไม่พบ Remote", "alert")
            return
        end
        rounds = rounds or 5
        local potionS = { "DamagePotion", "LuckPotion", "TrainPotion" }
        notify("Potion", "Overkill " .. tostring(rounds) .. " รอบ...", "flask")
        for r = 1, rounds do
            for _, p in ipairs(potionS) do
                pcall(function() Event:FireServer(p, -1/0) end)
            end
            task.wait(0.2)
            for _, p in ipairs(potionS) do
                pcall(function() Event:FireServer(p, 1/0) end)
            end
            task.wait(0.4)
        end
        notify("Potion", "Overkill เสร็จสิ้น! น้ำยาอนันต์ 100%", "check-circle")
    end)
end

-- ═════════════════════════════════════════════════════════════
--  ASTRAL SPAWNER
-- ═════════════════════════════════════════════════════════════
local function getDevRemoteFolder()
    if not RemoteRoot then return nil end
    local candidates = { "Dev", "Dev_Server", "Developer", "Developer_Server", "Admin", "Admin_Server", "Cheat", "Cheat_Server", "Debug", "Debug_Server" }
    for _, name in ipairs(candidates) do
        local f = RemoteRoot:FindFirstChild(name)
        if f then return f end
    end
    return nil
end

local function findRemoteByName(nameList)
    if type(nameList) == "string" then nameList = { nameList } end
    if not RemoteRoot then return nil end
    for _, n in ipairs(nameList) do
        local r = RemoteRoot:FindFirstChild(n)
        if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
            return r, "Remote/" .. n
        end
    end
    for _, n in ipairs(nameList) do
        for _, d in ipairs(RemoteRoot:GetDescendants()) do
            if d.Name == n and (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) then
                return d, "descendant: " .. d:GetFullName()
            end
        end
    end
    for _, n in ipairs(nameList) do
        local keyword = n:gsub("RE$", ""):gsub("RF$", ""):lower()
        if #keyword >= 4 then
            for _, d in ipairs(RemoteRoot:GetDescendants()) do
                if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                    local dn = d.Name:lower()
                    if dn:find(keyword, 1, true) then
                        return d, "fuzzy: " .. d:GetFullName()
                    end
                end
            end
        end
    end
    return nil
end

local function dumpDevRemotes()
    local lines = { "=== Maru Hub: Astral Debug ===" }
    local dev = getDevRemoteFolder()
    if dev then
        lines[#lines + 1] = "✅ Dev folder: " .. dev:GetFullName()
        for _, r in ipairs(dev:GetChildren()) do
            lines[#lines + 1] = "  • " .. r.Name .. " [" .. r.ClassName .. "]"
        end
    else
        lines[#lines + 1] = "❌ ไม่พบ Dev folder"
        lines[#lines + 1] = "ค้นหา Remote ที่มีคำว่า Weapon/Armor/Ore/Ench:"
        local found = 0
        for _, d in ipairs(RemoteRoot:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                local n = d.Name:lower()
                if n:find("weapon") or n:find("armor") or n:find("ore") or n:find("ench") or n:find("spawn") or n:find("get") or n:find("dev") then
                    lines[#lines + 1] = "  ⚡ " .. d:GetFullName() .. " [" .. d.ClassName .. "]"
                    found = found + 1
                end
            end
        end
        if found == 0 then
            lines[#lines + 1] = "  ⚠️ ไม่พบ Remote ที่เกี่ยวข้อง"
        end
    end
    local report = table.concat(lines, "\n")
    print(report)
    if setclipboard then pcall(setclipboard, report) end
    return #lines
end

local function equipGoldAndRedGear()
    local items = getBackpackItems()
    local remote = getRemote("Backpack", "TryEquipItemRE")
    if not items or not remote then return false, 0 end
    local slots = { "Weapon", "Armor", "Hat" }
    local equippedCount = 0
    for _, slot in ipairs(slots) do
        local bestUuid, bestScore = nil, -1
        for uuid, item in pairs(items) do
            if type(item) == "table" and item.Type == slot then
                local idStr = tostring(item.ID or "")
                local rarityVal = tostring(item.RarityLevel or item.Rarity or item.RareLevel or "")
                local enh = (tonumber(item.EnchanceNum or item.EnhanceNum) or 0) * 1000
                local score
                if rarityVal == "Exclusive" or idStr:find("1101") then
                    score = 1000000000000 + enh
                elseif rarityVal == "Infinite" or idStr:find("K_26") then
                    score = 900000000000 + enh
                elseif rarityVal == "Ancient" then
                    score = 800000000000 + enh
                elseif rarityVal == "Eternal" or idStr:find("LHat_16") then
                    score = 700000000000 + enh
                elseif rarityVal == "Mythic" or idStr:find("HArmor_14") or idStr:find("K_21") or idStr:find("HHat_14") then
                    score = 600000000000 + enh
                else
                    score = itemGearScore(item)
                end
                if score > bestScore then
                    bestScore, bestUuid = score, uuid
                end
            end
        end
        if bestUuid then
            local ok = pcall(function() remote:FireServer(bestUuid, slot) end)
            if ok then equippedCount += 1 end
        end
    end
    return equippedCount > 0, equippedCount
end

local ASTRAL_SETS = {
    Apocalypse   = { weapon = "K_1101", hat = "HHat_1101", armor = "HArmor_1101" },
    TriWyrm      = { weapon = "K_1001", hat = "HHat_1001", armor = "HArmor_1001" },
    Cataclysm    = { weapon = "K_1002", hat = "HHat_1002", armor = "HArmor_1002" },
    VoidOverlord = { weapon = "K_26",   hat = "LHat_16",   armor = "LArmor_16"   },
}

local function spawnGodSet(setName)
    local set = ASTRAL_SETS[setName]
    if not set then return false, "Unknown set: " .. tostring(setName) end
    local weaponRE = findRemoteByName({ "GetWeaponRE", "GetWeaponRF", "SpawnWeaponRE", "GiveWeaponRE", "WeaponRE", "Weapon" })
    local armorRE  = findRemoteByName({ "GetArmorRE", "GetArmorRF", "SpawnArmorRE", "GiveArmorRE", "ArmorRE", "Armor" })
    local hatRE    = findRemoteByName({ "GetHatRE", "GetHatRF", "SpawnHatRE", "GiveHatRE", "HatRE", "Hat" })
    if not weaponRE and not armorRE and not hatRE then
        return false, "❌ ไม่พบ Remote Weapon/Armor/Hat — กด Debug Remote"
    end
    local firedCount = 0
    if weaponRE then
        if pcall(function() weaponRE:FireServer(set.weapon) end) then firedCount += 1 end
        pcall(function() weaponRE:FireServer({ ID = set.weapon }) end)
        pcall(function() weaponRE:FireServer(set.weapon, "Weapon") end)
        if weaponRE:IsA("RemoteFunction") then
            pcall(function() weaponRE:InvokeServer(set.weapon) end)
        end
    end
    if armorRE then
        if pcall(function() armorRE:FireServer(set.armor) end) then firedCount += 1 end
        pcall(function() armorRE:FireServer({ ID = set.armor }) end)
        pcall(function() armorRE:FireServer(set.armor, "Armor") end)
    end
    if hatRE then
        if pcall(function() hatRE:FireServer(set.hat) end) then firedCount += 1 end
        pcall(function() hatRE:FireServer({ ID = set.hat }) end)
        pcall(function() hatRE:FireServer(set.hat, "Hat") end)
    elseif armorRE then
        pcall(function() armorRE:FireServer(set.hat) end)
    end
    task.wait(0.4)
    local _, equipped = pcall(equipGoldAndRedGear)
    if firedCount == 0 then return false, "❌ ยิงไม่สำเร็จ" end
    return true, "✅ " .. tostring(firedCount) .. " shots | Equipped: " .. tostring(equipped or 0)
end

local function countBackpackOres()
    local total = 0
    local bp = getBackpackItems()
    if bp then
        for _, it in pairs(bp) do
            if type(it) == "table" and it.Type == "Ore" then
                total = total + (tonumber(it.Number) or 1)
            end
        end
    end
    return total
end

local function spawnApexOresDirect(count)
    count = count or 10
    local oreRE = findRemoteByName({ "GetOreRE", "GetOreRF", "SpawnOreRE", "GiveOreRE", "OreRE", "Ore" })
    if not oreRE then return false, "❌ ไม่พบ Remote Ore" end
    local fired = 0
    for _ = 1, count do
        if pcall(function() oreRE:FireServer("Ore_48") end) then fired += 1 end
        pcall(function() oreRE:FireServer({ ID = "Ore_48" }) end)
        pcall(function() oreRE:FireServer("Ore_48", 1) end)
    end
    task.wait(0.3)
    pcall(function()
        local LeftInfoGUI = require(ReplicatedStorage.GuiUtils.LeftInfoGUI)
        if LeftInfoGUI and LeftInfoGUI.UpdateOrePack then
            LeftInfoGUI.UpdateOrePack(countBackpackOres())
        end
    end)
    if fired == 0 then return false, "❌ ยิงไม่ได้" end
    return true, "✅ " .. tostring(fired) .. " shots"
end

local function spawnAllRunesDirect()
    local runeRE = findRemoteByName({ "GetEnchStoneRE", "GetEnchStoneRF", "SpawnEnchStoneRE", "GetRuneRE", "EnchStoneRE", "RuneRE" })
    if not runeRE then return false, "❌ ไม่พบ Remote EnchStone" end
    local runes = { "Poison_3", "Ice_3", "Fire_3", "Thunder_3", "Poison_2", "Ice_2", "Fire_2", "Thunder_2" }
    local fired = 0
    for _, r in ipairs(runes) do
        if pcall(function() runeRE:FireServer(r) end) then fired += 1 end
        pcall(function() runeRE:FireServer({ ID = r }) end)
    end
    if fired == 0 then return false, "❌ ยิงไม่ได้" end
    return true, "✅ " .. tostring(fired) .. " runes"
end

-- ─────────────────────────────────────────────────────────────
-- Ember Stone Engine
-- ─────────────────────────────────────────────────────────────
local myToken = tick()
_G.MaruActiveToken = myToken
_G.MaruRunning = true

local function applyBackpackVisualEngine()
    pcall(function()
        local AnyHelper = require(ReplicatedStorage.Config.AnyHelper)
        local MatHelper = nil
        pcall(function() MatHelper = require(ReplicatedStorage.Config.Material.Helper) end)
        local MatShow = nil
        pcall(function() MatShow = require(ReplicatedStorage.Config.Material.Show) end)
        local MatConfig = nil
        pcall(function() MatConfig = require(ReplicatedStorage.Config.Material.Config) end)
        local OreHelper = nil
        pcall(function() OreHelper = require(ReplicatedStorage.Config.Ore.Helper) end)
        local EnchHelper = nil
        pcall(function() EnchHelper = require(ReplicatedStorage.Config.EnchStone.Helper) end)
        local WeaponHelper = nil
        pcall(function() WeaponHelper = require(ReplicatedStorage.Config.Weapon.Helper) end)
        local ArmorHelper = nil
        pcall(function() ArmorHelper = require(ReplicatedStorage.Config.Armor.Helper) end)
        local RarityHelper = nil
        pcall(function() RarityHelper = require(ReplicatedStorage.Config.Rarity.Helper) end)
        local AbbNumber = nil
        pcall(function() AbbNumber = require(ReplicatedStorage.Utils.AbbNumber) end)
        local BackpackData = require(ReplicatedStorage.LocalData.BackpackData)
        local BackpackGUI = nil
        pcall(function() BackpackGUI = require(ReplicatedStorage.GuiUtils.BackpackGUI) end)

        local function sanitizeBackpackData()
            local bp = BackpackData and BackpackData.GetData()
            if not bp or not bp.have then return end
            local corruptOreCount = 0
            local toRemove = {}
            for k, v in pairs(bp.have) do
                if v.Type == "Ore" and type(v.ID) == "table" then
                    corruptOreCount = corruptOreCount + (v.Number or 0)
                    table.insert(toRemove, k)
                end
            end
            if corruptOreCount > 0 then
                local merged = false
                for k2, v in pairs(bp.have) do
                    if v.Type == "Material" and v.ID == "EnhantStone_1" and not tostring(k2):find("^SSS%-MAT") then
                        v.Number = (v.Number or 0) + corruptOreCount
                        merged = true
                        break
                    end
                end
                if not merged then
                    bp.have["SSS-CLEAN-EMBER-1"] = {
                        ID = "EnhantStone_1", Type = "Material", Number = corruptOreCount,
                        Equip = false, Lock = false, Level = 1
                    }
                end
                for _, k in ipairs(toRemove) do bp.have[k] = nil end
            end
        end

        if MatHelper and MatShow and not _G._Maru_MatHelperProtected then
            _G._Maru_MatHelperProtected = true
            MatHelper.GetImage = function(id)
                if id and MatShow[id] then return MatShow[id].Image end
                return nil
            end
            MatHelper.GetDisName = function(id)
                if id and MatShow[id] then return MatShow[id].DisplayName end
                return nil
            end
            MatHelper.GetRarity = function(id)
                if id and MatConfig and MatConfig[id] then return MatConfig[id].Rarity end
                return nil
            end
        end

        local function resolveItemIdentity(itemType, itemId)
            local aType = itemType or "Material"
            local aId = itemId
            if type(itemId) == "table" then
                aId = itemId.ID or itemId.Name or itemId
                aType = itemId.Type or itemType or "Material"
            end
            return aType, tostring(aId)
        end

        local origGetImage = AnyHelper.GetImage
        local origGetDisName = AnyHelper.GetDisName
        local origGetRarity = AnyHelper.GetRarity
        local origGetPrice = AnyHelper.GetPrice

        local function safeResolveImage(itemType, itemId)
            local aType, aId = resolveItemIdentity(itemType, itemId)
            local img = nil
            pcall(function() img = origGetImage(aType, aId) end)
            if img and img ~= "" then return img end
            pcall(function() if MatHelper and MatHelper.GetImage then img = MatHelper.GetImage(aId) end end)
            if img and img ~= "" then return img end
            pcall(function() if OreHelper and OreHelper.GetImage then img = OreHelper.GetImage(aId) end end)
            if img and img ~= "" then return img end
            pcall(function() if EnchHelper and EnchHelper.GetImage then img = EnchHelper.GetImage(aId) end end)
            if img and img ~= "" then return img end
            pcall(function() if WeaponHelper and WeaponHelper.GetImage then img = WeaponHelper.GetImage(aId) end end)
            if img and img ~= "" then return img end
            pcall(function() if ArmorHelper and ArmorHelper.GetImage then img = ArmorHelper.GetImage(aId) end end)
            if img and img ~= "" then return img end
            return "rbxassetid://93499783424371"
        end

        local function safeResolveDisName(itemType, itemId)
            local aType, aId = resolveItemIdentity(itemType, itemId)
            local name = nil
            pcall(function() name = origGetDisName(aType, aId) end)
            if name and name ~= "" then return name end
            pcall(function() if MatHelper and MatHelper.GetDisName then name = MatHelper.GetDisName(aId) end end)
            if name and name ~= "" then return name end
            pcall(function() if OreHelper and OreHelper.GetDisName then name = OreHelper.GetDisName(aId) end end)
            if name and name ~= "" then return name end
            return aId
        end

        local function safeResolveRarity(itemType, itemId)
            local aType, aId = resolveItemIdentity(itemType, itemId)
            local rar = nil
            pcall(function() rar = origGetRarity(aType, aId) end)
            if rar and rar ~= "" then return rar end
            pcall(function() if MatHelper and MatHelper.GetRarity then rar = MatHelper.GetRarity(aId) end end)
            if rar and rar ~= "" then return rar end
            return "Legendary"
        end

        local function safeResolvePrice(itemType, itemId)
            local aType, aId = resolveItemIdentity(itemType, itemId)
            local price = nil
            pcall(function() price = origGetPrice(aType, aId) end)
            if price and price > 0 then return price end
            return 50000
        end

        if not _G._Maru_AnyHelperHooked then
            _G._Maru_AnyHelperHooked = true
            AnyHelper.GetImage = safeResolveImage
            AnyHelper.GetDisName = safeResolveDisName
            AnyHelper.GetRarity = safeResolveRarity
            AnyHelper.GetPrice = safeResolvePrice
        end

        local isHealing = false
        local function healBackpackFrames()
            if isHealing then return end
            isHealing = true
            sanitizeBackpackData()
            local bpGui = LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main:FindFirstChild("Backpack")
            if not bpGui then isHealing = false; return end
            local scroll = bpGui:FindFirstChild("Main") and bpGui.Main:FindFirstChild("Right") and bpGui.Main.Right:FindFirstChild("Bg") and bpGui.Main.Right.Bg:FindFirstChild("ScrollingFrame")
            if not scroll then isHealing = false; return end
            for _, cell in ipairs(scroll:GetChildren()) do
                if cell:IsA("Frame") and cell.Visible then
                    local item = BackpackData.GetItemData(cell.Name)
                    if item then
                        local btn = cell:FindFirstChild("Button")
                        if btn then
                            local frame = btn:FindFirstChild("Frame")
                            if frame then
                                local imgLabel = frame:FindFirstChild("ImageLabel")
                                if imgLabel and (imgLabel.Image == "" or not imgLabel.Image) then
                                    imgLabel.Image = safeResolveImage(item.Type, item.ID)
                                end
                                local zi = frame:FindFirstChild("zi")
                                if zi then
                                    local atkLabel = zi:FindFirstChild("ATK")
                                    if atkLabel and (atkLabel.Text == "" or not atkLabel.Text) then
                                        atkLabel.Text = safeResolveDisName(item.Type, item.ID)
                                    end
                                end
                                local qty = frame:FindFirstChild("Quantity")
                                local qtyLabel = qty and qty:FindFirstChild("TextLabel")
                                if qtyLabel and item.Number then
                                    local numStr = AbbNumber and AbbNumber.AbbreviateNumber and AbbNumber.AbbreviateNumber(item.Number) or tostring(item.Number)
                                    local expectedText = "x" .. tostring(numStr)
                                    if qtyLabel.Text ~= expectedText then qtyLabel.Text = expectedText end
                                    qty.Visible = (item.Number > 1)
                                end
                            end
                        end
                    end
                end
            end
            isHealing = false
        end
        _G._Maru_HealBackpack = healBackpackFrames

        if BackpackGUI then
            local origOpen = _G._Maru_OrigBackpackOpen or BackpackGUI.open
            _G._Maru_OrigBackpackOpen = origOpen
            BackpackGUI.open = function(...)
                if origOpen then origOpen(...) end
                pcall(function()
                    if BackpackGUI.UpdateBackpack then BackpackGUI.UpdateBackpack() end
                    healBackpackFrames()
                end)
            end
        end

        BackpackData.AddCallback(function() task.defer(healBackpackFrames) end)

        local ProfileData = require(ReplicatedStorage.ProfileData)
        if ProfileData and ProfileData.AddStoreCallback then
            ProfileData.AddStoreCallback("Backpack", function() task.defer(healBackpackFrames) end)
        end

        task.spawn(function()
            local bpGui = LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("Backpack")
            local scroll = bpGui:WaitForChild("Main"):WaitForChild("Right"):WaitForChild("Bg"):WaitForChild("ScrollingFrame")
            scroll.ChildAdded:Connect(function() task.defer(healBackpackFrames) end)
            while _G.MaruRunning and _G.MaruActiveToken == myToken do
                if bpGui.Visible then
                    pcall(healBackpackFrames)
                end
                task.wait(0.2)
            end
        end)

        sanitizeBackpackData()
        healBackpackFrames()
    end)
end

-- ★ Normal Ember Stone
local isPumpingEmber = false
local function pumpRealEmberStones(targetAmount)
    targetAmount = tonumber(targetAmount) or 5000
    if isPumpingEmber then return false end
    isPumpingEmber = true

    local function getStoneCount()
        local bp = BackpackData and BackpackData.GetData()
        if bp and bp.have then
            for k, item in pairs(bp.have) do
                if item.ID == "EnhantStone_1" and not tostring(k):find("^SSS%-MAT") then
                    return item.Number or 0
                end
            end
        end
        return 0
    end

    local initialCount = getStoneCount()
    local goal = initialCount + targetAmount

    task.spawn(function()
        notify("Ember Stone", "กำลังเสก Ember +" .. tostring(targetAmount) .. " ก้อน...", "flame")
        local stageRemote = getRemote("Stage", "StageFinishedRF")
        local stoneRemote = getRemote("Stage", "GetEnhantStoneRE")
        local current = getStoneCount()
        local t0 = os.clock()
        local maxWait = 60

        while current < goal and (os.clock() - t0) < maxWait and _G.MaruRunning and _G.MaruActiveToken == myToken do
            local batchSize = 35
            local needed = goal - current
            if needed < 50 then batchSize = 15 end
            for i = 1, batchSize do
                task.spawn(function()
                    local ok, drops = pcall(function() return stageRemote:InvokeServer("Stage_27") end)
                    if ok and type(drops) == "table" and stoneRemote then
                        for uuid, itm in pairs(drops) do
                            if type(itm) == "table" and (itm.ID == "EnhantStone_1" or itm.Type == "Material") then
                                pcall(function() stoneRemote:FireServer(uuid) end)
                            end
                        end
                    end
                end)
            end
            task.wait(0.12)
            current = getStoneCount()
            if _G._Maru_HealBackpack then pcall(_G._Maru_HealBackpack) end
        end

        local finalCount = getStoneCount()
        local gained = finalCount - initialCount
        isPumpingEmber = false
        notify("Ember Stone", "✅ ได้ +" .. tostring(gained) .. " ก้อน (รวม " .. tostring(finalCount) .. ")", "flame")
    end)
    return true
end

-- ★★ NEW: Infinity Ember Stone (999,999,999)
local function pumpInfinityEmber()
    if isPumpingEmber then
        notify("Ember Infinity", "กำลังเสกอยู่ กรุณารอ", "flame")
        return false
    end
    isPumpingEmber = true

    local function getStoneCount()
        local bp = BackpackData and BackpackData.GetData()
        if bp and bp.have then
            for k, item in pairs(bp.have) do
                if item.ID == "EnhantStone_1" and not tostring(k):find("^SSS%-MAT") then
                    return item.Number or 0
                end
            end
        end
        return 0
    end

    task.spawn(function()
        notify("Ember Infinity", "🚀 เริ่มเสก Ember Stone ไม่จำกัด (999M)...", "flame")
        local stageRemote = getRemote("Stage", "StageFinishedRF")
        local stoneRemote = getRemote("Stage", "GetEnhantStoneRE")
        if not stageRemote or not stoneRemote then
            isPumpingEmber = false
            notify("Ember Infinity", "❌ ไม่พบ Remote Stage", "alert")
            return
        end

        local goal = 999999999
        local current = getStoneCount()
        local t0 = os.clock()
        local maxWait = 300
        local batchSize = 200

        while current < goal and (os.clock() - t0) < maxWait and _G.MaruRunning and _G.MaruActiveToken == myToken do
            for i = 1, batchSize do
                task.spawn(function()
                    local ok, drops = pcall(function() return stageRemote:InvokeServer("Stage_27") end)
                    if ok and type(drops) == "table" and stoneRemote then
                        for uuid, itm in pairs(drops) do
                            if type(itm) == "table" and (itm.ID == "EnhantStone_1" or itm.Type == "Material") then
                                pcall(function() stoneRemote:FireServer(uuid) end)
                            end
                        end
                    end
                end)
            end
            task.wait(0.08)
            local newCount = getStoneCount()
            if newCount > current then current = newCount end
            if _G._Maru_HealBackpack then pcall(_G._Maru_HealBackpack) end
        end

        local finalCount = getStoneCount()
        isPumpingEmber = false
        notify("Ember Infinity", "✅ เสร็จ! Ember = " .. tostring(finalCount) .. " ก้อน", "flame")
    end)
    return true
end

-- ★★ NEW: Flood Ember (Multi-thread super fast)
local function floodEmberStone()
    task.spawn(function()
        notify("Ember Flood", "⚡ กำลัง Flood Ember เข้ากระเป๋า...", "zap")
        local materialRemote = findRemoteByName({
            "GetEnchStoneRE", "GetEnchStoneRF", "SpawnEnchStoneRE",
            "GiveEnchStoneRE", "EnchStoneRE", "MaterialRE"
        })
        local stageRemote = getRemote("Stage", "StageFinishedRF")
        local stoneRemote = getRemote("Stage", "GetEnhantStoneRE")

        if not materialRemote and (not stageRemote or not stoneRemote) then
            notify("Ember Flood", "❌ ไม่พบ Remote ที่ใช้ได้", "alert")
            return
        end

        local hit = 0
        for i = 1, 50 do
            task.spawn(function()
                for j = 1, 20 do
                    if materialRemote then
                        pcall(function() materialRemote:FireServer("EnhantStone_1", 9999999) end)
                        pcall(function() materialRemote:FireServer({ ID = "EnhantStone_1", Number = 9999999 }) end)
                        hit = hit + 1
                    end
                    if stageRemote and stoneRemote then
                        local ok, drops = pcall(function() return stageRemote:InvokeServer("Stage_27") end)
                        if ok and type(drops) == "table" then
                            for uuid, itm in pairs(drops) do
                                if type(itm) == "table" then
                                    pcall(function() stoneRemote:FireServer(uuid) end)
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(1.5)
        if _G._Maru_HealBackpack then pcall(_G._Maru_HealBackpack) end

        local finalCount = 0
        local bp = BackpackData and BackpackData.GetData()
        if bp and bp.have then
            for k, item in pairs(bp.have) do
                if item.ID == "EnhantStone_1" and not tostring(k):find("^SSS%-MAT") then
                    finalCount = item.Number or 0
                    break
                end
            end
        end
        notify("Ember Flood", "✅ เสร็จ! Ember = " .. tostring(finalCount) .. " | Shots = " .. tostring(hit), "check-circle")
    end)
end

-- ─────────────────────────────────────────────────────────────
-- Equipment Management
-- ─────────────────────────────────────────────────────────────
local equipBestGearNow, autoEnchantEquippedGear
local function runAlgorithmicGearSolver()
    local ok, count, score = equipBestGearNow("All")
    pcall(autoEnchantEquippedGear)
    return ok, count, score
end

equipBestGearNow = function(targetType)
    local items = getBackpackItems()
    local remote = getRemote("Backpack", "TryEquipItemRE")
    if not items or not remote then return false, 0 end
    local slots = (targetType == "Weapon" or targetType == "Armor" or targetType == "Hat")
        and { targetType } or { "Weapon", "Armor", "Hat" }
    local equipped, highestScore = 0, 0
    for _, slot in ipairs(slots) do
        local bestUuid, bestScore = nil, -1
        for uuid, item in pairs(items) do
            if type(item) == "table" and item.Type == slot then
                local score = itemGearScore(item)
                if score > bestScore then bestUuid, bestScore = uuid, score end
            end
        end
        if bestUuid then
            local ok = pcall(function() remote:FireServer(bestUuid, slot) end)
            if ok then equipped += 1; highestScore = math.max(highestScore, bestScore) end
        end
    end
    return equipped > 0, equipped, highestScore
end

local forgeCycleIndex = 1
local function executeForgeNow(forgeType, minOres)
    local items = getBackpackItems()
    local remote = getRemote("Forge", "ForgeRF")
    if not items or not remote or not remote:IsA("RemoteFunction") then
        return false, "Forge remote unavailable"
    end
    forgeType = forgeType or State.ForgeType or "All"
    minOres = math.max(4, math.floor(tonumber(minOres or State.MinOreToForge) or 4))
    local totalOres, oreEntries = 0, {}
    for uuid, item in pairs(items) do
        if type(item) == "table" and item.Type == "Ore" then
            local count = math.max(1, math.floor(tonumber(item.Number) or 1))
            local power = 0
            if OreHelper and type(OreHelper.GetPower) == "function" then
                pcall(function() power = tonumber(OreHelper.GetPower(item.ID)) or 0 end)
            end
            totalOres += count
            oreEntries[#oreEntries + 1] = { UUID = uuid, Count = count, Power = power }
        end
    end
    if totalOres < 4 then return false, "Need 4+ ores" end
    local rotating = forgeType == "All"
    local slot = forgeType
    if rotating then
        local rotation = { "Weapon", "Armor", "Hat" }
        slot = rotation[((forgeCycleIndex - 1) % #rotation) + 1]
    end
    if slot ~= "Weapon" and slot ~= "Armor" and slot ~= "Hat" then slot = "Weapon" end
    local targetCount
    if slot == "Weapon" then
        targetCount = math.clamp(minOres, 4, 13)
    elseif slot == "Hat" then
        targetCount = minOres >= 16 and 16 or 4
    elseif minOres >= 20 and totalOres >= 23 then
        targetCount = 23
    elseif minOres >= 11 and totalOres >= 11 then
        targetCount = 11
    elseif minOres >= 8 and totalOres >= 8 then
        targetCount = 8
    elseif rotating then
        slot, targetCount = "Hat", 4
    else
        return false, "Need 8/11/23"
    end
    if totalOres < targetCount then return false, "Need " .. tostring(targetCount) end
    if State.OreQualityMode == "High" then
        table.sort(oreEntries, function(a, b) return a.Power > b.Power end)
    elseif State.OreQualityMode == "Low" then
        table.sort(oreEntries, function(a, b) return a.Power < b.Power end)
    end
    local uuidList, selected = {}, 0
    for _, ore in ipairs(oreEntries) do
        local take = math.min(ore.Count, targetCount - selected)
        if take > 0 then uuidList[ore.UUID] = take; selected += take end
        if selected >= targetCount then break end
    end
    if selected < targetCount then return false, "Not enough" end
    local serverConfigType = slot == "Weapon" and "Weapon" or "Armor"
    local ok, result = pcall(function()
        return remote:InvokeServer({ ConfigType = serverConfigType, UUIDList = uuidList })
    end)
    if not ok or result == false then return false, "Failed" end
    if rotating then
        forgeCycleIndex = slot == "Hat" and 1 or (forgeCycleIndex % 3) + 1
    end
    task.delay(0.25, function() equipBestGearNow(slot) end)
    return true, slot, selected
end

local STONE_GRADE_RANKS = {
    Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5,
    Mythic = 6, Eternal = 7, Secret = 8, Ancient = 9, Infinite = 10,
}

local function getStoneGrade(item)
    if type(item) ~= "table" then return 1 end
    local r = item.RarityLevel or item.Rarity or item.RareLevel or item.Rare
    if tonumber(r) then return tonumber(r) end
    if type(r) == "string" and STONE_GRADE_RANKS[r] then return STONE_GRADE_RANKS[r] end
    local id = tostring(item.ID or item.id or "")
    for name, rank in pairs(STONE_GRADE_RANKS) do
        if id:find(name) then return rank end
    end
    return 1
end

autoEnchantEquippedGear = function()
    local bp = getBackpackItems()
    if not bp then return false, 0 end
    local maxAllowedRank = STONE_GRADE_RANKS[State.EnchantMaxGrade] or 6
    if State.EnchantMaxGrade == "All" then maxAllowedRank = 99 end
    local usableStones = {}
    for uuid, item in pairs(bp) do
        if type(item) == "table" then
            local isStone = item.Type == "EnchStone" or (item.ID and tostring(item.ID):find("Stone"))
            if isStone then
                local gradeRank = getStoneGrade(item)
                local skip = false
                if State.EnchantKeepHighGrade and gradeRank >= 7 then skip = true end
                if gradeRank > maxAllowedRank then skip = true end
                if not skip then
                    local count = tonumber(item.Number or item.Count) or 1
                    for _ = 1, count do
                        table.insert(usableStones, { UUID = uuid, Rank = gradeRank })
                    end
                end
            end
        end
    end
    if #usableStones == 0 then return false, 0 end
    table.sort(usableStones, function(a, b) return a.Rank < b.Rank end)
    local targetSlots = (State.EnchantSlots == "Weapon" or State.EnchantSlots == "Armor" or State.EnchantSlots == "Hat")
        and { State.EnchantSlots } or { "Weapon", "Armor", "Hat" }
    local enchantRE = getRemote("Backpack", "EnchantRE")
    local stoneIdx = 1
    local totalEnchanted = 0
    for uuid, item in pairs(bp) do
        local isEquipped = false
        pcall(function()
            if BackpackData and BackpackData.IsEquipedUUID then
                isEquipped = BackpackData.IsEquipedUUID(uuid)
            end
        end)
        if isEquipped and type(item) == "table" and table.find(targetSlots, item.Type) then
            local maxSlots = tonumber(item.EnchanceNum or item.EnhanceNum) or 0
            if maxSlots > 0 then
                local currentList = item.EnchanceList or item.EnhanceList or {}
                local usedSlots = 0
                for _, s in ipairs(currentList) do
                    if s and (s.ID or s.id or s.Name) and (s.ID ~= "" and s.id ~= "") then
                        usedSlots = usedSlots + 1
                    end
                end
                local emptySlots = maxSlots - usedSlots
                while emptySlots > 0 and stoneIdx <= #usableStones do
                    local stone = usableStones[stoneIdx]
                    stoneIdx = stoneIdx + 1
                    local fired = false
                    pcall(function()
                        if BackpackData and BackpackData.EnchantEquipment then
                            BackpackData.EnchantEquipment(uuid, stone.UUID)
                            fired = true
                        elseif enchantRE then
                            enchantRE:FireServer(uuid, stone.UUID)
                            fired = true
                        end
                    end)
                    if fired then
                        totalEnchanted = totalEnchanted + 1
                        emptySlots = emptySlots - 1
                        task.wait(0.2)
                    end
                end
            end
        end
        if stoneIdx > #usableStones then break end
    end
    return totalEnchanted > 0, totalEnchanted
end

-- ─────────────────────────────────────────────────────────────
-- Loop Helpers
-- ─────────────────────────────────────────────────────────────
local function getBindable(category, name)
    local be = nil
    pcall(function()
        local CommunicationUtils = require(ReplicatedStorage.Utils.CommunicationUtils)
        be = CommunicationUtils.TryGetBindableEvent(category, name)
    end)
    return be
end

local ActiveThreads = {}
local function loop(flag, delay, fn)
    if ActiveThreads[flag] then return end
    ActiveThreads[flag] = true
    task.spawn(function()
        while State[flag] do
            local ok, err = pcall(fn)
            if not ok and State.Debug then warn("[Maru Loop Error]:", flag, err) end
            local waitTime = type(delay) == "string" and State[delay] or delay
            task.wait(math.max(waitTime or 0.1, 0.05))
        end
        ActiveThreads[flag] = nil
    end)
end

local function toggleLoop(flag, delay, fn)
    return function(v)
        State[flag] = v
        if v then loop(flag, delay, fn) end
    end
end

-- ─────────────────────────────────────────────────────────────
-- Webhook
-- ─────────────────────────────────────────────────────────────
local function sendWebhook(title, description, fields, color)
    if not State.WebhookEnabled or not State.WebhookUrl or State.WebhookUrl == "" then return end
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if not req then return end
    task.spawn(function()
        local embed = {
            title = title, description = description, color = color or 16720962,
            fields = fields or {},
            footer = { text = "Maru Hub v6.0 | Telemetry" },
            timestamp = DateTime.now():ToIsoDate(),
        }
        pcall(function()
            req({
                Url = State.WebhookUrl, Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({ embeds = { embed } }),
            })
        end)
    end)
end

-- ─────────────────────────────────────────────────────────────
-- Config Persistence
-- ─────────────────────────────────────────────────────────────
local ConfigFileName = "MaruHub_Config.json"

Dynamic.sanitize = function(v, depth)
    local t = type(v)
    if t == "boolean" or t == "string" then return v end
    if t == "number" then
        if v ~= v or v == math.huge or v == -math.huge then return nil end
        return v
    end
    if t == "table" and depth < 3 then
        local out, isArray = {}, true
        for k in pairs(v) do
            if type(k) ~= "number" then isArray = false break end
        end
        for k, x in pairs(v) do
            local c = Dynamic.sanitize(x, depth + 1)
            if c ~= nil then
                if isArray then out[#out + 1] = c
                elseif type(k) == "string" then out[k] = c end
            end
        end
        return out
    end
    return nil
end

Dynamic.encodeState = function()
    local clean = {}
    for k, v in pairs(State) do
        if type(k) == "string" then
            local c = Dynamic.sanitize(v, 0)
            if c ~= nil then clean[k] = c end
        end
    end
    local ok, encoded = pcall(function() return HttpService:JSONEncode(clean) end)
    return ok and encoded or nil
end

local function saveConfig()
    if type(writefile) ~= "function" then return false, "no_writefile" end
    local encoded = Dynamic.encodeState()
    if not encoded then return false, "encode_failed" end
    local wok, werr = pcall(writefile, ConfigFileName, encoded)
    if not wok then return false, tostring(werr) end
    return true, #encoded
end

local function loadConfig()
    if not (type(isfile) == "function" and type(readfile) == "function") then return false, "no_readfile" end
    local fok, exists = pcall(isfile, ConfigFileName)
    if not fok or not exists then return false, "no_file" end
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(ConfigFileName))
    end)
    if not ok or type(decoded) ~= "table" then return false, "bad_json" end
    local count = 0
    for k, v in pairs(decoded) do
        if State[k] ~= nil and type(State[k]) == type(v) then
            State[k] = v
            count = count + 1
        end
    end
    return true, count
end

task.spawn(function() pcall(loadConfig) end)

task.spawn(function()
    local last = Dynamic.encodeState()
    while true do
        task.wait(3)
        if State.AutoSaveConfig then
            local now = Dynamic.encodeState()
            if now and now ~= last then
                if saveConfig() then last = now end
            end
        end
    end
end)

-- ─────────────────────────────────────────────────────────────
-- Train Zone Logic
-- ─────────────────────────────────────────────────────────────
local function getSelectedTrainZone()
    local sel = State and State.SelectedTrainZone
    if not sel or sel == TRAIN_AUTO_BEST then return getBestTrainZone() end
    return getZoneByName(sel) or getBestTrainZone()
end

local _currentTrainZoneId = nil

local function disengageIdleTraining()
    pcall(function()
        local tc = TrainCTRL or (ReplicatedStorage:FindFirstChild("CTRL") and require(ReplicatedStorage.CTRL.TrainCTRL))
        if tc then
            if tc.GetIsAutoing and tc.GetIsAutoing() then tc.ExitAutoTrain() end
            if tc.GetIsTraining and tc.GetIsTraining() then tc.EndTrain() end
        end
    end)
    pcall(function()
        LocalPlayer:SetAttribute("AutoTrainAreaID", nil)
        call("Train", "ExitAutoTrainRE")
    end)
    _currentTrainZoneId = nil
end

local function engageIdleTraining()
    local inFight = LocalPlayer:GetAttribute("IntoFight")
    local inDung  = LocalPlayer:GetAttribute("Dungeoning")
    if inFight or inDung then return end
    local r = hrp()
    if not r then return end
    local safePad = getBestLegitTrainZone() or TrainAreaConfig[1]
    local targetId = (State.ForceVIPTrain and 9) or (safePad and safePad.Id) or 1
    local part = safePad and getTrainZonePart(safePad.Id)
    local targetCF = (part and (part.CFrame + Vector3.new(0, 3.2, 0)))
        or (safePad and safePad.PadPos and CFrame.new(safePad.PadPos + Vector3.new(0, 1.5, 0)))
        or (safePad and safePad.FallbackPos and CFrame.new(safePad.FallbackPos + Vector3.new(0, 3.2, 0)))
    if targetCF then
        local dist = (r.Position - targetCF.Position).Magnitude
        if dist > 4.0 or _currentTrainZoneId ~= targetId then
            _currentTrainZoneId = targetId
            pcall(function()
                r.AssemblyLinearVelocity = Vector3.zero
                r.AssemblyAngularVelocity = Vector3.zero
                r.CFrame = targetCF
            end)
        end
    end
    State.TrainArea = tostring(targetId)
    LocalPlayer:SetAttribute("AutoTrainAreaID", targetId)
    call("Train", "IntoAutoTrainRE", targetId)
    pcall(function()
        local tc = TrainCTRL or (ReplicatedStorage:FindFirstChild("CTRL") and require(ReplicatedStorage.CTRL.TrainCTRL))
        if tc then
            if tc.StartTrain and not (tc.GetIsTraining and tc.GetIsTraining()) then tc.StartTrain() end
            if tc.StartAutoTrain and not (tc.GetIsAutoing and tc.GetIsAutoing()) then tc.StartAutoTrain() end
            if State.ForceVIPTrain then
                LocalPlayer:SetAttribute("AutoTrainAreaID", 9)
                call("Train", "IntoAutoTrainRE", 9)
            end
            if tc.TrainOnce then tc.TrainOnce() end
        else
            call("Train", "TrainOnceRE")
        end
    end)
    Stats.CurrentActivity = "Training at Zone " .. tostring(targetId)
end

local function enterTrainZone(zone)
    zone = zone or getSelectedTrainZone()
    if not zone then return end
    if State.ForceVIPTrain then
        engageIdleTraining()
        return
    end
    local standPad = zone
    if zone.IsPay then
        standPad = getBestLegitTrainZone() or TrainAreaConfig[1]
    end
    local r, h = hrp(), hum()
    if r and h and h.Health > 0 and standPad.PadPos then
        local cur = r.Position
        local dist = (Vector3.new(cur.X, standPad.PadPos.Y, cur.Z) - standPad.PadPos).Magnitude
        if dist > 6 then
            r.CFrame = CFrame.lookAt(standPad.PadPos + Vector3.new(0, 1.5, 0), standPad.DummyPos or (standPad.PadPos + Vector3.new(0, 0, 5)))
            r.AssemblyLinearVelocity = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.1)
        end
    end
    local targetId = zone.Id
    if LocalPlayer:GetAttribute("AutoTrainAreaID") ~= targetId then
        call("Train", "IntoAutoTrainRE", targetId)
    end
    State.TrainArea = tostring(targetId)
end

-- ─────────────────────────────────────────────────────────────
-- Drop Magnet
-- ─────────────────────────────────────────────────────────────
local function runDropMagnet()
    local oreCache = workspace:FindFirstChild("OreCache")
    if not oreCache then return end
    local targetCF
    if State.MagnetTarget == "Safe Zone" then
        targetCF = getSafeZoneCF() + Vector3.new(0, 2, 0)
    else
        local r = hrp()
        if not r then return end
        targetCF = r.CFrame
    end
    for _, drop in ipairs(oreCache:GetChildren()) do
        if drop:IsA("Model") then
            pcall(function()
                if drop.PrimaryPart then
                    drop.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
                    drop.PrimaryPart.AssemblyAngularVelocity = Vector3.zero
                    drop.PrimaryPart.CanCollide = false
                end
                drop:PivotTo(targetCF)
            end)
        end
    end
end

local notifiedDrops = {}
local function runUltraPrompts()
    if not fireproximityprompt then return end
    local oreCache = workspace:FindFirstChild("OreCache")
    local prompts = {}
    if oreCache then
        for _, p in ipairs(oreCache:GetDescendants()) do
            if p:IsA("ProximityPrompt") and p.Enabled then
                table.insert(prompts, p)
            end
        end
    end
    for _, p in ipairs(prompts) do
        pcall(function()
            p.MaxActivationDistance = 1e6
            p.RequiresLineOfSight = false
            p.HoldDuration = 0
            fireproximityprompt(p, 0)
            Stats.OresCollected = Stats.OresCollected + 1
        end)
    end
end

-- ─────────────────────────────────────────────────────────────
-- Safe Evacuate
-- ─────────────────────────────────────────────────────────────
local lastSafeEvacuationAt = 0
local function checkSafeEvacuate()
    local cur, maxNum = getPackInfo()
    local packFullPercent = (cur / math.max(maxNum, 1)) * 100
    local h = hum()
    local hpPercent = h and ((h.Health / math.max(h.MaxHealth, 1)) * 100) or 100
    local shouldEvacuate = false
    local reason = ""
    if State.AutoSafeEvacuate and packFullPercent >= State.EvacuateThreshold then
        shouldEvacuate = true
        reason = ("Pack Full (%d/%d)"):format(cur, maxNum)
    elseif State.LowHPEvacuate and hpPercent <= State.LowHPThreshold then
        shouldEvacuate = true
        reason = ("Critical HP (%.1f%%)"):format(hpPercent)
    end
    if shouldEvacuate then
        local now = os.clock()
        if now - lastSafeEvacuationAt < 20 then return true end
        lastSafeEvacuationAt = now
        Stats.CurrentActivity = "Evacuating: " .. reason
        call("Stage", "ClaimedAllOreRE")
        tpTo(getSafeZoneCF())
        task.wait(0.3)
        call("Backpack", "TrySellAllRE")
        Stats.SellCycles = Stats.SellCycles + 1
        task.wait(0.2)
        call("Upgrade", "UpgradeOnceRE", "OrePack")
        task.wait(0.5)
        notify("Safe Zone", "Loot secured (" .. reason .. ")", "shield-check")
        return true
    end
    return false
end

-- ─────────────────────────────────────────────────────────────
-- Combat
-- ─────────────────────────────────────────────────────────────
local function getDungeonManagerEnv()
    local dmEnv, u140 = nil, nil
    pcall(function()
        local dmScript = LocalPlayer.PlayerScripts:FindFirstChild("Manager")
            and LocalPlayer.PlayerScripts.Manager:FindFirstChild("DungeonManager")
        if dmScript and getsenv then
            dmEnv = getsenv(dmScript)
            if dmEnv and debug and debug.getupvalues and dmEnv.CheckFinishedOnce then
                local upvals = debug.getupvalues(dmEnv.CheckFinishedOnce)
                if upvals and type(upvals[1]) == "table" then u140 = upvals[1] end
            end
        end
    end)
    return dmEnv, u140
end

local function instantKillEnemy(enemy)
    if not enemy or not enemy:IsA("Model") then return end
    local uuid = enemy:GetAttribute("UUID") or enemy.Name
    if not uuid then return end
    pcall(function()
        local _, u140 = getDungeonManagerEnv()
        if u140 then
            local pivot = enemy:GetPivot()
            local r = hrp()
            u140.DeadCF = pivot or (r and r.CFrame) or CFrame.new(3482, 23, -4)
        end
    end)
    pcall(function()
        if Bindable_EnemyHit then Bindable_EnemyHit:Fire(uuid, 1e30) end
        if EnemyCTRL then
            if EnemyCTRL.HurtEnemy then EnemyCTRL.HurtEnemy(uuid, 1e30) end
            if EnemyCTRL.DeadEnemyData then EnemyCTRL.DeadEnemyData(uuid) end
        end
        if HPCTRL and HPCTRL.SetCurrentHP then HPCTRL.SetCurrentHP(enemy, 0) end
        enemy:SetAttribute("Dead", true)
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
        Stats.Kills = Stats.Kills + 1
    end)
end

local function instantKillAllEnemies()
    local enemyFolder = workspace:FindFirstChild("EnemyFolder")
    if not enemyFolder then return 0 end
    local killed = 0
    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        if enemy:IsA("Model") and not enemy:GetAttribute("Dead") then
            instantKillEnemy(enemy)
            killed = killed + 1
        end
    end
    return killed
end

local function runKillAura()
    local hitBE = Bindable_EnemyHit or getBindable("Attack", "EnemyHitBE")
    if not hitBE then return end
    local enemyFolder = workspace:FindFirstChild("EnemyFolder")
    if not enemyFolder then return end
    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        if enemy:IsA("Model") and not enemy:GetAttribute("Dead") then
            pcall(function()
                hitBE:Fire(enemy.Name, 99999999, { SkillID = "K_Skill_1_ATK" })
                Stats.Kills = Stats.Kills + 1
            end)
        end
    end
    local superLootFolder = workspace:FindFirstChild("SuperLootFolder")
    if superLootFolder then
        for _, s in ipairs(superLootFolder:GetChildren()) do
            pcall(function()
                hitBE:Fire(s.Name, 99999999, { SkillID = "K_Skill_1_ATK" })
            end)
        end
    end
end

local function runSafeFlight()
    if not State.SafeCombatFlight then return end
    local r = hrp()
    if not r then return end
    local enemyFolder = workspace:FindFirstChild("EnemyFolder")
    local hasEnemies = enemyFolder and #enemyFolder:GetChildren() > 0
    if hasEnemies then
        local firstEnemy = enemyFolder:GetChildren()[1]
        if firstEnemy and firstEnemy:IsA("Model") and firstEnemy.PrimaryPart then
            local enemyPos = firstEnemy.PrimaryPart.Position
            r.AssemblyLinearVelocity = Vector3.zero
            r.CFrame = CFrame.new(enemyPos.X, enemyPos.Y + State.FlightHeight, enemyPos.Z)
        end
    end
end

local function maintainGodMode()
    if State.GodMode then
        pcall(function()
            LocalPlayer:SetAttribute("Invincible", true)
            local hp = HPCTRL or require(ReplicatedStorage.CTRL.HPCTRL)
            hp.SetCurrentHP(LocalPlayer, hp.GetMaxHP(LocalPlayer))
        end)
    end
end

-- ─────────────────────────────────────────────────────────────
-- Super Loot Hunter
-- ─────────────────────────────────────────────────────────────
local huntedBosses = {}
local function checkSuperLootHunter()
    if not State.SuperLootHunter then return end
    local superLootFolder = workspace:FindFirstChild("SuperLootFolder")
    if not superLootFolder or #superLootFolder:GetChildren() == 0 then return end
    for _, bossVal in ipairs(superLootFolder:GetChildren()) do
        local bossRarity = bossVal.Name
        if State.SuperLootTargetTier == "All" or State.SuperLootTargetTier == bossRarity then
            local enemyFolder = workspace:FindFirstChild("EnemyFolder")
            local targetBossModel = nil
            if enemyFolder then
                for _, e in ipairs(enemyFolder:GetChildren()) do
                    if e:GetAttribute("EnemyID") and tostring(e:GetAttribute("EnemyID")):find("Super") then
                        targetBossModel = e
                        break
                    end
                end
            end
            if targetBossModel and targetBossModel.PrimaryPart and not huntedBosses[targetBossModel] then
                Stats.CurrentActivity = "Hunting Super Loot: " .. bossRarity
                notify("Super Loot", "Target: " .. bossRarity, "crosshair")
                tpTo(targetBossModel.PrimaryPart.CFrame + Vector3.new(0, 8, 0))
                task.wait(0.2)
                runKillAura()
                call("SuperLoot", "KillSuperLootRE", targetBossModel.Name)
                Stats.SuperLootKills = Stats.SuperLootKills + 1
                huntedBosses[targetBossModel] = true
                task.wait(0.5)
                runDropMagnet()
                runUltraPrompts()
                break
            end
        end
    end
end

-- ─────────────────────────────────────────────────────────────
-- Dungeon & Stage Loops
-- ─────────────────────────────────────────────────────────────
local function runDungeonLoop()
    if not State.AutoDungeon then return end
    if checkSafeEvacuate() then return end
    local isDungeoning = LocalPlayer:GetAttribute("Dungeoning")
    if not isDungeoning then
        Stats.CurrentActivity = "Entering Dungeon R" .. tostring(State.DungeonRound)
        if State.AutoClaimTicket then call("Dungeon", "TryClaimDailyDunTicRE") end
        local ok = call("Dungeon", "TryIntoDungeonRF", State.DungeonRound)
        task.wait(0.8)
        if ok or LocalPlayer:GetAttribute("Dungeoning") then
            call("Dungeon", "StartRoundRE", State.DungeonRound)
        end
    else
        Stats.CurrentActivity = "Dungeon Wave"
        local dmEnv, u140 = getDungeonManagerEnv()
        if u140 and u140.Round and u140.Round >= 30 and u140.Finished then
            if dmEnv and dmEnv.ExitDungeon then
                pcall(function() dmEnv.ExitDungeon() end)
                task.wait(1.0)
                return
            else
                call("Dungeon", "ExitDungeonRE")
                task.wait(1.0)
                return
            end
        end
        if State.DungeonInstaKill then
            local killed = instantKillAllEnemies()
            if killed > 0 then
                pcall(function()
                    if dmEnv and dmEnv.CheckFinishedOnce then dmEnv.CheckFinishedOnce() end
                end)
            end
        end
        runKillAura()
        if State.DropMagnet then runDropMagnet() end
        if State.UltraPrompt then runUltraPrompts() end
        runSafeFlight()
    end
end

local function runStageLoop()
    if not State.AutoStage then return end
    if LocalPlayer:GetAttribute("Dungeoning") then return end
    if checkSafeEvacuate() then return end
    local targetStageId, stageNum = getTargetStageId()
    Stats.CurrentActivity = "Stage: " .. targetStageId
    LocalPlayer:SetAttribute("StageID", targetStageId)
    local stageFinishedRF = getRemote("Stage", "StageFinishedRF")
    local getOreRF        = getRemote("Stage", "GetOreRF")
    local claimedAllOreRE = getRemote("Stage", "ClaimedAllOreRE")
    if stageFinishedRF and stageFinishedRF:IsA("RemoteFunction") then
        local ok, ores = pcall(function() return stageFinishedRF:InvokeServer(targetStageId) end)
        if ok and type(ores) == "table" then
            if getOreRF and getOreRF:IsA("RemoteFunction") then
                for oreUuid in pairs(ores) do
                    Stats.OresCollected = Stats.OresCollected + 1
                    pcall(function() getOreRF:InvokeServer(oreUuid) end)
                end
            end
            if claimedAllOreRE then pcall(function() claimedAllOreRE:FireServer() end) end
            Stats.LastStageClear = os.time()
        end
    end
    local intoFight = LocalPlayer:GetAttribute("IntoFight")
    if intoFight then
        Stats.CurrentActivity = "Fighting: " .. targetStageId
        if State.StageInstaKill then instantKillAllEnemies() end
        runKillAura()
        runSafeFlight()
    end
    if State.DropMagnet then runDropMagnet() end
    if State.UltraPrompt then runUltraPrompts() end
end

local _isBlitzingStages = false
local function runStageBlitz()
    if _isBlitzingStages then return end
    if LocalPlayer:GetAttribute("Dungeoning") then return end
    if checkSafeEvacuate() then return end
    local stageFinishedRF = getRemote("Stage", "StageFinishedRF")
    local getOreRF        = getRemote("Stage", "GetOreRF")
    local claimedAllOreRE = getRemote("Stage", "ClaimedAllOreRE")
    if not (stageFinishedRF and stageFinishedRF:IsA("RemoteFunction")) then return end
    pcall(disengageIdleTraining)
    _isBlitzingStages = true
    Stats.CurrentActivity = "GOD-Farm Blitz 1-30"
    task.spawn(function()
        for i = 1, 30 do
            if not (State.GodFarmStageBlitz or (State.Master247 and State.MasterStageBlitz)) then break end
            if LocalPlayer:GetAttribute("Dungeoning") then break end
            if checkSafeEvacuate() then break end
            local stageId = "Stage_" .. i
            local ok, ores = pcall(function() return stageFinishedRF:InvokeServer(stageId) end)
            if ok and type(ores) == "table" then
                if getOreRF and getOreRF:IsA("RemoteFunction") then
                    for oreUuid in pairs(ores) do
                        Stats.OresCollected = Stats.OresCollected + 1
                        pcall(function() getOreRF:InvokeServer(oreUuid) end)
                    end
                end
                if claimedAllOreRE then pcall(function() claimedAllOreRE:FireServer() end) end
                Stats.LastStageClear = os.time()
            end
            task.wait(State.StageBlitzInterval or 0.09)
        end
        if State.DropMagnet then pcall(runDropMagnet) end
        if State.UltraPrompt then pcall(runUltraPrompts) end
        _isBlitzingStages = false
    end)
end

local _lastSwordTrainTick = 0
local function runSwordClickFarm()
    local now = os.clock()
    local delay = tonumber(State.SwordClickDelay) or 0.16
    if now - _lastSwordTrainTick < delay then return end
    _lastSwordTrainTick = now
    if State.ForceVIPTrain then
        LocalPlayer:SetAttribute("AutoTrainAreaID", 9)
        call("Train", "IntoAutoTrainRE", 9)
    end
    local tc = TrainCTRL or (ReplicatedStorage:FindFirstChild("CTRL") and require(ReplicatedStorage.CTRL.TrainCTRL))
    if tc and type(tc.TrainOnce) == "function" then
        pcall(tc.TrainOnce)
    else
        call("Train", "TrainOnceRE")
    end
end

-- ─────────────────────────────────────────────────────────────
-- Class Gacha (simplified)
-- ─────────────────────────────────────────────────────────────
local function runClassAndSkillRoll()
    if State.AutoRollClass then
        local idx = call("Class", "GetEquipedIndex") or "1"
        call("Class", "LuckOnceRE", idx)
    end
    if State.AutoRollSkills then
        call("Backpack", "LuckSkillCell_2RE")
    end
end

local function runPotionAndHatch()
    if State.AutoUsePotions then
        pcall(function()
            local BuffData = require(ReplicatedStorage.LocalData.BuffData)
            for _, pot in ipairs(Dynamic.Potions) do
                if not BuffData.IsHaveBuff(pot) then
                    call("Potion", "TryUsePotionRE", pot)
                    task.wait(0.1)
                end
            end
        end)
    end
    if State.AutoHatchEggs then
        call("Egg", "PutEggRE")
    end
end

-- ─────────────────────────────────────────────────────────────
-- Master Engine
-- ─────────────────────────────────────────────────────────────
local _masterUpgradeTick = 0
local _masterForgeTick   = 0
local _masterClaimTick   = 0
local _masterEnchantTick = 0

local function runMaster247Engine()
    if not State.Master247 then return end
    if checkSafeEvacuate() then task.wait(0.8); return end
    if State.SuperLootHunter then pcall(checkSuperLootHunter) end
    local now = os.clock()
    if now - _masterClaimTick >= 60 then
        _masterClaimTick = now
        pcall(function()
            call("Offline", "TryClaimOfflineRewardRE")
            call("Dungeon", "TryClaimDailyDunTicRE")
            for i = 1, 12 do call("Online", "TryClaimRE", i) end
        end)
    end
    local hasTickets = false
    pcall(function()
        local bd = require(ReplicatedStorage.LocalData.BackpackData)
        local t = bd.GetItemDataByIDType and bd.GetItemDataByIDType("Dungeon_Ticket", "Material")
        hasTickets = t and (tonumber(t.Number) or 0) > 0
    end)
    if hasTickets and State.MasterDungeonTicket then
        State.AutoDungeon = true
        State.AutoStage   = false
        pcall(runDungeonLoop)
    else
        State.AutoDungeon = false
        State.AutoStage   = true
        if State.MasterStageBlitz or State.GodFarmStageBlitz then
            pcall(runStageBlitz)
        else
            pcall(runStageLoop)
        end
    end
    if State.MasterAutoClickSword then pcall(runSwordClickFarm) end
    local inFight  = LocalPlayer:GetAttribute("IntoFight")
    local inDung   = LocalPlayer:GetAttribute("Dungeoning")
    if State.MasterTrainWhenIdle and not inFight and not inDung then
        if State.ForceVIPTrain then
            pcall(engageIdleTraining)
        else
            if State.AutoTrainBestZone then pcall(enterTrainZone) end
            local tc = TrainCTRL or (ReplicatedStorage:FindFirstChild("CTRL") and require(ReplicatedStorage.CTRL.TrainCTRL))
            if tc and type(tc.TrainOnce) == "function" then
                pcall(tc.TrainOnce)
            else
                call("Train", "TrainOnceRE")
            end
        end
    end
    if State.DropMagnet then pcall(runDropMagnet) end
    if State.UltraPrompt then pcall(runUltraPrompts) end
    if State.MasterAutoUpgrade and (now - _masterUpgradeTick >= 3) then
        _masterUpgradeTick = now
        pcall(function()
            if State.UpgradeType == "All in One" then
                call("Upgrade", "UpgradeOnceRE", "Train")
                call("Upgrade", "UpgradeOnceRE", "OrePack")
                call("Upgrade", "UpgradeOnceRE", "Luck")
            elseif State.AutoUpgrade then
                call("Upgrade", "UpgradeOnceRE", State.UpgradeType)
            end
        end)
    end
    if State.MasterAutoForgeWhenReady and State.AutoForge and (now - _masterForgeTick >= 2) then
        _masterForgeTick = now
        pcall(function()
            local items = getBackpackItems()
            if not items then return end
            local totalOres = 0
            for _, item in pairs(items) do
                if type(item) == "table" and item.Type == "Ore" then
                    totalOres = totalOres + (tonumber(item.Number) or 1)
                end
            end
            if totalOres >= State.MinOreToForge then
                local ok = executeForgeNow(State.ForgeType, State.MinOreToForge)
                if ok then
                    task.delay(0.3, function() pcall(function() equipBestGearNow("All") end) end)
                end
            end
        end)
    end
    if State.AutoEquipBest then pcall(function() equipBestGearNow("All") end) end
    if State.AutoEnchant and (now - _masterEnchantTick >= (State.EnchantDelay or 2.0)) then
        _masterEnchantTick = now
        pcall(autoEnchantEquippedGear)
    end
    if State.AutoRebirth then
        pcall(function()
            call("Rebirth", "TryRebirthRE")
            Stats.RebirthCount = Stats.RebirthCount + 1
        end)
    end
    pcall(runPotionAndHatch)
    pcall(runClassAndSkillRoll)
end

local function claimAllRewards()
    call("Offline", "TryClaimOfflineRewardRE")
    for i = 1, 12 do
        call("Online", "TryClaimRE", i)
        task.wait(0.05)
    end
    call("UpdateLog", "TryClaimUPDRewardRE")
    call("Dungeon", "TryClaimDailyDunTicRE")
    call("EnhantEvent", "TryClaimQuestRE")
    call("Index", "TryClaimIndexExpRF")
    call("Index", "TryClaimLevelRewardRF")
end

-- ─────────────────────────────────────────────────────────────
-- Selective Sell
-- ─────────────────────────────────────────────────────────────
local RARITY_RANK = {
    Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5,
    Mythic = 6, Eternal = 7, Secret = 8, Ancient = 9, Infinite = 10,
}

local function getItemRarityLevel(item)
    if not item or type(item) ~= "table" then return 1 end
    local rarity = nil
    if item.Type == "Weapon" and WeaponHelper and WeaponHelper.GetRarity then
        pcall(function() rarity = WeaponHelper.GetRarity(item.ID) or rarity end)
    elseif (item.Type == "Armor" or item.Type == "Hat") and ArmorHelper and ArmorHelper.GetRarity then
        pcall(function() rarity = ArmorHelper.GetRarity(item.ID) or rarity end)
    elseif item.Type == "Ore" and OreHelper and OreHelper.GetRarity then
        pcall(function() rarity = OreHelper.GetRarity(item.ID) or rarity end)
    elseif (item.Type == "EnchStone" or (item.ID and item.ID:find("Stone"))) and EnchStoneHelper and EnchStoneHelper.GetRarity then
        pcall(function() rarity = EnchStoneHelper.GetRarity(item.ID) or rarity end)
    end
    if not rarity and item.Rarity then rarity = item.Rarity end
    if not rarity and item.ID then
        for _, rName in ipairs({ "Infinite", "Ancient", "Secret", "Eternal", "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common" }) do
            if string.find(string.lower(item.ID), string.lower(rName), 1, true) then
                rarity = rName
                break
            end
        end
    end
    return RARITY_RANK[rarity] or 1
end

local function sellTrashGearNow()
    if not BackpackData then return 0 end
    local bp = nil
    pcall(function() bp = BackpackData.GetData() end)
    if not bp or not bp.have then return 0 end
    if State.AutoEquipBest then
        pcall(function() equipBestGearNow("All") end)
        task.wait(0.08)
    end
    local keepThreshold = RARITY_RANK[State.MinGearRarityToKeep] or 5
    local unequippedGears = {}
    for uuid, item in pairs(bp.have) do
        if type(item) == "table" and (item.Type == "Weapon" or item.Type == "Armor" or item.Type == "Hat") then
            local isEquipped = false
            pcall(function()
                if BackpackData.IsEquipedUUID then
                    isEquipped = BackpackData.IsEquipedUUID(uuid)
                end
            end)
            if not isEquipped then
                local score = 0
                pcall(function() score = itemGearScore(item) end)
                table.insert(unequippedGears, { uuid = uuid, item = item, score = score, rarity = getItemRarityLevel(item) })
            end
        end
    end
    table.sort(unequippedGears, function(a, b) return a.score > b.score end)
    local protectedUuids = {}
    for i = 1, math.min(7, #unequippedGears) do
        protectedUuids[unequippedGears[i].uuid] = true
    end
    local soldCount = 0
    for _, gear in ipairs(unequippedGears) do
        if not protectedUuids[gear.uuid] and gear.rarity < keepThreshold then
            pcall(function() call("Backpack", "TrySellItemRE", gear.uuid, 1) end)
            soldCount = soldCount + 1
            task.wait(0.02)
        end
    end
    return soldCount
end

local LEVEL_TO_RARITY = {
    [1] = "Common", [2] = "UnCommon", [3] = "Rare", [4] = "Epic",
    [5] = "Legendary", [6] = "Mythic", [7] = "Eternal", [8] = "Secret",
    [9] = "Ancient", [10] = "Infinite",
}

local function cleanRarityText(txt)
    if not txt or type(txt) ~= "string" then return "Common" end
    local lower = txt:lower()
    if lower:find("infinite") then return "Infinite" end
    if lower:find("ancient") then return "Ancient" end
    if lower:find("secret") then return "Secret" end
    if lower:find("eternal") then return "Eternal" end
    if lower:find("mythic") then return "Mythic" end
    if lower:find("legendary") then return "Legendary" end
    if lower:find("epic") then return "Epic" end
    if lower:find("rare") then return "Rare" end
    if lower:find("uncommon") then return "UnCommon" end
    if lower:find("common") then return "Common" end
    return "Common"
end

local function sellOresNow()
    local bp = getBackpackItems()
    if not bp then return 0 end
    local keptRanks = {}
    for _, str in ipairs(State.OreRaritiesToKeep or {}) do
        keptRanks[cleanRarityText(str)] = true
    end
    local sold = 0
    local minKeep = tonumber(State.KeepMinOreAmount) or 0
    for uuid, item in pairs(bp) do
        if type(item) == "table" and item.Type == "Ore" then
            local rLevel = getItemRarityLevel(item)
            local rName = LEVEL_TO_RARITY[rLevel] or "Common"
            if not keptRanks[rName] then
                local curCount = tonumber(item.Number or item.Count) or 1
                local sellQty = (minKeep > 0) and (curCount - minKeep) or curCount
                if sellQty > 0 then
                    pcall(function() call("Backpack", "TrySellItemRE", uuid, sellQty) end)
                    sold = sold + sellQty
                    task.wait(0.02)
                end
            end
        end
    end
    return sold
end

local function sellEnchantStonesNow()
    local bp = getBackpackItems()
    if not bp then return 0 end
    local targetRanks = {}
    for _, str in ipairs(State.EnchantRaritiesToTarget or {}) do
        targetRanks[cleanRarityText(str)] = true
    end
    local isSellSelected = not State.EnchantFilterMode or State.EnchantFilterMode:find("Sell")
    local sold = 0
    local minKeep = tonumber(State.KeepMinStoneAmount) or 0
    for uuid, item in pairs(bp) do
        if type(item) == "table" and (item.Type == "EnchStone" or (item.ID and tostring(item.ID):find("Stone"))) then
            local rLevel = getItemRarityLevel(item)
            local rName = LEVEL_TO_RARITY[rLevel] or "Common"
            local shouldSell = isSellSelected and (targetRanks[rName] == true) or (not isSellSelected and not targetRanks[rName])
            if shouldSell then
                local curCount = tonumber(item.Number or item.Count) or 1
                local sellQty = (minKeep > 0) and (curCount - minKeep) or curCount
                if sellQty > 0 then
                    pcall(function() call("Backpack", "TrySellItemRE", uuid, sellQty) end)
                    sold = sold + sellQty
                    task.wait(0.02)
                end
            end
        end
    end
    return sold
end

local function equipBestPet()
    pcall(function()
        local bp = getBackpackItems()
        if not bp then return end
        local bestUUID, bestPower = nil, -1
        for uuid, item in pairs(bp) do
            if type(item) == "table" and item.ID then
                local isPet = item.Type == "Pet" or tostring(item.ID):lower():find("pet")
                if isPet then
                    local power = getItemRarityLevel(item) * 100000 + (tonumber(item.Level) or 0) * 100
                    if power > bestPower then bestUUID = uuid; bestPower = power end
                end
            end
        end
        if bestUUID then
            call("Pet", "TryEquipPetRE", bestUUID)
            call("Backpack", "TryEquipPetRE", bestUUID)
        end
    end)
end

local function fetchOnlineCodes()
    local list = { "RELEASE", "LOOT", "FORGE", "ENHANCE", "UPDATE1", "FREEGEMS", "LIKE1000" }
    return list
end

local function redeemAllOnlineCodes(silent)
    local activeCodes = fetchOnlineCodes()
    local count = 0
    State.RedeemedCodes = State.RedeemedCodes or {}
    for _, c in ipairs(activeCodes) do
        if not State.RedeemedCodes[c] then
            pcall(function() call("Code", "TryUseCodeRF", c) end)
            State.RedeemedCodes[c] = true
            count = count + 1
            task.wait(0.25)
        end
    end
    if not silent then
        notify("Codes", "Redeemed " .. tostring(count) .. " codes!", "check-circle")
    end
    return count
end

local function applyAntiTrip(humanoid)
    if not humanoid then return end
    pcall(function()
        if State.AntiTrip ~= false then
            humanoid.MaxSlopeAngle = 89
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(c)
    local h = c:WaitForChild("Humanoid", 8)
    if h and State.AntiTrip then applyAntiTrip(h) end
end)

-- ═════════════════════════════════════════════════════════════
--  ★ MODERN NEON UI ENGINE v6.0
-- ═════════════════════════════════════════════════════════════
local MaruUI = {}
MaruUI.Themes = {
    ["Neon Cyan"]    = { primary = Color3.fromRGB(0, 255, 240), secondary = Color3.fromRGB(0, 130, 200), glow = Color3.fromRGB(0, 255, 240) },
    ["Neon Purple"]  = { primary = Color3.fromRGB(190, 90, 255), secondary = Color3.fromRGB(120, 30, 200), glow = Color3.fromRGB(190, 90, 255) },
    ["Neon Pink"]    = { primary = Color3.fromRGB(255, 60, 160), secondary = Color3.fromRGB(200, 20, 100), glow = Color3.fromRGB(255, 60, 160) },
    ["Neon Green"]   = { primary = Color3.fromRGB(0, 255, 120), secondary = Color3.fromRGB(0, 180, 80), glow = Color3.fromRGB(0, 255, 120) },
    ["Neon Orange"]  = { primary = Color3.fromRGB(255, 130, 0), secondary = Color3.fromRGB(200, 80, 0), glow = Color3.fromRGB(255, 130, 0) },
    ["Neon Red"]     = { primary = Color3.fromRGB(255, 60, 90), secondary = Color3.fromRGB(180, 20, 50), glow = Color3.fromRGB(255, 60, 90) },
    ["Neon Blue"]    = { primary = Color3.fromRGB(60, 150, 255), secondary = Color3.fromRGB(30, 80, 200), glow = Color3.fromRGB(60, 150, 255) },
    ["Neon Yellow"]  = { primary = Color3.fromRGB(255, 230, 60), secondary = Color3.fromRGB(200, 170, 20), glow = Color3.fromRGB(255, 230, 60) },
}
MaruUI.ThemeNames = { "Neon Cyan", "Neon Purple", "Neon Pink", "Neon Green", "Neon Orange", "Neon Red", "Neon Blue", "Neon Yellow" }
MaruUI.Theme = "Neon Cyan"

function MaruUI.create(opts)
    opts = opts or {}
    if _G.MaruHubCleanup then pcall(_G.MaruHubCleanup) end

    local Window = { Tabs = {} }
    local conns, renders, tabs = {}, {}, {}
    local theme = MaruUI.Themes[opts.Theme or MaruUI.Theme] or MaruUI.Themes["Neon Cyan"]
    local accent = theme.primary

    -- Neon Glassmorphism palette
    local C = {
        bgDeep     = Color3.fromRGB(8, 8, 14),
        bgGlass    = Color3.fromRGB(14, 14, 22),
        card       = Color3.fromRGB(20, 20, 32),
        cardHi     = Color3.fromRGB(30, 30, 46),
        line       = Color3.fromRGB(50, 50, 70),
        lineGlow   = theme.glow,
        text       = Color3.fromRGB(240, 245, 255),
        textSub    = Color3.fromRGB(150, 160, 190),
        textDim    = Color3.fromRGB(100, 110, 140),
        off        = Color3.fromRGB(45, 45, 65),
        success    = Color3.fromRGB(0, 220, 130),
        warn       = Color3.fromRGB(255, 190, 60),
        danger     = Color3.fromRGB(255, 80, 100),
    }

    local function track(c) table.insert(conns, c); return c end
    local function onAccent(fn) table.insert(renders, fn); pcall(fn) end
    local function applyAccent() for _, fn in ipairs(renders) do pcall(fn) end end

    local function new(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props or {}) do o[k] = v end
        if parent then o.Parent = parent end
        return o
    end
    local function round(o, r) return new("UICorner", { CornerRadius = UDim.new(0, r) }, o) end
    local function stroke(o, color, th, tr)
        return new("UIStroke", {
            Color = color or C.line, Thickness = th or 1, Transparency = tr or 0,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }, o)
    end
    local function pad(o, l, t, r, b)
        new("UIPadding", {
            PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t),
            PaddingRight = UDim.new(0, r or l), PaddingBottom = UDim.new(0, b or t)
        }, o)
    end
    local function list(o, gap)
        return new("UIListLayout", { Padding = UDim.new(0, gap or 6), SortOrder = Enum.SortOrder.LayoutOrder }, o)
    end
    local function label(parent, text, size, color, font, xa)
        return new("TextLabel", {
            BackgroundTransparency = 1, Text = tostring(text or ""), TextColor3 = color or C.text,
            Font = font or Enum.Font.GothamMedium, TextSize = size or 13,
            TextXAlignment = xa or Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true, TextTruncate = Enum.TextTruncate.None,
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        }, parent)
    end

    -- ★ Gradient builder
    local function gradient(parent, c1, c2, rot)
        return new("UIGradient", {
            Rotation = rot or 0,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, c1),
                ColorSequenceKeypoint.new(1, c2),
            }),
        }, parent)
    end

    -- ★ Glow effect
    local function glowStroke(o, color, th)
        local g = stroke(o, color, th or 2, 0.3)
        g.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        return g
    end

    -- [FIX] Safe cloneref
    local cloneref_ = cloneref or function(i) return i end
    local function getParent()
        if gethui then
            local ok, h = pcall(gethui)
            if ok and typeof(h) == "Instance" then return h end
        end
        local cg
        pcall(function()
            local raw = game:GetService("CoreGui")
            if raw then cg = cloneref_(raw) end
        end)
        if cg and typeof(cg) == "Instance" then
            local ok = pcall(function()
                local t = Instance.new("Folder")
                t.Parent = cg
                t:Destroy()
            end)
            if ok then return cg end
        end
        return LocalPlayer:WaitForChild("PlayerGui", 10)
    end
    local guiParent = getParent()

    for _, root in ipairs({ guiParent, LocalPlayer:FindFirstChild("PlayerGui") }) do
        if root then
            for _, nm in ipairs({ "MaruHubUI", "MaruHub_Float", "MaruHub_NeonBG" }) do
                local old = root:FindFirstChild(nm)
                if old then pcall(function() old:Destroy() end) end
            end
        end
    end

    local gui = new("ScreenGui", {
        Name = "MaruHubUI", ResetOnSpawn = false, IgnoreGuiInset = true,
        DisplayOrder = 2147483647, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    gui.Parent = guiParent

    -- ═══════ MAIN WINDOW ═══════
    local main = new("Frame", {
        Name = "MainFrame", Size = UDim2.fromScale(0.75, 0.9),
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor3 = C.bgDeep, BorderSizePixel = 0, Visible = true, Active = true,
    }, gui)
    round(main, 20)
    new("UISizeConstraint", { MaxSize = Vector2.new(700, 480), MinSize = Vector2.new(400, 300) }, main)
    local scaleObj = new("UIScale", { Scale = 1 }, main)
    local mainGlow = glowStroke(main, accent, 2.5)
    local mainGradient = gradient(main, C.bgDeep, C.bgGlass, 90)

    -- ═══════ HEADER ═══════
    local header = new("Frame", {
        Name = "Header", Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = C.bgGlass, BorderSizePixel = 0,
    }, main)
    round(header, 20)
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, 40),
        BackgroundColor3 = C.bgDeep, BorderSizePixel = 0, ZIndex = 2,
    }, header)
    gradient(header, C.bgGlass, C.bgDeep, 90)

    -- ═══════ LOGO (Neon Diamond) ═══════
    local logoBox = new("Frame", {
        Size = UDim2.fromOffset(40, 40), Position = UDim2.fromOffset(16, 10),
        BackgroundColor3 = accent, BorderSizePixel = 0, Rotation = 45, ZIndex = 3,
    }, header)
    round(logoBox, 10)
    local logoGrad = gradient(logoBox, theme.primary, theme.secondary, 90)
    onAccent(function()
        logoBox.BackgroundColor3 = accent
        logoGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.primary),
            ColorSequenceKeypoint.new(1, theme.secondary),
        })
    end)
    new("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Text = "M", TextColor3 = C.bgDeep, TextSize = 22,
        Font = Enum.Font.GothamBlack, Rotation = -45, ZIndex = 4,
    }, logoBox)

    -- ═══════ TITLE ═══════
    local titleLbl = new("TextLabel", {
        Name = "Title", Size = UDim2.new(0, 260, 0, 26), Position = UDim2.fromOffset(70, 10),
        Text = tostring(opts.Title or "Maru Hub"), TextColor3 = C.text, TextSize = 22,
        Font = Enum.Font.GothamBlack, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, ZIndex = 3,
    }, header)
    new("UIGradient", {
        Rotation = 0,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, accent),
            ColorSequenceKeypoint.new(1, C.text),
        }),
    }, titleLbl)
    onAccent(function()
        titleLbl:FindFirstChildOfClass("UIGradient").Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, accent),
            ColorSequenceKeypoint.new(1, C.text),
        })
    end)

    -- ═══════ SUBTITLE (Neon pill) ═══════
    local subPill = new("Frame", {
        Size = UDim2.fromOffset(220, 18), Position = UDim2.fromOffset(70, 36),
        BackgroundColor3 = C.card, BorderSizePixel = 0, ZIndex = 3,
    }, header)
    round(subPill, 6)
    local subGrad = gradient(subPill, C.card, C.cardHi, 0)
    local subLbl = new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = tostring(opts.Subtitle or "Neon Automation Hub"),
        TextColor3 = C.textSub, TextSize = 10, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 4,
    }, subPill)

    -- ═══════ VERSION PILL ═══════
    local verPill = new("Frame", {
        Size = UDim2.fromOffset(66, 26), AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -52, 0.5, 0),
        BackgroundColor3 = C.card, BorderSizePixel = 0, ZIndex = 3,
    }, header)
    round(verPill, 13)
    local verStroke = glowStroke(verPill, accent, 1.5)
    local verTxt = new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = tostring(opts.Version or "v6.0"), TextColor3 = accent,
        TextSize = 11, Font = Enum.Font.GothamBlack, ZIndex = 4,
    }, verPill)
    onAccent(function()
        verStroke.Color = accent
        verTxt.TextColor3 = accent
    end)

    -- ═══════ CLOSE BUTTON ═══════
    local closeBtn = new("TextButton", {
        Name = "CloseBtn", Size = UDim2.fromOffset(32, 32), AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0), BackgroundColor3 = C.card,
        Text = "✕", TextColor3 = accent, TextSize = 14, Font = Enum.Font.GothamBlack,
        AutoButtonColor = false, ZIndex = 3,
    }, header)
    round(closeBtn, 8)
    local closeStroke = glowStroke(closeBtn, accent, 1.5)
    track(closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(40, 15, 25) }):Play()
    end))
    track(closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.card }):Play()
    end))
    onAccent(function()
        closeStroke.Color = accent
        closeBtn.TextColor3 = accent
    end)

    -- ═══════ CONTENT AREA ═══════
    local contentFrame = new("Frame", {
        Name = "Content", Size = UDim2.new(1, -20, 1, -74), Position = UDim2.fromOffset(10, 64),
        BackgroundColor3 = C.bgGlass, BorderSizePixel = 0, ClipsDescendants = true,
    }, main)
    round(contentFrame, 14)
    stroke(contentFrame, C.line, 1, 0.5)

    -- ═══════ SIDEBAR ═══════
    local sidebar = new("ScrollingFrame", {
        Position = UDim2.fromOffset(8, 8), Size = UDim2.new(0, 170, 1, -16),
        BackgroundColor3 = C.bgDeep, BackgroundTransparency = 0.3,
        BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, ClipsDescendants = true,
    }, contentFrame)
    round(sidebar, 12)
    stroke(sidebar, C.line, 1, 0.5)
    pad(sidebar, 6, 6, 6, 6); list(sidebar, 5)

    -- ═══════ CONTENT PANEL ═══════
    local content = new("ScrollingFrame", {
        Position = UDim2.fromOffset(186, 8), Size = UDim2.new(1, -194, 1, -16),
        BackgroundColor3 = C.bgDeep, BackgroundTransparency = 0.3,
        BorderSizePixel = 0, ScrollBarThickness = 4, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, ClipsDescendants = true,
    }, contentFrame)
    round(content, 12)
    stroke(content, C.line, 1, 0.5)

    onAccent(function()
        sidebar.ScrollBarImageColor3 = accent
        content.ScrollBarImageColor3 = accent
        mainGlow.Color = accent
    end)

    -- ═══════ DRAGGABLE ═══════
    local function makeDraggable(handle, target, onTap)
        local dragging, moved, dragStart, startPos = false, false, nil, nil
        track(handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging, moved = true, false
                dragStart, startPos = input.Position, target.Position
                local ended
                ended = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        ended:Disconnect()
                        dragging = false
                        if not moved and onTap then onTap() end
                    end
                end)
            end
        end))
        track(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local d = input.Position - dragStart
                if d.Magnitude > 6 then moved = true end
                if moved then
                    local s = (target == main) and scaleObj.Scale or 1
                    target.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + d.X / s,
                        startPos.Y.Scale, startPos.Y.Offset + d.Y / s
                    )
                end
            end
        end))
    end
    makeDraggable(header, main, nil)

    -- ═══════ OPEN / CLOSE ═══════
    local lastToggle = 0
    function Window:Open()
        scaleObj.Scale = 0.92
        main.Visible = true
        TweenService:Create(scaleObj, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    end
    function Window:Close() main.Visible = false end
    function Window:Toggle()
        local now = tick()
        if now - lastToggle < 0.2 then return end
        lastToggle = now
        if main.Visible then Window:Close() else Window:Open() end
    end
    track(closeBtn.MouseButton1Click:Connect(function() Window:Close() end))

    -- ═══════ FLOATING BUTTON (Neon) ═══════
    local BTN_SIZE = 62
    local floatBtn = new("TextButton", {
        Name = "FloatingToggleButton", Size = UDim2.fromOffset(BTN_SIZE, BTN_SIZE),
        Position = UDim2.new(0, 20, 0.5, -BTN_SIZE / 2),
        BackgroundColor3 = C.bgDeep, BorderSizePixel = 0,
        Text = "", AutoButtonColor = false, Active = true,
    }, gui)
    round(floatBtn, 18)
    local floatGlow = glowStroke(floatBtn, accent, 2.5)

    local floatInner = new("Frame", {
        Size = UDim2.new(1, -8, 1, -8), Position = UDim2.fromOffset(4, 4),
        BackgroundColor3 = C.card, BorderSizePixel = 0,
    }, floatBtn)
    round(floatInner, 14)
    gradient(floatInner, C.card, C.cardHi, 90)

    local floatText = new("TextLabel", {
        Size = UDim2.fromScale(1, 1), Text = "M", TextColor3 = accent,
        TextSize = 30, Font = Enum.Font.GothamBlack, BackgroundTransparency = 1, ZIndex = 2,
    }, floatBtn)

    local floatDot = new("Frame", {
        Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = C.success, BorderSizePixel = 0, ZIndex = 3,
    }, floatBtn)
    round(floatDot, 6)
    stroke(floatDot, C.bgDeep, 2, 0)

    -- Pulsing animation
    task.spawn(function()
        while floatBtn.Parent do
            pcall(function()
                local tween = TweenService:Create(floatGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                    Transparency = 0.6
                })
                tween:Play()
            end)
            task.wait(2.5)
        end
    end)

    onAccent(function()
        floatGlow.Color = accent
        floatText.TextColor3 = accent
    end)

    makeDraggable(floatBtn, floatBtn, function() Window:Toggle() end)

    -- ═══════ NOTIFICATION ═══════
    local toastBox = new("Frame", {
        Size = UDim2.new(0, 360, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0.5, -180, 0, 14), BackgroundTransparency = 1,
    }, gui)
    list(toastBox, 10)

    function Window:Notify(ttl, msg)
        local t = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = C.bgGlass, BorderSizePixel = 0,
            BackgroundTransparency = 0.05,
        }, toastBox)
        round(t, 14)
        local tGlow = glowStroke(t, accent, 2)
        pad(t, 16, 12, 16, 12)
        gradient(t, C.bgGlass, C.card, 90)

        local accentBar = new("Frame", {
            Size = UDim2.new(0, 4, 1, 0), Position = UDim2.fromOffset(0, 0),
            BackgroundColor3 = accent, BorderSizePixel = 0, ZIndex = 2,
        }, t)
        round(accentBar, 2)

        local innerF = new("Frame", {
            Size = UDim2.new(1, -12, 0, 0), Position = UDim2.fromOffset(14, 0),
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        }, t)
        list(innerF, 4)

        local titleLbl = label(innerF, ttl, 14, accent, Enum.Font.GothamBlack)
        label(innerF, msg, 12, C.text, Enum.Font.GothamMedium)

        onAccent(function()
            tGlow.Color = accent
            accentBar.BackgroundColor3 = accent
            titleLbl.TextColor3 = accent
        end)

        TweenService:Create(t, TweenInfo.new(0.2), { BackgroundTransparency = 0.05 }):Play()
        task.delay(3.5, function()
            pcall(function()
                TweenService:Create(t, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                task.wait(0.3)
                t:Destroy()
            end)
        end)
    end

    -- ═══════ TAB SYSTEM ═══════
    local function selectTab(tab)
        for _, t in ipairs(tabs) do
            t.page.Visible = (t == tab)
            t.selected = (t == tab)
            pcall(t.render)
        end
        content.CanvasPosition = Vector2.new(0, 0)
        Window.ActiveTab = tab
    end

    function Window:SelectTab(target)
        if type(target) == "number" then target = tabs[target] end
        if target then selectTab(target) end
    end

    function Window:Tab(config)
        config = config or {}
        local tab = { order = 0, selected = false }

        -- ═══ TAB PAGE ═══
        tab.page = new("Frame", {
            Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -36, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = false,
        }, content)
        pad(tab.page, 0, 14, 0, 16)
        list(tab.page, 12)

        -- ═══ PAGE HEADER ═══
        local head = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = 0,
        }, tab.page)
        list(head, 8)
        local headTitle = label(head, config.Title or "", 22, C.text, Enum.Font.GothamBlack)
        local headBar = new("Frame", { Size = UDim2.fromOffset(56, 4), BorderSizePixel = 0, BackgroundColor3 = accent }, head)
        round(headBar, 2)
        local headBarGrad = gradient(headBar, accent, theme.secondary, 0)

        -- ═══ TAB BUTTON (Sidebar) ═══
        local btn = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = C.card,
            BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
            BorderSizePixel = 0, LayoutOrder = #tabs + 1,
        }, sidebar)
        round(btn, 12)
        local btnStroke = stroke(btn, accent, 1, 1)
        local btnGrad = gradient(btn, C.cardHi, C.card, 0)
        btnGrad.Transparency = NumberSequence.new(1)

        local mark = new("Frame", {
            Size = UDim2.new(0, 3, 0, 28), Position = UDim2.new(0, 0, 0.5, -14),
            BorderSizePixel = 0, Visible = false, BackgroundColor3 = accent,
        }, btn)
        round(mark, 2)
        local markGlow = glowStroke(mark, accent, 1, 0.3)

        local icon = new("TextLabel", {
            Size = UDim2.fromOffset(36, 48), Position = UDim2.fromOffset(10, 0),
            BackgroundTransparency = 1, Text = config.Icon or "•", TextColor3 = accent,
            TextSize = 20, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center,
        }, btn)

        local txt = new("TextLabel", {
            Size = UDim2.new(1, -56, 1, 0), Position = UDim2.fromOffset(50, 0),
            BackgroundTransparency = 1, Text = config.Short or config.Title or "",
            TextColor3 = C.textSub, TextSize = 12, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        }, btn)

        tab.render = function()
            btn.BackgroundTransparency = tab.selected and 0.1 or 1
            btnGrad.Transparency = NumberSequence.new(tab.selected and 0.4 or 1)
            btnStroke.Transparency = tab.selected and 0.4 or 1
            mark.Visible = tab.selected
            txt.TextColor3 = tab.selected and C.text or C.textSub
            icon.TextColor3 = tab.selected and accent or C.textDim
        end
        onAccent(tab.render)
        track(btn.MouseButton1Click:Connect(function() selectTab(tab) end))
        table.insert(tabs, tab)
        table.insert(Window.Tabs, tab)
        if #tabs == 1 then selectTab(tab) end

        local adapter = { Native = tab }
        local function nextOrder() tab.order = tab.order + 1; return tab.order end

        -- ═══ CARD BUILDER ═══
        local function newCard(asButton)
            local c = new(asButton and "TextButton" or "Frame", {
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = C.card, BackgroundTransparency = 0.15,
                BorderSizePixel = 0, LayoutOrder = nextOrder(),
            }, tab.page)
            if asButton then c.Text = ""; c.AutoButtonColor = false end
            round(c, 14)
            stroke(c, C.line, 1, 0.4)
            pad(c, 16, 14, 16, 14)
            new("UISizeConstraint", { MinSize = Vector2.new(0, 60) }, c)
            gradient(c, C.card, C.cardHi, 90)
            return c
        end

        local function infoBlock(parent, titleText, descText, rightPad)
            local info = new("Frame", {
                Size = UDim2.new(1, -(rightPad or 0), 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
            }, parent)
            list(info, 5)
            label(info, titleText, 14, C.text, Enum.Font.GothamBold)
            if descText and tostring(descText) ~= "" then
                label(info, descText, 11, C.textSub, Enum.Font.Gotham)
            end
            return info
        end

        -- ═══ SECTION ═══
        function adapter:Section(o)
            local f = new("Frame", {
                Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, LayoutOrder = nextOrder(),
            }, tab.page)
            local dot = new("Frame", {
                Size = UDim2.fromOffset(8, 8), AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = accent,
                BorderSizePixel = 0, Rotation = 45,
            }, f)
            round(dot, 2)
            glowStroke(dot, accent, 1.5, 0.4)
            local l = label(f, (o and (o.Title or o.Name)) or "", 14, accent, Enum.Font.GothamBlack)
            l.Position = UDim2.new(0, 20, 1, -28); l.Size = UDim2.new(1, -20, 0, 26)
            l.AutomaticSize = Enum.AutomaticSize.None; l.TextYAlignment = Enum.TextYAlignment.Center
            l.TextWrapped = false; l.TextTruncate = Enum.TextTruncate.AtEnd
            onAccent(function()
                l.TextColor3 = accent
                dot.BackgroundColor3 = accent
            end)
            return f
        end

        -- ═══ TOGGLE ═══
        function adapter:Toggle(o)
            o = o or {}
            local state = o.Value == true
            local card = newCard(true)
            infoBlock(card, o.Title, o.Desc, 78)

            local trackF = new("Frame", {
                Size = UDim2.fromOffset(56, 30), AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0), BorderSizePixel = 0,
                BackgroundColor3 = C.off,
            }, card)
            round(trackF, 15)
            local trackStroke = stroke(trackF, C.line, 1, 0.4)
            local trackGrad = gradient(trackF, C.off, C.off, 0)

            local knob = new("Frame", {
                Size = UDim2.fromOffset(24, 24), AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
            }, trackF)
            round(knob, 12)

            local function render(animate)
                local goal = { Position = state and UDim2.new(1, -27, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }
                if animate then
                    TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), goal):Play()
                else
                    knob.Position = goal.Position
                end
                TweenService:Create(trackF, TweenInfo.new(0.2), {
                    BackgroundColor3 = state and accent or C.off
                }):Play()
                TweenService:Create(trackStroke, TweenInfo.new(0.2), {
                    Color = state and accent or C.line,
                    Transparency = state and 0.2 or 0.4,
                }):Play()
                trackGrad.Color = ColorSequence.new(state and accent or C.off, state and theme.secondary or C.off)
            end
            onAccent(function() render(false) end)

            local ctl = {}
            local function set(v, fire)
                state = v == true
                render(true)
                if fire and type(o.Callback) == "function" then pcall(o.Callback, state) end
            end
            function ctl:Set(v) set(v, true) end
            function ctl:SetValue(v) set(v, true) end
            function ctl:GetValue() return state end

            if Dynamic.FireToggles and state and type(o.Callback) == "function" then
                task.defer(function() pcall(o.Callback, true) end)
            end

            track(card.MouseButton1Click:Connect(function() set(not state, true) end))
            return ctl
        end

        -- ═══ BUTTON ═══
        function adapter:Button(o)
            o = o or {}
            local card = newCard(true)
            infoBlock(card, o.Title, o.Desc, 36)

            local arrow = new("TextLabel", {
                Size = UDim2.fromOffset(32, 32), AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0), BackgroundTransparency = 1,
                Text = "›", TextColor3 = accent, TextSize = 28, Font = Enum.Font.GothamBlack,
                TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
            }, card)
            local cardStroke = stroke(card, accent, 1.2, 0.7)
            local cardGrad = card:FindFirstChildOfClass("UIGradient")

            onAccent(function()
                arrow.TextColor3 = accent
                cardStroke.Color = accent
            end)

            track(card.MouseEnter:Connect(function()
                TweenService:Create(card, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
                TweenService:Create(cardStroke, TweenInfo.new(0.15), { Transparency = 0.3 }):Play()
            end))
            track(card.MouseLeave:Connect(function()
                TweenService:Create(card, TweenInfo.new(0.2), { BackgroundTransparency = 0.15 }):Play()
                TweenService:Create(cardStroke, TweenInfo.new(0.2), { Transparency = 0.7 }):Play()
            end))

            track(card.MouseButton1Click:Connect(function()
                TweenService:Create(card, TweenInfo.new(0.08), { BackgroundColor3 = C.line }):Play()
                task.delay(0.12, function()
                    TweenService:Create(card, TweenInfo.new(0.15), { BackgroundColor3 = C.card }):Play()
                end)
                if type(o.Callback) == "function" then pcall(o.Callback) end
            end))
            return card
        end

        -- ═══ SLIDER ═══
        function adapter:Slider(o)
            o = o or {}
            local range = type(o.Value) == "table" and o.Value or {}
            local mn, mx = tonumber(range.Min) or 0, tonumber(range.Max) or 100
            local def = tonumber(range.Default) or mn
            local isInt = (mn % 1 == 0) and (mx % 1 == 0) and (def % 1 == 0)
            local step = range.Rounding and (10 ^ -range.Rounding) or (isInt and 1 or 0.01)
            local value = math.clamp(def, mn, mx)

            local card = newCard(false)
            list(card, 10)

            local top = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, LayoutOrder = 1,
            }, card)
            local t = label(top, o.Title, 14, C.text, Enum.Font.GothamBold)
            t.Size = UDim2.new(1, -100, 0, 0)

            local valLbl = new("TextLabel", {
                Size = UDim2.fromOffset(94, 26), AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 0), BackgroundColor3 = C.bgDeep,
                Text = "", TextColor3 = accent, TextSize = 13, Font = Enum.Font.GothamBlack,
                TextXAlignment = Enum.TextXAlignment.Center,
            }, top)
            round(valLbl, 8)
            local valStroke = glowStroke(valLbl, accent, 1.5)

            if o.Desc and tostring(o.Desc) ~= "" then
                local d = label(card, o.Desc, 11, C.textSub, Enum.Font.Gotham)
                d.LayoutOrder = 2
            end

            local area = new("TextButton", {
                Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1,
                Text = "", AutoButtonColor = false, LayoutOrder = 3,
            }, card)

            local bar = new("Frame", {
                Size = UDim2.new(1, -20, 0, 10), AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 10, 0.5, 0), BackgroundColor3 = C.off, BorderSizePixel = 0,
            }, area)
            round(bar, 5)
            stroke(bar, C.line, 1, 0.3)

            local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0, BackgroundColor3 = accent }, bar)
            round(fill, 5)
            gradient(fill, accent, theme.secondary, 0)

            local knob = new("Frame", {
                Size = UDim2.fromOffset(24, 24), AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
            }, bar)
            round(knob, 12)
            local knobGlow = glowStroke(knob, accent, 2)

            local function render()
                local ratio = (mx > mn) and ((value - mn) / (mx - mn)) or 0
                fill.Size = UDim2.new(ratio, 0, 1, 0)
                knob.Position = UDim2.new(ratio, 0, 0.5, 0)
                valLbl.Text = tostring(math.floor(value * 100 + 0.5) / 100)
                valLbl.TextColor3 = accent
                valStroke.Color = accent
                knobGlow.Color = accent
            end
            onAccent(render)

            local function set(v, fire)
                v = math.clamp(tonumber(v) or value, mn, mx)
                v = mn + math.floor((v - mn) / step + 0.5) * step
                v = math.floor(math.clamp(v, mn, mx) * 10000 + 0.5) / 10000
                local changed = v ~= value
                value = v
                render()
                if fire and changed and type(o.Callback) == "function" then pcall(o.Callback, value) end
            end

            local dragging = false
            local function fromX(x)
                local ratio = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
                set(mn + ratio * (mx - mn), true)
            end
            track(area.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    content.ScrollingEnabled = false
                    fromX(input.Position.X)
                end
            end))
            track(UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    fromX(input.Position.X)
                end
            end))
            track(UserInputService.InputEnded:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    dragging = false
                    content.ScrollingEnabled = true
                end
            end))

            local ctl = {}
            function ctl:Set(v) set(v, true) end
            function ctl:SetValue(v) set(v, true) end
            function ctl:GetValue() return value end
            return ctl
        end

        -- ═══ DROPDOWN ═══
        function adapter:Dropdown(o)
            o = o or {}
            local values = o.Values or {}
            local current = o.Value
            if current == nil then current = values[1] end

            local card = newCard(false)
            list(card, 10)

            local head2 = new("TextButton", {
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = 1,
            }, card)

            local info = new("Frame", {
                Size = UDim2.new(1, -36, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
            }, head2)
            list(info, 4)
            label(info, o.Title, 14, C.text, Enum.Font.GothamBold)
            if o.Desc and tostring(o.Desc) ~= "" then
                label(info, o.Desc, 11, C.textSub, Enum.Font.Gotham)
            end

            local valLbl = label(info, tostring(current or ""), 13, accent, Enum.Font.GothamBold)

            local arrow = new("TextLabel", {
                Size = UDim2.fromOffset(28, 28), AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0), BackgroundTransparency = 1,
                Text = "▾", TextColor3 = accent, TextSize = 18, Font = Enum.Font.GothamBlack,
                TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
            }, head2)

            local box = new("ScrollingFrame", {
                Size = UDim2.new(1, 0, 0, math.min(#values * 40 + 10, 220)),
                BackgroundColor3 = C.bgDeep, ClipsDescendants = true,
                BorderSizePixel = 0, Visible = false, ScrollBarThickness = 3,
                CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
                LayoutOrder = 2,
            }, card)
            round(box, 12)
            stroke(box, C.line, 1, 0.3)
            pad(box, 6, 6, 8, 6); list(box, 3)

            local items = {}
            local function renderItems()
                valLbl.Text = tostring(current or "")
                valLbl.TextColor3 = accent
                for _, it in ipairs(items) do
                    local sel = tostring(it.value) == tostring(current)
                    it.btn.BackgroundColor3 = sel and C.cardHi or C.bgDeep
                    it.lbl.TextColor3 = sel and accent or C.text
                    it.lbl.Text = (sel and "◆  " or "    ") .. tostring(it.value)
                end
            end

            local function build()
                for _, it in ipairs(items) do pcall(function() it.btn:Destroy() end) end
                table.clear(items)
                box.Size = UDim2.new(1, 0, 0, math.min(#values * 40 + 10, 220))
                for i, v in ipairs(values) do
                    local b = new("TextButton", {
                        Size = UDim2.new(1, 0, 0, 38),
                        BackgroundColor3 = C.bgDeep,
                        Text = "", AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = i,
                    }, box)
                    round(b, 8)
                    local l = label(b, tostring(v), 13, C.text, Enum.Font.GothamMedium)
                    l.Position = UDim2.new(0, 12, 0, 0); l.Size = UDim2.new(1, -20, 1, 0)
                    l.AutomaticSize = Enum.AutomaticSize.None; l.TextYAlignment = Enum.TextYAlignment.Center
                    l.TextWrapped = false; l.TextTruncate = Enum.TextTruncate.AtEnd
                    table.insert(items, { btn = b, lbl = l, value = v })
                    track(b.MouseEnter:Connect(function()
                        if tostring(current) ~= tostring(v) then
                            TweenService:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = C.card }):Play()
                        end
                    end))
                    track(b.MouseLeave:Connect(function()
                        if tostring(current) ~= tostring(v) then
                            TweenService:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = C.bgDeep }):Play()
                        end
                    end))
                    track(b.MouseButton1Click:Connect(function()
                        current = v
                        box.Visible = false
                        arrow.Text = "▾"
                        renderItems()
                        if type(o.Callback) == "function" then pcall(o.Callback, current) end
                    end))
                end
                renderItems()
            end
            build()
            onAccent(renderItems)

            track(head2.MouseButton1Click:Connect(function()
                box.Visible = not box.Visible
                arrow.Text = box.Visible and "▴" or "▾"
            end))

            local ctl = {}
            function ctl:Select(v) current = v; renderItems(); if type(o.Callback) == "function" then pcall(o.Callback, current) end end
            function ctl:Set(v) self:Select(v) end
            function ctl:SetValue(v) self:Select(v) end
            function ctl:GetValue() return current end
            function ctl:Refresh(newValues)
                values = newValues or {}
                local found = false
                for _, v in ipairs(values) do
                    if tostring(v) == tostring(current) then found = true break end
                end
                if not found then current = "---" end
                box.Visible = false
                arrow.Text = "▾"
                build()
            end
            return ctl
        end

        -- ═══ INPUT ═══
        function adapter:Input(o)
            o = o or {}
            local card = newCard(false)
            list(card, 10)
            local info = infoBlock(card, o.Title, o.Desc, 0)
            info.LayoutOrder = 1

            local box = new("TextBox", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = C.bgDeep,
                BorderSizePixel = 0, LayoutOrder = 2,
                Text = tostring(o.Value or o.Default or ""),
                PlaceholderText = tostring(o.Placeholder or ""),
                PlaceholderColor3 = C.textDim, TextColor3 = C.text,
                Font = Enum.Font.GothamMedium, TextSize = 13,
                ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
                ClipsDescendants = true, TextTruncate = Enum.TextTruncate.AtEnd,
            }, card)
            round(box, 10); pad(box, 14, 0, 14, 0)
            local st = stroke(box, C.line, 1, 0.3)
            onAccent(function() st.Color = accent end)

            track(box.Focused:Connect(function()
                TweenService:Create(st, TweenInfo.new(0.15), { Color = accent, Transparency = 0 }):Play()
            end))
            track(box.FocusLost:Connect(function()
                TweenService:Create(st, TweenInfo.new(0.15), { Color = C.line, Transparency = 0.3 }):Play()
                if type(o.Callback) == "function" then pcall(o.Callback, box.Text) end
            end))

            local ctl = {}
            function ctl:Set(v) box.Text = tostring(v or "") end
            function ctl:GetValue() return box.Text end
            return ctl
        end

        -- ═══ PARAGRAPH ═══
        function adapter:Paragraph(o)
            o = o or {}
            local card = newCard(false)
            local _, _, body = infoBlock(card, o.Title, (o.Desc ~= nil and o.Desc ~= "") and o.Desc or " ", 0)
            local st = glowStroke(card, accent, 1.2)
            onAccent(function() st.Color = accent end)
            local function set(_, text) if body then body.Text = tostring(text or "") end end
            return { SetDesc = set, Set = set, SetContent = set }
        end

        -- ═══ PILL BUTTON ═══
        function adapter:PillButton(o)
            o = o or {}
            local card = new("TextButton", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = C.card, BackgroundTransparency = 0.1,
                BorderSizePixel = 0, LayoutOrder = nextOrder(), Text = "", AutoButtonColor = false,
            }, tab.page)
            round(card, 22)
            local st = stroke(card, C.line, 1, 0.3)
            gradient(card, C.card, C.cardHi, 0)
            local l = label(card, o.Title, 13, C.text, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
            l.Size = UDim2.fromScale(1, 1); l.AutomaticSize = Enum.AutomaticSize.None
            l.TextYAlignment = Enum.TextYAlignment.Center; l.TextWrapped = false
            l.TextTruncate = Enum.TextTruncate.AtEnd
            onAccent(function() st.Color = accent end)
            track(card.MouseEnter:Connect(function()
                TweenService:Create(card, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
                TweenService:Create(st, TweenInfo.new(0.15), { Color = accent, Transparency = 0.2 }):Play()
            end))
            track(card.MouseLeave:Connect(function()
                TweenService:Create(card, TweenInfo.new(0.2), { BackgroundTransparency = 0.1 }):Play()
                TweenService:Create(st, TweenInfo.new(0.2), { Color = C.line, Transparency = 0.3 }):Play()
            end))
            track(card.MouseButton1Click:Connect(function()
                TweenService:Create(card, TweenInfo.new(0.08), { BackgroundColor3 = C.line }):Play()
                task.delay(0.12, function()
                    TweenService:Create(card, TweenInfo.new(0.15), { BackgroundColor3 = C.card }):Play()
                end)
                if type(o.Callback) == "function" then pcall(o.Callback) end
            end))
            return card
        end

        return adapter
    end

    function Window:SetTheme(name)
        local t = MaruUI.Themes[name]
        if t then
            MaruUI.Theme = name
            theme = t
            accent = t.primary
            applyAccent()
        end
    end
    function Window:ToggleTransparency(enabled)
        contentFrame.BackgroundTransparency = enabled and 0.6 or 0
    end

    function Window:Destroy()
        if _G.MaruActiveToken == myToken then _G.MaruRunning = false end
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        pcall(function() gui:Destroy() end)
        if _G.MaruHubCleanup == Window.__cleanup then _G.MaruHubCleanup = nil end
    end
    Window.__cleanup = function() Window:Destroy() end
    _G.MaruHubCleanup = Window.__cleanup

    return Window
end

-- ═════════════════════════════════════════════════════════════
--  BUILD UI
-- ═════════════════════════════════════════════════════════════
local StatusCard, StatsCard, BagCard
local function BuildUI()
    if CurrentWindow then
        pcall(function() CurrentWindow:Destroy() end)
        CurrentWindow = nil
    end

    local Window = MaruUI.create({
        Title = "Maru Hub",
        Subtitle = "Neon Automation v6.0",
        Version = "v6.0",
        Theme = MaruUI.Theme,
    })
    CurrentWindow = Window

    -- ═══════ TAB 1: Dashboard ═══════
    local T1 = Window:Tab({ Title = "หน้าหลัก (Dashboard)", Short = "Dashboard", Icon = "🏠" })

    T1:Section({ Title = "สถานะการทำงานสด" })
    StatusCard = T1:Paragraph({ Title = "สถานะปัจจุบัน", Desc = "System Ready" })
    StatsCard = T1:Paragraph({ Title = "สถิติรอบนี้", Desc = "Elapsed: 00:00:00\nOres: 0 | Kills: 0 | Sales: 0" })
    BagCard = T1:Paragraph({ Title = "กระเป๋า / พลังชีวิต", Desc = "Bag: 0/10 | HP: 100%" })

    T1:Section({ Title = "ระบบไก่ตัน (Master AI)" })

    T1:Toggle({
        Title = "เปิดระบบไก่ตันอัตโนมัติ (Master 24/7)",
        Desc  = "ดันเจี้ยน > ด่าน > ฝึกพลัง > หลอม > ตีบวก",
        Value = State.Master247,
        Callback = function(v)
            State.Master247 = v
            if v then
                State.DropMagnet = true
                State.UltraPrompt = true
                State.AutoSafeEvacuate = true
                State.GodMode = true
                State.KillAura = true
                State.AntiAFK = true
                State.DungeonInstaKill = true
                State.StageInstaKill = true
                State.MasterAutoUpgrade = true
                State.MasterAutoForgeWhenReady = true
                State.AutoEnchant = true
                notify("Master AI", "เปิดระบบไก่ตันสำเร็จ", "zap")
            else
                Stats.CurrentActivity = "Paused"
            end
            if State.AutoSaveConfig then saveConfig() end
        end,
    })

    T1:Toggle({ Title = "Auto Forge เมื่อแร่ครบ", Value = State.MasterAutoForgeWhenReady, Callback = function(v) State.MasterAutoForgeWhenReady = v end })
    T1:Toggle({ Title = "Auto Upgrade พื้นหลัง", Value = State.MasterAutoUpgrade, Callback = function(v) State.MasterAutoUpgrade = v end })
    T1:Toggle({ Title = "Auto Enchant พื้นหลัง", Value = State.AutoEnchant, Callback = function(v) State.AutoEnchant = v end })
    T1:Toggle({ Title = "GOD-Farm Stage Blitz", Value = State.MasterStageBlitz, Callback = function(v) State.MasterStageBlitz = v end })
    T1:Toggle({ Title = "Concurrent Forge ขณะฟาร์ม", Value = State.MasterConcurrentForge, Callback = function(v) State.MasterConcurrentForge = v end })
    T1:Toggle({ Title = "Auto Click Sword Power", Value = State.MasterAutoClickSword, Callback = function(v) State.MasterAutoClickSword = v end })
    T1:Toggle({ Title = "Algorithmic DPS Solver AI", Value = State.AlgorithmicDPSSolver, Callback = function(v) State.AlgorithmicDPSSolver = v end })

    T1:Section({ Title = "คำสั่งด่วน" })

    T1:Button({
        Title = "อพยพฉุกเฉินไป Safe Zone",
        Callback = function()
            call("Stage", "ClaimedAllOreRE")
            tpTo(getSafeZoneCF())
            call("Backpack", "TrySellAllRE")
            Stats.SellCycles = Stats.SellCycles + 1
            notify("Safe Zone", "อพยพและขายของสำเร็จ", "shield")
        end,
    })

    T1:Button({
        Title = "ขายของทั้งหมดทันที",
        Callback = function()
            call("Backpack", "TrySellAllRE")
            Stats.SellCycles = Stats.SellCycles + 1
            notify("Merchant", "ขายของในกระเป๋าแล้ว", "coins")
        end,
    })

    T1:Button({
        Title = "ดูดแร่และเก็บของรอบตัวทันที",
        Callback = function()
            runDropMagnet()
            runUltraPrompts()
            notify("Magnet", "ดูดแร่รอบตัวเรียบร้อย", "sparkles")
        end,
    })

    -- ═══════ TAB 2: Race Roll ═══════
    local T2 = Window:Tab({ Title = "เสกที่รีเผ่า (Race Roll)", Short = "Race", Icon = "🏁" })

    T2:Section({ Title = "ระบบเสกที่รีเผ่า (Reward 4/5/6)" })
    T2:Paragraph({
        Title = "Race Roll Engine",
        Desc  = "ยิง TryClaimUPDRewardRE พร้อม Random Prefix เพื่อบายพาส Rate Limit\nใช้สำหรับฟาร์ม Reward 4, 5, 6 จาก Update Log",
    })

    T2:Toggle({
        Title = "เปิดระบบเสกที่รีเผ่าตลอดเวลา",
        Desc  = "ยิงทุก 0.1s ไปยัง Reward 4, 5, 6 (เปิดค้าง)",
        Value = false,
        Callback = function(v)
            if v then startRaceRoll() else stopRaceRoll() end
        end,
    })

    T2:Button({ Title = "ยิง Race Roll 100 ครั้ง (Burst Mode)", Desc = "300 shots แล้วหยุด", Callback = function() burstRaceRoll(100) end })
    T2:Button({ Title = "ยิง Race Roll 500 ครั้ง (Mega Burst)", Desc = "1500 shots", Callback = function() burstRaceRoll(500) end })
    T2:Button({ Title = "หยุด Race Roll ทันที", Callback = function() stopRaceRoll(); notify("Race Roll", "หยุดระบบแล้ว", "info") end })

    -- ═══════ TAB 3: Potion ═══════
    local T3 = Window:Tab({ Title = "น้ำยาไม่จำกัด (Potion)", Short = "Potion", Icon = "🧪" })

    T3:Section({ Title = "เสกน้ำยาไม่จำกัด" })
    T3:Paragraph({
        Title = "Infinity Potion",
        Desc  = "ยิง TryUsePotionRE ด้วยค่า -Infinity/Infinity เพื่อรีเซ็ตจำนวนน้ำยาให้เป็นค่าอนันต์",
    })

    T3:Button({ Title = "🧪 เสกน้ำยาไม่จำกัดทั้งหมด (All)", Callback = function() spawnInfinityPotions() end })
    T3:Button({ Title = "🧪 เสก DamagePotion ไม่จำกัด", Callback = function() spawnInfinityPotion("DamagePotion") end })
    T3:Button({ Title = "🧪 เสก LuckPotion ไม่จำกัด", Callback = function() spawnInfinityPotion("LuckPotion") end })
    T3:Button({ Title = "🧪 เสก TrainPotion ไม่จำกัด", Callback = function() spawnInfinityPotion("TrainPotion") end })
    T3:Button({ Title = "🧪 Overkill น้ำยาทั้งหมด 5 รอบ", Callback = function() overkillPotions(5) end })

    -- ═══════ TAB 4: Astral ═══════
    local T4 = Window:Tab({ Title = "เสกไอเทมเทพ (Astral)", Short = "Astral", Icon = "✨" })

    T4:Section({ Title = "🔍 ตรวจสอบ Remote" })
    T4:Paragraph({
        Title = "คำแนะนำ",
        Desc  = "ก่อนกดปุ่มเสกไอเทม ให้กด 'Debug Remote' ก่อน 1 ครั้ง ระบบจะค้นหา Remote ให้อัตโนมัติ",
    })

    T4:Button({
        Title = "🔍 Debug Remote (ตรวจสอบ)",
        Desc  = "แสดงรายชื่อ Remote ที่เกี่ยวข้อง",
        Callback = function()
            local count = dumpDevRemotes()
            notify("Astral Debug", "ดัมป์ " .. tostring(count) .. " บรรทัด", "check")
        end,
    })

    T4:Section({ Title = "เสกเซ็ตเทพ" })
    T4:Button({ Title = "เสกเซ็ต Apocalypse", Desc = "K_1101 + HHat_1101 + HArmor_1101", Callback = function()
        local ok, msg = spawnGodSet("Apocalypse")
        notify("Astral", (ok and "✅ " or "❌ ") .. tostring(msg), ok and "sword" or "alert")
    end })
    T4:Button({ Title = "เสกเซ็ต Tri-Wyrm (มังกร 3 หัว)", Desc = "K_1001 + HHat_1001 + HArmor_1001", Callback = function()
        local ok, msg = spawnGodSet("TriWyrm")
        notify("Astral", (ok and "✅ " or "❌ ") .. tostring(msg), ok and "sword" or "alert")
    end })
    T4:Button({ Title = "เสกเซ็ต Cataclysm", Desc = "K_1002 + HHat_1002 + HArmor_1002", Callback = function()
        local ok, msg = spawnGodSet("Cataclysm")
        notify("Astral", (ok and "✅ " or "❌ ") .. tostring(msg), ok and "sword" or "alert")
    end })
    T4:Button({ Title = "เสกเซ็ต Void Overlord", Desc = "K_26 + LHat_16 + LArmor_16", Callback = function()
        local ok, msg = spawnGodSet("VoidOverlord")
        notify("Astral", (ok and "✅ " or "❌ ") .. tostring(msg), ok and "sword" or "alert")
    end })

    T4:Section({ Title = "แร่และหิน" })
    T4:Button({ Title = "เสกแร่ Apex x10", Callback = function()
        local ok, msg = spawnApexOresDirect(10)
        notify("Astral", (ok and "✅ " or "❌ ") .. tostring(msg), ok and "gem" or "alert")
    end })
    T4:Button({ Title = "เสกแร่ Apex x50", Callback = function()
        local ok, msg = spawnApexOresDirect(50)
        notify("Astral", (ok and "✅ " or "❌ ") .. tostring(msg), ok and "gem" or "alert")
    end })
    T4:Button({ Title = "เสกหินรูนทั้งหมด", Callback = function()
        local ok, msg = spawnAllRunesDirect()
        notify("Astral", (ok and "✅ " or "❌ ") .. tostring(msg), ok and "sparkles" or "alert")
    end })

    T4:Section({ Title = "อัตโนมัติ" })
    T4:Button({ Title = "สวมใส่เซ็ตเทพที่ดีที่สุด", Callback = function()
        local ok, count = equipGoldAndRedGear()
        notify("Astral", ok and ("สวมใส่ " .. tostring(count) .. " ชิ้น") or "ไม่พบไอเทม", "check")
    end })
    T4:Button({ Title = "🎁 เสกทุกเซ็ตเทพ (All Sets)", Callback = function()
        task.spawn(function()
            notify("Astral", "เริ่มเสกทุกเซ็ต...", "sparkles")
            for _, s in ipairs({ "Apocalypse", "TriWyrm", "Cataclysm", "VoidOverlord" }) do
                spawnGodSet(s)
                task.wait(0.5)
            end
            pcall(equipGoldAndRedGear)
            notify("Astral", "🎉 เสร็จสิ้น!", "check-circle")
        end)
    end })
    T4:Button({ Title = "🎁 Ultimate Combo (Everything)", Desc = "ทุกอย่างในคลิกเดียว", Callback = function()
        task.spawn(function()
            notify("Astral", "🚀 Ultimate Combo...", "sparkles")
            for _, s in ipairs({ "Apocalypse", "TriWyrm", "Cataclysm", "VoidOverlord" }) do
                spawnGodSet(s)
                task.wait(0.4)
            end
            spawnApexOresDirect(50)
            task.wait(0.3)
            spawnAllRunesDirect()
            task.wait(0.3)
            equipGoldAndRedGear()
            notify("Astral", "🎉 Ultimate Combo เสร็จ!", "check-circle")
        end)
    end })

    -- ═══════ TAB 5: Ember Stone (★ INFINITY) ═══════
    local T5 = Window:Tab({ Title = "ปั๊ม Ember Stone", Short = "Ember", Icon = "🔥" })

    T5:Section({ Title = "🔥 Ember Stone ไม่จำกัด (Infinity)" })
    T5:Paragraph({
        Title = "Infinity Mode",
        Desc  = "• Flood = เร็วสุด (~50K-500K ใน 1-2 วิ)\n• Infinity 999M = รันจนเต็ม (~1-5 นาที)\n• Mega Flood = ยิงซ้ำ 5 รอบ\n\n⚠️ ถ้า Kick ให้ลดความเร็ว",
    })

    T5:Button({
        Title = "⚡ Flood Ember Stone (เร็วสุด)",
        Desc  = "ยิงตรงเข้า Inventory 1000 shots Multi-Thread",
        Callback = function() floodEmberStone() end,
    })

    T5:Button({
        Title = "💥 Mega Flood x5000 (จัดเต็ม)",
        Desc  = "ยิง 5000 shots เข้ากระเป๋าทันที",
        Callback = function()
            task.spawn(function()
                notify("Mega Flood", "💥 เริ่ม Mega Flood 5000 shots...", "zap")
                for round = 1, 5 do
                    floodEmberStone()
                    task.wait(0.8)
                end
                notify("Mega Flood", "🎉 เสร็จสิ้น! (25,000 shots)", "check-circle")
            end)
        end,
    })

    T5:Button({
        Title = "🚀 Ember Stone 999M (Infinity Mode)",
        Desc  = "รันจนกว่าจะได้ 999,999,999 ก้อน — ใช้เวลา 1-5 นาที",
        Callback = function() pumpInfinityEmber() end,
    })

    T5:Section({ Title = "เสกแบบปกติ" })

    T5:Button({ Title = "เสก Ember +5,000 ก้อน", Callback = function()
        if not pumpRealEmberStones(5000) then notify("Ember", "กำลังเสกอยู่", "flame") end
    end })
    T5:Button({ Title = "เสก Ember +20,000 ก้อน", Callback = function()
        if not pumpRealEmberStones(20000) then notify("Ember", "กำลังเสกอยู่", "flame") end
    end })
    T5:Button({ Title = "เสก Ember +100,000 ก้อน", Callback = function()
        if not pumpRealEmberStones(100000) then notify("Ember", "กำลังเสกอยู่", "flame") end
    end })

    -- ═══════ TAB 6: Loot & Magnet ═══════
    local T6 = Window:Tab({ Title = "ฟาร์มแร่ & ดูดของ", Short = "Loot", Icon = "💎" })

    T6:Section({ Title = "ระบบดูดแร่" })
    T6:Toggle({ Title = "Auto Drop Magnet", Value = State.DropMagnet, Callback = toggleLoop("DropMagnet", "MagnetInterval", runDropMagnet) })
    T6:Dropdown({ Title = "ตำแหน่งปลายทาง", Values = { "Safe Zone", "To Player" }, Value = State.MagnetTarget, Callback = function(v) State.MagnetTarget = v end })
    T6:Slider({ Title = "ความถี่ในการดูด (วินาที)", Value = { Min = 0.05, Max = 1.0, Default = State.MagnetInterval }, Callback = function(v) State.MagnetInterval = v end })
    T6:Toggle({ Title = "Ultra Proximity Prompt", Value = State.UltraPrompt, Callback = toggleLoop("UltraPrompt", 0.15, runUltraPrompts) })

    T6:Section({ Title = "ความปลอดภัย" })
    T6:Toggle({ Title = "อพยพเมื่อกระเป๋าใกล้เต็ม", Value = State.AutoSafeEvacuate, Callback = function(v) State.AutoSafeEvacuate = v end })
    T6:Slider({ Title = "ความจุขั้นต่ำ (%)", Value = { Min = 50, Max = 100, Default = State.EvacuateThreshold }, Callback = function(v) State.EvacuateThreshold = v end })
    T6:Toggle({ Title = "หนีฉุกเฉินเมื่อเลือดน้อย", Value = State.LowHPEvacuate, Callback = function(v) State.LowHPEvacuate = v end })
    T6:Slider({ Title = "ระดับเลือดวิกฤต (%)", Value = { Min = 10, Max = 50, Default = State.LowHPThreshold }, Callback = function(v) State.LowHPThreshold = v end })

    T6:Section({ Title = "ขายของอัตโนมัติ" })
    T6:Toggle({ Title = "Auto Sell ทั้งหมด", Value = State.AutoSell, Callback = toggleLoop("AutoSell", "SellDelay", function()
        call("Backpack", "TrySellAllRE"); Stats.SellCycles = Stats.SellCycles + 1
    end) })
    T6:Slider({ Title = "รอบการขาย (วินาที)", Value = { Min = 1, Max = 60, Default = State.SellDelay }, Callback = function(v) State.SellDelay = v end })
    T6:Toggle({ Title = "ขายเฉพาะเกียร์ขยะ", Value = State.AutoSellTrashGear, Callback = toggleLoop("AutoSellTrashGear", "SellDelay", function()
        sellTrashGearNow(); Stats.SellCycles = Stats.SellCycles + 1
    end) })
    T6:Dropdown({ Title = "เก็บเกรดนี้ขึ้นไป", Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Eternal", "Ancient" }, Value = State.MinGearRarityToKeep, Callback = function(v) State.MinGearRarityToKeep = v end })
    T6:Toggle({ Title = "ขายแร่อัตโนมัติ", Value = State.AutoSellOres, Callback = toggleLoop("AutoSellOres", "SellDelay", sellOresNow) })
    T6:Toggle({ Title = "ขายหิน Enchant อัตโนมัติ", Value = State.AutoSellEnchantStones, Callback = toggleLoop("AutoSellEnchantStones", "SellDelay", sellEnchantStonesNow) })
    T6:Toggle({ Title = "สวมสัตว์เลี้ยงที่แรงที่สุด", Value = State.AutoEquipBestPet, Callback = toggleLoop("AutoEquipBestPet", "PetEquipDelay", equipBestPet) })
    T6:Toggle({ Title = "Anti-Trip & Ragdoll Immunity", Value = State.AntiTrip, Callback = function(v)
        State.AntiTrip = v
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h and v then applyAntiTrip(h) end
    end })

    -- ═══════ TAB 7: Dungeon ═══════
    local T7 = Window:Tab({ Title = "ดันเจี้ยน & ด่าน", Short = "Dungeon", Icon = "⚔️" })

    T7:Section({ Title = "ดันเจี้ยน" })
    T7:Toggle({ Title = "Auto Farm Dungeon", Value = State.AutoDungeon, Callback = toggleLoop("AutoDungeon", 0.5, runDungeonLoop) })
    T7:Slider({ Title = "รอบดันเจี้ยน", Value = { Min = 1, Max = 30, Default = State.DungeonRound }, Callback = function(v) State.DungeonRound = v end })
    T7:Toggle({ Title = "กดรับตั๋วฟรีรายวัน", Value = State.AutoClaimTicket, Callback = function(v) State.AutoClaimTicket = v end })
    T7:Toggle({ Title = "★ Instant Kill มอนสเตอร์", Value = State.DungeonInstaKill, Callback = function(v) State.DungeonInstaKill = v end })

    T7:Section({ Title = "ด่าน" })
    T7:Dropdown({ Title = "ด่านเป้าหมาย", Values = Dynamic.Stages, Value = State.SelectedStage, Callback = function(v) State.SelectedStage = v end })
    T7:Toggle({ Title = "Auto Farm ด่าน", Value = State.AutoStage, Callback = toggleLoop("AutoStage", 0.5, runStageLoop) })
    T7:Toggle({ Title = "★ Instant Kill Stage", Value = State.StageInstaKill, Callback = function(v) State.StageInstaKill = v end })
    T7:Toggle({ Title = "Auto Climb", Value = State.AutoClimbStages, Callback = function(v) State.AutoClimbStages = v end })
    T7:Slider({ Title = "ระยะเวลาจำกัดต่อด่าน", Value = { Min = 10, Max = 60, Default = State.StageClimbTimeout }, Callback = function(v) State.StageClimbTimeout = v end })
    T7:Toggle({ Title = "★ GOD-Farm: Stage Blitz", Value = State.GodFarmStageBlitz, Callback = function(v)
        State.GodFarmStageBlitz = v
        if v then task.spawn(runStageBlitz) end
    end })
    T7:Button({ Title = "ยิง GOD-Farm ทันที", Callback = function()
        task.spawn(runStageBlitz)
        notify("GOD-Farm", "เริ่มทะลวง Stage 1-30!", "zap")
    end })

    T7:Section({ Title = "ระบบโจมตี" })
    T7:Toggle({ Title = "Kill Aura", Value = State.KillAura, Callback = toggleLoop("KillAura", "KillAuraDelay", runKillAura) })
    T7:Slider({ Title = "ความเร็ว Kill Aura", Value = { Min = 0.05, Max = 1.0, Default = State.KillAuraDelay }, Callback = function(v) State.KillAuraDelay = v end })
    T7:Toggle({ Title = "God Mode (อมตะ)", Value = State.GodMode, Callback = function(v)
        State.GodMode = v; maintainGodMode()
    end })
    T7:Toggle({ Title = "Safe Combat Flight", Value = State.SafeCombatFlight, Callback = function(v) State.SafeCombatFlight = v end })
    T7:Slider({ Title = "ความสูงบิน", Value = { Min = 8, Max = 30, Default = State.FlightHeight }, Callback = function(v) State.FlightHeight = v end })

    -- ═══════ TAB 8: Boss ═══════
    local T8 = Window:Tab({ Title = "ล่าบอสแร่ยักษ์", Short = "Boss", Icon = "🎯" })

    T8:Section({ Title = "Super Loot Hunter" })
    T8:Toggle({ Title = "เปิดสไนป์บอสแร่ยักษ์", Value = State.SuperLootHunter, Callback = function(v) State.SuperLootHunter = v end })
    T8:Dropdown({ Title = "ระดับบอส", Values = Dynamic.SuperLootTiers, Value = State.SuperLootTargetTier, Callback = function(v) State.SuperLootTargetTier = v end })
    T8:Toggle({ Title = "แจ้งเตือน Discord", Value = State.SuperLootNotify, Callback = function(v) State.SuperLootNotify = v end })
    T8:Button({ Title = "สแกนและจัดการบอสทันที", Callback = function()
        checkSuperLootHunter()
        notify("Boss Hunter", "สแกนบอสเรียบร้อย", "crosshair")
    end })

    -- ═══════ TAB 9: Train ═══════
    local T9 = Window:Tab({ Title = "ฝึกพลัง & อัปเกรด", Short = "Train", Icon = "⚡" })

    T9:Section({ Title = "ฝึกพลัง" })
    T9:Toggle({ Title = "★ Auto Stand ฝึกพลังที่เลือก", Value = State.AutoTrainBestZone, Callback = function(v)
        State.AutoTrainBestZone = v
        if v then
            local zone = getSelectedTrainZone()
            if zone then task.spawn(function() pcall(enterTrainZone, zone) end) end
        end
    end })
    T9:Dropdown({ Title = "เลือกแท่นฝึก", Values = getTrainZoneNames(), Value = State.SelectedTrainZone, Callback = function(v)
        State.SelectedTrainZone = v
        local z = getZoneByName(v)
        if z then State.TrainArea = tostring(z.Id) end
        if State.AutoTrainBestZone then task.spawn(function() pcall(enterTrainZone) end) end
    end })
    T9:Toggle({ Title = "Auto Train", Value = State.AutoTrain, Callback = toggleLoop("AutoTrain", "TrainDelay", function()
        if State.ForceVIPTrain then
            LocalPlayer:SetAttribute("AutoTrainAreaID", 9)
            call("Train", "IntoAutoTrainRE", 9)
        elseif State.AutoTrainBestZone then
            pcall(enterTrainZone)
        end
        local tc = TrainCTRL or (ReplicatedStorage:FindFirstChild("CTRL") and require(ReplicatedStorage.CTRL.TrainCTRL))
        if tc and type(tc.TrainOnce) == "function" then tc.TrainOnce()
        else call("Train", "TrainOnceRE") end
    end) })
    T9:Slider({ Title = "ระยะเวลาฝึกต่อครั้ง", Value = { Min = 0.05, Max = 1.5, Default = State.TrainDelay }, Callback = function(v) State.TrainDelay = v end })
    T9:Toggle({ Title = "★ Auto Click Sword Power", Value = State.AutoClickSword, Callback = function(v) State.AutoClickSword = v end })
    T9:Slider({ Title = "ความเร็วคลิกดาบ", Value = { Min = 0.08, Max = 0.5, Default = State.SwordClickDelay }, Callback = function(v) State.SwordClickDelay = v end })
    T9:Toggle({ Title = "★ บัคแท่น x100 VIP (Force Zone 9)", Value = State.ForceVIPTrain, Callback = function(v)
        State.ForceVIPTrain = v
        if v then
            pcall(function()
                LocalPlayer:SetAttribute("AutoTrainAreaID", 9)
                call("Train", "IntoAutoTrainRE", 9)
            end)
            notify("x100 VIP", "เปิดใช้งานแท่น x100 VIP", "zap")
        else
            pcall(disengageIdleTraining)
            notify("x100 VIP", "ปิดโหมด x100 VIP", "info")
        end
    end })
    T9:Toggle({ Title = "★ Remote-Only Train Farm", Value = State.RemoteOnlyTrain, Callback = function(v)
        State.RemoteOnlyTrain = v
        notify("Remote Train", v and "⚡ เปิดโหมด Remote Train" or "ปิดโหมด Remote Train", "zap")
    end })

    T9:Section({ Title = "อัปเกรด" })
    T9:Dropdown({ Title = "หมวดหมู่อัปเกรด", Values = { "All in One", "Train", "OrePack", "Luck" }, Value = State.UpgradeType, Callback = function(v) State.UpgradeType = v end })
    T9:Toggle({ Title = "Auto Upgrade", Value = State.AutoUpgrade, Callback = toggleLoop("AutoUpgrade", "UpgradeDelay", function()
        if State.UpgradeType == "All in One" then
            call("Upgrade", "UpgradeOnceRE", "Train")
            call("Upgrade", "UpgradeOnceRE", "OrePack")
            call("Upgrade", "UpgradeOnceRE", "Luck")
        else
            call("Upgrade", "UpgradeOnceRE", State.UpgradeType)
        end
    end) })
    T9:Toggle({ Title = "Auto Rebirth", Value = State.AutoRebirth, Callback = toggleLoop("AutoRebirth", "RebirthDelay", function()
        call("Rebirth", "TryRebirthRE")
        Stats.RebirthCount = Stats.RebirthCount + 1
    end) })
    T9:Slider({ Title = "รอบตรวจสอบ Rebirth", Value = { Min = 2, Max = 60, Default = State.RebirthDelay }, Callback = function(v) State.RebirthDelay = v end })

    -- ═══════ TAB 10: Forge ═══════
    local T10 = Window:Tab({ Title = "หลอม & อุปกรณ์", Short = "Forge", Icon = "🔨" })

    T10:Section({ Title = "หลอมอุปกรณ์" })
    T10:Dropdown({ Title = "ชนิดอุปกรณ์", Values = { "All", "Weapon", "Armor", "Hat" }, Value = State.ForgeType, Callback = function(v) State.ForgeType = v end })
    T10:Slider({ Title = "จำนวนแร่ขั้นต่ำ", Desc = "Weapon 4-13 | Armor 8/11/23 | Hat 4/16", Value = { Min = 4, Max = 23, Default = State.MinOreToForge }, Callback = function(v) State.MinOreToForge = math.floor(v) end })
    T10:Dropdown({ Title = "ลำดับการใช้แร่", Values = { "Any", "High", "Low" }, Value = State.OreQualityMode, Callback = function(v) State.OreQualityMode = v end })
    T10:Toggle({ Title = "Auto Forge", Value = State.AutoForge, Callback = toggleLoop("AutoForge", "ForgeDelay", function()
        executeForgeNow(State.ForgeType, State.MinOreToForge)
    end) })
    T10:Slider({ Title = "ความเร็วหลอม", Value = { Min = 0.3, Max = 5.0, Default = State.ForgeDelay }, Callback = function(v) State.ForgeDelay = v end })
    T10:Button({ Title = "หลอม 1 ครั้งทันที", Callback = function()
        local ok, slot, count = executeForgeNow(State.ForgeType, State.MinOreToForge)
        notify("Forge", ok and ("หลอม " .. tostring(slot) .. " / " .. tostring(count) .. " แร่") or tostring(slot), "hammer")
    end })
    T10:Button({ Title = "สวมใส่เซ็ตที่ดีที่สุด", Callback = function()
        local ok, count = equipBestGearNow("All")
        notify("Equipment", ok and ("สวมใส่ " .. tostring(count) .. " ชิ้น") or "ไม่พบอุปกรณ์", "check")
    end })

    T10:Section({ Title = "ตีบวก & อักขระ" })
    T10:Toggle({ Title = "Auto Equip Best", Value = State.AutoEquipBest, Callback = toggleLoop("AutoEquipBest", 3.0, function() equipBestGearNow("All") end) })
    T10:Toggle({ Title = "Auto Enhance", Value = State.AutoEnhance, Callback = toggleLoop("AutoEnhance", "EnhanceDelay", function() call("Backpack", "EnhantEquipmentRF") end) })
    T10:Toggle({ Title = "Auto Enchant", Value = State.AutoEnchant, Callback = toggleLoop("AutoEnchant", "EnchantDelay", autoEnchantEquippedGear) })
    T10:Dropdown({ Title = "ระดับหินสูงสุด", Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Eternal", "All" }, Value = State.EnchantMaxGrade, Callback = function(v) State.EnchantMaxGrade = v end })
    T10:Toggle({ Title = "★ เก็บหินเกรดสูง", Value = State.EnchantKeepHighGrade, Callback = function(v) State.EnchantKeepHighGrade = v end })
    T10:Button({ Title = "ถอดอุปกรณ์ทั้งหมด + ล้างอักขระ", Callback = function()
        call("Backpack", "TryUnEquipItemRE")
        call("Backpack", "UnEnchantRE")
        notify("Inventory", "ถอดและล้างอักขระเรียบร้อย", "trash")
    end })

    -- ═══════ TAB 11: Class ═══════
    local T11 = Window:Tab({ Title = "คลาส สกิล & สัตว์เลี้ยง", Short = "Class", Icon = "🌟" })

    T11:Section({ Title = "สุ่มคลาส" })
    T11:Dropdown({ Title = "คลาสเป้าหมาย", Values = Dynamic.Classes, Value = State.TargetClassToLock, Callback = function(v) State.TargetClassToLock = v end })
    T11:Toggle({ Title = "Auto Roll Class", Value = State.AutoRollClass, Callback = toggleLoop("AutoRollClass", "RollClassDelay", runClassAndSkillRoll) })
    T11:Slider({ Title = "ความเร็วในการสุ่ม", Value = { Min = 0.5, Max = 5.0, Default = State.RollClassDelay }, Callback = function(v) State.RollClassDelay = v end })
    T11:Toggle({ Title = "Auto Roll Skill Cells", Value = State.AutoRollSkills, Callback = toggleLoop("AutoRollSkills", "RollSkillDelay", runClassAndSkillRoll) })

    T11:Section({ Title = "สัตว์เลี้ยง & น้ำยา" })
    T11:Toggle({ Title = "Auto Use Buff Potions", Value = State.AutoUsePotions, Callback = toggleLoop("AutoUsePotions", "PotionDelay", runPotionAndHatch) })
    T11:Toggle({ Title = "Auto Hatch Eggs", Value = State.AutoHatchEggs, Callback = toggleLoop("AutoHatchEggs", "HatchEggDelay", runPotionAndHatch) })

    -- ═══════ TAB 12: Rewards ═══════
    local T12 = Window:Tab({ Title = "รางวัล & โค้ดฟรี", Short = "Rewards", Icon = "🎁" })

    T12:Section({ Title = "กดรับของรางวัล" })
    T12:Toggle({ Title = "Auto Claim All Rewards", Value = State.AutoClaimRewards, Callback = toggleLoop("AutoClaimRewards", "ClaimDelay", claimAllRewards) })
    T12:Slider({ Title = "รอบการกดรับ", Value = { Min = 10, Max = 300, Default = State.ClaimDelay }, Callback = function(v) State.ClaimDelay = v end })
    T12:Button({ Title = "กดรับของรางวัลทั้งหมดทันที", Callback = function()
        task.spawn(claimAllRewards)
        notify("Rewards", "ส่งคำสั่งกดรับทุกหมวดหมู่", "gift")
    end })

    T12:Section({ Title = "โค้ดแจกฟรี" })
    T12:Button({ Title = "ดึงโค้ดล่าสุดจากออนไลน์ + กดรับทั้งหมด", Callback = function()
        task.spawn(function() redeemAllOnlineCodes(false) end)
    end })

    local codeInput = ""
    T12:Input({ Title = "กรอกโค้ด", Placeholder = "ใส่โค้ดที่นี่...", Callback = function(t) codeInput = t end })
    T12:Button({ Title = "ยืนยันการใช้โค้ด", Callback = function()
        if codeInput == "" then return notify("Codes", "กรุณากรอกโค้ดก่อน", "alert") end
        local res = call("Code", "TryUseCodeRF", codeInput)
        notify("Codes", "Server: " .. tostring(res), "ticket")
    end })

    -- ═══════ TAB 13: Travel ═══════
    local T13 = Window:Tab({ Title = "จุดวาร์ป & เซิร์ฟเวอร์", Short = "Travel", Icon = "📍" })

    T13:Section({ Title = "จุดวาร์ป" })
    T13:Button({ Title = "วาร์ปไป Safe Zone", Callback = function()
        tpTo(getSafeZoneCF())
        notify("Waypoint", "ถึง Safe Zone แล้ว", "shield")
    end })
    T13:Button({ Title = "วาร์ปไปพื้นที่ฝึกพลัง", Callback = function()
        local tm = workspace:FindFirstChild("WorldModel") and workspace.WorldModel:FindFirstChild("TrainMap")
        if tm then tpTo(tm:GetPivot()); notify("Waypoint", "ถึง Train Map", "map-pin")
        else notify("Waypoint", "ไม่พบ Train Map", "alert") end
    end })
    T13:Button({ Title = "วาร์ปไปหน้าดันเจี้ยน", Callback = function()
        local dm = workspace:FindFirstChild("WorldModel") and workspace.WorldModel:FindFirstChild("DungeonMap")
        local sp = dm and dm:FindFirstChild("StartPoint")
        if sp then tpTo(sp.CFrame); notify("Waypoint", "ถึงหน้าดันเจี้ยน", "map-pin")
        else notify("Waypoint", "ไม่พบทางเข้า", "alert") end
    end })

    local savedPosition = nil
    T13:Button({ Title = "บันทึกพิกัดปัจจุบัน", Callback = function()
        local r = hrp()
        if r then savedPosition = r.CFrame; notify("Waypoint", "บันทึกพิกัดแล้ว", "check") end
    end })
    T13:Button({ Title = "วาร์ปกลับพิกัดที่บันทึก", Callback = function()
        if savedPosition then tpTo(savedPosition); notify("Waypoint", "วาร์ปกลับสำเร็จ", "map-pin")
        else notify("Waypoint", "ยังไม่มีการบันทึก", "alert") end
    end })

    T13:Section({ Title = "เซิร์ฟเวอร์" })
    T13:Button({ Title = "Rejoin เซิร์ฟเวอร์เดิม", Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end })
    T13:Button({ Title = "Server Hop (คนน้อยสุด)", Callback = function()
        local ok, data = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
            ))
        end)
        if ok and data and data.data then
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    notify("Server Hop", "กำลังเชื่อมต่อ...", "server")
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    return
                end
            end
        end
        notify("Server Hop", "ไม่พบเซิร์ฟเวอร์", "alert")
    end })
    T13:Button({ Title = "คัดลอกรหัสเซิร์ฟเวอร์ (JobId)", Desc = tostring(game.JobId), Callback = function()
        if setclipboard then setclipboard(game.JobId); notify("JobId", "คัดลอกแล้ว", "copy") end
    end })

    -- ═══════ TAB 14: Settings ═══════
    local T14 = Window:Tab({ Title = "ตั้งค่า & Webhook", Short = "Settings", Icon = "⚙️" })

    T14:Section({ Title = "Neon UI Theme" })
    T14:Dropdown({
        Title = "ธีม Neון",
        Desc  = "เปลี่ยนสี Neon ของทั้ง UI",
        Values = MaruUI.ThemeNames,
        Value = MaruUI.Theme,
        Callback = function(name) Window:SetTheme(name) end,
    })
    T14:Toggle({ Title = "ความโปร่งใสแบบ Glass", Value = false, Callback = function(v) Window:ToggleTransparency(v) end })
    T14:Dropdown({ Title = "ภาษา", Values = { "ไทย (Thai)", "English (EN)" }, Value = (State.Language == "EN" and "English (EN)" or "ไทย (Thai)"), Callback = function(v)
        local newLang = (v:find("English") or v:find("EN")) and "EN" or "TH"
        if State.Language ~= newLang then
            State.Language = newLang
            if State.AutoSaveConfig then saveConfig() end
            notify("Language", newLang == "TH" and "เปลี่ยนเป็นภาษาไทย" or "Switched to English", "globe")
            task.delay(0.3, function() pcall(BuildUI) end)
        end
    end })

    T14:Section({ Title = "Discord Webhook" })
    T14:Toggle({ Title = "เปิด Discord Webhook", Value = State.WebhookEnabled, Callback = function(v) State.WebhookEnabled = v end })
    T14:Input({ Title = "Webhook URL", Placeholder = "วางลิงก์ Discord Webhook...", Callback = function(t)
        State.WebhookUrl = t
        if State.AutoSaveConfig then saveConfig() end
    end })
    T14:Toggle({ Title = "แจ้งเตือนไอเทมหายาก", Value = State.NotifyRareDrops, Callback = function(v) State.NotifyRareDrops = v end })
    T14:Toggle({ Title = "รายงานสถิติรายชั่วโมง", Value = State.NotifyHourlyReport, Callback = function(v) State.NotifyHourlyReport = v end })
    T14:Button({ Title = "ส่งข้อความทดสอบ Webhook", Callback = function()
        if not State.WebhookUrl or State.WebhookUrl == "" then
            return notify("Webhook", "ยังไม่ได้ตั้งค่า URL", "alert")
        end
        sendWebhook("Maru Hub v6.0 Test", "Neon Webhook connected!", {
            { name = "Player", value = LocalPlayer.Name, inline = true },
            { name = "Engine", value = "Maru Hub v6.0 Neon", inline = true },
        }, 0x10B981)
        notify("Webhook", "ส่งข้อความทดสอบแล้ว", "send")
    end })

    T14:Section({ Title = "ปรับแต่งตัวละคร" })
    T14:Slider({ Title = "WalkSpeed", Value = { Min = 16, Max = 250, Default = State.WalkSpeed }, Callback = function(v)
        State.WalkSpeed = v
        local h = hum(); if h then h.WalkSpeed = v end
    end })
    T14:Slider({ Title = "JumpPower", Value = { Min = 50, Max = 300, Default = State.JumpPower }, Callback = function(v)
        State.JumpPower = v
        local h = hum()
        if h then h.UseJumpPower = true; h.JumpPower = v end
    end })
    T14:Toggle({ Title = "Infinite Jump", Value = State.InfJump, Callback = function(v) State.InfJump = v end })
    T14:Toggle({ Title = "Noclip", Value = State.Noclip, Callback = function(v) State.Noclip = v end })
    T14:Toggle({ Title = "Anti-AFK", Value = State.AntiAFK, Callback = function(v) State.AntiAFK = v end })
    T14:Toggle({ Title = "CPU Saver Mode", Value = State.CpuSaver, Callback = function(v)
        State.CpuSaver = v
        pcall(function()
            RunService:Set3dRenderingEnabled(not v)
            if setfpscap then setfpscap(v and 15 or 60) end
        end)
        notify("Optimizer", v and "3D disabled (15 FPS)" or "3D restored", "zap")
    end })

    T14:Section({ Title = "คอนฟิก" })
    T14:Toggle({ Title = "บันทึกอัตโนมัติ", Value = State.AutoSaveConfig, Callback = function(v) State.AutoSaveConfig = v end })
    T14:Button({ Title = "บันทึกการตั้งค่าลงเครื่อง", Callback = function()
        local ok, info = saveConfig()
        notify("Config", ok and ("บันทึกสำเร็จ (" .. tostring(info) .. " B)") or ("ไม่สำเร็จ: " .. tostring(info)), "save")
    end })
    T14:Button({ Title = "โหลดการตั้งค่าที่บันทึกไว้", Callback = function()
        local ok, info = loadConfig()
        if ok then
            notify("Config", "โหลดสำเร็จ (" .. tostring(info) .. " ค่า)", "folder")
            task.delay(0.3, function()
                Dynamic.FireToggles = true
                pcall(BuildUI)
                Dynamic.FireToggles = false
            end)
        else
            notify("Config", "ไม่สำเร็จ: " .. tostring(info), "alert")
        end
    end })
    T14:Button({ Title = "ปิดสคริปต์และลบ UI ทั้งหมด", Callback = function()
        for k, v in pairs(State) do
            if type(v) == "boolean" then State[k] = false end
        end
        getgenv().maruRaceRoll = false
        pcall(function() RunService:Set3dRenderingEnabled(true) end)
        Window:Destroy()
    end })

    Window:SelectTab(1)
    return Window
end

-- ─────────────────────────────────────────────────────────────
-- Event Listeners
-- ─────────────────────────────────────────────────────────────
LocalPlayer.CharacterAdded:Connect(function(c)
    local h = c:WaitForChild("Humanoid", 8)
    if h then
        h.WalkSpeed = State.WalkSpeed
        h.UseJumpPower = true
        h.JumpPower = State.JumpPower
    end
    if State.GodMode then
        task.wait(0.5)
        maintainGodMode()
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfJump then
        local h = hum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Stepped:Connect(function()
    if State.Noclip and char() then
        for _, p in ipairs(char():GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
    if State.GodMode then maintainGodMode() end
end)

LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

pcall(function()
    GuiService.ErrorMessageChanged:Connect(function()
        if State.Master247 or State.AutoDungeon or State.AutoStage then
            task.wait(3)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
end)

-- ─────────────────────────────────────────────────────────────
-- Background Workers
-- ─────────────────────────────────────────────────────────────
task.spawn(function()
    while true do
        if State.Master247 then pcall(runMaster247Engine) end
        task.wait(0.15)
    end
end)

task.spawn(function()
    while true do
        if not State.Master247 then
            if State.AutoDungeon then pcall(runDungeonLoop) end
            if State.GodFarmStageBlitz then
                pcall(runStageBlitz)
            elseif State.AutoStage then
                pcall(runStageLoop)
            end
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if State.AutoClickSword or (State.Master247 and State.MasterAutoClickSword) then
            pcall(runSwordClickFarm)
        end
        task.wait(State.SwordClickDelay or 0.16)
    end
end)

task.spawn(function()
    while true do
        if State.ForceVIPTrain then
            local inFight = LocalPlayer:GetAttribute("IntoFight")
            local inDung  = LocalPlayer:GetAttribute("Dungeoning")
            if not inFight and not inDung then
                local currentZoneId = LocalPlayer:GetAttribute("AutoTrainAreaID")
                if currentZoneId ~= 9 then
                    pcall(function()
                        LocalPlayer:SetAttribute("AutoTrainAreaID", 9)
                        call("Train", "IntoAutoTrainRE", 9)
                    end)
                end
            end
        end
        task.wait(3.0)
    end
end)

-- ─────────────────────────────────────────────────────────────
-- Live Dashboard
-- ─────────────────────────────────────────────────────────────
local Live = { RealKills = 0, RealSuper = 0, OresGained = 0, LastOres = nil, StartRebirth = nil, Watched = {} }

local function getEcoStats()
    local rebirth, stagePass = nil, nil
    pcall(function()
        local pd = ProfileData and ProfileData.GetTotalData and ProfileData.GetTotalData()
        rebirth = pd and pd.Eco and tonumber(pd.Eco.rebirth)
        stagePass = pd and pd.Stats and tonumber(pd.Stats.StagePass)
    end)
    return rebirth, stagePass
end

local function getOreInventoryTotal()
    local items = getBackpackItems()
    if not items then return nil end
    local total = 0
    for _, it in pairs(items) do
        if type(it) == "table" and it.Type == "Ore" then
            total = total + (tonumber(it.Number) or 1)
        end
    end
    return total
end

local function getDungeonTickets()
    local n = nil
    pcall(function()
        local t = BackpackData and BackpackData.GetItemDataByIDType and BackpackData.GetItemDataByIDType("Dungeon_Ticket", "Material")
        n = t and tonumber(t.Number) or 0
    end)
    return n
end

local function watchFolder(name, onRemoved)
    local f = workspace:FindFirstChild(name)
    if f and Live.Watched[name] ~= f then
        Live.Watched[name] = f
        f.ChildRemoved:Connect(onRemoved)
    end
end

local function isAnyAutomationOn()
    return State.Master247 or State.AutoDungeon or State.AutoStage or State.GodFarmStageBlitz
        or State.AutoTrain or State.AutoTrainBestZone or State.AutoClickSword
        or State.ForceVIPTrain or State.SuperLootHunter or State.AutoRollClass
        or State.AutoForge or State.KillAura
end

task.spawn(function()
    while true do
        pcall(function()
            local elapsed = os.time() - Stats.StartTime
            local hh = math.floor(elapsed / 3600)
            local mm = math.floor((elapsed % 3600) / 60)
            local ss = elapsed % 60
            local timeStr = ("%02d:%02d:%02d"):format(hh, mm, ss)

            local curBag, maxBag = getPackInfo()
            local hPart = hum()
            local curHp = hPart and math.floor(hPart.Health) or 100
            local maxHp = hPart and math.floor(hPart.MaxHealth) or 100

            watchFolder("EnemyFolder", function(c) if c:IsA("Model") then Live.RealKills = Live.RealKills + 1 end end)
            watchFolder("SuperLootFolder", function() Live.RealSuper = Live.RealSuper + 1 end)

            local oreNow = getOreInventoryTotal()
            if oreNow then
                if Live.LastOres and oreNow > Live.LastOres then
                    Live.OresGained = Live.OresGained + (oreNow - Live.LastOres)
                end
                Live.LastOres = oreNow
            end

            local rebNow, stagePass = getEcoStats()
            if rebNow and not Live.StartRebirth then Live.StartRebirth = rebNow end
            local rebGained = (rebNow and Live.StartRebirth) and math.max(rebNow - Live.StartRebirth, 0) or 0

            Stats.OresCollected = Live.OresGained
            Stats.Kills = Live.RealKills
            Stats.SuperLootKills = Live.RealSuper
            Stats.RebirthCount = rebGained

            local orePerHour = elapsed > 0 and math.floor(Live.OresGained / elapsed * 3600) or 0
            local tickets = getDungeonTickets()
            local inDungeon = LocalPlayer:GetAttribute("Dungeoning")

            if StatusCard then
                local actText = Stats.CurrentActivity
                if not isAnyAutomationOn() then
                    actText = "ยังไม่ได้เปิดระบบอัตโนมัติ"
                elseif inDungeon then
                    actText = "กำลังเคลียร์ดันเจี้ยน"
                end
                StatusCard:SetDesc("สถานะ: " .. tostring(actText) ..
                    "\nMaster AI: " .. (State.Master247 and "เปิด" or "ปิด") ..
                    "\nRace Roll: " .. (getgenv().maruRaceRoll and "เปิด" or "ปิด") ..
                    "\nตำแหน่ง: " .. (inDungeon and "ในดันเจี้ยน" or (LocalPlayer:GetAttribute("IntoFight") and "กำลังต่อสู้" or "แมพหลัก")))
            end

            if StatsCard then
                StatsCard:SetDesc(
                    ("เวลา: %s\nแร่: %d (%d/ชม.) | ขาย: %d\nมอนที่กำจัด: %d | เกิดใหม่: %d\nด่านสูงสุด: %s | ตั๋ว: %s\nบอสยักษ์: %d")
                    :format(timeStr, Live.OresGained, orePerHour, Stats.SellCycles, Live.RealKills, rebGained,
                        stagePass and tostring(stagePass) or "-", tickets and tostring(tickets) or "-", Live.RealSuper)
                )
            end

            if BagCard then
                local bagPct = math.floor((curBag / math.max(maxBag, 1)) * 100)
                local hpPct = math.floor((curHp / math.max(maxHp, 1)) * 100)
                BagCard:SetDesc(("กระเป๋า: %d / %d (%d%%)\nเลือด: %d / %d (%d%%)"):format(curBag, maxBag, bagPct, curHp, maxHp, hpPct))
            end
        end)
        task.wait(1)
    end
end)

-- ─────────────────────────────────────────────────────────────
-- Launch
-- ─────────────────────────────────────────────────────────────
MARU_DEBUG("building UI...")
local buildOk, buildErr = xpcall(BuildUI, function(e) return tostring(e) .. " | " .. debug.traceback() end)
if not buildOk then
    warn("[Maru Hub] UI build error:", tostring(buildErr))
    MARU_DEBUG("UI ERROR: " .. tostring(buildErr), true)
else
    MARU_DEBUG("UI built OK")
end

task.defer(function() pcall(applyBackpackVisualEngine) end)

notify("Maru Hub v6.0", "🎨 Neon UI พร้อมใช้งาน! กดปุ่ม M มุมซ้าย", "sparkles")
