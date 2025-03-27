-- Script Protection
print("Loading script...")

if not _G.AutofarmScript then
    _G.AutofarmScript = {
        Enabled = true,
        UI = nil,
        Connections = {},
        Weapons = {},
        TeleportPoints = {},
        currentWeaponIndex = 0
    }
end

-- Default Settings
local Settings = {
    AutoAttack = true,
    Speed = 450,
    Enabled = true,
    ServerHopMinPlayers = 10,
    AutoStart = true,
    AutoWeaponSwitch = true,
    SwitchInterval = 1,
    AutoTeleport = true,
    TeleportInterval = 1,
    TeleportLocations = {
        Vector3.new(100, 375, 200),
        Vector3.new(300, 375, -15),
        Vector3.new(-25, 375, 100),
        Vector3.new(150, 375, 400),
        Vector3.new(-305, 375, 100),
        Vector3.new(150, 370, 400),
        Vector3.new(-209, 375, -300)
    }
}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

-- Wait for LocalPlayer
print("Waiting for LocalPlayer...")
local LocalPlayer
local maxWaitTime = 5
local startTime = tick()
while not LocalPlayer and (tick() - startTime) < maxWaitTime do
    LocalPlayer = Players.LocalPlayer
    task.wait(0.5)
end

if not LocalPlayer then
    warn("LocalPlayer not found after waiting " .. maxWaitTime .. " seconds, script cannot run")
    return
end
print("LocalPlayer found: " .. LocalPlayer.Name)

-- Wait for PlayerGui
print("Waiting for PlayerGui...")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
if not PlayerGui then
    warn("PlayerGui not found after waiting 10 seconds, script cannot run")
    return
end
print("PlayerGui found")

-- Weapon System (ปรับเงื่อนไขให้เข้มงวดขึ้น)
local function updateWeaponList()
    local success, result = pcall(function()
        _G.AutofarmScript.Weapons = {}
        local player = LocalPlayer
        
        local backpack = player:WaitForChild("Backpack", 5)
        if not backpack then
            warn("Backpack not found after waiting 5 seconds")
            return false
        end
        
        local character = player.Character or player.CharacterAdded:Wait()
        if not character then
            warn("Character not found after waiting")
            return false
        end
        
        print("Checking Character for potential weapons...")
        for _, item in pairs(character:GetChildren()) do
            print("Character item: " .. item.Name .. " (Class: " .. item.ClassName .. ")")
            if item:IsA("Tool") then
                table.insert(_G.AutofarmScript.Weapons, item)
                shared.SelectedWeapon = item
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid and item.Parent ~= character then
                    humanoid:EquipTool(item)
                end
                print("Found and using equipped Tool immediately: " .. item.Name)
                return true
            elseif item:IsA("Accessory") or item:IsA("Model") then
                -- ปรับเงื่อนไขให้เข้มงวดขึ้น
                local isWeapon = (item:FindFirstChild("Handle") or item.Name:lower():match("sword") or item.Name:lower():match("gun") or item.Name:lower():match("weapon"))
                    and not item.Name:lower():match("hair") -- ข้ามไอเทมที่เป็น "Hair"
                    and not item.Name:lower():match("hat") -- ข้ามไอเทมที่เป็น "Hat"
                if isWeapon then
                    table.insert(_G.AutofarmScript.Weapons, item)
                    shared.SelectedWeapon = item
                    print("Found potential weapon (Accessory/Model): " .. item.Name)
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid and item:IsA("Tool") and item.Parent ~= character then
                        humanoid:EquipTool(item)
                    end
                    return true
                else
                    print("Skipped non-weapon item: " .. item.Name)
                end
            end
        end
        
        print("Checking Backpack for potential weapons...")
        for _, item in pairs(backpack:GetChildren()) do
            print("Backpack item: " .. item.Name .. " (Class: " .. item.ClassName .. ")")
            if item:IsA("Tool") then
                table.insert(_G.AutofarmScript.Weapons, item)
                print("Found Tool in backpack: " .. item.Name)
            elseif item:IsA("Accessory") or item:IsA("Model") then
                local isWeapon = (item:FindFirstChild("Handle") or item.Name:lower():match("sword") or item.Name:lower():match("gun") or item.Name:lower():match("weapon"))
                    and not item.Name:lower():match("hair")
                    and not item.Name:lower():match("hat")
                if isWeapon then
                    table.insert(_G.AutofarmScript.Weapons, item)
                    print("Found potential weapon (Accessory/Model) in backpack: " .. item.Name)
                else
                    print("Skipped non-weapon item in backpack: " .. item.Name)
                end
            end
        end
        
        if #_G.AutofarmScript.Weapons == 0 then
            warn("No weapons (Tool, Accessory, or Model) found in Character or Backpack")
        end
        
        return #_G.AutofarmScript.Weapons > 0
    end)

    if not success then
        warn("Error in updateWeaponList: " .. tostring(result))
        return false
    end
    return result
