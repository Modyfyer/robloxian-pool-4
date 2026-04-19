-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local ShowerComponent = Component.new({
	Tag = "ShowerComponent",
})

function ShowerComponent:Construct()
	self._trove = Trove.new()
	self._showerHead = self.Instance:WaitForChild("ShowerHead")
	self._spout = self._showerHead:WaitForChild("Head"):WaitForChild("Spout")
	self._emit = self._spout:WaitForChild("Water")
	self._sound = self._spout:WaitForChild("Sound")
	self._click = self.Instance:WaitForChild("Control"):WaitForChild("Click")

	self._on = false
	self._debounce = false
end

function ShowerComponent:Start()
	self._trove:Connect(self._click.MouseClick, function()
		if self._debounce then
			return
		end

		Promise.resolve()
			:andThenCall(function()
				self._debounce = true
			end)
			:andThenCall(function()
				if self._on then
					self._emit.Enabled = false
					self._sound:Stop()
					self._on = false
				else
					self._emit.Enabled = true
					self._sound:Play()
					self._on = true
				end
			end)
			:andThenCall(Promise.delay, 1)
			:finallyCall(function()
				self._debounce = false
			end)
	end)
end

function ShowerComponent:Stop()
	self._trove:Destroy()
end

return ShowerComponent
