--[[--<<---------------------------------------------------->>--
Module purpose: Makes common UI functions easy to use in any file

--]]--<<---------------------------------------------------->>--

local Helpers = {}

function Helpers.DisplayErrorMessage(displayTime, message, alertsScreen)
	local errorUI = alertsScreen.ErrorAlert

	task.spawn(function()
		alertsScreen.Visible = true
		errorUI.Description.Text = message
		errorUI.Visible = true

		task.wait(displayTime)

		alertsScreen.Visible = false
		errorUI.Visible = false
	end)
end

function Helpers.PlaySoundByName(soundName, soundsFolder)
	local soundInstance = soundsFolder:FindFirstChild(soundName)
	assert(soundInstance, string.format("No sound found by the name %s", soundName))

	soundInstance:Play()
end

function Helpers.PlaySoundByNameAfterWait(soundName, soundsFolder)
	local soundInstance = soundsFolder:FindFirstChild(soundName)
	assert(soundInstance, string.format("No sound found by the name %s", soundName))
	if not soundInstance.IsLoaded then
		soundInstance.Loaded:wait()
	end
	soundInstance:Play()
end
function Helpers.PlaySoundByNameASync(soundName, soundsFolder)
	local soundInstance = soundsFolder:FindFirstChild(soundName)
	assert(soundInstance, string.format("No sound found by the name %s", soundName))
	soundInstance:Play()
	soundInstance.Ended:Wait()
end

function Helpers.StopSoundByName(soundName, soundsFolder)
	local soundInstance = soundsFolder:FindFirstChild(soundName)
	assert(soundInstance, string.format("No sound found by the name %s", soundName))

	soundInstance:Stop()
end

function Helpers:SetupViewport(viewportFrame : ViewportFrame, item: Instance)
	local rootPart = nil
	if item:IsA("BasePart") then
		rootPart = item
	elseif item:IsA("Model") and item.PrimaryPart ~= nil then
		rootPart = item.PrimaryPart
	elseif item:FindFirstChild("Handle") then
		rootPart = item:FindFirstChild("Handle")
	else
		rootPart = item:FindFirstChildWhichIsA("BasePart")
	end

	if not rootPart then
		rootPart = {CFrame = CFrame.new(), Size = Vector3.new()}
	end

	local cam = viewportFrame:FindFirstChildOfClass("Camera") or Instance.new("Camera")
	cam.CameraType = Enum.CameraType.Scriptable

	local _, modelSize = if item:IsA("Model") then item:GetBoundingBox() else nil, rootPart.Size
	local cameraCFrame = rootPart.CFrame * CFrame.new(Vector3.new(-0.5, 0.4, -0.5).Unit * Helpers:GetCameraOffset(cam.FieldOfView, modelSize), Vector3.zero)

	local thumbnailConfig = item:FindFirstChild("ThumbnailConfiguration")
	if thumbnailConfig then
		rootPart = thumbnailConfig.ThumbnailCameraTarget.Value
		cameraCFrame = rootPart.CFrame * thumbnailConfig.ThumbnailCameraValue.Value
	end
	cam.CFrame = cameraCFrame
	cam.Parent = viewportFrame
	viewportFrame.CurrentCamera = cam
end

function Helpers:GetCameraOffset(fov, targetSize)
	local x, y, z = targetSize.x, targetSize.y, targetSize.Z
	local maxSize = math.sqrt(x^2 + y^2 + z^2)
	local fac = math.tan(math.rad(fov)/2)
	local depth = 0.5 * maxSize/fac
	return depth + maxSize/2
end

local function _formatTime(currentTime, isRacing)
	assert(type(currentTime) == "number", "Cannot format time: currentTime type: " .. type(currentTime))
	local formattedTime = "00:00:00"
	local currentHour = math.floor(currentTime/3600)
	local currentMinute = math.floor((currentTime%3600)/60)
	local currentSecond = math.floor(currentTime%60)

	if currentTime < 0 then
		return "--:--:--"
	end

	if currentHour < 10 and currentMinute < 10 and currentSecond < 10 then
		formattedTime = "0" .. currentHour .. ":" .. "0" .. currentMinute .. ":" .. "0" .. currentSecond
	elseif currentMinute < 10 and currentSecond < 10 then
		formattedTime = currentHour .. ":" .. "0" .. currentMinute .. ":" .. "0" .. currentSecond
	elseif currentMinute < 10 and currentHour < 10 then
		formattedTime = "0" .. currentHour .. ":" .. "0" .. currentMinute .. ":" .. currentSecond
	elseif currentHour < 10 and currentSecond < 10 then
		formattedTime = "0" .. currentHour .. ":" .. currentMinute .. ":" .. "0" .. currentSecond
	elseif currentHour < 10 then
		formattedTime = "0" .. currentHour .. ":" .. currentMinute .. ":" .. currentSecond
	elseif currentSecond < 10 then
		formattedTime = currentHour .. ":" .. currentMinute .. ":" .. "0" .. currentSecond
	elseif currentMinute < 10 then
		formattedTime = currentHour .. ":" .. "0" .. currentMinute .. ":" .. currentSecond
	else
		formattedTime = currentHour .. ":" .. currentMinute .. ":" .. currentSecond
	end

	if isRacing then
		local amount = currentTime - math.floor(currentTime)
		if amount > 0 then
			if amount < 0.1 then
				formattedTime = formattedTime .. ":0" .. string.sub(currentTime, string.len(currentTime))
			else
				formattedTime = formattedTime .. ":" .. string.sub(currentTime, string.len(currentTime) - 1)
			end
		else
			formattedTime = formattedTime .. ":00"
		end
	end

	if currentHour == 0 then
		formattedTime = string.sub(formattedTime, 4)
		if currentMinute == 0 then
			formattedTime = string.sub(formattedTime, 4)
			if currentSecond < 10 then
				formattedTime = string.sub(formattedTime, 2)
			end
		elseif currentMinute < 10 then
			formattedTime = string.sub(formattedTime, 2)
		end
	elseif currentHour < 10 then
		formattedTime = string.sub(formattedTime, 2)
	end

	return formattedTime
end

function Helpers:FormatTime(currentTime, isRacing)
	return _formatTime(currentTime, isRacing)
end

function Helpers.Debounce(func)
	local isRunning = false
	return function(...)
		if not isRunning then
			isRunning = true

			func(...)

			isRunning = false
		end
	end
end

function Helpers.OnMenuButtonClicked(menuOpen, menuClose, soundName, soundFolder)
	if soundName and soundFolder then
		Helpers.PlaySoundByName(soundName, soundFolder)
	end
	if menuOpen then
		menuOpen.Visible = true
	end
	if menuClose then
		menuClose.Visible = false
	end
end

return Helpers
