local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = Players.LocalPlayer

local Client = {}

function Client:Init()
	self:Start():catch(function(err)
		Player:Kick("Could not connect to server")
		warn("Server did not start:\n" .. tostring(err))
	end)
end

function Client:_loadComponentsIn(container: Instance)
	for _, instance in container:GetDescendants() do
		if
			instance:IsA("ModuleScript")
			and (instance.Parent == container or instance.Name:sub(#instance.Name - 8, #instance.Name) == "Component")
		then
			require(instance)
		end
	end
end

function Client:Start()
	Knit.AddControllers(script.Controllers)
	return Knit:Start()
		:andThenCall(self._loadComponentsIn, self, script.Components)
		:andThenCall(self._loadComponentsIn, self, ReplicatedStorage.Shared.Components)
end

return Client
