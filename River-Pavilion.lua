local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AcceptCarry = Remotes:WaitForChild("AcceptCarry")
local GetOff = Remotes:WaitForChild("GetOff")

-- สร้าง UI
local gui = Instance.new("ScreenGui")
gui.Name = "CarryControlUI"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 250)
frame.Position = UDim2.new(0.5, -100, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "เนตรนารีฮ๊าฟ Control"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextScaled = true
title.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0, 40)
toggleButton.Position = UDim2.new(0.05, 0, 0, 40)
toggleButton.Text = "Start"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
toggleButton.TextScaled = true
toggleButton.Parent = frame

local carryDelayLabel = Instance.new("TextLabel")
carryDelayLabel.Size = UDim2.new(0.9, 0, 0, 20)
carryDelayLabel.Position = UDim2.new(0.05, 0, 0, 90)
carryDelayLabel.Text = "Carry-GetOff Delay (s):"
carryDelayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
carryDelayLabel.BackgroundTransparency = 1
carryDelayLabel.TextScaled = true
carryDelayLabel.Parent = frame

local carryDelayInput = Instance.new("TextBox")
carryDelayInput.Size = UDim2.new(0.9, 0, 0, 30)
carryDelayInput.Position = UDim2.new(0.05, 0, 0, 110)
carryDelayInput.Text = "0.0001"
carryDelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
carryDelayInput.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
carryDelayInput.TextScaled = true
carryDelayInput.Parent = frame

local swapDelayLabel = Instance.new("TextLabel")
swapDelayLabel.Size = UDim2.new(0.9, 0, 0, 20)
swapDelayLabel.Position = UDim2.new(0.05, 0, 0, 150)
swapDelayLabel.Text = "Player Swap Delay (s):"
swapDelayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
swapDelayLabel.BackgroundTransparency = 1
swapDelayLabel.TextScaled = true
swapDelayLabel.Parent = frame

local swapDelayInput = Instance.new("TextBox")
swapDelayInput.Size = UDim2.new(0.9, 0, 0, 30)
swapDelayInput.Position = UDim2.new(0.05, 0, 0, 170)
swapDelayInput.Text = "0.1"
swapDelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
swapDelayInput.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
swapDelayInput.TextScaled = true
swapDelayInput.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.3, 0, 0, 30)
closeButton.Position = UDim2.new(0.65, 0, 0, 210)
closeButton.Text = "Close"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
closeButton.TextScaled = true
closeButton.Parent = frame

-- ตัวแปรควบคุม
local isRunning = false
local currentIndex = 1

-- ฟังก์ชันเรียก AcceptCarry และ GetOff
local function applyCarry(player)
    if player ~= LocalPlayer and player.Character then
        local carryDelay = tonumber(carryDelayInput.Text) or 0.5
        local args = {
            player,
            "PiggyBack"
        }
        pcall(function()
            AcceptCarry:FireServer(unpack(args))
            print("Called AcceptCarry for " .. player.Name)
            wait(carryDelay)
            GetOff:FireServer()
            print("Called GetOff after carrying " .. player.Name)
        end)
    else
        print("Skipped " .. player.Name .. " (either LocalPlayer or no Character)")
    end
end

-- ฟังก์ชันสลับเป้าหมาย
local function swapToNextPlayer()
    if not isRunning then return end
    local playerList = Players:GetPlayers()
    if #playerList <= 1 then
        print("No other players to target")
        return
    end

    local targetPlayer
    local startIndex = currentIndex
    repeat
        targetPlayer = playerList[currentIndex]
        currentIndex = currentIndex % #playerList + 1
        if currentIndex == startIndex then
            print("No valid targets found")
            return
        end
    until targetPlayer ~= LocalPlayer and targetPlayer.Character

    applyCarry(targetPlayer)
    print("Swapped to next player: " .. targetPlayer.Name)
end

-- ควบคุมการเปิด/ปิด
toggleButton.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    toggleButton.Text = isRunning and "Stop" or "Start"
    toggleButton.BackgroundColor3 = isRunning and Color3.fromRGB(120, 0, 0) or Color3.fromRGB(0, 120, 0)
    if isRunning then
        spawn(function()
            while isRunning do
                swapToNextPlayer()
                local swapDelay = tonumber(swapDelayInput.Text) or 2
                wait(swapDelay)
            end
        end)
    end
end)

-- ปิด UI
closeButton.MouseButton1Click:Connect(function()
    isRunning = false
    gui:Destroy()
end)

-- จัดการผู้เล่นใหม่
Players.PlayerAdded:Connect(function(player)
    print(player.Name .. " joined, will be included in next swap")
end)

-- จัดการผู้เล่นที่ออก
Players.PlayerRemoving:Connect(function(player)
    print(player.Name .. " left the game")
    if currentIndex > #Players:GetPlayers() then
        currentIndex = 1
    end
end)

-- ลาก UI ได้
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
