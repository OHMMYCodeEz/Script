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
    SwitchInterval = 1,
    AutoTeleport = true,
    TeleportInterval = 5,
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
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Ensure LocalPlayer is available
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("LocalPlayer not found, script cannot run")
    return
end

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
                                    shellMaxDist = 1000,
                                    origin = localPlayer.Character and localPlayer.Character:GetPivot().Position or Vector3.zero,
                                    weaponName = shared.SelectedWeapon,
                                    bulletID = "Bullet_" .. math.random(100000, 999999),
                                    currentPenetrationCount = 5,
                                    shellSpeed = 100,
                                    localShellName = "Invisible",
                                    maxPenetrationCount = 1e99,
                                    registeredParts = {[head] = true},
                                    shellType = "Bullet",
                                    penetrationMultiplier = 1e99,
                                    filterDescendants = {workspace:FindFirstChild(player.Name)}
                                }, humanoid, 1000000, 1, head)
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
        if _G.AutofarmScript.UI then
            _G.AutofarmScript.UI:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AutoFarmUI"
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
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
    end)

    if not success then
        warn("Error in createUI: " .. tostring(result))
    end
end

-- Auto Systems
local function autoTeleportSystem()
    local success, result = pcall(function()
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

-- Deploy System Using Virtual Input with Fixed Coordinates
local function attemptDeploy()
    local success = false
    local maxAttempts = 5
    local delayBetweenAttempts = 3 -- Delay between attempts

    -- Fixed coordinates for the DEPLOY button
    local clickX = 471.50885009765625
    local clickY = 412.12939453125

    -- Attempt to click at the specified coordinates multiple times
    for attempt = 1, maxAttempts do
        local s, e = pcall(function()
            -- Simulate a mouse click at the fixed coordinates
            print("Attempting to click at position: (" .. clickX .. ", " .. clickY .. ")")
            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0) -- Mouse down
            task.wait(0.2) -- Delay to ensure the click is registered
            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0) -- Mouse up
            success = true
        end)

        if success then
            print("Successfully clicked at position on attempt " .. attempt)
            -- Wait a bit to see if the deploy UI disappears (indicating a successful deploy)
            task.wait(1)
            -- Check if the DEPLOY button is still visible (as a fallback)
            local deployButton
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                for _, gui in pairs(playerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        for _, frame in pairs(gui:GetDescendants()) do
                            if frame:IsA("TextButton") and frame.Text:upper() == "DEPLOY" then
                                deployButton = frame
                                break
                            end
                        end
                    end
                    if deployButton then break end
                end
            end

            if deployButton and deployButton.Parent and deployButton.Visible then
                warn("DEPLOY button is still visible after clicking, deploy might have failed")
                success = false
            else
                success = true
                break
            end
        else
            warn("Deploy attempt " .. attempt .. " failed: " .. tostring(e))
        end

        if attempt < maxAttempts then
            task.wait(delayBetweenAttempts)
        end
    end

    if not success then
        warn("Failed to deploy after " .. maxAttempts .. " attempts")
    end

    return success
end

-- Deploy and Respawn System
local function setupAutoRespawn()
    local success, result = pcall(function()
        for _, conn in pairs(_G.AutofarmScript.Connections) do
            conn:Disconnect()
        end
        
        _G.AutofarmScript.Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
            -- Ensure character is fully loaded
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
    end)

    if not success then
        warn("Error in setupAutoRespawn: " .. tostring(result))
    end
end

-- Utility Systems
local function setupWalkSpeed()
    local success, result = pcall(function()
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
    end)

    if not success then
        warn("Error in setupWalkSpeed: " .. tostring(result))
    end
end

local function hopToPopulatedServer()
    local success, result = pcall(function()
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
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)

    if not success then
        warn("Error in setupAntiAFK: " .. tostring(result))
    end
end

-- Initialization
local function initialize()
    local success, result = pcall(function()
        setupWalkSpeed()
        createUI()
        setupAutoRespawn()
        setupAntiAFK()
        
        selectNextWeapon()
        
        task.spawn(attackEnemies)
        task.spawn(autoWeaponSwitch)
        task.spawn(autoTeleportSystem)
        task.spawn(checkPlayerCount)
        
        if Settings.AutoStart then
            task.wait(3) -- Slight delay for initial deploy
            local deployed = attemptDeploy()
            if not deployed and _G.AutofarmScript.UIElements then
                warn("Initial deploy failed")
                _G.AutofarmScript.UIElements.Status.Text = "Status: Deploy Failed"
                _G.AutofarmScript.UIElements.Status.TextColor3 = Color3.fromRGB(255, 165, 0)
            end
        end
    end)

    if not success then
        warn("Error in initialize: " .. tostring(result))
    end
end

-- Start
if _G.AutofarmScript.Enabled then
    pcall(initialize)
end
