-- Cleaned Chicago Client Script: Only Aimbot, ESP, and Misc Tabs Retained

----------------------------------------------------------
-- Rayfield Setup & Window/Tabs
----------------------------------------------------------
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "⭐Chicago Client ⭐",
   Icon = 0,
   LoadingTitle = "Chicago Hub",
   LoadingSubtitle = "by Kingrunzy",
   Theme = "DarkBlue",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Not Functional"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "⭐Chicago Client| Key system⭐",
      Subtitle = "Key System",
      Note = "Join Discord Server https://discord.gg/j444ECwP",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = true,
      Key = {"ChicagoDaily"}
   }
})

Rayfield:Notify({
   Title = "Shut the fuck up nigga",
   Content = "Enjoy the cheat",
   Duration = 8,
   Image = nil,
})

local MainTab = Window:CreateTab("Aimbot", nil)
local SecondTab = Window:CreateTab("ESP", nil)
local ThirdTab = Window:CreateTab("Misc", nil)
----------------------------------------------------------
-- Aimbot & FOV Integration (MainTab)
----------------------------------------------------------
----------------------------------------------------------
-- Aimbot & FOV Integration (MainTab)
----------------------------------------------------------
--// CONFIGURABLE SETTINGS
local aimbotEnabled = false
local silentAimEnabled = false
local rainbowFOVEnabled = false
local fov = 90
local smoothing = 1
local predictionFactor = 0
local hitboxSize = 1
local FOVColor = Color3.fromRGB(255, 128, 128)
local aimPart = "Head"
local aimbotToggledWithKey = false
local AimPartOptions = {"Head", "Torso", "Chest", "HumanoidRootPart"}

--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// GUI SETUP
MainTab:CreateDropdown({
   Name = "Aim Part",
   Options = AimPartOptions,
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Callback = function(options)
      aimPart = options[1]
   end,
})

MainTab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = aimbotEnabled,
   Callback = function(Value)
      aimbotEnabled = Value
      aimbotToggledWithKey = Value -- sync toggle when changed from GUI
   end,
})
MainTab:CreateToggle({
   Name = "Rainbow FOV",
   CurrentValue = rainbowFOVEnabled,
   Callback = function(Value)
      rainbowFOVEnabled = Value
   end,
})

MainTab:CreateSlider({
   Name = "FOV",
   Range = {0, 1000},
   Increment = 10,
   CurrentValue = fov,
   Callback = function(Value)
      fov = Value
   end,
})

MainTab:CreateSlider({
   Name = "Hitbox Size",
   Range = {1, 20},
   Increment = 0.1,
   CurrentValue = hitboxSize,
   Callback = function(Value)
      hitboxSize = Value
   end,
})

MainTab:CreateColorPicker({
   Name = "FOV Color",
   Color = FOVColor,
   Callback = function(color)
      FOVColor = color
   end,
})

--// E KEY TOGGLE
UserInputService.InputBegan:Connect(function(input, gameProcessed)
   if gameProcessed then return end
   if input.KeyCode == Enum.KeyCode.E then
      aimbotToggledWithKey = not aimbotToggledWithKey
      aimbotEnabled = aimbotToggledWithKey -- sync aimbot enabled to toggle
      print("Aimbot toggled via E key:", aimbotEnabled)
   end
end)

--// FOV CIRCLE
local FOVring = Drawing.new("Circle")
FOVring.Thickness = 1
FOVring.NumSides = 100
FOVring.Transparency = 0.8
FOVring.Filled = false
FOVring.Radius = fov
FOVring.Color = FOVColor
FOVring.Visible = true

--// UTILS
local function updateHitboxSizes()
   for _, plr in ipairs(Players:GetPlayers()) do
      if plr ~= LocalPlayer and plr.Character then
         local part = plr.Character:FindFirstChild(aimPart)
         if part then
            part.Size = Vector3.new(1, 1, 1) * hitboxSize
            part.CanCollide = false
         end
      end
   end
end

local function getClosestTarget()
   local closest = nil
   local shortestDistance = math.huge
   local mousePos = UserInputService:GetMouseLocation()

   for _, plr in ipairs(Players:GetPlayers()) do
      if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(aimPart) then
         local part = plr.Character[aimPart]
         local partPos = part.Position
         local screenPoint, onScreen = Camera:WorldToViewportPoint(partPos)
         if onScreen then
            local distFromMouse = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
            if distFromMouse <= fov and distFromMouse < shortestDistance then
               shortestDistance = distFromMouse
               closest = plr
            end
         end
      end
   end

   return closest
