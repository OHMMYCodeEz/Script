-- UI สำหรับแสดงข้อความ MARU HUB กลางจอแบบไม่มีพื้นหลัง (เวอร์ชันกระพริบ)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- สร้าง ScreenGui
local MaruHubUI = Instance.new("ScreenGui")
MaruHubUI.Name = "MaruHubUI"
MaruHubUI.ResetOnSpawn = false
MaruHubUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- สร้าง TextLabel สำหรับข้อความ (ไม่มีพื้นหลัง)
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(0, 600, 0, 50)
TitleLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
TitleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
TitleLabel.BackgroundTransparency = 1 -- ไม่มีพื้นหลัง
TitleLabel.Text = "MARU HUB Next Gen Pro Max Galaxy A17 Pro++"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
TitleLabel.TextSize = 48
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextStrokeTransparency = 0.5
TitleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center

-- ประกอบ UI เข้าด้วยกัน
TitleLabel.Parent = MaruHubUI
MaruHubUI.Parent = PlayerGui

-- ฟังก์ชันสำหรับแอนิเมชันกระพริบ
local function blinkAnimation()
    local colors = {
        Color3.fromRGB(255, 215, 0), -- Gold
        Color3.fromRGB(255, 255, 255), -- White
        Color3.fromRGB(255, 100, 100), -- Red
        Color3.fromRGB(100, 255, 100), -- Green
        Color3.fromRGB(100, 100, 255) -- Blue
    }
    
    local currentColor = 1
    
    while MaruHubUI.Parent do
        -- เปลี่ยนสี
        TitleLabel.TextColor3 = colors[currentColor]
        currentColor = currentColor + 1
        if currentColor > #colors then
            currentColor = 1
        end
        
        -- เอฟเฟกต์กระพริบ
        for i = 1, 3 do
            TitleLabel.TextTransparency = 0.2
            wait(0.1)
            TitleLabel.TextTransparency = 0
            wait(0.1)
        end
        
        wait(1)
    end
end

-- เริ่มแอนิเมชัน
coroutine.wrap(blinkAnimation)()
-- เปลี่ยนที่อยู่ของกล่องเป็นไข่ workspace.AreaEgg
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Workspace = game:GetService("Workspace")

-- ตัวแปรเก็บสถานะ
local currentIsland = ""
local respawnAttempts = 0
local maxRespawnAttempts = 3

-- ฟังก์ชันเช็คการตาย
local function checkIfDead()
    if not Character or not Character:FindFirstChild("Humanoid") then
        return true
    end
    return Character.Humanoid.Health <= 0
end

-- ฟังก์ชันรอให้เกิดใหม่
local function waitForRespawn()
    print("Player died, waiting for respawn...")
    
    -- รอให้เกิดใหม่
    local newCharacter = LocalPlayer.CharacterAdded:Wait()
    Character = newCharacter
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    wait(3) -- รอให้การเกิดใหม่เสร็จสมบูรณ์
    respawnAttempts = respawnAttempts + 1
    
    print("Respawned! Attempt " .. respawnAttempts .. "/" .. maxRespawnAttempts)
    return true
end

