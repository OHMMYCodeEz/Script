local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "เนตรนารี ฮัปฟูํววว " .. Fluent.Version,
    SubTitle = "by ohmmy69",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ตัวแปรเก็บตำแหน่งเดิม
local originalPosition = nil

-- สร้างปุ่ม Minimize แยก
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FluentMinimizeButton"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 40, 0, 40)
MinimizeButton.Position = UDim2.new(0, 20, 0, 20)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MinimizeButton.BorderColor3 = Color3.fromRGB(20, 20, 20)
MinimizeButton.BorderSizePixel = 2
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 20
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = ScreenGui

-- ทำให้ปุ่มกลม
MinimizeButton.AutoButtonColor = false
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = MinimizeButton

-- เพิ่มเอฟเฟกต์เมื่อโฮเวอร์
MinimizeButton.MouseEnter:Connect(function()
    game:GetService("TweenService"):Create(MinimizeButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(65, 65, 65),
        Size = UDim2.new(0, 45, 0, 45)
    }):Play()
end)

MinimizeButton.MouseLeave:Connect(function()
    game:GetService("TweenService"):Create(MinimizeButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Size = UDim2.new(0, 40, 0, 40)
    }):Play()
end)

-- ฟังก์ชันสำหรับ minimize/maximize
local function toggleWindowVisibility()
    if Window.Visible then
        Window.Visible = false  -- ซ่อนหน้าต่าง
        MinimizeButton.Text = "+"
    else
        Window.Visible = true  -- แสดงหน้าต่าง
        MinimizeButton.Text = "_"
    end
end

-- ฟังก์ชันสำหรับการจำลองการกดปุ่ม LeftControl
local function simulateLeftControlPress()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "LeftControl", false, game)  -- กดปุ่ม LeftControl
    toggleWindowVisibility()  -- เรียกฟังก์ชันซ่อน/แสดงหน้าต่าง
end

-- ทำให้ MinimizeButton ซ่อน/แสดงหน้าต่างและจำลองการกด LeftControl
MinimizeButton.MouseButton1Click:Connect(function()
    simulateLeftControlPress()  -- เรียกฟังก์ชันจำลองการกด LeftControl
end)

-- ใช้ `UserInputService` เพื่อจับการกดปุ่ม LeftControl
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end  -- หากเกมประมวลผลการกดแล้ว ให้ข้าม
    if input.KeyCode == Enum.KeyCode.LeftControl then
        toggleWindowVisibility()  -- เรียกฟังก์ชันซ่อน/แสดงหน้าต่างเมื่อกด LeftControl
    end
end)

-- Fishing function
local function startFishing()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    -- Check player status
    if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
        return false
    end

    -- Part 1: Equip fishing rod
    local args = {1}
    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE/EquipToolFromHotbar"):FireServer(unpack(args))

    -- Part 2: Charge fishing rod
    local args2 = {tick()}
    local success2, result2 = pcall(function()
        return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/ChargeFishingRod"):InvokeServer(unpack(args2))
    end)
    if not success2 then
        return false
    end

    -- Part 3: Start fishing minigame
    local args3 = {-0.233184814453125, 3.9932774359211974}
    local success3, result3 = pcall(function()
        return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/RequestFishingMinigameStarted"):InvokeServer(unpack(args3))
    end)
    if not success3 then
        return false
    end
    return true
end

-- Complete fishing function
local function completeFishing()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    -- Check player status
    if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
        return false
    end

    -- Fire FishingCompleted event
    local success, result = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE/FishingCompleted"):FireServer()
        return true
    end)
    if not success then
        return false
    end
    return true
end

-- Equip rod function
local function equipRod()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    -- Check player status
    if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
        return false
    end

    -- Equip fishing rod
    local args = {1}
    local success, result = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE/EquipToolFromHotbar"):FireServer(unpack(args))
        return true
    end)
    if not success then
        return false
    end
    return true
end

-- Sell all fish function
local function sellAllFish()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    -- Check player status
    if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
        return false
    end

    -- Fire SellAllItems event
    local success, result = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/SellAllItems"):InvokeServer()
    end)
    if not success then
        return false
    end
    return true
end

