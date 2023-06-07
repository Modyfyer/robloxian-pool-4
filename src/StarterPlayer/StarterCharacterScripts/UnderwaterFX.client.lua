rServ = game:GetService("RunService")
sServ = game:GetService("SoundService")
camera = game.Workspace.CurrentCamera
uwFX = game:GetService("ReplicatedStorage"):WaitForChild("Underwater"):Clone()
uwBlur = game.Lighting:WaitForChild("UWBlur")

waterLevel = 28

underwater = false

if game.Lighting:FindFirstChild("Underwater") then
	game.Lighting.Underwater:Destroy()
end

rServ.RenderStepped:connect(function()
	if camera.CFrame.Y < waterLevel and underwater == false then
		underwater = true
		uwFX.Parent = game.Lighting
		sServ.AmbientReverb = Enum.ReverbType.UnderWater
		sServ.RolloffScale = .1
		uwBlur.Enabled = true
	elseif camera.CFrame.Y > waterLevel and underwater == true then
		underwater = false
		uwFX.Parent = game.ReplicatedStorage
		sServ.AmbientReverb = Enum.ReverbType.NoReverb
		sServ.RolloffScale = 1
		uwBlur.Enabled = false
	end
end)