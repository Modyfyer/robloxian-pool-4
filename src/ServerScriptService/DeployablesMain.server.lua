towelEvent = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PlaceTowel")
towelModel = game.ServerStorage.TowelModels

towelEvent.OnServerEvent:Connect(function(player)
	local char = player.Character
	local hrp = char:WaitForChild("HumanoidRootPart")
	
	if not char:FindFirstChild("PoolTowel") then
		local color = char:WaitForChild("Color")
		
		local towel = towelModel:GetChildren()[math.random(1, #towelModel:GetChildren())]:Clone()
		towel.Name = "PoolTowel"
		towel.Parent = char
		towel.Color = color.Value
		
		for _, v in pairs(towel:GetChildren()) do
			if v:IsA("Decal") then
				v.Color3 = color.Value
			end
		end
		
		towel.CFrame = hrp.CFrame * CFrame.new(0, 0, -6)
		local towelOrientation = towel.Orientation
		
		local ray = Ray.new(towel.Position, Vector3.new(0, -1, 0) * 100)
		
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		raycastParams.FilterDescendantsInstances = {towel, char}
		
		local result = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
		
		if result then
			local hitPos = result.Position
			local hitNormal = result.Normal
			local yOffset = towel.Size.Y / 2 -- Adjust for the towel's Y Size
			towel.CFrame = CFrame.new(hitPos + hitNormal * yOffset, hitPos)
			towel.Orientation = towelOrientation -- Set the towel's orientation again
		end
	elseif char:FindFirstChild("PoolTowel") then
		char.PoolTowel:Destroy()
	end
end)