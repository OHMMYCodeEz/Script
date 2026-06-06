-- ✅ Collect specific objects from Gubby (Flexible Version with Skip)
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- ===== ตั้งค่าต่างๆ =====
local TARGET_PATH = workspace.World.NPC.Gubby  -- ตำแหน่งที่ต้องการเก็บ
local TARGET_OBJECT_NAMES = {"TouchPart", "Gubby", "Part", "Collectible"}  -- ชื่อวัตถุที่ต้องการเก็บ (เพิ่ม/ลดได้)
local COLLECT_BUTTON = "E"  -- ปุ่มที่ใช้เก็บ
local TELEPORT_OFFSET_Y = 3  -- ระยะห่างแนวแกน Y เมื่อเทเลพอร์ต
-- =========================

-- ฟังก์ชันรอ character พร้อม
local function waitForCharacter()
    local char = player.Character
    if not char then
        char = player.CharacterAdded:Wait()
        task.wait(2)
    end
    local hrp = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    return char, hrp, humanoid
end

-- ฟังก์ชันตรวจสอบการตาย
local function checkAlive(humanoid)
    return humanoid and humanoid.Health > 0
end

-- ฟังก์ชันค้นหาส่วนที่สัมผัส
local function findTargetPart(container)
    for _, name in ipairs(TARGET_OBJECT_NAMES) do
        local part = container:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            return part
        end
    end
    
    for _, obj in ipairs(container:GetDescendants()) do
        for _, name in ipairs(TARGET_OBJECT_NAMES) do
            if obj.Name == name and obj:IsA("BasePart") then
                return obj
            end
        end
    end
    
    return nil
end

-- ฟังก์ชันเทเลพอร์ต
local function teleportToPosition(position)
    local char, hrp, humanoid = waitForCharacter()
    if not checkAlive(humanoid) then
        return false
    end
    
    hrp.CFrame = CFrame.new(position.X, position.Y + TELEPORT_OFFSET_Y, position.Z)
    task.wait(0.5)
    return true
end

-- ฟังก์ชันกดปุ่ม
local function pressButton(button)
    VirtualInputManager:SendKeyEvent(true, button, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, button, false, game)
end

-- ฟังก์ชันตรวจสอบว่าวัตถุยังมีอยู่และสามารถเก็บได้
local function isValidObject(obj)
    if not obj or not obj.Parent then
        return false
    end
    if not obj:IsA("BasePart") then
        return false
    end
    if obj:IsDescendantOf(player.Character) then
        return false
    end
    -- ตรวจสอบว่าวัตถุถูกทำลายหรือไม่
    local success, _ = pcall(function()
        return obj.Position
    end)
    return success
end

