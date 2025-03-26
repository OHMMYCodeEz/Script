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
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- สไตล์สี
local colors = {
    background = Color3.fromRGB(25, 25, 30),
    primary = Color3.fromRGB(40, 40, 50),
    secondary = Color3.fromRGB(60, 60, 70),
    accent = Color3.fromRGB(0, 170, 255),
    text = Color3.fromRGB(240, 240, 240),
    success = Color3.fromRGB(0, 200, 0),
    danger = Color3.fromRGB(200, 0, 0)
}

-- ฟังก์ชันสร้าง UI Elements
local function createButton(name, parent, size, position, text)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = parent
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = colors.primary
    button.TextColor3 = colors.text
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 14
    button.Text = text
    button.AutoButtonColor = true
    button.BorderSizePixel = 0
    button.ZIndex = 2
    
    -- เอฟเฟกต์เมื่อโฮเวอร์
    button.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = colors.secondary}
        ):Play()
    end)
    
    button.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = colors.primary}
        ):Play()
    end)
    
    return button
end

local function createLabel(name, parent, size, position, text)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Parent = parent
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.TextColor3 = colors.text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 2
    return label
end

local function createToggle(name, parent, size, position, default)
    local toggle = Instance.new("TextButton")
    toggle.Name = name
    toggle.Parent = parent
    toggle.Size = size
    toggle.Position = position
    toggle.BackgroundColor3 = default and colors.success or colors.danger
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 14
    toggle.Text = default and "✓" or "✗"
    toggle.AutoButtonColor = false
    toggle.BorderSizePixel = 0
    toggle.ZIndex = 2
    
    -- เอฟเฟกต์เมื่อโฮเวอร์
    toggle.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(
            toggle,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.3}
        ):Play()
    end)
    
    toggle.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(
            toggle,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0}
        ):Play()
    end)
    
    return toggle
end

local function createSlider(name, parent, size, position, min, max, default)
    local slider = Instance.new("Frame")
    slider.Name = name
    slider.Parent = parent
    slider.Size = size
    slider.Position = position
    slider.BackgroundColor3 = colors.secondary
    slider.BorderSizePixel = 0
    slider.ZIndex = 2
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Parent = slider
    fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = colors.accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 3
    
    local knob = Instance.new("TextButton")
    knob.Name = "Knob"
    knob.Parent = slider
    knob.Size = UDim2.new(0, 10, 1.5, 0)
    knob.Position = UDim2.new((default - min)/(max - min), -5, 0, -3)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.BorderSizePixel = 0
    knob.ZIndex = 4
    
    local valueLabel = createLabel("Value", parent, UDim2.new(0, 40, 0, 20), 
        UDim2.new(position.X.Scale + size.X.Scale + 0.02, 0, position.Y.Scale, 0), tostring(default))
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    return slider, fill, knob, valueLabel
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = colors.background
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Position = UDim2.new(0.5, -125, 0.2, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 1

-- Corner Radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = MainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Parent = MainFrame
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = colors.primary
titleBar.ZIndex = 2

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local title = createLabel("Title", titleBar, UDim2.new(0.7, 0, 1, 0), UDim2.new(0.05, 0, 0, 0), "👳🏿‍♂️ Maru Hub Private")
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local closeBtn = createButton("Close", titleBar, UDim2.new(0, 30, 0, 30), UDim2.new(1, -30, 0, 0), "×")
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.BackgroundColor3 = colors.danger
closeBtn.TextColor3 = Color3.new(1,1,1)

-- Minimize Button
local minimizeBtn = createButton("Minimize", titleBar, UDim2.new(0, 30, 0, 30), UDim2.new(1, -60, 0, 0), "-")
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Parent = MainFrame
contentFrame.Size = UDim2.new(1, -20, 1, -50)
contentFrame.Position = UDim2.new(0, 10, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.ZIndex = 2

-- Auto Attack Toggle
local attackLabel = createLabel("AttackLabel", contentFrame, UDim2.new(0.7, 0, 0, 25), UDim2.new(0, 0, 0, 0), "Enable Damage Aura")
local attackToggle = createToggle("AttackToggle", contentFrame, UDim2.new(0, 50, 0, 25), UDim2.new(0.8, 0, 0, 0), false)

-- Weapon Selection
local weaponLabel = createLabel("WeaponLabel", contentFrame, UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 0, 30), "Weapon: None")
local weaponBtn = createButton("WeaponBtn", contentFrame, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 55), "Select Weapon")
local refreshBtn = createButton("RefreshBtn", contentFrame, UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 0, 90), "Refresh Weapons")

-- Speed Hack
local speedLabel = createLabel("SpeedLabel", contentFrame, UDim2.new(0.7, 0, 0, 25), UDim2.new(0, 0, 0, 120), "Speed Hack")
local speedToggle = createToggle("SpeedToggle", contentFrame, UDim2.new(0, 50, 0, 25), UDim2.new(0.8, 0, 0, 120), false)

-- Speed Slider
local sliderLabel = createLabel("SliderLabel", contentFrame, UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 150), "WalkSpeed: 50")
local slider, fill, knob, sliderValue = createSlider("SpeedSlider", contentFrame, 
    UDim2.new(1, 0, 0, 10), UDim2.new(0, 0, 0, 175), 16, 216, 50)

