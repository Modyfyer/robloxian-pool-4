local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local TrashComponent = Component.new({
	Tag = "TrashComponent",
})

function TrashComponent:Construct()
	self._trove = Trove.new()

	if not self.Instance:IsA("Model") then
		warn("TrashComponent is not a Model")
		return
	end

	self._canCollision = self.Instance:WaitForChild("CanCollision") :: BasePart
end

function TrashComponent:Start()
	self._trove:Connect(self._canCollision.Touched, function(part)
		if part.Name == "Handle" and part.Parent.ClassName == "Tool" then
			part.Parent:Destroy()
		end
	end)
end

function TrashComponent:Stop()
	self._trove:Destroy()
end

return TrashComponent
