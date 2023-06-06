wait(3)
towelEvent = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PlaceTowel")

tool = script.Parent
player = game.Players.LocalPlayer
char = player.Character
hrp = char:WaitForChild("HumanoidRootPart")


deb = false
tool.Activated:Connect(function()
	if deb == false then
		deb = true
		
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		raycastParams.FilterDescendantsInstances = {char}
		
		local raycastResult = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 8, raycastParams)
		
		if raycastResult == nil then
			towelEvent:FireServer()
			wait(3)
		else
			wait(3)
		end
		
		deb = false
	end
end)