end

local function predictPosition(target)
   if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
      local hrp = target.Character.HumanoidRootPart
      local velocity = hrp.Velocity
      return target.Character[aimPart].Position + (velocity * predictionFactor)
   end
   return nil
end

--// MAIN AIM LOOP
local currentTarget = nil

RunService.RenderStepped:Connect(function()
   FOVring.Position = UserInputService:GetMouseLocation()
   FOVring.Radius = fov
   FOVring.Color = rainbowFOVEnabled and Color3.fromHSV(tick() % 5 / 5, 1, 1) or FOVColor
   updateHitboxSizes()

   if aimbotEnabled and aimbotToggledWithKey then
      currentTarget = getClosestTarget()
      if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild(aimPart) then
         local predictedPos = predictPosition(currentTarget)
         if predictedPos then
            local newCF = CFrame.new(Camera.CFrame.Position, predictedPos)
            Camera.CFrame = Camera.CFrame:Lerp(newCF, smoothing)
         end
      end
   else
      currentTarget = nil
   end
end)

--// SILENT AIM HOOK
pcall(function()
   local mt = getrawmetatable(game)
   local old = mt.__namecall
   setreadonly(mt, false)
   mt.__namecall = newcclosure(function(self, ...)
      local args = {...}
      local method = getnamecallmethod()
      if silentAimEnabled and tostring(self):lower():find("fire") and method == "FireServer" then
         if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild(aimPart) then
            args[1] = currentTarget.Character[aimPart].Position
         end
      end
      return old(self, unpack(args))
   end)
end)

----------------------------------------------------------
-- ESP Integration (Full Box ESP with Names & Health) (SecondTab)
----------------------------------------------------------
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- State
local ESPEnabled, NamesEnabled, HealthEnabled, ChamsEnabled, RainbowChams = false, false, false, false, false
local skeletonESPEnabled = false

-- Colors
local BoxESPColor = Color3.fromRGB(255, 0, 0)
local NameESPColor = Color3.fromRGB(255, 255, 255)
local SkeletonColor = Color3.fromRGB(0, 255, 0)
local ChamsColor = Color3.fromRGB(0, 255, 255)

-- Storage
local ESPObjects = {}

-- UI Toggles
SecondTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "ESP_Toggle",
    Callback = function(v)
        ESPEnabled = v
        for _, obj in pairs(ESPObjects) do
            if obj.Lines then
                for _, line in pairs(obj.Lines) do
                    line.Visible = v
                end
            end
        end
    end,
})

SecondTab:CreateToggle({
    Name = "Names",
    CurrentValue = false,
    Flag = "ESP_Names",
    Callback = function(v)
        NamesEnabled = v
        for _, obj in pairs(ESPObjects) do
            if obj.Name then
                obj.Name.Visible = v
            end
        end
    end,
})

SecondTab:CreateToggle({
    Name = "Health Bar",
    CurrentValue = false,
    Flag = "ESP_Health",
    Callback = function(v)
        HealthEnabled = v
        for _, obj in pairs(ESPObjects) do
            if obj.Health then
                obj.Health.Visible = v
            end
            if obj.HealthText then
                obj.HealthText.Visible = v
            end
        end
    end,
})

SecondTab:CreateToggle({
    Name = "Chams",
    CurrentValue = false,
    Flag = "ESP_Chams",
    Callback = function(v)
        ChamsEnabled = v
        for _, obj in pairs(ESPObjects) do
            if obj.Chams then
                obj.Chams.Visible = v
                obj.Chams.Color3 = ChamsColor
            end
        end
    end,
})

SecondTab:CreateToggle({
    Name = "Rainbow Chams",
    CurrentValue = false,
    Flag = "Rainbow_Chams",
    Callback = function(v)
        RainbowChams = v
    end,
})

SecondTab:CreateToggle({
    Name = "Skeleton ESP",
    CurrentValue = false,
    Flag = "Skeleton_ESP",
    Callback = function(v)
        skeletonESPEnabled = v
        for _, obj in pairs(ESPObjects) do
            if obj.Skeleton then
                for _, line in pairs(obj.Skeleton.Lines) do
                    line.Visible = v
                end
            end
        end
    end,
})

-- Color Pickers
SecondTab:CreateColorPicker({
    Name = "Box ESP Color",
    Color = BoxESPColor,
    Callback = function(color) BoxESPColor = color end,
})

