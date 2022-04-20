local Class = {}
Class.__index = Class

--[[**
	Creates a new instance

	@returns The new instance
**--]]
function new()
	local self = setmetatable({}, Class)

	self._bindableEvent = Instance.new("BindableEvent")
	self._connections = {}

	return self
end

--[[**
	Destroys the event, disconnecting all connections and removing the BindableEvent instance
**--]]
function Class:Destroy()
	self:DisconnectAll()
	self._bindableEvent:Destroy()
	self._bindableEvent = nil

	self.__call = function ()
		error("Object is destroyed")
	end
end

--[[**
	Connect a function to when this event is fired

	@param handlerFunction The function to be connected

	@returns A new RBXScriptSignal object representing the connection
**--]]
function Class:Connect(handlerFunction)
	assert(type(handlerFunction) == "function", "Handler must be a function")

	local connection = self._bindableEvent.Event:Connect(handlerFunction)

	table.insert(self._connections, connection)

	return connection
end

--[[**
	Disonnects a RBXScriptSignal from this event

	@param connection The RBXScriptSignal that is to be disconnected
**--]]
function Class:Disconnect(connection)
	connection:Disconnect()
end

--[[**
	Disconnects all connections to the event
**--]]
function Class:DisconnectAll()
	for _, conn in ipairs(self._connections) do
		conn:Disconnect()
	end
	self._connections = {}
end

--[[**
	Yields until the event is fired
**--]]
function Class:Wait()
	self._bindableEvent.Event:Wait()
end

--[[**
	Fires the event with the given arguments

	@param ... The optional list of arguments to be given to each handler function
**--]]
function Class:Fire(...)
	self._bindableEvent:Fire(...)
end

--[[**
	Gets the actual Roblox event object for this event

	@returns The event object
**--]]
function Class:GetSignalInstance()
	return self._bindableEvent.Event
end

return {
	new = new
}
