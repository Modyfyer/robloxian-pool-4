local orderEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("OrderFood")

orderEvent.OnServerEvent:connect(function(player, foodItem)
	local food = foodItem:Clone()
	food.Parent = player.Backpack
end)