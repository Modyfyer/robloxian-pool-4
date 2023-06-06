Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Event = script:WaitForChild("FireVolleyball")
Debounce = false

function setVis(part, amt)
	part.Transparency = amt
	
	for _, v in pairs(part:GetChildren()) do
		if v:IsA("Decal") then
			v.Transparency = amt
		end
	end
end

function fireVolleyball(distance, angle)
	if Tool.Parent.Name ~= "Backpack" and Debounce == false then
		Debounce = true
		local player = game.Players:GetPlayerFromCharacter(Tool.Parent)
		local originPart = player.Character:WaitForChild("HumanoidRootPart")
		local projectile = Handle:Clone()
		local trail = projectile:WaitForChild("Trail")
		local snd = projectile:WaitForChild("Whoosh")
		
		setVis(Handle, 1)
		
		projectile.CanCollide = true
		projectile.CFrame = originPart.CFrame * CFrame.new(1, 0, -2)
		projectile.Parent = workspace

		local g = workspace.Gravity
		local v0 = math.sqrt(distance * g / math.sin(2 * angle))
		local v0x, v0y = v0 * math.cos(angle), v0 * math.sin(angle)
		
		trail.Enabled = true
		snd:Play()
		projectile.Velocity = originPart.CFrame.lookVector * v0x + Vector3.new(0, v0y, 0)
		game:GetService("Debris"):AddItem(projectile, 10)
		task.wait(10)
		Debounce = false
		setVis(Handle, 0)
		trail.Enabled = false
	end
end

Event.OnServerEvent:Connect(function(player, dist, ang)
	fireVolleyball(dist, ang)
end)