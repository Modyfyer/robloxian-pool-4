wait(3)

Tool = script.Parent
Player = game.Players.LocalPlayer
Character = Player.Character
Humanoid = Character:WaitForChild("Humanoid")
Event = Tool:WaitForChild("DStickEvent")
Mouse = Player:GetMouse()

hold = Tool:WaitForChild("Hold")
throw = Tool:WaitForChild("Throw")
holdAnim = Humanoid:LoadAnimation(hold)
throwAnim = Humanoid:LoadAnimation(throw)


Debounce = false
thrown = false

local function onActivated()
	if Debounce == false then
		Debounce = true
		holdAnim:Play()
	end
end

local function onDeactivated()
	if Debounce == true and thrown == false then
		holdAnim:Stop()
		throwAnim:Play()
		Event:FireServer(Mouse.Hit.Position)
		thrown = true
		wait(5)
		Debounce = false
		thrown = false
	end
end

Tool.Activated:Connect(onActivated)
Tool.Deactivated:Connect(onDeactivated)