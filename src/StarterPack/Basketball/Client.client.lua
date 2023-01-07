local Tool = script.Parent
local event = Tool:WaitForChild("dest")
local mouse = nil

function onActivated()
	if mouse ~= nil then
		event:FireServer(mouse.Hit.p)
	end
end

function onEquip()
	mouse = game.Players.LocalPlayer:GetMouse()
	mouse.Icon = "http://www.roblox.com/asset/?id=12074918065"
end

function onUnequip()
	mouse.Icon = ""
	mouse = nil
end

Tool.Activated:Connect(onActivated)
Tool.Equipped:Connect(onEquip)
Tool.Unequipped:Connect(onUnequip)
