local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local PlayerService

local ADJUSTMENT_VAL: number = 20

local WaterBalloonComponent = Component.new({
	Tag = "WaterBalloonComponent",
})

function WaterBalloonComponent:Construct()
	self._trove = Trove.new()
	self.Tool = self.Instance
	self.Handle = self.Tool:WaitForChild("Handle")
	self.BalloonEvent = self.Tool:WaitForChild("FireBalloon")
end

function WaterBalloonComponent:Start()
	PlayerService = Knit.GetService("PlayerService")
	if RunService:IsServer() then
		self:StartServer()
	elseif RunService:IsClient() then
		self:StartClient()
	end
end

function WaterBalloonComponent:StartServer()
	self.BalloonEvent.OnServerEvent:Connect(function(player: Player, target)
		self:FireBalloon(player, target)
	end)
end

function WaterBalloonComponent:FireBalloon(_, target)
	local projectile = self.Handle:Clone()
	projectile.CFrame = self.Handle.CFrame
	projectile.Parent = workspace

	self.Handle.Transparency = 1

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = (target - projectile.Position).unit * 100
	bodyVelocity.Parent = projectile

	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyAngularVelocity.AngularVelocity = Vector3.new(math.random(), math.random(), math.random()) * 10
	bodyAngularVelocity.Parent = projectile

	task.wait(0.3)

	self:BalloonHit(projectile)

	task.wait(5)

	self.Handle.Transparency = 0.15
end

function WaterBalloonComponent:BalloonHit(balloon)
	balloon.Touched:Connect(function(p)
		if p.Name ~= "Handle" then
			balloon.Anchored = true
			local emitPos = balloon.Position

			local emitterPart = Instance.new("Part")
			emitterPart.Anchored = true
			emitterPart.Size = Vector3.new(2, 2, 2)
			emitterPart.Transparency = 1
			emitterPart.CanCollide = false
			emitterPart.CFrame = CFrame.new(emitPos)

			local emitter = self.Tool:WaitForChild("Particle"):Clone()
			emitter.Parent = emitterPart

			local snd = self.Tool:WaitForChild("Splat"):Clone() :: Sound
			snd.Parent = emitterPart

			emitterPart.Parent = workspace

			Debris:AddItem(emitterPart, 1)
			Debris:AddItem(balloon, 8)
			emitter.Enabled = true
			snd:Play()
			balloon:Destroy()

			local plTarg = Players:GetPlayerFromCharacter(p.Parent)
			if plTarg then
				local oxygen = plTarg:GetAttribute("Oxygen")
				if oxygen then
					oxygen -= ADJUSTMENT_VAL
				end
			end
		end
	end)
end

function WaterBalloonComponent:StartClient()
	local LocalPlayer = Players.LocalPlayer
	local Character = LocalPlayer.Character
	local Humanoid = Character:WaitForChild("Humanoid")
	local Mouse = LocalPlayer:GetMouse()

	local waterAmount = LocalPlayer:GetAttribute("Water")

	local hold = self.Tool:WaitForChild("Hold")
	local throw = self.Tool:WaitForChild("Throw")
	local holdAnim = Humanoid:LoadAnimation(hold)
	local throwAnim = Humanoid:LoadAnimation(throw)

	local debounce = false
	local thrown = false

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
			self.BalloonEvent:FireServer(Mouse.Hit.Position)
			PlayerService:ChangeWater(-ADJUSTMENT_VAL)
			thrown = true
			task.wait(5)
			debounce = false
			thrown = false
		end
	end

	self._trove:Connect(self.Tool.Activated, onActivated)
	self._trove:Connect(self.Tool.Deactivated, onDeactivated)
end

function WaterBalloonComponent:Stop()
	self._trove:Destroy()
end

return WaterBalloonComponent
