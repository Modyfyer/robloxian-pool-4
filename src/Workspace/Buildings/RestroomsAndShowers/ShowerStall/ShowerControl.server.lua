show = script.Parent
emit = show.ShowerHead.Head.Spout.Water
sound = show.ShowerHead.Head.Spout.Sound
click = show.Control.Click

on = false
deb = false

click.MouseClick:connect(function()
	if deb == false then
		deb = true
		if on == true then
			emit.Enabled = false
			sound:Stop()
			on = false
		else
			emit.Enabled = true
			sound:Play()
			on = true
		end
		wait(1)
		deb = false
	end
end)