-- ฟังก์ชันวาปไปที่เกาะ
local function teleportToIsland(islandName)
    currentIsland = islandName
    respawnAttempts = 0
    
    local island = Workspace:FindFirstChild("Area")
    if island then
        island = island:FindFirstChild(islandName)
    end
    
    if not island then
        -- ลองค้นหาโดยตรงใน Workspace
        island = Workspace:FindFirstChild(islandName)
    end
    
    if island then
        -- ค้นหา Part ใดๆ ในเกาะเพื่อใช้เป็นจุดวาป
        local targetPart = island:FindFirstChildWhichIsA("BasePart") or
                          island:FindFirstChild("SpawnPoint") or
                          island:FindFirstChild("Part")
        
        if not targetPart and island:IsA("Model") then
            for _, child in pairs(island:GetDescendants()) do
                if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
                    targetPart = child
                    break
                end
            end
        end
        
        if targetPart then
            local islandPosition = targetPart.Position
            
            -- เช็คก่อนว่ายังไม่ตาย
            if checkIfDead() then
                if waitForRespawn() then
                    -- พยายามวาปอีกครั้งหลังจากเกิดใหม่
                    return teleportToIsland(islandName)
                end
            end
            
            HumanoidRootPart.CFrame = CFrame.new(islandPosition + Vector3.new(0, 10, 0))
            
            print("Teleported to " .. islandName)
            wait(2) -- รอให้โหลดเกาะ
            
            -- เช็คอีกครั้งหลังวาป
            if checkIfDead() then
                print("Died after teleporting to " .. islandName)
                if respawnAttempts < maxRespawnAttempts then
                    if waitForRespawn() then
                        return teleportToIsland(islandName)
                    end
                else
                    print("Max respawn attempts reached for " .. islandName)
                    return false
                end
            end
            
            return true
        else
            print("No valid part found in " .. islandName)
            return false
        end
    else
        print("Island " .. islandName .. " not found!")
        return false
    end
end

-- ฟังก์ชันเก็บไข่ทั้งหมดใน AreaEgg
local function collectAllEggsInArea()
    local areaEgg = Workspace:FindFirstChild("AreaEgg")
    if not areaEgg then
        print("AreaEgg area not found!")
        return 0
    end
    
    print("Found AreaEgg, searching for egg crates...")
    local collectedCount = 0
    
    for _, eggCrate in pairs(areaEgg:GetChildren()) do
        -- เช็คการตายก่อนเก็บไข่แต่ละฟอง
        if checkIfDead() then
            print("Died while collecting eggs, respawning...")
            if respawnAttempts < maxRespawnAttempts then
                if waitForRespawn() then
                    -- กลับไปเกาะเดิมหลังจากเกิดใหม่
                    if teleportToIsland(currentIsland) then
                        -- เริ่มต้นเก็บไข่ใหม่
                        return collectAllEggsInArea()
                    else
                        return collectedCount
                    end
                end
            else
                print("Max respawn attempts reached, moving to next island")
                return collectedCount
            end
        end
        
        -- ตรวจสอบว่าเป็นกล่องไข่ (ขยายเงื่อนไขการค้นหา)
        if eggCrate:IsA("Model") or eggCrate:IsA("Part") or string.find(eggCrate.Name:lower(), "egg") or tonumber(eggCrate.Name) ~= nil then
            
            local targetPart = nil
            
            -- ลองหา Part ในลำดับความสำคัญ
            if eggCrate:IsA("Part") then
                targetPart = eggCrate
            else
                targetPart = eggCrate:FindFirstChildWhichIsA("BasePart") or
                           eggCrate:FindFirstChild("Handle") or
                           eggCrate:FindFirstChild("MainPart") or
                           eggCrate:FindFirstChild("Part")
                
                -- ถ้ายังหาไม่เจอ ให้ค้นหาใน descendants ทั้งหมด
                if not targetPart then
                    for _, child in pairs(eggCrate:GetDescendants()) do
                        if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
                            targetPart = child
                            break
                        end
                    end
                end
            end
            
            if targetPart then
                local eggPosition = targetPart.Position
                
                -- ตรวจสอบว่าตำแหน่งไม่ใช่ (0,0,0)
                if eggPosition.Magnitude > 1 then
                    
                    -- เช็คการตายก่อนวาปไปหาไข่
                    if checkIfDead() then
                        print("Died before collecting egg, respawning...")
                        if respawnAttempts < maxRespawnAttempts then
                            if waitForRespawn() then
                                if teleportToIsland(currentIsland) then
                                    return collectAllEggsInArea()
                                else
                                    return collectedCount
                                end
                            end
                        else
                            return collectedCount
                        end
                    end
                    
                    HumanoidRootPart.CFrame = CFrame.new(eggPosition + Vector3.new(0, 5, 0))

                    wait(0.5)

                    -- เช็คการตายก่อนกดปุ่ม E
                    if not checkIfDead() then
                        VirtualInputManager:SendKeyEvent(true, "E", false, game)
                        wait(1.5)
                        VirtualInputManager:SendKeyEvent(false, "E", false, game)
                        wait(0.5)
                        VirtualInputManager:SendKeyEvent(true, "E", false, game)
                        wait(1.5)
                        VirtualInputManager:SendKeyEvent(false, "E", false, game)
                        wait(0.5)
                        VirtualInputManager:SendKeyEvent(true, "E", false, game)
                        wait(1.5)
                        VirtualInputManager:SendKeyEvent(false, "E", false, game)
                        collectedCount = collectedCount + 1
                        print("Collected egg: " .. eggCrate.Name .. " (" .. collectedCount .. ")")
                    else
                        print("Died while pressing E, will respawn and continue")
                        if respawnAttempts < maxRespawnAttempts then
                            if waitForRespawn() then
                                if teleportToIsland(currentIsland) then
                                    return collectAllEggsInArea()
                                else
                                    return collectedCount
                                end
                            end
                        else
                            return collectedCount
                        end
                    end
                    
                    wait(0.1)
                else
                    print("Invalid position for egg: " .. eggCrate.Name)
                end
            else
                print("No valid part found for: " .. eggCrate.Name)
            end
        end
    end
    
    return collectedCount
