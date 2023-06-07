Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Sound = Handle:WaitForChild("WhackNoise")
wAnim = Tool:WaitForChild("WhackAnim")
nAnim = Tool:WaitForChild("NoodleAnim")
anCont = Tool:WaitForChild("AnimationController")
animator = anCont:WaitForChild("Animator")

Player = nil
Char = nil
Humanoid = nil

noodleAnimation = animator:LoadAnimation(nAnim)
whackAnimation = nil

Deb = false

Tool.Equipped:Connect(function()
	if Tool.Parent.ClassName == "Model" and game.Players:GetPlayerFromCharacter(Tool.Parent) then
		Player = game.Players:GetPlayerFromCharacter(Tool.Parent)
		Char = Player.Character
		Humanoid = Char:WaitForChild("Humanoid")
		whackAnimation = Humanoid:LoadAnimation(wAnim)
	end
end)

Tool.Activated:connect(function()
	if Deb == false then
		Deb = true
		if whackAnimation ~= nil then
			noodleAnimation:Play()
			whackAnimation:Play()
		end
		
		wait(1.8)
		
		Deb = false
	end
end)

Handle.Touched:connect(function(part)
	if Deb == true then
		if game.Players:GetPlayerFromCharacter(part.Parent) then
			Sound:Play()
		end
	end
end)