end

local function selectNextWeapon()
    local success, result = pcall(function()
        if not updateWeaponList() or #_G.AutofarmScript.Weapons == 0 then
            warn("No weapons found in inventory")
            if _G.AutofarmScript.UIElements then
                _G.AutofarmScript.UIElements.Weapon.Text = "Weapon: None (Refresh in 5s)"
                _G.AutofarmScript.UIElements.Weapon.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
            return false
        end
        
        if shared.SelectedWeapon and shared.SelectedWeapon.Parent == LocalPlayer.Character then
            if _G.AutofarmScript.UIElements then
                _G.AutofarmScript.UIElements.Weapon.Text = "Weapon: " .. shared.SelectedWeapon.Name .. " (Equipped)"
                _G.AutofarmScript.UIElements.Weapon.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
            return true
        end
        
        _G.AutofarmScript.currentWeaponIndex = (_G.AutofarmScript.currentWeaponIndex % #_G.AutofarmScript.Weapons) + 1
        shared.SelectedWeapon = _G.AutofarmScript.Weapons[_G.AutofarmScript.currentWeaponIndex]
        
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and shared.SelectedWeapon:IsA("Tool") then
                humanoid:UnequipTools()
                humanoid:EquipTool(shared.SelectedWeapon)
            end
        end
        
        if _G.AutofarmScript.UIElements then
            _G.AutofarmScript.UIElements.Weapon.Text = "Weapon: " .. shared.SelectedWeapon.Name 
                .. " (" .. _G.AutofarmScript.currentWeaponIndex .. "/" .. #_G.AutofarmScript.Weapons .. ")"
            _G.AutofarmScript.UIElements.Weapon.TextColor3 = Color3.fromRGB(255, 255, 0)
            task.wait(0.5)
            _G.AutofarmScript.UIElements.Weapon.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        print("Selected weapon: " .. shared.SelectedWeapon.Name)
        return true
    end)

    if not success then
        warn("Error in selectNextWeapon: " .. tostring(result))
        return false
    end
    return result
end

-- Auto Weapon Switch (เพิ่มฟังก์ชันที่ขาดหายไป)
local function autoWeaponSwitch()
    local success, result = pcall(function()
        print("Starting auto weapon switch...")
        while Settings.AutoWeaponSwitch and task.wait(Settings.SwitchInterval) do
            selectNextWeapon()
            if _G.AutofarmScript.UIElements then
                _G.AutofarmScript.UIElements.NextSwitch.Text = "Next Switch: " .. Settings.SwitchInterval .. "s"
            end
        end
    end)

    if not success then
        warn("Error in autoWeaponSwitch: " .. tostring(result))
    end
end

-- Teleport System
local function randomTeleport()
    local success, result = pcall(function()
        if not Settings.AutoTeleport or not LocalPlayer.Character then
            warn("Cannot teleport: AutoTeleport is disabled or character not found")
            return
        end
        
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and #Settings.TeleportLocations > 0 then
            local randomPoint = Settings.TeleportLocations[math.random(1, #Settings.TeleportLocations)]
            hrp.CFrame = CFrame.new(randomPoint)
            if _G.AutofarmScript.UIElements then
                _G.AutofarmScript.UIElements.Teleport.Text = "Teleport: Active (" .. math.floor(randomPoint.X) .. "," .. math.floor(randomPoint.Z) .. ")"
                _G.AutofarmScript.UIElements.Teleport.TextColor3 = Color3.fromRGB(0, 255, 255)
                task.wait(1)
                _G.AutofarmScript.UIElements.Teleport.TextColor3 = Color3.fromRGB(200, 200, 255)
            end
        end
    end)

    if not success then
        warn("Error in randomTeleport: " .. tostring(result))
    end
end

-- Auto Teleport System (เพิ่มฟังก์ชันที่ขาดหายไป)
local function autoTeleportSystem()
    local success, result = pcall(function()
        print("Starting auto teleport system...")
        while Settings.AutoTeleport and task.wait(Settings.TeleportInterval) do
            randomTeleport()
            if _G.AutofarmScript.UIElements then
                _G.AutofarmScript.UIElements.NextTeleport.Text = "Next Teleport: " .. Settings.TeleportInterval .. "s"
            end
        end
    end)

    if not success then
        warn("Error in autoTeleportSystem: " .. tostring(result))
    end
end

-- Attack System
local function attackEnemies()
    local success, result = pcall(function()
        local remoteEvent = ReplicatedStorage:WaitForChild("ACS_Engine"):WaitForChild("Events"):WaitForChild("Damage")
        
        while Settings.AutoAttack and task.wait(0.1) do
            if not shared.SelectedWeapon then
                selectNextWeapon()
                task.wait(0.5)
                continue
            end
            
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then
                task.wait(0.5)
                continue
            end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if shared.SelectedWeapon:IsA("Tool") and shared.SelectedWeapon.Parent ~= character then
                humanoid:EquipTool(shared.SelectedWeapon)
            end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
                    local target = player.Character
                    if target and target:FindFirstChild("HumanoidRootPart") then
                        local head = target:FindFirstChild("Head")
                        local targetHumanoid = target:FindFirstChild("Humanoid")
                        
                        if head and targetHumanoid and targetHumanoid.Health > 0 then
                            pcall(function()
                                local weaponName = shared.SelectedWeapon.Name
                                if not shared.SelectedWeapon:IsA("Tool") then
                                    weaponName = "CustomWeapon_" .. weaponName
                                end
                                remoteEvent:InvokeServer({
                                    shellMaxDist = 0,
                                    origin = character:GetPivot().Position,
                                    weaponName = weaponName,
                                    bulletID = "Bullet_" .. math.random(10000000, 99999999),
                                    currentPenetrationCount = 200,
                                    shellSpeed = 0,
                                    localShellName = "Invisible",
                                    maxPenetrationCount = 1e99,
                                    registeredParts = {[head] = true},
                                    shellType = "Bullet",
                                    penetrationMultiplier = 1e99,
                                    filterDescendants = {workspace:FindFirstChild(player.Name)}
                                }, targetHumanoid, 10000, 1, head)
                            end)
                        end
                    end
                end
            end
        end
    end)

    if not success then
        warn("Error in attackEnemies: " .. tostring(result))
    end
end

-- UI System
local function createUI()
    local success, result = pcall(function()
        print("Creating UI...")
        if _G.AutofarmScript.UI then
            _G.AutofarmScript.UI:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AutoFarmUI"
        screenGui.Parent = PlayerGui
        screenGui.ResetOnSpawn = false
        _G.AutofarmScript.UI = screenGui

        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 205, 0, 260)
        mainFrame.Position = UDim2.new(0.2, -140, 0, 10)
        mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        mainFrame.BorderSizePixel = 0
        mainFrame.Active = true
        mainFrame.Parent = screenGui

        Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Text = "Maru Hub Private"
        title.TextColor3 = Color3.fromRGB(255, 255, 0)
        title.Size = UDim2.new(1, 0, 0, 25)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.TextSize = 16
        title.TextXAlignment = Enum.TextXAlignment.Center
        title.Parent = mainFrame

        local divider = Instance.new("Frame")
        divider.Size = UDim2.new(0.9, 0, 0, 1)
        divider.Position = UDim2.new(0.05, 0, 0, 25)
        divider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        divider.BorderSizePixel = 0
        divider.Parent = mainFrame

        local statusLabels = {
            AutoAttack = {Text = "Auto Attack: ON", YPos = 30, Color = Color3.fromRGB(0, 255, 0)},
            SpeedHack = {Text = "Speed Hack: ON (" .. Settings.Speed .. ")", YPos = 55, Color = Color3.fromRGB(0, 255, 0)},
            Weapon = {Text = "Weapon: Randomizing...", YPos = 80, Color = Color3.fromRGB(255, 255, 0)},
            AutoStart = {Text = "Auto Start: ON", YPos = 105, Color = Color3.fromRGB(0, 255, 0)},
            ServerHop = {Text = "Server Hop: Active", YPos = 130, Color = Color3.fromRGB(0, 255, 255)},
            Teleport = {Text = "Teleport: Ready", YPos = 155, Color = Color3.fromRGB(200, 200, 255)},
            Status = {Text = "Status: Alive", YPos = 180, Color = Color3.fromRGB(0, 255, 0)},
            NextSwitch = {Text = "Next Switch: " .. Settings.SwitchInterval .. "s", YPos = 205, Color = Color3.fromRGB(200, 200, 200)},
            NextTeleport = {Text = "Next Teleport: " .. Settings.TeleportInterval .. "s", YPos = 230, Color = Color3.fromRGB(200, 200, 200)}
        }

        _G.AutofarmScript.UIElements = {}
        for name, data in pairs(statusLabels) do
            local label = Instance.new("TextLabel")
            label.Name = name
            label.Text = data.Text
            label.TextColor3 = data.Color
            label.Position = UDim2.new(0, 10, 0, data.YPos)
            label.Size = UDim2.new(1, -20, 0, 25)
            label.BackgroundTransparency = 1
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.Parent = mainFrame
            _G.AutofarmScript.UIElements[name] = label
        end

        local dragging, dragStart, startPos
        mainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)

        mainFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                if not input.Position or not dragStart then return end
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        print("UI created successfully")
    end)

    if not success then
        warn("Error in createUI: " .. tostring(result))
    end
end

-- Deploy System
local function attemptDeploy()
    local success = false
    local maxAttempts = 1e99
    local delayBetweenAttempts = 1
    local baseX = 700
    local baseY = 650
    local randomRange = 10

    print("Waiting for UI to load before attempting deploy...")
    task.wait(10)

    print("Checking for DEPLOY button in UI...")
    local deployButton = nil
    for attempt = 1, 3 do
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, frame in pairs(gui:GetDescendants()) do
                    if frame:IsA("TextButton") and frame.Text:upper() == "DEPLOY" and frame.Visible then
                        deployButton = frame
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                        print("Found DEPLOY button at attempt " .. attempt)
                        break
                    end
                end
            end
            if deployButton then break end
        end
        if deployButton then break end
        warn("DEPLOY button not found on attempt " .. attempt .. ", retrying in 2 seconds...")
        task.wait(1)
    end

    if deployButton then
        local buttonPos = deployButton.AbsolutePosition + deployButton.AbsoluteSize / 2
        for attempt = 1, maxAttempts do
            local s, e = pcall(function()
                print("Attempting to click DEPLOY button at position: (" .. buttonPos.X .. ", " .. buttonPos.Y .. ")")
                VirtualInputManager:SendMouseButtonEvent(buttonPos.X, buttonPos.Y, 0, true, game, 1)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.2)
                VirtualInputManager:SendMouseButtonEvent(buttonPos.X, buttonPos.Y, 0, false, game, 1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                success = true
            end)

            if success then
                print("Successfully clicked DEPLOY button on attempt " .. attempt)
                task.wait(1)
                if deployButton.Parent and deployButton.Visible then
                    warn("DEPLOY button still visible after click, deploy might have failed")
                    success = false
                else
                    success = true
                    break
                end
            else
                warn("Click attempt " .. attempt .. " failed: " .. tostring(e))
            end

            if attempt < maxAttempts then
                task.wait(delayBetweenAttempts)
            end
        end
    else
        warn("DEPLOY button not found in UI, falling back to random click around (" .. baseX .. ", " .. baseY .. ")...")
        for attempt = 1, maxAttempts do
            local clickX = baseX + math.random(-randomRange, randomRange)
            local clickY = baseY + math.random(-randomRange, randomRange)
            
            local s, e = pcall(function()
                print("Attempting to click at random position: (" .. clickX .. ", " .. clickY .. ")")
                VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.2)
                VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                success = true
            end)

            if success then
                print("Successfully clicked at random position on attempt " .. attempt)
                task.wait(1)
                local deployButtonCheck = nil
                for _, gui in pairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        for _, frame in pairs(gui:GetDescendants()) do
                            if frame:IsA("TextButton") and frame.Text:upper() == "DEPLOY" and frame.Visible then
                                deployButtonCheck = frame
                                break
                            end
                        end
                    end
                    if deployButtonCheck then break end
                end

                if deployButtonCheck then
                    warn("DEPLOY button still visible after click, deploy might have failed")
                    success = false
                else
                    success = true
                    break
                end
            else
                warn("Click attempt " .. attempt .. " failed: " .. tostring(e))
            end

            if attempt < maxAttempts then
                task.wait(delayBetweenAttempts)
            end
        end
    end

    if _G.AutofarmScript.UIElements then
        _G.AutofarmScript.UIElements.Status.Text = success and "Status: Deployed" or "Status: Deploy Failed"
        _G.AutofarmScript.UIElements.Status.TextColor3 = success and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 165, 0)
    end

    return success
