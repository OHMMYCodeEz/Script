local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Maru Hub - Private abc-" .. Fluent.Version,
    SubTitle = " ",
    TabWidth = 130,
    Size = UDim2.fromScale(0.4, 0.4),
    Position = UDim2.fromScale(0.1, 0.2),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
    Resizeable = true, -- Enable resizing
    Minimizable = true -- Enable minimizing/collapsing
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "M" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

shared.AutoAttack = false
shared.SelectedWeapon = nil
getgenv().Speed = 50
getgenv().Enabled = false
getgenv().InfiniteAmmoEnabled = false

local players = game:GetService("Players")
local function bypassWalkSpeed()
    if getgenv().executed then
        print("Walkspeed Already Bypassed - Applying Settings Changes")
        if not getgenv().Enabled then
            return
        end
    else
        getgenv().executed = true
        print("Walkspeed Bypassed")
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldindex = mt.__index
        mt.__index = newcclosure(function(self, b)
            if b == "WalkSpeed" then
                return getgenv().Speed
            end
            return oldindex(self, b)
        end)
    end
end

players.LocalPlayer.CharacterAdded:Connect(function(char)
    bypassWalkSpeed()
    char:WaitForChild("Humanoid").WalkSpeed = getgenv().Speed
end)

spawn(function()
    while wait() do
        if getgenv().Enabled and players.LocalPlayer.Character and players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            players.LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Speed
        end
    end
end)

local function getWeaponsFromBackpack()
    local player = game:GetService("Players").LocalPlayer
    local backpack = player:WaitForChild("Backpack")
    local weapons = {}
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(weapons, item.Name)
        end
    end
    return weapons
end

local function refreshWeapons()
    local weapons = getWeaponsFromBackpack()
    if weaponDropdown then
        weaponDropdown:SetValues(weapons)
        if #weapons > 0 then
            shared.SelectedWeapon = weapons[1]
            weaponDropdown:SetValue(weapons[1])
        else
            shared.SelectedWeapon = nil
        end
    end
end

local weapons = getWeaponsFromBackpack()
shared.SelectedWeapon = weapons[1] or "Knife"

local weaponDropdown = Tabs.Main:AddDropdown("WeaponDropdown", {
    Title = "Select Weapon",
    Values = weapons,
    Multi = false,
    Default = 1,
})

weaponDropdown:OnChanged(function(Value)
    shared.SelectedWeapon = Value
end)

local autoAttackToggle = Tabs.Main:AddToggle("AutoAttackToggle", { Title = "Enable Auto Attack", Default = false })
autoAttackToggle:OnChanged(function()
    shared.AutoAttack = Options.AutoAttackToggle.Value
    if shared.AutoAttack then
        attackEnemies()
    end
end)

local refreshButton = Tabs.Main:AddButton({
    Title = "Refresh Weapons",
    Description = "Refresh weapon list from backpack",
    Callback = function()
        refreshWeapons()
    end
})

function attackEnemies()
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    local remoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("ACS_Engine"):WaitForChild("Events"):WaitForChild("Damage")
    while shared.AutoAttack do
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer and player.Team ~= localPlayer.Team then
                local targetModel = player.Character
                if targetModel then
                    local head = targetModel:FindFirstChild("Head")
                    local humanoid = targetModel:FindFirstChild("Humanoid")
                    if head and humanoid then
                        local args = {
                            [1] = {
                                ["shellMaxDist"] = getgenv().ShellMaxDist or 100,
                                ["origin"] = localPlayer.Character and localPlayer.Character:GetPivot().Position or Vector3.new(0, 0, 0),
                                ["weaponName"] = shared.SelectedWeapon,
                                ["bulletID"] = "Bullet_" .. tostring(math.random(100000, 999999)),
                                ["currentPenetrationCount"] = getgenv().CurrentPenetrationCount or 5,
                                ["shellSpeed"] = getgenv().ShellSpeed or 100,
                                ["localShellName"] = "Invisible",
                                ["maxPenetrationCount"] = 1e99,
                                ["registeredParts"] = { [head] = true },
                                ["shellType"] = "Bullet",
                                ["penetrationMultiplier"] = 1e99,
                                ["filterDescendants"] = {
                                    [1] = workspace:FindFirstChild(player.Name),
                                }
                            },
                            [2] = humanoid,
                            [3] = getgenv().AttackValue or 10,
                            [4] = 1,
                            [5] = head,
                        }
                        remoteEvent:InvokeServer(unpack(args))
                    end
                end
            end
        end
        wait(0.00001)
    end
end

