Fix
-- Remove old GUI if exists
if game.CoreGui:FindFirstChild("AutoAttackGUI") then
    game.CoreGui.AutoAttackGUI:Destroy()
end

-- Settings
shared.AutoAttack = false
shared.SelectedWeapon = nil
local isGuiExpanded = true
local isGuiVisible = true
getgenv().Speed = 50
getgenv().Enabled = false

-- UI Library
local UI = {
    Colors = {
        Dark = Color3.fromRGB(20, 20, 25),
        Darker = Color3.fromRGB(15, 15, 20),
        Primary = Color3.fromRGB(30, 30, 40),
        Secondary = Color3.fromRGB(45, 45, 60),
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(240, 240, 250),
        Success = Color3.fromRGB(50, 200, 100),
        Danger = Color3.fromRGB(220, 70, 70),
        Warning = Color3.fromRGB(255, 170, 0)
    },
    Fonts = {
        Title = Enum.Font.GothamBlack,
        Header = Enum.Font.GothamBold,
        Body = Enum.Font.GothamMedium,
        Label = Enum.Font.Gotham
    }
}

local function Create(class, props)
    local inst = Instance.new(class)
    for prop, val in pairs(props) do
        inst[prop] = val
    end
    return inst
end

-- Main GUI
local ScreenGui = Create("ScreenGui", {
    Name = "AutoAttackGUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    Parent = game.CoreGui
})

local MainContainer = Create("Frame", {
    Name = "MainContainer",
    Size = UDim2.new(0, 280, 0, 40),
    Position = UDim2.new(0.5, -140, 0.2, 0),
    BackgroundColor3 = UI.Colors.Dark,
    AnchorPoint = Vector2.new(0.5, 0),
    Active = true,
    Draggable = true,
    Parent = ScreenGui
})

Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainContainer})
Create("UIStroke", {Color = UI.Colors.Primary, Thickness = 2, Parent = MainContainer})

-- Title Bar
local TitleBar = Create("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = UI.Colors.Primary,
    Parent = MainContainer
})

Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = TitleBar})

local Title = Create("TextLabel", {
    Name = "Title",
    Size = UDim2.new(0.7, 0, 1, 0),
    Position = UDim2.new(0.05, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "⚔️ MARU HUB",
    TextColor3 = UI.Colors.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = UI.Fonts.Title,
    TextSize = 18,
    Parent = TitleBar
})

-- Control Buttons
local MinimizeBtn = Create("TextButton", {
    Name = "MinimizeBtn",
    Size = UDim2.new(0, 40, 1, 0),
    Position = UDim2.new(1, -80, 0, 0),
    BackgroundColor3 = UI.Colors.Secondary,
    TextColor3 = UI.Colors.Text,
    Text = "-",
    Font = UI.Fonts.Header,
    TextSize = 20,
    Parent = TitleBar
})

Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MinimizeBtn})

local CloseBtn = Create("TextButton", {
    Name = "CloseBtn",
    Size = UDim2.new(0, 40, 1, 0),
    Position = UDim2.new(1, -40, 0, 0),
    BackgroundColor3 = UI.Colors.Danger,
    TextColor3 = Color3.new(1,1,1),
    Text = "×",
    Font = UI.Fonts.Header,
    TextSize = 20,
    Parent = TitleBar
})

Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = CloseBtn})

-- Content Frame
local ContentFrame = Create("Frame", {
    Name = "ContentFrame",
    Size = UDim2.new(1, -20, 1, -60),
    Position = UDim2.new(0, 10, 0, 50),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Parent = MainContainer
})

-- Auto Attack Section
local AttackSection = Create("Frame", {
    Name = "AttackSection",
    Size = UDim2.new(1, 0, 0, 80),
    BackgroundTransparency = 1,
    Parent = ContentFrame
})

Create("TextLabel", {
    Name = "SectionTitle",
    Size = UDim2.new(1, 0, 0, 25),
    BackgroundTransparency = 1,
    Text = "DAMAGE AURA",
    TextColor3 = UI.Colors.Accent,
    Font = UI.Fonts.Header,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = AttackSection
})

local AttackToggle = Create("TextButton", {
    Name = "AttackToggle",
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 25),
    BackgroundColor3 = UI.Colors.Danger,
    TextColor3 = Color3.new(1,1,1),
    Text = "✗ OFF",
    Font = UI.Fonts.Body,
    TextSize = 14,
    AutoButtonColor = false,
    Parent = AttackSection
})

Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = AttackToggle})
Create("UIStroke", {Color = UI.Colors.Darker, Thickness = 1, Parent = AttackToggle})

-- Weapon Selection
local WeaponBtn = Create("TextButton", {
    Name = "WeaponBtn",
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 60),
    BackgroundColor3 = UI.Colors.Primary,
    TextColor3 = UI.Colors.Text,
    Text = "SELECT WEAPON",
    Font = UI.Fonts.Body,
    TextSize = 14,
    AutoButtonColor = false,
    Parent = AttackSection
})

Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = WeaponBtn})
Create("UIStroke", {Color = UI.Colors.Darker, Thickness = 1, Parent = WeaponBtn})

