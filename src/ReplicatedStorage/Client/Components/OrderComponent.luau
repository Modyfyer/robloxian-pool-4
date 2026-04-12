local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local OrderComponent = Component.new({
	Tag = "OrderComponent",
})

function OrderComponent:Construct()
	self._trove = Trove.new()
	self.Distance = 5
	self.IsVisible = false
end

function OrderComponent:Start()
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	self._screenGui = PlayerGui:WaitForChild("OrderFoodGui")

	local MenuVisibilityComponent = require(ReplicatedStorage.Client.Components.MenuVisibilityComponent)
	MenuVisibilityComponent:WaitForInstance(self._screenGui):andThen(function(component)
		self._trove:Add(task.spawn(function()
			while task.wait() do
				local playerChar = Players.LocalPlayer.Character
				local hrp = playerChar:WaitForChild("HumanoidRootPart")

				local distance = (hrp.Position - self.Instance.Position).Magnitude
				if distance <= self.Distance and not self.IsVisible then
					component:Show()
					self.IsVisible = true
				elseif self.IsVisible and distance > self.Distance then
					component:Hide()
					self.IsVisible = false
				end
			end
		end))
	end)
end

function OrderComponent:Stop()
	self._trove:Destroy()
end

return OrderComponent
