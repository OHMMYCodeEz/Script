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
        if not getgenv().Enabled then
            return
        end
    else
        getgenv().executed = true
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

-- ฟังก์ชันการควบคุม AutoAttack, เปลี่ยนอาวุธ, Speed Hack
local autoAttackToggle = Tabs.Main:AddToggle("Auto Attack", {Title = "Auto Attack", Default = shared.AutoAttack})
autoAttackToggle:OnChanged(function()
    shared.AutoAttack = autoAttackToggle.Value
    if shared.AutoAttack then
        attackEnemies()
    end
end)

local weaponDropdown = Tabs.Main:AddDropdown("Weapon Selector", {
    Title = "Select Weapon",
    Values = getWeaponsFromBackpack(),
    Default = 1,
    Callback = function(Value)
        shared.SelectedWeapon = Value
    end
})

local speedSlider = Tabs.Main:AddSlider("Speed", {
    Title = "Speed",
    Min = 0,
    Max = 200,
    Default = getgenv().Speed,
    Rounding = 0,
    Callback = function(Value)
        getgenv().Speed = Value
        bypassWalkSpeed()
    end
})

-- สร้างปุ่มซ่อน/แสดง UI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = players.LocalPlayer:WaitForChild("PlayerGui")

local hideUIButton = Instance.new("TextButton")
hideUIButton.Size = UDim2.new(0, 200, 0, 50)
hideUIButton.Position = UDim2.new(0.5, -100, 0.9, -25)
hideUIButton.Text = "Hide UI"
hideUIButton.TextSize = 24
hideUIButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
hideUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hideUIButton.Parent = screenGui

local uiVisible = true

hideUIButton.MouseButton1Click:Connect(function()
    if uiVisible then
        Window.Enabled = false
        hideUIButton.Text = "Show UI"
    else
        Window.Enabled = true
        hideUIButton.Text = "Hide UI"
    end
    uiVisible = not uiVisible
end)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
