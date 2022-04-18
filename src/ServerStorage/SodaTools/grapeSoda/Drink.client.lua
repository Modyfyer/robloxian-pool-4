tool = script.Parent
sound = tool:WaitForChild("Handle"):WaitForChild("Sound")

drinking = false
tool.Activated:connect(function()
	if drinking == false then
		drinking = true
		anim = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(tool.Animation)
		anim:Play()
		wait(1)
		sound:Play()
		wait(1.5)
		anim:Stop()
		drinking = false
	end
end)

tool.Unequipped:connect(function()
	drinking = false
	anim:Stop()
end)