-- List of islands from the file you provided
local islandNames = {
    "Coral Reefs",
    "Crater Island", 
    "Esoteric Depths",
    "Fisherman Island",
    "Kohana",
    "Kohana Volcano",
    "Lost Isle",
    "Tropical Grove",
    "Weather Machine"
}

-- Function to find island position by name
local function findIslandPosition(islandName)
    local workspace = game:GetService("Workspace")
    
    -- Method 1: Search in workspace directly
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == islandName and (obj:IsA("Part") or obj:IsA("Model")) then
            if obj:IsA("Part") then
                return obj.Position + Vector3.new(0, 5, 0)
            elseif obj:IsA("Model") and obj.PrimaryPart then
                return obj.PrimaryPart.Position + Vector3.new(0, 5, 0)
            end
        end
    end
    
    -- Method 2: Search for any object that contains the island name
    for _, obj in pairs(workspace:GetDescendants()) do
        if string.find(obj.Name:lower(), islandName:lower()) and (obj:IsA("Part") or obj:IsA("Model")) then
            if obj:IsA("Part") then
                return obj.Position + Vector3.new(0, 5, 0)
            elseif obj:IsA("Model") and obj.PrimaryPart then
                return obj.PrimaryPart.Position + Vector3.new(0, 5, 0)
            end
        end
    end
    
    -- Method 3: Check common locations
    local commonLocations = {
        ["Coral Reefs"] = Vector3.new(100, 20, -200),
        ["Crater Island"] = Vector3.new(-150, 50, 300),
        ["Fisherman Island"] = Vector3.new(0, 25, 500),
        ["Kohana"] = Vector3.new(200, 30, -100),
        ["Kohana Volcano"] = Vector3.new(250, 100, -150),
        ["Tropical Grove"] = Vector3.new(-100, 40, -300)
    }
    
    if commonLocations[islandName] then
        return commonLocations[islandName]
    end
    
    return nil
end

-- Function to get event names from workspace.Props
local function getEventNames()
    local eventNames = {}
    local propsFolder = workspace:FindFirstChild("Props")
    
    if propsFolder then
        for _, prop in pairs(propsFolder:GetChildren()) do
            if prop:IsA("Model") or prop:IsA("Part") then
                table.insert(eventNames, prop.Name)
            end
        end
    end
    
    if #eventNames == 0 then
        table.insert(eventNames, "No events found")
    end
    
    return eventNames
end

-- Function to find event position by name
local function findEventPosition(eventName)
    local propsFolder = workspace:FindFirstChild("Props")
    
    if not propsFolder then
        return nil
    end
    
    local event = propsFolder:FindFirstChild(eventName)
    if not event then
        return nil
    end
    
    if event:IsA("Part") then
        return event.Position + Vector3.new(0, 5, 0)
    elseif event:IsA("Model") and event.PrimaryPart then
        return event.PrimaryPart.Position + Vector3.new(0, 5, 0)
    elseif event:IsA("Model") then
        -- Try to find any part in the model
        for _, part in pairs(event:GetDescendants()) do
            if part:IsA("Part") then
                return part.Position + Vector3.new(0, 5, 0)
            end
        end
    end
    
    return nil
end

-- Function to save current position
local function saveCurrentPosition()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        originalPosition = player.Character.HumanoidRootPart.Position
        return true
    end
    return false
end

-- Function to teleport back to original position
local function teleportBackToOriginal()
    if not originalPosition then
        Fluent:Notify({
            Title = "Error",
            Content = "No original position saved",
            Duration = 3
        })
        return false
    end
    
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
        Fluent:Notify({
            Title = "Success",
            Content = "Teleported back to original position",
            Duration = 3
        })
        return true
    end
    return false
end

-- Teleport to island function
local function teleportToIsland(islandName)
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    -- Check player status
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        Fluent:Notify({
            Title = "Error",
            Content = "Player character not found",
            Duration = 3
        })
        return false
    end

    -- Find island position
    local targetPosition = findIslandPosition(islandName)
    
    if not targetPosition then
        Fluent:Notify({
            Title = "Error",
            Content = "Could not find position for " .. islandName,
            Duration = 3
        })
        return false
    end

    -- Perform teleport
    local humanoidRootPart = player.Character.HumanoidRootPart
    humanoidRootPart.CFrame = CFrame.new(targetPosition)
    
    Fluent:Notify({
        Title = "Success",
        Content = "Teleported to " .. islandName,
        Duration = 3
    })
    
    return true
