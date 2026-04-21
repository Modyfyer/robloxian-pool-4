-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Declarations
local CURSOR_IMAGE: string = "rbxasset://textures/cursors/CrossMouseIcon.png"

local ToolService = Knit.GetService("ToolService")

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
end

function WaterRifleComponent:Start()
	if RunService:IsServer() then
		self:StartServer()
	elseif RunService:IsClient() then
		self:StartClient()
	end
end

function WaterRifleComponent:StartServer()
	-- Server-side shoot handling
end

function WaterRifleComponent:RifleFired(part: BasePart, loc: CFrame)
	local atB = Instance.new("Attachment")
	atB.Position = part.CFrame:ToObjectSpace(loc).Position
	atB.Parent = part
	local beam = self.Handle:WaitForChild("Beam")
	local sound = self.Handle:WaitForChild("Sound")

	beam.Attachment1 = atB
	sound:Play()

	task.wait(0.2)
	atB:Destroy()
end

function WaterRifleComponent:StartClient()
	local LocalPlayer: Player = Players.LocalPlayer
	local Character: Model = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp: BasePart = Character:WaitForChild("HumanoidRootPart") :: BasePart
	local Mouse: Mouse = LocalPlayer:GetMouse()

	self._trove:Connect(self.Instance.Equipped, function()
		Mouse.Icon = CURSOR_IMAGE
	end)

	self._trove:Connect(self.Instance.Unequipped, function()
		Mouse.Icon = ""
	end)

	local debounce: boolean = false

	local function onActivated()
		if debounce then
			return
		end
		local Water = LocalPlayer:GetAttribute("Water")
		if Water > 0 then
			debounce = true
			while debounce and Water > 0 do
				task.wait(0.2)
				if (Mouse.Target ~= nil) and ((hrp.Position - Mouse.Hit.Position).Magnitude < 30) then
					self:RifleFired(Mouse.Target, Mouse.Hit)
					ToolService:WaterFired(Mouse.Target)
					Water = LocalPlayer:GetAttribute("Water")
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
end

function WaterRifleComponent:Stop()
	self._trove:Destroy()
end

return WaterRifleComponent
