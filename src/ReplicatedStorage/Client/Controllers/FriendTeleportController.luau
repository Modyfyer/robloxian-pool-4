-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local DISTANCE_VISIBILITY_THRESHOLD = 70

local FriendTeleportController = Knit.CreateController({
	Name = "FriendTeleportController",
})
FriendTeleportController._trove = Trove.new()
FriendTeleportController._playerBillboards = {}

function FriendTeleportController:KnitInit()
	self._character = Knit.Player.Character or Knit.Player:WaitForChild("Character")
	self._hrp = self._character:WaitForChild("HumanoidRootPart")
	self._humanoid = self._character:WaitForChild("Humanoid")
	self._camera = game.Workspace.CurrentCamera

	local playerGui = Knit.Player:WaitForChild("PlayerGui")
	local friendTeleportGui = playerGui:WaitForChild("FriendTeleport")
	self._guiTemplate = friendTeleportGui:WaitForChild("FriendTele")
end

function FriendTeleportController:KnitStart()
	local function tagPlayer(targetPlayer: Player)
		if targetPlayer == Knit.Player or not Knit.Player:IsFriendsWithAsync(targetPlayer.UserId) then
			return
		end

		local targetCharacter = targetPlayer.Character
		if not targetCharacter then
			return
		end

		local targetHrp = targetCharacter:WaitForChild("HumanoidRootPart")
		local targetHum = targetCharacter:WaitForChild("Humanoid")

		local billboard = self._guiTemplate:Clone()
		billboard.Parent = self._guiTemplate.Parent
		billboard.Adornee = targetHrp
		billboard.Enabled = true

		billboard.Button.playerIMG.Image = Players:GetUserThumbnailAsync(
			targetPlayer.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size420x420
		)

		self._playerBillboards[targetPlayer.UserId] = billboard

		-- Handle target player death
		local deathConnection
		deathConnection = self._trove:Connect(targetHum.Died, function()
			billboard:Destroy()
			self._playerBillboards[targetPlayer.UserId] = nil
			deathConnection:Disconnect()
		end)

		-- Handle teleport button click
		self._trove:Connect(billboard.Button.MouseButton1Click, function()
			if self._humanoid.Sit == false then
				self._hrp.CFrame = targetHrp.CFrame
			end
		end)

		-- Handle billboard visibility based on distance
		self._trove:Connect(RunService.RenderStepped, function()
			if billboard and billboard.Parent then
				local distance = (self._camera.CFrame.Position - targetHrp.Position).Magnitude
				billboard.Button.Visible = distance > DISTANCE_VISIBILITY_THRESHOLD
			end
		end)
	end

	local function handlePlayer(player: Player)
		-- Tag player on initial load
		if player ~= Knit.Player then
			tagPlayer(player)
		end

		-- Handle character respawns
		self._trove:Connect(player.CharacterAdded, function()
			tagPlayer(player)
		end)
	end

	-- Tag all existing players
	for _, player in pairs(Players:GetPlayers()) do
		handlePlayer(player)
	end

	-- Handle new players joining
	self._trove:Connect(Players.PlayerAdded, function(newPlayer)
		handlePlayer(newPlayer)
	end)

	-- Cleanup billboards when players leave
	self._trove:Connect(Players.PlayerRemoving, function(leavingPlayer)
		local billboard = self._playerBillboards[leavingPlayer.UserId]
		if billboard then
			billboard:Destroy()
			self._playerBillboards[leavingPlayer.UserId] = nil
		end
	end)

	-- Handle character respawn
	self._trove:Connect(Knit.Player.CharacterAdded, function(newCharacter)
		self._character = newCharacter
		self._hrp = newCharacter:WaitForChild("HumanoidRootPart")
		self._humanoid = newCharacter:WaitForChild("Humanoid")
	end)
end

return FriendTeleportController
