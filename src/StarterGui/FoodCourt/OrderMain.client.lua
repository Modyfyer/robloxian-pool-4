guiMain = script.Parent.BG
left = guiMain.Left
right = guiMain.Right
order = guiMain.Order
selection = guiMain.Selection.FoodImage
orderEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("OrderFood")
hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
orderPart = workspace:WaitForChild("FoodOrder")

foods = game:GetService("ReplicatedStorage"):WaitForChild("Foods"):GetChildren()
selNum = 1

left.Activated:connect(function()
	if selNum == 1 then
		selNum = #foods
	else
		selNum -= 1
	end

	selection.Image = foods[selNum].TextureId
end)

right.Activated:connect(function()
	if selNum == #foods then
		selNum = 1
	else
		selNum += 1
	end

	selection.Image = foods[selNum].TextureId
end)

order.Activated:connect(function()
	orderEvent:FireServer(foods[selNum])
end)

game:GetService("RunService").RenderStepped:connect(function()
	if (hrp.Position - orderPart.Position).magnitude < 15 then
		guiMain.Visible = true
	else
		guiMain.Visible = false
	end
end)