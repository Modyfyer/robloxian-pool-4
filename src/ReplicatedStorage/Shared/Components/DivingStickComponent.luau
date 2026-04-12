local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local STICK_POWER = 50
local THROW_COOLDOWN = 5

local DivingStickComponent = Component.new({
	Tag = "DivingStickComponent",
})

function DivingStickComponent:Construct()
	self._trove = Trove.new()

	if not self.Instance:IsA("Tool") then
		warn("DivingStickComponent is not a Tool")
		return
	end

	self.Handle = self.Instance:WaitForChild("Handle")
	self.StickEvent = self.Instance:WaitForChild("DStickEvent") :: RemoteEvent
end

function DivingStickComponent:Start()
	if RunService:IsServer() then
		self:StartServer()
	elseif RunService:IsClient() then
		self:StartClient()
	end
end

function DivingStickComponent:StartServer()
	-- Server-side logic for handling stick physics
	self.StickEvent.OnServerEvent:Connect(function(_, target: Vector3)
		self:FireStick(target)
	end)
end

function DivingStickComponent:FireStick(target: Vector3)
	local projectile = self.Handle:Clone()
	projectile.CFrame = self.Handle.CFrame
	projectile.Parent = workspace

	Promise.resolve()
		:andThenCall(function()
			self.Handle.Transparency = 1
			self.Instance.Parent = workspace
			projectile.Position = projectile.Position + Vector3.new(0, 0.2, 0)
			local direction = (target - projectile.Position).Unit
			projectile.Velocity = direction * STICK_POWER
		end)
		:andThenCall(Promise.delay, THROW_COOLDOWN)
		:finallyCall(function()
			self.Handle.Transparency = 0
			projectile:Destroy()
		end)
end

function DivingStickComponent:StartClient()
	local LocalPlayer = game:GetService("Players").LocalPlayer
	local Character = LocalPlayer.Character
	local Humanoid = Character:WaitForChild("Humanoid")
	local Mouse: Mouse = LocalPlayer:GetMouse()

	local hold = self.Instance:WaitForChild("Hold")
	local throw = self.Instance:WaitForChild("Throw")
	local holdAnim = Humanoid:LoadAnimation(hold)
	local throwAnim = Humanoid:LoadAnimation(throw)

	local debounce: boolean = false
	local thrown: boolean = false

	local function onActivated()
		if not debounce then
			debounce = true
			holdAnim:Play()
		end
	end

	local function onDeactivated()
		if debounce and not thrown then
			holdAnim:Stop()
			throwAnim:Play()
			self.StickEvent:FireServer(Mouse.Hit.Position)
			thrown = true
			task.wait(THROW_COOLDOWN)
			debounce = false
			thrown = false
		end
	end

	self._trove:Connect(self.Instance.Activated, onActivated)
	self._trove:Connect(self.Instance.Deactivated, onDeactivated)
end

function DivingStickComponent:Stop()
	self._trove:Destroy()
end

return DivingStickComponent
