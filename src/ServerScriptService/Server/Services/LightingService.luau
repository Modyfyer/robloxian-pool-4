-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- Service definition
local LightingService = Knit.CreateService({
	Name = "LightingService",
	Client = {
		TimeOfDayChanged = Knit.CreateSignal(),
	},
	TimeOfDayChanged = Signal.new(),
})

-- Constants
local DAY_START = 6.5
local DAY_END = 17.7
local currentTimeOfDay: string = "Day"
local isNight: boolean = false
local waitTime = 0.25

local function recursiveToggle(instance, predicate, action)
	for _, child in pairs(instance:GetChildren()) do
		if predicate(child) then
			action(child)
		end
		recursiveToggle(child, predicate, action)
	end
end

local function toggleLights(state: boolean)
	recursiveToggle(workspace, function(v)
		return v:IsA("Light") and v.Name == "NightLight"
	end, function(v)
		v.Enabled = state
	end)
end

local function toggleBulbs(state: boolean)
	recursiveToggle(workspace, function(v)
		return v:IsA("BasePart") and v:GetAttribute("IsBulb") == true
	end, function(v)
		v.Material = state and Enum.Material.Neon or Enum.Material.SmoothPlastic
	end)
end

local function toggleFlames(state: boolean)
	recursiveToggle(workspace, function(v)
		return v:IsA("ParticleEmitter") and v:GetAttribute("IsFlame") == true
	end, function(v)
		v.Enabled = state
	end)
end

local function toggleLightCones(state: boolean)
	recursiveToggle(workspace, function(v)
		return v:IsA("Beam") and v.Name == "LightCone"
	end, function(v)
		v.Enabled = state
	end)
end

local function toggleOutdoorAmb(state: string)
	local outdoorAmb = workspace:FindFirstChild("AmbientSounds")
	if not outdoorAmb then
		return
	end

	if state == "Day" then
		for _, sound in pairs(outdoorAmb:GetChildren()) do
			if sound:FindFirstChild("Night") then
				sound.Night:Stop()
			end
			if sound:FindFirstChild("Day") then
				sound.Day:Play()
			end
		end
	elseif state == "Night" then
		for _, sound in pairs(outdoorAmb:GetChildren()) do
			if sound:FindFirstChild("Day") then
				sound.Day:Stop()
			end
			if sound:FindFirstChild("Night") then
				sound.Night:Play()
			end
		end
	end
end

function LightingService:_broadcastTimeChanged()
	-- self.TimeOfDayChanged:Fire(currentTimeOfDay)
	-- self.Client.TimeOfDayChanged:Fire(currentTimeOfDay)
end

function LightingService:_setDay()
	currentTimeOfDay = "Day"
	isNight = false
	toggleLights(false)
	toggleBulbs(false)
	toggleFlames(false)
	toggleLightCones(false)
	toggleOutdoorAmb("Day")
	waitTime = 0.25
	self:_broadcastTimeChanged()
end

function LightingService:_setNight()
	currentTimeOfDay = "Night"
	isNight = true
	toggleLights(true)
	toggleBulbs(true)
	toggleFlames(true)
	toggleLightCones(true)
	toggleOutdoorAmb("Night")
	waitTime = 0.001
	self:_broadcastTimeChanged()
end

function LightingService:_setInitialTime()
	if Lighting.ClockTime >= DAY_START and Lighting.ClockTime < DAY_END then
		self:_setDay()
	else
		self:_setNight()
	end
end

function LightingService:_timeCycle()
	while true do
		task.wait(waitTime)

		Lighting.ClockTime = Lighting.ClockTime + 0.005
		if Lighting.ClockTime >= 24 then
			Lighting.ClockTime = 0
		end

		if Lighting.ClockTime >= DAY_END and not isNight then
			self:_setNight()
		elseif Lighting.ClockTime > DAY_START and Lighting.ClockTime < DAY_END and isNight then
			self:_setDay()
		end
	end
end

function LightingService:KnitStart()
	self:_setInitialTime()
	self:_timeCycle()
end

function LightingService:KnitInit()
	-- No special init required for LightingService
end

return LightingService