end

-- Deploy and Respawn System
local function setupAutoRespawn()
    local success, result = pcall(function()
        print("Setting up auto respawn...")
        for _, conn in pairs(_G.AutofarmScript.Connections) do
            conn:Disconnect()
        end
        
        _G.AutofarmScript.Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
            print("Character added, waiting for humanoid...")
            local humanoid = character:WaitForChild("Humanoid", 5)
            local hrp = character:WaitForChild("HumanoidRootPart", 5)
            
            if not humanoid or not hrp then
                warn("Character not fully loaded, skipping deploy")
                return
            end

            createUI()
            if _G.AutofarmScript.UIElements then
                _G.AutofarmScript.UIElements.Status.Text = "Status: Alive"
                _G.AutofarmScript.UIElements.Status.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
            
            if Settings.AutoStart then
                task.wait(2)
                local deployed = attemptDeploy()
                if not deployed and _G.AutofarmScript.UIElements then
                    _G.AutofarmScript.UIElements.Status.Text = "Status: Deploy Failed"
                    _G.AutofarmScript.UIElements.Status.TextColor3 = Color3.fromRGB(255, 165, 0)
                end
            end
            
            if Settings.AutoWeaponSwitch then
                selectNextWeapon()
            end
            
            if Settings.Enabled and humanoid then
                humanoid.WalkSpeed = Settings.Speed
            end
        end)
        
        _G.AutofarmScript.Connections.CharacterRemoving = LocalPlayer.CharacterRemoving:Connect(function()
            if _G.AutofarmScript.UIElements then
                _G.AutofarmScript.UIElements.Status.Text = "Status: Dead"
                _G.AutofarmScript.UIElements.Status.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        end)
        print("Auto respawn setup complete")
    end)

    if not success then
        warn("Error in setupAutoRespawn: " .. tostring(result))
    end
