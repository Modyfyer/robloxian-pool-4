script.Parent.Touched:connect(function(p)
	local hum = p.Parent:FindFirstChild("Humanoid")
	if hum ~= nil then
		hum.Sit = true
	end
end)