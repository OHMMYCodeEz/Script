local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local Camera = game:GetService("Workspace").CurrentCamera

wait(10)
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

--Server Hop Script cr.Magma Hub Src
          local PlaceID = game.PlaceId
          local AllIDs = {}
          local foundAnything = ""
          local actualHour = os.date("!*t").hour
          local Deleted = false
          --[[
          local File = pcall(function()
              AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
          end)
          if not File then
              table.insert(AllIDs, actualHour)
              writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
          end
          ]]
          function TPReturner()
              local Site;
              if foundAnything == "" then
                  Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
              else
                  Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
              end
              local ID = ""
              if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
                  foundAnything = Site.nextPageCursor
              end
              local num = 0;
              for i,v in pairs(Site.data) do
                  local Possible = true
                  ID = tostring(v.id)
                  if tonumber(v.maxPlayers) > tonumber(v.playing) then
                      for _,Existing in pairs(AllIDs) do
                          if num ~= 0 then
                              if ID == tostring(Existing) then
                                  Possible = false
                              end
                          else
                              if tonumber(actualHour) ~= tonumber(Existing) then
                                  local delFile = pcall(function()
                                      -- delfile("NotSameServers.json")
                                      AllIDs = {}
                                      table.insert(AllIDs, actualHour)
                                  end)
                              end
                          end
                          num = num + 1
                      end
                      if Possible == true then
                          table.insert(AllIDs, ID)
                          wait()
                          pcall(function()
                              -- writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                              wait()
                              game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                          end)
                          wait(4)
                      end
                  end
              end
          end

          function Teleport()
              while wait() do
                  pcall(function()
                      TPReturner()
                      if foundAnything ~= "" then
                          TPReturner()
                      end
                  end)
              end
          end

          Teleport()
