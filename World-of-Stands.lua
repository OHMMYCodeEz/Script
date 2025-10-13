local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local Camera = game:GetService("Workspace").CurrentCamera

local baseGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("BaseGui")
if baseGui and baseGui:FindFirstChild("StartScreen") then
    local playButton = baseGui.StartScreen:FindFirstChild("PlayButton")
    if playButton then
        game:GetService("GuiService").SelectedObject = playButton
        task.wait()
        if game:GetService("GuiService").SelectedObject == playButton then
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            task.wait()
            game:GetService("GuiService").SelectedObject = nil
        end
    end
end

local function collectBottle(crateNumber)
    local cratePath = Workspace:FindFirstChild(tostring(crateNumber))
    if cratePath then
        local targetPart = cratePath:FindFirstChildWhichIsA("BasePart")
        
        if targetPart then
            local bottlePosition = targetPart.Position
            HumanoidRootPart.CFrame = CFrame.new(bottlePosition + Vector3.new(0, 5, 0))

            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = CFrame.new(bottlePosition + Vector3.new(0, 5, -10))

            wait(0.5)

            VirtualInputManager:SendKeyEvent(true, "E", false, game)
            wait(1.5)
            VirtualInputManager:SendKeyEvent(false, "E", false, game)

            print("Collected at crate " .. crateNumber)
        else
            print("No valid BasePart found in crate " .. crateNumber)
        end
    end
end

for round = 1, 3 do
    for i = 1, 100 do
        collectBottle(i)
        wait(0.1)
    end
    print("Completed round " .. round .. " of 3")
    if round < 3 then
        wait(1)
    end
end

TeleportService:Teleport(game.PlaceId, LocalPlayer)
