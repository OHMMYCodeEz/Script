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

-- สร้างหน้าต่างเมนู (แก้กรง Acrylic = false เพื่อไม่ให้เกมเบลอแล้วครับ)
local Window = Fluent:CreateWindow({
    Title = "แจกควยไรบ้านนอก Menu",
    SubTitle = "by แจกควยไรบ้านนอก",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- ปิดระบบเบลอฉากหลังเรียบร้อย จอไม่เบลอแน่นอน
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.End
})

-- สร้างแท็บหน้าต่าง
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "UI Settings", Icon = "settings" })
}

-- [ ส่วนของหน้า MAIN ]
local LeftGroupBox = Tabs.Main:AddSection("Groupbox")

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
        RemoteEvent:FireServer(buffer.fromstring("6\000\001\255"))
        statusLabel:SetDesc("Status : On 🟢")
    end
})

-- ปุ่ม Turn off
LeftGroupBox:AddButton({
    Title = "Turn off",
    Description = "ปิดใช้งานระบบ",
    Callback = function()
        RemoteEvent:FireServer(buffer.fromstring("6\000\000"))
        statusLabel:SetDesc("Status : Off 🔴")
    end
})

-- ปุ่ม Rejoin
LeftGroupBox:AddButton({
    Title = "Rejoin",
    Description = "กลับเข้าเซิร์ฟเวอร์เดิมอีกครั้ง",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})


-- [ ระบบนับ FPS & PING ]
local infoLabel = Tabs.Main:AddParagraph({
    Title = "Performance Status",
    Content = "FPS: 240 | Ping: 0 ms"
})

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 240

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end

    local success, pingValue = pcall(function()
        return math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    end)
    if not success then pingValue = 0 end

    infoLabel:SetDesc(string.format("FPS: %s | Ping: %s ms", math.floor(FPS), pingValue))
end)


-- [ ส่วนของหน้า UI SETTINGS & UNLOAD ]
local MenuGroup = Tabs.Settings:AddSection("Menu")

-- ปุ่ม Unload
MenuGroup:AddButton({
    Title = "Unload",
    Description = "ปิดสคริปต์และล้างการเชื่อมต่อทั้งหมด",
    Callback = function()
        if WatermarkConnection then
            WatermarkConnection:Disconnect()
        end
        print('Unloaded!')
        Fluent:Destroy()
    end
})


-- [ ระบบบันทึกการตั้งค่า (Save / Load Config) ]
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- ลบโค้ด Tabs.Main:Select() ที่ทำให้เกิดบัคออกแล้วครับนิวส์

SaveManager:LoadAutoloadConfig()

-- แจ้งเตือนเมื่อโหลดเสร็จ
Fluent:Notify({
    Title = "แจกควยไรบ้านนอก Menu",
    Content = "สคริปต์แก้ไขบัคและอาการจอเบลอเสร็จสิ้น!",
    Duration = 5
})
