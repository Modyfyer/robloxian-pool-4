-- Services
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local ToolService

local ADJUSTMENT_VAL: number = 20

local WaterBalloonComponent = Component.new({
	Tag = "WaterBalloonComponent",
})

function WaterBalloonComponent:Construct()
	self._trove = Trove.new()
	self._fireTrove = Trove.new()

	if not self.Instance:IsA("Tool") then
		warn("WaterBalloonComponent is not a Tool")
		return
	end

	self.Handle = self.Instance:WaitForChild("Handle")
end

function WaterBalloonComponent:Start()
	ToolService = Knit.GetService("ToolService")
	if RunService:IsServer() then
		self:StartServer()
	elseif RunService:IsClient() then
		self:StartClient()
	end
end

function WaterBalloonComponent:StartServer() end

function WaterBalloonComponent:FireBalloon(target: Vector3)
	local projectile = self.Handle:Clone()
	projectile.CFrame = self.Handle.CFrame
	projectile.Parent = workspace

	Promise.resolve()
		:andThenCall(function()
			self.Handle.Transparency = 1
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bodyVelocity.Velocity = (target - projectile.Position).unit * 100
			bodyVelocity.Parent = projectile

			local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
			bodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
			bodyAngularVelocity.AngularVelocity = Vector3.new(math.random(), math.random(), math.random()) * 10
			bodyAngularVelocity.Parent = projectile
		end)
		:andThenCall(Promise.delay, 0.3)
		:andThenCall(function()
			self:BalloonHit(projectile)
		end)
		:andThenCall(Promise.delay, 5)
		:finallyCall(function()
			self.Handle.Transparency = 0.15
		end)
end

function WaterBalloonComponent:BalloonHit(balloon: BasePart)
	self._fireTrove:Connect(balloon.Touched, function(p)
		if p.Name ~= "Handle" then
			balloon.Anchored = true
			local emitPos = balloon.Position

			local emitterPart = Instance.new("Part")
			emitterPart.Anchored = true
			emitterPart.Size = Vector3.new(2, 2, 2)
			emitterPart.Transparency = 1
			emitterPart.CanCollide = false
			emitterPart.CFrame = CFrame.new(emitPos)

			local emitter = self.Instance:WaitForChild("Particle"):Clone()
			emitter.Parent = emitterPart

			local snd = self.Instance:WaitForChild("Splat"):Clone() :: Sound
			snd.Parent = emitterPart

			emitterPart.Parent = workspace

			Debris:AddItem(emitterPart, 1)
			Debris:AddItem(balloon, 8)
			emitter.Enabled = true
			snd:Play()
			balloon:Destroy()

			ToolService:WaterFired(p.Parent)

			self._fireTrove:Clean()
		end
	end)
end

function WaterBalloonComponent:StartClient()
	local LocalPlayer = Players.LocalPlayer
	local Character = LocalPlayer.Character
	local Humanoid = Character:WaitForChild("Humanoid")
	local Mouse: Mouse = LocalPlayer:GetMouse()

	local waterAmount = LocalPlayer:GetAttribute("Water")

	local hold = self.Instance:WaitForChild("Hold")
	local throw = self.Instance:WaitForChild("Throw")
	local holdAnim = Humanoid:LoadAnimation(hold)
	local throwAnim = Humanoid:LoadAnimation(throw)

	local debounce: boolean = false
	local thrown: boolean = false

	local function onActivated()
		if waterAmount >= ADJUSTMENT_VAL then
			if not debounce then
				debounce = true
				holdAnim:Play()
			end
		end
	end

	local function onDeactivated()
		if waterAmount >= ADJUSTMENT_VAL and debounce and not thrown then
			holdAnim:Stop()
			throwAnim:Play()
			self:FireBalloon(Mouse.Hit.Position)

			thrown = true
			task.wait(5)
			debounce = false
			thrown = false
		end
	end

	self._trove:Connect(self.Instance.Activated, onActivated)
	self._trove:Connect(self.Instance.Deactivated, onDeactivated)
end

function WaterBalloonComponent:Stop()
	self._trove:Destroy()
	self._fireTrove:Destroy()
end

return WaterBalloonComponent
