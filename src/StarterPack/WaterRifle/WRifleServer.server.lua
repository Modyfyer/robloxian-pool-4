tool = script.Parent
shootEvent = tool:WaitForChild("ShootBeam")
sound = tool:WaitForChild("Handle"):WaitForChild("Sound")

function getPlayerFromPart(part)
	local player = nil

	if part.Parent.ClassName == "Accessory" or part.Parent.ClassName == "Hat" then
		if part.Parent.Parent ~= workspace then
			player = game.Players:GetPlayerFromCharacter(part.Parent.Parent)
		end
	elseif part.Parent.ClassName == "Model" and game.Players:GetPlayerFromCharacter(part.Parent) then
		player = game.Players:GetPlayerFromCharacter(part.Parent)
	end
	return player
end

shootEvent.OnServerEvent:connect(function(pl, part, loc)
	local atA = tool.Handle:WaitForChild("Attachment")
	local atB = Instance.new("Attachment", part)
	local beam = tool.Handle:WaitForChild("Beam")
	local watLev = pl.Character:WaitForChild("Water")

	atB.Position = part.CFrame:ToObjectSpace(loc).Position
	beam.Attachment1 = atB
	sound:Play()
	watLev.Value = watLev.Value - 1

	if getPlayerFromPart(part) ~= nil then
		local dedPlayer = getPlayerFromPart(part)
		local oxy = dedPlayer.Character:FindFirstChild("Oxygen")

		if oxy ~= nil then
			oxy.Value = oxy.Value - 5
		end
	end

	wait(.2)
	atB:Destroy()
end)