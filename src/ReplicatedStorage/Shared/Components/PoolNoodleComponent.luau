local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Component = require(ReplicatedStorage.Packages.Component)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)

local PoolNoodleComponent = Component.new({
	Tag = "PoolNoodleComponent",
})

function PoolNoodleComponent:Construct()
	self._trove = Trove.new()

	if not self.Instance:IsA("Tool") then
		warn("PoolNoodleComponent is not a Tool")
		return
	end

	self.Handle = self.Instance:WaitForChild("Handle")
	self.Sound = self.Handle:WaitForChild("WhackNoise")
	self.WhackEvent = Signal.new()
end

function PoolNoodleComponent:Start()
	if RunService:IsServer() then
		self:StartServer()
	elseif RunService:IsClient() then
		self:StartClient()
	end

	self.WhackEvent:Connect(function()
		self:OnWhack()
	end)
end

function PoolNoodleComponent:StartServer()
	self._trove:Connect(self.Handle.Touched, function(part)
		if self._isWhacking and Players:GetPlayerFromCharacter(part.Parent) then
			self.Sound:Play()
		end
	end)
end

function PoolNoodleComponent:StartClient()
	local LocalPlayer = Players.LocalPlayer
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")

	local whackAnim = self.Instance:WaitForChild("WhackAnim")
	local noodleAnim = self.Instance:WaitForChild("NoodleAnim")

	local whackAnimation = Humanoid:LoadAnimation(whackAnim)
	local noodleAnimation = Humanoid:LoadAnimation(noodleAnim)

	local debounce: boolean = false

	local function onActivated()
		if debounce == false then
			debounce = true
			noodleAnimation:Play()
			whackAnimation:Play()
			self.WhackEvent:Fire()

			task.wait(1.8)
			debounce = false
		end
	end

	self._trove:Connect(self.Instance.Activated, onActivated)
end

function PoolNoodleComponent:OnWhack()
	self._isWhacking = true
	task.wait(1.8)
	self._isWhacking = false
end

function PoolNoodleComponent:Stop()
	self._trove:Destroy()
end

return PoolNoodleComponent
