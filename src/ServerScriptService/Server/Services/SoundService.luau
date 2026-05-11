-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Declarations
local ASSETS_FOLDER = ReplicatedStorage:WaitForChild("Assets") :: Folder
local SOUNDS_FOLDER = ASSETS_FOLDER:WaitForChild("Sounds") :: Folder
local SOUNDGROUPS_FOLDER = ASSETS_FOLDER:WaitForChild("SoundGroups") :: Folder

local SoundService = Knit.CreateService({
	Name = "SoundService",
	Client = { PlaySoundFor = Knit.CreateSignal() },
})

function SoundService:_setSoundGroup(container: Instance, soundGroup: SoundGroup)
	for _, item in container:GetDescendants() do
		if not item:IsA("Sound") then
			continue
		end
		if not item.SoundGroup then
			item.SoundGroup = soundGroup
		end
	end
end

function SoundService:PlaySoundFor(player: Player, sound: string)
	self.Client.PlaySoundFor:Fire(player, sound)
end

function SoundService:KnitInit()
	self._ambientFolder = Workspace:WaitForChild("AmbientSounds")
end

function SoundService:KnitStart()
	for _, part in ipairs(self._ambientFolder:GetChildren()) do
		if part:IsA("BasePart") then
			local ambience = part:FindFirstChild("Ambience")
			if ambience and ambience:IsA("Sound") then
				ambience:Play()
			end
		end
	end

	local musicFolder = SOUNDS_FOLDER:WaitForChild("Music") :: Folder
	local musicGroup = SOUNDGROUPS_FOLDER:WaitForChild("Music") :: SoundGroup

	local SFXFolder = SOUNDS_FOLDER:WaitForChild("SFX") :: Folder
	local SFXGroup = SOUNDGROUPS_FOLDER:WaitForChild("SFX") :: SoundGroup

	local UIFolder = SOUNDS_FOLDER:WaitForChild("UI") :: Folder
	local UIGroup = SOUNDGROUPS_FOLDER:WaitForChild("UI") :: SoundGroup

	self:_setSoundGroup(musicFolder, musicGroup)
	self:_setSoundGroup(SFXFolder, SFXGroup)
	self:_setSoundGroup(UIFolder, UIGroup)
end

return SoundService
