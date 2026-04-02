local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local VELOCITY = 200
local THROW_COOLDOWN = 5

local BasketballComponent = Component.new({
	Tag = "BasketballComponent",
})

function BasketballComponent:Construct()
	self._trove = Trove.new()

	if not self.Instance:IsA("Tool") then
		warn("BasketballComponent is not a Tool")
		return
	end

	self.Handle = self.Instance:WaitForChild("Handle")
	self.ServerThrowEvent = self.Instance:WaitForChild("dest")
end

function BasketballComponent:Start()
	if RunService:IsServer() then
		self:StartServer()
	elseif RunService:IsClient() then
		self:StartClient()
	end
end

function BasketballComponent:StartServer()
	-- Server-side logic for handling basketball physics
	self.ServerThrowEvent.OnServerEvent:Connect(function(_, target: Vector3)
		self:FireBasketball(target)
	end)
end

function BasketballComponent:ComputeLaunchAngle(dx: number, dy: number, grav: number): number
	-- Calculate optimal launch angle for projectile motion
	local g = math.abs(grav)
	local inRoot = (VELOCITY * VELOCITY * VELOCITY * VELOCITY) - (g * ((g * dx * dx) + (2 * dy * VELOCITY * VELOCITY)))
	if inRoot <= 0 then
		return 0.25 * math.pi
	end
	local root = math.sqrt(inRoot)
	local inATan1 = ((VELOCITY * VELOCITY) + root) / (g * dx)
	local inATan2 = ((VELOCITY * VELOCITY) - root) / (g * dx)
	local answer1 = math.atan(inATan1)
	local answer2 = math.atan(inATan2)
	if answer1 < answer2 then
		return answer1
	end
	return answer2
end

function BasketballComponent:ComputeDirection(vec: Vector3): Vector3
	local lenSquared = vec.Magnitude * vec.Magnitude
	local invSqrt = 1 / math.sqrt(lenSquared)
	return Vector3.new(vec.X * invSqrt, vec.Y * invSqrt, vec.Z * invSqrt)
end

function BasketballComponent:FireBasketball(target: Vector3)
	local projectile = self.Handle:Clone()
	projectile.CFrame = self.Handle.CFrame
	projectile.Parent = workspace
	projectile.Transparency = 0
	projectile.CanCollide = true
	projectile.Name = "Basketball"

	if projectile:FindFirstChild("Trail") then
		projectile.Trail.Enabled = true
	end

	Promise.resolve()
		:andThenCall(function()
			self.Handle.Transparency = 1
			local startP = self.Handle.Position
			local lAng = self:ComputeLaunchAngle((target - startP).X, (target - startP).Y, -9.81 * 20)
			local dir = self:ComputeDirection(target - startP)
			local vel = dir * 50 * math.cos(lAng) + Vector3.new(0, 100 * math.sin(lAng), 0)
			projectile.Position = startP
			projectile.Velocity = vel
		end)
		:andThenCall(Promise.delay, THROW_COOLDOWN)
		:finallyCall(function()
			self.Handle.Transparency = 0
		end)

	Debris:AddItem(projectile, 10)
end

function BasketballComponent:StartClient()
	local LocalPlayer = Players.LocalPlayer
	local Character = LocalPlayer.Character
	local Humanoid = Character:WaitForChild("Humanoid")
	local Mouse: Mouse = LocalPlayer:GetMouse()

	local anim = self.Instance:WaitForChild("Throw")
	local throwAnim = Humanoid:LoadAnimation(anim)

	local snd = self.Handle:WaitForChild("Whoosh") :: Sound

	local debounce: boolean = false

	local function onActivated()
		if not debounce then
			debounce = true
			throwAnim:Play()
			snd:Play()
			self.ServerThrowEvent:FireServer(Mouse.Hit.Position)
			task.wait(THROW_COOLDOWN)
			debounce = false
		end
	end

	self._trove:Connect(self.Instance.Activated, onActivated)
end

function BasketballComponent:Stop()
	self._trove:Destroy()
end

return BasketballComponent
