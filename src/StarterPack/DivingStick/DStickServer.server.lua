Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Event = Tool:WaitForChild("DStickEvent")
power = 50 -- customizable variable for the amount of velocity power applied to the handle


function fireStick(target)
	Tool.Parent = workspace
	Handle.Position = Handle.Position + Vector3.new(0, .2, 0)
	local direction = (target - Handle.Position).Unit
	Handle.Velocity = direction * power
end

Event.OnServerEvent:Connect(function(player, targ)
	fireStick(targ)
end)