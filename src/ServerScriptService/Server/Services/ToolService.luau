local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ToolService = Knit.CreateService({
	Name = "ToolService",
	Client = {
		PlaceTowel = Knit.CreateSignal(),
	},
})

function ToolService:KnitInit()
	self._towelTemplates = {}
end

function ToolService:RegisterTowelTemplates()
	local towelTemplates = ReplicatedStorage:WaitForChild("Tools"):WaitForChild("TowelModels")
	self._towelTemplates = towelTemplates:GetChildren()
end

function ToolService:_placeTowel(player)
	local character = player.Character
	if not character then
		return
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	if character:FindFirstChild("PoolTowel") then
		character.PoolTowel:Destroy()
		return
	end

	local color = character:FindFirstChild("Color")
	if not color then
		return
	end

	if #self._towelTemplates == 0 then
		warn("ToolService: no towel templates registered")
		return
	end

	local towelTemplate = self._towelTemplates[math.random(1, #self._towelTemplates)]
	if not towelTemplate then
		warn("ToolService: no towel template available")
		return
	end

	local towel = towelTemplate:Clone()
	towel.Name = "PoolTowel"
	towel.Parent = character
	towel.Color = color.Value

	for _, descendant in pairs(towel:GetDescendants()) do
		if descendant:IsA("Decal") and descendant.Color3 then
			descendant.Color3 = color.Value
		end
	end

	towel.CFrame = hrp.CFrame * CFrame.new(0, 0, -6)
	local towelOrientation = towel.Orientation

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { towel, character }

	local raycastResult = workspace:Raycast(towel.Position, Vector3.new(0, -1, 0) * 100, raycastParams)
	if raycastResult then
		local hitPos = raycastResult.Position
		local hitNormal = raycastResult.Normal
		local yOffset = towel.Size.Y / 2
		towel.CFrame = CFrame.new(hitPos + hitNormal * yOffset, hitPos)
		towel.Orientation = towelOrientation

		return true
	end
	return false
end

function ToolService.Client:PlaceTowel(player: Player)
	return ToolService:_placeTowel(player)
end

function ToolService:KnitStart()
	self:RegisterTowelTemplates()
end

return ToolService
