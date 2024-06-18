--Services
local Players = game:GetService("Players")

--Declarations
local tool: Instance = script.Parent
local sound = tool:WaitForChild("Handle"):WaitForChild("Sound")
local player: Player = Players.LocalPlayer
local char = player.Character
local anim = nil
local chip = nil
local eating: boolean = false

--Functions
tool.Activated:Connect(function()
	if not char then
		char = player.Character
	end
	
	if eating == false then
		eating = true
		
		anim = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(tool.Animation)
		anim:Play()
		
		task.wait(.4)
		
		chip = Instance.new("Part")
		chip.Size = Vector3.new(.1, .1, .1)
		chip.CanCollide = false

		local msh = Instance.new("SpecialMesh")
		msh.MeshId = "rbxassetid://17087148864"
		msh.TextureId = "rbxassetid://17087148881"
		msh.Scale = Vector3.new(.5, .5, .5)
		msh.Parent = chip

		chip.Parent = char

		local hand = char:FindFirstChild("LeftHand")
		local wld = Instance.new("Weld")
		wld.Part0 = chip
		wld.Part1 = hand
		wld.C0 = CFrame.new() * CFrame.Angles(math.rad(90), math.rad(90), 0) + Vector3.new(.2, -.3, -.1)
		wld.Parent = chip

		
		task.wait(.1)
		
		sound:Play()
		
		task.wait(.5)
		
		anim:Stop()
		chip:Destroy()
		eating = false
	end
end)

tool.Unequipped:Connect(function()
	eating = false
	anim:Stop()
	if chip ~= nil then
		chip:Destroy()
	end
end)