SecondTab:CreateColorPicker({
    Name = "Name ESP Color",
    Color = NameESPColor,
    Callback = function(color) NameESPColor = color end,
})

SecondTab:CreateColorPicker({
    Name = "Skeleton Color",
    Color = SkeletonColor,
    Callback = function(color)
        SkeletonColor = color
        for _, obj in pairs(ESPObjects) do
            if obj.Skeleton then
                for _, line in pairs(obj.Skeleton.Lines) do
                    line.Color = color
                end
            end
        end
    end,
})

SecondTab:CreateColorPicker({
    Name = "Chams Color",
    Flag = "Chams_Color",
    Color = ChamsColor,
    Callback = function(color)
        ChamsColor = color
    end,
})

-- Drawing helpers
local function NewLine()
    local line = Drawing.new("Line")
    line.Color = BoxESPColor
    line.Thickness = 2
    line.Visible = false
    return line
end

local function NewText(size)
    local txt = Drawing.new("Text")
    txt.Size = size
    txt.Center = true
    txt.Outline = true
    txt.OutlineColor = Color3.fromRGB(0, 0, 0)
    txt.Color = NameESPColor
    txt.Visible = false
    return txt
end

local function NewBox(color)
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(2, 5, 1)
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Adornee = nil
    box.Color3 = color
    box.Transparency = 0.5
    box.Parent = workspace.CurrentCamera
    return box
end

local function drawSkeleton(plr)
    local function createLine()
        local line = Drawing.new("Line")
        line.Color = SkeletonColor
        line.Thickness = 2
        line.Visible = false
        return line
    end

    local skeletonLines = {
        HeadToTorso = createLine(),
        TorsoToLeftArm = createLine(),
        TorsoToRightArm = createLine(),
        TorsoToLeftLeg = createLine(),
        TorsoToRightLeg = createLine()
    }

    local con = RunService.RenderStepped:Connect(function()
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        local function getPos(partName)
            local part = char:FindFirstChild(partName)
            if not part then return nil, false end
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            return Vector2.new(pos.X, pos.Y), onScreen and pos.Z > 0
        end

        local headPos, hOn = getPos("Head")
        local torsoPos, tOn = getPos("HumanoidRootPart")
        local lArmPos, lAOn = getPos("LeftUpperArm")
        local rArmPos, rAOn = getPos("RightUpperArm")
        local lLegPos, lLOn = getPos("LeftUpperLeg")
        local rLegPos, rLOn = getPos("RightUpperLeg")

        local function connect(line, fromPos, toPos, fromOn, toOn)
            if fromOn and toOn and skeletonESPEnabled then
                line.From = fromPos
                line.To = toPos
                line.Visible = true
            else
                line.Visible = false
            end
        end

        connect(skeletonLines.HeadToTorso, headPos, torsoPos, hOn, tOn)
        connect(skeletonLines.TorsoToLeftArm, torsoPos, lArmPos, tOn, lAOn)
        connect(skeletonLines.TorsoToRightArm, torsoPos, rArmPos, tOn, rAOn)
        connect(skeletonLines.TorsoToLeftLeg, torsoPos, lLegPos, tOn, lLOn)
        connect(skeletonLines.TorsoToRightLeg, torsoPos, rLegPos, tOn, rLOn)
    end)

    ESPObjects[plr] = ESPObjects[plr] or {}
    ESPObjects[plr].Skeleton = {
        Lines = skeletonLines,
        Connection = con
    }
end

