-- @leadmarker

if not game:IsLoaded() then
	task.wait()
end

-- Services
local players = game:GetService('Players')
local tweenService = game:GetService('TweenService')

-- Variables
local client = players.LocalPlayer
local positions = {
	mission = Vector3.new(1, 1, 235),
	wave = Vector3.new(234, 1, -1)
}

-- Functions
local function moveto(Target, tweenSpeed)
	if typeof(Target) == "Instance" and Target:IsA("BasePart") then
		Target = Target.Position
	end
	if typeof(Target) == "CFrame" then
		Target = Target.p
	end

	local HRP = client.Character and client.Character:FindFirstChild("HumanoidRootPart")
	if not HRP then return end

	local startingPosition = HRP.Position
	local positionDelta = (Target - startingPosition)
	local startTime = tick()
	local totalDuration = (startingPosition - Target).magnitude / tweenSpeed

	repeat
		game:GetService("RunService").Heartbeat:Wait()
		local delta = tick() - startTime
		local progress = math.min(delta / totalDuration, 1)
		local mappedPosition = startingPosition + (positionDelta * progress)
		HRP.Velocity = Vector3.new()
		HRP.CFrame = CFrame.new(mappedPosition)
	until (HRP.Position - Target).magnitude <= tweenSpeed / 2000
	HRP.Anchored = false
	HRP.CFrame = CFrame.new(Target)
end

local function getTitan()
	local titan = nil
	local dist = math.huge

	for _, v in pairs(workspace.Entities.Titans:GetChildren()) do
		if v:IsA('Model') then
			local root = v:FindFirstChild('HumanoidRootPart')
			local humanoid = v:FindFirstChild('Humanoid')

			local char = client.Character
			local myRoot = char:FindFirstChild('HumanoidRootPart')

			if root and humanoid and myRoot then
				local mag = (myRoot.Position - root.Position).magnitude
				if mag < dist then
					titan = v
					dist = mag
				end
			end
		end
	end

	return titan
end

-- Disable idle detection
for _, v in pairs(getconnections(client.Idled)) do
	if v.Disable then
		v:Disable()
	else
		warn("Connection does not have a Disable method")
	end
end

while task.wait() do
	if game.PlaceId == 6372960231 then
		moveto(CFrame.new(positions[settings.mission_type]), settings.tween_speed)

		end
	else
		local target = getTitan()
		local root = target and target:FindFirstChild('HumanoidRootPart')
		local humanoid = target and target:FindFirstChild('Humanoid')

		if root and humanoid then
			moveto(CFrame.new(positions[settings.mission_type]), settings.tween_speed)
			game:GetService("ReplicatedStorage").DamageEvent:FireServer(nil, humanoid, '&@&*&@&', target)
		end
	end
end
