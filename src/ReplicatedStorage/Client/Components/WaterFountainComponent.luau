local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)
local RunService = game:GetService("RunService")

local WaterFountainComponent = Component.new({
	Tag = "WaterFountainComponent",
})

function WaterFountainComponent:Construct()
	self._trove = Trove.new()

	self.fountain = self.Instance
	self.button = self.fountain.Button
	self.spout = self.fountain.Spout
	self.water = self.spout.Water
	self.wateron = false
	self.playerparts = {}
end

function WaterFountainComponent:getCharacters()
	self.playerparts = {}
	for _, v in pairs(game.Players:GetPlayers()) do
		if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			table.insert(self.playerparts, v.Character.HumanoidRootPart)
		end
	end
end

function WaterFountainComponent:shouldBeOn()
	for _, v in pairs(self.playerparts) do
		if (v.Position - self.button.Position).magnitude <= 2.5 then
			return true
		end
	end
	return false
end

function WaterFountainComponent:Start()
	self._trove:Connect(RunService.Heartbeat, function()
		self:getCharacters()
		if self:shouldBeOn() then
			self.water.Enabled = true
			if not self.wateron then
				self.wateron = true
				self.spout.Sound:Play()
			end
		else
			self.water.Enabled = false
			self.wateron = false
			self.spout.Sound:Stop()
		end
	end)
end

function WaterFountainComponent:Stop()
	self._trove:Destroy()
end

return WaterFountainComponent
