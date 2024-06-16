--Services
--local Players = game:GetService("Players")

--Declarations
local tool: Instance = script.Parent
local sound = tool:WaitForChild("Handle"):WaitForChild("Sound")
local anim = nil
local eating: boolean = false

--Functions
tool.Activated:connect(function()
	if eating == false then
		eating = true
		anim = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(tool.Animation)
		anim:Play()
		task.wait(.7)
		sound:Play()
		task.wait(1.5)
		anim:Stop()
		eating = false
	end
end)

tool.Unequipped:connect(function()
	eating = false
	anim:Stop()
end)