end

-- ฟังก์ชันดีบัก: ดูโครงสร้างของ Area และ AreaEgg
local function debugAreas()
    print("=== Debugging Areas ===")
    
    local area = Workspace:FindFirstChild("Area")
    if area then
        print("Found Area, children:")
        for _, child in pairs(area:GetChildren()) do
            print(" - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    else
        print("Area not found in Workspace")
    end
    
    local areaEgg = Workspace:FindFirstChild("AreaEgg")
    if areaEgg then
        print("Found AreaEgg, first 10 children:")
        local count = 0
        for _, child in pairs(areaEgg:GetChildren()) do
            print(" - " .. child.Name .. " (" .. child.ClassName .. ")")
            count = count + 1
            if count >= 10 then break end
        end
    else
        print("AreaEgg not found in Workspace")
    end
    print("======================")
end

-- ฟังก์ชันหลักในการรวบรวมไข่จากทุกเกาะ
local function collectEggsFromAllIslands()
    local islands = {"Ice", "Root", "Volcano"} -- เพิ่มชื่อเกาะอื่นๆ ตามต้องการ
    
    for round = 1, 2 do
        print("Starting round " .. round .. " of 2")
        local totalCollected = 0
        
        for _, islandName in pairs(islands) do
            print("Teleporting to " .. islandName .. "...")
            
            if teleportToIsland(islandName) then
                wait(3) -- รอให้โหลดเกาะเสร็จ
                
                -- เก็บไข่ในเกาะนี้
                local collected = collectAllEggsInArea()
                totalCollected = totalCollected + collected
                print("Collected " .. collected .. " eggs from " .. islandName)
                
                wait(5) -- รอก่อนไปเกาะถัดไป
            else
                print("Failed to teleport to " .. islandName .. ", skipping...")
            end
        end
        
        print("Completed round " .. round .. ": " .. totalCollected .. " eggs total")
        
        if round < 2 then
            print("Waiting before next round...")
            wait(5) -- รอนานขึ้นระหว่างรอบ
        end
    end
    
    return totalCollected
end

-- เริ่มต้นสคริปต์
debugAreas() -- ดูโครงสร้างก่อนเริ่ม

-- รวบรวมไข่จากทุกเกาะ
collectEggsFromAllIslands()

print("Egg collection completed! Starting server hop...")

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
                          wait(1)
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
