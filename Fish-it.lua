local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- อ้างอิง RemoteEvent และ RemoteFunction
local REFishingCompleted = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingCompleted"]
local RFSellAllItems = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]

-- สร้าง UI
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ป้องกันการสร้าง UI ซ้ำ
local existingGui = playerGui:FindFirstChild("FishingControlUI")
if existingGui then
    existingGui:Destroy()
end

-- สร้าง ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishingControlUI"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- สร้างปุ่ม Toggle UI
local toggleUIButton = Instance.new("TextButton")
toggleUIButton.Size = UDim2.new(0, 50, 0, 25)
toggleUIButton.Position = UDim2.new(0.5, -25, 0, 10)
toggleUIButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleUIButton.Text = "Show"
toggleUIButton.TextSize = 12
toggleUIButton.Parent = screenGui
local uiCornerToggle = Instance.new("UICorner")
uiCornerToggle.CornerRadius = UDim.new(0, 6)
uiCornerToggle.Parent = toggleUIButton
local uiStrokeToggle = Instance.new("UIStroke")
uiStrokeToggle.Color = Color3.fromRGB(120, 120, 120)
uiStrokeToggle.Thickness = 1
uiStrokeToggle.Parent = toggleUIButton

-- สร้าง Frame หลัก
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.25, 0, 0.25, 0)
frame.Position = UDim2.new(0.5, -frame.Size.X.Offset/2, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
local uiCornerFrame = Instance.new("UICorner")
uiCornerFrame.CornerRadius = UDim.new(0, 10)
uiCornerFrame.Parent = frame
local uiStrokeFrame = Instance.new("UIStroke")
uiStrokeFrame.Color = Color3.fromRGB(90, 90, 90)
uiStrokeFrame.Thickness = 1.5
uiStrokeFrame.Parent = frame
local uiGradientFrame = Instance.new("UIGradient")
uiGradientFrame.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
}
uiGradientFrame.Rotation = 45
uiGradientFrame.Parent = frame

-- เพิ่ม DropShadow
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 12, 1, 12)
shadow.Position = UDim2.new(0, -6, 0, -6)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.5
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ZIndex = -1
shadow.Parent = frame

-- สร้าง Container สำหรับปุ่ม
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -20, 1, -20)
buttonContainer.Position = UDim2.new(0, 10, 0, 10)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = frame

-- เพิ่ม UIPadding ใน Container
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 10)
uiPadding.PaddingBottom = UDim.new(0, 10)
uiPadding.PaddingLeft = UDim.new(0, 10)
uiPadding.PaddingRight = UDim.new(0, 10)
uiPadding.Parent = buttonContainer

-- เพิ่ม UIListLayout ใน Container
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 10)
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = buttonContainer

-- สร้างปุ่ม Toggle Fishing
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.6, 0, 0, 35)
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "Fishing: OFF"
toggleButton.TextSize = 12
toggleButton.Parent = buttonContainer
local uiCornerToggleFishing = Instance.new("UICorner")
uiCornerToggleFishing.CornerRadius = UDim.new(0, 6)
uiCornerToggleFishing.Parent = toggleButton
local uiStrokeToggleFishing = Instance.new("UIStroke")
uiStrokeToggleFishing.Color = Color3.fromRGB(110, 110, 110)
uiStrokeToggleFishing.Thickness = 1
uiStrokeToggleFishing.Parent = toggleButton

-- เพิ่ม Hover effect สำหรับ Toggle Button
local originalToggleColor = toggleButton.BackgroundColor3
toggleButton.MouseEnter:Connect(function()
    TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(90, 90, 90)}):Play()
end)
toggleButton.MouseLeave:Connect(function()
    TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = originalToggleColor}):Play()
end)

-- สร้างปุ่ม Sell All
local sellAllButton = Instance.new("TextButton")
sellAllButton.Size = UDim2.new(0.6, 0, 0, 35)
sellAllButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
sellAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sellAllButton.Text = "Sell All"
sellAllButton.TextSize = 12
sellAllButton.Parent = buttonContainer
local uiCornerSell = Instance.new("UICorner")
uiCornerSell.CornerRadius = UDim.new(0, 6)
uiCornerSell.Parent = sellAllButton
local uiStrokeSell = Instance.new("UIStroke")
uiStrokeSell.Color = Color3.fromRGB(110, 110, 110)
uiStrokeSell.Thickness = 1
uiStrokeSell.Parent = sellAllButton