local function DrawESP(plr)
    local function setupESP()
        local character = plr.Character
        if not character then return end

        local head = character:WaitForChild("Head")
        local hrp = character:WaitForChild("HumanoidRootPart")
        local hum = character:WaitForChild("Humanoid")

        local top = NewLine()
        local bottom = NewLine()
        local left = NewLine()
        local right = NewLine()

        local nameText = NewText(18)
        local healthText = NewText(16)

        local healthBar = Drawing.new("Line")
        healthBar.Color = Color3.fromRGB(0, 255, 0)
        healthBar.Thickness = 3
        healthBar.Visible = false

        local chams = nil
        if ChamsEnabled then
            chams = NewBox(ChamsColor)
            chams.Adornee = character
        end

        local con = RunService.RenderStepped:Connect(function()
            if not character or not character:FindFirstChild("HumanoidRootPart") or hum.Health <= 0 then
                top.Visible = false
                bottom.Visible = false
                left.Visible = false
                right.Visible = false
                nameText.Visible = false
                healthBar.Visible = false
                healthText.Visible = false
                if chams then chams.Visible = false end
                return
            end

            if RainbowChams and chams then
                local tickColor = tick() * 100 % 255
                chams.Color3 = Color3.fromHSV(tickColor / 255, 1, 1)
                chams.Visible = true
            elseif chams then
                chams.Color3 = ChamsColor
                chams.Visible = ChamsEnabled
            end

            local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
            local hrpPos, hrpOnScreen = Camera:WorldToViewportPoint(hrp.Position)

            if headOnScreen and hrpOnScreen then
                local height = math.abs(hrpPos.Y - headPos.Y)
                local width = height / 2
                local x = headPos.X - width / 2
                local y = headPos.Y

                top.From = Vector2.new(x, y)
                top.To = Vector2.new(x + width, y)
                top.Visible = ESPEnabled

                bottom.From = Vector2.new(x, y + height)
                bottom.To = Vector2.new(x + width, y + height)
                bottom.Visible = ESPEnabled

                left.From = Vector2.new(x, y)
                left.To = Vector2.new(x, y + height)
                left.Visible = ESPEnabled

                right.From = Vector2.new(x + width, y)
                right.To = Vector2.new(x + width, y + height)
                right.Visible = ESPEnabled

                nameText.Text = plr.Name
                nameText.Position = Vector2.new(x + width/2, y - 20)
                nameText.Visible = NamesEnabled

                if HealthEnabled then
                    local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    local barHeight = height * healthPercent
                    healthBar.From = Vector2.new(x - 6, y + height)
                    healthBar.To = Vector2.new(x - 6, y + height - barHeight)
                    healthBar.Visible = true

                    healthText.Text = string.format("%d / %d", math.floor(hum.Health), hum.MaxHealth)
                    healthText.Position = Vector2.new(x + width / 2, y - 35)
                    healthText.Visible = true
                else
                    healthBar.Visible = false
                    healthText.Visible = false
                end
            else
                top.Visible, bottom.Visible, left.Visible, right.Visible = false, false, false, false
                nameText.Visible = false
                healthBar.Visible = false
                healthText.Visible = false
                if chams then chams.Visible = false end
            end
        end)

        ESPObjects[plr] = {
            Lines = {top, bottom, left, right},
            Name = nameText,
            Health = healthBar,
            HealthText = healthText,
            Chams = chams,
            Connection = con
        }

        drawSkeleton(plr)
    end

    if plr.Character then
        setupESP()
    end

    plr.CharacterAdded:Connect(function()
        RemoveESP(plr)
        task.wait(0.1)
        setupESP()
    end)
end

-- Cleanup
local function RemoveESP(plr)
    local obj = ESPObjects[plr]
    if obj then
        for _, part in pairs(obj.Lines or {}) do part:Remove() end
        if obj.Name then obj.Name:Remove() end
        if obj.Health then obj.Health:Remove() end
        if obj.HealthText then obj.HealthText:Remove() end
        if obj.Chams then obj.Chams:Destroy() end
        if obj.Connection then obj.Connection:Disconnect() end
        if obj.Skeleton then
            for _, line in pairs(obj.Skeleton.Lines) do line:Remove() end
            if obj.Skeleton.Connection then obj.Skeleton.Connection:Disconnect() end
        end
        ESPObjects[plr] = nil
    end
end

-- Apply ESP to all players
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        coroutine.wrap(DrawESP)(plr)
    end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        coroutine.wrap(DrawESP)(plr)
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)


-----------------------------------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local noclipEnabled = false
local infiniteJumpEnabled = false
local clickTPEnabled = false
local flySpeed = 50

-- Fly Status Display
local flyStatusText = Drawing.new("Text")
flyStatusText.Size = 18
flyStatusText.Position = Vector2.new(20, 100)
flyStatusText.Color = Color3.fromRGB(0, 255, 255)
flyStatusText.Outline = true
flyStatusText.Visible = false
flyStatusText.Center = false
flyStatusText.Text = "Fly: OFF"


----------------------------------------------------------
-- Noclip
----------------------------------------------------------
ThirdTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "Misc_Noclip",
   Callback = function(Value)
      noclipEnabled = Value
   end,
})

RunService.Stepped:Connect(function()
   if noclipEnabled and LocalPlayer.Character then
      for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
         if part:IsA("BasePart") then
            part.CanCollide = false
         end
      end
   end
end)

