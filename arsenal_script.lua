local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera
local tool = character:WaitForChild("YourWeaponName") -- Replace with your weapon's name

-- No Recoil
tool.Equipped:Connect(function()
    local originalFOV = camera.FieldOfView
    camera.FieldOfView = originalFOV
end)

-- Infinite Ammo and No Reload
tool.Equipped:Connect(function()
    tool.Ammo = math.huge
    tool.CanReload = false
    tool.Reloading = false
end)

-- Tracer Function
local function createTracer(startPos, endPos)
    local tracer = Instance.new("Part")
    tracer.Size = Vector3.new(0.1, 0.1, (startPos - endPos).Magnitude)
    tracer.Position = (startPos + endPos) / 2
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.BrickColor = BrickColor.new("Bright red")
    tracer.Material = Enum.Material.Neon
    tracer.Parent = workspace
    tracer.CFrame = CFrame.new(startPos, endPos)
    game:GetService("Debris"):AddItem(tracer, 0.1)
end

-- Aimbot (Silent Aim)
local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
            local target = otherPlayer.Character.Head
            local distance = (camera.CFrame.Position - target.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = otherPlayer
            end
        end
    end
    return closestPlayer
end

-- ESP (Highlight Players)
local function createESP(player)
    local esp = Instance.new("Highlight")
    esp.Parent = player.Character
    esp.FillTransparency = 0.5
    esp.OutlineTransparency = 0
    esp.FillColor = Color3.fromRGB(255, 0, 0) -- Red by default
    return esp
end

local espFrames = {}
for _, opponent in ipairs(game.Players:GetPlayers()) do
    if opponent ~= player then
        espFrames[opponent] = createESP(opponent)
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    local target = getClosestPlayer()
    for opponent, esp in pairs(espFrames) do
        if opponent.Character then
            esp.FillColor = opponent == target and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end
    end
end)

-- Zoom (L2 Button on Mobile or Controller)
local zoomedIn = false
local normalFOV = 70
local zoomFOV = 40

local function onInput(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonL2 then
        camera.FieldOfView = zoomedIn and normalFOV or zoomFOV
        zoomedIn = not zoomedIn
    end
end

game:GetService("UserInputService").InputBegan:Connect(onInput)

-- Shooting with Aimbot and Headshot
tool.Activated:Connect(function()
    local target = getClosestPlayer()
    if target then
        local headPos = target.Character.Head.Position
        local camPos = camera.CFrame.Position
        createTracer(camPos, headPos)
        tool:Fire()
    end
end)