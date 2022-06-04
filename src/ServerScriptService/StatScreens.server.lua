local statScreens = workspace:WaitForChild("Buildings"):WaitForChild("EntranceBuilding"):WaitForChild("StatScreens")
local timeStat = statScreens:WaitForChild("TimeStat")

local timeGuiMain = timeStat:WaitForChild("Screen"):WaitForChild("TimeStat")
local timeRow = timeGuiMain:WaitForChild("Row")

function addRow(gui, player, stat, place)
	local row = timeRow:Clone()
	row.PlayerName.TextLabel.Text = player
	row.PlayerValue.TextLabel.Text = stat
	row.Place.TextLabel.Text = place
	
	for _, v in pairs(row:GetChildren()) do
		v.Parent = gui
		v.Visible = true
	end
end

function updateTimeStat()
	local playerData = {}

	for _, v in pairs(timeGuiMain.Frame.ScrollingFrame:GetChildren()) do
		if v.Name == "Place" or v.Name == "PlayerName" or v.Name == "PlayerValue" then
			v:Destroy()
		end
	end

	for _, v in pairs(game.Players:GetPlayers()) do
		if v:FindFirstChild("TimeSpent") then
			local dataPiece = {PlayerName = v.Name, PlayerData = v.TimeSpent.Value}
			table.insert(playerData, dataPiece)
		end
	end

	table.sort(playerData, function(a, b)
		return a.PlayerData > b.PlayerData
	end)

	for i = 1, #playerData do
		local pd = playerData[i]
		addRow(timeGuiMain.Frame.ScrollingFrame, pd.PlayerName, pd.PlayerData, i)
	end
end

game.Players.PlayerAdded:Connect(function(player)
	local timeValue = Instance.new("NumberValue", player)
	timeValue.Name = "TimeSpent"
	
	pcall(function()
		while task.wait(60) do
			timeValue.Value += 1
			updateTimeStat()
		end
	end)
	updateTimeStat()
end)