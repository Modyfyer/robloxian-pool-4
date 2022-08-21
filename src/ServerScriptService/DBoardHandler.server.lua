function handleDBoard(model)
	local boardModel = model:WaitForChild("Board")
	local board = boardModel:WaitForChild("Board")
	local sound = board:WaitForChild("Sound")
	local touch = model:WaitForChild("TouchDetector")

	local anim = boardModel:WaitForChild("Anim")
	local animControl = boardModel:WaitForChild("AnimationController")
	local animator = animControl:WaitForChild("Animator")

	local loadedAnim = animator:LoadAnimation(anim)

	local deb = false

	touch.Touched:connect(function(part)
		if deb == false then
			if game.Players:GetPlayerFromCharacter(part.Parent) then
				local player = game.Players:GetPlayerFromCharacter(part.Parent)
				local char = player.Character
				local hum = char:WaitForChild("Humanoid")

				if hum:FindFirstChild("JustJumped") then
					deb = true
					loadedAnim:Play()
					sound:Play()
					wait(3)
					deb = false
				end
			end
		end
	end)
end

for _, v in pairs(workspace.DivingBoards:GetChildren()) do
	handleDBoard(v)
end