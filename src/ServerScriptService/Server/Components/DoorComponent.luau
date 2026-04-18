-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local DoorComponent = Component.new({
	Tag = "DoorComponent",
})

function DoorComponent:Construct()
	self._trove = Trove.new()
	self._click = self.Instance:WaitForChild("Click")
	self._sound = self.Instance.Main:WaitForChild("Effect")

	-- Store door positions
	self._orgPos = self.Instance:GetPrimaryPartCFrame()
	self._openPos = self._orgPos * CFrame.Angles(0, math.rad(-100), 0)

	self._closed = true
	self._debounce = false
end

function DoorComponent:Start()
	self._trove:Connect(self._click.MouseClick, function()
		if self._debounce then
			return
		end

		Promise.resolve()
			:andThenCall(function()
				self._debounce = true
			end)
			:andThenCall(function()
				if self._closed then
					self._sound.PlaybackSpeed = 1
					self._sound:Play()
					self.Instance:SetPrimaryPartCFrame(self._openPos)
					self._closed = false
				else
					self._sound.PlaybackSpeed = 0.6
					self._sound:Play()
					self.Instance:SetPrimaryPartCFrame(self._orgPos)
					self._closed = true
				end
			end)
			:andThenCall(Promise.delay, 1)
			:finallyCall(function()
				self._debounce = false
			end)
	end)
end

function DoorComponent:Stop()
	self._trove:Destroy()
end

return DoorComponent
