-- Script Protection
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
    SwitchInterval = 2,
    AutoTeleport = true,
    TeleportInterval = 15,
    TeleportLocations = {
        Vector3.new(10, 35, 20),
        Vector3.new(30, 35, -15),
        Vector3.new(-25, 35, 10),
        Vector3.new(15, 35, 40),
        Vector3.new(-10, 35, -30)
    }
}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

-- Wait for LocalPlayer to be available
print("Waiting for LocalPlayer...")
local LocalPlayer
local maxWaitTime = 10
local startTime = tick()
while not LocalPlayer and (tick() - startTime) < maxWaitTime do
    LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        task.wait(0.5)
    end
end

if not LocalPlayer then
    warn("LocalPlayer not found after waiting " .. maxWaitTime .. " seconds, script cannot run")
    return
end
print("LocalPlayer found: " .. LocalPlayer.Name)

-- Wait for PlayerGui to be available
print("Waiting for PlayerGui...")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then
    warn("PlayerGui not found after waiting 10 seconds, script cannot run")
    return
end
print("PlayerGui found")

-- Weapon System
local function updateWeaponList()
    local success, result = pcall(function()
        _G.AutofarmScript.Weapons = {}
        local player = LocalPlayer
        local backpack = player:FindFirstChild("Backpack")
        local character = player.Character
        
        if backpack then
            for _, item in pairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(_G.AutofarmScript.Weapons, item.Name)
                end
            end
        end
        
        if character then
            for _, item in pairs(character:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(_G.AutofarmScript.Weapons, item.Name)
                end
            end
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
                _G.AutofarmScript.UIElements.Weapon.Text = "Weapon: None"
                _G.AutofarmScript.UIElements.Weapon.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
            return false
        end
        
        _G.AutofarmScript.currentWeaponIndex = _G.AutofarmScript.currentWeaponIndex + 1
        if _G.AutofarmScript.currentWeaponIndex > #_G.AutofarmScript.Weapons then
            _G.AutofarmScript.currentWeaponIndex = 1
        end
        
        shared.SelectedWeapon = _G.AutofarmScript.Weapons[_G.AutofarmScript.currentWeaponIndex]
        if _G.AutofarmScript.UIElements then
            _G.AutofarmScript.UIElements.Weapon.Text = "Weapon: " .. shared.SelectedWeapon
            _G.AutofarmScript.UIElements.Weapon.TextColor3 = Color3.fromRGB(255, 255, 0)
            task.wait(0.5)
            _G.AutofarmScript.UIElements.Weapon.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        print("Selected weapon: " .. shared.SelectedWeapon .. " (Index: " .. _G.AutofarmScript.currentWeaponIndex .. ")")
        return true
    end)

    if not success then
        warn("Error in selectNextWeapon: " .. tostring(result))
        return false
    end
    return result
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
        else
            warn("Cannot teleport: HumanoidRootPart not found or no teleport locations")
        end
    end)

    if not success then
        warn("Error in randomTeleport: " .. tostring(result))
    end
end

-- Attack System
local function attackEnemies()
    local success, result = pcall(function()
        local localPlayer = LocalPlayer
        local remoteEvent = ReplicatedStorage:FindFirstChild("ACS_Engine") and 
                           ReplicatedStorage.ACS_Engine:FindFirstChild("Events") and 
                           ReplicatedStorage.ACS_Engine.Events:FindFirstChild("Damage")
        
        if not remoteEvent then 
            warn("Damage remote event not found")
            return 
        end

        while Settings.AutoAttack and task.wait() do
            if not shared.SelectedWeapon and not selectNextWeapon() then
                task.wait(1)
                continue
            end

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Team ~= localPlayer.Team then
                    local target = player.Character
                    if target and target:FindFirstChild("HumanoidRootPart") then
                        local head = target:FindFirstChild("Head")
                        local humanoid = target:FindFirstChild("Humanoid")

                        if head and humanoid and humanoid.Health > 0 then
                            pcall(function()
                                remoteEvent:InvokeServer({
                                    shellMaxDist = 0,
                                    origin = localPlayer.Character and localPlayer.Character:GetPivot().Position or Vector3.zero,
                                    weaponName = shared.SelectedWeapon,
                                    bulletID = "Bullet_" .. math.random(100000, 999999),
                                    currentPenetrationCount = 5,
                                    shellSpeed = 0,
                                    localShellName = "Invisible",
                                    maxPenetrationCount = 1e99,
                                    registeredParts = {[head] = true},
                                    shellType = "Bullet",
                                    penetrationMultiplier = 1e99,
                                    filterDescendants = {workspace:FindFirstChild(player.Name)}
                                }, humanoid, 10, 1, head)
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

-- UI System with Draggable Functionality
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
        mainFrame.Size = UDim2.new(0, 280, 0, 250)
        mainFrame.Position = UDim2.new(0.5, -140, 0, 10)
        mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui

        Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Text = LocalPlayer.Name .. " - Maru Hub Private"
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

        -- Make the UI draggable
        print("Setting up draggable UI...")
        local dragging = false
        local dragStart = nil
        local startPos = nil

        mainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
                print("Started dragging UI at position: " .. tostring(dragStart))
            end
        end)

        mainFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                print("Stopped dragging UI at position: " .. tostring(mainFrame.Position))
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                if not input.Position then
                    warn("Input.Position is nil during drag")
                    return
                end
                if not dragStart then
                    warn("dragStart is nil during drag")
                    return
                end
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        print("UI created successfully")
    end)

    if not success then
        warn("Error in createUI: " .. tostring(result))
    end
