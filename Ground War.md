-- ตรวจสอบว่ามี GUI อยู่แล้วหรือไม่ ถ้ามีให้ลบทิ้งก่อน
if game.CoreGui:FindFirstChild("AutoAttackGUI") then
    game.CoreGui:FindFirstChild("AutoAttackGUI"):Destroy()
end

-- ตั้งค่าเริ่มต้น
shared.AutoAttack = false
shared.SelectedWeapon = "Knife" -- อาวุธเริ่มต้น

-- สร้าง GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoAttackGUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Size = UDim2.new(0, 200, 0, 120) -- เพิ่มความสูงเพื่อรองรับ dropdown
MainFrame.Position = UDim2.new(0.5, -100, 0.2, 0)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "👳🏿‍♂️ Maru-Shop.gay 🤰"
Title.TextScaled = true

local Checkbox = Instance.new("TextButton")
Checkbox.Parent = MainFrame
Checkbox.Size = UDim2.new(0, 20, 0, 20)
Checkbox.Position = UDim2.new(0, 10, 0, 40)
Checkbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Checkbox.Font = Enum.Font.SourceSansBold
Checkbox.TextSize = 16
Checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
Checkbox.Text = "❌"

local Label = Instance.new("TextLabel")
Label.Parent = MainFrame
Label.Size = UDim2.new(1, -40, 0, 20)
Label.Position = UDim2.new(0, 40, 0, 40)
Label.BackgroundTransparency = 1
Label.Font = Enum.Font.SourceSans
Label.TextSize = 18
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.Text = "Enable DamageAura"

-- สร้าง Weapon Selection Dropdown
local WeaponButton = Instance.new("TextButton")
WeaponButton.Parent = MainFrame
WeaponButton.Size = UDim2.new(0, 180, 0, 30)
WeaponButton.Position = UDim2.new(0, 10, 0, 70)
WeaponButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
WeaponButton.Font = Enum.Font.SourceSans
WeaponButton.TextSize = 16
WeaponButton.TextColor3 = Color3.fromRGB(255, 255, 255)
WeaponButton.Text = "Weapon: Knife"

local weapons = {"Knife", "Pistol", "Rifle", "Shotgun"} -- รายการอาวุธที่เลือกได้
local dropdownVisible = false
local DropdownFrame

-- ฟังก์ชันสร้าง Dropdown
local function createDropdown()
    if DropdownFrame then DropdownFrame:Destroy() end
    
    DropdownFrame = Instance.new("Frame")
    DropdownFrame.Parent = MainFrame
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    DropdownFrame.Size = UDim2.new(0, 180, 0, #weapons * 25)
    DropdownFrame.Position = UDim2.new(0, 10, 0, 100)
    
    for i, weapon in ipairs(weapons) do
        local button = Instance.new("TextButton")
        button.Parent = DropdownFrame
        button.Size = UDim2.new(1, 0, 0, 25)
        button.Position = UDim2.new(0, 0, 0, (i-1) * 25)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.Font = Enum.Font.SourceSans
        button.TextSize = 16
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Text = weapon
        
        button.MouseButton1Click:Connect(function()
            shared.SelectedWeapon = weapon
            WeaponButton.Text = "Weapon: " .. weapon
            DropdownFrame:Destroy()
            dropdownVisible = false
        end)
    end
end

-- Event สำหรับ Weapon Button
WeaponButton.MouseButton1Click:Connect(function()
    dropdownVisible = not dropdownVisible
    if dropdownVisible then
        createDropdown()
    elseif DropdownFrame then
        DropdownFrame:Destroy()
    end
end)

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
                                ["weaponName"] = shared.SelectedWeapon, -- ใช้ weapon ที่เลือก
                                ["bulletID"] = "Bullet_" .. tostring(math.random(100000, 999999)),
                                ["currentPenetrationCount"] = 1,
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

-- ฟังก์ชันเปิด/ปิด Auto Attack
function toggleAutoAttack()
    shared.AutoAttack = not shared.AutoAttack
    if shared.AutoAttack then
        Checkbox.Text = "✅"
        spawn(attackEnemies) -- ใช้ spawn เพื่อรันใน thread ใหม่
    else
        Checkbox.Text = "❌"
    end
end

-- กด Checkbox เพื่อเปิด/ปิด Auto Attack
Checkbox.MouseButton1Click:Connect(toggleAutoAttack)
