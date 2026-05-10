-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Zone = require(ReplicatedStorage.Packages.ZonePlus)

local OrderComponent = Component.new({
	Tag = "OrderComponent",
})

function OrderComponent:Construct()
	self._trove = Trove.new()

	self.IsVisible = false
	self.Bounds = self.Instance:WaitForChild("Bounds") :: BasePart

	self.Zone = Zone.new(self.Bounds)
end

function OrderComponent:Start()
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	self._screenGui = PlayerGui:WaitForChild("OrderFoodGui")

	local MenuVisibilityComponent = require(ReplicatedStorage.Client.Components.MenuVisibilityComponent)
	MenuVisibilityComponent:WaitForInstance(self._screenGui):andThen(function(component)
		self.Zone.localPlayerEntered:Connect(function()
			if not self.IsVisible then
				component:Show()
				self.IsVisible = true
			end
		end)
		self.Zone.localPlayerExited:Connect(function()
			if self.IsVisible then
				component:Hide()
				self.IsVisible = false
			end
		end)
	end)
end

function OrderComponent:Stop()
	self._trove:Destroy()
end

return OrderComponent
