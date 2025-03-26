-- สร้าง ScreenGui และปุ่มซ่อน/แสดง UI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local toggleUIButton = Instance.new("TextButton")
toggleUIButton.Size = UDim2.new(0, 200, 0, 50)
toggleUIButton.Position = UDim2.new(0.5, -100, 0.9, -25)
toggleUIButton.Text = "Hide UI"
toggleUIButton.TextSize = 24
toggleUIButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggleUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleUIButton.Parent = screenGui

local uiVisible = true  -- ตัวแปรในการเช็คสถานะของ UI

-- ฟังก์ชันซ่อน/แสดง UI
toggleUIButton.MouseButton1Click:Connect(function()
    if uiVisible then
        Window.Enabled = false   -- ซ่อน UI
        toggleUIButton.Text = "Show UI"   -- เปลี่ยนข้อความของปุ่ม
    else
        Window.Enabled = true    -- แสดง UI
        toggleUIButton.Text = "Hide UI"   -- เปลี่ยนข้อความของปุ่ม
    end
    uiVisible = not uiVisible  -- สลับสถานะการแสดง UI
end)

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

bypassWalkSpeed()

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

-- เรียกใช้ Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fluent " .. Fluent.Version,
    SubTitle = "by dawid",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

-- ฟังก์ชัน Toggle Auto Attack
local autoAttackToggle = Tabs.Main:AddToggle("AutoAttackToggle", {
    Title = "Auto Attack",
    Default = false,  -- เริ่มต้นคือปิด
})

autoAttackToggle:OnChanged(function(state)
    shared.AutoAttack = state
    if shared.AutoAttack then
        print("Auto Attack Enabled")
        attackEnemies()  -- เรียกฟังก์ชันโจมตีอัตโนมัติ
    else
        print("Auto Attack Disabled")
    end
end)

-- ฟังก์ชัน Toggle Speed Hack
local speedHackToggle = Tabs.Main:AddToggle("SpeedHackToggle", {
    Title = "Speed Hack",
    Default = false,  -- เริ่มต้นคือปิด
})

speedHackToggle:OnChanged(function(state)
    getgenv().Enabled = state
    if getgenv().Enabled then
        print("Speed Hack Enabled")
    else
        print("Speed Hack Disabled")
    end
end)

-- ฟังก์ชันเปลี่ยนอาวุธ
local weaponDropdown = Tabs.Main:AddDropdown("WeaponDropdown", {
    Title = "Select Weapon",
    Values = weapons,
    Default = shared.SelectedWeapon,
})

weaponDropdown:OnChanged(function(selectedWeapon)
    shared.SelectedWeapon = selectedWeapon
    print("Selected Weapon: " .. shared.SelectedWeapon)
end)

-- ฟังก์ชันปรับความเร็ว
local speedSlider = Tabs.Main:AddSlider("SpeedSlider", {
    Title = "Speed",
    Min = 10,
    Max = 200,
    Default = getgenv().Speed,
    Rounding = 1,
})

speedSlider:OnChanged(function(value)
    getgenv().Speed = value
    print("Speed set to: " .. getgenv().Speed)
end)

-- การโหลดการตั้งค่าที่บันทึกไว้
SaveManager:LoadAutoloadConfig()

