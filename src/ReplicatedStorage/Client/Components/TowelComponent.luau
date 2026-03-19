-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local ToolService

local TowelComponent = Component.new({
	Tag = "TowelComponent",
})

function TowelComponent:Construct()
	self._trove = Trove.new()

	if not self.Instance:IsA("Tool") then
		warn("TowelComponent is not a Tool")
		return
	end

	self.towelEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PlaceTowel")
	self.deb = false
end

function TowelComponent:Start()
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
				local hrp = character:WaitForChild("HumanoidRootPart")

				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { character }

				local raycastResult = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 8, raycastParams)
				if raycastResult == nil then
					ToolService:PlaceTowel()
				end
			end)
			:andThenCall(Promise.delay, 3)
			:finallyCall(function()
				self.deb = false
			end)
	end)
end

function TowelComponent:Stop()
	self._trove:Destroy()
end

return TowelComponent
