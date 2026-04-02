-- Services
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
--local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local MIN_NUMBER = 7
local MAX_NUMBER = 25
local INCREMENT_AMOUNT = 0.2
local THROW_COOLDOWN = 10
local STICK_POWER = 75

local VolleyballComponent = Component.new({
	Tag = "VolleyballComponent",
})

function VolleyballComponent:Construct()
	self._trove = Trove.new()

	if not self.Instance:IsA("Tool") then
		warn("VolleyballComponent is not a Tool")
		return
	end

	self.Handle = self.Instance:WaitForChild("Handle")
	self.ProgressEmitter = self.Handle:WaitForChild("Progress")
	self.FireEvent = self.Instance:WaitForChild("FireVolleyball") :: RemoteEvent
end

function VolleyballComponent:Start()
	if RunService:IsServer() then
		self:StartServer()
	elseif RunService:IsClient() then
		self:StartClient()
	end
end

function VolleyballComponent:StartServer()
	self.FireEvent.OnServerEvent:Connect(function(_, distance, angle)
		self:FireVolleyball(distance, angle)
	end)
end

function VolleyballComponent:FireVolleyball(distance, angle)
	if self.Instance.Parent.Name ~= "Backpack" then
		local player = Players:GetPlayerFromCharacter(self.Instance.Parent)
		local originPart = player.Character:WaitForChild("HumanoidRootPart")
		local projectile = self.Handle:Clone()
		local trail = projectile:WaitForChild("Trail")
		local snd = projectile:WaitForChild("Whoosh")

		self:SetVis(self.Handle, 1)

		projectile.CanCollide = true
		projectile.CFrame = originPart.CFrame * CFrame.new(1, 0, -2)
		projectile.Parent = workspace

		local g = workspace.Gravity
		local v0 = math.sqrt(distance * g / math.sin(2 * angle))
		local v0x, v0y = v0 * math.cos(angle), v0 * math.sin(angle)

		trail.Enabled = true
		snd:Play()
		projectile.Velocity = originPart.CFrame.lookVector * v0x + Vector3.new(0, v0y, 0)
		Debris:AddItem(projectile, 10)
		task.wait(THROW_COOLDOWN)
		self:SetVis(self.Handle, 0)
		trail.Enabled = false
	end
end

function VolleyballComponent:SetVis(part, amt)
	part.Transparency = amt

	for _, v in pairs(part:GetChildren()) do
		if v:IsA("Decal") then
			v.Transparency = amt
		end
	end
end

function VolleyballComponent:UpdateEmitterColor(currentNumber)
	if self.ProgressEmitter then
		local progress = (currentNumber - MIN_NUMBER) / (MAX_NUMBER - MIN_NUMBER)
		self.ProgressEmitter.Color = ColorSequence.new(Color3.new(1, 1 - progress, 1 - progress))
	end
end

function VolleyballComponent:StartClient()
	local LocalPlayer = game:GetService("Players").LocalPlayer
	local Character = LocalPlayer.Character
	local Humanoid = Character:WaitForChild("Humanoid")

	local holdObj = self.Instance:WaitForChild("Hold")
	local swingObj = self.Instance:WaitForChild("Swing")
	local holdAnim = Humanoid:LoadAnimation(holdObj)
	local swingAnim = Humanoid:LoadAnimation(swingObj)

	local currentNumber = MIN_NUMBER
	local counting = false
	local debounce = false
	local thrown = false

	local function onActivated()
		if not debounce then
			debounce = true
			counting = true
			self.ProgressEmitter.Enabled = true
			holdAnim:Play()

			while counting and currentNumber <= MAX_NUMBER do
				currentNumber = currentNumber + INCREMENT_AMOUNT
				self:UpdateEmitterColor(currentNumber)
				self.ProgressEmitter.Rate = math.floor(currentNumber / 2)
				task.wait(0.05)
			end
		end
	end

	local function onDeactivated()
		if debounce and not thrown then
			counting = false
			self.ProgressEmitter.Enabled = false
			holdAnim:Stop()
			swingAnim:Play()
			self.FireEvent:FireServer(currentNumber, math.rad(STICK_POWER))
			thrown = true
			currentNumber = MIN_NUMBER
			self:UpdateEmitterColor(currentNumber)
			self.ProgressEmitter.Rate = 2
			task.wait(THROW_COOLDOWN)
			debounce = false
			thrown = false
		end
	end

	self._trove:Connect(self.Instance.Activated, onActivated)
	self._trove:Connect(self.Instance.Deactivated, onDeactivated)
end

function VolleyballComponent:Stop()
	self._trove:Destroy()
end

return VolleyballComponent
