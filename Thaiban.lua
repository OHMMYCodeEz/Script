if not game:IsLoaded() then game.Loaded:Wait() end 

local Players = game:GetService('Players')
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService('RunService')
local PathfindingService = game:GetService('PathfindingService')

local Env = getgenv()

local Client = Players.LocalPlayer
local UserId = Client.UserId
local Backpack = Client.Backpack
local PlayerGui = Client.PlayerGui

local Character = Client.Character or Client.CharacterAdded:Wait()
local RootPart = Character:WaitForChild('HumanoidRootPart')
local Humanoid = Character:WaitForChild('Humanoid')

local V2JobRuntime = workspace:WaitForChild('V2JobRuntime')
local JobInteraction = workspace:WaitForChild('JobInteractions')
local NpcJobGiver = JobInteraction:WaitForChild('NPCJobGiver')
local JobManagerV2 = ReplicatedStorage:WaitForChild("JobManagerV2")

local Network = require(JobManagerV2.Network.Client)
local StepProofCodec = require(JobManagerV2.Shared.StepProofCodec)
local Delivery = require(JobManagerV2.JobChannels.Delivery)

local JobManager = Network.JobManager

local Func = {}
local Module = {}
local AllPlayersDrawings = {}
local TargetAim = nil

local DataInteraction = nil
local CurrentCamera = workspace:FindFirstChild('Camera')

local function Connect(Event, Callback)
    local Conn = Event:Connect(Callback)
    return Conn
end

Connect(Client.CharacterAdded, function(newChar)
    Character = newChar
    RootPart = Character:WaitForChild('HumanoidRootPart')
    Humanoid = Character:WaitForChild('Humanoid')
end)

function Module.Draw(Object, Prop)
    local Draw = Drawing.new(Object)
    if not Draw then
        warn('Failed to create drawing object.')
        return
    end 
    
    for Name, Value in pairs(Prop) do
        Draw[Name] = Value
    end
    return Draw
end

function Module.WorldToScreen(part)
    local Target = typeof(part) == "Instance" and part.Position or part
    return CurrentCamera:WorldToViewportPoint(Target)
end

function Module.IsAlive(Model)
    if not Model then return end 
    local Hum = Model:FindFirstChildOfClass('Humanoid')
    if not Hum then return end 
    return Hum.Health > 0
end

function Module.GetDistance(Start, End)
    if typeof(Start) == "Vector2" and typeof(End) == "Vector2" then
        return (End - Start).Magnitude
    end

    if typeof(Start) == "Instance" then
        Start = (Start:IsA("BasePart") and Start.Position) or (Start:IsA("Model") and Start:GetPivot().Position) or RootPart.Position
    elseif typeof(Start) == "CFrame" then
        Start = Start.Position
    elseif typeof(Start) ~= "Vector3" then
        Start = RootPart.Position
    end

    if typeof(End) == "Instance" then
        if End:IsA("BasePart") then
            return (End.Position - Start).Magnitude
        elseif End:IsA("Model") then
            return (End:GetPivot().Position - Start).Magnitude
        end
    elseif typeof(End) == "Vector3" or typeof(End) == "CFrame" then
        return ((typeof(End) == "CFrame" and End.Position or End) - Start).Magnitude
    end

    return math.huge
end

function Module.Closest(Path, condition, Base_position, mode, range)
	local results = {}
	local maxRange = math.huge
	local sortMode = "nearest"
	if type(mode) == "number" then
		maxRange = mode
		sortMode = "nearest"
	elseif mode == "farthest" then
		sortMode = "farthest"
	elseif mode == "value" then
		sortMode = "value"
	elseif type(range) == "number" then
		maxRange = range
	end
	for _, Object in pairs(Path) do
		if condition(Object) then
			if sortMode == "value" then
				local diff = math.abs(Object.price - Base_position)
				table.insert(results, {
					obj = Object,
					dist = diff
				})
			else
				local Distance = (Object:GetPivot().Position - Base_position).Magnitude
				if Distance <= maxRange then
					table.insert(results, {
						obj = Object,
						dist = Distance
					})
				end
			end
		end
	end
	if #results == 0 then
		return nil
	end
	table.sort(results, function(a, b)
		return a.dist < b.dist
	end)
    return results[1].obj
