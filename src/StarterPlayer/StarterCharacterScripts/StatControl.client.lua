pl = game.Players.LocalPlayer
ch = pl.Character
head = ch:WaitForChild("Head")
oxyVal = ch:WaitForChild("Oxygen")
oxyEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("OxygenChange")
waterVal = ch:WaitForChild("Water")
waterEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("WaterChange")
waterLevel = 28

while wait(1) do
	if head.Position.Y < waterLevel then
		if oxyVal.Value > 0 then
			oxyEvent:FireServer(-5)
		end
		if waterVal.Value < 100 then
			waterEvent:FireServer(5)
		end
	elseif head.Position.Y > waterLevel and oxyVal.Value < 100 then
		oxyEvent:FireServer(5)
	end
end