local shellSpeedSlider = Tabs.Main:AddSlider("ShellSpeedSlider", {
    Title = "Shell Speed",
    Description = "Set the speed of the shell",
    Default = 100,
    Min = 0,
    Max = 1000,
    Rounding = 2,
    Callback = function(Value)
        getgenv().ShellSpeed = Value
    end
})

local currentPenetrationCountSlider = Tabs.Main:AddSlider("CurrentPenetrationCountSlider", {
    Title = "Current Penetration Count",
    Description = "Set the current penetration count",
    Default = 5,
    Min = 1,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        getgenv().CurrentPenetrationCount = Value
    end
})

local shellMaxDistSlider = Tabs.Main:AddSlider("ShellMaxDistSlider", {
    Title = "Shell Max Distance",
    Description = "Set the max distance for shells",
    Default = 100,
    Min = 10,
    Max = 1000,
    Rounding = 2,
    Callback = function(Value)
        getgenv().ShellMaxDist = Value
    end
})

local attackValueSlider = Tabs.Main:AddSlider("AttackValueSlider", {
    Title = "Attack Damage (ตำแหน่ง [3])",
    Description = "Set the attack value (ตำแหน่ง [3])",
    Default = 10,
    Min = 1,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        getgenv().AttackValue = Value
    end
})

local speedToggle = Tabs.Main:AddToggle("SpeedHackToggle", { Title = "Enable Speed Hack", Default = false })
speedToggle:OnChanged(function()
    getgenv().Enabled = Options.SpeedHackToggle.Value
end)

local speedSlider = Tabs.Main:AddSlider("SpeedSlider", {
    Title = "Speed",
    Description = "Set your walking speed",
    Default = 50,
    Min = 0,
    Max = 1000,
    Rounding = 2,
    Callback = function(Value)
        getgenv().Speed = Value
    end
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function infiniteAmmoServer()
    local function applySettings(tool)
        if tool:IsA("Tool") then
            local acsSettings = tool:FindFirstChild("ACS_Settings")
            if acsSettings and acsSettings:IsA("ModuleScript") then
                local m = require(acsSettings)
                if type(m) == "table" then
                    m.AmmoInGun = 999999
                    m.ShellInsert = true
                    m.ShootRate = 160000
                    m.adsTime = 0.1
                    m.MuzzleVelocity = 1000
                    m.Bullets = 3
                    m.ShootType = 3
                    m.MinDamage = 6000
                    m.Explosion = {Radius = 140000, Damage = 1400}
                    m.camRecoil = {
                        camRecoilUp = {0, 0},
                        camRecoilTilt = {0, 0},
                        camRecoilLeft = {0, 0},
                        camRecoilRight = {0, 0}
                    }
                    m.gunRecoil = {
                        gunRecoilUp = {0, 0},
                        gunRecoilTilt = {0, 0},
                        gunRecoilLeft = {0, 0},
                        gunRecoilRight = {0, 0}
                    }
                    m.MinSpread = 0
                    m.MaxSpread = 0
                    m.AimRecoilReduction = 1e999
                    m.AimSpreadReduction = 0
                    m.AimInaccuracyStepAmount = 0
                    m.AimInaccuracyDecrease = 1e999
                    m.MinRecoilPower = 1e999
                    m.MaxRecoilPower = 0
                    m.WalkMult = 300
                    m.MaxZero = 0
                end
            end
        end
    end
    
    spawn(function()
        while wait(0.1) do
            if getgenv().InfiniteAmmoEnabled then
                if player.Character then
                    for _, tool in pairs(player.Character:GetChildren()) do
                        applySettings(tool)
                    end
                end
                for _, tool in pairs(player.Backpack:GetChildren()) do
                    applySettings(tool)
                end
            end
        end
    end)
end

local infiniteAmmoToggle = Tabs.Main:AddToggle("InfiniteAmmoToggle", { 
    Title = "Enable Infinite Ammo", 
    Default = false,
    Description = "Gives infinite ammo and enhanced weapon stats"
})
infiniteAmmoToggle:OnChanged(function()
    getgenv().InfiniteAmmoEnabled = Options.InfiniteAmmoToggle.Value
    if getgenv().InfiniteAmmoEnabled then
        Fluent:Notify({
            Title = "Infinite Ammo",
            Content = "Infinite ammo and enhanced weapon stats enabled!",
            Duration = 3
        })
    end
end)

infiniteAmmoServer()

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

Fluent:Notify({
    Title = "Maru Hub Private !!",
    Content = "The Maru Private script has been loaded.",
    Duration = 8
})

Window:SelectTab(1)

refreshWeapons()
