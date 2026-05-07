-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)

-- Declarations
local SOUNDS_FOLDER = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Sounds") :: Folder

local DEFAULT_VOLUME = 0.5

local SoundController = Knit.CreateController({
	Name = "SoundController",
})
SoundController.CurrentMusic = nil :: Sound?
SoundController.SoundsByName = {} :: { [string]: Sound }

function SoundController:_getSoundsByName()
	for _, sound in pairs(SOUNDS_FOLDER:GetDescendants()) do
		if not sound:IsA("Sound") then
			continue
		end
		self.SoundsByName[sound.Name] = sound
	end
end

function SoundController:PlaySound(soundName: string, volume: number?)
	assert(soundName, "Unable to play sound: no sound name provided")

	local sound = self.SoundsByName[soundName]
	sound.Volume = volume or DEFAULT_VOLUME
	sound.Looped = true

	sound:Stop()
	sound:Play()

	return Promise.fromEvent(sound.Ended)
end

function SoundController:StopSound(soundName: string)
	assert(soundName, "Unable to stop sound: no sound name provided")

	local sound = self.SoundsByName[soundName]
	sound:Stop()
end

function SoundController:PlayMusic(soundName: string, volume: number?)
	assert(soundName, "Unable to play sound: no sound name provided")

	local sound = self.SoundsByName[soundName]
	sound.Volume = volume or DEFAULT_VOLUME
	sound.Looped = true

	if self.CurrentMusic then
		self.CurrentMusic:Stop()
	end

	self.CurrentMusic = sound
	self.CurrentMusic:Play()
end

function SoundController:StopMusic()
	if self.CurrentMusic then
		self.CurrentMusic:Stop()
	end
end

function SoundController:KnitStart() end

function SoundController:KnitInit()
	self:_getSoundsByName()
end

return SoundController
