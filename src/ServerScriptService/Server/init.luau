local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Server = {}

function Server:_initComponents(container: Instance)
	for _, instance in container:GetDescendants() do
		if instance:IsA("ModuleScript") and instance.Name:sub(#instance.Name - 8, #instance.Name) == "Component" then
			require(instance)
		end
	end
end

function Server:Initialize()
	self:Start()
end

function Server:Start()
	Knit.AddServices(script.Services)
	return Knit:Start()
		:andThenCall(self._initComponents, self, script.Components)
		:andThenCall(self._initComponents, self, ReplicatedStorage.Shared.Components)
end

return Server