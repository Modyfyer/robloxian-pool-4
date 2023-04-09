-- Services
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local playerDataStore = DataStoreService:GetDataStore("PlayerData")


--Functions
function savePoolPoints(player, poolPoints)
  local playerKey = tostring(player.UserId)
  playerDataStore:SetAsync(playerKey, {PoolPoints = poolPoints})
end

function getPoolPoints(player)
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

function addPoolPoints(player, points)
  local poolPoints = player:FindFirstChild("PoolPoints")
  if poolPoints then
    poolPoints.Value = poolPoints.Value + points
    savePoolPoints(player, poolPoints.Value)
  end
end

function deductPoolPoints(player, points)
  local poolPoints = player:FindFirstChild("PoolPoints")
  if poolPoints then
    poolPoints.Value = poolPoints.Value - points
    savePoolPoints(player, poolPoints.Value)
  end
end


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

-- ReplicatedStorage.RemoteEvents.getPoolPoints.OnServerInvoke:Connect(function(player: Player)
--   return getPoolPoints(player)
-- end)
