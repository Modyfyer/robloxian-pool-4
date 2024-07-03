-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager).new()
local DataMigration = require(script.Parent.DataMigration)
local DataTypes = require(script.Parent.DataTypes)
local ProfileService = require(ServerScriptService.Data.ProfileService)

-- Declarations
local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")

--Module
local DataManager = {}
DataManager.template = DataTypes.ProfileTemplate
DataManager.playerDataKey = DataTypes.PlayerDataKey
DataManager.playerDataStoreName = DataTypes.PlayerDataStoreName

----- Private Variables -----
local Profiles: {[Player]: DataTypes.DataTemplate} = {}

----- Private Functions -----
local function onLoadedProfile(player: Player, profile: DataTypes.DataTemplate)
  BindableEvents.ProfileLoaded:Fire(player, profile.Data)
  RemoteEvents.ProfileLoaded:FireClient(player, profile.Data)
end

local function loadPlayerData(player: Player)
  local profile = nil

  if ProfileService.ServiceLocked then -- Server is shutting down
    player:Kick()
  end

  local ProfileStore = ProfileService.GetProfileStore(
    DataManager.playerDataStoreName,
    DataManager.template
  )

  local success, err = pcall(function()
      profile = ProfileStore:LoadProfileAsync(DataManager.playerDataKey .. player.UserId)
  end)

  if success and profile and profile.Data then
      profile:AddUserId(player.UserId) -- GDPR compliance
      profile:Reconcile() -- Fill in missing variables from ProfileTemplate
      --DataMigration.run(profile.Data)
      profile:ListenToRelease(function() --The profile could've been loaded on another Roblox server:
          Profiles[player] = nil
          player:Kick()
      end)
      if player:IsDescendantOf(Players) then -- Success
          Profiles[player] = profile
          onLoadedProfile(player, profile)
      else -- Player left before the profile loaded
          profile:Release()
      end
  else -- The profile couldn't be loaded possibly due to other Roblox servers trying to load this profile at the same time
      player:Kick("Error loading profile:", tostring(err))
      warn("Unable to load profile for", player.Name, ":", tostring(err))
  end
end

local function savePlayerData(player: Player)
  local profile = Profiles[player]
  if profile ~= nil then
      print("Saving data for", player.UserId)
      print(profile.Data)
      profile:Release()
  else
    warn("Unable to find profile for", player.UserId)
  end
end

----- Public Functions -----
function DataManager.getProfile(player: Player): any
  local profile = Profiles[player]
  if profile then
		return profile
	end
  return
end

function DataManager.getProfileData(player: Player): DataTypes.DataTemplate?
  local profile = Profiles[player]
  if profile and profile.Data then
		return profile.Data
	end
  return
end

function DataManager.getKey(player: Player, key: string): any
	local data = DataManager.getProfileData(player)
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

function DataManager.setKey(player: Player, key: string, value: any): boolean
	local data = DataManager.getProfileData(player)
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
function DataManager.new()
  task.spawn(function()
    for _, player: Player in ipairs(Players:GetPlayers()) do
      task.spawn(function()
        loadPlayerData(player)
      end)
    end
  end)
end

----- Connections -----
ConnectionManager:ConnectToEvent(Players.PlayerAdded, function(player: Player)
  loadPlayerData(player)
end)

ConnectionManager:ConnectToEvent(Players.PlayerRemoving, function(player: Player)
  savePlayerData(player)
end)

return DataManager