lighting = game.Lighting

dayStart = 6.5
dayEnd = 17.7

waitTime = .25

function toggleLights(p, state)
	for _, v in pairs(p:GetChildren()) do
		if v:IsA("Light") and v.Name == "NightLight" then
			v.Enabled = state
		end
		toggleLights(v, state)
	end
end

function toggleBulbs(p, state)
	for _, v in pairs(p:GetChildren()) do
		if v:IsA("BasePart") and v:GetAttribute("IsBulb") == true then
			if state == true then
				v.Material = "Neon"
			else
				v.Material = "SmoothPlastic"
			end
		end
		toggleBulbs(v, state)
	end
end

function toggleFlames(p, state)
	for _, v in pairs(p:GetChildren()) do
		if v:IsA("ParticleEmitter") and v:GetAttribute("IsFlame") == true then
			v.Enabled = state
		end
		toggleFlames(v, state)
	end
end

while wait(waitTime) do
	lighting.ClockTime += .005
	if (lighting.ClockTime >= dayEnd) then
		toggleLights(workspace, true)
		toggleBulbs(workspace, true)
		toggleFlames(workspace, true)
		waitTime = .001
	elseif (lighting.ClockTime > dayStart) and (lighting.ClockTime < dayEnd) then
		toggleLights(workspace, false)
		toggleBulbs(workspace, false)
		toggleFlames(workspace, false)
		waitTime = .25
	end
end