-- เพิ่ม Hover effect สำหรับ Sell All Button
local originalSellColor = sellAllButton.BackgroundColor3
sellAllButton.MouseEnter:Connect(function()
    TweenService:Create(sellAllButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 80, 80)}):Play()
end)
sellAllButton.MouseLeave:Connect(function()
    TweenService:Create(sellAllButton, TweenInfo.new(0.2), {BackgroundColor3 = originalSellColor}):Play()
end)

-- สร้างปุ่ม Toggle Fly
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0.6, 0, 0, 35)
flyButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Text = "Fly: OFF"
flyButton.TextSize = 12
flyButton.Parent = buttonContainer
local uiCornerFly = Instance.new("UICorner")
uiCornerFly.CornerRadius = UDim.new(0, 6)
uiCornerFly.Parent = flyButton
local uiStrokeFly = Instance.new("UIStroke")
uiStrokeFly.Color = Color3.fromRGB(110, 110, 110)
uiStrokeFly.Thickness = 1
uiStrokeFly.Parent = flyButton

-- เพิ่ม Hover effect สำหรับ Fly Button
local originalFlyColor = flyButton.BackgroundColor3
flyButton.MouseEnter:Connect(function()
    TweenService:Create(flyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 140, 220)}):Play()
end)
flyButton.MouseLeave:Connect(function()
    TweenService:Create(flyButton, TweenInfo.new(0.2), {BackgroundColor3 = originalFlyColor}):Play()
end)

-- สร้างปุ่ม Adjust Fly Speed
local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0.6, 0, 0, 35)
speedButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.Text = "Speed: 100"
speedButton.TextSize = 12
speedButton.Parent = buttonContainer
local uiCornerSpeed = Instance.new("UICorner")
uiCornerSpeed.CornerRadius = UDim.new(0, 6)
uiCornerSpeed.Parent = speedButton
local uiStrokeSpeed = Instance.new("UIStroke")
uiStrokeSpeed.Color = Color3.fromRGB(110, 110, 110)
uiStrokeSpeed.Thickness = 1
uiStrokeSpeed.Parent = speedButton

-- เพิ่ม Hover effect สำหรับ Speed Button
local originalSpeedColor = speedButton.BackgroundColor3
speedButton.MouseEnter:Connect(function()
    TweenService:Create(speedButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(120, 120, 120)}):Play()
end)
speedButton.MouseLeave:Connect(function()
    TweenService:Create(speedButton, TweenInfo.new(0.2), {BackgroundColor3 = originalSpeedColor}):Play()
end)

-- ตัวแปรควบคุมสถานะ
local isFishingEnabled = false
local isUIVisible = false
local isFlying = false
local flySpeed = 100
local fishingLoop = nil
local flyLoop = nil
local bodyVelocity = nil

-- ฟังก์ชันสำหรับเรียก FireServer ในลูป Fishing
local function startFishingLoop()
    if fishingLoop then
        fishingLoop:Disconnect()
    end
    fishingLoop = RunService.Heartbeat:Connect(function()
        if isFishingEnabled then
            REFishingCompleted:FireServer()
        end
    end)
end

-- ฟังก์ชันหยุดลูป Fishing
local function stopFishingLoop()
    if fishingLoop then
        fishingLoop:Disconnect()
        fishingLoop = nil
    end
end

