player = game.Players.LocalPlayer
char = player.Character
hum = char:WaitForChild("Humanoid")
oxygenBar = script.Parent.Desktop.OxygenMeter.OxygenLevelBG.OxygenLevel
oxygenVal = player.Character:WaitForChild("Oxygen")
waterBar = script.Parent.Desktop.WaterMeter.WaterLevelBG.WaterLevel
waterVal = player.Character:WaitForChild("Water")
drownFrame = script.Parent.Desktop.DrownAnim
ts = game:GetService("TweenService")

local drownTweenInfo = TweenInfo.new(
	3, -- Time
	Enum.EasingStyle.Linear, -- EasingStyle
	Enum.EasingDirection.Out, -- EasingDirection
	0, -- RepeatCount (when less than zero the tween will loop indefinitely)
	false, -- Reverses (tween will reverse once reaching it's goal)
	0 -- DelayTime
)

drownAnimA = ts:Create(drownFrame, drownTweenInfo, {BackgroundTransparency = 0})
drownAnimB = ts:Create(drownFrame, drownTweenInfo, {BackgroundTransparency = 1})

oxygenVal.Changed:connect(function()
	local oxLev = oxygenVal.Value
	oxygenBar.Size = UDim2.new(1, 0, 0, ((70 / 100) * oxLev))
	oxygenBar.Position = UDim2.new(0, 0, 1, (((70 / 100) * oxLev) * -1))

	if oxLev <= 0 then
		drownFrame.Visible = true
		drownAnimA:Play()
		hum.WalkSpeed = 0
		wait(4)
		drownAnimB:Play()
		wait(3)
		drownFrame.Visible = false
		hum.WalkSpeed = 16
	end
end)

waterVal.Changed:connect(function()
	local waterLev = waterVal.Value
	waterBar.Size = UDim2.new(0, ((180 / 100) * waterLev), 1, 0)
end)