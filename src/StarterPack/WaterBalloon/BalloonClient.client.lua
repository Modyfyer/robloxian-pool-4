wait(3)

Tool = script.Parent
Player = game.Players.LocalPlayer
Character = Player.Character
Humanoid = Character:WaitForChild("Humanoid")
balloonEvent = Tool:WaitForChild("FireBalloon")
Mouse = Player:GetMouse()

Water = Character:WaitForChild("Water")
waterEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("WaterChange")

hold = Tool:WaitForChild("Hold")
throw = Tool:WaitForChild("Throw")
holdAnim = Humanoid:LoadAnimation(hold)
throwAnim = Humanoid:LoadAnimation(throw)


Debounce = false
thrown = false

local function onActivated()
	if Water.Value >= 20 then
		if Debounce == false then
			Debounce = true
			holdAnim:Play()
		end
	end
end

local function onDeactivated()
	if Water.Value >= 20 and Debounce == true and thrown == false then
		holdAnim:Stop()
		throwAnim:Play()
		balloonEvent:FireServer(Mouse.Hit.Position)
		waterEvent:FireServer(-20)
		thrown = true
		wait(5)
		Debounce = false
		thrown = false
	end
end

Tool.Activated:Connect(onActivated)
Tool.Deactivated:Connect(onDeactivated)