pl = game.Players.LocalPlayer
ch = pl.Character

snd = script:WaitForChild("Rain")

hum = ch:WaitForChild("Humanoid")
hrp = ch:WaitForChild("HumanoidRootPart")

cam = workspace.CurrentCamera

rainPart = game:GetService("ReplicatedStorage"):WaitForChild("RainPart"):Clone()
rainPart.Parent = cam

isRaining = game:GetService("ReplicatedStorage"):WaitForChild("IsRaining")

function renderRain()
	rainPart.CFrame = CFrame.new(cam.CFrame.Position) + Vector3.new(0, 80, 0)

	local raycastResult = nil
	local raycastParms = nil

	if isRaining.Value == true then
		raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {ch, rainPart, workspace:WaitForChild("TimeCycleLights")}
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		raycastResult = workspace:Raycast(cam.CFrame.Position, Vector3.new(0, 100, 0), raycastParams)
	end

	if (isRaining.Value == true) and not raycastResult then
		rainPart.Rain.Enabled = true

		if snd.IsPaused == true then
			snd:Play()
		end
	else
		rainPart.Rain.Enabled = false
		rainPart.Rain:Clear()
		if snd.IsPaused == false then
			snd:Stop()
		end
	end
end

renderConnect = game:GetService("RunService").RenderStepped:connect(renderRain)

hum.Died:connect(function()
	renderConnect:disconnect()
	rainPart:Destroy()
	snd:Stop()
end)