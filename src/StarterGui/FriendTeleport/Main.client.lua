task.wait(3)
local guiMain = script.Parent

local player = game.Players.LocalPlayer
local char = player.Character
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local camera = game.Workspace.CurrentCamera

local exGui = guiMain:WaitForChild("FriendTele")


function tagPlayer(targetPlayer)
	if targetPlayer ~= player and player:IsFriendsWith(targetPlayer.UserId) then
		local trgChar = targetPlayer.Character
		local trgHrp = trgChar:WaitForChild("HumanoidRootPart")
		local trgHum = trgChar:WaitForChild("Humanoid")
		local deadConnect = false
		
		local bbg = exGui:Clone()
		bbg.Parent = guiMain
		bbg.Adornee = trgHrp
		bbg.Enabled = true
		
		bbg.Button.playerIMG.Image = game.Players:GetUserThumbnailAsync(targetPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		
		trgHum.Died:connect(function()
			bbg:Destroy()
			deadConnect = true
		end)
		
		bbg.Button.MouseButton1Click:connect(function()
			if hum.Sit == false then
				hrp.CFrame = trgHrp.CFrame
			end
		end)
		
		game:GetService("RunService").RenderStepped:Connect(function()
			if deadConnect ~= true then
				bbg.Button.Visible = (camera.CFrame.Position - trgHrp.Position).Magnitude > 70
			end
		end)
	end
end


function handlePlr(plr)
	plr.CharacterAdded:connect(function()
		tagPlayer(plr)
	end)	
end

for _, v in pairs(game.Players:GetPlayers()) do
	tagPlayer(v)
	handlePlr(v)
end

game.Players.PlayerAdded:Connect(function(addedPlr)
	handlePlr(addedPlr)
end)
