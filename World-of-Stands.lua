local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

local function collectBottle(crateNumber)
    local cratePath = Workspace:FindFirstChild(tostring(crateNumber))
    if cratePath then
        local targetPart = cratePath:FindFirstChildWhichIsA("BasePart")
        
        if targetPart then
            local bottlePosition = targetPart.Position
            HumanoidRootPart.CFrame = CFrame.new(bottlePosition + Vector3.new(0, 5, 0))

            wait(0.5)

            VirtualInputManager:SendKeyEvent(true, "E", false, game)
            wait(1.5)
            VirtualInputManager:SendKeyEvent(false, "E", false, game)

            print("Collected at crate " .. crateNumber)
        else
            print("No valid BasePart found in crate " .. crateNumber)
        end
    else
        print("Crate " .. crateNumber .. " not found!")
    end
end

for round = 1, 10 do
    for i = 1, 100 do
        collectBottle(i)
        wait(0.1)
    end
    print("Completed round " .. round .. " of 3")
    if round < 10 then
        wait(1)
    end
end

TeleportService:Teleport(game.PlaceId, LocalPlayer)
