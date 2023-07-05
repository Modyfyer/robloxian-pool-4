local slides = workspace:WaitForChild("Slides")

function handleSlide(slide)
	local trigger = slide:WaitForChild("SitTrigger")
	trigger.Touched:connect(function(p)
		local hum = p.Parent:FindFirstChild("Humanoid")
		if hum ~= nil then
			hum.Sit = true
		end
	end)
end

for _, v in pairs(slides:GetChildren()) do
	handleSlide(v)
end

local kpg = workspace:WaitForChild("KiddiePlayground")

handleSlide(kpg)

for _, v in pairs(kpg:WaitForChild("Velocity"):GetChildren()) do
	if v.Name == "VelocityPart" then
		v.Velocity = v.CFrame.lookVector * 50
	end
end