-- Speed Section
local SpeedSection = Create("Frame", {
    Name = "SpeedSection",
    Size = UDim2.new(1, 0, 0, 100),
    Position = UDim2.new(0, 0, 0, 100),
    BackgroundTransparency = 1,
    Parent = ContentFrame
})

Create("TextLabel", {
    Name = "SectionTitle",
    Size = UDim2.new(1, 0, 0, 25),
    BackgroundTransparency = 1,
    Text = "SPEED HACK",
    TextColor3 = UI.Colors.Accent,
    Font = UI.Fonts.Header,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = SpeedSection
})

local SpeedToggle = Create("TextButton", {
    Name = "SpeedToggle",
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 25),
    BackgroundColor3 = UI.Colors.Danger,
    TextColor3 = Color3.new(1,1,1),
    Text = "✗ OFF",
    Font = UI.Fonts.Body,
    TextSize = 14,
    AutoButtonColor = false,
    Parent = SpeedSection
})

Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SpeedToggle})
Create("UIStroke", {Color = UI.Colors.Darker, Thickness = 1, Parent = SpeedToggle})

-- Speed Slider
local SpeedSlider = Create("Frame", {
    Name = "SpeedSlider",
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 60),
    BackgroundColor3 = UI.Colors.Secondary,
    Parent = SpeedSection
})

Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = SpeedSlider})
Create("UIStroke", {Color = UI.Colors.Darker, Thickness = 1, Parent = SpeedSlider})

local SpeedFill = Create("Frame", {
    Name = "SpeedFill",
    Size = UDim2.new((getgenv().Speed - 16)/200, 0, 1, 0),
    BackgroundColor3 = UI.Colors.Accent,
    Parent = SpeedSlider
})

Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = SpeedFill})

local SpeedKnob = Create("TextButton", {
    Name = "SpeedKnob",
    Size = UDim2.new(0, 12, 1.5, 0),
    Position = UDim2.new((getgenv().Speed - 16)/200, -6, 0, -3),
    BackgroundColor3 = Color3.new(1,1,1),
    AutoButtonColor = false,
    Text = "",
    Parent = SpeedSlider
})

Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = SpeedKnob})
Create("UIStroke", {Color = UI.Colors.Darker, Thickness = 1, Parent = SpeedKnob})

local SpeedValue = Create("TextLabel", {
    Name = "SpeedValue",
    Size = UDim2.new(0, 50, 0, 20),
    Position = UDim2.new(1, -50, 0, 30),
    BackgroundTransparency = 1,
    Text = getgenv().Speed,
    TextColor3 = UI.Colors.Text,
    Font = UI.Fonts.Body,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = SpeedSection
})

-- Mobile Support
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

if isMobile then
    MainContainer.Size = UDim2.new(0.9, 0, 0, 40)
    MainContainer.Position = UDim2.new(0.5, 0, 0.1, 0)
    MainContainer.AnchorPoint = Vector2.new(0.5, 0)
    
    local MobileToggle = Create("TextButton", {
        Name = "MobileToggle",
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = UI.Colors.Primary,
        TextColor3 = UI.Colors.Text,
        Text = "☰",
        Font = UI.Fonts.Header,
        TextSize = 24,
        ZIndex = 10,
        Parent = ScreenGui
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MobileToggle})
    Create("UIStroke", {Color = UI.Colors.Darker, Thickness = 2, Parent = MobileToggle})
    
    MobileToggle.MouseButton1Click:Connect(function()
        isGuiVisible = not isGuiVisible
        MainContainer.Visible = isGuiVisible
    end)
end