----------------------------------------------------------
-- Infinite Jump / Fly
----------------------------------------------------------
ThirdTab:CreateToggle({
   Name = "Infinite Jump / Fly",
   CurrentValue = false,
   Flag = "Misc_InfiniteJump",
   Callback = function(Value)
      infiniteJumpEnabled = Value
   end,
})

ThirdTab:CreateSlider({
   Name = "Fly/Jump Height",
   Range = {10, 300},
   Increment = 5,
   Suffix = " units",
   CurrentValue = flySpeed,
   Flag = "FlyHeight_Slider",
   Callback = function(Value)
      flySpeed = Value
   end,
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
   if gameProcessed then return end
   if infiniteJumpEnabled and input.KeyCode == Enum.KeyCode.Space then
      local character = LocalPlayer.Character
      if character and character:FindFirstChild("HumanoidRootPart") then
         character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, flySpeed, 0)
      end
   end
end)

----------------------------------------------------------
-- Click TP
----------------------------------------------------------
ThirdTab:CreateToggle({
   Name = "Click TP",
   CurrentValue = false,
   Flag = "Misc_ClickTP",
   Callback = function(Value)
      clickTPEnabled = Value
   end,
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
   if gameProcessed then return end
   if clickTPEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
      local mousePos = input.Position
      local camera = workspace.CurrentCamera
      local ray = camera:ScreenPointToRay(mousePos.X, mousePos.Y)
      local raycastParams = RaycastParams.new()
      raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
      raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
      local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
      if raycastResult and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
      end
   end
end)

----------------------------------------------------------
-- Duplicate Item
----------------------------------------------------------
local function duplicateItem()
   local item
   local player = Players.LocalPlayer

   local function findTool(container)
      for _, child in pairs(container:GetChildren()) do
         if child:IsA("Tool") or child:IsA("Model") then
            return child
         elseif string.lower(child.Name):find("gun") then
            return child
         end
      end
   end

   item = findTool(player.Character or player.Backpack)

   if item then
      local clone = item:Clone()
      clone.Parent = player.Backpack
      print("Duplicated item:", clone.Name)
   else
      print("No item found to duplicate.")
   end
end

ThirdTab:CreateButton({
   Name = "Duplicate Item",
   Callback = function()
      duplicateItem()
   end,
})

----------------------------------------------------------
-- Daylight Forever
----------------------------------------------------------
local fixedTime = 12
local daylightConnection
local daylightPropertyConnection

ThirdTab:CreateToggle({
   Name = "Daylight",
   CurrentValue = false,
   Flag = "Misc_Daylight",
   Callback = function(Value)
      if Value then
         Lighting.ClockTime = fixedTime
         daylightPropertyConnection = Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
            Lighting.ClockTime = fixedTime
         end)
         daylightConnection = RunService.Stepped:Connect(function()
            Lighting.ClockTime = fixedTime
         end)
         Lighting.Brightness = 2
         Lighting.Ambient = Color3.fromRGB(255, 255, 255)
         Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
      else
         if daylightPropertyConnection then
            daylightPropertyConnection:Disconnect()
            daylightPropertyConnection = nil
         end
         if daylightConnection then
            daylightConnection:Disconnect()
            daylightConnection = nil
         end
      end
   end,
})

-- Location tables
local locations = {
    ["Noodles"] = Vector3.new(1108, 7, 265),
    ["Gas station"] = Vector3.new(879, 7, 280),
    ["Gun store"] = Vector3.new(581, 7, 1038),
    ["Dealership"] = Vector3.new(-598, 7, 153),
    ["Studio"] = Vector3.new(382, 7, 920),
    ["O'block"] = Vector3.new(-63, 7, -90),
    ["Police Station"] = Vector3.new(-742, 7, 140),
    ["Criminal Base"] = Vector3.new(-212, 7, 557),
}

local locations1 = {
    ["Junkie 1"] = Vector3.new(969, 7, 1059),
    ["Junkie 2"] = Vector3.new(791, 7, 124),
    ["Junkie 3"] = Vector3.new(-64, 7, 1064),
    ["Junkie 4"] = Vector3.new(-212, 7, 557),
    
}

local flyEnabled = false
local flyConnection = nil
local flySpeed = 2
local riseSpeed = 3
local hoverDampen = 0.98
local verticalVelocity = 0
local velocity = Vector3.zero

local antiGravityLift = 0.5

