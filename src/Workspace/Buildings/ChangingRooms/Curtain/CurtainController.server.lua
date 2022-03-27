curt = script.Parent
click = curt.Click
sound = curt.Effect

orgSize = curt.Size
orgPos = curt.CFrame

open = true

deb = false
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
		wait(2)
		deb = false
	end
end)