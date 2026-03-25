-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local VendingComponent = Component.new({
	Tag = "VendingComponent",
	Ancestors = { workspace },
})

function VendingComponent:Construct()
	self._trove = Trove.new()
	self._vendingTrove = Trove.new()

	if not self.Instance:IsA("Instance") then
		warn("VendingComponent is not a Instance")
		return
	end

	self.isVending = false
	self.machineSpawn = self.Instance.Spawn
	self.sound = self.machineSpawn.Vend
	self.buttons = {}

	for _, button in pairs(self.Instance:GetChildren()) do
		if button.Name == "Button" then
			table.insert(self.buttons, button)
			self._trove:Add(button)
		end
	end
end

function VendingComponent:_vendItem(player: Player, button)
	if self.isVending then
		return
	end

	self.isVending = true

	Promise.resolve()
		:andThenCall(function()
			button.BrickColor = BrickColor.new("Smoky grey")
			button.CFrame = button.CFrame * CFrame.new(0, 0, 0.08)
			button.Decal.Transparency = 0.5
		end)
		:andThenCall(self.sound.Play, self.sound)
		:andThenCall(function()
			local fakeSoda = ServerStorage:WaitForChild("SodaPack")[button.SodaType.Value]:Clone()
			fakeSoda.Parent = self.Instance
			fakeSoda.CFrame = self.machineSpawn.CFrame
			self._vendingTrove:Add(fakeSoda)
		end)
		:andThenCall(function()
			local tool = ServerStorage:WaitForChild("SodaTools")[button.SodaType.Value]:Clone()
			tool.Parent = player.Backpack
		end)
		:andThenCall(Promise.delay, 3)
		:andThenCall(function()
			button.BrickColor = BrickColor.new("Medium stone grey")
			button.CFrame = button.CFrame * CFrame.new(0, 0, -0.08)
			button.Decal.Transparency = 0
		end)
		:finallyCall(function()
			self.isVending = false
			self._vendingTrove:Clean()
		end)
end

function VendingComponent:Start()
	for i = 1, #self.buttons do
		local button = self.buttons[i]
		self._trove:Connect(button.Click.MouseClick, function(player: Player)
			self:_vendItem(player, button)
		end)
	end
end

function VendingComponent:Stop()
	self._trove:Destroy()
end

return VendingComponent
