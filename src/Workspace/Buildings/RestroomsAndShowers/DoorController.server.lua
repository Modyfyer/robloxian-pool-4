function handleDoor(door)
    local click = door.Click
    local orgPos = door:GetPrimaryPartCFrame()
    local openPos = orgPos * CFrame.Angles(0, math.rad(-100), 0)
    local sound = door.Main.Effect
    local closed = true
    
    local deb = false
    
    click.MouseClick:connect(function()
        if deb == false then
            deb = true
            if closed == true then
                sound.PlaybackSpeed = 1
                sound:Play()
                door:SetPrimaryPartCFrame(openPos)
                closed = false
            else
                sound.PlaybackSpeed = .6
                sound:Play()
                door:SetPrimaryPartCFrame(orgPos)
                closed = true
            end
            task.wait(1)
            deb = false
        end
    end)
end

for _, v in pairs(script.Parent.Stalls:GetChildren()) do
    if v.Name == "StallDoor" then
        handleDoor(v)
    end
end