-- ฟังก์ชันเริ่มการบิน
local function startFlying()
    if not bodyVelocity then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Parent = humanoidRootPart
    end
    if flyLoop then flyLoop:Disconnect() end
    flyLoop = RunService.RenderStepped:Connect(function()
        if isFlying and bodyVelocity and bodyVelocity.Parent then
            local moveDirection = Vector3.new(0, 0, 0) -- ตั้งค่าเริ่มต้นเป็นศูนย์
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + humanoidRootPart.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - humanoidRootPart.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - humanoidRootPart.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + humanoidRootPart.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
            if moveDirection.Magnitude == 0 then
                bodyVelocity.Velocity = Vector3.new(0, bodyVelocity.Velocity.Y, 0) -- รักษาความสูงถ้าไม่มีอินพุตแนวนอน
            else
                moveDirection = moveDirection.Unit * flySpeed
                bodyVelocity.Velocity = Vector3.new(moveDirection.X, moveDirection.Y, moveDirection.Z)
            end
        elseif isFlying and not bodyVelocity then
            startFlying() -- รีเซ็ตถ้า bodyVelocity หาย
        end
    end)
    humanoidRootPart.Anchored = false
end

-- ฟังก์ชันหยุดการบิน
local function stopFlying()
    if flyLoop then flyLoop:Disconnect() flyLoop = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    humanoidRootPart.Anchored = false
end

-- การจัดการ Checkbox (Toggle Fishing)
toggleButton.MouseButton1Click:Connect(function()
    isFishingEnabled = not isFishingEnabled
    toggleButton.Text = "Fishing: " .. (isFishingEnabled and "ON" or "OFF")
    originalToggleColor = isFishingEnabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(70, 70, 70)
    TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = originalToggleColor}):Play()
    
    if isFishingEnabled then
        startFishingLoop()
    else
        stopFishingLoop()
    end
end)

-- การจัดการปุ่ม Sell All
sellAllButton.MouseButton1Click:Connect(function()
    RFSellAllItems:InvokeServer()
end)

-- การจัดการปุ่ม Toggle Fly
flyButton.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    flyButton.Text = "Fly: " .. (isFlying and "ON" or "OFF")
    originalFlyColor = isFlying and Color3.fromRGB(60, 180, 200) or Color3.fromRGB(60, 120, 200)
    TweenService:Create(flyButton, TweenInfo.new(0.2), {BackgroundColor3 = originalFlyColor}):Play()
    
    if isFlying then
        startFlying()
    else
        stopFlying()
    end
end)

-- การจัดการปุ่ม Adjust Fly Speed
speedButton.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 50
    if flySpeed > 300 then flySpeed = 100 end
    speedButton.Text = "Speed: " .. flySpeed
    originalSpeedColor = Color3.fromRGB(100 + (flySpeed - 100) / 2, 100 + (flySpeed - 100) / 2, 100 + (flySpeed - 100) / 2)
    TweenService:Create(speedButton, TweenInfo.new(0.2), {BackgroundColor3 = originalSpeedColor}):Play()
end)

-- การจัดการปุ่มเปิด/ปิด UI
toggleUIButton.MouseButton1Click:Connect(function()
    isUIVisible = not isUIVisible
    frame.Visible = isUIVisible
    toggleUIButton.Text = isUIVisible and "Hide" or "Show"
    if isUIVisible then
        frame.Size = UDim2.new(0, 0, 0, 0)
        frame.Visible = true
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0.25, 0, 0.25, 0)}):Play()
    else
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        wait(0.3)
        frame.Visible = false
    end
end)

-- การควบคุมด้วยคีย์บอร์ด (กด H เพื่อเปิด/ปิด UI)
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.H then
        isUIVisible = not isUIVisible
        frame.Visible = isUIVisible
        toggleUIButton.Text = isUIVisible and "Hide" or "Show"
        if isUIVisible then
            frame.Size = UDim2.new(0, 0, 0, 0)
            frame.Visible = true
            TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0.25, 0, 0.25, 0)}):Play()
        else
            TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            wait(0.3)
            frame.Visible = false
        end
    end
end)

-- เพิ่ม Hover effect สำหรับ Toggle UI Button
local originalToggleUIColor = toggleUIButton.BackgroundColor3
toggleUIButton.MouseEnter:Connect(function()
    TweenService:Create(toggleUIButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
end)
toggleUIButton.MouseLeave:Connect(function()
    TweenService:Create(toggleUIButton, TweenInfo.new(0.2), {BackgroundColor3 = originalToggleUIColor}):Play()
end)
