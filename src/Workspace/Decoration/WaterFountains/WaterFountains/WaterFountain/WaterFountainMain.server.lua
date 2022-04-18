fountain = script.Parent
button = fountain.Button
spout = fountain.Spout
water = spout.Water
wateron = false

playerparts = {}

function getCharacters()
	spawn(function()
		playerparts = {}
		for _, v in pairs(game.Players:GetPlayers()) do
			if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
				table.insert(playerparts, v.Character.HumanoidRootPart)
			end
		end
	end)
end

function shouldBeOn()
	for _, v in pairs(playerparts) do
		if (v.Position - button.Position).magnitude <= 2.5 then
			return true
		end
	end
end

while wait() do
	getCharacters()
	for _, v in pairs(playerparts) do
		if shouldBeOn() then
			water.Enabled = true
			if wateron ~= true then
				wateron = true
				spout.Sound:Play()
			end
		else
			water.Enabled = false
			wateron = false
			spout.Sound:Stop()
		end
	end
end