end

-- Auto Systems
local function autoTeleportSystem()
    local success, result = pcall(function()
        print("Starting autoTeleportSystem...")
        while Settings.AutoTeleport and task.wait(1) do
            local timer = Settings.TeleportInterval
            while timer > 0 and Settings.AutoTeleport do
                if _G.AutofarmScript.UIElements then
                    _G.AutofarmScript.UIElements.NextTeleport.Text = "Next Teleport: " .. timer .. "s"
                end
                task.wait(1)
                timer -= 1
            end
            if Settings.AutoTeleport then
                randomTeleport()
            end
        end
    end)

    if not success then
        warn("Error in autoTeleportSystem: " .. tostring(result))
    end
end

local function autoWeaponSwitch()
    local success, result = pcall(function()
        print("Starting autoWeaponSwitch...")
        while Settings.AutoWeaponSwitch and task.wait(1) do
            local timer = Settings.SwitchInterval
            while timer > 0 and Settings.AutoWeaponSwitch do
                if _G.AutofarmScript.UIElements then
                    _G.AutofarmScript.UIElements.NextSwitch.Text = "Next Switch: " .. timer .. "s"
                end
                task.wait(1)
                timer -= 1
            end
            if Settings.AutoWeaponSwitch then
                selectNextWeapon()
            end
        end
    end)

    if not success then
        warn("Error in autoWeaponSwitch: " .. tostring(result))
    end
end

-- Deploy System (Manual for now)
local function attemptDeploy()
    -- Temporarily removed VirtualInputManager to isolate the issue
    warn("Please manually click the DEPLOY button to continue. Auto-deploy is disabled for debugging.")
    return true -- Assume deploy is successful for now
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
                task.wait(5) -- Increased delay to ensure game state and UI are ready
                local deployed = attemptDeploy()
                if not deployed and _G.AutofarmScript.UIElements then
                    _G.AutofarmScript.UIElements.Status.Text = "Status: Deploy Failed"
                    _G.AutofarmScript.UIElements.Status.TextColor3 = Color3.fromRGB(255, 165, 0) -- Orange to indicate warning
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
            if server.playing and server.playing >= Settings.ServerHopMinPlayers and server.id != game.JobId then
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

-- Initialization
local function initialize()
    local success, result = pcall(function()
        print("Initializing script...")
        
        print("Step 1: Setting up walk speed...")
        setupWalkSpeed()
        
        print("Step 2: Creating UI...")
        createUI()
        
        print("Step 3: Setting up auto respawn...")
        setupAutoRespawn()
        
        print("Step 4: Setting up anti-AFK...")
        setupAntiAFK()
        
        print("Step 5: Selecting initial weapon...")
        selectNextWeapon()
        
        print("Step 6: Starting attack system...")
        task.spawn(attackEnemies)
        
        print("Step 7: Starting weapon switch system...")
        task.spawn(autoWeaponSwitch)
        
        print("Step 8: Starting teleport system...")
        task.spawn(autoTeleportSystem)
        
        print("Step 9: Starting player count check...")
        task.spawn(checkPlayerCount)
        
        if Settings.AutoStart then
            print("Step 10: Attempting initial deploy...")
            task.wait(3) -- Slight delay for initial deploy
            local deployed = attemptDeploy()
            if not deployed and _G.AutofarmScript.UIElements then
                warn("Initial deploy failed")
                _G.AutofarmScript.UIElements.Status.Text = "Status: Deploy Failed"
                _G.AutofarmScript.UIElements.Status.TextColor3 = Color3.fromRGB(255, 165, 0)
            else
                print("Initial deploy successful (manual deploy)")
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
