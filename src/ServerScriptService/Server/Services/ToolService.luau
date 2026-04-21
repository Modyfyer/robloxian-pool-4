-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local PlayerService

local ToolService = Knit.CreateService({
	Name = "ToolService",
	Client = {
		PlaceTowel = Knit.CreateSignal(),
		PlaceFloaty = Knit.CreateSignal(),
	},
})
ToolService._trove = Trove.new()

function ToolService:KnitInit()
	local toolsFolder = ReplicatedStorage:WaitForChild("Tools")
	self._towelFolder = toolsFolder:WaitForChild("TowelModels")
	self._floatyFolder = toolsFolder:WaitForChild("Floaties") :: Folder
	self._towelTemplates = {}
	self._floatyTemplates = {}
end

function ToolService:RegisterTowelTemplates()
	self._towelTemplates = self._towelFolder:GetChildren()
end

function ToolService:_placeFloaty(player: Player)
	local char = player.Character
	local existingFloaty = char:FindFirstChild("Floaty")
	if existingFloaty then
		local floatyKind = player:GetAttribute("FloatyType")
		if not floatyKind then
			return
		end

		local floatyModel = self._floatyFolder:FindFirstChild(floatyKind)
		if floatyModel then
			local floatyClone = floatyModel:Clone()
			floatyClone.Name = "Floaty"
			floatyClone.Parent = char
			floatyClone:SetPrimaryPartCFrame(char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -8))
		end
	else
		existingFloaty:Destroy()
	end
end

function ToolService:_placeTowel(player: Player)
	if #self._towelTemplates == 0 then
		warn("ToolService: no towel templates registered")
		return
	end

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
	end

	local color = character:FindFirstChild("Color")
	if not color then
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
	end
end

function ToolService:_getPlayerFromPart(part: BasePart): Player?
	local player: Player? = nil

	local partParent = part.Parent
	if partParent.ClassName == "Accessory" or partParent.ClassName == "Hat" then
		if partParent.Parent ~= workspace then
			player = Players:GetPlayerFromCharacter(partParent.Parent)
		end
	elseif partParent.ClassName == "Model" and Players:GetPlayerFromCharacter(part.Parent) then
		player = Players:GetPlayerFromCharacter(part.Parent)
	end

	return player
end

function ToolService:_fireWater(player: Player, part: BasePart)
	PlayerService:ChangeWater(player, -1)

	local foundPlayer: Player? = self:_getPlayerFromPart(part)
	if foundPlayer ~= nil then
		PlayerService:ChangeOxygen(foundPlayer, -5)
	end
end

function ToolService.Client:PlaceTowel(player: Player)
	ToolService:_placeTowel(player)
end

function ToolService.Client:PlaceFloaty(player: Player)
	ToolService:_placeFloaty(player)
end

function ToolService.Client:WaterFired(player: Player, part: BasePart)
	ToolService:_fireWater(player, part)
end

function ToolService:KnitStart()
	PlayerService = Knit.GetService("PlayerService")

	self:RegisterTowelTemplates()

	self._trove:Connect(Players.PlayerAdded, function(player)
		local FloatyTypeValue = Instance.new("StringValue")
		FloatyTypeValue.Name = "FloatyType"
		FloatyTypeValue.Value = "Default"
		FloatyTypeValue.Parent = player

		player:SetAttribute("FloatyType", "Default") -- TODO: read off player data
	end)
end

return ToolService
