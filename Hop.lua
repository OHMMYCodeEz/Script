local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Define the target PlaceId and a list of InstanceIds (add as many as you want)
local targetPlaceId = game.PlaceId -- Current place
local targetInstanceIds = {
    "a81a47e8-3a42-4b5b-ae30-0db04d7b5760",  -- Server 1
    "24a0aa1c-ee10-4077-839f-763048ce2541",                  -- Server 2 (replace with actual ID)
    "9231665b-145c-40f6-9129-54788db0e760",
    "3eed1a38-23f3-4b68-99aa-cd102fae8a80",
    "8f47fd82-0dac-41f3-8fff-45e722fac902"                   -- Server 3 (replace with actual ID)
    -- Add more InstanceIds here if needed
}

-- Index to track which server to try next
local currentTryIndex = 1

-- Function to check if player is in any target server
local function isInTargetServer(currentInstanceId)
    for _, id in ipairs(targetInstanceIds) do
        if currentInstanceId == id then
            return true
        end
    end
    return false
end

-- Function to attempt teleport to the next available server
local function tryTeleportToNextServer()
    if currentTryIndex > #targetInstanceIds then
        warn("All target servers are unavailable or full. No more retries.")
        return
    end

    local targetId = targetInstanceIds[currentTryIndex]
    print("Attempting to join server: " .. targetId)
    TeleportService:TeleportToPlaceInstance(targetPlaceId, targetId, LocalPlayer)
end

-- Function to check and rejoin if necessary
local function checkAndRejoinServer()
    -- Get the current server's JobId (InstanceId)
    local currentInstanceId = game.JobId

    -- If already in one of the target servers, do nothing
    if isInTargetServer(currentInstanceId) then
        print("Already in a target server!")
        return
    end

    -- Otherwise, start trying to teleport to the target servers
    print("Not in a target server. Starting teleport attempts...")
    tryTeleportToNextServer()
end

-- Run the check when the player joins the game
checkAndRejoinServer()

-- Handle teleport errors and retry with next server
TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
    warn("Teleport to server " .. targetInstanceIds[currentTryIndex] .. " failed: " .. errorMessage)
    
    -- Move to the next server in the list
    currentTryIndex = currentTryIndex + 1
    
    -- Retry with the next server after a short delay
    wait(2)  -- Adjust delay as needed to avoid rate limits
    tryTeleportToNextServer()
end)