-- ฟังก์ชันหลักในการเก็บของ
local function collectObjects()
    print("🚀 เริ่มเก็บของจาก Gubby...")
    
    local char, hrp, humanoid = waitForCharacter()
    if not checkAlive(humanoid) then
        warn("❌ Character ไม่พร้อม")
        return
    end

    -- ตรวจสอบว่า Gubby มีอยู่จริง
    local gubby = TARGET_PATH
    if not gubby then
        warn("❌ ไม่พบ Gubby ที่: " .. tostring(TARGET_PATH))
        return
    end
    
    print("✅ พบ Gubby แล้ว: " .. gubby.Name)
    
    -- หาวัตถุทั้งหมดใน Gubby (แบบ Real-time)
    local function getAllObjects()
        local objects = {}
        if not gubby or not gubby.Parent then
            return objects
        end
        for _, obj in ipairs(gubby:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(player.Character) then
                -- ตรวจสอบว่าวัตถุมี Position ที่ถูกต้อง
                local success, _ = pcall(function()
                    return obj.Position
                end)
                if success then
                    table.insert(objects, obj)
                end
            end
        end
        return objects
    end
    
    local allObjects = getAllObjects()
    
    if #allObjects == 0 then
        warn("❌ ไม่พบวัตถุที่สามารถเก็บได้ใน Gubby")
        print("🔍 ใน Gubby มีเด็กดังนี้:")
        for _, child in ipairs(gubby:GetChildren()) do
            print("   - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
        return
    end

    print("🔍 พบวัตถุทั้งหมด " .. #allObjects .. " ชิ้นใน Gubby")
    
    -- แสดงรายการวัตถุที่พบ
    for i, obj in ipairs(allObjects) do
        print(string.format("   %d. %s (ประเภท: %s)", i, obj.Name, obj.ClassName))
    end

    local collectedCount = 0
    local skippedCount = 0

    -- เก็บทีละชิ้น
    for i, targetObj in ipairs(allObjects) do
        -- ก่อนเริ่มแต่ละรอบ ตรวจสอบว่าวัตถุยังมีอยู่
        if not isValidObject(targetObj) then
            print(string.format("⚠️ [%d/%d] ข้าม: %s (วัตถุหายไปหรือถูกทำลายแล้ว)", i, #allObjects, targetObj.Name))
            skippedCount = skippedCount + 1
            -- ข้ามไปชิ้นถัดไป
        else
            print(string.format("📦 [%d/%d] กำลังเก็บ: %s", i, #allObjects, targetObj.Name))
            
            -- ตรวจสอบสถานะตัวละคร
            char, hrp, humanoid = waitForCharacter()
            if not checkAlive(humanoid) then
                print("⚠️ Character ตาย ข้ามไปชิ้นถัดไป")
                skippedCount = skippedCount + 1
                -- ข้ามไปชิ้นถัดไป
            elseif not isValidObject(targetObj) then
                print(string.format("⚠️ วัตถุ %s หายไประหว่างรอ ข้ามไป", targetObj.Name))
                skippedCount = skippedCount + 1
                -- ข้ามไปชิ้นถัดไป
            else
                -- ดึงตำแหน่งล่าสุด
                local targetPosition
                local success, pos = pcall(function()
                    return targetObj.Position
                end)
                
                if not success or not pos then
                    print(string.format("⚠️ ไม่สามารถดึงตำแหน่งของ %s ได้ ข้ามไป", targetObj.Name))
                    skippedCount = skippedCount + 1
                    -- ข้ามไปชิ้นถัดไป
                else
                    targetPosition = pos
                    
                    -- เทเลพอร์ตไปยังวัตถุ
                    print(string.format("📍 เทเลพอร์ตไปที่ %s (%.1f, %.1f, %.1f)", 
                        targetObj.Name, 
                        targetPosition.X, 
                        targetPosition.Y, 
                        targetPosition.Z))
                    
                    local teleportSuccess = teleportToPosition(targetPosition)
                    
                    if not teleportSuccess then
                        print(string.format("⚠️ เทเลพอร์ตล้มเหลวที่ %s ข้ามไป", targetObj.Name))
                        skippedCount = skippedCount + 1
                        -- ข้ามไปชิ้นถัดไป
                    else
                        -- ตรวจสอบวัตถุอีกครั้งก่อนกดปุ่ม
                        if not isValidObject(targetObj) then
                            print(string.format("⚠️ วัตถุ %s หายไประหว่างเทเลพอร์ต ข้ามไป", targetObj.Name))
                            skippedCount = skippedCount + 1
                            -- ข้ามไปชิ้นถัดไป
                        else
                            task.wait(0.3)
                            
                            -- กดปุ่มเพื่อเก็บ
                            print(string.format("⌨️ กดปุ่ม %s ที่ %s", COLLECT_BUTTON, targetObj.Name))
                            pressButton(COLLECT_BUTTON)
                            
                            collectedCount = collectedCount + 1
                            print(string.format("✅ เก็บสำเร็จ! (%d/%d) เก็บแล้ว %d ชิ้น, ข้าม %d ชิ้น", 
                                collectedCount, #allObjects, collectedCount, skippedCount))
                            
                            -- รอระหว่างเก็บ
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
    end

    print(string.format("🎊 เก็บเสร็จ! เก็บได้ %d/%d ชิ้น (ข้าม %d ชิ้น)", 
        collectedCount, #allObjects, skippedCount))
    
    if collectedCount < #allObjects then
        print("⚠️ เก็บไม่หมด! บางชิ้นอาจหายไปหรือเก็บไม่ได้")
    end
end

-- เริ่มทำงานแบบ Loop จนกว่าจะเก็บหมด
local function main()
    local maxRetries = 3
    local retryCount = 0
    
    while retryCount < maxRetries do
        local success, err = pcall(function()
            collectObjects()
        end)

        if not success then
            warn("❌ เกิดข้อผิดพลาด: " .. tostring(err))
            retryCount = retryCount + 1
            if retryCount < maxRetries then
                print(string.format("🔄 ลองใหม่ครั้งที่ %d ใน %d วินาที...", retryCount + 1, retryCount * 2))
                task.wait(retryCount * 2)
            else
                print("❌ ลองใหม่ครบ " .. maxRetries .. " ครั้งแล้ว หยุดการทำงาน")
            end
        else
            break
        end
    end
end

print("🎯 Collector Started!")
print("📍 Target: workspace.World.NPC.Gubby")
print("🔧 ปรับแต่งได้ที่ส่วน SETTINGS ด้านบนของสคริปต์")
print("✨ ถ้าไม่เจอวัตถุ หรือวัตถุหาย จะข้ามไปชิ้นถัดไปอัตโนมัติ")
main()
