local sndfold = workspace:WaitForChild("AmbientSounds")

for _, v in pairs(sndfold:GetChildren()) do
	if v:IsA("BasePart") and v:FindFirstChild("Ambience") then
		v.Ambience:Play()
	end
end