function handleBasketballHoop(hoop)
	local goalPart = hoop:WaitForChild("Goal")
	local snd = goalPart:WaitForChild("Applause")
	local deb = false

	goalPart.Touched:Connect(function(prt)
		if prt:IsA("MeshPart") and prt.Name == "Basketball" and not deb then
			snd:Play()
			for _, v in pairs(goalPart:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = true
				end
			end
			deb = true
			
			wait(5)
			
			snd:Stop()
			for _, v in pairs(goalPart:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
			deb = false
		end
	end)
end

for _, v in pairs(workspace.BasketBallHoops:GetChildren()) do
	if v.Name == "BasketballHoop" then
		handleBasketballHoop(v)
	end
end