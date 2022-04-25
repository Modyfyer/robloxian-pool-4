local trees = game.ServerStorage.Trees:GetChildren()
local treeSpots = workspace.TreeSpots

function placeTrees()
	if workspace:FindFirstChild("Trees") then
		workspace.Trees:Destroy()
	end

	local treeModel = Instance.new("Model")
	treeModel.Name = "Trees"
	treeModel.Parent = workspace

	for _, v in pairs(treeSpots:GetChildren()) do
		v.Transparency = 1
		local tree = trees[math.random(1, #trees)]:Clone()
		tree.Parent = treeModel
		tree:SetPrimaryPartCFrame(v.CFrame * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0) + Vector3.new(0, 0, 0))
	end
end

placeTrees()