-- ✅ Collect specific objects from Gubby (Flexible Version)
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- ===== ตั้งค่าต่างๆ =====
local TARGET_PATH = workspace.World.NPC.Gubby  -- ตำแหน่งที่ต้องการเก็บ
local TARGET_OBJECT_NAMES = {"TouchPart", "MoneyBox", "Part", "Collectible"}  -- ชื่อวัตถุที่ต้องการเก็บ (เพิ่ม/ลดได้)
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
    task.wait(0.8)
    return true
end

-- ฟังก์ชันกดปุ่ม
local function pressButton(button)
    VirtualInputManager:SendKeyEvent(true, button, false, game)
    task.wait(1)
    VirtualInputManager:SendKeyEvent(false, button, false, game)
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
        warn("❌ ไม่พบ Gubny ที่: " .. tostring(TARGET_PATH))
        return
    end
    
    print("✅ พบ Gubby แล้ว: " .. gubby.Name)
    
    -- หาวัตถุทั้งหมดใน Gubby
    local allObjects = {}
    
    -- หาทั้งเด็กและลูกหลาน
    for _, obj in ipairs(gubby:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(player.Character) then
            table.insert(allObjects, obj)
        end
    end
    
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

    -- เก็บทีละชิ้น
    for i, targetObj in ipairs(allObjects) do
        print(string.format("📦 [%d/%d] กำลังเก็บ: %s", i, #allObjects, targetObj.Name))
        
        -- ตรวจสอบสถานะตัวละคร
        char, hrp, humanoid = waitForCharacter()
        if not checkAlive(humanoid) then
            warn("❌ Character ตาย หยุดการทำงาน")
            break
        end
        
        -- เทเลพอร์ตไปยังวัตถุ
        print(string.format("📍 เทเลพอร์ตไปที่ %s (%.1f, %.1f, %.1f)", 
            targetObj.Name, 
            targetObj.Position.X, 
            targetObj.Position.Y, 
            targetObj.Position.Z))
        
        local teleportSuccess = teleportToPosition(targetObj.Position)
        
        if not teleportSuccess then
            warn("❌ เทเลพอร์ตล้มเหลวที่ " .. targetObj.Name)
            break
        end
        
        task.wait(0.5)
        
        -- กดปุ่มเพื่อเก็บ
        print(string.format("⌨️ กดปุ่ม %s ที่ %s", COLLECT_BUTTON, targetObj.Name))
        pressButton(COLLECT_BUTTON)
        
        collectedCount = collectedCount + 1
        print(string.format("✅ เก็บสำเร็จ! (%d/%d)", collectedCount, #allObjects))
        
        -- รอระหว่างเก็บ
        task.wait(0.8)
    end

    print(string.format("🎊 เก็บเสร็จ! เก็บได้ %d/%d ชิ้น", collectedCount, #allObjects))
end

-- เริ่มทำงาน
local function main()
    local success, err = pcall(function()
        collectObjects()
    end)

    if not success then
        warn("❌ เกิดข้อผิดพลาด: " .. tostring(err))
        print("🔄 ลองใหม่ใน 3 วินาที...")
        task.wait(2)
        pcall(function()
            collectObjects()
        end)
    end
end

print("🎯 Collector Started!")
print("📍 Target: workspace.World.NPC.Gubby")
print("🔧 ปรับแต่งได้ที่ส่วน SETTINGS ด้านบนของสคริปต์")
main()
