local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Maru Hub - Private Script " .. Fluent.Version,
    SubTitle = "heekuy",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ฟังก์ชันตั้งค่าเริ่มต้น
shared.AutoAttack = false
shared.SelectedWeapon = nil
getgenv().Speed = 50 -- ความเร็วเริ่มต้น
getgenv().Enabled = false -- สถานะ Speed Hack

-- ฟังก์ชัน Bypass WalkSpeed
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

-- อัปเดต WalkSpeed เมื่อตัวละครเกิดใหม่
players.LocalPlayer.CharacterAdded:Connect(function(char)
    bypassWalkSpeed()
    char:WaitForChild("Humanoid").WalkSpeed = getgenv().Speed
end)

-- ลูปอัปเดต WalkSpeed
spawn(function()
    while wait() do
        if getgenv().Enabled and players.LocalPlayer.Character and players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            players.LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Speed
        end
    end
end)

-- ฟังก์ชันดึงรายการอาวุธจาก Backpack
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

-- ฟังก์ชันรีเฟรชรายการอาวุธ
local function refreshWeapons()
    local weapons = getWeaponsFromBackpack()
    weaponDropdown:SetValues(weapons)
    shared.SelectedWeapon = weapons[1] or "Knife"  -- เลือกอาวุธแรกจากรายการ
end

-- ตั้งค่าอาวุธเริ่มต้น
local weapons = getWeaponsFromBackpack()
shared.SelectedWeapon = weapons[1] or "Knife"

-- ฟังก์ชันสำหรับ Auto Attack
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
                                ["shellMaxDist"] = 0,
                                ["origin"] = localPlayer.Character and localPlayer.Character:GetPivot().Position or Vector3.new(0, 0, 0),
                                ["weaponName"] = shared.SelectedWeapon,
                                ["bulletID"] = "Bullet_" .. tostring(math.random(100000, 999999)),
                                ["currentPenetrationCount"] = 5,
                                ["shellSpeed"] = 0,
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
                            [3] = 10,
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

-- Add UI Elements to Fluent

-- ตั้งค่า Speed Hack
local speedToggle = Tabs.Main:AddToggle("SpeedHackToggle", { Title = "Enable Speed Hack", Default = false })
speedToggle:OnChanged(function()
    getgenv().Enabled = Options.SpeedHackToggle.Value
end)

local speedSlider = Tabs.Main:AddSlider("SpeedSlider", {
    Title = "Speed",
    Description = "Set your walking speed",
    Default = 50,
    Min = 0,
    Max = 400,
    Rounding = 1,
    Callback = function(Value)
        getgenv().Speed = Value
    end
})

-- ฟังก์ชัน Auto Attack
local autoAttackToggle = Tabs.Main:AddToggle("AutoAttackToggle", { Title = "Enable Auto Attack", Default = false })
autoAttackToggle:OnChanged(function()
    shared.AutoAttack = Options.AutoAttackToggle.Value
    if shared.AutoAttack then
        attackEnemies()  -- เริ่มการโจมตีอัตโนมัติ
    end
end)

-- ตัวเลือกอาวุธ
local weaponDropdown = Tabs.Main:AddDropdown("WeaponDropdown", {
    Title = "Select Weapon",
    Values = weapons,
    Multi = false,
    Default = 1,
})

weaponDropdown:OnChanged(function(Value)
    shared.SelectedWeapon = Value
end)

-- เพิ่มปุ่มรีเฟรชรายการอาวุธ
local refreshButton = Tabs.Main:AddButton({
    Title = "Refresh Weapons",
    Description = "Refresh weapon list from backpack",
    Callback = function()
        refreshWeapons()
    end
})

-- การตั้งค่า SaveManager และ InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

-- แจ้งเตือนเมื่อโหลดสคริปต์
Fluent:Notify({
    Title = "Maru Hub",
    Content = "The Maru script has been loaded.",
    Duration = 8
})

Window:SelectTab(1)
