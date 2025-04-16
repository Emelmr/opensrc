-- @leadmarker

-- Wait for game to load safely
if not game:IsLoaded() then
	game.Loaded:Wait()
end

-- Services
local players = game:GetService('Players')
local tweenservice = game:GetService('TweenService')
local replicated = game:GetService("ReplicatedStorage")
local runservice = game:GetService("RunService")

-- Variables
local client = players.LocalPlayer 
local positions = { mission = Vector3.new(1, 1, 235), wave = Vector3.new(234, 1, -1) }

-- Settings (set these!)
local settings = {
	mission_type = "wave", -- or "mission"
	tween_speed = 1000
}

-- Functions
local function moveto(Target, TeleportSpeed)
	if typeof(Target) == "Instance" and Target:IsA("BasePart") then
		Target = Target.Position
	elseif typeof(Target) == "CFrame" then
		Target = Target.Position
	end

	local HRP = client.Character and client.Character:FindFirstChild("HumanoidRootPart")
	if not HRP then return end

	local StartingPosition = HRP.Position
	local PositionDelta = Target - StartingPosition
	local StartTime = tick()
	local TotalDuration = PositionDelta.Magnitude / TeleportSpeed

	repeat runservice.Heartbeat:Wait()
		local Delta = tick() - StartTime
		local Progress = math.min(Delta / TotalDuration, 1)
		local MappedPosition = StartingPosition + (PositionDelta * Progress)
		HRP.Velocity = Vector3.zero
		HRP.CFrame = CFrame.new(MappedPosition)
	until (HRP.Position - Target).Magnitude <= TeleportSpeed / 1000

	HRP.Anchored = false
	HRP.CFrame = CFrame.new(Target)
end

local function get_titan()
	local titan, dist = nil, math.huge
	for _, v in pairs(workspace.Entities.Titans:GetChildren()) do
		if v:IsA('Model') then
			local root = v:FindFirstChild('HumanoidRootPart')
			local humanoid = v:FindFirstChild('Humanoid')
			local char = client.Character 
			local my_root = char and char:FindFirstChild('HumanoidRootPart')

			if root and humanoid and my_root then
				local mag = (my_root.Position - root.Position).Magnitude
				if mag < dist then
					titan = v
					dist = mag
				end
			end
		end
	end
	return titan
end

-- Disable idle connections safely
for _, v in pairs(getconnections(client.Idled)) do
	if typeof(v) == "table" and typeof(v.Disable) == "function" then
		v:Disable()
	elseif typeof(v) == "RBXScriptConnection" then
		v:Disable()
	end
end

-- Main loop
while task.wait() do 
	if game.PlaceId == 6372960231 then 
		moveto(CFrame.new(positions[settings.mission_type]), settings.tween_speed)
		if settings.mission_type == "wave" then 
			replicated.Remotes.VotedMapEvent:FireServer(1)
		end
	else
		local target = get_titan()
		local root = target and target:FindFirstChild('HumanoidRootPart')
		local humanoid = target and target:FindFirstChild('Humanoid')

		if root and humanoid then 
			moveto(root.CFrame * CFrame.new(0, 0, 5), settings.tween_speed)
			replicated.DamageEvent:FireServer(nil, humanoid, "&@&*&@&", target)
		end
	end
end
