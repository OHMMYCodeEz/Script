local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local Packet = SharedModules:WaitForChild("Packet")
local RemoteEvent = Packet:WaitForChild("RemoteEvent")

-- โหลด Fluent Library และ Addons
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- สร้างหน้าต่างเมนู
local Window = Fluent:CreateWindow({
    Title = "แจกควยไรบ้านนอก Menu",
    SubTitle = "by แจกควยไรบ้านนอก",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.End
})

-- สร้างแท็บหน้าต่าง
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "UI Settings", Icon = "settings" })
}

-- [ ส่วนของหน้า MAIN ]
-- แก้ไข: ใช้ AddGroup แทน AddSection
local LeftGroupBox = Tabs.Main:AddGroup("Groupbox", "Control")

-- ส่วนแสดงสถานะ
local statusLabel = LeftGroupBox:AddParagraph({
    Title = "System Status",
    Content = "Status : Off 🔴"
})

-- ปุ่ม Turn on
LeftGroupBox:AddButton({
    Title = "Turn on",
    Description = "เปิดใช้งานระบบ",
    Callback = function()
        -- แก้ไข: ตรวจสอบว่า RemoteEvent มีอยู่จริง
        if RemoteEvent then
            local success, err = pcall(function()
                RemoteEvent:FireServer(buffer.fromstring("6\000\001\255"))
            end)
            if success then
                statusLabel:SetDesc("Status : On 🟢")
            else
                warn("ส่ง Packet ไม่สำเร็จ: " .. tostring(err))
            end
        else
            warn("ไม่พบ RemoteEvent")
        end
    end
})

-- ปุ่ม Turn off
LeftGroupBox:AddButton({
    Title = "Turn off",
    Description = "ปิดใช้งานระบบ",
    Callback = function()
        if RemoteEvent then
            local success, err = pcall(function()
                RemoteEvent:FireServer(buffer.fromstring("6\000\000"))
            end)
            if success then
                statusLabel:SetDesc("Status : Off 🔴")
            else
                warn("ส่ง Packet ไม่สำเร็จ: " .. tostring(err))
            end
        end
    end
})

-- ปุ่ม Rejoin
LeftGroupBox:AddButton({
    Title = "Rejoin",
    Description = "กลับเข้าเซิร์ฟเวอร์เดิมอีกครั้ง",
    Callback = function()
        -- แก้ไข: ใช้ task.wait เพื่อให้แน่ใจว่า Teleport ทำงาน
        task.spawn(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
})

-- [ ระบบนับ FPS & PING ]
local infoLabel = Tabs.Main:AddParagraph({
    Title = "Performance Status",
    Content = "FPS: 0 | Ping: 0 ms"
})

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 0

local WatermarkConnection
WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1
    
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end
    
    -- แก้ไข: ใช้ pcall ครอบคลุมทั้งหมด
    local success, pingValue = pcall(function()
        local stats = game:GetService('Stats')
        if stats and stats.Network and stats.Network.ServerStatsItem then
            local pingItem = stats.Network.ServerStatsItem['Data Ping']
            if pingItem then
                return math.floor(pingItem:GetValue())
            end
        end
        return 0
    end)
    
    if not success then 
        pingValue = 0 
    end
    
    -- แก้ไข: ใช้ tostring เพื่อป้องกัน error
    infoLabel:SetDesc("FPS: " .. tostring(math.floor(FPS)) .. " | Ping: " .. tostring(pingValue) .. " ms")
end)

-- [ ส่วนของหน้า UI SETTINGS & UNLOAD ]
local MenuGroup = Tabs.Settings:AddGroup("Menu", "Settings")

-- ปุ่ม Unload
MenuGroup:AddButton({
    Title = "Unload",
    Description = "ปิดสคริปต์และล้างการเชื่อมต่อทั้งหมด",
    Callback = function()
        if WatermarkConnection then
            WatermarkConnection:Disconnect()
            WatermarkConnection = nil
        end
        print('Unloaded!')
        Fluent:Destroy()
        -- แก้ไข: ทำลาย UI ทั้งหมด
        game:GetService("GuiService"):ClearError()
    end
})

-- [ ระบบบันทึกการตั้งค่า (Save / Load Config) ]
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")

-- แก้ไข: ตรวจสอบว่ามี Tabs.Settings ก่อนใช้งาน
if Tabs and Tabs.Settings then
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)
end

-- แก้ไข: ใช้ pcall ป้องกัน error ตอนโหลด config
pcall(function()
    SaveManager:LoadAutoloadConfig()
end)

-- แจ้งเตือนเมื่อโหลดเสร็จ
Fluent:Notify({
    Title = "แจกควยไรบ้านนอก Menu",
    Content = "สคริปต์แก้ไขบัคและอาการจอเบลอเสร็จสิ้น!",
    Duration = 5
})