end

function Module.EncodeStep(token, step, total)
    local buf = buffer.create(6)
    buffer.writeu32(buf, 0, token)
    buffer.writeu8(buf, 4, step or 0)
    buffer.writeu8(buf, 5, total or 0)
    return buf
end

JobManager.InteractionAdded.On(function(data)
    DataInteraction = data
end)

for _,v in next, workspace:GetDescendants() do 
    if not v:IsA("BasePart") then continue end 
    if not v:FindFirstChildOfClass("PathfindingModifier") then continue end


    local Modifier = Instance.new("PathfindingModifier")
    Modifier.Label = "AutoObstacle"
    Modifier.Parent = v
end

local PathFindingConfig = {
    AgentRadius = 2.5,
    AgentHeight = 5.5,
    AgentCanClimb = true,
    AgentCanJump = true,
    Costs = {
        AutoObstacle = 45
    }
}

function Module.MoveTo(TargetPos)
    if Humanoid.Sit then Humanoid.Sit = false end

    local Path = PathfindingService:CreatePath(PathFindingConfig)

    local Success, ErrorMessage = pcall(function()
        Path:ComputeAsync(RootPart.Position, TargetPos)
    end)

    if not Success then warn('Failed to generate waypoint.') return end
    if Path.Status ~= Enum.PathStatus.Success then warn("Can't generate waypoint.") return end

    local Waypoints = Path:GetWaypoints()

    local AllPoint = workspace:FindFirstChild('AllPoint')

    if not AllPoint then 
        AllPoint = Instance.new('Folder', workspace)
        AllPoint.Name = "AllPoint"
    end

    AllPoint:ClearAllChildren()

    for _, GetWaypoint in ipairs(Waypoints) do 
        local Marker = Instance.new("Part", AllPoint)
        Marker.Shape = Enum.PartType.Ball
        Marker.Size = Vector3.new(0.2, 0.2, 0.2)
        Marker.Position = GetWaypoint.Position
        Marker.Anchored = true
        Marker.CanCollide = false
        Marker.Material = Enum.Material.Neon
        Marker.Color = Color3.fromRGB(0, 170, 255)
    end

    for _, Waypoint in ipairs(Waypoints) do
        if Humanoid.Sit then Humanoid.Sit = false end

        if Env.StopTween then
            return
        end

        if Humanoid.Health <= 0 then
            return
        end

        if Humanoid.WalkSpeed ~= 16 then
            Humanoid.WalkSpeed = 30
        end

        if Waypoint.Action == Enum.PathWaypointAction.Jump then
            Humanoid:ChangeState("Jumping")
        end
        
        Humanoid:MoveTo(Waypoint.Position)

        local Reached = false
        local Connection

        Connection = Connect(Humanoid.MoveToFinished, function(reached)
            Reached = reached
        end)

        local StartTime = os.clock()

        repeat task.wait() until (os.clock() - StartTime) >= 15 or Reached

        if not Reached then
            return
        end
    end

    AllPoint:Destroy()
    return
end

function Module.StopMove()
    Env.StopTween = true 
    task.wait()
    Env.StopTween = false
end

local Circle = Module.Draw("Circle", {
    Visible = false,
    Thickness = 0.5,
    Color = Color3.fromRGB(255, 105, 180)
})

local TrackAimbot = Module.Draw("Line", {
    Visible = false,
    Thickness = 1,
    Color = Color3.fromRGB(173, 16, 16)
})