end

-- Utility Systems
local function setupWalkSpeed()
    local success, result = pcall(function()
        print("Setting up walk speed...")
        if not getgenv().speedHooked then
            getgenv().speedHooked = true
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            local oldindex = mt.__index
            mt.__index = newcclosure(function(self, key)
                if key == "WalkSpeed" then 
                    return Settings.Enabled and Settings.Speed or oldindex(self, key) 
                end
                return oldindex(self, key)
            end)
            setreadonly(mt, true)
        end
        print("Walk speed setup complete")
    end)

    if not success then
        warn("Error in setupWalkSpeed: " .. tostring(result))
    end
end

local function hopToPopulatedServer()
    local success, result = pcall(function()
        print("Hopping to populated server...")
        local data = HttpService:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
        local servers = {}
        
        for _, server in pairs(data.data or {}) do
            if server.playing and server.playing >= Settings.ServerHopMinPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
        
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
            return true
        end
        return false
    end)

    if not success then
        warn("Error in hopToPopulatedServer: " .. tostring(result))
        return false
    end
    return result
end

local function checkPlayerCount()
    local success, result = pcall(function()
        print("Starting player count check...")
        while task.wait(30) do
            if #Players:GetPlayers() < Settings.ServerHopMinPlayers then
                hopToPopulatedServer()
            end
        end
    end)

    if not success then
        warn("Error in checkPlayerCount: " .. tostring(result))
    end
