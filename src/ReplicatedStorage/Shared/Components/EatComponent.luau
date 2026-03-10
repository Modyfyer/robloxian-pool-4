-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local EatComponent = Component.new({
	Tag = "EatComponent",
	Ancestors = { workspace },
})

function EatComponent:Construct()
	self._trove = Trove.new()
	self._eatingTrove = Trove.new()

	if not self.Instance:IsA("Tool") then
		warn("EatComponent is not a Tool")
		return
	end

	self.isEating = false
	self.sound = self.Instance:WaitForChild("Handle"):WaitForChild("Sound")
	self.chip = nil :: Part?
end

function EatComponent:Start()
	self._trove:Connect(self.Instance.Activated, function()
		if self.isEating then
			return
		end

		self.isEating = true

		local char = Players.LocalPlayer.Character
		local anim = char.Humanoid:LoadAnimation(self.Instance.Animation)

		Promise.resolve()
			:andThenCall(anim.Play, anim)
			:andThenCall(Promise.delay, 0.4)
			:andThenCall(function()
				local chip = ReplicatedStorage:WaitForChild("Foods"):WaitForChild("Chip"):Clone()
				chip.Parent = char
				self.chip = chip
				self._eatingTrove:Add(chip)
				self._eatingTrove:Add(self.chip)

				local hand = char:FindFirstChild("LeftHand")
				local wld = Instance.new("Weld")
				wld.Part0 = chip
				wld.Part1 = hand
				wld.C0 = CFrame.new() * CFrame.Angles(math.rad(90), math.rad(90), 0) + Vector3.new(0.2, -0.3, -0.1)
				wld.Parent = chip
			end)
			:andThenCall(Promise.delay, 0.1)
			:andThenCall(self.sound.Play, self.sound)
			:andThenCall(Promise.delay, 0.5)
			:andThenCall(self.sound.Stop, self.sound)
			:finallyCall(function()
				self.isEating = false
				self._eatingTrove:Clean()
				self.chip = nil
			end)
	end)

	self._trove:Connect(self.Instance.Unequipped, function()
		self.isEating = false
		self._eatingTrove:Clean()
		self.chip = nil
	end)
end

function EatComponent:Stop()
	self._trove:Destroy()
end

return EatComponent