-- Mobile Support
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

if isMobile then
    MainFrame.Size = UDim2.new(0.8, 0, 0, 250)
    MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    
    -- เพิ่มปุ่มสำหรับซ่อน GUI บนมือถือ
    local mobileToggleBtn = createButton("MobileToggle", ScreenGui, UDim2.new(0, 50, 0, 50), UDim2.new(0, 10, 0, 10), "☰")
    mobileToggleBtn.Font = Enum.Font.GothamBold
    mobileToggleBtn.TextSize = 20
    mobileToggleBtn.ZIndex = 10
    
    mobileToggleBtn.MouseButton1Click:Connect(function()
        isGuiVisible = not isGuiVisible
        MainFrame.Visible = isGuiVisible
    end)
end

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

-- Dropdown สำหรับเลือกอาวุธ
local dropdownVisible = false
local DropdownFrame

local function createDropdown()
    if DropdownFrame then DropdownFrame:Destroy() end
    
    local currentWeapons = getWeaponsFromBackpack()
    if #currentWeapons == 0 then
        table.insert(currentWeapons, "No Weapons")
    end
    
    DropdownFrame = Instance.new("Frame")
    DropdownFrame.Parent = contentFrame
    DropdownFrame.BackgroundColor3 = colors.primary
    DropdownFrame.Size = UDim2.new(1, 0, 0, #currentWeapons * 30)
    DropdownFrame.Position = UDim2.new(0, 0, 0, 85)
    DropdownFrame.ZIndex = 5
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 5)
    dropdownCorner.Parent = DropdownFrame
    
    for i, weapon in ipairs(currentWeapons) do
        local button = createButton(weapon, DropdownFrame, 
            UDim2.new(1, -10, 0, 25), 
            UDim2.new(0, 5, 0, (i-1) * 30 + 5), weapon)
        
        button.MouseButton1Click:Connect(function()
            shared.SelectedWeapon = weapon
            weaponLabel.Text = "Weapon: " .. weapon
            DropdownFrame:Destroy()
            dropdownVisible = false
        end)
    end
end

-- Event สำหรับ Weapon Button
weaponBtn.MouseButton1Click:Connect(function()
    dropdownVisible = not dropdownVisible
    if dropdownVisible then
        createDropdown()
    elseif DropdownFrame then
        DropdownFrame:Destroy()
    end
end)

-- Event สำหรับ Refresh Button
refreshBtn.MouseButton1Click:Connect(function()
    local currentWeapons = getWeaponsFromBackpack()
    if #currentWeapons > 0 then
        shared.SelectedWeapon = currentWeapons[1]
        weaponLabel.Text = "Weapon: " .. currentWeapons[1]
    else
        shared.SelectedWeapon = nil
        weaponLabel.Text = "Weapon: None"
    end
    if dropdownVisible then
        createDropdown()
    end
end)

-- Speed Toggle และ Slider Logic
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

speedToggle.MouseButton1Click:Connect(function()
    getgenv().Enabled = not getgenv().Enabled
    speedToggle.Text = getgenv().Enabled and "✓" or "✗"
    speedToggle.BackgroundColor3 = getgenv().Enabled and colors.success or colors.danger
end)

local dragging = false

knob.MouseButton1Down:Connect(function()
    dragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            mousePos = input.Position
        else
            mousePos = input.Position
        end
        
        local sliderPos = slider.AbsolutePosition
        local sliderSize = slider.AbsoluteSize
        local mouseX = mousePos.X - sliderPos.X
        local clampedX = math.clamp(mouseX, 0, sliderSize.X)
        local ratio = clampedX / sliderSize.X
        local speedValue = math.floor(16 + ratio * 200) -- 16-216
        
        -- อัปเดต UI
        knob.Position = UDim2.new(ratio, -5, 0, -3)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        sliderValue.Text = tostring(speedValue)
        sliderLabel.Text = "WalkSpeed: " .. speedValue
        
        -- อัปเดตค่า Speed
        getgenv().Speed = speedValue
    end
end)

-- ปุ่มปิด GUI
closeBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ปุ่มย่อ GUI
minimizeBtn.MouseButton1Click:Connect(function()
    isGuiExpanded = not isGuiExpanded
    local targetSize = isGuiExpanded and UDim2.new(0, 250, 0, 220) or UDim2.new(0, 250, 0, 30)
    
    game:GetService("TweenService"):Create(
        MainFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = targetSize}
    ):Play()
    
    minimizeBtn.Text = isGuiExpanded and "-" or "+"
    
    if not isGuiExpanded and DropdownFrame then
        DropdownFrame:Destroy()
        dropdownVisible = false
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
        attackToggle.Text = "✓"
        attackToggle.BackgroundColor3 = colors.success
        spawn(attackEnemies)
    else
        attackToggle.Text = "✗"
        attackToggle.BackgroundColor3 = colors.danger
    end
end

attackToggle.MouseButton1Click:Connect(toggleAutoAttack)

-- อัปเดต UI เมื่อเริ่มต้น
local weapons = getWeaponsFromBackpack()
if #weapons > 0 then
    shared.SelectedWeapon = weapons[1]
    weaponLabel.Text = "Weapon: " .. weapons[1]
else
    weaponLabel.Text = "Weapon: None"
end
