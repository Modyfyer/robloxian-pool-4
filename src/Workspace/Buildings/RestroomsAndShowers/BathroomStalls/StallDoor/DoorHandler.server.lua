door = script.Parent
click = door.Click
orgPos = door:GetPrimaryPartCFrame()
openPos = orgPos * CFrame.Angles(0, math.rad(-100), 0)
sound = door.Main.Effect
closed = true

deb = false

click.MouseClick:connect(function()
	if deb == false then
		deb = true
		if closed == true then
			sound.PlaybackSpeed = 1
			sound:Play()
			door:SetPrimaryPartCFrame(openPos)
			closed = false
		else
			sound.PlaybackSpeed = .6
			sound:Play()
			door:SetPrimaryPartCFrame(orgPos)
			closed = true
		end
		wait(1)
		deb = false
	end
end)


