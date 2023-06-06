local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local rgb = script.Parent:WaitForChild("RGB")
local preview = script.Parent:WaitForChild("Preview")

local selectedColor = Color3.fromHSV(1,1,1)
local colorData = {1,1,1}

event = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("UpdateColor")
toggle = script.Parent.Parent:WaitForChild("Toggle")

local mouse1down = false

local function setColor(hue,sat,val)
	colorData = {hue or colorData[1],sat or colorData[2],val or colorData[3]}
	selectedColor = Color3.fromHSV(colorData[1],colorData[2],colorData[3])
	preview.BackgroundColor3 = selectedColor
end

local function inBounds(frame)
	local x,y = mouse.X - frame.AbsolutePosition.X,mouse.Y - frame.AbsolutePosition.Y
	local maxX,maxY = frame.AbsoluteSize.X,frame.AbsoluteSize.Y
	if x >= 0 and y >= 0 and x <= maxX and y <= maxY then
		return x/maxX,y/maxY
	end
end

local function updateRGB()
	if script.Parent.Visible == true then
		if mouse1Down then
			local x,y = inBounds(rgb)
			if x and y then
				rgb:WaitForChild("Marker").Position = UDim2.new(x,0,y,0)
				setColor(1 - x,1 - y)
			end
		end
	end
end

mouse.Move:connect(updateRGB)

mouse.Button1Down:connect(function()mouse1Down = true end)
mouse.Button1Up:connect(function()
	if script.Parent.Visible == true then
		mouse1Down = false
		event:FireServer(selectedColor)
	end
end)

toggle.MouseButton1Click:Connect(function()
	script.Parent.Visible = not script.Parent.Visible
end)