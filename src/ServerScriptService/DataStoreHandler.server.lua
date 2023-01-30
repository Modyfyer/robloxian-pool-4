local DataStoreService = game:GetService("DataStoreService")
local playerDataStore = DataStoreService:GetDataStore("PlayerData")

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

game.Players.PlayerAdded:Connect(function(player)
  local poolPoints = Instance.new("NumberValue")
  poolPoints.Name = "PoolPoints"
  poolPoints.Parent = player
  poolPoints.Value = getPoolPoints(player)
end)

game.Players.PlayerRemoving:Connect(function(player)
  local poolPoints = player:FindFirstChild("PoolPoints")
  if poolPoints then
    savePoolPoints(player, poolPoints.Value)
  end
end)

game.ReplicatedStorage.getPoolPoints.OnServerInvoke:Connect(function(player: Player)
  return getPoolPoints(player)
end)
