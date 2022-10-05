function doTrash(can)
	can.Touched:connect(function(part)
		if part.Name == "Handle" and part.Parent.ClassName == "Tool" then
			part.Parent:Destroy()
		end
	end)
end

for _, v in pairs(workspace:WaitForChild("TrashCans"):GetChildren()) do
	doTrash(v.CanCollision)
end