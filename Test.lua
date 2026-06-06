-- ✅ Collect specific objects from Gubby (Fixed Version)
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- Fallback wait function if task.wait is nil
local function safeWait(seconds)
    if task and task.wait then
        task.wait(seconds)
    else
        wait(seconds)
    end
end

-- ===== ตั้งค่าต่างๆ =====
local TARGET_PATH = workspace:FindFirstChild("World")
if TARGET_PATH then
    TARGET_PATH = TARGET_PATH:FindFirstChild("NPC")
    if TARGET_PATH then
        TARGET_PATH = TARGET_PATH:FindFirstChild("Gubby")
    end
end

local TARGET_OBJECT_NAMES = {"TouchPart", "Gubby", "Part", "Collectible"}
local COLLECT_BUTTON = "E"
local TELEPORT_OFFSET_Y = 3
-- =========================

-- ฟังก์ชันรอ character พร้อม
local function waitForCharacter()
    local char = player.Character
    if not char then
        char = player.CharacterAdded:Wait()
        safeWait(2)
    end
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        hrp = char and char:WaitForChild("HumanoidRootPart")
    end
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    return char, hrp, humanoid
end

-- ฟังก์ชันตรวจสอบการตาย
local function checkAlive(humanoid)
    return humanoid and humanoid.Health and humanoid.Health > 0 or false
end

-- ฟังก์ชันเทเลพอร์ต
local function teleportToPosition(position)
    local char, hrp, humanoid = waitForCharacter()
    if not hrp or not checkAlive(humanoid) then
        return false
    end
    
    hrp.CFrame = CFrame.new(position.X, position.Y + TELEPORT_OFFSET_Y, position.Z)
    safeWait(0.5)
    return true
end

-- ฟังก์ชันกดปุ่ม
local function pressButton(button)
    if VirtualInputManager then
        VirtualInputManager:SendKeyEvent(true, button, false, game)
        safeWait(0.1)
        VirtualInputManager:SendKeyEvent(false, button, false, game)
    end
end

-- ฟังก์ชันตรวจสอบว่าวัตถุยังมีอยู่
local function isValidObject(obj)
    if not obj then return false end
    local success, _ = pcall(function()
        return obj.Parent and obj:IsA("BasePart")
    end)
    return success
end

-- ฟังก์ชันหลักในการเก็บของ
local function collectObjects()
    print("🚀 เริ่มเก็บของจาก Gubby...")
    
    if not TARGET_PATH then
        warn("❌ ไม่พบ workspace.World.NPC.Gubby")
        print("🔍 กำลังค้นหาเส้นทางอื่น...")
        
        -- ลองค้นหาอัตโนมัติ
        local world = workspace:FindFirstChild("World")
        if world then
            local npc = world:FindFirstChild("NPC")
            if npc then
                local gubby = npc:FindFirstChild("Gubby")
                if gubby then
                    TARGET_PATH = gubby
                    print("✅ พบ Gubby แล้ว!")
                end
            end
        end
        
        if not TARGET_PATH then
            return
        end
    end
    
    print("✅ พบ Gubby แล้ว: " .. TARGET_PATH.Name)
    
    -- หาวัตถุทั้งหมดใน Gubby
    local allObjects = {}
    
    local success, err = pcall(function()
        for _, obj in ipairs(TARGET_PATH:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Parent ~= player.Character then
                local hasPosition, _ = pcall(function()
                    return obj.Position
                end)
                if hasPosition then
                    table.insert(allObjects, obj)
                end
            end
        end
    end)
    
    if not success then
        warn("❌ ไม่สามารถอ่านวัตถุใน Gubby: " .. tostring(err))
        return
    end
    
    if #allObjects == 0 then
        warn("❌ ไม่พบวัตถุที่สามารถเก็บได้ใน Gubby")
        print("🔍 ใน Gubby มีเด็กดังนี้:")
        for _, child in ipairs(TARGET_PATH:GetChildren()) do
            print("   - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
        return
    end

    print("🔍 พบวัตถุทั้งหมด " .. #allObjects .. " ชิ้นใน Gubby")

    local collectedCount = 0
    local skippedCount = 0

    -- เก็บทีละชิ้น
    for i, targetObj in ipairs(allObjects) do
        if not isValidObject(targetObj) then
            print(string.format("⚠️ [%d/%d] ข้าม: %s (วัตถุหายไป)", i, #allObjects, targetObj.Name))
            skippedCount = skippedCount + 1
        else
            print(string.format("📦 [%d/%d] กำลังเก็บ: %s", i, #allObjects, targetObj.Name))
            
            local _, hrp, humanoid = waitForCharacter()
            if not hrp or not checkAlive(humanoid) then
                print("⚠️ Character ไม่พร้อม ข้ามไป")
                skippedCount = skippedCount + 1
            else
                local targetPosition
                local posSuccess, pos = pcall(function()
                    return targetObj.Position
                end)
                
                if not posSuccess then
                    print(string.format("⚠️ ดึงตำแหน่ง %s ไม่ได้ ข้ามไป", targetObj.Name))
                    skippedCount = skippedCount + 1
                else
                    targetPosition = pos
                    
                    print(string.format("📍 เทเลพอร์ตไปที่ %s", targetObj.Name))
                    local teleportSuccess = teleportToPosition(targetPosition)
                    
                    if not teleportSuccess then
                        print(string.format("⚠️ เทเลพอร์ตล้มเหลวที่ %s", targetObj.Name))
                        skippedCount = skippedCount + 1
                    else
                        safeWait(0.3)
                        print(string.format("⌨️ กดปุ่ม %s", COLLECT_BUTTON))
                        pressButton(COLLECT_BUTTON)
                        
                        collectedCount = collectedCount + 1
                        print(string.format("✅ เก็บสำเร็จ! (%d/%d)", collectedCount, #allObjects))
                        safeWait(0.5)
                    end
                end
            end
        end
    end

    print(string.format("🎊 เสร็จ! เก็บ %d/%d ชิ้น (ข้าม %d ชิ้น)", collectedCount, #allObjects, skippedCount))
end

-- เริ่มทำงาน
local function main()
    safeWait(1)
    local success, err = pcall(function()
        collectObjects()
    end)

    if not success then
        warn("❌ เกิดข้อผิดพลาด: " .. tostring(err))
    end
end

print("🎯 Collector Started!")
main()
