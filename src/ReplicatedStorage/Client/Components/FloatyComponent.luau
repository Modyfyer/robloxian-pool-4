-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local ToolService

local FloatyComponent = Component.new({
	Tag = "FloatyComponent",
})

function FloatyComponent:Construct()
	self._trove = Trove.new()

	if not self.Instance:IsA("Tool") then
		warn("FloatyComponent is not a Tool")
		return
	end

	self.deb = false
end

function FloatyComponent:Start()
	ToolService = Knit.GetService("ToolService")

	self._trove:Connect(self.Instance.Activated, function()
		if self.deb then
			return
		end

		Promise.resolve()
			:andThenCall(function()
				self.deb = true
			end)
			:andThenCall(function()
				local player = Players.LocalPlayer
				local character = player.Character or player.CharacterAdded:Wait()
				if character then
					ToolService:PlaceFloaty()
				end
			end)
			:andThenCall(Promise.delay, 5)
			:finallyCall(function()
				self.deb = false
			end)
	end)
end

function FloatyComponent:Stop()
	self._trove:Destroy()
end

return FloatyComponent
