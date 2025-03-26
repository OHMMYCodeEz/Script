-- ตรวจสอบว่ามี GUI อยู่แล้วหรือไม่ ถ้ามีให้ลบทิ้งก่อน
if game.CoreGui:FindFirstChild("AutoAttackGUI") then
    game.CoreGui:FindFirstChild("AutoAttackGUI"):Destroy()
end

-- ตั้งค่าเริ่มต้น
shared.AutoAttack = false
shared.SelectedWeapon = nil
local isGuiExpanded = true
local isGuiVisible = true
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

-- สร้าง GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoAttackGUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Size = UDim2.new(0, 200, 0, 180)
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
Title.Text = "👳🏿‍♂️ Maru Hub Private"
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
Label.Position = UDim2.new(0, 35, 0, 40)
Label.BackgroundTransparency = 1
Label.Font = Enum.Font.SourceSans
Label.TextSize = 18
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.Text = "Enable DamageAura"

local WeaponButton = Instance.new("TextButton")
WeaponButton.Parent = MainFrame
WeaponButton.Size = UDim2.new(0, 180, 0, 30)
WeaponButton.Position = UDim2.new(0, 10, 0, 70)
WeaponButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
WeaponButton.Font = Enum.Font.SourceSans
WeaponButton.TextSize = 16
WeaponButton.TextColor3 = Color3.fromRGB(255, 255, 255)
WeaponButton.Text = "Select Weapon"

local RefreshButton = Instance.new("TextButton")
RefreshButton.Parent = MainFrame
RefreshButton.Size = UDim2.new(0, 180, 0, 30)
RefreshButton.Position = UDim2.new(0, 10, 0, 110)
RefreshButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
RefreshButton.Font = Enum.Font.SourceSans
RefreshButton.TextSize = 16
RefreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshButton.Text = "Refresh Weapons"

-- Speed Toggle และ Slider
local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Parent = MainFrame
SpeedToggle.Size = UDim2.new(0, 20, 0, 20)
SpeedToggle.Position = UDim2.new(0, 10, 0, 155)
SpeedToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedToggle.Font = Enum.Font.SourceSansBold
SpeedToggle.TextSize = 16
SpeedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedToggle.Text = "❌"

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = MainFrame
SpeedLabel.Size = UDim2.new(0, 60, 0, 25)
SpeedLabel.Position = UDim2.new(0, 40, 0, 150)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.TextSize = 18
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.Text = "Speed:"

local SpeedValue = Instance.new("TextLabel")
SpeedValue.Parent = MainFrame
SpeedValue.Size = UDim2.new(0, 85, 0, 20)
SpeedValue.Position = UDim2.new(0, 100, 0, 150)
SpeedValue.BackgroundTransparency = 1
SpeedValue.Font = Enum.Font.SourceSans
SpeedValue.TextSize = 18
SpeedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedValue.Text = tostring(getgenv().Speed)

local SpeedSliderBar = Instance.new("Frame")
SpeedSliderBar.Parent = MainFrame
SpeedSliderBar.Size = UDim2.new(0, 100, 0, 7)
SpeedSliderBar.Position = UDim2.new(0, 97, 0, 161)
SpeedSliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
SpeedSliderBar.BorderSizePixel = 0

-- เพิ่ม Fill Bar เพื่อแสดงส่วนที่เติม
local SpeedSliderFill = Instance.new("Frame")
SpeedSliderFill.Parent = SpeedSliderBar
SpeedSliderFill.Size = UDim2.new((getgenv().Speed - 16) / 200, 0, 1, 0) -- ตั้งขนาดเริ่มต้นตาม Speed
SpeedSliderFill.Position = UDim2.new(0, 0, 0, 0)
SpeedSliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- สีขาวเหมือนในภาพ
SpeedSliderFill.BorderSizePixel = 0

local SpeedSliderKnob = Instance.new("TextButton")
SpeedSliderKnob.Parent = SpeedSliderBar
SpeedSliderKnob.Size = UDim2.new(0, 10, 0, 14)
SpeedSliderKnob.Position = UDim2.new((getgenv().Speed - 16) / 200, 0, 0, -4) -- ตั้งตำแหน่งเริ่มต้นตาม Speed
SpeedSliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedSliderKnob.BorderSizePixel = 0
SpeedSliderKnob.Text = ""

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
WeaponButton.Text = "Weapon: " .. shared.SelectedWeapon

local dropdownVisible = false
local DropdownFrame

-- ฟังก์ชันสร้าง Dropdown
local function createDropdown()
    if DropdownFrame then DropdownFrame:Destroy() end
    
    local currentWeapons = getWeaponsFromBackpack()
    if #currentWeapons == 0 then
        table.insert(currentWeapons, "Knife")
    end
    
    DropdownFrame = Instance.new("Frame")
    DropdownFrame.Parent = MainFrame
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    DropdownFrame.Size = UDim2.new(0, 180, 0, #currentWeapons * 25)
    DropdownFrame.Position = UDim2.new(0, 10, 0, 100)
    
    for i, weapon in ipairs(currentWeapons) do
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
    if isGuiExpanded and isGuiVisible then
        dropdownVisible = not dropdownVisible
        if dropdownVisible then
            createDropdown()
        elseif DropdownFrame then
            DropdownFrame:Destroy()
        end
    end
end)