local flyStatusText = Drawing.new("Text")
flyStatusText.Size = 18
flyStatusText.Position = Vector2.new(20, 100)
flyStatusText.Color = Color3.fromRGB(0, 255, 255)
flyStatusText.Outline = true
flyStatusText.Visible = false
flyStatusText.Center = false
flyStatusText.Text = "Fly: OFF"

ThirdTab:CreateToggle({
    Name = "Fly (Floating & Movement, Anchored Fix)",
    CurrentValue = false,
    Callback = function(Value)
        flyEnabled = Value
        flyStatusText.Visible = Value
        flyStatusText.Text = Value and "Fly: ON" or "Fly: OFF"

        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")

        if Value then
            humanoid.PlatformStand = false
            hrp.Anchored = true

            local currentCFrame = hrp.CFrame

            flyConnection = RunService.RenderStepped:Connect(function(dt)
                if not flyEnabled or not hrp then return end

                local camCF = Camera.CFrame
                local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
                local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
                local moveVec = Vector3.zero

                -- Input
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVec += forward
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVec -= forward
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVec -= right
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVec += right
                end

                if moveVec.Magnitude > 0 then
                    velocity = velocity:Lerp(moveVec.Unit * flySpeed, 0.2)
                else
                    velocity *= hoverDampen
                end

                -- Vertical movement
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    verticalVelocity = verticalVelocity + riseSpeed * dt
                elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    verticalVelocity = verticalVelocity - riseSpeed * dt
                else
                    verticalVelocity = verticalVelocity * 0.9
                    verticalVelocity = verticalVelocity + (antiGravityLift * dt)
                end

                verticalVelocity = math.clamp(verticalVelocity, -5, 5)

                local movement = velocity + Vector3.new(0, verticalVelocity, 0)
                currentCFrame = currentCFrame + movement
                hrp.CFrame = currentCFrame
            end)

            humanoid.Died:Connect(function()
                flyEnabled = false
                flyStatusText.Visible = false
                if flyConnection then flyConnection:Disconnect() end
                flyConnection = nil
                hrp.Anchored = false
            end)
        else
            if flyConnection then flyConnection:Disconnect() end
            flyConnection = nil
            velocity = Vector3.zero
            verticalVelocity = 0
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.Humanoid.PlatformStand = false
                character.HumanoidRootPart.Anchored = false
            end
        end
    end,
})


ThirdTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = flySpeed,
    Callback = function(Value)
        flySpeed = Value
    end,
})



-- First Dropdown (Main locations)
ThirdTab:CreateDropdown({
    Name = "Teleport To",
    Options = {"Noodles", "Gas station", "Gun store", "Dealership", "Studio", "O'block", "Police Station", "Criminal Base"},
    CurrentOption = {"Noodles"},
    MultipleOptions = false,
    Flag = "TeleportDropdown_Main",
    Callback = function(Options)
        local selected = Options[1]
        local pos = locations[selected]
        if pos then
            local lp = game.Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            hrp.CFrame = CFrame.new(pos)
        end
    end,
})

-- Second Dropdown (Junkie teleport)
ThirdTab:CreateDropdown({
    Name = "Teleport To",
    Options = {"Junkie 1", "Junkie 2", "Junkie 3", "Junkie 4"},
    CurrentOption = {"Junkie 1"},
    MultipleOptions = false,
    Flag = "TeleportDropdown_Junkie",
    Callback = function(Options)
        local selected = Options[1]
        local pos = locations1[selected]
        if pos then
            local lp = game.Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            hrp.CFrame = CFrame.new(pos)
        end
    end
}) -- ← add this line

----------------------------------------------------------
-- STATUS DISPLAY (Top Left)
----------------------------------------------------------
local statusText = Drawing.new("Text")
statusText.Size = 18
statusText.Position = Vector2.new(20, 20)
statusText.Color = Color3.fromRGB(0, 255, 0)
statusText.Outline = true
statusText.Visible = true
statusText.Center = false

-- Update function
local function updateStatusText()
    statusText.Text = string.format("Aimbot: %s\nESP: %s\nFly: %s\nNoclip: %s\nInfiniteJump: %s",
        tostring(aimbotEnabled and "ON" or "OFF"),
        tostring(ESPEnabled and "ON" or "OFF"),
        tostring(flyEnabled and "ON" or "OFF"),
        tostring(noclipEnabled and "ON" or "OFF"),
        tostring(infiniteJumpEnabled and "ON" or "OFF")
    )
end

-- Hook into heartbeat to update regularly
RunService.Heartbeat:Connect(updateStatusText)
