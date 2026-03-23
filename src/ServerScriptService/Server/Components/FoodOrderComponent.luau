local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local FoodOrderComponent = Component.new({
	Tag = "FoodOrderComponent",
})

function FoodOrderComponent:Construct()
	self._trove = Trove.new()
	self.OrderEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("OrderFood")
end

function FoodOrderComponent:Start()
	self.OrderEvent.OnServerEvent:connect(function(player, foodItem)
		local food = foodItem:Clone()
		food.Parent = player.Backpack
	end)
end

function FoodOrderComponent:Stop()
	self._trove:Destroy()
end

return FoodOrderComponent
