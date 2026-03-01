-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local DrinkComponent = Component.new({
	Tag = "DrinkComponent",
	Ancestors = { workspace },
})

function DrinkComponent:Construct()
	self._trove = Trove.new()

	if not self.Instance:IsA("Tool") then
		warn("DrinkComponent is not a Tool")
		return
	end

	self.isDrinking = false
	self.sound = self.Instance:WaitForChild("Handle"):WaitForChild("Sound")
end

function DrinkComponent:Start()
	self._trove:Connect(self.Instance.Activated, function()
		if self.isDrinking then
			return
		end
		self.isDrinking = true

		local anim = Players.LocalPlayer.Character.Humanoid:LoadAnimation(self.Instance.Animation)

		Promise.resolve()
			:andThenCall(anim.Play, anim)
			:andThenCall(Promise.delay, 0.5)
			:andThenCall(self.sound.Play, self.sound)
			:andThenCall(Promise.delay, 1.5)
			:andThenCall(self.sound.Stop, self.sound)
			:andThenCall(function()
				self.isDrinking = false
			end)
	end)
end

function DrinkComponent:Stop()
	self._trove:Destroy()
end

return DrinkComponent
