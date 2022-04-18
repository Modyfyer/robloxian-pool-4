tool = script.Parent
shootEvent = tool:WaitForChild("ShootBeam")
sound = tool:WaitForChild("Handle"):WaitForChild("Sound")

shootEvent.OnServerEvent:connect(function(pl, part, loc)
	local atA = tool.Handle:WaitForChild("Attachment")
	local atB = Instance.new("Attachment", part)
	local beam = tool.Handle:WaitForChild("Beam")
	local watLev = pl.Character:WaitForChild("Water")

	atB.Position = part.CFrame:ToObjectSpace(loc).Position
	beam.Attachment1 = atB
	sound:Play()
	watLev.Value = watLev.Value - 5

	if game.Players:GetPlayerFromCharacter(part.Parent) then
		local dedPlayer = game.Players:GetPlayerFromCharacter(part.Parent)
		local oxy = dedPlayer.Character:FindFirstChild("Oxygen")

		if oxy ~= nil then
			oxy.Value = oxy.Value - 10
		end
	end

	wait(.2)
	atB:Destroy()
end)