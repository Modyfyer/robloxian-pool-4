trees = game.ServerStorage.Trees:GetChildren()
treeSpots = Workspace.TreeSpots

function placeTrees()
	if Workspace:FindFirstChild("Trees") then
		Workspace.Trees:Destroy()
	end

	local treeModel = Instance.new("Model", Workspace)
	treeModel.Name = "Trees"

	for _, v in pairs(treeSpots:GetChildren()) do
		v.Transparency = 1
		local tree = trees[math.random(1, #trees)]:Clone()
		tree.Parent = treeModel
		tree:SetPrimaryPartCFrame(v.CFrame * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0) + Vector3.new(0, 0, 0))
	end
end

placeTrees()