-- Dropdown Menu
local DropdownFrame
local function CreateDropdown()
    if DropdownFrame then 
        DropdownFrame:Destroy() 
        DropdownFrame = nil
        return
    end
    
    local weapons = {}
    local backpack = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then table.insert(weapons, item.Name) end
        end
    end
    
    if #weapons == 0 then table.insert(weapons, "No weapons found") end
    
    DropdownFrame = Create("Frame", {
        Name = "DropdownFrame",
        Size = UDim2.new(1, 0, 0, math.min(#weapons * 35 + 10, 150)),
        Position = UDim2.new(0, 0, 0, 95),
        BackgroundColor3 = UI.Colors.Darker,
        Parent = AttackSection,
        ZIndex = 5
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = DropdownFrame})
    Create("UIStroke", {Color = UI.Colors.Primary, Thickness = 1, Parent = DropdownFrame})
    
    local ScrollFrame = Create("ScrollingFrame", {
        Name = "ScrollFrame",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 0, #weapons * 35),
        Parent = DropdownFrame
    })
    
    for i, weapon in ipairs(weapons) do
        local btn = Create("TextButton", {
            Name = weapon,
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, (i-1)*35),
            BackgroundColor3 = UI.Colors.Primary,
            TextColor3 = UI.Colors.Text,
            Text = weapon,
            Font = UI.Fonts.Body,
            TextSize = 14,
            AutoButtonColor = false,
            Parent = ScrollFrame
        })
        
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
        Create("UIStroke", {Color = UI.Colors.Darker, Thickness = 1, Parent = btn})
        
        btn.MouseButton1Click:Connect(function()
            if weapon ~= "No weapons found" then
                shared.SelectedWeapon = weapon
                WeaponBtn.Text = "WEAPON: "..weapon:upper()
            end
            DropdownFrame:Destroy()
            DropdownFrame = nil
        end)
    end
end

-- Weapon Button Click
WeaponBtn.MouseButton1Click:Connect(function()
    CreateDropdown()
end)

-- Refresh Weapons Function
local function RefreshWeapons()
    local weapons = {}
    local backpack = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then table.insert(weapons, item.Name) end
        end
    end
    
    if #weapons > 0 then
        shared.SelectedWeapon = weapons[1]
        WeaponBtn.Text = "WEAPON: "..weapons[1]:upper()
    else
        WeaponBtn.Text = "SELECT WEAPON"
        shared.SelectedWeapon = nil
    end
    
    if DropdownFrame then
        CreateDropdown() -- Refresh dropdown if open
    end
end

-- Auto Attack Function
local function ToggleAutoAttack()
    shared.AutoAttack = not shared.AutoAttack
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(
        AttackToggle,
        tweenInfo,
        {
            BackgroundColor3 = shared.AutoAttack and UI.Colors.Success or UI.Colors.Danger,
            Text = shared.AutoAttack and "✓ ON" or "✗ OFF"
        }
    )
    tween:Play()
    
    if shared.AutoAttack then
        spawn(function()
            while shared.AutoAttack and task.wait() do
                if shared.SelectedWeapon then
                    -- Your attack code here
                end
            end
        end)
    end
end

AttackToggle.MouseButton1Click:Connect(ToggleAutoAttack)

-- Speed Hack Toggle
local function ToggleSpeedHack()
    getgenv().Enabled = not getgenv().Enabled
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(
        SpeedToggle,
        tweenInfo,
        {
            BackgroundColor3 = getgenv().Enabled and UI.Colors.Success or UI.Colors.Danger,
            Text = getgenv().Enabled and "✓ ON" or "✗ OFF"
        }
    )
    tween:Play()
end

SpeedToggle.MouseButton1Click:Connect(ToggleSpeedHack)

-- Slider Logic
local dragging = false
local function UpdateSlider(input)
    local sliderPos = SpeedSlider.AbsolutePosition
    local sliderSize = SpeedSlider.AbsoluteSize
    local mousePos = input.Position
    local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize.X)
    local ratio = relativeX / sliderSize.X
    local speed = math.floor(16 + ratio * 200) -- 16-216
    
    getgenv().Speed = speed
    SpeedValue.Text = tostring(speed)
    
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    game:GetService("TweenService"):Create(
        SpeedFill,
        tweenInfo,
        {Size = UDim2.new(ratio, 0, 1, 0)}
    ):Play()
    
    game:GetService("TweenService"):Create(
        SpeedKnob,
        tweenInfo,
        {Position = UDim2.new(ratio, -6, 0, -3)}
    ):Play()
end

SpeedKnob.MouseButton1Down:Connect(function()
    dragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        UpdateSlider(input)
    end
end)

-- Mobile Touch Support
if isMobile then
    SpeedSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
        end
    end)
    
    SpeedSlider.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            UpdateSlider(input)
        end
    end)
    
    SpeedSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Minimize Function
local function ToggleMinimize()
    isGuiExpanded = not isGuiExpanded
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(
        MainContainer,
        tweenInfo,
        {Size = isGuiExpanded and UDim2.new(0, 280, 0, 250) or UDim2.new(0, 280, 0, 40)}
    )
    tween:Play()
    
    MinimizeBtn.Text = isGuiExpanded and "-" or "+"
end

MinimizeBtn.MouseButton1Click:Connect(ToggleMinimize)

-- Close Function
CloseBtn.MouseButton1Click:Connect(function()
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    game:GetService("TweenService"):Create(
        MainContainer,
        tweenInfo,
        {Size = UDim2.new(0, 280, 0, 0)}
    ):Play()
    
    task.wait(0.3)
    ScreenGui:Destroy()
end)

-- Hover Effects
local function SetupHoverEffect(button)
    button.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.3}
        ):Play()
    end)
    
    button.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0}
        ):Play()
    end)
end

-- Apply hover effects to all buttons
for _, button in pairs(MainContainer:GetDescendants()) do
    if button:IsA("TextButton") and button.Name ~= "SpeedKnob" then
        SetupHoverEffect(button)
    end
end

-- Initialization
RefreshWeapons()

-- Fix for mobile viewport
if isMobile then
    game:GetService("RunService").RenderStepped:Connect(function()
        if MainContainer.AbsoluteSize.Y > 100 then
            ContentFrame.Visible = true
        else
            ContentFrame.Visible = false
        end
    end)
end
