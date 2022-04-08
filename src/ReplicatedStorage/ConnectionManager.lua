--[[--<<---------------------------------------------------->>--
Module purpose: Handles connections

Functions:
-Reset()
-ConnectAll()
-DisconnectAll()
-AddConnectionData(event, handler)
-ConnectToEvent(event, handler)
-DisconnectAllConnectionsToEvent(event)
-RemoveAllConnectionDataToEvent(event)

--]]--<<---------------------------------------------------->>--

local Class = {}
Class.__index = Class

--[[**
	Creates a new instance

	@returns The new instance
**--]]
function new()
	local self = setmetatable({}, Class)

	self._connectionData = {}

	return self
end

--[[**
	Resets the instance by disconnecting all connections and clearing all connection data
**--]]
function Class:Reset()
	self:DisconnectAll()
	self._connectionData = {}
end

--[[**
	Connects all connection data into actual connections
**--]]
function Class:ConnectAll()
	for _, v in pairs(self._connectionData) do
		if not v.Connection or not v.Connection.Connected then
	    	v.Connection = v.Event:Connect(v.Handler)
		end
	end
end

--[[**
	Disconnects all active connections
**--]]
function Class:DisconnectAll()
	for _, v in pairs(self._connectionData) do
		if v.Connection and v.Connection.Connected then
	    	v.Connection:Disconnect()
			v.Connection = nil
		end
	end
end

--[[**
	Adds the connection data but does not connect the handler to the event

	@param event The event to connect to at a later point
	@param handler The handler function to connect to the event at a later point
**--]]
function Class:AddConnectionData(event, handler)
	table.insert(self._connectionData, { Event = event, Handler = handler })
end

--[[**
	Adds the connection data and connects the handler to the event

	@param event The event to connect to
	@param handler The handler function to connect to the event
**--]]
function Class:ConnectToEvent(event, handler)
	local connection = event:Connect(handler)
	table.insert(self._connectionData, { Connection = connection, Event = event, Handler = handler })
end

--[[**
	Disconnects all connections in this connection manager's data to the given event

	@param event The event to disconnect all from
**--]]
function Class:DisconnectAllConnectionsToEvent(event)
	for i = 1, #self._connectionData do
		local v = self._connectionData[i]

		if v.Event == event and v.Connection and v.Connection.Connected then
	    	v.Connection:Disconnect()
			v.Connection = nil
		end
	end
end

--[[**
	Disconnects all connections in this connection manager's data to the given event and removes their connection data

	@param event The event to disconnect all from
**--]]
function Class:RemoveAllConnectionDataToEvent(event)
	local indicesToRemove = {}

	for i = 1, #self._connectionData do
		local v = self._connectionData[i]

		if v.Event == event then
			table.insert(indicesToRemove, i)
		end
	end

	for i = #indicesToRemove, 1, -1 do
		local index = indicesToRemove[i]
		local v = self._connectionData[index]
		if v.Connection and v.Connection.Connected then
	    	v.Connection:Disconnect()
			v.Connection = nil
		end
		table.remove(self._connectionData, index)
	end
end

return {
	new = new
}