end

-- Teleport to event function
local function teleportToEvent(eventName)
    if eventName == "No events found" then
        Fluent:Notify({
            Title = "Error",
            Content = "No events available",
            Duration = 3
        })
        return false
    end
    
    local player = game.Players.LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        Fluent:Notify({
            Title = "Error",
            Content = "Player character not found",
            Duration = 3
        })
        return false
    end

    -- Save current position before teleporting
    saveCurrentPosition()
    
    local targetPosition = findEventPosition(eventName)
    
    if not targetPosition then
        Fluent:Notify({
            Title = "Error",
            Content = "Could not find event: " .. eventName,
            Duration = 3
        })
        return false
    end

    player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
    
    Fluent:Notify({
        Title = "Success",
        Content = "Teleported to event: " .. eventName,
        Duration = 3
    })
    
    return true
end

do
    -- Main tab setup
    Tabs.Main:AddParagraph({
        Title = "Fishing Automation",
        Content = "Automate fishing tasks and teleport to islands"
    })

    -- Auto fishing toggle
    local FishingToggle = Tabs.Main:AddToggle("FishingToggle", {
        Title = "Auto Fishing",
        Description = "Toggles automatic fishing on/off",
        Default = false
    })

    FishingToggle:OnChanged(function()
        if Options.FishingToggle.Value then
            task.spawn(function()
                while Options.FishingToggle.Value and not Fluent.Unloaded do
                    local success = startFishing()
                    if not success then
                        Options.FishingToggle:SetValue(false)
                        break
                    end
                    wait(4)
                end
            end)
        end
    end)

    -- Fishing completed toggle
    local CompleteFishingToggle = Tabs.Main:AddToggle("CompleteFishingToggle", {
        Title = "Auto Complete Fishing",
        Description = "Toggles automatic fishing completion on/off",
        Default = false
    })

    CompleteFishingToggle:OnChanged(function()
        if Options.CompleteFishingToggle.Value then
            task.spawn(function()
                while Options.CompleteFishingToggle.Value and not Fluent.Unloaded do
                    local success = completeFishing()
                    if not success then
                        Options.CompleteFishingToggle:SetValue(false)
                        break
                    end
                    wait(0.5)
                end
            end)
        end
    end)

    -- Auto equip rod toggle
    local EquipRodToggle = Tabs.Main:AddToggle("EquipRodToggle", {
        Title = "Auto Equip Rod",
        Description = "Toggles automatic rod equipping on/off",
        Default = false
    })

    EquipRodToggle:OnChanged(function()
        if Options.EquipRodToggle.Value then
            task.spawn(function()
                while Options.EquipRodToggle.Value and not Fluent.Unloaded do
                    local success = equipRod()
                    if not success then
                        Options.EquipRodToggle:SetValue(false)
                        break
                    end
                    wait(0.5)
                end
            end)
        end
    end)

    -- Sell all fish toggle and delay input
    local SellAllFishToggle = Tabs.Main:AddToggle("SellAllFishToggle", {
        Title = "Auto Sell All Fish",
        Description = "Toggles automatic selling of all fish on/off",
        Default = false
    })

    local SellDelayInput = Tabs.Main:AddInput("SellDelayInput", {
        Title = "Sell Delay (seconds)",
        Description = "Set the delay between sell attempts",
        Default = "0.5",
        Placeholder = "Enter delay in seconds",
        Numeric = true,
        Finished = false,
        Callback = function(Value)
            Options.SellDelayInput.Value = math.max(0.1, tonumber(Value) or 0.5)
        end
    })

    SellAllFishToggle:OnChanged(function()
        if Options.SellAllFishToggle.Value then
            task.spawn(function()
                while Options.SellAllFishToggle.Value and not Fluent.Unloaded do
                    local success = sellAllFish()
                    if not success then
                        Options.SellAllFishToggle:SetValue(false)
                        break
                    end
                    wait(tonumber(Options.SellDelayInput.Value) or 0.5)
                end
            end)
        end
    end)

    -- Teleport to Event Toggle
    local EventDropdown = Tabs.Main:AddDropdown("EventDropdown", {
        Title = "Select Event",
        Description = "Choose an event to teleport to",
        Values = getEventNames(),
        Multi = false,
        Default = getEventNames()[1] or "No events found"
    })

    local TeleportEventToggle = Tabs.Main:AddToggle("TeleportEventToggle", {
        Title = "Teleport To Event",
        Description = "Teleport to selected event and back when toggled off",
        Default = false
    })

    TeleportEventToggle:OnChanged(function()
        if Options.TeleportEventToggle.Value then
            -- Teleport to event
            local selectedEvent = Options.EventDropdown.Value
            teleportToEvent(selectedEvent)
        else
            -- Teleport back to original position
            teleportBackToOriginal()
        end
    end)

    -- Refresh events button
    Tabs.Main:AddButton({
        Title = "Refresh Events",
        Description = "Refresh the list of available events",
        Callback = function()
            local events = getEventNames()
            Options.EventDropdown:SetValues(events)
            Options.EventDropdown:SetValue(events[1])
        end
    })

    -- Teleport tab setup
    Tabs.Teleport:AddParagraph({
        Title = "Island Teleportation",
        Content = "Select an island to teleport to"
    })

    local IslandDropdown = Tabs.Teleport:AddDropdown("IslandDropdown", {
        Title = "Select Island",
        Description = "Choose an island to teleport to",
        Values = islandNames,
        Multi = false,
        Default = islandNames[1] or "Coral Reefs"
    })

    Tabs.Teleport:AddButton({
        Title = "Teleport to Selected Island",
        Description = "Teleport to the currently selected island",
        Callback = function()
            local selectedIsland = Options.IslandDropdown.Value
            teleportToIsland(selectedIsland)
        end
    })

    Tabs.Teleport:AddButton({
        Title = "Refresh Island List",
        Description = "Refresh the list of available islands",
        Callback = function()
            IslandDropdown:SetValues(islandNames)
            IslandDropdown:SetValue(islandNames[1])
        end
    })

    -- Add manual position input for custom teleport
    Tabs.Teleport:AddInput("CustomPosition", {
        Title = "Custom Position (X, Y, Z)",
        Description = "Enter custom coordinates to teleport to",
        Default = "0, 0, 0",
        Placeholder = "Example: 100, 50, -200",
        Numeric = false,
        Finished = false,
        Callback = function(Value)
            -- This is just for storage, actual teleport happens in the button
        end
    })

    Tabs.Teleport:AddButton({
        Title = "Teleport to Custom Position",
        Description = "Teleport to the specified coordinates",
        Callback = function()
            local coordsText = Options.CustomPosition.Value
            local coords = {}
            
            for num in string.gmatch(coordsText, "[%-%d%.]+") do
                table.insert(coords, tonumber(num))
            end
            
            if #coords == 3 then
                local player = game.Players.LocalPlayer
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(coords[1], coords[2], coords[3])
                    Fluent:Notify({
                        Title = "Success",
                        Content = "Teleported to custom position",
                        Duration = 3
                    })
                end
            else
                Fluent:Notify({
                    Title = "Error",
                    Content = "Invalid coordinates format. Use: X, Y, Z",
                    Duration = 3
                })
            end
        end
    })

    -- เพิ่มปุ่ม Minimize ใน UI ด้วย
    Tabs.Settings:AddButton({
        Title = "Minimize Window",
        Description = "Minimize the Fluent window",
        Callback = function()
            toggleWindowVisibility()
        end
    })
end

-- ทำความสะอาดเมื่อสคริปต์ถูกยกเลิก
game:GetService("UserInputService").WindowFocused:Connect(function()
    if ScreenGui then
        ScreenGui.Enabled = true
    end
end)

game:GetService("UserInputService").WindowFocusReleased:Connect(function()
    if ScreenGui then
        ScreenGui.Enabled = true
    end
end)

-- เก็บ reference เพื่อทำความสะอาด later
Fluent.MinimizeButton = MinimizeButton
Fluent.ScreenGui = ScreenGui

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
    Title = "Script Loaded",
    Content = "Fishing automation script has been loaded successfully!\n" .. #islandNames .. " islands available.\nUse the minimize button on screen!",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