-- Event สำหรับ Refresh Button
RefreshButton.MouseButton1Click:Connect(function()
    local currentWeapons = getWeaponsFromBackpack()
    if #currentWeapons > 0 then
        shared.SelectedWeapon = currentWeapons[1]
        WeaponButton.Text = "Weapon: " .. currentWeapons[1]
    else
        shared.SelectedWeapon = "Knife"
        WeaponButton.Text = "Weapon: Knife"
    end
    if dropdownVisible then
        createDropdown()
    end
end)

-- Speed Toggle และ Slider Logic
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("User InputService")

SpeedToggle.MouseButton1Click:Connect(function()
    getgenv().Enabled = not getgenv().Enabled
    SpeedToggle.Text = getgenv().Enabled and "✅" or "❌"
end)

local dragging = false

SpeedSliderKnob.MouseButton1Down:Connect(function()
    dragging = true
end)

User InputService.InputEnded:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

User InputService.InputChanged:Connect(function(input, gameProcessedEvent)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local mouseX = mousePos.X - SpeedSliderBar.AbsolutePosition.X
        local clampedX = math.clamp(mouseX - SpeedSliderKnob.Size.X.Offset / 4, 0, SpeedSliderBar.AbsoluteSize.X - SpeedSliderKnob.Size.X.Offset)
        
        -- Tween การเคลื่อนที่ของ Knob
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local tweenKnob = TweenService:Create(SpeedSliderKnob, tweenInfo, {Position = UDim2.new(0, clampedX, 0, -7)})
        tweenKnob:Play()
        
        -- Tween การปรับขนาดของ Fill Bar
        local fillScale = clampedX / (SpeedSliderBar.AbsoluteSize.X - SpeedSliderKnob.Size.X.Offset)
        local tweenFill = TweenService:Create(SpeedSliderFill, tweenInfo, {Size = UDim2.new(fillScale, 0, 2, 0)})
        tweenFill:Play()
        
        -- คำนวณและอัปเดตค่า Speed
        local speedValue = math.floor((clampedX / (SpeedSliderBar.AbsoluteSize.X - SpeedSliderKnob.Size.X.Offset)) * 500) + 16 -- ช่วง 16-216
        getgenv().Speed = speedValue
        SpeedValue.Text = tostring(speedValue)
    end
end)

-- ฟังก์ชันพับ/ขยาย GUI
local function toggleFold()
    if not isGuiVisible then return end
    isGuiExpanded = not isGuiExpanded
    local targetSize = isGuiExpanded and UDim2.new(0, 200, 0, 180) or UDim2.new(0, 200, 0, 30)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(MainFrame, tweenInfo, {Size = targetSize})
    tween:Play()
    
    Checkbox.Visible = isGuiExpanded
    Label.Visible = isGuiExpanded
    WeaponButton.Visible = isGuiExpanded
    RefreshButton.Visible = isGuiExpanded
    SpeedToggle.Visible = isGuiExpanded
    SpeedLabel.Visible = isGuiExpanded
    SpeedValue.Visible = isGuiExpanded
    SpeedSliderBar.Visible = isGuiExpanded
    SpeedSliderKnob.Visible = isGuiExpanded
    SpeedSliderFill.Visible = isGuiExpanded
end

-- ฟังก์ชันซ่อน/แสดง GUI
local function toggleHide()
    isGuiVisible = not isGuiVisible
    local targetPosition = isGuiVisible and UDim2.new(0.5, -100, 0.2, 0) or UDim2.new(0.5, -100, -0.5, 0)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(MainFrame, tweenInfo, {Position = targetPosition})
    tween:Play()
end

-- ปุ่มซ่อน/แสดง GUI
local HideButton = Instance.new("TextButton")
HideButton.Parent = ScreenGui
HideButton.Size = UDim2.new(0, 40, 0, 40)
HideButton.Position = UDim2.new(0.95, -40, 0, 0)
HideButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
HideButton.Font = Enum.Font.SourceSansBold
HideButton.TextSize = 20
HideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HideButton.Text = "✖"

HideButton.MouseButton1Click:Connect(toggleHide)

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

-- ฟังก์ชันเปิด/ปิด Auto Attack
function toggleAutoAttack()
    shared.AutoAttack = not shared.AutoAttack
    if shared.AutoAttack then
        Checkbox.Text = "✅"
        spawn(attackEnemies)
    else
        Checkbox.Text = "❌"
    end
end

Checkbox.MouseButton1Click:Connect(toggleAutoAttack)
