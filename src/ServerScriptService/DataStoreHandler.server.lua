-- Services
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Modules
local ConnectionManager = require(ReplicatedStorage.ConnectionManager)

--Declarations
local playerDataStore = DataStoreService:GetDataStore("PlayerData")

type playerProfileDefault = {
  
}

--Functions
function savePoolPoints(player: Player, poolPoints: number)
  local playerKey = tostring(player.UserId)
  playerDataStore:SetAsync(playerKey, {PoolPoints = poolPoints})
end

function getPoolPoints(player: Player): number
  local playerKey = tostring(player.UserId)
  local success, playerData = pcall(function()
    return playerDataStore:GetAsync(playerKey)
  end)
  if success then
    return playerData.PoolPoints
  else
    return 0
  end
end

-- function addPoolPoints(player: Player, points)
--   local poolPoints = player:FindFirstChild("PoolPoints")
--   if poolPoints then
--     poolPoints.Value = poolPoints.Value + points
--     savePoolPoints(player, poolPoints.Value)
--   end
-- end

-- function deductPoolPoints(player: Player, points)
--   local poolPoints = player:FindFirstChild("PoolPoints")
--   if poolPoints then
--     poolPoints.Value = poolPoints.Value - points
--     savePoolPoints(player, poolPoints.Value)
--   end
-- end

--Events
Players.PlayerAdded:Connect(function(player)
  local poolPoints = Instance.new("NumberValue")
  poolPoints.Name = "PoolPoints"
  poolPoints.Parent = player
  poolPoints.Value = getPoolPoints(player)
end)

Players.PlayerRemoving:Connect(function(player)
  local poolPoints = player:FindFirstChild("PoolPoints")
  if poolPoints then
    savePoolPoints(player, poolPoints.Value)
  end
end)

ReplicatedStorage.RemoteEvents.getPoolPoints.OnServerEvent:Connect(function(player)
  return getPoolPoints(player)
end)
