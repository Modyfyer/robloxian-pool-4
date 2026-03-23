-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- Declarations
local LeaderboardService = Knit.CreateService({
	Name = "LeaderboardService",
	Client = {},
	LeaderboardUpdated = Signal.new(),
})

local StatScreens = nil
local TimeStat = nil
local TimeGuiMain = nil
local TimeRow = nil

----- Private Functions -----
function LeaderboardService:_findUIElements()
	if StatScreens then
		return true
	end

	local success = pcall(function()
		StatScreens = workspace:WaitForChild("Buildings"):WaitForChild("EntranceBuilding"):WaitForChild("StatScreens")
		TimeStat = StatScreens:WaitForChild("TimeStat")
		TimeGuiMain = TimeStat:WaitForChild("Screen"):WaitForChild("TimeStat")
		TimeRow = TimeGuiMain:WaitForChild("Row")
	end)

	return success
end

function LeaderboardService:_clearLeaderboardRows()
	if not TimeGuiMain then
		return
	end

	for _, v in pairs(TimeGuiMain.Frame.ScrollingFrame:GetChildren()) do
		if v.Name == "Place" or v.Name == "PlayerName" or v.Name == "PlayerValue" then
			v:Destroy()
		end
	end
end

function LeaderboardService:_addRow(player: string, stat: number, place: number)
	if not TimeRow or not TimeGuiMain then
		return
	end

	local row = TimeRow:Clone()
	row.PlayerName.TextLabel.Text = player
	row.PlayerValue.TextLabel.Text = tostring(stat)
	row.Place.TextLabel.Text = tostring(place)

	for _, v in pairs(row:GetChildren()) do
		v.Parent = TimeGuiMain.Frame.ScrollingFrame
		v.Visible = true
	end
end

function LeaderboardService:_updateLeaderboard()
	if not TimeGuiMain then
		return
	end

	local playerData = {}

	-- Collect player data
	for _, v in pairs(Players:GetPlayers()) do
		if v:FindFirstChild("TimeSpent") then
			local dataPiece = { PlayerName = v.Name, PlayerData = v.TimeSpent.Value }
			table.insert(playerData, dataPiece)
		end
	end

	-- Sort by stat descending
	table.sort(playerData, function(a, b)
		return a.PlayerData > b.PlayerData
	end)

	-- Clear and rebuild leaderboard
	self:_clearLeaderboardRows()
	for i = 1, #playerData do
		local pd = playerData[i]
		self:_addRow(pd.PlayerName, pd.PlayerData, i)
	end

	self.LeaderboardUpdated:Fire(playerData)
end

----- Public Functions -----
function LeaderboardService:GetLeaderboard(): {}
	local playerData = {}

	for _, v in pairs(Players:GetPlayers()) do
		if v:FindFirstChild("TimeSpent") then
			local dataPiece = { PlayerName = v.Name, PlayerData = v.TimeSpent.Value }
			table.insert(playerData, dataPiece)
		end
	end

	table.sort(playerData, function(a, b)
		return a.PlayerData > b.PlayerData
	end)

	return playerData
end

----- Initialize -----
function LeaderboardService:KnitStart()
	Players.PlayerAdded:Connect(function(player: Player)
		if not player:FindFirstChild("TimeSpent") then
			local timeValue = Instance.new("NumberValue")
			timeValue.Name = "TimeSpent"
			timeValue.Parent = player
		end

		self:_updateLeaderboard()
	end)

	Players.PlayerRemoving:Connect(function()
		self:_updateLeaderboard()
	end)

	-- Update leaderboard every 60 seconds
	task.spawn(function()
		while task.wait(60) do
			for _, player in pairs(Players:GetPlayers()) do
				if player:FindFirstChild("TimeSpent") then
					player.TimeSpent.Value += 1
				end
			end
			self:_updateLeaderboard()
		end
	end)
end

function LeaderboardService:KnitInit()
	if self:_findUIElements() then
		self:_clearLeaderboardRows()
	else
		warn("LeaderboardService: Unable to find UI elements")
	end
end

return LeaderboardService