end

local function setupAntiAFK()
    local success, result = pcall(function()
        print("Setting up anti-AFK...")
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        print("Anti-AFK setup complete")
    end)

    if not success then
        warn("Error in setupAntiAFK: " .. tostring(result))
    end
end

local function autoRefreshWeapons()
    while task.wait(10) do
        updateWeaponList()
        if #_G.AutofarmScript.Weapons > 0 and _G.AutofarmScript.UIElements then
            _G.AutofarmScript.UIElements.Weapon.Text = "Weapons: " .. #_G.AutofarmScript.Weapons .. " found"
        end
    end
end

-- Initialization
local function initialize()
    local success, result = pcall(function()
        print("Initializing script...")
        
        setupWalkSpeed()
        createUI()
        setupAutoRespawn()
        setupAntiAFK()
        selectNextWeapon()
        
        task.spawn(attackEnemies)
        task.spawn(autoWeaponSwitch)
        task.spawn(autoTeleportSystem)
        task.spawn(checkPlayerCount)
        task.spawn(autoRefreshWeapons)
        
        if Settings.AutoStart then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            print("Attempting initial deploy...")
            task.wait(3)
            local deployed = attemptDeploy()
            if not deployed and _G.AutofarmScript.UIElements then
                warn("Initial deploy failed")
                _G.AutofarmScript.UIElements.Status.Text = "Status: Deploy Failed"
                _G.AutofarmScript.UIElements.Status.TextColor3 = Color3.fromRGB(255, 165, 0)
            else
                print("Initial deploy successful")
            end
        end
        print("Initialization complete")
    end)

    if not success then
        warn("Error in initialize: " .. tostring(result))
    end
end

-- Start
if _G.AutofarmScript.Enabled then
    print("Starting script...")
    pcall(initialize)
else
    warn("Script is disabled, not starting")
end

print("Script loaded successfully")
