local tool = script.Parent
local sound = tool:WaitForChild("Handle"):WaitForChild("Sound")
local anim = nil

local drinking: boolean = false
tool.Activated:connect(function()
	if drinking == false then
		drinking = true
		anim = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(tool.Animation)
		anim:Play()
		task.wait(.7)
		sound:Play()
		task.wait(1.5)
		anim:Stop()
		drinking = false
	end
end)

tool.Unequipped:connect(function()
	drinking = false
	anim:Stop()
end)