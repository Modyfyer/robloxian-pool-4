local lighting = game:GetService("Lighting")
local outdoorAmb = workspace:WaitForChild("AmbientSounds"):WaitForChild("Outdoor")

local dayStart = 6.5
local dayEnd = 17.7

local waitTime = .25

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

function toggleLightCones(p, state)
	for _, v in pairs(p:GetChildren()) do
		if v:IsA("Beam") and v.Name == "LightCone" then
			v.Enabled = state
		end
		toggleLightCones(v, state)
	end
end

function toggleOutdoorAmb(state)
	if state == "Day" then
		for _, v in pairs(outdoorAmb:GetChildren()) do
			v.Night:Stop()
			v.Day:Play()
		end
	elseif state == "Night" then
		for _, v in pairs(outdoorAmb:GetChildren()) do
			v.Night:Play()
			v.Day:Stop()
		end
	end
end

toggleOutdoorAmb("Day")
local currentTime = "Day"

while task.wait(waitTime) do
	lighting.ClockTime += .005
	if (lighting.ClockTime >= dayEnd) and currentTime ~= "Night" then
		currentTime = "Night"
		toggleLights(workspace, true)
		toggleBulbs(workspace, true)
		toggleFlames(workspace, true)
		toggleLightCones(workspace, true)
		toggleOutdoorAmb("Night")
		waitTime = .001
	elseif (lighting.ClockTime > dayStart) and (lighting.ClockTime < dayEnd) and currentTime ~= "Day" then
		currentTime = "Day"
		toggleLights(workspace, false)
		toggleBulbs(workspace, false)
		toggleFlames(workspace, false)
		toggleLightCones(workspace, false)
		toggleOutdoorAmb("Day")
		waitTime = .25
	end
end