for i,v in next, Players:GetPlayers() do 
    if v == Client then continue end 

    AllPlayersDrawings[v] = {
        Box = Module.Draw('Square',{
            Visible = false,
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 0.7,
            Transparency = 1,
            Filled = false
        }),
        HpBar = Module.Draw('Line',{
            Visible = false,
            Color = Color3.new(0, 1, 0),
            Thickness = 2
        }),
        Name = Module.Draw('Text',{
            Visible = false,
            Color = Color3.new(1, 1, 1),
            Size = 15,
            Center = true,
            Outline = true,
            OutlineColor = Color3.new(0, 0, 0),
            Text = v.Name
        }),
        Distance = Module.Draw('Text',{
            Visible = false,
            Color = Color3.new(1, 1, 1),
            Size = 15,
            Center = true,
            Outline = true,
            OutlineColor = Color3.new(0, 0, 0),
            Text = ""
        }),
        Line = Module.Draw("Line", {
            Visible = false,
            Thickness = 1,
            Color = Color3.fromRGB(255, 255, 255)
        })
    }
end

Connect(Players.PlayerAdded, function(Plr)
    if Plr == Client then return end

    AllPlayersDrawings[Plr] = {
        Box = Module.Draw('Square',{
            Visible = false,
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 0.7,
            Transparency = 1,
            Filled = false
        }),
        HpBar = Module.Draw('Line',{
            Visible = false,
            Color = Color3.new(0, 1, 0),
            Thickness = 2
        }),
        Name = Module.Draw('Text',{
            Visible = false,
            Color = Color3.new(1, 1, 1),
            Size = 15,
            Center = true,
            Outline = true,
            OutlineColor = Color3.new(0, 0, 0),
            Text = Plr.Name
        }),
        Distance = Module.Draw('Text',{
            Visible = false,
            Color = Color3.new(1, 1, 1),
            Size = 15,
            Center = true,
            Outline = true,
            OutlineColor = Color3.new(0, 0, 0),
            Text = ""
        }),
        Line = Module.Draw("Line", {
            Visible = false,
            Thickness = 1,
            Color = Color3.fromRGB(255, 255, 255)
        })
    }
end)

Connect(Players.PlayerRemoving, function(v)
    if AllPlayersDrawings[v] then
        for _, drawing in next, AllPlayersDrawings[v] do
            if drawing.Remove then
                drawing:Remove()
                task.wait()
            end
        end
        AllPlayersDrawings[v] = nil
    end
end)

Connect(RunService.RenderStepped, function()
    local FovPos = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
    Circle.Visible = Env.Aimbot or false
    Circle.Position = FovPos
    Circle.Radius = Env.FovRadius or 200
    TrackAimbot.Visible = false

    local Closest, ClosestDist = nil, math.huge

    for _, v in next, Players:GetPlayers() do
        if v ~= Client and Module.IsAlive(v.Character) then
            local Char = v.Character
            local Root = Char:FindFirstChild("HumanoidRootPart")
            if Root then
                local ScreenPos, OnScreen = Module.WorldToScreen(Root)
                if OnScreen then
                    local dist = Module.GetDistance(Vector2.new(ScreenPos.X, ScreenPos.Y), FovPos)
                    if dist <= Circle.Radius and dist < ClosestDist then
                        Closest, ClosestDist = Char, dist
                    end
                end
            end
        end
    end

    TargetAim = Closest

    if Closest then 
        local Head = Closest:FindFirstChild("Head")

        if Head then
            local Pos, On = Module.WorldToScreen(Head)
            TrackAimbot.Visible = Env.Aimbot and On or false 
            TrackAimbot.From = FovPos
            TrackAimbot.To = Vector2.new(Pos.X, Pos.Y)
        end
    end 

    for i,v in pairs(AllPlayersDrawings) do 
        local Char = i.Character
        if Char and Module.IsAlive(Char) then
            local Root = Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char:FindFirstChild("Humanoid")
            local Head = Char:FindFirstChild("Head")
            if Root and Head then
                local RootPos, OnScreen = Module.WorldToScreen(Root)
                if OnScreen then
                    local HeadPos = Module.WorldToScreen(Head.Position + Vector3.new(0, 0.5, 0))
                    local LegPos  = Module.WorldToScreen(Root.Position - Vector3.new(0, 3, 0))
                    local Hp    = Hum.Health / Hum.MaxHealth
                    local BSize = Vector2.new(1000 / RootPos.Z, HeadPos.Y - LegPos.Y)
                    local BPos  = Vector2.new(RootPos.X - BSize.X / 2, RootPos.Y - BSize.Y / 2)

                    v.Box.Visible  = Env.Box or false
                    v.Box.Size     = BSize
                    v.Box.Position = BPos

                    v.HpBar.From    = Vector2.new(BPos.X + BSize.X + 3, BPos.Y + BSize.Y * (1 - Hp))
                    v.HpBar.To      = Vector2.new(BPos.X + BSize.X + 3, BPos.Y + BSize.Y)
                    v.HpBar.Color   = Color3.new(1 - Hp, Hp, 0)
                    v.HpBar.Visible = Env.HpBar or false

                    v.Name.Position = Vector2.new(HeadPos.X, HeadPos.Y - 20)
                    v.Name.Visible  = Env.Name or false

                    v.Distance.Position = Vector2.new(HeadPos.X, LegPos.Y + 5)
                    v.Distance.Text     = "(" .. math.floor(Module.GetDistance(RootPart, Char)) .. ")"
                    v.Distance.Visible  = Env.Distance or false
                else
                    for _, d in next, v do d.Visible = false end
                end
            end
        else
            for _, d in next, v do d.Visible = false end
        end
    end
end)

