player = game.Players.LocalPlayer
print("Loaded sprint")

if not player.Character then 
	player.CharacterAdded:Wait()
end

char = player.Character
hum = char:WaitForChild("Humanoid")
uis = game:GetService("UserInputService")
cam = workspace.CurrentCamera
ts = game:GetService("TweenService")
blur = game.Lighting:WaitForChild("RunBlur")

local tweenInfo = TweenInfo.new(
	.5, -- Time
	Enum.EasingStyle.Linear, -- EasingStyle
	Enum.EasingDirection.Out, -- EasingDirection
	0, -- RepeatCount (when less than zero the tween will loop indefinitely)
	false, -- Reverses (tween will reverse once reaching it's goal)
	0 -- DelayTime
)

blurOn = ts:Create(blur, tweenInfo, {Size = 5})
blurOff = ts:Create(blur, tweenInfo, {Size = 0})
tweenOn = ts:Create(cam, tweenInfo, {FieldOfView = 90})
tweenOff = ts:Create(cam, tweenInfo, {FieldOfView = 70})

running = false
uis.InputBegan:connect(function(input)
	if running == false then
		if input.KeyCode == Enum.KeyCode.LeftShift then
			blurOff:Pause()
			blurOn:Play()
			tweenOff:Pause()
			tweenOn:Play()
			hum.WalkSpeed = 45
			running = true
		end
	end
end)

uis.InputEnded:connect(function(input)
	if running == true then
		if input.KeyCode == Enum.KeyCode.LeftShift then
			blurOn:Pause()
			blurOff:Play()
			tweenOn:Pause()
			tweenOff:Play()
			hum.WalkSpeed = 16
			running = false
		end
	end
end)