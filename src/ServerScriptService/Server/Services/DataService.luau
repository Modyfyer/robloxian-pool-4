-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules
local DataTypes = require(ServerScriptService.Data.DataTypes)
local Knit = require(ReplicatedStorage.Packages.Knit)
local ProfileService = require(ServerScriptService.Data.ProfileService)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- Declarations
local DataService = Knit.CreateService({
	Name = "DataService",
	Client = {
		ProfileLoaded = Knit.CreateSignal(),
	},
	ProfileLoaded = Signal.new(),
	PlayerDataKey = DataTypes.PlayerDataKey,
	PlayerDataStoreName = DataTypes.PlayerDataStoreName,
	Template = DataTypes.ProfileTemplate,
})

local Profiles: { [Player]: DataTypes.DataTemplate } = {}
----- Private Functions -----
function DataService:_onLoadedProfile(player: Player, profile)
	self.ProfileLoaded:Fire(player, profile.Data)
end

function DataService:_loadPlayerData(player: Player)
	local profile = nil

	if ProfileService.ServiceLocked then -- Server is shutting down
		player:Kick()
	end

	local ProfileStore = ProfileService.GetProfileStore(self.PlayerDataStoreName, self.Template)

	local success, err = pcall(function()
		profile = ProfileStore:LoadProfileAsync(self.PlayerDataKey .. player.UserId)
	end)

	if success and profile and profile.Data then
		profile:AddUserId(player.UserId)
		profile:Reconcile()
		profile:ListenToRelease(function()
			Profiles[player] = nil
			player:Kick()
		end)
		if player:IsDescendantOf(Players) then
			Profiles[player] = profile
			self:_onLoadedProfile(player, profile)
		--onLoadedProfile(player, profile)
		else
			profile:Release()
		end
	else
		player:Kick(`Error loading profile: {tostring(err)}`)
		warn("Unable to load profile for", player.Name, ":", tostring(err))
	end
end

function DataService:_savePlayerData(player: Player)
	local profile = Profiles[player]
	if profile ~= nil then
		print(`Saving data for {player.UserId}`)
		print(profile.Data)
		profile:Release()
	else
		warn("Unable to find profile for", player.UserId)
	end
end

----- Public Functions -----
function DataService:GetProfile(player: Player): any
	local profile = Profiles[player]
	if profile then
		return profile
	end
	return
end

function DataService:GetProfileData(player: Player): DataTypes.DataTemplate?
	local profile = Profiles[player]
	if profile and profile.Data then
		return profile.Data
	end
	return
end

function DataService:GetKey(player: Player, key: string): any
	local data = self:GetProfileData(player)
	if data then
		local tokens = string.split(key, ".")
		local pos = data
		for i, t in tokens do
			if pos[t] ~= nil then
				if i == #tokens then
					return pos[t]
				end
				pos = pos[t]
			end
		end
		error("Unable to find key " .. key)
	end
	return nil
end

function DataService:SetKey(player: Player, key: string, value: any): boolean
	local data = self:GetProfileData(player)
	if data then
		local tokens = string.split(key, ".")
		local pos = data
		for i, t in tokens do
			if pos[t] ~= nil then
				if i == #tokens then
					if typeof(value) == typeof(pos[t]) then
						pos[t] = value
						return true
					else
						warn("Set key types do not match!")
						return false
					end
				end
				pos = pos[t]
			end
		end
	else
		warn("Data not found")
	end
	return false
end

----- Initialize -----
function DataService:KnitStart()
	Players.PlayerAdded:Connect(function(player: Player)
		self:_loadPlayerData(player)
	end)
end

function DataService:KnitInit()
	for _, player: Player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			self:_loadPlayerData(player)
		end)
	end
end

return DataService