function Func.StartFarm()
    while task.wait(0.55) do 
        xpcall(function()
            if not Env.StartFarm then Module.StopMove() return end 

            if Env.SelectJob == "ส่งของ" then
                if Client.Team.Name ~= "พนักงานขนส่ง" then
                    JobManager.RequestStartJob.Invoke("Delivery")
                else 
                    if DataInteraction then
                        if DataInteraction.Text == 'รับพัสดุ' then 
                            if not PlayerGui:FindFirstChild('Frame') then
                                if Module.GetDistance(RootPart, JobInteraction.Delivery.RackTrigger) > 5 then 
                                    Module.MoveTo(JobInteraction.Delivery.RackTrigger.Position)
                                else 
                                    fireproximityprompt(JobInteraction.Delivery.RackTrigger.ProximityPrompt)
                                end
                            else 
                                local Ok, Result = StepProofCodec.Decode(DataInteraction.Payload)
                                if not Ok then return end

                                local Token = Result.Token
                                local Total = Result.Total

                                local Chain = JobManager.SubmitInteraction.Invoke({
                                    SessionNonce = DataInteraction.SessionNonce,
                                    InteractionId = DataInteraction.InteractionId,
                                    Phase = {
                                        Kind = "Custom",
                                        Payload = Module.EncodeStep(Token, 0, Total)
                                    }
                                })

                                for _ = 2, Total do
                                    Chain = Chain:andThen(function(res)

                                        if res and res.Kind == "Accepted" and res.Payload then
                                            local Ok2, Result2 = StepProofCodec.Decode(res.Payload)
                                            if Ok2 and Result2 then Token = Result2.Token end
                                        end

                                        task.wait(0.25)

                                        return JobManager.SubmitInteraction.Invoke({
                                            SessionNonce = DataInteraction.SessionNonce,
                                            InteractionId = DataInteraction.InteractionId,
                                            Phase = {
                                                Kind = "Custom",
                                                Payload = Module.EncodeStep(Token, 0, Total)
                                            }
                                        })
                                    end)
                                end
                            end 
                        elseif DataInteraction.Text == 'ซื้อกล่องพัสดุ' or DataInteraction.Text == "ส่งพัสดุ" then
                            for _,v in pairs(V2JobRuntime:GetChildren()) do 
                                if not string.find(v.Name, tostring(Client.UserId)) then continue end 

                                if Module.GetDistance(RootPart, v) > 5 then 
                                    Module.MoveTo(v:GetPivot().Position)
                                else 
                                    JobManager.SubmitInteraction.Invoke({
                                        SessionNonce = DataInteraction.SessionNonce,
                                        InteractionId = DataInteraction.InteractionId,
                                        Phase = {
                                            Kind = "HoldBegin"
                                        }
                                    })
                                    task.wait(DataInteraction.HoldDuration)
                                    JobManager.SubmitInteraction.Invoke({
                                        SessionNonce = DataInteraction.SessionNonce,
                                        InteractionId = DataInteraction.InteractionId,
                                        Phase = {
                                            Kind = "HoldEnd"
                                        }
                                    })
                                end
                            end
                        end
                    end
                end
            elseif Env.SelectJob == "เซเว่น" then 
                if Client.Team.Name ~= "พนักงานเซเว่น" then
                    JobManager.RequestStartJob.Invoke("SevenEleven")
                else 
                    if DataInteraction then
                        for _,v in pairs(V2JobRuntime:GetChildren()) do 
                            if not string.find(v.Name, tostring(Client.UserId)) then continue end 

                            for _,jp in pairs(v:GetChildren()) do 
                                if tostring(jp.Name) ~= tostring(DataInteraction.InteractionId) then continue end
                                
                                local Prompt = jp:FindFirstChild('ProximityPrompt')
                                if not Prompt then continue end

                                local StartTime = os.clock()

                                if Module.GetDistance(RootPart, jp) > 12 then 
                                    Module.MoveTo(jp:GetPivot().Position + Vector3.new(0, -5, 0))
                                end 

                                repeat task.wait() until Module.GetDistance(RootPart, jp) <= 12 or (os.clock() - StartTime) >= 10 or not Env.StartFarm
                                
                                if (os.clock() - StartTime) >= 10 then
                                    continue
                                end

                                if not PlayerGui:FindFirstChild('Frame') then 
                                    fireproximityprompt(Prompt)
                                end

                                local Ok, Result = StepProofCodec.Decode(DataInteraction.Payload)
                                if not Ok then continue end

                                local Token = Result.Token
                                local Total = Result.Total

                                local Chain = JobManager.SubmitInteraction.Invoke({
                                    SessionNonce = DataInteraction.SessionNonce,
                                    InteractionId = DataInteraction.InteractionId,
                                    Phase = {
                                        Kind = "Custom",
                                        Payload = Module.EncodeStep(Token, 0, Total)
                                    }
                                })

                                for _ = 2, Total do
                                    Chain = Chain:andThen(function(res)

                                        if res and res.Kind == "Accepted" and res.Payload then
                                            local Ok2, Result2 = StepProofCodec.Decode(res.Payload)
                                            if Ok2 and Result2 then Token = Result2.Token end
                                        end

                                        task.wait(0.1)

                                        return JobManager.SubmitInteraction.Invoke({
                                            SessionNonce = DataInteraction.SessionNonce,
                                            InteractionId = DataInteraction.InteractionId,
                                            Phase = {
                                                Kind = "Custom",
                                                Payload = Module.EncodeStep(Token, 0, Total)
                                            }
                                        })
                                    end)
                                end
                            end
                        end
                    end
                end
            elseif Env.SelectJob == "ก่อสร้าง" then
                if Client.Team.Name ~= "คนงานก่อสร้าง" then
                    JobManager.RequestStartJob.Invoke("ConstructionWorker")
                else 
                    if DataInteraction then
                        for _,v in pairs(V2JobRuntime:GetChildren()) do 
                            if not string.find(v.Name, tostring(Client.UserId)) then continue end 

                            for _,jp in pairs(v:GetChildren()) do 
                                if tostring(jp.Name) ~= tostring(DataInteraction.InteractionId) then continue end
                                
                                local Prompt = jp:FindFirstChild('ProximityPrompt')
                                if not Prompt then continue end

                                local StartTime = os.clock()

                                if Module.GetDistance(RootPart, jp) > 12 then 
                                    Module.MoveTo(jp:GetPivot().Position + Vector3.new(0, -5, 0))
                                end 

                                repeat task.wait() until Module.GetDistance(RootPart, jp) <= 12 or (os.clock() - StartTime) >= 10 or not Env.StartFarm
                                
                                if (os.clock() - StartTime) >= 10 then
                                    continue
                                end

                                if not PlayerGui:FindFirstChild('Frame') then 
                                    fireproximityprompt(Prompt)
                                end

                                local Ok, Result = StepProofCodec.Decode(DataInteraction.Payload)
                                if not Ok then continue end

                                local Token = Result.Token
                                local Total = Result.Total

                                local Chain = JobManager.SubmitInteraction.Invoke({
                                    SessionNonce = DataInteraction.SessionNonce,
                                    InteractionId = DataInteraction.InteractionId,
                                    Phase = {
                                        Kind = "Custom",
                                        Payload = Module.EncodeStep(Token, 0, Total)
                                    }
                                })

                                for _ = 2, Total do
                                    Chain = Chain:andThen(function(res)

                                        if res and res.Kind == "Accepted" and res.Payload then
                                            local Ok2, Result2 = StepProofCodec.Decode(res.Payload)
                                            if Ok2 and Result2 then Token = Result2.Token end
                                        end

                                        task.wait(0.25)

                                        return JobManager.SubmitInteraction.Invoke({
                                            SessionNonce = DataInteraction.SessionNonce,
                                            InteractionId = DataInteraction.InteractionId,
                                            Phase = {
                                                Kind = "Custom",
                                                Payload = Module.EncodeStep(Token, 0, Total)
                                            }
                                        })
                                    end)
                                end
                            end
                        end
                    end
                end
            elseif Env.SelectJob == "ตัดกล้วย" then
                if Client.Team.Name ~= "คนตัดกล้วย" then
                    JobManager.RequestStartJob.Invoke("BananaCutter")
                else 
                    if DataInteraction then
                        if not Character:FindFirstChild('Axe') then 
                            Humanoid:EquipTool(Backpack:FindFirstChild('Axe'))
                        else 
                            for _,v in pairs(V2JobRuntime:GetChildren()) do 
                                if not string.find(v.Name, tostring(Client.UserId)) then continue end 

                                for _,jp in pairs(v:GetChildren()) do 
                                    if tostring(jp.Name) ~= tostring(DataInteraction.InteractionId) then continue end
                                    
                                    local StartTime = os.clock()

                                    if Module.GetDistance(RootPart, jp) > 7 then 
                                        Module.MoveTo(jp:GetPivot().Position)
                                    end 

                                    repeat task.wait() until Module.GetDistance(RootPart, jp) <= 7 or (os.clock() - StartTime) >= 10 or not Env.StartFarm
                                    
                                    if (os.clock() - StartTime) >= 10 then
                                        continue
                                    end

                                    repeat 
                                        JobManager.SubmitInteraction.Invoke({
                                            SessionNonce = DataInteraction.SessionNonce,
                                            InteractionId = DataInteraction.InteractionId,
                                            Phase = {
                                                Kind = "Tap",
                                            }
                                        })
                                        task.wait(0.15)
                                    until jp:GetAttribute('JobHealth') <= 0 or (os.clock() - StartTime) >= 40 or not Env.StartFarm
                                end
                            end
                        end
                    end
                end
            end
        end, warn)
    end
