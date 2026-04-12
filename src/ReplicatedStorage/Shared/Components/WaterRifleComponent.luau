local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Component = require(ReplicatedStorage.Packages.Component)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)

local CURSOR_IMAGE: string = "rbxasset://textures/cursors/CrossMouseIcon.png"

local WaterRifleComponent = Component.new({
	Tag = "WaterRifleComponent",
})

function WaterRifleComponent:Construct()
	self._trove = Trove.new()

	if not self.Instance:IsA("Tool") then
		warn("WaterRifleComponent is not a Tool")
		return
	end

	self.Handle = self.Instance:WaitForChild("Handle")
	self.ShootEvent = Signal.new()
end

function WaterRifleComponent:Start()
	if RunService:IsServer() then
		self:StartServer()
	elseif RunService:IsClient() then
		self:StartClient()
	end

	self.ShootEvent:Connect(function(part: BasePart, loc: CFrame)
		self:OnServerShoot(part, loc)
	end)
end

function WaterRifleComponent:StartServer()
	-- Server-side shoot handling
end

function WaterRifleComponent:OnServerShoot(part: BasePart, loc: CFrame)
	local player = self:GetPlayerFromPart(part)
	if player then
		local watLev = player:GetAttribute("Water")
		watLev -= 1
	end

	local atB = Instance.new("Attachment")
	atB.Position = part.CFrame:ToObjectSpace(loc).Position
	atB.Parent = part
	local beam = self.Handle:WaitForChild("Beam")
	local sound = self.Handle:WaitForChild("Sound")

	beam.Attachment1 = atB
	sound:Play()

	-- TODO: use PlayerService
	-- if self:GetPlayerFromPart(part) ~= nil then
	-- 	local dedPlayer = self:GetPlayerFromPart(part)
	-- 	local oxy = dedPlayer.Character:FindFirstChild("Oxygen")

	-- 	if oxy ~= nil then
	-- 		oxy.Value = oxy.Value - 5
	-- 	end
	-- end

	task.wait(0.2)
	atB:Destroy()
end

function WaterRifleComponent:GetPlayerFromPart(part: BasePart): Player?
	local player: Player? = nil

	local partParent = part.Parent
	if partParent.ClassName == "Accessory" or partParent.ClassName == "Hat" then
		if partParent.Parent ~= workspace then
			player = Players:GetPlayerFromCharacter(partParent.Parent)
		end
	elseif partParent.ClassName == "Model" and Players:GetPlayerFromCharacter(part.Parent) then
		player = Players:GetPlayerFromCharacter(part.Parent)
	end

	return player
end

function WaterRifleComponent:StartClient()
	local LocalPlayer = Players.LocalPlayer
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = Character:WaitForChild("HumanoidRootPart")
	local Mouse: Mouse = LocalPlayer:GetMouse()
	local Water = LocalPlayer:GetAttribute("Water")

	self.Instance.Equipped:Connect(function()
		Mouse.Icon = CURSOR_IMAGE
	end)

	self.Instance.Unequipped:Connect(function()
		Mouse.Icon = ""
	end)

	local debounce: boolean = false

	local function onActivated()
		if debounce == false and Water >= 1 then
			debounce = true
			while debounce and Water >= 1 do
				task.wait(0.2)
				if (Mouse.Target ~= nil) and ((hrp.Position - Mouse.Hit.Position).Magnitude < 30) and Water >= 1 then
					self.ShootEvent:Fire(Mouse.Target, Mouse.Hit)
					Water -= 1
				end
			end
		end
	end

	local function onDeactivated()
		if debounce then
			debounce = false
		end
	end

	self._trove:Connect(self.Instance.Activated, onActivated)
	self._trove:Connect(self.Instance.Deactivated, onDeactivated)
	-- self._trove:Connect(Water.Changed, function()
	-- 	-- Water value changed
	-- end)
end

function WaterRifleComponent:Stop()
	self._trove:Destroy()
end

return WaterRifleComponent
