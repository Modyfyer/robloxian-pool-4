-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Packages
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- Data
local SharedSettings = require(ReplicatedStorage.Data.SharedSettings)

local DEFAULT_LABEL = "RENT THIS CABANA"
local DEFAULT_PROMPT = "Rent Cabana"

local CabanaComponent = Component.new({
	Tag = "CabanaComponent",
})

function CabanaComponent:Construct()
	self._trove = Trove.new()

	self._owner = ""
	self._rented = false
	self._index = nil :: number?
end

function CabanaComponent:_resetCabana()
	self.Instance:SetAttribute("Owner", "")
	self.Instance:SetAttribute("Rented", false)

	self._rented = false
	self._owner = ""

	self._statusGui.Frame.TextLabel.Text = DEFAULT_LABEL
	self._prompt.ActionText = DEFAULT_PROMPT
end

function CabanaComponent:Start()
	self._roof = self.Instance:FindFirstChild("Roof") :: BasePart?
	self._floor = self.Instance:FindFirstChild("Floor") :: BasePart?

	self._statusGui = self._roof:FindFirstChild("RentalStatusGui") :: GuiObject
	self._prompt = self._floor:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt

	self:_resetCabana()
end

function CabanaComponent:Stop()
	self._trove:Destroy()
end

return CabanaComponent
