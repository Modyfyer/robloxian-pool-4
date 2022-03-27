function handleCurtain(curt)
	local click = curt.Click
	local sound = curt.Effect

	local orgSize = curt.Size
	local orgPos = curt.CFrame

	local open = true

	local deb = false
	click.MouseClick:connect(function()
		if deb == false then
			deb = true
			if open == true then
				curt.Size = orgSize + Vector3.new(6, 0, 0)
				curt.CFrame = orgPos * CFrame.new(3, 0, 0)
				sound.PlaybackSpeed = .7
				sound:Play()
				open = false
			else
				curt.Size = orgSize
				curt.CFrame = orgPos
				sound.PlaybackSpeed = 1
				sound:Play()
				open = true
			end
			task.wait(2)
			deb = false
		end
	end)
end

for _, v in pairs(script.Parent:GetChildren()) do
	if v:IsA("BasePart") and v.Name == "Curtain" then
		handleCurtain(v)
	end
end