end

local Config_Manager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Yenixs/ToolScript/refs/heads/main/ConfigManager.luau"))()('BuildAZoo',Env)
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

Config_Manager.SC()

local Window = WindUI:CreateWindow({
    Title = "Maru HeeKuyTed Thaiban",
    Icon = "github",
    Author = "By.NinoKuy49",
    Folder = "Maru",
    Size = UDim2.fromOffset(400, 400),
    Theme = "Dark",
    Transparent = true,
    Resizable = true,
    OpenButton = {
        Title = "Maru HeeKuyTed",
        CornerRadius = UDim.new(1,0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Color = ColorSequence.new(Color3.fromRGB(50, 168, 131),Color3.fromRGB(50, 168, 131))
    },
})

local Tabs = {
    Pvp = Window:Tab({Title = "Pvp", Icon = "swords"}),
    Farm = Window:Tab({Title = "Farm", Icon = "tractor"}),
    Visual = Window:Tab({Title = "Visual", Icon = "eye"})
}

Tabs.Pvp:Select()

local function AddSection(Tab,Text)
    local Section = Tab:Section({ 
        Title = Text,
        Box = false,
        TextSize = 17,
        Opened = true,
    })
    return Section
end

local function AddToggle(Tab,Title,Description,Keys,Callback)
    local taskThread
    local toggle = Tab:Toggle({
        Title = Title,
        Desc = Description,
        Value = Env[Keys] or false,
        Callback = function(state)
            Config_Manager.S()[Keys] = state
            Env[Keys] = state
            if Callback and typeof(Callback) == "function" then
                Callback(state)
            end
            if not state then 
                if taskThread then
                    task.cancel(taskThread)
                    taskThread = nil
                end
            end

            if state then 
                if Func[Keys] then
                    taskThread = task.spawn(Func[Keys])
                end
            end
            Config_Manager.SG()
        end
    })
    if toggle then toggle.Callback(Env[Keys]) end
    return toggle 
end

local function AddSlider(Tab,Title,Steps,Mins,Maxs,Def,Keys)
    local slider = Tab:Slider({
        Flag = Title,
        Title = Title,
        Step = Steps,
        Value = {
            Min = Mins,
            Max = Maxs,
            Default = Env[Keys] or Def,
        },
        Callback = function(value)
            Config_Manager.S()[Keys] = value 
            Env[Keys] = value 
            Config_Manager.SG()
        end
    })
    if slider then slider.Callback(Env[Keys] or Def) end
    return slider
end

local function AddInput(Tab, Title, Keys)
    local input = Tab:Input({
        Title = Title,
        Type = "Input",
        Placeholder = "Enter here...",
        Callback = function(value)
            Config_Manager.S()[Keys] = value
            Env[Keys] = value
            Config_Manager.SG()
        end
    })
    return input
end

local function AddDropdown(Tab, Title, Keys, Values, Multi, AllowNone)
    local dropdown = Tab:Dropdown({
        Title = Title,
        Values = Values or {"Back"},
        Multi = Multi or false,
        AllowNone = AllowNone or false, 
        Value = Env[Keys] or Values[1], 
        Callback = function(option)
            Config_Manager.S()[Keys] = option
            Env[Keys] = option
            Config_Manager.SG()
        end
    })
    if dropdown and dropdown.Callback then
        dropdown.Callback(Env[Keys] or (Multi and {} or Values[1]))
    end
    return dropdown
end

local function AddButton(Tab, Title, Desc, Callback)
    local button = Tab:Button({
        Title = Title,
        Desc = Desc,
        Locked = false,
        Callback = Callback or function() end
    })

    return button
end

do 
    do
        local Automation = AddSection(Tabs.Pvp, "Automation")

        AddToggle(Automation, "Aimbot", nil, "Aimbot")
        AddSlider(Automation, "Fov Radius", 1, 200, 800, 200, "FovRadius")
        AddDropdown(Automation, "Select Part", "SelectPart", {"Head", "HumanoidRootPart"}, false)
    end

    do 
        local Farm = AddSection(Tabs.Farm, "Auto Farm")

        AddDropdown(Farm, "Select Job", "SelectJob", {"ส่งของ", "เซเว่น", "ก่อสร้าง", "ตัดกล้วย"}, false)
        AddToggle(Farm, "Start Farm", nil, "StartFarm")
    end

    do 
        local Visual = AddSection(Tabs.Visual, "Visual")
        
        AddToggle(Visual, "Box", nil, "Box")
        AddToggle(Visual, "Hp Bar", nil, "HpBar")
        AddToggle(Visual, "Name", nil, "Name")
        AddToggle(Visual, "Distance", nil, "Distance")
    end
end

player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    print("[Anti-AFK] Idle detected - activity simulated")
end)

print("[Anti-AFK] Script loaded successfully")
