repeat task.wait(15) until game:IsLoaded() and game.Players.LocalPlayer.Character

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

local PlayersTable = {}
local SentRequests = {}
local Processing = false
local RequestCooldown = 15
local RetryAttempts = 10

local function addPlayer(player)
    if player ~= Players.LocalPlayer and not SentRequests[player.Name] then
        table.insert(PlayersTable, player.Name)
        return true
    end
    return false
end

local function confirmFriendRequest()
    if CoreGui:FindFirstChild("RobloxGui") and CoreGui.RobloxGui:FindFirstChild("PromptDialog") then
        if CoreGui.RobloxGui.PromptDialog.ContainerFrame:FindFirstChild("ConfirmButton") then
            GuiService.SelectedObject = CoreGui.RobloxGui.PromptDialog.ContainerFrame:FindFirstChild("ConfirmButton")
            task.wait(0.1)
            if GuiService.SelectedObject == CoreGui.RobloxGui.PromptDialog.ContainerFrame:FindFirstChild("ConfirmButton") then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                task.wait(0.1)
                GuiService.SelectedObject = nil
                return true
            end
        end
    end
    return false
end

local function sendFriendRequest(playerName, attempt)
    attempt = attempt or 1
    
    local player = Players:FindFirstChild(playerName)
    if not player then
        return false
    end
    
    if SentRequests[player.Name] then
        return true
    end
    
    local success, err = pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Friend Request Prompt",
            Text = player.Name,
            Duration = 5
        })
        
        game.StarterGui:SetCore("PromptSendFriendRequest", player)
        task.wait(1)
        
        if confirmFriendRequest() then
            SentRequests[player.Name] = true
            return true
        else
            return false
        end
    end)
    
    if not success then
        return false
    end
    
    return SentRequests[player.Name] or false
end

Players.PlayerAdded:Connect(function(player)
    addPlayer(player)
end)

for _, player in pairs(Players:GetPlayers()) do
    addPlayer(player)
end

local function processQueue()
    while true do
        if not Processing and #PlayersTable > 0 then
            Processing = true
            
            for i = #PlayersTable, 1, -1 do
                local playerName = PlayersTable[i]
                
                local success = false
                for attempt = 1, RetryAttempts do
                    success = sendFriendRequest(playerName, attempt)
                    if success then
                        break
                    else
                        task.wait(1)
                    end
                end
                
                if success then
                    table.remove(PlayersTable, i)
                end
                
                task.wait(RequestCooldown)
            end
            
            Processing = false
        end
        
        task.wait(5)
    end
end

local function checkForMissingPlayers()
    while true do
        task.wait(30)
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and not SentRequests[player.Name] then
                local alreadyInQueue = false
                for _, name in ipairs(PlayersTable) do
                    if name == player.Name then
                        alreadyInQueue = true
                        break
                    end
                end
                
                if not alreadyInQueue then
                    addPlayer(player)
                end
            end
        end
    end
end

spawn(processQueue)
spawn(checkForMissingPlayers)
