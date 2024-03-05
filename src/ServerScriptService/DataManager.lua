-- Services
--local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager).new()
local ProfileService = require(ServerScriptService.ProfileService)

-- Types
export type DataTemplate = {
  poolPoints: number,
  items: {},
  daysLoggedIn: number
}

-- Declarations
local PLAYER_DATA_KEY: string = "Player_"
local PLAYER_DATA_STORE_NAME: string = if RunService:IsStudio() then "Player_data_studio" else "Player_data_live"

local ProfileTemplate: DataTemplate = {
  poolPoints = 0,
  items = {},
  daysLoggedIn = 0,
}

local BindableEvents: Folder = ReplicatedStorage:WaitForChild("BindableEvents")
local RemoteEvents: Folder = ReplicatedStorage:WaitForChild("RemoteEvents")

--Module
local DataManager = {}
DataManager.template = ProfileTemplate
DataManager.playerDataKey = PLAYER_DATA_KEY
DataManager.playerDataStoreName = PLAYER_DATA_STORE_NAME

----- Private Variables -----
local Profiles: {[Player]: DataTemplate} = {}

----- Private Functions -----
local function onLoadedProfile(player: Player, profile: DataTemplate)
  BindableEvents.ProfileLoaded:Fire(profile.Data)
  RemoteEvents.ProfileLoaded:FireClient(player, profile.Data)
  print(profile.Data)
end

local function loadPlayerData(player: Player)
  local profile = nil

  if ProfileService.ServiceLocked then -- Server is shutting down
    player:Kick()
  end

  local ProfileStore = ProfileService.GetProfileStore(
    PLAYER_DATA_STORE_NAME,
    ProfileTemplate
  )

  local success, err = pcall(function()
      profile = ProfileStore:LoadProfileAsync(PLAYER_DATA_KEY .. player.UserId)
  end)

  if success and profile and profile.Data then
      profile:AddUserId(player.UserId) -- GDPR compliance
      profile:Reconcile() -- Fill in missing variables from ProfileTemplate
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
      profile:Release()
  else
    warn("Unable to find profile for", player.UserId)
  end
end

----- Public Functions -----
function DataManager.getProfile(player: Player): DataTemplate?
  local profile = Profiles[player]
  if profile and profile.Data then
		return profile.Data
	end
  return
end

----- Initialize -----
function DataManager.new()
  for _, player: Player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
      loadPlayerData(player)
    end)
  end
end


----- Connections -----
ConnectionManager:ConnectToEvent(Players.PlayerAdded, function(player: Player)
  loadPlayerData(player)
end)

ConnectionManager:ConnectToEvent(Players.PlayerRemoving, function(player: Player)
  savePlayerData(player)
end)

return DataManager