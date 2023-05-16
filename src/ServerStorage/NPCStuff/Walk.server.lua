local NPCNodes = game.Workspace.NPCNodes
local character = script.Parent

local nodes = {}

for i, node in pairs(NPCNodes:GetChildren()) do
	if node:IsA("BasePart") then
		table.insert(nodes, node)
	end
end

-- Sort the nodes numerically based on their names
table.sort(nodes, function(a, b)
	return tonumber(a.Name) < tonumber(b.Name)
end)

local currentNode = 1
local goalNode = 2

character:SetPrimaryPartCFrame(nodes[currentNode].CFrame)

while true do
	-- Start walking to the goal node
	character.Humanoid:MoveTo(nodes[goalNode].Position)

	-- Cast a ray from the character's humanoid root part
	local ray = Ray.new(character.HumanoidRootPart.Position, character.HumanoidRootPart.CFrame.lookVector * 3)
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}
	local hit, pos = workspace:Raycast(ray.Origin, ray.Direction, rayParams)

	-- If the raycast result shows a part within 3 meters, set the humanoid's jump property to true
	if hit then
		character.Humanoid.Jump = true
	end

	-- Calculate the distance to the next node
	local distance = (nodes[goalNode].Position - character.HumanoidRootPart.Position).Magnitude

	-- Check if the character is within 4.5 units of the next node
	if distance < 4.5 then
		-- Update the current and goal nodes
		currentNode = goalNode
		goalNode = goalNode + 1
		if goalNode > #nodes then
			goalNode = 1
		end
	end

	wait()
end
